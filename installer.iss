[Setup]
AppName=GenXBill
AppVersion=5.2.0
AppPublisher=GenXis Inc
DefaultGroupName=GenXBill
DefaultDirName={autopf}\GenXBill
UninstallDisplayIcon={app}\genx_bill.exe
Compression=lzma2
SolidCompression=yes
OutputDir=.
OutputBaseFilename=GenXBill_Setup_v5.2.0
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\genx_bill.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Visual C++ Redistributable
Source: "vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: VCRedistNeedsInstall

[Icons]
Name: "{group}\GenXBill"; Filename: "{app}\genx_bill.exe"
Name: "{commondesktop}\GenXBill"; Filename: "{app}\genx_bill.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
; Install Visual C++ Redistributable first if needed
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Visual C++ Redistributable..."; Check: VCRedistNeedsInstall
; Then run the main app
Filename: "{app}\genx_bill.exe"; Description: "{cm:LaunchProgram,GenXBill}"; Flags: nowait postinstall skipifsilent

[Code]
function VCRedistNeedsInstall: Boolean;
begin
  // Check if Visual C++ 2015-2022 Redistributable (x64) is installed
  // Registry key for VC++ 14.30-14.40 (VS 2022)
  if RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64') then
  begin
    Result := False;
    Exit;
  end;
  // Check for VC++ 2015-2019 (14.0-14.29)
  if RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64') then
  begin
    Result := False;
    Exit;
  end;
  // Check for VC++ 2015-2022 in Wow6432Node
  if RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64') then
  begin
    Result := False;
    Exit;
  end;
  // If not found, need to install
  Result := True;
end;
