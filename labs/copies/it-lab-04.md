---
title: "IT LAB 4 - DNSSEC & Email Security Configuration"
parent: Labs
nav_order: 4
---

# IT LAB 4 - DNSSEC & Email Security Configuration
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Sign a DNS zone with DNSSEC using both KSK and ZSK keys, including DS record delegation
- Configure and validate SPF, DKIM, and DMARC for an email domain
- Implement DMARC reporting and interpret aggregate report data
- Analyze DNSSEC chain of trust validation and diagnose common DNSSEC failures
- Assess the security posture of a third-party domain using available DNS tooling

---

## Tools Required

- This lab reuses `lab02-rocky01`, the Rocky Linux 9 VM with BIND already configured from Lab 2 - no new VM needed
- Packages: `bind-utils`, `bind-dnssec-utils`, `opendkim`, `opendkim-tools` (`opendkim` ships via EPEL - `sudo dnf install -y epel-release` first if it isn't already enabled)
- Online tools: MXToolbox, DMARC Analyzer, dnsviz.net (for validation)

---

## Background

DNSSEC (DNS Security Extensions) adds cryptographic signatures to DNS responses, preventing cache poisoning and man-in-the-middle attacks. The chain of trust flows from the root zone (signed by ICANN) through TLD registrars to individual zone operators. A break anywhere in the chain causes SERVFAIL for validating resolvers.

SPF, DKIM, and DMARC form the email authentication triad: SPF specifies authorized senders, DKIM signs message content, DMARC tells receivers what to do with failures and requests reports. Together they prevent domain spoofing, phishing, and unauthorized bulk mail.

---

## Procedure

### Part 1 - DNSSEC Zone Signing

**1.1 Generate KSK and ZSK**

```bash
sudo mkdir -p /var/named/keys && cd /var/named/keys

# Zone Signing Key (ZSK) - shorter, rotated more frequently
sudo dnssec-keygen -a RSASHA256 -b 1024 -n ZONE lab.internal

# Key Signing Key (KSK) - longer, rotated rarely
sudo dnssec-keygen -a RSASHA256 -b 2048 -n ZONE -f KSK lab.internal

sudo chown -R named:named /var/named/keys
ls -la /var/named/keys/
```

Record the key IDs (the numbers in the filenames, e.g., `Klab.internal.+008+12345`).

**1.2 Configure auto-signing in named.conf**

Rocky ships BIND's configuration as a single `/etc/named.conf` (see Lab 2, Part 3.1) - update the `lab.internal` zone block you already created there rather than looking for a separate `named.conf.local`:

```
zone "lab.internal" {
    type master;
    file "/var/named/lab.internal.zone.signed";
    key-directory "/var/named/keys";
    auto-dnssec maintain;
    inline-signing yes;
    notify no;
};
```

**1.3 Sign the zone**

```bash
# Add $INCLUDE directives for both keys to the zone file
cd /var/named
sudo tee -a lab.internal.zone <<'EOF'
$INCLUDE /var/named/keys/Klab.internal.+008+XXXXX.key   ; ZSK public key
$INCLUDE /var/named/keys/Klab.internal.+008+YYYYY.key   ; KSK public key
EOF

# Sign the zone (manual approach for learning)
sudo dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -c1-16) \
    -N INCREMENT -o lab.internal -t \
    /var/named/lab.internal.zone \
    /var/named/keys/Klab.internal.+008+XXXXX.private \
    /var/named/keys/Klab.internal.+008+YYYYY.private
sudo restorecon -Rv /var/named
```

This creates `lab.internal.zone.signed`. Update the zone file reference:

```bash
sudo systemctl reload named
```

**1.4 Verify DNSSEC signatures**

```bash
# Query with DNSSEC DO bit
dig @127.0.0.1 lab.internal SOA +dnssec +multiline

# Verify RRSIG records exist
dig @127.0.0.1 www.lab.internal A +dnssec | grep RRSIG

# Check DS record hash (for delegation)
dig @127.0.0.1 lab.internal DNSKEY | dnssec-dsfromkey -f - lab.internal

# Validate the chain
delv @127.0.0.1 lab.internal SOA +vtrace
```

Document the DNSKEY records (KSK and ZSK), the RRSIG for the A record, and the DS record hash.

**1.5 Simulate a DNSSEC validation failure**

Manually modify a signed record without re-signing:

```bash
# Edit lab.internal.zone.signed - change www A record from 10.0.0.10 to 10.0.0.99
sudo sed -i 's/10.0.0.10/10.0.0.99/' /var/named/lab.internal.zone.signed
sudo rndc reload
```

Query with validation:

```bash
dig @127.0.0.1 www.lab.internal A +dnssec
delv @127.0.0.1 www.lab.internal A +vtrace
```

Document the error (should see SERVFAIL or BOGUS). Explain why this protection matters for DNS cache poisoning prevention. Restore the original value and re-sign.

**1.6 Key rollover planning**

ZSKs should be rotated every 3 months; KSKs every year. Document the ZSK rollover procedure:
1. Generate new ZSK
2. Pre-publish new ZSK in zone (both old and new keys active)
3. Wait one TTL period (for caches to pick up new key)
4. Re-sign zone with new ZSK only
5. Remove old ZSK after another TTL period

Explain why skipping the pre-publication step causes validation failures for clients that cached the old key.

---

### Part 2 - SPF Configuration

SPF (Sender Policy Framework) publishes a list of authorized mail servers for your domain.

**2.1 Create SPF record**

For `lab.internal`, create a TXT record authorizing only your mail server (10.0.0.20):

```
lab.internal. IN TXT "v=spf1 ip4:10.0.0.20 -all"
```

Add this to `/var/named/lab.internal.zone` and reload.

**2.2 Test SPF lookup**

```bash
dig @127.0.0.1 lab.internal TXT +short | grep spf
```

**2.3 Interpret qualifiers**

Write a table explaining each SPF qualifier (`+all`, `-all`, `~all`, `?all`) and when to use each. Which is most restrictive? Which is the DMARC-compatible choice for a domain that wants to block spoofing?

**2.4 SPF include chains**

Explain the SPF 10-lookup limit and why complex organizations (using multiple email providers like GSuite + SendGrid + Salesforce) commonly exceed it. What tool would you use to analyze and flatten an SPF record to stay under the limit?

---

### Part 3 - DKIM Configuration

DKIM (DomainKeys Identified Mail) signs outgoing messages so receivers can verify they haven't been tampered with.

**3.1 Generate DKIM keys**

```bash
sudo dnf install -y opendkim opendkim-tools

# Generate a 2048-bit RSA key pair
sudo mkdir -p /etc/opendkim/keys/lab.internal
sudo opendkim-genkey -b 2048 -d lab.internal -D /etc/opendkim/keys/lab.internal \
    -s mail -v

# Set permissions
sudo chown -R opendkim:opendkim /etc/opendkim
sudo chmod 700 /etc/opendkim/keys/lab.internal
sudo chmod 600 /etc/opendkim/keys/lab.internal/mail.private

cat /etc/opendkim/keys/lab.internal/mail.txt
```

**3.2 Publish DKIM DNS record**

The `mail.txt` file contains the TXT record to publish. Add to `/var/named/lab.internal.zone`:

```
mail._domainkey.lab.internal. IN TXT "v=DKIM1; k=rsa; p=MIIBIjANBgkq..."
```

The `p=` value is the base64-encoded public key. After adding, reload BIND.

**3.3 Configure OpenDKIM**

Edit `/etc/opendkim.conf`:

```
Mode                    sv
Syslog                  yes
LogWhy                  yes
Domain                  lab.internal
KeyFile                 /etc/opendkim/keys/lab.internal/mail.private
Selector                mail
Socket                  inet:12301@localhost
PidFile                 /run/opendkim/opendkim.pid
OversignHeaders         From
```

```bash
sudo systemctl enable --now opendkim
sudo systemctl status opendkim
```

**3.4 Verify DKIM signing**

```bash
# Verify key is accessible
sudo opendkim-testkey -d lab.internal -s mail -vvv

# Test DNS lookup for DKIM selector
dig @127.0.0.1 mail._domainkey.lab.internal TXT +short
```

Explain: What does DKIM protect against? Does it prevent an attacker from registering `lab-internal.com` and sending phishing emails that look like they come from `lab.internal`? What mechanism closes this gap?

---

### Part 4 - DMARC Configuration and Reporting

DMARC (Domain-based Message Authentication, Reporting and Conformance) ties SPF and DKIM together with a policy and reporting mechanism.

**4.1 Create DMARC record**

```bash
# Stage 1: Monitor-only policy (p=none) with reporting
_dmarc.lab.internal. IN TXT "v=DMARC1; p=none; rua=mailto:dmarc-reports@lab.internal; ruf=mailto:dmarc-forensics@lab.internal; sp=none; adkim=r; aspf=r; pct=100; fo=1"
```

Add to BIND zone and reload.

**4.2 DMARC policy progression**

Document the recommended DMARC deployment stages:

| Stage | Policy | Purpose | Duration |
|-------|---------|---------|---------|
| 1 | `p=none` | Monitoring - collect data without blocking | 2-4 weeks |
| 2 | `p=quarantine; pct=10` | Quarantine 10% of failing mail | 2 weeks |
| 3 | `p=quarantine; pct=100` | Quarantine all failing mail | 4 weeks |
| 4 | `p=reject` | Reject all failing mail | Production state |

Explain why jumping directly to `p=reject` without the monitoring phase is dangerous. Give a scenario where `p=reject` causes legitimate mail delivery failures.

**4.3 Interpret a DMARC aggregate report**

Analyze the following simulated DMARC aggregate report (RUA) excerpt:

```xml
<record>
  <row>
    <source_ip>203.0.113.45</source_ip>
    <count>1247</count>
    <policy_evaluated>
      <disposition>none</disposition>
      <dkim>fail</dkim>
      <spf>fail</spf>
    </policy_evaluated>
  </row>
  <row>
    <source_ip>198.51.100.12</source_ip>
    <count>3</count>
    <policy_evaluated>
      <disposition>none</disposition>
      <dkim>pass</dkim>
      <spf>pass</spf>
    </policy_evaluated>
  </row>
</record>
```

Answer:
1. What does the first record indicate? Is 203.0.113.45 likely a legitimate sender?
2. If DMARC policy were `p=reject` instead of `p=none`, what would happen to those 1,247 messages?
3. What investigation steps would you take before escalating to `p=quarantine`?

---

### Part 5 - Third-Party Domain Security Assessment

Assess the DNS security posture of **three real-world domains** (use publicly available tools):

For each domain, document:
- SPF record: present? qualifier? `include:` chain complexity?
- DKIM: can you find any published selector? (hint: try `default._domainkey`, `google._domainkey`)
- DMARC: policy level? reporting configured?
- DNSSEC: signed? DS record in parent zone?

Use: `dig`, `nslookup`, MXToolbox (mxtoolbox.com), and dnsviz.net.

Suggested domains to assess: A large university (.edu), a government agency (.gov), and a major retailer. Do not use your own organization.

Rate each domain's email security posture: Strong / Moderate / Weak. Justify each rating.

---

## Deliverables

1. DNSSEC: zone signing commands + DNSKEY/RRSIG/DS record output + validation failure demonstration
2. ZSK rollover procedure (6 steps) + explanation of pre-publication requirement
3. SPF record + qualifier comparison table + include chain discussion
4. DKIM key generation + DNS record + OpenDKIM config + testkey output
5. DMARC record + policy progression table + aggregate report analysis (3 questions)
6. Third-party domain assessment table (3 domains)

---

## Grading

| Item | Points |
|------|--------|
| DNSSEC signed zone with validation + failure demo | 30 |
| SPF configuration and explanation | 15 |
| DKIM configuration and verification | 25 |
| DMARC configuration, policy table, report analysis | 20 |
| Third-party domain assessment | 10 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
