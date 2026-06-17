---
title: "LAB 8 - PKI & Certificate Management"
parent: Labs
nav_order: 8
---

# LAB 8 - PKI & Certificate Management
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 8
{: .fs-5 }

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

---

## Tools Required

- Ubuntu 22.04 VM
- OpenSSL (pre-installed)
- Nginx (`sudo apt install nginx`)
- `testssl.sh` (download from testssl.sh)

---

## Procedure

### Part 1 - OpenSSL Configuration Files

The default `/etc/ssl/openssl.cnf` is insufficient for a proper PKI. Create dedicated config files for each CA tier.

Create `~/pki/root-ca/openssl-root.cnf`:

```ini
[ca]
default_ca = CA_default

[CA_default]
dir             = /root/pki/root-ca
certs           = $dir/certs
crl_dir         = $dir/crl
new_certs_dir   = $dir/newcerts
database        = $dir/index.txt
serial          = $dir/serial
RANDFILE        = $dir/private/.rand
private_key     = $dir/private/ca.key.pem
certificate     = $dir/certs/ca.cert.pem
crlnumber       = $dir/crlnumber
crl             = $dir/crl/ca.crl.pem
crl_extensions  = crl_ext
default_crl_days = 30
default_md      = sha256
name_opt        = ca_default
cert_opt        = ca_default
default_days    = 375
preserve        = no
policy          = policy_strict

[policy_strict]
countryName            = match
stateOrProvinceName    = match
organizationName       = match
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[req]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca

[req_distinguished_name]
countryName                    = Country Name (2 letter code)
stateOrProvinceName            = State or Province Name
localityName                   = Locality Name
organizationName               = Organization Name
organizationalUnitName         = Organizational Unit Name
commonName                     = Common Name
emailAddress                   = Email Address

[v3_ca]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign

[v3_intermediate_ca]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign

[server_cert]
basicConstraints       = CA:FALSE
nsCertType             = server
nsComment              = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage               = critical, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth
subjectAltName         = @alt_names

[alt_names]
DNS.1 = lab8.local
DNS.2 = www.lab8.local
IP.1  = 192.168.56.10

[crl_ext]
authorityKeyIdentifier = keyid:always
```

Create the directory structure:

```bash
mkdir -p ~/pki/{root-ca,intermediate-ca,server}/{certs,private,crl,newcerts}
chmod 700 ~/pki/root-ca/private ~/pki/intermediate-ca/private
for d in root-ca intermediate-ca; do
  echo 1000 > ~/pki/$d/serial
  echo 1000 > ~/pki/$d/crlnumber
  touch ~/pki/$d/index.txt
done
```

### Part 2 - Create the Root CA

```bash
# Generate Root CA key (4096-bit RSA, AES-256 encrypted)
openssl genrsa -aes256 -out ~/pki/root-ca/private/ca.key.pem 4096
chmod 400 ~/pki/root-ca/private/ca.key.pem

# Self-sign the Root CA certificate (10 years)
openssl req -config ~/pki/root-ca/openssl-root.cnf   -key ~/pki/root-ca/private/ca.key.pem   -new -x509 -days 3650 -sha256 -extensions v3_ca   -out ~/pki/root-ca/certs/ca.cert.pem   -subj "/C=US/ST=Utah/O=CYBER444 Lab/CN=CYBER444 Root CA"
chmod 444 ~/pki/root-ca/certs/ca.cert.pem

# Verify
openssl x509 -noout -text -in ~/pki/root-ca/certs/ca.cert.pem | grep -E "Issuer|Subject|Not|CA:true|pathlen"
```

### Part 3 - Create the Intermediate CA

