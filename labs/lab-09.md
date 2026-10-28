---
title: "LAB 9 - CIS Benchmark Assessment & Targeted Remediation"
parent: Labs
nav_order: 9
---

# LAB 9 - CIS Benchmark Assessment & Targeted Remediation
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Purpose

Assess a Rocky Linux 9 server against the CIS Level 1 Server profile, investigate ten selected findings, remediate them, and compare a focused before-and-after assessment. The selected controls cover login notices, system cryptography, temporary storage, boot protection, scheduled-task access, unused services, persistent logs, and PAM authentication policy.

The full profile will likely report other findings. You are responsible for the ten areas listed here; you are not expected to make the entire profile pass.


## Part 1 - Record the baseline

Before changing the VM, run the full CIS Level 1 Server assessment. Save the machine-readable and HTML reports in your home directory as:

- `lab09-baseline.xml`
- `lab09-baseline.html`

An OpenSCAP exit code of `2` is expected when the scan finds failures. Use the selected-rule descriptions below to understand the checks; you do not need to search the HTML report for their definitions. Record which selected checks fail in the baseline. The HTML report is still useful for seeing the host-specific evidence and any finding-specific guidance. Some related checks, such as `/tmp` mount options, may be reported as not applicable until the mount exists.

## Part 2 - Understand the selected rules

The quoted phrases below are short excerpts from the selected SCAP rule titles. The explanations state the full requirement being assessed for this lab in plain language. The rule IDs match the rules used by the grader. Values shown are this lab's target settings.


### 1. Local and remote login banners

**Rule title excerpt:** “Login Banner”

**Selected rules:** `banner_etc_issue_cis`, `banner_etc_issue_net_cis`

Configure both `/etc/issue` (local console) and `/etc/issue.net` (remote login) with an approved notice that access is restricted to authorized users and activity may be monitored. The CIS profile's suggested wording is `Authorized users only. All activity may be monitored and reported.`

**Verify:** Inspect both files and confirm each contains the intended notice.

### 2. System-wide cryptographic policy

**Rule title excerpt:** “Crypto Policy”

**Selected rule:** `configure_custom_crypto_policy_cis`

Use custom crypto-policy modules and activate them as part of the system-wide policy. The selected policy must disable CBC ciphers for SSH, the listed weak SSH ciphers and MACs, and weak MACs globally. Create these module files in `/etc/crypto-policies/policies/modules/`, using exactly these names and contents: `NO-SSHCBC.pmod` contains `cipher@SSH = -*-CBC`; `NO-SSHWEAKCIPHERS.pmod` contains `cipher@SSH = -3DES-CBC -AES-128-CBC -AES-192-CBC -AES-256-CBC -CHACHA20-POLY1305`; `NO-SSHWEAKMACS.pmod` contains `mac@SSH = -HMAC-MD5* -UMAC-64* -UMAC-128*`; and `NO-WEAKMAC.pmod` contains `mac = -*-128*`. Where the installed RPM crypto backend supports it (that is, when `/etc/crypto-policies/back-ends/rpm-sequoia.config` exists), also disable SHA-1 for RPM verification with a fifth module, `NO-RPMSHA1.pmod`, containing `hash@rpm = -SHA1`. The rule checks for these exact file names and lines. A custom module file by itself is not enough: the modules must be included in the active policy.

**Verify:** Inspect the active policy and its custom modules. Confirm the active policy names the modules and the effective SSH cipher/MAC list excludes the prohibited algorithms.

### 3. Separate `/tmp` mount and mount options

**Rule title excerpt:** “Separate Partition”

**Selected rules:** `partition_for_tmp`, `mount_option_tmp_nodev`, `mount_option_tmp_noexec`, `mount_option_tmp_nosuid`

Mount `/tmp` separately from the root filesystem and make the mount persistent. A dedicated `tmpfs` mount is acceptable for this lab. The active mount and its persistent configuration must include all three options:

