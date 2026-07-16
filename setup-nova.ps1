# Xoa VoltX + auto-start, tai Nova-Release.rar, giai nen Desktop, mo folder
$novaUrl = 'https://cdn.discordapp.com/attachments/927038770149195849/1527313276680016072/Nova-Release.rar?ex=6a5a34d5&is=6a58e355&hm=2a9aa0c8ed0719f1a58b909d05093d7923dedf058282df7632c0297f50b98359&'
$desktop = [Environment]::GetFolderPath('Desktop')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$startup = [Environment]::GetFolderPath('Startup')
$novaDir = Join-Path $desktop 'Nova-Release'
$voltDir = Join-Path $downloads 'VoltX'
$appDir = Join-Path $env:APPDATA 'VoltX'

function Expand-Rar($Archive, $Dest) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    $outDir = ($Dest.TrimEnd('\') + '\')
    $winrar = @("${env:ProgramFiles}\WinRAR\WinRAR.exe", "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($winrar) {
        $proc = Start-Process -FilePath $winrar -ArgumentList @('x', '-y', $Archive, $outDir) -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) { return }
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
    $proc = Start-Process -FilePath $seven -ArgumentList @('x', '-y', $Archive, "-o$outDir") -Wait -PassThru -WindowStyle Hidden
    if ($proc.ExitCode -ne 0) { throw "Giai nen that bai: $Archive" }
}

Write-Host '=== [1/4] Dung process VoltX / Nova / watcher ===' -ForegroundColor Cyan
@('volt-headless-p2', 'volt-headless', 'nova') | ForEach-Object {
    Get-Process -Name $_ -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*watch-volt-headless.ps1*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Write-Host '=== [2/4] Xoa VoltX, auto-start, autoexe ===' -ForegroundColor Cyan
@(
    (Join-Path $startup 'Volt Headless Watchdog.lnk'),
    (Join-Path $startup 'Volt Headless.lnk'),
    (Join-Path $desktop 'VoltX.lnk'),
    (Join-Path $desktop 'Volt.lnk')
) | ForEach-Object {
    if (Test-Path $_) { Remove-Item $_ -Force; Write-Host "Da xoa: $_" -ForegroundColor Yellow }
}
schtasks /delete /tn 'NovaVoltHeadless' /f 2>$null | Out-Null

@($voltDir, $appDir, (Join-Path $desktop 'VoltX'), (Join-Path $desktop 'autoexe'), (Join-Path $downloads 'autoexe')) | ForEach-Object {
    if (Test-Path $_) { Remove-Item $_ -Recurse -Force; Write-Host "Da xoa: $_" -ForegroundColor Yellow }
}
Get-ChildItem $startup -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match 'volt|nova|autoexe' -or $_.Name -like '*headless*'
} | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force
    Write-Host "Da xoa startup: $($_.FullName)" -ForegroundColor Yellow
}

Write-Host '=== [3/4] Tai Nova-Release.rar ===' -ForegroundColor Cyan
$rarPath = Join-Path $env:TEMP 'Nova-Release.rar'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = @{ 'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell' }
if (Test-Path $novaDir) { Remove-Item $novaDir -Recurse -Force }
Invoke-WebRequest -Uri $novaUrl -OutFile $rarPath -UseBasicParsing -Headers $headers -TimeoutSec 600
$mb = [math]::Round((Get-Item $rarPath).Length / 1MB, 2)
Write-Host "OK: $rarPath ($mb MB)" -ForegroundColor Green

Write-Host '=== [4/4] Giai nen -> Desktop\Nova-Release ===' -ForegroundColor Cyan
Expand-Rar $rarPath $novaDir
if (-not (Test-Path (Join-Path $novaDir 'nova.exe'))) { throw "Khong tim thay nova.exe trong $novaDir" }
Write-Host "OK: $novaDir" -ForegroundColor Green

Write-Host '=== HOAN TAT ===' -ForegroundColor Cyan
Start-Process explorer.exe $novaDir
