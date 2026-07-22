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

A draft Patch Management Policy for Acme Financial Corp is linked below. It has multiple deficiencies that would cause it to fail a PCI-DSS audit. Write a structured critique identifying every gap:

[Read the draft policy: Acme Financial Corp Patch Management Policy]({% link homework/description-files/cyber-hw-04-bad-policy.md %})

For each deficiency: section it appears in, what is wrong or missing, which PCI-DSS requirement it would fail (cite the specific requirement number from PCI-DSS v4.0), and what the corrected language should say. You must identify **at least 6 deficiencies**.

### Part 2 - Full Vulnerability Management Policy (65 pts)

Write a complete, production-quality Vulnerability Management Policy for Acme Financial Corp (200 seats, SOX and PCI-DSS regulated, running mixed Linux and Windows infrastructure). Use the [Acme Financial Corp Environment Profile]({% link homework/description-files/cyber-hw-04-scenario.md %}) for the specific infrastructure, staffing, and tooling details your policy needs to reference - a policy that ignores the scenario's actual constraints (e.g., assuming a dedicated scanning tool the company doesn't have, or a security team headcount the company can't staff) will lose points for not being grounded in the assigned environment.

1. **Policy statement and governance (10 pts)** - purpose, authority, what happens if this policy is not followed, and roles and responsibilities (CISO, Security Team, System Owners - specific obligations for each, not just titles, matching the roles defined in the Environment Profile)

2. **CVSS-based severity classification & remediation SLA matrix (25 pts)** - define your remediation SLA by CVSS score, but go beyond a simple table. For each severity tier, specify:
   - CVSS score range
   - Remediation SLA from vendor disclosure (not from your scan finding it - explain the difference)
   - Remediation SLA from scan discovery
   - Business approval required for the fix to proceed (who signs off?)
   - Include at least 3 real CVEs from the last 2 years as examples and classify them using your matrix (cite CVE ID and CVSS score from NVD)

3. **Vulnerability identification & scanning program (25 pts)** - define:
   - How new vulnerabilities are identified (vendor mailing lists, NVD feeds, CISA KEV - specify all sources; must be reputable outside sources with a documented risk-ranking process)
   - Scan frequency by asset type (external-facing vs. internal) and how it satisfies PCI-DSS's quarterly-minimum requirement
   - Tool(s) used and credentialed vs. uncredentialed scanning (reference what's actually available per the Environment Profile)
   - Segregation of duties between the person remediating a finding and the person who scans/verifies it
   - What constitutes a scan "finding" vs. a confirmed "vulnerability," how false positives are handled, and the requirement to rescan until a passing result (or approved exception) is achieved

4. **Exception and risk acceptance process (15 pts)** - for vulnerabilities that cannot be remediated within SLA:
   - Who can grant an exception (by risk level)
   - Maximum exception duration
   - Required compensating controls
   - How exceptions are tracked and reviewed
   - What triggers mandatory escalation to the CISO

5. **KPIs and compliance metrics (5 pts)** - define at least 5 measurable KPIs the security team will report monthly:
   - Metric name, formula, and target value
   - How it maps to PCI-DSS or SOX reporting requirements

---

## Deliverable(s)

Write your full submission in `homework/cyber-hw-04.md`.

Open a PR titled `CYBER HW 4 - Patch Management Policy` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Policy critique - 6+ deficiencies with PCI-DSS citations | 20 |
| Policy statement and governance - roles grounded in the Environment Profile | 10 |
| CVSS matrix - real CVE examples classified | 25 |
| Scanning program - identification sources, segregation of duties, rescan requirement | 25 |
| Exception process - approval chain, tracking, escalation | 15 |
| KPIs - 5 metrics with formulas and targets | 5 |

---

## Tip

{: .tip }
PCI-DSS v4.0 Requirement 6.3.3 requires all software components to be protected from known vulnerabilities. Requirement 11.3.1 specifies internal vulnerability scan frequency. Know those sections before writing your policy.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section. Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 3 - Quantitative Risk Analysis & Federal Alignment (30 pts)

**Annual Loss Expectancy Calculation (15 pts)**

For each of the 3 CVEs you classified in your CVSS matrix (Part 2), calculate **Annual Loss Expectancy (ALE)** using the formula `ALE = ARO × SLE`:

- **ARO (Annual Rate of Occurrence):** Derive from the CVE's CVSS exploitability metrics and publicly available exploit-in-the-wild data (NVD, CISA KEV, VulnCheck, etc.). Justify your estimate.
- **SLE (Single Loss Expectancy):** Use the IBM/Ponemon Cost of a Data Breach Report current year figures as your baseline breach cost, then adjust for asset value and scope. Show your calculation.
- **ALE:** Calculate and compare against your vulnerability policy's implementation cost for each CVE to produce a **Return on Security Investment (ROSI)** figure.

Present results in a table and write 2-3 paragraphs interpreting the numbers - which CVE gives the best ROSI, and does your policy's timeline appropriately reflect the financial risk?

**CISA BOD 22-01 Federal Alignment Analysis (15 pts)**

Research CISA Binding Operational Directive 22-01 (the Known Exploited Vulnerabilities catalog requirement) and write a 2-page analysis addressing:

1. If your organization were a federal civilian executive branch (FCEB) agency, which of your policy's timelines would be out of compliance with BOD 22-01's mandated remediation windows (14 days for critical/high KEV entries)?
2. Identify 3 specific CVEs currently on the KEV catalog that fall within your policy's severity categories. For each, note the KEV-mandated deadline and compare to your policy's timeline.
3. Propose specific amendments to your vulnerability policy that would bring it into BOD 22-01 alignment without being operationally unrealistic for a non-federal organization - and justify why a private organization might voluntarily adopt federal timelines.


[← Back to Homework]({{ site.baseurl }}/homework/)
