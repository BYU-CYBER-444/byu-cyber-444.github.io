---
title: "C4 - Compliance-as-Code Pipeline"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 4
---

# C4 - Compliance-as-Code Pipeline
{: .no_toc }

Compliance is not a scan you run once: it is a pipeline that applies, measures, enforces, and repairs.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Servers drift. Someone changes a setting by hand, a package update reverts a control, and the compliance score you proved last month is wrong today. You build a pipeline that treats hardening as code: Ansible roles apply a benchmark, a CI pipeline lints and tests every change, scans produce a score, a gate blocks changes that lower it, scheduled scans detect drift, and remediation puts the host back. This builds directly on Labs 10-11 and the HW 11 drift exercise.

## What You Build

| Component | Description |
|---|---|
| Hardening roles | Ansible roles implementing **at least 30** controls from a CIS Level 1 or 2 benchmark (or STIG), each task tagged with its control ID |
| Target hosts | Two managed Linux hosts (for example Rocky 9 and Ubuntu 22.04) |
| CI pipeline | On every push: `ansible-lint` and `yamllint`, apply to a test host, run an OpenSCAP scan, and fail the build if the score drops below your threshold |
| CI service | A self-hosted Git service with CI (Gitea or Forgejo with its Actions runner, or GitLab CE) running on your Proxmox environment, so the whole pipeline lives in your lab. GitHub-hosted runners cannot reach your lab network; if you use GitHub Actions instead, the runner must be self-hosted inside the lab. |
| Drift detection | A scheduled `--check --diff` run or scan that reports drift automatically |
| Remediation | An automated job that restores drifted controls |
| Exceptions | A documented exceptions file (control ID, justification, owner, expiry) that the pipeline honors |
| Reporting | HTML scan reports published as pipeline artifacts, and a score history over time |

## Proposal Checklist

Your proposal must include:

- The benchmark or STIG you will implement and which hosts it applies to
- Your CI service (a self-hosted Git service with CI on Proxmox is recommended), where its runner lives, and how it reaches your lab hosts
- Your score threshold for the gate and how you chose it
- Your drift-detection method and schedule

## Pair Extension (pairs only: complete one)

- Add a Windows host with a matching hardening role and scan
- Add a second benchmark layer (for example a STIG overlay on top of CIS) with a mapping of which controls overlap

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; target hosts and runner up |
| 10 | Roles for 25+ controls, baseline scan |
| 11 | CI pipeline and gate |
| 12 | Drift detection, exceptions, score history |
| 14 | Remediation, documentation, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - C4 Compliance-as-Code Pipeline`. Everything lives in `final-project-cyber/` in your portfolio repo.

1. **Pipeline design document.** The flow from commit to enforced state, gate logic and threshold rationale, drift and remediation design, and the exception process.
2. **Architecture diagram.** Repo, runner, test and target hosts, scanners, report storage, and the network paths between them.
3. **Final scan reports and trend.** Scan reports for all hosts and the score history across the semester.
4. **Automation package.** Roles, pipeline definition, and runner setup, reproducible from the README.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Pipeline design document | 25 | Complete and consistent with what you built | Present but thin |
| Architecture diagram | 15 | Flow and network paths clearly labeled | Missing labels or paths |
| Scan reports and trend | 20 | All hosts at or above your stated threshold, with trend | Reports present; below threshold or no trend |
| Automation package | 25 | Rebuilds from checkout; README accurate | Runs with manual fixes |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Gate.** Push a change and show the pipeline run. Then push a change that lowers the score and show the gate block it.
2. **Drift.** Inject drift on a target host by hand and show your detection report it.
3. **Remediation.** Run remediation and show the score recover.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Pipeline and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Gate demo | 25 | Passing run and blocked run both shown | Passing run only |
| Drift detection demo | 25 | Injected drift detected and identified by control ID | Detected; cause unclear |
| Remediation demo | 20 | Score recovery shown after remediation | Remediation runs; recovery not shown |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to Cyber Project Options]({% link final-project-cyber/projects/index.md %})
