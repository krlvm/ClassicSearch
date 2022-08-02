@echo off
if not "%1"=="admin" (powershell start -verb runas '%0' admin & exit /b)
reg delete "HKLM\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f
reg delete "HKLM\Software\WOW6432Node\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f