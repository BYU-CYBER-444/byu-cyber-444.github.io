---
title: "IT HW 2 - Working exports (Given Environment)"
parent: Homework
nav_exclude: true
---

# Acme Financial - Working NFS Configuration
{: .no_toc }

{: .note }
This is the **already-deployed, working** NFS configuration referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 2. You are documenting a live Rocky Linux 9 NFS server a colleague built - you do not need to have built this yourself in a lab to complete Part 2. `/exports` sits on a dedicated 3 GB LVM volume (`vg_lab2/lv_exports`), not plain disk space - relevant to the reflection question in Part 3.

**`/etc/exports`:**

```
/exports/shared  10.0.0.0/24(rw,sync,no_subtree_check,root_squash)
/exports/builds  10.0.0.10(ro,sync,no_subtree_check,root_squash,nosuid,noexec)
```

`/exports/shared` is world-writable with the sticky bit set (`chmod 1777`, owned `nobody:nobody`) so any authenticated host on the subnet can drop files without one user clobbering another's; `/exports/builds` is read-only and restricted to the web server's own IP.

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
