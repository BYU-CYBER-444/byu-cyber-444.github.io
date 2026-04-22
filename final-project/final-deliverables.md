---
title: Final Deliverables
parent: Final Project
nav_order: 3
---

# final-project Final Deliverables
{: .no_toc }

**Due:** Week 15 (before your presentation slot) &nbsp;·&nbsp; **Weight:** 5% documentation + 5% presentation
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Final Documentation Package

Submit a single `.zip` to the LMS containing:

1. **System Security Plan (SSP)** — use the provided `SSP_Template.docx` from the LMS. Must include:
   - System identification and description
   - Security categorization (FIPS 199)
   - Implemented security controls (mapped to CIS/STIG)
   - Known vulnerabilities and POA&M items

2. **Architecture Diagram** — network topology showing all 3 servers, IPs, roles, and firewall zones (PNG/PDF)

3. **Final Compliance Scan Reports** — CIS-CAT HTML reports for all servers + STIG `.ckl` or OpenSCAP `.xml` results

4. **Automation Package** — full Ansible playbook or Terraform configuration with README

5. **Lessons Learned** (1 page) — what worked, what didn't, what you would do differently

---

## Live Presentation & Demo {#presentation}

Each team has **20 minutes** (15 min demo + 5 min Q&A).

### Presentation Must Include

1. Brief architecture overview (2 min)
2. **Live CIS-CAT scan demo** showing compliance score for at least 1 server
3. **Ansible playbook live run** (or recorded if run time is too long) showing idempotency
4. **Logging dashboard demo** — show Graylog/Elastic capturing at least one security event in real time
5. **IAM demo** — demonstrate SSH CA certificate login or MFA flow
6. Q&A from instructor and peers

### Presentation Tips

{: .tip }
Rehearse your demo at least once beforehand. Live demos can fail — have screenshots as backup for each demo component.

[← Back to final-project Overview]({% link final-project/index.md%})
