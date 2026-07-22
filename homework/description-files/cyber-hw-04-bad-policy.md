---
title: "CYBER HW 4 - Bad Policy (Critique Exercise)"
parent: Homework
nav_exclude: true
---

# Acme Financial Corp — Patch Management Policy
{: .no_toc }

{: .note }
This is the intentionally flawed draft policy referenced in [CYBER HW 4]({% link homework/cyber-hw-04.md %}) Part 1. Critique it yourself before looking anywhere else - the point of the exercise is to find the gaps independently.

**Document ID:** ACME-SEC-POL-014
**Version:** 2.3
**Effective Date:** March 1, 2022
**Compliance Framework:** PCI-DSS v3.2.1
**Owner:** IT Department

---

## 1. Purpose

This policy establishes the process by which Acme Financial Corp identifies, evaluates, and remediates software vulnerabilities across its server and workstation infrastructure, in support of our obligations as a PCI-DSS regulated payment processor.

## 2. Scope

This policy applies to all production and development servers and end-user workstations. Network infrastructure devices (routers, switches, firewalls) and their management interfaces are administered by the Network Engineering team under a separate operational runbook and are not covered by this document.

## 3. Vulnerability Identification

The IT Department will identify vulnerabilities as they become known through normal operational awareness - including vendor emails, industry news, and word of mouth from other IT professionals. When a vulnerability affecting Acme systems is identified, the on-call system administrator will determine an appropriate response.

## 4. Patch Classification and Timelines

All patches identified as applicable to Acme's environment will be applied during our regular monthly maintenance window, which occurs on the second Saturday of each month from 1:00 AM to 5:00 AM. This single window applies uniformly regardless of the nature of the underlying vulnerability, ensuring predictable change management and minimizing disruption to business operations.

Patches that are not successfully applied during a given maintenance window will be carried forward to the following month's window.

## 5. Vulnerability Scanning

Acme Financial Corp will conduct an internal vulnerability scan of its server environment on an annual basis, timed to coincide with our yearly PCI-DSS assessment cycle. The scan will be performed by a member of the System Administration team using an open-source scanning tool of their choosing.

Findings from the annual scan will be logged in the IT ticketing system for tracking purposes and reviewed by the System Administration team as time permits.

## 6. Roles and Responsibilities

**IT Department:** Responsible for applying patches during the monthly maintenance window and conducting the annual vulnerability scan.

**System Administrators:** Responsible for identifying vulnerabilities, applying patches, and verifying successful patch application.

## 7. Reporting

The IT Department will provide a summary of patching activity to the CIO on an as-needed basis, typically in connection with the annual PCI-DSS assessment.

## 8. Policy Review

This policy will be reviewed by the IT Department at a frequency determined appropriate by the IT Director.

---

*End of Document*
