---
title: "IT HW 12 - On-Premises AI Inference Server Proposal"
parent: Homework
nav_order: 112
---

# IT HW 12 - On-Premises AI Inference Server Proposal
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
| **Assignment** | IT HW 12 |
| **Points** | 100 |
| **Due** | Week 13 |
| **Track** | IT |

---

## Description

Valley Medical Group's CISO has approved a pilot of an on-premises AI assistant for clinical staff. No patient data may leave the building - cloud AI APIs are prohibited by the HIPAA BAA review. You are writing the IT proposal that must survive a security and budget review.

### Part 1 - Use Case Definition & Data Flow (15 pts)

Define exactly 3 use cases. For each:

- What clinical task does the AI assist with?
- What data is submitted as a prompt (be specific - "the physician types a draft note" is not enough; describe what PHI fields could appear)
- What data the model receives vs. what stays client-side
- Why on-premises inference satisfies the HIPAA requirement that this use case could not meet with a cloud API

Then draw or describe the data flow diagram: from clinical workstation → AI request → inference server → response → workstation. Identify every point where PHI could be present and what protects it at each point.

### Part 2 - Model Evaluation & Selection (20 pts)

Evaluate **at least 3 open-weight models** for your use cases. For each model:

| Model | Parameters | Quantization Options | VRAM Required (Q4) | Context Window | License | Medical Benchmark Score (if available) |
|---|---|---|---|---|---|---|

Select one model and justify the choice based on: performance for clinical language tasks, hardware requirements vs. your proposed server, license compatibility with commercial clinical use, and context window adequacy for the longest prompt your use cases generate.

Explain the quantization trade-off: what does Q4_K_M cost you in accuracy compared to full precision, and is that acceptable given the use case?

### Part 3 - Hardware Specification (20 pts)

Propose a server specification. Your spec must be derived from the model's requirements - not a generic "powerful server." Include:

- CPU (cores, generation, why this matters for CPU-only inference throughput in tokens/sec)
- RAM (minimum for the model size + OS + concurrent requests - show your calculation)
- GPU decision: CPU-only vs. GPU inference. If GPU: model name, VRAM, expected tokens/sec improvement. If CPU-only: justify why the latency is acceptable for your use cases.
- Storage: model weights storage (show size calculation), inference cache, audit logs (show retention × log size calculation)
- Network: bandwidth requirements for concurrent users
- Estimated acquisition cost (name specific products and prices or quote ranges)
- Estimated monthly power cost (use server TDP and $0.12/kWh)

### Part 4 - Security Architecture (25 pts)

Design the full security architecture for this system:

**Network isolation:** Which VLAN? What firewall rules allow access to the inference server? What egress rules ensure the server cannot reach the internet? Write the specific firewall rules (source/destination/port/action).

**Authentication & authorization:** How do clinical staff authenticate to the AI service? Design a role-based access model (at minimum: Physician, Nurse, Admin-only). Specify whether you use API keys, SSO (which IdP?), or a reverse proxy with auth. Include the nginx or HAProxy config snippet for the auth proxy.

**Audit logging:** Every query to the inference server must be logged. Design the log schema (what fields are captured per request), the log destination, retention period, and who has access to audit logs. Write a sample log entry in JSON format.

**Incident response plan:** What is the response procedure if the inference server is compromised? Who is notified, in what order, and within what timeframe? How do you determine if any PHI-containing prompts were exfiltrated? What is the HIPAA breach determination checklist for this scenario?

### Part 5 - AUP Addendum & Governance (10 pts)

Write a 1-paragraph Acceptable Use Policy addendum for Valley Medical Group covering clinical AI assistant use. It must address: what staff may submit to the AI, what is prohibited (PHI in prompts for uses beyond clinical documentation, sharing responses externally, using AI output without clinical review), and consequences for violation.

Then define: who owns the AI system from a governance perspective (IT? Clinical informatics? CISO?), how the model is updated (who approves a new model version and what security review is required?), and how the system is decommissioned when no longer needed.

### Part 6 - Cost Summary (10 pts)

Produce a 3-year total cost of ownership:

- Year 0: hardware acquisition, setup labor (estimate hours × your loaded hourly rate)
- Years 1-3: power, maintenance contract or self-maintained labor, storage growth, model updates
- Compare to 3-year cost of a HIPAA-compliant cloud AI API (Azure OpenAI with BAA, or AWS Bedrock) at estimated query volume
- State the break-even point and your recommendation

---

## Deliverable(s)

Write your full proposal in `homework/it-hw-12.md`.

Open a PR titled `IT HW 12 - AI Inference Server Proposal` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Use case definition + data flow - PHI risks identified | 15 |
| Model evaluation - 3 models compared, selection justified | 20 |
| Hardware spec - derived from model requirements, costs shown | 20 |
| Security architecture - network isolation, auth, audit log schema, IR plan | 25 |
| AUP + governance | 10 |
| 3-year TCO + cloud comparison | 10 |

---

## Tip

{: .tip }
Ollama's model page shows VRAM requirements by quantization level. For CPU inference, llama.cpp benchmarks on your target CPU class are searchable on GitHub - use these to estimate tokens/sec and therefore response latency for your use cases.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 7 - NIST AI RMF Assessment & AI System Card (30 pts)

**NIST AI Risk Management Framework Assessment (15 pts)**

Assess your proposed AI inference deployment against the **NIST AI RMF 1.0** four core functions. For each function, identify at least 3 specific actions your deployment plan does or should take:

| Function | Action | Current State | Gap |
|---|---|---|---|
| **GOVERN** | Establish AI risk management policies | Draft policy in Part 3 | No approval process defined |
| **MAP** | Identify AI risks and impacts | ... | ... |
| **MEASURE** | Analyze and assess AI risks | ... | ... |
| **MANAGE** | Prioritize and address AI risks | ... | ... |

For each gap identified, propose a specific remediation with an estimated implementation effort (days/weeks of work). Prioritize your top 3 gaps by risk and justify why they are highest priority.

**AI System Card (15 pts)**

Produce a formal **AI System Card** (`it-hw-12-system-card.md`) for your proposed model following the Hugging Face Model Card / Mitchell et al. (2019) format, extended for organizational deployment:

1. **Model Details** - architecture, version, training data provenance (what was it trained on, by whom, under what license), intended use cases, and out-of-scope uses
2. **Intended Users** - who will use this system, what their technical sophistication is, and what guardrails exist to prevent misuse
3. **Data Provenance** - for your use case's inference inputs, where does the data come from, who owns it, and what data classification does it carry?
4. **Performance Metrics** - what metrics will you use to evaluate model performance in production (accuracy, latency, drift), at what thresholds will you trigger a model update or rollback?
5. **Bias & Fairness** - what populations or edge cases might your model underperform on, and what testing will you do before deployment?
6. **Incident Reporting** - how would a user report a model error or harmful output, who triages it, and what is the escalation path if the error is systematic?
7. **Limitations** - what can this model definitively NOT do, and how will you prevent users from relying on it for those tasks?


[← Back to Homework]({{ site.baseurl }}/homework/)
