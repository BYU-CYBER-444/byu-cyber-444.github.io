---
title: "IT LAB 5 - Data Center Site Survey Exercise"
parent: Labs
nav_order: 105
---

# IT LAB 5 - Data Center Site Survey Exercise
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 5 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Evaluate a data center design scenario against Uptime Institute Tier standards
- Analyze power architecture including UPS, PDU, and generator configurations
- Assess cooling infrastructure using PUE calculations and hot/cold aisle containment
- Identify physical security control gaps and propose remediations
- Produce a formal site assessment report with tier classification and upgrade roadmap

---

## Tools Required

- Provided data center design documents (see scenario below)
- Calculator or spreadsheet for PUE and power calculations
- Word processor or Markdown for assessment report

---

## Background

The Uptime Institute Tier Classification System (Tier I-IV) defines availability commitments through redundancy in power, cooling, and network paths. Tier IV requires 99.9995% availability (< 26 minutes downtime/year) through fully fault-tolerant, concurrently maintainable infrastructure with no single point of failure.

PUE (Power Usage Effectiveness) = Total Facility Power / IT Equipment Power. Industry average is ~1.58; hyperscale operators achieve 1.1-1.2. High PUE wastes energy on cooling overhead.

---

## Scenario: Meridian Financial Services Data Center

You are an IT infrastructure consultant hired to assess Meridian Financial Services' primary data center. The facility hosts core banking applications, trading systems, and customer data for a mid-size regional bank (350 employees, $2.1B AUM). A regulatory audit has flagged concerns about availability and physical security. Your task is to evaluate the facility against Uptime Tier III requirements.

**Facility Specifications Provided:**

*Power Infrastructure:*
- Utility feed: Single feed from local utility substation (15 MVA capacity)
- UPS: Two APC Symmetra 80kVA units, configured A/B feeds to PDUs
- Transfer time between UPS and utility: 8ms (double conversion)
- Generator: One 200kW Caterpillar diesel generator with 72-hour fuel tank
- Generator auto-transfer: ATS with 12-second transfer time
- PDU configuration: Two PDUs per rack row; single-corded servers (no dual PSUs)

*Cooling Infrastructure:*
- CRAC units: 6 × 30-ton precision AC units (5 operational, 1 redundant)
- Airflow: Cold aisle containment installed in rows 1-4; rows 5-8 have no containment
- Hot aisle: Open, exhausting to raised floor plenum
- Average inlet temperature: 75°F (measured)
- Power measurements: IT equipment draw = 180kW; total facility power = 306kW

*Physical Security:*
- Perimeter: Card-access double door at main entrance (mantrap)
- Camera coverage: Lobby, main entrance, server room entrance - no cameras inside server room
- Server room access: Badge + PIN
- Visitor policy: Visitors escorted by any employee with badge access
- Rack security: Racks without doors (open frame)
- Media destruction: Shredder on-site; no dedicated media destruction log

*Network Infrastructure:*
- ISP connections: Primary fiber (1Gbps) from ISP-A; no secondary ISP
- BGP: Not configured; single default route to ISP-A
- Internal switching: Dual Cisco Nexus 5000 core switches, VSS configured
- Edge firewall: Single Palo Alto PA-3250 (no HA configured)

---

## Procedure

### Part 1 - Uptime Tier Classification Analysis (45 min)

For each Tier III requirement, evaluate Meridian's compliance:

| Requirement | Tier III Standard | Meridian Status | Gap |
|-------------|-------------------|-----------------|-----|
| Power paths | N+1 redundant, single active | | |
| UPS | N+1 | | |
| Generators | N+1 | | |
| Cooling | N+1, concurrently maintainable | | |
| Network | Redundant paths | | |
| Concurrent maintainability | All systems maintainable without downtime | | |
| Single points of failure | None allowed for Tier III | | |

Complete the table. For each Gap, describe the specific deficiency (e.g., "Single utility feed = single point of failure in power delivery path").

Based on your analysis, determine: **What Tier can Meridian currently claim?** Justify your answer with at least 3 specific supporting points.

---

### Part 2 - Power Architecture Analysis (45 min)

**2.1 UPS capacity calculation**

Current UPS: 2 × 80kVA at 0.9 power factor = 2 × 72kW = 144kW combined.
IT load: 180kW.

Calculate:
- Is current UPS capacity sufficient? (144kW available vs. 180kW load)
- If one UPS fails (N+1 scenario), what is the available capacity?
- At 80% safe loading threshold, what is the maximum IT load each UPS can handle?

Show your calculations. What does this reveal about the UPS configuration?

**2.2 Generator runtime analysis**

Generator: 200kW output, 72-hour fuel tank.
Actual load at full facility: 306kW.

- Can the 200kW generator support the full 306kW facility load? If not, what is the shortfall?
- At the actual load the generator can sustain (200kW), calculate: which systems must be shed?
- Assuming IT equipment (180kW) takes priority, how long will the 72-hour tank actually last if the generator runs at 200kW?
- Note: Fuel consumption at 200kW for a typical diesel generator is approximately 14.5 gallons/hour.

Document a **Load Shedding Priority List** for a generator failover event:
1. HVAC non-critical zones
2. Lighting (emergency only)
3. [Continue for 5 items total]

**2.3 Single-corded server risk**

Servers with single PSUs cannot benefit from A/B power feeds. Estimate: if one PDU fails, what percentage of servers lose power immediately? Propose a remediation plan with cost-benefit analysis (dual PSU server pricing vs. availability improvement).

---

