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

program XMLPreferenceTest;

{$mode objfpc}
{$H+}

uses
  Classes,
  SysUtils,
  StrUtils,
  DOM,
  XMLRead,
  XMLWrite;

type
  TPreferenceData = class
    FileVersion: string;
    Language:    string;
    constructor Create;
    procedure Save;
    procedure Read;
  end;

var
  PreferenceData: TPreferenceData;
  PreferenceDoc:  TXMLDocument;

constructor TPreferenceData.Create;
begin
end;

procedure TPreferenceData.Read;

var
  Error: record
    NoFileversion: boolean;
    NoLanguage:    boolean;
  end;

  KeyNode:           TDOMNode;
  StringNode:        TDOMNode;
  FileVersionNode:   TDOMNode;
  LanguageNode:      TDOMNode;
  FileVersionBuffer: string;
  LanguageBuffer:    string;
  i, j, ThisItem:    integer;
  WholeFileAsString: string;
  AllKeyNodes:       TDOMNodeList;
  PreferenceList:    TStringlist;
  
begin
  writeln;
  writeln ('XMLPreferenceTest: ', 'Read PreferenceDoc');
  writeln;

  ReadXMLFile(PreferenceDoc, 'heatwizard.xml');
  
  writeln ('Name of 1st node:');
  writeln (PreferenceDoc.DocumentElement.FirstChild.NodeName);
  writeln;

  WholeFileAsString := PreferenceDoc.DocumentElement.FirstChild.TextContent;
  
  writeln ('GetTextContent of 1st node:');
  writeln (WholeFileAsString);
  writeln;

  PreferenceList := TStringlist.Create;
  ThisItem := -1;
  with PreferenceDoc.DocumentElement.ChildNodes do
  begin
    writeln ('UPreferenceData: ', 'PreferenceDoc.DocumentElement.ChildNodes.Count: ', Count);
    for i := 0 to (Count - 1) do
    begin
      writeln;
      writeln ('UPreferenceData: ', Item[i].NodeName);
      writeln;
      writeln ('Loop through children:');
      writeln;
      for j := 0 to (Item[i].ChildNodes.Count - 1) do
      begin
        writeln ('UPreferenceData: ', Item[i].ChildNodes.Item[j].NodeName + ' '
         + Item[i].ChildNodes.Item[j].FirstChild.NodeValue);
        if Item[i].ChildNodes.Item[j].NodeName = 'key' then
        begin
          inc(ThisItem);
          PreferenceList.append(Item[i].ChildNodes.Item[j].FirstChild.NodeValue + '=')
        end
        else
          PreferenceList.Strings[ThisItem] := PreferenceList.Strings[ThisItem] + Item[i].ChildNodes.Item[j].FirstChild.NodeValue;
      end;
    end;
  end;
  
  writeln;
  writeln ('The Stringlist from PreferenceData:');
  writeln;
  writeln (PreferenceList.Text);
  writeln ('Checking the StringList:');
  writeln;
  writeln ('[0] ', PreferenceList.Names[0], ': ', PreferenceList.ValueFromIndex[0]);
  writeln ('[1] ', PreferenceList.Names[1], ': ', PreferenceList.ValueFromIndex[1]);
  writeln ('FileVersion: ', PreferenceList.Values['FileVersion']);
  writeln ('Language: ', PreferenceList.Values['Language']);
  writeln;
  writeln ('The Stringlist from PreferenceData (one more try):');
  writeln;
  writeln ('FileVersion: ', PreferenceList.ValueFromIndex[PreferenceList.IndexOfName('FileVersion')]);

  writeln;
  AllKeyNodes := PreferenceDoc.GetElementsByTagName('key');
  
  writeln ('Found ', AllKeyNodes.Count, ' nodes with tag name ''key''.');
  writeln;
  writeln ('Loop through nodes:');

  for i := 0 to (AllKeyNodes.Count - 1) do
  begin
    writeln (i, ': ', AllKeyNodes.Item[i].FirstChild.NodeValue);
  end;
  writeln;

  KeyNode := PreferenceDoc.DocumentElement.FirstChild.FindNode('key');
  if KeyNode = NIL then
    writeln ('UXMLPreferences: ', 'Find KeyNode: KeyNode not found.')
  else
    writeln ('UXMLPreferences: ', 'Find KeyNode: KeyNode found. Name: ' +  KeyNode.NodeName + ' Value: ' + KeyNode.FirstChild.NodeValue);
  
  if KeyNode.FirstChild.NodeValue = 'FileVersion' then
  begin
    FileVersionNode := KeyNode.NextSibling;
    writeln ('UXMLPreferences: ', 'Find FileVersionNode: FileVersionNode found. Name: ' +  FileVersionNode.NodeName + ' Value: ' + FileVersionNode.FirstChild.NodeValue);
  end;
{
  KeyNode := PreferenceDoc.DocumentElement.FirstChild.FindNode('key');
  if KeyNode = NIL then
    writeln ('UXMLPreferences: ', 'Find KeyNode: KeyNode not found.')
  else
    writeln ('UXMLPreferences: ', 'Find KeyNode: KeyNode found. Name: ' +  KeyNode.NodeName + ' Value: ' + KeyNode.FirstChild.NodeValue);
  
  if KeyNode.FirstChild.NodeValue = 'Language' then
  begin
    LanguageNode := KeyNode.NextSibling;
    writeln ('UXMLPreferences: ', 'Find LanguageNode: LanguageNode found. Name: ' +  LanguageNode.NodeName + ' Value: ' + LanguageNode.FirstChild.NodeValue);
  end;

  LanguageNode := PreferenceDoc.DocumentElement.FirstChild.FindNode('Language');
  if LanguageNode = NIL then
    writeln ('UXMLPreferences: ',  'Read LanguageNode.NodeValue: ', 'LanguageNode.NodeValue not found.')
  else
    writeln ('UXMLPreferences: ',  'Read LanguageNode.NodeValue: ' + LanguageNode.NodeValue);
}
  Error.NoFileVersion := true;
  if FileVersionNode <> NIL then
    if FileVersionNode.FirstChild.NodeValue <> '' then
    begin
      FileVersionBuffer   := FileVersionNode.FirstChild.NodeValue;
      Error.NoFileVersion := false;
    end;
{    
  Error.NoLanguage := true;
  if LanguageNode <> NIL then
    if LanguageNode.NodeValue <> '' then 
    begin
      LanguageBuffer      := LanguageNode.NodeValue;
      Error.NoLanguage    := false;
    end;
}
//  PreferenceData.Save;

  writeln('UPreferenceData: ', 'Leaving Read. Fileversion: ' + FileversionBuffer + ' Language: ' + LanguageBuffer);
end;

procedure TPreferenceData.Save;
var
  FileVersionNode: TDOMNode;
  LanguageNode:    TDOMNode;
begin
  writeln ('UXMLPreferencesSave: ',  '');
  writeln ('UXMLPreferencesSave: ',  'Write FileVersionNode.NodeValue: ' + FileVersionNode.NodeValue);
  writeln ('UXMLPreferencesSave: ',  'Write LanguageNode.NodeValue: '    + LanguageNode.NodeValue);
  FileVersionNode.NodeValue := PreferenceData.FileVersion;
  LanguageNode.NodeValue    := PreferenceData.Language;
  WriteXMLFile(PreferenceDoc, 'heatwizard.xml');
end;

begin
  PreferenceData := TPreferenceData.Create;
  PreferenceData.Read;
end.

