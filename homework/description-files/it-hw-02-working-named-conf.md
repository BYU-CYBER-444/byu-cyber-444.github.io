---
title: "IT HW 2 - Working named.conf (Given Environment)"
parent: Homework
nav_exclude: true
---

# Acme Financial - Working DNS Configuration
{: .no_toc }

{: .note }
This is the **already-deployed, working** DNS configuration referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 2. You are documenting a live Rocky Linux 9 BIND server a colleague built - you do not need to have built this yourself in a lab to complete Part 2.

**`/etc/named.conf`:**

```
options {
    directory "/var/named";
    recursion no;
    allow-query { any; };
    dnssec-validation auto;
    listen-on { 127.0.0.1; 10.0.0.1; };
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

**`/var/named/lab.internal.zone`:**

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

**`/var/named/10.0.0.rev`:**

```
$TTL 3600
@   IN  SOA  ns1.lab.internal. admin.lab.internal. (
            2024010101 3600 900 604800 300 )

    IN  NS   ns1.lab.internal.

1   IN  PTR  ns1.lab.internal.
10  IN  PTR  www.lab.internal.
20  IN  PTR  mail.lab.internal.
```

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