- `nodev` prevents device files on the temporary filesystem from being treated as devices.
- `noexec` prevents programs stored there from being executed directly.
- `nosuid` prevents set-user-ID and set-group-ID privilege behavior there.

The mount-option checks can be not applicable before `/tmp` is a separate mount.

### 4. GRUB boot password

**Rule title excerpt:** “Boot Loader”

**Selected rule:** `grub2_password`

Configure a GRUB superuser and password so a person with console or physical access cannot freely edit boot settings or select an alternate boot path. The system must store a protected password hash, not a plaintext password. Keep the password private and out of shell history, scripts, and shared files.

**Verify:** Confirm the protected GRUB user configuration exists and that OpenSCAP reports the rule passing. 

### 5. Cron access and file permissions

**Rule title excerpt:** “cron.allow”

**Selected rules:** `file_cron_allow_exists`, `file_cron_deny_not_exist`, `file_permissions_cron_d`, `file_permissions_cron_daily`, `file_permissions_cron_hourly`, `file_permissions_cron_monthly`, `file_permissions_cron_weekly`, `file_permissions_crontab`

Use an allow-list for ordinary users' crontabs: `/etc/cron.allow` must exist and `/etc/cron.deny` must be absent. The selected ownership and modes are below. The rules check that `/etc/cron.allow` exists and that the directories and `/etc/crontab` are at these modes or stricter; `root:root` and `0640` on `cron.allow` follow the CIS recommendation.

| Path | Owner and group | Mode |
|---|---|---:|
| `/etc/cron.allow` | `root:root` | `0640` |
| `/etc/cron.d`, `/etc/cron.daily`, `/etc/cron.hourly`, `/etc/cron.monthly`, `/etc/cron.weekly` | `root:root` | `0700` |
| `/etc/crontab` | `root:root` | `0600` |

These permissions prevent unprivileged users from changing scheduled jobs or cron configuration. Root remains able to administer cron.

**Verify:** Check the two allow/deny file conditions, then inspect ownership and modes for every listed path.

### 6. NFS and RPC services

**Rule title excerpt:** “rpcbind”

**Selected rules:** `service_nfs_disabled`, `service_rpcbind_disabled`

If this VM is not providing network file shares or RPC services, stop and **mask** `nfs-server` and `rpcbind` (or remove their packages). The rules pass only when each unit is inactive and masked; disabling alone does not satisfy them. `rpcbind` advertises RPC service ports; NFS uses it to support network file sharing. Do not disable either service on a host that depends on it.

**Verify:** Confirm `nfs-server` and `rpcbind` are inactive and masked. Check both the service and socket units when present.

### 7. Bluetooth service

**Rule title excerpt:** “Bluetooth”

**Selected rule:** `service_bluetooth_disabled`

This server does not need Bluetooth. Stop and **mask** the Bluetooth service (or remove the `bluez` package). The rule passes only when `bluetooth.service` is inactive and masked; disabling alone does not satisfy it.

**Verify:** Confirm `bluetooth.service` is inactive and masked.

### 8. Persistent and compressed system journal

**Rule title excerpt:** “persistent disk”

**Selected rules:** `journald_storage`, `journald_compress`

Configure `systemd-journald` to retain journal data on disk across reboot and to compress journal files. The effective settings are `Storage=persistent` and `Compress=yes`. Restart or reload the service as required for the settings to take effect; a configuration file that has not been applied is not sufficient.

**Verify:** Inspect the effective journald configuration and confirm the journal is using persistent storage.

### 9. PAM account lockout

**Rule title excerpt:** “Lock Accounts”

**Selected rules:** `enable_authselect`, `accounts_password_pam_modules_in_authselect_profile`, `account_password_pam_faillock_password_auth`, `account_password_pam_faillock_system_auth`, `accounts_passwords_pam_faillock_deny`, `accounts_passwords_pam_faillock_unlock_time`

