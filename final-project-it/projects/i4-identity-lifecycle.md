---
title: "I4 - Identity and Endpoint Lifecycle"
parent: IT Project Options
grand_parent: Final Project (IT Track)
nav_order: 4
---

# I4 - Identity and Endpoint Lifecycle
{: .no_toc }

When someone joins, changes roles, or leaves, their access should change correctly and on time, without anyone clicking through a console.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Valley Medical Group hires, promotes, and loses staff every week, and every change must adjust access to patient systems the same day. You build the identity backbone and the automation on top of it: Active Directory with role-based groups and baseline policies, single sign-on for a web application, and a joiner-mover-leaver (JML) process driven from an HR-style CSV feed. You also produce the access-control and BYOD policies and the quarterly access review an auditor would ask for.

## What You Build

| Component | Description |
|---|---|
| Directory | Windows Server domain controller with an OU structure and role-based security groups (for example Physician, Nurse, Billing, IT) |
| Baseline policy | Group Policy for password and lockout policy, screen lock, and at least three further settings you justify |
| Linux integration | One Linux host joined to the domain (realmd/SSSD) with role-based login |
| Single sign-on | Keycloak (or similar) federated to your directory, protecting a small web application |
| JML automation | Scripts or Ansible driven from an HR CSV: **onboard** (account, groups by role, home folder), **move** (role change adjusts groups), **offboard** (disable, remove groups, move to a disabled OU, revoke SSO access) |
| Access review | A generated report of users, groups, last logon, and stale accounts for a manager to certify |
| Policies | Access-control policy and BYOD/MDM policy including an explicit decision on PHI access from personal devices |

Windows Server VMs are RAM-heavy; confirm resources with the instructor before planning more than one Windows machine.

## Proposal Checklist

Your proposal must include:

- Your OU and group design, and the role-to-access matrix for at least four roles
- Your JML automation tool (PowerShell, Ansible, or both) and the format of your HR feed
- Your SSO product and the application it will protect
- Your BYOD stance on PHI and one sentence justifying it

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; domain controller and OU design |
| 10 | Directory, GPOs, and onboarding automation |
| 11 | Mover and leaver automation |
| 12 | SSO and access review |
| 14 | Policies, documentation, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - I4 Identity and Endpoint Lifecycle`. Everything lives in `final-project-it/` in your portfolio repo.

1. **Identity and access standard.** OU and group design, role-to-access matrix, naming standards, privileged-account handling, and the JML process with timing expectations.
2. **Policies.** Access-control policy and BYOD/MDM policy (device requirements, MDM scope, PHI decision with justification, remote wipe, offboarding).
3. **Access review evidence.** A completed review: generated report, flagged accounts, and a manager sign-off record.
4. **Architecture diagram.** Domain controller, Linux host, SSO, protected application, HR feed, and automation flow.
5. **Automation package.** Scripts and configs reproducible from the README.
6. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Identity and access standard | 25 | Complete matrix and process, consistent with the build | Present but generic |
| Policies | 20 | Both specific, with a justified PHI decision | One thin or generic |
| Access review evidence | 20 | Real report, real findings, sign-off | Report only |
| Architecture diagram | 15 | Components and flows labeled | Vague |
| Automation package | 10 | Reproducible from checkout | Runs with manual fixes |
| Lessons learned | 10 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Joiner.** Add a new hire to the HR CSV, run the automation, and show the account, groups, and a successful SSO login to the web application.
2. **Mover.** Change that person's role in the CSV, rerun, and show their access change (what they gained and lost).
3. **Leaver.** Mark the person as terminated, rerun, and show the account disabled, groups removed, SSO login refused, and the access review flagging the change.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Design and decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Joiner demo | 30 | New hire usable end to end after one run | Account created; access incomplete |
| Mover demo | 20 | Access change correct in both directions | Gained access but did not lose old access |
| Leaver demo | 20 | All access removed and the denial shown | Account disabled; SSO still works |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to IT Project Options]({% link final-project-it/projects/index.md %})
