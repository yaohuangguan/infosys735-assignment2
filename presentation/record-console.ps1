# Capture one silent AWS Console segment from the Windows primary screen.
# Run from Windows PowerShell or through Remote Arc AFTER hiding any secrets.
# Example: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\samyao\work\infosys735-assignment2\presentation\record-console.ps1" -Part 1 -Seconds 300
param(
  [Parameter(Mandatory=$true)][ValidateRange(1,4)][int]$Part,
  [ValidateRange(20,1800)][int]$Seconds = 360,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$FFmpeg = 'C:\Program Files\ffmpeg\bin\ffmpeg.exe'
$FFprobe = 'C:\Program Files\ffmpeg\bin\ffprobe.exe'
if (-not (Test-Path -LiteralPath $FFmpeg)) { throw 'Windows FFmpeg missing at expected location.' }
$Names = @('Vincent','Zack','Sam','Kevin')
$Speaker = $Names[$Part-1]
$Repo = Split-Path -Parent $PSScriptRoot
$Dir = Join-Path $Repo 'recordings'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Out = Join-Path $Dir ('Part{0}_{1}_Raw_{2}.mp4' -f $Part,$Speaker,$Stamp)

Write-Host "Part $Part ($Speaker) — planned capture $Seconds seconds, no audio."
Write-Host 'Source: Windows primary display (2560x1440), saved at 1920x1080, 30fps.'
Write-Host "Output: $Out"
Write-Host 'Check that AWS keys, account credentials, email, personal notifications and other windows are hidden.'
if ($DryRun) { Write-Host '[DryRun] No recording started.'; exit 0 }

New-Item -ItemType Directory -Path $Dir -Force | Out-Null
if (Test-Path -LiteralPath $Out) { throw "Will not overwrite existing clip: $Out" }
Write-Host 'Recording starts in 3 seconds ...'
Start-Sleep -Seconds 3
# -t provides guaranteed MP4 finalization after the chosen time,
# even when recording is started via a remote non-interactive process.
$Arg = @(
  '-hide_banner','-loglevel','warning','-stats',
  '-f','gdigrab','-framerate','30',
  '-offset_x','0','-offset_y','0','-video_size','2560x1440',
  '-i','desktop','-an',
  '-vf','scale=1920:1080:flags=lanczos',
  '-c:v','libx264','-preset','veryfast','-crf','21',
  '-pix_fmt','yuv420p','-movflags','+faststart',
  '-t',"$Seconds",$Out
)
& $FFmpeg @Arg
if ($LASTEXITCODE -ne 0) { throw "FFmpeg returned exit code $LASTEXITCODE." }
if (-not (Test-Path -LiteralPath $Out)) { throw 'Output clip missing.' }
if ((Get-Item -LiteralPath $Out).Length -lt 10240) { throw 'Output MP4 unexpectedly small.' }
if (Test-Path -LiteralPath $FFprobe) {
  $duration = & $FFprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$Out"
  Write-Host "FFprobe duration (seconds): $duration"
}
Write-Host "SAVED: $Out"
