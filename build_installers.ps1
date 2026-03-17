# GenXBill v5.2.0 Installer Builder
# Creates both MSIX and Setup package

param(
    [switch]$SkipMSIX = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GenXBill v5.2.0 Installer Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify build exists
$buildPath = "build\windows\x64\runner\Release\genx_bill.exe"
if (-not (Test-Path $buildPath)) {
    Write-Host "ERROR: Build not found at $buildPath" -ForegroundColor Red
    Write-Host "Please run 'flutter build windows --release' first" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] Verifying build files..." -ForegroundColor Green
Write-Host "      Build found: $buildPath" -ForegroundColor Gray
Write-Host ""

# Create Setup ZIP Package
Write-Host "[2/4] Creating Setup Package..." -ForegroundColor Green

$setupFolder = "GenXBill_Setup_v5.2.0"
$setupZip = "GenXBill_Setup_v5.2.0.zip"

# Clean previous builds
if (Test-Path $setupFolder) {
    Remove-Item -Path $setupFolder -Recurse -Force
}
if (Test-Path $setupZip) {
    Remove-Item -Path $setupZip -Force
}

# Create setup folder
New-Item -ItemType Directory -Path $setupFolder -Force | Out-Null

# Copy all release files
Write-Host "      Copying application files..." -ForegroundColor Gray
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "$setupFolder\" -Recurse -Force

# Copy installer scripts
Write-Host "      Copying installer scripts..." -ForegroundColor Gray
Copy-Item -Path "install_genxbill.bat" -Destination "$setupFolder\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "reset_database.bat" -Destination "$setupFolder\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "vc_redist.x64.exe" -Destination "$setupFolder\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "README_INSTALLATION.md" -Destination "$setupFolder\" -Force -ErrorAction SilentlyContinue

# Create a simple launcher
$launcherContent = @"
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
"@

Set-Content -Path "$setupFolder\SETUP.bat" -Value $launcherContent

# Create README
$readmeContent = @"
# GenXBill v5.0.0 Setup Package

## Quick Start

1. Run **SETUP.bat** for guided installation
2. Choose installation method:
   - **Install**: Full installation with shortcuts (requires admin)
   - **Portable**: Run directly without installation
   - **Reset**: Clear database if you encounter errors

## Manual Installation

1. Right-click **install_genxbill.bat**
2. Select "Run as administrator"
3. Follow the prompts

## Portable Mode

Simply run **genx_bill.exe** directly from this folder.

## Troubleshooting

If the app shows "Application Initialization Failed":
1. Run **reset_database.bat**
2. Restart the application

## System Requirements

- Windows 10/11 (64-bit)
- Visual C++ Redistributable (included)
- 100 MB free disk space

## Support

For issues or questions, contact GenXis Inc.

Version: 5.2.0
Build Date: $(Get-Date -Format "yyyy-MM-dd")
"@

Set-Content -Path "$setupFolder\README.txt" -Value $readmeContent

# Compress to ZIP
Write-Host "      Creating ZIP archive..." -ForegroundColor Gray
Compress-Archive -Path "$setupFolder\*" -DestinationPath $setupZip -Force

$zipSize = [math]::Round((Get-Item $setupZip).Length / 1MB, 2)
Write-Host "      Created: $setupZip ($zipSize MB)" -ForegroundColor Green
Write-Host ""

# Check for MSIX
Write-Host "[3/4] Checking MSIX package..." -ForegroundColor Green
$msixPath = "build\windows\x64\runner\Release\genx_bill.msix"
if (Test-Path $msixPath) {
    $msixSize = [math]::Round((Get-Item $msixPath).Length / 1MB, 2)
    Write-Host "      Found: $msixPath ($msixSize MB)" -ForegroundColor Green
    
    # Copy MSIX to root for easy access
    Copy-Item -Path $msixPath -Destination "GenXBill_v5.2.0.msix" -Force
    Write-Host "      Copied to: GenXBill_v5.2.0.msix" -ForegroundColor Green
} else {
    Write-Host "      MSIX not found (run 'flutter pub run msix:create' to build)" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "[4/4] Build Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created Packages:" -ForegroundColor White
Write-Host ""

if (Test-Path $setupZip) {
    Write-Host "  [ZIP]  $setupZip" -ForegroundColor Green
    Write-Host "         Size: $zipSize MB" -ForegroundColor Gray
    Write-Host "         Type: Universal setup package" -ForegroundColor Gray
    Write-Host ""
}

if (Test-Path "GenXBill_v5.2.0.msix") {
    $msixSize = [math]::Round((Get-Item "GenXBill_v5.2.0.msix").Length / 1MB, 2)
    Write-Host "  [MSIX] GenXBill_v5.2.0.msix" -ForegroundColor Green
    Write-Host "         Size: $msixSize MB" -ForegroundColor Gray
    Write-Host "         Type: Microsoft Store package" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Distribution Ready!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Methods:" -ForegroundColor Yellow
Write-Host "  1. Extract ZIP and run SETUP.bat (Recommended)" -ForegroundColor White
Write-Host "  2. Double-click MSIX for Microsoft Store install" -ForegroundColor White
Write-Host ""
