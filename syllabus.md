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


## Course Information

| | |
|---|---|
| **Course Number** | CYBER 444 |
| **Credits** | 3 |
| **Prerequisites** | CYBER 366 or instructors consent |
| **Delivery** | 2 hrs. lecture + 2 hrs. in-person lab/week |
| **Instructor** | Sebastian Hayes |
| **Office Hours** | By Appointment |
| **Email** | sebastian.hayes@byu.edu |
| **Class Location** | CTB 345 · Tuesdays & Thursdays · 4:00-5:50 PM |


## Course Tracks

CYBER 444 is delivered in two parallel tracks: a **Cyber Track** and an **IT Track**. The lectures and midterm are common to the whole class, but most weeks each track has its own lab and homework assignment focused on the work that track is preparing you for.

### Purpose of the two tracks

System administration sits at the intersection of two adjacent careers, and students in CYBER 444 come from both sides. The two tracks let you spend the semester practicing the work that matches the role you're aiming at, while still sharing a common foundation with the rest of the class.

- **Cyber Track** is for students preparing for security engineering, security operations, GRC, or compliance-focused sysadmin roles. Track-specific assignments emphasize hardening (CIS Benchmarks, DISA STIGs), audit and logging architecture, vulnerability and patch remediation, secure configuration management with Ansible, container security, and incident response from the sysadmin seat.
- **IT Track** is for students preparing for infrastructure engineering, IT operations, cloud, or platform roles. Track-specific assignments emphasize ITSM workflows (ticketing, change management), networking and DNS, high availability, data center operations, cloud provisioning and IAM, monitoring with Prometheus/Grafana, and enterprise IT policy.

You will see the track designation on every lab and homework page. Shared assignments are listed under "Shared" on the [Labs]({% link labs/index.md %}) and [Homework]({% link homework/index.md %}) index pages; track-specific assignments are prefixed with `CYBER` or `IT`.

### How the tracks work

The following rules apply to every weekly lab and homework assignment:

1. **Shared assignments are required for everyone.** Any assignment listed under "Shared" (or marked as applying to both tracks) must be completed by every student regardless of which track you identify with. These cover material the whole class is responsible for.
2. **You choose your track.** You do not need to formally declare a track, register it with the instructor, or stay locked into one for the whole semester. Pick the track whose work is most useful to you.
3. **One assignment per week from your chosen track.** In any given week that offers a Cyber and an IT version of the lab (or homework), you are only required to complete **one of the two**. You may switch which track you pick from week to week - for example, doing the Cyber lab in Week 5 and the IT lab in Week 6 is perfectly fine. Pick whichever assignment that week best serves what you want to learn.
4. **Doing both does not earn extra credit.** If you choose to complete both the Cyber and IT version of a given week's assignment, only one will count toward your grade. There is no bonus, multiplier, or extra-credit adjustment for doing the second one. Do the second only if you want the practice.
5. **Lowest scores are dropped on the track assignments.** Learning Suite is configured to **drop the lowest scores** on the homework and lab categories equal to the number of weeks that offer two track options. In practical terms this means that if you complete only your chosen track's assignment each week (and skip the other track's version, as expected), the unsubmitted assignment is dropped automatically and your grade is not affected. You do **not** need to email the instructor or request a manual drop - it happens automatically in the gradebook.

### Choosing and switching tracks

You can switch tracks freely from week to week, but for your own consistency it is recommended that you pick a primary track at the start of the semester and stay with it most of the time. The track-specific labs build progressively (e.g., the Cyber Ansible playbook in Week 9 is extended in Week 10; the IT cloud provisioning lab in Week 9 is the foundation for IAM and monitoring in Weeks 10-11). Bouncing between tracks every week may leave you without the prerequisite work for the next assignment in either lane.

If you are unsure which track to pick, the default recommendation is:

