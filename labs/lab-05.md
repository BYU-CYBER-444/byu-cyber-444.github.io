---
title: "LAB 5 - PKI & Certificate Management"
parent: Labs
nav_order: 5
---

# LAB 5 - PKI & Certificate Management
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


---

## Objectives

- Build a two-tier PKI (offline Root CA → online Intermediate CA) using OpenSSL with a proper configuration file
- Issue a server certificate with correct Subject Alternative Names (SANs) and Extended Key Usage
- Configure Nginx for HTTPS with TLS 1.2/1.3 only, hardened cipher suite, and HSTS
- Implement certificate revocation: revoke a certificate, generate a CRL, and verify revoked certs are rejected
- Validate the complete TLS configuration with `testssl.sh`
- Issue and deploy a real certificate for your own Proxmox nodes' web UI, eliminating the self-signed warning

---

## Tools Required

- Your instructor has provisioned a Rocky 9 VM for this lab, `lab05-pki01`. Your username on it is your Net ID, and your password is the one emailed to you at the start of the semester. It's reachable at `172.19.x.18`.

---


## Background

Every certificate you've ever clicked past a browser warning for exists because some part of a PKI trust chain was misconfigured, expired, or never validated - and every certificate that worked silently exists because someone got the chain, the extensions, and the revocation path right. This lab builds a real two-tier CA hierarchy (not a single self-signed cert) specifically because that's the structure production PKI actually uses: an offline Root CA that almost never touches a network, and an online Intermediate CA that does the day-to-day signing, so that a compromise of the busy, exposed tier doesn't automatically compromise the trust anchor everything else depends on.

---





## Procedure

### Part 1 - OpenSSL Configuration Files

The default `/etc/ssl/openssl.cnf` is insufficient for a proper PKI. Create dedicated config files for each CA tier.

Replace `172.19.x.18` in `[alt_names]` with your own VM's actual address (`x` = your subnet's third octet - see Tools Required above).

Create the directory structure:

| Step | Action | Where | Purpose |
|---|---|---|---|
| 1 | Create the base directory tree | `~/pki/` with subfolders `root-ca`, `intermediate-ca`, and `server` | Gives each entity in the chain (root CA, intermediate CA, server) its own workspace |
| 2 | Add four subfolders to each entity | `certs`, `private`, `crl`, `newcerts` inside each of the three folders (12 directories total) | `certs` holds issued certificates, `private` holds private keys, `crl` holds certificate revocation lists, and `newcerts` holds a copy of each certificate the CA signs, named by serial number |
| 3 | Restrict access to private key folders | `root-ca/private` and `intermediate-ca/private` | Sets owner-only permissions (read/write/execute for you, nothing for anyone else) so CA keys can't be read by other users on the system |
| 4 | Initialize the serial number counter | `serial` file in `root-ca` and `intermediate-ca` | Starts certificate serial numbers at 1000; the CA increments this for each certificate it signs |
| 5 | Initialize the CRL number counter | `crlnumber` file in `root-ca` and `intermediate-ca` | Starts revocation list versioning at 1000, so each new CRL gets a higher number than the last |
| 6 | Create an empty certificate database | `index.txt` in `root-ca` and `intermediate-ca` | Gives each CA a flat-file record of every certificate it issues, with status and expiry; it starts empty |

**Notes:**
- Steps 4-6 apply only to the two CAs, since they issue certificates. The `server` folder is just an end entity, so it gets no counters or database.
- The `server/private` folder is not locked down by this setup, so you may want to restrict it too.



