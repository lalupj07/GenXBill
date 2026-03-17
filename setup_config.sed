[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=Welcome to GenXBill v5.0.0 Setup. Click OK to continue.
DisplayLicense=
FinishMessage=GenXBill v5.0.0 has been extracted. Please run install_genxbill.bat as administrator to complete installation.
TargetName=.\GenXBill_Setup_v5.0.0.exe
FriendlyName=GenXBill v5.0.0 Setup
AppLaunched=cmd /c install_genxbill.bat
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="genx_bill.exe"
FILE1="install_genxbill.bat"
FILE2="reset_database.bat"
FILE3="vc_redist.x64.exe"
FILE4="README_INSTALLATION.md"
[SourceFiles]
SourceFiles0=.\build\windows\x64\runner\Release\
SourceFiles1=.\
[SourceFiles0]
%FILE0%=
[SourceFiles1]
%FILE1%=
%FILE2%=
%FILE3%=
%FILE4%=
