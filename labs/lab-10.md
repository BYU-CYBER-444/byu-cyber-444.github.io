---
title: "LAB 10 & 11 - Automated Deployment and Hardening"
parent: Labs
nav_order: 10
---

# LAB 10 & 11 - Automated Deployment and Hardening
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Purpose

Set up an automation system that will deploy five Rocky Linux 9 virtual machines using Ansible, Proxmox, and cloud-init. Then, create another Ansible role that will apply 10 security controls to the machine. The goal of this lab is to teach you Ansible and cloud-init.

The autograder will only allow you one attempt. You should have a stable, tested final script before you submit to attempt it. Additionally, your script should be idempotent.

## Learning objectives

By the end of this lab, you will be able to:

- Build five Rocky Linux targets with your own cloud-init configuration and provisioning automation.
- Apply a documented Linux baseline to all five targets with an Ansible role.
- Prepare separate student and TA access on every target.
- Make repeatable changes that report `changed=0` on a second run.
- Test the full workflow before a one-time external grade run.


## Read before starting

The instructor autograder runs once for the final grade; it is not a debugging loop. Before requesting that run, test provisioning, access, hardening, and idempotency yourself (a second run must report `changed=0`).

The autograder deletes the five assigned VMs and then runs the deployment script you create at **`/opt/autograder.sh`** on `lab11-ctrl`. That script must rebuild the VMs and apply your hardening playbook using only software already present on the LXC. It must not prompt for input. The autograder will then independently inspect the resulting VMs.

The autograder depends on all VMIDs, names, and IP addresses matching the table below. The instructor's public SSH key must be installed for `ta` on every VM, and `ta` must have passwordless sudo access so the autograder can inspect and test the systems.

## Environment

You have been given the machine `lab11-ctrl`, which is your Ansible controller. You will create five target VMs in your own Proxmox cluster as part of this lab. Download the official Rocky Linux 9 GenericCloud x86_64 QCOW2 image from the [Rocky Linux image repository](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/) directly to the Proxmox host where you will create the VMs. Do not download or store the VM disk image on `lab11-ctrl` or inside a guest VM. This file will need to live inside of an appropriate directory on Proxmox such that cloud-init will be able to access it; as you read online about cloud-init in trying to set up your automation, you should learn where to move it on the system.

Starter code is provided to help you with this, which you should download using the link below. The starter code contains the intended layout of directories and files (including any roles you should be making), and the different files you need to complete have helpful comments that should be able to guide you to the right resources.

[**starter code**](./assets/lab10-starter.zip)

Your instructor has set up Proxmox access that is scoped to this lab. `/opt/lab11/pve-credentials.txt` on `lab11-ctrl` lists everything you need: the Proxmox API address, a limited API token that can only manage VMs in your lab resource pool (create each of your VMs with the `pool` parameter set to that pool, or Proxmox refuses it), the storage names for the image, the snippets, and the VM disks, the network bridge, and an SSH account and key that can only write cloud-init snippets and the image file to the Proxmox host's import directory. These are credentials; copy the values into your encrypted `vault.yml` and never into plaintext project files. You should need to use each value provided in that credentials file, so if something you have isn't working right maybe check and make sure you're not missing some details from there.

| Machine | Role | Notes |
|---|---|---|
| `lab11-ctrl` | Ansible LXC controller | The only machine supplied for this lab. Do all provisioning and Ansible work here. Do not install packages, collections, Python modules, or other software on this LXC. |
| `lab11-rocky01`–`lab11-rocky05` | Linux targets | Create five separate Rocky Linux 9 VMs from a cloud image; configure each with your own cloud-init data. |


{: .warning }
> You are responsible for creating all five target VMs. Before grading, the instructor autograder deletes VMIDs 1001–1005 and recreates them by running your deployment script.

Do not use VMIDs `1001`–`1005` for any other VMs or data: the autograder deletes the VMs with these IDs before rebuilding the lab.

## Part 1 - Provision targets and configure access

