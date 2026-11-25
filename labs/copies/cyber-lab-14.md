---
title: "CYBER LAB 14 - Docker & Container Security Hardening"
parent: Labs
nav_order: 14
---

# CYBER LAB 14 - Docker & Container Security Hardening
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

By the end of this lab, learners will be able to:

- **Analyze** a container host's security warnings against the CIS Benchmark to prioritize which risks to fix first (Part 1)
- **Apply** hardening to the container daemon so every container starts with secure defaults (Part 2)
- **Create** a container image that runs safely as a non-root user (Part 3)


- **Analyze** a container host's security warnings against the CIS Benchmark (Part 1)
- **Apply** security hardening to the container daemon configuration (Part 2)
- **Create** a hardened container image that runs as a non-root user (Part 3)
- **Apply** security controls when running a container (Part 4)
- **Evaluate** container images for known vulnerabilities using multiple scanners (Part 5)
- **Evaluate** the effect of hardening by comparing benchmark results before and after (Part 6)
- **Apply** a CIS-style hardening baseline to the hypervisor layer (Part 7)

--- 

## Tools Required

- Your instructor has provisioned two Rocky Linux 9 LXC containers on your Proxmox node, each running Docker Engine. Your username on both is your Net ID, and your password is the one emailed to you at the start of the semester.
  - `cyber-lab14-docker-priv` - a **privileged** LXC container (container root is host root)
  - `cyber-lab14-docker-unpriv` - an **unprivileged** LXC container (container root is mapped to an unprivileged host UID)
- docker-bench-security
- Trivy (`https://github.com/aquasecurity/trivy`)
- Grype (`https://github.com/anchore/grype`)
- Administrative (root) access to the Proxmox node that hosts the two LXC containers, for Part 7

Do Parts 1-4 and 6 on **both** containers. Part 5 only needs to be done on one, since both run the same images. Where a step differs between the two, the lab says so.

Run this on each container:

```bash
# Install helper packages (git for docker-bench-security, jq for docker inspect output)
sudo dnf install -y git jq

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

---

## Background

Container security fails in layers most people don't think to check: an image that runs as root undoes every network control you put around it, a docker-bench WARN that never gets triaged sits there until it's exploited, and even a perfectly hardened container is meaningless if the LXC container and hypervisor underneath it can be escaped. Here Docker runs inside a Rocky Linux LXC container, which adds a layer to reason about: a **privileged** LXC container shares UID 0 with the host, while an **unprivileged** one maps container root to an unprivileged host UID, and that one setting changes how much damage a Docker escape can do. This lab works through that whole stack on both kinds of container - baseline assessment, daemon hardening, a hardened image built from scratch, vulnerability scanning across two independent scanners, and an LXC and hypervisor-layer hardening pass - because "the container is secure" is only true if every layer underneath it is too.

---

## Procedure

### Part 1 - docker-bench-security Baseline

Run this on **both** containers. First, record how each LXC container maps user IDs to the host:

```bash
cat /proc/self/uid_map
```

The privileged container shows a single identity mapping (`0 0 4294967295`). The unprivileged one shows container UID 0 mapped to a high host UID range (typically `0 100000 65536`). Save this output - you will use it in Part 7.

```bash
git clone https://github.com/docker/docker-bench-security
cd docker-bench-security
sudo sh docker-bench-security.sh 2>&1 | tee ~/cyber-lab14-bench-baseline.txt
```

Categorize all WARN results:

| Check ID | Description | Severity (your assessment) | Remediation Plan |
|---|---|---|---|
| 2.1 | Network traffic not restricted between containers | High | Configure `--icc=false` |
| 2.2 | Logging level not set to 'info' | Medium | Add to daemon.json |

You must identify and categorize ALL WARN items - not just the 5 from the old lab. Expect the two containers' WARN lists to differ, and expect some Host Configuration (section 1) WARNs that cannot be fixed from inside an LXC container at all, such as a separate partition for `/var/lib/docker` or kernel-level auditing. For those, record the remediation as "Accepted - handled at the LXC/hypervisor layer" and name the control that compensates for it.

### Part 2 - Harden Docker Daemon

Do this on **both** containers. First put the default seccomp profile in place, since `daemon.json` points to it:

```bash
sudo mkdir -p /etc/docker/seccomp
sudo curl -fsSL -o /etc/docker/seccomp/default.json https://raw.githubusercontent.com/moby/profiles/main/seccomp/default.json
```

Apply hardening via `/etc/docker/daemon.json`. Replace the existing file (back it up first):

```json
{
  "log-driver": "journald",
  "log-opts": {
    "tag": "docker/{{.Name}}"
  },
  "icc": false,
  "live-restore": true,
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp/default.json",
  "log-level": "info",
  "userland-proxy": false,
  "storage-driver": "overlay2"
}
```

**Privileged container only:** also add `"userns-remap": "default",` to the file. Without it, root inside a Docker container is root inside a privileged LXC container, which is root on the host. Docker will re-pull images after this change because remapped containers use a separate storage directory.

**Unprivileged container:** leave `userns-remap` out. The LXC container already maps container root to an unprivileged host UID, so a second remap is redundant here and needs a larger subordinate-ID range than the LXC container's mapping provides. In your write-up, explain why the two `daemon.json` files differ.

```bash
sudo systemctl daemon-reload && sudo systemctl restart docker
docker info | grep -E "Logging|User|Security"
```

If Docker fails to restart, read the reason with `sudo journalctl -u docker --no-pager | tail -30`.

### Part 3 - Write a Hardened Dockerfile

The `nginx:latest` image runs as root and includes unnecessary packages. Write a hardened alternative:

`Dockerfile.hardened`:
```dockerfile
# Use a specific digest (not 'latest') - pinned to a known-good image
FROM nginx:1.26.0-alpine@sha256:ACTUAL_DIGEST_HERE

