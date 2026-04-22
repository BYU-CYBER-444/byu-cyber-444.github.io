---
title: Progress Checks
parent: Final Project
nav_order: 2
---

# Capstone Progress Checks
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Progress Check 1 — Automation

**Due:** Week 10 &nbsp;·&nbsp; **Weight:** 5% of final grade

Submit the current state of your Final Project Ansible playbook or Terraform configuration for
**one server** in your infrastructure.

### Requirements

- Minimum **15 hardening controls** implemented
- Variables externalized in a separate `vars/` or `.tfvars` file
- `README.md` documenting: purpose, prerequisites, variable descriptions, and how to run
- Summary of current CIS-CAT or STIG scan score for the target server

### Submission

Compressed `.zip` of your playbook/config directory + `README.md` + CIS-CAT or STIG scan report (PDF or HTML).

---

## Progress Check 2 — Compliance Scans {#progress-check-2}

**Due:** Week 12 &nbsp;·&nbsp; **Weight:** 5% of final grade

Submit CIS-CAT Pro and/or STIG scan reports for **all 3 servers** in your capstone environment.

### Requirements

- CIS-CAT HTML report for each Linux server
- STIG scan results (OpenSCAP `.xml` or STIG Viewer `.ckl`) for each server
- Each server must show a **minimum 70% compliance score**
- Include a brief narrative explaining any controls not yet remediated

### Submission

One `.zip` containing all scan reports + a one-page progress narrative.

[← Back to Capstone Overview]({% link final-project/index.md%})