Create `~/pki/root-ca/openssl-root.cnf`:
```
[ca]                                             # Section listing which CA settings to use
default_ca = CA_default                          # Use the [CA_default] section when running `openssl ca`

[CA_default]                                     # Main settings for the CA that signs certificates
dir             = /root/pki/root-ca              # Base directory; reused below as $dir
certs           = $dir/certs                     # Where issued certificates are stored
crl_dir         = $dir/crl                       # Where certificate revocation lists are stored
new_certs_dir   = $dir/newcerts                  # Where a copy of each newly signed cert goes (named by serial)
database        = $dir/index.txt                 # Flat-file database of every cert issued and its status
serial          = $dir/serial                    # File holding the next certificate serial number
RANDFILE        = $dir/private/.rand             # Random seed file (obsolete in OpenSSL 1.1.1+, safe to remove)
private_key     = $dir/private/ca.key.pem        # The CA's private key, used to sign certificates
certificate     = $dir/certs/ca.cert.pem         # The CA's own certificate
crlnumber       = $dir/crlnumber                 # File holding the next CRL version number
crl             = $dir/crl/ca.crl.pem            # Output path for the generated CRL
crl_extensions  = crl_ext                        # Extensions section applied to generated CRLs
default_crl_days = 30                            # How many days a CRL is valid before it needs refreshing
default_md      = sha256                         # Hash algorithm used when signing certificates
name_opt        = ca_default                     # How subject names are displayed during signing
cert_opt        = ca_default                     # How certificate details are displayed during signing
default_days    = 90                             # Default validity period for certs signed by this CA (matches the 90-day leaf-cert policy this lab uses throughout - see Part 4's note)
preserve        = no                             # Let OpenSSL reorder subject fields to match the policy
policy          = policy_strict                  # Which naming policy to enforce on signing requests

[policy_strict]                                  # Rules for the subject fields in requests this CA signs
countryName            = match                   # Must be identical to the CA's country
stateOrProvinceName    = match                   # Must be identical to the CA's state/province
organizationName       = match                   # Must be identical to the CA's organization
organizationalUnitName = optional                # May be included, but not required
commonName             = supplied                # Required, any value allowed
emailAddress           = optional                # May be included, but not required

[req]                                            # Settings for `openssl req` (creating keys and CSRs)
default_bits        = 4096                       # RSA key size in bits
distinguished_name  = req_distinguished_name     # Section defining which subject fields to prompt for
string_mask         = utf8only                   # Encode subject strings as UTF-8
default_md          = sha256                     # Hash algorithm used to sign the request or self-signed cert
x509_extensions     = v3_ca                      # Extensions applied when creating a self-signed cert (the root)

[req_distinguished_name]                         # The prompts shown when creating a request
countryName                    = <Country Name (2 letter code)>   # Prompt text for country
stateOrProvinceName            = <State or Province Name>         # Prompt text for state/province
localityName                   = <Locality Name>                  # Prompt text for city
organizationName               = <Organization Name>              # Prompt text for organization
organizationalUnitName         = <Organizational Unit Name>       # Prompt text for department/unit
commonName                     = <Common Name>                    # Prompt text for the name (CA name or hostname)
emailAddress                   = <Email Address>                  # Prompt text for contact email

[v3_ca]                                          # Extensions for the root CA certificate
subjectKeyIdentifier   = hash                    # Adds a unique ID (hash) of this cert's public key
authorityKeyIdentifier = keyid:always,issuer     # Identifies the issuing key; for a root, that is itself
basicConstraints       = critical, CA:true       # Marks this cert as a CA; clients must honor this
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign   # Allowed uses: sign data, sign CRLs, sign certificates

[v3_intermediate_ca]                             # Extensions applied when the root signs the intermediate CA
subjectKeyIdentifier   = hash                    # Adds a unique ID (hash) of the intermediate's public key
authorityKeyIdentifier = keyid:always,issuer     # Points back to the root CA's key that signed this cert
basicConstraints       = critical, CA:true, pathlen:0   # Is a CA, but can only issue end-entity certs, not more CAs
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign   # Allowed uses: sign data, sign CRLs, sign certificates

[server_cert]                                    # Extensions for server (TLS) certificates
basicConstraints       = CA:FALSE                # This cert cannot sign other certificates
nsCertType             = server                  # Legacy Netscape flag marking it as a server cert (deprecated)
nsComment              = "OpenSSL Generated Server Certificate"   # Free-text comment embedded in the cert (deprecated)
subjectKeyIdentifier   = hash                    # Adds a unique ID (hash) of the server's public key
authorityKeyIdentifier = keyid,issuer:always     # Identifies the signing CA by key ID and issuer name
keyUsage               = critical, digitalSignature, keyEncipherment   # Allowed uses: sign handshakes, encrypt key exchange
extendedKeyUsage       = serverAuth              # Limits the cert to TLS server authentication
subjectAltName         = @alt_names              # Names the cert is valid for, defined in [alt_names]

[alt_names]                                      # Hostnames and IPs the server cert covers
DNS.1 = lab5.local                               # First valid hostname
DNS.2 = www.lab5.local                           # Second valid hostname
IP.1  = 172.19.x.18                              # Valid IP address (replace x with the real octet)

[crl_ext]                                        # Extensions added to generated CRLs
authorityKeyIdentifier = keyid:always            # Records which CA key signed the CRL
```

