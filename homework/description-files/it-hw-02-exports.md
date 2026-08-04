---
title: "IT HW 2 - Broken exports"
parent: Homework
nav_exclude: true
---

# Acme Financial - Broken `/etc/exports`
{: .no_toc }

{: .note }
This is one of the three intentionally flawed configuration files referenced in [IT HW 2]({% link homework/it-hw-02.md %}) Part 1. Audit it yourself before looking anywhere else - the point of the exercise is to find the gaps independently. It contains **at least 3 errors** across syntax, security, and operational categories.

```
/exports/shared  10.0.0.0/24(rw,async,no_root_squash)
/exports/build   10.0.0.10(ro,sync,subtree_check,nosuid,noexec)
/exports/shared  *(rw,sync,no_root_squash)
```

---

[← Back to IT HW 2]({% link homework/it-hw-02.md %})
