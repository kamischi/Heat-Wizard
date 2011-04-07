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

unit ULog;

{$mode objfpc}
{$H+}

interface

uses
  Classes,
  SysUtils;

type
  TLogger = class
  public
    constructor Create;
    destructor Destroy;
    procedure Output(const Position, Message: string);
  end;

var
  Logger: TLogger;

{$IF Defined(DARWIN)}
function GetPathToUserLibraryFolder: string;
{$IFEND}

implementation

{$IF Defined(DARWIN)}
uses
  MacOSAll;
{$IFEND}

{$I version.inc}

var
  LogFile:        text;
  LogFileName:    string;
  LogFileDirName: string;

{$IF Defined(DARWIN)}
// This is carbon and should be replaced by cocoa as soon as it is a default part of fpc
function GetPathToUserLibraryFolder: string;
  const
    PathNameLength = 200;
  var
    foundRef: FSRef;
    Path:     CStringPtr;
    Error:    OSStatus;
  begin
    Error := FSFindFolder(kUserDomain, kDomainLibraryFolderType, kDontCreateFolder, foundRef);
    if Error <> noErr then
    begin
      writeln ('FSFindFolder Error: ', Error);
      exit;
    end;
    Path  := StrAlloc(PathNameLength + 1);  // null termination needs one more character
    Error := FSRefMakePath(foundRef, Path, PathNameLength);
    if Error <> noErr then
    begin
      writeln ('FSRefMakePath Error (check MacErrors.h): ', Error);
      if Error = -2110 then
        writeln ('Length of path name is to short. Increase PathNameLength.');
      exit;
    end;
    writeln (Path);
    Result := Path;
  end;
{$IFEND}

{$IF Defined(WINDOWS)}
  function SetApplicationName: string;
  begin
    SetApplicationName := 'Heat Wizard';
  end;
{$IFEND}

constructor TLogger.Create;
  var
    Intro: string;
  begin
    {$IF Defined(DARWIN)}
    LogFileDirName := GetPathToUserLibraryFolder + '/Logs/';
    LogFileName := 'Heat Wizard.log';
    {$ELSEIF Defined(WINDOWS)}
    OnGetApplicationName := @SetApplicationName;
    LogFileDirName := GetAppConfigDir(false) + '\';
    LogFileName := 'Heat Wizard.log';
    {$ELSE}
    LogFileDirName := GetEnvironmentVariable('HOME') + '/.heatwizard/';
    LogFileName := 'heatwizard.log';
    {$IFEND}
    if not DirectoryExists (LogFileDirName) then
      mkdir(LogFileDirName);
    LogFileName := LogFileDirName + LogFileName;
    Intro := FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz', Now) + ' Heat Wizard[' + IntToStr(GetProcessID) + '] ';
    {$I-} // for checking IO error
    AssignFile(LogFile, LogFileName);
    Rewrite (LogFile);
    {$I+}
    if IOResult = 0 then
    begin
      writeln (LogFile, Intro + 'Log file');
      writeln (LogFile, Intro + 'Version: ', Version);
      writeln (LogFile, Intro + '----------------------------------------------------');
      flush (LogFile);
    end
    else
    begin
      writeln ('Error when opening log file.');
      writeln ('LogFileName: ', LogFileName);
      writeln ('Error code: ', IOResult, ' (explanations: rtl.pdf, System unit, 36.9.110 IOResult)');
      writeln ('Current directory: ', GetCurrentDir);
    end;
  end;

procedure TLogger.Output(const Position, Message: string);
  var
    Intro: string;
  begin
    Intro := FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz', Now) + ' Heat Wizard[' + IntToStr(GetProcessID) + '] ';
    writeln (LogFile, Intro + 'Unit ' + Position + ': ' + Message);
    flush (LogFile);
  end;

destructor TLogger.Destroy;
  begin
    Close(LogFile);
  end;

end.
