---
title: "CYBER HW 6 - STIG Assessment, POAM & Automated Remediation"
parent: Homework
nav_order: 6
---

# CYBER HW 6 - STIG Assessment, POAM & Automated Remediation
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
| **Assignment** | CYBER HW 6 |
| **Points** | 100 |
| **Due** | Week 7 |
| **Track** | Cyber |

---

## Description

Using the OpenSCAP results from **Lab 6**, produce a professional STIG assessment package - the same artifacts you would deliver to a DoD ISSO (Information System Security Officer).

### Part 1 - STIG Finding Documentation (40 pts)

Document **25 STIG findings** from your Lab 6 scan results. For each finding:

| STIG ID | Rule Title | Severity (CAT I/II/III) | Status | Finding Details | Fix Text | Compensating Control (if NA) |
|---|---|---|---|---|---|---|

**Status definitions:**
- **Open** - the finding applies and has not been remediated
- **Not a Finding (NF)** - the check ran and the system is compliant
- **Not Applicable (NA)** - the control does not apply to this system; you must provide a written justification and a compensating control if the underlying intent still applies
- **Not Reviewed (NR)** - you could not evaluate the control; explain why

Your 25 findings must include at least: 3 CAT I, 10 CAT II, and 5 CAT III. Status distribution must be realistic - not all NF. At least 6 must be Open.

For every **Open** finding: write the specific remediation command or configuration change required.

### Part 2 - Automated Remediation Script (25 pts)

Write `cyber-hw-06-stig-fix.sh` that automates remediation for **5 of your Open findings** (choose the 5 highest-severity Open findings). For each:

1. Comment the STIG ID and rule title
2. Check the current state before remediating (print `[BEFORE]` output)
3. Apply the fix
4. Verify the fix (print `[AFTER]` output showing the corrected state)
5. Log the action to `/var/log/stig-remediation.log`

The script must be idempotent - running it twice on an already-remediated system must produce no errors and log "already compliant" for each control.

Run the script and include the full terminal output in your submission.

### Part 3 - POAM (Plan of Action & Milestones) (25 pts)

For all **Open** findings, create a POAM table as defined by NIST SP 800-18 and used in DoD RMF (Risk Management Framework) processes:

| POAM ID | STIG Rule ID | Weakness Description | Point of Contact | Resources Required | Scheduled Completion | Milestones | Status |
|---|---|---|---|---|---|---|---|

**Milestones** must be specific and dated - "develop fix" by [date], "test in staging" by [date], "deploy to production" by [date].

For any Open finding where the fix cannot be completed within 30 days (due to operational impact, vendor dependency, etc.), write a formal **Risk Acceptance Statement** that includes: why it cannot be remediated on schedule, what compensating control is in place, who is accepting the residual risk (by role), and the risk acceptance expiration date.

### Part 4 - STIG vs. CIS Analysis (10 pts)

Choose 3 of your Open STIG findings and look up whether the same control exists in the CIS Ubuntu 22.04 Benchmark. For each:
- Is there a corresponding CIS control? (Yes/No, and cite the CIS control ID if yes)
- If yes: is the remediation the same, stricter, or less strict than the STIG?
- What does this tell you about when to use STIG vs. CIS as your baseline?

Conclude with a 1-paragraph recommendation: for a non-DoD healthcare organization like Valley Medical Group, would you use STIG, CIS, or a combination as your hardening baseline? Justify with at least 2 specific reasons.

---

## Deliverable(s)

Write your full assessment in `homework/cyber-hw-06.md`. Commit to `homework/assets/`:

- `cyber-hw-06-stig-fix.sh` - your remediation script
- `cyber-hw-06-remediation-output.txt` - full terminal output from running the script
- `cyber-hw-06-poam.csv` - POAM table as a CSV file

Open a PR titled `CYBER HW 6 - STIG Assessment & POAM` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| 25 STIG findings documented with correct status and finding details | 40 |
| Remediation script - 5 controls, before/after, idempotent | 25 |
| POAM - all Open findings tracked, milestones dated | 20 |
| Risk acceptance statements for delayed remediations | 5 |
| STIG vs. CIS analysis and recommendation | 10 |

---

## Tip

{: .tip }
STIG Viewer 2.x lets you import your OpenSCAP results XML directly and export a checklist. Use it - manually tracking 25 findings in a spreadsheet is how errors creep in.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - ATO Package & RMF Role Analysis (30 pts)

**Plan of Action & Milestones (POA&M) (15 pts)**

Using the DoD POA&M template structure, produce a formal POA&M for all **Open** findings in your STIG assessment. Each POA&M entry must include:

| Field | Description |
|---|---|
| POA&M ID | Unique identifier (e.g., POAM-001) |
| Weakness Name | Descriptive title |
| Finding Source | STIG Rule ID |
| Status | Ongoing / Completed / Risk Accepted |
| Resources Required | Labor hours, tooling, licensing |
| Scheduled Completion Date | Realistic date with justification |
| Milestones | At least 2 intermediate milestones per Open finding |
| Risk Rating | CAT I/II/III with CVSS score |
| Residual Risk | Risk level if mitigated as planned |

For any finding you flag as **Risk Accepted** (rather than remediated), write a formal Risk Acceptance Statement that includes the authorizing official, business justification, compensating controls in place, and a review date.

**NIST RMF ATO Package Analysis (15 pts)**

Research the NIST Risk Management Framework (SP 800-37 Rev 2) and write a 2-page analysis covering:

1. List every artifact required in a complete ATO package beyond the STIG checklist (System Security Plan, Security Assessment Report, POA&M, etc.) - describe the purpose and responsible party for each.
2. Distinguish the roles of the **ISSO** (Information System Security Officer) and **ISSM** (Information System Security Manager) in the RMF authorization process. Who can sign what?
3. Describe the difference between an **ATO**, **IATT** (Interim Authority to Test), and **DATO** (Denial of Authority to Operate) - under what circumstances would each be issued?


[← Back to Homework]({{ site.baseurl }}/homework/)
