# Power off (or suspend) Windows (PowerShell/CMD). Usage: power-off.ps1 [-Sleep] [-DryRun]
param([switch]$Sleep, [switch]$DryRun)
$cmd = if ($Sleep) { 'rundll32.exe powrprof.dll,SetSuspendState 0,1,0' } else { 'shutdown /s /t 0' }
Write-Host "power-off: command: $cmd"
if ($DryRun) { exit 0 }
Start-Sleep -Seconds 5  # lets the calling agent finish its reply; Ctrl+C cancels
Invoke-Expression $cmd
