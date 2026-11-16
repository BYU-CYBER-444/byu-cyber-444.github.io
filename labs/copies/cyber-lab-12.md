---
title: "CYBER LAB 12 - Centralized Logging with auditd & Graylog"
parent: Labs
nav_order: 12
---

# CYBER LAB 12 - Centralized Logging with auditd & Graylog
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Purpose

Local audit records may be lost or altered when a host is compromised. In this lab, you will build a small centralized logging pipeline that sends Linux audit events to Graylog, extracts fields that an analyst can search, enriches those events with defensible security context, and detects repeated privilege-escalation activity.

This lab emphasizes independent implementation and verification. A running service or populated dashboard is not sufficient evidence by itself: you must generate known events, predict what the pipeline should produce, locate the resulting records, and explain whether the evidence supports your prediction.

## Learning Outcomes

Given the provisioned Ubuntu VM and the course-provided Graylog Compose file, you will be able to:

- configure persistent `auditd` rules and syslog forwarding while preserving the original audit record;
- deploy Graylog and verify that a controlled event travels from `auditd` through syslog into Graylog;
- parse the required audit fields and enrich events with a threat category and a defensible ATT&CK candidate;
- validate dashboard panels with known test events;
- configure and test grouped detection for repeated privilege escalation; and
- identify an important limit of the evidence produced by the pipeline.

## Starting Conditions and Resources

- Your instructor has provisioned an Ubuntu 22.04 VM for this lab, `cyber-lab12-log01` (logging target: `192.168.56.10`). Your username is your Net ID, and your password is the one emailed to you at the start of the semester.
- Docker and Docker Compose are installed on the VM.
- The Graylog 5.x Docker Compose file is available on Learning Suite.
- You have `sudo` access and can reach the Graylog web interface from your workstation.
- You may consult the technical references at the end of this lab. You are responsible for translating the requirements below into working commands and configurations.

Planning estimate: **4–6 hours**, including deployment, testing, and the verification record. This is an adjustable planning estimate; image-download speed and troubleshooting may change the time required.

{: .warning }
> Work only on the provisioned lab VM. Your tests should create benign audit activity, but some audit rules can generate many events. Do not use this ruleset on a production system.

## Completion Standard

Your work is complete when all of the following are true:

1. The persistent audit rules load without an error and do not erase rules supplied by an earlier rules file.
2. A controlled privileged action produces the expected local audit event and a matching Graylog message.
3. Graylog stores searchable `audit_key`, `audit_auid`, `threat_category`, and `mitre_candidate` fields for applicable events.
4. Each dashboard panel displays actual test data and uses the required time range and grouping.
5. A single privilege-escalation event does not satisfy the repeated-escalation definition, while more than three matching events from one audit user within five minutes do.
6. Your submitted files and verification record are complete, readable, and contain no passwords or other secrets.

## First Action: Record the Baseline

Create a private Lab 12 working area in your home directory with separate locations for the Graylog deployment and evidence. Before changing the VM, record:

- the host name and current date and time;
- whether `auditd` and `rsyslog` are active;
- the current audit subsystem status and loaded rules; and
- the installed Docker Compose version.

Save the results in `~/lab12/evidence/verification.md`. Identify any existing audit rules that must remain in effect. Resolve an inactive audit service or an unavailable Docker Compose installation before continuing.

---

## Part 1 - Configure and Verify `auditd` Forwarding

### 1.1 Enable the audit dispatcher plug-in

Install the Ubuntu package that supplies the `audisp-syslog` plug-in. Configure `/etc/audit/plugins.d/syslog.conf` so the plug-in is:

- active;
- outbound;
- connected to the built-in syslog path;
- using the informational syslog priority; and
- emitting string-formatted records.

Restart `auditd` and confirm that it returns to an active state. Preserve other course-image settings unless they conflict with these required end states.

### 1.2 Create persistent audit rules

Create `/etc/audit/rules.d/99-cyber-lab12.rules`. Organize the file with section comments and implement the following interfaces exactly so later pipeline, dashboard, and detection work can depend on them:

| Required audit key | Activity that must be recorded |
|---|---|
| `priv_escalation` | A 64-bit process execution running as UID 0 when the original audit user is an interactive user rather than an unset login identity. |
| `sudo_exec` | Execution of the system's `sudo` program. |
| `su_exec` | Execution of the system's `su` program. |
| `identity` | Writes or attribute changes to the local password and shadow files. |
| `sudoers` | Writes or attribute changes to the main sudoers file or its include directory. |
| `cron_change` | Writes or attribute changes to system and user cron configuration locations. |
| `ssh_keys` | Writes or attribute changes beneath the root account's and your account's SSH directories. |
| `tmp_exec` | Writes or execution activity beneath `/tmp` and `/var/tmp`. |
| `shm_exec` | Writes or execution activity beneath `/dev/shm`. |
| `access_denied` | 64-bit file-open attempts rejected with either an access-denied or operation-not-permitted result. |

The finished ruleset must cover the root account's SSH directory and the SSH directory belonging to your actual login account. All required watches must load successfully.