### Part 2 - Create the Root CA

| Step | Action | Key details | Purpose |
|---|---|---|---|
| 1 | Generate the Root CA private key | 4096-bit RSA, encrypted with AES-256; you'll be prompted for a passphrase. Saved to `root-ca/private/ca.key.pem` | Creates the key that anchors your entire trust chain. The passphrase means a stolen key file is useless without it |
| 2 | Lock down the private key | Permissions set to `400` (read-only, owner only) | Prevents accidental modification or deletion and blocks other users from reading it |
| 3 | Create the self-signed Root CA certificate | Uses `openssl-root.cnf`, the root key, and the `v3_ca` extensions. SHA-256 signature, valid 3650 days (10 years). Saved to `root-ca/certs/ca.cert.pem` | Produces the root certificate. It is self-signed because a root has no higher authority; it vouches for itself, and clients trust it because you install it manually |
| 4 | Set the subject identity | `-subj` supplies Country `US`, State `Utah`, Organization `CYBER444 Lab`, Common Name `CYBER444 Root CA` | Skips the interactive prompts and sets the name embedded in the certificate |
| 5 | Make the certificate world-readable | Permissions set to `444` (read-only for everyone) | The certificate is public information and needs to be distributed to clients, unlike the key |
| 6 | Verify the certificate | Prints the certificate details and filters for Issuer, Subject, validity dates, `CA:true`, and `pathlen` | Confirms the issuer and subject are identical (self-signed), the dates span 10 years, and it is marked as a CA |

**Notes:**
- The `-days 3650` on the command line overrides the `default_days = 90` in your config file, which is what you want for a root: roots stay long-lived and offline (rotating one means re-distributing trust to every device that has it installed), while leaf certs get the short, frequently-rotated lifetime instead - see Part 4's note on why.
- Because the config uses `policy_strict`, the `C`, `ST`, and `O` values used here (`US`, `Utah`, `CYBER444 Lab`) must be reused exactly on the intermediate and server certificates, or signing will fail.
- The verify step likely won't show `pathlen` for the root, since only the intermediate sets it. Seeing nothing for that term is normal.
- The `-subj` omits locality and email, which is fine since both are optional.




### Part 3 - Create the Intermediate CA

