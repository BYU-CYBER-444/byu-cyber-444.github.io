---
title: "CYBER LAB 9 - Ansible Hardening Playbook"
parent: Labs
nav_order: 9
---

# CYBER LAB 9 - Ansible Hardening Playbook
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 9 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Configure Ansible with a structured inventory and SSH key authentication
- Write a modular, production-quality hardening playbook for 10 CIS Level 1 controls
- Use variables, handlers, and tags - not hardcoded values
- Verify idempotency (zero changes on the second run)
- Lint the playbook with `ansible-lint` and resolve all violations
- Write a separate verification playbook that confirms control state without making changes

---

## Tools Required

- Ubuntu 22.04 controller VM (with Ansible 2.14+)
- Ubuntu 22.04 target VM (fresh from Lab 1 baseline snapshot)
- SSH key pair for Ansible authentication

```bash
sudo apt install ansible ansible-lint python3-pip -y
pip3 install ansible-lint --break-system-packages
```

---

## Procedure

### Part 1 - Ansible Setup & SSH Key Authentication

Ansible must authenticate via SSH key (not password) in production. Set this up first:

```bash
# On controller: generate a dedicated Ansible key
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key -C "ansible@lab9" -N ""

# Copy the public key to the target VM
ssh-copy-id -i ~/.ssh/ansible_key.pub ubuntu@192.168.56.30

# Test passwordless auth
ssh -i ~/.ssh/ansible_key ubuntu@192.168.56.30 'echo "SSH key auth works"'
```

### Part 2 - Inventory and Ansible Configuration

Create a structured project directory:

```bash
mkdir -p ~/lab9/{inventory,group_vars,host_vars,roles,playbooks}
cd ~/lab9
```

`inventory/hosts.yml`:
```yaml
all:
  children:
    lab_targets:
      hosts:
        ubuntu-target:
          ansible_host: 192.168.56.30
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/ansible_key
          ansible_become: true
          ansible_become_method: sudo
```

`ansible.cfg`:
```ini
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml

[privilege_escalation]
become = True
become_method = sudo
```

Test:
```bash
ansible all -m ping
ansible all -m setup -a "filter=ansible_distribution*"
```

### Part 3 - Variables File

`group_vars/all.yml` - all hardcoded values go here, not in the playbook:

```yaml
# SSH Hardening
ssh_port: 22
ssh_max_auth_tries: 4
ssh_client_alive_interval: 300
ssh_client_alive_count_max: 3
ssh_allow_tcp_forwarding: "no"
ssh_x11_forwarding: "no"
ssh_permit_root_login: "no"
ssh_password_authentication: "no"

# Password Policy
password_max_days: 365
password_min_days: 7
password_warn_days: 14

# Sysctl
sysctl_ipv4_forwarding: 0
sysctl_rp_filter: 1
sysctl_icmp_redirects: 0
sysctl_source_route: 0

# Packages to remove
packages_remove:
  - telnet
  - rsh-client
  - nis
  - talk

# Umask
system_umask: "027"
```

### Part 4 - Hardening Playbook

`playbooks/cis_harden.yml`:

