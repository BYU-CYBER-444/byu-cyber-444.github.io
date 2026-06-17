---
title: "IT LAB 6 - HAProxy & keepalived High Availability"
parent: Labs
nav_order: 106
---

# IT LAB 6 - HAProxy & keepalived High Availability
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 6 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy two HAProxy load balancers in active/passive VRRP configuration with keepalived
- Configure health checks, connection limits, timeouts, and logging for production-grade operation
- Implement layer-7 routing rules: path-based routing and header insertion
- Test automatic failover, measure failover time, and validate session persistence
- Tune HAProxy statistics and set up alerting for backend health

---

## Tools Required

- 4 Ubuntu 22.04 LTS VMs:
  - `lb01` (10.0.0.11) - Primary HAProxy + keepalived
  - `lb02` (10.0.0.12) - Secondary HAProxy + keepalived
  - `web01` (10.0.0.21) - Nginx backend 1
  - `web02` (10.0.0.22) - Nginx backend 2
- Virtual IP (VIP): 10.0.0.10
- Packages: `haproxy`, `keepalived`, `nginx`, `curl`, `ab` (Apache Bench)

---

## Background

A single load balancer is itself a single point of failure. VRRP (Virtual Router Redundancy Protocol) allows two load balancers to share a virtual IP address - the primary holds the VIP, and the backup assumes it automatically within seconds if the primary fails. keepalived implements VRRP and can also run health check scripts to transfer the VIP if HAProxy itself fails (not just the server).

HAProxy is the de facto standard for layer-4 and layer-7 load balancing in Linux environments. It is used by GitHub, Stack Overflow, and hundreds of Fortune 500 companies to handle millions of requests per second.

---

## Procedure

### Part 1 - Backend Web Servers (20 min)

**On web01 and web02:**

```bash
sudo apt install -y nginx
```

Create distinctive landing pages so you can verify which backend served a request:

```bash
# On web01:
echo "<html><body><h1>Backend: web01 (10.0.0.21)</h1><p>$(hostname)</p></body></html>" \
    | sudo tee /var/www/html/index.html

# On web02:
echo "<html><body><h1>Backend: web02 (10.0.0.22)</h1><p>$(hostname)</p></body></html>" \
    | sudo tee /var/www/html/index.html
```

Create a health check endpoint on both backends:

```bash
sudo mkdir -p /var/www/html/health
echo '{"status":"ok","host":"web01"}' | sudo tee /var/www/html/health/index.json
# (use web02 on the second server)
```

Configure Nginx to add a server identification header:

```nginx
# /etc/nginx/conf.d/server-id.conf
add_header X-Backend-Server $hostname always;
```

Start Nginx and verify: `curl http://10.0.0.21/health/index.json`

---

### Part 2 - HAProxy Configuration (50 min)

**Install on lb01 and lb02:**

```bash
sudo apt install -y haproxy
```

**Create `/etc/haproxy/haproxy.cfg` on both lb01 and lb02 (identical):**

```
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 50000

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    option  forwardfor
    option  http-server-close
    timeout connect  5s
    timeout client   30s
    timeout server   30s
    timeout http-request 10s
    retries 3
    default-server inter 3s fall 3 rise 2

# Statistics page
frontend stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth admin:changeme123
    stats show-legends
    stats show-node

# Main web frontend
frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/haproxy/certs/lab.pem  # self-signed for lab
    http-request redirect scheme https unless { ssl_fc }

    # Path-based routing: /api/* goes to api_backend
    acl is_api path_beg /api/
    use_backend api_backend if is_api

    # Add security headers
    http-response set-header X-Frame-Options DENY
    http-response set-header X-Content-Type-Options nosniff
    http-response set-header Strict-Transport-Security "max-age=31536000"

    default_backend web_backend

# Web backend - round-robin with health checks
backend web_backend
    balance roundrobin
    option httpchk GET /health/index.json HTTP/1.1\r\nHost:\ lb.lab.internal
    http-check expect status 200

    cookie SERVERID insert indirect nocache
    server web01 10.0.0.21:80 check cookie web01 weight 100
    server web02 10.0.0.22:80 check cookie web02 weight 100

# API backend - leastconn for long-lived connections
backend api_backend
    balance leastconn
    option httpchk GET /health/index.json
    timeout server 60s

    server web01 10.0.0.21:80 check weight 100
    server web02 10.0.0.22:80 check weight 100
```

