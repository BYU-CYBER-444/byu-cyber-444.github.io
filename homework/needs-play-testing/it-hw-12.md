---
title: "IT HW 12 - Monitoring Architecture with Alerting Rules & Runbooks"
parent: Homework
nav_order: 12
---
# IT HW 12 - Monitoring Architecture with Alerting Rules & Runbooks
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Design a complete monitoring architecture for Valley Medical Group's full infrastructure. Use the [Valley Medical Group Infrastructure & Monitoring Scope]({% link homework/description-files/it-hw-12-scenario.md %}) for the specific server inventory, AWS environment, and business-downtime-cost figures your design needs to reference. This assignment is a design exercise, not a hands-on build - you'll implement and test real Prometheus alerting rules against a live stack separately in lab. Here, the deliverable is a set of runbooks specific enough that an on-call engineer could actually use them at 2 AM.

### Part 1 - Stack Selection & Justification (10 pts)

Choose your monitoring stack (Prometheus + Grafana, Datadog, Zabbix, or another). Justify your choice against at least two alternatives using a weighted decision matrix. Criteria to evaluate: cost, HIPAA audit log support, Windows support, alert routing flexibility, on-call integration, and setup complexity. Show your scoring.

### Part 2 - Metrics & Alerting Conditions Inventory (45 pts)

For each infrastructure component, specify the exact metrics you will collect. Be specific - not "CPU usage" but `node_cpu_seconds_total{mode="idle"}` and the derived PromQL-style expression you'd use to compute utilization from it:

- Linux servers (5): system metrics via node_exporter, plus application-specific metrics for Nginx and Django
- Windows Server: equivalent metrics (use windows_exporter or Datadog agent - specify which)
- Network devices (3 switches, 1 firewall): SNMP OIDs for interface utilization, error rates, and availability (list the specific OIDs)
- AWS resources: CloudWatch metrics for EC2, RDS, and ALB (list metric names and namespaces)

Then design **at least 10 alerting conditions** covering the following categories. This is a design exercise - describe each one in a table (metric/expression, threshold, sustained duration, severity, and a one-sentence rationale for why you chose that threshold), not a Prometheus rules file. (Implementing and testing this as a real `alerts.yml` against a live Prometheus stack is covered separately in lab.)

- **Infrastructure:** High CPU (>85% for 5 min), high memory (>90%), disk filling fast (will fill in <4 hours based on derivative)
- **Availability:** Node down (instance unreachable), service down (specific process not running)
- **Application:** HTTP error rate >1% over 5 min (4xx+5xx), p95 response time >2s
- **Database:** PostgreSQL replication lag >30s, active connections >80% of `max_connections`
- **Business:** EMR application health check failure (endpoint returning non-200)

For two of your alert conditions, describe how each should be routed - P1 to PagerDuty, P2 to Slack, P3 email - and justify why that severity maps to that channel.

### Part 3 - Runbooks (30 pts)

Write runbooks for **3 of your alert conditions from Part 2**. A runbook is what an on-call engineer opens when paged at 2 AM. Each runbook must include:

1. **Alert name and trigger condition** - restate, in plain English, the specific condition you defined in Part 2 (metric, threshold, duration)
2. **Initial triage** - the first 3 commands to run and what you are looking for in the output
3. **Decision tree** - at least 3 branches: "if you see X, do Y; if you see A, do B"
4. **Resolution steps** - numbered, specific commands, not vague actions
5. **Escalation criteria** - when do you wake up the senior engineer vs. handle it yourself?
6. **Post-resolution** - what do you document, and how do you verify the system is stable before going back to sleep?

### Part 4 - SLO Design & Error Budget (15 pts)

Define SLOs for Valley Medical Group's EMR application:

- Define 3 SLOs (availability, latency, and error rate) with specific numeric targets
- Justify each target: why is 99.9% the right availability SLO - not 99.5% or 99.99%? (Use the business cost of downtime from the [Valley Medical Group Infrastructure & Monitoring Scope]({% link homework/description-files/it-hw-12-scenario.md %}).)
- Calculate the error budget for each SLO over a 30-day window (in minutes/requests)
- Define your burn rate alert thresholds: at what burn rate do you page immediately vs. create a ticket?
- What happens when the error budget is exhausted? Define the policy (freeze new deployments? reduce release cadence?)

---

## Deliverable(s)

Write your design document in `homework/it-hw-12.md`. Commit to `homework/assets/`:

- `it-hw-12-runbook-[alert-name].md` - 3 runbook files (one per alert)

Open a PR titled `IT HW 12 - Monitoring Architecture` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Stack selection - decision matrix, justified | 10 |
| Metrics & alerting conditions inventory - specific metrics/OIDs for all components, 10+ alert conditions, routing justified | 45 |
| Runbooks - 3 complete, actionable at 2 AM | 30 |
| SLO design - targets justified, error budget calculated, burn rate alerts | 15 |


[← Back to Homework]({{ site.baseurl }}/homework/)
