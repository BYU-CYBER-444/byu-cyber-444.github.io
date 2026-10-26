---
title: "Week 6"
parent: Schedule
nav_order: 6
---

# Week 6 - SSH CA, PAM MFA & Enterprise Policy
{: .no_toc }

---

## Topics

- Zero Trust Architecture (ZTA): "never trust, always verify" - identity, device, network, application, and data as the five pillars this week's mechanics (PAM, MFA, certs) actually implement
- Privileged Access Management (PAM): sudo hardening, command whitelisting, session recording
- SSH certificate authorities; LDAP/AD integration for Linux (sssd)
- MFA for admin access (Google Authenticator PAM, YubiKey); bastion host architecture
- Enterprise policy framework: Acceptable Use Policy (AUP), information security policy structure
- Data classification schemes (Public / Internal / Confidential / Restricted)
- BYOD policy design: device enrollment, MDM, remote wipe requirements
- Regulatory compliance: HIPAA technical safeguards, PCI-DSS network segmentation, GDPR data residency and right to erasure
- Vendor and third-party risk management: SLA/OLA structure, BAAs, and Data Processing Agreements (DPA)

## Supplemental Readings & Videos

### Readings

- [NIST SP 800-207: Zero Trust Architecture](https://csrc.nist.gov/pubs/sp/800/207/final) — Defines the architecture and deployment models underlying the identity- and resource-focused controls in this week.
- [CISA Zero Trust Maturity Model](https://www.cisa.gov/resources-tools/resources/zero-trust-maturity-model) — Provides a practical framework for evaluating identity, devices, networks, applications, and data protections.

### Videos

- [Zero Trust](https://www.cisa.gov/resources-tools/resources/zero-trust) — CISA's recorded discussion introduces the federal Zero Trust initiative and its implementation context.

---
## Slides

[SSH CA, PAM MFA & Enterprise Policy]({{ site.baseurl }}/lectures/CYBER444_Week06_SSH_CA_PAM_MFA_and_Enterprise_Policy.pptx)

---

## Labs

| Track | Lab |
|---|---|
| **Both Tracks** | [LAB 6 - Acceptable Use & Data Classification Enforcement]({% link labs/lab-06.md %}) |

---

## Homework

| Track | Assignment |
|---|---|
| **Cyber Track** | [CYBER HW 6 - SSH CA & MFA Deployment Design]({% link homework/cyber-hw-06.md %}) |
| **IT Track** | [IT HW 6 - Policy Package: AUP, Data Classification & Vendor Security]({% link homework/it-hw-06.md %}) |

---

[← Previous Week]({{ site.baseurl }}/schedule/week-05/)&nbsp;&nbsp;&nbsp;[Next Week →]({{ site.baseurl }}/schedule/week-07/)
{: .text-right }
