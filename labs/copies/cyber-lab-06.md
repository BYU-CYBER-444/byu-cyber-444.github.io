---
title: "CYBER LAB 6 - SSH Certificate Authority & PAM MFA"
parent: Labs
nav_order: 6
---

# CYBER LAB 6 - SSH Certificate Authority & PAM MFA
{: .no_toc }


<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Build a functional SSH Certificate Authority with both user and host certificate signing
- Issue certificates with principals to restrict which hosts each certificate can access
- Implement the full revocation workflow using a Key Revocation List (KRL)
- Configure Google Authenticator TOTP MFA via PAM with proper `sshd_config` settings
- Implement a `ForceCommand` restriction for a limited-access user

---

## Tools Required

- Your instructor has provisioned two Ubuntu 22.04 VMs for this lab: `cyber-lab06-ssh01` (SSH server) and `cyber-lab06-ssh02` (SSH client)
- `openssh-server`, `ssh-keygen`
- `libpam-google-authenticator`

---

## Background

SSH access at scale has a structural problem `authorized_keys` can't solve cleanly: revoking one departing employee's access means finding and removing their key from every server's `authorized_keys` file individually - a process that reliably gets missed somewhere. SSH certificates flip this model: a single Certificate Authority signs short-lived, centrally-revocable credentials, so access control becomes a CA operation instead of a per-host file edit. This lab builds that CA from scratch, for both user and host certificates, then layers MFA and command restriction on top - the same defense-in-depth combination a real production bastion host would use.

---

## Procedure

### Part 1 - Create the SSH Certificate Authority

```bash
# Create CA directory (in production, this would be an air-gapped machine)
sudo mkdir -p /etc/ssh/ca/{user,host}
sudo chmod 700 /etc/ssh/ca

# Generate User CA key (signs user certificates)
sudo ssh-keygen -t ed25519 -f /etc/ssh/ca/user_ca_key   -C "Lab6 User CA - $(date +%Y)" -N ""

# Generate Host CA key (signs host certificates - prevents TOFU attacks)
sudo ssh-keygen -t ed25519 -f /etc/ssh/ca/host_ca_key   -C "Lab6 Host CA - $(date +%Y)" -N ""

# Protect CA keys
sudo chmod 400 /etc/ssh/ca/user_ca_key /etc/ssh/ca/host_ca_key
sudo chown root:root /etc/ssh/ca/user_ca_key /etc/ssh/ca/host_ca_key
```

### Part 2 - Configure sshd to Trust the User CA

```bash
sudo tee -a /etc/ssh/sshd_config << 'EOF'

# SSH Certificate Authority Configuration
TrustedUserCAKeys /etc/ssh/ca/user_ca_key.pub

# Principals file - maps certificate principal to local user
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u

# Revoked keys list
RevokedKeys /etc/ssh/revoked_keys.krl
EOF

# Create principals directory
sudo mkdir -p /etc/ssh/auth_principals
```

### Part 3 - Issue User Certificates with Principals

The `principals` field restricts which users can use the certificate - critical for access control.

```bash
# Generate alice's user key pair (this would happen on alice's workstation)
ssh-keygen -t ed25519 -f /tmp/alice_key -C "alice@lab6" -N ""

# Sign alice's certificate for principal "alice" only (can only log in as alice)
# Flags:
#   -s = CA key to sign with
#   -I = certificate identity (for logging/auditing)
#   -n = principals (comma-separated - who this cert allows login as)
#   -V = validity period (+52w = valid for 1 year)
#   -O = option (source-address restricts client IP - production best practice)
sudo ssh-keygen   -s /etc/ssh/ca/user_ca_key   -I "alice@lab6-2025"   -n alice   -V +52w   -O source-address=192.168.56.0/24   /tmp/alice_key.pub

# Inspect the certificate to verify fields
ssh-keygen -L -f /tmp/alice_key-cert.pub
```

Configure the server to require the `alice` principal for the `alice` user account:

```bash
echo "alice" | sudo tee /etc/ssh/auth_principals/alice
```

Test certificate login:
```bash
# Copy key and cert to alice's home
sudo cp /tmp/alice_key /tmp/alice_key-cert.pub /home/alice/.ssh/
sudo chown alice:alice /home/alice/.ssh/alice_key*

# Test login (from client or using su)
ssh -i /home/alice/.ssh/alice_key -o "CertificateFile=/home/alice/.ssh/alice_key-cert.pub"   alice@localhost
```

### Part 4 - Host Certificate Signing

Without host certificates, users must manually verify host fingerprints on first connection (Trust on First Use - TOFU). Host certificates eliminate this by having the CA vouch for the server's identity.

