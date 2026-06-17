---
title: "CYBER LAB 7 - Windows Server 2022 Hardening"
parent: Labs
nav_order: 7
---

# CYBER LAB 7 - Windows Server 2022 Hardening
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 7 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Apply the Microsoft Security Compliance Toolkit (SCT) Windows Server 2022 baseline via LGPO
- Enable and configure Windows Defender Attack Surface Reduction (ASR) rules
- Configure Credential Guard via both GPO and PowerShell, and verify it is active
- Implement LAPS (Local Administrator Password Solution) for the local admin account
- Disable legacy protocols (SMBv1, NTLMv1, RC4 Kerberos) and verify via PowerShell
- Use Policy Analyzer to produce a before/after hardening delta report

---

## Tools Required

- Windows Server 2022 VM (with Active Directory from Lab 3)
- Microsoft Security Compliance Toolkit (download from microsoft.com/en-us/download)
- LGPO.exe (included in SCT)
- PowerShell 5.1+
- Windows LAPS (built into Windows Server 2022 - confirm with `Get-WindowsFeature LAPS`)

---

## Procedure

### Part 1 - SCT Baseline Application

1. Download and extract the Security Compliance Toolkit for Windows Server 2022.
2. Open **Policy Analyzer** and load the SCT baseline GPO:
   - **Add → File(s)** → navigate to `Windows Server 2022 Security Baseline\GPOs`
   - Compare against local settings - screenshot the delta (red items = local deviations from baseline)
3. Apply the baseline locally with LGPO:
   ```powershell
   cd "C:\SCT\Windows Server 2022 Security Baseline\Scripts"
   .\Baseline-LocalInstall.ps1
   ```
   If the script is not present, apply manually:
   ```powershell
   LGPO.exe /g ".\GPOs\Computer\"
   ```
4. Force a policy refresh and re-run Policy Analyzer to verify delta is reduced:
   ```powershell
   gpupdate /force
   ```
   Screenshot Policy Analyzer before and after - document which settings changed.

### Part 2 - Attack Surface Reduction (ASR) Rules

ASR rules block specific attack techniques at the kernel level. Configure them via PowerShell:

```powershell
# First, check current ASR status
Get-MpPreference | Select-Object AttackSurfaceReductionRules_Ids, AttackSurfaceReductionRules_Actions

# Enable ASR rules in Audit mode first (mode 2) - observe impact before blocking
$AuditRules = @(
  "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84",  # Block Office apps from creating child processes
  "3B576869-A4EC-4529-8536-B80A7769E899",  # Block Office apps from creating executable content
  "D4F940AB-401B-4EFC-AADC-AD5F3C50688A",  # Block Office apps from injecting code
  "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2",  # Block credential stealing from LSASS
  "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4",  # Block untrusted USB processes
  "26190899-1602-49E8-8B27-EB1D0A1CE869"   # Block Office comms app from creating child procs
)
foreach ($rule in $AuditRules) {
  Add-MpPreference -AttackSurfaceReductionRules_Ids $rule -AttackSurfaceReductionRules_Actions AuditMode
}

# After reviewing audit logs (Event ID 1121/1122 in Microsoft-Windows-Windows Defender/Operational),
# switch to Block mode for rules that have no false positives:
Add-MpPreference -AttackSurfaceReductionRules_Ids "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2" `
  -AttackSurfaceReductionRules_Actions Enabled   # LSASS credential theft: safe to block

# Verify
Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids
```

Test the LSASS protection rule: try to open LSASS with a tool like `procdump` or Task Manager → Create Dump File on lsass.exe. The blocked attempt should appear in Event Viewer under Windows Defender → Operational → Event ID 1121.

### Part 3 - Credential Guard

Credential Guard isolates NTLM hashes and Kerberos tickets in a hypervisor-protected process (VTL1). Without Credential Guard, these can be extracted by Mimikatz.

**Via PowerShell (preferred for automation):**
```powershell
# Prerequisite: check Secure Boot and UEFI are enabled
Confirm-SecureBootUEFI

# Enable VBS and Credential Guard
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
Set-ItemProperty -Path $regPath -Name EnableVirtualizationBasedSecurity -Value 1
Set-ItemProperty -Path $regPath -Name RequirePlatformSecurityFeatures -Value 1

$cgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $cgPath -Name LsaCfgFlags -Value 1   # 1 = enabled, 2 = UEFI lock

# Restart is required
# After restart, verify:
Get-WmiObject -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard |
  Select-Object SecurityServicesRunning
