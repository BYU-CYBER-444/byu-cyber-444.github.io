---
title: "LAB 10 & 11 - Automated Hardening and Drift Detection"
parent: Labs
nav_order: 10
---

# LAB 10 & 11 - Automated Hardening and Drift Detection
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Purpose

Turn a security baseline into automation that can be reviewed, applied repeatedly, checked independently, and repaired after drift. You will build five Rocky Linux 9 virtual machines from a cloud image using cloud-init, then write an Ansible role that applies the same 10 controls to every target. You will verify all 50 host-control results yourself, prove the role is idempotent, and build a drift detector with a safe remediation option.

The instructor autograder is a final, one-time grading run. You are responsible for testing your work thoroughly before that run. Your own test suite must catch incorrect control states, repeat-run changes, missed or falsely reported drift, broken remediation, and detector failures.

## Learning objectives

By the end of this lab, you will be able to:

- Build five Rocky Linux targets with your own cloud-init configuration and provisioning automation.
- Apply a documented Linux baseline to all five targets with an Ansible role.
- Prepare separate student and TA access on every target.
- Explain how each control is represented in the target system and how you verify it independently.
- Make repeatable changes that report `changed=0` on a second run.
- Detect exactly which controls have drifted, report them as JSON, and remediate them on request.
- Test the full workflow before a one-time external grade run.


## Read before starting

The instructor autograder runs once for the final grade; it is not a debugging loop. Before requesting that run, use your own test suite to verify provisioning, access, hardening, idempotency, drift detection, and remediation.

The autograder deletes the five assigned VMs and then runs the deployment script you create at **`/opt/autograder.sh`** on `lab11-ctrl`. That script must rebuild the VMs and apply your hardening playbook using only software already present on the LXC. It must not prompt for input. The autograder will then independently inspect the resulting VMs.

The autograder depends on all VMIDs, names, and IP addresses matching the table below. The instructor's public SSH key must be installed for `ta` on every VM, and `ta` must have passwordless sudo access so the autograder can inspect and test the systems.

## Environment

You have been given the machine `lab11-ctrl`, which is your Ansible controller. You will create five target VMs in your own Proxmox cluster as part of this lab. Download the official Rocky Linux 9 GenericCloud x86_64 QCOW2 image from the [Rocky Linux image repository](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/) directly to the Proxmox host where you will create the VMs. Verify it against the adjacent `.CHECKSUM` file. Do not download or store the VM disk image on `lab11-ctrl` or inside a guest VM.

Author the provisioning playbook and cloud-init configuration from scratch. Keep your source user-data and metadata files in `provision/cloud-init/` in your project, and have your provisioning workflow transfer or install the required cloud-init files as Proxmox snippets on Proxmox storage before creating the VMs. The image and cloud-init snippets must be available to Proxmox when the autograder rebuilds the VMs; they must not exist only on `lab11-ctrl`. Do not use or clone an existing Proxmox VM template. No starter scripts are provided. Store Proxmox credentials only in an encrypted Ansible Vault file.

Your instructor has set up Proxmox access that is scoped to this lab. `/opt/lab11/pve-credentials.txt` on `lab11-ctrl` lists everything you need: the Proxmox API address, a limited API token that can only manage VMs in your lab resource pool (create each of your VMs with the `pool` parameter set to that pool, or Proxmox refuses it), the storage names for the image, the snippets, and the VM disks, the network bridge, and an SSH account and key that can only write cloud-init snippets and the image file to the Proxmox host's import directory. Proxmox's `download-url` API call needs rights over the whole host, which this token deliberately does not have, so download the image on the Proxmox host through that SSH account. These are credentials; copy the values into your encrypted `vault.yml` and never into plaintext project files. You do not need, and are not given, a root or administrator login for this lab.

