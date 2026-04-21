---
title: "LAB 13 — SSH Certificate Authority & PAM MFA"
parent: Labs
nav_order: 13
---

# LAB 13 — SSH Certificate Authority & PAM MFA
{: .no_toc }

**Duration:** 2 hours &nbsp;·&nbsp; **Week:** Week 13
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Create an SSH Certificate Authority (CA) key pair
- Issue and revoke signed user certificates
- Integrate Ubuntu with the Windows AD domain using sssd
- Enable Google Authenticator PAM MFA for privileged access

---

## Tools Required

- Ubuntu 22.04 VM
- OpenSSH
- ``ssh-keygen``
- ``sssd` + `realmd``
- ``libpam-google-authenticator``

---

## Procedure


1. Create SSH CA:
   ```bash
   ssh-keygen -t ed25519 -f /etc/ssh/ca_key -C "Lab CA"
   ```
2. Configure SSH server to trust the CA — add to `/etc/ssh/sshd_config`:
   ```
   TrustedUserCAKeys /etc/ssh/ca_key.pub
   ```
3. Issue a signed user certificate for `alice`:
   ```bash
   ssh-keygen -s /etc/ssh/ca_key -I "alice@lab" -n alice -V +52w alice_user_key.pub
   ```
4. Test certificate-based login as `alice` — verify success
5. Revoke the certificate: create a KRL file and add `RevokedKeys` to `sshd_config`
6. Verify revoked cert is rejected
7. Install Google Authenticator PAM:
   ```bash
   sudo apt install libpam-google-authenticator
   ```
8. Configure PAM: add `auth required pam_google_authenticator.so` to `/etc/pam.d/sshd`
9. Update `sshd_config`:
   ```
   ChallengeResponseAuthentication yes
   AuthenticationMethods publickey,keyboard-interactive
   ```
10. Test full MFA login flow


---

## Submission Requirements

Lab Report: SSH CA config excerpt, certificate issuance command/output, successful cert-based login screenshot, KRL creation and revocation test screenshot, Google Authenticator PAM config, successful MFA login screenshot.

---

[← Back to Labs]({{ site.baseurl }}/labs/)
