---
title: "CYBER HW 12 - Audit Log Analysis & Attack Reconstruction"
parent: Homework
nav_order: 12
---
# CYBER HW 12 - Audit Log Analysis & Attack Reconstruction
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Analyze the provided [auditd log excerpt]({% link homework/description-files/cyber-hw-12-audit-log.md %}) from `prod-web-03` and reconstruct a complete attack narrative, as you would in a real incident investigation. Not every record in the excerpt is security-relevant - part of the exercise is separating routine background activity from what actually matters.

### Part 1 - Event Triage & Classification (25 pts)

Parse the log file and produce an event triage table. For every event you identify as security-relevant (not just routine activity), document:

| Timestamp | UID/EUID | Command / Syscall | Key Label | Raw Log Line (abbreviated) | Classification |
|---|---|---|---|---|---|
| 2024-03-14 02:17:03 *(example only - not from your log)* | 1001/0 | execve /usr/bin/sudo | priv_esc | `type=SYSCALL ... uid=1001 euid=0 comm="sudo" exe="/usr/bin/sudo" key="priv_esc"` | Suspicious |

**Classification options:** Normal Admin Activity / Suspicious / Likely Malicious / Confirmed Malicious

You must identify **at least 12 security-relevant events**. For each event classified as Suspicious or worse, provide a 1-sentence justification.

### Part 2 - Attack Chain Reconstruction (35 pts)

Using your triaged events, reconstruct the full attack chain. Present your analysis as:

**A. Chronological attack timeline** - a table showing each attacker action in sequence with timestamp, action description, and confidence level (High/Medium/Low - based on how directly the log supports your conclusion)

**B. MITRE ATT&CK mapping** - for each distinct attacker action, map to the most specific ATT&CK technique ID and name (not just the tactic). Explain briefly why this specific technique ID fits, not a more general one.

**C. Attack narrative** - 3-4 paragraphs telling the story of the attack from initial access to final objective. Written for a CISO briefing - technical but readable. It must be grounded in specific log evidence (cite timestamps).

**D. Objective assessment** - based on the log evidence, what was the attacker's most likely objective? State your confidence level and what evidence supports or undermines your conclusion.

### Part 3 - IOC Extraction & Threat Intelligence (40 pts)

Extract all Indicators of Compromise (IOCs) from the logs:

| IOC Type | Value | Context | Confidence |
|---|---|---|---|
| Network destination (IP) *(example only - not from your log)* | 203.0.113.77 | Outbound connection immediately following the privilege-escalation event, timed to match a likely exfiltration attempt | Medium |

IOC types to look for: suspicious usernames, unusual binary paths, unexpected file paths written to, network destinations (IP/domain) if present, unusual timestamps (off-hours activity).

For **at least 2 IOCs**, perform a brief open-source threat intelligence lookup:
- Search the IP/hash/filename in VirusTotal, Shodan, or AbuseIPDB
- Report what you found (or did not find)
- Does the OSINT evidence raise or lower your confidence that this is malicious?

---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-12.md`. Commit to `homework/assets/`:

- `cyber-hw-12-iocs.csv` - your IOC table as a CSV

Open a PR titled `Grade: cyber-hw-12 - Audit Log Analysis` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Event triage - 12+ relevant events, classification justified | 25 |
| Attack chain - timeline, ATT&CK mapping, narrative, objective assessment | 35 |
| IOC extraction + OSINT lookup for 2 IOCs | 40 |

---

## Tip

{: .tip }
Save the excerpt to a file on your lab VM (e.g. `AuditLog_Exercise.txt`), then `ausearch -i -f AuditLog_Exercise.txt` can help parse the records. The `-i` flag translates numeric UIDs and syscall numbers to human-readable names.

---

---

##  Graduate Extension - Graduate Students Only

### Part 5 - STIX 2.1 Threat Intelligence Report (30 pts)

Using the attack chain you reconstructed in Part 2, produce a formal **STIX 2.1 Bundle** (`cyber-hw-12-stix-bundle.json`) containing the following STIX Domain Objects:

- `threat-actor` - the attributed or suspected actor (use "Unknown" with appropriate confidence level if attribution is uncertain; document your reasoning)
- `campaign` - the overall intrusion campaign with first/last seen timestamps from your log analysis
- `attack-pattern` - one object per MITRE ATT&CK technique in your reconstruction (use STIX's `external_references` to link to ATT&CK technique IDs)
- `indicator` - one object per IOC you extracted (IP, domain, file hash), with `valid_from`, `pattern` (STIX patterning language), and `confidence` score
- `relationship` objects linking the above (e.g., `threat-actor` → `uses` → `attack-pattern`, `indicator` → `indicates` → `campaign`)

Validate your bundle using the `stix2-validator` Python package (`pip install stix2-validator`). Submit a screenshot of a clean validation run.


[← Back to Homework]({{ site.baseurl }}/homework/)
