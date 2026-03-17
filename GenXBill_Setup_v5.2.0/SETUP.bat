@echo off
title GenXBill v5.2.0 Setup
color 0B
cls
echo.
echo  ========================================
echo   GenXBill v5.2.0 Setup
echo   GenXis Inc - Billing Made Simple
echo  ========================================
echo.
echo  This package contains GenXBill v5.2.0
echo.
echo  Installation Options:
echo  ---------------------
echo.
echo  [1] Install to Program Files (Recommended)
echo      - Requires Administrator privileges
echo      - Creates desktop and start menu shortcuts
echo      - Installs VC++ Redistributable if needed
echo.
echo  [2] Run Portable (No Installation)
echo      - Run directly from this folder
echo      - No admin rights required
echo      - No shortcuts created
echo.
echo  [3] Reset Database (Fix Issues)
echo      - Clear all app data
echo      - Fix initialization errors
echo.
echo  [4] Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto portable
if "%choice%"=="3" goto reset
if "%choice%"=="4" goto end

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto start

:install
cls
echo.
echo Installing GenXBill...
echo.
call install_genxbill.bat
goto end

:portable
cls
echo.
echo Starting GenXBill in portable mode...
echo.
start "" genx_bill.exe
goto end

:reset
cls
echo.
echo Resetting database...
echo.
call reset_database.bat
goto end

:end
