---
title: "Week 2"
parent: Schedule
nav_order: 2
---

# Week 2 - Linux Administration Fundamentals
{: .no_toc }

---

## Topics

- Linux filesystem hierarchy (FHS), user/group management, file permissions (DAC, ACLs, umask)
- Storage management: partitioning, LVM (physical/volume/logical volumes, live resize, snapshots), software RAID with `mdadm`
- Sudo policy design, PAM basics, systemd service management (including managing a database service like PostgreSQL/MySQL as a systemd unit)
- Key sysadmin commands (`find`, `awk`, `ss`, `lsof`)
- Linux firewall management (`firewalld`, `nftables`, default-deny rulesets) and fail2ban
- Bash scripting for automation: variables, conditionals, loops, functions, error handling, cron scheduling
- Parsing command output to build audit reports (`awk`, `grep`, `cut`, process substitution)
- auditd introduction: architecture, rule types (file watches, syscall rules, key labels), querying with `ausearch` and `aureport`
- Linux network services overview: DNS (BIND), DHCP (ISC DHCP), NTP (chrony), NFS, Samba

---

## Slides

[Linux Administration Fundamentals]({{ site.baseurl }}/lectures/CYBER_444_Week02_Linux_Administration_Fundamentals.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **Both Tracks** | [LAB 2 - Linux Network Services, Privilege Management & Storage]({% link labs/lab-02.md %}) |

---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 2 - Linux Security Audit Script Suite]({% link homework/cyber-hw-02.md %}) |
| **IT Track** | [IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis]({% link homework/it-hw-02.md %}) |

---

[← Previous Week]({{ site.baseurl }}/schedule/week-01/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-03/)
{: .text-right }
