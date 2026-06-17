---
title: "LAB 3 - Active Directory & GPO Configuration"
parent: Labs
nav_order: 3
---

# LAB 3 - Active Directory & GPO Configuration
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 3
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Promote Windows Server 2022 to a domain controller with a properly designed domain
- Build a multi-tiered OU structure reflecting real-world administrative delegation
- Implement a security baseline GPO and a separate audit policy GPO
- Configure Fine-Grained Password Policy (PSO) for privileged accounts
- Test and verify policy application, account lockout, and audit logging

---

## Tools Required

- Windows Server 2022 VM from Lab 1
- Active Directory Domain Services (AD DS) role
- Group Policy Management Console (GPMC)
- Active Directory Users & Computers (ADUC)
- Active Directory Administrative Center (ADAC)

---

## Procedure

### Part 1 - Domain Controller Promotion

1. Install the AD DS role and promote to domain controller:
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
   Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" `
     -SafeModeAdministratorPassword (Read-Host -AsSecureString) -Force
   ```
2. After reboot, verify the domain is healthy:
   ```powershell
   Get-ADDomain
   dcdiag /test:replications /test:dns /test:netlogon
   netlogon /query
   ```
   All dcdiag tests must pass. Document any failures.

### Part 2 - OU Structure Design

Design your OU hierarchy to support delegation - each OU represents an administrative boundary. Create the following structure:

```
lab.local
 OU=Tier0           ← Domain Controllers, privileged admin workstations
    OU=AdminAccts  ← Tier 0 admin accounts only
 OU=Servers
    OU=Production
    OU=Development
 OU=Workstations
    OU=IT
    OU=Users
 OU=UserAccounts
     OU=IT
     OU=Finance
     OU=Disabled    ← Accounts pending deletion
