---
title: "CYBER HW 14 - Incident Response Report & HIPAA Breach Analysis"
parent: Homework
nav_order: 14
---

# CYBER HW 14 - Incident Response Report & HIPAA Breach Analysis
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
| **Assignment** | CYBER HW 14 |
| **Points** | 100 |
| **Due** | Week 15 |
| **Track** | Cyber |

---

## Description

Using the compromised Ubuntu server from **Lab 14**, produce the full incident response package that a security team would deliver after a confirmed breach of a HIPAA-regulated system.

### Part 1 - Formal Post-Incident Report (35 pts)

Following NIST SP 800-61 Rev. 2 structure:

1. **Incident header** - incident ID, dates/times (detection, containment, eradication, recovery), duration, severity, affected systems with asset classification (does this system store/process/transmit PHI?)

2. **Executive summary** - 2 paragraphs maximum, non-technical, written for a hospital CISO who will also send this to legal counsel. Must state what happened, what data was at risk, and what was done. Do not minimize - be accurate.

3. **Detailed timeline** - every action from "attacker first touched the system" through "system restored to production" with timestamps, actor, and source (which log file or artifact you found this in). Mark each event's confidence: **Confirmed** (in logs), **Probable** (inferred from evidence), or **Possible** (hypothesized).

4. **Root cause analysis** - use the 5 Whys method. The final cause must be systemic.

5. **Forensic evidence summary** - list every artifact you collected during Lab 14 and its evidentiary value:

| Artifact | Collection Method | Hash (MD5/SHA256) | Evidentiary Value |
|---|---|---|---|

For at least 3 artifacts, explain the chain of custody: who collected it, how it was stored, and how you verified it was not modified after collection.

6. **Impact assessment** - was PHI accessed, exfiltrated, or modified? For each answer: what is your evidence (or lack thereof)? This matters for HIPAA breach determination.

7. **What went well** - at least 3 specific items

8. **Improvement recommendations** - at least 5, each owned, dated, and measurable

### Part 2 - IOC List & Threat Intelligence (20 pts)

Extract and document all Indicators of Compromise from your Lab 14 investigation:

| IOC Type | Value | First Seen | Last Seen | Confidence | MITRE ATT&CK |
|---|---|---|---|---|---|

Minimum IOCs to document: the initial access vector, the persistence mechanism, any lateral movement or privilege escalation artifacts, and any data staging or exfiltration indicators.

For **2 IOCs** (at least one IP address or domain), perform OSINT lookups using VirusTotal, AbuseIPDB, or Shodan. Report your findings and how they affect your attribution confidence.

Write a **threat actor profile** (1 paragraph): based on the TTPs observed, what type of attacker is this? (Opportunistic/targeted, skill level, likely motivation.) What is your confidence level and what evidence supports vs. undermines your assessment?

### Part 3 - HIPAA Breach Determination (25 pts)

Apply the HIPAA Breach Notification Rule (45 CFR §164.400-414) to your incident:

**Step 1 - Was PHI involved?** Based on your forensic evidence, state whether the compromised system stored, processed, or transmitted PHI. If you cannot determine this from the evidence, state what additional investigation would be needed.

**Step 2 - Was there a "disclosure"?** Apply the 4-factor risk assessment from the Breach Notification Rule (45 CFR §164.402):
1. Nature and extent of PHI involved (type of information, likelihood of re-identification)
2. Who accessed or could have accessed the PHI
3. Whether PHI was actually acquired or viewed
4. Extent to which the risk has been mitigated

