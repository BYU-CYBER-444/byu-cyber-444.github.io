---
title: "CYBER HW 8 - Windows Hardening Deep Dive"
parent: Homework
nav_order: 8
---

# CYBER HW 8 - Windows Hardening Deep Dive
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | CYBER HW 8 |
| **Points** | 100 |
| **Due** | Week 9 |
| **Track** | Cyber |

---

## Description

### Part 1 - Hardening Controls Documentation (50 pts)

Document **15 Windows hardening controls** applied in or derived from Lab 7. For each control produce a complete record:

| Control # | CIS ID | DISA STIG Rule ID | Control Name | Default State | Hardened State | Implementation Method | Registry Path / GPO Path | PowerShell Verification Command | Security Impact | Operational Impact |
|---|---|---|---|---|---|---|---|---|---|---|

**Implementation method** must be one of: GPO (with the exact policy path), Registry key edit (with the key path and value), PowerShell command (include the full command), or Group Policy Preference.

**PowerShell verification command** must be a one-liner that returns the current value and can be used in an audit script - not just "check in the GUI."

**Security Impact** must use CIA Triad framing: which of Confidentiality, Integrity, or Availability does this control protect, and against what specific attack technique (cite MITRE ATT&CK technique ID)?

**Operational Impact** - what breaks or changes for users when this control is applied? Who needs to be notified?

Your 15 controls must include at minimum: 3 credential protections (Credential Guard, LAPS, or similar), 3 network protections (SMB signing, LLMNR disable, etc.), 3 audit/logging controls, 2 application controls (AppLocker, WDAC), and 2 attack surface reduction controls.

### Part 2 - Hardening Verification Script (25 pts)

Write `cyber-hw-08-verify.ps1` - a PowerShell script that checks the compliance state of all 15 controls and produces a report:

- For each control: `[PASS]` or `[FAIL]` with the current value vs. expected value
- Summary at the end: X/15 controls compliant
- Export results to `hardening-audit-YYYY-MM-DD.csv`
- The script must run without errors on both a hardened and non-hardened Windows Server 2022

Run the script on your hardened Lab 7 VM and include the output in your submission.

### Part 3 - Attack Scenario Analysis (15 pts)

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

### Part 4 - Compensating Controls (10 pts)

Two of your 15 hardening controls cannot be applied to a specific server because they break a legacy application that the vendor refuses to update. The controls are: SMB v1 disable and NTLM restriction.

Write a formal compensating control plan for each:
- What compensating control(s) replace the original control's security intent?
- Is the compensating control equivalent, stronger, or weaker? Justify.
- What additional monitoring do you implement to detect exploitation of the known-weak configuration?
- What is your remediation timeline and who accepts the residual risk?

---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-08.md`. Commit to `homework/assets/`:

- `cyber-hw-08-verify.ps1` - your verification script
- `cyber-hw-08-audit-output.csv` - output from running the script on your hardened VM
- `cyber-hw-08-audit-screenshot.png` - screenshot of script running on your VM

Open a PR titled `CYBER HW 8 - Windows Hardening` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| 15 controls - CIS ID, STIG ID, registry/GPO path, ATT&CK mapping | 50 |
| Verification script - all 15 checks, CSV export, runs cleanly | 25 |
| Attack scenario analysis - specific event IDs, control mapping | 15 |
| Compensating controls - equivalent intent, monitoring added | 10 |

---

## Tip

{: .tip }
Use `Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"` as a model for your verification commands - registry reads are reliable and scriptable. GUI screenshots are not acceptable as verification evidence.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Assume-Breach Detection Layer (30 pts)

Your hardening controls reduce attack surface but assume prevention is sufficient. Graduate students must design a complementary **detection layer** assuming an attacker has already obtained valid credentials.

**Sigma Detection Rules (15 pts)**

Write 5 Sigma rules in `cyber-hw-08-sigma-rules.yml` targeting Windows post-exploitation TTPs that your hardening controls alone cannot prevent:

1. **Lateral Movement** - detect Pass-the-Hash or Overpass-the-Hash (NTLM authentication from an unusual source process)
2. **Credential Access** - detect LSASS memory access (Mimikatz pattern: a process opening LSASS with `PROCESS_VM_READ`)
3. **Persistence** - detect a new scheduled task created by a non-SYSTEM, non-admin process
4. **Defense Evasion** - detect PowerShell with a Base64-encoded command longer than 500 characters
5. **Discovery** - detect `net user /domain`, `net group "Domain Admins"`, or equivalent LDAP enumeration burst (5+ queries in 60 seconds from one host)

Each rule must include: `title`, `status`, `description`, `references` (MITRE ATT&CK technique ID), `logsource` (product/category/service), `detection` (selection + condition), `falsepositives`, and `level`.

**MITRE ATT&CK Navigator Layer (15 pts)**

Produce a MITRE ATT&CK Navigator layer JSON file (`cyber-hw-08-navigator.json`) that:

- Colors all techniques **prevented** by your 15 hardening controls in green
- Colors all techniques **detected** by your 5 Sigma rules in blue
- Colors techniques that are **neither prevented nor detected** (your blind spots) in red
- Includes a comment on each colored technique explaining which control or rule covers it

Write a 1-page analysis of your red (blind spot) techniques: which 2-3 represent the highest risk given your assumed threat model, and what additional data source (EDR telemetry, network captures, deception technology) would be required to detect them?


[← Back to Homework]({{ site.baseurl }}/homework/)
