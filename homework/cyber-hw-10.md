---
title: "CYBER HW 10 - Configuration Drift: Detection, Threat Modeling & Monitoring"
parent: Homework
nav_order: 10
---

# CYBER HW 10 - Configuration Drift: Detection, Threat Modeling & Monitoring
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
| **Assignment** | CYBER HW 10 |
| **Points** | 100 |
| **Due** | Week 11 |
| **Track** | Cyber |

---

## Description

Configuration drift is how hardened systems become vulnerable over time. This assignment has you deliberately break a hardened VM six different ways, detect each instance of drift, threat-model its exploitation, and build automated detection.

### Part 1 - Drift Introduction & Detection (40 pts)

Start from your hardened Ubuntu VM (Lab 9 / HW 9 baseline). Introduce **6 configuration changes** that violate your hardening controls, then detect them with Ansible check mode.

Your 6 drift scenarios must include:

1. **Obvious credential risk:** Change SSH `PasswordAuthentication` to `yes`
2. **Service re-enablement:** Re-enable a previously disabled service (e.g., `avahi-daemon` or `cups`)
3. **Auditd rule removal:** Delete 3 auditd rules your playbook added
4. **Sysctl kernel weakening:** Change at least 2 sysctl hardening parameters back to their defaults
5. **Subtle permission drift:** Change `/etc/shadow` permissions from 640 to 644 (this is easy to overlook)
6. **Cron-based persistence (subtle):** Add a cron job that runs as root from a world-writable directory - this mimics attacker persistence and should be detected by your audit controls

For each drift scenario, document:
- The exact command you ran to introduce the drift
- The Ansible task name that detects it
- The full `changed` line from `ansible-playbook --check -v` output

Run `ansible-playbook site.yml --check -v` and paste the relevant sections showing all 6 changes detected.

Then run the playbook normally (without `--check`) to remediate, and run `--check` again to show `changed=0`.

### Part 2 - Threat Model for Each Drift Scenario (35 pts)

For each of your 6 drift scenarios, write a threat model entry:

| Drift | MITRE ATT&CK Technique(s) | Attack Scenario | Preconditions for Exploitation | Time to Exploit (estimate) | Detection Opportunity |
|---|---|---|---|---|---|

**Attack scenario** - describe concretely how an attacker would exploit this specific misconfiguration. Use a realistic attacker model (e.g., external attacker with network access but no credentials, or internal attacker with unprivileged shell access).

**Detection opportunity** - what log entry, network anomaly, or behavioral indicator would be generated if this misconfiguration were actively exploited? Be specific: "Event ID 4624 with Logon Type 3 from an unexpected source IP" is specific; "check logs" is not.

For scenario 6 (cron persistence), write an additional 1-paragraph analysis of why this technique is effective against organizations that only run periodic compliance scans vs. organizations with continuous monitoring.

### Part 3 - Automated Drift Detection (25 pts)

Build a solution that detects drift continuously without running Ansible manually:

**Option A (recommended):** Write a bash script `cyber-hw-10-drift-monitor.sh` that:
- Checks 8 specific configuration items from your hardening baseline (SSH config values, sysctl values, file permissions, service states, and auditd rules)
- For each item, prints `[OK]` or `[DRIFT DETECTED]` with the expected vs. actual value
- Exits with code 1 if any drift is found
- Logs all findings to `/var/log/drift-monitor-YYYY-MM-DD.log`
- Includes a `--remediate` flag that calls `ansible-playbook site.yml` when drift is detected

Then write a systemd service and timer that runs this script every 15 minutes:
- `cyber-hw-10-drift-monitor.service`
- `cyber-hw-10-drift-monitor.timer`

Include the output of `systemctl status cyber-hw-10-drift-monitor.timer` showing the timer is active.

**Option B:** Use `auditd` watch rules to detect the specific file modifications that constitute drift (e.g., `inotify` on `/etc/ssh/sshd_config`, `/etc/sysctl.conf`, `/etc/shadow`). Write 8 `auditd` watch rules and demonstrate that introducing drift triggers a log entry within 60 seconds.

---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-10.md`. Commit to `homework/assets/`:

- `cyber-hw-10-drift-monitor.sh` - your drift detection script
- `cyber-hw-10-drift-monitor.service` and `.timer` - systemd unit files
- `cyber-hw-10-check-mode-output.txt` - full `--check -v` output showing all 6 drifts detected
- `cyber-hw-10-remediated-output.txt` - `--check` output after remediation showing changed=0

Open a PR titled `CYBER HW 10 - Configuration Drift` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| 6 drift scenarios introduced and detected - evidence provided | 40 |
| Threat model - ATT&CK mapping, realistic attack scenarios, detection opportunities | 35 |
| Drift detection script - 8 checks, exit codes, logging | 20 |
| Systemd timer - active and running, output shown | 5 |

---

## Tip

{: .tip }
For scenario 6 (cron persistence), `echo "* * * * * root /tmp/backdoor.sh" >> /etc/cron.d/maintenance` is the kind of subtle drift an attacker would introduce. Your drift monitor should check for unexpected files in `/etc/cron.d/` and for cron entries referencing world-writable paths.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - Drift Response Playbook & Forensic Preservation (30 pts)

**Drift Response Playbook (15 pts)**

For each of your 6 drift scenarios, produce a formal **Drift Response Playbook** entry (`cyber-hw-10-playbook.md`) following this structure:

| Field | Content |
|---|---|
| Scenario ID | DR-01 through DR-06 |
| Drift Description | What changed and on what artifact |
| MITRE ATT&CK TTP | Technique ID and name |
| Detection Method | Which check catches it (Ansible check-mode, systemd timer, manual) |
| Triage Steps | Ordered list: what to check first, second, third |
| Containment | Immediate action to prevent further damage (isolate? disable? snapshot?) |
| Eradication | How to restore known-good state (Ansible re-run, restore from backup, rebuild) |
| Verification | How to confirm the system is clean (commands + expected output) |
| Evidence Preservation | What artifacts to capture before remediation and where to store them |
| Escalation Trigger | Criteria that escalate from automatic remediation to human IR |

**Forensic Snapshot Mechanism (15 pts)**

Implement `cyber-hw-10-snapshot.sh`: a script that runs automatically when your systemd drift monitor detects a change. Before any remediation occurs, the script must:

1. Capture: running process list (`ps auxf`), open network connections (`ss -tupan`), loaded kernel modules (`lsmod`), recently modified files in `/etc`, `/usr/bin`, `/usr/sbin`, `/tmp` (find -mmin -60), and SHA-256 hashes of all binaries in your SUID whitelist
2. Write all output to `/var/forensics/YYYY-MM-DD_HH-MM-SS/` with one file per artifact category
3. Create a manifest file listing each artifact's filename, capture time, and SHA-256 hash of the artifact file itself (chain of custody)
4. Alert: print a structured JSON alert to stdout (suitable for shipping to a SIEM via systemd journal) with `severity`, `drift_type`, `snapshot_path`, and `host`

Demonstrate the snapshot mechanism by triggering one of your drift scenarios and showing the populated `/var/forensics/` directory.


[← Back to Homework]({{ site.baseurl }}/homework/)
