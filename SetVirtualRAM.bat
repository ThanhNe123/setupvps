@echo off
:: File thiet lap RAM ao cho may tinh
:: Min: 100000MB (~100GB) | Max: 150000MB (~150GB)
:: Chay voi quyen Admin

echo ============================================
echo    THIET LAP RAM AO (VIRTUAL MEMORY)
echo ============================================
echo.

:: Kiem tra quyen Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] Ban can chay file nay voi quyen ADMIN!
    echo Click phai vao file -^> Run as Administrator
    pause
    exit /b 1
)

echo Dang thiet lap RAM ao...
echo Min: 150000 MB (~150 GB)
echo Max: 150000 MB (~150 GB)
echo.

:: Tat tu dong quan ly RAM ao (Su dung cho Windows Doi Cu)
wmic computersystem set AutomaticManagedPagefile=False >nul 2>&1

:: Dat RAM ao tren o C: (thay doi neu can)
wmic pagefileset create name="C:\\pagefile.sys" >nul 2>&1
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=100000,MaximumSize=150000 >nul 2>&1

:: Thu xai nang cap Registry Powershell cho Windows 10/11 moi nhat
powershell -Command "$cs = Get-CimInstance Win32_ComputerSystem; $cs.AutomaticManagedPagefile = $false; Set-CimInstance -InputObject $cs;" >nul 2>&1
powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Type MultiString -Value 'C:\pagefile.sys 100000 150000' -Force" >nul 2>&1

echo.
echo ============================================
echo    HOAN THANH!
echo ============================================
echo.
echo May tinh se tu dong KHOI DONG LAI sau 10 giay...
echo Nhan phim bat ky de HUY khoi dong lai.
echo.

:: Dem nguoc 10 giay roi restart
shutdown /r /t 10 /c "Khoi dong lai de ap dung RAM ao moi"

pause >nul && shutdown /a