```bash
# Generate Intermediate CA key
openssl genrsa -aes256 -out ~/pki/intermediate-ca/private/intermediate.key.pem 4096
chmod 400 ~/pki/intermediate-ca/private/intermediate.key.pem

# Generate CSR for the Intermediate CA
openssl req -config ~/pki/root-ca/openssl-root.cnf -new -sha256   -key ~/pki/intermediate-ca/private/intermediate.key.pem   -out ~/pki/intermediate-ca/intermediate.csr.pem   -subj "/C=US/ST=Utah/O=CYBER444 Lab/CN=CYBER444 Intermediate CA"

# Sign the Intermediate CA with the Root CA (5 years, pathlen:0)
openssl ca -config ~/pki/root-ca/openssl-root.cnf   -extensions v3_intermediate_ca -days 1825 -notext -md sha256   -in ~/pki/intermediate-ca/intermediate.csr.pem   -out ~/pki/intermediate-ca/certs/intermediate.cert.pem

# Build the chain file
cat ~/pki/intermediate-ca/certs/intermediate.cert.pem     ~/pki/root-ca/certs/ca.cert.pem     > ~/pki/intermediate-ca/certs/ca-chain.cert.pem

# Verify chain
openssl verify -CAfile ~/pki/root-ca/certs/ca.cert.pem   ~/pki/intermediate-ca/certs/intermediate.cert.pem
```

### Part 4 - Issue a Server Certificate with SANs

The server certificate must include Subject Alternative Names (SANs) - modern browsers reject certificates without them.

```bash
# Generate server key (2048-bit is sufficient for leaf certs)
openssl genrsa -out ~/pki/server/private/server.key.pem 2048
chmod 400 ~/pki/server/private/server.key.pem

# Generate CSR (SANs are added at signing time via the config file)
openssl req -config ~/pki/root-ca/openssl-root.cnf -new -sha256   -key ~/pki/server/private/server.key.pem   -out ~/pki/server/server.csr.pem   -subj "/C=US/ST=Utah/O=CYBER444 Lab/CN=lab8.local"

# Sign with the Intermediate CA using the server_cert extension (includes SANs from alt_names)
openssl ca -config ~/pki/root-ca/openssl-root.cnf   -extensions server_cert -days 375 -notext -md sha256   -keyfile ~/pki/intermediate-ca/private/intermediate.key.pem   -cert ~/pki/intermediate-ca/certs/intermediate.cert.pem   -in ~/pki/server/server.csr.pem   -out ~/pki/server/certs/server.cert.pem

# Verify the full chain
openssl verify -CAfile ~/pki/intermediate-ca/certs/ca-chain.cert.pem   ~/pki/server/certs/server.cert.pem
# Expected: server.cert.pem: OK

# Inspect SANs
openssl x509 -noout -text -in ~/pki/server/certs/server.cert.pem | grep -A5 "Subject Alternative"
```

### Part 5 - Configure Nginx with Hardened TLS

```bash
sudo mkdir -p /etc/nginx/ssl
sudo cp ~/pki/server/certs/server.cert.pem /etc/nginx/ssl/server.crt
sudo cp ~/pki/intermediate-ca/certs/ca-chain.cert.pem /etc/nginx/ssl/ca-chain.crt
sudo cp ~/pki/server/private/server.key.pem /etc/nginx/ssl/server.key
sudo chmod 600 /etc/nginx/ssl/server.key
sudo chown www-data:www-data /etc/nginx/ssl/server.key
```

Create `/etc/nginx/sites-available/lab8`:

```nginx
server {
    listen 443 ssl;
    server_name lab8.local;

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
    server_name lab8.local;
    return 301 https://$host$request_uri;
}
```

```bash
sudo ln -s /etc/nginx/sites-available/lab8 /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
echo "192.168.56.10 lab8.local" | sudo tee -a /etc/hosts
```

Trust the Root CA and verify:
```bash
sudo cp ~/pki/root-ca/certs/ca.cert.pem /usr/local/share/ca-certificates/lab-root-ca.crt
sudo update-ca-certificates
curl https://lab8.local   # should succeed
curl http://lab8.local    # should redirect to HTTPS (302/301)
```

### Part 6 - Certificate Revocation (CRL)

Revoke the server certificate (simulate a key compromise scenario):

