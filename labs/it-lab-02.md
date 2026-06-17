---
title: "IT LAB 2 - Linux Network Services"
parent: Labs
nav_order: 102
---

# IT LAB 2 - Linux Network Services
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 2 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Configure a BIND9 authoritative DNS server with forward and reverse zones, including CNAME, MX, and TXT records
- Set up ISC DHCP with multiple scopes, class-based assignment, and static reservations
- Export an NFS share with host-based access controls and verify mount options including `nosuid` and `noexec`
- Deploy NTP with chrony as both a client and a stratum-2 server for the internal network
- Validate each service with structured diagnostic commands and capture evidence

---

## Tools Required

- Ubuntu 22.04 LTS VM (or instructor-provided environment)
- Packages: `bind9`, `bind9utils`, `isc-dhcp-server`, `nfs-kernel-server`, `chrony`
- Client VM or namespace for service verification

---

## Background

Linux network services form the backbone of enterprise infrastructure. DNS resolves hostnames, DHCP automates IP assignment, NFS enables shared storage, and NTP ensures time consistency for authentication (Kerberos requires < 5 min skew) and log correlation. Misconfiguration in any one service can cascade: a wrong PTR record breaks SSH host verification; a DHCP scope overlap causes address conflicts; NTP drift invalidates TLS certificates.

This lab treats each service as a production deployment - you will configure, test, break, and verify recovery.

---

## Procedure

### Part 1 - BIND9 Authoritative DNS (60 min)

**1.1 Install and configure named.conf**

```bash
sudo apt install -y bind9 bind9utils
```

Edit `/etc/bind/named.conf.options`:

```
options {
    directory "/var/cache/bind";
    recursion no;                    // authoritative only
    allow-query { any; };
    dnssec-validation auto;
    listen-on { 127.0.0.1; 10.0.0.1; };  // adjust to your IP
    version "not disclosed";
};
```

**1.2 Create the forward zone**

Add to `/etc/bind/named.conf.local`:

```
zone "lab.internal" {
    type master;
    file "/etc/bind/db.lab.internal";
    notify no;
};

zone "0.0.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.0";
    notify no;
};
```

Create `/etc/bind/db.lab.internal`:

```
$TTL 3600
@   IN  SOA  ns1.lab.internal. admin.lab.internal. (
            2024010101 ; Serial
            3600       ; Refresh
            900        ; Retry
            604800     ; Expire
            300 )      ; Negative TTL

    IN  NS   ns1.lab.internal.
    IN  MX   10 mail.lab.internal.

ns1     IN  A     10.0.0.1
www     IN  A     10.0.0.10
mail    IN  A     10.0.0.20
ftp     IN  CNAME www.lab.internal.
_dmarc  IN  TXT   "v=DMARC1; p=none; rua=mailto:dmarc@lab.internal"
@       IN  TXT   "v=spf1 mx ~all"
```

Create `/etc/bind/db.10.0.0`:

```
$TTL 3600
@   IN  SOA  ns1.lab.internal. admin.lab.internal. (
            2024010101 3600 900 604800 300 )

    IN  NS   ns1.lab.internal.

1   IN  PTR  ns1.lab.internal.
10  IN  PTR  www.lab.internal.
20  IN  PTR  mail.lab.internal.
```

**1.3 Validate and start**

```bash
sudo named-checkconf
sudo named-checkzone lab.internal /etc/bind/db.lab.internal
sudo named-checkzone 0.0.10.in-addr.arpa /etc/bind/db.10.0.0
sudo systemctl enable --now named
```

**1.4 Test resolution**

```bash
dig @127.0.0.1 www.lab.internal A +short
dig @127.0.0.1 mail.lab.internal MX +short
dig @127.0.0.1 ftp.lab.internal CNAME +short
dig @127.0.0.1 -x 10.0.0.10 +short          # reverse lookup
dig @127.0.0.1 lab.internal TXT +short
```

Capture output of all five commands. Verify CNAME for ftp points to www.lab.internal. and PTR for .10 returns www.lab.internal.

**1.5 Introduce and diagnose an error**

Temporarily break the zone: change the SOA serial to a lower value than the current serial (e.g., 2020010101). Reload named:

```bash
sudo rndc reload
dig @127.0.0.1 www.lab.internal A
```

Document the behavior. Explain in your report why DNS caching can cause stale records to persist even after a zone file correction.

Restore the correct serial and reload again.

---

### Part 2 - ISC DHCP Server (45 min)

**2.1 Install**

```bash
sudo apt install -y isc-dhcp-server
```

