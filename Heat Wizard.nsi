!include MUI2.nsh

!define name "Heat Wizard"

Name "${name}"
OutFile "${name} Installer.exe"
InstallDir "$PROGRAMFILES\${name}"
RequestExecutionLevel user
SetCompressor /SOLID lzma
XPStyle on

Page license
Page directory
Page instfiles

LicenseData "COPYING"

UninstPage uninstConfirm
UninstPage instfiles

Section ""
  SetOutPath $INSTDIR
  File "${name}.exe"
  File "Heat Wizard Release Notes 0.3.1.txt"
  CreateDirectory "$LOCALAPPDATA\${name}\languages\de\LC_MESSAGES"
  CreateDirectory "$LOCALAPPDATA\${name}\languages\en\LC_MESSAGES"
  CreateDirectory "$LOCALAPPDATA\${name}\languages\fr\LC_MESSAGES"
  CreateDirectory "$LOCALAPPDATA\${name}\languages\fi\LC_MESSAGES"
  SetOutPath      "$LOCALAPPDATA\${name}\languages\"
  File /oname=de\LC_MESSAGES\heatwizard.mo languages\heatwizard.de.mo
  File /oname=en\LC_MESSAGES\heatwizard.mo languages\heatwizard.en.mo
  File /oname=fr\LC_MESSAGES\heatwizard.mo languages\heatwizard.fr.mo
  File /oname=fi\LC_MESSAGES\heatwizard.mo languages\heatwizard.fi.mo
  CreateDirectory "$SMPROGRAMS\${name}"
  CreateShortCut  "$SMPROGRAMS\${name}\${name}.lnk"           "$INSTDIR\${name}.exe"
  CreateShortCut  "$SMPROGRAMS\${name}\Uninstall ${name}.lnk" "$INSTDIR\uninstall.exe"
  CreateShortCut  "$SMPROGRAMS\${name}\Heat Wizard Release Notes 0.3.1.lnk" "$INSTDIR\Heat Wizard Release Notes 0.3.1.txt"
  WriteUninstaller $INSTDIR\uninstall.exe
SectionEnd

Section "Uninstall"
  RMDir /r "$LOCALAPPDATA\${name}"
  Delete   "$SMPROGRAMS\${name}\${name}.lnk"
  Delete   "$SMPROGRAMS\${name}\Uninstall ${name}.lnk"
  Delete   "$SMPROGRAMS\${name}\Heat Wizard Release Notes 0.3.1.lnk"
  RMDir    "$SMPROGRAMS\${name}"
  Delete   "$INSTDIR\${name}.exe"
  Delete   "$INSTDIR\Heat Wizard Release Notes 0.3.1.txt"
  Delete    $INSTDIR\uninstall.exe
  RMDir     $INSTDIR
SectionEnd