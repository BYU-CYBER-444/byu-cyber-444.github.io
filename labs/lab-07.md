---
title: "LAB 7 — Windows Server 2022 Hardening"
parent: Labs
nav_order: 7
---

# LAB 7 — Windows Server 2022 Hardening
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 7
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Apply the Microsoft Security Compliance Toolkit (SCT) baseline
- Enable AppLocker in Audit mode
- Configure Credential Guard via Group Policy
- Disable legacy protocols and validate all settings

---

## Tools Required

- Windows Server 2022 VM
- Microsoft Security Compliance Toolkit (download from microsoft.com)
- LGPO.exe
- PowerShell 5.1+

---

## Procedure


1. Download the Microsoft Security Compliance Toolkit for Windows Server 2022
2. Review baseline settings with **Policy Analyzer**
3. Apply the baseline GPO locally:
   ```powershell
   LGPO.exe /g .\GPOs
   ```
4. Enable AppLocker via Local Security Policy:
   - Set all rule categories to **Audit** mode
   - Create default rules for Executable Rules
5. Configure Credential Guard:
   - `gpedit.msc > Computer Config > Admin Templates > System > Device Guard`
   - Turn On Virtualization Based Security: **Enabled**
   - Credential Guard: **Enabled with UEFI lock**
6. Disable SMBv1:
   ```powershell
   Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
   ```
7. Verify with `Get-WindowsFeature` and export GPO backup:
   ```powershell
   LGPO.exe /b C:\GPO_Backup
   ```


---

## Submission Requirements

Lab Report: Policy Analyzer before/after screenshots, AppLocker audit mode event log screenshot, Credential Guard configuration screenshot, SMBv1 disable verification, `Get-WindowsFeature` output, exported GPO backup files.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
