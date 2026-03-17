@echo off
echo ========================================
echo GenXBill Installation Script
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo Installing GenXBill to C:\Program Files\GenXBill...
echo.

REM Create installation directory
if not exist "C:\Program Files\GenXBill" mkdir "C:\Program Files\GenXBill"

REM Copy application files
echo Copying application files...
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "C:\Program Files\GenXBill\"

REM Check if VC++ Redistributable is needed
echo.
echo Checking for Visual C++ Redistributable...
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
if %errorLevel% neq 0 (
    echo Visual C++ Redistributable not found.
    echo Installing Visual C++ Redistributable...
    if exist "vc_redist.x64.exe" (
        vc_redist.x64.exe /install /quiet /norestart
        echo VC++ Redistributable installed.
    ) else (
        echo WARNING: vc_redist.x64.exe not found!
        echo Please download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
        echo And place it in the same folder as this script.
    )
) else (
    echo Visual C++ Redistributable already installed.
)

REM Create desktop shortcut
echo.
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\GenXBill.lnk'); $Shortcut.TargetPath = 'C:\Program Files\GenXBill\genx_bill.exe'; $Shortcut.WorkingDirectory = 'C:\Program Files\GenXBill'; $Shortcut.Save()"

REM Create Start Menu shortcut
echo Creating Start Menu shortcut...
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\GenXBill" mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\GenXBill"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\GenXBill\GenXBill.lnk'); $Shortcut.TargetPath = 'C:\Program Files\GenXBill\genx_bill.exe'; $Shortcut.WorkingDirectory = 'C:\Program Files\GenXBill'; $Shortcut.Save()"

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo GenXBill has been installed to: C:\Program Files\GenXBill
echo Desktop shortcut created.
echo Start Menu shortcut created.
echo.

REM Ask to launch
set /p LAUNCH="Would you like to launch GenXBill now? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    start "" "C:\Program Files\GenXBill\genx_bill.exe"
)

pause
