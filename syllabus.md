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
| **Prerequisites** | CYBER 366 or instructor's consent |
| **Delivery** | 2 hrs. lecture + 2 hrs. in-person lab/week |
| **Instructor** | Sebastian Hayes |
| **Office Hours** | By Appointment |
| **Email** | sebastian.hayes@byu.edu |
| **Class Location** | CTB 350 · Tuesdays & Thursdays · 4:00-5:50 PM |



## Office Hours

| Time | Monday | Tuesday | Wednesday | Thursday | Friday |
|---|---|---|---|---|---|
| 9:00 - 10:00 AM | | | | | |
| 10:00 - 11:00 AM | | | | | |
| 11:00 AM - 12:00 PM | | | | | |
| 12:00 - 1:00 PM | | | | | |
| 1:00 - 2:00 PM | | Sebastian | | Sebastian | |
| 2:00 - 3:00 PM | | Sebastian | | Sebastian | |
| 3:00 - 4:00 PM | | | |  | |
| 4:00 - 5:00 PM | | | | | |
| 5:00 - 6:00 PM | | Sebastian | | Sebastian  | |

## Course Tracks

CYBER 444 is delivered in two parallel tracks: a **Cyber Track** and an **IT Track**. The lectures and midterm are common to the whole class, but some weeks each track has its own lab and homework assignment focused on the work that track is preparing you for.

### Purpose of the two tracks

System administration sits at the intersection of two adjacent careers, and students in CYBER 444 come from both sides. The two tracks let you spend the semester practicing the work that matches the role you're aiming at, while still sharing a common foundation with the rest of the class.

- **Cyber Track** is for students preparing for security engineering, security operations, GRC, or compliance-focused sysadmin roles. Track-specific assignments emphasize hardening (CIS Benchmarks, DISA STIGs), audit and logging architecture, vulnerability and patch remediation, secure configuration management with Ansible, container security, and incident response from the sysadmin seat.
- **IT Track** is for students preparing for infrastructure engineering, IT operations, cloud, or platform roles. Track-specific assignments emphasize networking and DNS, high availability, data center operations, monitoring with Prometheus/Grafana, and enterprise IT policy.

You will see the track designation on every lab and homework page. Shared assignments are listed under "Shared" on the [Labs]({% link labs/index.md %}) and [Homework]({% link homework/index.md %}) index pages; track-specific assignments are prefixed with `CYBER` or `IT`.

### How the tracks work

The following rules apply to every lab and homework assignment:

1. **Shared assignments are required for everyone.** Any assignment listed under "Shared" (or marked as applying to both tracks) must be completed by every student regardless of which track you choose. These cover material the whole class is responsible for.
2. **You choose your track.** You do not need to formally declare a track, register it with the instructor, or stay locked into one for the whole semester. Pick the track whose work is most useful to you.
3. **One assignment per week from your chosen track.** In any given week that offers a Cyber and an IT version of the lab (or homework), you are only required to complete **one of the two**. You may switch which track you pick from week to week - for example, doing the Cyber lab in Week 5 and the IT lab in Week 6 is perfectly fine. Pick whichever assignment that week best serves what you want to learn.
4. **Doing both does not earn extra credit.** If you choose to complete both the Cyber and IT version of a given week's assignment, only one will count toward your grade. There is no bonus, multiplier, or extra-credit adjustment for doing the second one. Do the second only if you want the practice.

### Choosing and switching tracks

You can switch tracks freely from week to week, but for your own consistency it is recommended that you pick a primary track at the start of the semester and stay with it most of the time.

If you are unsure which track to pick, the default recommendation is:

- Pick **Cyber** if you are pursuing a security, GRC, SOC, or compliance career, or if you plan to take CYBER electives focused on offensive/defensive security.
- Pick **IT** if you are pursuing an IT operations, infrastructure engineering, cloud, SRE, or platform career, or if you intend to pursue certifications like ITIL, or RHCE/RHCSA-style admin paths.

The final project has both a Cyber-track and IT-track version; you may pick either regardless of which track you have been doing weekly. See [Final Project (Cyber)]({% link final-project-cyber/index.md %}) and [Final Project (IT)]({% link final-project-it/index.md %}) for the respective scopes.

### Midterm and final project

The midterm and lecture material are the same for both tracks. Rather than a written exam, the midterm is a single tabletop scenario: every student works through a scenario individually, adjudicated by the course's AI Dungeon Master, drawing on material every student is responsible for (the shared lectures and readings), not track-specific lab content. You are not at a disadvantage on the midterm because of which track you chose. The midterm will have a 30-minute time limit and can be attempted up to 3 times. Due to the new nature of a midterm like this, everyone who completes at least one attempt will get a passing grade for the midterm.


