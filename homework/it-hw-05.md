---
title: "IT HW 5 - Data Center Risk Assessment & Remediation Roadmap"
parent: Homework
nav_order: 105
---

# IT HW 5 - Data Center Risk Assessment & Remediation Roadmap
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
| **Assignment** | IT HW 5 |
| **Points** | 100 |
| **Due** | Week 6 |
| **Track** | IT |

---

## Description

Using the site survey findings from **IT LAB 5**, produce a formal Data Center Risk Assessment Report for Acme Financial Corp's CTO and facilities team. This document will be used to justify a capital expenditure request - it must be persuasive to a financial audience, not just technically accurate.

### Part 1 - Executive Summary (10 pts)

Write a 2-paragraph non-technical summary for the CTO. It must convey the current risk posture in business terms (e.g., dollar exposure per hour of downtime, regulatory implications) and state your top recommendation. Do not use technical acronyms without defining them.

Estimate the financial exposure: research the average cost of unplanned downtime for a financial services company (cite your source) and apply it to the specific failure scenarios you identified.

### Part 2 - Risk Register (35 pts)

Document every risk identified in your site survey. Use the following table format:

| Risk ID | Category | Description | Likelihood (1-5) | Impact (1-5) | Score | Current Controls | Recommended Control | Cost Category |
|---|---|---|---|---|---|---|---|---|

Categories: Physical Security / Power / Cooling / Environmental / Network / Operational.

Cost categories: Low (<$10K) / Medium ($10K-$100K) / High (>$100K).

You must document **at least 12 risks**. For any risk scoring 15 or higher (Likelihood × Impact), mark it as **Critical** and explain in a footnote what a realistic worst-case incident looks like in concrete terms.

### Part 3 - Uptime Tier Analysis (20 pts)

Based on your survey findings, determine which Uptime Institute Tier (I-IV) the facility currently meets. Your analysis must:

- State the tier and cite the specific Uptime Institute criteria that are met or not met
- Identify the **three most significant gaps** preventing the next tier up
- Estimate the cost range to close each gap and the resulting improvement in annual downtime allowance (use Uptime Institute published figures)
- State whether you recommend pursuing the next tier and justify with a cost-benefit argument

### Part 4 - Remediation Roadmap (25 pts)

Produce a prioritized remediation plan organized into three horizons:

- **Immediate (0-30 days):** No-cost or low-cost actions that reduce risk now
- **Short-term (1-6 months):** Medium-cost improvements requiring budget approval
- **Long-term (6-18 months):** Major capital investments requiring board-level approval

For each item include: risk IDs addressed, responsible owner role, estimated cost, expected risk score reduction after implementation, and one measurable success criterion.

### Part 5 - MTTR & Reliability Calculations (10 pts)

For the two highest-scoring power risks and one cooling risk:

1. Estimate the Mean Time Between Failures (MTBF) for the component at risk (use manufacturer specs or industry averages - cite your source)
2. Estimate the Mean Time To Repair (MTTR) given the current staffing and spare-parts situation described in your lab
3. Calculate the resulting availability percentage: `MTBF / (MTBF + MTTR)`
4. Compare to the Uptime Institute availability target for the current and target tier

---

## Deliverable(s)

Write your full report in `homework/it-hw-05.md`.

Open a PR titled `IT HW 5 - Data Center Risk Assessment` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Executive summary - financial framing, non-technical language | 10 |
| Risk register - 12+ risks, scoring rationale | 35 |
| Uptime tier analysis - criteria cited, gap analysis, cost-benefit | 20 |
| Remediation roadmap - three horizons, measurable success criteria | 25 |
| MTTR/MTBF calculations - sourced, computed correctly | 10 |

---

## Tip

{: .tip }
The Uptime Institute publishes tier availability targets (Tier I = 99.671%, Tier II = 99.741%, Tier III = 99.982%, Tier IV = 99.995%). Use these for your calculations.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 6 - Monte Carlo Downtime Simulation (30 pts)

**Monte Carlo Annual Downtime Model (20 pts)**

Using the failure probabilities and MTTR values from your risk register, implement a **Monte Carlo simulation** of annual downtime for your data center. Submit `it-hw-05-montecarlo.py`:

1. For each of your identified failure scenarios, define:
   - Annual failure rate (λ = 1/MTTF, derived from your risk register probabilities)
   - MTTR distribution (use a lognormal distribution with your estimated MTTR as the median and a reasonable σ - justify your σ choice)
2. Simulate 10,000 years of operation. For each simulated year:
   - For each failure scenario, use a Poisson process to determine how many failures occur
   - For each failure, sample repair time from your MTTR distribution
   - Sum total downtime hours, accounting for concurrent failures (overlapping repair windows count as single downtime)
3. Produce and save a histogram of annual downtime hours (`it-hw-05-downtime-histogram.png`)
4. Report: mean annual downtime, standard deviation, 50th/95th/99th percentile, and the probability of exceeding your SLA threshold (define what SLA threshold you're evaluating against)

**Financial Impact Analysis (10 pts)**

Using your simulation results:

1. Calculate the **expected annual financial loss** from downtime: mean downtime hours × revenue-per-hour (define and justify your revenue figure for your assumed organization)
2. Calculate the **95th percentile annual loss** and interpret what it means operationally ("in the worst 1-in-20 years, the organization would lose $X")
3. For your top 3 risks from your risk register, calculate how much each individual risk contributes to total expected downtime (run the simulation with that risk removed and compare)
4. Produce a **Risk Prioritization Table** ranking risks by their marginal contribution to expected annual downtime - this should drive your remediation roadmap sequence


[← Back to Homework]({{ site.baseurl }}/homework/)
