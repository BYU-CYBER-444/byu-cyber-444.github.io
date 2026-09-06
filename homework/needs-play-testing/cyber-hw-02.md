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

## Description

This assignment is about **using and interpreting** a security audit tool, not writing one. You are given a working audit script that checks 5 categories - filesystem, accounts, network, SSH, and scheduled tasks - and a sample of its expected output; your job is to run it against 3 target machines you don't already know the state of, and produce a findings analysis a sysadmin could actually act on.

You are provided:
- [`cyber-hw-02-audit.sh`]({% link homework/description-files/cyber-hw-02-audit-script.md %}) - the audit script itself
- [Sample Audit Output]({% link homework/description-files/cyber-hw-02-sample-output.md %}) - reference clean-run and planted-issue output, for calibrating that the script is working correctly on your system

Your instructor has provisioned **four Rocky 9 VMs** for this assignment - one known-clean **HW 2 baseline VM**, plus **three target VMs** - connection details and credentials are on Learning Suite. You are not told in advance what, if anything, is wrong on any of the three targets; that's the point of running an audit rather than being handed a list of known issues.

### Part 1 - Run the Audit (20 pts)

1. Save the script as `cyber-hw-02-audit.sh` and `chmod +x` it.
2. **Before touching the target VMs:** run it against the **HW 2 baseline VM** and compare your output against the Sample Audit Output reference. Confirm the report file passes `jq empty` and its schema matches. Don't skip this step: if the script isn't behaving correctly on a machine you understand, you can't trust its results on one you don't.
3. Run `sudo ./cyber-hw-02-audit.sh` against each of the 3 target VMs. Do not modify the script or the target machines - the script is read-only and safe to run more than once if you need to re-check something.
4. Save each run's report with a name that identifies which machine it came from, e.g. `cyber-hw-02-target1.json`, `cyber-hw-02-target2.json`, `cyber-hw-02-target3.json`. Confirm all three pass `jq empty` before moving on.

### Part 2 - Findings Analysis & Remediation (45 pts)

For **each of the 3 target machines**, write up:

- A summary of findings by severity (how many CRITICAL, WARNING, INFO, and what categories of check they came from)
- The single most urgent finding on that machine, and a one-paragraph justification for why it's the most urgent (not just "it's CRITICAL" - explain the actual risk)
- For every CRITICAL and WARNING finding, a specific remediation step - the exact command or configuration change that would fix it, not a general description like "restrict permissions"

Then, across all 3 machines:

- **Rank the machines from highest to lowest risk** and justify the ranking. Raw finding count is not the same as risk - explain why your ranking is or isn't just "the machine with the most findings wins."
- If you had one hour to remediate before a compliance audit and could only fully address **one** of the three machines, which would you choose and why?

### Part 3 - Reflection Write-Up (35 pts)

1. This script uses a hardcoded SUID whitelist. In a real enterprise environment managing 200 servers with different roles (web, database, build), how would you manage this whitelist at scale? Describe a practical approach.
2. What category of attack would NOT be detected by this script, even with all 5 categories running? Describe one real attack technique (name a MITRE ATT&CK technique) that leaves no trace in the artifacts this script examines, and explain what additional data source would be needed to detect it.
3. This script now checks 5 categories against a real 200-server fleet. Which single category do you think would generate the most **false positives** at that scale, and why? Propose one specific change to that category's logic (a config option, an exception list, a different threshold) that would cut down the noise without just turning the check off. Separately: which category's findings would you treat as highest priority to triage first if a fleet-wide scan came back with results in all 5 categories at once, and why?

### What This Script Checks

{: .note }
The finding `check` and `severity` values below are exactly what appears in each finding's JSON - useful for Part 2 when you're cross-referencing your 3 target machines' reports.

| Category | `check` | Severity | What it means |
|---|---|---|---|
| `filesystem` | `unexpected_suid` | WARNING | SUID/SGID binary not on the script's whitelist |
| `filesystem` | `world_writable` | WARNING | World-writable file/dir under `/etc`, `/usr`, or `/home` |
| `filesystem` | `bad_permissions` | CRITICAL | Wrong owner/mode on `/etc/passwd`, `/etc/shadow`, or `/etc/sudoers` |
| `filesystem` | `unowned_file` | WARNING | File/dir owned by a UID or GID with no matching account |
| `accounts` | `duplicate_uid0` | CRITICAL | An account other than `root` has UID 0 |
| `accounts` | `empty_password` | CRITICAL | An account has a blank password hash in `/etc/shadow` |
| `accounts` | `stale_privileged_account` | WARNING | A `wheel`-group member hasn't logged in within 90 days (or never) |
| `accounts` | `nopasswd_sudo` | WARNING | An active `NOPASSWD` entry exists in sudoers |
| `network` | `unexpected_listener` | WARNING | A service is listening on all interfaces on a port not on the expected list |
| `network` | `external_connection` | INFO | An established outbound connection to a non-private address |
| `ssh` | `ssh_password_auth_enabled` | WARNING | `PasswordAuthentication yes` in `sshd_config` |
| `ssh` | `ssh_root_login_enabled` | CRITICAL | `PermitRootLogin yes` in `sshd_config` |
| `ssh` | `ssh_x11_forwarding_enabled` | WARNING | `X11Forwarding yes` in `sshd_config` |
| `ssh` | `ssh_protocol1_enabled` | CRITICAL | Deprecated, broken SSH protocol 1 enabled |
| `ssh` | `excessive_authorized_keys` | WARNING | An account's `authorized_keys` has more than 5 entries |
| `cron` | `cron_world_writable_path` | CRITICAL | A scheduled command runs from a world-writable directory |
| `cron` | `cron_writable_script` | CRITICAL | A root-run scheduled command's script file is group/other-writable |

The script's own comments explain the detection logic and any simplifying assumptions (e.g. the stale-account check only looks at supplementary `wheel` membership, not primary-group membership) if you want the full detail behind any row above.

---

## Deliverable(s)

{: .callout }

Commit to `homework/assets/` using exactly these filenames:

- `cyber-hw-02-target1.json`, `cyber-hw-02-target2.json`, `cyber-hw-02-target3.json` - the raw audit reports from each target VM

Write your analysis (Parts 2 and 3) in `homework/cyber-hw-02.md`.

Open a PR titled `CYBER HW 2 - Linux Security Audit Suite` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Part 1 - all 3 reports collected correctly, valid JSON, correct schema | 20 |
| Part 2 - per-machine findings summary, urgency justification, specific remediation | 30 |
| Part 2 - cross-machine risk ranking and prioritization | 15 |
| Part 3 - whitelist scaling, undetectable attack, false-positive tuning & triage priority | 35 |


[← Back to Homework]({{ site.baseurl }}/homework/)
