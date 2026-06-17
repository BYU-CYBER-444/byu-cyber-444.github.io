---
title: "IT LAB 3 - Windows Server Infrastructure Roles"
parent: Labs
nav_order: 103
---

# IT LAB 3 - Windows Server Infrastructure Roles
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 3 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy and configure WSUS for patch management with downstream client targeting
- Configure DFS Namespace and DFS Replication between two folder targets
- Implement Windows Server Backup with a structured retention schedule
- Configure Group Policy for audit logging and software restriction
- Analyze patch compliance and produce a management-ready report

---

## Tools Required

- Windows Server 2022 VM (primary - DC + WSUS role)
- Windows Server 2022 VM (secondary - DFS replication target)
- Windows 10/11 client VM joined to domain
- PowerShell 5.1+, RSAT tools

---

## Background

Enterprise Windows environments rely on WSUS for controlled patch distribution (preventing untested patches from breaking production), DFS for high-availability file shares (users always access `\\domain\share` regardless of which server is hosting it), and structured backup for RPO/RTO compliance. A misconfigured WSUS that approves all updates automatically is as dangerous as no WSUS at all - it removes the change window control that ITIL mandates.

---

## Procedure

### Part 1 - WSUS Deployment and Configuration (60 min)

**1.1 Install WSUS role**

```powershell
# Run on primary server as Administrator
Install-WindowsFeature -Name UpdateServices, UpdateServices-UI `
    -IncludeManagementTools

# Initialize WSUS with local storage
& "C:\Program Files\Update Services\Tools\wsusutil.exe" postinstall `
    CONTENT_DIR="C:\WSUS"
```

**1.2 Configure WSUS via PowerShell**

```powershell
$wsus = Get-WsusServer -Name localhost -PortNumber 8530

# Set synchronization source
$wsusConfig = $wsus.GetConfiguration()
$wsusConfig.SyncFromMicrosoftUpdate = $true
$wsusConfig.Save()

# Configure products to synchronize
$wsus.GetSubscription().GetUpdateClassifications() | Where-Object {
    $_.Title -in @("Critical Updates","Security Updates","Definition Updates")
} | ForEach-Object {
    $_.SetFlag($true)
}

# Limit to Windows 10, Windows 11, Windows Server 2022
Get-WsusProduct | Where-Object {
    $_.Product.Title -match "Windows (10|11|Server 2022)"
} | Set-WsusProduct -Value $true

# Run initial synchronization
$wsus.GetSubscription().StartSynchronization()
Write-Host "Synchronization started. Monitor in WSUS console."
```

**1.3 Create computer groups**

```powershell
$wsus.CreateComputerTargetGroup("Pilot")
$wsus.CreateComputerTargetGroup("Production")
$wsus.CreateComputerTargetGroup("Servers")

# List groups to confirm
$wsus.GetComputerTargetGroups() | Select-Object Name, Id
```

**1.4 Configure automatic approval rules**

In the WSUS console (or via PowerShell): create an approval rule named "Critical Security Auto-Approve" that:
- Applies to: **Pilot** group only
- Approves: Critical Updates and Security Updates
- Does NOT auto-approve to Production (manual review required)

Document why auto-approving to Production is dangerous. Give one real-world example of a problematic cumulative update (e.g., KB5034441 causing WinRE update failures).

**1.5 Point a client to WSUS via GPO**

On the domain controller, create a new GPO named "WSUS-Client-Settings" and link to the domain:

```powershell
# Create and configure GPO
$gpo = New-GPO -Name "WSUS-Client-Settings"
$gpoPath = "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

Set-GPRegistryValue -Name "WSUS-Client-Settings" -Key "$gpoPath" `
    -ValueName "WUServer" -Type String `
    -Value "http://dc01.lab.internal:8530"

Set-GPRegistryValue -Name "WSUS-Client-Settings" -Key "$gpoPath" `
    -ValueName "WUStatusServer" -Type String `
    -Value "http://dc01.lab.internal:8530"

Set-GPRegistryValue -Name "WSUS-Client-Settings" `
    -Key "$gpoPath\AU" -ValueName "UseWUServer" -Type DWord -Value 1

Set-GPRegistryValue -Name "WSUS-Client-Settings" `
    -Key "$gpoPath\AU" -ValueName "AUOptions" -Type DWord -Value 3

New-GPLink -Name "WSUS-Client-Settings" -Target "DC=lab,DC=internal"
```