Do not place a delete-all-rules directive in this lab-specific file. Such a directive could silently remove baseline rules loaded from earlier files.

Use the standard persistent-rule tooling to validate, load, and list the combined ruleset. Stop and correct any reported rule error rather than treating a partially loaded ruleset as success.

### 1.3 Generate a controlled local event

Before testing, predict which required audit keys a benign privileged command should produce and which login identity should appear as its audit user. Generate the action, locate the associated records with the audit search tools, and check the recent syslog copy.

Record the expected key, observed key, audit user, timestamp, and your interpretation in `verification.md`. If the local audit event exists but no syslog copy appears, investigate the dispatcher configuration and the recent `auditd` and `rsyslog` service records before changing the audit rules.

---

## Part 2 - Deploy Graylog and Prove End-to-End Ingestion

### 2.1 Start the course-provided stack

Place the Learning Suite Compose file and its required environment file in `~/lab12/graylog/`. Validate the resolved Compose configuration before starting it, then deploy the stack and confirm that every required container reaches its expected running or healthy state.

If a container exits, use its recent container logs to identify the failure rather than repeatedly restarting the entire stack. Sign in with the credentials configured by the course-provided environment. Replace any shared default with a unique password, and keep that password out of shell history and submitted evidence.

### 2.2 Create a Syslog UDP input

Create a Graylog **Syslog UDP** input titled `auditd-syslog`. Choose a nonprivileged UDP container port and ensure that:

- the input is active on the Graylog node;
- the Compose file publishes the selected container port to a known host UDP port; and
- the destination in the forwarding configuration uses that published host port.

Inspect the resolved Compose configuration rather than assuming that host port `514` is available. Record the chosen container and host ports in your verification record.

### 2.3 Forward and verify

Create `/etc/rsyslog.d/99-graylog.conf` so local syslog messages are forwarded over UDP to the published Graylog input on the same VM using the modern syslog protocol format. Validate the configuration before restarting `rsyslog`.

Generate a new benign privileged process containing a unique, timestamped marker in its arguments. Search for that marker in Graylog and correlate it with the audit event identifier shared by the associated audit records.

Record the marker, local audit timestamp, Graylog timestamp, source, and message identifier in `verification.md`. If Graylog receives ordinary syslog messages but not the audit event, investigate the boundary between `auditd` and `rsyslog`. If Graylog receives neither, investigate the input state, UDP port mapping, host firewall, and forwarding configuration.

---

## Part 3 - Parse and Enrich Audit Events

Graylog cannot reliably search or group on an audit key or audit user until the raw values have been extracted into fields. Build the pipeline in two stages: parsing first, then enrichment.

### 3.1 Parse the fields

Confirm that Graylog's Pipeline Processor is enabled after the Message Filter Chain. Create a pipeline named `auditd-enrichment` and connect it to the stream that receives the audit messages.

In Stage 0, create a rule that applies only to Linux audit messages and extracts:

- the audit rule key into `audit_key`; and
- the audit login identity into `audit_auid`.

Use a real raw message from Part 2 in the rule simulator. Confirm that both fields contain the expected values before connecting the rule to live traffic. If the course image formats a field differently from the documentation example, adapt the parser and record the reason in your verification record.

### 3.2 Enrich the parsed events

In Stage 1, classify every required audit key into one of these six `threat_category` values:

| Required category | Audit keys it must cover |
|---|---|
| `Privilege Escalation` | `priv_escalation`, `sudo_exec` |
| `Privilege Configuration` | `su_exec`, `sudoers` |
| `Account or Identity Change` | `identity` |
| `Persistence` | `cron_change`, `ssh_keys` |
| `Suspicious Temporary-Path Activity` | `tmp_exec`, `shm_exec` |
| `Access Failure` | `access_denied` |

For every mapping, set `mitre_candidate` to a defensible ATT&CK technique or to `Unresolved` when the audit evidence is insufficient. In `verification.md`, justify each candidate and state at least one interpretation limit. An audit key identifies the rule that matched; it does not prove attacker intent or, by itself, establish a technique.

Simulate every enrichment path before relying on live messages. Export the parser and all enrichment rules as JSON. Generate a fresh privileged test event and verify that the applicable live message contains all four searchable fields required by the completion standard.

---

## Part 4 - Build and Test the Security Operations Dashboard

Create a dashboard named `Lab 12 Security Operations`. Each panel must display real test data rather than an empty widget or manually entered value.

| Panel | Type | Required data and grouping | Time range |
|---|---|---|---|
| Privilege Escalations | Single number | Count events carrying the `priv_escalation` audit key. | Last 24 hours |
| Events by Threat Category | Pie chart | Include enriched events and group them by `threat_category`. | Last 24 hours |
| Top Audit Users by Sudo Execution | Bar chart | Include `sudo_exec` events and group them by `audit_auid`. | Last 7 days |
| Access Denied Events | Data table | Include `access_denied` events and display timestamp, source, and message. | Last 24 hours |
| Security Event Timeline | Line chart | Plot enriched events over time and separate the series by `threat_category`. | Last 24 hours |

