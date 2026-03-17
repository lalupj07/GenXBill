# GenXBill Installation Guide

## Simple Installation Method

### For Users (Recommended)

1. **Download the installation package** containing:
   - `install_genxbill.bat` (installer script)
   - `build\windows\x64\runner\Release\` folder (application files)
   - `vc_redist.x64.exe` (Visual C++ Redistributable)

2. **Right-click on `install_genxbill.bat`** and select **"Run as administrator"**

3. Follow the on-screen prompts

4. The installer will:
   - Install GenXBill to `C:\Program Files\GenXBill`
   - Install Visual C++ Redistributable (if needed)
   - Create desktop and Start Menu shortcuts
   - Optionally launch the application

### Manual Installation

If the batch script doesn't work:

1. **Install Visual C++ Redistributable first:**
   - Run `vc_redist.x64.exe`
   - Or download from: https://aka.ms/vs/17/release/vc_redist.x64.exe

2. **Copy application files:**
   - Copy the entire `build\windows\x64\runner\Release\` folder to `C:\Program Files\GenXBill`

3. **Run the application:**
   - Double-click `C:\Program Files\GenXBill\genx_bill.exe`

## Troubleshooting

### App doesn't open after installation

**Cause:** Missing Visual C++ Redistributable runtime

**Solution:**
1. Download and install: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Restart your computer
3. Try launching GenXBill again

### Permission errors during installation

**Cause:** Insufficient privileges

**Solution:**
- Right-click the installer and select "Run as administrator"

### App crashes on startup

**Cause:** Corrupted installation or missing files

**Solution:**
1. Uninstall GenXBill
2. Delete `C:\Program Files\GenXBill` folder
3. Reinstall using the installation script

## Creating Distribution Package

To create a distribution package for users:

```powershell
# 1. Ensure the app is built
flutter build windows --release

# 2. Create a distribution folder
New-Item -ItemType Directory -Path "GenXBill_Portable_v2.0.0" -Force

# 3. Copy necessary files
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "GenXBill_Portable_v2.0.0\" -Recurse
Copy-Item -Path "install_genxbill.bat" -Destination "GenXBill_Portable_v2.0.0\"
Copy-Item -Path "vc_redist.x64.exe" -Destination "GenXBill_Portable_v2.0.0\"
Copy-Item -Path "README_INSTALLATION.md" -Destination "GenXBill_Portable_v2.0.0\"

# 4. Compress to ZIP
Compress-Archive -Path "GenXBill_Portable_v2.0.0\*" -DestinationPath "GenXBill_Portable_v2.0.0.zip" -Force
```

Users can then extract the ZIP and run `install_genxbill.bat` as administrator.