| Machine | Role | Notes |
|---|---|---|
| `lab11-ctrl` | Ansible LXC controller | The only machine supplied for this lab. Do all provisioning and Ansible work here. Do not install packages, collections, Python modules, or other software on this LXC. |
| `lab11-rocky01`–`lab11-rocky05` | Linux targets | Create five separate Rocky Linux 9 VMs from a cloud image; configure each with your own cloud-init data. |


{: .warning }
> You are responsible for creating all five target VMs. Before grading, the instructor autograder deletes VMIDs 1001–1005 and recreates them by running your deployment script.

Do not use VMIDs `1001`–`1005` for any other VMs or data: the autograder deletes the VMs with these IDs before rebuilding the lab.

## Part 1 - Provision targets and configure access

Write the VM creation as an Ansible playbook and write the cloud-init files yourself from scratch. The instructor autograder deletes these five VMs, then runs your deployment script on the provided LXC to recreate them. The playbook and script must be complete, repeatable, and noninteractive. Use these exact VM names:

Use the same per-student subnet convention as the other labs: `x` is the third octet of your assigned `172.19.x.0` subnet. Configure these fixed IP addresses in cloud-init so the VMs keep the same addresses after reboot and rebuild:

| VM name | Required VMID | Required IP address | Operating system |
|---|---:|---|---|
| `lab11-rocky01` | `1001` | `172.19.x.27` | Rocky Linux 9 |
| `lab11-rocky02` | `1002` | `172.19.x.28` | Rocky Linux 9 |
| `lab11-rocky03` | `1003` | `172.19.x.29` | Rocky Linux 9 |
| `lab11-rocky04` | `1004` | `172.19.x.30` | Rocky Linux 9 |
| `lab11-rocky05` | `1005` | `172.19.x.31` | Rocky Linux 9 |

Create your own cloud-init user-data and metadata for the VMs. Configure each VM with its required static IP from the table, a unique hostname, student SSH access, and the `ta` account. Use the gateway (`172.19.x.1`) and DNS server assigned to your nested subnet; use the gateway as DNS if your subnet has no separate DNS address. Do not choose different VM addresses. Author all cloud-init, provisioning, Ansible role, playbook, verifier, and detector files from scratch; you may consult documentation, but no starter files or copied solutions are allowed. Record each VM ID and address. Confirm student SSH access before hardening. Do not apply any controls from Part 2 yet.

Save the cloud-init source files, your provisioning playbook, an encrypted `vault.yml`, and a short `provision/README.md` recording the image filename and checksum, Proxmox host and storage location for the image and snippets, VM names, required VMIDs, and addresses. Put Proxmox API credentials and other provisioning secrets in `vault.yml`; do not put plaintext secrets or the Vault password in the project or Git history. The encrypted Vault file is required in your submission.

The autograder reads the Ansible Vault password from **`/opt/password`**. Store only the password on the first line of that file. Set permissions so only your account and the autograder can read it, and keep it out of the lab project and Git. Your `/opt/autograder.sh` must tell Ansible to use this file; the autograder does not set any Ansible variables for it.

In `provision/create-vms.yml`, load `vault.yml` from the `provision/` directory and use those decrypted values for Proxmox access. Do not hard-code Proxmox credentials in the playbook. Keep this playbook at `/home/<netid>/lab11/provision/create-vms.yml`; the deployment script must call it from there. Create the executable deployment script at `/opt/autograder.sh`. It must provision the five VMs, wait until cloud-init and SSH are ready, apply `site.yml`, and stop with a failure status if any required step fails. The playbook and script must use only tools already present on `lab11-ctrl` and must not install packages, collections, Python modules, or other software.

Create a separate student-controlled Ansible login on each target before hardening. On `lab11-ctrl`, create an SSH key pair for your own account. Install that key pair's public key for your student-controlled account on all five targets, and configure your inventory to use the matching private key from `lab11-ctrl`. Keep the private key on the controller only; do not copy it to a target, include it in the project, or submit it. Use this student key to test SSH and Ansible connectivity before hardening. Also configure the privilege escalation needed for the role. Put only the connection details the playbook needs in `/opt/lab11/inventory.ini`.

