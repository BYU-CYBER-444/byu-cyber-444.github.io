---
title: "LAB 10 - Ansible Hardening Playbook"
parent: Labs
nav_order: 10
---

# LAB 10 - Ansible Hardening Playbook
{: .no_toc }


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
- Restructure the playbook into a proper, reusable Ansible role with pre-tasks and 8 additional CIS controls
- Encrypt sensitive variables with Ansible Vault
- Build a Molecule test scenario (Docker driver) that verifies the role's behavior, including a negative test
- Gate the role behind a GitHub Actions CI pipeline (lint, syntax check, and Molecule test on a matrix of OS versions)

---

## Tools Required

- Your instructor has provisioned two Ubuntu 22.04 VMs for this lab: `lab10-ctrl01` (the Ansible controller, with Ansible 2.14+) and `lab10-target01` (the hardening target)
- SSH key pair for Ansible authentication
- Docker (for Molecule's Docker driver, Part 9)
- Molecule with the Docker driver and `ansible-lint` (`pip3 install molecule molecule-plugins[docker] ansible-lint --break-system-packages`)
- A GitHub repo for the lab work, for the CI pipeline in Part 10

```bash
sudo apt install ansible ansible-lint python3-pip -y
pip3 install ansible-lint --break-system-packages
```

---

## Background

A hardening script that only runs correctly when the person who wrote it runs it isn't infrastructure automation - it's a one-off. This lab builds toward genuine, reusable configuration management: starting with a flat, idempotent playbook against 10 CIS controls, then restructuring that same logic into a proper Ansible role with pre-tasks, encrypted secrets, and automated testing via Molecule - the same shape a role published for a real fleet would need to take before anyone else could trust running it unattended.

---

## Procedure

### Part 1 - Ansible Setup & SSH Key Authentication

Ansible must authenticate via SSH key (not password) in production. Set this up first:

```bash
# On controller: generate a dedicated Ansible key
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key -C "ansible@lab10" -N ""

# Copy the public key to the target VM
ssh-copy-id -i ~/.ssh/ansible_key.pub ubuntu@192.168.56.30

# Test passwordless auth
ssh -i ~/.ssh/ansible_key ubuntu@192.168.56.30 'echo "SSH key auth works"'
```

### Part 2 - Inventory and Ansible Configuration

Create a structured project directory:

```bash
mkdir -p ~/lab10/{inventory,group_vars,host_vars,roles,playbooks}
cd ~/lab10
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

### Part 7 - Restructure as a Production Role

A playbook that only works when an expert runs it is a script, not infrastructure code. Restructure the flat playbook from Parts 1-6 into a proper Ansible role at `roles/harden-ubuntu/`:

```
roles/harden-ubuntu/
 defaults/main.yml     # all defaults with comments
 vars/main.yml         # site-specific overrides (no secrets)
 tasks/
    main.yml          # imports all task files
    accounts.yml      # account hardening tasks
    ssh.yml           # SSH hardening tasks
    kernel.yml        # sysctl hardening tasks
    auditd.yml        # audit rules tasks
    packages.yml      # package management tasks
 handlers/main.yml     # service restart handlers
 templates/            # Jinja2 templates for configs
    sshd_config.j2
    audit.rules.j2
 meta/main.yml         # role metadata
```

All site-specific values (org name, log server IP, allowed SSH ciphers, NTP servers) must be variables in `defaults/main.yml` with clear documentation comments. No hardcoded values anywhere else.

**Handlers:** Write handlers for `restart sshd`, `restart auditd`, `reload sysctl`, and `apply auditd rules`. Tasks that modify configs must notify the appropriate handler.

**Pre-tasks:** Add a pre-task block that:
1. Verifies the target OS is Ubuntu 20.04 or 22.04 - fails with a clear error message if not
2. Checks that the target host has at least 1 GB of free disk space (for log storage) - warns if below 2 GB

**Additional CIS controls:** Add at least **8 new CIS Level 1 or Level 2 controls** beyond the 10 from Part 4. For each, add a comment citing the exact CIS control ID.

### Part 8 - Ansible Vault for Secrets

Use Ansible Vault to encrypt sensitive values:

1. Create `vars/secrets.yml` containing: a dummy LDAP bind password, a dummy log server API key, and a dummy SNMP community string
2. Encrypt the file with `ansible-vault encrypt`
3. Reference the encrypted variables in your tasks (for example, use the LDAP password in a task that configures PAM LDAP - even if the task is a `debug` print for testing purposes)
4. Document in your README: how a new team member would run the playbook with vault (what `--ask-vault-pass` or vault password file approach you use), and the security trade-off of storing the vault password file on disk vs. using a secrets manager

The encrypted `vars/secrets.yml` is safe to commit alongside the rest of the role.

### Part 9 - Idempotency & Molecule Testing

**Role idempotency verification:** Run your restructured role twice against the same host and capture the output of both runs. The second run must show `changed=0` for all tasks - the added pre-tasks and 8 new controls must be idempotent too, not just the original 10. Include both run outputs in your submission. If any task is not idempotent, fix it and explain what you changed.

**Molecule test scaffold:** Set up a Molecule test scenario (`molecule/default/`) using the Docker driver:

```
molecule/
 default/
     molecule.yml      # Docker driver config
     converge.yml      # runs your role
     verify.yml        # Testinfra or Ansible assertions
```

Write at least **8 Molecule verify assertions** covering:
- sshd is running and PermitRootLogin is disabled
- Password authentication is disabled in sshd_config
- auditd service is running and enabled
- At least 3 of your 8 new CIS controls are in their hardened state
- The pre-task OS check works (test with a non-Ubuntu image - Molecule should fail and show your error message)

Run `molecule test` and include the truncated output showing all tests passing.

### Part 10 - GitHub Actions CI Pipeline

Write `.github/workflows/ansible-lint.yml` that runs on every pull request to `main`:

1. **ansible-lint** - runs `ansible-lint` against your role and fails the PR if any violations above `warning` severity are found
2. **yaml-lint** - runs `yamllint` against all YAML files
3. **syntax check** - runs `ansible-playbook --syntax-check site.yml`
4. **Molecule test** - runs `molecule test` using the Docker driver (use `ubuntu:22.04` as the test image)

The workflow must use a matrix strategy to test against both `ubuntu:20.04` and `ubuntu:22.04`.

Include a screenshot of a passing GitHub Actions run in your submission, or provide your PR link where the Actions run is visible.

---

## Deliverables

- `inventory/hosts.yml`, `ansible.cfg`, `group_vars/all.yml`
- `playbooks/cis_harden.yml` (complete, annotated, from Part 4)
- First and second run output for the Part 4 playbook (showing `changed=0` on the second run)
- `playbooks/verify.yml` with assertions for all 10 Part-4 controls, plus its run output showing all PASS
- CIS control mapping table: Control ID → Playbook task name → Variable name → What it configures
- Full `roles/harden-ubuntu/` role structure (Part 7), including the encrypted `vars/secrets.yml` (Part 8)
- Role first and second run output proving `changed=0`
- `ansible-lint` clean output (zero violations) for the role
- `molecule/default/` scenario and a `molecule test` run showing all assertions passing (Part 9)
- `.github/workflows/ansible-lint.yml` and a screenshot or PR link showing a passing Actions run (Part 10)
- README section documenting your Vault password-management approach and its security trade-offs

---

## Grading

| Item | Points |
|------|--------|
| SSH key authentication setup (Part 1) | 5 |
| Inventory and Ansible configuration (Part 2) | 5 |
| Variables file (Part 3) | 5 |
| Hardening playbook - 10 CIS controls (Part 4) | 15 |
| Idempotency verified + clean lint (Part 5) | 10 |
| Verification playbook - all PASS (Part 6) | 10 |
| Production role restructure + 8 additional controls (Part 7) | 15 |
| Ansible Vault for secrets (Part 8) | 8 |
| Molecule testing - 8+ assertions (Part 9) | 12 |
| GitHub Actions CI pipeline (Part 10) | 15 |
| **Total** | **100** |

---

[← Back to Labs]({{ site.baseurl }}/labs/)
