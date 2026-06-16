---
title: "IT HW 10 - IAM Audit & Least-Privilege Remediation"
parent: Homework
nav_order: 110
---

# IT HW 10 - IAM Audit & Least-Privilege Remediation
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | IT HW 10 |
| **Points** | 100 |
| **Due** | Week 11 |
| **Track** | IT |

---

## Description

You have been handed access to IAM policy JSON files for a simulated AWS account (available on Learning Suite: `IAMAudit_HW10.zip`). The account has 6 IAM users and 4 roles configured by a previous admin with no least-privilege review. A recent security assessment flagged this account as critical risk. Your job is to audit every entity, produce a remediation report, and write corrected policies.

### Part 1 - Executive Risk Summary (10 pts)

Write a 1-page executive summary for the CISO. Lead with the most critical finding. Include a summary table showing each entity's current risk rating (Critical/High/Medium/Low) and the estimated blast radius if those credentials were compromised (what could an attacker do?). Use dollar or business terms - "an attacker could exfiltrate all S3 data, including PHI stored in the patient-records bucket, triggering HIPAA breach notification for up to 50,000 patients."

### Part 2 - Full Entity Audit (50 pts)

For each of the 6 users and 4 roles, document:

1. **Entity name, type, and purpose** (what is this entity supposed to do?)
2. **All attached policies** - managed and inline
3. **Effective permissions summary** - what can this entity actually do? Summarize in plain English, focusing on dangerous permissions (write/delete/admin on sensitive services)
4. **Violations found** - list every least-privilege violation:
   - Overly broad actions (e.g., `s3:*` where only `s3:GetObject` on one bucket is needed)
   - Wildcard resources where a specific ARN would suffice
   - Unused permissions (identify permissions that are attached but not needed for the stated purpose)
   - Admin-equivalent permissions granted to non-admin entities (look for `iam:PassRole`, `sts:AssumeRole *`, `ec2:RunInstances` with `iam:PassRole`, etc.)
5. **Risk rating** - Critical / High / Medium / Low with justification
6. **Corrected policy** - write a least-privilege JSON IAM policy for any entity rated High or Critical (minimum 4 corrected policies)

### Part 3 - Permission Boundary (20 pts)

Write a **Permission Boundary policy** in JSON that would limit the maximum permissions any developer IAM user in this account can have, regardless of what policies are attached to them. The boundary must:

- Allow EC2 read-only access and the ability to start/stop (but not terminate) instances
- Allow S3 access only to the `dev-*` and `staging-*` prefix paths in the `acme-app-data` bucket
- Allow CloudWatch Logs write access for the developer's own log groups (use a condition key)
- Explicitly deny: IAM policy changes, S3 access to production buckets, and VPC/security-group modification
- Deny all actions outside `us-west-2` using a `Condition` block

Explain in 2-3 paragraphs how Permission Boundaries interact with identity-based policies, and give an example of a scenario where a boundary prevents privilege escalation even if a developer somehow gets `iam:*` attached.

### Part 4 - Automated Remediation Script (20 pts)

Write a bash script using the AWS CLI (`hw-10-remediate.sh`) that performs the following for one of the high-risk users you identified:

1. Lists all currently attached managed policies
2. Detaches all attached managed policies
3. Lists and deletes all inline policies
4. Attaches your corrected policy (created and named in the script using `aws iam create-policy`)
5. Attaches the Permission Boundary from Part 3
6. Generates a credential report and confirms the user's last activity

The script must handle errors gracefully - if any `aws` command fails, print the error and exit with a non-zero code. Use `set -euo pipefail`. Include a `--dry-run` flag that prints the commands that would be run without executing them.

---

## Deliverable(s)

Write your full audit in `homework/it-hw-10.md`. Commit to `homework/assets/`:

- `it-hw-10-corrected-policies/` - directory containing your corrected JSON policy files (one file per entity)
- `it-hw-10-permission-boundary.json` - your Permission Boundary policy
- `it-hw-10-remediate.sh` - your remediation script

Open a PR titled `IT HW 10 - IAM Audit` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Executive summary - business impact framing | 10 |
| Entity audit - violations found, effective permissions accurate | 50 |
| Permission boundary - correct deny/allow logic, condition keys used | 20 |
| Remediation script - error handling, dry-run, correct CLI usage | 20 |

---

## Tip

{: .tip }
Use the IAM Policy Simulator (or `aws iam simulate-principal-policy` CLI) to verify your corrected policies actually deny the permissions you intend to deny. Paste the simulator output for at least one entity into your write-up.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Continuous Access Review & Automated Enforcement (30 pts)

**Automated Quarterly Access Review Report (15 pts)**

Write `it-hw-10-access-review.py` that generates a **quarterly access review report** suitable for distribution to resource owners for certification:

1. Query IAM for all users, their attached policies, group memberships, and last activity (use `generate_credential_report` + `get_credential_report`)
2. For each IAM role, list the principals that can assume it (`get-role` trust policy parsing) and the last time it was assumed (CloudTrail: `AssumeRole` events in the last 90 days)
3. Produce a CSV report with columns: `Principal`, `Type` (User/Role), `AttachedPolicies`, `InlinePolicies`, `Groups`, `LastActivity`, `DaysSinceActivity`, `CanAssumeRoles`, `ReviewDecision` (blank - to be filled by resource owner), `Reviewer`, `ReviewDate`
4. Flag any principal with `DaysSinceActivity > 90` in a separate "Stale Access" tab
5. Email the report as a CSV attachment using SES (or simulate with a local file write if SES is not configured)

**Automated Permission Boundary Enforcement (15 pts)**

Implement a **detective + corrective control** using a Lambda function (`it-hw-10-boundary-enforcer`):

1. Trigger: EventBridge rule on `iam:CreateRole` API calls
2. Logic:
   - Check if the new role has your Permission Boundary policy attached
   - If NOT: immediately attach the Permission Boundary, then publish an SNS alert: `{ "violation": "Role created without Permission Boundary", "role_arn": "...", "created_by": "...", "action_taken": "Boundary attached automatically", "timestamp": "..." }`
3. The Lambda execution role must itself have a Permission Boundary (no recursive privilege escalation)
4. Write a pytest test that mocks `boto3` and verifies: (a) the boundary is attached when missing, (b) the SNS alert fires, (c) if the boundary is already present, neither action occurs

Document this as a **Detective + Corrective Control** in your IAM Audit report, explaining why automated enforcement is preferred over manual review for this specific control.


[← Back to Homework]({{ site.baseurl }}/homework/)