| Step | Action | Key details | Purpose |
|---|---|---|---|
| 1 | Generate the Intermediate CA private key | 4096-bit RSA, encrypted with AES-256 (you'll be prompted for a passphrase). Saved to `intermediate-ca/private/intermediate.key.pem` | Creates the key the intermediate uses to sign server certificates. The passphrase protects it if the file is stolen |
| 2 | Lock down the private key | Permissions set to `400` (read-only, owner only) | Prevents other users from reading the key and guards against accidental changes |
| 3 | Create the certificate signing request (CSR) | Uses `openssl-root.cnf` and the intermediate key. SHA-256, subject `US`, `Utah`, `CYBER444 Lab`, CN `CYBER444 Intermediate CA`. Saved to `intermediate-ca/intermediate.csr.pem` | Packages the intermediate's public key and identity into a request for the root to sign |
| 4 | Sign the CSR with the Root CA | Uses `openssl-root.cnf` with the `v3_intermediate_ca` extensions, SHA-256, valid 1095 days (3 years), `-notext`. Saved to `intermediate-ca/certs/intermediate.cert.pem` | Makes the root vouch for the intermediate. The extensions mark it as a CA with `pathlen:0`, so it can issue end-entity certs but not further sub-CAs. `-notext` keeps the human-readable dump out of the file |
| 5 | Build the chain file | Concatenates the intermediate cert first, then the root cert, into `intermediate-ca/certs/ca-chain.cert.pem` | Gives servers a single file to present to clients so they can build the path back to the trusted root |
| 6 | Verify the chain | Checks the intermediate cert against the root cert using `-CAfile` | Confirms the intermediate was correctly signed by the root; a successful check prints `OK` |

**Notes:**
- Steps 3 and 4 both use the root config. That works for the CSR because `openssl req` only needs the `[req]` and subject settings, and it is required for signing because the root is the issuer.
- This version names the files `intermediate.key.pem` and `intermediate.cert.pem`, while my earlier example used `ca.key.pem` and `ca.cert.pem`. If you create an `openssl-intermediate.cnf`, make sure its `private_key` and `certificate` paths match whichever names you keep.
- The signing step will only succeed if the CSR's country, state, and organization match the root's (`policy_strict`), which they do here.
- **Validity:** 1095 days (3 years) sits between the root's 10-year lifetime and the leaf certs' 90 days - a common enterprise-PKI range for an intermediate. It's the CA actually doing day-to-day signing, so it's rotated more often than the offline root, but still far less often than the certs it issues.

### Part 4 - Issue a Server Certificate with SANs

The server certificate must include Subject Alternative Names (SANs) - modern browsers reject certificates without them.

| Step | Action | Key details | Purpose |
|---|---|---|---|
| 1 | Generate the server private key | 2048-bit RSA, **not** encrypted. Saved to `server/private/server.key.pem` | Creates the key the web server uses for TLS. It has no passphrase so the service can start unattended. 2048 bits is sufficient for a leaf certificate |
| 2 | Lock down the private key | Permissions set to `400` (read-only, owner only) | Stops other users from reading or altering the key. Since it is unencrypted, file permissions are its only protection |
| 3 | Create the CSR | Uses `openssl-root.cnf` and the server key. SHA-256, subject `US`, `Utah`, `CYBER444 Lab`, CN `lab5.local`. Saved to `server/server.csr.pem` | Packages the server's public key and identity into a request. SANs are not included here; they are added at signing time |
| 4 | Sign the CSR with the Intermediate CA | Uses the `server_cert` extensions, 90 days, SHA-256, `-notext`. `-keyfile` and `-cert` point to the intermediate's key and certificate. Saved to `server/certs/server.cert.pem` | Makes the intermediate vouch for the server. The `server_cert` section marks it as a non-CA and limits it to TLS server authentication, and it adds the SANs (`lab5.local`, `www.lab5.local`, and the IP) from `[alt_names]` |
| 5 | Verify the chain | Checks the server cert against `ca-chain.cert.pem` (intermediate + root) | Confirms the server cert links back to the trusted root through the intermediate. Expected output is `server.cert.pem: OK` |
| 6 | Inspect the SANs | Prints the certificate details and shows the five lines after "Subject Alternative" | Confirms the hostnames and IP made it into the certificate, since browsers reject certs without matching SANs |

**Notes:**
- **Wrong database:** the signing step uses `openssl-root.cnf`, so `dir` points to `root-ca`. That means OpenSSL uses the **root's** `index.txt`, `serial`, and `newcerts`, and records the server cert in the root's database even though the intermediate signs it. The cert still verifies, but the bookkeeping is wrong and revocation via the intermediate's CRL won't work. The cleaner fix is to use `openssl-intermediate.cnf` (with `dir` set to `intermediate-ca`, and `private_key` and `certificate` set to the `intermediate.*` filenames) and drop the `-keyfile` and `-cert` overrides.
- **Policy check:** `policy_strict` requires `C`, `ST`, and `O` to match the signing CA's certificate. They match here, so signing succeeds.
- **Placeholder IP:** `IP.1 = 172.19.x.18` must be replaced with a real address before signing, or OpenSSL will fail.
- **Passphrase prompt:** signing asks for the intermediate key's passphrase.
- **Validity:** 90 days matches Let's Encrypt's own default, and sits well ahead of where the CA/Browser Forum is taking *every* publicly-trusted cert - a 2023 ballot (SC-063) phases the max down from the old 398-day ceiling to 200 days (2026), 100 days (2027), and 47 days (2029). Short-lived leaf certs limit how long a stolen key stays useful, and force the renewal-automation habit production TLS increasingly requires. Part 7's Proxmox certs use the same 90-day policy.

### Part 5 - Configure Nginx with Hardened TLS

`ssl_certificate` is what Nginx actually sends to connecting clients during the TLS handshake - it must contain the leaf cert **and** the Intermediate CA cert, or clients that only trust the Root CA can't bridge the gap between the leaf and the root they trust (`ssl_trusted_certificate` below is only used for OCSP stapling/client-cert verification, it's never sent to clients):

