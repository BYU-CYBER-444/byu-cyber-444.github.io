---
title: "IT LAB 11 - Prometheus & Grafana Monitoring Stack"
parent: Labs
nav_order: 111
---

# IT LAB 11 - Prometheus & Grafana Monitoring Stack
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 11 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy a Prometheus + Grafana monitoring stack with node_exporter for host metrics
- Write PromQL queries covering rate calculations, aggregations, and histogram analysis
- Build a production-quality Grafana dashboard for infrastructure health
- Configure Alertmanager with multi-channel routing and alert inhibition rules
- Define SLOs and implement error budget burn rate alerting

---

## Tools Required

- Ubuntu 22.04 LTS VM (monitoring server)
- Ubuntu 22.04 LTS VM(s) for monitored nodes (or use localhost)
- Packages: Prometheus, Grafana, Alertmanager, node_exporter (download from prometheus.io)
- `curl`, `jq`

---

## Background

Prometheus uses a pull model: it scrapes metrics endpoints at configured intervals. All metrics are time-series with labels for dimensionality. PromQL is Prometheus's query language - it differs from SQL in that it operates on time ranges rather than rows.

An **SLO** (Service Level Objective) is a target for reliability - e.g., "99.9% of HTTP requests complete in < 200ms." An **error budget** is the allowed failure space: 0.1% of requests over 30 days = 43.2 minutes of allowed downtime. **Burn rate** alerting catches SLO threats before the budget is exhausted.

---

## Procedure

### Part 1 - Stack Deployment (30 min)

```bash
# Create a dedicated user for Prometheus
sudo useradd --no-create-home --shell /bin/false prometheus

# Download and install Prometheus
PROM_VER="2.47.0"
wget -q https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz
tar xzf prometheus-${PROM_VER}.linux-amd64.tar.gz
sudo cp prometheus-${PROM_VER}.linux-amd64/{prometheus,promtool} /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp -r prometheus-${PROM_VER}.linux-amd64/{consoles,console_libraries} /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and install node_exporter
NE_VER="1.6.1"
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NE_VER}/node_exporter-${NE_VER}.linux-amd64.tar.gz
tar xzf node_exporter-${NE_VER}.linux-amd64.tar.gz
sudo cp node_exporter-${NE_VER}.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create systemd units
sudo tee /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter \
    --collector.systemd \
    --collector.processes \
    --web.listen-address=:9100
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus \
    --storage.tsdb.retention.time=30d \
    --web.enable-lifecycle \
    --web.enable-admin-api
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter prometheus
```

**Configure `/etc/prometheus/prometheus.yml`:**

```yaml
global:
  scrape_interval:     15s
  evaluation_interval: 15s
  external_labels:
    environment: lab
    region: us-east-1

rule_files:
  - /etc/prometheus/rules/*.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100', '10.0.0.21:9100', '10.0.0.22:9100']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+).*'
        replacement: '$1'
```

Verify Prometheus is scraping: `curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[].health'`

**Install Grafana:**

```bash
sudo apt install -y apt-transport-https software-properties-common
wget -q -O - https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update && sudo apt install -y grafana
sudo systemctl enable --now grafana-server
```

