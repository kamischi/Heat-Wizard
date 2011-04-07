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
  Inherited;
  Logger.Output('UPreferenceData', 'Create');
{$IF not Defined(DARWIN)}
  PreferenceDoc := TXMLDocument.Create;
{$IFEND}
end;

destructor TPreferenceData.Destroy;
begin
  Inherited;
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
    Error.NoFormsPosition := true;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'FormsPosition Buffer Top as read from file: ' + FormsPositionTopBuffer);
    Logger.Output('UPreferenceData', 'FormsPosition Buffer Left as read from file: ' + FormsPositionLeftBuffer);
    Error.NoFormsPosition := false;
  end;
  end
  else
  begin
    Logger.Output('UPreferenceData', 'Error reading FormsPosition from file. Continue with Default');
    Error.NoFormsPosition := true;
  end;

{$ELSE}
var
  HeaderStream:            TStringStream;
  FileVersionBuffer:       string;
  LanguageBuffer:          string;
  FormsPositionTopBuffer:  string;
  FormsPositionLeftBuffer: string;
  i, ThisItem:             integer;
  PreferenceList:          TStringlist;
  HereNode:                TDOMNode;

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
    HeaderStream.WriteString('  <key>FileVersion</key>');
    HeaderStream.WriteString('  <string>' + FileVersion + '</string>');
    HeaderStream.WriteString('  <key>Language</key>');
    HeaderStream.WriteString('  <string>' + Language + '</string>');
    HeaderStream.WriteString('  <key>FormsPosition</key>');
    HeaderStream.WriteString('  <dict>');
    HeaderStream.WriteString('    <key>Top</key>');
    HeaderStream.WriteString('    <string>' + intToStr(FormsPosition.Top) + '</string>');
    HeaderStream.WriteString('    <key>Left</key>');
    HeaderStream.WriteString('    <string>' + intToStr(FormsPosition.Left) + '</string>');
    HeaderStream.WriteString('  </dict>');
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

    PreferenceList := TStringlist.Create;            // FOrmsPosition is not yet done
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
          if ChildNodes.Item[i].NodeName = 'dict' then
          begin
            HereNode := ChildNodes.Item[i].FindNode('FormsPosition');
            Logger.Output('UPreferenceData', 'HereNode: ' + HereNode.NodeValue);
            HereNode := ChildNodes.Item[i].FindNode('Top');
            Logger.Output('UPreferenceData', 'HereNode: ' + HereNode.NodeValue);
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

    FormsPositionTopBuffer := PreferenceList.Values['FormsPosition'];
    Error.NoFormsPosition := false;
    if FormsPositionTopBuffer = '' then
      Error.NoFormsPosition    := true;
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
  HeaderStream:    TStringStream;
begin
  Logger.Output ('UPreferenceData',  'Enter Save');
  Logger.Output ('UPreferenceData',  'Write FileVersionNode.NodeValue: ' + FileVersion);
  Logger.Output ('UPreferenceData',  'Write LanguageNode.NodeValue: '    + Language);

  HeaderStream := TStringStream.Create('<?xml version="1.0" encoding="UTF-8"?>');
  HeaderStream.WriteString('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
  HeaderStream.WriteString('<plist version="1.0">');
  HeaderStream.WriteString('<dict>');
  HeaderStream.WriteString('  <key>FileVersion</key>');
  HeaderStream.WriteString('  <string>' + FileVersion + '</string>');
  HeaderStream.WriteString('  <key>Language</key>');
  HeaderStream.WriteString('  <string>' + Language + '</string>');
  HeaderStream.WriteString('  <key>FormsPosition</key>');
  HeaderStream.WriteString('  <dict>');
  HeaderStream.WriteString('    <key>Top</key>');
  HeaderStream.WriteString('    <string>' + intToStr(FormsPosition.Top) + '</string>');
  HeaderStream.WriteString('    <key>Left</key>');
  HeaderStream.WriteString('    <string>' + intToStr(FormsPosition.Left) + '</string>');
  HeaderStream.WriteString('  </dict>');
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

