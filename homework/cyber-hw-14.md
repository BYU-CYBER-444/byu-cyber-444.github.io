---
title: "CYBER HW 14 - Container Security Audit & Hardened Deployment"
parent: Homework
nav_order: 14
---
# CYBER HW 14 - Container Security Audit & Hardened Deployment
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

### Part 1 - Dockerfile Audit (30 pts)

A vulnerable Dockerfile is provided: [Acme Widgets Co. - Vulnerable Dockerfile]({% link homework/description-files/cyber-hw-14-dockerfile.md %}). Identify and fix every security issue.

For each issue found, document:

| Issue # | Line # | Issue Type | Risk Description | MITRE ATT&CK Technique | Corrected Dockerfile Line |
|---|---|---|---|---|---|
| Ex. | *(illustrative only - not one of the issues in your provided Dockerfile; find your own 8+)* | Private key copied into image (`COPY id_rsa /root/.ssh/id_rsa`) | SSH private key becomes permanently recoverable from any pulled copy of the image via `docker history`/`docker save`, even if a later layer deletes the file | T1552.004 - Unsecured Credentials: Private Keys | Line removed entirely; key never enters the image - mounted at runtime via a secret store instead |

Issue types to look for: running as root, unpinned base image (floating tag), secrets in environment variables or build args, world-readable sensitive files, unnecessary packages installed, no HEALTHCHECK defined, missing `--no-install-recommends`, exposed unnecessary ports, missing `.dockerignore` patterns.

You must find **at least 8 issues**. Provide the full corrected Dockerfile as a deliverable.

### Part 2 - Docker Compose Security Audit (30 pts)

A Docker Compose file is provided: [Acme Widgets Co. - Vulnerable Docker Compose Stack]({% link homework/description-files/cyber-hw-14-docker-compose.md %}). It defines a 3-service stack: web (Nginx), app (Python), and database (PostgreSQL). For each of the **10 security improvements** you identify, document:

| CIS Docker Benchmark Control # | Title | Current State | Risk | Remediated Compose Snippet | Priority |
|---|---|---|---|---|---|
| Secrets management (CIS/NIST guidance) | No plaintext passwords in environment variables | *Illustrative example only - not one of your 10; your provided stack doesn't have a `cache` service.* A hypothetical `cache` service setting `REDIS_PASSWORD=cachepass123` directly in `environment:` | Any principal who can read the Compose file or run `docker inspect` has the credential in cleartext | `secrets:` top-level block (file-backed), consumed via `REDIS_PASSWORD_FILE` pointing at `/run/secrets/redis_password` | P1 |

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


---

## Deliverable(s)

Write your full analysis in `homework/cyber-hw-14.md`. Commit to `homework/assets/` using exactly these filenames (the autograder workflow triggers on these exact paths):

- `cyber-hw-14-Dockerfile.hardened` - your corrected Dockerfile
- `cyber-hw-14-docker-compose.hardened.yml` - your remediated Compose file

Open a PR titled `Grade: cyber-hw-14 - Container Security` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Dockerfile audit - 8+ issues, corrected file provided | 40 |
| Compose audit - 10 controls, all required categories covered | 35 |
| Container escape analysis - mechanism explained, controls mapped | 25 |



---

##  Graduate Extension - Graduate Students Only

### Part 4 - Container Security Policy (30 pts)





Write a formal **Container Security Policy** (`cyber-hw-14-security-policy.md`) suitable for adoption by a DevSecOps team. The policy must cover:

1. **Approved Base Images** - list of approved base image registries and tags, process for adding new base images, and mandatory review cadence
2. **SBOM Requirements** - when an SBOM must be generated, where it must be stored, and how long it must be retained
3. **Image Signing** - requirement for Cosign/Sigstore signing before images are promoted to production, including who holds signing keys and how keys are rotated
4. **Runtime Security Requirements** - minimum required Falco rules, mandatory seccomp profiles, disallowed capabilities, and required read-only filesystem configuration
5. **Incident Response** - procedure for a container compromise: isolation steps, forensic artifact collection from a running container (`docker export`, `kubectl debug`), and escalation path
6. **Supply Chain Threat Model** - a brief STRIDE analysis of your container build pipeline (from developer commit to production deployment) identifying the top 3 threats and mitigations


[← Back to Homework]({{ site.baseurl }}/homework/)
