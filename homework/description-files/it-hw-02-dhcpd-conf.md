---
title: "IT HW 2 - Broken dhcpd.conf"
parent: Homework
nav_exclude: true
---

# Acme Financial - Broken `/etc/dhcp/dhcpd.conf`
{: .no_toc }

{: .note }
This is one of the three intentionally flawed configuration files referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 1. Audit it yourself before looking anywhere else - the point of the exercise is to find the gaps independently. It contains **at least 3 errors** across syntax, security, and operational categories.

```
default-lease-time 3600
max-lease-time 86400;

option domain-name "lab.internal";
option domain-name-servers 10.0.0.1;

subnet 10.0.0.0 netmask 255.255.255.0 {
    range 10.0.0.100 10.0.0.200;
    option routers 10.0.0.254;
    option broadcast-address 10.0.1.255;

    class "pxe-clients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient"
        filename "pxelinux.0";
        next-server 10.0.0.1;
    }
}

host www-server {
    hardware ethernet 00:50:56:aa:bb:01;
    fixed-address 10.0.0.150;
    option host-name "www";
}

subnet 10.0.1.0 netmask 255.255.255.0 {
    range 10.0.1.10 10.0.1.50;
    option routers 10.0.1.254;
}
```

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