On the client VM, run `gpupdate /force` then `wuauclt /detectnow`. Verify the client appears in WSUS under **Unassigned Computers** within 10 minutes.

**1.6 Patch compliance report**

In the WSUS console, run **Reports → Computer Status → Status of Computers** for all groups. Export to HTML or screenshot showing: computer name, last reported status, needed updates count, installed updates count.

---

### Part 2 - DFS Namespace and Replication (45 min)

**2.1 Install DFS roles on both servers**

```powershell
# On both servers
Install-WindowsFeature -Name FS-DFS-Namespace, FS-DFS-Replication `
    -IncludeManagementTools
```

**2.2 Create a domain-based DFS Namespace**

```powershell
# On the namespace server (primary DC)
$namespace = "\\lab.internal\Files"
New-DfsnRoot -Path $namespace `
    -TargetPath "\\dc01\DFSRoots\Files" `
    -Type DomainV2 `
    -Description "Enterprise shared files namespace"

# Create DFS folders
New-DfsnFolder -Path "$namespace\Software" `
    -TargetPath "\\dc01\Software" `
    -Description "Software repository"

New-DfsnFolder -Path "$namespace\Docs" `
    -TargetPath "\\dc01\Docs" `
    -Description "Department documentation"
```

**2.3 Add a second target and configure replication**

```powershell
# Add secondary target
New-DfsnFolderTarget -Path "$namespace\Docs" `
    -TargetPath "\\srv02\Docs"

# Create replication group
New-DfsReplicationGroup -GroupName "Docs-RG" | Out-Null
Add-DfsrMember -GroupName "Docs-RG" -ComputerName "dc01", "srv02"

New-DfsReplicatedFolder -GroupName "Docs-RG" `
    -FolderName "Docs" `
    -DfsnPath "$namespace\Docs"

# Set primary member
Set-DfsrMembership -GroupName "Docs-RG" `
    -FolderName "Docs" `
    -ComputerName "dc01" `
    -ContentPath "C:\Shares\Docs" `
    -PrimaryMember $true `
    -Force

Set-DfsrMembership -GroupName "Docs-RG" `
    -FolderName "Docs" `
    -ComputerName "srv02" `
    -ContentPath "C:\Shares\Docs" `
    -Force
```

**2.4 Verify replication**

```powershell
# Check replication state
Get-DfsrState -GroupName "Docs-RG"

# Create a test file on dc01 and verify it appears on srv02
New-Item -Path "C:\Shares\Docs\replication_test.txt" -ItemType File `
    -Value "DFS replication test $(Get-Date)"

Start-Sleep -Seconds 30

# Check on srv02
Invoke-Command -ComputerName srv02 {
    Get-Item "C:\Shares\Docs\replication_test.txt"
}
```

From a client, access `\\lab.internal\Files\Docs` and verify you reach the share. Disconnect dc01's NIC and verify the client automatically fails over to srv02.

---

### Part 3 - Windows Server Backup with Retention Schedule (30 min)

**3.1 Install and configure**

```powershell
Install-WindowsFeature -Name Windows-Server-Backup

# Configure a backup policy
$policy = New-WBPolicy

# Add system state
Add-WBSystemState -Policy $policy

# Add specific volume
$volume = Get-WBVolume -AllVolumes | Where-Object { $_.DriveLetter -eq "C" }
Add-WBVolume -Policy $policy -Volume $volume

# Set backup target (use a secondary disk or network path)
$backupTarget = New-WBBackupTarget -VolumePath "D:"
Add-WBBackupTarget -Policy $policy -Target $backupTarget

# Schedule: daily at 02:00 and 14:00
Set-WBSchedule -Policy $policy -Schedule 02:00, 14:00

# Set backup retention (keep 14 versions)
Set-WBVersionTarget -Policy $policy -RetentionPolicy Copies -RetentionCount 14

Set-WBPolicy -Policy $policy -Force
```

**3.2 Run a manual backup and verify**

```powershell
# Start backup immediately
Start-WBBackup -Policy $policy

# Monitor progress
Get-WBJob -Previous 1

