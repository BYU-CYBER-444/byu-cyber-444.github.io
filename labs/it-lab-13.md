---
title: "IT LAB 13 - Enterprise Policy Drafting"
parent: Labs
nav_order: 113
---

# IT LAB 13 - Enterprise Policy Drafting
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 13 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Draft a complete, production-quality IT Security Policy using a structured policy framework
- Apply the SANS policy template methodology with mandatory and optional components
- Map policy controls to ISO/IEC 27001:2022 Annex A control objectives
- Conduct a policy gap analysis against a provided baseline
- Define policy exception and waiver processes with risk acceptance documentation

---

## Tools Required

- Word processor or Markdown editor
- SANS Institute Security Policy Templates (publicly available at sans.org/information-security-policy)
- ISO/IEC 27001:2022 Annex A reference (publicly available summaries)

---

## Background

IT security policies are not just compliance checkboxes - they are the documented expression of an organization's risk decisions. A policy without enforcement is theater; enforcement without a policy is arbitrary. Policies must be: clear (no ambiguity), enforceable (actionable, measurable), role-specific (who is responsible), and reviewed regularly (not a living document that never changes).

SANS identifies four levels: Policies (management intent), Standards (specific mandatory controls), Guidelines (recommended practices), Procedures (step-by-step operational steps). This lab focuses on Policy and Standards layers.

---

## Procedure

### Part 1 - Password and Authentication Policy (45 min)

Draft a complete **Password and Authentication Policy** for "Meridian Financial Services" (the data center scenario from Lab 5). The organization has:
- 350 employees, 45 IT staff
- Active Directory environment (Windows)
- Mix of on-premises and cloud (AWS) systems
- PCI-DSS scope (processes payment card data)
- Remote work: 40% of staff work remotely

Your policy must address each section below. Write complete sentences - not bullet fragments.

```
MERIDIAN FINANCIAL SERVICES
PASSWORD AND AUTHENTICATION POLICY

Policy ID:      SEC-AUTH-001
Classification: Internal
Version:        2.1
Effective Date: [Date]
Review Date:    [Date + 1 year]
Owner:          CISO
Approver:       CEO

1. PURPOSE
   [State why this policy exists - not just "to comply with PCI-DSS" but the
   security objectives being achieved]

2. SCOPE
   [Who and what systems are covered; explicitly list any exclusions]

3. POLICY STATEMENTS

   3.1 Password Complexity Requirements
       [Minimum length, character classes, prohibition of username in password,
       prohibition of sequential/repeated characters, specific requirements for
       privileged accounts vs. standard accounts]

   3.2 Password History and Rotation
       [Rotation frequency by account type, history enforcement,
       prohibition of password "rotation tricks" like appending numbers]

   3.3 Account Lockout
       [Threshold, observation window, lockout duration,
       distinction between self-service unlock and administrative unlock]

   3.4 Multi-Factor Authentication
       [Which systems require MFA, acceptable MFA factors, prohibited factors
       (e.g., SMS OTP for PCI-scoped systems per NIST SP 800-63B), exceptions process]

   3.5 Service Accounts and Non-Human Identities
       [Password length requirements, storage (Vault/PAM), rotation schedule,
       prohibition of sharing, documentation requirements]

   3.6 Privileged Account Controls
       [Separate admin accounts required, named accounts only (no shared admin),
       session recording requirements, PAM integration]

4. STANDARDS
   [Specific technical configuration requirements - e.g., "Active Directory
   password policy shall be configured with: minPasswordLength=14,
   passwordHistorySize=24, maxPasswordAge=90 for standard accounts"]

5. EXCEPTIONS
   [Process for requesting an exception, required documentation,
   risk acceptance form, maximum exception duration, approval authority]

6. ENFORCEMENT
   [Consequences for violation - from coaching to termination;
   how violations are detected and reported]

7. DEFINITIONS
   [Define at minimum: MFA, privileged account, service account,
   password complexity, passphrase]

8. REFERENCES
   - NIST SP 800-63B Digital Identity Guidelines
   - PCI-DSS v4.0 Requirement 8
   - ISO/IEC 27001:2022 Annex A 5.17 (Authentication Information)
```

