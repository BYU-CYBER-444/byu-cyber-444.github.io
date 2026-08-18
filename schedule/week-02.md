---
title: "Week 2"
parent: Schedule
nav_order: 2
---

# Week 2 - Linux Administration Fundamentals
{: .no_toc }

---

## Topics

- Linux filesystem hierarchy (FHS), user/group management, file permissions (DAC, umask) and POSIX ACLs for role-based access on shared paths
- Least-privilege sudo policy design (`sudoers.d`, `Cmnd_Alias`) and alternatives (`doas`, centralized sudo via FreeIPA/IdM, PAM-gated MFA)
- Linux network services: authoritative DNS with BIND (zones, SOA/NS/MX/CNAME/TXT/PTR records), DHCP, and NFS
- Time synchronization with chrony (client and internal stratum-2 server) and NTP vs. PTP
- `firewalld` service scoping
- Interpreting automated security audit output (filesystem, accounts, network, SSH, and cron findings) and prioritizing remediation

---

## Slides

[Linux Administration Fundamentals]({{ site.baseurl }}/lectures/CYBER_444_Week02_Linux_Administration_Fundamentals.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **Both Tracks** | [LAB 2 - Linux Network Services & Privilege Management]({% link labs/lab-02.md %}) |

---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 2 - Linux Security Audit Script Suite]({% link homework/cyber-hw-02.md %}) |
| **IT Track** | [IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis]({% link homework/it-hw-02.md %}) |

---

[← Previous Week]({{ site.baseurl }}/schedule/week-01/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-03/)
{: .text-right }