```

Create this structure via PowerShell (not GUI - this is a senior course):

```powershell
$domain = "DC=lab,DC=local"
$ous = @(
  "OU=Tier0,$domain",
  "OU=AdminAccts,OU=Tier0,$domain",
  "OU=Servers,$domain",
  "OU=Production,OU=Servers,$domain",
  "OU=Development,OU=Servers,$domain",
  "OU=Workstations,$domain",
  "OU=IT,OU=Workstations,$domain",
  "OU=Users,OU=Workstations,$domain",
  "OU=UserAccounts,$domain",
  "OU=IT,OU=UserAccounts,$domain",
  "OU=Finance,OU=UserAccounts,$domain",
  "OU=Disabled,OU=UserAccounts,$domain"
)
foreach ($ou in $ous) { New-ADOrganizationalUnit -Path $ou.Split(",",2)[1] -Name $ou.Split("=")[1].Split(",")[0] }
```

Adjust the logic as needed for correct parent paths. Screenshot the final OU tree in ADUC.

### Part 3 - User and Group Creation

Create test accounts representing different privilege tiers:

```powershell
# Standard users
$users = @(
  @{Name="Alice Johnson"; Sam="ajohnson"; OU="OU=IT,OU=UserAccounts,$domain"; Title="IT Analyst"},
  @{Name="Bob Martinez"; Sam="bmartinez"; OU="OU=Finance,OU=UserAccounts,$domain"; Title="Financial Analyst"},
  @{Name="Carol Kim"; Sam="ckim"; OU="OU=Finance,OU=UserAccounts,$domain"; Title="CFO"},
  @{Name="Dave Singh"; Sam="dsingh"; OU="OU=IT,OU=UserAccounts,$domain"; Title="Help Desk"},
  @{Name="Eve Novak"; Sam="enovak"; OU="OU=IT,OU=UserAccounts,$domain"; Title="Systems Admin"}
)
foreach ($u in $users) {
  New-ADUser -Name $u.Name -SamAccountName $u.Sam -Path $u.OU -Title $u.Title `
    -AccountPassword (ConvertTo-SecureString "Lab@444Temp!" -AsPlainText -Force) -Enabled $true
}

# Privileged admin account for Eve (Tier 0 - separate from her daily-use account)
New-ADUser -Name "Eve Novak (Admin)" -SamAccountName "enovak-adm" `
  -Path "OU=AdminAccts,OU=Tier0,$domain" `
  -AccountPassword (ConvertTo-SecureString "Admin@444Complex#99" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "enovak-adm"
```

Create two security groups: `GRP-IT-Staff` and `GRP-Finance-Staff`. Add users to appropriate groups.

### Part 4 - Security Baseline GPO

Create a **Security-Baseline** GPO linked to the domain root. Configure via PowerShell using `secedit` or manually via GPMC - document all settings:

```powershell
$gpo = New-GPO -Name "Security-Baseline" -Comment "CIS L1 password and lockout baseline"
New-GPLink -Name "Security-Baseline" -Target $domain
```

Required settings (Computer Configuration → Windows Settings → Security Settings):

| Setting | Value | CIS Reference |
|---|---|---|
| Minimum password length | 14 characters | CIS 1.1.4 |
| Password complexity | Enabled | CIS 1.1.5 |
| Password history | 24 passwords remembered | CIS 1.1.1 |
| Max password age | 365 days | CIS 1.1.2 |
| Account lockout threshold | 5 invalid attempts | CIS 1.2.1 |
| Account lockout duration | 15 minutes | CIS 1.2.2 |
| Reset lockout counter after | 15 minutes | CIS 1.2.3 |
| Interactive logon: Do not display last username | Enabled | CIS 2.3.7.1 |

### Part 5 - Audit Policy GPO

Create a separate **Audit-Policy** GPO and link it to the domain root. Configure Advanced Audit Policy (not legacy):

```
Computer Config → Windows Settings → Security Settings → Advanced Audit Policy
```

| Category | Subcategory | Setting |
|---|---|---|
| Account Logon | Credential Validation | Success, Failure |
| Account Management | User Account Management | Success, Failure |
| Account Management | Security Group Management | Success |
| Logon/Logoff | Logon | Success, Failure |
| Logon/Logoff | Account Lockout | Failure |
| Object Access | File System | Success, Failure |
| Privilege Use | Sensitive Privilege Use | Success, Failure |
| Policy Change | Audit Policy Change | Success |

Apply and verify:
```powershell
gpupdate /force
auditpol /get /category:* | Select-String "Account Logon|Account Management|Logon/Logoff"
```

### Part 6 - Fine-Grained Password Policy (PSO)

Standard domain password policy applies to all users. Create a stricter PSO for admin accounts:

```powershell
New-ADFineGrainedPasswordPolicy -Name "PSO-AdminAccts" -Precedence 10 `
  -MinPasswordLength 20 -ComplexityEnabled $true -PasswordHistoryCount 24 `
  -MaxPasswordAge "90.00:00:00" -MinPasswordAge "1.00:00:00" `
  -LockoutThreshold 3 -LockoutDuration "00:30:00" `
  -LockoutObservationWindow "00:30:00" -ProtectedFromAccidentalDeletion $true

Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-AdminAccts" -Subjects "enovak-adm"
Get-ADUserResultantPasswordPolicy -Identity "enovak-adm"
```

Verify the PSO is applied by checking the resultant password policy for `enovak-adm` vs. a standard user.

### Part 7 - Verification

```powershell
# Confirm GPO application
gpresult /H C:\gpresult.html /F
Start-Process C:\gpresult.html

# Test lockout: attempt 6 failed logins for ajohnson, verify account locks
# (Do NOT do this for enovak-adm - the PSO locks after 3 attempts)
for ($i=1; $i -le 6; $i++) {
  runas /user:labjohnson /noprofile cmd 2>&1
}
Get-ADUser ajohnson -Properties LockedOut | Select-Object SamAccountName, LockedOut

# Unlock:
Unlock-ADAccount -Identity ajohnson

# Verify audit events in Event Viewer
Get-WinEvent -LogName Security | Where-Object {$_.Id -eq 4625} | Select-Object -First 5 | Format-List
```

---

## Submission Requirements

- `gpresult.html` - GPO application report (attach file)
- ADUC screenshot showing complete OU structure
- Security-Baseline GPO settings screenshot (all required settings visible)
- Audit-Policy GPO advanced audit settings screenshot
- Lockout test: `Get-ADUser` output showing `LockedOut: True` then `LockedOut: False` after unlock
- Security event log screenshot showing Event ID 4625 (failed logon) entries from the lockout test
- PSO verification: `Get-ADUserResultantPasswordPolicy` output for `enovak-adm` vs. `ajohnson`
- Written reflection (3-4 sentences): Why does the tiered admin model (separate `enovak` and `enovak-adm` accounts) reduce risk compared to a single all-powerful admin account?

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### AdminSDHolder & Protected Users Security Group

1. **AdminSDHolder protection:** Move `enovak-adm` into the `Domain Admins` group (already done), then verify that AdminSDHolder has propagated its ACL to the account within 60 minutes. Run `Get-ADUser enovak-adm -Properties nTSecurityDescriptor` and compare the ACL to a standard user's ACL. Document which permissions are different and explain what attack AdminSDHolder protection prevents.

2. **Protected Users group:** Add `enovak-adm` to the **Protected Users** security group:
   ```powershell
   Add-ADGroupMember -Identity "Protected Users" -Members "enovak-adm"
   ```
   Test the impact: attempt to authenticate `enovak-adm` via NTLM (use a tool like `runas` on a non-domain machine if available, or document the limitation). Document exactly which authentication protocols Protected Users blocks and why this matters for Pass-the-Hash / Pass-the-Ticket attacks. Reference the specific MITRE ATT&CK technique(s) this control mitigates.

3. **Delegation audit:** Run this query and document which service accounts have unconstrained Kerberos delegation enabled:
   ```powershell
   Get-ADComputer -Filter {TrustedForDelegation -eq $true} | Select-Object Name
   Get-ADUser -Filter {TrustedForDelegation -eq $true} | Select-Object Name
   ```
   Explain why unconstrained delegation is dangerous and what a Kerberos delegation attack (S4U2Proxy, S4U2Self) looks like.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
