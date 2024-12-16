# Security Audit Script
# Version: 2.0
# Author: ![Ricky](https://github.com/Ricky-bruh/)

# Function: Check System Security
function Check-SystemSecurity {
    Write-Host "============================================"
    Write-Host "Starting Security Audit..." -ForegroundColor Green
    Write-Host "============================================"
    
    # Check Windows Defender Status
    Write-Host "`nChecking Windows Defender Status..." -ForegroundColor Yellow
    Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, IoavProtectionEnabled, AMServiceEnabled

    # Check Firewall Status
    Write-Host "`nChecking Firewall Status..." -ForegroundColor Yellow
    Get-NetFirewallProfile | Select-Object Name, Enabled

    # Check Running Services
    Write-Host "`nChecking Critical Services..." -ForegroundColor Yellow
    $services = @('WinDefend', 'SecurityHealthService', 'wuauserv')
    foreach ($service in $services) {
        Get-Service -Name $service | Select-Object Name, Status, StartType
    }

    # Check Network Connections
    Write-Host "`nChecking Active Network Connections..." -ForegroundColor Yellow
    Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort

    # Check System Updates
    Write-Host "`nChecking Recent Updates..." -ForegroundColor Yellow
    Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 10
}

# Function: Analyze Security Events
function Analyze-SecurityEvents {
    Write-Host "`nAnalyzing Security Events..." -ForegroundColor Yellow
    Get-EventLog -LogName Security -Newest 50 | 
        Where-Object {$_.EntryType -eq "FailureAudit"} |
        Select-Object TimeGenerated, EventID, Message
}

# Function: Check Disk Space
function Check-DiskSpace {
    Write-Host "`nChecking Disk Space..." -ForegroundColor Yellow
    Get-WmiObject -Class Win32_LogicalDisk |
        Where-Object {$_.DriveType -eq 3} |
        Select-Object DeviceID, @{n='FreeSpace(GB)';e={[math]::Round($_.FreeSpace/1GB,2)}}, @{n='TotalSize(GB)';e={[math]::Round($_.Size/1GB,2)}}
}

# Main Execution
Write-Host "PC Security Audit Tool" -ForegroundColor Cyan
Write-Host "Version 2.0" -ForegroundColor Cyan
Write-Host "================================`n"

Check-SystemSecurity
Analyze-SecurityEvents
Check-DiskSpace

Write-Host "`n============================================"
Write-Host "Security Audit Complete!" -ForegroundColor Green
Write-Host "============================================"
