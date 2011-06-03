{* Copyright (C) 2009-2011 Karl-Michael Schindler
 *
 * This file is part of Heat Wizard.
 *
 * Heat Wizard is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * Heat Wizard is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Heat Wizard; see the file COPYING. If not, see
 * <http://www.gnu.org/licenses/> or write to the
 * Free Software Foundation, Inc.
 * 51 Franklin Street, Fifth Floor
 * Boston, MA 02110-1301, USA
 *
 * $URL$
 * $Id$
 *}

unit UPreferenceData;

{$mode objfpc}
{$H+}

interface

uses
  Classes,
  SysUtils;

type
  TPreferenceData = class
    FileVersion: string;
    Language:    string;
    FormsPosition: record
      Top, Left: integer
    end;
    constructor Create;
    destructor Destroy;
    procedure Save;
    procedure Read;
  end;

var
  PreferenceData: TPreferenceData;

implementation

uses
  StrUtils,
  {$IF Defined(DARWIN)}
  MacOSAll,
  {$ELSE}
  XMLConf,
  {$IFEND}
  Ulog,
  UPath;

constructor TPreferenceData.Create;
begin
  Inherited;
  Logger.Output('UPreferenceData', 'Create');
end;

destructor TPreferenceData.Destroy;
begin
  Inherited;
end;

procedure TPreferenceData.Read;
var
  Error: record
    NoFileversion:       boolean;
    NoLanguage:          boolean;
    NoFormsTopPosition:  boolean;
    NoFormsLeftPosition: boolean;
  end;
{$IF Defined(DARWIN)}
var
 StringConversionSuccess: boolean;
 DataString:              CFPropertyListRef;
 FileVersionBuffer:       str255;
 LanguageBuffer:          str255;
 FormsPositionTopBuffer:  str255;
 FormsPositionLeftBuffer: str255;
 TopCFString:             CFStringRef;
 LeftCFString:            CFStringRef;
begin
  Logger.Output('UPreferenceData', 'Enter Read');
  DataString := CFPreferencesCopyAppValue(CFStr('FileVersion'), kCFPreferencesCurrentApplication);
  if not (DataString = NIL) then
  begin
    StringConversionSuccess := CFStringGetPascalString(DataString,
                                   @FileVersionBuffer,
                                   Length(FileVersionBuffer),
                                   kCFStringEncodingUTF8);
    if not StringConversionSuccess then
    begin
      Logger.Output('UPreferenceData', 'Error reading Fileversion from file. Continue with Default');
      Error.NoFileversion := true;
    end
    else
    begin
      Logger.Output('UPreferenceData', 'Fileversion Buffer as read from file: ' + FileVersionBuffer);
      Error.NoFileversion := false;
    end;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'Error reading Fileversion from file. Continue with Default');
    Error.NoFileversion := true;
  end;

  DataString := CFPreferencesCopyAppValue(CFStr('Language'), kCFPreferencesCurrentApplication);
  if not (DataString = NIL) then
  begin
    StringConversionSuccess := CFStringGetPascalString(DataString,
                                   @LanguageBuffer,
                                   Length(LanguageBuffer),
                                   kCFStringEncodingUTF8);
  if not StringConversionSuccess then
  begin
    Logger.Output('UPreferenceData', 'Error reading Language from file. Continue with Default');
    Error.NoLanguage := true;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'Language Buffer as read from file: ' + LanguageBuffer);
    Error.NoLanguage := false;
  end;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'Error reading Language from file. Continue with Default');
    Error.NoFileversion := true;
  end;

  DataString := CFPreferencesCopyAppValue(CFStr('FormsPosition'), kCFPreferencesCurrentApplication);
  if not (DataString = NIL) then
  begin
    TopCFString := CFDictionaryGetValue (DataString, CFStr('Top'));
    StringConversionSuccess := CFStringGetPascalString(TopCFString,
                                   @FormsPositionTopBuffer,
                                   Length(FormsPositionTopBuffer),
                                   kCFStringEncodingUTF8);
    if StringConversionSuccess then
    begin
    LeftCFString := CFDictionaryGetValue (DataString, CFStr('Left'));
    StringConversionSuccess := CFStringGetPascalString(LeftCFString,
                                   @FormsPositionLeftBuffer,
                                   Length(FormsPositionLeftBuffer),
                                   kCFStringEncodingUTF8);
    end;
  if not StringConversionSuccess then
  begin
    Logger.Output('UPreferenceData', 'Error reading FormsPosition from file. Continue with Default');
    Error.NoFormsTopPosition := true;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'FormsPosition Buffer Top as read from file: ' + FormsPositionTopBuffer);
    Logger.Output('UPreferenceData', 'FormsPosition Buffer Left as read from file: ' + FormsPositionLeftBuffer);
    Error.NoFormsTopPosition := false;
  end;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'Error reading FormsPosition from file. Continue with Default');
    Error.NoFormsTopPosition := true;
  end;

{$ELSE}
var
  FileVersionBuffer:       string;
  LanguageBuffer:          string;
  FormsPositionTopBuffer:  string;
  FormsPositionLeftBuffer: string;
  Preferences:             TXMLConfig;

