---
title: "IT LAB 12 - Prometheus & Grafana Monitoring Stack"
parent: Labs
nav_order: 12
---

# IT LAB 12 - Prometheus & Grafana Monitoring Stack
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy and operate a host monitoring stack across the three assigned VMs.
- Collect and interpret CPU, memory, disk, network, filesystem, and load metrics from every host.
- Create a multi-host Grafana dashboard with eight useful panels.
- Design severity-based alert routing and suppress redundant alerts when a host is down.
- Validate infrastructure alerts and HTTP SLO burn-rate rules, and explain which can produce live alerts in this environment.

## Tools and Starting Conditions

Your instructor has provisioned three Ubuntu 22.04 LTS VMs:

| Host | Address | Role |
|---|---|---|
| `it-lab12-mon01` | assigned monitoring VM address | Monitoring server and one monitored host |
| `it-lab12-node01` | `10.0.0.21` | Monitored host |
| `it-lab12-node02` | `10.0.0.22` | Monitored host |

Your username on all three is your Net ID; use the password emailed at the start of the semester. You need SSH access to all three VMs and a browser that can reach the monitoring server.

**First action:** Connect to each VM and confirm its hostname matches the table before making changes. If a VM or address does not match, contact your instructor before continuing.

**Estimated effort:** 3–4 hours (unpiloted, adjustable planning estimate; actual time may vary with download speed and dashboard familiarity).

**Help route:** If access, starting conditions, or expected results do not match this brief, stop and contact your instructor or course lab support. Include the VM name, the check you performed, its observed result, and a focused question.

## Background

Prometheus collects time-series data by scraping configured metrics endpoints. PromQL is used to calculate and compare measurements over time. An SLO (Service Level Objective) describes a reliability target; its error budget is the amount of unreliability allowed within the target period. Burn-rate alerts indicate how quickly that budget would be consumed if the current failure rate continued.

The assigned VMs provide host metrics through node_exporter. They do not run an HTTP application that publishes request metrics. Your HTTP SLO rules must therefore be syntactically valid and loaded by Prometheus, but are not expected to fire.

## Work and Required Outcomes

Complete the work across the three hosts. Install and run node_exporter on all three VMs. Run Prometheus, Grafana, and Alertmanager on `it-lab12-mon01`; configure Prometheus to collect from itself and both monitored nodes. Set up the Prometheus scrape and alert-rule configuration before relying on the service. Keep the monitoring services available for grading.

Create a submission directory on the monitoring host at `~/lab12-submission`. Work in the order below and retain each named artifact there.

### 1. Monitoring stack

The three node_exporter services must be active. Prometheus must be active with a valid configuration and three healthy node targets, one for each VM. Grafana must be active and have a working Prometheus data source. Alertmanager must be active and report ready.

Allow enough time for initial scrapes and rate calculations. If a service or target check fails, inspect the relevant service logs and configuration, correct the cause, and repeat the check before moving on.

### 2. Host metric queries

Prepare and run one PromQL query for each required result. Each query must return live data for all three host instances. Record one row for each returned series, including the instance, value, and any additional identifying labels. Values vary over time and between VMs; grading checks that the required result is present and queryable, not that it equals a fixed measurement.

Save the query expressions in these files under `~/lab12-submission/queries/`:

| File | Required result |
|---|---|
| `cpu.promql` | Per-host CPU utilization percentage calculated from recent CPU activity |
| `memory.promql` | Per-host percentage of memory available |
| `disk-read.promql` | Per-host disk read throughput in decimal MB/s, excluding loop and RAM devices |
| `disk-write.promql` | Per-host disk write throughput in decimal MB/s, excluding loop and RAM devices |
| `network-inbound.promql` | Per-host inbound network throughput in decimal Mbps, excluding loopback |
| `network-top3-outbound.promql` | The three highest per-host outbound traffic rates, excluding loopback |
| `filesystem-usage.promql` | Filesystem use as a percentage, excluding temporary and device-backed filesystems |
| `system-load.promql` | Per-host 15-minute load average normalized by logical CPU count |

Save the observed results in `~/lab12-submission/query-results.md`. Include the query ID, instance, value, and any series labels beyond instance. Use the eight file basenames as the query IDs.

### 3. Grafana dashboard

Create and save a dashboard titled **Infrastructure Health**. Use the Prometheus data source and include the following eight panels. The displayed measurements must correspond to the selected host or hosts, and each panel must use its named title, visualization type, unit, and threshold behavior.