- Pick **Cyber** if you are pursuing a security, GRC, SOC, or compliance career, or if you plan to take CYBER electives focused on offensive/defensive security.
- Pick **IT** if you are pursuing an IT operations, infrastructure engineering, cloud, SRE, or platform career, or if you intend to pursue certifications like ITIL, AWS/Azure infrastructure tracks, or RHCE/RHCSA-style admin paths.

The final project has both a Cyber-track and IT-track version; you may pick either regardless of which track you have been doing weekly. See [Final Project (Cyber)]({% link final-project-cyber/index.md %}) and [Final Project (IT)]({% link final-project-it/index.md %}) for the respective scopes.

### Midterm and final project

The midterm exam and lecture material are the same for both tracks. Midterm questions are drawn from material every student is responsible for (the shared lectures and readings), not from track-specific lab content. You are not at a disadvantage on the midterm because of which track you chose.


## Student Learning Outcomes

### Shared outcomes (all students)

Regardless of track, upon successful completion of this course students will be able to:

1. Build and maintain a hardened Linux and Windows Server lab environment suitable for production-grade work.
2. Apply Active Directory and Group Policy fundamentals to manage a small Windows estate.
3. Operate a basic patch management pipeline and certificate / PKI infrastructure.
4. Document operations work clearly using a GitHub-based pull request workflow that mirrors industry change management.
5. Design, implement, and present a multi-week capstone infrastructure project.

### Cyber Track outcomes

Students completing the Cyber Track will additionally be able to:

1. Apply CIS Benchmark and DISA STIG controls to harden Linux and Windows Server systems to a measurable compliance score.
2. Design and implement automated configuration management solutions using Ansible playbooks and Galaxy roles.
3. Configure centralized logging, auditd, and SIEM integration to establish a defensible audit trail.
4. Implement identity and access management (PAM, SSH CA) aligned with least-privilege principles.
5. Harden Docker container deployments against CIS Docker Benchmark criteria.
6. Produce professional-grade compliance documentation including STIG checklists, gap analyses, and post-incident reports.

### IT Track outcomes

Students completing the IT Track will additionally be able to:

1. Operate within an ITSM framework, including ticketing, change management, and problem management workflows.
2. Design and implement core network services (DNS / DNSSEC, email security, high-availability load balancing).
3. Conduct data center site evaluations and risk assessments.
4. Provision and secure cloud infrastructure using IaC, including cloud IAM configuration and auditing.
5. Build a monitoring and observability stack using Prometheus and Grafana.
6. Draft enterprise IT policy and produce architecture and problem-management documentation.


## Grading

| Component | Weight | Details |
|---|---|---|
| Weekly Labs (14) | 55% | Started in lab session; report due within one week. Most weeks offer a Cyber and an IT version - pick one. |
| Homework (14) | 30% | Written, scripted, and analysis assignments. Most weeks offer a Cyber and an IT version - pick one. |
| Midterm Exam | 5% | Week 8, closed-book, 90 min (shared, both tracks) |
| Final Project | 10% | Weeks 8-15 (Cyber or IT version) |

### Drop-lowest policy for track assignments

Learning Suite is configured to **automatically drop the lowest scores** in the homework and lab categories equal to the number of weeks that have two track-specific options. If you complete only one of the two track versions each week (which is what you are expected to do), the unsubmitted assignment will be dropped from your grade automatically - your average will not be reduced for skipping the other track's version. See the [Course Tracks](#course-tracks) section for the full rules.

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


## Assignments

### Weekly Labs

Labs are the core of this course and are submitted through a GitHub-based workflow that mirrors professional sysadmin documentation practice. At the start of the semester you will create a GitHub repository from the course template. Each lab is submitted as a pull request to your site, reviewed by the Teaching Assistant, and merged into your main branch, the same change-management workflow used by operations teams.

