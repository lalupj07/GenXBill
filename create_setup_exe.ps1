# GenXBill Setup.exe Creator
# This script creates a self-extracting setup executable

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GenXBill Setup.exe Creator v5.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Inno Setup is installed
$innoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$innoSetupFound = Test-Path $innoSetupPath

if ($innoSetupFound) {
    Write-Host "Inno Setup found! Creating professional installer..." -ForegroundColor Green
    Write-Host ""
    
    # Compile the installer using Inno Setup
    & $innoSetupPath "installer.iss"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Setup.exe created successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Location: GenXBill_Setup_v5.0.0.exe" -ForegroundColor Yellow
    } else {
        Write-Host "Error creating installer with Inno Setup" -ForegroundColor Red
    }
} else {
    Write-Host "Inno Setup not found at: $innoSetupPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Creating alternative self-extracting installer..." -ForegroundColor Cyan
    Write-Host ""
    
    # Create a self-extracting archive using PowerShell
    $setupFolder = "GenXBill_Setup_v5.0.0"
    $setupExe = "GenXBill_Setup_v5.0.0.exe"
    
    # Create temporary setup folder
    if (Test-Path $setupFolder) {
        Remove-Item -Path $setupFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $setupFolder -Force | Out-Null
    
    # Copy files
    Write-Host "Copying application files..." -ForegroundColor Cyan
    Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "$setupFolder\" -Recurse -Force
    Copy-Item -Path "install_genxbill.bat" -Destination "$setupFolder\" -Force
    Copy-Item -Path "reset_database.bat" -Destination "$setupFolder\" -Force
    Copy-Item -Path "vc_redist.x64.exe" -Destination "$setupFolder\" -Force
    Copy-Item -Path "README_INSTALLATION.md" -Destination "$setupFolder\" -Force
    
    # Create installer script
    $installerScript = @"
@echo off
title GenXBill v5.0.0 Setup
color 0A
echo ========================================
echo GenXBill v5.0.0 Setup
echo ========================================
echo.
echo Extracting files...
echo.

REM Extract files to temp location
set TEMP_DIR=%TEMP%\GenXBill_Setup
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM This is a placeholder - in production, use a proper self-extracting archive tool
echo Please run install_genxbill.bat as administrator after extraction.
pause
"@
    
    Set-Content -Path "$setupFolder\setup.bat" -Value $installerScript
    
    # Create ZIP archive
    Write-Host "Creating compressed archive..." -ForegroundColor Cyan
    Compress-Archive -Path "$setupFolder\*" -DestinationPath "GenXBill_Setup_v5.0.0.zip" -Force
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Alternative installer created!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Created: GenXBill_Setup_v5.0.0.zip" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create a proper .exe installer, please:" -ForegroundColor Cyan
    Write-Host "1. Download Inno Setup from: https://jrsoftware.org/isdl.php" -ForegroundColor White
    Write-Host "2. Install it to: C:\Program Files (x86)\Inno Setup 6\" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
