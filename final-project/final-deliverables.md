---
title: Final Deliverables
parent: Final Project
nav_order: 3
---

# Final Project Deliverables
{: .no_toc }

**Due:** (last class day) &nbsp;·&nbsp; **Weight:** 2.5% documentation + 2.5% presentation
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Final Documentation Package

All final project documentation is submitted through your GitHub portfolio using the same PR workflow as labs. Open a PR titled `Final Project — [Your Project Name]` and submit the PR link on Learning Suite before 11:59 on the last day of classes.

### 1. System Security Plan (SSP)

Your SSP must include all four of the following sections — missing sections will be reflected in the rubric score:

- **System Identification and Description** — system name, purpose, environment, and all three servers with OS, IP, and role
- **Security Categorization** — FIPS 199 impact level (Confidentiality / Integrity / Availability) with justification
- **Implemented Security Controls** — table of all hardening controls applied, mapped to their CIS Benchmark or STIG rule ID
- **Known Vulnerabilities and POA&M** — any controls not yet remediated, with risk description and planned remediation date

### 2. Architecture Diagram

The diagram must show:

- All three servers with hostnames, IPs, and roles
- Network zones and firewall boundaries
- Data flows between components (logging, IAM, web traffic)

Diagrams that are too vague to convey actual infrastructure design will not receive full credit.

### 3. Final Compliance Scan Reports

Required files:

- CIS-CAT HTML report for each Linux server (Server 1 and Server 3)
- OpenSCAP `.xml` or STIG Viewer `.ckl` for all three servers

All servers must show a minimum 85% compliance score in the final submission.

### 4. Automation Package

Commit your complete Ansible playbook or Terraform configuration. The package must:

- Run cleanly from a fresh checkout using only the instructions in the README
- Be fully idempotent (0 changed on a second run)
- Include a `README.md` with purpose, prerequisites, variable descriptions, and run instructions

### 5. Lessons Learned

Write your lessons learned and address specifically:

- What went well and why
- What failed or took significantly longer than planned
- What you would do differently if starting over
- One recommendation for a student taking this course next year

Generic or one-paragraph responses will not receive full credit.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| System Security Plan | 30 | All four sections complete (system ID, FIPS 199, control mappings, POA&M); professional quality | Most sections present; minor gaps | Significant sections missing or placeholder content |
| Architecture Diagram | 15 | Shows all 3 servers with IPs, roles, firewall zones, and data flows; clean and labeled | Diagram present; missing some labels or zones | Diagram too vague to represent actual infrastructure |
| Final Compliance Scan Reports | 25 | CIS-CAT HTML + STIG/OpenSCAP results for all 3 servers; all servers at 85% or above | All servers represented; one below 85% | Missing servers or reports in wrong format |
| Automation Package | 20 | Complete, runs cleanly from checkout, fully idempotent, README accurate | Playbook present; README incomplete or minor run errors | Automation incomplete or not runnable |
| Lessons Learned | 10 | Specific and reflective; addresses all four prompts | Present but generic | Missing or fewer than one paragraph |

---

## Live Presentation and Demo {#presentation}

Each student has **20 minutes** (15 min demo + 5 min Q&A). Presentations are held during the Week 15 class and lab session on Dec 10.

### What to Demonstrate

You must demonstrate all five of the following components. Missing a component will be reflected directly in your rubric score.

**1. Architecture Overview**

Briefly explain your three servers, the compliance targets for each, and the key design decisions you made. This should be spoken from memory, not read from a slide.

**2. Live CIS-CAT Scan**

Run a live CIS-CAT scan on at least one server and show the resulting compliance score. The score must be 85% or above to receive full credit for this component.

**3. Ansible Idempotency Demo**

Run your Ansible playbook live (or show a recording if run time exceeds the slot). Then run it a second time and show 0 changed. Both runs must be visible.

**4. Logging Dashboard**

Show your Graylog or Elastic Stack dashboard live. Trigger at least one security-relevant event (failed SSH login, sudo escalation, file access) and demonstrate that it appears in the dashboard in real time.

**5. IAM Demo**

Demonstrate one of the following end-to-end:
- SSH CA certificate-based login (show certificate issuance and successful auth)
- MFA flow (show prompt and successful second-factor authentication)

{: .tip }
Rehearse your demo at least twice before Dec 10. Live demos fail — prepare screenshots as backup for each component so you can continue presenting even if something breaks.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Overview | 15 | Clearly explains all 3 servers, compliance targets, and design decisions | Covers the basics; some elements unclear | Vague or skips key components |
| CIS-CAT Live Demo | 20 | Live scan runs successfully and shows 85% or above on at least 1 server | Demo runs; score below target or minor issues | Demo fails or is replaced by screenshots only |
| Ansible Idempotency Demo | 20 | Playbook runs live (or recorded); second run shows 0 changed | Runs successfully; idempotency not clearly demonstrated | Demo not attempted or fails to run |
| Logging Dashboard Demo | 20 | Dashboard shown live capturing a real security event in real time | Dashboard shown; event capture unclear | Dashboard not functional or not demonstrated |
| IAM Demo | 15 | SSH CA or MFA flow demonstrated end-to-end | Demonstrated but with issues or workarounds | Not demonstrated |
| Q&A | 10 | Answers are accurate, specific, and confident; demonstrates deep understanding | Most questions answered adequately | Answers vague or incorrect |

[Back to Final Project Overview]({% link final-project/index.md %})
