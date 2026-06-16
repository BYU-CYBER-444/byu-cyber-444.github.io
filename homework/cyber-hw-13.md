---
title: "CYBER HW 13 - SSH CA & MFA Deployment Design"
parent: Homework
nav_order: 13
---

# CYBER HW 13 - SSH CA & MFA Deployment Design
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Overview

| | |
|---|---|
| **Assignment** | CYBER HW 13 |
| **Points** | 100 |
| **Due** | Week 14 |
| **Track** | Cyber |

---

## Description

Design and partially implement a complete Privileged Access Management solution for Valley Medical Group using SSH Certificate Authority and MFA - the two highest-impact controls for securing server access at scale.

### Part 1 - SSH CA Architecture & Implementation (40 pts)

**Architecture design:**

Design an SSH CA architecture for Valley Medical Group (5 Linux servers, 2 environments: production and staging). Your design must address:

- CA key storage: where is the CA private key stored and how is it protected? (Hardware HSM, encrypted volume, Vault - choose and justify)
- User certificate workflow: how does an engineer request and receive a certificate? (Manual signing, HashiCorp Vault SSH secrets engine, Teleport, or similar - choose and justify)
- Certificate validity period: what is your maximum certificate TTL and why? Address the trade-off between operational convenience and security (what happens if a certificate is issued to a compromised workstation?)
- Host certificate signing: how do servers prove their identity to clients (preventing TOFU/MITM attacks)?
- Certificate revocation: what is your procedure if a certificate is compromised? What is the gap between revocation and full enforcement across all servers?

**Implementation - write the commands:**

Write the exact `ssh-keygen` commands to:
1. Generate a CA key pair (with appropriate key type and comment)
2. Sign a user public key to create a 4-hour certificate for user `jsmith` granting access to servers tagged `environment=production`
3. Sign a host key for `web-01.vmg.internal` with a 1-year validity
4. Configure `/etc/ssh/sshd_config` to trust user certificates from your CA and require host certificate verification
5. Configure `~/.ssh/known_hosts` or `/etc/ssh/ssh_known_hosts` to trust host certificates

For each command, explain every flag you use.

**ForceCommand and certificate extensions:** Write an `AuthorizedPrincipals` configuration that restricts certificate holders to specific usernames based on their certificate principal, and show how `ForceCommand` in an `sshd_config` `Match` block can restrict a vendor's certificate to only running a specific monitoring script, not an interactive shell.

### Part 2 - MFA Technology Comparison & Selection (20 pts)

Evaluate **TOTP (Time-based OTP)**, **FIDO2/WebAuthn hardware keys**, and **Push notification (Duo/Okta Verify)** for Valley Medical Group's SSH access:

| Criterion | TOTP | FIDO2 | Push Notification |
|---|---|---|---|
| Phishing resistance | | | |
| Offline capability | | | |
| Implementation complexity | | | |
| Cost per user | | | |
| Works with SSH | | | |
| Regulatory compliance (HIPAA, NIST 800-63B AAL level) | | | |

Fill in every cell substantively (not just "medium"). Cite the NIST SP 800-63B Authenticator Assurance Level for each method.

Recommend one method for Valley Medical Group's clinical staff SSH access and justify with at least 3 specific reasons. Then recommend a different method for privileged admin access and justify why the admin use case warrants a different choice.

### Part 3 - PAM MFA Configuration (25 pts)

Write the PAM configuration for TOTP MFA on SSH logins using `libpam-google-authenticator` or `libpam-oath`:

1. Write the complete `/etc/pam.d/sshd` configuration that:
   - Requires TOTP as a second factor (after public key authentication)
   - Allows service accounts in the `svcaccount` group to bypass MFA (using PAM `pam_listfile` or `pam_succeed_if`)
   - Falls back to password + TOTP if public key authentication fails (for emergency break-glass)

2. Write the corresponding `/etc/ssh/sshd_config` stanza that enables `AuthenticationMethods` to require `publickey,keyboard-interactive` for normal users and `publickey` only for the `svcaccount` group

3. Write a bash script `cyber-hw-13-mfa-enroll.sh` that automates TOTP enrollment for a new user: runs `google-authenticator` in non-interactive mode with your required settings, saves the QR code URL to a temp file, and emails (simulated with `echo` to a log file) the enrollment URL to the user's address from LDAP

