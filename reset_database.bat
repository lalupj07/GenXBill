@echo off
echo ========================================
echo GenXBill Database Reset Utility
echo ========================================
echo.
echo This will clear all GenXBill data and fix initialization errors.
echo.
set /p CONFIRM="Are you sure you want to continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b 0
)

echo.
echo Closing GenXBill if running...
taskkill /F /IM genx_bill.exe >nul 2>&1

echo Clearing application data...
rd /s /q "%LOCALAPPDATA%\com.genxis" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\GenXis Innovation" >nul 2>&1

echo.
echo ========================================
echo Database Reset Complete!
echo ========================================
echo.
echo You can now run GenXBill again.
echo All data has been cleared and the app will start fresh.
echo.
pause