Write all of the necessary VM creation infrastructure-as-code as detailed by lab instructions. The instructor autograder deletes these five VMs, then runs your deployment script on the provided LXC to recreate them. The playbook and script must be complete, repeatable, and noninteractive. Use these exact VM names (make sure you replace `x` with your assigned id. If you have come this far and can't do that, seek professional help):

| VM name | Required VMID | Required IP address | Operating system |
|---|---:|---|---|
| `lab11-rocky01` | `1001` | `172.19.x.27` | Rocky Linux 9 |
| `lab11-rocky02` | `1002` | `172.19.x.28` | Rocky Linux 9 |
| `lab11-rocky03` | `1003` | `172.19.x.29` | Rocky Linux 9 |
| `lab11-rocky04` | `1004` | `172.19.x.30` | Rocky Linux 9 |
| `lab11-rocky05` | `1005` | `172.19.x.31` | Rocky Linux 9 |

For the vault, autograder (and your starter code by default) will read the vault password out of **`/opt/password`**. Drop a password on the first and only line of that file and then don't worry about it for the rest of the lab (the grader will check and make sure the file only has one line fyi). You *might* need to make `/opt/autograder.sh` use it but I think the `ansible.cfg` probably covers it. Test it to be sure. Auto-dq if you hard-code credentials in your scripts. Use the vault file pls.

Ultimately, the starter code and comments will be the *most* helpful out of anything, but some more instructions are here as well for extra verbosity. [Cloud-init](https://cloud-init.io/) is a tool that aids in automation by allowing you to use a default cloud image and with a couple of extra static files configure things like its hostname, user information, and more. For this lab, you'll be creating `user-data` and `meta-data` files to configure the users for the lab and also the hostname and instance id. From inside Ansible, you will create these files from a template and place them on Proxmox for the create vm functionality to use.

Feel free to add additional files to the structure of the starter code, but don't go deleting or doing any major refactors to the code. What we've given you conforms to best practice in terms of playbook structure, so you should work off of the existing framework.

When you're configuring all the variables and stuff, you should heavily reference the variables and code that has been provided for you for starters. Understanding the meaning and purpose of different variables (such as `proxmox_snippets_dir`) will help you understand more about cloud-init and deployment.

PLEASE PLEASE PLEASE GUYS we spent a lot of time working on this lab to make it so that you can do it without AI. So pls don't slop it that would make me sad. Feel free to ask pointed questions about settings or ansible syntax on like a single-line basis to AI as you work through the `create_vms` role, but don't have it just generate you the stuff. Use the suggested ansible module, throw that into your search bar and just read through the docs on it and like 7/10 times the exact thing you want to do is in the example code anyways. We want you to learn to read the docs bc it will make you better with ansible in the long run. For the Linux hardening side, make sure you manually do the first like 2 or 3 (it should be trivial if you actually did the vm creation stuff) and then feel free to augment with AI for the rest of them.

Go back and make sure you read that last paragraph all the way please.

General helpful notes:
- Take a second and understand why the directory structure is the way it is
- You will need to create an account for you and an account for the ta
- You need more options than you think configured to create a VM
- Try, try again
- Maybe find a way to test on just creating one vm and scale it up for when you have it working
- Between creation and verification, you'll use an ephereal group for inventory, then the inventory file you make will be used by your hardening

### Add the TA account and public key

Create a local account named `ta` on **all five** VMs and install the instructor-provided public key for that account. Grant the account passwordless sudo access so the instructor autograder can inspect each VM. Preserve this account and its access during hardening.

Install the complete instructor-provided public key below without changing it.

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsguw+aHZohBHM33FiiI0kL/ku7phW/OsOV1MMyL4eG
```

On every Rocky Linux target, place the instructor's public key in `/home/ta/.ssh/authorized_keys` with ownership and permissions that allow SSH to use it. Do not replace this key with your own key or use it for your student Ansible account. You receive only the TA public key, so you cannot test TA authentication yourself; the instructor autograder holds the matching private key and will test it.

Test access with your own self-generated key pair: verify that your private key on `lab11-ctrl` authenticates as your student-controlled account on all five targets, and confirm Ansible can reach all five. Separately verify that provisioning created the `ta` account, installed the exact instructor public key, and granted passwordless sudo. The autograder verifies actual TA-key login and sudo access.

## Part 2 - Build the Linux baseline

Fill in `roles/linux_hardening`. Apply every control to all five hosts through `site.yml`.

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

Make sure `site.yml` uses the right group as you configured in the inventory file.

Apply the role to your created inventory, confirm all five targets remain reachable, and inspect the results. Then run the full playbook a second time to verify idempotency.

The recap must show `changed=0` and `failed=0` for all five hosts. Investigate every change on the second run. Common causes include shell tasks without accurate change reporting, edits that rewrite a file every run, and unconditional service restarts.

Run `ansible-lint` on `site.yml` and your role. Fix the findings that apply to your code. Keep all work local to `lab11-ctrl`; the autograder performs no installs.

## Part 4 - Prepare for the one-time instructor autograder

The instructor autograder is not a test environment. It runs once for the final grade. Test everything yourself and inspect the output before requesting that run.

Before grading, confirm:

- Your project is in `/home/<netid>/lab11/` and contains `provision.yml`, `site.yml`, `roles/create_vms/`, and `roles/linux_hardening/`.
- `provision.yml` and `roles/create_vms/` create VMIDs 1001–1005 from scratch with cloud-init and generate the protected inventory. `provision/vault.yml` is encrypted and contains no plaintext secrets.
- `provision/README.md` records the image filename and all five VM IDs and required IP addresses (`172.19.x.27`–`172.19.x.31`). The image and snippets remain available on Proxmox storage after VM deletion and are not in Git or stored only on `lab11-ctrl`.
- `/opt/autograder.sh` exists, is executable, and has been run successfully from a clean state. It creates the five assigned VMIDs, configures access, generates `/opt/lab11/inventory.ini` (mode `0600`), and applies `site.yml`.
- You have verified the full rebuild path by removing only your assigned VMs, then confirming the deployment script recreates them correctly. Do this before requesting the one-time instructor run.
- `/opt/password` contains the Vault password and is readable by the autograder but is excluded from the project and Git.
- All five targets are reachable, the role applies without prompts, and a second run reports `changed=0` and `failed=0` for every host.
- The default target inventory is `/opt/lab11/inventory.ini` (mode `0600`); deployment and hardening run without prompts, privilege-escalation password prompts, unexpected extra variables, or collection installs. Your script points Ansible at `/opt/password`; the autograder sets no Ansible variables for you.
- The full playbook completes in under 15 minutes.

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
| Software | Only what is already on `lab11-ctrl`. You can install packages and collections beforehand, but your script shouldn't. |

Make sure it works:

1. **Start with the working directory and the Ansible settings.** Because the script starts in `/`, begin it with `cd /home/<netid>/lab11` (or use absolute paths everywhere) and `export ANSIBLE_CONFIG=/home/<netid>/lab11/ansible.cfg`. Tell Ansible about the Vault password too, either with `vault_password_file = /opt/password` in that `ansible.cfg` or with `export ANSIBLE_VAULT_PASSWORD_FILE=/opt/password`. The autograder does **not** do this for you; without it you get `Attempting to decrypt but no vault secrets found` or `No inventory was parsed`.
2. **Stop on the first failure.** Use `set -euo pipefail`, and let the failing command's status become the script's exit status. Do not end the script with a command that always succeeds, such as `echo done`, after a step that failed.
3. **Never wait for input.** No prompts of any kind: no `read`, no `--ask-pass`, no `--ask-become-pass`, no `pause`, no `sudo`, and no SSH "are you sure you want to continue connecting" question. Every rebuilt VM has a new host key, so your SSH settings must not stop on an unknown or changed key.
4. **Do not depend on your shell.** No aliases, functions, exported variables, SSH agent, or hand-edited `~/.ssh/config`. Everything the script needs must be in the script, your project, `/opt/password`, or `/opt/lab11/`.
5. **Rebuild from nothing.** Assume no VMs exist: create them, wait for cloud-init and SSH, regenerate `/opt/lab11/inventory.ini`, and only then apply `site.yml`. Every step must also be safe to run again when the VMs already exist.
6. **Keep secrets out of the output.** The output goes to a file under `/tmp`. Do not print the API token or the Vault password.
7. **Check the files.** `/opt/autograder.sh` is executable (`chmod 755`) and owned by you. `/opt/password` has exactly one line and is not readable by everyone (for example `chmod 600`), and `/opt/lab11/inventory.ini` has permissions `600`. Your whole run must finish in under 15 minutes; a normal rebuild takes about four.

Rehearse it the same way before you ask for the autograder, as yourself (this reproduces the account, directory, `PATH`, and the missing terminal and input):

```bash
env -i HOME=/home/<netid> USER=<netid> LOGNAME=<netid> LANG=en_US.utf8 TERM=unknown \
  PATH=/home/<netid>/.local/bin:/home/<netid>/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin \
  bash -c 'cd / && /opt/autograder.sh < /dev/null > /tmp/lab11-rehearsal.log 2>&1; echo RC=$?'
```

Then check all of these:

- It printed `RC=0`. Any other number means it failed; read the end of `/tmp/lab11-rehearsal.log` (`tail -n 40 /tmp/lab11-rehearsal.log`).
- Do it **from a clean state at least once**: remove VMIDs `1001`-`1005` first (in the Proxmox web interface: stop each VM, then **More > Remove**, tick **Destroy unreferenced disks**), run the rehearsal, and confirm all five VMs come back, reachable, with the baseline applied.
- Afterwards a second `site.yml` run reports `changed=0`.

<!-- | What you see in the log | Likely cause | Fix |
|---|---|---|
| `Attempting to decrypt but no vault secrets found` | The script did not point Ansible at `/opt/password`. | Set `ANSIBLE_VAULT_PASSWORD_FILE` or `vault_password_file`, and `ANSIBLE_CONFIG` (step 1). |
| `No inventory was parsed`, or `skipping: no hosts matched` | `ansible.cfg` was not found from `/`, or the inventory was not regenerated first. | Set `ANSIBLE_CONFIG`, or `cd` into the project; run the provisioning playbook before `site.yml`. |
| `ansible-playbook: command not found` | The script changed `PATH`. | Keep `/usr/local/bin` on `PATH`, or call `/usr/local/bin/ansible-playbook`. |
| `Host key verification failed`, or it hangs at a `yes/no` question | The rebuilt VMs have new SSH host keys. | Turn off strict host key checking for these hosts (step 3). |
| `sudo: a password is required` | The script uses `sudo`. | Remove it; nothing in the script needs root. |
| It hangs and the log stops growing | It is waiting for input or a terminal. | Remove every prompt (step 3); give waits an upper limit. |
| `RC=` is not `0` although everything looked fine | A command near the end (for example `grep` finding nothing) returns non-zero under `set -e`. | Read the last lines of the log and fix or handle that command. |
| It works in your shell but fails in the rehearsal | Your shell has variables, aliases, or an agent the script was relying on. | Compare with `env`, and move what it needs into the script. | -->

### What the instructor autograder does, in order

1. Deletes only the five assigned VMs, VMIDs `1001`–`1005`.
2. Executes `/opt/autograder.sh` on `lab11-ctrl` with the exact command above. Your script must use the Vault password in `/opt/password` itself. The script provisions the VMs with `provision.yml`, then applies `site.yml`. It does not install anything on the LXC.
3. Waits for cloud-init and SSH, then confirms the five exact names and VMIDs, assigned IP addresses, and TA key access.
4. Checks the generated `/opt/lab11/inventory.ini` (mode `0600`), your project for leaked secrets, and your README.
5. Checks all 10 controls independently on all five targets.
6. Runs `site.yml` a second time and requires `changed=0` on all five hosts.
7. Runs `ansible-lint` on `site.yml` and `roles/linux_hardening/` and a syntax check of both playbooks.

If any of your own checks fails, do not proceed to the one-time instructor run. Read the failing output, fix the corresponding role or playbook, recreate an affected assigned VM if needed, and test again.

## Grading

| Area | What is checked | Points |
|---|---|---:|
| Environment, cloud-init, and connectivity | Five from-scratch Rocky VMs at the required VMIDs and IP addresses, encrypted provisioning secrets, original cloud-init and provisioning automation at the required path, generated protected inventory (mode `0600`), a README recording the image filename and the VM IDs and addresses, and working student and TA key-based access. | 70 |
| Linux hardening controls | LNX-01 through LNX-10 reach their specified end states on all five hosts after provisioning and role application (6 points per control: 1 for each compliant host, plus 1 when all five are). | 60 |
| Role structure and safe automation | The `linux_hardening` role has its `defaults`, `handlers`, and `tasks` files and `site.yml` applies it to your inventory's group; safeguards preserve SSH access (sshd configuration validated with `sshd -t`, `PermitRootLogin` and `PasswordAuthentication` untouched, `ta` and your account still working). | 25 |
| Idempotency | A second run of `site.yml` reports `changed=0` and `failed=0` on all five hosts. | 25 |
| Lint, syntax, and grader compatibility | `ansible-lint` on `site.yml` and `roles/linux_hardening/` and syntax checks are clean; grader paths, no-prompt execution, installed dependencies, and time limit are met. | 20 |
| **Total** |  | **200** |

---

[← Back to Labs]({{ site.baseurl }}/labs/)
