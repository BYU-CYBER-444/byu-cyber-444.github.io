# CYBER 444 — VM/Container Inventory & Resource Estimates

Instructor-only planning document. Not part of the published course site (`infra/` is excluded from the Jekyll build in `_config.yml`).

Derived from a full read-through of every lab, homework, and final-project file in both tracks (as of the current schedule: RADIUS/AAA lab and SIEM lab wired into Week 3 and Week 6, tabletop exercise as the Week 8 midterm), cross-referenced against `infra/proxmox-student-isolation/`, the existing per-student provisioning playbook. That playbook automates exactly 2 machines per student (a Rocky Linux 9 VM and a Windows Server 2022 VM) and sets no CPU/RAM/disk parameters anywhere — every resource estimate below is derived from workload analysis, not an existing spec.

**Standardization decision:** the baseline Linux template is **Rocky Linux 9**, matching the existing automation. Several Cyber-track lab pages originally described reusing "the Ubuntu 22.04 VM from Lab 1" — of those, only LAB 4 (Patch Management) was genuinely Debian/Ubuntu-specific (`unattended-upgrades` has no direct RHEL/Rocky equivalent) and has been rewritten to use `dnf-automatic`/`dnf` in place of `apt`/`unattended-upgrades`. Everything else in the Cyber track (auditd/ACLs, CIS-CAT, OpenSCAP/STIG — the Week 6 lecture already targets RHEL 9 — OpenSSL/Nginx, Docker/Graylog, docker-bench-security, SSH CA/PAM) works the same on Rocky with `dnf` instead of `apt`. IT-track VMs that explicitly call for Ubuntu 22.04 in their own lab text (the HAProxy/Nginx HA stack, Graylog, Prometheus, Ollama) are purpose-built, separate machines unrelated to the Lab 1 baseline and remain Ubuntu.

**Provisioning model (confirmed):** every machine below is provisioned by the instructor, one per student — the only shared/class-wide exception is the FreeIPA server. Every lab/homework/final-project machine beyond the 2-machine baseline currently has no automation and needs new templates/playbook work.

**VM vs. LXC:** each entry below is classified as a full VM or a lighter LXC container based on the workload — LXC where the service is simple/stateless with no nested-virtualization or foreign-OS requirement (HAProxy, keepalived, Nginx, Prometheus, RADIUS test clients, hardening targets), full VM where Docker-in-container nesting, Windows, imported forensic images, or hardware virtualization features (Credential Guard) are involved.

## Baseline (every student, both tracks) — Week 1

