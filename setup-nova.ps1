# Xoa VoltX + auto-start, tai Nova-Release.rar, giai nen Desktop, mo folder
$baseUrl = 'https://github.com/ThanhNe123/setupvps/releases/download/v1.0'
$novaUrl = "$baseUrl/Nova-Release.rar"
$desktop = [Environment]::GetFolderPath('Desktop')
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$startup = [Environment]::GetFolderPath('Startup')
$novaDir = Join-Path $desktop 'Nova-Release'
$voltDir = Join-Path $downloads 'VoltX'
$appDir = Join-Path $env:APPDATA 'VoltX'
$autoexecDir = Join-Path $env:LOCALAPPDATA 'Volt\autoexec'

function Expand-Rar($Archive, $Dest) {
    if (-not (Test-Path $Archive)) { throw "Khong tim thay file giai nen: $Archive" }
    if ((Get-Item $Archive).Length -lt 1000000) { throw "File giai nen qua nho / tai loi: $Archive" }
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    $outDir = ($Dest.TrimEnd('\') + '\')
    $winrar = @("${env:ProgramFiles}\WinRAR\WinRAR.exe", "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($winrar) {
        $proc = Start-Process -FilePath $winrar -ArgumentList @('x', '-y', $Archive, $outDir) -Wait -PassThru -WindowStyle Hidden
        if ($proc.ExitCode -eq 0) { return }
        Write-Host "WinRAR loi (exit $($proc.ExitCode)), thu 7-Zip..." -ForegroundColor Yellow
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
    if ($proc.ExitCode -ne 0) { throw "Giai nen that bai: $Archive (exit $($proc.ExitCode))" }
}

function Download-Nova($Url, $OutFile) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell' }
    for ($i = 1; $i -le 3; $i++) {
        try {
            Write-Host "Tai: $Url (lan $i/3)"
            if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -Headers $headers -TimeoutSec 600 -MaximumRedirection 10
            if ((Test-Path $OutFile) -and ((Get-Item $OutFile).Length -ge 1000000)) {
                $mb = [math]::Round((Get-Item $OutFile).Length / 1MB, 2)
                Write-Host "OK: $OutFile ($mb MB)" -ForegroundColor Green
                return
            }
            throw 'File tai ve qua nho hoac rong'
        } catch {
            Write-Host "Loi: $($_.Exception.Message)" -ForegroundColor Yellow
            if ($i -eq 3) {
                throw "Tai Nova-Release.rar that bai.`nUpload file len Release v1.0: https://github.com/ThanhNe123/setupvps/releases/tag/v1.0"
            }
            Start-Sleep -Seconds 5
        }
    }
}

Write-Host '=== [1/4] Dung process VoltX / Nova / watcher ===' -ForegroundColor Cyan
@('volt-headless-p2', 'volt-headless', 'nova') | ForEach-Object {
    Get-Process -Name $_ -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like '*watch-volt-headless.ps1*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Write-Host '=== [2/4] Xoa VoltX, auto-start, autoexec ===' -ForegroundColor Cyan
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
if (Test-Path $autoexecDir) {
    Remove-Item (Join-Path $autoexecDir '*') -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Da xoa noi dung: $autoexecDir" -ForegroundColor Yellow
}
Get-ChildItem $startup -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match 'volt|nova|autoexe' -or $_.Name -like '*headless*'
} | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force
    Write-Host "Da xoa startup: $($_.FullName)" -ForegroundColor Yellow
}

Write-Host '=== [3/4] Tai Nova-Release.rar ===' -ForegroundColor Cyan
$rarPath = Join-Path $env:TEMP 'Nova-Release.rar'
if (Test-Path $novaDir) { Remove-Item $novaDir -Recurse -Force }
Download-Nova $novaUrl $rarPath

Write-Host '=== [4/4] Giai nen -> Desktop\Nova-Release ===' -ForegroundColor Cyan
Expand-Rar $rarPath $novaDir
if (-not (Test-Path (Join-Path $novaDir 'nova.exe'))) { throw "Khong tim thay nova.exe trong $novaDir" }
Write-Host "OK: $novaDir" -ForegroundColor Green

Write-Host '=== HOAN TAT ===' -ForegroundColor Cyan
Start-Process explorer.exe $novaDir
