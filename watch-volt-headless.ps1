# Giam sat volt-headless-p2.exe — chay an nen, chi mo cua so volt-headless-p2
$voltDir = Join-Path $env:USERPROFILE 'Downloads\VoltX'
$voltExe = Join-Path $voltDir 'volt-headless-p2.exe'
$procName = 'volt-headless-p2'
$intervalSec = 30
$logFile = Join-Path (Join-Path $env:APPDATA 'VoltX') 'watchdog.log'

function Write-Log($msg) {
    Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
}

if (-not (Test-Path $voltExe)) {
    Write-Log "LOI: Khong tim thay $voltExe"
    exit 1
}

Write-Log 'Watchdog started'
while ($true) {
    if (-not (Get-Process -Name $procName -ErrorAction SilentlyContinue)) {
        Write-Log "$procName khong chay - dang bat lai"
        Start-Process -FilePath $voltExe -WorkingDirectory $voltDir
    }
    Start-Sleep -Seconds $intervalSec
}
