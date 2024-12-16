# ==============================================
# System Info Script
# Made by Ricky - https://github.com/Ricky-bruh/
# ==============================================

Write-Host "Gathering system information..." -ForegroundColor Green

# Display Windows Version
Write-Host "Windows Version:"
Get-ComputerInfo | Select-Object WindowsVersion

# Check Installed Updates
Write-Host "`nInstalled Updates:"
Get-HotFix | Select-Object HotFixID, InstalledOn

# List Startup Programs
Write-Host "`nStartup Programs:"
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command

Write-Host "`nSecurity Scan Recommended!"