For each panel, record the test action that should affect it, your predicted change, the observed change, and your assessment of the panel's intended use. If a panel is empty, you may temporarily widen its time range to diagnose the cause, but restore the required range before grading.

---

## Part 5 - Detect Repeated Privilege Escalation

Create an enabled **Filter & Aggregation** event definition with these required properties:

- Title: `Repeated Privilege Escalation`
- Priority: High
- Source: the stream receiving the enriched audit messages
- Population: events carrying the `priv_escalation` audit key
- Search window: the previous 5 minutes
- Execution interval: every 1 minute
- Grouping field: `audit_auid`
- Condition: grouped message count `> 3`

Attach an HTTP notification only if the course environment provides an approved test webhook. Otherwise, verify the generated event in Graylog's Alerts & Events view; do not send lab alerts to a real operational channel.

Allow earlier test events to age out of the search window. Generate one matching event, predict that the definition will remain inactive, and confirm that no new event appears after an evaluation interval. Then generate at least five benign matching events rapidly for the same audit user and confirm that a new event appears.

Record the event-definition name, grouped audit user, message count, timestamp, and both test outcomes. If the expected event does not appear, check the definition preview, time window, execution schedule, stream, grouping field, and enriched source messages before changing the threshold.

---

## Verification Record

Keep `~/lab12/evidence/verification.md` concise. Use one row per required test:

| Test | Prediction | Evidence observed | Interpretation / next decision |
|---|---|---|---|
| Baseline and loaded rules |  |  |  |
| Local audit event |  |  |  |
| End-to-end forwarding |  |  |  |
| Field parsing and enrichment |  |  |  |
| Dashboard panels |  |  |  |
| Detection negative test |  |  |  |
| Detection positive test |  |  |  |

Add a short mapping table listing each audit key, its `threat_category`, your `mitre_candidate`, the evidence that supports that candidate, and one interpretation limit.

Finish with two brief responses:

1. Name one important activity the current ruleset would not record.
2. Name one additional piece of evidence an analyst would need before treating one of your ATT&CK candidates as a supported finding.

Use message identifiers, timestamps, field values, and short output excerpts as evidence. Do not paste entire logs or include passwords, tokens, or the Graylog environment file.

## Troubleshooting and Help

Work from the earliest failed boundary:

1. **Rule load:** validate the persistent rules and compare them with the loaded ruleset.
2. **Local event:** search recent audit records by the expected key and event identifier.
3. **Dispatcher and syslog:** inspect the plug-in state, configuration validation, and recent service records.
4. **Network input:** compare the Compose UDP mapping, Graylog input state, destination port, and host firewall.
5. **Parsing:** simulate the rule with the exact raw message that failed.
6. **Dashboard or detection:** verify the stream, time range, field name, grouping, and definition preview.

When asking for help, include the expected result, the observed result, the earliest boundary that failed, one relevant error or message identifier, what you already tested, and a focused question. Redact secrets before sharing output.

## Deliverables

Submit these artifacts from the provisioned VM:

- `/etc/audit/rules.d/99-cyber-lab12.rules`, with section comments retained;
- `/etc/audit/plugins.d/syslog.conf`;
- `/etc/rsyslog.d/99-graylog.conf`;
- exported JSON containing the parser and all enrichment rules;
- a Graylog content pack or equivalent export containing the dashboard and event definition; and
- `~/lab12/evidence/verification.md` with every required test, the mapping table, and the two limitation responses.

Leave the configured services, input, pipeline, dashboard, and event definition available on `cyber-lab12-log01` for instructor verification. Do not submit the Compose environment file, passwords, API tokens, or full raw logs.

## Grading

| Item | Evidence used for grading | Points |
|---|---|---:|
| Persistent audit rules and syslog forwarding | Valid configurations, loaded rules, and local-event verification | 20 |
| Graylog deployment and ingestion | Healthy stack and correlated end-to-end test event | 15 |
| Parsing and enrichment | Searchable fields, exported rules, simulation, and justified mappings | 20 |
| Security operations dashboard | Five correctly configured panels with known test data | 20 |
| Repeated-escalation detection and verification | Correct grouped condition plus negative and positive tests | 15 |
| **Total** |  | **90** |

## Technical References

Use the Graylog documentation version selector to match the 5.x release supplied for the lab; labels and menu locations can differ in newer releases.

- [Graylog: Build Pipeline Rules](https://go2docs.graylog.org/current/making_sense_of_your_log_data/pipeline_usage.html)
- [Graylog: Pipeline Functions Reference](https://go2docs.graylog.org/current/making_sense_of_your_log_data/functions_index.html)
- [Graylog: Event Definitions](https://go2docs.graylog.org/current/interacting_with_your_log_data/event_definitions.html)
- [`auditctl(8)` manual](https://man7.org/linux/man-pages/man8/auditctl.8.html)

[← Back to Labs]({{ site.baseurl }}/labs/)