# Remove default nginx config and replace with hardened version
RUN rm /etc/nginx/conf.d/default.conf

COPY nginx-hardened.conf /etc/nginx/conf.d/default.conf

# Create a non-root user for nginx
RUN addgroup -S webgroup && adduser -S webuser -G webgroup

# Change ownership of nginx runtime directories
RUN chown -R webuser:webgroup /var/cache/nginx /var/run /var/log/nginx &&     chmod -R 755 /var/cache/nginx

# Drop all capabilities - only add back what nginx needs
USER webuser

# Expose only the port in use
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3   CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1
```

`nginx-hardened.conf`:
```nginx
server {
    listen 8080;
    server_name localhost;
    server_tokens off;   # hide nginx version
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```

Build the image on **each** container (there is no shared registry between them):
```bash
docker build -f Dockerfile.hardened -t nginx-hardened:cyber-lab14 .
```

### Part 4 - Run with Security Options

Run the same command on **both** containers.

```bash
docker run -d   --name hardened-nginx   --read-only   --tmpfs /var/run:rw,noexec,nosuid,size=65536k   --tmpfs /var/cache/nginx:rw,noexec,nosuid,size=65536k   --security-opt no-new-privileges:true   --security-opt seccomp=/etc/docker/seccomp/default.json   --cap-drop ALL   --cap-add NET_BIND_SERVICE   -p 8080:8080   nginx-hardened:cyber-lab14

# Verify container is running
curl http://localhost:8080

# Inspect security options applied
docker inspect hardened-nginx | jq '.[0].HostConfig | {SecurityOpt, CapAdd, CapDrop, ReadonlyRootfs}'

# Which UID is nginx running as, as this LXC container sees it?
ps -eo uid,user,comm | grep nginx
```

Note the UID on each container. On the privileged container it should be a remapped high UID (from `userns-remap`); on the unprivileged one it is the image's own `webuser` UID. You will see how the Proxmox host views these same processes in Part 7.

### Part 5 - Vulnerability Scanning: Trivy + Grype

Do this on **one** container only - both run the same images, so the results will not differ. Scan both the original nginx and your hardened image:

```bash
# Scan original nginx:latest
trivy image --severity HIGH,CRITICAL nginx:latest --format json -o trivy-nginx-latest.json
grype nginx:latest -o json > grype-nginx-latest.json

# Scan hardened image
trivy image --severity HIGH,CRITICAL nginx-hardened:cyber-lab14 --format json -o trivy-hardened.json
grype nginx-hardened:cyber-lab14 -o json > grype-hardened.json
```

Build a comparison table:

| Tool | Image | CRITICAL | HIGH | MEDIUM | LOW |
|---|---|---|---|---|---|
| Trivy | nginx:latest | X | X | X | X |
| Trivy | nginx-hardened:cyber-lab14 | X | X | X | X |
| Grype | nginx:latest | X | X | X | X |
| Grype | nginx-hardened:cyber-lab14 | X | X | X | X |

Note where Trivy and Grype differ - different scanners use different vulnerability databases.

### Part 6 - Post-Hardening docker-bench Re-scan

Run this on **both** containers.

```bash
sudo sh docker-bench-security.sh 2>&1 | tee ~/cyber-lab14-bench-hardened.txt
diff ~/cyber-lab14-bench-baseline.txt ~/cyber-lab14-bench-hardened.txt | grep "^[<>]" | grep -i warn
```

Count how many WARN items moved to PASS, and fill in:

| Host | Baseline WARNs | Hardened WARNs | WARN → PASS |
|---|---|---|---|
| `cyber-lab14-docker-priv` | X | X | X |
| `cyber-lab14-docker-unpriv` | X | X | X |

Explain why the counts differ, and which remaining WARNs can only be fixed at the LXC or hypervisor layer (Part 7).

### Part 7 - LXC & Hypervisor Hardening: Privileged vs. Unprivileged Isolation

Everything you've hardened so far runs *inside* an LXC container - but the container and the Proxmox host underneath it are themselves an attack surface, and an escape defeats every Docker control you just applied. This part applies a CIS-style hardening baseline to those layers. Run these commands as root on the Proxmox node that hosts the two containers. Find each container's ID with `pct list`.

**1. Compare privilege and reduce the container's attack surface.** Every unnecessary feature, device, or mount point is one more thing a compromised container could try to exploit for an escape. Compare the two configurations and remove anything not in active use:

```bash
# List configuration for each container (note the 'unprivileged' and 'features' lines)
pct config <ctid>

# Example: restrict a container to only the feature Docker needs, then restart it
pct set <ctid> --features nesting=1
pct reboot <ctid>

# Example: remove an unused device passthrough or mount point
pct set <ctid> --delete dev0
pct set <ctid> --delete mp0
```

Docker needs `nesting=1` in both containers; `keyctl=1` is only needed by the unprivileged one. Do not remove a feature Docker still needs - confirm `docker run --rm hello-world` still works afterward.

**2. Verify isolation at the filesystem level.** A container's root filesystem should not be readable by other users on the Proxmox host - if it is, one compromised management account can read every container's disk offline, bypassing every in-container control entirely. Also compare how the host sees file ownership for each container:

```bash
pct config <ctid> | grep rootfs
ls -la /var/lib/vz/images/<ctid>/   # or your storage backend's equivalent path

# File ownership as the host sees it (the container must be running)
ls -ln /var/lib/lxc/<ctid>/rootfs/root
```

Confirm the disk image or volume is owned by `root` with no group/other read access. Then compare the file owners: the privileged container's files are owned by UID 0 on the host, the unprivileged container's by a high UID such as 100000. Explain in one or two sentences what that means for an attacker who escapes each container.

**3. Harden the hypervisor's own management interface.** Confirm the Proxmox web UI enforces TLS 1.2+ (no legacy SSL/TLS versions), and that access to the management port (8006) is restricted at the network level to the admin subnet - tying directly back to Week 5's out-of-band management hardening and Week 6's network segmentation work, since the hypervisor management plane deserves exactly the same isolation as a server's IPMI card.

---

## Deliverables

- `/proc/self/uid_map` output from both containers
- Baseline docker-bench output from both containers with all WARNs categorized
- `/etc/docker/daemon.json` from both containers (annotated, explaining the `userns-remap` difference)
- `Dockerfile.hardened` and `nginx-hardened.conf` (annotated)
- `docker run` command showing all security options
- `docker inspect` output showing `SecurityOpt`, `CapDrop`, `ReadonlyRootfs` from both containers
- Trivy + Grype comparison table for both images
- Post-hardening docker-bench output from both containers and the WARN → PASS delta table
- `pct config` before/after for both containers showing removed features/devices, rootfs permission verification, and the host-side file ownership comparison

---

## Grading

| Item | Points |
|------|--------|
| docker-bench baseline - all WARNs categorized, both containers (Part 1) | 12 |
| Docker daemon hardening, both containers (Part 2) | 12 |
| Hardened Dockerfile (Part 3) | 15 |
| Run with security options, verified on both containers (Part 4) | 10 |
| Trivy + Grype scanning and comparison (Part 5) | 15 |
| Post-hardening rescan and delta, both containers (Part 6) | 10 |
| LXC and hypervisor hardening - all 3 items (Part 7) | 18 |
| **Total** | **92** |


[← Back to Labs]({{ site.baseurl }}/labs/)
