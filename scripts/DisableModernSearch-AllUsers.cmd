@echo off
if not "%1"=="admin" (powershell.exe start -verb runas '%0' admin & exit /b)
cd /D "%~dp0"
powershell.exe -executionpolicy unrestricted .\AllUsers-Ownership.ps1
reg add "HKLM\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
reg add "HKLM\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
reg add "HKLM\Software\WOW6432Node\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"