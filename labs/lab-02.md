---
title: "LAB 2 - Linux Network Services & Privilege Management"
parent: Labs
nav_order: 2
---

# LAB 2 - Linux Network Services & Privilege Management
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


---

## Objectives

- Configure a BIND (`named`) authoritative DNS server with forward and reverse zones, including CNAME, MX, and TXT records
- Deploy chrony as both a client and an internal stratum-2 NTP server, and compare NTP against PTP for high-precision time synchronization
- Design and implement a least-privilege sudo policy scoping exactly who may administer the DNS service on this host
- Configure POSIX ACLs restricting access to zone files and shared storage by role
- Verify every access control by attempting an unauthorized action and confirming denial
- Scope `firewalld` to expose only the services this host actually provides

---

## Tools Required

- Packages: `bind`, `bind-utils`, `chrony`, `acl`
- `firewalld` (enabled by default on a Rocky 9 Server install - if it isn't running, `sudo systemctl enable --now firewalld`)

```bash
sudo dnf install -y bind bind-utils chrony acl
```

---

## Background

Linux network services form the backbone of enterprise infrastructure. DNS resolves hostnames, and NTP ensures time consistency for authentication (Kerberos requires < 5 min skew) and log correlation. Misconfiguration in any one service can cascade: a wrong PTR record breaks SSH host verification; NTP drift invalidates TLS certificates.

But a network-services host is also a high-value target in its own right - it isn't just infrastructure, it's *trusted* infrastructure. Poisoning a DNS zone compromises every client that trusts this box, silently and at scale, in a way a single compromised workstation never could. That's why this lab doesn't stop at "the services work" - Part 4 applies the same privilege-management discipline a security-conscious organization would apply to *any* host, specifically to this one, so that the question "who can change what on our DNS server" has a real, tested answer by the end of the lab.

None of this is invented for the classroom. The role separation in Part 1 and the access-control layering in Part 4 are small-scale, hands-on implementations of controls you'll find by name in the CIS Benchmarks for RHEL/Rocky Linux and DISA's STIG for RHEL - "limit direct root logins," "ensure only authorized users own DNS zone data," "assign each user account a distinct role" are catalog entries in those frameworks, not lab conventions. Part of thinking like a senior sysadmin instead of just a lab-completer is recognizing when a "best practice" you're told to follow maps to a specific line item an auditor will eventually check.

---

## Procedure

Three accounts already exist on this host with the following roles - you'll spend the rest of the lab scoping their actual access to match:

- **alice** - full sysadmin for this host.
- **bob** - the day-to-day operator responsible for DNS specifically. Notably, his role does **not** extend to storage administration - that's a deliberate boundary you'll enforce in Parts 1 and 4, modeling how a real organization separates "network services operator" from "storage administrator" even when one person could technically do both.
- **carol** - read-only auditor with no write access anywhere on this host.

---

### Part 1 - Least-Privilege Sudo Policy

Create separate sudoers files for each role. Never edit `/etc/sudoers` directly - use `/etc/sudoers.d/`:

**`/etc/sudoers.d/10-sysadmins`:**
```
# Alice is a full sysadmin - full sudo, but requires password
# NOT NOPASSWD - no one gets passwordless sudo in production
alice ALL=(ALL:ALL) ALL
```

**`/etc/sudoers.d/20-operators`:**
```
# Bob can restart/reload/check DNS only - no other services, not full root
# Cmnd_Alias prevents sudo bash, sudo su, or sudo -s escapes
Cmnd_Alias DNSCTL = /usr/bin/systemctl restart named, /usr/bin/systemctl status named, /usr/bin/systemctl reload named
bob ALL=(root) NOPASSWD: DNSCTL
```

**`/etc/sudoers.d/30-auditors`:**
```
# Carol cannot sudo at all (no entry = no sudo access)
# This is implicit - document it explicitly for clarity
```

Validate all sudoers files before saving (a syntax error locks you out):

```bash
sudo visudo -c -f /etc/sudoers.d/10-sysadmins
sudo visudo -c -f /etc/sudoers.d/20-operators
```

**Verify restrictions work:**

Confirm, as each user, that the policy actually does what it claims: bob can manage the DNS service, bob cannot restart an unrelated service (e.g. chronyd), bob cannot escape to a root shell, and carol cannot sudo at all. Record each test in your notes - both the successes and the denials.

**Alternatives to sudoers-based privilege management**

Per-host `sudoers.d` files are the right tool for a single, standalone box like this one, but it's worth knowing what you'd reach for as the scale or risk profile changes:

| | Scope | Strength | Weakness |
|---|---|---|---|
| `sudoers.d` (this lab) | Per-host | Simple, no external dependencies, plain-text and diffable | Doesn't scale - policy drifts host-to-host with nothing to keep them in sync |
| `doas` / `opendoas` | Per-host | Tiny codebase (a few hundred lines vs. sudo's tens of thousands) means a much smaller attack surface, simpler rule syntax | Far fewer features (no `Cmnd_Alias`-style grouping), not in RHEL/Rocky's default repos, smaller community to lean on when something breaks |
| Centralized sudo via FreeIPA / Red Hat IdM | Fleet-wide | Sudo rules live in LDAP and apply consistently across every enrolled host - one change, every server updates | Adds a hard dependency on directory-service availability; a single host now has a network dependency for a decision it used to make locally |
| PAM-gated sudo (MFA) | Per-host or fleet | Requires a second factor before granting elevation - meaningfully raises the bar for a stolen password | Enrollment/recovery overhead, and a new failure mode: a locked-out MFA device can lock a sysadmin out of their own elevation path |
| Commercial PAM/PIM (CyberArk, BeyondTrust) | Fleet-wide | Session recording, just-in-time elevation, credential vaulting - full accountability for every privileged action | Cost and operational complexity that's hard to justify below a certain fleet size |

Consider: at what point does this lab's per-host `sudoers.d` approach stop being appropriate for a real organization, and what specific operational pain (not just "it doesn't scale" in the abstract) forces the move to something centralized?

---

### Part 2 - BIND (`named`) Authoritative DNS

**2.1 Configure `/etc/named.conf`**

Rocky 9 ships BIND's configuration as a single `/etc/named.conf` file (not Debian/Ubuntu's split `named.conf.options`/`named.conf.local`). Edit the `options` block and add your zone statements directly:

```
options {
    directory "/var/named";
    recursion no;                          // authoritative only
    allow-query { any; };
    dnssec-validation auto;
    listen-on { 127.0.0.1; 10.0.0.1; };     // adjust to your IP
    listen-on-v6 { none; };
    version "not disclosed";
};

zone "lab.internal" {
    type master;
    file "lab.internal.zone";
    notify no;
};

zone "0.0.10.in-addr.arpa" {
    type master;
    file "10.0.0.rev";
    notify no;
};
```

**2.2 Create the zone files**

Zone data on Rocky/RHEL lives under `/var/named/`, owned by the `named` user/group - not `/etc/bind/` as on Debian-family systems.

Create `/var/named/lab.internal.zone`:

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

Create `/var/named/10.0.0.rev`:

```
$TTL 3600
@   IN  SOA  ns1.lab.internal. admin.lab.internal. (
            2024010101 3600 900 604800 300 )

    IN  NS   ns1.lab.internal.

1   IN  PTR  ns1.lab.internal.
10  IN  PTR  www.lab.internal.
20  IN  PTR  mail.lab.internal.
```

Set correct ownership and let SELinux relabel the files to their expected context:

```bash
sudo chown root:named /var/named/lab.internal.zone /var/named/10.0.0.rev
sudo chmod 640 /var/named/lab.internal.zone /var/named/10.0.0.rev
sudo restorecon -Rv /var/named
```

{: .note }
Rocky 9 enforces SELinux by default. Zone files created directly under `/var/named` normally pick up the `named_zone_t` context automatically via the directory's default file context, but `restorecon` makes that explicit rather than hoping it happened. If `named` ever refuses to load a zone file with a permissions-looking error that `ls -lZ` doesn't explain, check `sudo ausearch -m avc -ts recent` for an SELinux denial before assuming it's a Unix-permissions problem - `ausearch` is part of the `audit` subsystem you'll build persistent detection rules with in a later lab, but it's already running by default and surfacing AVC denials right now.

**2.3 Validate and start**

```bash
sudo named-checkconf
sudo named-checkzone lab.internal /var/named/lab.internal.zone
sudo named-checkzone 0.0.10.in-addr.arpa /var/named/10.0.0.rev
sudo systemctl enable --now named
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload
```

**2.4 Test resolution**

Verify that every record you configured actually resolves against your own server: the `www` A record, the `mail` MX record, the `ftp` CNAME, the reverse (PTR) lookup for `10.0.0.10`, and the TXT records. Record the output of all five checks in your notes, and confirm the CNAME resolves to `www.lab.internal.` and the PTR lookup returns `www.lab.internal.`.

**2.5 Introduce and diagnose an error**

Temporarily break the zone: change the SOA serial to a lower value than the current serial (e.g., `2020010101`). Reload named, then query the `www` record again and observe what happens.

Document the behavior in your notes. Explain why DNS caching can cause stale records to persist even after a zone file correction.

Restore the correct serial and reload again.

**Alternative DNS server implementations**

BIND is what this lab runs, but it's one of several production-grade authoritative nameservers, and picking one is a real architectural decision, not just a matter of taste:

| | Model | Strength | Weakness |
|---|---|---|---|
| BIND (this lab) | Authoritative + recursive-capable | The reference implementation - ubiquitous, exhaustively documented, what most certs and vendor docs assume | Historically the most CVE-heavy nameserver of the major options; config syntax (zone statements, ACLs, views) is dense |
| PowerDNS | Authoritative (SQL-backed) | Zones live in MySQL/PostgreSQL instead of flat files - trivial to manage programmatically or from a web UI, scales well for multi-tenant hosting | Adds a database dependency where BIND needs none; "just edit a text file" simplicity is gone |
| Knot DNS | Authoritative-only | Built for raw performance - very fast zone reloads and transfers, modern codebase | Smaller community and ecosystem than BIND; fewer third-party integrations |
| Unbound | Recursive/validating only | Lightweight, security-focused, does one job (resolving on behalf of clients) very well | Not authoritative at all - it's the *other* half of the DNS architecture, not a substitute for this lab's role |
| CoreDNS | Authoritative/recursive via plugin chain | Go-based, the default DNS server for Kubernetes, easy to extend with plugins | Assumes a containerized/cloud-native operational model; less natural fit for a traditional zone-file-driven enterprise host |

Notice this server's config sets `recursion no;`. That's not incidental - an authoritative server that also answers arbitrary recursive queries for anyone who asks becomes two attack surfaces instead of one: it's a target for cache-poisoning (recursive resolvers cache and trust answers in a way authoritative-only servers don't) and it can be abused as a DNS amplification reflector in a DDoS against a third party. Splitting the authoritative role (this box) from the recursive-resolver role (something like Unbound, running separately for actual client resolution) is a deliberate hardening boundary, not an accident of this config.

