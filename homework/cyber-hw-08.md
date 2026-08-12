---
title: "CYBER HW 8 - CIS Benchmark Gap Analysis & Remediation Plan"
parent: Homework
nav_order: 8
---
# CYBER HW 8 - CIS Benchmark Gap Analysis & Remediation Plan
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Produce a gap analysis report that goes beyond listing failures - it must prioritize them, explain the business risk, and provide verified remediation steps.

You are given a completed CIS Benchmark assessment report to work from - you do not need to run CIS-CAT Pro or any other scanner yourself:

- [Sample CIS Benchmark Assessment Report]({% link homework/description-files/cyber-hw-08-sample-report.md %}) - CIS Ubuntu 22.04 LTS Benchmark results (48 controls, 21 FAIL) for a fictional host, rendered inline on the page

### Part 1 - Scoring & Risk Prioritization (35 pts)

Rank all 21 failing controls in the sample report by CIS severity/level, then document the **top 15**:

| Control ID | Title | CIS Level | CIS Section | CVSS-equivalent Risk (1-10 - your assessment) | Rationale for Rating |
|---|---|---|---|---|---|
| 5.2.10 | Ensure SSH root login is disabled | L1 | 5 - Access, Authentication and Authorization | 8 | Direct root login over SSH means a stolen or brute-forced root credential grants immediate, full-privilege remote access with no intermediate account to detect or revoke - no privilege escalation step required, and no per-user audit trail for root actions. |

After documenting all failures, group them into three tiers:
- **Tier 1 (Fix immediately):** Controls whose failure creates direct exploitation risk - remote code execution, privilege escalation, or credential exposure
- **Tier 2 (Fix within 30 days):** Controls whose failure increases attack surface or degrades detection capability
- **Tier 3 (Fix within 90 days):** Hardening controls with limited standalone risk

Justify every tier assignment. "Low risk" is not a justification - explain specifically what an attacker would need to do to exploit this gap and why that is or is not realistic in your environment.

### Part 2 - Verified Remediation Commands (65 pts)

For every Tier 1 and Tier 2 control (and at least 5 Tier 3 controls), provide:

1. **Current state** - what the CIS-CAT scan found (exact value or configuration)
2. **Target state** - what CIS requires and why
3. **Remediation command(s)** - the exact bash command(s) to remediate. Must be tested and working.
4. **Verification command** - the exact command to confirm the fix was applied, with expected output
5. **Side effect risk** - does this change break anything? List any services or workflows that need to be tested after applying this control

Format as a numbered remediation runbook - a junior admin should be able to run through it sequentially and harden the system.

**For at least 5 controls**, show before-and-after: paste the CIS-CAT output line showing the failure, apply your remediation, then re-run the specific check and paste the passing result.

---

## Deliverable(s)

Write your full gap analysis in `homework/cyber-hw-08.md`.

Open a PR titled `CYBER HW 8 - CIS Benchmark Gap Analysis` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Risk prioritization - tier assignments justified | 35 |
| Remediation runbook - tested commands + verification for all Tier 1/2 | 65 |


---


##  Graduate Extension - Graduate Students Only

### Part 5 - FAIR Quantitative Risk Analysis (30 pts)


Using the FAIR ontology, define and estimate values for your top gap:

- **Threat Event Frequency (TEF):** How often does the threat community attempt this attack against similar organizations? Cite a data source (Verizon DBIR, MITRE ATT&CK prevalence data, or similar).
- **Vulnerability (Vuln):** Given a threat event occurs, what is the probability it succeeds given your current control state? Justify with the control gap specifics.
- **Primary Loss Magnitude (PLM):** Estimate productivity loss, response costs, and data breach costs if the threat succeeds. Use Ponemon or equivalent benchmarks.
- **Risk Range:** Calculate Loss Event Frequency (LEF = TEF × Vuln) and expected annual loss range (minimum, most likely, maximum). A Monte Carlo simulation is not required but earns extra credit if implemented.

Submit as `cyber-hw-08-fair-analysis.md`.


[← Back to Homework]({{ site.baseurl }}/homework/)