| Machine | Type | OS | Reasoning | vCPU / RAM / Disk | Lifecycle |
|---|---|---|---|---|---|
| Base Linux (`rocky-01-<netid>`) | VM | Rocky Linux 9 | Persists the whole semester; must survive its heaviest week (a full Graylog Docker stack — Graylog + MongoDB + OpenSearch, ~6-8GB RAM per Graylog's own sizing guidance — plus later Docker/Trivy/Grype scanning). Kept as a full VM because it runs Docker itself; nesting Docker in an unprivileged LXC container adds real reliability risk for a stack this heavy. | 4 vCPU / 8 GB RAM / 60-80 GB disk | Persists all 14-15 weeks |
| Base Windows (`winsrv-01-<netid>`) | VM (Windows can't run in LXC) | Windows Server 2022 | Becomes an AD domain controller (Cyber LAB 3) or WSUS/DC role (IT LAB 3); later hosts Credential Guard/VBS testing (Cyber LAB 7), which requires nested virtualization enabled on the Proxmox VM config | 4 vCPU / 8-12 GB RAM / 80 GB disk | Persists all 14-15 weeks |

## Shared, class-wide infrastructure (not per-student)

| Machine | Type | Purpose | vCPU / RAM / Disk | Notes |
|---|---|---|---|---|
| FreeIPA server | LXC | SSO/identity backend for Proxmox login and the LAB 3B RADIUS lab's LDAP source | 2 vCPU / 4 GB RAM / 40 GB disk | Single always-on shared instance, not multiplied per student. FreeIPA runs fine in a privileged LXC container. |

## Cyber Track — additional per-student machines

| Machine | Type | Week(s) | OS | vCPU / RAM / Disk | Lifecycle |
|---|---|---|---|---|---|
| FreeRADIUS server | LXC | Wk 3 (LAB 3B) | Rocky 9 | 1-2 / 2 GB / 15-20 GB | Lightweight service — must be a separate host from the directory server. Ephemeral, week 3 only. |
| "Network device" stand-in | LXC | Wk 3 (LAB 3B) | Rocky 9 | 1 / 1-2 GB / 10 GB | Trivial `sshd`+PAM workload; the lab explicitly allows a container. Ephemeral. |
| Ansible controller | VM | Wk 9-10 | Rocky 9 | 1-2 / 2 GB / 20 GB | Kept as a VM — HW 9's Molecule tests spin up nested Docker containers. Torn down after Lab 10. |
| Ansible target | LXC | Wk 9-10 | Rocky 9 | 2 / 2-4 GB / 20-30 GB | Just a hardening target (auditd/sysctl/SSH), no nested-virt needs. Torn down after Lab 10. |
| SSH test client | LXC | Wk 13 | Rocky 9 | 1 / 1 GB / 10 GB | Trivial, lab allows a container. Ephemeral. |
| Pre-compromised IR machine (imported `.ova`) | VM | Wk 14 | Per provided image | 2 / 2-4 GB / 20-30 GB | Must stay a full VM — imported forensic disk image, isolated (no internet), destroyed after the exercise. Not shareable between students. |
| Final Project Server 1 (Linux Identity) | VM | Wk 8-15 | Rocky 9 | 2 / 4 GB / 40 GB | New machine. Full VM for realistic CIS/STIG scanning. |
| Final Project Server 2 (Windows App) | VM (Windows) | Wk 8-15 | Windows Server 2022 | 4 / 8 GB / 80 GB | New machine. |
| Final Project Server 3 (Docker Host) | VM | Wk 8-15 | Rocky 9 | 2-4 / 4-8 GB / 60 GB | New machine. Runs Docker itself, same reasoning as the baseline Linux VM. |

**Cyber-track peak concurrency (weeks 8-15):** 2 baseline + 3 final-project machines = **5 concurrent VMs/student**, roughly 16 vCPU / 32-36 GB RAM / 300+ GB disk. The midterm tabletop exercise needs no VM or container at all — it's purely text/AI-DM adjudicated.

## IT Track — additional per-student machines

| Machine | Type | Week(s) | OS | vCPU / RAM / Disk | Lifecycle |
|---|---|---|---|---|---|
| Network services (BIND9/DHCP/NFS/chrony) | VM | Wk 2, reused Wk 7 (adds DNSSEC+DKIM) | Ubuntu 22.04 | 2 / 2 GB / 20 GB | Kept as a VM rather than LXC — NFS server (`nfsd`) kernel-module exposure inside unprivileged containers is a known friction point, not worth the savings on a machine this small. |
| Lab 3 primary DC+WSUS | VM (Windows) | Wk 3 | Windows Server 2022 | 2 / 4 GB / 60 GB | WSUS content store grows over time. |
| Lab 3 secondary DFS target | VM (Windows) | Wk 3 | Windows Server 2022 | 2 / 4 GB / 40 GB | |
| Lab 3 domain client | VM (Windows) | Wk 3 | Windows 10/11 | 2 / 4 GB / 40 GB | |
| `lb01`, `lb02` (HAProxy + keepalived) | LXC | Wk 6, reused Wk 6B/SIEM, Wk 11 | Ubuntu 22.04 | 1-2 / 1-2 GB / 10 GB each | HAProxy + keepalived/VRRP both run fine in privileged LXC with the right network capabilities. |
| `web01`, `web02` (Nginx backends) | LXC | Wk 6, reused Wk 6B/SIEM, Wk 11 | Ubuntu 22.04 | 1 / 1 GB / 10 GB each | Simple static Nginx — ideal LXC fit. |
| Graylog machine (5th, SIEM/6B) | VM | Wk 6 only | Ubuntu 22.04 + Docker | 4 / 8-12 GB / 40-50 GB | **RAM-heavy** (Graylog + MongoDB + OpenSearch via Docker Compose) — kept as a full VM for the same Docker-nesting reason as the Cyber-track Graylog machine. |
| Prometheus/Grafana/Alertmanager | LXC | Wk 11 | Ubuntu 22.04 | 2 / 4 GB / 30 GB | Installed as native binaries in the lab (not Dockerized) — no nesting concerns. 30-day TSDB retention configured, budget disk generously. |
| Ollama AI inference machine | VM | Wk 12 | Ubuntu 22.04 | 4 / **16 GB (hard minimum stated directly in the lab text)** / 30 GB | **Largest single-machine RAM ask in either track.** Kept as a full VM given its size and CPU-bound inference workload. GPU is explicitly optional (CPU inference is sufficient, just slow) — no GPU passthrough required. |
| Final Project HA LB node | LXC | Wk 8-15 | Ubuntu 22.04 | 1-2 / 2 GB / 10 GB | New machine, separate from `lb01`/`lb02`. |
| Final Project app servers ×2 | LXC | Wk 8-15 | Ubuntu 22.04 | 1 / 1-2 GB / 10 GB each | New machines, separate from `web01`/`web02`. |
| Final Project monitoring host | LXC | Wk 8-15 | Ubuntu 22.04 | 2 / 4 GB / 30 GB | New machine, separate from the Wk 11 Prometheus box. |
| Final Project cloud environment | n/a | Wk 8-15 | AWS/Azure | n/a | Not a local machine — cloud-hosted. |

Cloud-only labs (no local machine beyond a CLI workstation, which can be the baseline Rocky VM): IT LAB 9, IT LAB 10. Paper/documentation-only labs (no machine at all): IT LAB 4, IT LAB 5, IT LAB 13, IT LAB 14.

**IT-track peak concurrency, confirmed all-new final-project machines:** assuming earlier-week machines aren't proactively torn down mid-term, an IT-track student's worst-case concurrent load from Week 12 onward is: 2 baseline + `lb01`/`lb02`/`web01`/`web02` (4) + Wk 11 Prometheus host (1) + Wk 12 Ollama machine (1) + 4 new final-project machines = **12 concurrent VMs/containers**, roughly 20-24 vCPU / 55-65 GB RAM / 350-400 GB disk per IT-track student at peak (the Week 6 Graylog machine is excluded here on the assumption it's retired after that week's grading — confirm if it should persist longer). This is meaningfully higher than the Cyber track's 5-concurrent peak and is the single biggest number to size the Proxmox cluster against.

## Open follow-ups

- The existing `infra/proxmox-student-isolation/` playbook only automates the 2-machine baseline. Every other machine in this inventory (RADIUS lab, SIEM lab, Ansible controller/target, IR scenario image, Ollama, Graylog, HA stack, both final projects) currently has no provisioning automation and needs new templates and/or playbook extensions.
- Confirm whether the Week 6 Graylog machine (SIEM lab) should be torn down immediately after grading or left running — affects the IT-track peak-concurrency number above.
- Nested virtualization must be enabled on the Windows template/Proxmox config for Cyber LAB 7's Credential Guard step — already known, noted here for the provisioning build-out.
