---
title: "LAB 4 - Patch Management Implementation"
parent: Labs
nav_order: 4
---

# LAB 4 - Patch Management Implementation
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 4
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Configure `unattended-upgrades` with a production-realistic schedule and notification policy
- Run a pre-patch vulnerability scan and categorize findings by CVSS severity
- Apply patches and verify closure with a post-patch rescan
- Write a formal patch rollback procedure that could be executed by a different engineer
- Configure AIDE to detect unexpected filesystem changes introduced by patching
- Document a patch exception for a package that cannot be upgraded

---

## Tools Required

- Ubuntu 22.04 LTS VM
- `unattended-upgrades`, `apt-show-versions`
- Nessus Essentials (free account at tenable.com) OR OpenVAS Community Edition
- AIDE (`sudo apt install aide`)
- `needrestart` (`sudo apt install needrestart`)

---

## Procedure

### Part 1 - Vulnerability Inventory Before Patching

Before touching any packages, take a full inventory of what's installed and what's vulnerable:

```bash
# List all installed packages with versions
dpkg -l > /tmp/pre-patch-packages.txt

# Show packages with available upgrades
apt list --upgradable 2>/dev/null | tee /tmp/upgradable.txt

# Install apt-show-versions for detailed version tracking
sudo apt install apt-show-versions -y
apt-show-versions | grep "upgradeable" > /tmp/upgradeable-versions.txt
```

Run a **Nessus Essentials** (or OpenVAS) scan against `192.168.56.10`:
- Configure a Basic Network Scan targeting your Ubuntu VM
- After the scan completes, export the results as a CSV and HTML report
- Build a vulnerability table categorized by CVSS severity:

| CVE | CVSS Score | Severity | Package | Installed Version | Fixed Version |
|---|---|---|---|---|---|
| CVE-XXXX-XXXX | 9.8 | Critical | openssl | 3.0.2 | 3.0.2-1 |

Focus on packages with CVSS ≥ 7.0 - these are your patch priority.

### Part 2 - Configure unattended-upgrades

Install and configure for production-realistic automated patching:

```bash
sudo apt install unattended-upgrades apt-listchanges -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Edit `/etc/apt/apt.conf.d/50unattended-upgrades`:

```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};

// Do NOT auto-upgrade these (requires manual testing):
Unattended-Upgrade::Package-Blacklist {
    "nginx";
    "mysql-server";
};

// Auto-reboot at 2 AM if kernel patch requires it:
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Notify on errors:
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::MailReport "on-change";

// Remove unused kernel versions:
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
```

Edit `/etc/apt/apt.conf.d/20auto-upgrades`:
```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
```

Test a dry run: `sudo unattended-upgrade --dry-run --debug`

### Part 3 - Initialize AIDE Before Patching

AIDE (Advanced Intrusion Detection Environment) creates a cryptographic hash of the filesystem so you can detect unexpected changes. Initialize it BEFORE patching so you have a clean baseline:

```bash
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
echo "AIDE baseline created: $(date)" | sudo tee /var/log/aide-baseline.log
```

### Part 4 - Apply Patches

Apply all available security updates:

```bash
sudo apt update
sudo apt upgrade -y 2>&1 | tee /tmp/patch-output.txt
```

Check if a reboot is required:
```bash
sudo needrestart -b   # batch mode - shows what needs restart
```

If a kernel update was applied, reboot and verify the system comes back up cleanly:
```bash
sudo reboot
# After reboot:
uname -r   # confirm running new kernel
```

Take a post-patch package inventory:
```bash
dpkg -l > /tmp/post-patch-packages.txt
diff /tmp/pre-patch-packages.txt /tmp/post-patch-packages.txt | grep "^[<>]" > /tmp/patch-delta.txt
```

### Part 5 - Run AIDE Post-Patch Check

```bash
sudo aide --check 2>&1 | tee /tmp/aide-post-patch.txt
```

Review the AIDE output carefully. Classify every change detected:
- **Expected:** package-installed binary replaced by patched version → acceptable
- **Unexpected:** configuration file modified, new setuid binary, new cron job → investigate

Document each AIDE finding with a classification and justification.

### Part 6 - Post-Patch Vulnerability Rescan

Run a second Nessus/OpenVAS scan with identical settings as Part 1. Export results as CSV and HTML.

Build a delta table:

| CVE | Pre-Patch CVSS | Status After Patch |
|---|---|---|
| CVE-XXXX-XXXX | 9.8 |  Closed |
| CVE-YYYY-YYYY | 7.5 |  Closed |
| CVE-ZZZZ-ZZZZ | 8.1 |  Still Open - see exception |

For any CVE that is still open after patching:
- Document why the package cannot be upgraded (e.g., dependency conflict, blacklisted, application compatibility)
- Write a formal **Patch Exception** entry:
  - CVE, CVSS score, affected package
  - Business justification for exception
  - Compensating control in place (e.g., network segmentation, WAF rule)
  - Exception expiry date and owner

### Part 7 - Rollback Procedure

Write a formal rollback procedure (`lab-04-rollback.md`) that a different engineer could follow if a patch causes a service outage. The procedure must cover:

1. How to identify which packages were installed during the patch window (use `/var/log/apt/history.log`)
2. How to downgrade a specific package: `sudo apt install package=<old-version>`
3. How to restore from the VM snapshot taken before patching (if package downgrade fails)
4. Verification steps after rollback (service health checks, quick Nessus scan)
5. Who must be notified and how the rollback is documented in the change management system

---

## Submission Requirements

- Pre-patch Nessus/OpenVAS HTML report
- Vulnerability prioritization table (CVSS-categorized, with fixed versions identified)
- `/etc/apt/apt.conf.d/50unattended-upgrades` (annotated - explain every non-default setting)
- `patch-output.txt` - full patch run output
- `patch-delta.txt` - diff of installed packages before/after
- AIDE post-patch output with each finding classified (expected vs. unexpected)
- Post-patch Nessus/OpenVAS HTML report
- CVE delta table (what closed, what remains open)
- Patch exception documentation for any remaining CVEs
- `lab-04-rollback.md` - rollback procedure

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Patch Pipeline Automation

Write `lab-04-patch-pipeline.sh` - a script that implements a fully automated patch assessment pipeline:

1. **Pre-patch snapshot:** Use `VBoxManage snapshot` (or VMware equivalent) to programmatically take a pre-patch snapshot named `pre-patch-$(date +%Y%m%d)` before any changes are made
2. **Vulnerability export:** Use the OpenVAS/Nessus API (or `apt-get --simulate upgrade` output) to enumerate packages with security fixes available and output structured JSON: `[{"package": "openssl", "installed": "3.0.2", "available": "3.0.2-1", "cve": ["CVE-2024-XXXX"], "cvss": 9.8}]`
3. **Patch prioritization:** Sort the JSON output by CVSS score descending and apply only packages with CVSS ≥ 7.0 in the first pass
4. **AIDE pre/post comparison:** Run `aide --init` before, `apt upgrade` for the selected packages, then `aide --check` after, and parse the output to separate expected changes (updated package binaries) from unexpected changes (config files, new binaries not from the package)
5. **Report generation:** Write a JSON patch report to `/var/log/patch-pipeline/YYYY-MM-DD.json` with: packages patched, CVEs closed, AIDE unexpected findings, total duration

The script must be idempotent - running it a second time the same day should detect there's nothing new to patch and exit cleanly. Submit the script and a screenshot of it running end-to-end.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
