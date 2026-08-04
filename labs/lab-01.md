---
title: "LAB 1 - Proxmox Orientation"
parent: Labs
nav_order: 1
---

# LAB 1 - Proxmox Orientation
{: .no_toc }

**Duration:** ~3.5 hours &nbsp;·&nbsp; **Week:** Week 1 &nbsp;·&nbsp; **Track:** Both
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Establish secure remote access to your assigned Proxmox environment over WireGuard
- Understand Proxmox VE cluster architecture and why quorum requires a minimum of 3 nodes
- Join your 3 assigned nodes into a single Proxmox cluster
- Deploy Ceph as a distributed, replicated storage backend across the cluster
- Apply OS updates safely on a live cluster using a rolling, one-node-at-a-time procedure
- Configure the foundational settings (admin user, storage, firewall baseline) every later lab this semester will depend on

---

## Tools Required

- 3 Proxmox VE nodes assigned to you, each with at least one additional raw (unpartitioned) disk beyond the OS disk for Ceph
- WireGuard client for your OS (`wireguard-tools` on Linux, the WireGuard app on Windows/macOS)
- The WireGuard profile (`.conf`) and Proxmox credentials emailed to you before this lab
- SSH client
- Web browser

---

## Background

Proxmox VE clusters use **Corosync** for cluster communication and a **quorum** model to decide whether the cluster is in a safe state to operate: a majority of nodes (more than half) must be reachable and agreeing, or the cluster refuses risky operations to avoid split-brain. With exactly 3 nodes, you can lose any *one* node and still hold quorum (2 of 3); losing 2 nodes drops you below a majority and the surviving node alone will not run HA operations. This is also exactly why **Ceph** - the distributed storage layer you'll deploy on top of this cluster - defaults to a replication factor of 3 (`size 3, min_size 2`): the storage layer and the cluster layer are both built around the same "tolerate one failure, still function" assumption, which is the whole reason 3 nodes is the practical minimum for a real Proxmox+Ceph deployment rather than an arbitrary number.

Your Proxmox nodes are not exposed on the public internet - the only way in is through a WireGuard tunnel. This mirrors real production practice: management interfaces for hypervisors and storage clusters should never be directly internet-facing, and a VPN tunnel is the access-control boundary, not the Proxmox login page itself.

Everything you build in this lab - the cluster, the Ceph pool, the admin user, the Rocky Linux template - is the foundation the rest of this semester's labs will run on top of. Get it right now and you won't be fighting infrastructure problems in Week 5.

---

## Procedure

### Part 1 - Secure Remote Access via WireGuard

1. Locate the email from containing your WireGuard profile (`.conf` file) and your 3 nodes' Proxmox credentials and IP addresses. If you can't find it, ask before proceeding - do not attempt to reach these nodes any other way.
1. Install the WireGuard client for your OS
1. Import your profile and bring the tunnel up
1. Open `https://<node1-internal-ip>:8006` in your browser (accept the self-signed certificate warning) and confirm you can log in with the credentials you were given.

---

### Part 2 - Initial Node Preparation

Confirm all 3 nodes' clocks agree - Corosync and Ceph are both clock-sensitive, and a node with drifted time can behave unpredictably once clustered:

```bash
timedatectl status   # confirm "System clock synchronized: yes" on all 3 nodes
```

Don't run the full package upgrade yet - that's Part 6, done deliberately *after* the cluster and Ceph are live, using a rolling procedure that won't be safe to skip.

---

### Part 3 - Building the Proxmox Cluster

On **node 1**:

```bash
pvecm create lab-cluster
pvecm status   # confirm 1 node, quorate
```

On **node 2** and **node 3**:

```bash
pvecm add <node1-ip>
```

Back on any node, confirm all 3 have joined:

```bash
pvecm status          # expect: Quorate, 3 nodes, 3 votes
corosync-cfgtool -s    # confirm all links are "connected"
```

Log into the web UI and confirm all 3 nodes appear under **Datacenter** with a green status icon.

---

### Part 4 - Deploying Ceph on the Cluster

**4.1 Initialize Ceph**

On node 1:

```bash
pveceph install
pveceph init --network <your-cluster-subnet>/24
```

**4.2 Create monitors and managers on all 3 nodes**

Ceph monitors need an odd number for their own quorum logic - 3 matches your node count exactly. Repeat on each node (via CLI or Datacenter → Ceph → Monitor/Manager → Create in the web UI):

```bash
pveceph mon create
pveceph mgr create
```

**4.3 Add OSDs**

On each node, identify the additional raw disk you were assigned (not the OS disk):

```bash
lsblk
pveceph osd create /dev/sdX   # replace with your actual additional disk
```

Do this once per node, so you end up with (at minimum) one OSD per node - 3 total.

**4.4 Create a pool and verify health**

```bash
pveceph pool create labstorage --size 3 --min_size 2
ceph -s          # expect: HEALTH_OK
ceph osd tree     # expect: all 3 OSDs "up" and "in"
```

`size 3` means every object is replicated 3 times, once per node; `min_size 2` means the pool stays writable if one node/OSD is temporarily down, but blocks writes if you drop to only one surviving copy - a deliberate safety margin, not a typo.

**4.5 Add the pool as Proxmox storage**

In the web UI: **Datacenter → Storage → Add → RBD**, point it at your new pool. This is what makes the Ceph pool usable as shared VM/container storage - any node can now run a VM whose disk lives on this pool, which is the foundation for live migration and HA later in the semester.

---

### Part 5 - Foundational Setup for the Rest of the Semester

A few things every later lab will assume already exist:

**5.1 Create a non-root admin user**

