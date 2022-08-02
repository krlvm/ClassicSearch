# ClassicSearch

In Windows 10 version 1909 Microsoft updated File Explorer search - it is now running in the `SearchApp.exe` UWP process, which uses EdgeHTML WebView to render the UI, making it too slow to use even on high-end PCs. It also has very poor DPI scaling support, resulting in the bottom input border line gone on focus with fractional scaling factors (125%, 175%, etc.). Also, the search tab in Explorer Ribbon is not visible until you have done at least one search, and the ability to conveniently use advanced search filters is also gone.

Another change related to this was the increase in the height of the address bar of the explorer, which does not look very and not very necessary on devices without touchscreen support.

Unfortunately, the known way to turn off the "modern" search experience by importing some registry keys does not shrink the address bar height, there also haven't been any information on which key to add to disable this in the Open/Save dialogs of 32-bit processes on 64-bit systems.

This project provides a collection of batch files, which can be used to disable or restore "modern" search experience for current or all users - they call `reg.exe` command to add the needed registry keys, including those ones required for disabling the new search experience in 32-bit processes Open/Save dialogs. Those commands are also published below.

Also, this project contains a fix for the address bar height - it is a COM DLL that registers itself as a shell extension and prevents File Explorer from enlarging the address bar by returning `0` (as it should be) as `GetSystemMetricsForDpi` result for `SM_CYFIXEDFRAME`.

> **You need to have both x86 and x64 [Visual C++ Redistributable](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) installed as the DLL depends on it**

The distribution which can be downloaded from [Releases](https://github.com/krlvm/ClassicSearch/releases) includes the batch files for installation or disabling the modern search:
* **INSTALL.cmd** - install DLL for reducing address bar height and turn off modern search experience
* **UNINSTALL.cmd** - install DLL for reducing address bar height and restore modern search experience
* **DisableModernSearch-CurrentUser.cmd** - disable modern search experience for current user
* **RestoreModernSearch-CurrentUser.cmd** - restore modern search experience for current user
* **DisableModernSearch-AllUsers.cmd** - disable modern search experience for current user
* **RestoreModernSearch-AllUsers.cmd** - restore modern search experience for current user

It is also possible to have modern search enabled with tiny address bar - just execute `RestoreModernSearch-AllUsers.cmd` after installation.

If you want to disable modern search only for particular user, but keep tiny address bar, execute `RestoreModernSearch-AllUsers.cmd`, then `DisableModernSearch-CurrentUser.cmd`.

Before:\
![Before](https://github.com/krlvm/ClassicSearch/blob/master/github-images/before.png?raw=true)

After:\
![After](https://github.com/krlvm/ClassicSearch/blob/master/github-images/after.png?raw=true)

## Disable or Restore Modern Search Manually

### For Current User

Disable new Search Box:
```
reg.exe add "HKCU\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
reg.exe add "HKCU\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
```

Restore new Search Box:
```
reg.exe delete "HKCU\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}" /f
reg.exe delete "HKCU\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}" /f
```

### For All Users

This commands should be executed as administator.\
This also requires you to have write access on some registry keys - scripts from this project take the needed permissions automatically.

Disable new Search Box:
```
reg.exe add "HKLM\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
reg.exe add "HKLM\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
reg.exe add "HKLM\Software\WOW6432Node\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f /ve /t REG_SZ /d "{64bc32b5-4eec-4de7-972d-bd8bd0324537}"
```

Restore new Search Box:
```
reg.exe delete "HKLM\Software\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f
reg.exe delete "HKLM\Software\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f
reg.exe delete "HKLM\Software\WOW6432Node\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs" /f
```

## Credits
* [ExplorerPatcher](https://github.com/valinet/ExplorerPatcher) - IAT hooking code and [explaination](https://github.com/valinet/ExplorerPatcher/wiki/Using-ExplorerPatcher-as-shell-extension) of how to register shell extension