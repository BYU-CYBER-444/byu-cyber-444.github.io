---
title: "LAB 1 - Environment Setup & Access Verification"
parent: Labs
nav_order: 1
---

# LAB 1 - Environment Setup & Access Verification
{: .no_toc }

**Duration:** ~1.5 hours &nbsp;·&nbsp; **Week:** Week 1
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


## Objectives

- Get access to your two assigned lab VMs on the course Proxmox cluster
- Verify SSH access to the Linux VM and RDP access to the Windows Server VM
- Document your environment's connection details for use throughout the semester


## Tools Required

- SSH client
- RDP client
- Your domain credentials (emailed to you - log in to the Proxmox web UI with these)
- Your VM login credentials (emailed to you separately - a shared username used to log into the VMs themselves, plus a password that's unique to you. The username is the same for every student; the password is not - it won't work on anyone else's VMs, and theirs won't work on yours)
- Your assigned SSH and RDP ports (emailed to you along with your credentials - see Part 2, these are specific to you)


## Procedure

### Part 1 - Getting Access to Your VMs

1. Log in to the course Proxmox web UI using the domain credentials emailed to you.
1. Locate your two assigned VMs in the resource tree - they'll be named with your netid, e.g. `rocky-01-<netid>` and `winsrv-01-<netid>`.
1. Start both VMs from the Proxmox console if they aren't already running.
1. Confirm the QEMU Guest Agent is running on both machines (it ships pre-installed and enabled on the course templates - you shouldn't need to install anything). On the Summary tab for each VM, the IP address should appear automatically once the agent reports in; if it doesn't after a minute or two, flag it to a TA rather than installing the agent yourself.
1. Record the IP address of each VM (from the Summary tab, or via `ip addr show` on Rocky / `ipconfig` on Windows if you'd rather confirm from inside the guest).

By the end of Part 1 you should have two internal IP addresses - one Linux (Rocky Linux 9), one Windows (Windows Server 2022). They'll be `192.168.56.10` and `192.168.56.20` - and they'll be the *same* for every student, because each of you has your own private copy of this network. That's expected, not a conflict.

> **Note:** SSH (port 22) and RDP (port 3389) are already open on both VMs by design - that's how you're meant to reach them this week. You don't need to open, justify, or flag these ports.

> **Note:** Proxmox itself is joined to the course domain, so the domain credentials emailed to you are what get you into the Proxmox web UI. The VMs are separate - they log in with their own username (also emailed to you, the same for every student) and a password that's unique to you. Don't share your VM password or try a classmate's - it's specific to your two VMs and won't grant access to theirs. TAs have their own VM credentials, so do not change anything on the account called TA if you want support and grading throughout the semester.

#### How You'll Actually Connect

Your VMs are not directly reachable from the internet - each student's pair of VMs sits on its own private, isolated network, which is why the internal IPs above are identical for everyone. To get in, you connect to one shared **course access host** (the same for the whole class) on a **port that's unique to you**. That port is forwarded ("NAT'd") through to your VM's internal IP on the standard service port - you never type the internal IP yourself.

| VM | Internal IP (inside your network) | Standard Port | What you actually connect to |
|---|---|---|---|
| Linux - `rocky-01` | 192.168.56.10 | 22 (SSH) | `<access host>` on `<your assigned SSH port>` |
| Windows - `winsrv-01` | 192.168.56.20 | 3389 (RDP) | `<access host>` on `<your assigned RDP port>` |

Your access host and your two assigned ports are all in the credentials email - the access host is identical for everyone; the SSH and RDP ports are specific to you and won't work for anyone else's VMs.

**Worked example:** if your credentials email says access host `access.cyber444.csrl.local` and SSH port `22007`, you'd run:
```bash
ssh -p 22007 <vm-username>@access.cyber444.csrl.local
```
That connection lands you on your Rocky Linux VM's internal address, `192.168.56.10:22` - the port number is what routes you to *your* VM specifically and not someone else's.

### Part 2 - Verify Access

1. **SSH into the Rocky Linux VM** using your VM credentials (shared username, your unique password) and your assigned SSH port (see "How You'll Actually Connect" above), then confirm you're on the box you expect:
   ```bash
   ssh -p <your assigned SSH port> <vm-username>@<access host>
   hostnamectl
   ip addr show
   ```

1. **RDP into the Windows Server VM** using the same VM credentials and your assigned RDP port. Point your RDP client at `<access host>:<your assigned RDP port>` (most clients, including Microsoft's, accept a `host:port` address). Once connected, confirm with:
   ```powershell
   systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
   ```

1. Take a screenshot of each successful session (terminal showing `hostnamectl` output, and the RDP desktop with the `systeminfo` result).

### Part 3 - Document Your Environment

Fill out `lab-01-access.md` and resolve all the TODOs


## Submission Requirements

- Screenshot of SSH login to the Linux VM (showing `hostnamectl` output)
- Screenshot of the RDP session to the Windows Server VM (showing `systeminfo` output)
- `lab-01-access.md` - completed environment documentation

---

[← Back to Labs]({{ site.baseurl }}/labs/)
