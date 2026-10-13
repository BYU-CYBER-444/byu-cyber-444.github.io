---
title: "C3 - Detection Engineering / SOC-in-a-Box"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 3
---

# C3 - Detection Engineering / SOC-in-a-Box
{: .no_toc }

Build the monitoring, attack it yourself, and prove you can catch and contain what you did.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

A SOC is only as good as its detections. You build a small security operations setup: a monitored victim host, a SIEM or log platform, and an attacker host inside your own isolated lab network. You run a set of scripted attacks mapped to **MITRE ATT&CK** techniques, write detection rules that catch them, tune out false positives, and produce a response runbook. Your recorded demo shows an attack triggering your alert, followed by your response.

{: .warning }
**Rules of engagement.** All attacks run only from your own attacker host against your own victim host, inside your own lab network. No scanning or attacking class infrastructure, other students, or anything outside the lab. Your proposal must include a signed-off statement of these rules of engagement; breaking them is an academic integrity matter.

## What You Build

| Component | Description |
|---|---|
| Victim host | Linux server (Ubuntu or Rocky) with `auditd` rules and a log shipper/agent; runs a few realistic services (SSH, a web app) |
| Log / SIEM host | Graylog, Wazuh, or an Elastic stack receiving and indexing events |
| Windows victim host | Windows Server 2022 with Sysmon and Windows event forwarding (or a log agent) shipping to the same SIEM. At least 2 of your techniques must target it, for example failed-logon spraying (T1110, event 4625), new local account creation (T1136, event 4720), scheduled-task persistence (T1053.005, event 4698), or clearing the event log (T1070.001, event 1102) |
| Attacker host | A VM or LXC (Kali or a hand-built toolkit) with scripted attack scenarios, restricted to your lab network |
| Attack scenarios | At least **5** techniques mapped to ATT&CK, for example SSH brute force (T1110), privilege escalation via sudo misuse (T1548), persistence via cron (T1053), credential file access (T1552), and log tampering (T1070) |
| Detections | At least **8** detection rules or alerts, **at least 3 of them on Windows events**, with a documented false-positive tuning pass |
| Response | A runbook, plus at least one automated containment action (for example blocking an attacking IP with a firewall rule via Ansible) |

The SIEM host and the Windows Server are the heaviest components; confirm RAM with the instructor before choosing Graylog/Elastic over Wazuh or another lighter stack.

## Proposal Checklist

Your proposal must include:

- The log/SIEM platform you will use and why it fits your RAM budget
- The five or more ATT&CK techniques you will simulate, with the technique ID for each, and which of them target the Windows host
- The rules-of-engagement statement above
- How you will measure detection quality (for example time to alert and false positives per hour of normal activity)

---

## Final Documentation Package {#documentation}

**Due:** December 10, 11:59 PM. Submit everything in Learning Suite, as uploaded files or a link to them (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#submission)).

1. **Detection catalog and ATT&CK coverage matrix.** For each detection: the technique, the data source, the rule logic, severity, expected false positives, and how it was tested.
2. **Incident response runbook.** Triage steps, escalation, containment, and evidence preservation for at least two of your scenarios.
3. **Architecture diagram.** Hosts, network zones, log flow, and where the attacker is isolated.
4. **Automation package.** Rebuilds the lab (hosts, agents, rules, dashboards) from the repo; attack scripts are included and clearly labeled as lab-only.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Detection catalog and matrix | 30 | Complete, specific, and tested, with 3+ Windows detections and 2+ Windows techniques | Present; some entries thin or untested |
| IR runbook | 20 | Actionable steps a new analyst could follow | Generic |
| Architecture diagram | 15 | Hosts, zones, and log flow clearly labeled | Missing labels or isolation boundary |
| Automation package | 20 | Rebuilds from checkout; README accurate | Runs with manual fixes |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Attack to alert.** Run one of your attacks live from the attacker host and show the alert fire in your SIEM. State how long it took.
2. **Triage.** Starting from the alert, use your dashboard and queries to reconstruct what the attacker did.
3. **Containment.** Contain the attack, either by following your runbook or by an automated action, and show that the attacker is blocked.

At least one of the three demos must use the Windows host.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Setup, scenarios, and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Attack to alert | 30 | Attack triggers the alert; time to detect stated | Alert fires; timing or cause unclear |
| Triage | 20 | Attack reconstructed from the SIEM data alone | Partially reconstructed |
| Containment | 20 | Attacker blocked and verified | Containment attempted; not verified |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to Cyber Project Options]({% link final-project-cyber/projects/index.md %})
