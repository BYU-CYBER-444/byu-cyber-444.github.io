---
title: "IT LAB 4 - ITSM Change Management Workflow"
parent: Labs
nav_order: 104
---

# IT LAB 4 - ITSM Change Management Workflow
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 4 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Draft complete RFC documentation for a Normal change following ITIL 4 change management practice
- Simulate a CAB review meeting with structured risk discussion
- Execute a Standard change using a pre-approved change template
- Handle an Emergency change with expedited approval and mandatory PIR
- Complete a post-implementation review (PIR) identifying lessons learned and process improvements

---

## Tools Required

- ITSM platform (Jira Service Management or instructor-provided)
- Word processor or Markdown editor for RFC documentation
- Spreadsheet for risk register

---

## Background

ITIL 4 defines three change types: **Standard** (pre-approved, low risk, documented procedure), **Normal** (requires authorization via CAB or designated approver, risk-assessed), and **Emergency** (urgent, bypasses normal CAB but requires post-implementation review). Skipping proper change documentation is the leading cause of failed changes in enterprise environments - the 2021 Facebook outage (BGP route withdrawal causing 6-hour global outage) was a Normal change with an incomplete rollback procedure.

---

## Procedure

### Part 1 - Normal Change: RFC for DNS Infrastructure Upgrade (60 min)

Your organization is upgrading its primary DNS infrastructure from BIND 8 to BIND9 with DNSSEC. You will write a complete RFC.

**Complete the following RFC template:**

```
REQUEST FOR CHANGE (RFC)

RFC Number:         CHG-2024-0042
Title:              Primary DNS Infrastructure Upgrade - BIND8 to BIND9 with DNSSEC
Change Type:        Normal
Priority:           High
Requestor:          [Your Name], Senior Systems Engineer
Date Submitted:     [Date]
Proposed Change Window: Saturday [Date+7] 02:00-06:00 UTC


1. DESCRIPTION OF CHANGE
   Upgrade primary authoritative DNS server from BIND8 (EOL since 2015) to
   BIND9.18 LTS with DNSSEC signing enabled for all internal zones.

2. BUSINESS JUSTIFICATION
   BIND8 has 23 unpatched CVEs. DNSSEC prevents cache poisoning attacks
   (Kaminsky attack vector). Required for compliance with internal security
   policy SEC-NET-007 (DNS Security Standards).

3. SCOPE AND AFFECTED SYSTEMS
   - Primary: ns1.lab.internal (10.0.0.1)
   - Secondary: ns2.lab.internal (10.0.0.2) - cascading update
   - Affected clients: All 847 domain-joined workstations and servers
   - Downstream impact: DHCP option 6 points to ns1; will auto-failover to ns2

4. RISK ASSESSMENT

   Risk ID | Risk Description           | Likelihood | Impact | Mitigation
   --------|----------------------------|------------|--------|---------------------------
   R-01    | Zone file syntax error      | Low        | High   | named-checkzone pre-flight
   R-02    | DNSSEC key rollover failure | Medium     | High   | Test in staging 72hr prior
   R-03    | Legacy client DNSSEC issues | Low        | Medium | Set DNSSEC-validation auto
   R-04    | Change window overrun       | Medium     | Medium | 4hr window; rollback at 3hr

   Overall Risk Rating: MEDIUM

5. IMPLEMENTATION PLAN
   Step 1 (02:00): Snapshot ns1 VM
   Step 2 (02:05): Install BIND9: apt install bind9 bind9utils
   Step 3 (02:20): Migrate zone files and validate: named-checkzone
   Step 4 (02:35): Generate DNSSEC keys: dnssec-keygen -a RSASHA256 -b 2048
   Step 5 (02:50): Sign zones: dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum)
   Step 6 (03:10): Restart named and verify: dig +dnssec lab.internal SOA
   Step 7 (03:20): Update ns2 as secondary; verify zone transfer
   Step 8 (03:40): Validate from 5 client endpoints
   Step 9 (03:50): Update monitoring (Prometheus named_exporter)

6. ROLLBACK PLAN
   Trigger: Any verification failure or service degradation > 15 minutes
   Procedure:
     1. Restore ns1 from VM snapshot (estimated 8 minutes)
     2. Flush DNS cache on downstream resolvers: rndc flush
     3. Verify resolution from clients
     4. Notify stakeholders; schedule re-attempt

7. TESTING PLAN
   Pre-change (72hr before):
     - Deploy identical change in staging environment
     - Run full test suite: all A, AAAA, MX, TXT records resolve correctly
     - Verify DNSSEC validation: dig +dnssec +cd lab.internal SOA
   Post-change validation:
     - Resolution test from 5 endpoints across subnets
     - DNSSEC chain validation: delv @127.0.0.1 lab.internal SOA
     - Monitor DNS query error rate for 30 minutes post-change

8. COMMUNICATION PLAN
   T-72hr: Email to all IT staff with maintenance window notice
   T-1hr:  Reminder email; confirm on-call contact available
   T+0:    Change begins; update ITSM ticket status to In Progress
   T+end:  Change complete email or escalation to incident bridge

9. APPROVAL REQUIRED
   CAB Chair: _________________ Date: _________
   Change Owner: ______________ Date: _________
   Security Review: ___________ Date: _________
```

