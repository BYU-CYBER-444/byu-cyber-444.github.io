---
title: "CYBER HW 4 - Patch Management & Vulnerability Policy"
parent: Homework
nav_order: 4
---

# CYBER HW 4 - Patch Management & Vulnerability Policy
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
| **Assignment** | CYBER HW 4 |
| **Points** | 100 |
| **Due** | Week 5 |
| **Track** | Cyber |

---

## Description

### Part 1 - Policy Critique (20 pts)

A draft Patch Management Policy is provided on Learning Suite (`CYBER_HW4_Bad_Policy.pdf`). It has multiple deficiencies that would cause it to fail a PCI-DSS audit. Write a structured critique identifying every gap:

For each deficiency: section it appears in, what is wrong or missing, which PCI-DSS requirement it would fail (cite the specific requirement number from PCI-DSS v4.0), and what the corrected language should say. You must identify **at least 6 deficiencies**.

### Part 2 - Full Patch Management & Vulnerability Policy (65 pts)

Write a complete, production-quality Patch Management and Vulnerability Management Policy for Acme Financial Corp (200 seats, SOX and PCI-DSS regulated, running mixed Linux and Windows infrastructure):

1. **Policy statement** - purpose, authority, and what happens if this policy is not followed

2. **CVSS-based patch classification matrix** - define your SLA timelines by CVSS score, but go beyond a simple table. For each severity tier, specify:
   - CVSS score range
   - Patch SLA from vendor disclosure (not from your scan finding it - explain the difference)
   - SLA from scan discovery
   - Testing requirements before production deployment
   - Business approval required (who signs off?)
   - Include at least 3 real CVEs from the last 2 years as examples and classify them using your matrix (cite CVE ID and CVSS score from NVD)

3. **Patch pipeline** - describe the full pipeline from vendor release to production deployment:
   - How you are notified of new vulnerabilities (vendor mailing lists, NVD feeds, CISA KEV - specify all sources)
   - Testing stages (dev → staging → production) with go/no-go criteria at each stage
   - Emergency (out-of-band) patching procedure: who can authorize bypassing the normal pipeline and under what conditions
   - How you handle patches that break functionality (rollback procedure and exception tracking)

4. **Vulnerability scanning program** - define:
   - Scan frequency by asset type (external-facing vs. internal)
   - Tool(s) used and credentialed vs. uncredentialed scanning
   - Remediation SLAs that align with your CVSS classification (must be the same timelines - no contradictions)
   - What constitutes a scan "finding" vs. a confirmed "vulnerability" and how you handle false positives

5. **Exception and risk acceptance process** - for vulnerabilities that cannot be patched within SLA:
   - Who can grant an exception (by risk level)
   - Maximum exception duration
   - Required compensating controls
   - How exceptions are tracked and reviewed
   - What triggers mandatory escalation to the CISO

6. **KPIs and compliance metrics** - define at least 5 measurable KPIs the security team will report monthly:
   - Metric name, formula, and target value
   - How it maps to PCI-DSS or SOX reporting requirements

7. **Roles and responsibilities** - CISO, Security Team, System Owners, Change Advisory Board - specific obligations for each, not just titles

### Part 3 - CISA KEV Analysis (15 pts)

The CISA Known Exploited Vulnerabilities catalog (cisa.gov/known-exploited-vulnerabilities-catalog) is the authoritative list of vulnerabilities being actively exploited in the wild.

1. Identify **3 CVEs** from the CISA KEV catalog that would affect a Windows Server 2022 + Ubuntu 22.04 environment running Nginx and PostgreSQL
2. For each CVE: CVSS score, affected component, what the exploit does, CISA's required remediation date, and whether the patch is available
3. Apply your policy's classification matrix and determine: would your SLA timeline meet CISA's required remediation date? If not, explain what exception process would be invoked.

---

## Deliverable(s)

Write your full submission in `homework/cyber-hw-04.md`.

Open a PR titled `CYBER HW 4 - Patch Management Policy` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Policy critique - 6+ deficiencies with PCI-DSS citations | 20 |
| CVSS matrix - real CVE examples classified | 15 |
| Patch pipeline - all stages, emergency procedure, rollback | 20 |
| Scanning program - credentialed/uncredentialed, SLA alignment | 10 |
| Exception process - approval chain, tracking, escalation | 10 |
| KPIs - 5 metrics with formulas and targets | 10 |
| CISA KEV analysis - 3 CVEs, SLA gap identified | 15 |

---

## Tip

{: .tip }
PCI-DSS v4.0 Requirement 6.3.3 requires all software components to be protected from known vulnerabilities. Requirement 11.3.1 specifies internal vulnerability scan frequency. Know those sections before writing your policy.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - Quantitative Risk Analysis & Federal Alignment (30 pts)

**Annual Loss Expectancy Calculation (15 pts)**

For each of the 3 CVEs you analyzed in Part 3, calculate **Annual Loss Expectancy (ALE)** using the formula `ALE = ARO × SLE`:

- **ARO (Annual Rate of Occurrence):** Derive from the CVE's CVSS exploitability metrics and publicly available exploit-in-the-wild data (NVD, CISA KEV, VulnCheck, etc.). Justify your estimate.
- **SLE (Single Loss Expectancy):** Use the IBM/Ponemon Cost of a Data Breach Report current year figures as your baseline breach cost, then adjust for asset value and scope. Show your calculation.
- **ALE:** Calculate and compare against your patch policy's implementation cost for each CVE to produce a **Return on Security Investment (ROSI)** figure.

Present results in a table and write 2-3 paragraphs interpreting the numbers - which CVE gives the best ROSI, and does your policy's timeline appropriately reflect the financial risk?

**CISA BOD 22-01 Federal Alignment Analysis (15 pts)**

Research CISA Binding Operational Directive 22-01 (the Known Exploited Vulnerabilities catalog requirement) and write a 2-page analysis addressing:

1. If your organization were a federal civilian executive branch (FCEB) agency, which of your policy's timelines would be out of compliance with BOD 22-01's mandated remediation windows (14 days for critical/high KEV entries)?
2. Identify 3 specific CVEs currently on the KEV catalog that fall within your policy's patch categories. For each, note the KEV-mandated deadline and compare to your policy's timeline.
3. Propose specific amendments to your patch policy that would bring it into BOD 22-01 alignment without being operationally unrealistic for a non-federal organization - and justify why a private organization might voluntarily adopt federal timelines.


[← Back to Homework]({{ site.baseurl }}/homework/)
