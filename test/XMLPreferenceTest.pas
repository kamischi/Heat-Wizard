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
  i, j, ThisItem: integer;
  PreferenceList: TStringlist;
  
begin
  writeln;
  writeln ('XMLPreferenceTest: ', 'Read PreferenceDoc');
  writeln;

  ReadXMLFile(PreferenceDoc, 'heatwizard.xml');
  
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
      try
      for j := 0 to (Item[i].ChildNodes.Count - 1) do
      begin
        writeln ('UPreferenceData: ', Item[i].ChildNodes.Item[j].NodeName + ' ' + Item[i].ChildNodes.Item[j].FirstChild.NodeValue);
        if Item[i].ChildNodes.Item[j].NodeName = 'key' then
        begin
          inc(ThisItem);
          PreferenceList.append(Item[i].ChildNodes.Item[j].FirstChild.NodeValue + '=')
        end
        else
          PreferenceList.Strings[ThisItem] := PreferenceList.Strings[ThisItem] + Item[i].ChildNodes.Item[j].FirstChild.NodeValue;
      end;
      except
        writeln;
        writeln ('Something went wrong when reading the preferences.');
	writeln ('Falling back to defaults.');
	PreferenceList.Clear;
        PreferenceList.append('Fileversion=1.0.0');
        PreferenceList.append('Language=en');	
      end;
    end;
  end;
  
  writeln;
  writeln ('The StringList from PreferenceData:');
  writeln;
  writeln (PreferenceList.Text);
  writeln ('Checking the StringList:');
  writeln;
  writeln ('FileVersion: ', PreferenceList.Values['FileVersion']);
  writeln ('Language: ', PreferenceList.Values['Language']);
  writeln;

  FileVersion := PreferenceList.Values['FileVersion'];
  if FileVersion = '' then
    FileVersion := '1.0.0';

  Language := PreferenceList.Values['Language'];
  if Language = '' then 
    Language := 'en';

  writeln ('UPreferenceData: ', 'Leaving Read. Fileversion: ' + Fileversion + ' Language: ' + Language);
  writeln;

  Self.Save;
end;

procedure TPreferenceData.Save;
var
  child, next: TDOMNode;
  KeyNode:     TDOMNode;
  StringNode:  TDOMNode;
  KeyName:     TDOMText;
  StringText:  TDOMText;
begin
  writeln ('UXMLPreferencesSave: ',  '');
  with PreferenceDoc.DocumentElement do
  begin
    writeln ('UPreferenceData: ', 'ChildNodes.Count: ', ChildNodes.Count);
   writeln;
   writeln ('UPreferenceData: ', FirstChild.NodeName);
   writeln;
   writeln ('Free children');
   writeln;
   with FirstChild do
   begin
     child := FirstChild;
     while Assigned(child) do
     begin
       next := child.NextSibling;
       child.Destroy;
       child := next;
     end;
   end;
   writeln ('All children deleted.');
   writeln;
   KeyNode    := PreferenceDoc.CreateElement('key');
   StringNode := PreferenceDoc.CreateElement('string');
   KeyName    := PreferenceDoc.CreateTextNode('Fileversion');
   StringText := PreferenceDoc.CreateTextNode(Fileversion);
   KeyNode.AppendChild(KeyName);      
   StringNode.AppendChild(StringText);
   PreferenceDoc.DocumentElement.FirstChild.AppendChild(KeyNode.CloneNode(true));
   PreferenceDoc.DocumentElement.FirstChild.AppendChild(StringNode.CloneNode(true));      
   KeyName.NodeValue    := 'Language';
   StringText.NodeValue := Language;
   PreferenceDoc.DocumentElement.FirstChild.AppendChild(KeyNode.CloneNode(true));
   PreferenceDoc.DocumentElement.FirstChild.AppendChild(StringNode.CloneNode(true));      
  end;

  WriteXMLFile(PreferenceDoc, 'heatwizard.xml');
end;

begin
  PreferenceData := TPreferenceData.Create;
  PreferenceData.Read;
  PreferenceData.Save;
  PreferenceData.Destroy;
end.

