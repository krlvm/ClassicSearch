@echo off

title ClassicSearch Uninstaller

cd /D "%~dp0"
if not "%1"=="admin" (powershell.exe start -verb runas '%0' admin & exit /b)

echo ClassicSearch
echo Restore classic File Explorer search and shrink address bar height
echo https://github.com/krlvm/ClassicSearch

echo.
echo Uninstalling ClassicSearch...

call RestoreModernSearch-AllUsers.cmd

taskkill /f /im explorer.exe
rmdir /S /Q "%ProgramFiles%\ClassicSearch\"

reg delete "HKLM\SOFTWARE\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /f
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /f
reg delete "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /f

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{8baaa930-ba82-40d9-9632-16fd947e6068}" /f

reg delete "HKLM\SOFTWARE\Classes\Drive\shellex\FolderExtensions\{8baaa930-ba82-40d9-9632-16fd947e6068}" /f

start explorer.exe

echo ClassicSearch has been uninstalled
pause