---
title: "IT HW 6 - Policy Package: AUP, Data Classification & Vendor Security"
parent: Homework
nav_order: 6
---

# IT HW 6 - Policy Package: AUP, Data Classification & Vendor Security
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Produce a three-document policy package for Riverbend Community Bank, using the [Organizational & Vendor Profile]({% link homework/description-files/it-hw-06-org-profile.md %}) for the staffing, systems, data, and vendor facts your policies need to be written against. These are production-ready documents - not rough drafts. Each policy will be reviewed as if it were going to legal and the Board for approval. Vague language ("systems should be secured appropriately") will lose points.

### Document 1 - Acceptable Use Policy (27 pts)

Riverbend Community Bank has a [draft Acceptable Use Policy]({% link homework/description-files/it-hw-06-draft-aup.md %}) that was written years ago and never formally adopted. It is thin, vague, and missing entire required sections. Read it critically, identify every gap against the requirements below, and write the complete, production-ready policy that closes every gap you found - do not just patch the draft's wording:

- **Policy statement** - why this policy exists and what authority enforces it
- **Scope** - exactly which systems, users (including contractors, vendors with remote access), and data types are covered
- **Authorized use** - what staff may do on organizational systems (be specific enough that a new employee knows exactly what is and is not allowed)
- **Prohibited activities** - minimum 12 specific prohibitions with no ambiguity (not "inappropriate use of the internet" - name the behavior)
- **AI assistant use** - RCB has not deployed a sanctioned AI tool, but staff have started using public consumer AI chatbots on their own initiative to help draft customer correspondence and internal memos. Define what may never be submitted to any AI tool not covered by a signed data-sharing/service provider agreement (customer nonpublic personal information (NPI) and account numbers, chief among them), what limited non-NPI uses (if any) are permitted in the meantime, and what constitutes a policy violation. Also address the specific risk of using unreviewed AI output in a customer-facing decision such as a loan adverse action notice, given RCB's obligations under the Equal Credit Opportunity Act. Write this section generally enough that it still holds once RCB adopts a specific sanctioned tool - don't name one that doesn't exist yet
- **Monitoring disclosure** - inform staff that activity on organizational systems is subject to monitoring and logging; cite the legal basis
- **Violation consequences** - tiered: minor violation / major violation / criminal referral
- **Acknowledgment block** - formatted signature block that employees sign at onboarding and annually

### Document 2 - Data Classification Policy (32 pts)

A standalone policy covering the full data lifecycle:

- **Policy statement and purpose**
- **Scope** - systems, data types, and personnel covered
- **Classification tiers** - exactly 4 tiers. For each tier define:
  - Tier name and description
  - Examples specific to a community banking environment (minimum 4 examples per tier)
  - Handling requirements: storage (encryption at rest - specify algorithm and key management), transmission (TLS version minimum, acceptable methods), access control (who can access by role), physical media handling, disposal method (NIST 800-88 compliance level)
  - Labeling requirements (how is this data labeled in documents, email, systems?)
- **Classification process** - who is responsible for classifying new data, what is the default classification for unclassified data, and how is reclassification requested
- **Roles and responsibilities** - Data Owner, Data Custodian, Data Steward, all users - define each role's specific obligations
- **Compliance and audit** - how compliance is verified and at what frequency

### Document 3 - Vendor & Third-Party Access Policy (31 pts)

This policy governs how third-party vendors (MSPs, software vendors, contractors) are granted access to Riverbend Community Bank's systems, consistent with the third-party risk management expectations bank examiners look for (see OCC Bulletin 2013-29):

- **Vendor onboarding requirements** - minimum security controls a vendor must demonstrate before being granted access (at minimum: SOC 2 Type II or equivalent, MFA for all remote access accounts, a signed data-sharing/service provider agreement addressing GLBA Safeguards Rule obligations if they will access customer NPI)
- **Access provisioning process** - approval chain, how vendor accounts are created (named accounts only - no shared credentials), what systems/data vendors can access and how this is scoped
- **Remote access requirements** - which VPN/jump host/PAM tool vendors must use; no direct RDP/SSH to production without going through the jump host; session recording requirements
- **Ongoing monitoring** - how vendor access is monitored (logging requirements, review frequency, what triggers immediate access revocation)
- **Vendor access review** - quarterly access review process: who conducts it, what is reviewed, what happens to accounts where the vendor relationship has ended
- **Incident notification** - if a vendor discovers or causes a security incident affecting Riverbend Community Bank systems, what must they notify you of and within what timeframe? (Include a template notification that vendors must submit.)
- **Termination of access** - exactly how vendor access is revoked at end of engagement (account disabled, VPN certificate revoked, credentials rotated, access log archived)

### Document 4 - Zero Trust Architecture Alignment (10 pts)

The three policies above collectively implement pieces of a Zero Trust Architecture, even though none of them use that term. Write a short (half-page) mapping of each of the 5 ZTA pillars (identity, device, network, application, data) to the specific policy requirement(s) above that enforce it - and for any pillar none of your three policies actually cover, say so explicitly rather than stretching a weak fit. Conclude with 2-3 sentences: which pillar is weakest across this policy package, and what would you add to close that gap?

---

## Deliverable(s)

Write all three policies in `homework/it-hw-06.md` (or as three linked sub-pages if you prefer). Each policy must be clearly delineated with a version number, effective date, owner, and approval signature block. Include the Zero Trust alignment write-up as a final section.

Open a PR titled `IT HW 6 - Policy Package` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| AUP - 12+ specific prohibitions, AI use section, monitoring disclosure, acknowledgment block | 27 |
| Data classification - 4 tiers, 4+ examples each, full handling requirements per tier | 32 |
| Vendor policy - onboarding, access scoping, monitoring, incident notification template, termination | 31 |
| Zero Trust alignment - all 5 pillars addressed, gaps identified honestly | 10 |

---

## Tip

{: .tip }
Read one real AUP from a public institution (BYU's or your previous employer's) and one from a bank or credit union before writing yours. Notice how specific the language is in the prohibition section - that specificity is what makes a policy enforceable.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section. Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Policy Governance Framework & Regulatory Mapping (30 pts)

Map your three policies (AUP, Data Classification, Vendor Access) against **ISO/IEC 27001:2022 Annex A** controls. For each Annex A control domain:

1. Identify which of your policies (if any) satisfies or partially satisfies it
2. For domains where none of your three policies provide coverage, note the gap
3. Produce a heatmap-style coverage table showing which domains are: Fully Covered, Partially Covered, Not Covered

Identify your top 3 coverage gaps and write a brief policy stub (title, scope, 3 key requirements) for each gap policy you would need to write to achieve ISO 27001 certification readiness.


[← Back to Homework]({{ site.baseurl }}/homework/)
