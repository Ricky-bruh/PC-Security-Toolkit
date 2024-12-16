@echo off
:: System Security Check Script
:: Version: 2.0
:: Author: ![Ricky](https://github.com/Ricky-bruh/)

echo ============================================
echo PC Security Quick Check
echo ============================================
echo.

:: Check Windows Defender Status
echo Checking Windows Defender...
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -quick

:: List Running Services
echo.
echo Checking Critical Services...
sc query WinDefend
sc query wuauserv

:: Check Windows Updates
echo.
echo Checking Windows Updates...
powershell -Command "Get-WindowsUpdate"

:: Check Disk Space
echo.
echo Checking Disk Space...
wmic logicaldisk get deviceid,size,freespace

:: Check Network Connections
echo.
echo Checking Network Connections...
netstat -ano | findstr ESTABLISHED

:: Generate Report
echo.
echo Generating Security Report...
echo ---------------------------------------- > security_report.txt
echo Security Check Report >> security_report.txt
echo Date: %date% Time: %time% >> security_report.txt
echo ---------------------------------------- >> security_report.txt
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> security_report.txt

echo.
echo ============================================
echo Security Check Complete!
echo Report saved as security_report.txt
echo ============================================
pause
