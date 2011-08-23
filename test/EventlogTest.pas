{* Copyright (C) 2011 Karl-Michael Schindler
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

program EventlogTest;

{$mode objfpc}

uses
  Sysutils, EventLog;

var
  Logger: TEventlog;

begin
  writeln ('Test of Eventlogger: Start');
  writeln ('You can check the open files now.');
  writeln ('Hit Return when done.');
  mkdir ('Out');
  Chdir('/Users/michael/Library/Logs/');
//  Chdir('Out');
  Logger := TEventlog.Create(nil);
  Logger.LogType := ltFile;
//  Logger.Filename := '~/Library/Logs/EventlogTest.log';
  Logger.Active := true;
//  Logger.AppendContent := true;
  Logger.Error  ('This is an error message');
  Logger.Info   ('This is an info message');
  Logger.Warning('This is a warning');
  Logger.Debug  ('This is a debug message');
  Logger.Log    (etError, 'This is a Error log message.');
  readln;
  Logger.Destroy;
  
  writeln ('Test of Eventlogger: End');
end.