# KB006 - Backup, Restore, and SHA-256 Verification

## Overview

Verify recoverability by restoring content into a separate location and comparing hashes.

## Common Symptoms

Missing backup files, copy errors, unreadable restore or a digest mismatch.

## Likely Causes

Incomplete copy, changed source during capture, access failure, storage failure or later content modification.

## Diagnostic Commands

```powershell
$run = .\scripts\Invoke-BackupRestoreTest.ps1 -FailOnMismatch
$run.Checks[0].Data | Format-List
Get-FileHash -LiteralPath .\lab-data\notes.txt -Algorithm SHA256
```

## Troubleshooting Procedure

Keep inputs idle. Inventory relative names, calculate originals, copy/hash backup files, restore from backup and hash again. Every file must match across all three digests. Inspect errors instead of treating a missing digest as a match.

## Resolution

Retain failed evidence, correct the specific access/path/content problem and retry into a fresh directory. Use the controlled mismatch exercise to demonstrate a difference. Never delete originals as part of this lab.

## Verification

Compare every expected file and open representative restored content. SHA-256 equality verifies captured content, not metadata, backup authenticity or future recoverability.

## Escalation Criteria

Persistent mismatch, inaccessible files, live application data, system recovery needs, encrypted content or requirements for ACL/alternate-stream preservation.

