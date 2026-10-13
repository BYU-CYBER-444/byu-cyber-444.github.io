---
title: "C5 - Secure Container Platform"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 5
---

# C5 - Secure Container Platform
{: .no_toc }

A hardened container host and a supply chain that only runs images you scanned and signed.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Containers move fast, and unchecked images and over-privileged containers are a common way in. You build a small container platform and secure both halves: the **host** (hardened to the CIS Docker Benchmark) and the **supply chain** (images are scanned for vulnerabilities and signed, and your deploy step refuses anything unscanned or unsigned). Containers run with least privilege, traffic is TLS-terminated using your own CA, and runtime events go to central logging.

## What You Build

| Component | Description |
|---|---|
| Container host | Ubuntu or Rocky host with Docker or Podman hardened to the CIS Docker Benchmark; assessed with `docker-bench-security` |
| App stack | A three-container application (web, app, database) on separate user-defined networks, running with dropped capabilities, read-only root filesystems where possible, non-root users, and resource limits |
| Registry | A private registry (for example `registry:2`) on its own small host or container |
| Image scanning | Trivy (or equivalent) scanning images with a policy that fails on high or critical findings |
| Image signing | `cosign` signatures on approved images, with a deploy script or policy check that verifies the signature before running anything. Plain Docker does not verify signatures on its own, so this check is part of your deliverable. |
| TLS front door | Reverse proxy (nginx, Traefik, or Caddy) with certificates issued by a CA you built (building on Lab 5) |
| Secrets | Secrets delivered without baking them into images or environment files in the repo |
| Logging | Container and daemon logs shipped to a central log host |

## Proposal Checklist

Your proposal must include:

- Container runtime (Docker or Podman) and the benchmark you will assess against
- The three containers in your app stack and the network segmentation between them
- Your scanner, signing tool, and the exact point in the deploy flow where each is enforced
- Where logs will go and which events you expect to see

## Pair Extension (pairs only: complete one)

- Add an admission-style policy (for example OPA or Kyverno-like rules, or a signed-policy check) covering more than image signatures, such as banned capabilities and required labels
- Add a runtime-detection tool (Falco or equivalent) with at least three custom rules

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; host and registry up |
| 10 | Host hardening, baseline benchmark score, app stack |
| 11 | Scanning and signing in the deploy flow |
| 12 | TLS proxy, secrets, logging |
| 14 | Runtime tests, documentation, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - C5 Secure Container Platform`. Everything lives in `final-project-cyber/` in your portfolio repo.

1. **Container security design and compliance matrix.** Threat model for the platform, and a table mapping CIS Docker Benchmark sections to your implementation, with justified exceptions.
2. **Architecture diagram.** Hosts, registry, proxy, containers, networks, trust boundaries, and log flow.
3. **Scan evidence.** `docker-bench-security` results and Trivy reports, before and after.
4. **Automation package.** Rebuilds the platform, registry, pipeline, and policy checks from the README.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Design and compliance matrix | 30 | Threat model and benchmark mapping complete and honest | Matrix incomplete |
| Architecture diagram | 15 | Trust boundaries and flows clearly labeled | Missing labels or boundaries |
| Scan evidence | 20 | Before and after for both host and images | One scan type or no comparison |
| Automation package | 20 | Rebuilds from checkout; README accurate | Runs with manual fixes |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Scan gate.** Attempt to deploy an image with known high-severity vulnerabilities and show it blocked, then deploy a clean image successfully.
2. **Signature check.** Attempt to deploy an unsigned image and show it refused, then run a signed image.
3. **Runtime.** Inside a running container, attempt a privileged action (for example mounting a filesystem or writing to a read-only path) and show it fail and appear in your central logs.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Platform and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Scan gate demo | 25 | Blocked and allowed cases both shown | One case only |
| Signature demo | 25 | Unsigned refused and signed allowed | One case only |
| Runtime demo | 20 | Failure shown and the matching log event found | Failure shown; log not found |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to Cyber Project Options]({% link final-project-cyber/projects/index.md %})