**Step 3 - Notification determination:** Based on your risk assessment, state whether this constitutes a reportable breach. If yes:
- Who must be notified and by when? (Affected individuals, HHS, media if >500 individuals)
- Draft the notification letter to affected individuals (use HHS's required content elements)

**Step 4 - Notification exemptions:** Does the incident qualify for any exemption from notification (e.g., encrypted data, good-faith access by authorized user)? Apply the exemption criteria and state your conclusion.

### Part 4 - Hardening Recommendations (20 pts)

Provide **6 specific hardening recommendations** that would have prevented or limited this breach. For each:

1. What it prevents (specific attack step from your timeline)
2. Implementation: specific tool, configuration, or control
3. Effort estimate: Low (<4 hrs), Medium (1-5 days), High (>1 week)
4. Priority: P1 (implement before returning system to production), P2 (implement within 30 days), P3 (implement within 90 days)

At minimum: one recommendation must address backup and recovery (include specific RTO/RPO targets and backup strategy for this system type), and one must address detection/monitoring (specific alert rule or SIEM query that would have detected this attack earlier).

---

## Deliverable(s)

Write your full submission in `homework/cyber-hw-14.md`. Commit to `homework/assets/`:

- `cyber-hw-14-iocs.csv` - your IOC list
- `cyber-hw-14-hipaa-notification.md` - your draft breach notification letter (if applicable)

Open a PR titled `CYBER HW 14 - Incident Response Report` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Post-incident report - timeline with confidence ratings, 5 Whys, forensic evidence table | 35 |
| IOC list + OSINT lookups + threat actor profile | 20 |
| HIPAA breach determination - 4-factor assessment, notification decision | 25 |
| Hardening recommendations - all 6 specific, prioritized, P1 justified | 20 |

---

## Tip

{: .tip }
HHS provides a free HIPAA Security Risk Assessment tool and breach notification guidance at hhs.gov/hipaa. The 4-factor risk assessment from 45 CFR §164.402 is what you apply to determine if the incident is a "breach" - not whether PHI exists, but whether the disclosure poses significant risk of harm.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Tabletop Exercise Design & Financial Breach Quantification (30 pts)

**Tabletop Exercise Facilitator Guide (20 pts)**

Design a full **Tabletop Exercise** based on the ransomware-with-PHI-exfiltration scenario from this assignment. Your facilitator guide (`cyber-hw-14-tabletop.md`) must include:

1. **Scenario Overview** - 1-page narrative briefing provided to participants before the exercise begins. Do not reveal the full attack chain upfront; provide only the initial symptom (e.g., "at 09:14 Monday, the EHR application team reports the database is unavailable and response times are anomalous").

2. **Inject Schedule** - 5 escalating injects, each with: inject text (what participants are told), inject timing (how many minutes into the exercise), facilitator notes (what a realistic organization should do at this point), and discussion questions (3 per inject).

   Injects should progress: initial anomaly → confirmed ransomware → PHI exfiltration confirmed → threat actor contact → HIPAA breach determination deadline.

3. **Expected Outcomes** - for each inject, document what decisions a mature IR team should make and what common failure modes (wrong decisions) to watch for.

4. **Debrief Template** - structured hot-wash questions covering: what went well, what failed, which playbook steps were missing or unclear, and what one process change the team commits to before the next exercise.

**Breach Cost Quantification (10 pts)**

Using the **Ponemon Institute Cost of a Data Breach** methodology, quantify the total financial impact of the incident you analyzed:

| Cost Component | Methodology | Estimated Cost |
|---|---|---|
| Detection & Escalation | IR team hours × loaded labor rate + tools/forensics vendor | $ |
| Notification | Per-record notification cost × affected records | $ |
| Post-Breach Response | Credit monitoring, call center, legal counsel | $ |
| Lost Business | Downtime hours × revenue/hour + customer churn estimate | $ |
| Regulatory Fines | HIPAA fine range for willful neglect (cite 45 CFR §160.404) | $ |
| **Total** | | $ |

Compare the total breach cost against the estimated cost of implementing the 6 hardening recommendations from Part 4. Calculate the **Return on Security Investment (ROSI)** for each recommendation and rank them by ROSI.


[← Back to Homework]({{ site.baseurl }}/homework/)
