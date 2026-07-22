---
title: "IT LAB 14 - Major Incident Tabletop Exercise"
parent: Labs
nav_order: 114
---

# IT LAB 14 - Major Incident Tabletop Exercise
{: .no_toc }

**Duration:** ~3.75 hours &nbsp;·&nbsp; **Week:** Week 14 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Lead or participate in a structured tabletop exercise simulating a major IT incident
- Apply ITIL 4 Major Incident Management procedures including P1 bridge protocols
- Produce real-time incident documentation: timeline, stakeholder communications, and decision log
- Conduct a Post-Incident Review (PIR) with root cause analysis and corrective action plan
- Identify gaps in current IR processes and propose measurable improvements
- Implement and test a real backup/restore procedure for the database at the center of this incident

---

## Tools Required

- ITSM platform (Jira Service Management or instructor-provided)
- Word processor for documentation
- Communication tool (Teams/Slack simulation for exercise)
- A PostgreSQL instance (can be minimal/local) for Part 6

---

## Background

A Major Incident is any P1 outage with significant business impact. The Major Incident Management process differs from standard incident management in its urgency, escalation requirements, and communication intensity. The role of the Major Incident Manager (MIM) is to coordinate - not to solve the technical problem. The MIM manages the bridge call, tracks decisions, provides stakeholder updates, and documents the timeline.

This tabletop is modeled after real-world financial services IR exercises. You will receive scenario injects and must respond as if the incident is happening live.

---

## Scenario: Meridian Financial Services - Core Banking Platform Outage

**Background:** You are the on-call IT Operations engineer at Meridian Financial Services. It is 14:37 on a Thursday. Your monitoring alerts fire simultaneously across multiple services.

---

## Procedure

### Part 1 - Incident Declaration and Bridge Activation (20 min)

**INJECT 1 - 14:37:**
> Prometheus fires: Database cluster `db-prod-primary` has been unreachable for 3 minutes. HAProxy health checks show both application servers failing. The core banking application returns 503 errors. Customer-facing web portal and mobile app are both down. Estimated affected users: 12,000 active sessions.

**Your actions:**

1. Declare a P1 Major Incident. Create the incident ticket in your ITSM:
   - Priority: P1 - Critical
   - Title: Core Banking Platform Outage - All customer services unavailable
   - Affected services: Core Banking App, Customer Portal, Mobile App
   - Impact: ~12,000 active sessions disrupted; no transaction processing

2. Activate the Major Incident Bridge. Write the opening bridge call script:

```
MAJOR INCIDENT BRIDGE - P1 - MERIDIAN CORE BANKING OUTAGE
Time: 14:38 UTC
Incident: INC-2024-9847
Bridge Lead: [Your Name]

ATTENDEES REQUESTED ON CALL:
  - Database Team Lead
  - Application Team Lead
  - Network/Infrastructure Engineer
  - Security Analyst (for breach assessment)
  - IT Management Notification: VP of IT

SITUATION BRIEF:
  At 14:34 UTC, database cluster db-prod-primary became unreachable.
  All downstream services are returning errors. Customer portal and
  mobile app are fully unavailable. No planned maintenance was scheduled.

INITIAL ACTIONS UNDERWAY:
   Database team investigating cluster status
   Network team verifying connectivity to db-prod-primary
   Security team assessing for unauthorized activity

NEXT BRIDGE UPDATE: 14:50 UTC (12 minutes)
```

3. Create an **Incident War Room Log** - you will add entries throughout the exercise:

```
INCIDENT WAR ROOM LOG
INC-2024-9847 - P1 Core Banking Outage
[Column headers: Time | Source | Information | Action Taken | Decision Made]
14:37 | Prometheus | db-prod-primary unreachable 3+ min | Declared P1, opened bridge | -
14:38 | MIM | Bridge opened | Notified all teams | -
```

---

### Part 2 - Concurrent Investigation and Communication (40 min)

**INJECT 2 - 14:44:**
> Database team reports: `db-prod-primary` is online and responding to pings but PostgreSQL is not accepting connections. Error in logs: `FATAL: max_connections = 200 reached`. All 200 connection slots are consumed. Application servers keep retrying connections, making it worse. Root cause candidate: connection pool leak.

**INJECT 3 - 14:51:**
> Network engineer reports: no network anomalies. Security analyst reports: no indicators of compromise in CloudTrail or IDS logs. No unauthorized access. This appears to be a technical failure, not a security incident.