Use a valid `authselect` profile to manage the PAM configuration. The active profile must include `pam_faillock.so`, `pam_pwquality.so`, `pam_pwhistory.so`, and `pam_unix.so` in both `system-auth` and `password-auth`. The faillock module must be present in the pre-authentication stack of both PAM files. Configure failed-login lockout with `deny = 5` and `unlock_time = 900` seconds; use `fail_interval = 900` seconds for the selected lab policy.

The lockout control limits repeated password guessing. Incorrect PAM ordering or editing generated `/etc/pam.d` files directly can break login or be overwritten. Keep your current SSH session open and confirm another login works after applying changes.

**Verify:** Run `authselect check`; inspect the active profile and the generated PAM stacks for the modules and pre-authentication entries; inspect `/etc/security/faillock.conf` for the values above.

### 10. PAM password quality and history

**Rule title excerpt:** “Password Reuse”

**Selected rules:** `accounts_password_pam_dictcheck`, `accounts_password_pam_difok`, `accounts_password_pam_minlen`, `accounts_password_pam_minclass`, `accounts_password_pam_maxrepeat`, `accounts_password_pam_pwhistory_enforce_for_root`, `accounts_password_pam_pwhistory_remember_password_auth`, `accounts_password_pam_pwhistory_remember_system_auth`

Configure `pam_pwquality` with these selected requirements:

| Setting | Target | Meaning |
|---|---:|---|
| `dictcheck` | `1` | Reject passwords containing dictionary words. |
| `difok` | `2` | Require at least two characters to differ from the old password. |
| `minlen` | `14` | Require at least 14 characters. |
| `minclass` | `4` | Require characters from all four classes: uppercase, lowercase, digits, and symbols. |
| `maxrepeat` | `3` | Reject runs of more than three identical consecutive characters. |

Enable password history and enforce it for root. The CIS profile requires `remember=24` or higher, so the grader checks `remember=24` on the active `pam_pwhistory.so` entries in both `password-auth` and `system-auth`. Set it on the PAM entries only: do not also put `remember` in `/etc/security/pwhistory.conf`, because the OpenSCAP check fails when the value appears in both places; verify the generated files after applying the authselect profile.

**Verify:** Inspect `/etc/security/pwquality.conf` and `/etc/security/pwhistory.conf`, then inspect both active PAM stacks. Confirm the history option is present on each `pam_pwhistory.so` line and that the corresponding OpenSCAP checks pass.

## Part 3 - Remediate the ten areas

Use the requirements and verification evidence in Part 2 to plan and apply your changes. For each area, record the baseline result, the setting or service you changed, the evidence that the effective state is correct, and the post-remediation result in your own notes. Choose supported system tools and verify the live state; a file edit alone does not prove that a policy or service is active.

Re-run the relevant OpenSCAP checks as you work. If a finding remains, compare its expected state above with the active system state and the exact file or service state reported by OpenSCAP. In particular, check both authselect profile templates and generated PAM files for password-history settings.

## Part 4 - Capture the post-remediation assessment

After the ten areas are configured, run the same full CIS profile again. Save the results as:

- `~/lab09-post-remediation.xml`
- `~/lab09-post-remediation.html`

Review the post-remediation report. Correct selected findings that remain, then save a new post-remediation report. The grader checks that the ten selected areas changed from their baseline state to passing in the post report and in a fresh scan of the VM. Other CIS findings may remain; they are outside this lab's grading scope.

## Required evidence and grading

Nothing is uploaded. Keep the two XML and two HTML reports in your home directory and leave the remediations active on the VM.

| Part | What is checked | Points |
|---|---|---:|
| 1 | Valid baseline assessment using the required profile. | 10 |
| 2-3 | Ten selected areas change from their baseline findings to passing in a fresh scan (7 points each). | 70 |
| 4 | Valid post-remediation assessment, created after the baseline; all selected checks pass in the saved report. | 20 |
| | **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