Edit `/etc/dhcp/dhcpd.conf`:

```
default-lease-time 3600;
max-lease-time 86400;
authoritative;

option domain-name "lab.internal";
option domain-name-servers 10.0.0.1;
option ntp-servers 10.0.0.1;

# Primary subnet
subnet 10.0.0.0 netmask 255.255.255.0 {
    range 10.0.0.100 10.0.0.200;
    option routers 10.0.0.254;
    option broadcast-address 10.0.0.255;

    # Vendor class for PXE clients
    class "pxe-clients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
        filename "pxelinux.0";
        next-server 10.0.0.1;
    }
}

# Static reservation for the web server
host www-server {
    hardware ethernet 00:50:56:aa:bb:01;
    fixed-address 10.0.0.10;
    option host-name "www";
}

# Management VLAN (documentation only - second interface not required)
subnet 10.0.1.0 netmask 255.255.255.0 {
    range 10.0.1.10 10.0.1.50;
    option routers 10.0.1.254;
    default-lease-time 600;
}
```

Set the interface in `/etc/default/isc-dhcp-server`:

```
INTERFACESv4="ens33"   # replace with your actual interface
```

**2.2 Start and verify**

```bash
sudo systemctl enable --now isc-dhcp-server
sudo systemctl status isc-dhcp-server
sudo journalctl -u isc-dhcp-server -n 30
```

From a client or using `dhclient` in a secondary namespace:

```bash
# Create a test namespace
sudo ip netns add testclient
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth1 netns testclient
sudo ip addr add 10.0.0.1/24 dev veth0
sudo ip link set veth0 up
sudo ip netns exec testclient ip link set veth1 up
sudo ip netns exec testclient dhclient veth1
sudo ip netns exec testclient ip addr show veth1
```

Verify the assigned address falls within 10.0.0.100-200.

**2.3 Inspect the lease file**

```bash
cat /var/lib/dhcp/dhcpd.leases
```

Identify the lease for your test client. Record: IP, MAC, lease-start, lease-end.

---

### Part 3 - NFS Shared Storage (30 min)

**3.1 Configure exports**

```bash
sudo apt install -y nfs-kernel-server
sudo mkdir -p /exports/shared /exports/builds
sudo chown nobody:nogroup /exports/shared
sudo chmod 1777 /exports/shared
```

Edit `/etc/exports`:

```
/exports/shared  10.0.0.0/24(rw,sync,no_subtree_check,root_squash)
/exports/builds  10.0.0.10(ro,sync,no_subtree_check,root_squash,nosuid,noexec)
```

```bash
sudo exportfs -ra
sudo exportfs -v
sudo systemctl enable --now nfs-kernel-server
```

**3.2 Mount and verify from client**

```bash
# On client (or localhost for testing)
sudo apt install -y nfs-common
sudo mkdir -p /mnt/shared /mnt/builds
sudo mount -t nfs -o hard,intr,timeo=14 10.0.0.1:/exports/shared /mnt/shared
sudo mount -t nfs -o ro,hard,intr 10.0.0.1:/exports/builds /mnt/builds

# Verify mount options
cat /proc/mounts | grep nfs

# Test write on shared (should succeed)
touch /mnt/shared/testfile

# Test write on builds (should fail with read-only error)
touch /mnt/builds/testfile
```

Document both outcomes. Explain why `root_squash` is a security best practice for NFS exports.

---

### Part 4 - NTP with Chrony (30 min)

**4.1 Configure as client and internal stratum-2 server**

```bash
sudo apt install -y chrony
```

Edit `/etc/chrony/chrony.conf`:

```
# Upstream NTP pools
pool 0.ubuntu.pool.ntp.org iburst maxsources 2
pool 1.ubuntu.pool.ntp.org iburst maxsources 2

# Allow internal network to sync from this server
allow 10.0.0.0/24

# Serve time even if no upstream is reachable (for air-gapped scenarios)
local stratum 2

# Leap second handling
leapsectz right/UTC

driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
```

```bash
sudo systemctl enable --now chrony
```

**4.2 Verify synchronization**

```bash
chronyc tracking
chronyc sources -v
chronyc sourcestats
```

Record: Reference ID, Stratum, System time offset, RMS offset, Frequency error.

**4.3 Test client synchronization**

From a second VM or using `chronyd` in client mode, verify it syncs from your server at 10.0.0.1. Alternatively, run:

```bash
chronyc -h 10.0.0.1 tracking 2>/dev/null || echo "Remote query disabled (expected)"
```

Explain in your report why NTP accuracy matters for: (a) Kerberos authentication, (b) log forensics, (c) TLS certificate validation.