Consider: what specific attack gets easier if this server also had `recursion yes;` and answered recursive queries from any client on the internet?

---

### Part 3 - NTP with Chrony

Rocky 9 ships with `chrony` installed and running as the default time client - you're reconfiguring it into an internal stratum-2 server, not installing something new.

**3.1 Configure as client and internal stratum-2 server**

Edit `/etc/chrony.conf` (Rocky/RHEL keeps this as a single file - no `/etc/chrony/` directory split like Debian-family systems use):

```
# Upstream NTP pools
pool 0.rocky.pool.ntp.org iburst maxsources 2
pool 1.rocky.pool.ntp.org iburst maxsources 2

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
sudo systemctl enable --now chronyd
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

**3.2 Verify synchronization**

Verify chrony is actually synchronized and serving time correctly. Record in your notes: Reference ID, Stratum, System time offset, RMS offset, Frequency error.

**3.3 Test client synchronization**

If you have access to a second VM, verify it can sync against your server at 10.0.0.1. If not, note in your notes file how you'd confirm a remote client is syncing against this server without physical access to that client.

Explain in your notes why NTP accuracy matters for: (a) Kerberos authentication, (b) log forensics, (c) TLS certificate validation.

**3.4 PTP vs NTP**

Chrony gets this lab's DNS/log-correlation/Kerberos-skew needs comfortably, but it isn't the only time-sync protocol you'll encounter in production. The Precision Time Protocol (IEEE 1588, PTP) solves a related but distinct problem, and it's worth understanding where each one fits:

| | NTP (chrony) | PTP (IEEE 1588) |
|---|---|---|
| Typical accuracy | Low single-digit milliseconds over a WAN, sub-millisecond on a clean LAN | Sub-microsecond, even nanosecond, with hardware timestamping |
| Timestamping | Software timestamps, taken in the OS network stack | Hardware timestamps, taken at the NIC as the packet crosses the wire |
| Topology | Client-server (or peer) polling against pool/upstream servers | Master-slave, typically within a single administrative LAN or dedicated PTP domain |
| Hardware requirements | None - runs on any NIC | Needs PTP-aware NICs/switches for hardware timestamping to realize its accuracy advantage; software-only PTP loses most of the benefit |
| Common use cases | General enterprise time sync: Kerberos, TLS validity, log correlation, cron | Financial trading (MiFID II timestamp requirements), telecom (5G/LTE base station sync), industrial control systems, broadcast/AV sync |

The reason this lab configures chrony and not PTP: PTP's accuracy advantage depends on hardware timestamping support in the NIC and switches along the path, which a lab VM's virtual NIC doesn't provide - running `ptp4l` here would fall back to software timestamping and land in roughly the same accuracy range as NTP anyway, without teaching the thing that actually makes PTP worth deploying. In your notes, write a short paragraph (3-5 sentences) comparing PTP and NTP and explaining, in your own words, why this lab's stratum-2 chrony server is the right tool for DNS/Kerberos/log-correlation time sync, and under what circumstances you'd reach for PTP instead.

It's also worth knowing chrony isn't the only NTP implementation. The older `ntpd` (from the reference `ntp` package) was the standard for decades and is still common on legacy systems, but it struggles with the exact conditions a modern host actually lives in: intermittent connectivity, VMs that get paused/resumed, and networks that only reach an upstream server occasionally. Chrony was designed for those cases - it converges faster after a long gap and steps the clock more gracefully - which is exactly why Rocky (like most current distros) ships it as the default instead of `ntpd`. Separately, note that neither protocol as configured here authenticates *who* it's syncing time from - a spoofed NTP source can quietly skew a host's clock. NTS (Network Time Security) is the newer standard that adds that authentication on top of NTP, conceptually the same problem TSIG solves for DNS zone transfers in the Graduate Extension below.

---

### Part 4 - POSIX ACLs on DNS Configuration & Shared Data

Lay out the two role-differentiated storage areas this part will assign access to:

```bash
sudo mkdir -p /data/shared /data/builds
sudo chown nobody:nobody /data/shared
sudo chmod 1777 /data/shared
```

The default Unix permissions on `/var/named` and `/data` are insufficient for multi-role access - alice, bob, and carol each need a different slice of access to the *same* locations you just built. Layer ACLs on top of the existing service-managed permissions rather than re-`chmod`ing these live system directories:

```bash
# Alice (sysadmin): full access everywhere
sudo setfacl -R -m u:alice:rwx /var/named /data
sudo setfacl -R -d -m u:alice:rwx /var/named /data