```bash
# Revoke the certificate (reason: keyCompromise)
openssl ca -config ~/pki/root-ca/openssl-root.cnf   -keyfile ~/pki/intermediate-ca/private/intermediate.key.pem   -cert ~/pki/intermediate-ca/certs/intermediate.cert.pem   -revoke ~/pki/server/certs/server.cert.pem   -crl_reason keyCompromise

# Generate the CRL
openssl ca -config ~/pki/root-ca/openssl-root.cnf   -keyfile ~/pki/intermediate-ca/private/intermediate.key.pem   -cert ~/pki/intermediate-ca/certs/intermediate.cert.pem   -gencrl -out ~/pki/intermediate-ca/crl/intermediate.crl.pem

# Verify the certificate now appears in the CRL
openssl crl -noout -text -in ~/pki/intermediate-ca/crl/intermediate.crl.pem | grep -A3 "Serial"

# Test revocation check
openssl verify -CAfile ~/pki/intermediate-ca/certs/ca-chain.cert.pem   -CRLfile ~/pki/intermediate-ca/crl/intermediate.crl.pem   -crl_check ~/pki/server/certs/server.cert.pem
# Expected: error 23 at 0 depth lookup: certificate revoked
```

### Part 7 - TLS Validation with testssl.sh

```bash
wget https://testssl.sh/testssl.sh -O testssl.sh
chmod +x testssl.sh
./testssl.sh --severity HIGH --html lab8-tls-report.html https://lab8.local
```

Review the report for any HIGH or CRITICAL findings. Fix any issues (typically weak ciphers or missing headers). Re-run until you get a clean report.

---

## Submission Requirements

- Root CA certificate `openssl x509 -text` output (showing `CA:true`, validity, key size)
- Intermediate CA `openssl verify` output against Root CA
- Server certificate `openssl x509 -text` output showing SANs and EKU
- Full chain verification output: `server.cert.pem: OK`
- `/etc/nginx/sites-available/lab8` config file (annotated)
- `curl https://lab8.local` output (connection succeeds)
- `curl http://lab8.local` output (redirect to HTTPS)
- Revocation: `openssl verify -crl_check` output showing "certificate revoked"
- `testssl.sh` HTML report showing no HIGH or CRITICAL issues
- Written explanation (4-6 sentences): Why is a two-tier CA hierarchy preferred over a single Root CA? What is the operational advantage of the Root CA being offline?

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### OCSP Responder & Certificate Transparency

1. **OCSP Responder:** Configure an OpenSSL OCSP responder for the Intermediate CA:
   ```bash
   openssl ocsp -port 2560 -text      -index ~/pki/intermediate-ca/index.txt      -CA ~/pki/intermediate-ca/certs/ca-chain.cert.pem      -rkey ~/pki/intermediate-ca/private/intermediate.key.pem      -rsigner ~/pki/intermediate-ca/certs/intermediate.cert.pem      -ndays 7 &
   ```
   Issue a new server certificate (re-create the server cert after revoking the first one). Add the OCSP URI to the certificate using the `authorityInfoAccess` extension in your OpenSSL config:
   ```
   [server_cert]
   authorityInfoAccess = OCSP;URI:http://lab8.local:2560
   ```
   Then test real-time OCSP checking:
   ```bash
   openssl ocsp -CAfile ~/pki/intermediate-ca/certs/ca-chain.cert.pem      -url http://lab8.local:2560      -issuer ~/pki/intermediate-ca/certs/intermediate.cert.pem      -cert ~/pki/server/certs/server.cert.pem
   ```
   Document the difference between CRL and OCSP: what are the staleness, privacy, and availability trade-offs?

2. **OCSP Stapling:** Configure Nginx to staple the OCSP response so clients don't need to contact the OCSP responder directly:
   ```nginx
   ssl_stapling on;
   ssl_stapling_verify on;
   ssl_trusted_certificate /etc/nginx/ssl/ca-chain.crt;
   ```
   Verify stapling is working: `openssl s_client -connect lab8.local:443 -status 2>&1 | grep "OCSP Response"`

---

[← Back to Labs]({{ site.baseurl }}/labs/)
