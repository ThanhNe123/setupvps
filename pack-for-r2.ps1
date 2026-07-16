# Dong goi file de upload len R2 (chay tren may local truoc khi deploy AIO)
$root = $PSScriptRoot
$out = Join-Path $root 'r2-upload'
New-Item -ItemType Directory -Path $out -Force | Out-Null

$winrar = @("${env:ProgramFiles}\WinRAR\WinRAR.exe", "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $winrar) { Write-Error 'Can WinRAR de dong goi'; exit 1 }

Write-Host 'Dong goi Mem Reduct...'
Push-Location $root
& $winrar a -r (Join-Path $out 'MemReduct.rar') 'Mem Reduct'

Write-Host 'Dong goi webrb...'
& $winrar a -r (Join-Path $out 'webrb.rar') 'webrb'

Write-Host 'Dong goi gialap...'
& $winrar a -r (Join-Path $out 'gialap.rar') 'gialap'
Pop-Location

Copy-Item (Join-Path $root 'setup-aio.ps1') $out -Force

Copy-Item (Join-Path $root 'LDPlayer_9.0.30_Lite_By_Mandu.exe') $out -Force
Copy-Item (Join-Path $root 'SetVirtualRAM.bat') $out -Force
Copy-Item (Join-Path $root 'tattb.bat') $out -Force

Write-Host ''
Write-Host "Upload tat ca file trong $out len R2:" -ForegroundColor Cyan
Write-Host 'https://pub-9f20d1ccb44e4694a145eb1d03b83dbc.r2.dev/' -ForegroundColor Yellow
Get-ChildItem $out | Format-Table Name, @{N='MB';E={[math]::Round($_.Length/1MB,2)}}
