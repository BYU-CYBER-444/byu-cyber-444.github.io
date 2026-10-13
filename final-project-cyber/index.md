---
title: Final Project (Cyber Track)
nav_order: 6
has_children: true
permalink: /final-project/
---

# Final Project - Cyber Track
{: .no_toc }


{: .note }
This is the **Cyber Track** final project. IT Track students complete the [IT Track Final Project]({% link final-project-it/index.md %}) instead. As the syllabus explains, you may pick either version regardless of which weekly track you followed.

---

## Overview

The final project is a multi-week capstone in which you design, build, document, and defend a piece of security infrastructure, and it serves as the final exam for the class. Instead of one assigned project, you **choose one of six options** and work on it from Week 9 through the presentations in Week 15.

All six options share the same schedule, submission process, and point structure. They differ in the system you build.

---

## How It Works

1. **Read the options.** Browse the [Cyber Project Options]({% link final-project-cyber/projects/index.md %}) and pick one.
2. **Submit your proposal** (Week 9) as a PDF. It names your option and fills in that option's proposal checklist. See [Project Proposal]({% link final-project-cyber/proposal.md %}).
3. **Submit the final package** and a **recorded presentation and demo** by December 10. See [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}).

---

## Teams and Help

- You may work **alone or in a pair**. Pairs must say so in the proposal, list who owns which pieces, and complete the **pair extension** listed on their option's page.
- This is the final exam. You may not receive help on the project itself from the instructor, teaching assistants, classmates, or anyone outside your group. You may ask the instructor or TAs clarifying questions about grading or scope.
- Late work is not accepted (see the syllabus).

---

## Schedule and Grading

| Milestone | Due | Weight |
|---|---|---|
| [Project Proposal]({% link final-project-cyber/proposal.md %}) | End of Week 9 | Pass/fail, required |
| [Final Documentation Package]({% link final-project-cyber/final-deliverables.md %}) | Dec 10, 11:59 PM | 5% |
| [Recorded Presentation and Demo]({% link final-project-cyber/final-deliverables.md %}#presentation) | Dec 10, 11:59 PM | 5% |

Week 13 is Thanksgiving break and has no class or deliverable. There are no in-class presentations: the presentation is a recording you submit as a link in Learning Suite. There are no graded checkpoints between the proposal and the final package, so use the suggested timeline on your option's page to pace yourself. The documentation package and the recorded presentation are each scored out of 100 points using the rubric on your option's page. The proposal is required: you may not receive credit for the final project without a passing proposal on file.

---

## Choose an Option

| # | Project | Summary |
|---|---|---|
| C1 | [Hardened Infrastructure Build]({% link final-project-cyber/projects/c1-hardened-infrastructure.md %}) | Three servers hardened to CIS Level 2 and DISA STIG, automated, with a System Security Plan |
| C2 | [Zero-Trust Identity and PKI Platform]({% link final-project-cyber/projects/c2-zero-trust-identity-pki.md %}) | Private CA, SSH CA, MFA, and mTLS with automated issue, renew, and revoke |
| C3 | [Detection Engineering / SOC-in-a-Box]({% link final-project-cyber/projects/c3-detection-engineering-soc.md %}) | SIEM pipeline, scripted attacks mapped to ATT&CK, detections, and response |
| C4 | [Compliance-as-Code Pipeline]({% link final-project-cyber/projects/c4-compliance-as-code.md %}) | CI pipeline that applies, scans, gates, detects drift, and remediates |
| C5 | [Secure Container Platform]({% link final-project-cyber/projects/c5-secure-container-platform.md %}) | Hardened container host with scanned and signed images and least-privilege containers |
| C6 | [Patch and Vulnerability Management Program]({% link final-project-cyber/projects/c6-patch-vulnerability-management.md %}) | Authenticated scanning, risk-ranked remediation, tested patch cycles, and metrics |

See the [options overview]({% link final-project-cyber/projects/index.md %}) for a comparison of workload, risk, and lab resources.

---

## Standards for Every Option

- **Isolation.** Build and test only inside your own lab network.
- **Reproducibility.** Everything rebuilds from your portfolio repo using only the README.
- **Evidence.** Every claim is backed by output, logs, or reports.
- **Submission.** The proposal is a PDF uploaded to Learning Suite. The final package is submitted through your GitHub portfolio with the same pull-request workflow as labs; paste the PR link into Learning Suite. The presentation is a recording whose link you also submit in Learning Suite.