### Add the TA account and public key

Create a local account named `ta` on **all five** VMs and install the instructor-provided public key for that account. Grant the account passwordless sudo access so the instructor autograder can inspect each VM. Preserve this account and its access during hardening.

Install the complete instructor-provided public key below without changing it.

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsguw+aHZohBHM33FiiI0kL/ku7phW/OsOV1MMyL4eG
```

On every Rocky Linux target, place the instructor's public key in `/home/ta/.ssh/authorized_keys` with ownership and permissions that allow SSH to use it. Do not replace this key with your own key or use it for your student Ansible account. You receive only the TA public key, so you cannot test TA authentication yourself; the instructor autograder holds the matching private key and will test it.

Test access with your own self-generated key pair: verify that your private key on `lab11-ctrl` authenticates as your student-controlled account on all five targets, and confirm Ansible can reach all five. Separately verify that provisioning created the `ta` account, installed the exact instructor public key, and granted passwordless sudo. The autograder verifies actual TA-key login and sudo access.

### Create the inventory

Have `provision/create-vms.yml` generate `/opt/lab11/inventory.ini` with a group named `linux`, all five exact host names, their stable IP addresses, and the SSH connection variables required by your student account. Use your student-controlled account and private key for your Ansible connections; the `ta` account is reserved for the instructor autograder's key-based SSH access. The playbook must set the inventory file's owner and permissions so only your account can read it. After provisioning, inspect the generated file and confirm its owner and permissions. Do not copy the inventory into your project directory or Git. Verify that Ansible can connect to all five machines before continuing.

Resolve connection problems before continuing. Confirm your Ansible account can reach all five machines over SSH and that the instructor's `ta` key access is configured on each. Do not remove or change the `ta` account while hardening.

Your `provision/create-vms.yml` playbook must wait for cloud-init to finish, verify student SSH access, confirm that the `ta` account has the required public key and passwordless sudo configuration, and write `/opt/lab11/inventory.ini`. Students cannot test TA key authentication; the instructor autograder verifies it. The playbook must be safe to rerun after the grader deletes the assigned VMIDs.

## Required project layout

Build this layout in `/home/<netid>/lab11/`:

```text
provision/
  README.md
  create-vms.yml                  # your from-scratch VM provisioning playbook
  vault.yml                       # encrypted Proxmox secrets; no plaintext values
  cloud-init/
    user-data.yaml                # source configuration; deploy as a Proxmox snippet
    meta-data.yaml                # distinct metadata per VM; deploy as Proxmox snippets
site.yml
roles/
  linux_hardening/
    defaults/
      main.yml
    handlers/
      main.yml
    tasks/
      main.yml
detect-drift.sh
tests/
  verify-controls.yml
  self-test.sh
  inject-test-drift.yml
  unreachable.ini
  self-test-output.txt
reports/
  clean.json
  injected-drift.json
  after-remediation.json
  unreachable-test.json
