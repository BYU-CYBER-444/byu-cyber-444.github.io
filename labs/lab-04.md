---
title: "LAB 4 — Patch Management Implementation"
parent: Labs
nav_order: 4
---

# LAB 4 — Patch Management Implementation
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 4
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Configure automated security patch management on Ubuntu
- Run pre- and post-patch Nessus vulnerability scans
- Document CVE delta between scan cycles
- Set up automated weekly scan reporting

---

## Tools Required

- Ubuntu 22.04 LTS VM
- ``unattended-upgrades``
- Nessus Essentials (free account) or OpenVAS

---

## Procedure


1. Install and configure unattended-upgrades:
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure --priority=low unattended-upgrades
   ```
2. Edit `/etc/apt/apt.conf.d/50unattended-upgrades` — enable only security updates and configure email notifications
3. Run a **Nessus Essentials** (or OpenVAS) scan on the Ubuntu VM — export results as CSV
4. Apply patches: `sudo apt update && sudo apt upgrade -y`
5. Re-run the Nessus scan — export second CSV
6. Import both CSVs into the provided delta comparison spreadsheet (on LMS)
7. Document: CVEs closed, CVEs remaining, CVSS score delta
8. Create a cron job for weekly automated scan summary


---

## Submission Requirements

Lab Report: `unattended-upgrades` config screenshot, pre-patch Nessus HTML report, post-patch Nessus HTML report, delta comparison table (completed template), cron job configuration.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
