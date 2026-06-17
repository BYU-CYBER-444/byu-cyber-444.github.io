---
title: Final Deliverables
parent: Final Project (IT Track)
nav_order: 3
---

# IT Track Final Project Deliverables
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Final Documentation Package

All final project deliverables are submitted through your GitHub portfolio using the same PR workflow as labs and homework. Open a PR titled `IT Final Project - [Your Project Name]` and submit the PR link on Learning Suite before 11:59 PM on the last day of classes.

Everything must be committed to a `final-project-it/` directory in your portfolio repo. The grader must be able to navigate your entire project from the `README.md` at the root of that directory.

---

### 1. Architecture Diagram

Your diagram must be a committed image file (`architecture-diagram.png` or `.pdf`) and must show:

- All infrastructure components: cloud VPC/VNet, subnets, security groups, EC2/VM instances, HA load balancer node, both backend app servers, and the monitoring host
- Hostnames, IP addresses, and roles for every node
- The VRRP virtual IP and which node currently holds it
- Network zone boundaries (cloud vs. on-prem, public subnet vs. private subnet)
- Monitoring data flows (which nodes are scraped by Prometheus, where Grafana is accessed from)
- Any external access paths (how administrators reach the environment)

Diagrams that use only generic shapes without labels, IPs, or data flows will not receive full credit.

---

### 2. ITSM Package

Commit all four ITSM records to `final-project-it/itsm/`. Each must be a standalone Markdown file:

**`service-catalog.md` - Service Catalog Entry**

A one-page service description for the IT infrastructure you built, written as if it would be published in the organization's service portal. Required fields: service name, service description (what it does and who it serves), service owner, hours of operation, SLA targets (availability %, RTO, RPO), how to request access, and escalation path.

**`rfc.md` - Request for Change**

A formal RFC covering the infrastructure deployment. All 9 fields required:

