# AIO Setup VPS - tai tu GitHub Releases, giai nen, cai dat, watcher VoltX
# Dong goi: pack-for-release.ps1 | Upload releases/ len GitHub Release v1.0

$baseUrl = 'https://github.com/ThanhNe123/setupvps/releases/download/v1.0'
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$desktop = [Environment]::GetFolderPath('Desktop')
$voltDir = Join-Path $downloads 'VoltX'
$voltExe = Join-Path $voltDir 'volt-headless-p2.exe'
$procName = 'volt-headless-p2'
$robloxDir = Join-Path $env:LOCALAPPDATA 'Roblox'
$robloxFile = Join-Path $robloxDir 'GlobalBasicSettings_13.xml'
$appDir = Join-Path $env:APPDATA 'VoltX'
$watchScript = Join-Path $appDir 'watch-volt-headless.ps1'
$memReductDir = Join-Path $desktop 'Mem Reduct'
$webrbDir = Join-Path $desktop 'webrb'
$gialapDir = Join-Path $desktop 'gialap'

function Expand-Rar($Archive, $Dest) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    $winrar = @("${env:ProgramFiles}\WinRAR\WinRAR.exe", "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($winrar) {
        & $winrar x -y $Archive ($Dest + '\')
        if ($LASTEXITCODE -eq 0) { return }
    }
    $seven = @("${env:ProgramFiles}\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $seven) {
        Write-Host 'Dang cai 7-Zip...' -ForegroundColor Yellow
        $inst = Join-Path $env:TEMP '7z-install.exe'
        Invoke-WebRequest -Uri 'https://7-zip.org/a/7z2409-x64.exe' -OutFile $inst -UseBasicParsing
        Start-Process $inst -ArgumentList '/S' -Wait
        $seven = @("${env:ProgramFiles}\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    if (-not $seven) { throw 'Khong giai nen duoc RAR - hay cai WinRAR hoac 7-Zip' }
    & $seven x -y $Archive "-o$Dest"
    if ($LASTEXITCODE -ne 0) { throw "Giai nen that bai: $Archive" }
}

function Get-ExtractedDir($root, $name) {
    $direct = Join-Path $root $name
    if (Test-Path $direct) { return $direct }
    $found = Get-ChildItem -Path $root -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $name } | Select-Object -First 1
    if ($found) { return $found.FullName }
    return $direct
}

function Resolve-VoltDir {
    if (Test-Path $voltExe) { return }
    $found = Get-ChildItem -Path $downloads -Filter 'volt-headless-p2.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $found) { throw 'Khong tim thay volt-headless-p2.exe sau khi giai nen' }
    $srcDir = $found.DirectoryName
    if ($srcDir -ne $voltDir) {
        New-Item -ItemType Directory -Path $voltDir -Force | Out-Null
        Get-ChildItem -Path $srcDir | Move-Item -Destination $voltDir -Force
        if ($srcDir -like "$voltDir*") { Remove-Item $srcDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host '=== [1/9] Tai VoltX.rar ===' -ForegroundColor Cyan
$rarPath = Join-Path $env:TEMP 'VoltX.rar'
Invoke-WebRequest -Uri "$baseUrl/VoltX.rar" -OutFile $rarPath -UseBasicParsing
if (Test-Path $voltDir) { Remove-Item $voltDir -Recurse -Force }
Expand-Rar $rarPath $downloads
Resolve-VoltDir
Write-Host "OK: $voltDir" -ForegroundColor Green

Write-Host '=== [2/9] Tai LDPlayer ===' -ForegroundColor Cyan
$ldPlayer = Join-Path $downloads 'LDPlayer_9.0.30_Lite_By_Mandu.exe'
Invoke-WebRequest -Uri "$baseUrl/LDPlayer_9.0.30_Lite_By_Mandu.exe" -OutFile $ldPlayer -UseBasicParsing
Write-Host "OK: $ldPlayer" -ForegroundColor Green

Write-Host '=== [3/9] Tai Mem Reduct ===' -ForegroundColor Cyan
$memRar = Join-Path $env:TEMP 'MemReduct.rar'
if (Test-Path $memReductDir) { Remove-Item $memReductDir -Recurse -Force }
Invoke-WebRequest -Uri "$baseUrl/MemReduct.rar" -OutFile $memRar -UseBasicParsing
Expand-Rar $memRar $desktop
$memResolved = Get-ExtractedDir $desktop 'Mem Reduct'
if ($memResolved -ne $memReductDir -and (Test-Path $memResolved)) {
    Move-Item $memResolved $memReductDir -Force
}
$memExe = Join-Path $memReductDir 'memreduct.exe'
if (-not (Test-Path $memExe)) { throw "Khong tim thay $memExe" }
Start-Process -FilePath $memExe -WorkingDirectory $memReductDir
Write-Host "OK: $memReductDir (da bat memreduct)" -ForegroundColor Green

Write-Host '=== [4/9] Tai SetVirtualRAM.bat ===' -ForegroundColor Cyan
$setVram = Join-Path $desktop 'SetVirtualRAM.bat'
Invoke-WebRequest -Uri "$baseUrl/SetVirtualRAM.bat" -OutFile $setVram -UseBasicParsing
Write-Host "OK: $setVram" -ForegroundColor Green

Write-Host '=== [5/9] Tai va chay tattb.bat (Admin) ===' -ForegroundColor Cyan
$tattb = Join-Path $env:TEMP 'tattb.bat'
Invoke-WebRequest -Uri "$baseUrl/tattb.bat" -OutFile $tattb -UseBasicParsing
Start-Process -FilePath $tattb -Verb RunAs
Write-Host 'OK: da chay tattb.bat voi quyen Admin' -ForegroundColor Green

Write-Host '=== [6/9] Tai webrb ===' -ForegroundColor Cyan
$webrbRar = Join-Path $env:TEMP 'webrb.rar'
if (Test-Path $webrbDir) { Remove-Item $webrbDir -Recurse -Force }
Invoke-WebRequest -Uri "$baseUrl/webrb.rar" -OutFile $webrbRar -UseBasicParsing
Expand-Rar $webrbRar $desktop
$webrbResolved = Get-ExtractedDir $desktop 'webrb'
if ($webrbResolved -ne $webrbDir -and (Test-Path $webrbResolved)) {
    Move-Item $webrbResolved $webrbDir -Force
}
Write-Host "OK: $webrbDir" -ForegroundColor Green

Write-Host '=== [7/9] Tai gialap ===' -ForegroundColor Cyan
$gialapRar = Join-Path $env:TEMP 'gialap.rar'
if (Test-Path $gialapDir) { Remove-Item $gialapDir -Recurse -Force }
Invoke-WebRequest -Uri "$baseUrl/gialap.rar" -OutFile $gialapRar -UseBasicParsing
Expand-Rar $gialapRar $desktop
$gialapResolved = Get-ExtractedDir $desktop 'gialap'
if ($gialapResolved -ne $gialapDir -and (Test-Path $gialapResolved)) {
    Move-Item $gialapResolved $gialapDir -Force
}
Write-Host "OK: $gialapDir" -ForegroundColor Green

Write-Host '=== [8/9] GlobalBasicSettings -> Roblox ===' -ForegroundColor Cyan
$globalSrc = Join-Path $voltDir 'GlobalBasicSettings_13.xml'
if (-not (Test-Path $globalSrc)) { throw "Khong tim thay $globalSrc" }
New-Item -ItemType Directory -Path $robloxDir -Force | Out-Null
Write-Host "Folder Roblox: $robloxDir" -ForegroundColor Green
if (Test-Path $robloxFile) { (Get-Item $robloxFile).IsReadOnly = $false; Remove-Item $robloxFile -Force }
Copy-Item $globalSrc $robloxFile -Force
Set-ItemProperty -Path $robloxFile -Name IsReadOnly -Value $true
Write-Host "OK: $robloxFile (read-only)" -ForegroundColor Green

Write-Host '=== [9/9] Volt Headless Watchdog -> Startup ===' -ForegroundColor Cyan
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
Remove-Item (Join-Path $startup 'Volt Headless.lnk') -Force -ErrorAction SilentlyContinue
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
Write-Host "OK: $watchLnk" -ForegroundColor Green

if (-not (Get-Process -Name $procName -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $voltExe -WorkingDirectory $voltDir
    Write-Host "Da khoi dong: $voltExe" -ForegroundColor Green
}

Write-Host '=== HOAN TAT ===' -ForegroundColor Cyan
Start-Process explorer.exe $webrbDir
Start-Process explorer.exe $voltDir
Read-Host 'Nhan Enter de dong'
