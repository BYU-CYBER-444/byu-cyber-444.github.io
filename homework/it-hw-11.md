---
title: "IT HW 11 - Monitoring Architecture with Alerting Rules & Runbooks"
parent: Homework
nav_order: 111
---

# IT HW 11 - Monitoring Architecture with Alerting Rules & Runbooks
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
| **Assignment** | IT HW 11 |
| **Points** | 100 |
| **Due** | Week 12 |
| **Track** | IT |

---

## Description

Design a complete monitoring architecture for Valley Medical Group's full infrastructure (5 Linux servers, 1 Windows Server, 3 network switches, 1 firewall, and the AWS environment from HW 9). Then write real alerting rules and runbooks - the deliverable is something an on-call engineer could actually use at 2 AM.

### Part 1 - Stack Selection & Justification (10 pts)

Choose your monitoring stack (Prometheus + Grafana, Datadog, Zabbix, or another). Justify your choice against at least two alternatives using a weighted decision matrix. Criteria to evaluate: cost, HIPAA audit log support, Windows support, alert routing flexibility, on-call integration, and setup complexity. Show your scoring.

### Part 2 - Metrics Inventory (15 pts)

For each infrastructure component, specify the exact metrics you will collect. Be specific - not "CPU usage" but `node_cpu_seconds_total{mode="idle"}` and the derived PromQL expression:

- Linux servers (5): system metrics via node_exporter, plus application-specific metrics for Nginx and Django
- Windows Server: equivalent metrics (use windows_exporter or Datadog agent - specify which)
- Network devices (3 switches, 1 firewall): SNMP OIDs for interface utilization, error rates, and availability (list the specific OIDs)
- AWS resources: CloudWatch metrics for EC2, RDS, and ALB (list metric names and namespaces)

### Part 3 - Prometheus Alerting Rules (30 pts)

Write a production-ready `alerts.yml` file for Prometheus Alertmanager with **at least 10 alert rules** covering the following categories. Each rule must include `expr`, `for`, `labels` (severity), and `annotations` (summary and description with `{{ $value }}` substitution):

- **Infrastructure:** High CPU (>85% for 5 min), high memory (>90%), disk filling fast (will fill in <4 hours based on derivative)
- **Availability:** Node down (instance unreachable), service down (specific process not running)
- **Application:** HTTP error rate >1% over 5 min (4xx+5xx), p95 response time >2s
- **Database:** PostgreSQL replication lag >30s, active connections >80% of `max_connections`
- **Business:** EMR application health check failure (endpoint returning non-200)

For two of your alerts, write a companion Alertmanager `route` block showing how that alert gets routed - P1 to PagerDuty, P2 to Slack, P3 email.

### Part 4 - Runbooks (30 pts)

Write runbooks for **3 of your alerts**. A runbook is what an on-call engineer opens when paged at 2 AM. Each runbook must include:

1. **Alert name and trigger condition** (restate the PromQL expression in plain English)
2. **Initial triage** - the first 3 commands to run and what you are looking for in the output
3. **Decision tree** - at least 3 branches: "if you see X, do Y; if you see A, do B"
4. **Resolution steps** - numbered, specific commands, not vague actions
5. **Escalation criteria** - when do you wake up the senior engineer vs. handle it yourself?
6. **Post-resolution** - what do you document, and how do you verify the system is stable before going back to sleep?

### Part 5 - SLO Design & Error Budget (15 pts)

Define SLOs for Valley Medical Group's EMR application:

- Define 3 SLOs (availability, latency, and error rate) with specific numeric targets
- Justify each target: why is 99.9% the right availability SLO - not 99.5% or 99.99%? (Use the business cost of downtime from HW 6.)
- Calculate the error budget for each SLO over a 30-day window (in minutes/requests)
- Define your burn rate alert thresholds: at what burn rate do you page immediately vs. create a ticket?
- What happens when the error budget is exhausted? Define the policy (freeze new deployments? reduce release cadence?)

---

## Deliverable(s)

Write your design document in `homework/it-hw-11.md`. Commit to `homework/assets/`:

- `it-hw-11-alerts.yml` - your Prometheus alerting rules file
- `it-hw-11-runbook-[alert-name].md` - 3 runbook files (one per alert)

Open a PR titled `IT HW 11 - Monitoring Architecture` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Stack selection - decision matrix, justified | 10 |
| Metrics inventory - specific metrics/OIDs for all components | 15 |
| Alert rules - 10+ rules, correct PromQL, routing blocks | 30 |
| Runbooks - 3 complete, actionable at 2 AM | 30 |
| SLO design - targets justified, error budget calculated, burn rate alerts | 15 |

---

## Tip

{: .tip }
`predict_linear(node_filesystem_free_bytes[1h], 4*3600) < 0` is how you write a "disk will fill in 4 hours" alert in PromQL. Test your expressions in the Prometheus expression browser before pasting them into `alerts.yml`.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 6 - SRE Runbook Library & Multi-Window Burn Rate Alerting (30 pts)

**Decision-Tree Runbooks (15 pts)**

Extend each of your 3 runbooks with a **diagnostic decision tree** that guides an on-call engineer who has never seen this system before. Each decision tree must:

1. Start from a single entry point: the PagerDuty/alerting system alert title
2. Branch based on observable conditions (command output, dashboard state, log patterns) - not assumptions
3. Lead to one of 4 terminal outcomes: `RESOLVED` (with remediation step), `ESCALATE` (with escalation path), `INVESTIGATE_FURTHER` (with next data source to examine), or `FALSE_POSITIVE` (with suppression procedure)
4. Cover at least 5 decision nodes per runbook
5. Be formatted in Mermaid flowchart syntax (rendered in your markdown)

Include the exact command to run at each diagnostic step and what the output means (both healthy and unhealthy patterns).

**Multi-Window Burn Rate Alert (15 pts)**

Implement the **multi-window, multi-burn-rate alerting** strategy described in the Google SRE Workbook (Chapter 5) for your most critical SLO.

In your `alerts.yml`, define alerts for all four burn rate windows:
- 1h window, 14.4× burn rate → page immediately (exhausts 1h budget)
- 6h window, 6× burn rate → page (exhausts 6h budget)
- 3d window, 1× burn rate → ticket (sustained degradation)
- 30d window, 0.1× burn rate → informational (trend watch)

In your write-up, show the full math:
- Given your SLO (e.g., 99.9% = 43.8 min/month error budget), what does a 14.4× burn rate mean in concrete terms?
- At what error rate does your 1h alert fire? (error_rate > burn_rate × (1 - SLO))
- Why is a single burn rate alert insufficient (explain false positive and false negative failure modes)?

Implement a PromQL recording rule that pre-computes the error rate ratio to make your alert expressions efficient, and explain why recording rules are important at scale.


[← Back to Homework]({{ site.baseurl }}/homework/)
