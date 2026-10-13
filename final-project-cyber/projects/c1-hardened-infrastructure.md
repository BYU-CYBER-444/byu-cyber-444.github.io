---
title: "C1 - Hardened Infrastructure Build"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 1
---

# C1 - Hardened Infrastructure Build
{: .no_toc }

Three servers, one compliance framework of your choice, one repeatable automation package.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

You are the security engineer for a small agency that must show an auditor its servers meet a recognized hardening standard. You choose **one** framework for the whole project, either **CIS Benchmark Level 2** or the applicable **DISA STIGs**, not both. You build three servers, automate their hardening so the result is repeatable, measure compliance with scanners, and write the System Security Plan an auditor would ask for.

## What You Build

| Server | Role | OS |
|---|---|---|
| Server 1 | Linux identity server (SSH CA and/or MFA) | Ubuntu 22.04 LTS |
| Server 2 | Windows app server | Windows Server 2022 |
| Server 3 | Web / Docker host | Ubuntu 22.04 LTS |

### Choose your framework

Pick one path and use it on all three servers. Do not mix frameworks.

| | CIS path | STIG path |
|---|---|---|
| Server 1 | CIS Ubuntu 22.04 Level 2 | DISA Ubuntu 22.04 LTS STIG |
| Server 2 | CIS Windows Server 2022 Level 2 | DISA Windows Server 2022 STIG |
| Server 3 | CIS Ubuntu 22.04 Level 2 + CIS Docker Benchmark | DISA Ubuntu 22.04 LTS STIG + the applicable STIG for the web server or container runtime you run (name it in your proposal) |
| Scanner | CIS-CAT | OpenSCAP with the SCAP Security Guide STIG profile on Linux; DISA SCAP Compliance Checker or a STIG Viewer checklist (`.ckl`) on Windows |

This option meets the Windows and Linux requirement by design: Servers 1 and 3 are Linux and Server 2 is Windows, all hardened and scanned.

Required on top of the three servers:

- Automation (Ansible, Terraform, or both) that applies the hardening and runs idempotently
- Centralized logging to Graylog or an Elastic stack, receiving events from all three servers
- Identity: SSH CA certificate login **or** MFA for privileged access on Server 1
- Final compliance of **85% or higher** on every server, measured with your framework's scanner

## Proposal Checklist

Your proposal must include:

- Hostname, OS, IP range, and role for each server
- Which framework you chose (CIS Level 2 or DISA STIG), and the exact benchmark or STIG, with version, that applies to **each** server (not a general list)
- Your scanning tool for each server (matched to your framework) and your logging stack, with a sentence justifying each
- Which identity control you will demonstrate (SSH CA or MFA)

---

## Final Documentation Package {#documentation}

**Due:** December 10, 11:59 PM. Submit everything in Learning Suite, as uploaded files or a link to them (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#submission)).

1. **System Security Plan (SSP).** System identification and description; FIPS 199 categorization with justification; table of implemented controls mapped to your framework's rule IDs; known vulnerabilities and a POA&M for anything unremediated.
2. **Architecture diagram.** All three servers with hostnames, IPs, roles, network zones and firewall boundaries, and data flows (logging, identity, web traffic).
3. **Final compliance scan reports.** Results from your framework's scanner for every server, all at 85% or higher.
4. **Automation package.** Complete playbook or Terraform configuration that runs cleanly from a fresh checkout and is idempotent.
5. **Lessons learned.** What went well, what failed or took longer than planned, what you would do differently, and one recommendation for next year's students.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| System Security Plan | 30 | All four sections complete and professional | Most sections present; minor gaps |
| Architecture diagram | 15 | Servers, IPs, roles, zones, and data flows clearly labeled | Present but missing labels or zones |
| Final scan reports | 25 | Results for all 3 servers from your framework's scanner, all at 85% or higher | All servers represented; one below target |
| Automation package | 20 | Runs cleanly from checkout; idempotent; README accurate | Present; README incomplete or minor run errors |
| Lessons learned | 10 | Specific and reflective; covers all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Compliance scan.** Run your framework's scanner (CIS-CAT on the CIS path; OpenSCAP or the SCAP Compliance Checker on the STIG path) on at least one server and show a score of 85% or higher.
2. **Idempotency.** Run your playbook, then run it again and show **0 changed**. Both runs must be visible.
3. **Identity and logging.** Log in with an SSH CA certificate (show the issuance) **or** complete an MFA login, then show that event appear in your Graylog or Elastic dashboard.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Servers, compliance targets, and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Compliance scan demo | 25 | Scan runs on screen and shows 85% or higher | Runs; score below target or minor issues |
| Idempotency demo | 25 | Both runs visible; second shows 0 changed | Runs; idempotency not clearly shown |
| Identity and logging demo | 20 | End-to-end login and the matching event shown in the dashboard | Demonstrated with issues or workarounds |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to Cyber Project Options]({% link final-project-cyber/projects/index.md %})
