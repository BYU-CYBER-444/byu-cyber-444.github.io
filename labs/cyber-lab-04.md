---
title: "CYBER LAB 4 - Windows Server 2022 Hardening"
parent: Labs
nav_order: 4
---

# CYBER LAB 4 - Windows Server 2022 Hardening
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy the Microsoft Security Compliance Toolkit (SCT) baseline for Windows Server 2022 as real domain GPOs, linked at the domain root as the default for every device - not applied locally, one machine at a time.
- Verify six Windows Defender Attack Surface Reduction (ASR) rules enforced by that same domain policy.
- Disable SMBv1 and NTLMv1 via domain policy, and restrict endpoint Kerberos encryption to AES128/AES256 via a supplemental GPO.
- Go beyond the stock baseline: restrict incoming NTLM, apply a default-block host firewall (with explicit exceptions), enable PowerShell script block/module logging, and require Restricted Admin mode for incoming RDP.

---

## Tools and Environment

- Two instructor-provisioned VMs, both joined to `lab4.local`:
  - `cyber-lab04-dc` - the domain controller for `lab4.local`. This is where you **administer** the domain - GPO import/linking happens here, the way a real admin would manage AD/GPO centrally rather than configuring each machine by hand.
  - `cyber-lab04-win01` - Windows Server 2022, the hardening target. This is where you **test/verify** - everything Parts 2 and 3 check is effective state pulled down from the domain-wide policy you set up on the DC.
 - Your Net ID account and the semester lab password. The account is a lab Domain Admin account because the lab requires GPO and computer-object permissions.
- The Microsoft Security Compliance Toolkit staged on `cyber-lab04-win01` at `C:\SCT`:
  - `C:\SCT\LGPO\LGPO.exe`
  - `C:\SCT\Windows Server 2022 Security Baseline`
- PowerShell 5.1 or later and Event Viewer. `cyber-lab04-dc` already has the Active Directory/Group Policy PowerShell modules (built into every domain controller) - no extra features to install there.

> **Note on RDP access:** `cyber-lab04-dc` is reachable via RDP at `172.19.x.17`, and `cyber-lab04-win01` at `172.19.x.16` - where `x` is the third octet of your own nested subnet (the same one your `pve1`/`pve2`/`pve3` VMs live on). Connect using your OS's RDP client (Microsoft Remote Desktop on macOS, the built-in Remote Desktop Connection app on Windows, or Remmina/xfreerdp on Linux). Log in with your Net ID and the password emailed to you at the start of the semester. You might see a black screen for a minute or two the first time you connect while it sets up your profile. Both are domain-joined machines, so you'll need `lab4\<netid>` (not a bare netid) as the username when logging in.

---

## Background

Windows hardening is a layered defense. ASR rules restrict process behaviors used by ransomware and macro-based malware, and protocol restrictions reduce legacy downgrade and compatibility paths. Real organizations deliver controls like these centrally - GPOs linked at the domain level, applied fleet-wide by default - rather than configuring each machine by hand, which doesn't scale and drifts out of sync the moment someone forgets a step on one box. This lab does the same: every control here is linked at the **domain root** of `lab4.local` as the default policy for every device, imported from Microsoft's own SCT baseline plus one small supplemental GPO for the handful of settings that baseline doesn't cover. `cyber-lab04-dc`'s own settings are then specifically overridden where they need to differ by a Domain-Controller-specific GPO linked to the built-in `Domain Controllers` OU - more specific scope wins over the domain-wide default, without needing any security filtering. `cyber-lab04-win01` gets the domain-wide default like any other member server, plus two win01-only settings (the host firewall and Restricted Admin RDP), then the lab verifies the resulting effective state rather than relying only on successful command execution.

---

## Procedure

> **After finishing each part, run `gpupdate /force` on `cyber-lab04-win01`** (restart if asked) so the new policy is applied before you check it or move on.

### Part 1 - SCT Baseline Application

The baseline is applied at the **domain level**: linked at the domain root as the default policy for every device in `lab4.local`, and administered entirely from `cyber-lab04-dc`.

**On `cyber-lab04-dc`:**

1. Import the baseline's 8 GPOs into Active Directory as real domain GPOs (unlinked). `Baseline-ADImport.ps1` is the domain-level counterpart of `Baseline-LocalInstall.ps1`, which configures a single standalone machine. Two of the eight, the Credential Guard and Domain Controller Virtualization Based Security GPOs, are deliberately left unlinked in this lab.

   ```powershell
   Set-Location "C:\SCT\Windows Server 2022 Security Baseline\Scripts"
   .\Baseline-ADImport.ps1
   ```

2. Link the GPOs in **Group Policy Management**. Expand **Forest: lab4.local > Domains > lab4.local**.

   1. **Domain-wide default (5 GPOs):**

      - **MSFT Windows Server 2022 - Member Server**
      - **MSFT Windows Server 2022 - Domain Security**
      - **MSFT Windows Server 2022 - Defender Antivirus**
      - **MSFT Internet Explorer 11 - Computer**
      - **MSFT Internet Explorer 11 - User**

   2. **Domain Controller override (1 GPO):**

      - **MSFT Windows Server 2022 - Domain Controller**

   3. Verify: select the **`lab4.local`** node and open the **Linked Group Policy Objects** tab - it should list the 5 domain-wide GPOs. Select the **Domain Controllers** OU - it should list the DC GPO plus the built-in Default Domain Controllers Policy.

