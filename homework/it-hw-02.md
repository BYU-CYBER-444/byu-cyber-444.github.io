---
title: "IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis"
parent: Homework
nav_order: 2
---
TODO: check over it
# IT HW 2 - Linux Network Services: Design, Audit & Failure Analysis
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

A junior admin at Acme Financial has handed you three broken configuration files. Your job is to audit them, document an already-deployed working environment, and produce a handoff document a new engineer could use to safely manage this environment.

### Part 1 - Configuration Audit (40 pts)

You are provided three intentionally broken config files: [named.conf]({% link homework/description-files/it-hw-02-named-conf.md %}), [dhcpd.conf]({% link homework/description-files/it-hw-02-dhcpd-conf.md %}), and [exports]({% link homework/description-files/it-hw-02-exports.md %}). Each file contains **at least 3 errors** - some are syntax errors, some are security misconfigurations, and some are operational mistakes that would cause subtle failures in production.

For each file (`named.conf`, `dhcpd.conf`, `exports`), produce an audit table with one row per issue found:

| File | Line # | Issue Type | What is wrong | Correct configuration | Severity (Critical/High/Medium) |
|---|---|---|---|---|---|

You must find **at least 8 issues total** across the three files. For each Critical or High issue, explain what would happen in production if the misconfiguration were left in place.

### Part 2 - Lab Documentation (45 pts)

A colleague already built and deployed this environment on a Rocky Linux 9 host: [named.conf & zone files]({% link homework/description-files/it-hw-02-working-named-conf.md %}), [dhcpd.conf]({% link homework/description-files/it-hw-02-working-dhcpd-conf.md %}), and [exports]({% link homework/description-files/it-hw-02-working-exports.md %}). Using that configuration, produce a handoff document covering all three services. This is not a lab report - it is a reference document written for a sysadmin who has never seen this environment before. (If you completed Lab 2 yourself, your own working configuration should match these closely enough to use interchangeably - this part doesn't require it either way.)

For each service (DNS/BIND, DHCP/ISC, NFS):

1. **Architecture decision record** - why this service is configured the way it is. Include at least one alternative design you considered and why you rejected it. ("That's just how it was configured" is not acceptable.)
2. **Key configuration explained** - annotate the provided config file inline, explaining the purpose of every non-default setting. Paste the annotated config directly in the write-up.
3. **Verification runbook** - the exact commands an admin would run to verify the service is healthy from scratch, with the expected output for each command.
4. **Security hardening applied** - list every hardening decision reflected in the provided configuration, with the specific config line responsible. Minimum 3 per service.
5. **Failure mode analysis** - for the two most likely failure scenarios for each service: describe the symptom a user would report, the diagnostic commands you would run (in order), and what each command's output would tell you.

### Part 3 - Reflection (15 pts)

Answer in 2-3 paragraphs: In a production environment with 500 clients, what are the operational risks of running DHCP and DNS on the same server as NFS? Propose a tiered service placement strategy that balances cost with resilience, and justify which service you would prioritize making redundant first.

Also answer in 2-3 sentences: Lab 2 put your NFS exports on an LVM volume from the start rather than plain disk space. Explain why that choice was made, and what specific operational problem you'd eventually hit running this server for a year with growing data if `/exports` had instead been a plain partition.

---

## Deliverable(s)

Write your full report in `homework/it-hw-02.md`. Commit your working (corrected) configs to `homework/assets/`:

- `it-hw-02-named.conf` - corrected, annotated BIND config
- `it-hw-02-lab.internal.zone` - corrected forward zone file
- `it-hw-02-10.0.0.rev` - corrected reverse zone file
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

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section. Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - DNS High-Availability Architecture & ADR (30 pts)

**HA Architecture Design (15 pts)**

Design a high-availability version of the DNS service suitable for a production environment with 500 clients and a 99.9% uptime SLA. Choose **one** approach and justify it over the other:

- An **anycast design** - justify when anycast is appropriate vs. overkill for an environment this size, and what routing infrastructure (BGP, IGP) it presupposes that a 500-client organization may or may not already run.
- An **active-passive failover** using `keepalived` + VRRP - specify the VIP, the failover trigger condition, and the exact health-check configuration that decides when to fail over.


Produce a network architecture diagram (ASCII or linked image) showing both DNS nodes, the VIP or anycast address, and the failure domain each node sits in.

**Architecture Decision Record (15 pts)**

Write a formal **Architecture Decision Record (ADR)** for your chosen HA approach using the Nygard ADR format:

```
# ADR-NNN: [Title]
Date: YYYY-MM-DD
Status: Proposed | Accepted | Deprecated | Superseded
Context: [Why this decision is needed]
Decision: [What we decided]
Alternatives Considered: [Other options evaluated with pros/cons]
Consequences: [What becomes easier, harder, or riskier]
```

The ADR should be genuinely analytical - "that's just how it was configured" is not acceptable. Reference specific failure modes, cost tradeoffs, or operational complexity considerations that drove your choice, and treat the "Alternatives Considered" section as a real comparison against the approach you didn't pick, not a formality.

Submit as `it-hw-02-dns-ha-adr.md`.


[← Back to Homework]({{ site.baseurl }}/homework/)