## Student Learning Outcomes

### Shared outcomes (all students)

Regardless of track, upon successful completion of this course students will be able to:

1. Build and maintain a hardened Linux and Windows Server lab environment suitable for production-grade work.
1. Apply Active Directory and Group Policy fundamentals to manage a small Windows Domain.
1. Operate a basic patch management pipeline and certificate / PKI infrastructure.
1. Design, implement, and present a multi-week capstone infrastructure project.

### Cyber Track outcomes

Students completing the Cyber Track will additionally be able to:

1. Apply controls to harden Linux and Windows Server systems to a measurable compliance score.
1. Design and implement automated configuration management solutions using Ansible playbooks and Galaxy roles.
1. Configure centralized logging, auditd, and SIEM integration to establish a defensible audit trail.
1. Implement identity and access management (PAM, SSH CA) aligned with least-privilege principles.
1. Harden Docker container deployments against CIS Docker Benchmark criteria.
1. Produce professional-grade compliance documentation.

### IT Track outcomes

Students completing the IT Track will additionally be able to:

1. Design and implement core network services.
1. Conduct data center site evaluations and risk assessments.
1. Provision and secure cloud infrastructure using IaC, including cloud IAM configuration and auditing.
1. Build a monitoring and observability stack using Prometheus and Grafana.
1. Draft enterprise IT policy and produce architecture and problem-management documentation.


## Grading

| Component | Weight | Details |
|---|---|---|
| Labs (12) | 55% | Started in lab session; report due within one week. Some weeks offer a Cyber and an IT version - pick one. |
| Homework (10 graded) | 30% | Written, scripted, and analysis assignments. Some weeks offer a Cyber and an IT version - pick one. An 11th assignment, an ungraded practice exam (Week 9), does not count toward this total. |
| Midterm Exam | 5% | Week 10, individual tabletop exercise |
| Final Project | 10% | Weeks 9-15 (Cyber or IT version) |

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

### Labs

Labs are the core of this course and are submitted via Discord. At the start of the semester you will create a blank GitHub repository that will hold your homework and submissions for Lab assignments. You will be able to submit a lab using a discord bot in the `#444` channel on the Discord. Just type `/grade` into the message bar, press enter when you see the autocomplete work, and then specify the lab you are submitting. You will be able to find your grade and comments attached to a response message. Please note that this is under construction and a last minute grading change, so have patience and know that the interface could slightly change as homeworks are absorbed into this grading format.

**Workflow for each lab:**

1. Follow the instructions for the lab
2. Use the discord slash command to submit your lab
3. The Autograder will respond immediately with whether your lab is being graded, and after a short wait it will update that message with your feedback and score
4. Rinse and repeat until you have the grade that you want.

Your repository site will grow throughout the semester into a technical reference you can share with employers. By the final week, if you have been diligent in note-taking and upkeep, it will contain scripts and configs for each lab and your final project documentation.

As you complete these labs, we strongly suggest that you document the commands used in each lab (failures, successes, etc) in a markdown file in the lab. This will not be graded, but if you get into the habit of keeping strong notes as you work, it will be a huge benefit during the class and as you enter the workforce.

See the Schedule in Learning Suite for specific due dates.

### Homework

Homework assignments are written, or analysis-based tasks that extend the week's lecture material. They typically involve producing a deliverable building on the recently learned principles, such as a hardening checklist or policy document. Homework will likely follow the same discord workflow as labs (subject to minor change): commit any supporting files to your repo, use the discord slash command. Assignments are due on Tuesdays at 11:59 PM. See the Schedule in Learning Suite for specific due dates.

### Midterm Exam

The midterm is administered during Week 10 as an individual, tabletop exercise covering material from Weeks 1-9. Each student works through a scenario alone, making decisions under uncertainty and rolling against posted difficulty checks; the course's AI Dungeon Master narrates encounters and adjudicates outcomes in place of a live proctor. No make-up midterms are given except for university-approved absences arranged in advance. There will be one class period dedicated to taking the midterm but it will be open from Tuesday to Thursday.

### Final Project

The final project is a multi-week capstone running from Week 9 through the last class, and has a version aligned with each track:

- **Cyber Track final project:** design, harden, document, and present a fully compliant server infrastructure meeting CIS Level 2. See [Final Project (Cyber)]({% link final-project-cyber/index.md %}).
- **IT Track final project:** design, build, document, and present an enterprise infrastructure deliverable aligned with the IT Track's focus on operations, networking, cloud, monitoring, and policy. See [Final Project (IT)]({% link final-project-it/index.md %}).

