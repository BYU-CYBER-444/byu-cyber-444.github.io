---
title: "Week 7"
parent: Schedule
nav_order: 7
---

# Week 7 - Windows Hardening & DNS/Email Security
{: .no_toc }

---

## Topics

- Windows Security Baseline (Microsoft SCT): AppLocker, WDAC, Credential Guard, BitLocker
- Windows Firewall with Advanced Security; disabling legacy protocols (SMBv1, NTLMv1)
- Attack surface reduction rules
- DNS security: DNSSEC zone signing, trust anchors, validation chain
- DNS attack types (cache poisoning, amplification, hijacking) and mitigations (RPZ, rate limiting)
- Email authentication: SPF record structure, DKIM key generation and DNS publishing, DMARC policy modes and reporting
- Mail server hardening: relay restrictions, TLS enforcement, anti-spam
- PKI fundamentals: X.509 certificate structure, Root CA → Intermediate CA → end-entity hierarchy
- Certificate lifecycle: issuance, renewal, revocation (CRL vs. OCSP); TLS handshake overview
- OpenSSL essentials (`genrsa`, `req`, `x509`, `ca`, `verify`, `s_client`); internal CA vs. Let's Encrypt trade-offs

---

## Slides

[Week07_Windows_Hardening_and_DNS_Email_Security.pptx]({{ site.baseurl }}/lectures/Week07_Windows_Hardening_and_DNS_Email_Security.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **IT Track** | [IT LAB 7 - DNSSEC & Email Security Configuration]({% link labs/it-lab-07.md %}) |
| **Cyber Track** | [CYBER LAB 7 - Windows Server 2022 Hardening]({% link labs/cyber-lab-07.md %}) |

---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 7 - Midterm Practice Exam]({% link homework/cyber-hw-07.md %}) (Ungraded) |
| **IT Track** | [IT HW 7 - IT Track Midterm Practice Exam]({% link homework/it-hw-07.md %}) (Ungraded) |

---

## Assessments

None this week.

---

[← Previous Week]({{ site.baseurl }}/schedule/week-06/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-08/)
{: .text-right }
