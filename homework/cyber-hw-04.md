---
title: "CYBER HW 4 - Windows Hardening Deep Dive"
parent: Homework
nav_order: 4
---
# CYBER HW 4 - Windows Hardening Deep Dive
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

This is a theoretical, written exercise - no VM, script, or lab environment required. You are given a [Windows Server 2022 Configuration Snapshot]({% link homework/description-files/cyber-hw-04-server-config.md %}): 20 findings from a config review of a production file/application server in its current, unhardened state. You will choose 15 of them, document the hardening for each, and analyze how those controls hold up against two real attack techniques.

### Part 1 - Hardening Controls Documentation (75 pts)

Choose **15 of the 20 findings** from the [Configuration Snapshot]({% link homework/description-files/cyber-hw-04-server-config.md %}) and document each as a complete hardening control record:

| Control # | CIS ID | DISA STIG Rule ID | Control Name | Default State | Hardened State | Implementation Method | Registry Path / GPO Path | How to Verify | Security Impact | Operational Impact |
|---|---|---|---|---|---|---|---|---|---|---|
| Ex. | CIS 2.3.7.1 *(example only - not one of the 20 findings; illustrates the expected format)* | WN22-SO-000200 | Interactive logon: Do not display last signed-in | Disabled (logon screen shows the last user's name) | Enabled (last signed-in username is hidden) | GPO: Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options > "Interactive logon: Do not display last signed-in" | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName = 1` | Read the registry value and confirm it equals `1` | Confidentiality - prevents username harvesting via shoulder-surfing or a photographed logon screen (T1589 - Gather Victim Identity Information) | Minor - users who rely on a pre-filled username at the logon screen must now type it themselves |

**Default State** for each control comes directly from the Configuration Snapshot - use the stated current value, don't invent a different one.

**Implementation method** must be one of: GPO (with the exact policy path), Registry key edit (with the key path and value), or Group Policy Preference.

**How to Verify** - describe precisely how you'd confirm the control is actually applied (e.g., the specific registry value and path to check, or the specific `Get-*`/`auditpol`/`gpresult` command and what output confirms compliance). Written description is fine - you are not submitting a script.

**Security Impact** must use CIA Triad framing: which of Confidentiality, Integrity, or Availability does this control protect, and against what specific attack technique (cite MITRE ATT&CK technique ID)?

**Operational Impact** - what breaks or changes for users when this control is applied? Who needs to be notified?

Your 15 controls must include at minimum: 3 credential protections, 3 network protections, 3 audit/logging controls, 2 application controls, and 2 attack surface reduction controls (the Configuration Snapshot's findings are grouped so you can identify which is which).

### Part 2 - Attack Scenario Analysis (15 pts)

For the following two attack techniques, analyze how your hardened controls would detect or prevent each:

**Technique 1: Pass-the-Hash (T1550.002)**
An attacker has dumped NTLM hashes from a workstation using Mimikatz and is attempting lateral movement to your Windows Server.

- Which of your 15 controls specifically prevent or detect this technique?
- What would the attacker see differently on a hardened system vs. an unprotected system?
- What Windows Security event IDs would be generated and what would they show?

**Technique 2: Scheduled Task Persistence (T1053.005)**
An attacker who has gained SYSTEM on one server is creating scheduled tasks to maintain persistence after reboots.

- Which of your controls prevent or detect this?
- How would you distinguish a malicious scheduled task from a legitimate administrative one in your audit logs?

### Part 3 - Compensating Controls (10 pts)

Two of your 15 hardening controls cannot be applied to a specific server because they break a legacy application that the vendor refuses to update. The controls are: SMBv1 disable and NTLM restriction.

Write a formal compensating control plan for each:
- What compensating control(s) replace the original control's security intent?
- Is the compensating control equivalent, stronger, or weaker? Justify.
- What additional monitoring do you implement to detect exploitation of the known-weak configuration?
- What is your remediation timeline and who accepts the residual risk?

---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-04.md`.

Open a PR titled `Grade: cyber-hw-04 - Windows Hardening` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| 15 controls - CIS ID, STIG ID, registry/GPO path, ATT&CK mapping | 75 |
| Attack scenario analysis - specific event IDs, control mapping | 15 |
| Compensating controls - equivalent intent, monitoring added | 10 |

---

## Tip

{: .tip }
When writing your "How to Verify" column, favor a specific registry value or a named `Get-*`/`auditpol` command over "check in the GUI" - it's more precise, and it's exactly the kind of detail a real audit checklist needs even without an actual script attached.

---

---

##  Graduate Extension - Graduate Students Only

### Part 4 - Assume-Breach Detection Layer (30 pts)

Your hardening controls reduce attack surface but assume prevention is sufficient. Graduate students must design a complementary **detection layer** assuming an attacker has already obtained valid credentials. This is a design exercise - describe the detection logic in prose/tables, not as executable rule syntax.

**Detection Approach Design (30 pts)**

Choose **2 of the following 5** post-exploitation TTPs and design a detection approach for each:

1. **Lateral Movement** - Pass-the-Hash or Overpass-the-Hash (NTLM authentication from an unusual source process)
2. **Credential Access** - LSASS memory access (Mimikatz pattern: a process opening LSASS with `PROCESS_VM_READ`)
3. **Persistence** - a new scheduled task created by a non-SYSTEM, non-admin process
4. **Defense Evasion** - PowerShell with a Base64-encoded command longer than 500 characters
5. **Discovery** - `net user /domain`, `net group "Domain Admins"`, or an equivalent LDAP enumeration burst (5+ queries in 60 seconds from one host)

For each of your 2 chosen TTPs, document: the specific log source and event ID(s) you'd query, the exact condition/pattern that indicates this technique, why that condition would **not** also match ordinary administrative activity, the MITRE ATT&CK technique ID, and at least one realistic false-positive scenario.



[← Back to Homework]({{ site.baseurl }}/homework/)
