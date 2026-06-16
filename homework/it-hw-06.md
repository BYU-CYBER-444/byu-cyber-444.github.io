---
title: "IT HW 6 - HA Infrastructure Design with Failure Analysis"
parent: Homework
nav_order: 106
---

# IT HW 6 - HA Infrastructure Design with Failure Analysis
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
| **Assignment** | IT HW 6 |
| **Points** | 100 |
| **Due** | Week 7 |
| **Track** | IT |

---

## Description

Design a production-grade high availability infrastructure for Valley Medical Group's EMR application and justify every design decision with engineering rationale, not just technology names. Your target is **99.9% availability** (≤8.7 hours unplanned downtime per year).

**Scenario:** Valley Medical Group is expanding their EMR (Electronic Medical Records) web application to 5 clinics simultaneously. Three-tier architecture: web tier (public-facing appointment portal), application tier (EMR logic, internal only), and database tier (PostgreSQL, HIPAA-regulated, internal only). Current state: one server per tier, no redundancy. A 2-hour outage last month cost $15,000 in lost productivity and affected 200 patients.

### Part 1 - Architecture Design (35 pts)

Produce a labeled architecture diagram (draw.io, Lucidchart, or hand-drawn and photographed) showing the full proposed HA infrastructure. Every component must be labeled with its technology and role. The diagram must show failure domains - draw a dashed boundary around components that fail together.

For each tier, document your technology choices and justify them:

- **Web tier:** Load balancer technology and configuration (HAProxy, Nginx, AWS ALB, etc.); number of backend instances and why; health check configuration; SSL termination approach
- **Application tier:** Active/passive or active/active, and quantitative justification (what is the cost difference, and does the app tier actually need active/active given realistic traffic patterns?)
- **Database tier:** PostgreSQL replication strategy (streaming replication, Patroni, pgBouncer, RDS Multi-AZ, etc.); automatic vs. manual failover and why; synchronous vs. asynchronous replication and the data-loss trade-off

### Part 2 - RTO & RPO Targets (15 pts)

Define Recovery Time Objective and Recovery Point Objective for each tier. These must be:

- Specific numbers, not ranges ("under 30 seconds" not "fast")
- Justified by both the technical mechanism and the business requirement (what does a 5-minute RTO cost Valley Medical Group per incident given the $15K/2hr figure?)
- Consistent with HIPAA requirements for healthcare system availability

For the database tier, explain the relationship between your replication mode (synchronous/asynchronous) and your RPO. If you chose asynchronous, quantify the maximum data loss in minutes under realistic WAN conditions.

### Part 3 - Failure Mode Analysis (30 pts)

For each of the following failure scenarios, describe exactly what happens in your design - which component detects the failure, how long before traffic is rerouted, what the user experiences, and whether your RTO is met:

1. The primary load balancer loses power
2. One of two web-tier backend servers fails its health check
3. The primary application server's NIC fails
4. The PostgreSQL primary crashes mid-transaction
5. The data center loses one of two power feeds (partial power loss)
6. A bad deployment pushes a code bug that causes the app tier to return HTTP 500 on all requests

### Part 4 - HA Validation Test Plan (15 pts)

Write a test plan with **6 specific test cases** that you would execute before declaring this infrastructure production-ready. For each test case include:

- Test name and objective
- Pre-conditions (starting state)
- Exact steps to induce the failure
- How you monitor during the test (specific commands or dashboard metrics)
- Pass/fail criteria (specific, measurable)
- Estimated test duration and rollback procedure

### Part 5 - Cost-Benefit Summary (5 pts)

Estimate the monthly infrastructure cost increase vs. the current single-server setup (use AWS or Azure on-demand pricing as reference, or bare-metal estimates if on-prem). Calculate the breakeven point: how many prevented incidents per year justify this HA investment, given the $15,000/incident cost?

---

## Deliverable(s)

Write your full design document in `homework/it-hw-06.md`. Commit your diagram image to `homework/assets/it-hw-06-diagram.png`.

Open a PR titled `IT HW 6 - HA Infrastructure Design` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Architecture diagram - labeled, failure domains shown | 15 |
| Technology choices - justified with engineering rationale | 20 |
| RTO/RPO - specific numbers, HIPAA context, replication trade-off explained | 15 |
| Failure mode analysis - all 6 scenarios, specific timing | 30 |
| Test plan - 6 test cases, pass/fail criteria measurable | 15 |
| Cost-benefit summary | 5 |

---

## Tip

{: .tip }
For the failure mode analysis, be precise about timing. "HAProxy detects the failure" takes how long? Check the `check inter` and `fall` settings in your HAProxy config from Lab 6 - those numbers determine your real RTO.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 6 - Disaster Recovery Plan & Chaos Engineering (30 pts)

**Formal Disaster Recovery Plan (15 pts)**

Produce a formal **Disaster Recovery Plan** (`it-hw-06-drp.md`) for your HA architecture that a new administrator could execute during a real incident:

1. **Recovery Tiers** - classify each service in your architecture by recovery tier (Tier 0: ≤15 min, Tier 1: ≤1h, Tier 2: ≤4h, Tier 3: ≤24h) with justification based on business impact
2. **Failover Runbook** - for each failure mode in your validation plan, provide an exact step-by-step command runbook (not conceptual - actual commands, in order, with expected output for each)
3. **Communication Tree** - who is called first, what they are told, who they escalate to, and at what time thresholds escalation is triggered
4. **DR Test Schedule** - define a test schedule (tabletop, functional test, full failover test), success criteria for each test type, and who is responsible for conducting and signing off on each
5. **Return to Normal** - procedure for failing back to primary after recovery, including validation steps before declaring the incident closed

**Chaos Engineering Test (15 pts)**

Conduct and document a real chaos engineering test in your lab:

1. Define your **hypothesis** before testing: "If [failure condition], then [expected behavior] because [mechanism], and we will verify by [measurement]"
2. Implement the failure using `tc netem` (network partition/delay), `iptables` (firewall a VIP), or equivalent - document the exact command used
3. Capture evidence: timestamps, HAProxy status page screenshots, application error logs, and keepalived state transitions (`journalctl -u keepalived -f` output)
4. Compare **actual behavior** to your hypothesis - if they differ, explain why
5. Document any gap between expected and actual failover time and propose a specific configuration change to close the gap

Submit evidence as screenshots or terminal recordings embedded in your write-up.


[← Back to Homework]({{ site.baseurl }}/homework/)
