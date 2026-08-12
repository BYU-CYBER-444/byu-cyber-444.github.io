---
title: "IT HW 2 - Broken named.conf"
parent: Homework
nav_exclude: true
---

# Acme Financial - Broken `/etc/named.conf`
{: .no_toc }

{: .note }
This is one of the three intentionally flawed configuration files referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 1. Audit it yourself before looking anywhere else - the point of the exercise is to find the gaps independently. It contains **at least 3 errors** across syntax, security, and operational categories.

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
    type master
    file "lab.internal.zone";
    allow-transfer { any; };
    notify no;
};

zone "0.0.10.in-addr.arpa" {
    type master;
    file "10.0.0.reverse";
    notify no;
}

zone "lab.internal" {
    type forward;
    forwarders { 8.8.8.8; };
};
```

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
