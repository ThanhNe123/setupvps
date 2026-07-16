# Chi tao watchdog vao Startup — chay an, chi hien cua so volt-headless-p2
$voltDir = Join-Path $env:USERPROFILE 'Downloads\VoltX'
$voltExe = Join-Path $voltDir 'volt-headless-p2.exe'
$appDir = Join-Path $env:APPDATA 'VoltX'
$watchScript = Join-Path $appDir 'watch-volt-headless.ps1'

if (-not (Test-Path $voltExe)) {
    Write-Error "Khong tim thay: $voltExe - hay dat volt-headless-p2.exe vao folder VoltX truoc."
    exit 1
}

New-Item -ItemType Directory -Path $appDir -Force | Out-Null
@'
$voltDir = Join-Path $env:USERPROFILE 'Downloads\VoltX'
$voltExe = Join-Path $voltDir 'volt-headless-p2.exe'
$procName = 'volt-headless-p2'
$intervalSec = 30
$logFile = Join-Path (Join-Path $env:APPDATA 'VoltX') 'watchdog.log'
function Write-Log($msg) { Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg" }
if (-not (Test-Path $voltExe)) { Write-Log "LOI: Khong tim thay $voltExe"; exit 1 }
Write-Log 'Watchdog started'
while ($true) {
    if (-not (Get-Process -Name $procName -ErrorAction SilentlyContinue)) {
        Write-Log "$procName khong chay - dang bat lai"
        Start-Process -FilePath $voltExe -WorkingDirectory $voltDir
    }
    Start-Sleep -Seconds $intervalSec
}
'@ | Set-Content -Path $watchScript -Encoding UTF8

$startup = [Environment]::GetFolderPath('Startup')
$oldLnk = Join-Path $startup 'Volt Headless.lnk'
if (Test-Path $oldLnk) { Remove-Item $oldLnk -Force; Write-Host "Da xoa shortcut cu: $oldLnk" }

$ws = New-Object -ComObject WScript.Shell
$psExe = (Get-Command powershell.exe).Source
$watchLnk = Join-Path $startup 'Volt Headless Watchdog.lnk'
$wsc = $ws.CreateShortcut($watchLnk)
$wsc.TargetPath = $psExe
$wsc.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watchScript`""
$wsc.WorkingDirectory = $appDir
$wsc.Description = 'Tu bat va giam sat Volt Headless P2'
$wsc.WindowStyle = 7
$wsc.Save()
Write-Host "Da tao watchdog shortcut: $watchLnk"
Write-Host "Log: $(Join-Path $appDir 'watchdog.log')"

Start-Process explorer.exe 'shell:startup'
