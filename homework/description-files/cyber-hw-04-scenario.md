---
title: "CYBER HW 4 - Acme Financial Corp Environment Profile"
parent: Homework
nav_exclude: true
---

# Acme Financial Corp - Environment Profile
{: .no_toc }

{: .note }
This is the reference scenario for [CYBER HW 4]({% link homework/cyber-hw-04.md %}) Part 2. It gives you the specific facts about Acme's infrastructure, staffing, and existing tooling your Vulnerability Management Policy needs to be written against. Don't invent facts that contradict this document, and don't leave obvious gaps unaddressed just because the profile doesn't spell out every detail - a real policy author would ask follow-up questions or make (and state) a reasonable assumption.

---

## Company Overview

Acme Financial Corp is a mid-sized regional lending and payment-processing company, ~200 employees, headquartered in a single office with all infrastructure hosted in a co-located data center (no cloud footprint at this time). Acme is subject to both **SOX** (public financial reporting controls) and **PCI-DSS v4.0** (it processes and stores cardholder data directly - it is not fully outsourcing to a payment processor). Acme has never failed a PCI-DSS assessment, but its most recent Report on Compliance (RoC) included several "compensating control" notations in the vulnerability management area that the QSA flagged as unsustainable long-term.

## Infrastructure Inventory

| Asset Class | Count | OS / Platform | Notes |
|---|---|---|---|
| Public-facing web/app servers | 6 | Ubuntu 22.04 LTS, Nginx + internal app | In the cardholder data environment (CDE) DMZ |
| Application/API servers | 10 | Ubuntu 22.04 LTS | CDE, internal network |
| Database servers | 4 | Ubuntu 22.04 LTS, PostgreSQL 15 | CDE, internal network, holds cardholder data |
| Windows domain controllers | 2 | Windows Server 2022 | Not in CDE, but authenticates CDE admin access |
| Windows file/print servers | 3 | Windows Server 2022 | Not in CDE |
| Employee workstations | ~200 | Windows 11 | Not in CDE (no cardholder data touches endpoints) |
| Network devices (switches, firewalls, load balancers) | 14 | Mixed vendor | Some in CDE boundary, managed by Network Engineering |

## Staffing

- **CISO** (1) - reports to the CFO, accountable for the security program overall, final escalation point for exceptions
- **Security Team** (3 people: 1 Security Engineer, 1 GRC Analyst, 1 SOC Analyst) - owns vulnerability identification, scanning, and compliance reporting; does **not** hold admin credentials on production systems
- **System Administration Team** (4 people, split ~2 Linux / 2 Windows) - owns patch deployment and remediation on the systems they administer
- **Network Engineering Team** (2 people) - owns network device configuration and patching
- **Change Advisory Board (CAB)** - meets weekly, chaired by the IT Director, includes a Security Team representative; approves production changes above a defined risk threshold

This staffing is a hard constraint: a policy that assumes a dedicated in-house Red Team, a 24/7 SOC, or a headcount Acme doesn't have will not be operationally realistic. Compensating design (e.g., relying on an outsourced ASV, or a smaller SOC doing double duty on business hours only) is expected and should be called out explicitly.

## Current Tooling

- **Vulnerability scanning:** Acme owns a Tenable Nessus Professional license (unlimited internal scanning, credentialed and uncredentialed both supported). Acme does **not** currently have a contract with a PCI SSC Approved Scanning Vendor (ASV) for external scanning - this is a known, unresolved gap the QSA has already flagged, and your policy should address how Acme will close it.
- **Patch deployment:** Linux systems are managed via Ansible (existing playbooks handle package updates but do not yet enforce SLA timelines). Windows systems are managed via WSUS.
- **Ticketing/change tracking:** Acme uses Jira Service Management for both IT tickets and CAB change records.
- **Vulnerability intelligence sources currently in use:** none formalized - the QSA's prior finding specifically called out that vulnerability awareness is "ad hoc, dependent on individual staff monitoring vendor mailing lists."

## Prior Audit Findings (from the most recent PCI-DSS RoC)

The QSA's Report on Compliance included three notations relevant to this policy, all currently covered only by temporary compensating controls that are not considered sustainable:

1. No formal, documented risk-ranking process for newly identified vulnerabilities (Req. 6.3.1).
2. No external ASV scanning contract in place (Req. 11.3.2).
3. The same System Administration staff who apply patches also perform ad hoc verification scans on their own systems - no segregation of duties (Req. 11.3.1.1).

Your policy must resolve all three of these, not merely acknowledge them.

## Business Constraints

- Acme's application has planned maintenance windows on the second and fourth Saturday of each month, 1:00 AM - 5:00 AM, during which production changes (including patch deployment) are preferred but not exclusively required - the CAB can approve out-of-window changes for urgent remediation.
- The Security Team's 3 headcount means daily/24-7 scan monitoring is not realistic; assume scan review happens during business hours, with a documented after-hours escalation path for anything CISA KEV-flagged or actively exploited.
- SOX requires that any control described in this policy that is relied upon for financial-reporting-system integrity (the database servers count) be evidenced and auditable - your policy's tracking/reporting mechanisms need to produce evidence a SOX auditor could review, not just a security team's internal notes.

---

[← Back to CYBER HW 4]({% link homework/cyber-hw-04.md %})