# SecurityServicesRunning = {1, 2} means VBS=1, Credential Guard=2
```

If the VM does not support nested virtualization (Credential Guard requires VT-x/AMD-V), document this limitation and explain what attack Credential Guard prevents (Pass-the-Hash, Pass-the-Ticket, Mimikatz sekurlsa::logonpasswords).

### Part 4 - LAPS (Local Administrator Password Solution)

Without LAPS, every Windows machine shares the same local admin password - compromise one, own all. LAPS generates unique, rotating passwords for each machine's local administrator.

```powershell
# LAPS is built into Windows Server 2022 (Windows LAPS)
# Check if it's available:
Get-Command Update-LapsADSchema -ErrorAction SilentlyContinue

# Extend AD schema for LAPS (requires Domain Admin - run on DC)
Update-LapsADSchema

# Grant the computer account permission to update its own LAPS password
Set-LapsADComputerSelfPermission -Identity "OU=Workstations,DC=lab,DC=local"

# Configure LAPS via GPO or registry (for lab, use registry directly):
$lapsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS"
New-Item -Path $lapsPath -Force
Set-ItemProperty -Path $lapsPath -Name BackupDirectory -Value 2   # 2 = Active Directory
Set-ItemProperty -Path $lapsPath -Name PasswordLength -Value 20
Set-ItemProperty -Path $lapsPath -Name PasswordComplexity -Value 4  # 4 = Large, small, numbers, specials
Set-ItemProperty -Path $lapsPath -Name PasswordAgeDays -Value 30

# Force LAPS to generate a password
Invoke-LapsPolicyProcessing

# Retrieve the password from AD (as Domain Admin)
Get-LapsADPassword -Identity $env:COMPUTERNAME -AsPlainText
```

Screenshot the generated LAPS password retrieved from AD.

### Part 5 - Disable Legacy Protocols

```powershell
# Disable SMBv1 (EternalBlue/WannaCry vector)
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol   # verify False

# Disable NTLMv1 (credential downgrade attack vector)
$secPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $secPath -Name LmCompatibilityLevel -Value 5
# 5 = Send NTLMv2 only, refuse LM and NTLMv1

# Disable RC4 Kerberos encryption (AS-REP roasting / Kerberoasting vector)
$kerbPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"
New-Item -Path $kerbPath -Force
Set-ItemProperty -Path $kerbPath -Name SupportedEncryptionTypes -Value 24
# 24 = AES128 + AES256 only (disable RC4/DES)

# Verify
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" | Select-Object LmCompatibilityLevel
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"

# Test SMB still works (should work - SMBv2/v3 is unaffected)
Get-SmbShare   # list shares
```

### Part 6 - Policy Analyzer Final Delta

Run Policy Analyzer one final time and compare against the initial screenshot from Part 1. The number of red (non-compliant) items should be significantly reduced. Document the remaining items and explain why each has not been addressed (e.g., requires reboot, requires additional infrastructure).

---

## Submission Requirements

- Policy Analyzer screenshot: before applying SCT baseline (showing deviations)
- Policy Analyzer screenshot: after applying SCT baseline (showing reduced deviations)
- ASR rules PowerShell output confirming rules are configured
- Event Viewer screenshot of ASR audit event (Event ID 1121 or 1122) from LSASS protection test
- Credential Guard: `Get-WmiObject Win32_DeviceGuard` output OR documented explanation of why it cannot run in your VM environment
- LAPS: `Get-LapsADPassword` output showing a generated password
- SMBv1/NTLMv1/RC4 disable verification screenshots
- Written reflection (3-4 sentences): Credential Guard is often described as "Mimikatz-resistant." Explain what Mimikatz does with LSASS, why Credential Guard prevents it, and what residual attack technique still works even WITH Credential Guard enabled.

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Windows Event Forwarding (WEF) Centralized Collection

Configure Windows Event Forwarding to centralize security events from your lab VM to a collector:

1. **Configure WinRM on all machines** (if not already enabled from AD setup):
   ```powershell
   winrm quickconfig -y
   winrm set winrm/config/client '@{TrustedHosts="*"}'
   ```

2. **On the collector (your Windows Server DC):** Create a new event subscription:
   ```powershell
   wecutil cs "C:\lab7-subscription.xml"
   ```
   Where `lab7-subscription.xml` defines:
   - Subscription name and type (Source Initiated)
   - Event queries for: Security log Event IDs 4624, 4625, 4648, 4672, 4720, 4732 (logon events, privilege use, group changes)
   - Delivery mode: Minimize Latency

3. **On the source (client/member server):** Register the subscription and configure the event log to forward:
   ```powershell
   winrm set winrm/config/client/auth '@{Kerberos="true"}'
   gpupdate /force
   ```

4. **Verify:** After 5 minutes, log out and back in on the source machine, then check the **Forwarded Events** log on the collector:
   ```powershell
   Get-WinEvent -LogName "ForwardedEvents" | Select-Object -First 5 | Format-List
   ```

Document the subscription XML, the verification event, and explain why centralizing Windows security events matters for incident response (what information is lost if logs are only stored locally on a compromised machine?).

---

[← Back to Labs]({{ site.baseurl }}/labs/)
