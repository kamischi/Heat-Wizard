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

program GetAppConfigDirTest;

{$H+}

uses
  SysUtils;

function getApplicationResourcesDirPath: string;
const
  GlobalDirectory = false;
begin
  getApplicationResourcesDirPath := GetAppConfigDir(GlobalDirectory);
end;

function NewApplicationName: string; // used for the callback function OnGetApplicationName
begin
  NewApplicationName := 'NewApplicationName';
end; 
  
begin
  writeln;
  writeln ('Application name is not set! Showing the default');
  writeln ('The non-global application config directory: ', getApplicationResourcesDirPath);
  writeln ('The   global   application config directory: ', GetAppConfigDir(true));
  writeln;
  OnGetApplicationName := @NewApplicationName;
  writeln ('Application name is set to ''NewApplicationName''!');
  writeln ('The non-global application config directory: ', getApplicationResourcesDirPath);
  writeln ('The   global   application config directory: ', GetAppConfigDir(true));
  writeln;
  writeln ('The default config file extension is: ', ConfigExtension);
  writeln;
  writeln ('In summary, the non-global config file is: ', GetAppConfigFile(false));
  writeln ('In summary, the   global   config file is: ', GetAppConfigFile(true));
  writeln;
  ConfigExtension := '.xml';
  writeln ('Changing the extension to ''.xml'':');
  writeln ('Non-global: ', GetAppConfigFile(false));
  writeln ('Global:     ', GetAppConfigFile(true));
  writeln;
end.

