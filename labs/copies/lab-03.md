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

- A dedicated VM, `lab03-addc` (Windows Server 2022), for this lab's domain controller - **AD DS is already installed and the forest already promoted** (domain `lab.local`) - you don't need to run `Install-ADDSForest` yourself (see Part 1). Your username is your Net ID, and your password is the one emailed to you at the start of the semester.
- A newly provisioned VM, `lab03-radius01` (Ubuntu 22.04), for the FreeRADIUS deployment in Part 8. Your username on it is your Net ID, and your password is the one emailed to you at the start of the semester.
- Group Policy Management Console (GPMC)
- Active Directory Users & Computers (ADUC)
- Active Directory Administrative Center (ADAC)
- `ldapsearch` (from `ldap-utils` / `openldap-clients`)

> **Note on RDP access:** `lab03-addc` is reachable via RDP (Remote Desktop Protocol) on port 3389. Connect using your OS's RDP client (Microsoft Remote Desktop on macOS, the built-in Remote Desktop Connection app on Windows, or Remmina/xfreerdp on Linux), pointing it at the VM's hostname or IP address. Log in with your Net ID and the password emailed to you at the start of the semester. `lab03-radius01` is Ubuntu, so you'll access it over SSH rather than RDP.

---

## Background

Active Directory is the trust anchor for most enterprise Windows environments - every workstation join, every GPO, and every resource ACL ultimately traces back to a security principal AD issued. A poorly designed OU/tiering model doesn't just create administrative headaches, it creates privilege-escalation paths: a Tier 0 credential exposed to a Tier 2 workstation is a real attack surface, not an inconvenience. This lab treats admin-tiering, password policy, and audit logging as controls with a specific attack each is meant to prevent, and extends the same directory-backed identity model past desktop logon into network-device administration via RADIUS - a router or switch authenticating admins faces the same credential-sprawl risk a workstation does.

---

## Procedure

### Part 1 - Verify the Domain Controller

`lab03-addc`, this lab's own domain controller, ships with AD DS already installed and the forest already promoted - you don't need to run `Install-ADDSForest` yourself. Start by confirming the domain is healthy:
   ```powershell
   Get-ADDomain
   dcdiag /test:replications /test:dns /test:netlogon
   netlogon /query
   ```
   All dcdiag tests must pass.

### Part 2 - OU Structure Design

Design your OU hierarchy to support delegation - each OU represents an administrative boundary. Create the following structure:

Make this a diagram and not something they can just use

```mermaid
flowchart TD
    ROOT["lab.local"]
    DC["OU=DomainControllers<br/><small>Tier 0</small>"]
    SRV["OU=Servers<br/><small>Tier 1</small>"]
    WS["OU=Workstations<br/><small>Tier 2</small>"]
    UA["OU=UserAccounts<br/><small>Tier 2</small>"]

    ADMIN["OU=AdminAccts<br/><small>Tier 0 admin accounts only</small>"]
    PROD["OU=Production"]
    DEV["OU=Development"]
    ITW["OU=IT"]
    USR["OU=Users"]
    ITA["OU=IT"]
    FIN["OU=Finance"]
    DIS["OU=Disabled<br/><small>accounts pending deletion</small>"]

    ROOT --> DC
    ROOT --> SRV
    ROOT --> WS
    ROOT --> UA

    DC --> ADMIN
    SRV --> PROD
    SRV --> DEV
    WS --> ITW
    WS --> USR
    UA --> ITA
    UA --> FIN
    UA --> DIS

    classDef root fill:#1e293b,color:#fff,stroke:#0f172a,stroke-width:1px;
    classDef tier0 fill:#b45309,color:#fff,stroke:#92400e,stroke-width:1px;
    classDef tier1 fill:#1d4ed8,color:#fff,stroke:#1e40af,stroke-width:1px;
    classDef tier2 fill:#0f766e,color:#fff,stroke:#115e59,stroke-width:1px;
    classDef tier2b fill:#6d28d9,color:#fff,stroke:#5b21b6,stroke-width:1px;
    classDef disabled fill:#7f1d1d,color:#fff,stroke:#991b1b,stroke-width:1px,stroke-dasharray: 5 3;

    class ROOT root;
    class DC,ADMIN tier0;
    class SRV,PROD,DEV tier1;
    class WS,ITW,USR tier2;
    class UA,ITA,FIN tier2b;
    class DIS disabled;
```


Create the above structure on your Domain Controller


### Part 3 - User and Group Creation

Also just give a table of accounts to create and the details not the commands to run

Create two security groups: `GRP-IT-Staff` and `GRP-Finance-Staff`. Add users to appropriate groups.

Create test accounts representing different privilege tiers:


