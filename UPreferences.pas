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
    LanguageLabel:      TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
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
  HeatWizardPanel,
  UAbout,
  UFormPainter,
  ULog,
  UPlatform,
  UPreferenceData;

procedure TPreferencesForm.FormCreate(Sender: TObject);
var
  index: integer;
begin
  Logger.Output('TPreferencesForm.FormCreate','Language: ' + LanguageShortString[Language]);
  LanguageComboBox.Items.Clear;
  for index := ord(low(Tlanguage)) to ord(high(Tlanguage)) do
  begin
    LanguageComboBox.Items.Add(LanguageLongString[TLanguage(index)]);
  end;
  LanguageComboBox.ItemIndex := ord(Language);
  TranslateTexts(LanguageShortString[Language]);
  DoneButton.Height := PF_ButtonHeight;
  Logger.Output('UPreferences', 'started with: ' + LanguageShortString[Language]);
  Visible := false;
end;

procedure TPreferencesForm.FormPaint(Sender: TObject);
begin
  PaintBackground(Self)
end;

procedure TPreferencesForm.FormResize(Sender: TObject);
begin
  PreferenceData.FormsPosition.Top  := Top;
  PreferenceData.FormsPosition.Left := Left;
  PreferenceData.Save;
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
  LanguageFilePath: string;
  MOFile:           TMOFile;
  index:            integer;
begin
  LanguageFilePath := getLanguageFilePath(locale);
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
      LanguageLabel.Caption := MOFile.translate('Language:');
      for index := ord(low(Tlanguage)) to ord(high(Tlanguage)) do
      begin
        LanguageComboBox.Items.Strings[index] := MOFile.translate(LanguageLongString[TLanguage(index)]);
      end;
      DoneButton.Caption := MOFile.translate('Done');
{$IF Defined(DARWIN)}
      MainForm.AboutMenu.Caption       := MOFile.translate('About ') + Application.Title;
      MainForm.PreferencesMenu.Caption := MOFile.translate('Preferences ...');
{$IFEND}
      MOFile.Destroy;
    end;
  end;
end;

{$R *.lfm}

end.

