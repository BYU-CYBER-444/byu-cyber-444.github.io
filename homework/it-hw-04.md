---
title: "IT HW 4 - RFC Writing & Change Risk Analysis"
parent: Homework
nav_order: 104
---

# IT HW 4 - RFC Writing & Change Risk Analysis
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
| **Assignment** | IT HW 4 |
| **Points** | 100 |
| **Due** | Week 5 |
| **Track** | IT |

---

## Description

### Part 1 - RFC Critique (25 pts)

A draft RFC is provided on Learning Suite (`IT_HW4_Bad_RFC.pdf`). It was submitted by a junior admin and rejected by the CAB. Write a structured critique identifying every deficiency.

For each problem found, document: which RFC section it's in, what is wrong or missing, the business/operational risk if the change proceeded with this gap, and what the correct content should be. You must identify **at least 8 distinct deficiencies**. Organize as a table followed by a 1-paragraph summary stating whether you would approve, reject, or request revisions - and what must change before approval.

### Part 2 - Full RFC (60 pts)

Write a complete, production-quality RFC for the following scenario:

**Scenario:** Acme Financial Corp (2,000 employees, subject to SOX and PCI-DSS) is migrating their primary email from on-premises Exchange Server 2016 to Microsoft 365. Requirements: preserve 7 years of email archives under legal hold, maintain continuous mail flow (no lost email), and complete migration in a rolling 6-week process with no single maintenance window longer than 4 hours. The CISO has classified this as High-risk due to regulated data.

Your RFC must include:

1. **Change summary** - one paragraph written for a non-technical CFO
2. **Business justification** - quantified cost-benefit including license cost assumptions, Exchange support end-of-life, and estimated operational savings
3. **Risk classification** - Normal/Standard/Emergency, risk level, and written justification referencing specific regulatory exposure
4. **Pre-change prerequisites** - every dependency that must be verified before the first window opens (minimum 6, with owner and verification method for each)
5. **Phased implementation plan** - 6-week timeline with specific milestones per phase. Each phase must define a measurable go/no-go criterion before proceeding to the next.
6. **Per-phase rollback plan** - for each phase: the exact trigger that causes you to abort (specific metric or failure condition), the rollback steps, and the maximum recovery time before you are back to baseline
7. **Validation plan** - how you verify mail flow, archive access, calendar sync, and mobile device connectivity for each user group before decommissioning Exchange
8. **Communication plan** - specific dates, channels, content summaries, and owners for notifications to end users, helpdesk, legal/compliance, and executives
9. **Post-implementation success metrics** - what you measure in the 30 days after completion; define numeric targets for each metric

### Part 3 - Reflection (15 pts)

Under what specific circumstances would you invoke an emergency change process (bypassing the 2-week CAB review) for a migration of this scope? What governance controls ensure the emergency process is not abused as a shortcut? Reference at least two ITIL 4 guiding principles in your answer.

---

## Deliverable(s)

Write your full submission in `homework/it-hw-04.md`.

Open a PR titled `IT HW 4 - RFC Writing & Change Risk Analysis` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| RFC critique - issues identified with risk explanations | 25 |
| RFC completeness - all 9 sections present and substantive | 20 |
| RFC quality - specific, quantified, no vague language | 25 |
| Per-phase rollback plan - triggers, steps, recovery time | 15 |
| Reflection - ITIL 4 principles cited, governance controls defined | 15 |

---

## Tip

{: .tip }
"Notify users before migration" is not a communication plan. Specify exact dates, channels (email/Teams/intranet), content summaries, and who owns each touchpoint.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - CAB Briefing & Post-Mortem Research (30 pts)

**Change Advisory Board (CAB) Briefing Document (15 pts)**

Your RFC is a technical document. Graduate students must also produce the **CAB Briefing** that a change manager would present when seeking approval (`it-hw-04-cab-briefing.md`). The CAB audience is IT leadership and business stakeholders - not engineers. The briefing must:

1. **Executive Summary** (1 paragraph) - what is changing, why, and when, in business terms
2. **Business Risk Assessment** - likelihood and impact of the change failing, expressed as business impact (revenue, compliance, customer impact) not technical terms
3. **Rollback Decision Gate** - specific, measurable criteria that trigger rollback. Not "if something goes wrong" - actual metrics: "if >5% of mailboxes fail to migrate within the first 2-hour window, rollback is initiated"
4. **Success Metrics** - how will the CAB know the change succeeded? Define KPIs measured at 24h, 72h, and 30d post-change.
5. **Stakeholder Communication Plan** - who is notified at each phase, through what channel, and what they are told. Include a user-facing communication template.
6. **Approval Matrix** - who must sign off (CAB chair, CISO, business owner, legal/compliance) and the minimum quorum required for approval

**Post-Mortem Research Analysis (15 pts)**

Research a real, publicly documented migration post-mortem or failure (Exchange, M365, or major email migration preferred - e.g., the Sidekick data loss incident, Knight Capital, or any public case study with enough technical detail). Write a 2-page analysis:

1. Summarize what happened, what the change process was, and what failed
2. Map the failure to a specific gap in your RFC - which section of your RFC would have caught or mitigated this failure?
3. Extract 3 specific lessons and propose concrete additions or amendments to your RFC based on each lesson (cite the section you would modify)


[← Back to Homework]({{ site.baseurl }}/homework/)