begin
  Logger.Output('UPreferenceData', 'Create PreferenceDoc');
  {$IF not defined(Windows)}
  PreferenceDirName := GetEnvironmentVariable('HOME') + PreferenceDirName;
  if not DirectoryExists(PreferenceDirName) then
  begin
    Logger.Output('UPreferenceData', 'Application directory not found. Trying to create: ' + PreferenceDirName);
    mkdir(PreferenceDirName);
  end;
  PreferenceFileName := PreferenceDirName + PreferenceFileName;
  {$IFEND}
  if not fileExists(PreferenceFileName) then
  begin
    Logger.Output('UPreferenceData', 'Preference file not found. Trying to create: ' + PreferenceFileName);
    FileVersionBuffer  := '1.0.0';
    LanguageBuffer     := 'en';
    FormsPosition.Top  := 130;
    FormsPosition.Left := 400;
  end
  else
  begin
    Preferences := TXMLConfig.Create(nil);
    Preferences.Filename := 'heatwizardTest.xml';

    FileVersionBuffer := Preferences.GetValue('FileVersion','1.0.0');
    if FileVersionBuffer = '' then
      Error.NoFileVersion := true;

    LanguageBuffer := Preferences.GetValue('Language', 'en');
    Error.NoLanguage := false;
    if LanguageBuffer = '' then
      Error.NoLanguage    := true;

    FormsPositionTopBuffer := intToStr(Preferences.GetValue('FormsPosition/Top', 130));
    Error.NoFormsTopPosition := false;
    if FormsPositionTopBuffer = '' then
      Error.NoFormsTopPosition    := true;

    FormsPositionLeftBuffer := intToStr(Preferences.GetValue('FormsPosition/Left', 400));
    Error.NoFormsLeftPosition := false;
    if FormsPositionLeftBuffer = '' then
      Error.NoFormsLeftPosition    := true;
    Preferences.Destroy;
  end;
{$IFEND}
  Logger.Output('UPreferenceData', 'Check: FileversionBuffer: ' + FileversionBuffer + ' LanguageBuffer: ' + LanguageBuffer);
  if (not Error.NoFileVersion) and AnsiMatchText(FileVersionBuffer, ['1.0.0']) then
    FileVersion := FileVersionBuffer
  else
    FileVersion := '1.0.0';
  if (not Error.NoLanguage) and AnsiMatchText(LanguageBuffer, ['en','de','fi', 'fr']) then
    Language := LanguageBuffer
  else
    Language := 'en';
  FormsPosition.Top  := StrToIntDef(FormsPositionTopBuffer, 130);
  FormsPosition.Left := StrToIntDef(FormsPositionLeftBuffer, 400);;
  PreferenceData.Save;
  Logger.Output('UPreferenceData', 'Leaving Read. Fileversion: ' + Fileversion + ' Language: ' + Language);
end;

procedure TPreferenceData.Save;
{$IF Defined(DARWIN)}
var
  FileVersionData: CFPropertyListRef;
  LanguageData:    CFPropertyListRef;
  PositionData:    CFPropertyListRef;
  keys: array [1..2] of CFStringRef;
  vals: array [1..2] of CFStringRef;
begin
  Logger.Output('UPreferenceData', 'Enter Save');
  Logger.Output('UPreferenceData', 'Fileversion: ' + FileVersion);
  Logger.Output('UPreferenceData', 'Language: '    + Language);
  Logger.Output('UPreferenceData', 'FormsPosition: Top: ' + intToStr(FormsPosition.Top) + ' Left: ' + intToStr(FormsPosition.Left));
  FileVersionData := CFStringCreateWithPascalString(kCFAllocatorDefault, FileVersion, kCFStringEncodingUTF8);
  CFPreferencesSetAppValue(CFStr('FileVersion'),   FileVersionData, kCFPreferencesCurrentApplication);

  LanguageData    := CFStringCreateWithPascalString(kCFAllocatorDefault, Language,    kCFStringEncodingUTF8);
  CFPreferencesSetAppValue(CFStr('Language'),      LanguageData,    kCFPreferencesCurrentApplication);

  keys[1] := CFStr('Top');
  vals[1] := CFStringCreateWithPascalString(kCFAllocatorDefault, intToStr(FormsPosition.Top),  kCFStringEncodingUTF8);
  keys[2] := CFStr('Left');
  vals[2] := CFStringCreateWithPascalString(kCFAllocatorDefault, intToStr(FormsPosition.Left), kCFStringEncodingUTF8);
  PositionData := CFDictionaryCreate(kCFAllocatorDefault, @keys, @vals, 2, Nil, Nil);
  CFPreferencesSetAppValue(CFStr('FormsPosition'), PositionData, kCFPreferencesCurrentApplication);

  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
{$ELSE}
var
  Preferences: TXMLConfig;
begin
  Logger.Output('UPreferenceData', 'Enter Save');
  Logger.Output('UPreferenceData', 'Fileversion: ' + FileVersion);
  Logger.Output('UPreferenceData', 'Language: '    + Language);
  Logger.Output('UPreferenceData', 'FormsPosition: Top: ' + intToStr(FormsPosition.Top) + ' Left: ' + intToStr(FormsPosition.Left));

  Preferences := TXMLConfig.Create(nil);
  Preferences.StartEmpty := true;
  Preferences.Clear;
  Preferences.Filename   := PreferenceFileName;

  Preferences.SetValue('FileVersion', FileVersion);
  Preferences.SetValue('Language',    Language);
  Preferences.SetValue('FormsPosition/Top',  intToStr(FormsPosition.Top));
  Preferences.SetValue('FormsPosition/Left', intToStr(FormsPosition.Left));

  Preferences.Flush;
  Preferences.Destroy;
{$IFEND}
end;

initialization
end.

