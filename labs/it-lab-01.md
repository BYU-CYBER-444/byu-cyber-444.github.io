---
title: "IT LAB 1 - ITSM Ticketing Orientation"
parent: Labs
nav_order: 101
---

# IT LAB 1 - ITSM Ticketing Orientation
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 1 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Navigate a production-grade ITSM platform and configure a complete service catalog
- Model ITIL 4 incident, problem, and change record types with correct priority and categorization
- Configure SLA timers, escalation policies, and breach notifications
- Produce and interpret ITSM reports: open ticket aging, SLA compliance rate, and MTTR by category
- Document the full lifecycle of a simulated P2 incident from detection to closure including PIR

---

## Tools Required

- Jira Service Management (free tier) or instructor-provided ITSM instance
- Web browser
- Text editor for documentation deliverables

---

## Background

ITIL 4 organizes IT work into four generic work items: **incidents** (unplanned interruptions), **problems** (causes of recurring incidents), **service requests** (pre-approved changes), and **changes** (controlled modifications). Each has its own SLA targets, workflow, and documentation requirements.

In production environments, SLA breach rates and MTTR are KPIs reported to senior leadership. A miscategorized ticket-such as logging a P1 outage as a P3 request-delays response and distorts metrics. Your job this lab is to configure the platform correctly and demonstrate accurate ticket handling.

---

## Procedure

### Part 1 - Platform Configuration and Service Catalog (45 min)

1. Log in to the ITSM instance. Navigate to **Project Settings → Components** and create the following components:

   | Component | Lead | Description |
   |-----------|------|-------------|
   | Network Infrastructure | (your name) | Switches, routers, firewalls |
   | Server & Compute | (your name) | Physical and virtual servers |
   | End User Computing | (your name) | Laptops, desktops, peripherals |
   | Application Support | (your name) | Business applications, ERPs |
   | Identity & Access | (your name) | AD, SSO, MFA, access provisioning |

2. Navigate to **Project Settings → Issue Types**. Verify these types exist; add any missing:
   - Incident, Problem, Service Request, Change Request

3. Configure **Priority Schemes** to match ITIL 4 impact/urgency matrix:

   | Priority | Impact | Urgency | Response SLA | Resolution SLA |
   |----------|--------|---------|--------------|----------------|
   | P1 - Critical | Enterprise-wide | Immediate | 15 min | 4 hr |
   | P2 - High | Department-wide | High | 30 min | 8 hr |
   | P3 - Medium | Single team | Medium | 2 hr | 24 hr |
   | P4 - Low | Single user | Low | 8 hr | 72 hr |

4. Navigate to **Project Settings → SLAs**. Create two SLA metrics:
   - **Time to First Response**: starts on ticket creation, paused when status = Waiting for Customer, breached per priority table above
   - **Time to Resolution**: starts on ticket creation, paused when status = Waiting for Customer or Pending Change, breached per priority table above

5. Create a **Notification Scheme**: when an SLA is within 30 minutes of breach, notify the assignee and their manager (use your email twice for this lab).

6. Build a **Service Catalog** with at least three request types:
   - New Employee Onboarding (Identity & Access component, P3)
   - VPN Access Request (Network Infrastructure, P4)
   - Password Reset (Identity & Access, P4, with auto-assign rule)

   Each request type must include a custom intake form capturing: requester name, department, justification, and desired completion date.

---

### Part 2 - Incident Management Simulation (45 min)

You will work through three simulated incidents. For each, create the ticket, manage it through its lifecycle, and close it with a resolution note.

**Scenario A - P1: Database cluster failover failure**

> *Alert received at 09:14: The primary PostgreSQL node in the finance cluster is unreachable. The standby has not promoted automatically. Finance applications are completely down.*

1. Create an Incident ticket: Priority = P1, Component = Server & Compute, Affected Service = Finance ERP.
2. Add a comment within 15 minutes of "creation" simulating the first response: acknowledge receipt, state initial diagnosis steps (check replication slot lag, verify standby trigger file, test network path between nodes).
3. Transition ticket to **In Progress**. Add a work log entry every 15 minutes with progress notes (simulate by writing 3-4 dated entries).
4. Simulate resolution: standby promoted manually using `pg_ctl promote`. Add resolution note with root cause (replication slot lag exceeded max_wal_senders limit) and resolution steps.
5. Close ticket. Verify SLA compliance shows "Met" for Time to First Response.

**Scenario B - P2: Active Directory replication failure**

> *Monitoring alert: AD replication has been failing between DC01 and DC02 for 6 hours. USN rollback suspected. Users in the west wing cannot authenticate.*

1. Create Incident: Priority = P2, Component = Identity & Access.
2. Immediately create a linked **Problem** record for the underlying replication architecture issue.
3. Work through resolution simulation: run `repadmin /showrepl` to identify failed DCs, force replication with `repadmin /syncall /AdeP`, verify with `dcdiag /test:replications`.
4. Close Incident. Leave Problem open (mark as Under Investigation).

**Scenario C - P3: NFS mount failures on build servers**

> *Three build servers report intermittent NFS mount drops. CI pipeline failing. Affects Dev team only.*

1. Create Incident: Priority = P3, Component = Network Infrastructure.
2. Create a **Service Request** for a permanent NFS capacity upgrade (separate from the incident).
3. Resolve incident by simulating remount commands: `mount -t nfs -o remount,hard,intr storage01:/exports/builds /mnt/builds`.
4. Document workaround vs. permanent fix distinction in the resolution notes.

---

