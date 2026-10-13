---
title: "I3 - On-Prem AI Inference Service"
parent: IT Project Options
grand_parent: Final Project (IT Track)
nav_order: 3
---

# I3 - On-Prem AI Inference Service
{: .no_toc }

Run an AI model inside the organization's walls, and make it safe, measurable, and worth its cost.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Valley Medical Group's clinicians want an AI assistant, but patient data cannot go to a public AI service. You deploy a real local inference service for the organization and treat it like any production system: authentication, TLS, rate limiting, network isolation, observability, benchmarks, and a data-handling policy that satisfies HIPAA safeguards. You finish with a cost comparison against a hosted API so leadership can decide.

## What You Build

| Component | Description |
|---|---|
| Inference service | Ollama or vLLM (or similar) serving an open-weight model on a VM. Use a model sized for your hardware; **check with the instructor whether a GPU is available**, otherwise use a small quantized model on CPU. |
| Secure front door | Reverse proxy with TLS, per-user API keys or SSO, and rate limiting |
| Isolation | The inference host has no internet egress after the model is downloaded, proven by a test |
| Observability | Prometheus metrics (requests, latency, tokens per second, CPU/RAM) and a Grafana dashboard |
| Benchmarks | A repeatable load test reporting latency and throughput at 1, 5, and 10 concurrent users |
| Provenance | Model files verified against published checksums, with version pinned |
| Logging | Request logging that records metadata for audit without storing patient content, with the decision documented |
| Policy | AUP addendum for AI use, data-handling policy, and a HIPAA safeguards mapping |

## Proposal Checklist

Your proposal must include:

- Three clinical or operational use cases and the data each would touch
- Your model candidate, its size, context window, and RAM/VRAM need, and your CPU-only versus GPU decision
- How users authenticate and how access is revoked
- What the service will and will not log, and why
- At least two HIPAA technical safeguards your design must satisfy

---

## Final Documentation Package {#documentation}

**Due:** December 10, 11:59 PM. Submit everything in Learning Suite, as uploaded files or a link to them (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#submission)).

1. **Design and sizing document.** Use cases, hardware specification with justification, model selection (size, context window, RAM/VRAM), software stack, access control, and security controls.
2. **Policy set.** AI acceptable-use addendum (consistent with the course AUP), data-handling policy (what may be submitted, what is logged, retention, who audits), and a HIPAA technical-safeguards mapping to your controls.
3. **Benchmark and cost report.** Final benchmark results and a cost comparison: one-time hardware cost, power and maintenance, versus an estimate of hosted-API cost for the same expected usage, with a recommendation.
4. **Architecture diagram.** Network zones, proxy, inference host, monitoring, users, and the blocked egress path.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Design and sizing document | 25 | Specific, justified, and consistent with what you built | Thin justification |
| Policy set | 25 | Complete, specific, and aligned with the technical controls | Generic policies |
| Benchmark and cost report | 20 | Real data, honest assumptions, clear recommendation | Estimates only |
| Architecture diagram | 15 | Zones, flows, and blocked egress clearly labeled | Missing zones or flows |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-it/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **Access control.** Make an authenticated query that succeeds, then an unauthenticated query and an over-limit query that are each refused.
2. **Under load.** Run your load test and show the dashboard respond: latency, throughput, and resource use.
3. **Isolation and audit.** Show that the inference host cannot reach the internet, and show the audit log entry for a request you just made.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Service, controls, and decisions explained clearly without reading a script | Basics covered; some elements unclear |
| Access-control demo | 25 | Success and both refusals shown | Success and one refusal |
| Under-load demo | 25 | Load test with the dashboard and an explanation of the numbers | Dashboard shown; numbers unexplained |
| Isolation and audit demo | 20 | Egress blocked and audit entry found | One of the two |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to IT Project Options]({% link final-project-it/projects/index.md %})
