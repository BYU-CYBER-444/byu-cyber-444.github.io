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
| **Course Number** | CYBER 444 |
| **Credits** | 3 |
| **Prerequisites** | CYBER 366 |
| **Delivery** | Hybrid — 2 hrs lecture + 2 hrs in-person lab/week |
| **Instructor** | Sebastian Hayes |
| **Office Hours** | _[By Appointment]_ |
| **Email** | _sebasitan.hayes@byu.edu_ |
| **Class Location** | _[Building, Room]_ |

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
| Weekly Labs (14) | 50% | Completed in lab session; report due within one week |
| Homework (12) | 30% | Written, scripted, and analysis assignments |
| Weekly Quizzes (12) | 5% | 10-question online quiz each lab session |
| Midterm Exam | 5% | Week 8 — closed-book, 90 min |
| Final Project | 10% | Weeks 8–15 — see [Final Project]({% link final-project/index.md %}) |

### Grade Scale

| Grade | Range |
|----|-----|
| A  | 93% |
| A- | 90% |
| B+ | 87% |
| B  | 83% |
| B- | 80% |
| C+ | 77% |
| C  | 73% |
| C- | 70% |
| D+ | 67% |
| D  | 63% |
| D- | 60% |
| E  |  0% |

---

## Course Policies

### Attendance

Attendance at both lecture and lab is expected. If you need to miss a class, please notify the instructor in advance whenever possible.

Lectures will **not** be recorded as a general practice. Recordings may be made on a case-by-case basis for university-excused absences (e.g., documented illness, university travel) — contact the instructor before the missed session to arrange this.

Attendance is not a graded component of the course; however, missing lecture and lab sessions will put you at a significant disadvantage. Course material builds week over week, lab work cannot easily be replicated outside of scheduled sessions, and in-class discussions and walkthroughs are not captured elsewhere. Frequent absences will likely be reflected in your overall performance.

### Late Work

Late work is not accepted. Assignments, lab reports, and homework are due at the time and date posted in Learning Suite; submissions after the deadline will receive a zero.

If you have a documented university accommodation that may affect your ability to meet a deadline, it is your responsibility to contact the instructor **at least 24 hours before the due date** so that alternative arrangements can be discussed. Accommodation requests made after a deadline has passed will not be considered retroactively.

Plan ahead — technical issues (network outages, VM failures, hardware problems) are a routine hazard in a systems administration course and are not grounds for an extension. Maintain regular backups of your lab environments and submit early when possible.

### Make-Up Exams

Make-up exams will not be administered. If you miss an exam, you will receive a zero for that component.

The only exceptions are university-recognized excused absences — documented illness, university-sponsored travel, a death in the immediate family, or other circumstances explicitly recognized by BYU policy. In any of these cases, you must contact the instructor **before the exam date** (or as soon as reasonably possible in the case of an emergency) with supporting documentation. Make-up exams granted under these conditions will be scheduled at the instructor's discretion, typically within one week of the original date, and may differ in format from the original.

### Use of AI Tools

Generative AI tools (ChatGPT, Claude, Copilot, Gemini, and similar) are permitted as study and reference aids in this course — roughly in the same spirit as using a search engine, man page, or Stack Overflow. You may use them to look up syntax, understand a concept, debug an error message, or brainstorm an approach.

What is not permitted is using AI to produce the substance of your work. Submitting output that was generated, drafted, or heavily rewritten by an AI tool — whether for a lab report, homework write-up, analysis, or script — and presenting it as your own thinking is a violation of the Academic Honesty Policy, regardless of how much you edited the result afterward.

**Permitted uses include:**
- Asking an AI to explain a concept or tool (e.g., "how does SELinux label inheritance work?")
- Using it to look up command syntax or flag options as you would a man page
- Generating a short boilerplate snippet (e.g., a basic Ansible task block) that you then build on, understand, and can explain
- Getting feedback on something you have already written

**Not permitted:**
- Generating a full or majority portion of a lab report, written analysis, or homework response
- Having an AI write, significantly rewrite, or restructure your scripts or configuration files and submitting them as your own
- Using AI output to answer short-answer or reflection questions that are intended to demonstrate your own understanding

The practical test: if you could not explain what you submitted — line by line for a script, paragraph by paragraph for a written response — to the instructor on request, you have likely crossed the line.

