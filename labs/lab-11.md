---
title: "LAB 11 — Centralized Logging with auditd & Graylog"
parent: Labs
nav_order: 11
---

# LAB 11 — Centralized Logging with auditd & Graylog
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 11
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Write advanced auditd rules covering privileged commands and sensitive files
- Configure rsyslog to forward events to a centralized Graylog instance
- Deploy Graylog via Docker Compose
- Build a security dashboard for privilege escalation events

---

## Tools Required

- Ubuntu 22.04 VM
- ``auditd``
- ``rsyslog``
- Graylog 5.x (Docker Compose file provided on LMS)
- Docker

---

## Procedure


1. Add advanced `auditd` rules to `/etc/audit/rules.d/99-custom.rules`:
   ```
   -a always,exit -F arch=b64 -S execve -F euid=0 -k root_commands
   -w /etc/sudoers -p wa -k sudoers_changes
   -w /home -p wa -k home_dir_writes
   -a always,exit -F arch=b64 -S openat -F exit=-EACCES -k access_denied
   ```
2. Configure `rsyslog` to forward to Graylog (UDP/514 output)
3. Deploy Graylog using the provided Docker Compose file:
   ```bash
   docker compose -f docker-compose.graylog.yml up -d
   ```
4. Create a Graylog input (Syslog UDP, port 514)
5. Trigger test events: run `sudo` commands, modify `/etc/sudoers`, attempt restricted file access
6. Verify all events appear in Graylog
7. Create a Graylog dashboard with 3 panels: root command count (24h), sudoers change events, failed access events


---

## Submission Requirements

Lab Report: `auditd` rules file, `rsyslog` configuration, Graylog dashboard screenshot (showing captured events), evidence of each triggered event type, dashboard export (JSON).

---

[← Back to Labs]({{ site.baseurl }}/labs/)