# Bob (DNS operator): full access to zone files (his job), read+execute on
# the general share, no access to build artifacts
sudo setfacl -m u:bob:rwx /var/named
sudo setfacl -d -m u:bob:rwx /var/named
sudo setfacl -m u:bob:r-x /data/shared
# No ACL entry for bob on /data/builds = no access

# Carol (auditor): read-only across every location
sudo setfacl -m u:carol:r-x /var/named
sudo setfacl -m u:carol:r-x /data/shared
```

Verify the ACLs landed the way you intended on each path.

**Verify access controls work:**

Confirm bob can write a zone file, and carol cannot write anywhere. Document each test result in your notes.

**POSIX ACLs vs. the alternatives**

ACLs aren't the only way to solve "three people need three different levels of access to the same path," and it's worth knowing where they sit relative to the other options:

| | Layer | Strength | Weakness |
|---|---|---|---|
| Plain Unix permissions | DAC | Universal, zero extra tooling, everyone already understands owner/group/other | Can only express one non-owner role (the group) - can't give bob and carol *different* access to the same path without duplicating directories |
| POSIX ACLs (this lab) | DAC | Per-user and per-group grants layered on top of the base permissions, without restructuring the filesystem | Still discretionary - the file owner (or root) can always override or strip an ACL; not portable to every filesystem |
| SELinux type enforcement | MAC | Enforced by policy at the kernel level, even against the file owner and root - an ACL can be right and SELinux can still block the access | Real authoring overhead (writing/compiling policy), steep learning curve compared to `setfacl` |
| NFSv4 ACLs | DAC (network) | Finer-grained than POSIX ACLs, with Windows-ACL-style inheritance semantics | Requires an NFSv4-aware export and filesystem - moot for this lab since it no longer exports anything over the network |

The distinction between the top two rows and SELinux matters more than it looks: DAC (discretionary access control - plain permissions and ACLs alike) is controlled by the resource's owner, which means anything running *as* alice, bob, or root can grant itself more access. MAC (mandatory access control - SELinux) is controlled by policy that even the owner can't override. This lab's zone-file directory already carries an SELinux context (`named_zone_t`, from Part 2) alongside the ACLs you just set - the two layers are complementary, not redundant, and a hardened production host relies on both rather than treating ACLs as sufficient on their own.

Consider: carol has read-only POSIX ACL access to `/var/named`. Describe a scenario where that DAC-layer protection alone is insufficient, and only a MAC-layer control like SELinux would actually stop the threat.

---

## Deliverables

Submit a single notes file (Markdown or plain text) logging every command you ran across Parts 1-4, in order, along with your own notes on what happened. This is where every "record," "document," and "explain" prompt in the Procedure above ends up - the notes file *is* the report. Your hands-on configuration work itself is autograded directly against the live system, so the notes file doesn't need separate screenshots or copy-pasted proof of success - it needs the command history and your reasoning.

At minimum, your notes should capture:

- The sudoers file contents for `10-sysadmins`, `20-operators`, and `30-auditors`, with a line-by-line explanation of what each rule does
- Results of every access-control verification test (sudo and ACL) from Parts 1 and 4
- The broken-serial DNS behavior you observed in Part 2.5, and your explanation of why DNS caching causes it
- Your written answers from Part 3: why NTP accuracy matters for Kerberos/forensics/TLS, and the PTP vs NTP comparison paragraph

---

## Grading

Autograded from your live system and submitted notes file - the point values below reflect what's checked automatically, not a manual rubric.

| Item | Points |
|------|--------|
| BIND DNS - forward zone with all record types | 12 |
| BIND DNS - reverse zone and broken-serial diagnosis | 8 |
| Chrony - configuration/synchronization evidence, and PTP vs NTP comparison | 26 |
| Sudo policy - least-privilege roles verified | 22 |
| ACLs - role-based access across zone/data paths verified | 32 |
| **Total** | **100** |

---

## Graduate Extension - Graduate Students Only

### TSIG-Secured DNS Zone Transfer

In production, DNS zone transfers between primary and secondary servers must be authenticated to prevent zone data exfiltration. Configure TSIG (Transaction Signature) authentication for a simulated zone transfer:

1. Generate a TSIG key: `tsig-keygen -a hmac-sha256 transfer-key`
2. Add the key to both `named.conf` files (primary and secondary, or simulate with two named instances on different ports).
3. Restrict zone transfers: `allow-transfer { key transfer-key; };`
4. Test authenticated transfer: `dig -y hmac-sha256:transfer-key:... AXFR lab.internal @127.0.0.1`
5. Test unauthenticated transfer (should be refused): `dig AXFR lab.internal @127.0.0.1`

Document the output of both transfer attempts and explain how TSIG prevents DNS cache poisoning attacks compared to IP-based restrictions alone.



[← Back to Labs]({{ site.baseurl }}/labs/)
