# setupvps

Script AIO cai dat VPS farm: VoltX, Roblox settings, LDPlayer, Mem Reduct, webrb, gialap.

## Chay AIO tren VPS (1 lenh)

```powershell
iex (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ThanhNe123/setupvps/main/setup-aio.ps1' -UseBasicParsing).Content
```

Hoac copy 1 dong tu `setup-aio-oneline.txt`.

## Publish file len GitHub Release

```powershell
powershell -File pack-for-release.ps1
```

1. Mo https://github.com/ThanhNe123/setupvps/releases/new?tag=v1.0
2. Title: `v1.0`
3. Upload **tat ca** file trong folder `releases/`
4. Publish release

## File trong Release v1.0

| File | Muc dich |
|------|----------|
| VoltX.rar | volt-headless-p2 + settings + GlobalBasicSettings |
| LDPlayer_9.0.30_Lite_By_Mandu.exe | Emulator |
| MemReduct.rar | Giam RAM |
| SetVirtualRAM.bat | Cai RAM ao (Desktop) |
| tattb.bat | Tat canh bao Unknown Publisher |
| webrb.rar | Web client |
| gialap.rar | Gia lap |
