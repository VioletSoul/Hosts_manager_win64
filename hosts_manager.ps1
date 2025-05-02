# Hosts File Manager for Windows 11
# Adapted from macOS zsh version
# All comments are in English

# --- Settings ---
$HOSTS_FILE = "C:\Windows\System32\drivers\etc\hosts"
$BACKUP_DIR = "C:\Windows\System32\drivers\etc"
$LOG_FILE = "$env:USERPROFILE\hosts_manager.log"
$MAX_BACKUPS = 5

# --- Logging function ---
function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp $msg" | Tee-Object -FilePath $LOG_FILE -Append
}

# --- Check if script is running as Administrator ---
function Check-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as Administrator."
        exit 1
    }
}

# --- Create a backup of the hosts file and rotate old backups ---
function Backup-Hosts {
    $backupFile = Join-Path $BACKUP_DIR ("hosts.backup." + (Get-Date -Format "yyyyMMddHHmmss"))
    Copy-Item $HOSTS_FILE $backupFile -Force
    Log "Created backup: $backupFile"

    # Remove old backups if there are more than $MAX_BACKUPS
    $backups = Get-ChildItem $BACKUP_DIR -Filter "hosts.backup.*" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -gt $MAX_BACKUPS) {
        $toDelete = $backups | Select-Object -Skip $MAX_BACKUPS
        foreach ($file in $toDelete) {
            Remove-Item $file.FullName -Force
            Log "Deleted old backup: $($file.FullName)"
        }
    }
}

# --- List available backups ---
function List-Backups {
    $backups = Get-ChildItem $BACKUP_DIR -Filter "hosts.backup.*" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) {
        Write-Host "No backups found."
        return $null
    }
    Write-Host "Available backups:"
    $i = 1
    foreach ($bkp in $backups) {
        Write-Host "  $i) $($bkp.Name)"
        $i++
    }
    return $backups
}

# --- Restore hosts file from a selected backup ---
function Restore-Hosts {
    $backups = List-Backups
    if (-not $backups) { return }
    $choice = Read-Host "Enter backup number to restore (or press Enter to cancel)"
    if (-not $choice) { Log "Restore cancelled."; return }
    if ($choice -lt 1 -or $choice -gt $backups.Count) {
        Write-Host "Invalid choice."
        return
    }
    $selected = $backups[$choice - 1].FullName
    Copy-Item $selected $HOSTS_FILE -Force
    Log "Restored from: $selected"
    Show-Hosts
}

# --- Add a new host entry ---
function Add-HostEntry {
    $ip = Read-Host "Enter IP address"
    $hostname = Read-Host "Enter hostname"
    if (-not $ip -or -not $hostname) {
        Log "IP or hostname cannot be empty."
        return
    }
    # Simple validation for IPv4 and IPv6
    if (-not ($ip -match '^(\d{1,3}\.){3}\d{1,3}$' -or $ip -match '^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$')) {
        Log "Invalid IP format."
        return
    }
    Backup-Hosts
    Add-Content $HOSTS_FILE "$ip`t$hostname"
    Log "Added entry: $ip $hostname"
}

# --- Remove host entries by IP or hostname ---
function Remove-HostEntry {
    $target = Read-Host "Enter hostname or IP to remove"
    if (-not $target) {
        Log "Input cannot be empty."
        return
    }
    Backup-Hosts
    $lines = Get-Content $HOSTS_FILE
    $filtered = $lines | Where-Object {$_ -notmatch $target}
    Set-Content $HOSTS_FILE $filtered
    Log "Removed entries matching: $target"
}

# --- Validate hosts file syntax ---
function Validate-Hosts {
    Write-Host "Validating hosts file syntax..."
    $lines = Get-Content $HOSTS_FILE
    $errors = 0
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        # Skip comments and empty lines
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        $parts = $line -split '\s+'
        $ip = $parts[0]
        $hostnames = $parts[1..($parts.Count-1)]
        # Validate IP address
        if (-not ($ip -match '^(\d{1,3}\.){3}\d{1,3}$' -or $ip -match '^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$')) {
            Write-Host "Syntax error on line $lineNum (invalid IP): $line"
            $errors++
            continue
        }
        # Check if at least one hostname is present
        if ($hostnames.Count -eq 0) {
            Write-Host "Syntax error on line $lineNum (no hostname): $line"
            $errors++
        }
    }
    if ($errors -eq 0) {
        Write-Host "No syntax errors found."
    } else {
        Write-Host "$errors syntax error(s) found."
    }
}