Fill in all fields completely. The risk table must have at least 4 risks with realistic mitigations.

---

### Part 2 - CAB Simulation (30 min)

Simulate a CAB review meeting for CHG-2024-0042. Write a structured **CAB Meeting Minutes** document:

```
CAB MEETING MINUTES
Date: [Date]
Attendees: IT Ops Manager (chair), Senior SysAdmin, Network Engineer, Security Analyst

Changes Reviewed: CHG-2024-0042

DISCUSSION POINTS:
1. Risk R-02 (DNSSEC key rollover failure): Security Analyst raised concern that
   KSK/ZSK key rotation schedule was not documented. Decision: Add key rotation
   schedule to implementation plan before approval.

2. Change window overlap: Network Engineer noted a scheduled firewall maintenance
   window on the same Saturday. Decision: DNS change moved to following Saturday.

3. Rollback time estimate: IT Ops Manager questioned 8-minute VM restore estimate.
   Senior SysAdmin confirmed testing in staging showed 6-minute restore. Acceptable.

DECISION: APPROVED with conditions:
  - Key rotation schedule documentation added to RFC by [Date+2]
  - Change rescheduled to [Date+14] 02:00-06:00 UTC

Action Items:
  [Your Name]: Update RFC with key rotation schedule - Due [Date+2]
  [Your Name]: Rebook change window in maintenance calendar - Due [Date+3]
```

Write at least 3 substantive discussion points with realistic technical challenges a CAB would raise.

---

### Part 3 - Standard Change: Pre-Approved Template (30 min)

Standard changes are pre-approved and require no CAB review. Create a Standard Change Template for "Add DNS CNAME Record":

```
STANDARD CHANGE TEMPLATE
Template ID:    SCT-DNS-003
Title:          Add/Remove DNS CNAME Record
Risk Level:     Low
Pre-Approved:   Yes - IT Operations Manager

ELIGIBILITY CRITERIA (all must be true):
   Target hostname does not exist in DNS (no record collision)
   CNAME does not create a circular reference
   Requestor has submitted a valid service request ticket

IMPLEMENTATION PROCEDURE:
  1. SSH to ns1.lab.internal
  2. Edit /etc/bind/db.lab.internal
  3. Add line: [alias] IN CNAME [target].
  4. Increment SOA serial by 1
  5. Run: sudo named-checkzone lab.internal /etc/bind/db.lab.internal
  6. Run: sudo rndc reload lab.internal
  7. Verify: dig @127.0.0.1 [alias].lab.internal CNAME +short
  8. Update ITSM ticket with before/after zone file diff

ROLLBACK:
  Remove the added line; restore previous serial; reload named.

EVIDENCE REQUIRED:
  - Before/after zone file diff
  - dig verification output
  - ITSM ticket number
```

Now execute this Standard Change: add a CNAME `portal.lab.internal` → `www.lab.internal`. Document all 8 steps with actual output.

