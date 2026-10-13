---
title: "LAB 6 - Acme Acceptable-Use Policy Compliance"
parent: Labs
nav_order: 6
---

# LAB 6 - Acme Acceptable-Use Policy Compliance
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Bring three Linux systems into compliance with the Acme Corp Acceptable Use Policy
- Verify that each required setting is effective on the running system and remains in force after reloads and reboot

## Tools Required

- Three Rocky Linux 9 VMs, provisioned for you in your own nested environment:

  | VM | Role | Address |
  |---|---|---|
  | `lab06-web01` | web server | `172.19.x.19` |
  | `lab06-db01` | database server | `172.19.x.20` |
  | `lab06-app01` | application workstation (GNOME desktop) | `172.19.x.21` |


- `lab06-app01` has a GNOME desktop; use the hypervisor console for its desktop and SSH for its shell
- Log in with your own NetID account. 

These VMs represent Acme Corp’s isolated, non-production Security Validation Lab. Treat their accounts and systems as company resources covered by the policy; use synthetic data only.

## Policy Source

The completed [Acme Corp Acceptable Use Policy]({{ site.baseurl }}/labs/acceptable-use-policy-acme-corp.md) is the authoritative source for this exercise. Every requirement below is stated in the policy; this lab restates each one as an exact end state so there is nothing to guess. The sections that govern the lab are:

| Lab Check | Governing policy section |
|---|---|
| 1 | Access Management (and Authentication/Passwords, for any password you set) |
| 2 | Hardware and Software (the Security Validation Lab Software Register) |
| 3 | Internet |
| 4 | Removable Media |
| 5 | Clear Desk/Clear Screen |

This is a policy-compliance exercise: put each system into the state the policy requires, then prove the state is effective. Do not write or revise a policy. You do not need to record or submit the systems’ initial state, and no commands are provided: choosing the right tools is part of the exercise.

---

## Rules for the Work

- Keep all three systems reachable. You must still be able to log in over SSH with your NetID account, and the staff account `ta` must keep working.
- Do not change settings that no requirement below asks for.
- Do not delete accounts, home directories, or files that belong to other users.
- Do not stop or disable `qemu-guest-agent` on any host.
- The starting state of each system is not described to you and differs from host to host and from student to student. Some of it is in plain sight, and some of it you will have to find.

---

## Part 1 - Required End State

For every check, **the effective state of the running system is what counts**. A configuration file that says the right thing does not pass if something else overrides it or if it is not in force. Other configuration already on a system may conflict with a requirement; where it does, you must resolve the conflict.

### Lab Check 1 - Access Management: individual accounts (all three hosts)

On each host, `/etc/acme/roster.txt` is the authoritative list of authorized users for that host. It holds one username per line and is different on each host. The roster always includes the staff account `ta` and your own NetID.

**Every user on the roster must have exactly one account that:**

- exists, with a user ID of 1000 or greater;
- has a login shell that is not `/sbin/nologin` or `/bin/false`;
- has a usable password that is not locked.

An account that is missing must be created as an ordinary individual account, with a home directory. An account that exists but has a disabled shell, a locked password, or a password field with no password behind it must be repaired. Any password you set must meet the policy’s Authentication/Passwords section: at least 14 characters, and it must not contain the account name.

**Every other account with a user ID of 1000 or greater must:**

- have `/sbin/nologin` as its login shell, **and**
- have its password locked.

Do not delete these accounts. System accounts below user ID 1000 and the built-in `nobody` account are out of scope.


### Lab Check 2 - Hardware and Software: approved software (all three hosts)

The policy’s Security Validation Lab Software Register prohibits these packages on every Security Validation Lab system. **None of them may be installed on any of the three hosts:**

| Package | What it is |
|---|---|
| `nmap` | port scanner |
| `john` | password cracker |
| `hydra` | network password cracker |
| `wireshark-cli` | packet sniffer |
| `telnet-server` | cleartext remote-access service |
| `transmission-cli` | peer-to-peer file sharing |
| `transmission-gtk` | peer-to-peer file sharing |


On `lab06-app01` only, Firefox (package `firefox`) is the only approved web browser:

- `firefox` **must be installed** and no other browser. It may not be installed when you start.


### Lab Check 3 - Internet: Firefox site policy (`lab06-app01`)

Firefox must be managed through its enterprise policy file at exactly this path:

`/etc/firefox/policies/policies.json`

The file must be **valid JSON** and must contain a `policies` object with a `WebsiteFilter` object whose `Block` list includes all three of these patterns, written exactly as shown:

```json
{
  "policies": {
    "WebsiteFilter": {
      "Block": [
        "*://*.facebook.com/*",
        "*://*.tiktok.com/*",
        "*://*.netflix.com/*"
      ]
    }
  }
}
```

A file may already exist at that path. Whatever you leave there must satisfy the above.

Firefox must also actually start on `lab06-app01`.


