---
title: "CYBER HW 2 - Security Audit Script (Given)"
parent: Homework
nav_exclude: true
---

# cyber-hw-02-audit.sh
{: .no_toc }

{: .note }
This is the audit script referenced in [CYBER HW 2]({% link homework/cyber-hw-02.md %}). Save the code below as `cyber-hw-02-audit.sh`, run `chmod +x cyber-hw-02-audit.sh`, and run it with `sudo ./cyber-hw-02-audit.sh` - no arguments, no prompts. It is read-only and makes no changes to the system, so it's safe to run repeatedly against the same machine.

```bash
#!/usr/bin/env bash
#
# cyber-hw-02-audit.sh
# Security audit script for Rocky Linux 9, covering 5 categories:
# filesystem (SUID/SGID, world-writable paths, passwd/shadow/sudoers
# permissions, orphaned files), account & privilege (duplicate UID 0,
# empty passwords, stale wheel members, NOPASSWD sudoers entries),
# network exposure (unexpected listeners, non-private outbound
# connections), SSH configuration (risky sshd_config directives,
# oversized authorized_keys), and scheduled tasks (cron jobs that run
# from a writable path or as root with a writable script).
#
# Usage: sudo ./cyber-hw-02-audit.sh
#
set -euo pipefail

# ── Configuration (no hardcoded paths inline - all here at the top) ──────────
PASSWD_FILE="/etc/passwd"
SHADOW_FILE="/etc/shadow"
SUDOERS_FILE="/etc/sudoers"
SSHD_CONFIG="/etc/ssh/sshd_config"
REPORT_DATE="$(date +%F)"
REPORT_FILE="/tmp/security-audit-${REPORT_DATE}.json"
HOSTNAME_VAL="$(hostname)"

# How many days without a login before a wheel-group member is flagged
# as stale (passed to `lastlog -b`).
STALE_LOGIN_DAYS=90

# How many entries in a single account's authorized_keys before it's
# flagged as worth a human look.
AUTHORIZED_KEYS_THRESHOLD=5

# Expected SUID/SGID baseline for a stock Rocky Linux 9 minimal install.
# Anything found on disk that is NOT in this list is flagged. Postfix ships
# by default on a Rocky 9 minimal install, hence the postdrop/postqueue
# entries - a different base image (e.g. no MTA installed) will legitimately
# have a shorter real-world list than this.
EXPECTED_SUID_SGID=(
  "/usr/bin/sudo"
  "/usr/bin/su"
  "/usr/bin/passwd"
  "/usr/bin/chsh"
  "/usr/bin/chfn"
  "/usr/bin/gpasswd"
  "/usr/bin/newgrp"
  "/usr/bin/mount"
  "/usr/bin/umount"
  "/usr/bin/crontab"
  "/usr/bin/pkexec"
  "/usr/bin/fusermount3"
  "/usr/sbin/unix_chkpwd"
  "/usr/sbin/pam_timestamp_check"
  "/usr/sbin/postdrop"
  "/usr/sbin/postqueue"
  "/usr/sbin/mount.nfs"
  "/usr/libexec/openssh/ssh-keysign"
)

# Expected owner/mode for the three identity files this script checks,
# per the CIS Rocky Linux 9 Benchmark (root:root, 644/000/440 respectively).
declare -A EXPECT_OWNER=( ["$PASSWD_FILE"]="root:root" ["$SHADOW_FILE"]="root:root" ["$SUDOERS_FILE"]="root:root" )
declare -A EXPECT_MODE=(  ["$PASSWD_FILE"]="644"       ["$SHADOW_FILE"]="000"       ["$SUDOERS_FILE"]="440" )

# Expected listening services (proto/port) for a stock Rocky 9 minimal
# install with only SSH exposed. Extend this if the host legitimately
# runs more (a web server, a database, etc.).
EXPECTED_LISTENERS=(
  "tcp/22"
)

# ── Finding accumulator ───────────────────────────────────────────────────────
CRITICAL_COUNT=0
WARNING_COUNT=0
INFO_COUNT=0
FINDINGS_JSON=()

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# json_escape STRING - escapes backslashes, double quotes, and newlines for
# safe embedding inside a JSON string value.
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

# build_details KEY1 VAL1 [KEY2 VAL2 ...] - builds a JSON object string with
# every value string-escaped. Called with zero args, returns "{}".
build_details() {
  local out="{" first=1 k v
  while [[ $# -gt 0 ]]; do
    k="$1"; v="$2"; shift 2
    [[ "$first" -eq 1 ]] || out+=","
    first=0
    out+="\"$(json_escape "$k")\":\"$(json_escape "$v")\""
  done
  out+="}"
  printf '%s' "$out"
}

# add_finding SEVERITY CATEGORY CHECK MESSAGE [DETAILS_JSON]
# Prints the color-coded, bracket-tagged line to stdout and appends a JSON
# finding object to FINDINGS_JSON. DETAILS_JSON must already be a valid
# JSON object literal (use build_details) - it defaults to "{}" if omitted.
add_finding() {
  local severity="$1" category="$2" check="$3" message="$4" details="${5:-{\}}"
  local color
  case "$severity" in
    CRITICAL) color="$RED";    CRITICAL_COUNT=$((CRITICAL_COUNT + 1)) ;;
    WARNING)  color="$YELLOW"; WARNING_COUNT=$((WARNING_COUNT + 1)) ;;
    INFO)     color="$GREEN";  INFO_COUNT=$((INFO_COUNT + 1)) ;;
    *) color="$NC" ;;
  esac
  printf "${color}[%s]${NC} (%s) %s: %s\n" "$severity" "$category" "$check" "$message"
  local msg_esc
  msg_esc="$(json_escape "$message")"
  FINDINGS_JSON+=("{\"severity\":\"${severity}\",\"category\":\"${category}\",\"check\":\"${check}\",\"message\":\"${msg_esc}\",\"details\":${details}}")
}

# is_private_ip IP - returns 0 (true) if IP is loopback or RFC1918, 1
# otherwise. IPv4 only - IPv6 connections are not evaluated by this check,
# a documented limitation rather than a silent gap.
is_private_ip() {
  local ip="$1"
  case "$ip" in
    127.*) return 0 ;;
    10.*) return 0 ;;
    192.168.*) return 0 ;;
    172.1[6-9].*|172.2[0-9].*|172.3[0-1].*) return 0 ;;
    *) return 1 ;;
  esac
}

# ── Filesystem Security ───────────────────────────────────────────────────────

# check_suid_sgid: find every SUID/SGID binary on the root filesystem and
# flag anything not on the EXPECTED_SUID_SGID whitelist. -xdev keeps the
# search on the root filesystem so it doesn't wander into mounted network
# shares or removable media.
check_suid_sgid() {
  local path whitelisted w mode owner
  while IFS= read -r path; do
    whitelisted=0
    for w in "${EXPECTED_SUID_SGID[@]}"; do
      [[ "$path" == "$w" ]] && whitelisted=1 && break
    done
    if [[ "$whitelisted" -eq 0 ]]; then
      mode="$(stat -c '%a' "$path" 2>/dev/null || echo unknown)"
      owner="$(stat -c '%U:%G' "$path" 2>/dev/null || echo unknown)"
      add_finding "WARNING" "filesystem" "unexpected_suid" \
        "SUID/SGID binary not on whitelist: ${path}" \
        "$(build_details path "$path" mode "$mode" owner "$owner")"
    fi
  done < <(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null)
}

# check_world_writable: world-writable files/dirs outside /tmp, /var/tmp,
# and /dev (all three are expected to be world-writable), flagged
# specifically when found under /etc, /usr, or /home - locations where a
# writable file/dir is a real tamper or privilege-escalation risk.
check_world_writable() {
  local path mode
  while IFS= read -r path; do
    case "$path" in
      /etc/*|/usr/*|/home/*)
        mode="$(stat -c '%a' "$path" 2>/dev/null || echo unknown)"
        add_finding "WARNING" "filesystem" "world_writable" \
          "World-writable path outside expected locations: ${path}" \
          "$(build_details path "$path" mode "$mode")"
        ;;
    esac
  done < <(find / -xdev \( -path /tmp -o -path /var/tmp -o -path /dev \) -prune -o -perm -0002 \( -type f -o -type d \) -print 2>/dev/null)
}

# check_bad_permissions: verify ownership and mode on the three core
# identity files against the CIS Rocky Linux 9 Benchmark target state.
# Ownership and mode issues on the same file both map to the single
# bad_permissions check per the assignment's finding contract.
check_bad_permissions() {
  local file actual_owner actual_mode expected_owner expected_mode
  for file in "$PASSWD_FILE" "$SHADOW_FILE" "$SUDOERS_FILE"; do
    [[ -e "$file" ]] || continue
    actual_owner="$(stat -c '%U:%G' "$file")"
    actual_mode="$(stat -c '%a' "$file")"
    expected_owner="${EXPECT_OWNER[$file]}"
    expected_mode="${EXPECT_MODE[$file]}"
    if [[ "$actual_owner" != "$expected_owner" ]]; then
      add_finding "CRITICAL" "filesystem" "bad_permissions" \
        "${file} owned by ${actual_owner}, expected ${expected_owner}" \
        "$(build_details path "$file" actual_owner "$actual_owner" expected_owner "$expected_owner")"
    fi
    if [[ "$actual_mode" != "$expected_mode" ]]; then
      add_finding "CRITICAL" "filesystem" "bad_permissions" \
        "${file} has mode ${actual_mode}, expected ${expected_mode}" \
        "$(build_details path "$file" actual_mode "$actual_mode" expected_mode "$expected_mode")"
    fi
  done
}

# check_unowned_files: files/dirs owned by a UID or GID with no matching
# /etc/passwd or /etc/group entry - find's -nouser/-nogroup do exactly this
# lookup natively. A common artifact of a deleted account whose files were
# never cleaned up or reassigned.
check_unowned_files() {
  local path uid gid
  while IFS= read -r path; do
    uid="$(stat -c '%u' "$path" 2>/dev/null || echo unknown)"
    gid="$(stat -c '%g' "$path" 2>/dev/null || echo unknown)"
    add_finding "WARNING" "filesystem" "unowned_file" \
      "File or directory owned by a UID/GID with no matching account: ${path}" \
      "$(build_details path "$path" uid "$uid" gid "$gid")"
  done < <(find / -xdev \( -nouser -o -nogroup \) 2>/dev/null)
}

# ── Account & Privilege Auditing ──────────────────────────────────────────────

# check_duplicate_uid0: any account other than root with UID 0 has full
# root privileges under a different name - a classic backdoor technique.
check_duplicate_uid0() {
  local user uid
  while IFS=: read -r user _ uid _; do
    if [[ "$uid" == "0" && "$user" != "root" ]]; then
      add_finding "CRITICAL" "accounts" "duplicate_uid0" \
        "Account '${user}' has UID 0 (root-equivalent) but is not the root account" \
        "$(build_details user "$user" uid "$uid")"
    fi
  done < "$PASSWD_FILE"
}

# check_empty_password: a truly empty password hash field in /etc/shadow
# (not "!", "!!", or "*", which mean locked/disabled) means that account
# can log in with no password at all.
check_empty_password() {
  local user hash
  while IFS=: read -r user hash _; do
    if [[ -z "$hash" ]]; then
      add_finding "CRITICAL" "accounts" "empty_password" \
        "Account '${user}' has an empty password hash in /etc/shadow" \
        "$(build_details user "$user")"
    fi
  done < "$SHADOW_FILE"
}

# check_stale_privileged_accounts: members of the wheel group (sudo-capable
# on Rocky Linux) who haven't logged in within STALE_LOGIN_DAYS, or never
# have. Uses `lastlog -b` rather than hand-parsing dates. Only checks
# *supplementary* wheel membership via getent - an account using wheel as
# its primary group would not be listed here, a known simplification.
check_stale_privileged_accounts() {
  local members member stale_users
  members="$(getent group wheel 2>/dev/null | awk -F: '{print $4}')" || true
  [[ -z "$members" ]] && return 0
  stale_users="$(lastlog -b "$STALE_LOGIN_DAYS" 2>/dev/null | tail -n +2 | awk '{print $1}')" || true
  IFS=',' read -ra member_list <<< "$members"
  for member in "${member_list[@]}"; do
    [[ -z "$member" ]] && continue
    if grep -qx "$member" <<< "$stale_users" 2>/dev/null; then
      add_finding "WARNING" "accounts" "stale_privileged_account" \
        "wheel-group member '${member}' has not logged in within ${STALE_LOGIN_DAYS} days (or never)" \
        "$(build_details user "$member" threshold_days "$STALE_LOGIN_DAYS")"
    fi
  done
}

# check_nopasswd_sudo: an active (uncommented) NOPASSWD entry in sudoers
# lets whoever it applies to run commands as root with no authentication
# at all - flagged for review since it may be a legitimate automation
# entry with its own compensating controls, or it may not be.
check_nopasswd_sudo() {
  local file line
  for file in "$SUDOERS_FILE" /etc/sudoers.d/*; do
    [[ -f "$file" ]] || continue
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" == *NOPASSWD* ]] || continue
      add_finding "WARNING" "accounts" "nopasswd_sudo" \
        "Active NOPASSWD sudoers entry in ${file}: ${line}" \
        "$(build_details path "$file" entry "$line")"
    done < "$file"
  done
}

# ── Network Exposure ───────────────────────────────────────────────────────────

# check_unexpected_listeners: any TCP/UDP socket listening on 0.0.0.0 or ::
# (all interfaces) on a proto/port not in EXPECTED_LISTENERS.
check_unexpected_listeners() {
  local proto state recvq sendq local_addr peer port key whitelisted w
  while read -r proto state recvq sendq local_addr peer; do
    case "$local_addr" in
      0.0.0.0:*) port="${local_addr##*:}" ;;
      \[::\]:*|:::*) port="${local_addr##*:}" ;;
      *) continue ;;
    esac
    key="${proto}/${port}"
    whitelisted=0
    for w in "${EXPECTED_LISTENERS[@]}"; do
      [[ "$key" == "$w" ]] && whitelisted=1 && break
    done
    if [[ "$whitelisted" -eq 0 ]]; then
      add_finding "WARNING" "network" "unexpected_listener" \
        "Service listening on all interfaces, not on the expected-services list: ${key}" \
        "$(build_details proto "$proto" port "$port")"
    fi
  done < <(ss -Htuln 2>/dev/null)
}

# check_external_connections: established outbound connections to a remote
# address outside RFC1918/loopback ranges. IPv4 only. INFO severity, not
# WARNING/CRITICAL - a lot of these will be entirely legitimate (package
# updates, NTP, etc.), so this is flagged for human review, not treated as
# inherently bad.
check_external_connections() {
  local netid state recvq sendq local_addr remote_addr remote_ip
  while read -r netid state recvq sendq local_addr remote_addr; do
    remote_ip="${remote_addr%:*}"
    [[ "$remote_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || continue
    if ! is_private_ip "$remote_ip"; then
      add_finding "INFO" "network" "external_connection" \
        "Established outbound connection to non-private address: ${remote_ip}" \
        "$(build_details remote_ip "$remote_ip")"
    fi
  done < <(ss -Htn state established 2>/dev/null)
}

# ── SSH Configuration ─────────────────────────────────────────────────────────

# check_sshd_config: flags known-risky sshd_config directives. Only matches
# an explicit, uncommented directive - an omitted directive relies on the
# OpenSSH build's compiled-in default and is not evaluated here.
check_sshd_config() {
  [[ -f "$SSHD_CONFIG" ]] || return 0
  local line
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    case "$line" in
      [Pp]asswordAuthentication\ *[Yy]es*)
        add_finding "WARNING" "ssh" "ssh_password_auth_enabled" \
          "sshd_config allows password authentication: ${line}" \
          "$(build_details directive "$line")" ;;
      [Pp]ermitRootLogin\ *[Yy]es*)
        add_finding "CRITICAL" "ssh" "ssh_root_login_enabled" \
          "sshd_config permits direct root login: ${line}" \
          "$(build_details directive "$line")" ;;
      [Xx]11Forwarding\ *[Yy]es*)
        add_finding "WARNING" "ssh" "ssh_x11_forwarding_enabled" \
          "sshd_config allows X11 forwarding: ${line}" \
          "$(build_details directive "$line")" ;;
      [Pp]rotocol\ *1*)
        add_finding "CRITICAL" "ssh" "ssh_protocol1_enabled" \
          "sshd_config allows deprecated, cryptographically broken SSH protocol 1: ${line}" \
          "$(build_details directive "$line")" ;;
    esac
  done < "$SSHD_CONFIG"
}

# check_authorized_keys: flags any account whose ~/.ssh/authorized_keys has
# more than AUTHORIZED_KEYS_THRESHOLD entries - not inherently wrong, but
# worth a human looking at why one account has so many trusted keys.
check_authorized_keys() {
  local user home keyfile count
  while IFS=: read -r user _ _ _ _ home _; do
    keyfile="${home}/.ssh/authorized_keys"
    [[ -f "$keyfile" ]] || continue
    count="$(grep -cve '^[[:space:]]*$' -e '^[[:space:]]*#' "$keyfile" 2>/dev/null)" || count=0
    if [[ "$count" -gt "$AUTHORIZED_KEYS_THRESHOLD" ]]; then
      add_finding "WARNING" "ssh" "excessive_authorized_keys" \
        "${user} has ${count} keys in authorized_keys (threshold: ${AUTHORIZED_KEYS_THRESHOLD})" \
        "$(build_details user "$user" path "$keyfile" count "$count")"
    fi
  done < "$PASSWD_FILE"
}

# ── Scheduled Tasks ────────────────────────────────────────────────────────────

# extract_cron_fields LINE HAS_USER_FIELD - given one crontab line (5 time
# fields, optionally a user field for /etc/crontab and cron.d, then the
# command), prints "USER COMMAND_PATH" separated by a space. USER is "-"
# for per-user spool lines (the caller already knows the user from the
# spool filename in that case).
extract_cron_fields() {
  local line="$1" has_user="$2"
  if [[ "$has_user" -eq 1 ]]; then
    awk '{print $6, $7}' <<< "$line"
  else
    awk '{print "-", $6}' <<< "$line"
  fi
}

# check_cron_issues: flags a scheduled command that either (a) lives in a
# world-writable directory, so any local user can replace what runs next,
# or (b) runs as root but the script file itself is group- or
# other-writable, so a non-root user with write access can alter root's
# next scheduled run.
check_cron_issues() {
  local src line run_user cmd_path dir_mode file_mode

  for src in /etc/crontab /etc/cron.d/*; do
    [[ -f "$src" ]] || continue
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" =~ ^[[:space:]]*$ ]] && continue
      read -r run_user cmd_path <<< "$(extract_cron_fields "$line" 1)"
      [[ "$cmd_path" == /* ]] || continue
      [[ -e "$cmd_path" ]] || continue

      dir_mode="$(stat -c '%a' "$(dirname "$cmd_path")" 2>/dev/null || echo 000)"
      if (( 8#$dir_mode & 0002 )); then
        add_finding "CRITICAL" "cron" "cron_world_writable_path" \
          "Scheduled command runs from a world-writable directory: ${cmd_path} (${src}, runs as ${run_user})" \
          "$(build_details path "$cmd_path" source "$src" run_as "$run_user" dir_mode "$dir_mode")"
      fi

      if [[ "$run_user" == "root" ]]; then
        file_mode="$(stat -c '%a' "$cmd_path" 2>/dev/null || echo 000)"
        if (( 8#$file_mode & 0022 )); then
          add_finding "CRITICAL" "cron" "cron_writable_script" \
            "Root-run scheduled command is group- or other-writable: ${cmd_path} (${src})" \
            "$(build_details path "$cmd_path" source "$src" mode "$file_mode")"
        fi
      fi
    done < "$src"
  done

  for src in /var/spool/cron/*; do
    [[ -f "$src" ]] || continue
    run_user="$(basename "$src")"
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" =~ ^[[:space:]]*$ ]] && continue
      read -r _ cmd_path <<< "$(extract_cron_fields "$line" 0)"
      [[ "$cmd_path" == /* ]] || continue
      [[ -e "$cmd_path" ]] || continue

      dir_mode="$(stat -c '%a' "$(dirname "$cmd_path")" 2>/dev/null || echo 000)"
      if (( 8#$dir_mode & 0002 )); then
        add_finding "CRITICAL" "cron" "cron_world_writable_path" \
          "Scheduled command runs from a world-writable directory: ${cmd_path} (${src}, runs as ${run_user})" \
          "$(build_details path "$cmd_path" source "$src" run_as "$run_user" dir_mode "$dir_mode")"
      fi

      if [[ "$run_user" == "root" ]]; then
        file_mode="$(stat -c '%a' "$cmd_path" 2>/dev/null || echo 000)"
        if (( 8#$file_mode & 0022 )); then
          add_finding "CRITICAL" "cron" "cron_writable_script" \
            "Root-run scheduled command is group- or other-writable: ${cmd_path} (${src})" \
            "$(build_details path "$cmd_path" source "$src" mode "$file_mode")"
        fi
      fi
    done < "$src"
  done
}

# ── Report assembly ────────────────────────────────────────────────────────────

# write_json_report: assembles the top-level JSON object. critical_count/
# warning_count/info_count are the accumulator totals, which by construction
# always equal the number of findings entries with the matching severity.
write_json_report() {
  local joined
  joined="$(IFS=,; echo "${FINDINGS_JSON[*]:-}")"
  cat > "$REPORT_FILE" <<EOF
{
  "hostname": "${HOSTNAME_VAL}",
  "audit_date": "${REPORT_DATE}",
  "critical_count": ${CRITICAL_COUNT},
  "warning_count": ${WARNING_COUNT},
  "info_count": ${INFO_COUNT},
  "findings": [${joined}]
}
EOF
}

main() {
  echo "=== CYBER HW 2 Security Audit - $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

  check_suid_sgid
  check_world_writable
  check_bad_permissions
  check_unowned_files

  check_duplicate_uid0
  check_empty_password
  check_stale_privileged_accounts
  check_nopasswd_sudo

  check_unexpected_listeners
  check_external_connections

  check_sshd_config
  check_authorized_keys

  check_cron_issues

  write_json_report

  echo "==="
  echo "Summary: ${CRITICAL_COUNT} CRITICAL, ${WARNING_COUNT} WARNING, ${INFO_COUNT} INFO"
  echo "Full report: ${REPORT_FILE}"

  if [[ "$CRITICAL_COUNT" -gt 0 ]]; then
    exit 1
  fi
  exit 0
}

main "$@"
```

---

[← Back to CYBER HW 2]({% link homework/cyber-hw-02.md %})
