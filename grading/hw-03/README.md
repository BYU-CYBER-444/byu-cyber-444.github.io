# HW 3 Autograder - TA Notes

This folder is instructor-only tooling for grading HW 3 (Stale Account Remediation
Pipeline). Students never see or touch this folder in this repo.

## Contents

- `FakeActiveDirectory.psm1` - in-memory stand-in for the real `ActiveDirectory` module.
  Exports functions with the same names as the real AD cmdlets (`Get-ADUser`,
  `Disable-ADAccount`, `Set-ADUser`, `Move-ADObject`, `Get-ADOrganizationalUnit`,
  `New-ADOrganizationalUnit`) backed by in-memory state, plus harness helpers
  (`Reset-FakeAD`, `Add-FakeADUser`, `Set-FakeADFailureTrigger`, etc.) used by the test suite.
- `hw-03-autograder.Tests.ps1` - Pester v5 suite that seeds a known dataset into the fake AD
  module, runs a student's submitted `hw-03-remediate.ps1` against it (dry-run and live), and
  asserts on observable outcomes. 17 checks across 5 contexts.
- `hw-03-grading.yml` - GitHub Actions workflow that runs the suite automatically on a PR.
  **See the placement note below - this file cannot run as-is in this repo.**
- `samples/good-remediate.ps1` - a correct reference implementation. Passes all 17 checks.
- `samples/bad-remediate.ps1` - a deliberately broken implementation (ignores `-WhatIf` and
  `-ExcludeList`, never moves/logs/labels accounts, missing CSV columns, no error handling).
  Fails 9 of 17 checks, confirming the suite actually discriminates good from bad submissions.

## Running it locally

```powershell
Import-Module ./grading/hw-03/FakeActiveDirectory.psm1 -Force   # done automatically by the test file
$env:HW03_STUDENT_SCRIPT = "./grading/hw-03/samples/good-remediate.ps1"
Invoke-Pester -Path ./grading/hw-03/hw-03-autograder.Tests.ps1 -Output Detailed
```

Swap in `samples/bad-remediate.ps1` or a real student submission path to test it instead.

## Placement caveat - read before relying on the CI workflow

This repo (`byu-cyber-444.github.io`) is the **course site** - assignment pages, schedule,
this grading tooling. Students never open PRs here. Per `resources/portfolio-setup.md`,
students submit by opening a PR in their own **GitHub Classroom repo**
(`cyber444-portfolio-yournetid`), forked from a Classroom **template repo**.

For the autograder to actually run on student PRs, copy three files into that template repo,
preserving the same relative paths:

```
<template-repo>/.github/workflows/hw-03-grading.yml   <- from grading/hw-03/hw-03-grading.yml
<template-repo>/grading/hw-03/FakeActiveDirectory.psm1
<template-repo>/grading/hw-03/hw-03-autograder.Tests.ps1
```

The workflow expects the student's submission at `homework/assets/hw-03-remediate.ps1`,
matching the path in `hw-03.md`'s Deliverables section. Until those three files are copied
into the Classroom template repo, this is a fully validated grading pipeline sitting in the
course site for reference/maintenance - it won't fire on a real student PR.
