---
title: "LAB 8 — Capstone Environment Setup"
parent: Labs
nav_order: 8
---

# LAB 8 — Capstone Environment Setup
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 8
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Design and document the capstone infrastructure topology
- Deploy all 3 required VMs in an isolated network
- Run baseline CIS-CAT scans on all servers
- Define per-server compliance targets and project milestones

---

## Tools Required

- VMware/VirtualBox
- draw.io or Visio (free at diagrams.net)
- CIS-CAT Pro
- Ubuntu 22.04 + Windows Server 2022

---

## Procedure


1. Define your capstone scope — minimum 3 servers:
   - **Server 1**: Linux Identity Server (Ubuntu 22.04 — LDAP/SSSD, SSH CA)
   - **Server 2**: Windows App Server (Windows Server 2022 — AD or standalone)
   - **Server 3**: Ubuntu Web/Docker Host (Ubuntu 22.04 — Docker or Nginx)
2. Create a network topology diagram (draw.io) showing: server names, IPs, roles, network segments, firewall zones
3. Deploy all 3 VMs in an isolated host-only network
4. Confirm SSH and RDP connectivity between systems
5. Run initial CIS-CAT scans on all 3 servers — record baseline scores
6. Define compliance targets: specify CIS Benchmark level and STIGs for each server
7. Create a project tracking spreadsheet with milestones and target scores


---

## Submission Requirements

Capstone Setup Package: network topology diagram (PNG/PDF), VM inventory table, initial CIS-CAT scores for all 3 servers, compliance target definition table, project milestone schedule.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
