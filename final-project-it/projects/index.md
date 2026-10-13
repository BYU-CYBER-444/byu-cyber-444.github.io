---
title: IT Project Options
parent: Final Project (IT Track)
has_children: true
nav_order: 4
---

# IT Track - Project Options
{: .no_toc }

Pick **one** of the five options below. Each option has its own scope, deliverables, and grading rubrics, but all five share the same schedule, submission process, and point structure (see [Final Project (IT Track)]({% link final-project-it/index.md %})).

Most options use **Valley Medical Group**, the 300-employee, HIPAA-regulated organization from the course, as the organization you are building for.

---

## The Options

| # | Project | You build | Best if you enjoyed |
|---|---|---|---|
| I1 | [HA Service Platform with Backup and Disaster Recovery]({% link final-project-it/projects/i1-ha-platform-backup-dr.md %}) | A load-balanced application with a replicated database, encrypted backups, and measured recovery times | Labs 2, 7, 12 |
| I2 | [Monitoring and Service Desk]({% link final-project-it/projects/i2-monitoring-service-desk.md %}) | A monitoring stack wired to a ticketing system so alerts become tickets, with SLAs, incident drills, and post-incident reviews | Lab 12, IT HW 12 and 14 |
| I3 | [On-Prem AI Inference Service]({% link final-project-it/projects/i3-onprem-ai-inference.md %}) | A secured, authenticated, observable local AI inference service with benchmarks, data-handling policy, and a cost comparison | Lab 14, IT HW 12 |
| I4 | [Identity and Endpoint Lifecycle]({% link final-project-it/projects/i4-identity-lifecycle.md %}) | Active Directory, single sign-on, and automated onboarding, role-change, and offboarding with access reviews | Labs 3-4, 6 |
| I5 | [Self-Service Provisioning and Golden Images]({% link final-project-it/projects/i5-self-service-provisioning.md %}) | A service catalog that provisions standardized, baseline-hardened machines on request, with inventory and change records | Labs 10-11 |

---

## Workload and Risk at a Glance

All five are sized to be completed in Weeks 9-15 by two students. They differ in where the effort and the risk sit.

| # | Where most of the effort goes | Main risk | Lab resources to confirm in Week 9 |
|---|---|---|---|
| I1 | Getting replication and failover correct | Failover edge cases (split brain, stale replicas) | Five to six small VMs or LXCs |
| I2 | Integration between alerting and the ticket system | Service desk software varies in weight; choose a light one | Small VMs or LXCs |
| I3 | Securing and measuring the service | Model performance depends on available CPU/GPU | Whether a GPU is available; otherwise a small CPU-only model |
| I4 | Windows and identity configuration | Windows VMs are RAM-heavy | One or two Windows Server VMs |
| I5 | Provisioning pipeline and guardrails | Nested virtualization is slow; use LXC or small VMs | Your own nested Proxmox cluster |

{: .important }
Check resource needs with the instructor in Week 9 lab before you commit. Your lab environment has a fixed RAM budget, and an option that does not fit will cost you more time than any other mistake.

---

## Rules That Apply to Every Option

- **Proxmox only.** Every option is designed to be completed entirely on your own Proxmox environment. You do not need a cloud account for any of them.
- **Isolation.** Everything you build and test stays inside your own lab network. Do not scan, attack, or probe class infrastructure or other students' environments.
- **Reproducibility.** Your configuration must rebuild the environment from your portfolio repo using only the README. Manual one-off changes that are not captured in code or documented steps lose points on every rubric.
- **Evidence.** Claims need output: command results, logs, dashboards, screenshots with timestamps. "It works" without evidence earns no credit.
- **Changing options.** Switching options after your proposal passes requires instructor approval and a new proposal PDF.
