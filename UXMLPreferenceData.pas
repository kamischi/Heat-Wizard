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

unit UXMLPreferenceData;

{$mode objfpc}
{$H+}

interface

uses
  Classes,
  SysUtils,
  DOM,
  XMLRead,
  XMLWrite;

type
  TPreferenceDataTest = class
    FileVersion: string;
    Language:    string;
    constructor Create;
    procedure Save;
    procedure Read;
  end;

var
  PreferenceDoc: TXMLDocument;
  FileVersionNode: TDOMNode;
  LanguageNode:    TDOMNode;
  PreferenceDataTest: TPreferenceDataTest;

implementation

uses
  ULog,
  UPath,
  UPreferenceData;

constructor TPreferenceDataTest.Create;
var
  CompletePathToPreferenceDir: string;

  DictNode:                   TDOMNode;
  FileVersionKeyNode:         TDOMNode;
  FileVersionKeyValueNode:    TDOMNode;
  FileVersionStringNode:      TDOMNode;
  LanguageKeyNode:            TDOMNode;
  LanguageKeyValueNode:       TDOMNode;
  LanguageStringNode:         TDOMNode;

  HeaderStream: TStringStream;

begin
  Logger.Output('UXMLPreferenceDataTest', 'Create PreferenceDoc');
  CompletePathToPreferenceDir := GetEnvironmentVariable('HOME') + PreferenceDirName;
  if not DirectoryExists(PreferenceDirName) then
  begin
    Logger.Output('UXMLPreferenceDataTest', 'Application directory not found. Trying to create: ' + PreferenceDirName);
    mkdir(PreferenceDirName);
  end;
  if not fileExists(PreferenceDirName + PreferenceFileName) then
  begin
    Logger.Output('UXMLPreferenceDataTest', 'Preference file not found. Trying to create: ' + PreferenceDirName + PreferenceFileName);
    PreferenceDoc := TXMLDocument.Create;

    HeaderStream := TStringStream.Create('<?xml version="1.0" encoding="UTF-8"?>');
    HeaderStream.WriteString('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
    HeaderStream.WriteString('<plist version="1.0">');
    HeaderStream.WriteString('<dict>');
    HeaderStream.WriteString('<key>FileVersion</key>');
    HeaderStream.WriteString('<string>1.0.0</string>');
    HeaderStream.WriteString('<key>Language</key>');
    HeaderStream.WriteString('<string>en</string>');
    HeaderStream.WriteString('</dict>');
    HeaderStream.WriteString('</plist>');

    HeaderStream.Position := 0;  // reset the stream for reading

    ReadXMLFile(PreferenceDoc, HeaderStream);

    HeaderStream.Destroy;

    Logger.Output('UXMLPreferenceDataTest', 'Header Stream created, read as xml and destroyed.');
{
    FileVersionKeyNode := PreferenceDoc.CreateElement('key');
    DictNode.Appendchild(FileVersionKeyNode);

    FileVersionKeyValueNode := TDomText.Create(PreferenceDoc);
    FileVersionKeyValueNode.NodeValue := 'FileVersion';
    FileVersionKeyNode.Appendchild(FileVersionKeyValueNode);

    FileVersionStringNode := PreferenceDoc.CreateElement('string');
    DictNode.Appendchild(FileVersionStringNode);

    FileVersionNode := TDomText.Create(PreferenceDoc);
    FileVersionNode.NodeValue := '1.0.0';
    FileVersionStringNode.Appendchild(FileVersionNode);

    LanguageKeyNode := PreferenceDoc.CreateElement('key');
    DictNode.Appendchild(LanguageKeyNode);

    LanguageKeyValueNode := TDomText.Create(PreferenceDoc);
    LanguageKeyValueNode.NodeValue := 'Language';
    LanguageKeyNode.Appendchild(LanguageKeyValueNode);

    LanguageStringNode := PreferenceDoc.CreateElement('string');
    DictNode.Appendchild(LanguageStringNode);

    LanguageNode := TDomText.Create(PreferenceDoc);
    LanguageNode.NodeValue := 'en';
    LanguageStringNode.Appendchild(LanguageNode);
}
    WriteXMLFile(PreferenceDoc, PreferenceDirName + PreferenceFileName);

    PreferenceData.FileVersion := FileVersionNode.NodeValue;
    PreferenceData.Language    := LanguageNode.NodeValue;
  end
  else
    ReadXMLFile(PreferenceDoc, PreferenceDirName + PreferenceFileName);
end;

procedure TPreferenceDataTest.Read;
begin
  FileVersionNode := PreferenceDoc.DocumentElement.FindNode('FileVersionNode');
  Logger.Output ('UXMLPreferences',  'Read FileVersionNode.NodeValue: ' + FileVersionNode.NodeValue);
  LanguageNode := PreferenceDoc.DocumentElement.FindNode('LanguageNode');
  Logger.Output ('UXMLPreferences',  'Read LanguageNode.NodeValue: ' + LanguageNode.NodeValue);
  if FileVersionNode.NodeValue <> '' then
    PreferenceData.FileVersion := FileVersionNode.NodeValue
  else
    PreferenceData.FileVersion := '1.0.0';
  if LanguageNode.NodeValue <> '' then
    PreferenceData.Language    := LanguageNode.NodeValue
  else
    PreferenceData.Language    := 'en';
end;

procedure TPreferenceDataTest.Save;
begin
  Logger.Output ('UXMLPreferencesSave',  '');
  Logger.Output ('UXMLPreferencesSave',  'Write FileVersionNode.NodeValue: ' + FileVersionNode.NodeValue);
  Logger.Output ('UXMLPreferencesSave',  'Write LanguageNode.NodeValue: '    + LanguageNode.NodeValue);
  FileVersionNode.NodeValue := PreferenceData.FileVersion;
  LanguageNode.NodeValue    := PreferenceData.Language;
  WriteXMLFile(PreferenceDoc, GetEnvironmentVariable('HOME') + PreferenceDirName + PreferenceFileName);
end;

end.

