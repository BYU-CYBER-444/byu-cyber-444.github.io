---
title: "CYBER LAB 11 - Centralized Logging with auditd & Graylog"
parent: Labs
nav_order: 11
---

# CYBER LAB 11 - Centralized Logging with auditd & Graylog
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 11 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

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

- Ubuntu 22.04 VM (logging target: 192.168.56.10)
- Docker and Docker Compose
- Graylog 5.x Docker Compose file (provided on Learning Suite)

---

## Procedure

### Part 1 - Advanced auditd Rules with audisp-syslog

The previous lab used `rsyslog` to forward auditd events, but `audisp-syslog` is the correct tool - it's an auditd dispatcher plugin designed for this purpose.

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

Write `/etc/audit/rules.d/99-lab11.rules`:
```bash
sudo tee /etc/audit/rules.d/99-lab11.rules << 'EOF'
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

## Submission Requirements

- `/etc/audit/rules.d/99-lab11.rules` (annotated)
- `/etc/audit/plugins.d/syslog.conf` showing audisp-syslog enabled
- Screenshot of Graylog showing incoming events (search for `key:priv_escalation`)
- Pipeline rules (screenshot or exported JSON) for all 6 event categories
- Dashboard screenshot showing all 5 panels with actual data
- Alert definition screenshot and triggered alert screenshot
- MITRE ATT&CK mapping table: each audit key → technique → what detection prevents
- Written analysis (3-4 sentences): What audit events does your rule set NOT capture? Name one post-exploitation technique an attacker could use that would leave no trace in your current auditd rules.

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Graylog Correlation Alert: Attack Chain Detection

Implement a **correlation alert** that detects a multi-stage attack sequence:

**Scenario:** An attacker logs in via SSH (Event ID: sshd in syslog) → reads `/etc/shadow` (key=identity) → adds a cron job (key=cron_change) within a 10-minute window.

In Graylog, create a correlation alert:
1. Create three individual Event Definitions (one per stage above)
2. Create a **Correlation** event that fires when all three events occur within 10 minutes with the same source IP or username
3. Add a notification that logs to a dedicated `high-priority-alerts` stream

Demonstrate the alert by manually triggering all three events in sequence and showing the correlation alert firing.

Write a brief analysis (1 page): How does correlation alerting differ from threshold alerting? What are the false positive and false negative trade-offs of your correlation window (10 minutes)? Would you set it longer or shorter for a production environment - and why?

---

[← Back to Labs]({{ site.baseurl }}/labs/)
