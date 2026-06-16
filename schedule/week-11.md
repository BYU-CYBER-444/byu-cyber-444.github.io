---
title: "Week 11"
parent: Schedule
nav_order: 11
---

# Week 11 - Logging, Monitoring & Audit Architecture
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

[Week11_Logging_Monitoring_and_Audit_Architecture.pptx]({{ site.baseurl }}/lectures/Week11_Logging_Monitoring_and_Audit_Architecture.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **IT Track** | [IT LAB 11 - Prometheus & Grafana Monitoring Stack]({% link labs/it-lab-11.md %}) |
| **Cyber Track** | [CYBER LAB 11 - Centralized Logging with auditd & Graylog]({% link labs/cyber-lab-11.md %}) |

---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 11 - Audit Log Analysis & Attack Reconstruction]({% link homework/cyber-hw-11.md %}) |
| **IT Track** | [IT HW 11 - Monitoring Architecture with Alerting Rules & Runbooks]({% link homework/it-hw-11.md %}) |

---

## Assessments

None this week.

---

[← Previous Week]({{ site.baseurl }}/schedule/week-10/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-12/)
{: .text-right }
