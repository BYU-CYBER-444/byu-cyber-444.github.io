---
title: "CYBER LAB 14 - Incident Response Scenario"
parent: Labs
nav_order: 14
---

# CYBER LAB 14 - Incident Response Scenario
{: .no_toc }

**Duration:** ~3 hours &nbsp;&middot;&nbsp; **Week:** Week 14 &nbsp;&middot;&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Follow the NIST SP 800-61 IR lifecycle: Preparation -> Detection -> Analysis -> Containment -> Eradication -> Recovery -> Lessons Learned
- Preserve volatile evidence with proper chain of custody before any remediation
- Identify all IOCs using systematic triage commands and map them to MITRE ATT&CK techniques
- Produce a formal post-incident report with a timestamped attack timeline
- Verify system integrity after recovery using AIDE

---

## Tools Required

- Pre-compromised Ubuntu VM `.ova` (provided on Learning Suite)
- Standard Linux CLI tools (`ps`, `ss`, `find`, `strings`, `sha256sum`)
- `rkhunter` (`sudo apt install rkhunter`)
- AIDE
- Restic (backup/restore)

{: .warning }
Do not share the compromised VM with anyone outside this class. It contains intentional malware artifacts for educational purposes only. Do not connect this VM to the internet.

---

## Procedure

### Phase 0 - Preparation

Before working on the compromised VM, prepare your evidence collection environment:

```bash
# On a SEPARATE clean VM or USB drive - create evidence directory
mkdir -p /mnt/evidence/{volatile,filesystem,logs,artifacts}
echo "Evidence collection started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > /mnt/evidence/chain-of-custody.txt
echo "Analyst: $(whoami)@$(hostname)" >> /mnt/evidence/chain-of-custody.txt
```

**Chain of Custody Rule:** Every file you copy must be hashed immediately after collection. Document: what you collected, when, from where, and why.

### Phase 1 - Detection & Initial Triage

Import the compromised VM from the `.ova` file. Boot it. You should NOT see anything obviously wrong - the attacker has been careful.

Run systematic triage in this order:

**Volatile evidence first (lost on reboot):**

```bash
# Capture timestamp
date -u +%Y-%m-%dT%H:%M:%SZ | tee /mnt/evidence/volatile/collection-time.txt

# Running processes (look for: unusual names, running from /tmp, running as root)
ps auxf | tee /mnt/evidence/volatile/processes.txt

# Network connections (look for: unexpected listeners, outbound connections to non-local IPs)
ss -tupan | tee /mnt/evidence/volatile/network.txt

# Open files by suspicious processes
lsof -nP 2>/dev/null | tee /mnt/evidence/volatile/open-files.txt

# Logged in users and recent logins
who | tee /mnt/evidence/volatile/who.txt
last -n 50 | tee /mnt/evidence/volatile/last.txt
lastb -n 50 | tee /mnt/evidence/volatile/lastb.txt

# Environment variables of suspicious processes (replace PID)
cat /proc/SUSPICIOUS_PID/environ 2>/dev/null | tr '' '
' | tee /mnt/evidence/volatile/proc-env.txt
```

**Hash everything immediately:**
```bash
sha256sum /mnt/evidence/volatile/* > /mnt/evidence/volatile/SHA256SUMS
echo "Volatile evidence hashed: $(date -u)" >> /mnt/evidence/chain-of-custody.txt
```

### Phase 2 - Deep Analysis

**Scheduled tasks (persistence mechanisms):**
```bash
for user in $(cut -d: -f1 /etc/passwd); do
  crontab -l -u $user 2>/dev/null | grep -v "^#" | grep . && echo "  ^ user: $user"
done | tee /mnt/evidence/filesystem/crontabs.txt

ls -la /etc/cron* /var/spool/cron/ 2>/dev/null | tee -a /mnt/evidence/filesystem/crontabs.txt
cat /etc/rc.local 2>/dev/null | tee /mnt/evidence/filesystem/rc-local.txt
```

**SSH backdoors:**
```bash
find / -name authorized_keys 2>/dev/null | while read f; do
  echo "=== $f ==="
  cat "$f"
  sha256sum "$f"
done | tee /mnt/evidence/filesystem/authorized-keys.txt
```

**Suspicious files:**
```bash
# Files modified in the last 7 days (excluding /proc, /sys, /dev)
find / -newer /etc/passwd -not -path "*/proc/*" -not -path "*/sys/*"   -not -path "*/dev/*" -type f 2>/dev/null | tee /mnt/evidence/filesystem/recently-modified.txt

# SUID binaries (compare to your Lab 1 baseline)
find / -perm -4000 -type f 2>/dev/null | tee /mnt/evidence/filesystem/suid-binaries.txt

# Files in /tmp or /dev/shm
find /tmp /dev/shm -type f 2>/dev/null | tee /mnt/evidence/filesystem/tmp-files.txt

# Analyze suspicious binaries with strings
for f in $(cat /mnt/evidence/filesystem/tmp-files.txt); do
  echo "=== strings: $f ==="
  strings "$f" | head -50
done | tee /mnt/evidence/artifacts/strings-output.txt
```

**Rootkit scan:**
```bash
sudo rkhunter --update && sudo rkhunter --check --skip-keypress 2>&1 | tee /mnt/evidence/artifacts/rkhunter.txt
grep -E "Warning|Found" /mnt/evidence/artifacts/rkhunter.txt
```

