---
title: Final Deliverables
parent: Final Project (Cyber Track)
nav_order: 3
---

# Final Project Deliverables
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

The final project is graded on two things, each out of 100 points and worth 5% of your course grade:

1. The **Final Documentation Package**: everything you built, documented so someone else could understand and rebuild it.
2. The **Recorded Presentation and Demo**: a video of you running your system and explaining it.

The specific documents and demos depend on your option. Find yours below.

| Option | Documentation package | Presentation and demo |
|---|---|---|
| C1 - Hardened Infrastructure Build | [Documentation]({% link final-project-cyber/projects/c1-hardened-infrastructure.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c1-hardened-infrastructure.md %}#presentation) |
| C2 - Zero-Trust Identity and PKI | [Documentation]({% link final-project-cyber/projects/c2-zero-trust-identity-pki.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c2-zero-trust-identity-pki.md %}#presentation) |
| C3 - Detection Engineering / SOC | [Documentation]({% link final-project-cyber/projects/c3-detection-engineering-soc.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c3-detection-engineering-soc.md %}#presentation) |
| C4 - Compliance-as-Code | [Documentation]({% link final-project-cyber/projects/c4-compliance-as-code.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c4-compliance-as-code.md %}#presentation) |
| C5 - Secure Container Platform | [Documentation]({% link final-project-cyber/projects/c5-secure-container-platform.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c5-secure-container-platform.md %}#presentation) |
| C6 - Patch and Vulnerability Management | [Documentation]({% link final-project-cyber/projects/c6-patch-vulnerability-management.md %}#documentation) | [Demo]({% link final-project-cyber/projects/c6-patch-vulnerability-management.md %}#presentation) |

---

## Final Documentation Package

### Submission {#submission}

Submit everything in Learning Suite by **11:59 PM on December 10**. You can upload the files, or submit a link to where they are (for example a GitHub repository or a shared folder). If you submit a link, make sure the instructor and TAs can open it without requesting access, and do not change its contents after the deadline. Organize the package so a grader can navigate it from a `README.md` at the top level.

### Required for every option

- **`README.md`** at the top level of your package: what the project is, a table of contents linking every deliverable, prerequisites, and exact commands to rebuild the environment from scratch.
- **Architecture diagram** committed as an image or PDF. A good diagram labels every component with hostname, IP, and role, shows network zones and trust boundaries, and shows the direction of the important data flows. Diagrams that are generic shapes without labels do not receive full credit.
- **Lessons learned** (`lessons-learned.md`), answering four prompts specifically:
  - What went well, and why (name actual decisions that paid off)
  - What failed or took significantly longer than planned (be honest)
  - What you would do differently if starting over (at least one concrete change)
  - One recommendation for a student taking this course next year

Your option's page lists the remaining documents and the rubric.

### A note on quality

Write for a reader who was not in the room: an engineer joining your team next month. Specific, tested, honest documentation earns more credit than long documentation.

---

## Recorded Presentation and Demo {#presentation}

### Format

Record a video of **10 minutes or less** and submit the link in Learning Suite by **11:59 PM on December 10**, the same deadline as the documentation package. There are no in-class presentations. Pairs submit one recording, and both partners must speak in it.

Each option has **three required demos**, listed on its page, plus a short architecture overview and a discussion of your design decisions and trade-offs.

### Recording requirements

- **Link access.** Submit a link that the instructor and TAs can open without requesting access (for example an unlisted video or a shared recording link). Keep it available until final grades are posted.
- **Real runs.** Demos must be actual runs of your system, captured on screen. Show the terminal or dashboard clearly, with the hostname and clock visible where practical. You may cut between demos, but do not edit or splice within a demo, and do not show output you did not produce.
- **Readable.** Use a large terminal font, close unrelated windows, and make sure your narration is clear.
- **Length.** Stay within 10 minutes. Content past 10 minutes will not be graded.

### Expectations

- **Architecture overview.** Explain what you built, why you made the major choices, and how it fits together, in your own words. Do not read from a script.
- **Demos.** Say what you are about to show, run it, and say what the result proves. A demo that works but is not explained earns partial credit. Demos can be speed up if they take too long.
- **Decisions and trade-offs.** Take the place of live questions. Cover what you chose and what you rejected, how the system can fail, and what you would change.
- **Pairs.** Both partners speak, and both should be able to explain any part of the project, not only the parts they owned.

{: .tip }
Rehearse, then record as many takes as you need and submit the best one. Test the link in a private browser window before you submit it.

[Back to Final Project Overview]({% link final-project-cyber/index.md %})