```bash
sudo mkdir -p /etc/nginx/ssl
cat ~/pki/server/certs/server.cert.pem ~/pki/intermediate-ca/certs/intermediate.cert.pem > /tmp/server-chain.crt
sudo cp /tmp/server-chain.crt /etc/nginx/ssl/server.crt
rm /tmp/server-chain.crt
sudo cp ~/pki/intermediate-ca/certs/ca-chain.cert.pem /etc/nginx/ssl/ca-chain.crt
sudo cp ~/pki/server/private/server.key.pem /etc/nginx/ssl/server.key
sudo chmod 600 /etc/nginx/ssl/server.key
sudo chown nginx:nginx /etc/nginx/ssl/server.key
```

Create `/etc/nginx/conf.d/lab5.conf`:

```nginx
server {
    listen 443 ssl;
    server_name lab5.local;

    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_trusted_certificate /etc/nginx/ssl/ca-chain.crt;

    # TLS hardening
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:!aNULL:!eNULL:!EXPORT:!MD5:!RC4:!3DES';
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;

    # HSTS: tell browsers to use HTTPS for 1 year
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    root /var/www/html;
    index index.html;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name lab5.local;
    return 301 https://$host$request_uri;
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
echo "172.19.x.18 lab5.local" | sudo tee -a /etc/hosts   # replace x with your subnet's third octet
```

Trust the Root CA at the OS level on the VM itself (so `curl` on the VM succeeds) and verify. Rocky 9 uses `update-ca-trust`, not Debian/Ubuntu's `update-ca-certificates`:
```bash
sudo cp ~/pki/root-ca/certs/ca.cert.pem /etc/pki/ca-trust/source/anchors/lab-root-ca.crt
sudo update-ca-trust extract
curl https://lab5.local   # should succeed
curl http://lab5.local    # should redirect to HTTPS (302/301)
```

Note that this only makes `lab5.local` trusted *on the VM*. Any other device - including your own laptop's browser - still has no reason to trust this Root CA. Part 6 walks through fixing that.

### Part 6 - Trust the Root CA in Your Browser (Not Graded)

The `curl` checks above succeeded because you trusted the Root CA on the VM itself. A real browser has never heard of your lab's Root CA, so it will reject `lab5.local` outright and give you the security warning about the certificate. This section walks through that rejection, then fixes it the same way a real organization distributes its internal CA to employee devices.

This part happens entirely on your own laptop, so there's no way for us to check it automatically - **it isn't graded and there's nothing to submit for it.** Do it anyway; it's the whole point of the lab.

