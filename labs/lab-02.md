---
title: "LAB 2 — Linux User Management & auditd"
parent: Labs
nav_order: 2
---

# LAB 2 — Linux User Management & auditd
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 2
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Implement a tiered sudo policy with least-privilege restrictions
- Configure file ACLs on a web application directory
- Enable and verify auditd with file-watch rules
- Document privilege management configuration as evidence

---

## Tools Required

- Ubuntu 22.04 LTS VM from Lab 1
- ``auditd``
- ``sudo``
- ``acl` package (`getfacl`/`setfacl`)`

---

## Procedure


1. Create three user accounts: `alice` (sysadmin), `bob` (developer), `carol` (readonly)
2. Configure `/etc/sudoers.d/sysadmins`:
   - `alice` — passwordless full sudo
   - `bob` — restricted to `sudo systemctl restart apache2` only
3. Set ACLs on `/srv/webapp`:
   ```bash
   setfacl -m u:alice:rwx /srv/webapp
   setfacl -m u:bob:r-x  /srv/webapp
   setfacl -m u:carol:r-- /srv/webapp
   getfacl /srv/webapp   # verify
   ```
4. Enable auditd: `sudo systemctl enable --now auditd`
5. Add a file-watch rule:
   ```bash
   sudo auditctl -w /etc/passwd -p wa -k passwd_changes
   ```
6. Trigger the rule: `sudo useradd testuser`
7. Verify the log entry: `sudo ausearch -k passwd_changes`
8. Screenshot the ACL output and audit log


---

## Submission Requirements

Lab Report: sudo configuration screenshot, `getfacl` ACL output, auditd rule file contents, `ausearch` output showing the triggered event, brief explanation of each user's access level.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
