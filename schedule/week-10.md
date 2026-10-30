---
title: "Week 10"
parent: Schedule
nav_order: 10
---

# Week 10 - Midterm, Configuration Management & Cloud Fundamentals
{: .no_toc }

---

## Topics

- Midterm tabletop exercise: individual assessment covering material from Weeks 1-9; see the syllabus for the access window and rules
- On-prem virtualization administration: VM lifecycle (create/clone from template), snapshots, live resize, live migration - the operational skill IaC automates in the cloud
- Infrastructure-as-Code (IaC) concepts and security implications
- Ansible architecture (inventory, playbooks, roles, vault); idempotency and configuration drift detection
- Terraform basics (providers, state, plan/apply); secrets management in IaC
- Cloud computing service models: IaaS, PaaS, SaaS, FaaS
- AWS and Azure core services: VPCs, subnets, route tables, IGW, NAT gateways, EC2/Azure VM lifecycle
- Cloud storage: S3/Blob, EFS/Azure Files; shared responsibility model
- AWS CLI and Azure CLI: authentication, core EC2/VPC commands, EBS management, JMESPath output formatting
- Containers and Docker: images, layers, registries, namespaces, cgroups; essential Docker commands; volumes and networking; Docker Compose

## Supplemental Readings & Videos

### Readings

- [Ansible getting started](https://docs.ansible.com/ansible/latest/getting_started/index.html) — Introduces inventories, playbooks, and the workflow used to automate system configuration.
- [AWS Shared Responsibility Model](https://aws.amazon.com/compliance/shared-responsibility-model/) — Clarifies provider and customer responsibilities when operating cloud infrastructure.

### Videos

- [AWS Shared Responsibility Overview](https://www.youtube.com/watch?v=U632-ND7dKQ) — An AWS video explains the provider and customer sides of cloud security.

---
## Slides

[Configuration Management & Cloud Fundamentals]({{ site.baseurl }}/lectures/CYBER444_Week09_Configuration_Management_and_Cloud_Fundamentals.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **Both Tracks** | [LAB 10 - Infrastructure as Code: Terraform & Ansible]({% link labs/lab-10.md %}) |

---

## Homework

None this week.

---

[← Previous Week]({{ site.baseurl }}/schedule/week-09/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-11/)
{: .text-right }
