---
title: "LAB 12 — Docker Security Hardening"
parent: Labs
nav_order: 12
---

# LAB 12 — Docker Security Hardening
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 12
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run docker-bench-security and analyze all WARN items
- Remediate 5 specific CIS Docker Benchmark controls
- Scan a container image with Trivy
- Document all findings and remediations

---

## Tools Required

- Ubuntu 22.04 VM
- Docker Engine
- docker-bench-security (GitHub)
- Trivy (aquasecurity.github.io/trivy)

---

## Procedure


1. Install Docker: `sudo apt install docker.io`
2. Pull and run a test image: `docker run -d nginx`
3. Run docker-bench-security:
   ```bash
   git clone https://github.com/docker/docker-bench-security
   cd docker-bench-security
   sudo sh docker-bench-security.sh > bench_results.txt 2>&1
   ```
4. Review results — identify all **WARN** items
5. Remediate these 5 controls:
   - Add `--userns-remap=default` to Docker daemon config
   - Add `"live-restore": true` to `/etc/docker/daemon.json`
   - Run containers with `--read-only --security-opt=no-new-privileges --cap-drop ALL`
   - Enable Docker Content Trust: `export DOCKER_CONTENT_TRUST=1`
   - Configure log driver: `"log-driver": "journald"` in `daemon.json`
6. Re-run docker-bench-security — verify remediated items now **PASS**
7. Scan the nginx image with Trivy:
   ```bash
   trivy image nginx:latest
   ```


---

## Submission Requirements

Lab Report: initial docker-bench results (WARN items highlighted), remediation evidence for each of 5 controls, post-remediation bench results comparison, Trivy scan output, summary table.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