**On `cyber-lab04-win01`:**

3. Pull down the newly linked policy and restart if requested:

   ```powershell
   gpupdate /force
   ```

### Part 2 - Attack Surface Reduction Rules

ASR rules restrict process behaviors that ransomware and malicious macros rely on. The `MSFT Windows Server 2022 - Defender Antivirus` GPO you linked in Part 1 already enforces a set of them, including the LSASS credential-theft rule. Here you'll extend that domain-wide with your own GPO, `Lab4-ASR`, adding two rules the baseline doesn't set. Microsoft's [ASR rules reference](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference) lists every rule with its GUID.

**On `cyber-lab04-dc`:**

1. Create a new GPO called `Lab4-ASR`.

2. Right-click **`Lab4-ASR`** (under the domain node) > **Edit...**, then browse to **Computer Configuration > Policies > Administrative Templates > Windows Components > Microsoft Defender Antivirus > Microsoft Defender Exploit Guard > Attack Surface Reduction**. Open **Configure Attack Surface Reduction rules**, select **Enabled**, click **Show...** under Options, and add each of these rule IDs as a **Value name** with **Value** `1` (Block):

   | Rule ID (value name) | Rule |
   |---|---|
   | `A8F5898E-1DC8-49A9-9878-85004B8A61E6` | Block Webshell creation for Servers |
   | `56A863A9-875E-4185-98A7-B882C64B5CE5` | Block abuse of exploited vulnerable signed drivers |

   Also add `9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2` (Block credential stealing from LSASS) with Value `1`, so it stays enforced whichever GPO's rule list Windows ends up using (see step 3). Click **OK** twice to save.

3. Select the **`lab4.local`** node > **Linked Group Policy Objects** tab, select `Lab4-ASR`, and click the up arrow until its **Link Order** is `1`. When two GPOs set the same rule list, Windows may apply only the higher-precedence GPO's list instead of merging them, so this makes sure `Lab4-ASR` is the one that counts.

4. On `cyber-lab04-win01`, run `gpupdate /force`.


### Part 3 - Disable Legacy Protocols

Part 1's baseline already disables SMBv1 and limits NTLM to v2 only. The stock baseline doesn't restrict Kerberos to AES, so add that in a new domain-wide GPO named `Lab4-Supplemental`, which you'll also use in later parts.

**On `cyber-lab04-dc`:**

1. Create and link a new GPO called `Lab4-Supplemental`.
2. Edit **Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options > Network security: Configure encryption types allowed for Kerberos** to **AES128_HMAC_SHA1** and **AES256_HMAC_SHA1** only (leave DES, RC4 and Future encryption types unchecked).

### Part 4 - Restrict NTLM Authentication

Part 3 downgraded NTLM to v2-only, but a real hardened environment typically goes further and has servers refuse NTLM entirely for domain accounts, forcing Kerberos. This is the same "Network security: Restrict NTLM" Security Options family Part 3 already touches - added to the same `Lab4-Supplemental` GPO, domain-wide, since Kerberos already works correctly in this domain.

**On `cyber-lab04-dc`:**

1. Edit the GPO `Lab4-Supplemental`
2. Browse to **Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options**. Open **Network security: Restrict NTLM: Incoming NTLM traffic**, check **Define this policy setting**, choose **Deny all domain accounts**, and click **OK**.

This means domain accounts must use Kerberos to authenticate to this server; non-domain/local NTLM (if anything ever legitimately needs it) is left alone. **Deny all accounts** is the maximum setting but has a wider blast radius than this lab needs to risk.


### Part 5 - Windows Defender Firewall Baseline

Nothing in this lab has configured the host firewall yet. Unlike Parts 1 and 4, this is deliberately **not** applied to every device: a domain controller's firewall needs to stay wide open for AD replication, LDAP, Kerberos, DNS, and SMB, so blocking inbound-by-default for the whole domain would break `cyber-lab04-dc` itself. Instead, this GPO is limited with security filtering to exactly the one machine that should get a locked-down firewall, `cyber-lab04-win01`.

1. Create and link a new GPO called `Lab4-Win01-Firewall`.

2. Scope it to win01 only: select `Lab4-Win01-Firewall` under the domain node, and on the **Scope** tab under **Security Filtering**, select **Authenticated Users** and click **Remove**. Then click **Add...**, click **Object Types...**, check **Computers**, and add `cyber-lab04-win01` (its computer name is auto-generated and will be different for everyone). Confirm the filtering list shows only `cyber-lab04-win01`.

