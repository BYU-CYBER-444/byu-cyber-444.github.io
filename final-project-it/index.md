---
title: Final Project (IT Track)
nav_order: 7
has_children: true
permalink: /final-project-it/
---

# Final Project - IT Track
{: .no_toc }

Choose your own capstone · 10% of course grade · Weeks 9-15 · Individual or pair
{: .fs-5 .fw-300 }

{: .note }
This is the **IT Track** final project. Cyber Track students complete the [Cyber Track Final Project]({% link final-project-cyber/index.md %}) instead. As the syllabus explains, you may pick either version regardless of which weekly track you followed.

---

## Overview

The final project is a multi-week capstone in which you design, build, document, and defend a piece of IT infrastructure the way an operations team would deliver it to leadership, and it serves as the final exam for the class. Instead of one assigned project, you **choose one of five options** and work on it from Week 9 through the presentations in Week 15.

All five options share the same schedule, submission process, and point structure. They differ in the system you build. Most use **Valley Medical Group**, the 300-employee, HIPAA-regulated organization from the course, as the organization you are building for.

---

## How It Works

1. **Read the options.** Browse the [IT Project Options]({% link final-project-it/projects/index.md %}) and pick one.
2. **Submit your proposal** (Week 9) as a PDF. It names your option and fills in that option's proposal checklist. See [Project Proposal]({% link final-project-it/proposal.md %}).
3. **Submit the final package** and a **recorded presentation and demo** by December 10. See [Final Deliverables]({% link final-project-it/final-deliverables.md %}).

---

## Teams and Help

- You may work **alone or in a pair**. Pairs must say so in the proposal and list who owns which pieces. The project scope and grading are the same regardless of team size.
- This is the final exam. You may not receive help on the project itself from the instructor, teaching assistants, classmates, or anyone outside your group. You may ask the instructor or TAs clarifying questions about grading or scope.
- Late work is not accepted (see the syllabus).

---

## Schedule and Grading

| Milestone | Due | Weight |
|---|---|---|
| [Project Proposal]({% link final-project-it/proposal.md %}) | End of Week 9 | Pass/fail, required |
| [Final Documentation Package]({% link final-project-it/final-deliverables.md %}) | Dec 10, 11:59 PM | 5% |
| [Recorded Presentation and Demo]({% link final-project-it/final-deliverables.md %}#presentation) | Dec 10, 11:59 PM | 5% |

Week 13 is Thanksgiving break and has no class or deliverable. There are no in-class presentations: the presentation is a recording you submit as a link in Learning Suite. There are no graded checkpoints between the proposal and the final package, so use the suggested timeline on your option's page to pace yourself. The documentation package and the recorded presentation are each scored out of 100 points using the rubric on your option's page. The proposal is required: you may not receive credit for the final project without a passing proposal on file.

---

## Choose an Option

| # | Project | Summary |
|---|---|---|
| I1 | [HA Service Platform with Backup and DR]({% link final-project-it/projects/i1-ha-platform-backup-dr.md %}) | Load-balanced app, replicated database, encrypted backups, and measured recovery times |
| I2 | [Monitoring and Service Desk]({% link final-project-it/projects/i2-monitoring-service-desk.md %}) | Alerts that become tickets, SLAs, incident drills, and post-incident reviews |
| I3 | [On-Prem AI Inference Service]({% link final-project-it/projects/i3-onprem-ai-inference.md %}) | A secured, observable local AI service with benchmarks, policy, and a cost comparison |
| I4 | [Identity and Endpoint Lifecycle]({% link final-project-it/projects/i4-identity-lifecycle.md %}) | Active Directory, SSO, and automated onboarding, role-change, and offboarding |
| I5 | [Self-Service Provisioning and Golden Images]({% link final-project-it/projects/i5-self-service-provisioning.md %}) | A service catalog that provisions standard machines with guardrails, inventory, and change records |

See the [options overview]({% link final-project-it/projects/index.md %}) for a comparison of workload, risk, and lab resources.

---

## Standards for Every Option

- **Isolation.** Build and test only inside your own lab network. Every option is designed to run entirely on your own Proxmox environment; no cloud account is needed.
- **Reproducibility.** Everything rebuilds from your portfolio repo using only the README.
- **Evidence.** Every claim is backed by output, logs, or screenshots.
- **Submission.** The proposal is a PDF uploaded to Learning Suite. The final package is submitted through your GitHub portfolio with the same pull-request workflow as labs; paste the PR link into Learning Suite. The presentation is a recording whose link you also submit in Learning Suite.