1. Add an entry on your computer hosts file for the website "172.19.x.18 lab5.local"
2. **Observe the untrusted warning.** In a real desktop browser (not curl), navigate to `https://lab5.local`. You should get a full-page warning ("Your connection is not private" / "Warning: Potential Security Risk"). Click through to view the certificate details and confirm the browser is complaining because it doesn't recognize `CYBER444 Root CA` as a trust anchor - not because anything about the cert itself is wrong.
3. Copy the Root CA certificate `~/pki/root-ca/certs/ca.cert.pem` to your machine
4. **Import the Root CA into your browser's (or OS's) trust store.** You only need to import the *Root* CA - not the intermediate - since the server already presents the full chain and the browser can build the path from your newly-trusted root down to the leaf cert. Use whichever applies to you:
5. **Reload `https://lab5.local`.** The warning should be gone and you should see a trusted padlock. Click the padlock and confirm the chain shown is `CYBER444 Root CA → CYBER444 Intermediate CA → lab5.local`. This may require you to close and reopen your browser.

### Part 7 - Trust Proxmox's Web UI on All 3 Nodes

Your own nested Proxmox cluster (`pve1`, `pve2`, `pve3` - the same three VMs your `lab05-pki01` VM and every other lab VM this semester have been cloned inside) has been showing you a browser warning every time you log into its web UI at port 8006. That's Proxmox's own auto-generated self-signed cert, issued by its internal `PVE Cluster Manager CA` - the same kind of untrusted cert Part 6 just taught you to recognize. This part fixes it for real, on all three nodes, using the Intermediate CA you already control.

