---
title: "I1 - HA Service Platform with Backup and DR"
parent: IT Project Options
grand_parent: Final Project (IT Track)
nav_order: 1
---

# I1 - HA Service Platform with Backup and Disaster Recovery
{: .no_toc }

Build a service that survives failures, and prove how fast you can recover from them.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Valley Medical Group's patient scheduling portal cannot go down for long, and it cannot lose data. You build the platform under it: a load-balanced front end, redundant application servers, a replicated database, and encrypted backups, then run a failure exercise ("game day") and **measure** recovery time (RTO) and data loss (RPO) against targets you set in an SLA. The demo is simple and dramatic: you break things on purpose and the service keeps going or comes back.

## What You Build

| Component | Description |
|---|---|
| Front end | HAProxy with keepalived (VRRP) providing a virtual IP and automatic failover; may be co-located on the app nodes to save resources |
| App tier | Two application servers running a small web application that reads and writes to the database |
| Database | PostgreSQL (or MariaDB) with a primary and a replica, replication lag monitored, and a documented promotion procedure |
| Backups | Automated, encrypted, off-host backups (restic, borg, or Proxmox Backup Server) with retention rules and a tested restore |
| Health checks | Monitoring or health checks for every tier, with alerts for failure |
| SLA | Written availability, RTO, and RPO targets, and measurements against them |

Plan for five to six small VMs or LXCs. Confirm resources with the instructor.

## Proposal Checklist

Your proposal must include:

- Your topology (nodes, IPs, VIP) and which components share a node
- Database technology, replication method, and your promotion plan
- Backup tool, schedule, retention, encryption, and where backups are stored
- Your target RTO and RPO and how you will measure them
- Your game-day failure scenarios (at least three)

## Pair Extension (pairs only: complete one)

- Add point-in-time recovery for the database (continuous log archiving) and demonstrate restoring to a chosen minute
- Add a second location for backups (a different host or site) with a documented 3-2-1 backup strategy

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; build nodes and app |
| 10 | HA front end and database replication |
| 11 | Backups and restore tests |
| 12 | Measure RTO/RPO; health checks |
| 14 | Game day, runbook, documentation |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - I1 HA Service Platform with Backup and DR`. Everything lives in `final-project-it/` in your portfolio repo.

1. **Service design and SLA.** What the service is, who depends on it, availability, RTO, and RPO targets with justification, and the design choices that meet them.
2. **DR runbook.** Failure scenarios, detection, decision points, recovery steps, and verification steps, written for an on-call engineer who did not build the system.
3. **Game-day report.** Each exercised failure: what was broken, what happened, timings, whether targets were met, and what you changed afterward.
4. **Architecture diagram.** Nodes, IPs, VIP, replication and backup flows, and failure domains.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Service design and SLA | 20 | Targets justified and consistent with the design | Targets stated, not justified |
| DR runbook | 25 | Usable by someone else; covers every scenario you tested | Generic or incomplete |
| Game-day report | 25 | Real timings, honest analysis, and follow-up changes | Timings missing or no analysis |
| Architecture diagram | 15 | Flows and failure domains clearly labeled | Missing flows |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Front-end failure.** With traffic flowing, stop the active load balancer and show the VIP move and requests continue.
2. **Database failure.** Stop the primary database, promote the replica, and show the application recover. State the downtime.
3. **Restore.** Delete or corrupt data, restore from backup, and report how long it took against your RTO and how much data was lost against your RPO.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Design and SLA targets explained clearly without reading a script | Basics covered; some elements unclear |
| Front-end failure demo | 25 | Failover shown with continued service | Failover shown; continuity unclear |
| Database failure demo | 25 | Promotion and application recovery shown, with downtime stated | Promotion shown; app recovery unclear |
| Restore demo | 20 | Restore shown with RTO/RPO reported | Restore shown; no timing |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to IT Project Options]({% link final-project-it/projects/index.md %})