```bash
# Sign the server's host key
sudo ssh-keygen   -s /etc/ssh/ca/host_ca_key   -I "cyber-lab06-ssh01"   -h   -n "cyber-lab06-ssh01,192.168.56.10"   -V +52w   /etc/ssh/ssh_host_ed25519_key.pub

# Configure sshd to present the host certificate
echo "HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd

# Verify the host cert
ssh-keygen -L -f /etc/ssh/ssh_host_ed25519_key-cert.pub
```

On `cyber-lab06-ssh02`, configure it to trust hosts signed by the Host CA instead of individual fingerprints:
```bash
# On cyber-lab06-ssh02:
echo "@cert-authority * $(cat /etc/ssh/ca/host_ca_key.pub)" >> ~/.ssh/known_hosts
# Now connecting to the server should NOT prompt for fingerprint verification
ssh alice@192.168.56.10 -i /tmp/alice_key
```

### Part 5 - Certificate Revocation (KRL)

```bash
# Create a Key Revocation List
sudo ssh-keygen -k -f /etc/ssh/revoked_keys.krl

# Revoke alice's certificate by serial number
# First, find the serial: ssh-keygen -L -f alice_key-cert.pub | grep Serial
sudo ssh-keygen -k -u   -f /etc/ssh/revoked_keys.krl   /home/alice/.ssh/alice_key-cert.pub

sudo systemctl reload sshd

# Verify revoked cert is rejected
ssh -i /home/alice/.ssh/alice_key alice@localhost
# Expected: sign_and_send_pubkey: certificate invalid: revoked by key revocation list
```

Screenshot the rejection error.

### Part 6 - TOTP MFA with Google Authenticator

```bash
sudo apt install libpam-google-authenticator -y

# Configure Google Authenticator for alice
sudo -u alice google-authenticator
# Options to select:
#   Time-based: y
#   Update .google_authenticator: y
#   Disallow multiple uses: y
#   Permit 30-second clock skew: n
#   Rate limiting: y
# Screenshot the QR code and backup codes
```

Configure PAM - edit `/etc/pam.d/sshd`:
```
# Add at the TOP of auth section:
auth required pam_google_authenticator.so nullok
```

Configure sshd for MFA:
```bash
sudo tee -a /etc/ssh/sshd_config << 'EOF'

# MFA Configuration
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
EOF

sudo systemctl reload sshd
```

Test the full MFA flow:
```bash
# Re-issue alice's certificate (revoked in Part 5 - generate a new key pair)
ssh-keygen -t ed25519 -f /tmp/alice_key2 -N ""
sudo ssh-keygen -s /etc/ssh/ca/user_ca_key -I "alice@lab6-mfa" -n alice -V +52w /tmp/alice_key2.pub

# Login should now require both cert and TOTP code
ssh -i /tmp/alice_key2 alice@localhost
# Expected: enters key auth silently, then prompts: "Verification code:"
```

### Part 7 - ForceCommand: Restricted Shell Access

Configure a `bob` user who can only run a specific command via SSH (useful for automated jobs):

```bash
# Add to /etc/ssh/sshd_config for bob's certificate principal
echo 'Match User bob
    ForceCommand /usr/bin/df -h
    AllowTcpForwarding no
    X11Forwarding no' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd
```

Issue bob's certificate with `ForceCommand` in the certificate options:
```bash
ssh-keygen -t ed25519 -f /tmp/bob_key -N ""
sudo ssh-keygen -s /etc/ssh/ca/user_ca_key -I "bob@lab6" -n bob   -O force-command="/usr/bin/df -h" -V +52w /tmp/bob_key.pub
```

Test: `ssh bob@localhost` should ONLY show disk usage output - any other command should be rejected.

---

## Deliverables

- `ssh-keygen -L` output for alice's user certificate (showing all fields)
- `ssh-keygen -L` output for the server's host certificate
- Principal file contents for alice (`/etc/ssh/auth_principals/alice`)
- Screenshot: successful alice certificate login
- Screenshot: alice certificate login REJECTED after KRL revocation
- Full `sshd_config` additions (commented)
- Screenshot: TOTP MFA login showing "Verification code:" prompt and successful auth
- ForceCommand: bob SSH output showing only `df -h` even when user tries to run `ls`
- Written reflection (4-5 sentences): Compare certificate-based SSH access to authorized_keys-based access. What is the operational advantage of certificates when you need to revoke access for a departing employee across 200 servers?

---

## Grading

| Item | Points |
|------|--------|
| SSH Certificate Authority created (Part 1) | 10 |
| sshd configured to trust the User CA (Part 2) | 8 |
| User certificate issued with principals, login verified (Part 3) | 15 |
| Host certificate signed and trusted (Part 4) | 15 |
| KRL revocation - rejection verified (Part 5) | 15 |
| TOTP MFA via PAM - full flow verified (Part 6) | 20 |
| ForceCommand restriction verified (Part 7) | 12 |
| Written reflection - certificates vs. authorized_keys at scale | 5 |
| **Total** | **100** |


[← Back to Labs]({{ site.baseurl }}/labs/)
