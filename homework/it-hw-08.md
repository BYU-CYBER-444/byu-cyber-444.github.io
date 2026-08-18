---
title: "IT HW 8 - Data Center Risk Assessment & Remediation Roadmap"
parent: Homework
nav_order: 8
---
# IT HW 8 - Data Center Risk Assessment & Remediation Roadmap
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Using the [Meridian Financial Services Data Center Site Survey Findings]({% link homework/description-files/it-hw-08-survey-findings.md %}), produce a formal Data Center Risk Assessment Report for Meridian's CTO and facilities team. This document will be used to justify a capital expenditure request - it must be persuasive to a financial audience, not just technically accurate.

### Part 1 - Executive Summary (10 pts)

Write a 2-paragraph non-technical summary for the CTO. It must convey the current risk posture in business terms (e.g., dollar exposure per hour of downtime, regulatory implications) and state your top recommendation. Do not use technical acronyms without defining them.

Estimate the financial exposure: research the average cost of unplanned downtime for a financial services company (cite your source) and apply it to the specific failure scenarios you identified.

### Part 2 - Risk Register (35 pts)

Document every risk identified in the site survey. Use the following table format:

| Risk ID | Category | Description | Likelihood (1-5) | Impact (1-5) | Score | Current Controls | Recommended Control | Cost Category |
|---|---|---|---|---|---|---|---|---|
| Ex. | Network | *(illustrative only - not one of your findings)* Single ISP uplink with no BGP failover; a fiber cut severs all connectivity | 3 | 5 | 15 (Critical) | None (single default route) | Add a second ISP on a physically diverse path, configure BGP for automatic failover | Medium ($10K-$100K) |

Categories: Physical Security / Power / Cooling / Environmental / Network / Operational.

Cost categories: Low (<$10K) / Medium ($10K-$100K) / High (>$100K).

You must document **at least 12 risks**. For any risk scoring 15 or higher (Likelihood × Impact), mark it as **Critical** and explain in a footnote what a realistic worst-case incident looks like in concrete terms.

### Part 3 - Uptime Tier Analysis (20 pts)

Based on the survey findings, determine which Uptime Institute Tier (I-IV) the facility currently meets. Your analysis must:

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
2. Estimate the Mean Time To Repair (MTTR) given the staffing and spare-parts situation described in the Site Survey Findings
3. Calculate the resulting availability percentage: `MTBF / (MTBF + MTTR)`
4. Compare to the Uptime Institute availability target for the current and target tier

---

## Deliverable(s)

Write your full report in `homework/it-hw-08.md`.

Open a PR titled `Grade: it-hw-08 - Data Center Risk Assessment` and submit your repo link on Learning Suite by the due date.

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

### Part 6 - Monte Carlo Downtime Simulation (30 pts)

Using the failure probabilities and MTTR values from your risk register, implement a **Monte Carlo simulation** of annual downtime for your data center. Submit `it-hw-08-montecarlo.py`:

1. For each of your identified failure scenarios, define:
   - Annual failure rate (λ = 1/MTTF, derived from your risk register probabilities)
   - MTTR distribution (use a lognormal distribution with your estimated MTTR as the median and a reasonable σ - justify your σ choice)
2. Simulate 10,000 years of operation. For each simulated year:
   - For each failure scenario, use a Poisson process to determine how many failures occur
   - For each failure, sample repair time from your MTTR distribution
   - Sum total downtime hours, accounting for concurrent failures (overlapping repair windows count as single downtime)
3. Produce and save a histogram of annual downtime hours (`it-hw-08-downtime-histogram.png`)
4. Report: mean annual downtime, standard deviation, 50th/95th/99th percentile, and the probability of exceeding your SLA threshold (define what SLA threshold you're evaluating against)
5. For your top 3 risks from your risk register, calculate how much each individual risk contributes to total expected downtime (run the simulation with that risk removed and compare)
6. Produce a **Risk Prioritization Table** ranking risks by their marginal contribution to expected annual downtime - this should drive your remediation roadmap sequence


[← Back to Homework]({{ site.baseurl }}/homework/)
