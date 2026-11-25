---
title: "Part 5 - AI Infrastructure Governance Policy"
parent: "IT LAB 14 - AI Inference Server Setup and Governance"
grand_parent: Labs
nav_order: 5
---

# Part 5 - AI Infrastructure Governance Policy
{: .no_toc }

---

Write your governance policy in `~/lab14-submission/policy.md`. The file must
satisfy the structural requirements listed at the end of this section — these
are checked automatically.

```
AI INFERENCE INFRASTRUCTURE GOVERNANCE POLICY
Policy ID: IT-AI-001
Version: 1.0
Owner: IT Operations
Effective Date: [Date]

1. PURPOSE
   This policy governs the deployment, operation, and use of self-hosted
   AI inference infrastructure within the organization.

2. SCOPE
   Applies to all self-hosted language model inference servers, including
   but not limited to Ollama, vLLM, llama.cpp, and similar platforms.

3. DATA CLASSIFICATION AND HANDLING
   3.1 PROHIBITED DATA: The following data types MUST NOT be submitted
       to AI inference endpoints:
         - PII (names, SSNs, addresses, dates of birth) — Rationale: [risk]
         - PHI (medical records, diagnoses, treatment information) — Rationale: [risk]
         - Authentication credentials (passwords, API keys, certificates) — Rationale: [risk]
         - Financial records (account numbers, payment card data) — Rationale: [risk]
         - Proprietary source code marked CONFIDENTIAL — Rationale: [risk]
         - [Add at least one more prohibited type] — Rationale: [risk]
   3.2 PERMITTED DATA: Anonymized operational data, publicly available
       information, and non-sensitive technical queries.

4. ACCESS CONTROLS
   4.1 All inference API access requires a valid API key issued by IT Operations.
       — Rationale: [risk]
   4.2 API keys are personal, non-shareable, and expire after 90 days.
       — Rationale: [risk]
   4.3 Rate limits: 100 requests/hour per key for standard users;
       500 requests/hour for approved automation workflows. — Rationale: [risk]

5. MODEL GOVERNANCE
   5.1 Only IT Operations-approved models may be deployed.
   5.2 Model pull requests require change management approval (Standard Change).
       Rationale: unlike a software package update, a new model version changes
       the system's behavior and output distribution in ways that cannot be
       verified by a checksum alone — [complete this rationale].
   5.3 Models must be reviewed for known biases and misuse potential.

6. MONITORING AND AUDIT
   6.1 All inference requests are logged (prompt hash, model, user, timestamp).
   6.2 Logs retained for 90 days.
   6.3 Anomalous usage patterns trigger security review.

7. INCIDENT RESPONSE
   7.1 Suspected prompt injection or misuse: report to security@[org] within 1 hour.
       — Rationale: [risk]
   7.2 Data exfiltration via AI endpoint: treat as P1 security incident.
       — Rationale: [risk]

8. REVIEW CYCLE
   This policy is reviewed annually and updated as AI infrastructure evolves.
```

## Structural Requirements

These are checked automatically:

| Requirement | Check |
|---|---|
| All 8 numbered sections present | Sections 1–8 each appear as a heading or numbered line |
| At least 6 prohibited data types | ≥ 6 lines matching `- ... — Rationale:` in section 3.1 |
| Rationale notes in sections 4 and 7 | ≥ 2 lines matching `— Rationale:` in each section |
| "prompt injection" appears in section 7 | Literal string present (case-insensitive) |
| Minimum length | `wc -w policy.md` ≥ 600 |

Replace every `[risk]` and `[complete this rationale]` placeholder with a specific, one-sentence explanation of the risk the control addresses.

---

{: .highlight }
> **Before moving on — Part 5 complete when:**
> - `policy.md` contains all 8 numbered section headings
> - All `[risk]` and `[complete this rationale]` placeholders have been replaced with real rationale text
> - Section 3.1 has at least 6 prohibited data types each with a `— Rationale:` note
> - The policy is at least 600 words long (use `wc -w ~/lab14-submission/policy.md` to check)

---

[← Prev: Part 4](part4) · [Next: Self-Check & Grading →](grading)

[← Back to Labs]({{ site.baseurl }}/labs/)