---

### Part 4 - Emergency Change (30 min)

**Scenario:** A critical vulnerability (CVE-2024-XXXX) in your production Apache web server is being actively exploited. The security team requires immediate deployment of a WAF rule and service restart. Normal change window is 4 days away.

Create an Emergency Change ticket:

```
EMERGENCY CHANGE
ECR-2024-0008
Title: Emergency WAF Rule Deployment - CVE-2024-XXXX Mitigation
Priority: Critical
Business Impact: Active exploitation of web server; potential data exfiltration
Expedited Approver: IT Operations Manager (verbal approval obtained 14:32)

Implementation (completed during emergency window 14:45-15:10):
  1. Deployed ModSecurity rule blocking the attack vector
  2. Restarted Apache service
  3. Verified application functionality
  4. Confirmed attack traffic blocked in access logs

Mandatory Post-Implementation Review: Due within 24 hours
```

Write the mandatory PIR for this Emergency Change (minimum 300 words). The PIR must address:
- Why the emergency occurred (was this preventable?)
- Was the expedited approval process followed correctly?
- What permanent fix is needed to prevent recurrence?
- Should this have been a Normal change with faster scheduling rather than Emergency?

---

### Part 5 - Change Metrics Analysis (30 min)

Using your four change records (one Normal, one Standard, one Emergency + PIR), produce a **Change Management Dashboard** report:

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Change Success Rate | X% | ≥ 95% | / |
| Emergency Change Ratio | X% | ≤ 5% | / |
| Average CAB Review Time | X days | ≤ 3 days | / |
| PIR Completion Rate | X% | 100% | / |
| Failed Changes | X | 0 | / |

Write a 200-word analysis: What does the Emergency change ratio tell you about your change management maturity? What industry benchmark (ITIL, DORA metrics) applies here?

---

## Deliverables

1. Completed RFC for CHG-2024-0042 (all 9 sections)
2. CAB Meeting Minutes with 3+ discussion points and decision
3. Standard Change Template + executed CNAME change with evidence
4. Emergency Change ticket + PIR (300+ words)
5. Change Metrics Dashboard table + 200-word analysis

---

## Grading

| Item | Points |
|------|--------|
| RFC - all sections complete, risk table with mitigations | 25 |
| CAB minutes - realistic discussion, decision, action items | 20 |
| Standard change - template + executed with evidence | 20 |
| Emergency change + PIR | 20 |
| Metrics dashboard + analysis | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Change Failure Rate Root Cause Analysis
>
> Research three publicly documented failed IT changes that caused significant outages. For each case:
> 1. Identify which ITIL 4 change management control failed (risk assessment, CAB review, testing, rollback procedure, communication)
> 2. Estimate the business cost using available data (or estimate from outage duration × industry average downtime cost)
> 3. Propose a specific process improvement that would have prevented the failure
>
> Suggested cases: 2021 Facebook BGP withdrawal, 2017 Amazon S3 outage (typo in runbook), 2016 Delta Air Lines power failure.
>
> Write a 600-word **Change Management Lessons Learned Report** suitable for a CAB chair.
>
> ### Extension B - Automated RFC Pre-Screening
>
> CABs spend significant time reviewing incomplete RFCs. Design an automated RFC pre-screening tool:
>
> 1. Define a scoring rubric: assign 1-5 points to each RFC section (Description, Justification, Risk Table, Implementation Plan, Rollback Plan, Testing Plan, Communication Plan). Minimum passing score = 28/35.
>
> 2. Write a Python script that reads an RFC text file and scores it:
>    - Uses keyword matching / section presence detection
>    - Checks risk table has ≥ 3 risks with mitigations
>    - Checks rollback plan contains a trigger condition and time estimate
>    - Outputs: Section scores, total score, Pass/Fail, list of missing elements
>
> 3. Run it against your CHG-2024-0042 RFC and attach the output.
>
> Submit the three case analyses (600-word report) and the Python screening tool with sample output.

[← Back to Labs]({{ site.baseurl }}/labs/)
