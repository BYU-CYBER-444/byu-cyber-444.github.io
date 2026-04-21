---
title: "LAB 10 — Ansible Galaxy Hardening Role"
parent: Labs
nav_order: 10
---

# LAB 10 — Ansible Galaxy Hardening Role
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 10
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Import and configure the dev-sec.io os-hardening Ansible Galaxy role
- Customize variables to achieve CIS Level 2 compliance
- Measure and document before/after CIS-CAT score delta
- Document all role customizations with justification

---

## Tools Required

- Ubuntu 22.04 controller VM
- Ansible 2.14+
- Ansible Galaxy
- dev-sec.io os-hardening role
- CIS-CAT Pro

---

## Procedure


1. Install the dev-sec.io hardening role:
   ```bash
   ansible-galaxy role install dev-sec.os-hardening
   ```
2. Review role defaults: `~/.ansible/roles/dev-sec.os-hardening/defaults/main.yml`
3. Create a `site_vars.yml` file overriding these variables:
   ```yaml
   os_auditd_enabled: true
   os_password_max_age: 90
   os_password_min_age: 7
   os_auth_pam_passwdqc_enable: true
   os_security_ssh_permitrootlogin: 'no'
   ```
4. Run CIS-CAT Pro on the target VM — **record the pre-role score**
5. Apply the role with your custom vars:
   ```bash
   ansible-playbook --extra-vars @site_vars.yml dev-sec-role.yml
   ```
6. Run CIS-CAT Pro again — **record the post-role score**
7. Document the delta and any additional customizations required


---

## Submission Requirements

Lab Report: customized vars file, playbook execution output, pre-role CIS-CAT score, post-role CIS-CAT score, delta comparison table, list of 3+ customizations with justification.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
