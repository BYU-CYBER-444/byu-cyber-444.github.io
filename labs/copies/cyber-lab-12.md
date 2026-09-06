---
title: "CYBER LAB 12 - Centralized Logging with auditd & Graylog"
parent: Labs
nav_order: 12
---

# CYBER LAB 12 - Centralized Logging with auditd & Graylog
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Write a comprehensive auditd rule set using `audisp-syslog` for reliable log forwarding
- Deploy and configure a Graylog SIEM stack via Docker Compose
- Build a Graylog pipeline that parses and enriches auditd events with a `threat_category` field
- Configure a Graylog alert that fires on repeated privilege escalation events
- Build a security operations dashboard with meaningful panels

---

## Tools Required

- Your instructor has provisioned an Ubuntu 22.04 VM for this lab, `cyber-lab12-log01` (logging target: 192.168.56.10)
- Docker and Docker Compose
- Graylog 5.x Docker Compose file (provided on Learning Suite)

---

## Background

Audit logs that only live on the host they were generated on disappear the moment that host is compromised or wiped - exactly when you need them most. Centralizing logs to a SIEM, with enrichment that maps raw audit keys to MITRE ATT&CK techniques and threat categories, turns a wall of terse audit records into something a SOC analyst can actually triage at a glance. This lab builds that full pipeline: reliable forwarding, a real SIEM, enrichment, a dashboard, and an alert that fires on the pattern that actually matters (repeated privilege escalation), not just a single noisy event.

---

## Procedure

### Part 1 - Advanced auditd Rules with audisp-syslog

`audisp-syslog` is the correct tool for reliable auditd-to-syslog forwarding - it's a dispatcher plugin built for exactly this purpose, unlike naively tailing `audit.log` with a generic file-watching approach, which is fragile and loses events across log rotation.

Configure `audisp-syslog`:
```bash
sudo apt install audispd-plugins -y
sudo nano /etc/audit/plugins.d/syslog.conf
```
Set:
```
active = yes
direction = out
path = builtin_syslog
type = builtin
args = LOG_INFO
format = string
```

Write `/etc/audit/rules.d/99-cyber-lab12.rules`:
```bash
sudo tee /etc/audit/rules.d/99-cyber-lab12.rules << 'EOF'
-D
-b 16384
-f 1

## Privilege escalation
-a always,exit -F arch=b64 -S execve -F uid=0 -F auid>=1000 -F auid!=unset -k priv_escalation
-w /usr/bin/sudo -p x -k sudo_exec
-w /bin/su -p x -k su_exec

## Credential files
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

## Scheduled tasks (common persistence)
-w /etc/crontab -p wa -k cron_change
-w /etc/cron.d/ -p wa -k cron_change
-w /var/spool/cron/ -p wa -k cron_change

## SSH keys (lateral movement staging)
-w /root/.ssh/ -p wa -k ssh_keys
-a always,exit -F dir=/home -F name=.ssh -F perm=wa -k ssh_keys

## Suspicious directories
-w /tmp -p wx -k tmp_exec
-w /var/tmp -p wx -k tmp_exec
-w /dev/shm -p wx -k shm_exec

## Access denied
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -k access_denied
-a always,exit -F arch=b64 -S openat -F exit=-EPERM -k access_denied
EOF

sudo augenrules --load && sudo systemctl restart auditd
sudo systemctl restart rsyslog
```

Verify events are reaching syslog:
```bash
sudo ausearch -k priv_escalation -ts recent
sudo journalctl -t audispd --since "5 minutes ago"
```

### Part 2 - Deploy Graylog

```bash
docker compose -f docker-compose.graylog.yml up -d
# Wait ~60 seconds for Graylog to initialize
docker compose -f docker-compose.graylog.yml ps   # verify all containers healthy
```

Default credentials: admin / admin (change immediately):
```bash
curl -u admin:admin -H 'Content-Type: application/json'   -X PUT http://localhost:9000/api/users/admin   -d '{"password": "CyberLab444!", "old_password": "admin"}'
```