Generate a self-signed certificate for the SSL bind:

```bash
sudo mkdir -p /etc/haproxy/certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/lab.key -out /tmp/lab.crt \
    -subj "/CN=lb.lab.internal"
sudo cat /tmp/lab.crt /tmp/lab.key | sudo tee /etc/haproxy/certs/lab.pem
```

Validate and start:

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy
```

Verify the stats page: `curl -u admin:changeme123 http://10.0.0.11:8404/stats`

---

### Part 3 - keepalived VRRP Configuration (40 min)

**On lb01 (`/etc/keepalived/keepalived.conf`):**

```
global_defs {
    notification_email {
        admin@lab.internal
    }
    router_id lb01
    script_user haproxy
    enable_script_security
}

vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight -20
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33        # adjust to your interface name
    virtual_router_id 51
    priority 110
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass SecureVRRP2024
    }
    virtual_ipaddress {
        10.0.0.10/24
    }
    track_script {
        chk_haproxy
    }
    notify_master "/usr/local/bin/notify_master.sh"
    notify_backup "/usr/local/bin/notify_backup.sh"
}
```

**On lb02 (`/etc/keepalived/keepalived.conf`):**

Same as lb01 except:
- `state BACKUP`
- `priority 90`
- `router_id lb02`

**Create notification scripts on both servers:**

```bash
sudo tee /usr/local/bin/notify_master.sh <<'EOF'
#!/bin/bash
echo "$(date): $(hostname) became MASTER for VIP 10.0.0.10" >> /var/log/vrrp-transitions.log
EOF

sudo tee /usr/local/bin/notify_backup.sh <<'EOF'
#!/bin/bash
echo "$(date): $(hostname) transitioned to BACKUP" >> /var/log/vrrp-transitions.log
EOF

sudo chmod +x /usr/local/bin/notify_master.sh /usr/local/bin/notify_backup.sh
sudo systemctl enable --now keepalived
```

**Verify VRRP state:**

```bash
ip addr show ens33 | grep 10.0.0.10    # should show VIP on lb01
sudo keepalived -t                      # config check
```

---

### Part 4 - Failover Testing and Measurement (40 min)

**4.1 Baseline - verify round-robin distribution**

```bash
for i in {1..10}; do
    curl -sk https://10.0.0.10/ -o /dev/null -w "%{http_code} %{time_total}\n"
done
```

Then test with session persistence: 10 requests with the same cookie should always go to the same backend.

**4.2 Measure failover time**

On a separate terminal, run a continuous request loop:

```bash
start=$(date +%s%3N)
for i in {1..300}; do
    result=$(curl -sk --max-time 2 https://10.0.0.10/ -w "%{http_code}" -o /dev/null 2>&1)
    echo "$(date +%H:%M:%S.%3N) Request $i: $result"
    sleep 0.5
done
```

While this runs, simulate lb01 failure:

```bash
# On lb01 - stop HAProxy (keepalived will detect and failover)
sudo systemctl stop haproxy
```

In your output, identify: the timestamp of the last successful request before failover, the timestamp of the first successful request after failover, and calculate failover time in seconds.

Then restore lb01:

```bash
sudo systemctl start haproxy
```

Observe lb02 return to BACKUP state and lb01 reclaim MASTER.

**4.3 Load test**

```bash
# Install Apache Bench
sudo apt install -y apache2-utils

# 1000 requests, 20 concurrent users
ab -n 1000 -c 20 -H "Accept-Encoding: gzip" \
   https://10.0.0.10/ 2>/dev/null | grep -E "Requests per|Failed|Time per"
```

Record: Requests/sec, Failed requests, Mean response time.

**4.4 HAProxy stats analysis**

After the load test, access `http://10.0.0.11:8404/stats` and document:
- Current sessions on each backend
- Health check status for each server
- Total bytes transferred
- Request rate

---

### Part 5 - Backend Failure Handling (30 min)

