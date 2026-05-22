---
title: "HW 2 - User Account Audit Bash Script"
parent: Homework
nav_order: 2
---

# HW 2 - User Account Audit Bash Script
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
| **Assignment** | HW 2 |
| **Points** | 100 |
| **Due** | Week 3 |

---

## Description

Write a Bash script that performs a system user account audit:

1. Lists all users with UID < 1000
2. Displays their login shell and home directory
3. Flags any non-system accounts (UID 0–999 with `/bin/bash` or `/bin/sh` shell)
4. Outputs findings to a dated report file in `/var/log/audit_reports/`

---

## Deliverable(s)

Write your write-up in `homework/hw-02.md` (use the [homework template]({% link resources/portfolio-setup.md %}#homework-template)). Commit your script and sample output to `homework/assets/` using **exactly these filenames**:

- `homework/assets/hw-02-audit.sh` - your audit script
- `homework/assets/hw-02-output.txt` - sample execution output from your lab Ubuntu VM

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow will automatically run `homework/assets/hw-02-audit.sh` against a test environment and post a results comment on your PR. The file path and name must match exactly or the auto-grader will not find your script. You can re-push commits to fix issues - the grader re-runs on each new commit.

Open a PR titled `HW 2 - User Account Audit Bash Script` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric


| Criterion | Points |
|---|---|
| Script functionality (all 4 requirements) | 50 |
| Code quality & inline comments | 25 |
| Output formatting | 15 |
| Edge case handling (empty shell, locked accounts) | 10 |


---

## Tip

{: .tip }
Test your script against a fresh Ubuntu VM with both system accounts and at least 2 test user accounts you create.

---

[← Back to Homework]({{ site.baseurl }}/homework/)