```

You may split role tasks into additional files. Keep every required file at the path shown so you and the instructor autograder can run it consistently.

Inspect all five systems and note a few controls that are not yet in their required state. Confirm the `linux` inventory group and all five host names before writing your role.

## Part 2 - Build the Linux baseline

Create `roles/linux_hardening`. Put configurable target values in `defaults/main.yml`, use handlers for required service restarts, and assign each control an Ansible tag matching its ID in lowercase. Every task name must begin with its bracketed ID exactly as shown, for example `[LNX-03] Set sshd session limits`.

| ID | Control | Required end state |
|---|---|---|
| LNX-01 | SELinux | Enforcing now and after reboot, with the targeted policy. |
| LNX-02 | Host firewall | `firewalld` enabled and running. The default zone allows only the `ssh` service in runtime and permanent configuration. |
| LNX-03 | sshd session limits | `MaxAuthTries 4`, `X11Forwarding no`, `ClientAliveInterval 300`, and `ClientAliveCountMax 3`. |
| LNX-04 | Password aging | `/etc/login.defs` has `PASS_MAX_DAYS 90`, `PASS_MIN_DAYS 1`, and `PASS_WARN_AGE 7`. |
| LNX-05 | Default umask | `UMASK 027` in `/etc/login.defs` and `umask 027` for login shells through `/etc/profile.d/lab11-umask.sh`. |
| LNX-06 | Unused kernel modules | `cramfs` and `usb-storage` each have `install <module> /bin/false` and `blacklist <module>` in `/etc/modprobe.d/`; neither is loaded. |
| LNX-07 | Time synchronization | `chrony` is installed, enabled, and running. |
| LNX-08 | Legacy remote-access software | `telnet`, `telnet-server`, `rsh`, and `rsh-server` are absent. |
| LNX-09 | World-writable directories | Every local world-writable directory has the sticky bit set. |
| LNX-10 | Sensitive file permissions | `/etc/ssh/sshd_config` is `root:root 0600`, `/etc/gshadow` is `root:root 0000`, and `/etc/group` is `root:root 0644`. |

Important constraints:

- Do not change `PermitRootLogin`, `PasswordAuthentication`, the student-controlled account, or any setting needed for SSH access. Validate sshd configuration with the daemon's syntax-check mode before restarting the service.
- Prefer purpose-built modules such as `ansible.posix.selinux`, `ansible.posix.firewalld`, `ansible.builtin.lineinfile`, `ansible.builtin.dnf`, `ansible.builtin.file`, and `ansible.builtin.stat` over `command` or `shell` for changes.
- Tasks that rely on `command` or `shell` do not provide useful `--check` results by default. For read-only discovery, set `check_mode: false` and `changed_when: false`; make changes with check-mode-aware modules.
- A second normal run must converge with no changes.

## Part 3 - Orchestrate and verify repeatability

Create `site.yml` with a play for the `linux` group and apply `roles/linux_hardening` to all five hosts. Use the same role and control values on each host.

Apply the role to the `linux` group, confirm all five targets remain reachable, and inspect the results. Then run the full playbook a second time to verify idempotency.

The recap must show `changed=0` and `failed=0` for all five hosts. Investigate every change on the second run. Common causes include shell tasks without accurate change reporting, edits that rewrite a file every run, and unconditional service restarts.

Run `ansible-lint` on `site.yml` and your role. Fix the findings that apply to your code. Keep all work local to `lab11-ctrl`; the autograder performs no installs.

## Part 4 - Build an independent control verifier

Create `tests/verify-controls.yml`. It must observe target state and assert the required end state for **all 10 controls on each of the five hosts** (50 host-control checks). It must not apply, repair, or otherwise change the targets. Do not use successful role output as proof that a control is correct; inspect the resulting service, package, file, or kernel state independently.

Use read-only checks such as facts, `stat`, `slurp`, service facts, package facts, and kernel module state. Use `ansible.builtin.assert` (or equivalent assertions) with a useful failure message naming the host and control ID.

Your verifier must check at least the following evidence:

- **LNX-01–02:** SELinux is enforcing and persistent; `firewalld` is active and enabled, and the default zone allows only SSH in runtime and permanent configuration.
- **LNX-03–05:** the required sshd values, password-aging values, login-shell umask, and profile script contents are present.
- **LNX-06–08:** both module configuration entries exist and the modules are unloaded; `chrony` is installed and active/enabled; all four packages are absent.
- **LNX-09–10:** local world-writable directories have the sticky bit; each protected file has the required owner, group, and mode.
- Run every check against every host in the `linux` group; do not verify only one representative machine.

Run the verifier against the clean, hardened targets and require all 50 host-control checks to pass. Also run it after controlled test drift in Part 5; it should fail only for the controls you intentionally changed. Verify that it passes again after remediation.

## Part 5 - Build and run your preflight suite

Create `tests/inject-test-drift.yml` to make two safe, temporary changes for testing only:

- Change the Linux password maximum age for LNX-04 from `90` to `91` on `lab11-rocky01` and `lab11-rocky05`.

Do not test by changing SSH access, the firewall, SELinux, or another control that could lock you out. If a test leaves a control in the wrong state, reapply the normal hardening playbook or use the detector's remediation mode. If a target becomes unreachable, use the Proxmox console to restore access or recreate only that assigned VM with your deployment automation, then rerun your checks.

Create executable `tests/self-test.sh`. It must run the following checks in order and return nonzero as soon as a required check fails:

1. Ping the `linux` inventory group and require all five hosts to respond.
2. Run `tests/verify-controls.yml` on the clean targets and require all 50 host-control checks to pass.
3. Run `site.yml` again and require all five hosts to report `changed=0` and `failed=0`.
4. Run the drift detector on the clean targets. Require exit `0` and an empty ID list for all five hosts in `reports/drift.json`.
5. Copy the clean report to `reports/clean.json`. Run `tests/inject-test-drift.yml`, then run `tests/verify-controls.yml` and require it to fail only on LNX-04 for `lab11-rocky01` and `lab11-rocky05`. Run the detector and require exit `2`; the report must list exactly `LNX-04` for those two hosts and empty lists for the other three. Copy this report to `reports/injected-drift.json`.
6. Confirm `reports/drift.json` is valid JSON, includes every inventory host, and contains no duplicate control IDs.
7. Run the detector with `--remediate`, then run the verifier and detector again. Require all assertions to pass, detector exit `0`, and empty drift lists. Copy the clean report to `reports/after-remediation.json`.
8. Exercise the detector's failure path with the disposable inventory in `tests/unreachable.ini`. Require exit `1`, not a clean-state or drift exit code. Use a short connection timeout so this check finishes promptly, and copy the resulting report to `reports/unreachable-test.json`.

The failure-path test must not use or modify `/opt/lab11/inventory.ini`. The disposable inventory should contain only a deliberately unreachable test host, use a reserved documentation IP address, and keep its connection timeout short.

Make `tests/self-test.sh` executable, then run the suite from the project root. Save its complete output in `tests/self-test-output.txt`. Fix every failed check before asking for the instructor autograder, and rerun the suite after every repair.

## Part 6 - Implement the drift detector

Create executable `detect-drift.sh`. It runs the playbook in check mode, does not change any target in its default mode, and writes `reports/drift.json` every time.

Required behavior:

- In its default mode, use `/opt/lab11/inventory.ini` and report drift without changing targets.
- Accept the `--remediate` option to reapply the baseline before checking again.
- Accept `--inventory PATH` for the unreachable-host test; without this option, always use `/opt/lab11/inventory.ini`.
- Allow the remediation and inventory options together.
- For detection, perform an Ansible playbook run in check mode with diff output enabled. In remediation mode, apply the baseline playbook normally, then check again.
- Exit `0` when no control would change, `2` when at least one control has drifted, and `1` when Ansible cannot complete the check or a task fails.
- Return each drifted control ID once under its host, even if multiple tasks for that control would change.
- Include every host in the selected inventory in the JSON report. If the check fails, do not return an exit code that suggests the targets are clean.

Example clean report:

```json
{
  "lab11-rocky01": [],
  "lab11-rocky02": [],
  "lab11-rocky03": [],
  "lab11-rocky04": [],
  "lab11-rocky05": []
}
```

Example report after the test drift in Part 5:

```json
{
  "lab11-rocky01": ["LNX-04"],
  "lab11-rocky02": [],
  "lab11-rocky03": [],
  "lab11-rocky04": [],
  "lab11-rocky05": ["LNX-04"]
}
```

The report's top-level keys must match the inventory host names. The order of hosts and IDs does not matter, but IDs must be unique within each host. Machine-readable Ansible output is a useful way to capture task names and change status; `python3` is installed on the controller to produce and validate JSON.

## Part 7 - Remediate drift

The remediation option must reapply `site.yml`, then run the check again. It must leave a clean report and exit `0` only if all five targets match the baseline after remediation.

Drift checks are run on demand, by you and by the autograder. Nothing runs on a schedule, so do not create a timer, cron job, or service for the detector.

## Part 8 - Prepare for the one-time instructor autograder

The instructor autograder is not a test environment. It runs once for the final grade. Finish the student-built suite and inspect its output before requesting that run.

Before grading, confirm:

- Your project is in `/home/<netid>/lab11/` and contains `provision/`, `site.yml`, `roles/linux_hardening/`, `detect-drift.sh`, `tests/verify-controls.yml`, `tests/self-test.sh`, `tests/inject-test-drift.yml`, `tests/unreachable.ini`, and `tests/self-test-output.txt`.
- `provision/create-vms.yml` is at the exact path used by the autograder; it creates VMIDs 1001–1005 from scratch with cloud-init and generates the protected inventory. `provision/vault.yml` is encrypted and contains no plaintext secrets.
- `provision/README.md` records the image filename and checksum, the Proxmox host and storage locations of the image and cloud-init snippets, all five VM IDs and required IP addresses (`172.19.x.27`–`172.19.x.31`), and your provisioning approach. The image and snippets remain available on Proxmox storage after VM deletion and are not in Git or stored only on `lab11-ctrl`.
- `/opt/autograder.sh` exists, is executable, and has been run successfully from a clean state. It creates the five assigned VMIDs, configures access, generates `/opt/lab11/inventory.ini`, and applies `site.yml`.
- You have verified the full rebuild path by removing only your assigned VMs, then confirming the deployment script recreates them correctly. Do this before requesting the one-time instructor run.
- `/opt/password` contains the Vault password and is readable by the autograder but is excluded from the project and Git.
- `detect-drift.sh` and `tests/self-test.sh` are executable.
- All five targets are reachable, the role applies without prompts, and a second run reports `changed=0` and `failed=0` for every host.
- The default target inventory is `/opt/lab11/inventory.ini`; hardening and drift checks run without prompts, privilege-escalation password prompts, unexpected extra variables, or collection installs. Your script points Ansible at `/opt/password`; the autograder sets no Ansible variables for you.
- The full playbook completes in under 15 minutes.
- `tests/self-test.sh` completes successfully from `/home/<netid>/lab11/` and its output is saved.
- The four saved JSON reports show the clean, injected-drift, remediated, and unreachable-host cases.

### Run your script exactly as the autograder does

After deleting VMIDs `1001`-`1005`, the autograder connects to `lab11-ctrl` over SSH as the `ta` account (no terminal, no input) and runs this one command, with `<netid>` replaced by your Net ID:

```bash
sudo -n -u <netid> -H env PATH=/home/<netid>/.local/bin:/home/<netid>/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin \
  bash -c 'cd / && /opt/autograder.sh > /tmp/lab11-grader-run.log 2>&1; echo RC=$?'