**5.1 Simulate a backend failure**

```bash
# On web01 - stop Nginx
sudo systemctl stop nginx
```

From the load balancer, verify HAProxy detected the failure:

```bash
echo "show servers state web_backend" | sudo socat stdio /run/haproxy/admin.sock
```

Confirm: `web01` shows state `DOWN` and all traffic routes to `web02`.

Add a **sorry server** (maintenance page) that serves when all backends are down:

```bash
# Create maintenance page on lb01
sudo mkdir -p /var/www/maintenance
sudo tee /var/www/maintenance/index.html <<'EOF'
<html><body><h1>Service Temporarily Unavailable</h1>
<p>We are performing maintenance. Please try again in a few minutes.</p></body></html>
EOF
```

Add to `haproxy.cfg`:

```
backend web_backend
    ...
    server sorry 127.0.0.1:8080 backup  # Nginx on lb01 serving maintenance page
```

Kill both backends and verify the maintenance page is served.

**5.2 Graceful server removal**

Use the HAProxy runtime API to take a server offline gracefully:

```bash
echo "set server web_backend/web01 state drain" | sudo socat stdio /run/haproxy/admin.sock
echo "show servers state web_backend" | sudo socat stdio /run/haproxy/admin.sock
```

Document the difference between `drain` (complete existing sessions) and `maint` (immediately stop) mode.

---

## Deliverables

1. HAProxy configuration file (both frontends + 2 backends)
2. keepalived config for both lb01 and lb02
3. Failover test log showing last success, first success after recovery, failover time in seconds
4. Load test results (ab output)
5. HAProxy stats page screenshot after load test
6. Backend failure test: DOWN state output + drain vs. maint explanation

---

## Grading

| Item | Points |
|------|--------|
| HAProxy config: frontends, backends, health checks, SSL | 25 |
| keepalived config: VRRP, health script, notifications | 20 |
| Failover test with measured failover time | 25 |
| Load test results and HAProxy stats analysis | 15 |
| Backend failure simulation and graceful drain | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Layer-7 Rate Limiting and DDoS Mitigation
>
> HAProxy can implement application-layer rate limiting using stick tables. Configure the following protections:
>
> 1. **Per-IP rate limit**: Block IPs making more than 100 requests in 30 seconds:
>    ```
>    stick-table type ip size 1m expire 30s store http_req_rate(30s)
>    http-request track-sc0 src
>    http-request deny deny_status 429 if { sc_http_req_rate(0) gt 100 }
>    ```
>
> 2. **Login brute-force protection**: For `/api/login` endpoint, block IPs with more than 5 requests/minute:
>    ```
>    acl is_login path /api/login
>    stick-table type ip size 100k expire 60s store http_req_rate(60s) table login_rate
>    http-request track-sc1 src table login_rate if is_login
>    http-request deny deny_status 429 if is_login { sc_http_req_rate(1) gt 5 }
>    ```
>
> 3. Test both rules: use `ab` to trigger the rate limit and capture the 429 response.
>
> 4. Write a brief analysis (200 words): What are the limitations of HAProxy-level rate limiting compared to a dedicated WAF? When would you use each?
>
> ### Extension B - HAProxy Prometheus Metrics and Alerting
>
> HAProxy exposes a Prometheus-compatible metrics endpoint. Set up monitoring:
>
> 1. Enable metrics in `haproxy.cfg`:
>    ```
>    frontend prometheus
>        bind *:8405
>        http-request use-service prometheus-exporter if { path /metrics }
>        stats enable
>    ```
>
> 2. Configure a Prometheus scrape job to collect HAProxy metrics every 15 seconds.
>
> 3. Write 3 Prometheus alerting rules:
>    - Alert when a backend server has been DOWN for > 1 minute
>    - Alert when the overall backend 5xx error rate exceeds 5%
>    - Alert when active connections exceed 80% of `maxconn`
>
> 4. Test each alert by simulating the condition and verifying the alert fires.
>
> Submit rate limiting configuration + ab test output showing 429 responses, and Prometheus scrape config + 3 alerting rule YAML files.

[← Back to Labs]({{ site.baseurl }}/labs/)
