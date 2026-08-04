---
title: "Week 5"
parent: Schedule
nav_order: 5
---

# Week 5 - PKI & Certificate Management

{: .no_toc }

---

## Topics

- PKI fundamentals: asymmetric cryptography recap, public/private key pairs, and how digital signatures establish trust without a shared secret
- X.509 certificate structure and critical extensions: `basicConstraints`, `keyUsage`, `extendedKeyUsage`, and Subject Alternative Names (SANs) - why modern browsers reject certificates without them
- CA hierarchy design: two-tier (offline Root CA → online Intermediate CA) vs. a single-tier CA, and why keeping the Root CA offline limits the blast radius if the Intermediate is ever compromised
- Certificate lifecycle: CSR generation, issuance, expiration/renewal windows, and why shorter validity periods reduce the exposure window from an undetected key compromise
- Certificate revocation: CRL vs. OCSP mechanics, and the staleness/privacy/availability trade-offs between them; OCSP stapling as the practical middle ground
- TLS handshake mechanics and protocol hardening: TLS 1.2/1.3 only, forward-secrecy cipher suites, and HSTS enforcement
- Certificate Transparency (CT) logs and real-world CA misissuance incidents (DigiNotar, mis-issued Symantec certs) - why browsers now require CT for publicly-trusted certificates
- Public CA (Let's Encrypt, DigiCert) vs. private/internal CA: when each is appropriate, and why an internal CA is the right call for internal service-to-service TLS
- Key management practicalities: private key storage/permissions, passphrase-protected CA keys, and the operational role of Hardware Security Modules (HSMs) in production PKI
- PKI lab: building a two-tier internal CA, issuing server certificates, configuring CRL/OCSP, validating with `testssl.sh`

---

## Slides

[PKI & Certificate Management]({{ site.baseurl }}/lectures/CYBER444_Week05_PKI_and_Certificate_Management.pptx) 

---

## Labs

| Track | Lab |
|---|---|
| **Both Tracks** | [LAB 5 - PKI & Certificate Management]({% link labs/lab-05.md %}) |

---

## Homework

None this week.

---


[← Previous Week]({{ site.baseurl }}/schedule/week-04/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-06/)
{: .text-right }
