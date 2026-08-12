<#
.SYNOPSIS
    HW 3 - Inactive AD Account Discovery/Audit Script (provided to students).

.DESCRIPTION
    Read-only audit tool. Queries Active Directory for enabled user accounts that
    are stale (LastLogonDate older than -StaleDays) and/or have an expired password
    (PasswordLastSet older than -PasswordDays), excluding service accounts, and
    writes the findings to a CSV.

    This script makes NO changes to Active Directory. It does not disable, move,
    or otherwise modify any account. Remediation of the accounts it flags is your
    responsibility - see homework/hw-03.md Part 2.

.PARAMETER Domain
    The target AD domain, as a DNS name (e.g. "lab.local") or an existing domain
    controller/server name. Passed straight through to Get-ADUser's -Server
    parameter, and also used to build the LDAP search base (e.g. "lab.local"
    becomes "DC=lab,DC=local") so the query is scoped to the right domain. If you
    were given a specific domain controller hostname instead of a DNS domain name,
    pass that hostname and use -SearchBaseDN to set the search base explicitly.

.PARAMETER SearchBaseDN
    Optional. Overrides the LDAP search base normally derived from -Domain, e.g.
    "DC=lab,DC=local". Use this if -Domain is a server hostname rather than a DNS
    domain name, or if you need to scope the audit to a sub-OU.

.PARAMETER ExcludeList
    SamAccountNames to exclude from the report even if they otherwise match the
    staleness criteria (in addition to any account whose Description contains
    "Service Account").

.PARAMETER StaleDays
    Number of days since LastLogonDate after which an account is considered stale.

.PARAMETER PasswordDays
    Number of days since PasswordLastSet after which an account's password is
    considered expired for the purposes of this report.

.PARAMETER OutputPath
    Directory to write the output CSV to. Defaults to the current directory.

.EXAMPLE
    .\hw-03-audit.ps1 -Domain lab.local
    Runs with defaults against lab.local and writes .\stale-accounts-YYYY-MM-DD.csv

.EXAMPLE
    .\hw-03-audit.ps1 -Domain dc01.lab.local -SearchBaseDN "DC=lab,DC=local" -StaleDays 60 -PasswordDays 120 -OutputPath C:\reports
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [string]$SearchBaseDN,

    [string[]]$ExcludeList = @('svc-backup', 'svc-sql'),
    [int]$StaleDays = 90,
    [int]$PasswordDays = 180,
    [string]$OutputPath = "."
)

# Guarded so this script does not hard-fail on a machine without RSAT installed.
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

if (-not (Get-Command Get-ADUser -ErrorAction SilentlyContinue)) {
    Write-Error "The ActiveDirectory module is not available. Run this from a machine with RSAT installed and joined to the target domain, or with an active session to the domain controller."
    exit 1
}

if (-not $SearchBaseDN) {
    if ($Domain -match '^[^.]+\.[^.]+') {
        $SearchBaseDN = "DC=" + (($Domain -split '\.') -join ',DC=')
    }
    else {
        Write-Error "-Domain '$Domain' doesn't look like a DNS domain name (e.g. lab.local), so a search base can't be derived from it. Pass -SearchBaseDN explicitly (e.g. -SearchBaseDN 'DC=lab,DC=local')."
        exit 1
    }
}

$staleThreshold    = (Get-Date).AddDays(-$StaleDays)
$passwordThreshold = (Get-Date).AddDays(-$PasswordDays)

Write-Host "Querying AD for enabled accounts in '$SearchBaseDN' via '$Domain'..." -ForegroundColor Cyan

try {
    $allEnabledUsers = Get-ADUser -Server $Domain -SearchBase $SearchBaseDN -Filter { Enabled -eq $true } -Properties `
        DisplayName, LastLogonDate, PasswordLastSet, Description, EmailAddress, DistinguishedName
}
catch {
    Write-Error "Failed to query Active Directory: $($_.Exception.Message)"
    exit 1
}

$results = foreach ($user in $allEnabledUsers) {

    $isExcludedByList = $ExcludeList -contains $user.SamAccountName
    $isServiceAccount = $user.Description -and ($user.Description -match 'Service Account')

    if ($isExcludedByList -or $isServiceAccount) {
        continue
    }

    $isStale          = $user.LastLogonDate    -and ($user.LastLogonDate    -lt $staleThreshold)
    $isPasswordExpired = $user.PasswordLastSet -and ($user.PasswordLastSet -lt $passwordThreshold)

    # Accounts that have never logged on (LastLogonDate is $null) are treated as stale.
    if (-not $user.LastLogonDate) {
        $isStale = $true
    }

    if (-not ($isStale -or $isPasswordExpired)) {
        continue
    }

    $reason = if ($isStale -and $isPasswordExpired) { 'both' }
              elseif ($isStale)                      { 'stale' }
              else                                    { 'expired-password' }

    $ou = ($user.DistinguishedName -split ',(?=OU=|DC=)', 2)[1]

    [PSCustomObject]@{
        SamAccountName   = $user.SamAccountName
        DisplayName      = $user.DisplayName
        LastLogonDate    = $user.LastLogonDate
        PasswordLastSet  = $user.PasswordLastSet
        OU               = $ou
        Email            = $user.EmailAddress
        Reason           = $reason
        RecommendedAction = 'Disable + move to OU=Disabled'
    }
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$csvName = "stale-accounts-{0}.csv" -f (Get-Date -Format 'yyyy-MM-dd')
$csvPath = Join-Path $OutputPath $csvName

$results | Export-Csv -Path $csvPath -NoTypeInformation

$staleCount   = ($results | Where-Object { $_.Reason -eq 'stale' }).Count
$expiredCount = ($results | Where-Object { $_.Reason -eq 'expired-password' }).Count
$bothCount    = ($results | Where-Object { $_.Reason -eq 'both' }).Count
$totalCount   = $results.Count

Write-Host ""
Write-Host "=== Audit Summary ===" -ForegroundColor Yellow
Write-Host "Stale login only     : $staleCount"
Write-Host "Expired password only: $expiredCount"
Write-Host "Both                 : $bothCount"
Write-Host "Total flagged        : $totalCount"
Write-Host ""
Write-Host "Report written to: $csvPath" -ForegroundColor Green
Write-Host "No accounts were modified. Review the CSV and remediate manually per hw-03.md Part 2." -ForegroundColor Yellow
