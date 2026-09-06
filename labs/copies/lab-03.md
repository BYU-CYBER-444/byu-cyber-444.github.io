---
title: "LAB 3 - Active Directory, GPO & Centralized AAA"
parent: Labs
nav_order: 3
---

# LAB 3 - Active Directory, GPO & Centralized AAA
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Verify a pre-promoted Active Directory domain controller and understand its design
- Build a multi-tiered OU structure reflecting real-world administrative delegation
- Implement a security baseline GPO and a separate audit policy GPO
- Configure Fine-Grained Password Policy (PSO) for privileged accounts
- Test and verify policy application, account lockout, and audit logging
- Write and test LDAP search filters against the domain, and deploy a minimal FreeRADIUS instance backed by it

---

## Tools Required

- Your instructor has provisioned a Windows Server 2022 VM for this lab, `lab03-dc01`, with **AD DS already installed and the forest already promoted** - you don't need to run `Install-ADDSForest` yourself (see Part 1)
- A second provisioned VM, `lab03-radius01` (Ubuntu 22.04), for the FreeRADIUS deployment in Part 8
- Group Policy Management Console (GPMC)
- Active Directory Users & Computers (ADUC)
- Active Directory Administrative Center (ADAC)
- `ldapsearch` (from `ldap-utils` / `openldap-clients`)

---

## Background

Active Directory is the trust anchor for most enterprise Windows environments - every workstation join, every GPO, and every resource ACL ultimately traces back to a security principal AD issued. A poorly designed OU/tiering model doesn't just create administrative headaches, it creates privilege-escalation paths: a Tier 0 credential exposed to a Tier 2 workstation is a real attack surface, not an inconvenience. This lab treats admin-tiering, password policy, and audit logging as controls with a specific attack each is meant to prevent, and extends the same directory-backed identity model past desktop logon into network-device administration via RADIUS - a router or switch authenticating admins faces the same credential-sprawl risk a workstation does.

---

## Procedure

### Part 1 - Verify the Domain Controller

Your VM template ships with AD DS already installed and the forest already promoted - you don't need to run `Install-ADDSForest` yourself. Start by confirming the domain is healthy:
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

### Part 8 - Centralized AAA: LDAP Queries & RADIUS

Your domain isn't just used by desktop logons - network infrastructure (routers, switches, VPN concentrators) authenticates administrators against a central directory too, using RADIUS instead of Kerberos/NTLM. This part gives you hands-on time with the query language itself and a minimal RADIUS deployment backed by your domain.

**LDAP filters (write and run against your domain with `ldapsearch`):**

1. Find every user whose `sAMAccountName` belongs to a group called `NetworkAdmins` (create this group first and put 2 test users in it):
   ```
   ldapsearch -x -H ldap://<dc-host> -D "<bind-dn>" -W \
     -b "<base-dn>" "(&(objectClass=person)(memberOf=cn=NetworkAdmins,...))"
   ```
2. Find every account that is **disabled** (bit 2 set in `userAccountControl` - use filter `(userAccountControl:1.2.840.113556.1.4.803:=2)`).
3. Find every account whose password has expired or is locked - tie this back to your PSO-protected `enovak-adm` account, and confirm the filter actually returns it after you intentionally lock it.

For each query, write 1-2 sentences explaining **why** that filter syntax produces that result (e.g., what the `:1.2.840.113556.1.4.803:` matching-rule OID means, or why `memberOf` requires the group's full DN rather than its short name).

**Minimal FreeRADIUS deployment:**

On `lab03-radius01` (do not run this on the domain controller itself), install and sanity-check FreeRADIUS with a local flat-file user first:

```bash
sudo apt install freeradius -y
sudo systemctl stop freeradius   # so you can run it in debug mode

echo 'testuser Cleartext-Password := "testpass123"' | sudo tee -a /etc/freeradius/3.0/users

sudo freeradius -X   # run in foreground debug mode, leave this terminal open
```

In a second terminal, on the same host:

```bash
radtest testuser testpass123 localhost 0 testing123
```

Capture the full debug output showing the Access-Request coming in and the Access-Accept going out. Identify in your write-up: which line shows the shared secret being validated, and which line shows the final accept/reject decision.

---

## Deliverables

- `gpresult.html` - GPO application report (attach file)
- ADUC screenshot showing complete OU structure
- Security-Baseline GPO settings screenshot (all required settings visible)
- Audit-Policy GPO advanced audit settings screenshot
- Lockout test: `Get-ADUser` output showing `LockedOut: True` then `LockedOut: False` after unlock
- Security event log screenshot showing Event ID 4625 (failed logon) entries from the lockout test
- PSO verification: `Get-ADUserResultantPasswordPolicy` output for `enovak-adm` vs. `ajohnson`
- Written reflection (3-4 sentences): Why does the tiered admin model (separate `enovak` and `enovak-adm` accounts) reduce risk compared to a single all-powerful admin account?
- LDAP filters and outputs for all 3 Part 8 queries, with explanations
- FreeRADIUS local flat-file debug output (Part 8)

---

## Grading

| Item | Points |
|------|--------|
| OU structure design and verification (Parts 1-2) | 15 |
| User and group creation (Part 3) | 10 |
| Security Baseline GPO (Part 4) | 12 |
| Audit Policy GPO (Part 5) | 10 |
| Fine-Grained Password Policy / PSO (Part 6) | 10 |
| Verification - lockout test, audit events (Part 7) | 13 |
| LDAP filters with explanations (Part 8) | 15 |
| FreeRADIUS local deployment and debug analysis (Part 8) | 15 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
