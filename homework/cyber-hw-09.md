---
title: "CYBER HW 9 - Ansible Hardening Playbook: Advanced Features & Testing"
parent: Homework
nav_order: 9
---

# CYBER HW 9 - Ansible Hardening Playbook: Advanced Features & Testing
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | CYBER HW 9 |
| **Points** | 100 |
| **Due** | Week 10 |
| **Track** | Cyber |

---

## Description

Extend the Ansible hardening playbook from **Lab 9** into a production-quality role with proper structure, secret management, testing, and CI integration. A playbook that only works when an expert runs it is a script, not infrastructure code.

### Part 1 - Playbook Architecture (25 pts)

Restructure your Lab 9 playbook as a proper Ansible role at `roles/harden-ubuntu/`:

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

**Additional CIS controls:** Add at least **8 new CIS Level 1 or Level 2 controls** not covered in Lab 9. For each, add a comment citing the exact CIS control ID.

### Part 2 - Ansible Vault for Secrets (15 pts)

Use Ansible Vault to encrypt sensitive values:

1. Create `vars/secrets.yml` containing: a dummy LDAP bind password, a dummy log server API key, and a dummy SNMP community string
2. Encrypt the file with `ansible-vault encrypt`
3. Reference the encrypted variables in your tasks (for example, use the LDAP password in a task that configures PAM LDAP - even if the task is a `debug` print for testing purposes)
4. Document in your README: how a new team member would run the playbook with vault (what `--ask-vault-pass` or vault password file approach you use), and the security trade-off of storing the vault password file on disk vs. using a secrets manager

Include the encrypted `vars/secrets.yml` in your PR (it is safe to commit encrypted vault files).

### Part 3 - Idempotency & Testing (35 pts)

**Idempotency verification:** Run your playbook twice against the same host and capture the output of both runs. The second run must show `changed=0` for all tasks. Include both run outputs in your submission. If any task is not idempotent, fix it and explain what you changed.

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
- At least 3 CIS controls from your role are in their hardened state
- The pre-task OS check works (test with a non-Ubuntu image - Molecule should fail and show your error message)

Run `molecule test` and include the truncated output showing all tests passing.

### Part 4 - GitHub Actions CI Pipeline (25 pts)

Write `.github/workflows/ansible-lint.yml` that runs on every pull request to `main`:

1. **ansible-lint** - runs `ansible-lint` against your role and fails the PR if any violations above `warning` severity are found
2. **yaml-lint** - runs `yamllint` against all YAML files
3. **syntax check** - runs `ansible-playbook --syntax-check site.yml`
4. **Molecule test** - runs `molecule test` using the Docker driver (use `ubuntu:22.04` as the test image)

The workflow must use a matrix strategy to test against both `ubuntu:20.04` and `ubuntu:22.04`.

Include a screenshot of a passing GitHub Actions run in your submission, or provide your PR link where the Actions run is visible.

---

## Deliverable(s)

{: .callout }
**Auto-grader:** When you open your PR, a GitHub Actions workflow runs `ansible-lint` and `ansible-playbook --syntax-check` against your role. It deliberately does not run your Molecule test suite in CI (too fragile to nest reliably on a hosted runner) - lint/syntax is a floor, not a substitute for your own Molecule results.

Commit your full role structure to `homework/assets/cyber-hw-09-role/`. Write your analysis and instructions in `homework/cyber-hw-09.md`.

Open a PR titled `CYBER HW 9 - Ansible Hardening Role` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| Role structure - correct directory layout, handlers, templates, pre-tasks | 25 |
| Ansible Vault - encrypted file, referenced in tasks, documented | 15 |
| Idempotency - second run shows changed=0, evidence provided | 15 |
| Molecule tests - 8+ assertions, OS pre-check tested | 20 |
| GitHub Actions CI pipeline - lint + test, matrix strategy | 25 |

---

## Tip

{: .tip }
`ansible-lint` will flag `ignore_errors: yes` and bare variable names. Fix the warnings before your CI run - they are there for good reasons. Use `# noqa` only when you genuinely know better than the linter, and comment why.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Supply Chain Security & External Validation (30 pts)

**Supply Chain Risk Analysis (15 pts)**

Enumerate every external dependency introduced by your Ansible role and produce a formal **Supply Chain Risk Assessment** (`cyber-hw-09-supply-chain.md`):

1. **Dependency Inventory:** List every Galaxy collection, OS package, pip module, and external URL your role touches during execution. For each, record: source, current version, last updated, maintainer/publisher, download count (as a proxy for vetting), and whether a known CVE exists against it.

2. **Risk Rating:** Rate each dependency Low/Medium/High based on: (a) whether it runs as root, (b) whether its integrity is verified (hash/signature), (c) whether you could substitute it with a first-party alternative.

3. **Mitigations:** For each High-rated dependency, propose a specific mitigation - e.g., hash pinning in `requirements.yml`, hosting a private Ansible Galaxy mirror, using `get_url` with `checksum`, or replacing with a built-in Ansible module. Implement at least 2 of these mitigations in your role and demonstrate them working in your Molecule tests.

**Delegated External Validation Test (15 pts)**

Extend your Molecule test suite with a **delegated validator** scenario: add a second container (`validator`) to your `molecule.yml` that is NOT the target of your role. After the role converges on the target, write a Molecule verify step that runs from the `validator` container and attempts:

- SSH login to the target with a password (should fail - verify exit code 1)
- Connection to a port that should be firewalled (should be refused)
- Fetching `/etc/shadow` via an HTTP server that should not be running (should be refused)

Document each test with the expected and actual output. The goal is to prove your hardening works from an external attacker's perspective, not just from localhost.


[← Back to Homework]({{ site.baseurl }}/homework/)
