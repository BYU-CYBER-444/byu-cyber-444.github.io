---
title: "CYBER LAB 8 - CIS Benchmark Assessment & Targeted Remediation"
parent: Labs
nav_order: 8
---

# CYBER LAB 8 - CIS Benchmark Assessment & Targeted Remediation
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run a full CIS-CAT Pro assessment and interpret results at the control level
- Map the top failing controls to MITRE ATT&CK techniques they are designed to prevent
- Remediate 5 high-impact controls with scripted, verifiable commands
- Write a formal risk acceptance statement for non-remediable controls
- Implement AIDE filesystem integrity monitoring and verify it detects a simulated attack

---

## Tools Required

- Your instructor has provisioned an Ubuntu 22.04 LTS VM for this lab, `cyber-lab08-cis01`
- CIS-CAT Pro (department license - credentials on Learning Suite)
- AIDE (`sudo apt install aide`)
- CIS Ubuntu 22.04 LTS Benchmark PDF (linked from CIS-CAT report)

---

## Background

A CIS-CAT score alone doesn't tell you which failing control actually matters - a benchmark treats every FAIL as equally worth fixing, but a real organization has to prioritize, and prioritization requires knowing what attack technique a control actually blocks. This lab pairs benchmark assessment with MITRE ATT&CK mapping so remediation decisions are grounded in "what does this control stop," not just "what does the checklist say," and closes with AIDE filesystem monitoring as a reminder that a clean compliance score is a point-in-time snapshot, not a guarantee nothing changes after you stop looking.

---

## Procedure

### Part 1 - Baseline CIS-CAT Assessment

Run a full CIS-CAT Pro Level 1 assessment and export results:

```bash
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -pf CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/   -rp cyber-lab08-baseline   --html --json
```

Open the HTML report and record:
- Overall score and per-section scores
- Count of FAIL results per section
- 10 failing controls with the highest remediation impact

### Part 2 - ATT&CK Mapping for Failing Controls

For each of your 10 failing controls, identify the MITRE ATT&CK technique(s) the control is designed to prevent. Build a mapping table:

| CIS Control ID | Description | Status | ATT&CK Technique | Technique Name |
|---|---|---|---|---|
| 1.1.1.1 | Disable mounting of cramfs | FAIL | T1092 | ... |
| 5.2.5 | Ensure SSH MaxAuthTries is ≤ 4 | FAIL | T1110.001 | Brute Force: Password Guessing |
| ... | | | | |

Use the MITRE ATT&CK website (attack.mitre.org) to look up techniques. This mapping demonstrates WHY each control matters beyond "the benchmark says so."

### Part 3 - Scripted Remediation for 5 Controls

Select 5 controls to remediate. Write a remediation script `cyber-lab08-remediate.sh` that implements all 5 idempotently (running it twice produces no errors and no changes on the second run):

```bash
#!/bin/bash
set -euo pipefail

echo "=== CIS Remediation Script - Lab 8 ==="
echo "Run as root. Idempotent - safe to run multiple times."
echo ""

# CIS 1.1.1.1 - Disable cramfs filesystem
CONTROL="1.1.1.1"; DESC="Disable cramfs"
if ! grep -q "install cramfs /bin/true" /etc/modprobe.d/cramfs.conf 2>/dev/null; then
  echo "install cramfs /bin/true" >> /etc/modprobe.d/cramfs.conf
  rmmod cramfs 2>/dev/null || true
  echo "[REMEDIATED] $CONTROL: $DESC"
else
  echo "[ALREADY DONE] $CONTROL: $DESC"
fi

# CIS 5.2.5 - SSH MaxAuthTries <= 4
CONTROL="5.2.5"; DESC="SSH MaxAuthTries <= 4"
if ! grep -qE "^MaxAuthTries [1-4]$" /etc/ssh/sshd_config; then
  sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
  systemctl reload sshd
  echo "[REMEDIATED] $CONTROL: $DESC"
else
  echo "[ALREADY DONE] $CONTROL: $DESC"
fi

# Add your other 3 remediations here...
```

Requirements for the script:
- Each remediation must print `[REMEDIATED]` or `[ALREADY DONE]`
- Must be idempotent (run it twice, second run shows all `[ALREADY DONE]`)
- Must reload/restart affected services where applicable

### Part 4 - Post-Remediation Assessment

```bash
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/   -rp cyber-lab08-post-remediation   --html --json
```

Build a before/after comparison table for your 5 remediated controls:

| CIS Control ID | Pre-Score | Post-Score | Delta | Verified |
|---|---|---|---|---|
| 1.1.1.1 | FAIL | PASS | +1 | Yes |
| 5.2.5 | FAIL | PASS | +1 | Yes |

Record the overall score delta.

### Part 5 - Risk Acceptance Documentation

For the remaining 5 failing controls you did NOT remediate, write formal **Risk Acceptance** entries. Each entry must contain:

| Field | Content |
|---|---|
| Control ID | e.g., CIS 2.2.1.2 |
| Control Description | Full text |
| Risk Justification | Why this cannot be remediated now |
| ATT&CK Technique | What attack this control prevents |
| Residual Risk Level | High / Medium / Low with rationale |
| Compensating Control | What alternative control partially mitigates the risk |
| Acceptance Owner | Your name (as the system owner for this lab) |
| Review Date | 90 days from today |

### Part 6 - AIDE Filesystem Integrity Monitoring

Initialize AIDE after your remediations are complete:

```bash
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
echo "AIDE baseline initialized: $(date)" | sudo tee /var/log/aide-init.log
```

Simulate an attacker dropping a backdoor:

```bash
# Simulate an unauthorized SUID binary (common persistence technique)
sudo cp /bin/bash /usr/local/bin/.hidden-shell
sudo chmod u+s /usr/local/bin/.hidden-shell
echo "Backdoor planted: $(date)"
```

Run AIDE check and verify detection:

```bash
sudo aide --check 2>&1 | tee /tmp/aide-lab8.txt
grep -E "added|changed|removed" /tmp/aide-lab8.txt
```

Clean up and verify AIDE reports clean:

```bash
sudo rm /usr/local/bin/.hidden-shell
sudo aide --check 2>&1 | grep -E "added|changed|removed" || echo "Clean"
```

Set up a daily AIDE check cron job:

```bash
echo "0 3 * * * root /usr/bin/aide --check | mail -s 'AIDE Daily Report' root" | sudo tee /etc/cron.d/aide-check
```

---

## Deliverables

- Pre-remediation CIS-CAT HTML report
- ATT&CK mapping table for 10 failing controls
- `cyber-lab08-remediate.sh` (annotated)
- First run output showing `[REMEDIATED]`; second run output showing all `[ALREADY DONE]` (proving idempotency)
- Post-remediation CIS-CAT HTML report
- Before/after comparison table
- Risk acceptance documentation for 5 non-remediated controls
- AIDE check output showing the unauthorized SUID binary detected
- Written reflection: What is the operational risk of NOT setting up AIDE monitoring even if your CIS-CAT score is 100%?

---

## Grading

| Item | Points |
|------|--------|
| Baseline CIS-CAT assessment (Part 1) | 10 |
| ATT&CK mapping table - 10 controls (Part 2) | 15 |
| Scripted remediation - idempotent, 5 controls (Part 3) | 25 |
| Post-remediation assessment and comparison (Part 4) | 15 |
| Risk acceptance documentation - 5 controls (Part 5) | 15 |
| AIDE monitoring - backdoor detection verified (Part 6) | 15 |
| Written reflection - AIDE vs. compliance score | 5 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
