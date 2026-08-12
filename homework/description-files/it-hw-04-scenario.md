---
title: "IT HW 4 - Cedar Ridge School District Environment Profile"
parent: Homework
nav_exclude: true
---

# Cedar Ridge School District - Environment Profile
{: .no_toc }

{: .note }
This is the reference scenario for [IT HW 4]({% link homework/it-hw-04.md %}). It gives you the staffing, current environment, network, and compliance facts your Windows Server infrastructure design needs to be written against. Don't invent a different user count, current-state server, or budget - use these.

---

## District Overview

Cedar Ridge School District is a mid-size K-12 public school district. This design covers **200 administrative and support staff accounts across 2 locations**: the **District Office** (150 users - HR, Business/Finance Office, Curriculum & Instruction, Student Services, IT) and a separate **Transportation & Maintenance Operations Center** (50 users - bus dispatch, routing, and facilities/maintenance staff).

Classroom teachers and students are **out of scope** for this design - they use a separate, cloud-only 1:1 Chromebook and Google Workspace for Education environment that does not join this Windows Active Directory domain. This design covers only the district's Windows-domain-joined administrative environment.

## Current Environment (Being Replaced)

The district currently runs **one aging physical server on Windows Server 2012 R2** (end of extended support), handling every role at once: domain controller, DNS, file shares, and print server, for both locations. There is no redundancy - if this server fails, the district has no functioning domain, no file access, and no student records system access district-wide. This single point of failure is the primary driver for the migration.

**Your design must migrate this environment to Windows Server 2022**, replacing the single-server model with a properly redundant architecture.

## Student Information System (SIS)

All official student education records - enrollment, grades, attendance, IEP/504 documentation, and transcripts - live in **EduTrack SIS**, a Windows-hosted line-of-business application used by registrars, counselors, Student Services staff, and Business Office staff (for fee/billing records tied to enrollment). EduTrack is the system your FERPA-driven access controls (Parts 1, 2, and 6) need to be designed around.

## Network

- **District Office subnet:** `10.10.0.0/16`
- **Operations Center subnet:** `10.20.0.0/16`
- **WAN link between locations:** a single 100 Mbps point-to-point circuit - adequate for day-to-day traffic but a real constraint for DFS-R replication and AD replication scheduling (Parts 1 and 4 should account for this, not assume unlimited bandwidth).

## Compliance Context

- **FERPA** (Family Educational Rights and Privacy Act, 20 U.S.C. §1232g; 34 CFR Part 99) governs access to student education records. Only school officials with a "legitimate educational interest" may access EduTrack or any system holding student records, and access must be logged and reviewable - this is the compliance driver for Part 2's access-logging GPO and Part 6's controls, in the same way SOX drives access logging at a financial-services organization.
- **CIPA** (Children's Internet Protection Act, 47 U.S.C. §254(h)) requires content filtering as a condition of the district's E-Rate internet discount funding. CIPA filtering is enforced at the network perimeter (a separate firewall/content-filter appliance) and is not part of this Windows Server design - mentioned here only so you don't need to address it; don't design AD-based content filtering for it.
- State records-retention schedules require student education records and related access logs to be retained for a **minimum of 7 years** after a student's expected graduation date - this is the retention figure your Part 6 controls and backup design should cite, in place of a fixed calendar-year retention period.

## Budget

The district has approved a **$25,000 hardware and licensing budget** for this migration. Your Part 1 licensing cost estimate should work within this ceiling, or explicitly flag if your recommended design exceeds it and why that tradeoff is still the right call for a district this size.

---

[← Back to IT HW 4]({% link homework/it-hw-04.md %})
