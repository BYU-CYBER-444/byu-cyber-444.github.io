---
title: "CYBER LAB 12 - Docker & Container Security Hardening"
parent: Labs
nav_order: 12
---

# CYBER LAB 12 - Docker & Container Security Hardening
{: .no_toc }

**Duration:** ~3.75 hours &nbsp;·&nbsp; **Week:** Week 12 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run docker-bench-security and analyze all WARN items against CIS Docker Benchmark controls
- Write a hardened Dockerfile from scratch for a web application container
- Scan images with both Trivy and Grype and compare results
- Configure Docker daemon hardening via `daemon.json`
- Apply a seccomp profile and verify it restricts syscalls
- Verify container security posture using `docker inspect`
- Apply a CIS-style hardening baseline to the hypervisor layer itself and verify VM isolation controls

---

## Tools Required

- Ubuntu 22.04 VM with Docker Engine
- docker-bench-security
- Trivy (`https://github.com/aquasecurity/trivy`)
- Grype (`https://github.com/anchore/grype`)
- Administrative access to your course's Proxmox (or equivalent KVM-based) hypervisor node for Part 7

```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

---

## Procedure

### Part 1 - docker-bench-security Baseline

```bash
git clone https://github.com/docker/docker-bench-security
cd docker-bench-security
sudo sh docker-bench-security.sh 2>&1 | tee ~/lab12-bench-baseline.txt
```

Categorize all WARN results:

| Check ID | Description | Severity (your assessment) | Remediation Plan |
|---|---|---|---|
| 2.1 | Network traffic not restricted between containers | High | Configure `--icc=false` |
| 2.2 | Logging level not set to 'info' | Medium | Add to daemon.json |

You must identify and categorize ALL WARN items - not just the 5 from the old lab.

### Part 2 - Harden Docker Daemon

Apply hardening via `/etc/docker/daemon.json`. Replace the existing file (back it up first):

```json
{
  "log-driver": "journald",
  "log-opts": {
    "tag": "docker/{{.Name}}"
  },
  "icc": false,
  "live-restore": true,
  "userns-remap": "default",
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp/default.json",
  "log-level": "info",
  "userland-proxy": false,
  "storage-driver": "overlay2"
}
```

Explanation of each setting (required in your report):
- `icc: false` - disables inter-container communication unless explicitly linked (prevents lateral movement)
- `userns-remap: default` - maps container root to an unprivileged host user (prevents container escape)
- `no-new-privileges: true` - prevents `setuid` binaries from escalating inside containers
- `live-restore: true` - containers keep running if the Docker daemon crashes (operational resilience)

```bash
sudo systemctl daemon-reload && sudo systemctl restart docker
docker info | grep -E "Logging|User|Security"
```

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

Build the image:
```bash
docker build -f Dockerfile.hardened -t nginx-hardened:lab12 .
```

### Part 4 - Run with Security Options

```bash
docker run -d   --name hardened-nginx   --read-only   --tmpfs /var/run:rw,noexec,nosuid,size=65536k   --tmpfs /var/cache/nginx:rw,noexec,nosuid,size=65536k   --security-opt no-new-privileges:true   --security-opt seccomp=/etc/docker/seccomp/default.json   --cap-drop ALL   --cap-add NET_BIND_SERVICE   -p 8080:8080   nginx-hardened:lab12

# Verify container is running
curl http://localhost:8080

# Inspect security options applied
docker inspect hardened-nginx | jq '.[0].HostConfig | {SecurityOpt, CapAdd, CapDrop, ReadonlyRootfs}'
```

### Part 5 - Vulnerability Scanning: Trivy + Grype

Scan both the original nginx and your hardened image:

```bash
# Scan original nginx:latest
trivy image --severity HIGH,CRITICAL nginx:latest --format json -o trivy-nginx-latest.json
grype nginx:latest -o json > grype-nginx-latest.json

# Scan hardened image
trivy image --severity HIGH,CRITICAL nginx-hardened:lab12 --format json -o trivy-hardened.json
grype nginx-hardened:lab12 -o json > grype-hardened.json
```

Build a comparison table:

| Tool | Image | CRITICAL | HIGH | MEDIUM | LOW |
|---|---|---|---|---|---|
| Trivy | nginx:latest | X | X | X | X |
| Trivy | nginx-hardened:lab12 | X | X | X | X |
| Grype | nginx:latest | X | X | X | X |
| Grype | nginx-hardened:lab12 | X | X | X | X |

Note where Trivy and Grype differ - different scanners use different vulnerability databases.

### Part 6 - Post-Hardening docker-bench Re-scan

```bash
sudo sh docker-bench-security.sh 2>&1 | tee ~/lab12-bench-hardened.txt
diff ~/lab12-bench-baseline.txt ~/lab12-bench-hardened.txt | grep "^[<>]" | grep -i warn
```

Count how many WARN items moved to PASS. Any remaining WARNs - document why they cannot be remediated in this environment.

### Part 7 - Hypervisor Hardening: Type 1 vs. Type 2 and VM Isolation

Everything you've hardened so far runs *inside* a VM - but the hypervisor underneath it is itself an attack surface, and a VM escape defeats every container control you just applied. This part applies a CIS-style hardening baseline to the hypervisor layer.

**1. Type 1 vs. Type 2 classification and why it matters here.** Your lab environment runs on Proxmox (KVM/QEMU, Type 1 - runs directly on hardware, no host OS in the way). Explain in 3-4 sentences why a Type 1 hypervisor has a smaller attack surface than a Type 2 hypervisor (VirtualBox, VMware Workstation) running as a process on top of a general-purpose host OS, and what that means for the VM-escape blast radius in each case.

**2. Reduce virtual hardware attack surface.** Every unnecessary virtual device (serial port, parallel port, unused USB controller, virtual sound card) is one more thing a compromised guest could try to exploit for an escape. Audit one of your lab VMs' hardware configuration and remove anything not in active use:

```bash
# Proxmox example - list configured hardware for a VM
qm config <vmid>

