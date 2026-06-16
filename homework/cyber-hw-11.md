---
title: "CYBER HW 11 - Audit Log Analysis & Attack Reconstruction"
parent: Homework
nav_order: 11
---

# CYBER HW 11 - Audit Log Analysis & Attack Reconstruction
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
| **Assignment** | CYBER HW 11 |
| **Points** | 100 |
| **Due** | Week 12 |
| **Track** | Cyber |

---

## Description

Analyze the provided 500-line auditd log excerpt (`AuditLog_Exercise.txt` on Learning Suite) and reconstruct a complete attack narrative, as you would in a real incident investigation.

### Part 1 - Event Triage & Classification (25 pts)

Parse the log file and produce an event triage table. For every event you identify as security-relevant (not just routine activity), document:

| Timestamp | UID/EUID | Command / Syscall | Key Label | Raw Log Line (abbreviated) | Classification |
|---|---|---|---|---|---|

**Classification options:** Normal Admin Activity / Suspicious / Likely Malicious / Confirmed Malicious

You must identify **at least 12 security-relevant events**. For each event classified as Suspicious or worse, provide a 1-sentence justification.

### Part 2 - Attack Chain Reconstruction (35 pts)

Using your triaged events, reconstruct the full attack chain. Present your analysis as:

**A. Chronological attack timeline** - a table showing each attacker action in sequence with timestamp, action description, and confidence level (High/Medium/Low - based on how directly the log supports your conclusion)

**B. MITRE ATT&CK mapping** - for each distinct attacker action, map to the most specific ATT&CK technique ID and name (not just the tactic). Explain briefly why this specific technique ID fits, not a more general one.

**C. Attack narrative** - 3-4 paragraphs telling the story of the attack from initial access to final objective. Written for a CISO briefing - technical but readable. It must be grounded in specific log evidence (cite timestamps).

**D. Objective assessment** - based on the log evidence, what was the attacker's most likely objective? State your confidence level and what evidence supports or undermines your conclusion.

### Part 3 - IOC Extraction & Threat Intelligence (20 pts)

Extract all Indicators of Compromise (IOCs) from the logs:

| IOC Type | Value | Context | Confidence |
|---|---|---|---|

IOC types to look for: suspicious usernames, unusual binary paths, unexpected file paths written to, network destinations (IP/domain) if present, unusual timestamps (off-hours activity).

For **at least 2 IOCs**, perform a brief open-source threat intelligence lookup:
- Search the IP/hash/filename in VirusTotal, Shodan, or AbuseIPDB
- Report what you found (or did not find)
- Does the OSINT evidence raise or lower your confidence that this is malicious?

### Part 4 - Detection Rule Writing (20 pts)

Write detection rules in two formats to catch the most critical attacker action you identified:

**Format 1 - auditd rule** - write the `auditctl` watch or syscall rule that would have generated a specific log entry for the attacker's most dangerous action. Explain why this rule would fire on the attacker's action but not on normal admin activity.

**Format 2 - Sigma rule** - write a Sigma detection rule (YAML format) for the same technique. Sigma is the vendor-neutral SIEM rule language. Your rule must include `title`, `status`, `description`, `logsource`, `detection` (with `condition`), and `falsepositives` fields.

For one of your rules, describe specifically how it would be deployed in Graylog or Splunk (whichever you have more experience with) and what the alert would look like.

---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-11.md`. Commit to `homework/assets/`:

- `cyber-hw-11-sigma-rule.yml` - your Sigma detection rule
- `cyber-hw-11-iocs.csv` - your IOC table as a CSV

Open a PR titled `CYBER HW 11 - Audit Log Analysis` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Event triage - 12+ relevant events, classification justified | 25 |
| Attack chain - timeline, ATT&CK mapping, narrative, objective assessment | 35 |
| IOC extraction + OSINT lookup for 2 IOCs | 20 |
| Detection rules - auditd rule correct, Sigma rule valid YAML | 20 |

---

## Tip

{: .tip }
`ausearch -i -f /path/to/AuditLog_Exercise.txt` can help parse auditd records if you copy the file to your lab VM. The `-i` flag translates numeric UIDs and syscall numbers to human-readable names.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Structured Threat Intelligence Export (30 pts)

**STIX 2.1 Threat Intelligence Report (20 pts)**

Using the attack chain you reconstructed in Part 2, produce a formal **STIX 2.1 Bundle** (`cyber-hw-11-stix-bundle.json`) containing the following STIX Domain Objects:

- `threat-actor` - the attributed or suspected actor (use "Unknown" with appropriate confidence level if attribution is uncertain; document your reasoning)
- `campaign` - the overall intrusion campaign with first/last seen timestamps from your log analysis
- `attack-pattern` - one object per MITRE ATT&CK technique in your reconstruction (use STIX's `external_references` to link to ATT&CK technique IDs)
- `indicator` - one object per IOC you extracted (IP, domain, file hash), with `valid_from`, `pattern` (STIX patterning language), and `confidence` score
- `relationship` objects linking the above (e.g., `threat-actor` → `uses` → `attack-pattern`, `indicator` → `indicates` → `campaign`)

Validate your bundle using the `stix2-validator` Python package (`pip install stix2-validator`). Submit a screenshot of a clean validation run.

**MISP-Compatible IOC Export (10 pts)**

Write `cyber-hw-11-misp-export.json`: a MISP event JSON that contains all your extracted IOCs formatted with correct MISP `type`, `category`, `to_ids` flag, and `comment` fields. Types must be accurate (e.g., `ip-dst`, `domain`, `md5`, `sha256`, `url` - not generic `text`). Include a MISP `Tag` for the relevant MITRE ATT&CK techniques using the `misp-galaxy:mitre-attack-pattern` taxonomy format.


[← Back to Homework]({{ site.baseurl }}/homework/)
