---
title: "LAB 1 — Environment Setup & Baseline Scanning"
parent: Labs
nav_order: 1
---

# LAB 1 — Environment Setup & Baseline Scanning
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 1
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Provision two lab VMs (Ubuntu 22.04 LTS + Windows Server 2022)
- Establish and verify host-only network connectivity between VMs
- Create labeled baseline VM snapshots
- Install CIS-CAT Lite and run an initial compliance scan
- Document the baseline security posture score

---

## Tools Required

- VMware Workstation Pro or VirtualBox
- Ubuntu 22.04 LTS ISO (provided via LMS)
- Windows Server 2022 Evaluation ISO (provided via LMS)
- CIS-CAT Lite (free download from cisecurity.org)

---

## Procedure


1. Install VMware Workstation or VirtualBox on your host machine
2. Deploy **Ubuntu 22.04 LTS VM** — 2 vCPU, 4 GB RAM, 40 GB disk
3. Deploy **Windows Server 2022 VM** — 2 vCPU, 4 GB RAM, 60 GB disk
4. Configure a host-only network adapter on both VMs and verify connectivity with `ping`
5. Take a snapshot of each VM labeled **BASELINE**
6. On the Ubuntu VM, install CIS-CAT Lite and run:
   ```bash
   ./Assessor-CLI.sh -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0.xml
   ```
7. Screenshot the score and export the HTML report
8. Record the baseline score in your Lab Report


---

## Submission Requirements

Lab Report (.docx template): VM specifications table, network diagram, CIS-CAT baseline score (%), screenshot of scan completion, and 3 observations about the baseline score.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