You may pick either version regardless of which weekly track you have been following. All project documentation is submitted through your GitHub portfolio using the same PR workflow as labs. A project proposal is due Week 9, and the final deliverable and live presentation are due on the last class day (December 10).

This will be a group assignment and will serve as the final exam for the class. You will work in groups of 2. As such, you may not receive help from the instructor, teaching assistants, classmates, or anyone outside your group. Each group must complete the assignment on its own. You may ask the instructor or teaching assistant clarifying questions related to grading or scope requirements, but no help on the project itself will be given.


## Course Policies

### Attendance

Attendance at both lecture and lab is expected, but not required. If you need to miss a class, please notify the instructor in advance whenever possible.

Lectures will **not** be recorded as a general practice. Recordings may be made on a case-by-case basis for university-excused absences (e.g., documented illness, university travel); contact the instructor before the missed session to arrange this.

Missing lecture and lab sessions will put you at a significant disadvantage. Course material builds week over week, lab work cannot easily be replicated outside of scheduled sessions, and in-class discussions and walkthroughs are not captured elsewhere. Frequent absences will likely be reflected in your overall performance. You cannot expect to utilize the instructor and TA as a substitute for class attendance, since hours are extremely limited for both outside of class time.

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

You are responsible for disclosing all of your use of AI in each lab. This mirrors many jobs, since AI use is typically monitored, reported, and charged (since it usually costs money to your organization). Add a brief note at the end of your submission describing how you used AI (e.g., "used Claude to look up the auditd rule syntax in Step 3" or "used ChatGPT to explain Windows domain configuration"). Voluntary disclosure will not be held against you UNLESS it is in violation of the above rules; undisclosed use that surfaces during review will be treated as an academic honesty violation.

If a submission is deemed to have used AI beyond the given confines above, it will be graded as a 0 and resubmission will not be allowed. You are allowed to ask why your submission was marked as such, but without significant evidence showing that you completed the assignment yourself, the decision will be final.

### Communication

The best ways to reach the instructor are **Discord** or **email**. Both channels are monitored equally; use whichever is most convenient for you.

Response time: expect a reply within one business day. Messages sent on weekends or after 5:00 PM will be answered the following business day. Hours of availability are **Monday-Friday, 9:00 AM - 5:00 PM**.

For lab-related questions, grading questions on lab reports, or help troubleshooting your environment, you are encouraged to contact the **Teaching Assistant** first. They are your fastest resource for hands-on technical issues and typically respond within the same business day. Teaching Assistant contact information is posted in Learning Suite.

A few norms that keep things running smoothly:

- For questions about assignment requirements, grading, or course content that others might benefit from, post in the appropriate Discord channel rather than a DM; you'll get a faster answer and your classmates will thank you.
- For anything personal (grade disputes, accommodation requests, sensitive circumstances), email or a private Discord message is appropriate.
- Office hours details are listed in the Course Information table above.

### Academic Honesty

The first injunction of the Honor Code is the call to "be honest." Students come to the university not only to improve their minds, gain knowledge, and develop skills that will assist them in their life's work, but also to build character. "President David O. McKay taught that character is the highest aim of education" (*The Aims of a BYU Education*, p. 6). It is the purpose of the BYU Academic Honesty Policy to assist in fulfilling that aim.

BYU students should seek to be totally honest in their dealings with others. They should complete their own work and be evaluated based upon that work. They should avoid academic dishonesty and misconduct in all its forms, including but not limited to plagiarism, fabrication or falsification, cheating, and other academic misconduct.

**In this course specifically**, academic dishonesty includes but is not limited to: submitting another student's lab report or scripts as your own, sharing completed lab configurations or scripts with classmates before the due date, and using generative AI tools beyond the scope permitted in the AI Tools policy above without disclosure.

### Honor Code

In keeping with the principles of the BYU Honor Code, students are expected to be honest in all of their academic work. Academic honesty means, most fundamentally, that any work you present as your own must in fact be your own work and not that of another. Violations of this principle may result in a failing grade in the course and additional disciplinary action by the university. Students are also expected to adhere to the Dress and Grooming Standards. Please call the Honor Code Office at 801-422-2847 if you have questions about those standards.

### Plagiarism

Intentional plagiarism is a form of intellectual theft that violates widely recognized principles of academic integrity as well as the Honor Code. Such plagiarism may subject the student to appropriate disciplinary action administered through the university Honor Code Office, in addition to academic sanctions that may be applied by an instructor. Inadvertent plagiarism, which may not be a violation of the Honor Code, is nevertheless a form of intellectual carelessness that is unacceptable in the academic community.

