---
title: Project Proposal
parent: Final Project (IT Track)
nav_order: 1
---

# IT Track Final Project Proposal
{: .no_toc }

---

## Overview

The proposal locks in your project scope before you begin building. It is graded pass/fail - all five sections must be present and specific. An instructor feedback session in Week 9 lab will confirm your scope before you invest significant time in implementation.

Submit your proposal on your portfolio site using the GitHub PR workflow. Open a PR titled `IT Final Project Proposal` and submit the PR link on Learning Suite by the end of Week 8.

{: .important }
The proposal is required. You may not receive credit for Progress Check 1 if a passing proposal is not on file.

---

## Requirements

All five sections must be present. Vague or missing sections will result in a failing grade and require resubmission before you can proceed to Progress Check 1.

### 1. Infrastructure Scope

Describe your three infrastructure pillars with enough detail to evaluate feasibility:

**Cloud Environment**

| Field | Required |
|---|---|
| Cloud Provider | AWS or Azure (state which) |
| Region | Which AWS region or Azure region you will use |
| VPC/VNet CIDR | Planned address space (e.g., `10.0.0.0/16`) |
| Subnet Plan | At least one public and one private subnet with CIDRs |
| Instances | At least 2 compute instances - state OS, instance type, and role for each |

**High-Availability Cluster**

| Field | Required |
|---|---|
| HA Technology | HAProxy + keepalived (VRRP) |
| VIP Address | Planned virtual IP address for the cluster |
| App Server Hostnames | Names and planned IPs for both backend nodes |
| Test Plan | Brief statement of how you will verify failover |

**Monitoring Stack**

| Field | Required |
|---|---|
| Technology | Prometheus + Grafana + node_exporter |
| Prometheus Host | Which machine will run the Prometheus server |
| Targets | Which machines will run node_exporter and be scraped |
| Planned Dashboards | At least 3 dashboard panels you plan to build |

### 2. ITSM Scope

Describe the ITSM documentation you will produce:

- **RFC:** State the infrastructure change your RFC will document (e.g., "RFC for deploying the HA cluster into production"). List the approval workflow you will simulate (submitter → manager → CAB).
- **Incident Scenario:** Describe the outage scenario you will use for your incident ticket and PIR. Be specific - what service fails, how is it detected, who responds?
- **PIR:** Confirm that your PIR will include a complete 5 Whys analysis reaching a systemic root cause (not just the immediate symptom).
- **KEDB Entry:** State what your Known Error Database entry will document.

### 3. Policy Scope

Identify the organization your policies will be written for and confirm coverage:

- **Organization:** Use Valley Medical Group (300 employees, HIPAA-regulated environment) or propose an alternate organization with instructor approval.
- **AUP:** List at least 5 of the prohibited activities you plan to include and confirm the document will include an AI tool usage section.
- **Data Classification Policy:** Name the 4 classification tiers you will use and give one healthcare-specific example for each.
- **BYOD Policy:** State your MDM solution choice and your decision on whether staff may access PHI on personal devices. Justify the decision.

### 4. AI Infrastructure Proposal Scope

Provide a preliminary outline of your on-premises AI proposal:

- **Use Case:** Which 3 clinical or operational use cases will the AI assistant support?
- **Model Candidate:** Which open-weight model are you proposing (LLaMA 3, Mistral, Phi-3, etc.)? What is its context window and RAM requirement?
- **Key Hardware Decision:** CPU-only or GPU? State your reasoning based on the model size and expected request volume.
- **HIPAA Consideration:** Identify at least one HIPAA technical safeguard requirement your proposal must address.

### 5. Week-by-Week Milestones

Provide a personal timeline from Week 8 through Week 15. Each week must list specific deliverables - not generic entries like "work on project." Your timeline must align with both progress check due dates (end of Week 10 and end of Week 12).

| Week | Planned Deliverables |
|---|---|
| Week 8 | Proposal submitted |
| Week 9 | |
| Week 10 | Progress Check 1 - Infrastructure Build |
| Week 11 | |
| Week 12 | Progress Check 2 - Monitoring & Documentation |
| Week 13 | |
| Week 14 | |
| Week 15 | Final deliverables + presentation |

Fill in Weeks 9, 11, 13, and 14 with your specific plans.

---

## Submission

Open a PR titled `IT Final Project Proposal` and submit the PR link on Learning Suite by the end of Week 8.

---

## Grading

| Criterion | Pass | Fail |
|---|---|---|
| Infrastructure Scope | All three pillars described with technology choices and IP/subnet plan | Any pillar missing or described only generically |
| ITSM Scope | RFC scenario, incident scenario, and KEDB entry all described | ITSM deliverables not described or incident scenario too vague |
| Policy Scope | Three policies identified with org context and key decisions stated | Policy documents not specified or org not named |
| AI Proposal Scope | Use case, model candidate, and hardware decision all addressed | AI proposal not described or missing hardware decision |
| Week-by-Week Milestones | Personal timeline with specific deliverables for all 8 weeks | Generic entries or milestone weeks left blank |
| Completeness | All five sections present; submitted on time | Any section missing or submitted late |

[Back to IT Track Final Project Overview]({% link final-project-it/index.md %})