```yaml
---
- name: CIS Level 1 Ubuntu 22.04 Hardening
  hosts: lab_targets
  gather_facts: true

  handlers:
    - name: Reload sshd
      ansible.builtin.service:
        name: sshd
        state: reloaded

    - name: Reload sysctl
      ansible.builtin.command: sysctl --system

  tasks:

    # CIS 2.3.4 - Remove unnecessary packages
    - name: CIS 2.3.4 | Remove insecure legacy packages
      ansible.builtin.package:
        name: "{{ packages_remove }}"
        state: absent
      tags: [packages, cis_2_3_4]

    # CIS 1.6.1 - Disable USB storage
    - name: CIS 1.6.1 | Disable USB mass storage kernel module
      ansible.builtin.copy:
        content: "install usb-storage /bin/true\nblacklist usb-storage\n"
        dest: /etc/modprobe.d/usb-storage.conf
        owner: root
        group: root
        mode: '0644'
      tags: [kernel, cis_1_6_1]

    # CIS 5.4 - Password aging
    - name: CIS 5.4.1.1 | Set password maximum age in login.defs
      ansible.builtin.lineinfile:
        path: /etc/login.defs
        regexp: '^PASS_MAX_DAYS'
        line: "PASS_MAX_DAYS   {{ password_max_days }}"
      tags: [accounts, cis_5_4_1_1]

    - name: CIS 5.4.1.2 | Set password minimum age in login.defs
      ansible.builtin.lineinfile:
        path: /etc/login.defs
        regexp: '^PASS_MIN_DAYS'
        line: "PASS_MIN_DAYS   {{ password_min_days }}"
      tags: [accounts, cis_5_4_1_2]

    # CIS 4.1 - auditd
    - name: CIS 4.1.1 | Ensure auditd is installed
      ansible.builtin.package:
        name: auditd
        state: present
      tags: [auditing, cis_4_1_1]

    - name: CIS 4.1.1 | Ensure auditd is enabled and running
      ansible.builtin.service:
        name: auditd
        state: started
        enabled: true
      tags: [auditing, cis_4_1_1]

    # CIS 1.4.1 - Disable Ctrl+Alt+Del
    - name: CIS 1.4.1 | Disable Ctrl-Alt-Delete target
      ansible.builtin.systemd:
        name: ctrl-alt-del.target
        masked: true
      tags: [system, cis_1_4_1]

    # CIS 3.1 - Network sysctl hardening
    - name: CIS 3.1 | Apply network sysctl hardening
      ansible.builtin.sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
        sysctl_set: true
        state: present
        reload: true
      loop:
        - { key: net.ipv4.ip_forward,            value: "{{ sysctl_ipv4_forwarding }}" }
        - { key: net.ipv4.conf.all.rp_filter,    value: "{{ sysctl_rp_filter }}" }
        - { key: net.ipv4.conf.all.send_redirects, value: "0" }
        - { key: net.ipv4.conf.all.accept_redirects, value: "{{ sysctl_icmp_redirects }}" }
        - { key: net.ipv4.conf.all.accept_source_route, value: "{{ sysctl_source_route }}" }
      tags: [network, cis_3_1]

    # CIS 5.2 - SSH hardening
    - name: CIS 5.2 | Configure SSH daemon hardening
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        validate: '/usr/sbin/sshd -t -f %s'
      loop:
        - { regexp: '^#?MaxAuthTries', line: "MaxAuthTries {{ ssh_max_auth_tries }}" }
        - { regexp: '^#?PermitRootLogin', line: "PermitRootLogin {{ ssh_permit_root_login }}" }
        - { regexp: '^#?X11Forwarding', line: "X11Forwarding {{ ssh_x11_forwarding }}" }
        - { regexp: '^#?AllowTcpForwarding', line: "AllowTcpForwarding {{ ssh_allow_tcp_forwarding }}" }
        - { regexp: '^#?ClientAliveInterval', line: "ClientAliveInterval {{ ssh_client_alive_interval }}" }
        - { regexp: '^#?ClientAliveCountMax', line: "ClientAliveCountMax {{ ssh_client_alive_count_max }}" }
        - { regexp: '^#?PasswordAuthentication', line: "PasswordAuthentication {{ ssh_password_authentication }}" }
      notify: Reload sshd
      tags: [ssh, cis_5_2]

    # CIS 5.6 - Umask
    - name: CIS 5.6 | Set system-wide umask in /etc/profile.d/
      ansible.builtin.copy:
        content: "umask {{ system_umask }}\n"
        dest: /etc/profile.d/cis-umask.sh
        owner: root
        group: root
        mode: '0644'
      tags: [accounts, cis_5_6]

    # CIS 1.7 - Core dumps
    - name: CIS 1.7 | Disable core dumps via limits.conf
      ansible.builtin.lineinfile:
        path: /etc/security/limits.conf
        line: "* hard core 0"
      tags: [system, cis_1_7]

    - name: CIS 1.7 | Disable core dumps via sysctl
      ansible.builtin.sysctl:
        name: fs.suid_dumpable
        value: "0"
        sysctl_set: true
      tags: [system, cis_1_7]
```