Add Prometheus as a data source in Grafana UI (http://localhost:3000, admin/admin): Configuration → Data Sources → Add data source → Prometheus → URL: http://localhost:9090.

---

### Part 2 - PromQL Queries (40 min)

Write and test each of the following PromQL queries. For each, record the query, a brief explanation, and a screenshot or formatted output.

**2.1 CPU utilization (rate-based)**

```promql
# CPU usage percentage per instance
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**2.2 Memory available**

```promql
# Memory available as percentage of total
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

**2.3 Disk I/O throughput**

```promql
# Disk read throughput in MB/s
rate(node_disk_read_bytes_total{device="sda"}[5m]) / 1024 / 1024

# Disk write throughput in MB/s
rate(node_disk_written_bytes_total{device="sda"}[5m]) / 1024 / 1024
```

**2.4 Network traffic**

```promql
# Inbound network traffic in Mbps
rate(node_network_receive_bytes_total{device="ens33"}[5m]) * 8 / 1024 / 1024

# Top 3 instances by outbound traffic
topk(3, rate(node_network_transmit_bytes_total[5m]) * 8 / 1024 / 1024)
```

**2.5 Filesystem usage with alerting threshold**

```promql
# Filesystems above 80% usage
(node_filesystem_size_bytes{fstype!~"tmpfs|devtmpfs"} - node_filesystem_free_bytes{fstype!~"tmpfs|devtmpfs"})
/ node_filesystem_size_bytes{fstype!~"tmpfs|devtmpfs"} * 100 > 80
```

**2.6 System load vs. CPU count**

```promql
# Load average normalized by CPU count (> 1 means overloaded)
node_load15 / count without(cpu, mode)(node_cpu_seconds_total{mode="idle"})
```

For each query: run it in Prometheus UI (http://localhost:9090/graph) and save the graph screenshot.

---

### Part 3 - Grafana Dashboard (40 min)

Build a Grafana dashboard named "Infrastructure Health" with the following panels:

| Panel | Type | PromQL | Thresholds |
|-------|------|--------|------------|
| CPU Usage (all hosts) | Time series | From 2.1 | Green < 70%, Yellow 70-90%, Red > 90% |
| Memory Available % | Gauge | From 2.2 | Red < 10%, Yellow 10-20% |
| Disk I/O Read | Time series | From 2.3 read | - |
| Disk I/O Write | Time series | From 2.3 write | - |
| Network Inbound | Time series | From 2.4 inbound | - |
| Filesystem Usage | Bar gauge | Adapted from 2.5 | Red > 80% |
| System Load | Stat | From 2.6 | Red > 1.5 |
| Up/Down Status | Stat | `up{job="node"}` | Red = 0 |

Configure dashboard variables: `$instance` (multi-value query variable from `label_values(up, instance)`) so individual hosts can be filtered.

Export the dashboard JSON and include in your submission.

---

### Part 4 - Alertmanager Configuration (30 min)

**Install Alertmanager:**

```bash
AM_VER="0.26.0"
wget -q https://github.com/prometheus/alertmanager/releases/download/v${AM_VER}/alertmanager-${AM_VER}.linux-amd64.tar.gz
tar xzf alertmanager-${AM_VER}.linux-amd64.tar.gz
sudo cp alertmanager-${AM_VER}.linux-amd64/{alertmanager,amtool} /usr/local/bin/
sudo mkdir -p /etc/alertmanager
```

**Create `/etc/alertmanager/alertmanager.yml`:**

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'localhost:25'
  smtp_from: 'alertmanager@lab.internal'

templates:
  - '/etc/alertmanager/templates/*.tmpl'

route:
  group_by: ['alertname', 'instance']
  group_wait:      30s
  group_interval:  5m
  repeat_interval: 4h
  receiver: 'team-default'
  routes:
    - match:
        severity: critical
      receiver: 'team-oncall'
      continue: false
    - match:
        severity: warning
      receiver: 'team-default'

inhibit_rules:
  - source_match:
      alertname: 'InstanceDown'
    target_match_re:
      alertname: 'High.*'
    equal: ['instance']

receivers:
  - name: 'team-default'
    email_configs:
      - to: 'it-ops@lab.internal'
        send_resolved: true
  - name: 'team-oncall'
    email_configs:
      - to: 'oncall@lab.internal'
        send_resolved: true
```

Explain the `inhibit_rules` entry: when an instance is completely down, suppress all other alerts for that instance (CPU high, memory low, disk full, etc.) since they are all caused by the outage.

---

### Part 5 - Alerting Rules and SLO Error Budget (20 min)

**Create `/etc/prometheus/rules/infrastructure.yml`:**

```yaml
groups:
  - name: infrastructure
    rules:
    - alert: InstanceDown
      expr: up{job="node"} == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Instance {{ $labels.instance }} is down"
        description: "{{ $labels.instance }} has been unreachable for > 2 minutes"

    - alert: HighCPUUsage
      expr: 100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU on {{ $labels.instance }}: {{ $value | printf \"%.1f\" }}%"

    - alert: DiskSpaceLow
      expr: |
        (node_filesystem_size_bytes - node_filesystem_free_bytes)
        / node_filesystem_size_bytes * 100 > 85
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Disk {{ $labels.mountpoint }} on {{ $labels.instance }} is {{ $value | printf \"%.1f\" }}% full"

  - name: slo-web-availability
    rules:
    # SLO: 99.9% availability over 30 days
    # Error budget: 0.1% = 43.2 minutes/month
    - alert: ErrorBudgetBurnRateFast
      expr: |
        sum(rate(http_requests_total{status=~"5.."}[1h]))
        / sum(rate(http_requests_total[1h])) > 0.14
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "SLO burning fast: 14x burn rate (1h window)"
        description: "At this rate, the monthly error budget will be exhausted in < 2 hours"

    - alert: ErrorBudgetBurnRateSlow
      expr: |
        sum(rate(http_requests_total{status=~"5.."}[6h]))
        / sum(rate(http_requests_total[6h])) > 0.05
      for: 15m
      labels:
        severity: warning
      annotations:
        summary: "SLO burning slowly: 5x burn rate (6h window)"
```

Validate: `promtool check rules /etc/prometheus/rules/infrastructure.yml`

Write a 200-word explanation of the error budget burn rate alerting strategy:
- Why are there two alerts (fast and slow burn)?
- What does "14x burn rate" mean in plain language?
- How does this approach differ from simple threshold alerting?

---

## Deliverables

1. Prometheus + Grafana stack running: screenshot of Prometheus targets page showing all scraped targets
2. Six PromQL queries with output screenshots or formatted results
3. Grafana dashboard JSON export + screenshot showing all 8 panels
4. Alertmanager config + inhibit rule explanation
5. Alert rules file + `promtool check` output
6. 200-word error budget burn rate explanation

---

## Grading

| Item | Points |
|------|--------|
| Stack deployment and all targets scraping | 20 |
| PromQL queries (6) with evidence | 25 |
| Grafana dashboard (8 panels + variable) | 25 |
| Alertmanager config with routing and inhibition | 15 |
| Alert rules + burn rate explanation | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Custom Exporter Development
>
> Prometheus exporters expose metrics from applications that don't natively speak Prometheus. Write a custom Python exporter that monitors your BIND9 DNS server:
>
> 1. Use the `prometheus_client` Python library.
> 2. Expose the following metrics by parsing BIND9's statistics channel (`curl http://localhost:8080/xml/v3`):
>    - `bind_queries_total` (counter, by query type: A, AAAA, MX, etc.)
>    - `bind_resolver_cache_hits_total` (counter)
>    - `bind_zone_serial` (gauge, by zone name)
> 3. Run the exporter on port 9119 and add it to Prometheus scrape config.
> 4. Build a Grafana panel showing DNS query rate by type over the last hour.
>
> ### Extension B - Multi-Window SLO Dashboard
>
> Implement the Google SRE multi-window, multi-burn-rate alerting approach for a web service SLO:
>
> 1. Define an SLO: 99.9% of requests must return HTTP 2xx within 500ms.
>
> 2. Implement four Prometheus alerting rules covering all four quadrants:
>    - Fast burn (1h/5m windows): 14× burn rate → page immediately
>    - Fast burn (6h/30m windows): 6× burn rate → page
>    - Slow burn (1d/2h windows): 3× burn rate → ticket
>    - Slow burn (3d/6h windows): 1× burn rate → review
>
> 3. Create a Grafana dashboard showing: current error rate, remaining error budget (%), projected budget exhaustion time at current rate.
>
> 4. Write a 300-word explanation of why the multi-window approach reduces both false positive rate (compared to single-window fast burn) and detection delay (compared to single-window slow burn).
>
> Submit Python exporter code + Grafana DNS panel screenshot, and SLO alerting rules YAML + multi-window dashboard screenshot + 300-word explanation.

[← Back to Labs]({{ site.baseurl }}/labs/)