### Part 4 - Break-Glass Procedure & Audit Design (15 pts)

Define the emergency break-glass procedure for when MFA is unavailable (authenticator app lost, CA infrastructure down, etc.):

1. **Procedure steps** - numbered, specific. Who is called, what is the verification process before granting break-glass access, what account/method is used, how access is monitored during the emergency
2. **Audit trail** - every break-glass access must be fully audited. Write the `auditd` rules that would capture break-glass logins specifically (hint: break-glass might use a specific account or source IP from the management network)
3. **Post-incident review** - after any break-glass use, what must be reviewed and remediated? Define a 5-item checklist.
4. **Testing** - how often is the break-glass procedure tested, who conducts the test, and what is documented afterward?

---

## Deliverable(s)

Write your full design and implementation in `homework/cyber-hw-13.md`. Commit to `homework/assets/`:

- `cyber-hw-13-ca-commands.sh` - all SSH CA commands (Part 1)
- `cyber-hw-13-sshd_config` - your hardened sshd_config with MFA (Part 3)
- `cyber-hw-13-pam-sshd` - your PAM sshd configuration (Part 3)
- `cyber-hw-13-mfa-enroll.sh` - enrollment automation script (Part 3)

Open a PR titled `CYBER HW 13 - SSH CA & MFA` and submit the PR link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| SSH CA architecture - key storage, TTL justification, revocation gap | 20 |
| SSH CA commands - all 5 commands correct with flags explained | 20 |
| MFA comparison table - all cells substantive, NIST 800-63B cited | 20 |
| PAM configuration - publickey+TOTP, service account bypass, sshd_config | 25 |
| Break-glass procedure - auditd rules, checklist, test plan | 15 |

---

## Tip

{: .tip }
Use `ssh-keygen -s ca_key -I "jsmith@vmg.internal" -n jsmith,sysadmin -V +4h -O permit-pty -O permit-agent-forwarding user_key.pub` to sign a certificate with specific extensions. The `-O` flags control what the certificate holder can do - learn them.

---

---

##  Graduate Extension - Graduate Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section. Graduate work is worth an additional 30 points added to this assignment.**

### Part 5 - Cryptographic Standards Policy & CA Compromise Response (30 pts)

**CA Compromise Response Plan (15 pts)**

Your SSH CA is a high-value target - its compromise invalidates every certificate it has ever issued. Design and document a formal **CA Compromise Response Plan** (`cyber-hw-13-ca-compromise.md`):

1. **Detection** - how would you know your CA key was compromised? List specific indicators (unexpected certificate issuance, CA key access outside maintenance window, audit log gaps) and the monitoring controls that would surface them.
2. **Immediate Containment** - exact steps to take within the first 30 minutes: revoke the CA key from all `TrustedUserCAKeys` files, rotate to a new CA, and block all existing certificates. Include the exact commands.
3. **Re-issuance** - process for re-issuing certificates to all affected users and hosts, including how to handle users who are currently logged in via compromised certificates without locking them out permanently.
4. **Communication** - who is notified, in what order, and what they are told. Write a template breach notification for affected system owners.
5. **Post-Incident** - what changes to CA architecture (hardware security module, offline CA, split knowledge) would prevent recurrence? Evaluate HSM vs. air-gapped offline CA for a 500-server fleet.

**Cryptographic Standards Policy (15 pts)**

Write a formal **Cryptographic Standards Policy** (`cyber-hw-13-crypto-policy.md`) aligned with NIST SP 800-131A Rev 2. The policy must specify:

- Approved and disallowed algorithms for: symmetric encryption, asymmetric encryption, digital signatures, key agreement, and hashing
- Minimum key lengths for each approved algorithm and the date after which shorter keys are prohibited
- Certificate validity periods and renewal requirements (align with current CA/Browser Forum Baseline Requirements for any public-facing certs)
- Key storage requirements: when hardware (HSM, TPM, YubiKey) is mandatory vs. when software key storage is acceptable
- Key rotation schedules: SSH host keys, SSH user CAs, TLS certificates, code signing keys, and secrets/API keys
- Algorithm deprecation process: how the organization will transition away from an algorithm when NIST deprecates it (e.g., the transition from SHA-1)


[← Back to Homework]({{ site.baseurl }}/homework/)
