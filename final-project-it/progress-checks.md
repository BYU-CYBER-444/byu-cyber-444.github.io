---
title: Progress Checks
parent: Final Project (IT Track)
nav_order: 2
---

# IT Track Final Project Progress Checks
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Progress Check 1 - Infrastructure Build

**Due:** End of Week 10

Submit your cloud environment and HA cluster in their current state. This checkpoint verifies that your core infrastructure is functional before you layer monitoring and documentation on top.

### Requirements

**1. Cloud Environment**

Your cloud environment must include all of the following and be functional at submission time:

- VPC or VNet with at least one public subnet and one private subnet (matching your proposal's CIDR plan)
- At minimum 2 running compute instances (EC2 or Azure VM), each reachable via SSH
- Security groups or NSGs configured with specific allow rules - no `0.0.0.0/0` on ports other than 80/443 (SSH must be restricted to your IP)
- An IAM user or service principal with a custom least-privilege policy attached. The policy must grant only the permissions your use case requires - no `*` actions or `*` resources unless specifically justified
- CLI or console evidence: include a screenshot or command output showing instances in running state and the IAM policy JSON

**2. High-Availability Cluster**

Your HA cluster must include all of the following:

- HAProxy installed and configured on a dedicated load balancer node, round-robining HTTP traffic to both backend app servers
- keepalived running on the load balancer with a VRRP virtual IP configured
- Failover test completed and documented: stop keepalived on the active node, run `ip addr show` on both nodes before and after, confirm the VIP moves
- Include your `/etc/haproxy/haproxy.cfg` and `/etc/keepalived/keepalived.conf` in the repo

**3. Cloud IAM Verification**

Demonstrate least-privilege enforcement with CLI output:

```bash
# Allowed action - should succeed
aws ec2 describe-instances --profile lab-readonly

# Denied action - should return AccessDenied
aws ec2 run-instances --image-id ami-12345 --profile lab-readonly
```

Include the actual terminal output (success + AccessDenied error) in your submission.

**4. Repo and README**

Commit all configuration files to your portfolio repo in a `final-project-it/` directory. Your `README.md` must cover:

- Architecture overview (which machine does what)
- Prerequisites (OS, packages, cloud provider credentials)
- Step-by-step instructions to reproduce the environment from scratch
- Current status and known gaps

### Submission

Open a PR titled `IT Final Project - Progress Check 1` and submit the PR link on Learning Suite by the end of Week 10.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Cloud Environment | 25 | VPC with public + private subnets, security groups with specific rules, 2+ instances running and reachable | VPC and instances running; security groups use overly broad rules | Missing subnets, instances not reachable, or not in cloud at all |
| HA Cluster | 30 | HAProxy round-robins to both app servers; keepalived holds VIP; failover test documented with before/after `ip addr` output | HAProxy and keepalived configured and running; failover not yet tested | Load balancer or VRRP not functional |
| Cloud IAM | 25 | Custom least-privilege policy; named IAM user/role with policy attached; CLI output shows allowed action succeeds and denied action returns AccessDenied | IAM policy created and attached; allowed/denied test not both demonstrated | IAM not configured or using root/admin credentials |
| Repo and README | 20 | All config files committed; README covers architecture, prerequisites, and exact reproduction steps; PR submitted on time | Files committed; README present but missing key sections | No PR or critical config files missing |

---

## Progress Check 2 - Monitoring & Documentation {#progress-check-2}

**Due:** End of Week 12

Submit your monitoring stack and first drafts of your ITSM and policy documentation. This checkpoint verifies that observability is in place and that the documentation package is substantially complete before the final week.

### Requirements

**1. Monitoring Stack**

Your Prometheus + Grafana deployment must be functional:

- Prometheus running and scraping node_exporter metrics from all target machines (cloud instances and HA cluster nodes)
- Grafana connected to Prometheus as a data source, with at least 3 working dashboard panels:
  - CPU utilization (all nodes)
  - Memory utilization (all nodes)
  - Disk usage (primary disk on each node)
- At least one Prometheus alert rule configured in `alerts.yml` - a `HighCPUUsage` rule that fires when CPU exceeds 80% for 5 minutes is the minimum. Include evidence that the rule is loaded (output of `curl localhost:9090/api/v1/rules`).
- Stress test: run `stress --cpu 4 --timeout 30s` on one node and include a Grafana screenshot showing the CPU spike

**2. ITSM Documentation**

Submit drafts of all four ITSM records:

- **Service Catalog Entry:** One-page description of the IT infrastructure service - service name, description, service owner, SLA, request process, and escalation path
- **RFC:** All 9 required fields - title, change type (normal/emergency/standard), description, justification, risk assessment, rollback plan, implementation steps, required approvals, and post-implementation test plan
- **Incident Ticket:** A fully populated ticket from your simulated outage scenario, including: description, P-level, timeline (from first alert to resolution), impact assessment, and resolution steps
- **PIR:** Draft Post-Incident Review including 5 Whys analysis. The fifth "why" must reach a systemic root cause (a process gap or architectural weakness), not just restate the immediate cause

**3. Policy Package Draft**

Submit drafts of all three policy documents. Drafts at this stage should be substantially complete - not outlines:

- **AUP:** Must have all 7 sections and at least 10 specific prohibited activities listed. The AI tool usage section must be present, even if still being refined
- **Data Classification Policy:** Must have all 4 tiers defined with handling requirements for storage, transmission, access, disposal, and labeling. At least one healthcare-specific example per tier
- **BYOD Policy:** Must include the MDM enrollment requirement, remote wipe circumstances, and your explicit decision on PHI access from personal devices

**4. AI Infrastructure Proposal Draft**

Submit a draft that covers at minimum:

- Use case definition (3 specific use cases with data access described)
- Hardware specification (CPU, RAM, GPU decision with justification)
- Open-weight model selection with context window and RAM requirement cited
- Data handling policy (what data may be submitted, how prompts are logged, retention period)

### Submission

Open a PR titled `IT Final Project - Progress Check 2` and submit the PR link on Learning Suite by the end of Week 12.

### Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Monitoring Stack | 30 | Prometheus scraping all nodes; Grafana has 3+ working panels; alert rule loaded; CPU spike test with Grafana screenshot | Prometheus and Grafana running; dashboards present but scraping fewer than all nodes or alert not configured | Monitoring not functional or only running on one node |
| ITSM Documentation | 30 | All 4 records present: service catalog, RFC (9 fields), incident ticket (full timeline + impact), PIR with 5 Whys reaching systemic root cause | 3 of 4 records complete and detailed; PIR root cause stays at symptom level | Fewer than 3 records or records are templates with placeholder text |
| Policy Package Draft | 25 | AUP (7 sections, 10+ prohibited activities, AI section), data classification (4 tiers with handling requirements, healthcare examples), BYOD (MDM, remote wipe, PHI decision) - all substantially complete | All three policies present; 1-2 sections thin or still at outline stage | Fewer than 3 policies or majority of content is placeholder |
| AI Proposal Draft | 15 | Use cases, hardware spec with justification, model selection with RAM cited, data handling policy - all present | Use cases and hardware spec present; data handling policy thin | Fewer than 3 sections present or hardware spec not actionable |

[Back to IT Track Final Project Overview]({% link final-project-it/index.md %})
