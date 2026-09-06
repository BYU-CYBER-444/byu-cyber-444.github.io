---
title: "CYBER HW 6 - SSH CA & MFA Deployment Design"
parent: Homework
nav_order: 6
---
# CYBER HW 6 - SSH CA & MFA Deployment Design
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Description

This is a theoretical design exercise - no VM, script, or config file to build. You are designing a complete Privileged Access Management approach for Valley Medical Group using SSH Certificate Authority and MFA - the two highest-impact controls for securing server access at scale. Use the [Valley Medical Group PAM/SSH Environment Profile]({% link homework/description-files/cyber-hw-06-scenario.md %}) for the specific server inventory, staffing, and network details your design needs to reference.

### Part 1 - SSH CA Architecture & Implementation Plan (50 pts)

**Architecture design:**

Design an SSH CA architecture for Valley Medical Group's production and staging environments. Your design must address:

- CA key storage: where is the CA private key stored and how is it protected? (Hardware HSM, encrypted volume, Vault - choose and justify)
- User certificate workflow: how does a sysadmin request and receive a certificate? (Manual signing, HashiCorp Vault SSH secrets engine, Teleport, or similar - choose and justify)
- Certificate validity period: what is your maximum certificate TTL and why? Address the trade-off between operational convenience and security (what happens if a certificate is issued to a compromised workstation?)
- Host certificate signing: how do servers prove their identity to clients (preventing TOFU/MITM attacks)?
- Certificate revocation: what is your procedure if a certificate is compromised? What is the gap between revocation and full enforcement across all servers?

**Implementation plan:**

Describe, step by step, how you would actually stand this up. For each step, name the specific `ssh-keygen` (or equivalent) command and the flags/options it needs, and explain what each flag accomplishes - you're documenting a runbook a colleague could follow, not submitting a working script:

1. Generating a CA key pair (key type, comment, and why)
2. Signing a user public key to create a short-lived certificate for one of the sysadmins, scoped to production hosts only
3. Signing a host key for one of the production web servers, and what validity period you'd give it (and why a host certificate's TTL logic differs from a user certificate's)
4. What `/etc/ssh/sshd_config` needs to trust user certificates from your CA and require host certificate verification
5. What `~/.ssh/known_hosts` or `/etc/ssh/ssh_known_hosts` needs to trust host certificates

**Certificate scoping:** Describe how you would use `AuthorizedPrincipals` to restrict certificate holders to specific usernames based on their certificate principal, and how a `ForceCommand` in an `sshd_config` `Match` block could restrict a vendor's certificate to only running a specific monitoring script, not an interactive shell. Sketch the relevant configuration blocks to illustrate your design - they don't need to be tested, working configs.

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

Recommend one method for the general sysadmin tier's routine SSH access and justify with at least 3 specific reasons. Then recommend a different method for the CISO/IT Director's privileged and break-glass access, and justify why that use case warrants a different choice.

### Part 3 - PAM MFA Design (30 pts)

Design (do not build) the PAM-based TOTP MFA layer for SSH logins:

1. Describe the complete `/etc/pam.d/sshd` stack you'd configure: what requires TOTP as a second factor (after public key authentication), how the `svcaccount` group (containing `svc-backup` and `svc-monitor`) bypasses MFA entirely, and what PAM mechanism (`pam_listfile`, `pam_succeed_if`, or similar) enforces that bypass and why you chose it.

2. Describe the corresponding `/etc/ssh/sshd_config` design that enables `AuthenticationMethods` to require `publickey,keyboard-interactive` for the general sysadmin tier and `publickey` only for the `svcaccount` group.

3. Describe the fallback path for emergency break-glass access if public key authentication fails (password + TOTP) - who can use it and how it differs operationally from Part 4's break-glass procedure.

4. Describe how you would automate TOTP enrollment for a new sysadmin: what tool generates the secret/QR code, where the enrollment link is sent (using the AD-integrated identity from the Environment Profile), and what a new hire's first-login experience looks like end to end.

---

## Deliverable(s)

Write your full design in `homework/cyber-hw-06.md`.

Open a PR titled `CYBER HW 6 - SSH CA & MFA Deployment Design` and submit your repo link on Learning Suite by the due date.

---

## Grading Rubric

| Criterion | Points |
|---|---|
| SSH CA architecture - key storage, TTL justification, revocation gap | 25 |
| SSH CA implementation plan - all 5 steps described with flags/options explained | 25 |
| MFA comparison table - all cells substantive, NIST 800-63B cited | 20 |
| PAM MFA design - publickey+TOTP, service account bypass, sshd_config design | 30 |


[← Back to Homework]({{ site.baseurl }}/homework/)
