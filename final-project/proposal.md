---
title: Project Proposal
parent: Final Project
nav_order: 1
---

# Final Project Proposal
{: .no_toc }

**Due:** Tuesday, Oct 20 (end of Week 8) &nbsp;·&nbsp; **Weight:** Required (pass/fail)
{: .fs-5 }

---

## Overview

The proposal locks in your infrastructure scope before you begin building. It is graded pass/fail — all five sections must be present and specific. A brief instructor feedback session in Week 8 lab will confirm your scope before you invest significant time in implementation.

---

## Requirements

Your proposal must address all five of the following sections. Vague or missing sections will result in a failing grade and you will need to resubmit before proceeding.

### 1. Infrastructure Scope

List all three servers with the following details for each:

| Field | Required |
|---|---|
| Hostname | Unique name for each server (e.g., `linux-id-01`) |
| OS | Full OS name and version (e.g., Ubuntu 22.04 LTS) |
| IP Range | Planned subnet or IP address |
| Role | What the server does (e.g., Linux Identity Server, Windows App Server, Ubuntu Web/Docker Host) |

### 2. Compliance Frameworks

For each server, specify which compliance targets you will pursue:

- Which **CIS Benchmark** and level (Level 1 or Level 2)
- Which **DISA STIG** applies (e.g., RHEL 9 STIG, Windows Server 2022 STIG)

Listing frameworks without mapping them to specific servers will not receive credit.

### 3. Tools

List the automation and scanning tools you plan to use and briefly justify each choice. At minimum address:

- Configuration management tool (Ansible, Terraform, or both)
- Compliance scanning tool (CIS-CAT, OpenSCAP, STIG Viewer)
- Logging stack (Graylog, Elastic Stack)

### 4. Week-by-Week Milestones

Provide a personal timeline from Week 8 through Week 15 with specific deliverables for each week. Generic entries such as "work on project" will not receive credit. Your timeline must account for both progress check due dates.

### 5. Division of Responsibilities

This is an individual assignment. Confirm that you are working independently. If you have received instructor approval to work in a pair, specify which servers and deliverables each person owns.

---

## Submission

Submit your proposal on your portfolio site using the GitHub PR workflow. Open a PR titled `Project Proposal` and submit the PR link on Learning Suite by Tuesday.

{: .important }
The proposal is required. You may not receive credit for Progress Check 1 if a passing proposal is not on file.

---

## Grading

| Criterion | Pass | Fail |
|---|---|---|
| Infrastructure Scope | All 3 servers listed with hostname, OS, IP range, and role | Missing servers or vague descriptions |
| Compliance Frameworks | CIS Benchmark level and applicable STIGs specified per server | Frameworks listed without server-level mapping |
| Tools | Automation tools listed and justified | Tools omitted or listed without context |
| Week-by-Week Milestones | Personal timeline from Week 8 to Week 15 with specific deliverables | Generic or missing milestones |
| Completeness | All 5 sections present; submitted on time | Any section missing or submitted late |

[Back to Final Project Overview]({% link final-project/index.md %})
