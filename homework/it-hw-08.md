---
title: "IT HW 8 - Windows Server Infrastructure Design"
parent: Homework
nav_order: 108
---

# IT HW 8 - Windows Server Infrastructure Design
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
| **Assignment** | IT HW 8 |
| **Points** | 100 |
| **Due** | Week 9 |
| **Track** | IT |

---

## Description

Design a complete Windows Server infrastructure for Acme Financial Corp and defend every decision as you would to a client during a professional engagement.

**Organization:** 200 employees across 2 offices (HQ: 150 users, Branch: 50 users). Currently running one aging Windows Server 2012 R2 handling all roles. Migrating to Windows Server 2022. Subject to SOX compliance - audit logs must be retained for 7 years and access to financial systems must be role-restricted and reviewable.

### Part 1 - Server Inventory & AD Design (25 pts)

**Server inventory:** For each proposed server list: role(s), hardware spec (CPU/RAM/Storage), which office it lives in, and Datacenter vs. Standard licensing justification. Include a total licensing cost estimate.

**Active Directory design:**
- Domain name and forest/domain structure (single vs. multi-domain - justify)
- OU structure with at least 6 OUs - show the tree structure and explain what objects go in each OU and why the hierarchy is designed this way (not just "Users OU for users")
- AD Sites and Services: site topology, subnet assignments, site link cost, replication schedule between HQ and branch
- At least 3 specific security-focused AD configurations (e.g., Protected Users group, Authentication Policies, AdminSDHolder)

### Part 2 - Group Policy Design (25 pts)

Design a GPO architecture with **at least 12 GPOs**. For each GPO document:

- GPO name and link target (domain/site/OU)
- What it enforces (specific policy paths and settings, not just "hardens workstations")
- Whether it applies via security filtering or WMI filter
- Link order relative to other GPOs at the same level and why

Your GPO design must address: password policy, account lockout, software restriction / AppLocker, Windows Defender settings, audit policy (aligned with CIS Benchmark Level 2), USB/removable media control, and remote desktop access control. The SOX requirement for financial system access logging must be specifically addressed in at least one GPO.

### Part 3 - WSUS & Patch Strategy (15 pts)

Design your WSUS topology and patch approval workflow:

- Upstream vs. downstream server placement and why
- Computer groups and their membership criteria
- Approval workflow: who approves critical vs. non-critical patches and in what time window?
- How do you handle patches that fail in your pilot ring - what is the rollback decision process?
- How do you verify patch compliance across all 200 machines? (What report or tool, and at what frequency?)

### Part 4 - File Services & DFS (15 pts)

Design the DFS namespace and replication topology:

- Namespace structure (domain-based or standalone - justify)
- At least 4 specific DFS shares with their purpose, access group, and quota
- DFS-R replication group configuration between HQ and branch: replication schedule, bandwidth throttle, staging area size
- Access-Based Enumeration (ABE): where you enable it and why

### Part 5 - Backup & Disaster Recovery (15 pts)

Design a backup strategy that meets a **4-hour RTO and 1-hour RPO** for the domain controllers:

- What gets backed up, with what tool, at what frequency
- Retention policy and where backups are stored (on-site and off-site/cloud)
- Bare-metal recovery procedure for a DC: specific steps from "the DC is dead" to "DC is restored and fully replicated"
- SYSVOL recovery procedure if GPOs are corrupted
- How you test backups and at what frequency

### Part 6 - SOX Compliance Controls (5 pts)

List the 5 most important Windows infrastructure controls that directly address SOX IT General Controls (ITGC). For each: the specific ITGC category it addresses (Access Management / Change Management / Availability), the Windows configuration or tool that implements it, and how you would produce evidence for an auditor.

---

## Deliverable(s)

Write your full design in `homework/it-hw-08.md`.

Open a PR titled `IT HW 8 - Windows Server Infrastructure Design` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Server inventory + AD design (OU rationale, security configs) | 25 |
| GPO architecture - 12+ GPOs, specific settings, SOX addressed | 25 |
| WSUS topology and patch approval workflow | 15 |
| DFS design - namespace, replication, ABE | 15 |
| Backup/DR - RTO/RPO met, bare-metal recovery steps | 15 |
| SOX controls - specific, auditable | 5 |

---

## Tip

{: .tip }
"Create a Users OU" is not a design - explain why that OU exists at that level in the hierarchy and what GPOs link to it. Think about delegation: who can create objects in each OU?

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 7 - SOX ITGC Evidence Package (30 pts)

**ITGC Evidence Collection Design (15 pts)**

For a publicly traded company running your Windows infrastructure design, map each SOX IT General Control category to specific evidence artifacts your environment produces. For each of the 4 ITGC categories:

| ITGC Category | Control Objective | Evidence Artifact | Collection Method | Retention Period |
|---|---|---|---|---|
| Logical Access Controls | Only authorized users can access financial systems | AD group membership export, last login report | PowerShell: `Get-ADGroupMember` + `Get-ADUser` | 7 years |
| Change Management | All changes are authorized and tested before production | ... | ... | ... |
| Computer Operations | Systems are monitored and backups are verified | ... | ... | ... |
| Program Development | New applications undergo SDLC controls | ... | ... | ... |

For each artifact, specify: the exact PowerShell command or process to collect it, how often it must be collected (continuous, daily, quarterly), and how an auditor would verify the control is operating effectively.

**IT General Controls Assessment Report (15 pts)**

Write a 2-3 page **ITGC Assessment Report** (`it-hw-08-itgc-report.md`) written as if presenting to an external auditor (PwC, Deloitte, etc.):

1. **Scope** - which systems, applications, and processes are in scope for this assessment
2. **Control Environment** - overall assessment of the control environment maturity (CMMI-style 1-5 rating with justification for each ITGC domain)
3. **Deficiencies** - identify at least 2 control deficiencies in your design (be honest - no design is perfect) and classify each as a Control Deficiency, Significant Deficiency, or Material Weakness using PCAOB AS 2201 criteria
4. **Management's Response** - for each deficiency, write a management response that acknowledges the finding and commits to a remediation timeline
5. **Auditor's Conclusion** - whether you believe your controls are sufficient to provide reasonable assurance over financial reporting integrity (and the caveats)


[← Back to Homework]({{ site.baseurl }}/homework/)
