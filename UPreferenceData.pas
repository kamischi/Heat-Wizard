{* Copyright (C) 2009 Karl-Michael Schindler
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
  DOM,
  XMLRead,
  XMLWrite,
  {$IFEND}
  Ulog,
  UPath;

{$IF not Defined(DARWIN)}
var
  PreferenceDoc: TXMLDocument;
{$IFEND}

constructor TPreferenceData.Create;
begin
  Logger.Output('UPreferenceData', 'Create');
{$IF not Defined(DARWIN)}
  PreferenceDoc := TXMLDocument.Create;
{$IFEND}
end;

destructor TPreferenceData.Destroy;
begin
{$IF not Defined(DARWIN)}
    PreferenceDoc.Destroy;
{$IFEND}
end;

{$IF Defined(WINDOWS)}
function SetApplicationName: string;
begin
  SetApplicationName := 'Heat Wizard';
end;
{$IFEND}

procedure TPreferenceData.Read;
var
  Error: record
    NoFileversion:   boolean;
    NoLanguage:      boolean;
    NoFormsPosition: boolean;
  end;
{$IF Defined(DARWIN)}
var
 StringConversionSuccess: boolean;
 DataString:          CFStringRef;
 FileVersionBuffer:   str255;
 LanguageBuffer:      str255;
 FormsPositionBuffer: str255;
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

{$ELSE}
var
  HeaderStream:        TStringStream;
  FileVersionBuffer:   string;
  LanguageBuffer:      string;
  FormsPositionBuffer: string;
  i, ThisItem:         integer;
  PreferenceList:      TStringlist;

begin
  Logger.Output('UPreferenceData', 'Create PreferenceDoc');
  {$IF defined(Windows)}
  OnGetApplicationName := @SetApplicationName;
  PreferenceDirName := GetAppConfigDir(false) + '\' + PreferenceDirName;
  {$ELSE}
  PreferenceDirName := GetEnvironmentVariable('HOME') + PreferenceDirName;
  {$IFEND}
  if not DirectoryExists(PreferenceDirName) then
  begin
    Logger.Output('UPreferenceData', 'Application directory not found. Trying to create: ' + PreferenceDirName);
    mkdir(PreferenceDirName);
  end;
  PreferenceFileName := PreferenceDirName + PreferenceFileName;
  if not fileExists(PreferenceFileName) then
  begin
    Logger.Output('UPreferenceData', 'Preference file not found. Trying to create: ' + PreferenceFileName);

    HeaderStream := TStringStream.Create('<?xml version="1.0" encoding="UTF-8"?>');
    HeaderStream.WriteString('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
    HeaderStream.WriteString('<plist version="1.0">');
    HeaderStream.WriteString('<dict>');
    HeaderStream.WriteString('<key>FileVersion</key>');
    HeaderStream.WriteString('<string>1.0.0</string>');
    HeaderStream.WriteString('<key>Language</key>');
    HeaderStream.WriteString('<string>en</string>');
    HeaderStream.WriteString('<key>FormsPosition</key>');
    HeaderStream.WriteString('<string>130,400</string>');
    HeaderStream.WriteString('</dict>');
    HeaderStream.WriteString('</plist>');

    HeaderStream.Position := 0;  // reset the stream for reading

    ReadXMLFile(PreferenceDoc, HeaderStream);

    HeaderStream.Destroy;

    Logger.Output('UPreferenceData', 'Header Stream created, read as xml and destroyed.');

    WriteXMLFile(PreferenceDoc, PreferenceFileName);

    FileVersionBuffer  := '1.0.0';
    LanguageBuffer     := 'en';
    FormsPosition.Top  := 130;
    FormsPosition.Left := 400;
  end
  else
  begin
    ReadXMLFile(PreferenceDoc, PreferenceFileName);

    PreferenceList := TStringlist.Create;
    ThisItem := -1;
    Logger.Output('UPreferenceData', 'PreferenceDoc.DocumentElement.FirstChild.ChildNodes.Count: ' + IntToStr(PreferenceDoc.DocumentElement.FirstChild.ChildNodes.Count));
    with PreferenceDoc.DocumentElement.FirstChild do
      try
        for i := 0 to (ChildNodes.Count - 1) do
        begin
          Logger.Output('UPreferenceData', ChildNodes.Item[i].NodeName + ' ' + ChildNodes.Item[i].FirstChild.NodeValue);
          if ChildNodes.Item[i].NodeName = 'key' then
          begin
            inc(ThisItem);
            Logger.Output('UPreferenceData', 'Found Preference Data: ' + ChildNodes.Item[i].FirstChild.NodeValue + ' ' + ChildNodes.Item[i+1].FirstChild.NodeValue);
            PreferenceList.append(ChildNodes.Item[i].FirstChild.NodeValue + '=' + ChildNodes.Item[i+1].FirstChild.NodeValue)
          end;
        end;
      except
        Logger.Output('UPreferenceData', 'Something went wrong when reading the preferences.');
        Logger.Output('UPreferenceData', 'Falling back to defaults.');
        PreferenceList.Clear;
        PreferenceList.append('Fileversion=1.0.0');
        PreferenceList.append('Language=en');
      end;

    FileVersionBuffer := PreferenceList.Values['FileVersion'];
    Error.NoFileversion := false;
    if FileVersionBuffer = '' then
      Error.NoFileVersion := true;

    LanguageBuffer := PreferenceList.Values['Language'];
    Error.NoLanguage := false;
    if LanguageBuffer = '' then
      Error.NoLanguage    := true;
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
  FormsPosition.Top  := 130;
  FormsPosition.Left := 400;
  PreferenceData.Save;
  Logger.Output('UPreferenceData', 'Leaving Read. Fileversion: ' + Fileversion + ' Language: ' + Language);
end;

procedure TPreferenceData.Save;
{$IF Defined(DARWIN)}
var
  FileVersionData: CFPropertyListRef;
  LanguageData:    CFPropertyListRef;
  PositionData:    CFPropertyListRef;
begin
  Logger.Output('UPreferenceData', 'Enter Save');
  Logger.Output('UPreferenceData', 'Fileversion: ' + FileVersion);
  Logger.Output('UPreferenceData', 'Language: '    + Language);
  Logger.Output('UPreferenceData', 'FormsPosition: Top: ' + intToStr(FormsPosition.Top) + ' Left: ' + intToStr(FormsPosition.Left));
  FileVersionData := CFStringCreateWithPascalString(kCFAllocatorDefault, FileVersion, kCFStringEncodingUTF8);
  CFPreferencesSetAppValue(CFStr('FileVersion'), FileVersionData, kCFPreferencesCurrentApplication);

  LanguageData    := CFStringCreateWithPascalString(kCFAllocatorDefault, Language,    kCFStringEncodingUTF8);
  CFPreferencesSetAppValue(CFStr('Language'),    LanguageData,    kCFPreferencesCurrentApplication);

  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
{$ELSE}
var
  HeaderStream:    TStringStream;
begin
  Logger.Output ('UPreferenceData',  'Enter Save');
  Logger.Output ('UPreferenceData',  'Write FileVersionNode.NodeValue: ' + FileVersion);
  Logger.Output ('UPreferenceData',  'Write LanguageNode.NodeValue: '    + Language);

  HeaderStream := TStringStream.Create('<?xml version="1.0" encoding="UTF-8"?>');
  HeaderStream.WriteString('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
  HeaderStream.WriteString('<plist version="1.0">');
  HeaderStream.WriteString('<dict>');
  HeaderStream.WriteString('<key>FileVersion</key>');
  HeaderStream.WriteString('<string>' + FileVersion + '</string>');
  HeaderStream.WriteString('<key>Language</key>');
  HeaderStream.WriteString('<string>' + Language + '</string>');
  HeaderStream.WriteString('<key>FormsPosition</key>');
  HeaderStream.WriteString('<string>' + Language + '</string>');
  HeaderStream.WriteString('</dict>');
  HeaderStream.WriteString('</plist>');

  HeaderStream.Position := 0;  // reset the stream for reading

  ReadXMLFile(PreferenceDoc, HeaderStream);

  HeaderStream.Destroy;

  Logger.Output('UPreferenceData', 'Header Stream created, read as xml and destroyed.');

  WriteXMLFile(PreferenceDoc, PreferenceFileName);

{$IFEND}
end;

initialization
end.