**Actions for this phase:**

1. Write a **Stakeholder Communication - Update 1** (sent at 14:50):

```
TO:      Executive Leadership, Customer Service Manager
FROM:    IT Operations - Major Incident Management
SUBJECT: [ONGOING] P1 Service Outage - Core Banking Platform - Update 1

TIME:       14:50 UTC (13 minutes into incident)
STATUS:     INVESTIGATING
IMPACT:     Core banking, customer portal, and mobile app unavailable
CUSTOMERS:  ~12,000 active sessions disrupted; no transactions processing

CURRENT STATUS:
  Root cause candidate identified: Database connection pool exhaustion.
  Security impact: NONE - no unauthorized access detected.
  Fix in progress: Database team working to clear blocked connections.

ESTIMATED RESOLUTION: 15:15 UTC (subject to change)

NEXT UPDATE: 15:00 UTC
```

2. Record the following decisions in your War Room Log (format them properly):
   - 14:46: Decision to flush the connection pool by restarting the PgBouncer connection pooler
   - 14:49: Decision NOT to failover to standby database (risk of data loss if WAL not current)
   - 14:52: Decision to throttle application server retry rate to 1/second to prevent thundering herd

3. At 15:02, PgBouncer is restarted and connection counts drop to 40/200. Application servers begin reconnecting. Services come online progressively.

**INJECT 4 - 15:06:**
> Core banking application is responding. Customer portal shows healthy. Mobile app team reports 95% of users can connect. Remaining 5% may need to clear app cache. Declare recovery.

Write a **Stakeholder Communication - Resolution Notice**:

```
TO:      Executive Leadership, Customer Service Manager, All-Staff
FROM:    IT Operations - Major Incident Management
SUBJECT: [RESOLVED] P1 Service Outage - Core Banking Platform

RESOLUTION TIME: 15:06 UTC
TOTAL OUTAGE DURATION: 32 minutes

SUMMARY:
  At 14:34 UTC, a connection pool exhaustion event caused the core banking
  database to become unreachable, disrupting all customer-facing services.
  At 15:06 UTC, services were fully restored.

CUSTOMER IMPACT:
  ~12,000 customer sessions were disrupted. No data loss occurred.
  Customers may need to log in again; mobile app users may need to
  clear their app cache.

ROOT CAUSE (PRELIMINARY):
  [To be confirmed in Post-Incident Review - PIR due within 48 hours]
  Preliminary: Connection pool leak in a recently deployed application update.

NEXT STEPS:
  Post-Incident Review scheduled: [Date + 2 days]
  Immediate action: Revert the application update deployed at 14:00 today.
```

---

### Part 3 - Post-Incident Review (60 min)

Complete a comprehensive PIR. This is the most important part of the incident process - it must be substantive enough to prevent recurrence.

```
POST-INCIDENT REVIEW
INC-2024-9847 - Core Banking Platform Outage

DATE OF INCIDENT:   [Date]
PIR PREPARED BY:    [Your Name]
PIR REVIEW DATE:    [Date + 2 days]
SEVERITY:           P1


EXECUTIVE SUMMARY (100 words):
[Write a non-technical summary for the CEO. Mention: duration, customer
impact, root cause in plain language, and assurance that it won't recur]

TIMELINE:
[Build a complete timeline with ALL events from your War Room Log, plus:
  - When monitoring first detected symptoms (vs. when alert fired)
  - When root cause was identified
  - When each service recovered individually
  - When communications were sent
  Minimum 10 timeline entries]

ROOT CAUSE ANALYSIS (5 Whys):
  Problem:  Database connections exhausted
  Why 1:    Connection pool was not returning connections
  Why 2:    [your analysis]
  Why 3:    [your analysis]
  Why 4:    [your analysis]
  Why 5:    [root cause - likely: no connection timeout configured in the ORM]

CONTRIBUTING FACTORS:
  [List 3-5 systemic factors that made this incident worse or harder to detect,
  e.g., no alert on connection pool utilization, no connection timeout in app,
  deployment without load testing]

WHAT WENT WELL:
  [Minimum 3 things - honest assessment. If comms went well, say so.]

WHAT WENT POORLY:
  [Minimum 3 things - honest assessment. These drive the action items.]

ACTION ITEMS:

  ID  | Action                              | Owner        | Due      | Priority
  ----|-------------------------------------|--------------|----------|----------
  A1  | Add Prometheus alert: pg_conn > 80% | DB Team      | +7 days  | P1
  A2  | Configure connection timeout in ORM | App Dev      | +3 days  | P1
  A3  | Require load testing before deploy  | IT Ops       | +14 days | High
  A4  | Document PgBouncer restart runbook  | DB Team      | +7 days  | High
  A5  | [Add 3 more action items]           |              |          |
  A9  | [Backup/restore procedure - added in Part 6] |    |          |

  [Write full descriptions for all 9 action items - each should be specific,
  measurable, and address a specific gap identified in "What Went Poorly"]

METRICS:
  Time to Detect:     [minutes from first symptom to alert fire]
  Time to Acknowledge: [minutes from alert to first response]
  Time to Identify RCA: [minutes from start to root cause identified]
  Time to Resolve:    32 minutes
  Total Customer Impact: 32 minutes × 12,000 users
  SLA Status:         Breached / Not Breached (based on your SLA from Lab 1)
  Estimated Financial Impact: [$X at $Y/minute for financial services]
```

