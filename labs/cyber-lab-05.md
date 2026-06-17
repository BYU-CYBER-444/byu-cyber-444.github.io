---
title: "CYBER LAB 5 - CIS Benchmark Assessment & Targeted Remediation"
parent: Labs
nav_order: 5
---

# CYBER LAB 5 - CIS Benchmark Assessment & Targeted Remediation
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 5 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

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

- Ubuntu 22.04 LTS VM
- CIS-CAT Pro (department license - credentials on Learning Suite)
- AIDE (`sudo apt install aide`)
- CIS Ubuntu 22.04 LTS Benchmark PDF (linked from CIS-CAT report)

---

## Procedure

### Part 1 - Baseline CIS-CAT Assessment

Run a full CIS-CAT Pro Level 1 assessment and export results:

```bash
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -pf CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/   -rp lab5-baseline   --html --json
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

Select 5 controls to remediate. Write a remediation script `lab5-remediate.sh` that implements all 5 idempotently (running it twice produces no errors and no changes on the second run):

```bash
#!/bin/bash
set -euo pipefail

echo "=== CIS Remediation Script - Lab 5 ==="
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
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/   -rp lab5-post-remediation   --html --json
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
sudo aide --check 2>&1 | tee /tmp/aide-lab5.txt
grep -E "added|changed|removed" /tmp/aide-lab5.txt
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

## Submission Requirements

- Pre-remediation CIS-CAT HTML report
- ATT&CK mapping table for 10 failing controls
- `lab5-remediate.sh` (annotated)
- First run output showing `[REMEDIATED]`; second run output showing all `[ALREADY DONE]` (proving idempotency)
- Post-remediation CIS-CAT HTML report
- Before/after comparison table
- Risk acceptance documentation for 5 non-remediated controls
- AIDE check output showing the unauthorized SUID binary detected
- Written reflection: What is the operational risk of NOT setting up AIDE monitoring even if your CIS-CAT score is 100%?

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Automated CIS Compliance Dashboard

Extend your remediation script into a full compliance tracking tool:

Write `lab5-compliance-tracker.py` that:
1. Parses the CIS-CAT JSON report output (`lab5-baseline.json` and `lab5-post-remediation.json`)
2. Produces a structured comparison output:
   ```json
   {
     "assessment_date": "2025-01-15",
     "baseline_score": 45.2,
     "post_remediation_score": 58.7,
     "delta": 13.5,
     "controls_remediated": 5,
     "controls_remaining_failed": 47,
     "top_risk_sections": [
       {"section": "5 - Access Authentication", "fail_count": 12, "mitre_techniques": ["T1110", "T1078"]},
       {"section": "4 - Logging", "fail_count": 8, "mitre_techniques": ["T1562.002"]}
     ]
   }
   ```
3. Outputs a plain-text executive summary suitable for a non-technical manager: overall posture grade (A/B/C/D/F based on score), one sentence per failing section describing the risk in business terms (not technical terms), and the top 3 recommended next remediations by ATT&CK technique impact.

Run the script against your actual JSON reports and submit the output.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
