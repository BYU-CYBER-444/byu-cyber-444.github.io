---
title: "LAB 1 - Proxmox Orientation"
parent: Labs
nav_order: 1
---

# LAB 1 - Proxmox Orientation
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Establish remote access to your assigned Proxmox environment over WireGuard
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

Everything you build in this lab - the cluster and the Ceph pool is the foundation the rest of this semester's labs will run on top of. Get it right now and you won't be fighting infrastructure problems in the coming weeks.

---

## Instructions

### Part 1 - Secure Remote Access via WireGuard

1. Locate the email containing your WireGuard profile (`.conf` file) and your 3 nodes' Proxmox credentials and IP addresses. If you can't find it, ask before proceeding - do not attempt to reach these nodes any other way.
1. Install the WireGuard client for your OS
1. Import your profile and bring the tunnel up
1. Open `https://<node1-internal-ip>:8006` in your browser (accept the self-signed certificate warning) and confirm you can log in with the credentials you were given for the root account.

---

### Part 2 - Initial Node Preparation

Confirm all 3 nodes' clocks agree - Corosync and Ceph are both clock-sensitive, and a node with drifted time can behave unpredictably once clustered:

You can reach a terminal for Proxmox via ssh or by clicking on the server in the left hand sideand then selecting shell

```bash
timedatectl status 
```

If the clocks do not agree you will have to sync them before you can move onto part 3

Don't run the full package upgrade yet - that's Part 6, done deliberately *after* the cluster and Ceph are live, using a rolling procedure that won't be safe to skip.

---

### Part 3 - Building the Proxmox Cluster

Proxmox VE's cluster setup is fully GUI-driven - no CLI needed:

Before creating the cluster, set static IPs on **`ens19`**, **`ens20`**, **`ens21`**, and **`ens20`** on all 3 nodes - these two interfaces will serve as your cluster's **ring 0** and **ring 1** (Corosync's primary and redundant links), so they need working addresses before you point cluster communication at them. On each node: **System → Network**, select `ens19`, edit it, assign it a static IP, and repeat for the rest. Also make sure that AutoStart is turned on and that the MTU is set to 1496 (You can see the MTU setting if you check the Advanced Option). Apply the configuration on each node before moving on.

Use a private `10.x` range dedicated to cluster traffic, with a different host octet per node, e.g.:

| Node | ens19 (ring 0) | ens20 (ring 1) | ens21 (Ceph Network) | ens22 (Ceph Cluster) 
|------|-------------------|-------------------| ------ | ------ |
| node1 | `10.10.10.1/24` | `10.10.20.1/24` | `10.10.30.1/24` | `10.10.40.1/24` |
| node2 | `10.10.10.2/24` | `10.10.20.2/24` | `10.10.30.2/24` | `10.10.40.2/24` |
| node3 | `10.10.10.3/24` | `10.10.20.3/24` | `10.10.30.3/24` | `10.10.40.3/24` |

1. On **node 1**: **Datacenter → Cluster → Create Cluster**. Give it a name (e.g., `lab-cluster`), select the network on ens19 for Link 0 and ens 20 for Link 1for cluster communication, and click **Create**.
2. Still on node 1: **Datacenter → Cluster → Join Information**, click **Copy Information**. This copies a join token containing node 1's fingerprint and connection details.
3. On **node 2**: **Datacenter → Cluster → Join Cluster**, paste the join information, enter node 1's root password, and click **Join**. Repeat on **node 3**.
4. Back on any node's **Datacenter → Cluster** page, confirm all 3 nodes are listed with a green status. The node list on this page *is* your quorum check - a node that's failed to join or has dropped out of quorum shows as red/greyed rather than green.


---

### Part 4 - Deploying Ceph on the Cluster

Proxmox's Ceph integration is fully GUI-driven, per node, under each node's own **Ceph** section in the left tree.

**4.1 Initialize Ceph**

On **node 1**: click the node, then **Ceph → Install Ceph**. The install wizard will prompt you to pick a Ceph version and a repository - choose the **No-Subscription** repository (same reasoning as Part 2: no paid subscription on lab hardware). Complete the wizard, which also configures the Ceph public network for you.
repeat for nodes 2 and 3

- Select ens21 as the public network and ens22 as the cluster network
- number of replicas 3, min replicas 2

**4.2 Create monitors and managers on all 3 nodes**

Ceph monitors need an odd number for their own quorum logic - 3 matches your node count exactly. On any node: **Ceph → Monitor → Create**, then **Ceph → Manager → Create**.

**4.3 Add OSDs**

On **each** node: **Ceph → OSD → Create: OSD**, and select the additional raw disk you were assigned from the dropdown (not the OS disk - Proxmox won't let you pick a disk that's already in use, but double-check you're selecting the right one). Repeat twice per node, so you end up with at two OSDs per node - 6 total. The OSD tab lists every OSD across the cluster with its **Status** column showing `up`/`in`.

**4.4 Create a pool and verify health**

Still in the **Ceph** section: **Pools → Create**, name it (e.g., `labstorage`), and set **Size = 3**, **Min Size = 2**. `size 3` means every object is replicated 3 times, once per node; `min_size 2` means the pool stays writable if one node/OSD is temporarily down, but blocks writes if you drop to only one surviving copy - a deliberate safety margin, not a typo. Make sure you select `Add as Storage`

Check overall health on the node's main **Ceph** dashboard page - it displays a health summary (`HEALTH_OK` or a warning banner) without needing `ceph -s` at all.

---

### Part 5 - Rolling Package Updates on a Live Cluster

Now run the full update/upgrade pass you deferred in Part 2 - but **one node at a time**, verifying cluster and Ceph health between each, never all 3 simultaneously. Proxmox exposes package updates and reboots directly in the GUI, so this whole part can be done without an SSH session:

For **each** node, in turn:

1. Confirm the cluster and Ceph are healthy *before* you touch this node: check the **Datacenter → Cluster** page (all nodes green) and the node's **Ceph** dashboard (`HEALTH_OK`).
2. Click the node, then **Updates → Refresh** to pull the latest package list, then **Upgrade**. This opens a task console window right in the browser and runs the underlying update/upgrade for you - watch it through to completion instead of closing the window early.
3. If the task output indicates a new kernel was installed, reboot this node using the **Reboot** button in the top-right of the node's **Summary** page (not a full shutdown).
4. Wait for it to fully rejoin before moving to the next node: recheck **Datacenter → Cluster** (this node shows green/joined again) and its **Ceph** dashboard (`HEALTH_OK` again - not just "the node is pingable").
5. Only once both checks pass, move on to the next node.

{: .warning }
Do not run this on all 3 nodes at once. Rebooting more than one node at a time can drop the cluster below quorum and can drop a Ceph pool below `min_size`, taking it read-only mid-upgrade - exactly the outage this rolling procedure exists to prevent.

---

## Deliverables

Submit a single Markdown document at `labs/lab-01.md` containing any notes you made and open a PR called `Grade: lab-1`

---

## Grading

| Item | Points |
|------|--------|
| Proxmox cluster formed (3/3 quorum) | 30 |
| Ceph deployed - monitors/managers/OSDs on all 3 nodes, pool created | 40 |
| Ceph pool added as Proxmox storage | 15 |
| Rolling package update completed with health verified between each node | 15 |
| **Total** | **100** |

---


[← Back to Labs]({{ site.baseurl }}/labs/)
