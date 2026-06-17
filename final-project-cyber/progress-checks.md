---
title: Progress Checks
parent: Final Project
nav_order: 2
---

# Final Project Progress Checks
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Progress Check 1 - Automation

Submit the current state of your Final Project Ansible playbook or Terraform configuration for **one server** in your infrastructure. This checkpoint verifies that your automation is functional and moving toward compliance before you attempt to scan all three servers.

### Requirements

Your submission must include all of the following:

**1. Hardening Controls (minimum 20)**

Implement and verify at least 20 CIS Level 2 or STIG hardening controls on your target server. Each task must be named clearly and mapped to a control ID in a comment.

**2. Code Quality**

Your playbook or configuration must be fully idempotent, meaning a second run must produce 0 changed. Use handlers correctly (for example, restarting `auditd` when audit rules change). Tasks must be clearly named and logically grouped.

**3. Variable Externalization**

All site-specific values (org name, allowed SSH ciphers, log retention days, IP ranges) must be in a separate `vars/` or `.tfvars` file. No hardcoded values in task files.

**4. README**

Include a `README.md` in your automation directory covering:
- Purpose and scope
- Prerequisites (OS version, dependencies)
- Description of all variables
- Exact commands to run

**5. Baseline Scan Report**

Run a CIS-CAT or STIG scan on your target server and include the report. Briefly explain the current score and which controls are still open.

### Submission

Commit your automation directory, README, and scan report to your portfolio site and open a PR titled `Progress Check 1: Automation`. Submit the PR link on Learning Suite.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Control Count | 30 | 20+ controls implemented and verified | 15-19 controls | Fewer than 15 controls |
| Code Quality | 25 | Fully idempotent (0 changed on second run), handlers used correctly, tasks well-named | Mostly idempotent; minor issues | Not idempotent or significant structural problems |
| Variable Externalization | 20 | All site-specific values in a separate file; no hardcoded values in task files | Most values externalized; a few hardcoded | Variables mixed into task files |
| README | 15 | Covers purpose, prerequisites, all variables described, and exact run instructions | Most sections present; minor gaps | Missing key sections |
| Baseline Scan Report | 10 | CIS-CAT or STIG report included; score reported with brief analysis | Report included; no analysis | Report missing |

---

## Progress Check 2: Compliance Scans {#progress-check-2}

Submit CIS-CAT and STIG scan reports for **all three servers** in your final project environment. This checkpoint verifies that all servers are actively being hardened and that you are on track to meet compliance targets before the final deadline.

### Requirements

**1. Full Coverage**

Provide both a CIS-CAT HTML report and an OpenSCAP `.xml` or STIG Viewer `.ckl` result for each server, six report files total.

**2. Minimum Compliance Scores**

Each server must show a minimum 70% compliance score at this checkpoint. Servers below 70% will be flagged and must reach 85% by the final submission.

**3. Progress Narrative**

Include a one-page written narrative that covers:
- Current compliance score for each server
- Which control categories have the most open findings and why
- Specific remediation plan for the remaining gaps before Week 15
- Comparison to your Progress Check 1 baseline showing measurable improvement

### Submission

Commit all six scan reports and your progress narrative to your portfolio site and open a PR titled `Progress Check 2 - Compliance Scans`. Submit the PR link on Learning Suite.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Coverage | 25 | All 3 servers scanned with both CIS-CAT and STIG/OpenSCAP reports | All 3 servers; one scan type per server | Fewer than 3 servers scanned |
| Compliance Scores | 30 | All servers at 85% or above | All servers at 70% or above | At least one server below 70% |
| Report Format | 15 | CIS-CAT HTML + OpenSCAP `.xml` or STIG Viewer `.ckl` for each server; all readable | Correct format for most servers | Incorrect formats or missing files |
| Progress Narrative | 20 | Clearly explains unremediated controls, root cause, and remediation plan for each | Narrative present but surface-level | Narrative missing or fewer than one paragraph |
| Trend vs. Baseline | 10 | Scores compared to Progress Check 1 baseline with measurable improvement shown | Some comparison to prior state | No comparison to prior scan |

[Back to Final Project Overview]({% link final-project-cyber/index.md %})