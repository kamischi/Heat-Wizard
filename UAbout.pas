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

unit UAbout;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms,
  Controls, Graphics, Dialogs, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    DoneButton: TButton;
    AboutText:  TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure DoneButtonClick(Sender: TObject);
    procedure TranslateTexts(const locale: string);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  AboutForm: TAboutForm;

implementation

{ TAboutForm }

uses
  gettext,
{$IF Defined(DARWIN)}
  MacOSAll,
{$IFEND}
  HeatWizardPanel,
  ULog,
  UPath,
  UPlatform;

{$I version.inc}

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  TranslateTexts(LanguageShortString[Language]);
  DoneButton.Height := PF_ButtonHeight;
  AboutText.Font.Size := PF_AboutTextFontSize;
end;

procedure TAboutForm.DoneButtonClick(Sender: TObject);
begin
  MainForm.Visible  := true;
  AboutForm.Visible := false;
end;

procedure TAboutForm.TranslateTexts(const locale: string);
const
  NonGlobalDirectory = false;
var
  MOFile:           TMOFile;
  LanguageFileDir:  string;
  LanguageFilePath: string;
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
    Logger.Output ('UAboutForm', 'Could not find the Resources directory in the application bundle.');
  end
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceDir, true, Path, PathNameLength);
    getApplicationResourcesDirPath := Path;
    Logger.Output ('UAboutForm', 'Resources directory found as: ' + Path);
  end;
end;
{$IFEND}
begin
{$IF Defined(DARWIN)}
  LanguageFileBasePath := getApplicationResourcesDirPath + '/languages/';
  LanguageFileDir := LanguageFileBasePath + locale + '/LC_MESSAGES/';
{$ELSEIF Defined(Windows)}
  LanguageFileDir := GetAppConfigDir(NonGlobalDirectory) + 'languages\' + locale + '\LC_MESSAGES\';
{$ELSE}
  LanguageFileDir := LanguageFileBasePath + locale + '/LC_MESSAGES/';
{$IFEND}
  if not DirectoryExists(LanguageFileDir) then
  begin
    Logger.Output ('AboutForm', 'Directory ' + LanguageFileDir + ' not found!');
//    mkdir (LanguageFileDir);
  end
  else
  begin
    LanguageFilePath := LanguageFileDir + 'heatwizard.mo';
    if not FileExists(LanguageFilePath) then
    begin
      Logger.Output ('AboutForm', 'File ' + LanguageFilePath + ' not found!');
      Logger.Output ('AboutForm', 'Continuing with default language, i.e. English!');
    end
    else
    begin
  try
    MOFile := TMOFile.Create(LanguageFilePath);
  except
   on EMOFileError do
     Logger.Output ('AboutForm', 'Invalid .mo file header');
  end;
  if assigned(MOFile) then
  begin
    AboutText.Caption  := MOFile.translate('About Text');
    AboutText.Caption  := StringReplace(AboutText.Caption, 'Placeholder', Version, []);
    DoneButton.Caption := MOFile.translate('Done');
    MOFile.Destroy;
  end;
  end;
  end;
end;

initialization
  {$I UAbout.lrs}
end.