3. Edit the GPO and browse to **Computer Configuration > Policies > Windows Settings > Security Settings > Windows Defender Firewall with Advanced Security**. Right-click **Windows Defender Firewall with Advanced Security - LDAP://...** > **Properties**. On each of the **Domain Profile**, **Private Profile**, and **Public Profile** tabs, set **Firewall state** to **On (recommended)**, **Inbound connections** to **Block (default)**, and **Outbound connections** to **Allow (default)**. Click **OK**.

4. Under that node, right-click **Inbound Rules** > **New Rule...** and create the two rules below. They are **not optional** - without them you lose WinRM (grading connects over it) and RDP (how you access this machine at all) the moment this policy applies. Use the exact names, since grading looks the rules up by name.

   | Setting | Rule 1 | Rule 2 |
   |---|---|---|
   | **Name** | `Allow WinRM (grading/management)` | `Allow RDP` |
   | **Direction** | Inbound | Inbound |
   | **Rule type** | Port | Port |
   | **Protocol** | TCP | TCP |
   | **Local port** | Specific local port: `5985` | Specific local port: `3389` |
   | **Remote port / remote IP** | Any (leave defaults) | Any (leave defaults) |
   | **Action** | Allow the connection | Allow the connection |
   | **Profile** | Domain, Private and Public | Domain, Private and Public |
   | **Enabled** | Yes (the default) | Yes (the default) |


### Part 6 - PowerShell Script Block and Module Logging

Enhanced PowerShell logging is one of the highest-value, lowest-risk detection improvements you can make - it doesn't restrict anything, it just records what ran. Domain-wide via `Lab4-Supplemental` is safe here, including on `cyber-lab04-dc`.


**On `cyber-lab04-dc`:**

1. Edit the **`Lab4-Supplemental`** GPO and browse to **Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell**.
2. Open **Turn on PowerShell Script Block Logging**, select **Enabled**.
3. Open **Turn on Module Logging**, select **Enabled**, click **Show...** next to Module Names, enter `*` as the value.


### Part 7 - Require Restricted Admin Mode for Incoming RDP

**On `cyber-lab04-dc`:**


1. Edit the **`Lab4-Win01-Firewall`** GPO and browse to **Computer Configuration > Policies > Administrative Templates > System > Credentials Delegation**.
2. Open **Restrict delegation of credentials to remote servers**, select **Enabled**, set **Use the following restricted mode** to **Require Restricted Admin**, and click **OK**.


---

## Deliverables

Nothing to submit. Grading connects to `cyber-lab04-win01` directly over WinRM and checks its live state (registry values, `Get-MpPreference`, `Get-SmbServerConfiguration`, `Get-NetFirewallProfile`, `Get-NetFirewallRule`) - no screenshots or pasted command output to hand in. Just make sure the VM is left in its hardened end state when the deadline hits. Do not save credential dumps anywhere retrievable by others.

---

## Grading


| Item | What's actually checked | Points |
|------|--------------------------|--------|
| SCT baseline application (Part 1) | `LimitBlankPasswordUse = 1`, `NoLMHash = 1`, and `RequireSecuritySignature = 1` (the baseline's expected values) | 16 |
| ASR rules (Part 2) | Each of these rule IDs is present with action `Enabled` (partial credit: LSASS 5, Webshell 6, drivers 5): the LSASS-credential-theft rule (`9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2`) and your two custom rules, `A8F5898E-1DC8-49A9-9878-85004B8A61E6` (Webshell creation for Servers) and `56A863A9-875E-4185-98A7-B882C64B5CE5` (vulnerable signed drivers) | 16 |
| Legacy protocols disabled (Part 3) | SMBv1 disabled, `LmCompatibilityLevel = 5`, Kerberos `SupportedEncryptionTypes = 24` | 16 |
| NTLM restriction (Part 4) | `RestrictReceivingNTLMTraffic = 1` under `HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0` | 13 |
| Firewall baseline (Part 5) | Domain/Private/Public profiles enabled with `DefaultInboundAction = Block`, and explicit allow rules for WinRM (5985) and RDP (3389) both present and enabled | 13 |
| PowerShell logging (Part 6) | `EnableScriptBlockLogging = 1` and `EnableModuleLogging = 1` | 13 |
| Restricted Admin for RDP (Part 7) | `RestrictedRemoteAdministration = 1` under `HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation` | 13 |
| **Total** | | **100** |

---

## References

- [Microsoft Security Compliance Toolkit](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10)
- [ASR rules reference (all rules and GUIDs)](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)
- [Configure ASR rules](https://learn.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-attack-surface-reduction)
- [Detect and remediate RC4 usage in Kerberos](https://learn.microsoft.com/en-us/windows-server/security/kerberos/detect-remediate-rc4-kerberos)
- [Network security: Restrict NTLM](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-incoming-ntlm-traffic)
- [Windows Defender Firewall with Advanced Security GPO management](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/best-practices-configuring)
- [PowerShell Script Block Logging](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_windows?view=powershell-7.4#script-block-logging)
- [Restricted Admin Mode for RDP](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-restricted-admin)

[← Back to Labs]({{ site.baseurl }}/labs/)
