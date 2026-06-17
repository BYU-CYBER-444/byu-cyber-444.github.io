---
title: Final Project (IT Track)
nav_order: 7
has_children: true
permalink: /final-project-it/
---

# Final Project - IT Track
{: .no_toc }

IT Infrastructure Operations Build · 10% of course grade · Weeks 8-15 · Individual Assignment
{: .fs-5 .fw-300 }

{: .note }
This is the **IT Track** final project. Cyber Track students complete the [Cyber Track Final Project]({% link final-project-cyber/index.md %}) instead.

---

## Overview

The IT Track Final Project is a multi-week applied project in which students design, provision, document,
and present a production-grade IT infrastructure. The project spans Weeks 8-15 and accounts for 10% of
the course grade.

Students build a complete operational environment covering three pillars: **cloud infrastructure**, **high availability**, and **monitoring**. They also produce a professional documentation package - ITSM records, enterprise policies, and an AI infrastructure proposal - that mirrors what an IT team would deliver to leadership.

---

## Required Infrastructure

| Component | Technology | Purpose |
|---|---|---|
| Cloud Environment | AWS or Azure | VPC/VNet, subnets, security groups, IAM, at least 2 EC2/VM instances |
| HA Cluster | HAProxy + keepalived (VRRP) | Active/passive load balancer with automatic VIP failover |
| App Servers | 2× Ubuntu 22.04 LTS | Backend application nodes behind the HA load balancer |
| Monitoring Stack | Prometheus + Grafana + node_exporter | Metrics collection, dashboards, and alert rules |

The infrastructure represents a simplified version of Valley Medical Group's IT environment, the same organization used throughout the course.

---

## Documentation Package

In addition to the infrastructure build, students produce a professional documentation package:

| Document | Description |
|---|---|
| ITSM Package | Service catalog entry, RFC for the infrastructure change, simulated incident ticket, PIR with 5 Whys |
| Policy Package | Production-ready AUP (with AI usage section), data classification policy, BYOD policy |
| AI Infrastructure Proposal | On-premises AI inference server spec for the organization |
| Architecture Diagram | Labeled network diagram showing all components, IPs, and data flows |

---

## Milestones

