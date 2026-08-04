---
title: "Week 12"
parent: Schedule
nav_order: 12
---

# Week 12 - Logging, Monitoring & Audit Architecture
{: .no_toc }

---

## Topics

- Linux `auditd` rule writing (syscall, file watch, key-based); Windows Event Log forwarding (WEF/WEC)
- Syslog-ng and rsyslog pipelines; centralized log aggregation with Graylog or Elastic
- Log retention policies and NIST SP 800-92 log management
- MITRE ATT&CK for log analysis: mapping auditd and Windows Event Log entries to ATT&CK techniques, using ATT&CK Navigator, building detection rules
- Prometheus data model: metric types, labels, scrape intervals; PromQL instant vectors, range queries, aggregations
- Grafana dashboard design: panels, variables, thresholds, annotations
- node_exporter and custom exporters; SNMP for network device monitoring (MIBs, SNMPv3)
- Alerting rule design: severity levels, routing, avoiding alert fatigue; PagerDuty/OpsGenie integration
- Capacity planning methodology: trending, forecasting, headroom analysis

---

## Slides

[Logging, Monitoring & Audit Architecture]({{ site.baseurl }}/lectures/CYBER444_Week12_Logging_Audit_and_Audit_Architecture.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **Cyber Track** | [CYBER LAB 12 - Centralized Logging with auditd & Graylog]({% link labs/cyber-lab-12.md %}) |
| **IT Track** | [IT LAB 12 - Prometheus & Grafana Monitoring Stack]({% link labs/it-lab-12.md %}) |


---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 12 - Audit Log Analysis & Attack Reconstruction]({% link homework/cyber-hw-12.md %}) |
| **IT Track** | [IT HW 12 - Monitoring Architecture with Alerting Rules & Runbooks]({% link homework/it-hw-12.md %}) |

---

[← Previous Week]({{ site.baseurl }}/schedule/week-11/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-14/)
{: .text-right }
