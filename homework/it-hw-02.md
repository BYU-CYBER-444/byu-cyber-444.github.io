---
title: "IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis"
parent: Homework
nav_order: 102
---

# IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis
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
| **Assignment** | IT HW 2 |
| **Points** | 100 |
| **Due** | Week 3 |
| **Track** | IT |

---

## Description

A junior admin at Acme Financial has handed you three broken configuration files. Your job is to audit them, document your lab implementation, and produce a handoff document a new engineer could use to safely manage this environment.

### Part 1 - Configuration Audit (40 pts)

You are provided three intentionally broken config files on Learning Suite (`IT_HW2_Broken_Configs.zip`). Each file contains **at least 3 errors** - some are syntax errors, some are security misconfigurations, and some are operational mistakes that would cause subtle failures in production.

For each file (`named.conf.local`, `dhcpd.conf`, `exports`), produce an audit table with one row per issue found:

| File | Line # | Issue Type | What is wrong | Correct configuration | Severity (Critical/High/Medium) |
|---|---|---|---|---|---|

You must find **at least 8 issues total** across the three files. For each Critical or High issue, explain what would happen in production if the misconfiguration were left in place.

### Part 2 - Lab Documentation (45 pts)

Using your working configuration from **IT LAB 2**, produce a handoff document covering all three services. This is not a lab report - it is a reference document written for a sysadmin who has never seen this environment before.

For each service (DNS/BIND9, DHCP/ISC, NFS):

1. **Architecture decision record** - why this service is configured the way it is. Include at least one alternative design you considered and why you rejected it. ("I just followed the lab" is not acceptable.)
2. **Key configuration explained** - annotate your actual config file inline, explaining the purpose of every non-default setting. Paste the annotated config directly in the write-up.
3. **Verification runbook** - the exact commands an admin would run to verify the service is healthy from scratch, with the expected output for each command.
4. **Security hardening applied** - list every hardening step you applied beyond the defaults, with the specific config line or command used. Minimum 3 per service.
5. **Failure mode analysis** - for the two most likely failure scenarios for each service: describe the symptom a user would report, the diagnostic commands you would run (in order), and what each command's output would tell you.

### Part 3 - Reflection (15 pts)

Answer in 2-3 paragraphs: In a production environment with 500 clients, what are the operational risks of running DHCP and DNS on the same server as NFS? Propose a tiered service placement strategy that balances cost with resilience, and justify which service you would prioritize making redundant first.

---

## Deliverable(s)

Write your full report in `homework/it-hw-02.md`. Commit your working (corrected) configs to `homework/assets/`:

- `it-hw-02-named.conf.local` - corrected, annotated BIND9 zone config
- `it-hw-02-db.lab.local` - corrected zone file
- `it-hw-02-dhcpd.conf` - corrected DHCP config
- `it-hw-02-exports` - corrected NFS exports file
- `it-hw-02-audit.md` - your config audit table (Part 1)

Open a PR titled `IT HW 2 - Linux Network Services` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Config audit - issues found, severity ratings, impact explanations | 40 |
| Architecture decision records (not just "I did X") | 15 |
| Annotated configs - every non-default setting explained | 15 |
| Verification runbooks - commands + expected output | 10 |
| Security hardening (3+ per service, specific) | 5 |
| Reflection - production reasoning, not lab reasoning | 15 |

---

## Tip

{: .tip }
When writing the failure mode analysis, simulate the failure in your lab VM and capture the actual diagnostic output - don't guess what it looks like.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - High-Availability Architecture & ADRs (30 pts)

**HA Architecture Design (15 pts)**

Design a high-availability version of your three-service architecture suitable for a production environment with 500 clients and a 99.9% uptime SLA. For each service:

- **DNS (BIND9):** Propose either an anycast design (with justification of when anycast is appropriate vs. overkill) or an active-passive failover using `keepalived` + VRRP. Specify which zone data synchronization mechanism you would use and how long it would take for a client to detect and recover from a primary DNS failure.
- **DHCP (ISC DHCP):** Implement ISC DHCP failover protocol in your lab. Document the exact `failover peer` configuration for both primary and secondary, explain the `split` parameter and how load is divided, and demonstrate failover by stopping the primary and showing a client successfully obtaining a lease from the secondary.
- **NFS:** Propose an HA NFS design using either DRBD + Pacemaker + Corosync or a shared storage model (NFS over iSCSI with SCSI-3 reservations). Explain the fencing (STONITH) requirement and why unfenced NFS HA is dangerous (split-brain scenario).

Produce a network architecture diagram (ASCII or linked image) showing all components, VIPs, and failure domains.

**Architecture Decision Records (15 pts)**

Write a formal **Architecture Decision Record (ADR)** for each of the three HA approaches using the Nygard ADR format:

```
# ADR-NNN: [Title]
Date: YYYY-MM-DD
Status: Proposed | Accepted | Deprecated | Superseded
Context: [Why this decision is needed]
Decision: [What we decided]
Alternatives Considered: [Other options evaluated with pros/cons]
Consequences: [What becomes easier, harder, or riskier]
```

Each ADR should be genuinely analytical - "I just followed the lab" is not acceptable. Reference specific failure modes, cost tradeoffs, or operational complexity considerations that drove your choice.

Submit as `it-hw-02-adrs.md`.


[← Back to Homework]({{ site.baseurl }}/homework/)