```

`/opt/autograder.sh` passes only if it exits with status `0` within 15 minutes (900 seconds). This is exactly what your script receives; nothing else is set up for it:

| What | Value |
|---|---|
| Account | You (`<netid>`), **not root**. `sudo` asks for a password, so your script cannot use it. |
| Working directory | **`/`**, not your project directory. Relative paths do not resolve. |
| `PATH` | `/home/<netid>/.local/bin:/home/<netid>/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin` (the Ansible commands are in `/usr/local/bin`). |
| Other environment | `HOME=/home/<netid>`, `USER` and `LOGNAME`, `LANG=en_US.utf8`, `SHELL=/bin/bash`, `TERM=unknown`, and `SUDO_*` variables. **No** `ANSIBLE_*` variables (so no `ANSIBLE_CONFIG` and no Vault password file), no SSH agent, and nothing from your `.bashrc`. |
| Terminal and input | No terminal. Standard input is `/dev/null`. Output goes to a log file, so nobody sees it live. |
| Starting state | VMs `1001`-`1005` do not exist. The Proxmox image and snippets, your key pair, and the old `/opt/lab11/inventory.ini` are still there, but the script must not depend on them; it must rebuild everything it needs. |
| Software | Only what is already on `lab11-ctrl`. Nothing may be installed. |

Make sure it works:

1. **Start with the working directory and the Ansible settings.** Because the script starts in `/`, begin it with `cd /home/<netid>/lab11` (or use absolute paths everywhere) and `export ANSIBLE_CONFIG=/home/<netid>/lab11/ansible.cfg`. Tell Ansible about the Vault password too, either with `vault_password_file = /opt/password` in that `ansible.cfg` or with `export ANSIBLE_VAULT_PASSWORD_FILE=/opt/password`. The autograder does **not** do this for you; without it you get `Attempting to decrypt but no vault secrets found` or `No inventory was parsed`.
2. **Stop on the first failure.** Use `set -euo pipefail`, and let the failing command's status become the script's exit status. Do not end the script with a command that always succeeds, such as `echo done`, after a step that failed.
3. **Never wait for input.** No prompts of any kind: no `read`, no `--ask-pass`, no `--ask-become-pass`, no `pause`, no `sudo`, and no SSH "are you sure you want to continue connecting" question. Every rebuilt VM has a new host key, so your SSH settings must not stop on an unknown or changed key.
4. **Do not depend on your shell.** No aliases, functions, exported variables, SSH agent, or hand-edited `~/.ssh/config`. Everything the script needs must be in the script, your project, `/opt/password`, or `/opt/lab11/`.
5. **Rebuild from nothing.** Assume no VMs exist: create them, wait for cloud-init and SSH, regenerate `/opt/lab11/inventory.ini`, and only then apply `site.yml`. Every step must also be safe to run again when the VMs already exist.
6. **Keep secrets out of the output.** The output goes to a file under `/tmp`. Do not print the API token or the Vault password.
7. **Check the files.** `/opt/autograder.sh` is executable (`chmod 755`) and owned by you. `/opt/password` has exactly one line and is not readable by everyone (for example `chmod 600`). Your whole run must finish in under 15 minutes; a normal rebuild takes about four.

Rehearse it the same way before you ask for the autograder, as yourself (this reproduces the account, directory, `PATH`, and the missing terminal and input):

```bash
env -i HOME=/home/<netid> USER=<netid> LOGNAME=<netid> LANG=en_US.utf8 TERM=unknown \
  PATH=/home/<netid>/.local/bin:/home/<netid>/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin \
  bash -c 'cd / && /opt/autograder.sh < /dev/null > /tmp/lab11-rehearsal.log 2>&1; echo RC=$?'
