---
title: "I5 - Self-Service Provisioning and Golden Images"
parent: IT Project Options
grand_parent: Final Project (IT Track)
nav_order: 5
---

# I5 - Self-Service Provisioning and Golden Images
{: .no_toc }

A service catalog where a request becomes a standardized, baseline-configured machine in minutes, with the paperwork generated automatically.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

At Valley Medical Group, a new server request takes two weeks because every machine is built by hand and each one is slightly different. You replace that with a pipeline: a reproducible **golden image**, an automated **baseline**, a small **service catalog** of standard offerings, and a request tool that provisions the machine, enforces guardrails (quotas, naming, approvals), registers it in an inventory, and creates a change record. You provision onto **your own nested Proxmox cluster** (the one you built in earlier labs), not onto shared class infrastructure.

## What You Build

| Component | Description |
|---|---|
| Golden image | A reproducible template (cloud-init template, Packer build, or LXC template) that you can rebuild from code |
| Baseline | An Ansible role applied to every machine: users, SSH settings, time sync, logging, and a monitoring agent |
| Service catalog | At least three standard offerings (for example small web server, database server, developer workstation), defined as data, not hardcoded in scripts |
| Request tool | A CLI or simple web form (Flask or similar; or a runner such as Semaphore) that takes a catalog item and requester and provisions through the Proxmox API (Terraform, Ansible, or direct API calls) |
| Guardrails | Per-requester quota, naming standard, and an approval step for larger sizes |
| Inventory / CMDB | Each machine is automatically recorded with owner, offering, creation date, and IP (a version-controlled file or a small database) |
| Change record | A record is generated per request (who, what, when, approval, outcome) |
| Decommission | A tested path that removes the machine and updates the inventory |

Nested virtualization performs poorly; prefer LXC containers or small VMs, and keep offerings small.

## Proposal Checklist

Your proposal must include:

- Your image-build method and what the baseline role configures
- The three catalog items, with sizes and the intended use of each
- Your request tool, how it authenticates to Proxmox (a scoped API token, not root), and where the inventory is stored
- Your guardrails: quota, naming standard, and what triggers approval

## Pair Extension (pairs only: complete one)

- Add a lifecycle policy: lease expiry with notification and automatic reclaim of unused machines
- Add network placement: each offering is placed in the correct VLAN/network with firewall rules chosen from the catalog item

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; Proxmox API token and image build started |
| 10 | Golden image and baseline; one catalog item end to end |
| 11 | Remaining catalog items and guardrails |
| 12 | Inventory, change records, decommission |
| 14 | Documentation, testing, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - I5 Self-Service Provisioning and Golden Images`. Everything lives in `final-project-it/` in your portfolio repo.

1. **Service catalog and request workflow.** Each offering (description, size, intended use, cost or quota impact), the request and approval flow, and expected delivery time.
2. **Standards document.** Naming standard, baseline contents, quotas, image lifecycle (how and when images are rebuilt), and decommission policy.
3. **Architecture diagram.** Image pipeline, request tool, Proxmox API, provisioned machines, inventory, and change-record flow.
4. **Automation package.** All code, catalog data, and docs, reproducible from the README.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Service catalog and workflow | 20 | Complete and consistent with the tool | Present but generic |
| Standards document | 20 | Specific and enforced by the tool | Stated but not enforced |
| Architecture diagram | 15 | Pipeline and data flows labeled | Vague |
| Automation package | 30 | Rebuilds from checkout; README accurate | Runs with manual fixes |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Request to machine.** Submit a request for a catalog item and show the machine appear, configured, with the baseline verified.
2. **Guardrail.** Submit an over-quota or unapproved request and show it refused or held for approval.
3. **Records and cleanup.** Show the inventory entry and change record produced by the request, then decommission the machine and show the inventory update.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Pipeline and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Request-to-machine demo | 30 | Request produces a verified, configured machine | Machine appears; baseline not shown |
| Guardrail demo | 20 | Refusal or approval hold shown | Described only |
| Records and cleanup demo | 20 | Inventory, change record, and decommission shown | One of the three missing |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to IT Project Options]({% link final-project-it/projects/index.md %})