1. Change title
2. Change type (Normal / Emergency / Standard - justify the classification)
3. Description of the change
4. Business justification
5. Risk assessment (likelihood and impact of failure, with a rollback trigger condition)
6. Rollback plan (specific steps to revert if the change fails)
7. Implementation steps (numbered, specific enough for a technician who wasn't involved in planning)
8. Required approvals (who must sign off - change submitter, manager, CAB)
9. Post-implementation test plan (how you verify the change succeeded)

**`incident-ticket.md` - Incident Ticket**

A fully populated incident ticket from your simulated outage scenario. Required fields: incident title, P-level with justification, date/time opened, date/time resolved, affected services, users impacted, timeline (chronological table from first alert to resolution, using the same format as IT LAB 14), root cause (brief - the full analysis goes in the PIR), and resolution steps taken.

**`pir.md` - Post-Incident Review**

A formal PIR following the structure from IT HW 14:

1. Incident summary (title, date/time, duration, P-level, affected services, users impacted)
2. Timeline (chronological table)
3. Root cause analysis - 5 Whys, documented layer by layer. The fifth layer must reach a systemic root cause: a process gap, architectural weakness, or missing control - not just a restatement of the immediate failure
4. Impact assessment (quantified: downtime duration, users affected, estimated productivity or revenue impact)
5. What went well (at least 3 items)
6. What needs improvement (at least 3 items - specific and actionable; "improve monitoring" is not acceptable; "add a Prometheus alert for disk utilization above 85% with a 10-minute evaluation window" is)
7. Action items table (task, owner, due date, priority)
8. KEDB entry - one concise paragraph written for a help desk analyst: "If you receive a ticket reporting X, the known cause is Y. Apply workaround Z while the permanent fix (ticket #) is implemented."

---

### 3. Policy Package

Commit all three policy documents to `final-project-it/policies/`. Each must be a standalone Markdown file ready for a real CISO to review.

**`aup.md` - Acceptable Use Policy**

- All 7 sections: Purpose, Scope, Definitions, Acceptable Use, Prohibited Activities, Enforcement, Acknowledgment
- Minimum 10 specific prohibited activities - each must be specific enough to be unambiguous. "Do not misuse IT resources" is not acceptable; "Users may not install software on company-owned devices without prior approval from the IT department" is
- AI tool usage section: specify which AI tools are approved for use, what data may and may not be submitted to AI tools, and the consequences for submitting PHI or confidential data to an unapproved AI service (reference your HW 12 proposal for consistency)
- Signature/acknowledgment block that employees will sign at onboarding

**`data-classification.md` - Data Classification Policy**

- Policy statement and purpose
- Scope (who and what systems this covers)
- 4-tier classification scheme. For each tier: tier name, definition, at least 2 healthcare-specific examples, and full handling requirements covering storage (encryption at rest? where stored?), transmission (encryption in transit? approved methods?), access (who may access? authentication requirements?), disposal (shredding? secure wipe?), and labeling (how is data labeled in emails, files, and systems?)
- Roles and responsibilities: who is responsible for classifying data, who enforces the policy, and who audits compliance
- De-classification and re-classification procedures: under what circumstances can data move to a lower tier, and who authorizes the change

**`byod.md` - BYOD Policy**

- Approved device types and minimum OS version requirements (iOS, Android, macOS, Windows - state minimum versions)
- MDM enrollment requirement: name the MDM solution, what it can access on a personal device, and what it explicitly cannot access (personal photos, personal apps, etc.)
- Required device security settings: screen lock timeout, full-disk encryption requirement, biometric authentication requirement
- PHI access decision: explicitly state whether staff may access PHI on a personal device. If yes, under what conditions? If no, how will staff who need PHI access on the go be accommodated?
- Remote wipe policy: under what circumstances may IT remotely wipe a device, who authorizes it, and whether the wipe is limited to the work container or covers the entire device
- Containerization: describe how work data is separated from personal data (managed app container, work profile, etc.)
- Offboarding: what happens to the MDM enrollment, work container, and data when an employee leaves the organization

---

### 4. AI Infrastructure Proposal

Commit your complete proposal to `final-project-it/ai-proposal.md`. All 8 sections are required:

1. **Use Case Definition** - 3 specific use cases, what data the model will access for each, and why on-premises deployment is required (HIPAA rationale)
2. **Hardware Specification** - CPU (cores and generation), RAM (minimum justified based on model size), GPU decision (CPU-only vs. GPU with justification; if GPU, include model name and VRAM), storage (model weights, inference cache, logs), network interface, and estimated cost range
3. **Software Stack** - open-weight model selection (name, version, context window, RAM requirement), serving framework (Ollama, vLLM, LM Studio, etc.), and OS
4. **Access Control Design** - how clinical staff authenticate to the AI service (SSO, API key, certificate), role-based access (nurses vs. physicians vs. admin), and how access is revoked when an employee leaves
5. **Data Handling Policy** - what data may be submitted to the model, how prompts and responses are logged, retention period, and who can audit the logs
6. **Security Controls** - at minimum: network isolation (VLAN, no internet egress), encrypted storage for model weights, audit logging for all queries, and vulnerability management for the serving stack
7. **Acceptable Use Policy Addendum** - a 1-paragraph addition to Valley Medical Group's AUP specifically covering AI tool use by clinical staff (this should be consistent with the AI section in your AUP)
8. **Cost Summary** - one-time hardware cost, ongoing power/cooling estimate (watts × kWh rate × hours), and staff time for maintenance per month

---

### 5. Lessons Learned

Commit `final-project-it/lessons-learned.md`. Address all four prompts specifically:

- What went well and why - name specific technical or process decisions that paid off
- What failed or took significantly longer than planned - be honest; vague entries will not receive full credit
- What you would do differently if starting over - at least one concrete change to your architecture or approach
- One recommendation for a student taking this course next year - something specific that would have helped you

---

### Final Documentation Package Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Diagram | 15 | All components labeled with hostnames, IPs, and roles; HA topology, cloud boundary, VIP, and monitoring flows all shown; clean and readable | Diagram present; missing IPs, VIP, or monitoring flows | Too vague to represent actual infrastructure |
| ITSM Package | 25 | All 4 records complete and professional (service catalog, RFC 9 fields, incident ticket full timeline, PIR with 5 Whys to systemic root cause and KEDB entry) | 3 of 4 records complete and detailed; PIR root cause stays at symptom level | Fewer than 3 records or records contain placeholder text |
| Policy Package | 25 | AUP (7 sections, 10+ specific prohibitions, AI section, signature block), data classification (4 tiers, healthcare examples, handling requirements, roles, de-classification), BYOD (MDM, PHI decision, remote wipe, offboarding) - all production-ready | All 3 policies present; 1-2 sections thin or vague | Fewer than 3 policies or majority of content is draft quality |
| AI Infrastructure Proposal | 20 | All 8 sections complete; hardware spec is specific and justified; model selection cites context window and RAM; data handling and HIPAA controls addressed; AUP addendum present and consistent with AUP | 6-7 sections complete; hardware spec or data handling thin | Fewer than 6 sections or spec not actionable |
| Lessons Learned | 15 | Specific and reflective; addresses all 4 prompts with concrete details | Present but generic; prompts addressed at surface level | Missing or fewer than one paragraph |

---

## Live Presentation and Demo {#presentation}

Each student has **20 minutes** (15 min demo + 5 min Q&A). Presentations are held during the Week 15 class and lab session.

You must demonstrate all five components. Missing a component will be reflected directly in your rubric score.

---

### What to Demonstrate

**1. Architecture Overview (spoken, 2-3 minutes)**

Explain your infrastructure: what you built, why you made the key technology choices, and what you would change if you had more time. This should be spoken from memory using your architecture diagram as a visual aid - do not read from notes.

**2. HA Failover Demo (live)**

With HAProxy serving traffic to both backend app servers:

1. Run `curl http://<VIP>` and confirm it responds (shows which backend handled the request)
2. Stop keepalived on the active node: `sudo systemctl stop keepalived`
3. Immediately run `ip addr show` on both nodes to confirm the VIP has moved to the standby
4. Run `curl http://<VIP>` again and confirm traffic is still being served

All four steps must be completed live. Prepare a fallback recording if your environment is unstable.

**3. Monitoring Dashboard Demo (live)**

Open your Grafana instance and show:

1. Your CPU, memory, and disk panels with real data from all nodes
2. Run a load test live: `stress --cpu 4 --timeout 60s &`
3. Watch the CPU panel spike in real time
4. Show the Prometheus alert rules page and confirm your HighCPUUsage alert is firing or pending

**4. Cloud IAM Demo (live)**

Open a terminal with your least-privilege IAM user's CLI profile configured:

1. Show the IAM policy JSON (in the console or via `aws iam get-policy-version`)
2. Run an allowed action - it must succeed
3. Run a denied action - it must return an `AccessDenied` error

Narrate what the policy allows and why the denied action is blocked.

**5. ITSM & Policy Walkthrough (2-3 minutes)**

Walk through two documents from your final package:

- Open your PIR and read the 5 Whys analysis aloud - explain each layer and what the systemic root cause is
- Open one policy document and explain the most important decision you made (e.g., your PHI-on-BYOD decision and why)

You are not required to demo tools for this component - clear explanation of your written work is sufficient.

{: .tip }
Rehearse your demo at least twice before presentation day. Live demos fail - prepare screenshots or a screen recording for the HA failover and monitoring spike as backup so you can continue presenting even if your environment is unresponsive.

---

### Live Presentation Grading Rubric

| Criterion | Points | Excellent | Proficient | Developing |
|---|---|---|---|---|
| Architecture Overview | 15 | Clearly explains all infrastructure pillars, technology choices, and design decisions; delivered from memory | Covers the basics; some elements unclear or read from notes | Vague, skips key components, or clearly reading from a script |
| HA Failover Demo | 25 | All 4 steps completed live: traffic confirmed, keepalived stopped, VIP moved (shown via `ip addr`), traffic confirmed again | Demo runs; VIP movement visible but traffic continuity not verified, or one step skipped | Demo not attempted, fails completely, or replaced by screenshots only |
| Monitoring Dashboard Demo | 25 | Grafana shown live with all 3 panels; stress test triggered; CPU spike visible; Prometheus alert fires or enters pending state | Dashboard shown; stress test run but alert not visible, or fewer than 3 panels | Dashboard not functional, not shown, or alert not configured |
| Cloud IAM Demo | 20 | IAM policy shown; allowed action succeeds and denied action returns AccessDenied - both live in terminal | IAM policy shown; only one of allowed/denied demonstrated | Not attempted or no IAM policy configured |
| Q&A | 15 | Answers are accurate, specific, and confident; demonstrates deep understanding of design trade-offs | Most questions answered adequately | Answers vague, incorrect, or student defers all questions |

[Back to IT Track Final Project Overview]({% link final-project-it/index.md %})
