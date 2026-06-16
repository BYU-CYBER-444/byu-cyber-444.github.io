---
title: "IT HW 13 - Policy Package: AUP, Data Classification & Vendor Security"
parent: Homework
nav_order: 113
---

# IT HW 13 - Policy Package: AUP, Data Classification & Vendor Security
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
| **Assignment** | IT HW 13 |
| **Points** | 100 |
| **Due** | Week 14 |
| **Track** | IT |

---

## Description

Produce a three-document policy package for Valley Medical Group. These are production-ready documents - not rough drafts. Each policy will be reviewed as if it were going to legal and the Board for approval. Vague language ("systems should be secured appropriately") will lose points.

### Document 1 - Acceptable Use Policy (30 pts)

Build on your Lab 13 AUP draft and finalize it:

- **Policy statement** - why this policy exists and what authority enforces it
- **Scope** - exactly which systems, users (including contractors, vendors with remote access), and data types are covered
- **Authorized use** - what staff may do on organizational systems (be specific enough that a new employee knows exactly what is and is not allowed)
- **Prohibited activities** - minimum 12 specific prohibitions with no ambiguity (not "inappropriate use of the internet" - name the behavior)
- **AI assistant use** - incorporate your HW 12 proposal: what staff may submit to the clinical AI tool vs. what is prohibited; what constitutes a policy violation when using AI
- **Monitoring disclosure** - inform staff that activity on organizational systems is subject to monitoring and logging; cite the legal basis
- **Violation consequences** - tiered: minor violation / major violation / criminal referral
- **Acknowledgment block** - formatted signature block that employees sign at onboarding and annually

### Document 2 - Data Classification Policy (35 pts)

A standalone policy covering the full data lifecycle:

- **Policy statement and purpose**
- **Scope** - systems, data types, and personnel covered
- **Classification tiers** - exactly 4 tiers. For each tier define:
  - Tier name and description
  - Examples specific to a healthcare environment (minimum 4 examples per tier)
  - Handling requirements: storage (encryption at rest - specify algorithm and key management), transmission (TLS version minimum, acceptable methods), access control (who can access by role), physical media handling, disposal method (NIST 800-88 compliance level)
  - Labeling requirements (how is this data labeled in documents, email, systems?)
- **Classification process** - who is responsible for classifying new data, what is the default classification for unclassified data, and how is reclassification requested
- **Roles and responsibilities** - Data Owner, Data Custodian, Data Steward, all users - define each role's specific obligations
- **Compliance and audit** - how compliance is verified and at what frequency

### Document 3 - Vendor & Third-Party Access Policy (35 pts)

This policy governs how third-party vendors (MSPs, software vendors, contractors) are granted access to Valley Medical Group's systems:

- **Vendor onboarding requirements** - minimum security controls a vendor must demonstrate before being granted access (at minimum: SOC 2 Type II or equivalent, MFA for all remote access accounts, signed BAA if they will access PHI)
- **Access provisioning process** - approval chain, how vendor accounts are created (named accounts only - no shared credentials), what systems/data vendors can access and how this is scoped
- **Remote access requirements** - which VPN/jump host/PAM tool vendors must use; no direct RDP/SSH to production without going through the jump host; session recording requirements
- **Ongoing monitoring** - how vendor access is monitored (logging requirements, review frequency, what triggers immediate access revocation)
- **Vendor access review** - quarterly access review process: who conducts it, what is reviewed, what happens to accounts where the vendor relationship has ended
- **Incident notification** - if a vendor discovers or causes a security incident affecting Valley Medical Group systems, what must they notify you of and within what timeframe? (Include a template notification that vendors must submit.)
- **Termination of access** - exactly how vendor access is revoked at end of engagement (account disabled, VPN certificate revoked, credentials rotated, access log archived)

---

## Deliverable(s)

Write all three policies in `homework/it-hw-13.md` (or as three linked sub-pages if you prefer). Each policy must be clearly delineated with a version number, effective date, owner, and approval signature block.

Open a PR titled `IT HW 13 - Policy Package` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| AUP - 12+ specific prohibitions, AI use section, monitoring disclosure, acknowledgment block | 30 |
| Data classification - 4 tiers, 4+ examples each, full handling requirements per tier | 35 |
| Vendor policy - onboarding, access scoping, monitoring, incident notification template, termination | 35 |

---

## Tip

{: .tip }
Read one real AUP from a public institution (BYU's or your previous employer's) and one from a healthcare organization before writing yours. Notice how specific the language is in the prohibition section - that specificity is what makes a policy enforceable.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 4 - Policy Governance Framework & Regulatory Mapping (30 pts)

**Policy Lifecycle Governance Framework (15 pts)**

Your three policies exist in isolation. Graduate students must design the **governance structure** that makes policy management sustainable at scale. Produce `it-hw-13-governance-framework.md`:

1. **Policy Lifecycle** - document each stage: Proposal → Review → Approval → Publication → Exception Handling → Annual Review → Deprecation. For each stage, specify: who initiates it, who participates, what artifact is produced, and how long the stage should take.

2. **Approval Authority Matrix** - define who can approve each policy type (AUP, Data Classification, Vendor Access), what minimum quorum is required (e.g., CISO + Legal + one business VP), and who has veto authority.

3. **Exception Request Template** - write a formal exception request form that captures: policy being excepted, business justification, risk assessment, compensating controls, approval chain, duration of exception, and review date. Exceptions should be time-limited and automatically expire.

4. **Policy Metrics** - define 5 KPIs for measuring policy program health: e.g., % of employees who have acknowledged each policy in the last 12 months, average time-to-remediate policy violations, number of open exceptions, etc. Specify how each metric would be measured.

**Regulatory Compliance Mapping (15 pts)**

Map your three policies (AUP, Data Classification, Vendor Access) against **ISO/IEC 27001:2022 Annex A** controls. For each Annex A control domain:

1. Identify which of your policies (if any) satisfies or partially satisfies it
2. For domains where none of your three policies provide coverage, note the gap
3. Produce a heatmap-style coverage table showing which domains are: Fully Covered, Partially Covered, Not Covered

Identify your top 3 coverage gaps and write a brief policy stub (title, scope, 3 key requirements) for each gap policy you would need to write to achieve ISO 27001 certification readiness.


[← Back to Homework]({{ site.baseurl }}/homework/)