Complete all 8 sections with substantive content. Section 3 must have all 6 subsections fully written.

---

### Part 2 - Remote Access Policy (30 min)

Draft a **Remote Access Policy** for the same organization. Use the same structure (Purpose → Scope → Policy Statements → Standards → Exceptions → Enforcement → Definitions → References).

Policy Statements must cover:
- Approved remote access methods (VPN, VDI - no split tunneling allowed for PCI systems)
- Endpoint security requirements (MDM enrollment, EDR agent, full-disk encryption)
- Home network isolation requirements (what traffic must traverse corporate VPN)
- Prohibited activities from personal devices accessing corporate resources
- Incident reporting for lost/stolen devices used for remote access

The Standards section must specify: VPN cipher suites (TLS 1.2+, AES-256), client certificate requirements, session timeout values, and log retention period.

---

### Part 3 - Policy Gap Analysis (30 min)

You have been given a draft "Acceptable Use Policy" from a previous employee. Conduct a gap analysis against ISO/IEC 27001:2022 Annex A controls A.5.10 (Acceptable Use of Information and Assets), A.6.2 (Terms and Conditions of Employment), and A.8.1 (User Endpoint Devices).

**Draft policy to analyze:**

> *Employees should use company computers responsibly. Personal use is okay as long as it doesn't affect work. Don't install unauthorized software. Report IT problems to the helpdesk. Don't share your password. Computers should be locked when you step away.*

For each of the three ISO controls, document:

