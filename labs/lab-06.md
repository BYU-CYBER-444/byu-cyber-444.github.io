---
title: "LAB 6 — OpenSCAP & DISA STIG Compliance"
parent: Labs
nav_order: 6
---

# LAB 6 — OpenSCAP & DISA STIG Compliance
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 6
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run an OpenSCAP scan with a STIG-compatible profile
- Identify and document all CAT I (high severity) findings
- Remediate every CAT I finding
- Export results in STIG Viewer format (.ckl)

---

## Tools Required

- Ubuntu 22.04 LTS VM
- OpenSCAP (`openscap-scanner`)
- SCAP Security Guide (SSG)
- STIG Viewer 2.x (download from public.cyber.mil)

---

## Procedure


1. Install OpenSCAP and SSG:
   ```bash
   sudo apt install openscap-scanner ssg-debderived
   ```
2. Run the scan:
   ```bash
   oscap xccdf eval \
     --profile xccdf_org.ssgproject.content_profile_stig \
     --results results.xml \
     --report report.html \
     /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
   ```
3. Open `report.html` — filter for **HIGH severity** (CAT I equivalent) findings
4. Record all CAT I findings in the provided STIG Viewer template
5. Remediate each CAT I finding and document every command used
6. Re-run OpenSCAP scan — verify all CAT I items now show **pass**
7. Import results into STIG Viewer 2.x and export a `.ckl` file


---

## Submission Requirements

Lab Report: initial OpenSCAP HTML report, STIG Viewer screenshot showing CAT I findings, all remediation commands, post-remediation HTML report, exported `.ckl` file, reflection: which CAT I finding was most impactful?

---

[← Back to Labs]({{ site.baseurl }}/labs/)