Using `root@pam` for everyday administration is exactly the anti-pattern this course spends the whole semester teaching you to avoid - fix it here, on your own infrastructure, before you touch anything else:

- **Datacenter → Permissions → Users → Add**: create a user (e.g., `yourname@pve`).
- **Datacenter → Permissions → Add → User Permission**: assign the `Administrator` role at the `/` path for now (you'll scope this down in later labs once you understand Proxmox's permission model better).
- Log out of `root@pam` and confirm you can log in and manage the cluster as your new user.

**5.2 Upload a Rocky Linux 9 ISO and build a template**

Every lab this semester builds on Rocky Linux 9 - get the ISO in place now instead of re-downloading it for every future lab:

- **Datacenter → your-node → local (storage) → ISO Images → Upload** (or `Download from URL` if your Proxmox storage has internet egress) - get the Rocky Linux 9 minimal or DVD ISO onto shared storage.
- Install a fresh Rocky 9 VM from that ISO, complete the base OS install, then run `dnf update -y` and shut it down.
- Right-click the VM → **Convert to Template**. This gives you (and every future lab) a fast, consistent starting point via **Clone** instead of a full OS install every time.

**5.3 Baseline firewall**

Your nodes are only reachable via WireGuard already, but layer Proxmox's own firewall as defense-in-depth: **Datacenter → Firewall**, enable the firewall, and add a rule allowing the web UI (8006) and SSH (22) only from your WireGuard tunnel's subnet, with a default-deny otherwise.

---

### Part 6 - Rolling Package Updates on a Live Cluster

Now run the full update/upgrade pass you deferred in Part 2 - but **one node at a time**, verifying cluster and Ceph health between each, never all 3 simultaneously:

For **each** node, in turn:

1. Confirm the cluster and Ceph are healthy *before* you touch this node:
   ```bash
   pvecm status   # Quorate
   ceph -s        # HEALTH_OK
   ```
2. Update and upgrade:
   ```bash
   apt update && apt full-upgrade -y
   ```
3. If the kernel was updated, reboot this node:
   ```bash
   reboot
   ```
4. Wait for it to fully rejoin before moving to the next node:
   ```bash
   pvecm status   # confirm this node shows up and the cluster is Quorate again
   ceph -s        # confirm HEALTH_OK again (not just "the node is pingable")
   ```
5. Only once both checks pass, move on to the next node.

{: .warning }
Do not run this on all 3 nodes at once. Rebooting more than one node at a time can drop the cluster below quorum and can drop a Ceph pool below `min_size`, taking it read-only mid-upgrade - exactly the outage this rolling procedure exists to prevent.

---

## Deliverables

Submit a single PDF or Markdown document containing:

1. `wg show` output confirming an active WireGuard handshake
2. Screenshot of the Proxmox **Datacenter** view showing all 3 nodes joined, green, and quorate
3. `pvecm status` output showing 3/3 quorum
4. `ceph -s` and `ceph osd tree` output showing HEALTH_OK with all OSDs up/in
5. Screenshot of your Ceph pool added as Proxmox storage (Datacenter → Storage)
6. Screenshot confirming your non-root admin user and its assigned role
7. Screenshot of the Rocky Linux 9 ISO in storage and the resulting VM template
8. Before/after `apt list --upgradable` output for all 3 nodes, plus `pvecm status`/`ceph -s` output captured *between* each node's reboot, showing the rolling procedure was actually followed in order
9. Written reflection (4-6 sentences): why does Proxmox clustering and Ceph both converge on "3 nodes, tolerate 1 failure" as the practical minimum, and what specifically would go wrong if you had rebooted all 3 nodes at the same time in Part 6?

---

## Grading

| Item | Points |
|------|--------|
| WireGuard connectivity established and verified | 10 |
| Proxmox cluster formed (3/3 quorum) | 15 |
| Ceph deployed - monitors/managers/OSDs on all 3 nodes, pool created | 25 |
| Ceph pool added as Proxmox storage | 10 |
| Non-root admin user and role configured | 10 |
| Rocky 9 ISO uploaded and template created | 10 |
| Rolling package update completed with health verified between each node | 15 |
| Written reflection | 5 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Ceph Network Separation Design (10 pts)
>
> Production Ceph deployments separate the **public network** (client/VM traffic to Ceph) from the **cluster network** (OSD-to-OSD replication traffic) onto different NICs or VLANs, so storage replication traffic never competes with or is exposed alongside client traffic. Your lab nodes likely only have one usable NIC each. Document a network design (diagram + `pveceph` configuration) for how you *would* separate these networks on hardware with 2+ NICs per node, and explain in 2-3 sentences what specifically goes wrong (performance and security) when public and cluster traffic share one network under load.
>
> ### Extension B - HA Groups and Fencing (10 pts)
>
> Configure a Proxmox HA group containing all 3 nodes (**Datacenter → HA → Groups**), add a test VM to HA management, and demonstrate failover by powering off the node currently running it - confirm Proxmox restarts it on a surviving node. Explain the role of a **watchdog** (softdog vs. a hardware watchdog) in Proxmox HA, and why HA without proper fencing risks running the same VM twice (split-brain) if a node merely loses network connectivity rather than actually failing.
>
> ### Extension C - MFA and Firewall Hardening (10 pts)
>
> Enable TOTP two-factor authentication for your admin user (**Datacenter → Permissions → Two Factor**) and screenshot a successful MFA-protected login. Then tighten the Part 5.3 firewall baseline: restrict not just the web UI and SSH, but explicitly deny Corosync/Ceph ports from anything outside the cluster's own node IPs, and document the specific ports involved and why they must never be reachable from outside the cluster network.

[← Back to Labs]({{ site.baseurl }}/labs/)
