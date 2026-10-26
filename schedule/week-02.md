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

## Supplemental Readings & Videos

### Readings

- [Managing users and groups in Red Hat Enterprise Linux 9](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/managing-users-and-groups_configuring-basic-system-settings) — Covers local account and group administration that underpins Linux access control.
- [BIND 9 Administrator Reference Manual](https://bind9.readthedocs.io/en/v9.18.49/index.html) — Reference for authoritative DNS configuration, zone files, DNSSEC, and operational security.

### Videos

- [Linux Crash Course: Understanding File and Directory Permissions](https://www.youtube.com/watch?v=4e669hSjaX8) — Learn Linux TV demonstrates ownership and permission bits used in day-to-day Linux administration.

---
## Slides

[Linux Administration Fundamentals]({{ site.baseurl }}/lectures/CYBER444_Week02_Linux_Administration_Fundamentals.pptx)

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
