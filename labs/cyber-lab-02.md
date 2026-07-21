---
title: "CYBER LAB 2 - Linux Privilege Management & Audit Framework"
parent: Labs
nav_order: 2
---

# CYBER LAB 2 - Linux Privilege Management & Audit Framework
{: .no_toc }

**Duration:** ~3.75 hours &nbsp;·&nbsp; **Week:** Week 2 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Design and implement a least-privilege sudo policy enforced at the command level
- Configure POSIX ACLs on a multi-role web application directory structure
- Build a persistent, production-quality auditd rule set covering privilege escalation, file access, and session tracking
- Verify that each access control works as intended by attempting unauthorized actions and confirming denial
- Generate auditd summary reports and interpret the output
- Build and resize an LVM volume, use an LVM snapshot, and build a software RAID1 array

---

## Tools Required

- Ubuntu 22.04 LTS VM from Lab 1
- `auditd`, `audispd-plugins`, `auditd-tools` (`auditctl`, `ausearch`, `aureport`)
- `acl` package (`getfacl`, `setfacl`)
- `sudo`, `visudo`
- `lvm2`, `mdadm` (Part 7 - storage management)
- **Two additional 5 GB virtual disks attached to your VM** (beyond your root disk) - add these in your hypervisor before starting Part 7; they show up as `/dev/sdb` and `/dev/sdc` (confirm with `lsblk`)

```bash
sudo apt install auditd audispd-plugins acl lvm2 mdadm -y
```

---

## Procedure

### Part 1 - User Account Setup

Create three accounts with clearly defined roles:

```bash
sudo useradd -m -s /bin/bash alice    # sysadmin
sudo useradd -m -s /bin/bash bob      # developer
sudo useradd -m -s /bin/bash carol    # read-only auditor
sudo passwd alice    # set a password for each
sudo passwd bob
sudo passwd carol
```

Create the web application directory structure:

```bash
sudo mkdir -p /srv/webapp/{public,private,logs,config}
sudo chown root:root /srv/webapp
```

### Part 2 - Least-Privilege Sudo Policy

Create separate sudoers files for each role. Never edit `/etc/sudoers` directly - use `/etc/sudoers.d/`:

**`/etc/sudoers.d/10-sysadmins`:**
```
# Alice is a full sysadmin - full sudo, but requires password
# NOT NOPASSWD - no one gets passwordless sudo in production
alice ALL=(ALL:ALL) ALL
```

**`/etc/sudoers.d/20-developers`:**
```
# Bob can only restart the web application service
# Cmnd_Alias prevents sudo bash, sudo su, or sudo -s escapes
Cmnd_Alias WEBAPP = /usr/bin/systemctl restart apache2, /usr/bin/systemctl status apache2, /usr/bin/systemctl reload apache2
bob ALL=(root) NOPASSWD: WEBAPP
```

**`/etc/sudoers.d/30-auditors`:**
```
# Carol cannot sudo at all (no entry = no sudo access)
# This is implicit - document it explicitly for clarity
```

Validate all sudoers files before saving (a syntax error locks you out):

```bash
sudo visudo -c -f /etc/sudoers.d/10-sysadmins
sudo visudo -c -f /etc/sudoers.d/20-developers
```

**Verify restrictions work:**

```bash
# Test bob can restart apache2
sudo -u bob sudo /usr/bin/systemctl status apache2   # should succeed

# Test bob CANNOT run any other sudo command
sudo -u bob sudo /usr/bin/systemctl restart ssh       # should FAIL
sudo -u bob sudo bash                                  # should FAIL
sudo -u bob sudo -s                                    # should FAIL
```

Screenshot each test - both the success and the denials.

### Part 3 - POSIX ACLs on Web Application Directory

The default Unix permissions (owner/group/other) are insufficient for multi-role access. Use ACLs:

```bash
# Set default permissions on the directory
sudo chmod 750 /srv/webapp/public /srv/webapp/logs
sudo chmod 700 /srv/webapp/private /srv/webapp/config

# Alice (sysadmin): full access everywhere
sudo setfacl -R -m u:alice:rwx /srv/webapp
sudo setfacl -R -d -m u:alice:rwx /srv/webapp   # default ACL (applies to new files)

# Bob (developer): read+execute on public, write to logs, no access to config or private
sudo setfacl -m u:bob:r-x /srv/webapp/public
sudo setfacl -d -m u:bob:r-x /srv/webapp/public
sudo setfacl -m u:bob:rwx /srv/webapp/logs
sudo setfacl -d -m u:bob:rwx /srv/webapp/logs
# No ACL entry for bob on private or config = no access

# Carol (auditor): read-only on public and logs
sudo setfacl -m u:carol:r-- /srv/webapp/public
sudo setfacl -m u:carol:r-- /srv/webapp/logs

# Verify
getfacl /srv/webapp/public
getfacl /srv/webapp/private
getfacl /srv/webapp/config
```

**Verify access controls work:**

