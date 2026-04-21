---
title: Syllabus
nav_order: 2
---

# Syllabus
{: .no_toc }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Course Information

| | |
|---|---|
| **Course Number** | IT&C 444 |
| **Credits** | 3 |
| **Prerequisites** | IT&C 201 (Computer Systems & OS) and IT&C 320 (Network Security Operations) |
| **Delivery** | Hybrid — 2 hrs lecture + 2 hrs in-person lab/week |
| **Instructor** | _[Instructor Name]_ |
| **Office Hours** | _[Days & Times or by appointment]_ |
| **Email** | _[instructor@university.edu]_ |
| **Class Location** | _[Building, Room]_ |
| **LMS** | _[Canvas/Blackboard URL]_ |

---

## Student Learning Outcomes

Upon successful completion of this course, students will be able to:

1. Apply CIS Benchmark and DISA STIG controls to harden Linux and Windows Server systems to a measurable compliance score.
2. Design and implement automated configuration management solutions using Ansible playbooks and Terraform modules.
3. Construct a secure patch management pipeline integrating vulnerability scanning and automated remediation.
4. Configure centralized logging, auditd, and SIEM integration to establish a defensible audit trail.
5. Implement identity and access management (PAM, SSH CA, LDAP/AD) aligned with least-privilege principles.
6. Harden virtual machine hypervisors and Docker container deployments against CIS Docker Benchmark criteria.
7. Produce professional-grade compliance documentation including SSPs, STIG checklists, and post-incident reports.

---

## Grading

| Component | Weight | Details |
|---|---|---|
| Weekly Labs (14) | 30% | Completed in lab session; report due within one week |
| Homework (12) | 20% | Written, scripted, and analysis assignments |
| Weekly Quizzes (12) | 10% | 10-question online quiz each lab session |
| Midterm Exam | 15% | Week 8 — closed-book, 90 min |
| Capstone Project | 25% | Weeks 8–15 — see [Capstone]({% link capstone/index.md %}) |

### Grade Scale

| Grade | Range |
|---|---|
| A | 90–100% |
| B | 80–89% |
| C | 70–79% |
| D | 60–69% |
| F | Below 60% |

---

## Course Policies

### Attendance
_[State attendance policy — required absences, excused absence process, lab attendance requirements.]_

### Late Work
_[State late work policy — % penalty per day, maximum penalty, no-late-work cutoff date.]_

### Make-Up Exams
_[State conditions under which make-up exams are granted and the process for requesting one.]_

### Academic Integrity
_[Paste your institution's academic integrity policy here. Clarify what counts as dishonesty in this course — e.g., sharing lab reports, submitting another student's scripts, undisclosed AI use.]_

### Use of AI Tools
_[State your AI/generative AI policy: prohibited / permitted with disclosure / permitted for specific tasks.]_

### Lab Environment Policy
All lab activities must be conducted within your designated lab environment (local VMs or provided cloud lab).
Students are **prohibited** from deploying course tools against systems they do not own or have explicit written
permission to test. Unauthorized scanning may violate the Computer Fraud and Abuse Act and university policy.

### Accessibility & Accommodations
_[Insert university disability services statement, office name, contact, and accommodation request process.]_

### Title IX / Non-Discrimination
_[Insert required university Title IX and non-discrimination statement.]_

### Communication
_[State expected email response time, preferred contact method, and LMS communication norms.]_

---

## Required Materials

### Readings (all free)
- **CIS Benchmarks** — Ubuntu 22.04 LTS & Windows Server 2022 ([cisecurity.org](https://cisecurity.org))
- **DISA STIG Library** — RHEL 9 & Windows Server 2022 STIGs ([public.cyber.mil](https://public.cyber.mil))
- **NIST SP 800-61 Rev. 2** — Incident Handling Guide ([csrc.nist.gov](https://csrc.nist.gov))
- **NIST SP 800-92** — Log Management Guide ([csrc.nist.gov](https://csrc.nist.gov))
- _[Add any required textbooks with ISBN and edition here, or state "no required textbook."]_

### Software & Tools (all free or provided)
- VMware Workstation Pro or VirtualBox
- Ubuntu 22.04 LTS ISO + Windows Server 2022 Evaluation ISO _(provided via LMS)_
- CIS-CAT Pro _(department license provided)_
- Ansible 2.14+, Terraform 1.6+, OpenSCAP, STIG Viewer 2.x
- Nessus Essentials _(free license — [tenable.com](https://www.tenable.com/products/nessus/nessus-essentials))_
- Docker Desktop / Docker Engine
- Graylog or Elastic Stack _(Docker Compose files provided)_

### Hardware Requirements
- RAM: 16 GB recommended (8 GB minimum)
- Storage: 100 GB free disk space
- CPU: x86-64 with Intel VT-x or AMD-V virtualization extensions enabled in BIOS

_[Note here if remote lab access is available as an alternative.]_
