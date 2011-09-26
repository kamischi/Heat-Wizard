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

unit UPlatform;

{$mode objfpc}
{$H+}

interface

uses
  SysUtils;

{$IF Defined(WINDOWS)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = 'heatwizard.xml';
{$ELSEIF Defined(DARWIN)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = '';
{$ELSEIF Defined(UNIX)}
const
  PF_ButtonHeight = 22;
  PF_AboutTextFontSize = -7;
var
  PreferenceDirName:    string = '/.heatwizard/';     // GetEnvironmentVariable('HOME') added where used
  PreferenceFileName:   string = 'heatwizard.xml';
{$IFEND}

function getLanguageFilePath(locale: string): string;

implementation

uses
{$IF Defined(DARWIN)}
  MacOSAll,
{$IFEND}
  ULog;

{$IF Defined(DARWIN)}
function getApplicationResourcesDirPath: string;
  const
    PathNameLength = 2000;
  var
    MainBundle:  CFBundleRef;
    ResourceDir: CFURLRef;
    Path:        PChar;
  begin
    Path        := StrAlloc(PathNameLength);
    MainBundle  := CFBundleGetMainBundle;
    ResourceDir := CFBundleCopyResourcesDirectoryURL(MainBundle);
    if ResourceDir = NIL then
    begin
      getApplicationResourcesDirPath := '';
      Logger.Output ('UPlatform', 'Could not find the Resources directory in the application bundle.');
    end
    else
    begin
      CFURLGetFileSystemRepresentation(ResourceDir, true, Path, PathNameLength);
      getApplicationResourcesDirPath := Path;
      Logger.Output ('UPlatform', 'Resources directory found as: ' + Path);
    end;
  end;

{$ELSEIF Defined(WINDOWS)}
function getApplicationResourcesDirPath: string;
  const
    NonGlobalDirectory = false;
  begin
    getApplicationResourcesDirPath := GetAppConfigDir(NonGlobalDirectory);
  end;

{$ELSEIF Defined(UNIX)}
function getApplicationResourcesDirPath: string;
  const
    NonGlobalDirectory = true;
  begin
    getApplicationResourcesDirPath := GetEnvironmentVariable('HOME') + '/.heatwizard/';
  end;
{$ENDIF}

function getLanguageFilePath(locale: string): string;
  var
    CurrentPath:     string;
    LanguageFileDir: string;

  begin
    LanguageFileDir := getApplicationResourcesDirPath + '/languages/' + locale + '/LC_MESSAGES/';
    DoDirSeparators (LanguageFileDir); //Set platform specific directory separators, i.e. \ or /
    if not DirectoryExists(LanguageFileDir) then
    begin
      Logger.Output ('UPlatform', 'Directory ' + LanguageFileDir + ' not found!');
//      mkdir (LanguageFileDir);
      GetDir(0, CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory: ' + CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory2: ' + GetCurrentDir);
    end;
    getLanguageFilePath := LanguageFileDir + 'heatwizard.mo';
  end;

end.