Fill in EVERY section. The 5 Whys must reach a systemic root cause (not "developer made a mistake" - that's Why 1, not the root cause).

---

### Part 4 - Process Gap Analysis and Improvements (30 min)

Based on this exercise, identify 3 gaps in your current IR process:

**Gap Analysis Template:**

```
GAP: [ID]
Description: [What process or tool was missing or inadequate?]
Evidence from this incident: [Specific moment in the exercise where the gap manifested]
Industry standard: [What does ITIL 4 / NIST SP 800-61 / your SLA require?]
Proposed improvement: [Specific, actionable change]
Success metric: [How will you know if the improvement worked?]
Estimated effort: [Low/Medium/High] - [brief justification]
```

Example gap (do not reuse this - find 3 of your own):

```
GAP: IR-GAP-01
Description: No pre-built communication templates for customer-facing outages
Evidence: 8 minutes spent drafting first stakeholder communication under pressure
Industry standard: ITIL 4 recommends pre-approved templates for common scenarios
Proposed improvement: Create template library for Top 5 outage types; integrate into ITSM
Success metric: First stakeholder communication sent within 5 minutes of P1 declaration
Estimated effort: Low - 4 hours to create templates, 1 hour for approval
```

---

### Part 5 - Metrics and KPI Dashboard (10 min)

Compile an **IR Metrics Summary** for this incident and the incidents from Lab 1:

| Metric | This Incident | Lab 1 Average | Target |
|--------|--------------|---------------|--------|
| Time to Detect (TTD) | X min | X min | < 5 min |
| Time to Acknowledge (TTA) | X min | X min | < 15 min |
| Time to Resolve (TTR) | 32 min | X min | < 240 min (P1) |
| Stakeholder Comms sent within 15 min | Yes/No | X% | 100% |
| PIR completed within 48 hours | Yes | X% | 100% |
| Action items completed on time | TBD | X% | > 90% |

Write a 150-word analysis comparing your metrics to industry benchmarks. Reference DORA metrics (Mean Time to Restore Service) if applicable.

---

### Part 6 - Technical Follow-Through: Database Backup & Restore (30 min)

This whole exercise has been process and communication - the tabletop never actually touched the database. One of your PIR action items should be preventing a *worse* version of this incident (actual data loss, not just a connection pool exhaustion), so implement it for real:

```bash
# Install PostgreSQL if not already present
sudo apt install -y postgresql postgresql-contrib

# Create a test database standing in for the core banking DB
sudo -u postgres createdb bankingdb
sudo -u postgres psql bankingdb -c "CREATE TABLE accounts (id serial PRIMARY KEY, balance numeric);"
sudo -u postgres psql bankingdb -c "INSERT INTO accounts (balance) VALUES (1000), (2500), (750);"

# Take a real backup
sudo -u postgres pg_dump bankingdb > /tmp/bankingdb-backup.sql

# Simulate the "worse" incident: data loss, not just unavailability
sudo -u postgres psql bankingdb -c "DROP TABLE accounts;"

# Restore and verify
sudo -u postgres psql bankingdb < /tmp/bankingdb-backup.sql
sudo -u postgres psql bankingdb -c "SELECT * FROM accounts;"
```

Time the full restore from the moment data loss is detected to verified-restored data, and compare it against the RTO/RPO targets you'd propose for a real core banking database (this should be much stricter than a typical application server - justify a specific number). Add a 9th action item to your PIR specifically covering this backup procedure, with an owner and due date, matching the style of A1-A8.

Capture the backup file creation, the simulated data loss, the restore output, and your timed RTO/RPO comparison.

---

## Deliverables

1. P1 incident ticket (screenshot or formatted text)
2. Bridge opening script + War Room Log (10+ entries with timestamps)
3. Stakeholder Communication - Update 1 + Resolution Notice
4. Complete PIR (all sections, 5 Whys reaching systemic root cause, 9 action items including the backup follow-through)
5. Three process gap analyses in structured format
6. IR Metrics Summary table + 150-word analysis
7. Database backup/restore command output and timed RTO/RPO comparison

---

## Grading

| Item | Points |
|------|--------|
| Incident declaration + bridge protocol | 13 |
| War room log (10+ entries) + decision recording | 13 |
| Stakeholder communications (Update + Resolution) | 13 |
| PIR - timeline, 5 Whys, contributing factors, action items | 30 |
| Process gap analyses (3) | 13 |
| Metrics summary | 5 |
| Database backup/restore implementation + RTO/RPO analysis | 13 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Chaos Engineering and Proactive Resilience Testing
>
> The best way to discover gaps in your IR process is to find them before customers do. Design a **Chaos Engineering Test Plan** for the Meridian infrastructure:
>
> 1. Select 3 failure modes to test (e.g., database primary failure, HAProxy primary failure, network partition between app and DB tiers).
>
> 2. For each test:
>    - Write a hypothesis: "If [failure] occurs, [system behavior] will happen and recovery will complete within [X] minutes."
>    - Define the blast radius: What is the maximum possible customer impact if the test does not behave as expected?
>    - Write the test procedure (what will be done to induce the failure)
>    - Define go/no-go criteria: Under what conditions will the test be aborted?
>    - Define success criteria: What evidence confirms the hypothesis was validated?
>
> 3. Write a **Chaos Engineering Policy** covering: approval requirements before testing in production, rollback procedures, communication to on-call team, and incident handling if a chaos test causes an unplanned outage.
>
> ### Extension B - Regulatory Reporting Requirements
>
> Financial institutions have mandatory breach and outage reporting obligations. For the Core Banking outage scenario:
>
> 1. Determine if this outage triggers any regulatory reporting obligations under: (a) FFIEC BCP guidance (if operational resilience thresholds are breached), (b) OCC heightened standards for large financial institutions, (c) PCI-DSS requirement 12.10.7 (if cardholder data was potentially accessible during the outage).
>
> 2. Draft a **Regulatory Notification** to the primary regulator for scenarios where reporting is required. Include: incident description, timeline, impact assessment, root cause (preliminary), and corrective actions.
>
> 3. Write a 300-word analysis of why financial institutions face asymmetric regulatory exposure from IT outages vs. security breaches, and how the IR process must accommodate regulatory timelines (some regulators require notification within 36 hours).
>
> Submit the Chaos Engineering Test Plan + Policy, and the regulatory analysis + notification draft.
>
> ### Extension C - Point-in-Time Recovery and Immutable Backup Design
>
> A single `pg_dump` snapshot only recovers to the moment it was taken - a real banking database needs point-in-time recovery to any second, not just the last nightly backup.
>
> 1. Configure PostgreSQL WAL archiving (`archive_mode = on`, `archive_command`) and take a base backup with `pg_basebackup`. Demonstrate a point-in-time recovery to a specific timestamp between two transactions, proving you can recover to a moment *before* a bad transaction rather than only to the last full backup.
> 2. Design (documented, not necessarily implemented) an immutable backup storage tier - object-lock-enabled S3 or equivalent - and explain what specific failure mode it protects against that a normal backup target doesn't (an attacker or a mistaken admin with valid credentials deleting the backups themselves).
> 3. Write a 1-page cost/RTO tradeoff analysis: point-in-time recovery granularity vs. WAL storage cost vs. recovery complexity - what granularity would you actually recommend for Meridian's core banking database, and why not "recover to any second" as a default for every system?
>
> Submit your PITR demonstration output, the immutable storage design, and the tradeoff analysis.

[← Back to Labs]({{ site.baseurl }}/labs/)
