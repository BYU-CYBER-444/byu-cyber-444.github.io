---
title: "CYBER HW 2 - Linux Security Audit Script Suite"
parent: Homework
nav_order: 2
---

# CYBER HW 2 - Linux Security Audit Script Suite
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | CYBER HW 2 |
| **Points** | 100 |
| **Due** | Week 3 |
| **Track** | Cyber |

---

## Description

Write a production-quality Linux security audit script that a sysadmin could drop onto any Ubuntu 22.04 system and get an actionable security posture report. This is not a homework exercise - it is a tool you would actually use.

### Part 1 - Audit Script (70 pts)

Build `hw-02-audit.sh`. The script must perform all of the following checks and output a structured report:

**Account & Privilege Auditing:**
- List all accounts with UID 0 (should be only root - flag any others as CRITICAL)
- List all accounts with empty passwords (check `/etc/shadow`)
- List all accounts with a login shell that are not in `/etc/sudoers` or a sudo group - flag any with `sudo` or `wheel` group membership that haven't logged in within 90 days
- Enumerate all sudoers rules including `/etc/sudoers.d/*` and flag any `NOPASSWD` entries

**Filesystem Security:**
- Find all SUID/SGID binaries - compare against a hardcoded expected whitelist and flag any that are NOT on the list
- Find all world-writable files and directories outside `/tmp`, `/var/tmp`, and `/dev` - flag any in `/etc`, `/usr`, or `/home`
- Check that `/etc/passwd`, `/etc/shadow`, and `/etc/sudoers` have correct permissions and ownership

**Network Exposure:**
- List all listening services (TCP and UDP) with the process name and PID
- Flag any service listening on `0.0.0.0` or `::` that is not in a hardcoded expected-services list
- Check for active outbound connections to non-RFC1918 addresses (potential C2 or data exfiltration indicator)

**SSH Configuration:**
- Parse `/etc/ssh/sshd_config` and flag: `PasswordAuthentication yes`, `PermitRootLogin yes`, `X11Forwarding yes`, `Protocol 1`, and any `PermitEmptyPasswords yes`
- List all authorized_keys files across all user home directories and flag any with more than one key (unusual for most environments)

**Scheduled Tasks:**
- Enumerate all system crontabs (`/etc/cron*`, `/var/spool/cron`) and flag any that run scripts from world-writable directories or run as root with a writable script path

**Report Output:**
- Output a color-coded summary to stdout: `[CRITICAL]` in red, `[WARNING]` in yellow, `[INFO]` in green
- Write a full machine-readable JSON report to `/tmp/security-audit-YYYY-MM-DD.json` with a top-level structure: `{"hostname": ..., "audit_date": ..., "critical_count": ..., "warning_count": ..., "findings": [...]}`
- Exit with code `1` if any CRITICAL findings exist, `0` if clean

**Script requirements:** `set -euo pipefail`, all functions documented with comments, no hardcoded paths (use variables at top), must run without errors on a clean Ubuntu 22.04 VM and also on a deliberately weakened VM.

### Part 2 - Deliberately Weakened VM Test (15 pts)

Introduce at least **5 deliberate misconfigurations** into a test VM (from your lab or a fresh VM) that your script should detect:

- One UID-0 account that is not root
- One account with `NOPASSWD` sudo
- One unexpected SUID binary
- One world-writable file in `/etc`
- One SSH misconfiguration

Run your script against the weakened VM and paste the colored output (screenshot) and the JSON report (file) in your submission. Every introduced misconfiguration must appear as a CRITICAL or WARNING finding.

### Part 3 - Write-Up (15 pts)

Answer in your write-up:

1. Your script uses a hardcoded SUID whitelist. In a real enterprise environment managing 200 servers with different roles (web, database, build), how would you manage this whitelist at scale? Describe a practical approach.
2. What category of attack would NOT be detected by your script? Describe one real attack technique (name a MITRE ATT&CK technique) that leaves no trace in the artifacts your script examines, and explain what additional data source would be needed to detect it.
3. If you installed PostgreSQL or MySQL on a box this audit script runs against, why would you scope a database user to a single database rather than granting it superuser/root on the whole instance? Give one concrete consequence of getting this wrong.

---

## Deliverable(s)

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow will run `homework/assets/hw-02-audit.sh` against a test Ubuntu 22.04 environment with 3 known misconfigurations. Your script must flag all 3 as CRITICAL or WARNING and produce a valid JSON report. The auto-grader posts results as a PR comment. Re-push to fix issues.

Commit to `homework/assets/` using exactly these filenames:

- `hw-02-audit.sh` - your audit script
- `cyber-hw-02-clean-output.txt` - output from clean VM
- `cyber-hw-02-dirty-output.txt` - output from weakened VM  
- `cyber-hw-02-dirty-report.json` - JSON report from weakened VM
- `cyber-hw-02-dirty-screenshot.png` - screenshot of colored terminal output on weakened VM

Write your analysis in `homework/cyber-hw-02.md`.

Open a PR titled `CYBER HW 2 - Linux Security Audit Suite` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| All audit checks implemented and working | 40 |
| JSON report output - valid JSON, correct schema | 15 |
| Exit code logic and color-coded output | 10 |
| Error handling (`set -euo pipefail`, graceful failures) | 5 |
| Weakened VM test - all 5 misconfigs detected in output | 15 |
| Write-up - whitelist scaling answer, undetectable attack | 15 |

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - CVSS Environmental Scoring & STRIDE Threat Model (30 pts)

**CVSS Environmental Scoring (15 pts)**

Extend `hw-02-audit.sh` to calculate a **CVSS v3.1 Environmental Score** for each CRITICAL finding. For each finding, the JSON output must include a `cvss` object with:

```json
{
  "base_vector": "AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H",
  "base_score": 6.7,
  "modified_attack_vector": "L",
  "confidentiality_requirement": "H",
  "integrity_requirement": "H",
  "availability_requirement": "M",
  "environmental_score": 7.2,
  "severity": "High"
}
```

You must implement the Environmental score calculation in bash (no external tools). Document your scoring rationale for each finding type in your write-up - explain why you assigned the Confidentiality/Integrity/Availability Requirements you did.

**STRIDE Threat Model (15 pts)**

Produce a formal STRIDE threat model for a Linux server running the services your audit examines (SSH, cron, web server, sudo). Your threat model must:

1. Create a Data Flow Diagram (DFD, Level 1) - can be ASCII art or a linked image - showing external actors, processes, data stores, and trust boundaries
2. For each of the 6 STRIDE categories, identify at least one concrete threat against your system and map it to a specific finding type your audit script checks (or explicitly note if it is a blind spot)
3. For each threat, assign a DREAD score and rank your top 3 threats
4. For your top-ranked threat, propose a specific detective and preventive control beyond what your audit script currently checks, and explain what data source would be required to detect it

Submit your threat model as `cyber-hw-02-threat-model.md`.


[← Back to Homework]({{ site.baseurl }}/homework/)