| Control | Requirement | Gap | Severity | Remediation |
|---------|-------------|-----|----------|-------------|
| A.5.10 | [requirement text] | [what's missing] | High/Med/Low | [what to add] |
| A.6.2 | ... | ... | ... | ... |
| A.8.1 | ... | ... | ... | ... |

Identify at least 2 gaps per control (6 gaps minimum). For each gap, write a specific policy statement that would close it.

---

### Part 4 - Policy Exception and Waiver Process (20 min)

Policies cannot anticipate every business need. Design a **Policy Exception Request and Waiver Process**:

```
POLICY EXCEPTION REQUEST FORM
Form ID: SEC-EXC-001

Requestor: _________________ Department: _________________
Policy Reference: _____________ Section: _________________
Date Requested: _____________ Desired Duration: ___________

1. EXCEPTION DESCRIPTION
   [Describe specifically what policy requirement you cannot meet and why]

2. BUSINESS JUSTIFICATION
   [Why is this exception necessary? What business function requires it?]

3. RISK ASSESSMENT
   [What security risk does this exception create?]
   Likelihood of exploitation: High / Medium / Low
   Potential impact: High / Medium / Low
   Risk rating (L×I): Critical / High / Medium / Low

4. COMPENSATING CONTROLS
   [What additional controls will you implement to offset the risk?]

5. RESIDUAL RISK STATEMENT
   [After compensating controls, what risk remains?]
   Residual Risk Rating: ____________
   Risk Acceptance By: _____________ (must be VP-level or above for Medium+)

APPROVAL CHAIN:
   IT Security Review: _____________ Date: _______
   Department Head:   _____________ Date: _______
   CISO (if High/Critical risk): ___ Date: _______
```

Write a **completed** example exception request for this scenario: *The DevOps team needs to disable full-disk encryption on a high-performance build server because FDE reduces build times by 40%, exceeding the SLA for CI/CD pipeline completion.*

Fill in every field. Propose realistic compensating controls (network isolation, enhanced logging, physical access controls). Rate the residual risk.

---

### Part 5 - Policy Maintenance Calendar (15 min)

Create a **Policy Review and Maintenance Calendar** for Meridian Financial Services' complete policy set:

| Policy | Current Version | Annual Review Date | Trigger Events for Ad-Hoc Review | Owner |
|--------|----------------|-------------------|----------------------------------|-------|
| Password & Authentication | 2.1 | [Date] | Major breach, NIST 800-63 update, PCI-DSS revision | CISO |
| Remote Access | 1.3 | [Date] | New remote work technology, VPN vulnerability | IT Ops |
| Acceptable Use | 3.0 | [Date] | New BYOD program, litigation, regulatory change | HR + IT |
| Data Classification | 1.1 | [Date] | New data type onboarding, M&A activity | CISO |
| Incident Response | 2.4 | [Date] | Post-incident lessons learned, new attack vectors | IR Team |
| Change Management | 1.7 | [Date] | ITSM platform migration, ITIL framework update | IT Ops |

Add 3 more policies with appropriate trigger events. Explain why "trigger events" for ad-hoc reviews are as important as annual review cycles - give a real-world example where a reactive review would have prevented a policy-driven failure.

---

## Deliverables

1. Complete Password and Authentication Policy (all 8 sections)
2. Remote Access Policy (all 8 sections, including VPN cipher suite standards)
3. Gap analysis table (6+ gaps mapped to ISO 27001 Annex A controls)
4. Completed exception request form for the FDE scenario
5. Policy maintenance calendar (9+ policies) with trigger event explanation

---

## Grading

| Item | Points |
|------|--------|
| Password Policy - all 8 sections, compliant with NIST 800-63B + PCI-DSS | 30 |
| Remote Access Policy - all sections, technical standards included | 25 |
| Gap analysis - 6+ gaps mapped to ISO 27001 Annex A | 20 |
| Exception request form - completed example with risk analysis | 15 |
| Policy maintenance calendar | 10 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Policy Maturity Assessment
>
> The CMMI (Capability Maturity Model Integration) framework can be applied to policy management. Develop a **Policy Maturity Assessment** model with 5 maturity levels:
>
> - Level 1 (Initial): Policies exist informally, not documented
> - Level 2 (Managed): Policies documented but inconsistently enforced
> - Level 3 (Defined): Standardized policy framework, regular reviews
> - Level 4 (Quantitatively Managed): Compliance metrics tracked, reported to leadership
> - Level 5 (Optimizing): Continuous improvement, automated compliance monitoring
>
> For each level, define: observable evidence that an organization is at that level, key activities required to advance to the next level, and a sample metric.
>
> Apply the model to assess Meridian Financial Services based on what you know from Labs 4 and 5. Where do they fall? What are the top 3 improvements needed to advance one level?
>
> Write a 500-word **Policy Maturity Report** formatted as a consulting deliverable.
>
> ### Extension B - Regulatory Compliance Mapping Matrix
>
> Large organizations must comply with multiple regulations simultaneously. Build a **Cross-Regulation Policy Mapping Matrix** for Meridian Financial Services, which is subject to PCI-DSS v4.0, HIPAA Technical Safeguards, SOX ITGC, and ISO 27001.
>
> For the Password and Authentication Policy you wrote in Part 1, map each policy requirement to the specific control identifier(s) in each regulation it satisfies:
>
> | Policy Section | PCI-DSS v4.0 | HIPAA (45 CFR) | SOX ITGC | ISO 27001 A.5.17 |
> |----------------|--------------|----------------|----------|------------------|
> | Complexity requirements | Req 8.3.6 | §164.312(d) | CC6.1 | A.5.17 |
> | MFA requirement | Req 8.4.2 | §164.312(d) | CC6.1 | A.5.17 |
> | ... | ... | ... | ... | ... |
>
> Complete the matrix for all 6 policy statement subsections.
>
> Identify any gaps: Are there regulatory requirements not covered by your policy? Propose additions.
>
> Submit the Policy Maturity Report and completed Cross-Regulation Mapping Matrix.

[← Back to Labs]({{ site.baseurl }}/labs/)
