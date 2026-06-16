---
title: "CYBER HW 5 - CIS Benchmark Gap Analysis & Remediation Plan"
parent: Homework
nav_order: 5
---

# CYBER HW 5 - CIS Benchmark Gap Analysis & Remediation Plan
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
| **Assignment** | CYBER HW 5 |
| **Points** | 100 |
| **Due** | Week 6 |
| **Track** | Cyber |

---

## Description

Using the CIS-CAT Pro results from **Lab 5**, produce a gap analysis report that goes beyond listing failures - it must prioritize them, explain the business risk, and provide verified remediation steps.

### Part 1 - Scoring & Risk Prioritization (25 pts)

For every failing control in your CIS-CAT report, document:

| Control ID | Title | CIS Level | CIS Section | CVSS-equivalent Risk (1-10 - your assessment) | Rationale for Rating |
|---|---|---|---|---|---|

After documenting all failures, group them into three tiers:
- **Tier 1 (Fix immediately):** Controls whose failure creates direct exploitation risk - remote code execution, privilege escalation, or credential exposure
- **Tier 2 (Fix within 30 days):** Controls whose failure increases attack surface or degrades detection capability
- **Tier 3 (Fix within 90 days):** Hardening controls with limited standalone risk

Justify every tier assignment. "Low risk" is not a justification - explain specifically what an attacker would need to do to exploit this gap and why that is or is not realistic in your environment.

### Part 2 - Verified Remediation Commands (45 pts)

For every Tier 1 and Tier 2 control (and at least 5 Tier 3 controls), provide:

1. **Current state** - what the CIS-CAT scan found (exact value or configuration)
2. **Target state** - what CIS requires and why
3. **Remediation command(s)** - the exact bash command(s) to remediate. Must be tested and working.
4. **Verification command** - the exact command to confirm the fix was applied, with expected output
5. **Side effect risk** - does this change break anything? List any services or workflows that need to be tested after applying this control

Format as a numbered remediation runbook - a junior admin should be able to run through it sequentially and harden the system.

**For at least 5 controls**, show before-and-after: paste the CIS-CAT output line showing the failure, apply your remediation, then re-run the specific check and paste the passing result.

### Part 3 - Bash Remediation Script (20 pts)

Write `cyber-hw-05-remediate.sh` that automates remediation for all Tier 1 controls and at least 3 Tier 2 controls. Requirements:

- `set -euo pipefail`
- Each change is logged to `/var/log/cis-remediation-YYYY-MM-DD.log` with timestamp and control ID
- Before applying each change, the script checks and logs the current state
- A `--dry-run` flag prints what would change without making changes
- After all changes, the script prints a summary: X controls remediated, Y skipped (already compliant), Z errors
- The script must be idempotent - running it twice should not break anything

### Part 4 - Remediation Report (10 pts)

Produce a 1-page executive summary suitable for presenting to a CISO:
- Overall CIS compliance score (before and after your proposed remediation)
- Count of Tier 1, 2, and 3 failures
- Estimated time to remediate each tier (in person-hours)
- Top 3 risks in plain business terms
- Your recommendation: what is the minimum acceptable remediation scope before this system handles production workloads?

---

## Deliverable(s)

Write your full gap analysis in `homework/cyber-hw-05.md`. Commit to `homework/assets/`:

- `cyber-hw-05-remediate.sh` - your remediation script
- `cyber-hw-05-before-report.html` - original CIS-CAT HTML report (or PDF)
- `cyber-hw-05-after-screenshot.png` - screenshot showing improved compliance for the controls you re-tested

Open a PR titled `CYBER HW 5 - CIS Benchmark Gap Analysis` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Risk prioritization - tier assignments justified | 25 |
| Remediation runbook - tested commands + verification for all Tier 1/2 | 30 |
| Before/after evidence for 5 controls | 15 |
| Remediation script - idempotent, logging, dry-run | 20 |
| Executive summary - scores, business framing | 10 |

---

## Tip

{: .tip }
Run `sudo oscap oval eval --results results.xml --report report.html /usr/share/scap-security-guide/ubuntu2204-oval.xml` to re-scan individual controls after remediation without running the full CIS-CAT tool again.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - FAIR Quantitative Risk Analysis (30 pts)

Apply the **Factor Analysis of Information Risk (FAIR)** methodology to your highest-priority CIS gap finding. Your analysis must:

**FAIR Model Construction (15 pts)**

Using the FAIR ontology, define and estimate values for your top gap:

- **Threat Event Frequency (TEF):** How often does the threat community attempt this attack against similar organizations? Cite a data source (Verizon DBIR, MITRE ATT&CK prevalence data, or similar).
- **Vulnerability (Vuln):** Given a threat event occurs, what is the probability it succeeds given your current control state? Justify with the control gap specifics.
- **Primary Loss Magnitude (PLM):** Estimate productivity loss, response costs, and data breach costs if the threat succeeds. Use Ponemon or equivalent benchmarks.
- **Risk Range:** Calculate Loss Event Frequency (LEF = TEF × Vuln) and expected annual loss range (minimum, most likely, maximum). A Monte Carlo simulation is not required but earns extra credit if implemented.

**Framework Comparison (15 pts)**

Write a 2-page comparison of **FAIR** versus **NIST SP 800-30** for ongoing CIS compliance risk tracking:

1. What information does each framework require that the other doesn't?
2. Which is more suited to a security team without a dedicated risk analyst? Why?
3. Given your organization's size and maturity (define your assumed organization), which framework would you recommend adopting, and what would a phased implementation look like?

Submit as `cyber-hw-05-fair-analysis.md`.


[← Back to Homework]({{ site.baseurl }}/homework/)
