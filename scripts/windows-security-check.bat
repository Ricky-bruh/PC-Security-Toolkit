@echo off
REM ==============================================
REM PC Security Quick Check
REM Made by Ricky - https://github.com/Ricky-bruh/
REM ==============================================

echo ===========================
echo PC Security Quick Check
echo ===========================

echo 1. Checking for updates...
powershell -Command "Get-WindowsUpdate | Out-File updates.txt"
type updates.txt

echo 2. Scanning for malware...
"C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1

echo 3. Listing startup programs...
wmic startup get caption,command > startup.txt
type startup.txt

echo ===========================
echo Quick Check Complete
echo ===========================
pause
