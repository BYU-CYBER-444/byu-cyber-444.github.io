---
title: "LAB 9 — Ansible Hardening Playbook"
parent: Labs
nav_order: 9
---

# LAB 9 — Ansible Hardening Playbook
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 9
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Install Ansible and configure an inventory for lab VMs
- Write a playbook automating 10 CIS Level 1 hardening tasks
- Verify idempotency (0 changes on second run)
- Map each playbook task to a CIS control ID

---

## Tools Required

- Ubuntu 22.04 controller VM
- Ansible 2.14+
- Target Ubuntu VM from your lab environment

---

## Procedure


1. Install Ansible on your controller VM:
   ```bash
   sudo apt install ansible
   ```
2. Create an inventory file (`inventory.ini`) with your Ubuntu and Windows target VMs
3. Test connectivity: `ansible all -m ping`
4. Create playbook `cis_harden.yml` with tasks for these 10 CIS Level 1 controls:
   - Disable USB storage (`modprobe blacklist`)
   - Set password aging (`chage` defaults)
   - Configure `auditd` rules (copy template)
   - Disable Ctrl+Alt+Del
   - Remove unneeded packages
   - Configure `sysctl` (`ip_forward`, `rp_filter`)
   - Set permissions on `/etc/cron.d`
   - Configure SSH hardening (Protocol 2, `PermitRootLogin no`, `MaxAuthTries 4`)
   - Set `umask 027`
   - Disable core dumps
5. Run the playbook: `ansible-playbook cis_harden.yml -v`
6. Run again to verify idempotency — confirm `changed=0`


---

## Submission Requirements

Lab Report: Ansible inventory file, `cis_harden.yml` playbook, first run output (screenshot — showing changed tasks), second run output (screenshot — 0 changed), CIS control mapping table.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
