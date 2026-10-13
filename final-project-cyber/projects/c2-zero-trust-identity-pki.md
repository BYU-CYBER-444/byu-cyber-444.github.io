---
title: "C2 - Zero-Trust Identity and PKI Platform"
parent: Cyber Project Options
grand_parent: Final Project (Cyber Track)
nav_order: 2
---

# C2 - Zero-Trust Identity and PKI Platform
{: .no_toc }

Nothing is trusted by default: every user, host, and service proves who it is with a certificate that can be rotated and revoked.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Pitch

Passwords and long-lived keys are how most breaches spread. You build an identity platform where access is granted by short-lived certificates: a private certificate authority hierarchy, an SSH CA for users and hosts, multi-factor authentication for privileged access, and mutual TLS (mTLS) so two services only talk to each other when both present valid certificates. You automate issuance, renewal, and revocation, and you prove that revoked or expired identities are actually refused.

## What You Build

| Component | Description |
|---|---|
| CA hierarchy | Offline root CA and an online intermediate CA (building on Lab 5), with documented key-handling steps for the root |
| SSH CA | User and host certificates with principals and short validity; servers trust the CA instead of individual keys (building on Lab 6) |
| MFA | TOTP (or similar) second factor required for privileged access (sudo or admin login) |
| mTLS service pair | Two services (for example a reverse proxy and a backend API) that accept connections only from clients with a valid certificate |
| Lifecycle automation | Scripted or ACME-based issuance and renewal, plus a revocation path (CRL or OCSP for X.509; short validity and revocation list for SSH) |
| Issuance audit trail | A log of what was issued, to whom, and when |

Plan for three to four small VMs or LXCs: a CA host, a server, a backend service, and a client.

## Proposal Checklist

Your proposal must include:

- Your CA hierarchy (names, key algorithms, validity periods) and how the root key is protected
- The two services that will use mTLS and who the clients are
- Your SSH CA design: principals, certificate lifetimes, and how hosts and users are enrolled
- How renewal and revocation will work for each certificate type

## Pair Extension (pairs only: complete one)

- Add 802.1X or RADIUS-based network authentication that uses your CA's certificates
- Add a second intermediate CA (for example separate user and server issuance) with name constraints and a documented rationale

## Suggested Timeline

There are no graded checkpoints before the final package, so these weeks are pacing targets.

| Week | Focus |
|---|---|
| 9 | Proposal; CA hierarchy design |
| 10 | Root and intermediate CA, SSH CA working |
| 11 | mTLS service pair; MFA |
| 12 | Automated renewal and revocation |
| 14 | Negative testing, documentation, rehearsal |
| 15 | Final package and recorded presentation |

---

## Final Documentation Package {#documentation}

**Due:** Last class day. Open a PR titled `Final Project - C2 Zero-Trust Identity and PKI Platform`. Everything lives in `final-project-cyber/` in your portfolio repo.

1. **Certificate policy (CP/CPS-lite).** What each CA issues, to whom, validity periods, key protection, revocation process, and who approves issuance.
2. **Architecture diagram.** Every host and service, each trust relationship (which CA signs what), and the direction of each mTLS and SSH connection.
3. **Verification report.** A table of tests (positive and negative) with commands, expected result, and actual output.
4. **Automation package.** Repo that rebuilds the platform from scratch using only the README.
5. **Lessons learned.** Same four prompts as every option.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Certificate policy | 25 | Complete, specific, and consistent with what you built | Present but generic or inconsistent |
| Architecture diagram | 15 | Trust relationships and connection directions clearly labeled | Present but missing trust paths |
| Verification report | 20 | Positive and negative tests with real output | Positive tests only |
| Automation package | 25 | Rebuilds cleanly from checkout; README accurate | Runs with manual fixes |
| Lessons learned | 15 | Specific and reflective; all four prompts | Present but generic |

---

## Recorded Presentation and Demo {#presentation}

Submit a recording of **10 minutes or less** as a link in Learning Suite by 11:59 PM on December 10 (see [Final Deliverables]({% link final-project-cyber/final-deliverables.md %}#presentation) for the recording rules). It must include an architecture overview, the three demos below, and a short discussion of your design decisions and trade-offs.

The three required demos:

1. **SSH certificate access.** Log in with a short-lived SSH certificate, show its principals, then show a login refused for an expired certificate or a wrong principal.
2. **mTLS.** Show a successful mTLS request, then a refused request from a client with no certificate or a revoked certificate.
3. **Lifecycle.** Show a certificate being renewed or rotated automatically and the services continuing without interruption.

| Criterion | Points | Full credit | Partial credit |
|---|---|---|---|
| Architecture overview | 15 | Trust model and design decisions explained clearly without reading a script | Basics covered; some elements unclear |
| SSH certificate demo | 25 | Success and refusal shown on screen | Success only |
| mTLS demo | 25 | Success and refusal shown on screen | Success only |
| Lifecycle demo | 20 | Renewal or rotation shown with no outage | Described but not shown |
| Decisions and trade-offs | 15 | Specific and accurate: what you chose and rejected, how it can fail, and what you would change | Mostly adequate; generic or missing a prompt |

[Back to Cyber Project Options]({% link final-project-cyber/projects/index.md %})