```bash
# Bob can read public:
sudo -u bob ls /srv/webapp/public    # should work
# Bob cannot read config:
sudo -u bob ls /srv/webapp/config    # should fail: Permission denied
# Carol cannot write to logs:
sudo -u bob sh -c 'echo test > /srv/webapp/logs/test.log'   # bob can write
sudo -u carol sh -c 'echo test > /srv/webapp/logs/test.log'  # carol CANNOT
```

Document each test result.

### Part 4 - Production auditd Rule Set

Temporary `auditctl` rules are lost on reboot. Write persistent rules to `/etc/audit/rules.d/99-lab2.rules`:

```bash
sudo tee /etc/audit/rules.d/99-lab2.rules << 'EOF'
## Lab 2 - Security Audit Rules
## Reload with: sudo augenrules --load

# Delete all existing rules first
-D

# Buffer size (increase if you see backlog warnings)
-b 8192

# Failure mode: 1=printk, 2=panic (use 1 in lab, 2 in production)
-f 1

## --- Privilege Escalation ---
# Monitor sudo usage (execve by root = command run as root)
-a always,exit -F arch=b64 -S execve -F uid=0 -F auid>=1000 -F auid!=unset -k priv_escalation

# Monitor su and sudo binaries directly
-w /usr/bin/sudo -p x -k sudo_usage
-w /bin/su -p x -k su_usage

## --- Identity & Authentication Files ---
-w /etc/passwd -p wa -k identity_change
-w /etc/shadow -p wa -k identity_change
-w /etc/group -p wa -k identity_change
-w /etc/sudoers -p wa -k sudoers_change
-w /etc/sudoers.d/ -p wa -k sudoers_change

## --- SSH ---
-w /etc/ssh/sshd_config -p wa -k sshd_config_change
-w /root/.ssh -p wa -k root_ssh_change

## --- Privileged Commands ---
-a always,exit -F path=/usr/bin/chown -F perm=x -F auid>=1000 -k priv_cmds
-a always,exit -F path=/usr/bin/chmod -F perm=x -F auid>=1000 -k priv_cmds
-a always,exit -F path=/usr/sbin/useradd -F perm=x -k user_mgmt
-a always,exit -F path=/usr/sbin/userdel -F perm=x -k user_mgmt
-a always,exit -F path=/usr/sbin/usermod -F perm=x -k user_mgmt

## --- Access Denied Events ---
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -k access_denied
-a always,exit -F arch=b64 -S openat -F exit=-EPERM -k access_denied

## --- Session Tracking ---
-w /var/run/utmp -p wa -k session_tracking
-w /var/log/wtmp -p wa -k session_tracking
-w /var/log/btmp -p wa -k session_tracking
EOF

# Load the rules (replaces auditctl -R)
sudo augenrules --load
sudo systemctl restart auditd

# Verify rules are active
sudo auditctl -l | head -30
```

### Part 5 - Trigger and Verify Audit Events

Generate test events and verify each appears in the audit log:

```bash
# 1. Trigger privilege escalation event
sudo useradd testuser2
sudo userdel testuser2

# 2. Trigger sudoers change event
sudo touch /etc/sudoers.d/test-file
sudo rm /etc/sudoers.d/test-file

# 3. Trigger access denied event
sudo -u carol cat /srv/webapp/config/dummy 2>/dev/null || true

# Now search for each event type
sudo ausearch -k priv_escalation -ts today | tail -20
sudo ausearch -k sudoers_change -ts today
sudo ausearch -k user_mgmt -ts today
sudo ausearch -k access_denied -ts today
```

### Part 6 - Audit Summary Reports

`aureport` generates statistical summaries from the audit log - essential for daily monitoring:

```bash
# Overall summary
sudo aureport --summary

# Authentication summary (login attempts)
sudo aureport --auth --summary

# Failed events
sudo aureport --failed

# Privileged command summary
sudo aureport --avc --summary 2>/dev/null || sudo aureport --syscall --summary | head -20

# User activity summary
sudo aureport --user --summary
```

Screenshot the `aureport --summary` and `aureport --failed` outputs.

### Part 7 - Storage Management: LVM & Software RAID

Everything so far has run on your root filesystem. Real sysadmin work also means managing the storage underneath it - adding capacity, resizing volumes without downtime, and building redundancy. Confirm your two additional disks are visible first:

```bash
lsblk
```

**LVM: build a volume, grow it, snapshot it**

```bash
# Partition /dev/sdb as an LVM physical volume
sudo parted /dev/sdb --script mklabel gpt mkpart primary 0% 100%
sudo pvcreate /dev/sdb1

# Build a volume group and a 2G logical volume inside it
sudo vgcreate vg_lab2 /dev/sdb1
sudo lvcreate -L 2G -n lv_data vg_lab2

# Format and mount it
sudo mkfs.ext4 /dev/vg_lab2/lv_data
sudo mkdir -p /mnt/lv_data
sudo mount /dev/vg_lab2/lv_data /mnt/lv_data
df -h /mnt/lv_data
```

Write a test file, then grow the volume **live, with no unmount**:

```bash
echo "before resize" | sudo tee /mnt/lv_data/testfile.txt
sudo lvextend -L +1G /dev/vg_lab2/lv_data
sudo resize2fs /dev/vg_lab2/lv_data
df -h /mnt/lv_data   # should now show ~3G
```

