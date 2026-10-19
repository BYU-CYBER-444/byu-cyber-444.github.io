---
title: "LAB 7 - Patch Management Implementation"
parent: Labs
nav_order: 7
---

# LAB 7 - Patch Management Implementation
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Take a vulnerability scan before patching and another after, and show that the patch closed findings
- Configure `dnf-automatic` with a production-realistic security-only policy
- Establish an AIDE baseline before patching, then use AIDE to check what patching changed
- Apply security patches, handle the reboot they require, and confirm the system is running the newest kernel
- Perform an in-place major version upgrade
- Recover a host that fails to boot after an update

## Tools Required

- Four VMs, provisioned for you in your own nested environment (two on `pve2`, two on `pve3`):

  | VM | Role | Address |
  |---|---|---|
  | `lab07-patch01` | Rocky Linux 8 - patch target (Parts 1-6) | `172.19.x.22` |
  | `lab07-upgrade01` | Rocky Linux 8 - major-version upgrade target (Part 7) | `172.19.x.23` |
  | `lab07-ts01` | Rocky Linux 8 - boot-failure target (Part 8) | `172.19.x.24` |
  | `lab07-gvm01` | OpenVAS / Greenbone vulnerability scanner (Parts 1 and 6) | `172.19.x.25` |

 
-  The scanner's web interface (`https://172.19.x.25`), usual credentials.

---

## Background

Patch management is where "apply the update" meets "don't break production" and "anything that can go wrong will go wrong". A team that patches blind, with no before-and-after comparison and no way to recover from a bad updates, is one reboot away from an outage nobody can quickly undo. This lab treats patching as a full lifecycle: measure what is vulnerable, patch deliberately, verify the patch closed what it claimed to, and confirm that nothing changed beyond what the patch was supposed to touch.

---

## Part 0 - Run the Grader BEFORE You Change Anything


**The first time you run `/grade lab-7`, it does not grade you. It records the starting state of your VMs, and that record is what every later run is compared against.** Run it now, before you install, update, configure, or reboot anything, and before you run any scan. The first run awards no points and cannot be repeated.

Run `/grade lab-7` again when you have finished all the parts. That run is your grade.

If the first run happens after you have already patched or changed a VM, the comparison is meaningless and the checks that depend on it cannot earn points.
---

## Rules for the Work


- Do not stop or disable `qemu-guest-agent` on any host.
- Do not change settings that no requirement below asks for.
- The starting state of each system is not described to you. Some of it is in plain sight, and some of it you will have to find.

---

## Part 1 - Pre-Patch Vulnerability Scan (`lab07-gvm01` → `lab07-patch01`)

After the baseline run from Part 0 and before any package changes, scan `lab07-patch01` from the scanner.

- A scan target for `lab07-patch01` (`172.19.x.22`) already exists in your scanner account, with the credentials the scanner needs to log in to the VM. Create a task for it using the **Full and fast** scan configuration, run it, and let it finish. A full scan takes around 20 minutes.
- Look at the findings. Identify which ones the available updates would fix and which would not.

The scan must be **completed** (not stopped or interrupted) and must **finish before your first patch is installed**.

---

## Part 2 - Automated Security Patching (`lab07-patch01`)

`lab07-patch01` must be set up for production-realistic automated patching using `dnf-automatic`. When you finish, **all of the following are true and still true after a reboot:**

- The `dnf-automatic` package is installed.
- The timer that drives scheduled runs is enabled and active.
- Only **security** updates are applied.
- Updates are downloaded **and** applied automatically.
- The packages `nginx` and `mariadb-server` are excluded from automatic upgrades, because they need manual testing.
- Results are reported by email to `root` on the local machine, with the host name `lab07-patch01`.

The effective configuration is what counts. A setting in the wrong section, or one `dnf-automatic` does not recognize, is not in force.

---

## Reference - AIDE

AIDE (Advanced Intrusion Detection Environment) is a **file integrity checker**. You tell it which files to watch, it records what each one looks like (owner, permissions, size, timestamps, and cryptographic hashes of the contents) in a **database**, and later it compares the live filesystem against that database and reports every file that was **added, removed, or changed**. Because it uses hashes, it notices a change even if the size and timestamp were made to look the same. Tripwire is the classic tool of this kind; AIDE is the one Rocky Linux ships.

**Why it belongs in a patching lab:** a patch deliberately changes files, so afterwards you have to answer "did the patch change exactly what it was supposed to, and nothing else?" AIDE gives you the full list of what changed so you can separate the expected (package files replaced by their patched versions) from the suspicious (a modified configuration file, a new setuid program, a new scheduled job).

**How it works on Rocky Linux 8**

