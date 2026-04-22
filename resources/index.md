---
title: Resources
nav_order: 7
permalink: /resources/
---

# Course Resources
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Official Standards & Frameworks

| Resource | URL |
|---|---|
| CIS Benchmarks (Ubuntu, Windows, Docker) | [cisecurity.org/cis-benchmarks](https://cisecurity.org/cis-benchmarks) |
| DISA STIG Library | [public.cyber.mil/stigs](https://public.cyber.mil/stigs) |
| MITRE ATT&CK Matrix | [attack.mitre.org](https://attack.mitre.org) |
| NIST SP 800-61 Rev. 2 (Incident Handling) | [csrc.nist.gov](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final) |
| NIST SP 800-92 (Log Management) | [csrc.nist.gov](https://csrc.nist.gov/publications/detail/sp/800-92/final) |
| NIST SP 800-40 Rev. 4 (Patch Management) | [csrc.nist.gov](https://csrc.nist.gov/publications/detail/sp/800-40/rev-4/final) |
| NICE Framework v2.1.0 | [niccs.cisa.gov](https://niccs.cisa.gov/workforce-development/nice-framework) |

---

## Tools

| Tool | Purpose | Download |
|---|---|---|
| CIS-CAT Pro | CIS Benchmark assessment | Department license (LMS) |
| STIG Viewer 2.x | View and manage STIG checklists | [public.cyber.mil](https://public.cyber.mil/stigs/srg-stig-tools/) |
| OpenSCAP | SCAP-based compliance scanning | `sudo apt install openscap-scanner ssg-debderived` |
| Nessus Essentials | Vulnerability scanning | [tenable.com/nessus-essentials](https://www.tenable.com/products/nessus/nessus-essentials) |
| Ansible | Configuration management | [docs.ansible.com](https://docs.ansible.com) |
| Terraform | Infrastructure as code | [developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform) |
| Trivy | Container image scanning | [aquasecurity.github.io/trivy](https://aquasecurity.github.io/trivy) |
| docker-bench-security | CIS Docker Benchmark tool | [github.com/docker/docker-bench-security](https://github.com/docker/docker-bench-security) |
| dev-sec.io os-hardening | Ansible Galaxy hardening role | `ansible-galaxy role install dev-sec.os-hardening` |

---

## Lab ISOs & Files

All lab ISOs and provided files are available on the course LMS:

- Ubuntu 22.04 LTS Server ISO
- Windows Server 2022 Evaluation ISO
- Compromised VM `.ova` (Lab 14)
- Graylog Docker Compose file
- Lab report templates (`.docx`)
- STIG Checklist template (HW 6)
- Gap Analysis template (HW 5)
- final-project SSP template
- final-project Proposal template

---

## Certification Pathways

This course directly prepares you for the following certifications:

| Certification | Vendor | Related Topics |
|---|---|---|
| CompTIA Linux+ | CompTIA | Linux administration, scripting, hardening |
| Red Hat RHCSA | Red Hat | Linux system administration, RHEL |
| Microsoft AZ-104 | Microsoft | Azure + Windows Server administration |
| GIAC GCWN (Windows) | GIAC | Windows security configuration |
| CIS Hardened Image Compliance | CIS | CIS Benchmark implementation |

---

## Helpful Cheat Sheets

- [Linux auditd Rule Syntax Reference](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/auditing-the-system_security-hardening)
- [Ansible Playbook YAML Reference](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
- [CVSS v3.1 Score Calculator](https://www.first.org/cvss/calculator/3.1)
- [MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/)
