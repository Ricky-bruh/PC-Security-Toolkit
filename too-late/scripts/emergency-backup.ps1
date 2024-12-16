# Emergency Backup Script
# Version: 1.0
# For use in emergency situations to backup critical data

# Configuration
$backupRoot = "D:\EmergencyBackup"
$logFile = "D:\EmergencyBackup\backup_log.txt"
$criticalFolders = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Downloads"
)

# Initialize Logging
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage
}

# Create Backup Directory
function Initialize-BackupDirectory {
    if (-not (Test-Path $backupRoot)) {
        New-Item -ItemType Directory -Path $backupRoot | Out-Null
        Write-Log "Created backup directory: $backupRoot"
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupDir = Join-Path $backupRoot $timestamp
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    return $backupDir
}

# Check Available Space
function Check-DiskSpace {
    param($Path)
    $drive = Split-Path -Qualifier $Path
    $freeSpace = (Get-PSDrive $drive.TrimEnd(':')).Free
    $freeSpaceGB = [math]::Round($freeSpace / 1GB, 2)
    Write-Log "Available space on $drive : $freeSpaceGB GB"
    return $freeSpace
}

# Backup Critical Files
function Backup-CriticalFiles {
    param($BackupDir)
    
    foreach ($folder in $criticalFolders) {
        if (Test-Path $folder) {
            $folderName = Split-Path $folder -Leaf
            $destination = Join-Path $BackupDir $folderName
            
            Write-Log "Backing up $folder..."
            try {
                Copy-Item -Path $folder -Destination $destination -Recurse -Force
                Write-Log "Successfully backed up $folderName"
            }
            catch {
                Write-Log "ERROR backing up $folderName : $_"
            }
        }
        else {
            Write-Log "WARNING: Source folder not found: $folder"
        }
    }
}

# Scan for Malware
function Scan-BackupForMalware {
    param($BackupDir)
    Write-Log "Starting security scan of backup..."
    try {
        Start-Process "C:\Program Files\Windows Defender\MpCmdRun.exe" -ArgumentList "-Scan -ScanType 3 -File `"$BackupDir`"" -Wait
        Write-Log "Security scan completed"
    }
    catch {
        Write-Log "ERROR during security scan: $_"
    }
}

# Create System Report
function Create-SystemReport {
    param($BackupDir)
    $reportPath = Join-Path $BackupDir "system_report.txt"
    
    Write-Log "Creating system report..."
    try {
        systeminfo > $reportPath
        Get-Process | Out-File -Append $reportPath
        Get-Service | Out-File -Append $reportPath
        Write-Log "System report created: $reportPath"
    }
    catch {
        Write-Log "ERROR creating system report: $_"
    }
}

# Main Execution
Write-Host "Emergency Backup Tool - Starting..." -ForegroundColor Red
Write-Host "=================================" -ForegroundColor Red

try {
    # Initialize
    $backupDir = Initialize-BackupDirectory
    $freeSpace = Check-DiskSpace -Path $backupRoot
    
    if ($freeSpace -lt 10GB) {
        throw "Insufficient disk space for backup"
    }
    
    # Execute Backup
    Backup-CriticalFiles -BackupDir $backupDir
    Create-SystemReport -BackupDir $backupDir
    Scan-BackupForMalware -BackupDir $backupDir
    
    Write-Host "`nBackup Complete!" -ForegroundColor Green
    Write-Host "Backup location: $backupDir" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Log "CRITICAL ERROR: $_"
}
finally {
    Write-Host "`nCheck $logFile for detailed log" -ForegroundColor Yellow
}
