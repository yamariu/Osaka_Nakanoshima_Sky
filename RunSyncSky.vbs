Set WinScriptHost = CreateObject("WScript.Shell")
' Run PowerShell script in background (Window Style = 0)
WinScriptHost.Run "powershell.exe -ExecutionPolicy Bypass -File C:\Users\wappa\Documents\Arduino\Arduino-Sentinel-Indicator\SyncSkyColor.ps1", 0
Set WinScriptHost = Nothing