Create a Syslog UDP Input:
- **System → Inputs → Select Input → Syslog UDP**
- Port: 514
- Title: `auditd-syslog`
- Save and Start

Configure `rsyslog` to forward to Graylog:
```bash
echo '*.* @127.0.0.1:514;RSYSLOG_SyslogProtocol23Format' | sudo tee /etc/rsyslog.d/99-graylog.conf
sudo systemctl restart rsyslog
```

### Part 3 - Graylog Pipeline: Event Enrichment

Create a pipeline that adds a `threat_category` field to auditd events based on the audit key. Navigate to **System → Pipelines → Create pipeline** named `auditd-enrichment`.

Stage 0 (match all auditd messages):
```
rule "auditd enrichment"
when
  contains(to_string($message.message), "key=priv_escalation") OR
  contains(to_string($message.message), "key=sudo_exec")
then
  set_field("threat_category", "Privilege Escalation");
  set_field("mitre_technique", "T1548.003");
end
```

Create additional rules for each key in your ruleset:
- `key=identity` → `threat_category = Credential Access`, `mitre_technique = T1003`
- `key=cron_change` → `threat_category = Persistence`, `mitre_technique = T1053.003`
- `key=ssh_keys` → `threat_category = Lateral Movement Prep`, `mitre_technique = T1098.004`
- `key=tmp_exec` → `threat_category = Defense Evasion`, `mitre_technique = T1036`
- `key=access_denied` → `threat_category = Discovery`, `mitre_technique = T1083`

Connect the pipeline to the `Default Stream`.

### Part 4 - Security Operations Dashboard

Create a dashboard with at least 5 panels:

| Panel | Type | Query | Time Range |
|---|---|---|---|
| Privilege Escalations (24h) | Single number | `key:priv_escalation` | Last 24h |
| Events by Threat Category | Pie chart | All events with `threat_category` field | Last 24h |
| Top Users by Escalation | Bar chart | `key:sudo_exec` grouped by `auid` | Last 7d |
| Access Denied Events | Data table | `key:access_denied` | Last 24h |
| Timeline of Security Events | Line chart | All events with `threat_category` | Last 24h |

### Part 5 - Graylog Alert: Repeated Privilege Escalation

Configure an alert that fires when more than 3 privilege escalation events occur within 5 minutes:

- **Alerts → Event Definitions → Create Event Definition**
- Title: `Repeated Privilege Escalation`
- Priority: High
- Filter query: `key:priv_escalation`
- Grouping: by `auid` field
- Condition: count() > 3 in the last 5 minutes
- Notification: Graylog HTTP notification pointing to a webhook (or just log to a stream)

Trigger the alert by running 4+ sudo commands quickly and verify it fires:
```bash
for i in {1..5}; do sudo ls /root; done
```

Screenshot the alert in the Graylog Alerts page showing status **Triggered**.

---

## Deliverables

- `/etc/audit/rules.d/99-cyber-lab12.rules` (annotated)
- `/etc/audit/plugins.d/syslog.conf` showing audisp-syslog enabled
- Screenshot of Graylog showing incoming events (search for `key:priv_escalation`)
- Pipeline rules (screenshot or exported JSON) for all 6 event categories
- Dashboard screenshot showing all 5 panels with actual data
- Alert definition screenshot and triggered alert screenshot
- MITRE ATT&CK mapping table: each audit key → technique → what detection prevents
- Written analysis (3-4 sentences): What audit events does your rule set NOT capture? Name one post-exploitation technique an attacker could use that would leave no trace in your current auditd rules.

---

## Grading

| Item | Points |
|------|--------|
| auditd rules + audisp-syslog forwarding verified (Part 1) | 20 |
| Graylog deployed and receiving events (Part 2) | 15 |
| Pipeline enrichment - all 6 event categories (Part 3) | 20 |
| Security operations dashboard - 5 panels (Part 4) | 20 |
| Repeated-escalation alert configured and triggered (Part 5) | 15 |
| Written analysis - detection blind spot | 10 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