---

### Part 5 - End-to-End Integration Test (15 min)

Write a shell script `verify_services.sh` that tests all four services and prints PASS/FAIL for each check:

```bash
#!/bin/bash
set -euo pipefail

PASS=0; FAIL=0
check() {
    local name="$1"; shift
    if eval "$@" &>/dev/null; then
        echo "PASS: $name"; ((PASS++))
    else
        echo "FAIL: $name"; ((FAIL++))
    fi
}

# DNS checks
check "DNS A record (www)"    "dig @127.0.0.1 www.lab.internal A +short | grep -q 10.0.0.10"
check "DNS PTR record"         "dig @127.0.0.1 -x 10.0.0.10 +short | grep -q www"
check "DNS MX record"          "dig @127.0.0.1 lab.internal MX +short | grep -q mail"

# DHCP check (service running)
check "DHCP service running"   "systemctl is-active isc-dhcp-server"

# NFS checks
check "NFS export visible"     "showmount -e localhost | grep -q /exports/shared"
check "NFS shared writable"    "touch /mnt/shared/verify_$$ && rm /mnt/shared/verify_$$"
check "NFS builds read-only"   "! touch /mnt/builds/verify_$$ 2>/dev/null"

# NTP check
check "Chrony synchronized"    "chronyc tracking | grep -q 'Leap status.*Normal'"

echo ""
echo "Results: $PASS passed, $FAIL failed"
```

Run the script and capture its output. All eight checks should pass.

---

## Deliverables

Submit a single document with:

1. BIND9 zone files (forward + reverse) and output of all five `dig` commands
2. Screenshot showing the broken-serial behavior and your written explanation
3. `dhcpd.conf` and lease file excerpt showing the test client lease
4. `/etc/exports` content and output of both mount tests (write success + write failure)
5. `chronyc tracking` and `chronyc sources -v` output
6. NTP explanation paragraph (Kerberos, forensics, TLS)
7. `verify_services.sh` script and its output showing all 8 PASSes

---

## Grading

| Item | Points |
|------|--------|
| BIND9 - forward zone with all record types | 20 |
| BIND9 - reverse zone and broken-serial diagnosis | 10 |
| DHCP - scopes, reservation, lease verification | 20 |
| NFS - exports with security options, write/read-only test | 20 |
| Chrony - configuration and synchronization evidence | 15 |
| Integration test script passing all 8 checks | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - TSIG-Secured DNS Zone Transfer
>
> In production, DNS zone transfers between primary and secondary servers must be authenticated to prevent zone data exfiltration. Configure TSIG (Transaction Signature) authentication for a simulated zone transfer:
>
> 1. Generate a TSIG key: `tsig-keygen -a hmac-sha256 transfer-key`
> 2. Add the key to both `named.conf` files (primary and secondary, or simulate with two named instances on different ports).
> 3. Restrict zone transfers: `allow-transfer { key transfer-key; };`
> 4. Test authenticated transfer: `dig -y hmac-sha256:transfer-key:... AXFR lab.internal @127.0.0.1`
> 5. Test unauthenticated transfer (should be refused): `dig AXFR lab.internal @127.0.0.1`
>
> Document the output of both transfer attempts and explain how TSIG prevents DNS cache poisoning attacks compared to IP-based restrictions alone.
>
> ### Extension B - DHCP Failover Configuration
>
> ISC DHCP supports active/passive failover between two servers to eliminate DHCP as a single point of failure. Configure DHCP failover between two instances (or two ports on localhost):
>
> 1. Configure primary (`dhcpd.conf`):
>    ```
>    failover peer "lab-failover" {
>        primary;
>        address 10.0.0.1;
>        port 647;
>        peer address 10.0.0.2;
>        peer port 647;
>        max-response-delay 30;
>        max-unacked-updates 10;
>        load balance max seconds 3;
>        mclt 1800;
>        split 128;
>    }
>    ```
> 2. Configure secondary with matching `secondary;` block.
> 3. Include `failover peer "lab-failover";` in each pool.
> 4. Verify failover state: `omshell` → `connect` → `show failover`.
>
> Document the failover state machine (NORMAL → COMMUNICATIONS-INTERRUPTED → PARTNER-DOWN) and explain under what conditions the secondary will begin issuing leases independently. Discuss the risk of duplicate IP assignments if failover state is not properly managed.
>
> Submit TSIG configuration files, both dig outputs, DHCP failover configuration, and the state machine explanation.

[← Back to Labs]({{ site.baseurl }}/labs/)