**Log analysis:**
```bash
sudo cp /var/log/auth.log /mnt/evidence/logs/
sudo cp /var/log/syslog /mnt/evidence/logs/

# Find failed logins
grep "Failed password" /mnt/evidence/logs/auth.log | tee /mnt/evidence/logs/failed-logins.txt

# Find successful logins
grep "Accepted" /mnt/evidence/logs/auth.log | tee /mnt/evidence/logs/successful-logins.txt

# Find sudo usage
grep "sudo:" /mnt/evidence/logs/auth.log | tee /mnt/evidence/logs/sudo-usage.txt
```

**Construct your IOC table as you go:**

| IOC Type | Value | Location | Timestamp | MITRE ATT&CK |
|---|---|---|---|---|
| Malicious process | bash -i >& /dev/tcp/... | /proc/1234 | 2025-01-15 03:22 | T1059.004 |
| Cron backdoor | * * * * * root /tmp/.hidden | /etc/cron.d/update | 2025-01-15 03:23 | T1053.003 |
| SSH unauthorized key | ssh-rsa AAAA... | /root/.ssh/authorized_keys | 2025-01-15 03:24 | T1098.004 |

### Phase 3 - Containment

Document EVERY action taken, in order, with timestamps:

```bash
# Kill malicious processes
sudo kill -9 SUSPICIOUS_PID
echo "$(date -u): Killed PID SUSPICIOUS_PID - reason: [IOC found]" >> /mnt/evidence/chain-of-custody.txt

# Remove cron backdoors (after documenting them)
sudo sed -i '/suspicious-entry/d' /etc/cron.d/compromised-file

# Remove unauthorized SSH keys (after documenting them)
sudo nano /root/.ssh/authorized_keys   # remove unauthorized keys

# Block suspicious outbound IPs with iptables (if active C2 connection found)
sudo iptables -A OUTPUT -d SUSPICIOUS_IP -j DROP
```

### Phase 4 - Eradication

Perform a thorough sweep:

```bash
# Check all locations the attacker might have placed persistence
sudo find / -newer /etc/passwd -type f -not -path "*/proc/*" -not -path "*/sys/*" 2>/dev/null |   grep -vE "^/run|^/tmp/evidence" | tee /mnt/evidence/eradication-sweep.txt

# Verify /etc/passwd and /etc/shadow haven't been modified (compare to your sha256 baseline)
sha256sum /etc/passwd /etc/shadow

# Check for new SUID binaries vs. your Lab 1 baseline
diff /mnt/evidence/filesystem/suid-binaries.txt YOUR_LAB1_SUID_BASELINE 2>/dev/null
```

### Phase 5 - Recovery & Verification

```bash
# Back up evidence before restoring snapshot
restic init --repo /mnt/evidence/restic-backup
restic -r /mnt/evidence/restic-backup backup /mnt/evidence
restic -r /mnt/evidence/restic-backup snapshots

# Restore from clean snapshot via VM hypervisor
# (Revert to BASELINE-WEEK1 snapshot)

# After restore - verify integrity with AIDE
sudo aide --check 2>&1 | tee /mnt/evidence/aide-post-restore.txt
```

### Phase 6 - Post-Incident Report

Write a formal post-incident report using NIST SP 800-61 sections:

1. **Executive Summary** - what happened, business impact, current status (1 paragraph)
2. **Incident Timeline** - chronological table of attacker actions with timestamps and evidence sources
3. **IOC Table** - all indicators with MITRE ATT&CK mapping
4. **Root Cause Analysis** - how did the attacker gain initial access? (identify the initial vector)
5. **Impact Assessment** - what data/systems could the attacker have accessed?
6. **Containment and Eradication Actions** - what you did and when
7. **Lessons Learned** - 3 specific improvements to prevent recurrence

---

## Submission Requirements

- `/mnt/evidence/chain-of-custody.txt` - showing all collection timestamps
- Volatile evidence files (processes, network, logins) with SHA256SUMS
- IOC table with all IOCs found, timestamps, and MITRE ATT&CK mapping
- rkhunter output with findings highlighted
- Log analysis: failed logins, successful logins, sudo usage
- Containment actions log with timestamps
- AIDE post-restore output showing clean system
- Restic snapshot verification screenshot
- Formal Post-Incident Report (NIST SP 800-61 structure)

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Threat Actor Attribution & Sigma Rule Development

1. **Threat Actor Profiling:** Based on the IOCs and TTPs you identified, research whether the attack pattern matches any known threat actor group. Use MITRE ATT&CK Groups (attack.mitre.org/groups/), VirusTotal, or abuse.ch to look up IP addresses or file hashes. Write a 1-page threat actor assessment covering: likely actor profile (opportunistic vs. targeted, skill level), what data or access they were likely after, and your confidence level with reasoning.

2. **Sigma Detection Rules:** Write 3 Sigma rules (`lab14-sigma-rules.yml`) that would have detected this attack earlier in the kill chain:
   - One rule targeting the initial access technique
   - One rule targeting the persistence mechanism
   - One rule targeting the command-and-control activity

   Each rule must include: title, status, description, logsource, detection (selection + condition), falsepositives, level, and MITRE ATT&CK tags. The rules must be specific enough to detect THIS attack, not just generic rules that catch everything.

3. **Test your rules:** Use `sigma convert` to translate your rules to a format compatible with your Graylog SIEM from Lab 11 and verify they would have produced an alert if they had been running during the attack.

---

[<- Back to Labs]({{ site.baseurl }}/labs/)