### Lab Check 4 - Removable Media (`lab06-app01`)

A USB storage device is attached to `lab06-app01`. The policy does not approve removable mass storage in the Security Validation Lab, so all of the following must be true:

1. **Loading is blocked.** The `usb-storage` kernel driver is configured so that any attempt to load it fails. Blocking only automatic loading is not enough: an explicit request to load the driver must also fail. The configuration must be persistent, and it must hold from the very start of boot: the early-boot image has its own set of drivers and does not read the installed system’s module configuration, so a rule that exists only on the installed system can be bypassed while the machine is still starting up.
2. **It is not loaded now.** The driver is not loaded in the running kernel.
3. **No USB storage is present or mounted.** No USB mass-storage block device is available to the system, and nothing is mounted from one.
4. **Automount is off for everyone.** The desktop settings `automount` and `automount-open` are both effectively `false` for every user, and both are **locked** so that a user cannot change them. See the desktop settings table below.


### Lab Check 5 - Clear Desk/Clear Screen (`lab06-app01`)

The desktop must lock itself after five minutes idle, with no grace period, and users must not be able to change this. The settings are system-wide (for every user) and locked.

### Desktop settings required for Lab Checks 4 and 5

These five GNOME settings are the complete requirement for Lab Checks 4 and 5. For each, the **effective value** for an ordinary user must be the one shown, and the setting must be **locked at the system level**.

| Setting (dconf path) | Required effective value | Lab Check |
|---|---|---|
| `/org/gnome/desktop/media-handling/automount` | `false` | 4 |
| `/org/gnome/desktop/media-handling/automount-open` | `false` | 4 |
| `/org/gnome/desktop/session/idle-delay` | `300` seconds (`uint32 300`) | 5 |
| `/org/gnome/desktop/screensaver/lock-enabled` | `true` | 5 |
| `/org/gnome/desktop/screensaver/lock-delay` | `0` seconds (`uint32 0`) | 5 |

System-wide dconf settings and locks for this machine belong in the system database named `local`, which the user profile already reads. dconf only reads its compiled database, so changes to the source files do not take effect until the database is rebuilt. A value is only effective if no other source supplies a different value that wins over yours.


### System health requirements

These must be true when you finish, and they are checked as part of the live and after-reboot checks above:

- `lab06-app01` boots to the graphical target, its display manager (GDM) is running, and Firefox starts.
- `qemu-guest-agent` is running on all three hosts.
- All three hosts are powered on and reachable.

---

## Part 2 - Verify the Enforced State

Your changes must be **effective** and must **persist**. For each Lab Check, confirm the real state of the system with the system’s own tools, not just the files you edited:

- **Lab Check 1:** read each host’s roster, then check every account with a user ID of 1000 or greater against it: whether it exists, its login shell, and its password status. Check the unlisted accounts as carefully as the listed ones.
- **Lab Check 2:** query the package database for each of the seven register packages on each host, and for the browsers on `lab06-app01`.
- **Lab Check 3:** confirm the policy file is valid JSON with all three patterns, then open Firefox’s `about:policies` page on `lab06-app01` and confirm the policy is active.
- **Lab Check 4:** ask the system what happens when the driver is asked to load, check whether the driver is currently loaded, check whether any USB storage device or mount remains, and read the two desktop settings. After the reboot, if the driver is loaded again, find out **when** during boot it was loaded and why the configuration you wrote did not apply at that point.
- **Lab Check 5:** read the three desktop settings as an ordinary user would see them.
- **Locks:** for all five desktop settings, confirm that a user is not allowed to change the value, not merely that the value is right.

If a check does not show the required state, work out **why** before changing anything else: something else on the system may be overriding or conflicting with what you set. Fix the cause.

**Reload and restart where needed.** dconf must be rebuilt after changes to its files, and Firefox must be restarted after changes to its policy file. Then verify the effective values again.

**Then reboot all three VMs and repeat every check.** Confirm that `lab06-app01` comes back at the graphical target with GDM running and that Firefox still starts. Leave all VMs powered on and reachable for grading.

---


## Grading

Every graded item below is checked automatically against your VMs. A host that is unreachable during grading, or that does not come back from the grader’s reboot, fails the checks that depend on it. `qemu-guest-agent` must also be running on all three hosts; this is reported in your results but carries no points of its own.

| Item | Points |
|---|---:|
| `Lab Check 1` individual account and roster requirements, all three hosts | 25 |
| `Lab Check 2` prohibited packages absent on all hosts and approved browser state on `lab06-app01` | 20 |
| `Lab Check 3` Firefox policy file valid with all three required patterns, and Firefox starts, on `lab06-app01` | 25 |
| `Lab Check 4` removable-storage policy effective and persistent on `lab06-app01` | 15 |
| `Lab Check 5` clear-screen settings effective, locked, and persistent on `lab06-app01` | 15 |
| **Total** | **100** |



[← Back to Labs]({{ site.baseurl }}/labs/)
