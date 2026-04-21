---
title: "LAB 3 — Active Directory & GPO Configuration"
parent: Labs
nav_order: 3
---

# LAB 3 — Active Directory & GPO Configuration
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 3
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Promote a Windows Server 2022 to a domain controller
- Build a structured OU hierarchy
- Create and link a security baseline GPO
- Verify policy application and account lockout

---

## Tools Required

- Windows Server 2022 VM from Lab 1
- Active Directory Domain Services role
- Group Policy Management Console (GPMC)

---

## Procedure


1. Promote Windows Server 2022 to DC for domain `lab.local`
2. Create OU structure: `OU=Users > OU=IT, OU=Finance` and `OU=Computers > OU=Workstations, OU=Servers`
3. Create 5 test users in `OU=IT` and 3 in `OU=Finance`
4. Create GPO **Security-Baseline** with these settings:
   - Password complexity: Enabled
   - Minimum password length: 14
   - Account lockout threshold: 5 attempts
   - Account lockout duration: 30 minutes
5. Link GPO to the domain root
6. Force a policy refresh: `gpupdate /force`
7. Verify: `gpresult /r` — confirm GPO appears under Applied GPOs
8. Test: Attempt 6 failed logins on a test account — verify lockout occurs


---

## Submission Requirements

Lab Report: AD Users & Computers screenshot (OU structure), GPO settings screenshot, `gpresult /r` output, lockout verification screenshot, reflection: what 3 additional security GPOs would you implement?

---

[← Back to Labs]({{ site.baseurl }}/labs/)
