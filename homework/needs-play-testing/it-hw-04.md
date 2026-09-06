---
title: "IT HW 4 - Windows Server Infrastructure Design"
parent: Homework
nav_order: 4
---

# IT HW 4 - Windows Server Infrastructure Design
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

Design a complete Windows Server infrastructure for Cedar Ridge School District and defend every decision as you would to the district's IT Director during a professional engagement. Use the [District Environment Profile]({% link homework/description-files/it-hw-04-scenario.md %}) for the staffing, current-state server, network, budget, and compliance facts your design needs to be written against.

### Part 1 - Server Inventory & AD Design (25 pts)

**Server inventory:** For each proposed server list: role(s), hardware spec (CPU/RAM/Storage), which location it lives in, and Datacenter vs. Standard licensing justification. Include a total licensing cost estimate.

**Active Directory design:**
- Domain name and forest/domain structure (single vs. multi-domain - justify)
- OU structure with at least 6 OUs - show the tree structure and explain what objects go in each OU and why the hierarchy is designed this way (not just "Users OU for users")
- AD Sites and Services: site topology, subnet assignments, site link cost, replication schedule between the District Office and the Operations Center
- At least 3 specific security-focused AD configurations (e.g., Protected Users group, Authentication Policies, AdminSDHolder)

### Part 2 - Group Policy Design (25 pts)

Design a GPO architecture with **at least 12 GPOs**. For each GPO document:

- GPO name and link target (domain/site/OU)
- What it enforces (specific policy paths and settings, not just "hardens workstations")
- Whether it applies via security filtering or WMI filter
- Link order relative to other GPOs at the same level and why

Your GPO design must address: password policy, account lockout, software restriction / AppLocker, Windows Defender settings, audit policy (aligned with CIS Benchmark Level 2), USB/removable media control, and remote desktop access control. The FERPA requirement for student-record-system access logging must be specifically addressed in at least one GPO.

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
- DFS-R replication group configuration between the District Office and the Operations Center: replication schedule, bandwidth throttle, staging area size
- Access-Based Enumeration (ABE): where you enable it and why

### Part 5 - Backup & Disaster Recovery (15 pts)

Design a backup strategy that meets a **4-hour RTO and 1-hour RPO** for the domain controllers:

- What gets backed up, with what tool, at what frequency
- Retention policy and where backups are stored (on-site and off-site/cloud)
- Bare-metal recovery procedure for a DC: specific steps from "the DC is dead" to "DC is restored and fully replicated"
- SYSVOL recovery procedure if GPOs are corrupted
- How you test backups and at what frequency

### Part 6 - FERPA Compliance Controls (5 pts)

List the 5 most important Windows infrastructure controls that directly protect student education records under FERPA. For each: the specific FERPA requirement it addresses (e.g., limiting access to school officials with a legitimate educational interest, access logging/auditability, retention), the Windows configuration or tool that implements it, and how you would produce evidence of it for a compliance review or state records request.

---

## Deliverable(s)

Write your full design in `homework/it-hw-04.md`.

Open a PR titled `IT HW 4 - Windows Server Infrastructure Design` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Server inventory + AD design (OU rationale, security configs) | 25 |
| GPO architecture - 12+ GPOs, specific settings, FERPA addressed | 25 |
| WSUS topology and patch approval workflow | 15 |
| DFS design - namespace, replication, ABE | 15 |
| Backup/DR - RTO/RPO met, bare-metal recovery steps | 15 |
| FERPA controls - specific, auditable | 5 |

---

## Tip

{: .tip }
"Create a Users OU" is not a design - explain why that OU exists at that level in the hierarchy and what GPOs link to it. Think about delegation: who can create objects in each OU?

[← Back to Homework]({{ site.baseurl }}/homework/)
