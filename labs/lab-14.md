---
title: "LAB 14 — Incident Response Scenario"
parent: Labs
nav_order: 14
---

# LAB 14 — Incident Response Scenario
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 14
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Identify all IOCs on a pre-compromised Ubuntu VM
- Preserve volatile evidence (processes, network state, memory artifacts)
- Contain and eradicate the compromise
- Recover from a clean snapshot and document a full timeline

---

## Tools Required

- Pre-compromised Ubuntu VM `.ova` (provided on LMS)
- Standard Linux CLI tools
- LiME kernel module (optional)
- AIDE

---

## Procedure


{: .warning }
Do not share the compromised VM with anyone outside this class. It contains intentional malware artifacts for educational purposes only.

1. **Import** the pre-compromised Ubuntu VM from the LMS `.ova` file
2. **IDENTIFY** — run these commands and document all IOCs found:
   ```bash
   ps auxf
   ss -tlnp
   crontab -l
   cat /etc/passwd
   find /tmp -type f
   ls -la ~/.ssh/authorized_keys
   ```
3. **PRESERVE** — capture volatile evidence:
   ```bash
   ps auxf > /mnt/evidence/processes.txt
   ss -tlnp > /mnt/evidence/netstat.txt
   cat /proc/[suspicious-pid]/maps > /mnt/evidence/maps.txt
   ```
4. **CONTAIN** — kill the malicious process, remove the cron backdoor, remove the unauthorized SSH key
5. **ERADICATE** — audit all cron jobs (`crontab -l -u root`), check `/etc/rc.local`, check all `authorized_keys` files
6. **RECOVER** — revert to the baseline snapshot, verify system integrity with AIDE
7. Document a complete incident timeline with timestamps


---

## Submission Requirements

Lab Report (Post-Incident Report template): complete IOC table, evidence preservation checklist with timestamps, containment/eradication actions log, recovery verification screenshot, full attack timeline narrative.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
