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

program XMLCreateTest;

uses
  Classes,
  DOM,
  XMLRead,
  XMLWrite;

var
  PreferenceDoc: TXMLDocument;
  
  DictNode:                   TDOMNode;
  FileVersionKeyNode:         TDOMNode;
  FileVersionNode:            TDOMNode;
  FileVersionStringNode:      TDOMNode;
  FileVersionStringValueNode: TDOMNode;
  LanguageKeyNode:            TDOMNode;
  LanguageKeyValueNode:       TDOMNode;
  LanguageStringNode:         TDOMNode;
  LanguageStringValueNode:    TDOMNode;

  HeaderStream: TStringStream;

begin
  PreferenceDoc := TXMLDocument.Create;
  
  HeaderStream := TStringStream.Create('<?xml version="1.0" encoding="UTF-8"?>');
  HeaderStream.WriteString('<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
  HeaderStream.WriteString('<plist version="1.0">');
  HeaderStream.WriteString('<dict>');
  HeaderStream.WriteString('</dict>');
  HeaderStream.WriteString('</plist>');
  
  HeaderStream.Position := 0;  // reset the stream for reading
  
  ReadXMLFile(PreferenceDoc, HeaderStream);
  
  HeaderStream.Destroy;

  writeln ('Header Stream created, read and destroyed.');
  
  DictNode := PreferenceDoc.DocumentElement.FirstChild;  //  set the insertion node
  
  FileVersionKeyNode := PreferenceDoc.CreateElement('key');
  DictNode.Appendchild(FileVersionKeyNode);

  FileVersionNode := TDomText.Create(PreferenceDoc);
  FileVersionNode.NodeValue := 'FileVersion';
  FileVersionKeyNode.Appendchild(FileVersionNode);
  
  FileVersionStringNode := PreferenceDoc.CreateElement('string');
  DictNode.Appendchild(FileVersionStringNode);

  FileVersionStringValueNode := TDomText.Create(PreferenceDoc);
  FileVersionStringValueNode.NodeValue := '1.0.0';
  FileVersionStringNode.Appendchild(FileVersionStringValueNode);
  
  writeln ('FileVersion added');

  LanguageKeyNode := PreferenceDoc.CreateElement('key');
  DictNode.Appendchild(LanguageKeyNode);

  LanguageKeyValueNode := TDomText.Create(PreferenceDoc);
  LanguageKeyValueNode.NodeValue := 'Language';
  LanguageKeyNode.Appendchild(LanguageKeyValueNode);

  LanguageStringNode := PreferenceDoc.CreateElement('string');
  DictNode.Appendchild(LanguageStringNode);

  LanguageStringValueNode := TDomText.Create(PreferenceDoc);
  LanguageStringValueNode.NodeValue := 'en';
  LanguageStringNode.Appendchild(LanguageStringValueNode);

  writeln ('Language added');

  WriteXMLFile(PreferenceDoc, 'test.xml');  // Note: enconding is not included
  
  PreferenceDoc.Free;
  
  ReadXMLFile(PreferenceDoc, 'test.xml');

end.