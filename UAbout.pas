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
    AboutLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DoneButtonClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
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
  UPlatform,
  UPreferenceData;

{$I version.inc}

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  TranslateTexts(LanguageShortString[Language]);
  DoneButton.Height := PF_ButtonHeight;
  AboutLabel.Font.Size := PF_AboutTextFontSize;
  Visible := false;
end;

procedure TAboutForm.DoneButtonClick(Sender: TObject);
begin
  PreferenceData.Save;
  MainForm.Left     := AboutForm.Left;
  MainForm.Top      := AboutForm.Top;
  MainForm.Visible  := true;
  AboutForm.Visible := false;
end;

function RGB(const R, G, B: Word): Integer;
begin
  RGB := R*256*256 + G*256 + B;
end;

procedure TAboutForm.FormPaint(Sender: TObject);
var
  Row, LocalHeight: word;
begin
  LocalHeight := (ClientHeight + 255) div 256;
  for Row := 0 to 255 do
    with Canvas do
    begin
      Brush.Color := RGB(0, 0, 96 + Row div 2);
      FillRect(0, Row * LocalHeight, ClientWidth, (Row + 1) * LocalHeight);
    end;
end;

procedure TAboutForm.FormResize(Sender: TObject);
begin
  PreferenceData.FormsPosition.Top  := Top;
  PreferenceData.FormsPosition.Left := Left;
  PreferenceData.Save;
end;

procedure TAboutForm.TranslateTexts(const locale: string);
{$IF Defined(Windows)}
const
  NonGlobalDirectory = false;
{$IFEND}
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
        AboutLabel.Caption  := MOFile.translate('About Text');
        AboutLabel.Caption  := StringReplace(AboutLabel.Caption, 'Placeholder', Version, []);
        DoneButton.Caption := MOFile.translate('Done');
        MOFile.Destroy;
      end;
    end;
  end;
end;

initialization
  {$I UAbout.lrs}
end.

