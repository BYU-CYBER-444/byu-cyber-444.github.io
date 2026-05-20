---
title: Final Project
nav_order: 6
has_children: true
permalink: /final-project/
---

# Final Project - Hardened Infrastructure Build
{: .no_toc }

10% of course grade · Weeks 8–15 · Individual Assignment
{: .fs-5 .fw-300 }

---

## Overview

The Final Project is a multi-week applied project in which students design, deploy, harden, document,
and defend a compliant multi-server infrastructure. The project spans Weeks 8–15 and accounts for 10% of
the course grade.

The infrastructure must meet **CIS Benchmark Level 2** AND applicable **DISA STIG requirements** across a
minimum of 3 servers.

---

## Required Infrastructure

| Server | Role | OS | Compliance Target |
|---|---|---|---|
| Server 1 | Linux Identity Server | Ubuntu 22.04 LTS | CIS Ubuntu L2 + DISA STIG |
| Server 2 | Windows App Server | Windows Server 2022 | CIS Windows Server 2022 L2 + DISA Windows STIG |
| Server 3 | Ubuntu Web/Docker Host | Ubuntu 22.04 LTS | CIS Ubuntu L2 + CIS Docker Benchmark |

---

## Milestones

| Milestone | Weight |
|---|---|---|
| [Project Proposal]({% link final-project/proposal.md %}) | Required |
| [Progress Check 1 - Automation]({% link final-project/progress-checks.md %}) | 2.5% |
| [Progress Check 2 - Compliance Scans]({% link final-project/progress-checks.md %}#progress-check-2) | 2.5% |
| [Final Documentation Package]({% link final-project/final-deliverables.md %}) | 2.5% |
| [Live Presentation & Demo]({% link final-project/final-deliverables.md %}#presentation) | 2.5% |

---

## Grading Rubrics

---

### Project Proposal — Pass/Fail (Required)

The proposal is graded on completeness. All five sections must be present and specific to receive a passing grade. A brief instructor feedback session in Week 9 lab will confirm scope.

| Criterion | Pass | Fail |
|---|---|---|
| Infrastructure Scope | All 3 servers listed with hostname, OS, IP range, and role | Missing servers or vague descriptions |
| Compliance Frameworks | CIS Benchmark level and applicable STIGs specified per server | Frameworks listed without server-level mapping |
| Tools | Automation tools (Ansible, Terraform, etc.) listed and justified | Tools omitted or listed without context |
| Week-by-Week Milestones | Personal timeline from Week 8 to Week 15 with specific deliverables | Generic or missing milestones |
| Completeness | All 5 sections present; submitted on time | Any section missing or submitted late |

---

### Progress Check 1 — Automation (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Control Count | 30 | 20+ hardening controls implemented and verified | 15–19 controls | Fewer than 15 controls |
| Code Quality | 25 | Fully idempotent (0 changed on second run), handlers used correctly, tasks well-named | Mostly idempotent; minor issues | Not idempotent or significant structural problems |
| Variable Externalization | 20 | All site-specific values in a separate `vars/` or `.tfvars` file; no hardcoded values | Most values externalized; a few hardcoded | Variables mixed into task files |
| README | 15 | Covers purpose, prerequisites, all variables described, and exact run instructions | Most sections present; minor gaps | Missing key sections |
| Baseline Scan Score | 10 | CIS-CAT or STIG scan report included; score reported with brief analysis | Report included; no analysis | Report missing |

---

### Progress Check 2 — Compliance Scans (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Coverage | 25 | All 3 servers scanned with both CIS-CAT and STIG/OpenSCAP reports | All 3 servers; one scan type per server | Fewer than 3 servers scanned |
| Compliance Scores | 30 | All servers ≥85% compliance | All servers ≥70% | At least one server below 70% |
| Report Format | 15 | CIS-CAT HTML + OpenSCAP `.xml` or STIG Viewer `.ckl` for each server; all readable | Correct format for most servers | Incorrect formats or missing files |
| Progress Narrative | 20 | Clearly explains unremediated controls, root cause, and remediation plan for each | Narrative present but surface-level | Narrative missing or fewer than one paragraph |
| Trend vs. Baseline | 10 | Scores compared to Progress Check 1 baseline with measurable improvement shown | Some comparison to prior state | No comparison to prior scan |

---

### Final Documentation Package (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| System Security Plan (SSP) | 30 | All required sections complete (system ID, FIPS 199 categorization, control mappings, POA&M); professional quality | Most sections present; minor gaps | Significant sections missing or placeholder content |
| Architecture Diagram | 15 | Network topology shows all 3 servers with IPs, roles, firewall zones, and data flows; clean and labeled | Diagram present; missing some labels or zones | Diagram too vague to be useful |
| Final Compliance Scan Reports | 25 | CIS-CAT HTML + STIG/OpenSCAP results for all 3 servers; all servers ≥85% compliance | All servers represented; one below target | Missing servers or reports in wrong format |
| Automation Package | 20 | Complete playbook or Terraform config committed; README accurate; runs cleanly from checkout | Playbook present; README incomplete or minor run errors | Automation incomplete or not runnable |
| Lessons Learned | 10 | Specific, reflective; identifies what worked, what failed, and what would be done differently | Present but generic | Missing or fewer than one paragraph |

---

### Live Presentation and Demo (100 pts)

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Overview | 15 | Clearly explains all 3 servers, compliance targets, and design decisions in 2 minutes | Covers the basics; some elements unclear | Vague or skips key components |
| CIS-CAT Live Demo | 20 | Live scan runs successfully and shows ≥85% compliance score on at least 1 server | Demo runs; score below target or minor issues | Demo fails or is replaced by screenshots only |
| Ansible Idempotency Demo | 20 | Playbook runs live (or recorded); second run shows 0 changed | Runs successfully; idempotency not clearly demonstrated | Demo not attempted or fails to run |
| Logging Dashboard Demo | 20 | Graylog or Elastic dashboard shown live capturing a real security event in real time | Dashboard shown; event capture unclear | Dashboard not functional or not demonstrated |
| IAM Demo | 15 | SSH CA certificate login or MFA flow demonstrated end-to-end | Demonstrated but with issues or workarounds | Not demonstrated |
| Q&A | 10 | Answers are accurate, specific, and confident; demonstrates deep understanding | Most questions answered adequately | Answers vague or incorrect |