### Part 3 - Change and Problem Management (45 min)

**Problem Management:**

1. Open the Problem record you created in Scenario B. Add a Problem Investigation:
   - Root Cause: AD replication topology had a single point of failure - site link cost misconfigured, forcing all replication through a saturated WAN link
   - Known Error: Document in a Known Error Database (KEDB) entry
   - Workaround: Force replication manually during WAN saturation events
   - Permanent Fix: Reconfigure site link costs; add direct replication link between DC01 and DC02

2. Create a **Change Request** linked to this Problem to implement the permanent fix:
   - Change Type: Normal
   - CAB Review Required: Yes
   - Risk: Medium (domain-wide impact if misconfigured)
   - Implementation Plan: 5-step plan with rollback procedure
   - Change Window: Saturday 02:00-04:00

3. Approve the change (approve it yourself in the tool). Transition through: Submitted → CAB Review → Approved → Scheduled.

---

### Part 4 - Reporting and Metrics (30 min)

1. Navigate to your project's **Reports** section. Locate or generate:
   - **Ticket Volume by Type**: screenshot showing your 3 incidents + 1 service request + 1 change
   - **SLA Compliance Report**: confirm P1 incident shows "Met" for Time to First Response
   - **Component Workload Distribution**: pie or bar chart showing distribution across components

2. Export a report or take screenshots of all three reports.

3. Write a 200-word **ITSM Metrics Summary** as if you were briefing your manager:
   - Total tickets created this period
   - SLA compliance rate (%)
   - Which component has the most open work
   - One recommendation to improve the current process

---

### Part 5 - Post-Incident Review (15 min)

Complete a **Post-Incident Review (PIR)** for the P1 database incident. Use the following template in your submission:

```
PIR: Finance Database Cluster Failover Failure
Date of Incident: [date]
Duration: [start] - [end]
Severity: P1
Impact: Finance ERP unavailable for [X] users for [Y] minutes

Timeline:
  09:14 - Alert triggered
  09:17 - On-call engineer acknowledged
  09:22 - Root cause identified (replication slot lag)
  09:41 - Standby promoted manually
  09:43 - Finance ERP confirmed restored

Root Cause:
  pg_max_wal_senders was set to 3; replication slot count reached limit during
  peak backup window, preventing standby from receiving WAL segments.

Contributing Factors:
  - No alert on replication slot count approaching max
  - Automatic failover depends on replication being current

Action Items:
  1. Add Prometheus alert: pg_replication_slots_active > 2 → Owner: DBA team → Due: [+1 week]
  2. Increase max_wal_senders to 10 via Change Request → Owner: DBA team → Due: [+2 weeks]
  3. Quarterly DR drill including standby promotion → Owner: IT Ops → Due: [+1 quarter]

Lessons Learned:
  Automatic failover tooling (Patroni/repmgr) must be tested under backup load conditions.
```

---

## Deliverables

Submit a single PDF or Markdown document containing:

1. Screenshots of the configured SLA scheme showing all four priority tiers
2. Screenshots of all three incident tickets (closed, showing SLA status)
3. The linked Problem → Change Request chain for the AD replication issue
4. All three ITSM report screenshots
5. Your 200-word ITSM Metrics Summary
6. Completed PIR for the P1 database incident

---

## Grading

| Item | Points |
|------|--------|
| Service catalog with 3 request types and intake forms | 15 |
| Three incidents correctly prioritized, routed, and closed | 25 |
| Problem + linked Change Request with full workflow | 20 |
| Three reports with analysis summary | 20 |
| Complete PIR with action items | 20 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - SLA Modeling and Breach Cost Analysis
>
> ITIL 4 recommends that SLA targets be derived from business impact, not arbitrary time windows. Using the three incidents from this lab:
>
> 1. For each incident, calculate the **cost of downtime** assuming: Finance ERP = $5,000/hr, AD authentication = $2,000/hr, CI pipeline = $500/hr. Use actual or simulated durations.
>
> 2. Build a spreadsheet or table showing: Incident, Duration (min), Cost per Hour, Total Cost, SLA Met (Y/N), Cost if SLA Breached vs. Not.
>
> 3. Write a 300-word **SLA Business Justification Memo** addressed to the CIO explaining:
>    - How current SLA targets align with (or fail to reflect) actual business impact
>    - Specific recommended changes to P1 and P2 resolution SLAs based on your cost analysis
>    - Why the P1 resolution window of 4 hours may be too generous for a Finance ERP
>
> ### Extension B - ITSM Automation with Scripted Rules
>
> In production ITSM platforms, manual ticket routing wastes engineering time. Configure (or document in pseudo-code if your instance lacks scripting) the following automation rules:
>
> 1. **Auto-escalation rule**: If a P2 ticket has not been acknowledged within 20 minutes, automatically reassign to the on-call manager and send a Slack/email notification.
>
> 2. **Auto-close rule**: If a ticket in "Waiting for Customer" status has received no customer response for 5 business days, automatically close with a resolution of "Closed - No Customer Response" and trigger a satisfaction survey.
>
> 3. **Duplicate detection rule**: If a new Incident is created with the same Component and a summary matching an existing open Incident (fuzzy match threshold 80%), auto-link as a duplicate and add a comment.
>
> For each rule: provide the trigger condition, actions taken, exceptions (when it should NOT fire), and the estimated time savings per 100 tickets.
>
> Submit the spreadsheet/table, the SLA Justification Memo, and the three automation rule specifications as part of your lab submission.

[← Back to Labs]({{ site.baseurl }}/labs/)
