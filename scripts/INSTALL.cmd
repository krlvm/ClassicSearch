@echo off

title ClassicSearch Installer

cd /D "%~dp0"
if not "%1"=="admin" (powershell.exe start -verb runas '%0' admin & exit /b)

echo ClassicSearch
echo Restore classic File Explorer search and shrink address bar height
echo https://github.com/krlvm/ClassicSearch

echo.
echo Installing ClassicSearch...

call DisableModernSearch-AllUsers.cmd

xcopy dist "%ProgramFiles%\ClassicSearch\" /sy

reg add "HKLM\SOFTWARE\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /ve /t REG_SZ /d "ClassicSearch Address Bar Shrinker" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /ve /t REG_SZ /d "%ProgramFiles%\ClassicSearch\ClassicSearch64.dll" /f
reg add "HKLM\SOFTWARE\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f

reg add "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /ve /t REG_SZ /d "ClassicSearch Address Bar Shrinker" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /ve /t REG_SZ /d "%ProgramFiles%\ClassicSearch\ClassicSearch32.dll" /f
reg add "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f

reg add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}" /ve /t REG_SZ /d "ClassicSearch Address Bar Shrinker" /f
reg add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /ve /t REG_SZ /d "%ProgramFiles%\ClassicSearch\ClassicSearch32.dll" /f
reg add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{8baaa930-ba82-40d9-9632-16fd947e6068}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{8baaa930-ba82-40d9-9632-16fd947e6068}" /v "NoInternetExplorer" /t REG_SZ /d "1" /f

reg add "HKLM\SOFTWARE\Classes\Drive\shellex\FolderExtensions\{8baaa930-ba82-40d9-9632-16fd947e6068}" /v "DriveMask" /t REG_DWORD /d "255" /f

taskkill /f /im explorer.exe
timeout 1 > nul
start explorer.exe

echo ClassicSearch has been installed
pause