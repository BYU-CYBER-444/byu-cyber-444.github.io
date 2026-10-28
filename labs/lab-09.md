---
title: "LAB 9 - CIS Benchmark Assessment & Targeted Remediation"
parent: Labs
nav_order: 9
---

# LAB 9 - CIS Benchmark Assessment & Targeted Remediation
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Purpose

Assess a Rocky Linux 9 server against the CIS Level 1 Server profile, explain what five selected controls are intended to prevent, apply the controls, and use AIDE to detect an unexpected privileged file.

By the end of the lab, you should be able to interpret control-level scan results, connect hardening controls to attack techniques, verify configuration in the running system, and explain what an integrity-monitoring baseline can and cannot tell you.

## Environment and constraints

- Use the Rocky Linux 9 VM provisioned for you: `lab09-cis01`. Log in with your own Net ID.
- OpenSCAP, the SCAP Security Guide content, and AIDE are installed already.
- The assessment uses the `cis_server_l1` profile in `/usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml`.
- Optional references: [CIS Rocky Linux 9 Benchmark](https://www.cisecurity.org/benchmark/rocky_linux) and [MITRE ATT&CK](https://attack.mitre.org).

{: .note }
OpenSCAP's content is derived from the RHEL content in the SCAP Security Guide. The report uses the title “CIS Red Hat Enterprise Linux 9 Benchmark”; it is a measurement against the benchmark, not a CIS certification or official CIS score.

The autograder connects to your VM and checks its state; it does not read or grade a written report. Keep the VM accessible while grading. Do not remove or alter the `ta` account, its SSH key, or its sudo access; add SSH allow/deny rules; change the installed SCAP content or `oscap`; or stop `sshd` or `crond`.

## Work to complete

### 1. Establish and interpret a baseline

Before changing the VM, assess it with the `cis_server_l1` profile. Save the result files in your home directory as:

- `/home/<netid>/lab09-baseline.xml`
- `/home/<netid>/lab09-baseline.html`

Review the HTML findings for the five controls listed below. Read each control's description, rationale, and remediation guidance. The XML is the machine-readable evidence; retain it unchanged for the final check. An OpenSCAP exit code of `2` is expected when the scan finds failing rules.

### 2. Relate controls to ATT&CK techniques

For each control, select the one MITRE ATT&CK technique from the list that best describes the threat it helps prevent. Base your choice on the control rationale and the technique definition. A technique can apply to more than one control.

Save `/home/<netid>/lab09-attack-map.csv` as a CSV with this exact header and one row per rule, in the order shown:

```text
rule_id,technique_id
sshd_set_max_auth_tries,T1xxx.xxx
sshd_disable_root_login,T1xxx.xxx
kernel_module_cramfs_disabled,T1xxx.xxx
sudo_require_reauthentication,T1xxx.xxx
sudo_add_use_pty,T1xxx.xxx
```

Choose only from these techniques:

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

### 3. Apply and verify the five controls

Use each rule's rationale and remediation guidance to decide how to harden the VM. The five areas are SSH authentication attempts, direct root SSH access, the `cramfs` kernel module, sudo reauthentication, and sudo terminal handling. Make each change effective on the VM, validate configuration syntax where applicable, and check the running state. A file edit by itself is not sufficient when the service or kernel behavior must change.

| OpenSCAP rule ID | Control area |
|---|---|
| `sshd_set_max_auth_tries` | SSH authentication attempts |
| `sshd_disable_root_login` | Direct root SSH access |
| `kernel_module_cramfs_disabled` | `cramfs` kernel module |
| `sudo_require_reauthentication` | Sudo reauthentication |
| `sudo_add_use_pty` | Sudo terminal handling |

Validate SSH changes before reloading the service. Keep your current session open and verify a second login before closing it. Use `visudo` or validate a sudoers drop-in with `visudo -c` so a syntax error does not disable sudo.

Check individual controls during your work. The final full-profile assessment in the next task is the required evidence that all five pass together.

### 4. Produce a post-remediation assessment

Document the VM's final condition with a second full-profile OpenSCAP report. Put the result files in your home directory at:

- `/home/<netid>/lab09-post-remediation.xml`
- `/home/<netid>/lab09-post-remediation.html`

Review the new report beside your baseline. Use rule-level details to identify any remaining issue, correct it, and capture an updated final report. Keep both XML snapshots separate and unchanged.

### 5. Establish and exercise AIDE monitoring

After the remediations, initialize the AIDE database and install the new database as `/var/lib/aide/aide.db.gz`. Confirm that the active database exists and is non-empty.

Exercise AIDE with a temporary, unauthorized SUID file under `/usr/local/bin`, then remove that file and confirm the test artifact is gone. The autograder performs its own detection check; your manual test is practice. The cron job is created after the baseline, so it may also be reported as a new AIDE entry.

Schedule a daily check by creating `/etc/cron.d/aide-check` with exactly this line:

```text
0 3 * * * root /usr/sbin/aide --check >> /var/log/aide-check.log 2>&1
```

Make sure `crond` is enabled and active. Do not edit `/etc/aide.conf` to exclude paths.

## Required evidence and grading

Nothing is uploaded. Keep the named files in your home directory and leave the required configuration on the VM for the autograder.

| Part | What is checked | Points |
|---|---|---:|
| 1 | Baseline assessment and retained result files. | 10 |
| 2 | ATT&CK mapping file and its five control-to-technique choices (2 points each). | 10 |
| 3 | Effectiveness of the five remediations, including verification on the VM (10 points each). | 50 |
| 4 | Post-remediation assessment and comparison with baseline. | 10 |
| 5 | AIDE database exists (5); AIDE detects the grader's temporary SUID file as added (10); the exact daily cron job exists and `crond` is enabled and active (5). | 20 |
| | **Total** | **100** |

The autograder removes its temporary test file when it finishes. There are no written answers, screenshots, or reports to submit; grading is based on evidence and system state that can be checked mechanically.

[← Back to Labs]({{ site.baseurl }}/labs/)