Take an LVM snapshot, then intentionally destroy data, then restore from the snapshot:

```bash
sudo lvcreate -L 500M -s -n lv_data_snap /dev/vg_lab2/lv_data
echo "this file should NOT survive the restore" | sudo tee /mnt/lv_data/oops.txt
sudo umount /mnt/lv_data
sudo lvconvert --merge /dev/vg_lab2/lv_data_snap
sudo mount /dev/vg_lab2/lv_data /mnt/lv_data
ls /mnt/lv_data   # oops.txt should be gone, testfile.txt should be back to "before resize"
```

**Software RAID1**

```bash
# Build a mirrored array across sdc and a second partition on sdb (or a 3rd disk if you attached one)
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdc /dev/sdb2
sudo mkfs.ext4 /dev/md0
sudo mkdir -p /mnt/raid1
sudo mount /dev/md0 /mnt/raid1
sudo mdadm --detail /dev/md0
```

Simulate a disk failure and confirm the array survives it in degraded mode:

```bash
sudo mdadm --manage /dev/md0 --fail /dev/sdc
sudo mdadm --detail /dev/md0   # should show State: clean, degraded
cat /mnt/raid1/*   # data is still readable
```

{: .note }
LVM snapshots and RAID both protect against different failure modes than a backup does - a snapshot on the same disk doesn't survive a disk failure, and a RAID array doesn't protect against `rm -rf` or ransomware, since a bad write replicates to every mirror instantly. You'll come back to this distinction directly in Week 14's backup and DR work.

---

## Submission Requirements

- `/etc/sudoers.d/10-sysadmins`, `20-developers`, `30-auditors` (with explanation of each line)
- `getfacl` output for all 4 webapp subdirectories
- Access control verification tests: at least 6 tests (3 expected-success, 3 expected-denial) with actual output
- `/etc/audit/rules.d/99-lab2.rules` (annotated - explain the purpose of each rule block)
- `auditctl -l` output confirming all rules are loaded
- `ausearch` output for each of the 4 event categories (priv_escalation, sudoers_change, user_mgmt, access_denied)
- `aureport --summary` and `aureport --failed` screenshots
- Written analysis (3-4 sentences): Looking at your aureport output, what would you investigate first if you were monitoring this system for malicious activity?
- `lsblk` and `df -h` output showing the LVM volume before and after the resize
- `mdadm --detail /dev/md0` output before and after the simulated disk failure
- Written analysis (2-3 sentences): why doesn't the LVM snapshot you took count as a backup?

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### PAM Password Controls & Audit Log Parsing Script

1. **PAM Password History Enforcement:** Configure PAM to prevent users from reusing their last 5 passwords and enforce a minimum password strength using `pam_pwquality`:
   ```bash
   sudo apt install libpam-pwquality -y
   sudo nano /etc/pam.d/common-password
   ```
   Add/modify these lines (order matters):
   ```
   password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1
   password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512 remember=5
   ```
   Test: Set alice's password 5 times trying to reuse it - the 5th reuse should be rejected. Screenshot the rejection.

2. **Audit Log Parser Script:** Write `lab02-audit-report.sh` that queries the audit log for the past 24 hours and outputs a structured JSON summary:
   ```json
   {
     "report_date": "2025-01-15",
     "privilege_escalations": 12,
     "failed_access_attempts": 3,
     "sudoers_changes": 0,
     "user_management_events": 2,
     "top_users_by_privilege_use": [
       {"user": "alice", "count": 10},
       {"user": "bob", "count": 2}
     ],
     "access_denied_details": [
       {"user": "carol", "path": "/srv/webapp/config", "time": "14:23:01"}
     ]
   }
   ```
   The script must use `ausearch` and `aureport` as data sources, parse their output with bash/awk/python, and write the JSON to `/var/log/audit-daily-report-$(date +%Y-%m-%d).json`. Create a cron job that runs it nightly at 23:55.

### Storage: RAID5 and Per-User Quotas

3. **RAID5 array:** Using 3 additional virtual disks (attach 3 more 5GB disks), build a RAID5 array (`mdadm --create /dev/md1 --level=5 --raid-devices=3 ...`). Fail one disk and confirm the array survives in degraded mode with data intact, then simulate replacing the failed disk (`mdadm --manage /dev/md1 --add /dev/sdX`) and confirm the array rebuilds. Document how long the rebuild took and what read/write performance looked like during the rebuild (`iostat` or `vmstat` output).

4. **Per-user disk quotas:** Enable quota support on `/mnt/lv_data` (`quota`, `quotatool` packages, `usrquota` mount option), set a 100MB soft limit and 150MB hard limit for `bob`, and demonstrate that `bob` gets a warning past the soft limit and is blocked entirely past the hard limit. Explain in 2-3 sentences a real scenario where per-user quotas on a shared filesystem prevent an operational incident (e.g., a runaway log file filling a shared volume for every user on the box).

---

[← Back to Labs]({{ site.baseurl }}/labs/)