When in doubt, disclose. Add a brief note at the end of your submission describing how you used AI (e.g., "used Claude to look up the auditd rule syntax in Step 3"). Voluntary disclosure will not be held against you; undisclosed use that surfaces during review will be treated as an academic honesty violation.

### Communication

The best ways to reach the instructor are **Discord** or **email**. Both channels are monitored equally — use whichever is most convenient for you.

Response time: expect a reply within one business day. Messages sent on weekends or after 5:00 PM will be answered the following business day. Hours of availability are **Monday–Friday, 9:00 AM – 5:00 PM**.

For lab-related questions, grading questions on lab reports, or help troubleshooting your environment, you are encouraged to contact the **Teaching Assistant** first — they are your fastest resource for hands-on technical issues and typically respond within the same business day. TA contact information is posted in Canvas.

A few norms that keep things running smoothly:

- For questions about assignment requirements, grading, or course content that others might benefit from, post in the appropriate Discord channel rather than a DM — you'll get a faster answer and your classmates will thank you.
- For anything personal (grade disputes, accommodation requests, sensitive circumstances), email or a private Discord message is appropriate.
- Office hours details are listed in the Course Information table above. If you cannot make scheduled hours, reply to your email thread and we can find a time that works.

### Academic Honesty

The first injunction of the Honor Code is the call to "be honest." Students come to the university not only to improve their minds, gain knowledge, and develop skills that will assist them in their life's work, but also to build character. "President David O. McKay taught that character is the highest aim of education" (*The Aims of a BYU Education*, p. 6). It is the purpose of the BYU Academic Honesty Policy to assist in fulfilling that aim.

BYU students should seek to be totally honest in their dealings with others. They should complete their own work and be evaluated based upon that work. They should avoid academic dishonesty and misconduct in all its forms, including but not limited to plagiarism, fabrication or falsification, cheating, and other academic misconduct.

**In this course specifically**, academic dishonesty includes but is not limited to: submitting another student's lab report or scripts as your own, sharing completed lab configurations or scripts with classmates before the due date, and using generative AI tools beyond the scope permitted in the AI Tools policy above without disclosure.

### Honor Code

In keeping with the principles of the BYU Honor Code, students are expected to be honest in all of their academic work. Academic honesty means, most fundamentally, that any work you present as your own must in fact be your own work and not that of another. Violations of this principle may result in a failing grade in the course and additional disciplinary action by the university. Students are also expected to adhere to the Dress and Grooming Standards. Please call the Honor Code Office at 801-422-2847 if you have questions about those standards.

### Plagiarism

Intentional plagiarism is a form of intellectual theft that violates widely recognized principles of academic integrity as well as the Honor Code. Such plagiarism may subject the student to appropriate disciplinary action administered through the university Honor Code Office, in addition to academic sanctions that may be applied by an instructor. Inadvertent plagiarism, which may not be a violation of the Honor Code, is nevertheless a form of intellectual carelessness that is unacceptable in the academic community.

Examples of plagiarism include:

- **Direct Plagiarism** — The verbatim copying of an original source without acknowledging the source.
- **Paraphrased Plagiarism** — The paraphrasing, without acknowledgement, of ideas from another that the reader might mistake for the author's own.
- **Plagiarism Mosaic** — Borrowing words, ideas, or data from an original source and blending this original material with one's own without acknowledging the source.
- **Insufficient Acknowledgement** — Partial or incomplete attribution of words, ideas, or data from an original source.

Copying another student's work and submitting it as your own individual work without proper attribution is a serious form of plagiarism.

### Inappropriate Use of Course Materials

All course materials (e.g., outlines, handouts, syllabi, exams, quizzes, PowerPoint presentations, lectures, audio and video recordings, etc.) are proprietary. Students are prohibited from posting or selling any such course materials without the express written permission of the instructor. To do so is a violation of the BYU Honor Code. It is also unethical to post your own work (study sheets, papers, scripts) from this course on file-sharing websites, as this encourages others to engage in plagiarism.

### Lab Environment Policy

All lab activities must be conducted within your designated lab environment (local VMs or provided cloud lab). Students are **prohibited** from deploying course tools — including vulnerability scanners (Nessus, OpenSCAP), configuration scanners (CIS-CAT), or Ansible playbooks — against any system they do not own or have explicit written permission to test. Unauthorized scanning may violate the Computer Fraud and Abuse Act (18 U.S.C. § 1030) and university policy.

### Accessibility & Accommodations