# List backup versions
Get-WBBackupTarget | Get-WBBackupSet
```

Document: backup duration, size, what components were included.

**3.3 Test partial restore**

```powershell
# Restore a specific file from the backup
$backupSet = Get-WBBackupSet | Select-Object -Last 1
$fileSpec = New-WBFileSpec -FileSpec "C:\Shares\Docs"
$restoreTarget = "C:\Restore_Test"

Start-WBFileRecovery -BackupSet $backupSet `
    -FileRestoreSpec $fileSpec `
    -RecoveryTarget $restoreTarget `
    -SkipRestoreAcl
```

Verify the restored files match the originals using `Get-FileHash`.

---

### Part 4 - GPO: Audit Logging and Software Restriction (30 min)

**4.1 Advanced Audit Policy GPO**

```powershell
$gpo = New-GPO -Name "Advanced-Audit-Policy"

# These registry keys are the MSS (Microsoft Solutions) mappings to audit subcategories
# Actual audit policy requires auditpol; set via GPO Security Settings
# Document the required subcategory settings:
```

In **Group Policy Management Editor → Computer Configuration → Windows Settings → Security Settings → Advanced Audit Policy Configuration**, enable:

| Category | Subcategory | Setting |
|----------|-------------|---------|
| Logon/Logoff | Logon | Success, Failure |
| Logon/Logoff | Logoff | Success |
| Account Logon | Credential Validation | Success, Failure |
| Account Management | User Account Management | Success, Failure |
| Object Access | File System | Failure |
| Policy Change | Audit Policy Change | Success |
| Privilege Use | Sensitive Privilege Use | Success, Failure |
| System | Security System Extension | Success |

Link GPO to the domain and run `gpupdate /force` on the client.

**4.2 Software Restriction Policy**

Create a second GPO "Software-Restriction" with an Applocker policy (or classic SRP) that:
- **Blocks** execution from `%TEMP%`, `%AppData%\Local\Temp`, and any path containing `\Downloads\`
- **Allows** only signed executables from `C:\Program Files` and `C:\Windows`

Document one real-world malware family that relies on executing from %TEMP% that this policy would block.

---

## Deliverables

1. WSUS: PowerShell install transcript, computer group configuration, GPO registry values, client detection screenshot, patch compliance report
2. DFS: Namespace and replication configuration commands + output, replication test file verification, failover test result
3. Backup: Policy configuration, manual backup output, file restore verification with hash comparison
4. GPO: Advanced audit subcategory table (configured) + Software Restriction policy description + malware example

---

## Grading

| Item | Points |
|------|--------|
| WSUS deployed, client detected, compliance report | 25 |
| DFS Namespace + Replication with failover test | 25 |
| Backup configured, executed, and restore tested | 25 |
| GPO: audit policy + software restriction | 25 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - WSUS Decline and Cleanup Automation
>
> WSUS databases grow large over time if unmanaged. Write a PowerShell script that performs monthly WSUS hygiene:
>
> 1. **Decline superseded updates**: Any update that has a newer superseding update and is older than 30 days should be declined.
> 2. **Decline expired updates**: All updates with `IsDeclined = $false` and `UpdatesSupersedingThisUpdate` not empty.
> 3. **Run server cleanup**: `Invoke-WsusServerCleanup -CleanupObsoleteUpdates -CleanupUnneededContentFiles -CompressUpdates -DeclineExpiredUpdates -DeclineSupersededUpdates`
> 4. **Report**: Output counts of declined, cleaned, and space recovered.
>
> Explain why running this script quarterly is part of good change management hygiene and how it aligns with ITIL 4 Practice: IT Asset Management.
>
> ### Extension B - DFS Replication Health Monitoring
>
> Manual checks of DFS replication state are insufficient for production. Build a monitoring solution:
>
> 1. Write a PowerShell script that queries `Get-DfsrState` for all replication groups and sends an email alert if any member reports a state other than `Normal`.
> 2. Schedule the script as a Windows Scheduled Task to run every 15 minutes.
> 3. Simulate a replication failure by stopping the DFS Replication service on srv02 and confirm the alert fires.
> 4. Extend the script to write a CSV log: `Timestamp, Group, Member, State, BacklogCount`.
>
> Submit both PowerShell scripts, the scheduled task configuration (XML export via `Export-ScheduledTask`), and a sample CSV log showing at least one Normal and one non-Normal state entry.

[← Back to Labs]({{ site.baseurl }}/labs/)
