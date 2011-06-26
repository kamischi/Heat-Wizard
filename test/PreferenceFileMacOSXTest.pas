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

program PreferenceFileMacOSXTest;

{$mode objfpc}
{$H+}

uses
  Classes,
  SysUtils,
  MacOSAll;
  
type
  TPreferenceData = class
    Pref1: string;
    Pref2: string;
    constructor Create;
    procedure Save;
    procedure Read;
  end;

var
  PreferenceData: TPreferenceData;

constructor TPreferenceData.Create;
  begin
  end;

procedure TPreferenceData.Save;
  var
    Pref1Data: CFPropertyListRef;
    Pref2Data: CFPropertyListRef;
  begin
    writeln('UPreferenceData', 'Enter Save');
    writeln('UPreferenceData', 'Pref1: ' + Pref1);
    writeln('UPreferenceData', 'Pref2: ' + Pref2);
    Pref1Data := CFStringCreateWithPascalString(kCFAllocatorDefault, Pref1, kCFStringEncodingUTF8);
    CFPreferencesSetAppValue(CFStr('Pref1'), Pref1Data, CFStr('com.KMS.PreferenceFileMacOSXTest'));

    Pref2Data := CFStringCreateWithPascalString(kCFAllocatorDefault, Pref2, kCFStringEncodingUTF8);
    CFPreferencesSetAppValue(CFStr('Pref2'), Pref2Data, CFStr('com.KMS.PreferenceFileMacOSXTest'));

    CFPreferencesAppSynchronize(CFStr('com.KMS.PreferenceFileMacOSXTest'));
  end;

procedure TPreferenceData.Read;
  var
    Error: boolean;
    DataString: CFStringRef;
    Buffer: Str255;
  begin
    writeln('UPreferenceData', 'Enter Read');
    DataString := CFPreferencesCopyAppValue(CFStr('Pref1'), CFStr('com.KMS.PreferenceFileMacOSXTest'));
    if (DataString = NIL) then
      writeln ('DataString = NIL after CFPreferencesCopyAppValue.');
    writeln ('CFTypeID of Datastring as integer: ', CFGetTypeID(Datastring));
    writeln ('CFTypeIDs: CFString, CFNumber, CFBoolean, CFDate, CFData, CFArray, CFDictionary');
    writeln (CFStringGetTypeID:3, CFNumberGetTypeID:3, CFBooleanGetTypeID:3, CFDateGetTypeID:3, CFDataGetTypeID:3, CFArrayGetTypeID:3, CFDictionaryGetTypeID:3);
    if (DataString = NIL) or not CFStringGetPascalString(DataString,
				     @Buffer,
				     Length(Buffer),
				     kCFStringEncodingUTF8)
				     then
				     Buffer := '1.0.0';
    writeln('UPreferenceData', 'Pref1 Buffer as read from file: ' + Buffer);
    Pref1 := Buffer;
    if Error then
      writeln('UPreferenceData', 'Error reading Pref1 from file.');

    DataString := CFPreferencesCopyAppValue(CFStr('Pref2'), CFStr('com.KMS.PreferenceFileMacOSXTest'));
    if (DataString = NIL) then
      writeln ('DataString = NIL after CFPreferencesCopyAppValue.');
    writeln ('CFTypeID of Datastring as integer: ', CFGetTypeID(Datastring));
    writeln ('CFTypeIDs: CFString, CFNumber, CFBoolean, CFDate, CFData, CFArray, CFDictionary');
    writeln (CFStringGetTypeID:3, CFNumberGetTypeID:3, CFBooleanGetTypeID:3, CFDateGetTypeID:3, CFDataGetTypeID:3, CFArrayGetTypeID:3, CFDictionaryGetTypeID:3);
    if (DataString = NIL ) or not CFStringGetPascalString(DataString,
				     @Buffer,
				     Length(Buffer),
				     kCFStringEncodingUTF8)
				     then
				     Buffer := 'en';
    writeln('UPreferenceData', 'Pref2 Buffer as read from file: ' + Buffer);
    Pref2 := Buffer;
    if Error then
      writeln('UPreferenceData', 'Error reading Pref2 from file.');
    writeln('UPreferenceData', 'Leaving Read. Pref1: ' + Pref1 + ' Pref2: ' + Pref2);
  end;

begin
  PreferenceData := TPreferenceData.Create;
  PreferenceData.Read;
  writeln('Pref1: ', PreferenceData.Pref1, 'Pref2: ', PreferenceData.Pref2);
  PreferenceData.Pref1 := '1.0.0';
  PreferenceData.Pref2 := 'en';
  PreferenceData.Save;
end.