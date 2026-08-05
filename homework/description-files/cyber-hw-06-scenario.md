---
title: "CYBER HW 6 - Valley Medical Group PAM/SSH Environment Profile"
parent: Homework
nav_exclude: true
---

# Valley Medical Group - PAM/SSH Environment Profile
{: .no_toc }

{: .note }
This is the reference scenario for [CYBER HW 6]({% link homework/cyber-hw-06.md %}). It gives you the specific server inventory, staffing, and existing infrastructure your SSH CA and MFA design needs to be written against. Don't invent a different server count, staffing model, or network layout - use these.

---

## Server Inventory

**Production (5 Linux servers, VLAN 40 - Server/Infrastructure):**

| Hostname | Role |
|---|---|
| `medflow-web01`, `medflow-web02` | MedFlow EMR web/app tier (Nginx + Django/Gunicorn) |
| `medflow-db01` | PostgreSQL 15 - MedFlow's primary database |
| `infra01` | Internal DNS, DHCP, and NTP |
| `backup01` | Nightly backup target + warm-standby PostgreSQL replica |

**Staging (2 Linux servers, isolated VLAN, no PHI):** `staging-web01`, `staging-db01` - a smaller mirror of the production web/app/db tier, used to test configuration changes (including your SSH CA rollout) before they touch production. No real patient data ever lands here.

## Staffing

- **IT Director** (1) - approves standard changes; final authority on break-glass access approval.
- **Systems Administrators** (3) - `jchen`, `mfoster`, `rpatel` - generalist Windows/Linux/network admins, the only staff with routine interactive SSH access to any of the 7 servers above.
- **CISO** (1) - also the HIPAA Security Officer; owns sign-off on the SSH CA architecture and the break-glass procedure.

There is no clinical-staff SSH access anywhere in this design - physicians and nurses never touch these servers directly. Your MFA method comparison (Part 2) should contrast the **general sysadmin tier** (all 3 sysadmins, routine access) against a **privileged/break-glass tier** (CISO + IT Director only), not a clinical-staff use case.

## Existing Identity & Network

- **Identity provider:** on-prem Active Directory (`dc01`) with Azure AD Connect syncing to Microsoft Entra ID - the same directory already used for EHR and email SSO. Each sysadmin has a named AD account; there is no shared/generic admin login.
- **Service accounts:** `svc-backup` (runs `backup01`'s nightly jobs) and `svc-monitor` (runs scheduled health checks against all 7 servers) - both are members of a `svcaccount` AD group, run unattended via cron/systemd timers, and must never be prompted for an interactive MFA challenge.
- **Network:** VLAN 40 (Server/Infrastructure) hosts all 7 Linux servers plus `dc01`. A separate, dedicated **management subnet (10.0.40.0/28, VLAN 45)** exists specifically for administrative access (SSH, RDP, iDRAC/IPMI) - the sysadmins' workstations reach servers through this subnet, not through the general VLANs. Break-glass access, if it happens, should be identifiable in logs partly by originating from this subnet.
- **Firewall:** Palo Alto Networks NGFW pair (`edge-fw01`) enforcing inter-VLAN policy, including which subnets may reach VLAN 40/45 over SSH at all.

## Compliance Context

Valley Medical Group is a HIPAA covered entity. Every one of the 7 servers processes or stores PHI (MedFlow's database) or is critical infrastructure that PHI-handling systems depend on (DNS/DHCP, backups). Access control and audit logging decisions in this assignment should be defensible in a HIPAA technical-safeguards audit, not just "good practice" in the abstract.

---

[← Back to CYBER HW 6]({% link homework/cyber-hw-06.md %})
