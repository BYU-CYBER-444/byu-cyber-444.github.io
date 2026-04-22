---
title: Final Project
nav_order: 6
has_children: true
permalink: /final-project/
---

# Final Project — Hardened Infrastructure Build
{: .no_toc }

25% of course grade · Weeks 8–15 · Individual or teams of 2
{: .fs-5 .fw-300 }

---

## Overview

The Final Project is a multi-week applied project in which students design, deploy, harden, document,
and defend a compliant multi-server infrastructure. The project spans Weeks 8–15 and accounts for 25% of
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

| Milestone | Due | Weight |
|---|---|---|
| [Project Proposal]({% link final-project/proposal.md %}) | End of Week 8 | 5% |
| [Progress Check 1 — Automation]({% link final-project/progress-checks.md %}) | Week 10 | 5% |
| [Progress Check 2 — Compliance Scans]({% link final-project/progress-checks.md %}#progress-check-2) | Week 12 | 5% |
| [Final Documentation Package]({% link final-project/final-deliverables.md %}) | Week 15 | 5% |
| [Live Presentation & Demo]({% link final-project/final-deliverables.md %}#presentation) | Week 15 | 5% |

---

## Grading Rubric

| Criterion | Weight | Excellent (A) | Proficient (B) | Developing (C) |
|---|---|---|---|---|
| Compliance Score (CIS-CAT + STIG) | 20% | ≥90% | 75–89% | 60–74% |
| Automation (Ansible/Terraform) | 20% | 15+ controls, idempotent, README | 10–14 controls | 5–9 controls |
| Documentation (SSP, diagrams) | 20% | Complete, professional | Most sections present | Partial |
| Logging & Monitoring | 15% | Central logging + 3-panel dashboard | Logging + basic dashboard | Logging only |
| IAM Implementation | 15% | SSH CA + MFA + LDAP/AD all working | 2 of 3 functional | 1 of 3 functional |
| Presentation Quality | 10% | Clear, demo successful, Q&A confident | Good delivery, minor demo issues | Basic presentation |