Examples of plagiarism include:

- **Direct Plagiarism:** The verbatim copying of an original source without acknowledging the source.
- **Paraphrased Plagiarism:** The paraphrasing, without acknowledgement, of ideas from another that the reader might mistake for the author's own.
- **Plagiarism Mosaic:** Borrowing words, ideas, or data from an original source and blending this original material with one's own without acknowledging the source.
- **Insufficient Acknowledgement:** Partial or incomplete attribution of words, ideas, or data from an original source.

Copying another student's work and submitting it as your own individual work without proper attribution is a serious form of plagiarism.

### Inappropriate Use of Course Materials

All course materials (e.g., outlines, handouts, syllabi, exams, quizzes, PowerPoint presentations, lectures, audio and video recordings, etc.) are proprietary. Students are prohibited from posting or selling any such course materials without the express written permission of the instructor. To do so is a violation of the BYU Honor Code. It is also unethical to post your own work (study sheets, papers, scripts) from this course on file-sharing websites, as this encourages others to engage in plagiarism.

### Lab Environment Policy

All lab activities must be conducted within your designated lab environment (local VMs or provided cloud lab). Students are **prohibited** from deploying course tools, including vulnerability scanners (Nessus, OpenSCAP), configuration scanners (CIS-CAT), and Ansible playbooks, against any system they do not own or have explicit written permission to test. Unauthorized scanning may violate the Computer Fraud and Abuse Act (18 U.S.C. § 1030) and university policy.

### Accessibility & Accommodations

Brigham Young University is committed to providing a working and learning atmosphere that reasonably accommodates qualified persons with disabilities. A disability is a physical or mental impairment that substantially limits one or more major life activities, including vision or hearing impairments, physical disabilities, chronic illnesses, emotional disorders (e.g., depression, anxiety), learning disorders, and attention disorders (e.g., ADHD).

If you have a disability that impairs your ability to complete this course successfully, please contact the **University Accessibility Center (UAC)**, 2170 WSC, 801-422-2767, to request a reasonable accommodation. The UAC can also assess students for learning, attention, and emotional concerns. If you feel you have been unlawfully discriminated against on the basis of disability, please contact the Equal Opportunity Office at 801-422-5895 or [eo_manager@byu.edu](mailto:eo_manager@byu.edu).

### Title IX / Preventing & Responding to Sexual Misconduct

In accordance with Title IX of the Education Amendments of 1972, BYU prohibits unlawful sex discrimination, including sexual harassment, against any participant in its education programs or activities. Sexual harassment occurs when a person is subjected to unwelcome sexual speech or conduct so severe, pervasive, and offensive that it effectively denies their ability to access any BYU education program or activity, or when a person suffers sexual assault, dating violence, domestic violence, or stalking on the basis of sex.

University policy requires all faculty members to promptly report incidents of sexual harassment that come to their attention. Incidents should be reported to the **Title IX Coordinator** at [t9coordinator@byu.edu](mailto:t9coordinator@byu.edu), (801) 422-8692, or 1085 WSC. Reports may also be submitted at [titleix.byu.edu/report](https://titleix.byu.edu/report) or 1-888-238-1062 (24 hours a day). Additional information is available at [titleix.byu.edu](http://titleix.byu.edu).

### Respectful Environment & Diversity

Because we feel the depth of God's love for His children, we care deeply about every child of God, regardless of age, personal circumstances, gender, sexual orientation, or other unique challenges. As a university community we strive to foster an educational environment that promotes the personal dignity of every student. Our course participation reflects our understanding that every individual is a child of Heavenly Parents. We use language that is polite, considerate, and courteous, even when we strongly disagree.

Derogatory or demeaning comments about other students, their career choices, or their backgrounds are completely out of place at BYU and in this course.

### Mental Health

Mental health concerns and stressful life events can affect students' academic performance and quality of life. **BYU Counseling and Psychological Services (CAPS)**, 1500 WSC, 801-422-3035, [caps.byu.edu](https://caps.byu.edu), provides individual, couples, and group counseling, as well as stress management services. These services are confidential and are provided by the university at no cost for full-time students. For more immediate concerns, visit [help.byu.edu](http://help.byu.edu).

### University Policies & Compliance Hotline

If you have questions about university policies, please visit [policy.byu.edu](https://policy.byu.edu). If you observe any non-emergency dangerous, illegal, or suspicious activity on campus or by a member of the BYU community, please report it through the **BYU Compliance Hotline** at [hotline.byu.edu](https://hotline.byu.edu). Emergencies and ongoing criminal activity should be reported directly to BYU Police at 801-422-2911.
