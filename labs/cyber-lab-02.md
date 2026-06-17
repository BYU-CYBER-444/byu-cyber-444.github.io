---
title: "CYBER LAB 2 - Linux Privilege Management & Audit Framework"
parent: Labs
nav_order: 2
---

# CYBER LAB 2 - Linux Privilege Management & Audit Framework
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 2 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Design and implement a least-privilege sudo policy enforced at the command level
- Configure POSIX ACLs on a multi-role web application directory structure
- Build a persistent, production-quality auditd rule set covering privilege escalation, file access, and session tracking
- Verify that each access control works as intended by attempting unauthorized actions and confirming denial
- Generate auditd summary reports and interpret the output

---

## Tools Required

- Ubuntu 22.04 LTS VM from Lab 1
- `auditd`, `audispd-plugins`, `auditd-tools` (`auditctl`, `ausearch`, `aureport`)
- `acl` package (`getfacl`, `setfacl`)
- `sudo`, `visudo`

```bash
sudo apt install auditd audispd-plugins acl -y
```

---

## Procedure

### Part 1 - User Account Setup

Create three accounts with clearly defined roles:

```bash
sudo useradd -m -s /bin/bash alice    # sysadmin
sudo useradd -m -s /bin/bash bob      # developer
sudo useradd -m -s /bin/bash carol    # read-only auditor
sudo passwd alice    # set a password for each
sudo passwd bob
sudo passwd carol
```

Create the web application directory structure:

```bash
sudo mkdir -p /srv/webapp/{public,private,logs,config}
sudo chown root:root /srv/webapp
```

### Part 2 - Least-Privilege Sudo Policy

Create separate sudoers files for each role. Never edit `/etc/sudoers` directly - use `/etc/sudoers.d/`:

**`/etc/sudoers.d/10-sysadmins`:**
```
# Alice is a full sysadmin - full sudo, but requires password
# NOT NOPASSWD - no one gets passwordless sudo in production
alice ALL=(ALL:ALL) ALL
```

**`/etc/sudoers.d/20-developers`:**
```
# Bob can only restart the web application service
# Cmnd_Alias prevents sudo bash, sudo su, or sudo -s escapes
Cmnd_Alias WEBAPP = /usr/bin/systemctl restart apache2, /usr/bin/systemctl status apache2, /usr/bin/systemctl reload apache2
bob ALL=(root) NOPASSWD: WEBAPP
```

**`/etc/sudoers.d/30-auditors`:**
```
# Carol cannot sudo at all (no entry = no sudo access)
# This is implicit - document it explicitly for clarity
```

Validate all sudoers files before saving (a syntax error locks you out):

```bash
sudo visudo -c -f /etc/sudoers.d/10-sysadmins
sudo visudo -c -f /etc/sudoers.d/20-developers
```

**Verify restrictions work:**

```bash
# Test bob can restart apache2
sudo -u bob sudo /usr/bin/systemctl status apache2   # should succeed

# Test bob CANNOT run any other sudo command
sudo -u bob sudo /usr/bin/systemctl restart ssh       # should FAIL
sudo -u bob sudo bash                                  # should FAIL
sudo -u bob sudo -s                                    # should FAIL
```

Screenshot each test - both the success and the denials.

### Part 3 - POSIX ACLs on Web Application Directory

The default Unix permissions (owner/group/other) are insufficient for multi-role access. Use ACLs:

```bash
# Set default permissions on the directory
sudo chmod 750 /srv/webapp/public /srv/webapp/logs
sudo chmod 700 /srv/webapp/private /srv/webapp/config

# Alice (sysadmin): full access everywhere
sudo setfacl -R -m u:alice:rwx /srv/webapp
sudo setfacl -R -d -m u:alice:rwx /srv/webapp   # default ACL (applies to new files)

# Bob (developer): read+execute on public, write to logs, no access to config or private
sudo setfacl -m u:bob:r-x /srv/webapp/public
sudo setfacl -d -m u:bob:r-x /srv/webapp/public
sudo setfacl -m u:bob:rwx /srv/webapp/logs
sudo setfacl -d -m u:bob:rwx /srv/webapp/logs
# No ACL entry for bob on private or config = no access

# Carol (auditor): read-only on public and logs
sudo setfacl -m u:carol:r-- /srv/webapp/public
sudo setfacl -m u:carol:r-- /srv/webapp/logs

# Verify
getfacl /srv/webapp/public
getfacl /srv/webapp/private
getfacl /srv/webapp/config
```

**Verify access controls work:**

```bash
# Bob can read public:
sudo -u bob ls /srv/webapp/public    # should work
# Bob cannot read config:
sudo -u bob ls /srv/webapp/config    # should fail: Permission denied
# Carol cannot write to logs:
sudo -u bob sh -c 'echo test > /srv/webapp/logs/test.log'   # bob can write
sudo -u carol sh -c 'echo test > /srv/webapp/logs/test.log'  # carol CANNOT
```

Document each test result.

### Part 4 - Production auditd Rule Set

Temporary `auditctl` rules are lost on reboot. Write persistent rules to `/etc/audit/rules.d/99-lab2.rules`:

```bash
sudo tee /etc/audit/rules.d/99-lab2.rules << 'EOF'
## Lab 2 - Security Audit Rules
## Reload with: sudo augenrules --load

# Delete all existing rules first
-D

# Buffer size (increase if you see backlog warnings)
-b 8192

# Failure mode: 1=printk, 2=panic (use 1 in lab, 2 in production)
-f 1

## --- Privilege Escalation ---
# Monitor sudo usage (execve by root = command run as root)
-a always,exit -F arch=b64 -S execve -F uid=0 -F auid>=1000 -F auid!=unset -k priv_escalation

# Monitor su and sudo binaries directly
-w /usr/bin/sudo -p x -k sudo_usage
-w /bin/su -p x -k su_usage

## --- Identity & Authentication Files ---
-w /etc/passwd -p wa -k identity_change
-w /etc/shadow -p wa -k identity_change
-w /etc/group -p wa -k identity_change
-w /etc/sudoers -p wa -k sudoers_change
-w /etc/sudoers.d/ -p wa -k sudoers_change

## --- SSH ---
-w /etc/ssh/sshd_config -p wa -k sshd_config_change
-w /root/.ssh -p wa -k root_ssh_change

## --- Privileged Commands ---
-a always,exit -F path=/usr/bin/chown -F perm=x -F auid>=1000 -k priv_cmds
-a always,exit -F path=/usr/bin/chmod -F perm=x -F auid>=1000 -k priv_cmds
-a always,exit -F path=/usr/sbin/useradd -F perm=x -k user_mgmt
-a always,exit -F path=/usr/sbin/userdel -F perm=x -k user_mgmt
-a always,exit -F path=/usr/sbin/usermod -F perm=x -k user_mgmt

## --- Access Denied Events ---
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -k access_denied
-a always,exit -F arch=b64 -S openat -F exit=-EPERM -k access_denied

## --- Session Tracking ---
-w /var/run/utmp -p wa -k session_tracking
-w /var/log/wtmp -p wa -k session_tracking
-w /var/log/btmp -p wa -k session_tracking
EOF

# Load the rules (replaces auditctl -R)
sudo augenrules --load
sudo systemctl restart auditd

# Verify rules are active
sudo auditctl -l | head -30
```

### Part 5 - Trigger and Verify Audit Events

Generate test events and verify each appears in the audit log:

```bash
# 1. Trigger privilege escalation event
sudo useradd testuser2
sudo userdel testuser2

# 2. Trigger sudoers change event
sudo touch /etc/sudoers.d/test-file
sudo rm /etc/sudoers.d/test-file

# 3. Trigger access denied event
sudo -u carol cat /srv/webapp/config/dummy 2>/dev/null || true

# Now search for each event type
sudo ausearch -k priv_escalation -ts today | tail -20
sudo ausearch -k sudoers_change -ts today
sudo ausearch -k user_mgmt -ts today
sudo ausearch -k access_denied -ts today
```

### Part 6 - Audit Summary Reports

`aureport` generates statistical summaries from the audit log - essential for daily monitoring:

```bash
# Overall summary
sudo aureport --summary

# Authentication summary (login attempts)
sudo aureport --auth --summary

# Failed events
sudo aureport --failed

# Privileged command summary
sudo aureport --avc --summary 2>/dev/null || sudo aureport --syscall --summary | head -20

# User activity summary
sudo aureport --user --summary
```

Screenshot the `aureport --summary` and `aureport --failed` outputs.

---

## Submission Requirements

- `/etc/sudoers.d/10-sysadmins`, `20-developers`, `30-auditors` (with explanation of each line)
- `getfacl` output for all 4 webapp subdirectories
- Access control verification tests: at least 6 tests (3 expected-success, 3 expected-denial) with actual output
- `/etc/audit/rules.d/99-lab2.rules` (annotated - explain the purpose of each rule block)
- `auditctl -l` output confirming all rules are loaded
- `ausearch` output for each of the 4 event categories (priv_escalation, sudoers_change, user_mgmt, access_denied)
- `aureport --summary` and `aureport --failed` screenshots
- Written analysis (3-4 sentences): Looking at your aureport output, what would you investigate first if you were monitoring this system for malicious activity?

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### PAM Password Controls & Audit Log Parsing Script

1. **PAM Password History Enforcement:** Configure PAM to prevent users from reusing their last 5 passwords and enforce a minimum password strength using `pam_pwquality`:
   ```bash
   sudo apt install libpam-pwquality -y
   sudo nano /etc/pam.d/common-password
   ```
   Add/modify these lines (order matters):
   ```
   password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1
   password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512 remember=5
   ```
   Test: Set alice's password 5 times trying to reuse it - the 5th reuse should be rejected. Screenshot the rejection.

2. **Audit Log Parser Script:** Write `lab02-audit-report.sh` that queries the audit log for the past 24 hours and outputs a structured JSON summary:
   ```json
   {
     "report_date": "2025-01-15",
     "privilege_escalations": 12,
     "failed_access_attempts": 3,
     "sudoers_changes": 0,
     "user_management_events": 2,
     "top_users_by_privilege_use": [
       {"user": "alice", "count": 10},
       {"user": "bob", "count": 2}
     ],
     "access_denied_details": [
       {"user": "carol", "path": "/srv/webapp/config", "time": "14:23:01"}
     ]
   }
   ```
   The script must use `ausearch` and `aureport` as data sources, parse their output with bash/awk/python, and write the JSON to `/var/log/audit-daily-report-$(date +%Y-%m-%d).json`. Create a cron job that runs it nightly at 23:55.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
