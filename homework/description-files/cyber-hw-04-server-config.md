---
title: "CYBER HW 4 - Windows Server 2022 Configuration Snapshot"
parent: Homework
nav_exclude: true
---

# prod-fs-02 - Windows Server 2022 Configuration Snapshot
{: .no_toc }

{: .note }
This is the reference configuration snapshot for [CYBER HW 4]({% link homework/cyber-hw-04.md %}) Part 1 - the current, unhardened state of a production Windows Server 2022 file/application server, as a config review found it. Choose **15 of the 20** findings below to document as hardening controls. Use the stated current values as your "Default State" column - don't invent different ones.

| # | Finding | Current (Unhardened) State |
|---|---|---|
| 1 | LAN Manager authentication level | `LmCompatibilityLevel` = `1` ("Send LM & NTLM, use NTLMv2 session security if negotiated") under `HKLM:\SYSTEM\CurrentControlSet\Control\Lsa` |
| 2 | SMBv1 protocol | Enabled server-wide (`Get-SmbServerConfiguration` shows `EnableSMB1Protocol : True`) |
| 3 | SMB signing (server) | Not required - `RequireSecuritySignature` = `0` under `HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters` |
| 4 | LLMNR (Link-Local Multicast Name Resolution) | Enabled - no policy configured under `HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient` |
| 5 | NetBIOS over TCP/IP | Enabled ("Default") on all network adapters |
| 6 | NTLM traffic restriction | Not configured - `RestrictSendingNTLMTraffic` absent (equivalent to "Allow all") |
| 7 | Cached domain logon credentials | `CachedLogonsCount` = `10` (default) under `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon` |
| 8 | Local Administrator password management | No LAPS (Local Administrator Password Solution) deployed - local Administrator password is static and shared across servers |
| 9 | Credential Guard | Not enabled - no `LsaCfgFlags` configured, Virtualization-Based Security not turned on |
| 10 | Built-in Guest account | Enabled (`Get-LocalUser -Name Guest` shows `Enabled : True`) |
| 11 | Advanced Audit Policy - Logon/Logoff subcategories | Only legacy "Basic" auditing configured via `auditpol`; Advanced Audit Policy subcategories not enabled |
| 12 | PowerShell Script Block Logging | Disabled - `EnableScriptBlockLogging` = `0` (or absent) under `HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging` |
| 13 | Command-line process auditing | `ProcessCreationIncludeCmdLine_Enabled` not set (command lines are not included in process-creation events) |
| 14 | Centralized log collection (Windows Event Forwarding) | Not configured - Security event logs stay local to each server, no central collector |
| 15 | Object access auditing on sensitive shares | No SACL configured on `C:\FinanceShare` - no audit trail of who reads/writes files there |
| 16 | AppLocker | Not configured - no rules defined, service not running |
| 17 | Windows Defender Application Control (WDAC) | Not enabled |
| 18 | PowerShell language mode | `FullLanguage` (unrestricted) for all users - no Constrained Language Mode |
| 19 | Windows Defender Attack Surface Reduction (ASR) rules | None enabled |
| 20 | RDP Network Level Authentication (NLA) | Not required - `UserAuthentication` = `0` under `HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp` |

---

[← Back to CYBER HW 4]({% link homework/cyber-hw-04.md %})
