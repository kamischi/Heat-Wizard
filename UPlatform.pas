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
  Classes, SysUtils;

{$IF Defined(WINDOWS)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = 'heatwizard.xml';
  LanguageFileDir:      string;
  LanguageFilePath:     string;
  LanguageFileBasePath: string = 'languages';
function getLanguageFilePath(language: string): string;
{$ELSEIF Defined(DARWIN)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = '';
  LanguageFileDir:      string;
  LanguageFilePath:     string;
  LanguageFileBasePath: string;   // path is constructed in Translate
function getLanguageFilePath(language: string): string;
{$ELSEIF Defined(UNIX)}
const
  PF_ButtonHeight = 22;
  PF_AboutTextFontSize = -7;
var
  PreferenceDirName:    string = '/.heatwizard/';     // GetEnvironmentVariable('HOME') added where used
  PreferenceFileName:   string = 'heatwizard.xml';
  LanguageFileDir:      string;
  LanguageFileBasePath: string = '/.heatwizard/locale/';
function getLanguageFilePath(language: string): string;
{$IFEND}

implementation

uses
  FileUtil,
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

function getLanguageFilePath(language: string): string;
  var
    CurrentPath: string = '';

  begin
    LanguageFileBasePath := getApplicationResourcesDirPath + '/languages/';
    getLanguageFilePath := LanguageFileBasePath + language + '/LC_MESSAGES/heatwizard.mo';
    LanguageFileDir     := LanguageFileBasePath + language + '/LC_MESSAGES/';
    if not DirectoryExists(LanguageFileDir) then
    begin
      Logger.Output ('UPlatform', 'Directory ' + LanguageFileDir + ' not found!');
//      mkdir (LanguageFileDir);
      GetDir(0, CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory: ' + CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory2: ' + GetCurrentDir);
    end
  end;

{$ELSEIF Defined(WINDOWS)}
function getApplicationResourcesDirPath: string;
  const
    NonGlobalDirectory = false;
  begin
    getApplicationResourcesDirPath := GetAppConfigDir(NonGlobalDirectory);
  end;

function getLanguageFilePath(language: string): string;
  var
    CurrentPath: string = '';

  begin
    getLanguageFileBasePath := GetAppConfigDir(NonGlobalDirectory) + 'languages\' + language + '\LC_MESSAGES\heatwizard.mo';
    LanguageFileDir         := GetAppConfigDir(NonGlobalDirectory) + 'languages\' + language + '\LC_MESSAGES\';
    if not DirectoryExists(LanguageFileDir) then
    begin
      Logger.Output ('UPlatform', 'Directory ' + LanguageFileDir + ' not found!');
//      mkdir (LanguageFileDir);
      GetDir(0, CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory: ' + CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory2: ' + GetCurrentDir);
    end
  end;

{$ELSEIF Defined(UNIX)}
function getApplicationResourcesDirPath: string;
  const
    NonGlobalDirectory = true;
  begin
    getApplicationResourcesDirPath := GetEnvironmentVariable('HOME') + '/.heatwizard/';
  end;

function getLanguageFilePath(language: string): string;
  var
    CurrentPath: string = '';

  begin
    getLanguageFileBasePath := LanguageFileBasePath + language + '/LC_MESSAGES/heatwizard.mo';
    LanguageFileDir         := LanguageFileBasePath + language + '/LC_MESSAGES/';
    if not DirectoryExists(LanguageFileDir) then
    begin
      Logger.Output ('UPlatform', 'Directory ' + LanguageFileDir + ' not found!');
//      mkdir (LanguageFileDir);
      GetDir(0, CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory: ' + CurrentPath);
      Logger.Output ('UPlatform', 'Current Directory2: ' + GetCurrentDir);
    end
  end;
{$ENDIF}

end.
