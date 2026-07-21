---
title: "IT HW 3 - Windows Infrastructure Governance: Patch Policy, DFS Resilience & Backup Verification"
parent: Homework
nav_order: 103
---

# IT HW 3 - Windows Infrastructure Governance: Patch Policy, DFS Resilience & Backup Verification
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | IT HW 3 |
| **Points** | 100 |
| **Due** | Week 4 |
| **Track** | IT |

---

## Description

Deploying WSUS, DFS, and Windows Server Backup in Lab 3 gets the infrastructure running - this assignment asks you to govern it. A patch server nobody has a rollout policy for, a DFS namespace nobody has stress-tested, and a backup job nobody verifies is running are each, individually, a production incident waiting to happen.

### Part 1 - Patch Governance Policy (30 pts)

You are given the following (deliberately bad) auto-approval policy excerpt:

> "All Critical and Security updates are automatically approved to all computer groups, including Production, immediately upon WSUS synchronization. This ensures servers always have the latest patches with no administrative overhead."

Critique this policy in 4-6 sentences: identify at least 3 specific ways this creates production risk, citing a real-world example of a problematic cumulative update (e.g., a Windows Update that broke a specific service, driver, or boot process) to ground your critique in something that actually happened, not a hypothetical.

Then write a production-grade **Patch Governance Policy** covering:

1. **Ring-based deployment** - define at least 3 rings (e.g., Pilot, Pilot-Extended, Production) with the computer groups, update classifications, and minimum soak time in each ring before promotion
2. **Testing SLA** - how long updates sit in each pre-production ring, and who signs off before promotion to Production
3. **Rollback triggers** - specific, measurable conditions that trigger an automatic hold on further rollout (e.g., failed reboot rate, help desk ticket volume threshold) and who has authority to invoke it
4. **Exception handling** - process for a server or application that cannot take a given patch (compatibility issue), including compensating controls while unpatched

### Part 2 - DFS Failure Mode & Capacity Analysis (25 pts)

Your Lab 3 DFS Replication Group (`Docs-RG`) currently replicates between two servers on what's presumably a fast local link. Extend the design to a 3-site scenario: your two Lab 3 servers plus a third branch office connected over a 10 Mbps WAN link with 200 GB of data to replicate.

For each of the following, describe exactly what happens and what you would monitor or change:

1. The namespace server (holding the DFS root) goes offline - what do clients experience, and how quickly do they fail over to a surviving target?
2. Two sites edit the same file within the WAN replication latency window - what does DFS Replication do, and where does the conflicted copy end up?
3. The WAN link to the branch office saturates during business hours - estimate how long a full initial sync of 200 GB would take at 10 Mbps, and propose a specific mitigation (staging, bandwidth throttling via `Set-DfsrConnectionSchedule`, seeding via removable media, etc.)
4. A single large file (5 GB) is modified frequently throughout the day at the branch site - explain why this is a worse case for DFS-R than the same total data spread across many small files, and what you'd do about it

### Part 3 - Backup Verification Script & Recovery Runbook (30 pts)

Write `it-hw-03-backup-healthcheck.ps1` that:

1. Queries `Get-WBJob -Previous <N>` and/or `Get-WBBackupSet` for the last 7 days
2. For each of the last 7 days, determines whether at least one successful backup ran; flag any day with zero successful backups as `FAIL`
3. Outputs a table (console or CSV) with columns: `Date`, `Status` (`PASS`/`FAIL`), `BackupSize`, `Duration`
4. Exits with a non-zero exit code if any day in the window is `FAIL`, so this can be wired into a scheduled task with alerting later
5. **CI compatibility** - guard your `Import-Module WindowsServerBackup` call, e.g. `Import-Module WindowsServerBackup -ErrorAction SilentlyContinue`. Your script is graded by a CI pipeline that supplies a stand-in module exposing the same cmdlet names (`Get-WBJob`, `Get-WBBackupSet`) without the real Windows Server Backup feature installed. An unconditional `Import-Module WindowsServerBackup` throws on that runner and fails your build before any of your logic runs.

Then write a formal **Backup & Recovery Runbook** (`it-hw-03-recovery-runbook.md`) covering:

- RTO and RPO targets for this environment, justified (not just asserted)
- Step-by-step restore procedure a different administrator could follow without you present
- Verification steps after restore (file hash comparison, service health checks)
- Who must be notified and how the recovery is documented

### Part 4 - Write-Up (15 pts)

1. WSUS, DFS, and backup verification are three separate subsystems you just governed independently. What is the argument for treating them as a single "infrastructure resilience" program with shared reporting, rather than three separate concerns each owned by whoever happened to configure them? What's lost if they stay siloed?
2. Of the three (patch governance, DFS resilience, backup verification), which is the biggest gap in what Lab 3 actually built, and what specific change would you make first if you only had time for one?

---

## Deliverable(s)

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow runs your `it-hw-03-backup-healthcheck.ps1` against a simulated week of backup jobs (6 successful, 1 day with none) and checks that your script correctly flags the FAIL day and returns the right exit code. This is a coarse smoke test, not your final grade - it does not verify your recovery runbook or patch governance policy.

Write your patch governance policy, DFS analysis, and write-up in `homework/it-hw-03.md`. Commit to `homework/assets/`:

- `it-hw-03-backup-healthcheck.ps1` - your backup verification script
- `it-hw-03-recovery-runbook.md` - your recovery runbook

Open a PR titled `IT HW 3 - Windows Infrastructure Governance` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Patch policy critique + ring-based governance policy | 30 |
| DFS failure mode and capacity analysis (all 4 scenarios) | 25 |
| Backup health-check script - correctness, exit code behavior | 20 |
| Recovery runbook - RTO/RPO justified, step-by-step, verification | 10 |
| Write-up - depth of analysis | 15 |

---

## Tip

{: .tip }
For Part 2's WAN transfer estimate, remember 10 Mbps is roughly 1.25 MB/s in practice after protocol overhead - the math should make the mitigation options in question 3 feel necessary, not optional.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Unified Infrastructure Health Dashboard (30 pts)

WSUS compliance, DFS replication state, and backup job status are three separate things an administrator currently has to check in three separate places. Build a single aggregated health report:

1. Write `it-hw-03-health-dashboard.ps1` that combines: WSUS patch compliance summary (from `Get-WsusServer` / computer status), DFS replication state (`Get-DfsrState` for all replication groups), and your Part 3 backup health check - into a single structured JSON or HTML report with one overall status (`Healthy` / `Degraded` / `Critical`) and per-subsystem detail.
2. Define the rule for how subsystem statuses roll up into the overall status (e.g., any subsystem `FAIL` → overall `Critical`; is that always the right call?).
3. Write a 1-page analysis: when you combine three independently-alerting subsystems into one dashboard, what's the risk of alert fatigue vs. the risk of a real problem getting buried in noise? Propose a specific threshold or suppression rule for at least one subsystem to reduce false-positive noise without missing a real incident, and justify the tradeoff.

Submit the script, a sample report showing at least one subsystem in a non-`Healthy` state, and your written analysis.

[← Back to Homework]({{ site.baseurl }}/homework/)
