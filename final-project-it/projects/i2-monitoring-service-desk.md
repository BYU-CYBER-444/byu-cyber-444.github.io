---
title: "I2 - Monitoring and Service Desk"
parent: IT Project Options
grand_parent: Final Project (IT Track)
nav_order: 2
---

# I2 - Monitoring and Service Desk
{: .no_toc }

Alerts that turn into tickets, tickets that follow a process, and incidents that end in lessons learned.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Monitoring without a process is noise, and a process without monitoring is guesswork. You build the operations loop an IT team actually lives in: a monitoring stack watches a small fleet, an alert automatically opens a correctly prioritized ticket in a service desk, a technician works it using dashboards, the ticket closes against an SLA clock, and a post-incident review feeds a known-error database. You document the service catalog and priority model that make it consistent.

## What You Build

| Component | Description |
|---|---|
| Monitored fleet | Three small hosts (for example a web server, a database, and a file server) running node_exporter and a simple service worth monitoring |
| Monitoring | Prometheus, Alertmanager, and Grafana; blackbox checks for service availability; at least 3 dashboards and 5 alert rules |
| Service desk | A ticketing system (GLPI, osTicket, Zammad, or similar; choose a light one) with categories, a priority matrix, SLA timers, and an escalation path |
| Integration | Alertmanager webhook that creates tickets with severity-to-priority mapping, de-duplication, and an automatic resolve or note when the alert clears |
| SLO view | A dashboard showing availability and response/resolution against your stated targets |
| ITSM records | Service catalog, simulated incidents, RFC for the monitoring rollout, PIR, and a known-error database entry |

## Proposal Checklist

Your proposal must include:

- Your fleet, the services you will monitor, and your service desk choice with a reason
- Your priority matrix (impact x urgency) and SLA targets by priority
- Five alert rules, and for each: what it detects and the priority of the ticket it should create
- Three incident scenarios you will stage

## Pair Extension (pairs only: complete one)

- Add an on-call rotation and escalation: unacknowledged high-priority tickets escalate automatically after a set time
- Add a self-service knowledge base fed by your known-error database, with a ticket-deflection measurement

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; fleet and service desk install |
| 10 | Monitoring stack and service desk configured |
| 11 | Alert-to-ticket integration |
| 12 | Staged incidents, SLO dashboard |
| 14 | PIR, KEDB, ITSM documents, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - I2 Monitoring and Service Desk`. Everything lives in `final-project-it/` in your portfolio repo.

1. **ITSM process document.** Service catalog, priority matrix, SLA targets, escalation path, and how alerts map to tickets.
2. **Post-incident review and KEDB.** A PIR for your most significant staged incident with timeline, a 5 Whys analysis reaching a systemic root cause, quantified impact, what went well, specific improvements, action items, and a known-error database entry written for a help-desk analyst.
3. **RFC.** A change record for rolling out the monitoring and service desk, with all nine standard fields (title, type, description, justification, risk and rollback trigger, rollback plan, implementation steps, approvals, post-implementation test).
4. **Architecture diagram.** Hosts, monitoring flow, alert path to the ticket system, and users.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| ITSM process document | 25 | Complete, consistent with the configured system | Present but generic |
| PIR and KEDB | 25 | Systemic root cause; specific improvements; usable KEDB entry | Root cause at symptom level |
| RFC | 15 | All 9 fields, ready for a change board | Missing fields |
| Architecture diagram | 15 | Alert path and components clearly labeled | Missing the alert path |
| Automation and README | 10 | Rebuilds from checkout | Runs with manual fixes |
| Lessons learned | 10 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Alert to ticket.** Break something on a monitored host and show the alert fire and a correctly prioritized ticket appear automatically.
2. **Work the ticket.** Diagnose using your dashboards, fix the problem, show the alert clear and the ticket resolve, with its timeline and SLA status.
3. **Report.** Show your SLO dashboard and walk through the 5 Whys from your PIR.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Operations loop and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Alert-to-ticket demo | 30 | Failure produces the right ticket automatically | Ticket appears; priority wrong or manual step needed |
| Work-the-ticket demo | 20 | Diagnosis from dashboards, resolution, and SLA shown | Resolved; process unclear |
| Report demo | 20 | SLO dashboard and PIR reasoning explained clearly | Dashboard or PIR only |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to IT Project Options]({% link final-project-it/projects/index.md %})
