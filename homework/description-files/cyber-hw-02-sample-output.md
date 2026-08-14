---
title: "CYBER HW 2 - Sample Audit Output (Given)"
parent: Homework
nav_exclude: true
---

# Sample Audit Output
{: .no_toc }

{: .note }
This is reference output for [CYBER HW 2]({% link homework/cyber-hw-02.md %}). Before running the script against your 3 assigned target machines, run it against the **HW 2 baseline VM** and confirm your output matches this shape - same top-level keys, same `findings` entry structure, `critical_count`/`warning_count`/`info_count` actually matching the `findings` array. This confirms the script is working correctly on your system before you trust its results against a machine you don't already know the state of.

Exact `details` field contents will vary by system - what matters is that the structure and severity/category/check/message fields match this pattern.

## Example: a clean machine

```json
{
  "hostname": "example-clean",
  "audit_date": "2026-08-03",
  "critical_count": 0,
  "warning_count": 0,
  "info_count": 0,
  "findings": []
}
```

Exit code `0`. No findings at all is a valid, correct result - it does not mean the script failed to do anything.

## Example: a machine with planted issues

This example machine has an unexpected SUID binary at `/usr/local/bin/backdoor`, `/etc/notes.txt` made world-writable, `/etc/shadow` mode changed to `644`, a file left behind at `/home/deleted-user/leftover.sh` owned by a UID with no `/etc/passwd` entry, an active `NOPASSWD` sudoers entry, `sshd_config` with `PermitRootLogin yes`, and a root cron job whose script is group-writable:

```json
{
  "hostname": "example-weak",
  "audit_date": "2026-08-03",
  "critical_count": 3,
  "warning_count": 4,
  "info_count": 0,
  "findings": [
    {"severity":"WARNING","category":"filesystem","check":"unexpected_suid","message":"SUID/SGID binary not on whitelist: /usr/local/bin/backdoor","details":{"path":"/usr/local/bin/backdoor","mode":"4755","owner":"root:root"}},
    {"severity":"WARNING","category":"filesystem","check":"world_writable","message":"World-writable path outside expected locations: /etc/notes.txt","details":{"path":"/etc/notes.txt","mode":"666"}},
    {"severity":"CRITICAL","category":"filesystem","check":"bad_permissions","message":"/etc/shadow has mode 644, expected 000","details":{"path":"/etc/shadow","actual_mode":"644","expected_mode":"000"}},
    {"severity":"WARNING","category":"filesystem","check":"unowned_file","message":"File or directory owned by a UID/GID with no matching account: /home/deleted-user/leftover.sh","details":{"path":"/home/deleted-user/leftover.sh","uid":"1042","gid":"1042"}},
    {"severity":"WARNING","category":"accounts","check":"nopasswd_sudo","message":"Active NOPASSWD sudoers entry in /etc/sudoers.d/90-app: appuser ALL=(ALL) NOPASSWD: ALL","details":{"path":"/etc/sudoers.d/90-app","entry":"appuser ALL=(ALL) NOPASSWD: ALL"}},
    {"severity":"CRITICAL","category":"ssh","check":"ssh_root_login_enabled","message":"sshd_config permits direct root login: PermitRootLogin yes","details":{"directive":"PermitRootLogin yes"}},
    {"severity":"CRITICAL","category":"cron","check":"cron_writable_script","message":"Root-run scheduled command is group- or other-writable: /opt/scripts/cleanup.sh (/etc/cron.d/cleanup)","details":{"path":"/opt/scripts/cleanup.sh","source":"/etc/cron.d/cleanup","mode":"775"}}
  ]
}
```

Exit code `1` (CRITICAL findings present). This example doesn't include every possible `check` value the script can produce - see the finding-contract table on the [CYBER HW 2]({% link homework/cyber-hw-02.md %}) page for the full list across all 5 categories.

---

[← Back to CYBER HW 2]({% link homework/cyber-hw-02.md %})
