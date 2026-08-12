---
title: "IT HW 2 - Working dhcpd.conf (Given Environment)"
parent: Homework
nav_exclude: true
---

# Acme Financial - Working DHCP Configuration
{: .no_toc }

{: .note }
This is the **already-deployed, working** DHCP configuration referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 2. You are documenting a live Rocky Linux 9 ISC DHCP server a colleague built - you do not need to have built this yourself in a lab to complete Part 2.

**`/etc/dhcp/dhcpd.conf`:**

```
default-lease-time 3600;
max-lease-time 86400;
authoritative;

option domain-name "lab.internal";
option domain-name-servers 10.0.0.1;
option ntp-servers 10.0.0.1;

# Primary subnet
subnet 10.0.0.0 netmask 255.255.255.0 {
    range 10.0.0.100 10.0.0.200;
    option routers 10.0.0.254;
    option broadcast-address 10.0.0.255;

    # Vendor class for PXE clients
    class "pxe-clients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
        filename "pxelinux.0";
        next-server 10.0.0.1;
    }
}

# Static reservation for the web server
host www-server {
    hardware ethernet 00:50:56:aa:bb:01;
    fixed-address 10.0.0.10;
    option host-name "www";
}

# Management VLAN (documentation only - second interface not required)
subnet 10.0.1.0 netmask 255.255.255.0 {
    range 10.0.1.10 10.0.1.50;
    option routers 10.0.1.254;
    default-lease-time 600;
}
```

Listening interface, set in **`/etc/sysconfig/dhcpd`**:

```
DHCPDARGS="enp0s8"
```

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
