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

unit UPreferences;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms,
  Controls, Graphics, Dialogs, StdCtrls, Menus;

type

  { TPreferencesForm }

  TPreferencesForm = class(TForm)
    LanguageComboBox:   TComboBox;
    DoneButton:         TButton;
    LanguageStaticText: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LanguageComboBoxSelect(Sender: TObject);
    procedure DoneButtonClick(Sender: TObject);
    procedure TranslateTexts(const locale: string);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  PreferencesForm: TPreferencesForm;

implementation

{ TPreferencesForm }

uses
  gettext,
{$IF Defined(DARWIN)}
  MacOSAll,
{$IFEND}
  HeatWizardPanel,
  UAbout,
  ULog,
  UPath,
  UPlatform,
  UPreferenceData;

procedure TPreferencesForm.FormCreate(Sender: TObject);
begin
  Logger.Output('TPreferencesForm.FormCreate','Language: ' + LanguageShortString[Language]);
  TranslateTexts(LanguageShortString[Language]);
  LanguageComboBox.ItemIndex := ord(Language);
  DoneButton.Height := PF_ButtonHeight;
  Logger.Output('UPreferences', 'started with: ' + LanguageShortString[Language]);
end;

procedure TPreferencesForm.FormResize(Sender: TObject);
begin
  PreferenceData.FormsPosition.Top  := Top;
  PreferenceData.FormsPosition.Left := Left;
end;

procedure TPreferencesForm.LanguageComboBoxSelect(Sender: TObject);
begin
  Language := TLanguage(LanguageComboBox.ItemIndex);
  TranslateTexts(LanguageShortString[Language]);
  AboutForm.TranslateTexts(LanguageShortString[Language]);
  MainForm.TranslateTexts(LanguageShortString[Language]);
  Logger.Output('UPreferences', 'Language changed to: ' + LanguageShortString[Language]);
end;

procedure TPreferencesForm.DoneButtonClick(Sender: TObject);
begin
  PreferenceData.Language := LanguageShortString[Language];
  PreferenceData.Save;
  MainForm.Left           := PreferencesForm.Left;
  MainForm.Top            := PreferencesForm.Top;
  MainForm.Visible        := true;
  PreferencesForm.Visible := false;
end;

procedure TPreferencesForm.TranslateTexts(const locale: string);
var
  MOFile:           TMOFile;
  LanguageFileDir:  string;
  LanguageFilePath: string;
  CurrentPath:      string;
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
    Logger.Output ('UPreferencesForm', 'Could not find the Resources directory in the application bundle.');
  end
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceDir, true, Path, PathNameLength);
    getApplicationResourcesDirPath := Path + '/';
    Logger.Output ('UPreferencesForm', 'Resources directory found as: ' + Path);
  end;
end;
{$ELSE}
function getApplicationResourcesDirPath: string;
const
  NonGlobalDirectory = false;
begin
  {$IF Defined(WINDOWS)}
  getApplicationResourcesDirPath := GetAppConfigDir(NonGlobalDirectory);
  {$ELSE}
  getApplicationResourcesDirPath := GetEnvironmentVariable('HOME') + '/.heatwizard/';
  {$IFEND}
end;
{$IFEND}
begin
{$IF Defined(WINDOWS)}
  LanguageFileDir := getApplicationResourcesDirPath + 'languages\' + locale + '\LC_MESSAGES\';
{$ELSE}
  LanguageFileDir := getApplicationResourcesDirPath + 'languages/' + locale + '/LC_MESSAGES/';
{$IFEND}
  if not DirectoryExists(LanguageFileDir) then
  begin
    Logger.Output ('PreferencesForm', 'Directory ' + LanguageFileDir + ' not found!');
    GetDir(0, CurrentPath);
    Logger.Output ('PreferencesForm', 'Current Directory: ' + CurrentPath);
    Logger.Output ('PreferencesForm', 'Current Directory2: ' + GetCurrentDir);
  end
  else
  begin
    LanguageFilePath := LanguageFileDir + 'heatwizard.mo';
    if not FileExists(LanguageFilePath) then
    begin
      Logger.Output ('PreferencesForm', 'File ' + LanguageFilePath + ' not found!');
      Logger.Output ('PreferencesForm', 'Continuing with default language, i.e. English!');
    end
    else
    begin
      try
        MOFile := TMOFile.Create(LanguageFilePath);
      except
       on EMOFileError do
         Logger.Output ('PreferencesForm', 'Invalid .mo file header');
      end;
      if assigned(MOFile) then
      begin
        LanguageStaticText.Caption        := MOFile.translate('Language:');
        LanguageComboBox.Items.Strings[0] := MOFile.translate('English');
        LanguageComboBox.Items.Strings[1] := MOFile.translate('German');
        LanguageComboBox.Items.Strings[2] := MOFile.translate('Finnish');
        DoneButton.Caption                := MOFile.translate('Done');
        MOFile.Destroy;
      end;
    end;
  end;
end;

initialization
  {$I UPreferences.lrs}
end.

