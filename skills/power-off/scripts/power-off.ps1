# Power off Windows (PowerShell/CMD). Usage: power-off.ps1 [-DryRun]
param([switch]$DryRun)
Write-Host "power-off: command: shutdown /s /t 0"
if ($DryRun) { exit 0 }
Start-Sleep -Seconds 5  # lets the calling agent finish its reply; Ctrl+C cancels
shutdown /s /t 0