| Name | SamAccountName | OU/Path | Title | Password | Enabled | Notes |
|---|---|---|---|---|---|---|
| Alice Johnson | ajohnson | OU=IT,OU=UserAccounts,$domain | IT Analyst | Lab@444Temp! | True | — |
| Bob Martinez | bmartinez | OU=Finance,OU=UserAccounts,$domain | Financial Analyst | Lab@444Temp! | True | — |
| Carol Kim | ckim | OU=Finance,OU=UserAccounts,$domain | CFO | Lab@444Temp! | True | — |
| Dave Singh | dsingh | OU=IT,OU=UserAccounts,$domain | Help Desk | Lab@444Temp! | True | — |
| Eve Novak | enovak | OU=IT,OU=UserAccounts,$domain | Systems Admin | Lab@444Temp! | True | Standard/daily-use account |
| Eve Novak (Admin) | enovak-adm | OU=AdminAccts,OU=Tier0,$domain | — | Admin@444Complex#99 | True | Tier 0 privileged account; added to **Domain Admins** group |




### Part 4 - Security Baseline GPO

Create a **Security-Baseline** GPO linked to the domain root.

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

| Setting | Value | Explanation |
|---|---|---|
| Policy Name | PSO-AdminAccts | Identifier for this Fine-Grained Password Policy (FGPP) object. |
| Precedence | 10 | Determines which PSO wins if a user is subject to more than one. **Lower number = higher priority.** |
| Min Password Length | 20 | Minimum number of characters required in the password. |
| Complexity Enabled | True | Requires the password to mix at least 3 of: uppercase, lowercase, digits, symbols — and disallows the username/parts of it. |
| Password History Count | 24 | Number of previous passwords remembered per user; prevents reusing any of the last 24 passwords. |
| Max Password Age | 90 days | How long a password can be used before AD forces a change. |
| Min Password Age | 1 day | Minimum time that must pass before the password can be changed again — stops someone from cycling through history 24 times in a row to reuse an old password immediately. |
| Lockout Threshold | 3 attempts | Number of failed logon attempts allowed before the account locks out. |
| Lockout Duration | 30 minutes | How long the account stays locked before automatically unlocking (or requires admin unlock if set to 0). |
| Lockout Observation Window | 30 minutes | The rolling time window during which failed attempts are counted toward the lockout threshold. Resets after this period with no failures. |
| Protected From Accidental Deletion | True | Sets `ProtectedFromAccidentalDeletion` on the AD object so it can't be deleted without first removing that protection flag. |
| Applied To (Subject) | enovak-adm | The user/group this PSO is linked to via `Add-ADFineGrainedPasswordPolicySubject`. Only subjects explicitly added receive this policy. |


Verify the PSO is applied by checking the resultant password policy for `enovak-adm` vs. a standard user.

### Part 7 - Verification

```powershell
# Confirm GPO application
gpresult /H C:\gpresult.html /F
Start-Process C:\gpresult.html

# Test lockout: attempt 6 failed logins for ajohnson, verify account locks
# (Do NOT do this for enovak-adm - the PSO locks after 3 attempts)
for ($i=1; $i -le 6; $i++) {
  runas /user:ajohnson /noprofile cmd 2>&1
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


Here's a worked example using a generic setup — with different placeholder values than your lab so it illustrates the pattern without solving your specific exercise:

```
ldapsearch -x -H ldap://dc01.example.com -D "cn=svc-ldapquery,ou=ServiceAccounts,dc=example,dc=com" -W \
  -b "dc=example,dc=com" "(&(objectClass=person)(memberOf=cn=Finance-Admins,ou=Groups,dc=example,dc=com))"
```

| Part of the example | What it maps to |
|---|---|
| `dc01.example.com` | A stand-in LDAP server hostname |
| `cn=svc-ldapquery,ou=ServiceAccounts,dc=example,dc=com` | A stand-in bind DN — a service account with read rights, sitting in a `ServiceAccounts` OU |
| `dc=example,dc=com` | The search base — root of the fictional `example.com` domain |
| `cn=Finance-Admins,ou=Groups,dc=example,dc=com` | A stand-in group DN — shows the group living under a `Groups` OU |



1. Find every user whose `sAMAccountName` belongs to a group called `NetworkAdmins` (create this group first and put 2 test users in it):
2. Find every account that is **disabled** (bit 2 set in `userAccountControl` - use filter `(userAccountControl:1.2.840.113556.1.4.803:=2)`).
3. Find every account whose password has expired or is locked - tie this back to your PSO-protected `enovak-adm` account, and confirm the filter actually returns it after you intentionally lock it.

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

Confirm the debug output shows the Access-Request coming in and an Access-Accept going out.

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
| LDAP filters and query outputs (Part 8) | 15 |
| FreeRADIUS local deployment and debug analysis (Part 8) | 15 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
