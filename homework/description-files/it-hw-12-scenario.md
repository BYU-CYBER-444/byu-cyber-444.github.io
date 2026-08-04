---
title: "IT HW 12 - Valley Medical Group Infrastructure & Monitoring Scope"
parent: Homework
nav_exclude: true
---

# Valley Medical Group - Infrastructure & Monitoring Scope
{: .no_toc }

{: .note }
This is the reference scenario for [IT HW 12]({% link homework/it-hw-12.md %}). It gives you the specific infrastructure inventory, AWS footprint, and business-cost figures your monitoring architecture, alerting rules, and SLO design need to be written against. Don't invent a different infrastructure count, AWS setup, or downtime cost - use these. This is the same Valley Medical Group used in [IT HW 14]({% link homework/it-hw-14.md %}) - the same Palo Alto firewall and VLAN scheme appear in both. This assignment comes before that one, though, so the 5 Linux servers below do **not** include HW 14's AI inference pilot server; it hadn't been proposed yet at this point in the environment's timeline.

---

## Linux Servers (5)

| Hostname | Role | Notes |
|---|---|---|
| `medflow-web01`, `medflow-web02` | MedFlow EMR web/app tier - Nginx reverse proxy + Django/Gunicorn | Active-active behind the internal load balancer; VLAN 40 (Server/Infrastructure) |
| `medflow-db01` | PostgreSQL 15 - MedFlow's primary database | VLAN 40; holds the practice's live EMR data, so its metrics are business-critical |
| `infra01` | Internal DNS, DHCP, and NTP for the practice's network | VLAN 40; if this goes down, every other host's name resolution degrades, so it's a high-priority target for "node down" alerting |
| `backup01` | Nightly backup target for MedFlow DB dumps and file shares | VLAN 40; also runs the organization's log-collection host |

## Windows Server (1)

| Hostname | Role | Notes |
|---|---|---|
| `dc01` | Domain Controller + Azure AD Connect (syncs on-prem AD to the practice's Microsoft Entra ID tenant) | VLAN 40; authenticates admin/IT staff access - clinical staff SSO to MedFlow depends on this host staying healthy |

## Network Devices (3 switches, 1 firewall)

| Device | Role | Notes |
|---|---|---|
| `core-sw01` | Core/distribution switch | Routes between VLANs 10/20/30/40 |
| `access-sw01` | Access switch - clinical workstation wing | Serves VLAN 10 (Clinical Workstations) |
| `access-sw02` | Access switch - admin wing | Serves VLAN 20 (Administrative) |
| `edge-fw01` | Palo Alto Networks NGFW - network edge and inter-VLAN policy enforcement | The same firewall referenced in IT HW 14's security architecture |

## AWS Environment

Valley Medical Group runs one cloud-hosted, non-clinical-data system: a public patient-facing appointment-scheduling portal. It stores only appointment slot availability and a confirmation code - no patient records or other PHI - which is why this specific piece of the environment was approved for the cloud.

| Resource | Type | Notes |
|---|---|---|
| `vmg-scheduling-alb` | Application Load Balancer | Public-facing, terminates TLS, routes to the EC2 target group |
| `vmg-scheduling-web` | EC2 (t3.medium, Auto Scaling group, 2-4 instances) | Runs the scheduling portal application |
| `vmg-scheduling-db` | RDS PostgreSQL (db.t3.medium, Multi-AZ) | Backs the scheduling portal only - not connected to MedFlow's on-prem database |

## Business Cost of Downtime (for Part 5's SLO justification)

Industry estimates for unplanned EHR/EMR downtime at an ambulatory practice of Valley Medical Group's size put the cost at roughly **$8,000/hour during business hours** (7 AM-7 PM: lost visit-documentation and billing throughput, plus idle clinical and administrative staff time) and **$500/hour outside business hours** (after-hours on-call clinical access only, no scheduled-visit throughput at risk). Use these two figures - not a single flat rate - when justifying your availability/latency/error-rate SLO targets and calculating your error budget in Part 5.

---

[← Back to IT HW 12]({% link homework/it-hw-12.md %})
