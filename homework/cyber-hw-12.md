---
title: "CYBER HW 12 - Container Security Audit & Hardened Deployment"
parent: Homework
nav_order: 12
---

# CYBER HW 12 - Container Security Audit & Hardened Deployment
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
| **Assignment** | CYBER HW 12 |
| **Points** | 100 |
| **Due** | Week 13 |
| **Track** | Cyber |

---

## Description

### Part 1 - Dockerfile Audit (30 pts)

A vulnerable Dockerfile is provided on Learning Suite (`CYBER_HW12_Dockerfile`). Identify and fix every security issue.

For each issue found, document:

| Issue # | Line # | Issue Type | Risk Description | MITRE ATT&CK Technique | Corrected Dockerfile Line |
|---|---|---|---|---|---|

Issue types to look for: running as root, unpinned base image (floating tag), secrets in environment variables or build args, world-readable sensitive files, unnecessary packages installed, no HEALTHCHECK defined, missing `--no-install-recommends`, exposed unnecessary ports, missing `.dockerignore` patterns.

You must find **at least 8 issues**. Provide the full corrected Dockerfile as a deliverable.

### Part 2 - Docker Compose Security Audit (30 pts)

A Docker Compose file is provided on Learning Suite (`CYBER_HW12_docker-compose.yml`). It defines a 3-service stack: web (Nginx), app (Python), and database (PostgreSQL). For each of the **10 security improvements** you identify, document:

| CIS Docker Benchmark Control # | Title | Current State | Risk | Remediated Compose Snippet | Priority |
|---|---|---|---|---|---|

Your 10 improvements must include:
- At minimum 2 that address privilege escalation (user mapping, capabilities)
- At minimum 2 that address secret management (no plaintext passwords in environment variables - implement Docker secrets or a `.env` file with proper permissions)
- At minimum 1 that addresses network segmentation (don't put all services on the same network)
- At minimum 2 that address resource limits (CPU, memory, and pids limits)
- At minimum 1 read-only filesystem mount

Provide the full remediated `docker-compose.yml` as a deliverable.

### Part 3 - Container Escape Scenario Analysis (25 pts)

Research the following container escape technique: **cgroup v1 release_agent escape** (CVE-2022-0492 or the classic Felix Wilhelm technique). Write a technical analysis covering:

1. **How it works** - step-by-step technical explanation of the escape mechanism (what kernel feature is abused, what the attacker does inside the container, what they gain on the host)
2. **Preconditions** - what must be true for this escape to work? (Specific capabilities, mount permissions, cgroup version, etc.)
3. **Which of your Docker Compose hardening controls prevent this** - for each relevant control from Part 2, explain precisely why it blocks this specific escape path
4. **Detection** - what host-level log entries or kernel events would indicate this escape was attempted? Write a specific `auditd` rule that would detect the key syscall in this escape
5. **Residual risk** - if ALL your Part 2 controls are applied, is this escape completely prevented? If any residual risk remains, what additional control addresses it?

### Part 4 - Runtime Security Monitoring (15 pts)

Write a `docker-bench-security.sh` wrapper script that:

1. Runs the official CIS Docker Benchmark tool (`docker/docker-bench-security`) against your hardened Compose stack
2. Parses the output and counts WARN vs. PASS results
3. Prints a summary and exits with code 1 if more than 5 WARNs remain

Then write a Falco rule (`cyber-hw-12-falco.yml`) that detects the following runtime behavior in any running container:
- A shell spawned inside a container that is not during a `docker exec` debug session (detect: `container.id != "" and proc.name in (bash, sh, zsh) and not proc.pname in (docker, sshd)`)
- A container writing to `/etc/` (detect filesystem writes outside of expected paths)

Explain what legitimate use case might trigger each rule as a false positive and how you would tune the rule to reduce that noise.

---

## Deliverable(s)

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow checks your Dockerfile and Compose file for the specific hardening patterns Part 1/2 require (non-root user, pinned base image, HEALTHCHECK, cap_drop, resource limits, secrets handling, network segmentation) and syntax-checks your wrapper script and Falco rules. It does not `docker build` your image or run docker-bench/Falco for real - runtime behavior and the escape analysis are graded by hand.

Write your full analysis in `homework/cyber-hw-12.md`. Commit to `homework/assets/`:

- `cyber-hw-12-Dockerfile.hardened` - your corrected Dockerfile
- `cyber-hw-12-docker-compose.hardened.yml` - your remediated Compose file
- `cyber-hw-12-docker-bench-wrapper.sh` - your benchmark wrapper
- `cyber-hw-12-falco-rules.yml` - your Falco detection rules

Open a PR titled `CYBER HW 12 - Container Security` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Dockerfile audit - 8+ issues, corrected file provided | 30 |
| Compose audit - 10 controls, all required categories covered | 30 |
| Container escape analysis - mechanism explained, controls mapped | 25 |
| Docker Bench wrapper script + Falco rules | 15 |

---

## Tip

{: .tip }
The CIS Docker Benchmark is free to download from cisecurity.org. Section 4 covers container image hardening (your Dockerfile audit) and Section 5 covers container runtime (your Compose audit). Reference the specific control numbers.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - SBOM Pipeline & Container Security Policy (30 pts)

**Software Bill of Materials Pipeline (15 pts)**

Implement a complete SBOM generation and vulnerability scanning pipeline:

1. Use **Syft** (`syft <image> -o spdx-json > sbom.spdx.json`) to generate an SPDX 2.3 SBOM for your hardened image
2. Feed the SBOM into **Grype** (`grype sbom:sbom.spdx.json -o json > vulns.json`) and produce a vulnerability report
3. Write a Python script (`cyber-hw-12-sbom-gate.py`) that reads `vulns.json` and:
   - Fails with exit code 1 if any CRITICAL severity vulnerability exists with a fix available
   - Prints a formatted summary: total packages, total CVEs by severity, list of CRITICAL CVEs with CVE ID, package, version, and fix version
   - Exits 0 (pass) if all criticals are either fixed in your image or have no fix available (with a warning)
4. Integrate this gate as a step in your CI/CD pipeline (GitHub Actions) that runs after the image build and blocks the push if it fails

Submit your SBOM file, vulnerability report, and a screenshot of the gate passing on your hardened image.

**Container Security Policy Document (15 pts)**

Write a formal **Container Security Policy** (`cyber-hw-12-security-policy.md`) suitable for adoption by a DevSecOps team. The policy must cover:

1. **Approved Base Images** - list of approved base image registries and tags, process for adding new base images, and mandatory review cadence
2. **SBOM Requirements** - when an SBOM must be generated, where it must be stored, and how long it must be retained
3. **Image Signing** - requirement for Cosign/Sigstore signing before images are promoted to production, including who holds signing keys and how keys are rotated
4. **Runtime Security Requirements** - minimum required Falco rules, mandatory seccomp profiles, disallowed capabilities, and required read-only filesystem configuration
5. **Incident Response** - procedure for a container compromise: isolation steps, forensic artifact collection from a running container (`docker export`, `kubectl debug`), and escalation path
6. **Supply Chain Threat Model** - a brief STRIDE analysis of your container build pipeline (from developer commit to production deployment) identifying the top 3 threats and mitigations


[← Back to Homework]({{ site.baseurl }}/homework/)