| Panel title | Type | Required display and behavior |
|---|---|---|
| CPU Usage | Time series | CPU utilization percentage; green below 70%, yellow from 70%, red from 90% |
| Memory Available | Gauge | Available memory percentage; red below 10%, yellow from 10%, green from 20% |
| Disk I/O Read | Time series | Disk read throughput in decimal MB/s |
| Disk I/O Write | Time series | Disk write throughput in decimal MB/s |
| Network Inbound | Time series | Inbound network throughput in decimal Mbps |
| Filesystem Usage | Bar gauge | Filesystem use percentage; green below 80%, red from 80% |
| System Load | Stat | 15-minute load normalized by logical CPU count; red from 1.5 |
| Up/Down Status | Stat | Whether each selected node target is up; red when down and green when up |

Add a query-based dashboard variable named `instance`, backed by the Prometheus data source. It must support selecting multiple instances and an all-host selection. All eight panels must respond to the variable so a grader can inspect either individual hosts or all three together.

Export the saved dashboard to `~/lab12-submission/infrastructure-health.json`. The export must represent the live dashboard, with the required title, eight panels, variable, and panel behavior. The live Grafana dashboard is the grading source of truth; the JSON export is also a required deliverable.

### 4. Alert routing and inhibition

Configure Alertmanager with a default receiver named `team-default` and a critical receiver named `team-oncall`. Warning alerts must route to `team-default`; critical alerts must route to `team-oncall`. Use the lab example addresses `it-ops@lab.internal` and `oncall@lab.internal` for the corresponding receivers. The grader checks configuration and routing, not email delivery.

Configure instance-based inhibition so an `InstanceDown` alert suppresses alerts named `High.*` or `DiskSpaceLow` for that same instance. Alertmanager must validate the configuration and report ready. Save a copy of the active configuration as `~/lab12-submission/alertmanager.yml`.

### 5. Alert rules and SLO

Create and load these three infrastructure alert rules with the stated conditions, durations, and severities:

| Rule | Condition | Duration | Severity |
|---|---|---:|---|
| `InstanceDown` | A node target reports down | 2 minutes | critical |
| `HighCPUUsage` | CPU use exceeds 90% | 5 minutes | warning |
| `DiskSpaceLow` | A non-temporary filesystem exceeds 85% use | 10 minutes | warning |

Also create and load the following HTTP SLO rules for a 99.9% availability objective over 30 days. The fast rule detects a 14x burn rate over a 1-hour window; the slow rule detects a 5x burn rate over a 6-hour window. Both use HTTP server-error requests relative to all requests. `ErrorBudgetBurnRateFast` has a 2-minute duration and critical severity; `ErrorBudgetBurnRateSlow` has a 15-minute duration and warning severity. The lab has no HTTP request metric source, so these rules must validate and load but need not fire.

The Prometheus rule validator must report success, Prometheus must remain active, and its live rules view must show all five exact rule names with the required conditions, durations, and severities. Save the rule file as `~/lab12-submission/infrastructure.yml` and the successful validator output as `~/lab12-submission/promtool-check.txt`.

## Deliverables

Keep the following items on `it-lab12-mon01` in `~/lab12-submission`:

- Eight named query files under `queries/` and `query-results.md` with observed values and labels.
- `infrastructure-health.json`, an export of the saved Grafana dashboard.
- `alertmanager.yml`, a copy of the active Alertmanager configuration.
- `infrastructure.yml`, the five required Prometheus alert rules.
- `promtool-check.txt`, showing successful rule validation.

The grader checks the live services, target health, active configurations, query results, dashboard, routing, inhibition, and loaded alert rules, along with the required copies. It does not compare dynamic metric values against fixed numbers. Leave all three VMs powered on and reachable, with the required services running, until grading is complete.

## Grading

Each listed check is assessed against the live VMs and required copies. Checks within each category are scored separately, so a missed check does not remove credit for other checks in that category.

| Item | Automatic checks | Points |
|---|---|---:|
| Stack deployment | node_exporter active on each VM (2 each); each of the three node targets healthy (1 each); Prometheus active/config valid (4); Grafana active with tested Prometheus data source (4); Alertmanager active and ready (3) | 20 |
| PromQL queries | Each of the eight named query files contains the required expression and returns series from the live API (3 each); `query-results.md` is present and records instance labels and values (1) | 25 |
| Grafana dashboard | Exact dashboard title (1); each panel has its required title/type (1 each) and expression (1 each); instance variable settings (4); thresholds (3); exported JSON matches the live dashboard (1) | 25 |
| Alertmanager | Service active and ready (3); config passes validation (3); default and severity routes are correct (5); instance-down inhibition rule is correct (4) | 15 |
| Alert rules and SLO | Rule validation succeeds and all five rules are loaded (5); each of the three infrastructure rules has its required expression, duration, and severity (2 each); each SLO rule has its required expression, duration, and severity (2 each) | 15 |
| **Total** |  | **100** |

[← Back to Labs]({{ site.baseurl }}/labs/)