# --- Check for duplicate IP-hostname pairs ---
function Check-Duplicates {
    Write-Host "Checking for duplicate IP-hostname pairs..."
    $pairs = @{}
    $lines = Get-Content $HOSTS_FILE
    $duplicates = @()
    foreach ($line in $lines) {
        # Skip comments and empty lines
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        $parts = $line -split '\s+'
        $ip = $parts[0]
        $hostnames = $parts[1..($parts.Count-1)]
        foreach ($hostnameEntry in $hostnames) {
            $key = "$ip $hostnameEntry"
            if ($pairs.ContainsKey($key)) {
                $duplicates += "$ip $hostnameEntry"
            } else {
                $pairs[$key] = $true
            }
        }
    }
    if ($duplicates.Count -eq 0) {
        Write-Host "No duplicates found."
    } else {
        Write-Host "Duplicates:"
        $duplicates | Sort-Object | Get-Unique | ForEach-Object { Write-Host $_ }
    }
}

# --- Export hosts file to a user-specified path ---
function Export-Hosts {
    $exportPath = Read-Host "Enter file path to export hosts"
    if (-not $exportPath) { Log "Export path cannot be empty."; return }
    Copy-Item $HOSTS_FILE $exportPath -Force
    Log "Exported to $exportPath"
}

# --- Import hosts file from a user-specified path ---
function Import-Hosts {
    $importPath = Read-Host "Enter file path to import hosts"
    if (-not (Test-Path $importPath)) {
        Log "File not found: $importPath"
        return
    }
    Backup-Hosts
    Copy-Item $importPath $HOSTS_FILE -Force
    Log "Imported from $importPath"
    Show-Hosts
}

# --- Reset hosts file to Windows default ---
function Reset-Hosts {
    $confirm = Read-Host "Reset hosts to default? [y/N]"
    if ($confirm -ne "y" -and $confirm -ne "Y") { return }
    Backup-Hosts
    $default = @"
# Copyright (c) 1993-2009 Microsoft Corp.
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
# localhost name resolution is handled within DNS itself.
127.0.0.1       localhost
::1             localhost
"@
    Set-Content $HOSTS_FILE $default
    Log "Hosts file reset to default."
    Show-Hosts
}

# --- Show current hosts file content ---
function Show-Hosts {
    Log "Current hosts file content:"
    Write-Host "------------------------------"
    Get-Content $HOSTS_FILE | Write-Host
    Write-Host "------------------------------"
}

# --- Print the main menu ---
function Print-Menu {
    Write-Host "Select an action:"
    Write-Host "  1) Reset to default"
    Write-Host "  2) Restore from backup"
    Write-Host "  3) Show current content"
    Write-Host "  4) Create a backup"
    Write-Host "  5) Add host entry"
    Write-Host "  6) Remove host entry"
    Write-Host "  7) Validate hosts file syntax"
    Write-Host "  8) Check for duplicate IP-hostname pairs"
    Write-Host "  9) Export hosts to file"
    Write-Host " 10) Import hosts from file"
    Write-Host "  0) Exit"
}

# --- Main loop ---
function Main {
    Check-Admin
    while ($true) {
        Clear-Host  # <--- This clears the terminal window
        Print-Menu
        $choice = Read-Host "Your choice"
        switch ($choice) {
            "1" { Reset-Hosts }
            "2" { Restore-Hosts }
            "3" { Show-Hosts }
            "4" { Backup-Hosts }
            "5" { Add-HostEntry }
            "6" { Remove-HostEntry }
            "7" { Validate-Hosts }
            "8" { Check-Duplicates }
            "9" { Export-Hosts }
            "10" { Import-Hosts }
            "0" {
                Log "Session ended."
                exit 0
            }
            default { Write-Host "Invalid choice!"; Start-Sleep -Seconds 1 }
        }
        Write-Host "`nPress Enter to continue..."
        Read-Host
    }
}


# --- Entry Point ---
Main
