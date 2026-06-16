---
title: "IT HW 14 - Post-Incident Review & Problem Management"
parent: Homework
nav_order: 114
---

# IT HW 14 - Post-Incident Review & Problem Management
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
| **Assignment** | IT HW 14 |
| **Points** | 100 |
| **Due** | Week 15 |
| **Track** | IT |

---

## Description

Using the P1 incident from **IT LAB 14** as your source material, produce the two formal ITSM documents that close out every major incident: the Post-Incident Review and the Problem ticket. These must be written as if they will be presented to IT leadership and retained for compliance.

### Part 1 - Post-Incident Review Report (60 pts)

The PIR is presented to IT leadership, and potentially to compliance or legal, within 5 business days of a P1 incident. It must be factual, blameless, and specific. Vague language or unsupported claims will be returned.

1. **Incident header** - title, date/time opened and closed, total duration, P-level, affected services, total users/patients impacted, incident commander name/role

2. **Executive summary** - 2 paragraphs maximum written for a non-technical CTO. Must state what broke, how long it was broken, and the business impact in dollar or patient-impact terms.

3. **Detailed timeline** - chronological table from first alert to full resolution. Include timestamps to the minute, actor (person or automated system), action taken, and outcome. Gaps in the timeline must be explained.

4. **Root cause analysis - 5 Whys** - document each layer of "why" until you reach the underlying cause. The final "why" must not be a person ("because the admin made a mistake") - it must be a system, process, or design failure that allowed the mistake to happen. Format as a numbered chain.

5. **Contributing factors** - beyond the root cause, list every factor that made the incident worse or harder to detect (delayed alerting, missing runbook, single point of failure, etc.). At least 3.

6. **Impact quantification** - calculate:
   - Total downtime duration
   - Number of users/patients affected (from Lab 14 data)
   - Financial impact: use $5,600/minute (Gartner average for IT downtime in healthcare) or a figure you justify differently
   - SLA breach: did this incident breach any SLA? If so, what are the contractual consequences?
   - Patient safety impact: for a healthcare environment, was there any possibility of patient harm? If yes, does this trigger mandatory reporting?

7. **What went well** - at least 4 things the team did correctly during the response. Be specific ("the on-call engineer acknowledged the page within 3 minutes, within our P1 SLA of 5 minutes").

8. **What needs improvement** - at least 5 specific, measurable improvement items. Each must have an owner and a completion date. Vague items like "improve monitoring" are not acceptable - "Add a Prometheus alert rule for PostgreSQL replication lag >30s by Dec 1" is.

9. **Action items table** - formal tracking table:

| Action | Owner | Due Date | Priority | Status |
|---|---|---|---|---|

### Part 2 - Problem Management Ticket (25 pts)

The problem ticket tracks the underlying root cause through to permanent fix. Create a ticket with:

- **Problem title** - specific, not "server crashed"
- **Root cause** - verbatim from your 5 Whys analysis
- **Problem category** - Hardware / Software / Configuration / Process / Human Error (ITIL classification)
- **Known error record** - what is the known workaround while the permanent fix is pending? How long is this workaround sustainable?
- **Permanent fix plan** - the specific change(s) that will prevent recurrence. For each fix: description, owner, estimated effort, target completion date
- **Verification criteria** - how will you confirm the fix is effective? (Specific test, metric, or audit check)
- **Recurrence risk** - if the permanent fix is delayed past its target date, what is the escalation path and who decides whether to accept the ongoing risk?

### Part 3 - SLA Breach Analysis (15 pts)

Assume Valley Medical Group has a standard SLA with the following commitments to clinical department heads:

- Availability: 99.9% monthly (≤43.8 minutes unplanned downtime/month)
- P1 response: Incident Commander assigned within 5 minutes of detection
- P1 resolution: Initial mitigation within 60 minutes, full resolution within 4 hours

For each commitment: did this incident breach it? If yes, calculate the magnitude of the breach. Identify any SLA credits or contractual remedies that may apply. Write a 1-paragraph communication to the clinical department head who was most impacted - this is a professional stakeholder communication, not a technical email.

---

## Deliverable(s)

Write your full submission in `homework/it-hw-14.md`.

Open a PR titled `IT HW 14 - Post-Incident Review` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| PIR - timeline detail, executive summary, 5 Whys chain | 25 |
| PIR - impact quantification with financial calculation | 15 |
| PIR - what went well + improvement items (specific, owned, dated) | 20 |
| Problem ticket - root cause, known error, permanent fix plan, verification | 25 |
| SLA breach analysis - breach determination, stakeholder communication | 15 |

---

## Tip

{: .tip }
The 5 Whys must reach a systemic cause. "Why did the server crash? Because the disk filled up. Why? Because log rotation wasn't configured. Why? Because the runbook for new server provisioning didn't include log rotation setup. Why? Because the runbook was never reviewed after the logging system changed. Why? Because there is no change management process for runbook updates." That's a systemic cause.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - Organizational Resilience Assessment & Executive Presentation (30 pts)

**Resilience Maturity Assessment (20 pts)**

Assess your organization's resilience maturity across 5 domains using a structured maturity model (adapt from CERT-RMM, RESILIA, or define your own 5-level scale). For each domain:

| Domain | Maturity Level (1-5) | Evidence from the Incident | Gap Analysis | 90-Day Improvement |
|---|---|---|---|---|
| Incident Management | | | | |
| Service Continuity | | | | |
| Risk Management | | | | |
| Knowledge Management | | | | |
| External Dependencies | | | | |

**Maturity Scale Definition:** Define your 5 levels explicitly (e.g., 1=Ad Hoc, 2=Repeatable, 3=Defined, 4=Managed, 5=Optimizing) with concrete behavioral descriptors for each level at each domain. Base your ratings on evidence from the incident - not aspirational self-assessment.

For your lowest-scored domain:
1. Describe exactly what happened during the incident that revealed this maturity gap
2. Propose 3 specific improvements with implementation effort estimates (person-days)
3. Define a measurable success criterion for each improvement

**Executive Steering Committee Presentation (10 pts)**

Produce a 5-7 slide presentation (`it-hw-14-exec-presentation.pptx` or `.md` with clearly delineated slides) suitable for delivery to an executive steering committee (CFO, COO, CISO). The audience has no technical depth - they care about business risk, cost, and accountability.

Slides must cover:
1. **What happened** - in business terms, not technical terms
2. **Business impact** - financial loss, customer impact, regulatory exposure
3. **Why it happened** - root cause in one sentence, systemic factor in one sentence
4. **What we're doing** - top 3 remediation investments with cost and expected risk reduction
5. **What we're asking for** - specific budget approval, policy decision, or executive action required

Avoid all technical jargon. If you must use a technical term, define it in the slide. The committee should be able to make an informed funding decision after reading your presentation.


[← Back to Homework]({{ site.baseurl }}/homework/)
