---
title: "CYBER LAB 10 - Ansible Galaxy Hardening Role"
parent: Labs
nav_order: 10
---

# CYBER LAB 10 - Ansible Galaxy Hardening Role
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 10 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Pin and install a production Galaxy hardening role with a locked version
- Audit the role's default variables and document your override rationale
- Run a CIS-CAT baseline scan, apply the role, and measure the score delta by section
- Verify that key variable overrides actually took effect on the target system
- Test the role for idempotency and document any non-idempotent behaviors

---

## Tools Required

- Ubuntu 22.04 controller and target VMs from Lab 9
- Ansible 2.14+
- dev-sec.io os-hardening Galaxy role (pinned version)
- CIS-CAT Pro

---

## Procedure

### Part 1 - Role Installation with Version Pinning

Never install Galaxy roles without pinning a version - unpinned roles can break when the upstream author pushes changes.

Create `requirements.yml`:
```yaml
---
roles:
  - name: dev-sec.os-hardening
    version: 9.3.0    # Pin to a specific release - check galaxy.ansible.com for latest stable

collections:
  - name: community.general
    version: ">=8.0.0"
```

Install:
```bash
ansible-galaxy install -r requirements.yml --force
ansible-galaxy role list   # verify version installed
```

### Part 2 - Role Defaults Audit

Before applying the role, audit its default variables to understand what it will do:

```bash
cat ~/.ansible/roles/dev-sec.os-hardening/defaults/main.yml | head -80
```

Build an audit table of the most security-relevant defaults:

| Variable | Default Value | Your Override | Reason |
|---|---|---|---|
| `os_auditd_enabled` | false | true | Lab requires auditd active |
| `os_security_ssh_permitrootlogin` | 'no' | 'no' | Keep - correct default |
| `os_password_max_age` | 60 | 365 | 60 days too aggressive for lab |
| `os_auth_pam_passwdqc_enable` | true | false | Conflicts with pam_pwquality from Lab 2 |

Document at least 8 variable decisions (keep or override) with justification.

### Part 3 - CIS-CAT Baseline (Pre-Role)

Run CIS-CAT against the target VM in its current state (post-Lab 9 hardening):

```bash
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/ -rp lab10-pre-role --html --json
```

Record per-section scores to enable a detailed delta analysis after the role runs.

### Part 4 - Apply the Role

`site.yml`:
```yaml
---
- name: Apply dev-sec hardening role
  hosts: lab_targets
  vars_files:
    - site_vars.yml
  roles:
    - dev-sec.os-hardening
```

`site_vars.yml`:
```yaml
# Pin version check - fail if wrong role version
os_auditd_enabled: true
os_password_max_age: 365
os_password_min_days: 7
os_password_warn_age: 14
os_security_ssh_permitrootlogin: 'no'
os_security_ssh_maxauthtries: 4
os_security_ssh_client_alive_interval: 300
os_security_ssh_client_alive_count: 3
os_security_ssh_password_authentication: "no"
os_auth_pam_passwdqc_enable: false   # we use pam_pwquality instead
os_security_kernel_enable_core_dump: false
os_env_umask: "027"
```

Run the role:
```bash
ansible-playbook site.yml -v 2>&1 | tee /tmp/role-run1.txt
```

### Part 5 - Idempotency Test

```bash
# Second run - must show changed=0 for all tasks
ansible-playbook site.yml 2>&1 | tee /tmp/role-run2.txt
grep "changed=" /tmp/role-run2.txt
```

If any tasks are NOT idempotent (show changed on second run), investigate and document:
- Which task is the issue?
- Why is it not idempotent? (e.g., uses `command` module without `creates` guard)
- What is the impact of running it multiple times?

### Part 6 - Verify Variables Actually Took Effect

Don't trust that the role applied your overrides - verify on the target system:

```bash
# Verify SSH settings
ansible lab_targets -m shell -a "grep -E 'MaxAuthTries|PermitRootLogin|PasswordAuthentication|ClientAliveInterval' /etc/ssh/sshd_config"

# Verify sysctl settings
ansible lab_targets -m shell -a "sysctl net.ipv4.ip_forward net.ipv4.conf.all.accept_redirects"

# Verify auditd is running
ansible lab_targets -m service_facts
ansible lab_targets -m debug -a "var=ansible_facts.services['auditd.service'].state"

# Verify password aging in login.defs
ansible lab_targets -m shell -a "grep PASS_MAX_DAYS /etc/login.defs"
```

For each variable override you made in Part 2, show verification output confirming the value is in place.

### Part 7 - Post-Role CIS-CAT Assessment

```bash
./Assessor-CLI.sh   -b benchmarks/CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.0.0-xccdf.xml   -rd reports/ -rp lab10-post-role --html --json
```

Produce a structured delta report by section:

| CIS Section | Pre-Role Score | Post-Role Score | Delta | Notable Changes |
|---|---|---|---|---|
| 1 - Initial Setup | 45% | 78% | +33% | Filesystem configs applied |
| 3 - Network Config | 60% | 91% | +31% | Sysctl hardening |
| 5 - Access Control | 55% | 72% | +17% | SSH, PAM hardening |

Overall score delta and explanation of the largest improvements.

---

## Submission Requirements

- `requirements.yml` with pinned role version
- Role defaults audit table (8+ variable decisions with justification)
- `site_vars.yml` (annotated)
- Pre-role CIS-CAT HTML report
- First role run output (showing what changed)
- Second role run output proving `changed=0` (or documented exceptions)
- Variable verification output for all 8+ overrides
- Post-role CIS-CAT HTML report
- Per-section score delta table with analysis
- Written reflection: What is the operational risk of NOT pinning Galaxy role versions? Describe a realistic scenario where an unpinned role causes a production outage.

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Molecule Testing for the Role

Set up Molecule to test the dev-sec role in an isolated Docker container, so you can verify behavior without touching your lab VM:

```bash
pip3 install molecule molecule-docker docker --break-system-packages
mkdir -p ~/lab10-molecule && cd ~/lab10-molecule
molecule init scenario --driver-name docker
```

Edit `molecule/default/molecule.yml` to use Ubuntu 22.04:
```yaml
platforms:
  - name: ubuntu-2204
    image: "geerlingguy/docker-ubuntu2204-ansible"
    command: /lib/systemd/systemd
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns_mode: host
    pre_build_image: true
```

Edit `molecule/default/converge.yml` to apply the role with your `site_vars.yml`.

Edit `molecule/default/verify.yml` to add at least 5 assertions:
```yaml
- name: Verify sshd PermitRootLogin
  ansible.builtin.assert:
    that: "'PermitRootLogin no' in lookup('file', '/etc/ssh/sshd_config')"
# Add 4 more assertions...
```

Run Molecule:
```bash
molecule test   # full cycle: create → converge → verify → destroy
```

Submit the Molecule config files and a screenshot of the full `molecule test` run passing all verifications.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