Brigham Young University is committed to providing a working and learning atmosphere that reasonably accommodates qualified persons with disabilities. A disability is a physical or mental impairment that substantially limits one or more major life activities, including vision or hearing impairments, physical disabilities, chronic illnesses, emotional disorders (e.g., depression, anxiety), learning disorders, and attention disorders (e.g., ADHD).

If you have a disability that impairs your ability to complete this course successfully, please contact the **University Accessibility Center (UAC)**, 2170 WSC, 801-422-2767, to request a reasonable accommodation. The UAC can also assess students for learning, attention, and emotional concerns. If you feel you have been unlawfully discriminated against on the basis of disability, please contact the Equal Opportunity Office at 801-422-5895 or [eo_manager@byu.edu](mailto:eo_manager@byu.edu).

### Title IX / Preventing & Responding to Sexual Misconduct

In accordance with Title IX of the Education Amendments of 1972, BYU prohibits unlawful sex discrimination, including sexual harassment, against any participant in its education programs or activities. Sexual harassment occurs when a person is subjected to unwelcome sexual speech or conduct so severe, pervasive, and offensive that it effectively denies their ability to access any BYU education program or activity, or when a person suffers sexual assault, dating violence, domestic violence, or stalking on the basis of sex.

University policy requires all faculty members to promptly report incidents of sexual harassment that come to their attention. Incidents should be reported to the **Title IX Coordinator** at [t9coordinator@byu.edu](mailto:t9coordinator@byu.edu), (801) 422-8692, or 1085 WSC. Reports may also be submitted at [titleix.byu.edu/report](https://titleix.byu.edu/report) or 1-888-238-1062 (24 hours a day). Additional information is available at [titleix.byu.edu](http://titleix.byu.edu).

### Respectful Environment & Diversity

Because we feel the depth of God's love for His children, we care deeply about every child of God, regardless of age, personal circumstances, gender, sexual orientation, or other unique challenges. As a university community we strive to foster an educational environment that promotes the personal dignity of every student. Our course participation reflects our understanding that every individual is a child of Heavenly Parents. We use language that is polite, considerate, and courteous — even when we strongly disagree.

Derogatory or demeaning comments about other students, their career choices, or their backgrounds are completely out of place at BYU and in this course.

### Mental Health

Mental health concerns and stressful life events can affect students' academic performance and quality of life. **BYU Counseling and Psychological Services (CAPS)**, 1500 WSC, 801-422-3035, [caps.byu.edu](https://caps.byu.edu), provides individual, couples, and group counseling, as well as stress management services. These services are confidential and are provided by the university at no cost for full-time students. For more immediate concerns, visit [help.byu.edu](http://help.byu.edu).

### University Policies & Compliance Hotline

If you have questions about university policies, please visit [policy.byu.edu](https://policy.byu.edu). If you observe any non-emergency dangerous, illegal, or suspicious activity on campus or by a member of the BYU community, please report it through the **BYU Compliance Hotline** at [hotline.byu.edu](https://hotline.byu.edu). Emergencies and ongoing criminal activity should be reported directly to BYU Police at 801-422-2911.

---

## Required Materials

### Readings (all free)
- **CIS Benchmarks** — Ubuntu 22.04 LTS & Windows Server 2022 ([cisecurity.org](https://cisecurity.org))
- **DISA STIG Library** — RHEL 9 & Windows Server 2022 STIGs ([public.cyber.mil](https://public.cyber.mil))
- **NIST SP 800-61 Rev. 2** — Incident Handling Guide ([csrc.nist.gov](https://csrc.nist.gov))
- **NIST SP 800-92** — Log Management Guide ([csrc.nist.gov](https://csrc.nist.gov))

### Software & Tools (all free or provided)
- VMware Workstation Pro or VirtualBox
- Ubuntu 22.04 LTS ISO + Windows Server 2022 Evaluation ISO _(provided via LMS)_
- CIS-CAT
- Ansible 2.14+, Terraform 1.6+, OpenSCAP, STIG Viewer 2.x
- Nessus Essentials _(free license — [tenable.com](https://www.tenable.com/products/nessus/nessus-essentials))_
- Docker Desktop / Docker Engine
- Graylog or Elastic Stack _(Docker Compose files provided)_

### Hardware Requirements
- RAM: 16 GB recommended (8 GB minimum)
- Storage: 100 GB free disk space
- CPU: x86-64 with Intel VT-x or AMD-V virtualization extensions enabled in BIOS

If you don't have access to a machine with the required resources, a lab environment can be made available to you.