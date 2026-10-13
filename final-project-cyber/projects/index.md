---
title: Cyber Project Options
parent: Final Project (Cyber Track)
has_children: true
nav_order: 4
---

# Cyber Track - Project Options
{: .no_toc }

Pick **one** of the six options below. Each option has its own scope, deliverables, and grading rubrics, but all six share the same schedule, submission process, and point structure (see [Final Project (Cyber Track)]({% link final-project-cyber/index.md %})).

---

## The Options

| # | Project | You build | Best if you enjoyed |
|---|---|---|---|
| C1 | [Hardened Infrastructure Build]({% link final-project-cyber/projects/c1-hardened-infrastructure.md %}) | Three servers (Linux identity, Windows app, Linux web/Docker) hardened to CIS Level 2 and DISA STIG, with automation and a System Security Plan | Labs 2-4, 8, 10-11 |
| C2 | [Zero-Trust Identity and PKI Platform]({% link final-project-cyber/projects/c2-zero-trust-identity-pki.md %}) | A private CA hierarchy, SSH CA, MFA, and mutual TLS between services, with automated issue, renew, and revoke | Labs 5-6 |
| C3 | [Detection Engineering / SOC-in-a-Box]({% link final-project-cyber/projects/c3-detection-engineering-soc.md %}) | A logging and SIEM pipeline plus an isolated attacker host; you write detections mapped to MITRE ATT&CK and respond to live attacks | Lab 12, HW 12 |
| C4 | [Compliance-as-Code Pipeline]({% link final-project-cyber/projects/c4-compliance-as-code.md %}) | Ansible hardening roles run through a CI pipeline that scans, gates, detects drift, and auto-remediates | Labs 10-11, HW 11 |
| C5 | [Secure Container Platform]({% link final-project-cyber/projects/c5-secure-container-platform.md %}) | A hardened container host with scanned and signed images, a TLS reverse proxy, least-privilege containers, and central logging | Lab 14 |
| C6 | [Patch and Vulnerability Management Program]({% link final-project-cyber/projects/c6-patch-vulnerability-management.md %}) | A scanner, patch automation, risk-ranked remediation, SLAs, and metrics, shown reducing risk on a deliberately vulnerable fleet | Labs 7-8 |

---

## Workload and Risk at a Glance

All six are sized to be completed in Weeks 9-15 and the scope is the same whether you work alone or in a pair. They differ in where the effort and the risk sit.

| # | Where most of the effort goes | Main risk | Lab resources to confirm in Week 9 |
|---|---|---|---|
| C1 | Control-by-control automation and the SSP | Scan scores plateau below target; Windows VM is RAM-heavy | One Windows Server VM |
| C2 | Getting every trust chain and revocation path right | Small mistakes in a trust chain break everything downstream | One Windows Server VM plus small Linux VMs or LXCs |
| C3 | Writing and tuning detections | SIEM stack needs enough RAM to run reliably | SIEM host and a Windows Server VM; confirm before choosing |
| C4 | CI pipeline and drift handling | Pipeline must reach your lab network (use a self-hosted runner) | One Windows Server VM, one Linux VM, plus the Git/CI service |
| C5 | Hardening plus the image supply chain | Local registry and scanner add RAM and disk | One Windows Server VM plus small Linux VMs |
| C6 | Scanner setup and a repeatable patch cycle | Scanner feed downloads are slow; start early | Scanner VM and a Windows Server VM; confirm before choosing |

{: .important }
The Windows Server VM is the heaviest part of every option now. Check resource needs with the instructor in Week 9 lab before you commit. Your nested Proxmox environment has a fixed RAM budget, and an option that does not fit will cost you more time than any other mistake.

---

## Rules That Apply to Every Option

- **Windows and Linux.** Every project must include at least one Linux system and at least one Windows Server system, and the Windows system must do real work in the project, not just exist. Both platforms must be covered by your automation, appear in your architecture diagram and documentation, and be shown in your recorded demos. Each option page says what its Windows system does.
- **Isolation.** Everything you build and every test you run stays inside your own lab network. Do not scan, attack, or probe class infrastructure, other students' environments, or anything outside the lab.
- **Reproducibility.** Your automation must rebuild the environment from your portfolio repo using only the README. Manual one-off changes that are not captured in code lose points on every rubric.
- **Evidence.** Claims need output: scan reports, command output, logs, screenshots with timestamps. "It works" without evidence earns no credit.
- **Changing options.** Switching options after your proposal passes requires instructor approval and a new proposal PDF.
