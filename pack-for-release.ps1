# Dong goi tat ca file de upload len GitHub Release v1.0
$root = $PSScriptRoot
$out = Join-Path $root 'releases'
New-Item -ItemType Directory -Path $out -Force | Out-Null

$winrar = @("${env:ProgramFiles}\WinRAR\WinRAR.exe", "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $winrar) { Write-Error 'Can WinRAR'; exit 1 }

Write-Host 'Dong goi VoltX.rar...'
$voltSrc = Join-Path (Split-Path $root -Parent) 'VoltX'
if (-not (Test-Path (Join-Path $voltSrc 'volt-headless-p2.exe'))) {
    $voltSrc = Join-Path $root 'VoltX'
}
if (-not (Test-Path (Join-Path $voltSrc 'volt-headless-p2.exe'))) {
    Write-Error "Khong tim thay VoltX folder co volt-headless-p2.exe"
    exit 1
}
Push-Location (Split-Path $voltSrc -Parent)
& $winrar a -r (Join-Path $out 'VoltX.rar') (Split-Path $voltSrc -Leaf)
Pop-Location

Write-Host 'Dong goi Mem Reduct, webrb, gialap...'
Push-Location $root
& $winrar a -r (Join-Path $out 'MemReduct.rar') 'Mem Reduct'
& $winrar a -r (Join-Path $out 'webrb.rar') 'webrb'
& $winrar a -r (Join-Path $out 'gialap.rar') 'gialap'
Pop-Location

Copy-Item (Join-Path $root 'LDPlayer_9.0.30_Lite_By_Mandu.exe') $out -Force
Copy-Item (Join-Path $root 'SetVirtualRAM.bat') $out -Force
Copy-Item (Join-Path $root 'tattb.bat') $out -Force

$novaSrc = Join-Path $root 'test-nova'
if (Test-Path (Join-Path $novaSrc 'nova.exe')) {
    Write-Host 'Dong goi Nova-Release.rar...'
    Push-Location $novaSrc
    & $winrar a -r (Join-Path $out 'Nova-Release.rar') '*'
    Pop-Location
} elseif (Test-Path (Join-Path $out 'Nova-Release.rar')) {
    Write-Host 'Giu Nova-Release.rar co san trong releases/'
} else {
    Write-Host 'Canh bao: chua co test-nova/ hoac Nova-Release.rar' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Upload tat ca file trong releases/ len GitHub:' -ForegroundColor Cyan
Write-Host 'https://github.com/ThanhNe123/setupvps/releases/new?tag=v1.0' -ForegroundColor Yellow
Get-ChildItem $out | Format-Table Name, @{N='MB';E={[math]::Round($_.Length/1MB,2)}}
