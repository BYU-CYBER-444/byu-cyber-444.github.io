---
title: "IT HW 9 - Cloud Migration Plan with IaC"
parent: Homework
nav_order: 109
---

# IT HW 9 - Cloud Migration Plan with IaC
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
| **Assignment** | IT HW 9 |
| **Points** | 100 |
| **Due** | Week 10 |
| **Track** | IT |

---

## Description

Design a cloud migration plan for Valley Medical Group and back it up with real IaC. A plan without implementation evidence is a slide deck - production engineers ship code.

**Scenario:** Valley Medical Group currently runs on-premises: 1 Nginx web server (Ubuntu 22.04, 4 vCPU/8 GB), 1 Django app server (Ubuntu 22.04, 8 vCPU/16 GB), 1 PostgreSQL 15 database (Ubuntu 22.04, 8 vCPU/32 GB, 2 TB data), 1 Samba file server (10 TB, 300 employees), 1 restic backup server (20 TB). Leadership wants full cloud migration within 6 months. Budget: $5,000/month. HIPAA compliance required.

### Part 1 - Cloud Provider Selection & Justification (10 pts)

Choose AWS or Azure. Your justification must address:

- At least 3 HIPAA-specific capabilities (BAA availability, encryption at rest/transit enforcement, audit logging - cite the specific service names)
- Total cost estimate across all workloads using your chosen provider's pricing (show your math - instance type, storage, data transfer)
- Whether the $5,000/month budget is achievable and what trade-offs are required if it is not

### Part 2 - Service Mapping & Architecture (20 pts)

For each on-premises workload, specify the target cloud service, instance type/tier, and migration approach (lift-and-shift / re-platform / refactor). Justify each choice.

Draw or describe the target network architecture:
- VPC/VNet with at minimum: public subnet (web), private subnet (app), isolated subnet (database), management subnet
- Security group rules for each subnet (source/destination/port - be specific)
- NAT gateway placement
- VPN or Direct Connect for on-premises connectivity during the 6-month parallel-run period

### Part 3 - Terraform Network Module (35 pts)

Write a Terraform module that provisions the VPC/VNet and subnets from Part 2. Your code must:

- Define the VPC and at least 3 subnets with correct CIDR blocks
- Create security groups for the web tier (ports 80/443 from 0.0.0.0/0, all else denied) and app tier (port 8000 from web-sg only)
- Create an Internet Gateway and route table for the public subnet
- Create a NAT Gateway and route table for the private subnets
- Use variables for all environment-specific values (region, CIDR blocks, environment name)
- Include meaningful resource tags (Environment, Owner, CostCenter, Compliance)
- Be syntactically valid - run `terraform validate` and include the output in your submission

You do not need to run `terraform apply` - validate and plan output is sufficient.

### Part 4 - HIPAA Compliance Mapping (20 pts)

Produce a compliance mapping table that maps each HIPAA Technical Safeguard to a specific cloud service or configuration in your design:

| HIPAA §164.312 | Requirement | Cloud Service/Config | How It Satisfies the Requirement |
|---|---|---|---|

Cover all 5 Technical Safeguard standards: Access Control, Audit Controls, Integrity, Person/Entity Authentication, Transmission Security.

For encryption: specify which keys are managed by the provider vs. customer (CMK), and where KMS or Key Vault fits in.

### Part 5 - Cost Optimization Analysis (15 pts)

For your two most expensive workloads (by monthly cost), compare three purchasing options:
- On-Demand
- 1-year Reserved/Committed Use
- Savings Plans or Spot (where applicable)

Calculate 1-year total cost for each option. Recommend an option for each workload and justify based on Valley Medical Group's stability of demand and cash flow constraints. Include a break-even analysis: at what utilization level does Reserved pricing pay off vs. On-Demand?

---

## Deliverable(s)

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow runs `terraform validate` and `terraform fmt -check` against your submitted module. This only confirms your HCL parses and is internally consistent - it does not run `terraform apply` against a real account and says nothing about whether your network design is good. That part is graded by hand.

Write your full plan in `homework/it-hw-09.md`. Commit your Terraform files to `homework/assets/it-hw-09-terraform/`:

- `main.tf` - VPC/network resources
- `variables.tf` - all input variables with descriptions and defaults
- `outputs.tf` - key outputs (VPC ID, subnet IDs, security group IDs)
- `it-hw-09-terraform-validate.txt` - output of `terraform validate`

Open a PR titled `IT HW 9 - Cloud Migration Plan` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Provider selection - HIPAA justification, cost math | 10 |
| Service mapping + network architecture | 20 |
| Terraform module - validity, security groups, variables, tags | 35 |
| HIPAA compliance mapping - all 5 standards covered | 20 |
| Cost optimization - three options compared, break-even calculated | 15 |

---

## Tip

{: .tip }
`terraform validate` only checks syntax - it does not check that resources will actually deploy. Read the error messages carefully; they tell you exactly which argument is wrong.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 6 - CSPM & Cloud Risk Assessment (30 pts)

**Cloud Security Posture Management (CSPM) Check (15 pts)**

Implement a **continuous compliance check** that validates your deployed infrastructure against your HIPAA compliance mapping:

Write `it-hw-09-cspm.py` that uses boto3 (or equivalent cloud SDK) to verify your top 5 most critical HIPAA controls are in place. For each control:
- Check the actual cloud resource configuration (not the Terraform state)
- Return a structured result: `{ "control_id": "HIPAA-SC-28", "description": "...", "status": "PASS|FAIL|WARN", "resource": "arn:...", "detail": "..." }`
- If any check FAILs, exit with code 1

Extend your Terraform to deploy this script as a scheduled Lambda (every 24h), with results published to an SNS topic that sends an email alert on any FAIL. The Lambda execution role must have least-privilege IAM permissions - document what permissions it needs and why.

Demonstrate the CSPM check by deliberately introducing a drift (e.g., disabling encryption on an S3 bucket via the console) and showing your Lambda catching and alerting on it within 24 hours (or trigger it manually).

**Cloud Risk Assessment (15 pts)**

Using the **CSA Cloud Controls Matrix (CCM) v4** as your framework, write a formal **Cloud Risk Assessment** (`it-hw-09-cloud-risk.md`) covering your top 5 cloud-specific risks:

For each risk:
1. Map it to a CCM control domain (e.g., DSP-07, IAM-02)
2. Describe the risk in terms of your specific deployment (not generic cloud risk)
3. Identify the shared responsibility boundary - is this the cloud provider's responsibility, yours, or shared?
4. Rate likelihood and impact (1-5 scale, with justification)
5. Describe the current control in place and its residual risk
6. Propose one additional control and estimate its implementation effort

Required risk categories to include: data residency/sovereignty, key management (who controls the encryption keys), vendor lock-in, IAM boundary failure (what happens if your AWS root account is compromised), and one risk specific to your HIPAA use case.


[← Back to Homework]({{ site.baseurl }}/homework/)