| Milestone | Weight |
|---|---|
| [Project Proposal]({% link final-project-it/proposal.md %}) | Required (pass/fail) |
| [Progress Check 1 - Infrastructure Build]({% link final-project-it/progress-checks.md %}) | 2.5% |
| [Progress Check 2 - Monitoring & Documentation]({% link final-project-it/progress-checks.md %}#progress-check-2) | 2.5% |
| [Final Documentation Package]({% link final-project-it/final-deliverables.md %}) | 2.5% |
| [Live Presentation & Demo]({% link final-project-it/final-deliverables.md %}#presentation) | 2.5% |

---

## Grading Rubrics

---

### Project Proposal - Pass/Fail (Required)

| Criterion | Pass | Fail |
|---|---|---|
| Infrastructure Scope | Cloud environment + HA cluster + monitoring stack all described with technology choices and IP/subnet plan | Any pillar missing or described only generically |
| ITSM Scope | States which ITSM records will be produced and what simulated scenario the incident/PIR will cover | ITSM deliverables not described |
| Policy Scope | Lists which three policy documents will be written and identifies the organization's context | Policy documents not specified |
| AI Proposal Scope | Identifies the use case, model candidate, and key hardware decision (CPU-only vs. GPU) | AI proposal not described or too vague to evaluate |
| Week-by-Week Milestones | Personal timeline from Week 8 to Week 15 with specific deliverables per week | Generic entries or missing milestone dates |
| Completeness | All five sections present and submitted on time | Any section missing or submitted late |

---

### Progress Check 1 - Infrastructure Build (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Cloud Environment | 25 | VPC/VNet with public and private subnets, security groups with least-privilege rules, at least 2 instances running and reachable | VPC and instances running; security groups use broad allow rules | Missing subnets or instances not reachable |
| HA Cluster | 30 | HAProxy round-robins to both app servers; keepalived holds VIP; failover test documented with before/after `ip addr` output | HAProxy and keepalived running; failover not yet tested | Load balancer or VRRP not functional |
| Cloud IAM | 25 | Custom least-privilege IAM policy; named IAM user/role with policy attached; CLI test showing an allowed action and a denied action | IAM policy created; least-privilege not verified | IAM not configured or using root credentials |
| Submission | 20 | All config files committed to portfolio repo; README covers architecture and exact commands to reproduce; PR submitted on time | Files committed; README incomplete | No PR or missing critical files |

---

### Progress Check 2 - Monitoring & Documentation (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Monitoring Stack | 30 | Prometheus scraping all nodes; Grafana dashboards show CPU, memory, disk, network; at least one alert rule configured and tested | Prometheus and Grafana running; dashboards present but incomplete | Monitoring not functional or scraping only one node |
| ITSM Documentation | 30 | RFC (all 9 fields), incident ticket from simulated outage, PIR with complete 5 Whys reaching systemic root cause | RFC and incident ticket present; PIR root cause stays at symptom level | ITSM records missing or incomplete |
| Policy Package Draft | 25 | AUP, data classification policy, and BYOD policy all drafted; each has required sections; AUP includes AI usage addendum | Two of three policies complete | Only one policy drafted |
| AI Proposal Draft | 15 | Hardware spec, open-weight model choice, and HIPAA data handling policy all present | Hardware spec and model choice present; data handling thin | Proposal not drafted |

---

### Final Documentation Package (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Diagram | 15 | Labels all components (hostnames, IPs, roles), shows HA cluster topology, cloud boundary, monitoring data flows, and VIP | Diagram present; missing some labels or the monitoring flows | Too vague to represent actual infrastructure |
| ITSM Package | 25 | RFC (9 fields, CAB-ready language), incident ticket (full timeline + impact), PIR (5 Whys to systemic root cause), KEDB entry | Three of four records complete and professional | One or more records missing or superficial |
| Policy Package | 25 | AUP (10+ specific prohibited activities, AI section, signature block), data classification (4 tiers, healthcare examples, roles), BYOD (MDM, remote wipe, PHI access decision) - all production-ready | All three policies present; one or two sections thin | Fewer than three policies or clearly draft quality |
| AI Infrastructure Proposal | 20 | All 8 sections complete (use cases, hardware spec with justification, software stack, access control, data handling, security controls, AUP addendum, cost summary) | Six or more sections complete | Fewer than 6 sections or spec not actionable |
| Lessons Learned | 15 | Specific and reflective; addresses what worked, what failed, what would be done differently, and one recommendation for future students | Present but generic | Missing or fewer than one paragraph |

---

### Live Presentation and Demo (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Overview | 15 | Clearly explains all infrastructure pillars, technology choices, and design decisions; spoken from memory | Covers the basics; some elements unclear | Vague or reads from notes |
| HA Failover Demo | 25 | Stops the active keepalived node live; VIP moves to standby; HAProxy continues serving traffic; before/after `ip addr` shown | Demo runs; VIP movement visible but traffic continuity not verified | Demo not attempted or fails |
| Monitoring Dashboard Demo | 25 | Shows Grafana live with real metrics; triggers a load test to produce elevated CPU; alert fires in Prometheus/Grafana in real time | Dashboard shown; alert rule not triggered live | Dashboard not functional or not demonstrated |
| Cloud IAM Demo | 20 | Shows a least-privilege IAM policy; demonstrates an allowed action succeeds and a denied action returns an access-denied error | IAM policy shown; allowed/denied test not both demonstrated | Not demonstrated |
| Q&A | 15 | Answers are accurate, specific, and confident; demonstrates deep understanding of design decisions | Most questions answered adequately | Answers vague or incorrect |