```

Then check all of these:

- It printed `RC=0`. Any other number means it failed; read the end of `/tmp/lab11-rehearsal.log` (`tail -n 40 /tmp/lab11-rehearsal.log`).
- Do it **from a clean state at least once**: remove VMIDs `1001`-`1005` first (in the Proxmox web interface: stop each VM, then **More > Remove**, tick **Destroy unreferenced disks**), run the rehearsal, and confirm all five VMs come back, reachable, with the baseline applied.
- Afterwards `tests/self-test.sh` still passes, and a second `site.yml` run reports `changed=0`.

| What you see in the log | Likely cause | Fix |
|---|---|---|
| `Attempting to decrypt but no vault secrets found` | The script did not point Ansible at `/opt/password`. | Set `ANSIBLE_VAULT_PASSWORD_FILE` or `vault_password_file`, and `ANSIBLE_CONFIG` (step 1). |
| `No inventory was parsed`, or `skipping: no hosts matched` | `ansible.cfg` was not found from `/`, or the inventory was not regenerated first. | Set `ANSIBLE_CONFIG`, or `cd` into the project; run the provisioning playbook before `site.yml`. |
| `ansible-playbook: command not found` | The script changed `PATH`. | Keep `/usr/local/bin` on `PATH`, or call `/usr/local/bin/ansible-playbook`. |
| `Host key verification failed`, or it hangs at a `yes/no` question | The rebuilt VMs have new SSH host keys. | Turn off strict host key checking for these hosts (step 3). |
| `sudo: a password is required` | The script uses `sudo`. | Remove it; nothing in the script needs root. |
| It hangs and the log stops growing | It is waiting for input or a terminal. | Remove every prompt (step 3); give waits an upper limit. |
| `RC=` is not `0` although everything looked fine | A command near the end (for example `grep` finding nothing) returns non-zero under `set -e`. | Read the last lines of the log and fix or handle that command. |
| It works in your shell but fails in the rehearsal | Your shell has variables, aliases, or an agent the script was relying on. | Compare with `env`, and move what it needs into the script. |

### What the instructor autograder does, in order


1. Deletes only the five assigned VMs, VMIDs `1001`–`1005`.
2. Executes `/opt/autograder.sh` on `lab11-ctrl` with the exact command above. Your script must use the Vault password in `/opt/password` itself. The script provisions the VMs using `provision/create-vms.yml`, then applies `site.yml`. It does not install anything on the LXC.
3. Waits for cloud-init and SSH, then confirms the five exact names and VMIDs, assigned IP addresses, target inventory, and TA key access.
4. Checks the applied baseline and records the play recap without prompts or extra variables.
5. Checks all 10 controls independently on all five targets.
6. Runs `site.yml` a second time and requires `changed=0` on all five hosts.
7. Calls `detect-drift.sh` with no options and requires exit `0` with an empty report.
8. Introduces drift in three randomly selected controls on each target, then requires detector exit `2` and a report naming exactly those controls for the correct hosts.
9. Calls `detect-drift.sh` with its remediation option, then checks again for exit `0` and a clean report.

If any student-built test fails, do not proceed to the one-time instructor run. Read the failing assertion or report, fix the corresponding role or detector, reapply the hardening playbook or recreate an affected assigned VM if needed, and run the full student suite again.

## Grading

| Area | What is checked | Points |
|---|---|---:|
| Environment, cloud-init, and connectivity | Five from-scratch Rocky VMs at the required VMIDs and IP addresses, encrypted provisioning secrets, original cloud-init and provisioning automation at the required path, generated protected inventory, and working student and TA key-based access. | 20 |
| Linux hardening controls | LNX-01 through LNX-10 reach their specified end states on all five hosts after provisioning and role application (6 points per control: 1 for each compliant host, plus 1 when all five are). | 60 |
| Role structure and safe automation | Required role layout, defaults, bracketed task IDs, matching tags, handlers, and safeguards that preserve SSH access. | 20 |
| Idempotency | Second full run reports `changed=0` and `failed=0` on all five hosts. | 20 |
| Student-built checks | Independent read-only assertions cover all 50 host-control results; the self-test runner checks repeatability, clean state, exact injected drift, valid JSON, remediation, and exit `1` for an unreachable host. | 25 |
| Drift detection | Clean and injected drift produce correct exit codes and exact, host-specific, duplicate-free JSON reports. | 25 |
| Remediation | `--remediate` restores the required baseline, then reports exit `0` and an empty drift report. | 15 |
| Lint, syntax, and grader compatibility | Lint and syntax checks are clean; grader paths, no-prompt execution, installed dependencies, and time limit are met. | 15 |
| **Total** |  | **200** |

---

[← Back to Labs]({{ site.baseurl }}/labs/)