### Part 5 - Run, Verify Idempotency, and Lint

```bash
# First run - will show many changed tasks
ansible-playbook playbooks/cis_harden.yml -v | tee /tmp/run1.txt

# Second run - must show changed=0, failed=0
ansible-playbook playbooks/cis_harden.yml -v | tee /tmp/run2.txt
grep "changed=" /tmp/run2.txt   # must be changed=0

# Lint - must resolve all violations
ansible-lint playbooks/cis_harden.yml
```

Fix any lint warnings before submission. Common fixes:
- Add `become: true` at play level instead of per-task
- Use FQCN (`ansible.builtin.package` not just `package`)
- Add `mode` to all `copy`/`template` tasks

### Part 6 - Verification Playbook

Write `playbooks/verify.yml` - runs assertions instead of making changes:

```yaml
---
- name: Verify CIS hardening controls are in place
  hosts: lab_targets
  gather_facts: false

  tasks:
    - name: Verify auditd is running
      ansible.builtin.service_facts:
    - name: Assert auditd is active
      ansible.builtin.assert:
        that: ansible_facts.services['auditd.service'].state == 'running'
        fail_msg: "FAIL: auditd is not running"
        success_msg: "PASS: auditd is running"

    - name: Read sshd_config
      ansible.builtin.slurp:
        src: /etc/ssh/sshd_config
      register: sshd_config

    - name: Assert PermitRootLogin is no
      ansible.builtin.assert:
        that: "'PermitRootLogin no' in sshd_config.content | b64decode"
        fail_msg: "FAIL: PermitRootLogin is not set to no"
        success_msg: "PASS: PermitRootLogin no"

    # Add similar assertions for each of your 10 controls...
```

```bash
ansible-playbook playbooks/verify.yml
```

All assertions must pass. Screenshot the output showing all PASS results.

---

## Submission Requirements

- `inventory/hosts.yml`, `ansible.cfg`, `group_vars/all.yml`
- `playbooks/cis_harden.yml` (complete, annotated)
- First run output (showing changed tasks with task names)
- Second run output proving `changed=0`
- `ansible-lint` clean output (zero violations)
- `playbooks/verify.yml` with assertions for all 10 controls
- Verification playbook run output showing all assertions PASS
- CIS control mapping table: Control ID → Playbook task name → Variable name → What it configures

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Ansible Vault & CI Integration

1. **Ansible Vault for sensitive variables:** Move any sensitive values (passwords, API keys - even if none exist yet, create a placeholder) into a vault-encrypted file:
   ```bash
   ansible-vault create group_vars/vault.yml
   # Add: vault_admin_password: "SuperSecretLab!"
   ansible-vault encrypt group_vars/vault.yml
   ```
   Update your playbook to reference `{{ vault_admin_password }}` where appropriate. Run the playbook using `--ask-vault-pass` or a vault password file. Document the security trade-offs of storing the vault password in a file vs. entering it interactively (consider CI/CD pipeline use cases).

2. **GitHub Actions CI pipeline:** Create `.github/workflows/ansible-lint.yml` in your lab repo:
   ```yaml
   name: Ansible Lint
   on: [push, pull_request]
   jobs:
     lint:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Run ansible-lint
           uses: ansible/ansible-lint@v24
           with:
             path: lab9/playbooks/cis_harden.yml
   ```
   Push your playbook to GitHub and show a screenshot of the Actions tab with a green lint run. This demonstrates the playbook is CI-gate-enforced - no bad playbooks can be merged.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
