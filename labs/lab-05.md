---
title: "LAB 5 — CIS-CAT Pro Benchmark Assessment"
parent: Labs
nav_order: 5
---

# LAB 5 — CIS-CAT Pro Benchmark Assessment
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 5
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run a full CIS-CAT Pro assessment on Ubuntu
- Identify and prioritize the top failing controls
- Remediate 5 high-impact items and verify closure
- Document risk acceptance for non-remediated items

---

## Tools Required

- Ubuntu 22.04 LTS VM
- CIS-CAT Pro (department license — credentials on LMS)
- CIS Ubuntu 22.04 LTS Benchmark

---

## Procedure


1. Install CIS-CAT Pro on the Ubuntu VM (credentials on LMS)
2. Run a full assessment:
   ```bash
   ./Assessor-CLI.sh -b [Ubuntu 22.04 benchmark] -rd reports/
   ```
3. Open the HTML report — record total score and per-section scores
4. Identify the **top 10 failing controls** (highest impact / easiest to fix)
5. Select 5 to remediate — document your selection rationale
6. Apply remediations (e.g., set permissions, disable services, configure sysctl)
7. Re-run CIS-CAT and compare before/after scores
8. For the remaining 5 failures, document risk acceptance or operational constraints


---

## Submission Requirements

Lab Report: pre-remediation HTML report, remediation evidence (terminal commands + output) for all 5 controls, post-remediation HTML report, score comparison table, risk acceptance documentation for 5 non-remediated items.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