A handful of labs are **shared** (required for both tracks); the rest are split into a **Cyber Track** and an **IT Track** version, and you complete only one. See the [Labs index]({% link labs/index.md %}) for which weeks are shared and which are split, and review the [Course Tracks](#course-tracks) section above for the full set of rules.

**Workflow for each lab:**

1. Create a branch from `main` named `lab-NN-short-description` (e.g., `lab-03-windows-hardening`)
2. Add your report as `labs/lab-NN.md` written in Markdown in runbook style, with commands, expected vs. actual output, screenshots, and analysis
3. Commit any supporting artifacts to the branch: config files, scripts, scan outputs (XCCDF XML, CIS-CAT HTML), STIG checklists
4. Open a pull request to `main` with the title `Lab NN: [Topic]`
5. The Teaching Assistant will review and leave inline comments; address any requested changes with additional commits
6. Once approved, merge the PR; your report goes live on your main branch
7. Submit the PR link on Learning Suite by the due date (one week after the lab session, Thursday 11:59 PM)

Your repository site will grow throughout the semester into a technical reference you can share with employers. By the final week it will contain 14 lab reports, supporting scripts and configs, and your final project documentation, a real artifact of the work you did in this course.

See the Schedule in Learning Suite for specific due dates and the [Lab index]({% link labs/index.md %})

### Homework

Homework assignments are written, scripted, or analysis-based tasks that extend the week's lecture material. They typically involve producing a deliverable such as a gap analysis, a hardening checklist, a policy document, or an Ansible playbook (Cyber Track), or an architecture design, an ITSM workflow, a risk assessment, or a cloud audit (IT Track). Homework follows the same GitHub PR workflow as labs: commit any supporting files, open a pull request, and submit the PR link on Learning Suite. Assignments are due on Tuesdays at 11:59 PM. See the Schedule in Learning Suite for specific due dates and the [Homework index]({% link homework/index.md %}) for which weeks are shared vs. split by track.
### Midterm Exam

The midterm is held in class during Week 8 (Tuesday, Oct 20) and covers all material from Weeks 1-7. It is closed-book and closed-note, 90 minutes, and consists of multiple-choice and short scenario-analysis questions. No make-up midterms are given except for university-approved absences arranged in advance.

### Final Project

The final project is a multi-week capstone running from Week 8 through the last class, and has a version aligned with each track:

- **Cyber Track final project:** design, harden, document, and present a fully compliant server infrastructure meeting CIS Level 2 and applicable DISA STIG requirements. See [Final Project (Cyber)]({% link final-project-cyber/index.md %}).
- **IT Track final project:** design, build, document, and present an enterprise infrastructure deliverable aligned with the IT Track's focus on operations, networking, cloud, monitoring, and policy. See [Final Project (IT)]({% link final-project-it/index.md %}).

You may pick either version regardless of which weekly track you have been following -- most students will pick the version that matches the track they have practiced most. All project documentation is submitted through your GitHub portfolio using the same PR workflow as labs. A project proposal is due Week 8, and the final deliverable and live presentation are due on the last class day (December 10).

This is an individual assignment and serves as the final exam for the course. As such, you may not receive help from the instructor, teaching assistants, classmates, or anyone else. You must complete it on your own. You may ask the instructor or teaching assistant clarifying questions related to grading or scope requirements, but no help on the project itself will be given.


## Course Policies

### Attendance

Attendance at both lecture and lab is expected. If you need to miss a class, please notify the instructor in advance whenever possible.

Lectures will **not** be recorded as a general practice. Recordings may be made on a case-by-case basis for university-excused absences (e.g., documented illness, university travel); contact the instructor before the missed session to arrange this.

Attendance is not a graded component of the course; however, missing lecture and lab sessions will put you at a significant disadvantage. Course material builds week over week, lab work cannot easily be replicated outside of scheduled sessions, and in-class discussions and walkthroughs are not captured elsewhere. Frequent absences will likely be reflected in your overall performance.

### Late Work

Late work is not accepted. Assignments, lab reports, and homework are due at the time and date posted in Learning Suite; submissions after the deadline will receive a zero.

If you have a documented university accommodation that may affect your ability to meet a deadline, it is your responsibility to contact the instructor **at least 24 hours before the due date** so that alternative arrangements can be discussed. Accommodation requests made after a deadline has passed will not be considered retroactively.

Plan ahead. Technical issues (network outages, VM failures, hardware problems) are a routine hazard in a systems administration course and are not grounds for an extension. Maintain regular backups of your lab environments and submit early when possible.

### Make-Up Exams

Make-up exams will not be administered. If you miss an exam, you will receive a zero for that component.

The only exceptions are university-recognized excused absences, including documented illness, university-sponsored travel, a death in the immediate family, or other circumstances explicitly recognized by BYU policy. In any of these cases, you must contact the instructor **before the exam date** (or as soon as reasonably possible in the case of an emergency) with supporting documentation. Make-up exams granted under these conditions will be scheduled at the instructor's discretion, typically within one week of the original date, and may differ in format from the original.

### Use of AI Tools

Generative AI tools (ChatGPT, Claude, Copilot, Gemini, and similar) are permitted as study and reference aids in this course, roughly in the same spirit as using a search engine, man page, or Stack Overflow. You may use them to look up syntax, understand a concept, debug an error message, or brainstorm an approach.

What is not permitted is using AI to produce the substance of your work. Submitting output that was generated, drafted, or heavily rewritten by an AI tool, whether for a lab report, homework write-up, analysis, or script, and presenting it as your own work is a violation of the Academic Honesty Policy, regardless of how much you edited the result afterward.

**Permitted uses include:**
- Asking an AI to explain a concept or tool (e.g., "how does SELinux label inheritance work?")
- Using it to look up command syntax or flag options as you would a man page
- Generating a short boilerplate snippet (e.g., a basic Ansible task block) that you then build on, understand, and can explain
- Getting feedback on something you have already written

**Not permitted:**
- Generating a full or majority portion of a lab report, written analysis, or homework response
- Having an AI write, significantly rewrite, or restructure your scripts or configuration files and submitting them as your own
- Using AI output to answer short-answer or reflection questions that are intended to demonstrate your own understanding

The practical test: if you could not explain what you submitted to the instructor on request, line by line for a script or paragraph by paragraph for a written response, you have likely crossed the line.

When in doubt, disclose. Add a brief note at the end of your submission describing how you used AI (e.g., "used Claude to look up the auditd rule syntax in Step 3"). Voluntary disclosure will not be held against you; undisclosed use that surfaces during review will be treated as an academic honesty violation.

### Communication

The best ways to reach the instructor are **Discord** or **email**. Both channels are monitored equally; use whichever is most convenient for you.

Response time: expect a reply within one business day. Messages sent on weekends or after 5:00 PM will be answered the following business day. Hours of availability are **Monday-Friday, 9:00 AM - 5:00 PM**.

For lab-related questions, grading questions on lab reports, or help troubleshooting your environment, you are encouraged to contact the **Teaching Assistant** first. They are your fastest resource for hands-on technical issues and typically respond within the same business day. Teaching Assistant contact information is posted in Learning Suite.

A few norms that keep things running smoothly:

- For questions about assignment requirements, grading, or course content that others might benefit from, post in the appropriate Discord channel rather than a DM; you'll get a faster answer and your classmates will thank you.
- For anything personal (grade disputes, accommodation requests, sensitive circumstances), email or a private Discord message is appropriate.
- Office hours details are listed in the Course Information table above. If you cannot make scheduled hours, reply to your email thread and we can find a time that works.

### Academic Honesty

The first injunction of the Honor Code is the call to "be honest." Students come to the university not only to improve their minds, gain knowledge, and develop skills that will assist them in their life's work, but also to build character. "President David O. McKay taught that character is the highest aim of education" (*The Aims of a BYU Education*, p. 6). It is the purpose of the BYU Academic Honesty Policy to assist in fulfilling that aim.

BYU students should seek to be totally honest in their dealings with others. They should complete their own work and be evaluated based upon that work. They should avoid academic dishonesty and misconduct in all its forms, including but not limited to plagiarism, fabrication or falsification, cheating, and other academic misconduct.

**In this course specifically**, academic dishonesty includes but is not limited to: submitting another student's lab report or scripts 