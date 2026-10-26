---
title: "CYBER LAB 9 - CIS Benchmark Assessment & Targeted Remediation"
parent: Labs
nav_order: 9
---

# CYBER LAB 9 - CIS Benchmark Assessment & Targeted Remediation
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run a CIS Level 1 Server assessment with OpenSCAP and read the results at the control level
- Map failing controls to the MITRE ATT&CK techniques they are designed to prevent
- Remediate five specific failing controls by hand and confirm each fix
- Implement AIDE filesystem integrity monitoring and verify it detects an unauthorized file

---

## Tools Required

- Your instructor has provisioned a Rocky Linux 9 VM for this lab, `cyber-lab08-cis01`. Your username on it is your Net ID, and your password is the one emailed to you at the start of the semester.
- OpenSCAP, the SCAP Security Guide content, and AIDE are already installed on the VM. You do not need to install anything.
- [CIS Rocky Linux 9 Benchmark PDF](https://www.cisecurity.org/benchmark/rocky_linux) (optional reading; free for non-commercial use with a short registration)
- [MITRE ATT&CK](https://attack.mitre.org) for looking up techniques

{: .note }
CIS-CAT Pro, CIS's own scanner, is limited to CIS SecureSuite members for Rocky Linux, so this lab uses OpenSCAP instead. Rocky's SCAP content is derived from the RHEL content in the SCAP Security Guide (the profile titles in the report say "CIS Red Hat Enterprise Linux 9 Benchmark") and is **not certified by CIS**. Treat its results as a measurement against the CIS Benchmark, not as an official CIS score.

---

## Background

A benchmark treats every FAIL as equally worth fixing, but a real organization has to prioritize, and prioritization requires knowing what attack technique a control actually blocks. This lab pairs benchmark assessment with MITRE ATT&CK mapping so remediation decisions are grounded in "what does this control stop," not just "what does the checklist say," and closes with AIDE filesystem monitoring as a reminder that a clean compliance score is a point-in-time snapshot, not a guarantee nothing changes after you stop looking.

### How this lab is graded

**Nothing is uploaded.** After the deadline the autograder logs in to your VM and checks its state. It does not read any report you write, and it does not trust your scan results alone: it runs its own OpenSCAP scan, checks the live system, and tests AIDE itself. Every item below is a pass or fail check with a fixed answer. The files and settings the autograder looks for are named exactly, so follow the names and paths in this document literally.

To keep the autograder able to log in and run its checks, do **not**:
- Remove or edit the `ta` account, its SSH key, or its sudo access. Run `sudo visudo -c` after any sudoers change.
- Add `AllowUsers`, `AllowGroups`, `DenyUsers`, or `DenyGroups` lines to `sshd_config`.
- Edit, replace, or delete anything under `/usr/share/xml/scap/` or the `oscap` program.
- Shut down the VM or stop `sshd` or `crond`.

---

## The Five Controls

You will remediate exactly these five controls. They are fixed so that every student is held to the same standard. Search the HTML report for the rule ID to find each one.

| # | OpenSCAP rule ID |
|---|---|
| 1 | `sshd_set_max_auth_tries` |
| 2 | `sshd_disable_root_login` |
| 3 | `kernel_module_cramfs_disabled` |
| 4 | `sudo_require_reauthentication` |
| 5 | `sudo_add_use_pty` |

---

## Procedure

Do all of your work logged in as your own Net ID. The files you create must be in your home directory, `/home/<netid>/`, with the exact names given.

### Part 1 - Baseline CIS Assessment

Run a CIS Level 1 Server assessment **before you change anything**:

```bash
cd ~
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
  --results ~/cyber-lab08-baseline.xml \
  --report ~/cyber-lab08-baseline.html \
  /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml
```

{: .note }
`oscap` exits with code 2 when any rule fails. That is normal and not an error in your command.

Copy `cyber-lab08-baseline.html` to your workstation (for example with `scp`) and read it. Find each of the five controls above and read its description, rationale, and fix text. Do not move, rename, or edit `cyber-lab08-baseline.xml`.

### Part 2 - ATT&CK Mapping

For each of the five controls, choose the **one** technique from the list below that the control is best designed to prevent. A technique may be used for more than one control. Create `~/cyber-lab08-attack-map.csv` containing exactly a header line and five data lines in this format:

```
rule_id,technique_id
sshd_set_max_auth_tries,T1xxx.xxx
sshd_disable_root_login,T1xxx.xxx
kernel_module_cramfs_disabled,T1xxx.xxx
sudo_require_reauthentication,T1xxx.xxx
sudo_add_use_pty,T1xxx.xxx
```

Use the rule IDs exactly as written above, and put a technique ID from this list (and only this list) in each row:

| Technique ID | Name |
|---|---|
| T1021.004 | Remote Services: SSH |
| T1059.004 | Command and Scripting Interpreter: Unix Shell |
| T1068 | Exploitation for Privilege Escalation |
| T1070.002 | Indicator Removal: Clear Linux or Mac System Logs |
| T1078.003 | Valid Accounts: Local Accounts |
| T1091 | Replication Through Removable Media |
| T1110.001 | Brute Force: Password Guessing |
| T1548.003 | Abuse Elevation Control Mechanism: Sudo and Sudo Caching |
| T1556 | Modify Authentication Process |
| T1557 | Adversary-in-the-Middle |

Use the control's rationale in the report and the technique pages on attack.mitre.org to decide.

### Part 3 - Remediate the Five Controls

Fix each of the five controls on the VM. Read the rule's rationale and fix text first, make the change yourself, and restart or reload any service the change affects so it is active now, not only in a file. The autograder checks that each rule passes in a fresh scan **and**, where a running service or kernel setting is involved, that the live system reflects the fix.

Worked example for control 1, SSH `MaxAuthTries`:

```bash
sudo vi /etc/ssh/sshd_config          # set: MaxAuthTries 4
sudo sshd -t                          # syntax check; prints nothing if valid
sudo systemctl reload sshd
sudo sshd -T | grep -i maxauthtries   # expect: maxauthtries 4
```

{: .warning }
Do not lock yourself out. Keep your current SSH session open, run `sudo sshd -t` before reloading, and open a **second** session to confirm you can still log in before you close the first. For the sudo controls, edit with `sudo visudo` (or a file in `/etc/sudoers.d/` checked with `sudo visudo -cf <file>`) so a typo cannot break sudo.

Check your own work by rescanning a single rule:

```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
  --rule xccdf_org.ssgproject.content_rule_sshd_set_max_auth_tries \
  /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml | grep -E "^(Rule|Result)"
```

### Part 4 - Post-Remediation Assessment

After all five controls are fixed, rerun the full scan with new output names:

```bash
cd ~
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_server_l1 \
  --results ~/cyber-lab08-post-remediation.xml \
  --report ~/cyber-lab08-post-remediation.html \
  /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml
```

All five controls must show PASS in this scan. If one still shows FAIL after you believe it is fixed, find out why (the rule may check a different file than the one you edited, or the change may not be active yet), fix it, and rescan.

### Part 5 - AIDE Filesystem Integrity Monitoring

Complete this part **after** Part 3 is done, so your baseline reflects the remediated system.

Build the AIDE baseline and put it in place (this takes about a minute):

```bash
sudo aide --init
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```

For practice, simulate an attacker dropping a backdoor and watch AIDE catch it. This step is not graded, because the autograder runs its own test (below):

```bash
sudo cp /bin/bash /usr/local/bin/.hidden-shell
sudo chmod u+s /usr/local/bin/.hidden-shell
sudo aide --check 2>&1 | grep -iE "added|changed|removed|hidden-shell"
sudo rm /usr/local/bin/.hidden-shell
sudo aide --check 2>&1 | grep -iE "added|changed|removed" || echo "Clean"
```

Then schedule a daily AIDE check. Create `/etc/cron.d/aide-check` containing **exactly** this one line, and make sure the cron service is running and enabled:

```bash
echo "0 3 * * * root /usr/sbin/aide --check >> /var/log/aide-check.log 2>&1" | sudo tee /etc/cron.d/aide-check
sudo systemctl enable --now crond
```

Do not change `/etc/aide.conf` to exclude any path.

---

## What the Autograder Checks

| Part | Check | Points |
|------|-------|--------|
| 1 | `~/cyber-lab08-baseline.xml` is a valid OpenSCAP result for the `cis_server_l1` profile and shows all five controls as FAIL | 10 |
| 2 | `~/cyber-lab08-attack-map.csv` has the required format and each of the five rows has the correct technique (2 points each) | 10 |
| 3 | Each control is remediated (6 points each): the rule passes in the autograder's own fresh scan, and the live `sshd` / kernel / sudo state matches | 30 |
| 4 | `~/cyber-lab08-post-remediation.xml` is a valid result for the same profile, was produced after the baseline, and shows all five controls as PASS | 10 |
| 5 | An AIDE baseline exists at `/var/lib/aide/aide.db.gz` (5), the autograder places its own unauthorized SUID file on the VM and `aide --check` reports it as added (10), and the daily check is scheduled exactly as specified with `crond` active and enabled (5) | 20 |
| | **Total** | **80** |

The autograder removes its own test file when it finishes. There are no written answers, screenshots, tables, or reports to submit, and no points are awarded for anything that cannot be checked mechanically.

[← Back to Labs]({{ site.baseurl }}/labs/)