# Remove an unused device, e.g. a serial port
qm set <vmid> --delete serial0
```

Document what you removed and why each removed device was unnecessary for that VM's role.

**3. Verify VM isolation at the filesystem level.** A VM's disk image should not be readable by other users on the hypervisor host - if it is, one compromised management account can read every VM's disk offline, bypassing every in-guest control entirely.

```bash
ls -la /var/lib/vz/images/<vmid>/   # or your storage backend's equivalent path
```

Confirm the disk image is owned by `root` with no group/other read access, and explain what regular filesystem permissions have to do with hypervisor security.

**4. Harden the hypervisor's own management interface.** Confirm the Proxmox web UI enforces TLS 1.2+ (no legacy SSL/TLS versions), and that access to the management port (8006) is restricted at the network level to the admin subnet - tying directly back to Week 5's out-of-band management hardening and Week 6's network segmentation work, since the hypervisor management plane deserves exactly the same isolation as a server's IPMI card.

**5. Map to a real benchmark.** Pick 3 controls from the CIS VMware ESXi Benchmark (or CIS Microsoft Hyper-V Benchmark) and map each to its closest KVM/Proxmox equivalent - name the control, describe what it requires, and describe the equivalent setting/command in your actual environment (some controls won't have an exact 1:1 equivalent; note that explicitly where true, rather than forcing a false mapping).

---

## Submission Requirements

- Baseline docker-bench output with all WARNs categorized
- `/etc/docker/daemon.json` (annotated - explain every setting)
- `Dockerfile.hardened` and `nginx-hardened.conf` (annotated)
- `docker run` command showing all security options
- `docker inspect` output showing `SecurityOpt`, `CapDrop`, `ReadonlyRootfs`
- Trivy + Grype comparison table for both images
- Post-hardening docker-bench output and WARN → PASS delta count
- Written reflection (3-4 sentences): Trivy and Grype reported different CVEs for the same image. What explains this difference, and what are the implications for a real security team's vulnerability management program?
- Type 1 vs. Type 2 explanation, `qm config` before/after showing removed virtual hardware, disk image permission verification, and the 3-control CIS benchmark mapping table

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Falco Runtime Security Monitoring

Deploy Falco to detect container runtime threats in real time:

```bash
# Install Falco kernel module
curl -s https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee /etc/apt/sources.list.d/falcosecurity.list
sudo apt update && sudo apt install falco -y
sudo systemctl enable --now falco
```

Write a custom Falco rule file `/etc/falco/rules.d/lab12-rules.yaml` with at least 3 rules:

```yaml
- rule: Shell spawned in container
  desc: Detect a shell spawned inside any container
  condition: container and proc.name in (shell_binaries) and evt.type = execve
  output: "Shell in container (container=%container.name user=%user.name cmd=%proc.cmdline)"
  priority: WARNING
  tags: [container, shell, T1059]

- rule: Write to /etc inside container
  desc: Detect writes to /etc inside a container (config tampering)
  condition: container and open_write and fd.name startswith /etc
  output: "Config write in container (container=%container.name file=%fd.name)"
  priority: ERROR
  tags: [container, T1565]

# Add a third rule of your own design...
```

Trigger each rule and capture Falco's detection output:
```bash
# Trigger shell rule:
docker exec hardened-nginx sh -c "echo triggered"

# Trigger /etc write rule (this should fail on read-only container, but test it):
docker run --rm ubuntu sh -c "echo test > /etc/testfile"

sudo journalctl -u falco --since "5 minutes ago" | grep -E "WARNING|ERROR"
```

For each Falco alert generated: identify the MITRE ATT&CK technique, explain what real attack the rule would detect, and assess the false positive rate (what legitimate action might trigger this rule?).

### Hypervisor Hardening: CIS Benchmark Automation and Escape Research

1. **Automate the CIS mapping.** Take the CIS VMware/Hyper-V benchmark control mapping from Part 7 and extend it to at least 10 controls (instead of 3). For each, write a shell command or script snippet that checks the KVM/Proxmox host's actual current state against that control (pass/fail), producing a structured compliance report similar in spirit to the CIS-CAT work from Week 5 - but for the hypervisor layer instead of the guest OS.
2. **Research a real VM escape.** Research one publicly documented QEMU/KVM VM escape vulnerability (e.g., VENOM/CVE-2015-3456, or a more recent QEMU CVE). Write a technical analysis covering: what component was vulnerable, what capability the attacker needed inside the guest to trigger it, what they gained on the host, and which of your Part 7 hardening controls (or a control you'd need to add) would have mitigated or detected the exploitation attempt.

Submit your extended compliance-check script with output, and your VM escape research write-up.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