- It is the `aide` package, which is not installed on your VMs.
- `/etc/aide.conf` is the configuration. It defines the **rules** (named sets of attributes to compare, such as "contents and permissions" or "permissions only") and then lists directories and files with the rule that applies to each; a line starting with `!` excludes a path. The defaults already cover the places that matter for this lab, such as `/etc`, `/boot`, `/usr`, `/bin` and `/lib`. You do not need to change them.
- The databases live in `/var/lib/aide/`. AIDE **reads its baseline from `aide.db.gz`**. When you ask it to build a database it writes the result to a **different file, `aide.db.new.gz`**, and that new file does nothing until you put it in place as the baseline. A newly built database that was never moved into place is the most common reason AIDE appears to "not work".
- Each report is printed on the screen **and** appended to `/var/log/aide/aide.log`.

**Its three operations** (the exact command-line options are in `man aide`; `man aide.conf` explains the configuration):

1. **Initialize** - scan the filesystem and build a new database. This is what creates your baseline. On a small VM it takes a few minutes while it hashes everything.
2. **Check** - compare the filesystem to the baseline and report differences. A check **never changes the baseline**, and AIDE exits with a non-zero status when it finds differences, so a non-zero status after a check is a finding, not a failure.
3. **Update** - run a check and also build a new database that reflects the current state, which you could then adopt as the new baseline.

**Reading a report.** It starts with a summary of how many files were added, removed and changed, then lists them, then gives the detail (which attribute of which file changed, with the old and new values). After a full round of patches you should expect a **large** number of changes, almost all of them under the system directories where packages install files. Work from the summary down, and use the tools you know (`grep`, `less`, `sort`, `rpm -qf` to ask which package owns a file, `rpm -V` to verify a package) to group the changes. Be most suspicious of anything that is **not owned by a package**, anything in a configuration directory you did not touch, and anything new.

**Timing is the whole point.** A baseline describes the system *as it was when you built it*. If you build it after patching, it describes the patched system and can tell you nothing about what patching changed. Likewise, do not rebuild or replace the baseline after patching to make a report look clean; that destroys the evidence the lab asks you to examine.

---

## Part 3 - AIDE Baseline Before Patching (`lab07-patch01`)

Install and initialize AIDE on `lab07-patch01` **before** patching (see the AIDE reference above), so you have a clean record of the filesystem to compare against. The baseline database must be the one AIDE actually reads, and it must have been created **before the first patch is installed**. Do not rebuild it later.

---

## Part 4 - Apply the Security Patches (`lab07-patch01`)

Apply all available security updates to `lab07-patch01`. When you finish:

- No security update is still pending.
- The system does not need a reboot, and any reboot the patches required has been done.
- The system is running the newest installed kernel.

Keep everything on the host exactly as the patches left it; do not remove packages to make a result look better.

---

## Part 5 - AIDE Post-Patch Check (`lab07-patch01`)

After patching, run an AIDE check on `lab07-patch01` against the baseline from Part 3 and read the report. Decide for each reported change whether patching explains it (a package-installed binary replaced by its patched version) or whether it deserves investigation (a modified configuration file, a new setuid binary, a new scheduled job). You do not submit your reasoning, but if something unexpected appears, find out why.

The check must be run **after** the last patch is installed. AIDE records each report in its log under `/var/log/aide/`, which is how the grader sees that you ran it. Leave the baseline from Part 3 as it is.

---

## Part 6 - Post-Patch Vulnerability Rescan (`lab07-gvm01` → `lab07-patch01`)

Scan `lab07-patch01` a second time with the same settings as Part 1, after patching and after any reboot. The scan must be **completed**, and it must finish **after** your last patch is installed. Compare it with the first scan and work out which findings changed and which did not, and why.


## Part 7 - Major Version Upgrade: Rocky Linux 8 → 9 (`lab07-upgrade01`)

Patching keeps a release current, but it cannot fix something that is only available on a newer major release. This part performs that upgrade for real on `lab07-upgrade01`. This machine needed to be upgraded to **Rocky Linux 9.6**, booted into an EL9 kernel with no Rocky Linux 8 packages or kernels were left behind. AIDE must also be installed and has been initialized on the new system. 


## Part 8 - Troubleshooting a Boot Failure (`lab07-ts01`)

`lab07-ts01` was patched by its previous administrator. An update was installed, the host was rebooted, and now it will not boot. You will need to get the host running and fix it so the host boots with all installed updates. You cannot SSH to `lab07-ts01` (`172.19.x.24`) until it boots, so start at its console in the web interface of your `pve3` node.


---

## Grading

Every graded item below is checked automatically against your VMs - nothing is submitted separately.

| Item | Points |
|---|---:|
| A valid baseline was recorded before any change, and the pre-patch scan exists (Parts 0, 1) | 10 |
| `dnf-automatic` configured and active (Part 2) | 12 |
| AIDE baseline created before patching (Part 3) | 8 |
| Security patches applied, no reboot pending, newest kernel running (Part 4) | 15 |
| AIDE check run after patching (Part 5) | 5 |
| Post-patch vulnerability scan completed (Part 6) | 10 |
| Rocky Linux 9 upgrade completed, inhibitor resolved, AIDE rebuilt (Part 7) | 20 |
| `lab07-ts01` boots its newest kernel unattended (Part 8) | 20 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