Proxmox's cluster filesystem (`/etc/pve`) is shared across all three nodes, but each node's own TLS certificate (`/etc/pve/local/pve-ssl.pem`, itself a symlink into that node's own `/etc/pve/nodes/<name>/` directory) is set independently - so one cert covering all three nodes still has to be installed on each of them separately.

Your `pve1`/`pve2`/`pve3` nodes live on the same subnet as `lab05-pki01`, at `172.19.x.2`, `172.19.x.3`, and `172.19.x.4` (`x` = your subnet's third octet, same as everywhere else in this lab) - you log into them the same way you log into Proxmox's web UI already, as `root`.

| Step | Action | Key details | Purpose |
|---|---|---|---|
| 1 | Write an ad-hoc extensions file | `~/pki/server/proxmox-ext.cnf`, listing `basicConstraints=CA:FALSE`, `keyUsage`, `extendedKeyUsage=serverAuth`, and `subjectAltName` with all three node IPs | Rather than editing the shared `[alt_names]` in `openssl-root.cnf` (which Part 4's server cert still depends on), `-extfile` lets you supply a one-off set of extensions for just this signing operation - the same mechanism real-world CAs use to issue ad-hoc SAN certs without a master config edit per request |
| 2 | Generate the Proxmox private key | 2048-bit RSA, unencrypted, same reasoning as Part 4's server key. Saved to `server/private/proxmox.key.pem` | The key the Proxmox nodes' `pveproxy` service will use for TLS |
| 3 | Create the CSR | Uses the proxmox key, CN set to the first node's IP | Packages the key and identity into a signing request - the SANs come from the extfile at signing time, not from this CSR |
| 4 | Sign the CSR with the Intermediate CA | Uses `-extfile ~/pki/server/proxmox-ext.cnf` (not `-extensions server_cert`), 90 days, SHA-256, `-notext`. Saved to `server/certs/proxmox.cert.pem` | Same signing authority as your `lab5.local` cert, same 90-day leaf-cert policy from Part 4's note - just different SANs, supplied via the extfile instead of `[alt_names]` |
| 5 | Build the leaf+intermediate chain file | Concatenate `proxmox.cert.pem` then `intermediate.cert.pem` into `proxmox-chain.cert.pem` | Same reason as Part 5's `server-chain.crt` fix: Proxmox's web server has to send the Intermediate CA cert to connecting browsers too, or a browser that only trusts your Root CA can't bridge the gap to the leaf |

Copy the chain and key to each node and install with Proxmox's own `pvenode cert set`. Despite what its own docs say, `--force` doesn't reliably restart `pveproxy` for you - confirmed live, the cert file was correct but the service kept serving the old self-signed cert until manually restarted - so restart it explicitly:


If that still shows `PVE Cluster Manager CA` instead of `CYBER444 Intermediate CA`, `pveproxy` hasn't picked up the change restart pveproxy again.

**Verify:** browse to `https://172.19.x.2:8006`, `https://172.19.x.3:8006`, and `https://172.19.x.4:8006`. Since your Root CA is already trusted in your browser from Part 6, all three should now show a trusted padlock with no warning - the same Root CA vouches for both `lab5.local` and all three Proxmox nodes, through the same Intermediate CA.

### Part 8 - Certificate Revocation (CRL)

Every cert you've issued so far has an expiration date, but sometimes a cert needs to stop being trusted *before* that - the private key leaks, an employee with access leaves, a server gets compromised. That's what revocation is for. A **Certificate Revocation List (CRL)** is a CA's own signed, timestamped "blocklist": a list of serial numbers it has revoked, which clients can check against before trusting a cert - even one that's otherwise unexpired and chains correctly to a trusted root.

Only the CA that *issued* a certificate can revoke it. Your `server.cert.pem` (the `lab5.local` leaf cert from Part 4) was issued by the **Intermediate CA**, so revoking it means signing a revocation entry with the Intermediate CA's own key and cert - the exact same `-keyfile`/`-cert` pair you used to *issue* the cert in the first place, just pointed at `openssl ca -revoke` instead of `openssl ca -in <csr>`. You are never revoking the Intermediate CA itself here; the Intermediate is the *issuer* doing the revoking, and the leaf cert is the *subject* being revoked. (If the Intermediate CA's own key were compromised, revoking *it* would be a Root CA operation instead - one level up the same pattern.)

| Step | Action | Key details | Purpose |
|---|---|---|---|
| 1 | Revoke the server certificate | `openssl ca -revoke`, signed by the Intermediate CA's key/cert, with `-crl_reason keyCompromise` | Marks the leaf cert's serial number as revoked in the CA's database (`index.txt`) - the reason code becomes part of the public record other tools can read |
| 2 | Generate the CRL | `openssl ca -gencrl`, signed by the same Intermediate CA key/cert, written to `intermediate-ca/crl/intermediate.crl.pem` | Publishes the current revocation state as a single signed file - the artifact clients actually check against, not the raw `index.txt` |
| 3 | Confirm the certificate appears in the CRL | `openssl crl -noout -text` on the CRL file, filtered to the `Serial Number` section | Verifies the CRL you just generated actually lists your revoked cert's serial number, not just that the commands ran without error |
| 4 | Test the revocation check | `openssl verify` with both `-CAfile` (the trust chain) and `-CRLfile` (your new CRL), plus `-crl_check`, against the leaf cert | Simulates what a revocation-aware client does: build the chain of trust *and* cross-reference the CRL. A cert that still chains fine to a trusted root should now fail with `error 23 at 0 depth lookup: certificate revoked` |


### Part 9 - TLS Validation with testssl.sh

```bash
wget https://testssl.sh/testssl.sh -O testssl.sh
chmod +x testssl.sh
./testssl.sh --severity HIGH --html lab5-tls-report.html https://lab5.local
```

Review the report for any HIGH or CRITICAL findings. Fix any issues (typically weak ciphers or missing headers). Re-run until you get a clean report. This run is for your own benefit - we independently re-check your TLS configuration the same way, so there's no report to submit.

---

## Grading

Every graded item below is checked automatically against your `lab05-pki01` VM - nothing is submitted separately.

| Item | Points |
|------|--------|
| OpenSSL configuration files - both CA tiers correctly defined (Part 1) | 10 |
| Root CA created and verified (Part 2) | 11 |
| Intermediate CA created, signed, chain verified (Part 3) | 12 |
| Server certificate with correct SANs/EKU (Part 4) | 14 |
| Nginx hardened TLS - protocols, ciphers, HSTS, redirect (Part 5) | 18 |
| Browser trust demo (Part 6) | Not graded |
| Proxmox web UI trusted on all 3 nodes with your own PKI (Part 7) | 13 |
| Certificate revocation - CRL generated, revocation check verified (Part 8) | 13 |
| testssl.sh validation - clean TLS configuration (Part 9) | 9 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