### Part 3 - Cooling and PUE Analysis (30 min)

**3.1 PUE calculation**

PUE = Total Facility Power / IT Equipment Power = 306kW / 180kW = **1.70**

Evaluate this PUE:
- Compare to industry benchmarks: Hyperscale (1.1-1.2), enterprise average (1.58), poor (>2.0)
- Where does Meridian fall?
- Estimate annual energy cost impact: Assume $0.12/kWh. What is the annual "waste" from cooling overhead vs. a 1.4 PUE facility?
  - Formula: (PUE_actual - PUE_target) × IT_Load × 8760 hours × $/kWh

**3.2 Hot/cold aisle assessment**

Rows 5-8 have no cold aisle containment. At 75°F average inlet temperature:
- ASHRAE A2 envelope allows 50-95°F inlet. Is 75°F within spec?
- What risks arise from hot air recirculation in unconstrained rows?
- Recommend: (a) seal existing open aisles with blanking panels in rows 1-4, (b) retrofit rows 5-8 with cold aisle containment curtains (estimated cost: $8,000/row × 4 rows = $32,000). Calculate the expected PUE improvement (industry data: proper containment reduces PUE by 0.15-0.25).

---

### Part 4 - Physical Security Gap Analysis (30 min)

For each gap identified, use the following format:

```
FINDING: [ID] - [Title]
Severity: Critical / High / Medium / Low
Current State: [describe what exists]
Required State: [describe what should exist]
Risk: [what could go wrong]
Remediation: [specific action]
Cost Estimate: [rough order of magnitude]
Timeline: [immediate / 30 days / 90 days]
```

Identify at least 5 physical security findings. You should find:
- Camera blind spots inside server room
- Visitor escort policy weakness (any badged employee, not security-trained staff)
- Open-frame racks (no locking doors)
- Media destruction without chain of custody log
- One additional finding of your choice

---

### Part 5 - Formal Site Assessment Report (30 min)

Compile your findings into a formal **Data Center Site Assessment Report**:

```
MERIDIAN FINANCIAL SERVICES
DATA CENTER SITE ASSESSMENT REPORT

Executive Summary (150 words):
  Current Tier classification, top 3 risks, overall readiness rating (Red/Yellow/Green).

Tier Classification Finding:
  Meridian currently meets [Tier X] requirements. The following gaps prevent Tier III certification: [list]

Power Architecture Findings:
  [From Part 2 - UPS shortfall, generator capacity gap, single-corded servers]

Cooling and Environmental Findings:
  [From Part 3 - PUE, hot aisle, ASHRAE compliance]

Physical Security Findings:
  [From Part 4 - 5 findings with severity ratings]

Upgrade Roadmap:

  Phase 1 (0-90 days / ~$X): Critical - address SPOFs that prevent any Tier III claim
  Phase 2 (90-180 days / ~$X): High - address N+1 gaps
  Phase 3 (180-365 days / ~$X): Medium - optimize PUE and security posture

Estimated Investment to Reach Tier III: $[range]
```

---

## Deliverables

1. Completed Tier Classification Table with current tier determination and justification
2. Power analysis calculations (UPS capacity, generator load, single-corded server risk)
3. PUE calculation, industry benchmark comparison, and cooling remediation cost analysis
4. Five physical security findings in structured format
5. Complete Site Assessment Report with Executive Summary and Upgrade Roadmap

---

## Grading

| Item | Points |
|------|--------|
| Tier classification table + current tier determination | 20 |
| Power architecture calculations (correct math required) | 25 |
| PUE analysis + cooling remediation | 20 |
| Physical security findings (5, structured) | 20 |
| Site Assessment Report with Executive Summary | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Monte Carlo Availability Simulation
>
> Uptime Institute Tier availability targets are theoretical; actual availability depends on component MTBF, MTTR, and the probability distribution of failure events.
>
> Using Python with `numpy` and `scipy`:
>
> 1. Model the following components with exponential failure distributions:
>    - Single utility feed: MTBF = 8,760 hr/year (one outage/year on average)
>    - UPS (each unit): MTBF = 43,800 hr (one failure per 5 years)
>    - Generator: MTBF = 8,760 hr, MTTR = 4 hr
>    - CRAC unit (each): MTBF = 26,280 hr (one failure per 3 years)
>
> 2. Run a Monte Carlo simulation (10,000 iterations, 1-year horizon) to estimate:
>    - Annual downtime probability with current single utility feed
>    - Annual downtime probability after adding a second utility feed
>    - Expected downtime minutes/year for each scenario
>
> 3. Plot the results as a histogram of annual downtime (minutes) for both scenarios.
>
> 4. Calculate the financial impact: Meridian processes $40M/day in transactions. What is the expected annual loss from each scenario at 100% revenue impact during downtime?
>
> ### Extension B - Regulatory Compliance Mapping
>
> Financial institutions must comply with FFIEC IT Examination Handbook guidelines for data center resilience. Map Meridian's gaps to specific FFIEC controls:
>
> 1. Download the FFIEC IT Examination Handbook - Business Continuity Management booklet (publicly available).
> 2. For each of the 5 most critical gaps you identified, cite the specific FFIEC control reference, describe how Meridian fails to meet it, and state the regulatory consequence (examination finding, MRA, or enforcement action).
> 3. Identify which gaps would constitute a Material Weakness under SOX Section 404 if Meridian were a public company.
>
> Submit your Monte Carlo Python script with output plot and the FFIEC compliance mapping table.

[← Back to Labs]({{ site.baseurl }}/labs/)
