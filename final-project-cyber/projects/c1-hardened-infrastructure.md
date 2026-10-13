---
title: "C1 - Hardened Infrastructure Build"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 1
---

# C1 - Hardened Infrastructure Build
{: .no_toc }

Three servers, two compliance frameworks, one repeatable automation package.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

You are the security engineer for a small agency that must show an auditor its servers meet **CIS Benchmark Level 2** and the applicable **DISA STIGs**. You build three servers, automate their hardening so the result is repeatable, measure compliance with scanners, and write the System Security Plan an auditor would ask for.

## What You Build

| Server | Role | OS | Compliance target |
|---|---|---|---|
| Server 1 | Linux identity server (SSH CA and/or MFA) | Ubuntu 22.04 LTS | CIS Ubuntu L2 + DISA STIG |
| Server 2 | Windows app server | Windows Server 2022 | CIS Windows Server 2022 L2 + DISA Windows STIG |
| Server 3 | Web / Docker host | Ubuntu 22.04 LTS | CIS Ubuntu L2 + CIS Docker Benchmark |

This option meets the Windows and Linux requirement by design: Servers 1 and 3 are Linux and Server 2 is Windows, all hardened and scanned.

Required on top of the three servers:

- Automation (Ansible, Terraform, or both) that applies the hardening and runs idempotently
- Centralized logging to Graylog or an Elastic stack, receiving events from all three servers
- Identity: SSH CA certificate login **or** MFA for privileged access on Server 1
- Final compliance of **85% or higher** on every server in both scan types

## Proposal Checklist

Your proposal must include:

- Hostname, OS, IP range, and role for each server
- The CIS level and STIG that applies to **each** server (not a general list)
- Your scanning tools (CIS-CAT and OpenSCAP or STIG Viewer) and logging stack, with a sentence justifying each
- Which identity control you will demonstrate (SSH CA or MFA)

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; build all three servers and confirm access |
| 10 | Automate one server (20+ controls); baseline scan |
| 11 | Extend automation to the other two servers; stand up logging |
| 12 | Scan all three; fix gaps |
| 14 | Reach 85%; write the SSP and diagram; rehearse |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - C1 Hardened Infrastructure Build`. Everything lives in `final-project-cyber/` in your portfolio repo, navigable from its `README.md`.

1. **System Security Plan (SSP).** System identification and description; FIPS 199 categorization with justification; table of implemented controls mapped to CIS/STIG rule IDs; known vulnerabilities and a POA&M for anything unremediated.
2. **Architecture diagram.** All three servers with hostnames, IPs, roles, network zones and firewall boundaries, and data flows (logging, identity, web traffic).
3. **Final compliance scan reports.** CIS-CAT and OpenSCAP/STIG results for every server, all at 85% or higher.
4. **Automation package.** Complete playbook or Terraform configuration that runs cleanly from a fresh checkout and is idempotent.
5. **Lessons learned.** What went well, what failed or took longer than planned, what you would do differently, and one recommendation for next year's students.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| System Security Plan | 30 | All four sections complete and professional | Most sections present; minor gaps |
| Architecture diagram | 15 | Servers, IPs, roles, zones, and data flows clearly labeled | Present but missing labels or zones |
| Final scan reports | 25 | Both scan types for all 3 servers, all at 85% or higher | All servers represented; one below target |
| Automation package | 20 | Runs cleanly from checkout; idempotent; README accurate | Present; README incomplete or minor run errors |
| Lessons learned | 10 | Specific and reflective; covers all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Compliance scan.** Run a CIS-CAT scan on at least one server and show a score of 85% or higher.
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
