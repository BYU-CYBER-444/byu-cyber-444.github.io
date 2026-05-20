---
title: Portfolio Setup
parent: Resources
nav_order: 1
---

# Portfolio Site Setup
{: .no_toc }

Lab reports, homework assignments, and the final project are all submitted through your personal GitHub Pages portfolio site. This page walks you through the one-time setup at the start of the semester and the PR workflow used for every submission.

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Why GitHub?

Professional sysadmins document their work constantly — runbooks, incident reports, change requests, post-mortems, gap analyses, hardening plans. That documentation almost always lives in a version-controlled repo and goes through a review process before it becomes official. This workflow gives you that practice from day one. By the end of the semester your portfolio will contain 14 lab reports, 12 homework write-ups, supporting scripts and config files, and a complete final project — a real artifact of the work you did in this course that you can show to employers.

---

## One-Time Setup (Week 1)

### 1. Accept the GitHub Classroom assignment

Click the invitation link posted on Learning Suite. GitHub Classroom will automatically create your portfolio repo (`cyber444-portfolio-yournetid`) under the course organization and pre-configure GitHub Pages for you.

### 2. Verify your site is live

After accepting the assignment, wait about 60 seconds and visit:

```
https://your-username.github.io/cyber444-portfolio-yournetid/
```

You should see the portfolio home page. If it shows a 404, wait another minute and refresh.

### 3. Customize your home page

Clone your repo locally, open `index.md`, and fill in your name, BYU NetID, and a brief bio. Commit directly to `main` for this initial edit:

```bash
git clone https://github.com/byu-cyber-444/cyber444-portfolio-yournetid
cd cyber444-portfolio-yournetid
# edit index.md
git add index.md
git commit -m "Add bio to home page"
git push origin main
```

### 4. Submit your portfolio URL on Learning Suite

Paste your live site URL into the Week 1 submission on Learning Suite. This is how the TA knows where to find your work all semester — you only need to do this once.

---

## Portfolio Structure

The template repo is pre-organized to match the course:

```
cyber444-portfolio-yournetid/
├── index.md                    ← Your home page (name, bio, course overview)
├── labs/
│   ├── index.md                ← Lab index (links populate as you add reports)
│   ├── lab-01.md               ← Each lab report lives here
│   ├── lab-02.md
│   └── assets/                 ← Screenshots, scan outputs, config files
│       ├── lab-01-scan.html
│       └── lab-02-screenshot.png
├── homework/
│   ├── index.md                ← Homework index
│   ├── hw-01.md                ← Each homework write-up lives here
│   ├── hw-02.md
│   └── assets/                 ← Supporting files (scripts, xlsx, policy docs)
│       └── hw-05-gap-analysis.xlsx
├── final-project/
│   ├── index.md                ← Project overview and proposal
│   ├── hardening-plan.md
│   ├── ssp.md
│   └── assets/
└── _config.yml                 ← Site configuration (do not modify)
```

---

## Submission Workflow

Labs and homework follow the same five-step PR process. This mirrors real change management — documentation is written on a branch, reviewed by a senior (the TA), and merged into the official record only after approval.

### Step 1 — Create a branch

```bash
git checkout main
git pull origin main
git checkout -b TYPE-NN-short-description
```

Use a consistent naming convention:
- Labs: `lab-03-windows-hardening`
- Homework: `hw-05-cis-gap-analysis`
- Final project milestones: `project-proposal`, `project-hardening-plan`

### Step 2 — Write your submission

**For labs** — create `labs/lab-NN.md` as a runbook (see Lab Report Template below). Commit supporting artifacts to `labs/assets/`: config files, scripts, scan outputs, screenshots.

**For homework** — create `homework/hw-NN.md` as a written analysis (see Homework Template below). Commit any supporting files (scripts, spreadsheets, policy docs) to `homework/assets/`.

### Step 3 — Commit your work

```bash
# For a lab:
git add labs/lab-NN.md labs/assets/
git commit -m "Lab NN: brief description"
git push origin lab-NN-short-description

# For homework:
git add homework/hw-NN.md homework/assets/
git commit -m "HW NN: brief description"
git push origin hw-NN-short-description
```

### Step 4 — Open a pull request

1. Go to your repo on GitHub
2. Click **Compare & pull request** on your branch
3. Use the title format:
   - `Lab NN — Topic` (e.g., `Lab 03 — Windows Server Hardening`)
   - `HW NN — Topic` (e.g., `HW 05 — CIS Benchmark Gap Analysis`)
4. In the description, paste the link to the assignment page on the course site
5. Click **Create pull request**

The TA will review your PR and may leave inline comments on specific lines of your Markdown or committed files. Address feedback by adding commits to the same branch — the PR updates automatically.

### Step 5 — Submit the PR link on Learning Suite

Paste your pull request URL into Learning Suite by the assignment due date. Do **not** merge the PR yourself — the TA approves and merges it once grading is complete, at which point your submission goes live on your portfolio site.

---

## Lab Report Template

Copy this into `labs/lab-NN.md` for each lab:

```markdown
---
title: "Lab NN — Topic"
parent: Labs
nav_order: NN
---

# Lab NN — Topic
{: .no_toc }

**Date completed:** Month DD, 2026  
**Environment:** Ubuntu 22.04 LTS / Windows Server 2022 *(describe your setup)*

---

## Objective

One or two sentences describing what this lab set out to accomplish.

---

## Environment & Tools

| Item | Version / Detail |
|---|---|
| OS | Ubuntu 22.04.3 LTS |
| Tool | version |

---

## Procedure

### Step 1 — Step name

Describe what you did and why. Include exact commands:

\`\`\`bash
command --flag argument
\`\`\`

Expected output:
\`\`\`
output here
\`\`\`

Actual output / screenshot: ![description](assets/lab-NN-step1.png)

### Step 2 — Step name

...

---

## Results & Findings

Summarize what you observed. Include before/after comparisons where applicable
(e.g., CIS-CAT score before and after hardening).

---

## Challenges & Troubleshooting

Describe errors you hit and how you resolved them. This section demonstrates
real troubleshooting ability — do not skip it.

---

## Reflection

Two to three sentences: what did this lab teach you, and how does it connect
to real-world sysadmin practice?
```

---

## Homework Template

Copy this into `homework/hw-NN.md` for each assignment:

```markdown
---
title: "HW NN — Topic"
parent: Homework
nav_order: NN
---

# HW NN — Topic
{: .no_toc }

**Due:** Day, Month DD, 2026  
**Submitted:** Month DD, 2026

---

## Overview

One or two sentences restating the assignment objective in your own words.

---

## Analysis / Findings

Your main written response. Use sub-headings to organize longer responses.
Commit any supporting files (scripts, spreadsheets, configs) to
`homework/assets/` and reference them here with links or code blocks.

---

## References

List any documentation, standards, or tools you referenced.
```

---

## Grading Rubrics

### Labs

| Criterion | Points |
|---|---|
| Procedure documented with commands and actual output | 40 |
| Supporting artifacts committed (configs, scripts, scans) | 20 |
| Results and findings clearly explained | 20 |
| Challenges / troubleshooting section completed | 10 |
| Reflection connects lab to professional practice | 10 |
| **Total** | **100** |

### Homework

| Criterion | Points |
|---|---|
| Directly addresses all parts of the assignment prompt | 40 |
| Analysis is accurate and technically grounded | 30 |
| Supporting files committed where required | 15 |
| Writing is clear and professionally formatted | 15 |
| **Total** | **100** |

The TA may deduct points for missing artifacts, vague responses that don't demonstrate understanding, or submissions that are not reproducible from what's committed.
