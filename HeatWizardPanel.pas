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
 
 unit HeatWizardPanel;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Menus;

type

  { TMainForm }

  TMainForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    InfoButton: TLabel;
    Warning: TLabel;
    PreferenceButton: TLabel;
{$IF Defined(DARWIN)}
    MainMenu:        TMainMenu;
    ApplicationMenu: TMenuItem;
    AboutMenu:       TMenuItem;
    LayoutLine:      TMenuItem;
    PreferencesMenu: TMenuItem;
{$IFEND}
    TemperatureKelvinEdit:     TEdit;
    ReferenceKelvinEdit:       TEdit;
    VoltageEdit:               TLabeledEdit;
    TemperatureCelsiusEdit:    TLabeledEdit;
    ReferenceCelsiusEdit:      TLabeledEdit;
    TemperatureFahrenheitEdit: TEdit;
    ReferenceFahrenheitEdit:   TEdit;
    TypeBox:                   TComboBox;
    QuitButton:                TButton;
    InfoCircle:                TShape;
    PreferenceCircle:          TShape;
    procedure FormCreate(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
    procedure TemperatureFahrenheitEditDblClick(Sender: TObject);
    procedure TemperatureFahrenheitEditEditingDone(Sender: TObject);
    procedure VoltageEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceCelsiusEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceKelvinEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceFahrenheitEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureCelsiusEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureKelvinEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureFahrenheitEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InfoClick(Sender: TObject);
    procedure InfoCircleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PreferenceButtonClick(Sender: TObject);
    procedure PreferenceCircleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure QuitButtonClick(Sender: TObject);
    procedure UpdateDisplay;
    procedure FormPaint(Sender: TObject);
    procedure TranslateTexts(const locale: string);
  private
    { private declarations }
  public
    { public declarations }
  end; 

type
  TLanguage = (en, de, fi);

var
  MainForm: TMainForm;
  Language: TLanguage;
  LanguageLongString:  array[TLanguage] of string = ('English', 'German', 'Finnish');
  LanguageShortString: array[TLanguage] of string = ('en', 'de', 'fi');

implementation

{ TMainForm }

uses
  gettext,
  typinfo,
{$IF Defined(DARWIN)}
  MacOSAll,
{$IFEND}
  UAbout,
  ULog,
  UPath,
  UPlatform,
  UPreferences,
  UPreferenceData;

var
  Voltage              : double = 0.0;
  TemperatureCelsius   : double = 25.00;
  TemperatureKelvin    : double = 298.15;
  TemperatureFahrenheit: double = 77.00;
  ReferenceCelsius     : double = 25.00;
  ReferenceKelvin      : double = 298.15;
  ReferenceFahrenheit  : double = 77.00;
  LastChange           : (VoltageChange, TemperatureChange);

function TypK_Temp2Volt (Temp: real) : real;

  const
    a1  =  0.394501280250E-01;
    a2  =  0.236223735980E-04;
    a3  = -0.328589067840E-06;
    a4  = -0.499048287770E-08;
    a5  = -0.675090591730E-10;
    a6  = -0.574103274280E-12;
    a7  = -0.310888728940E-14;
    a8  = -0.104516093650E-16;
    a9  = -0.198892668780E-19;
    a10 = -0.163226974860E-22;

    b0  = -0.176004136860E-01;
    b1  =  0.389212049750E-01;
    b2  =  0.185587700320E-04;
    b3  = -0.994575928740E-07;
    b4  =  0.318409457190E-09;
    b5  = -0.560728448890E-12;
    b6  =  0.560750590590E-15;
    b7  = -0.320207200030E-18;
    b8  =  0.971511471520E-22;
    b9  = -0.121047212750E-25;

    c0 =  0.118597600000E+00;
    c1 = -0.118343200000E-03;
    c2 =  0.126968600000E+03;

  begin
    if (Temp < 0) then
      TypK_Temp2Volt := (((((((((a10*Temp +
                                 a9)*Temp +
                                 a8)*Temp +
                                 a7)*Temp +
                                 a6)*Temp +
                                 a5)*Temp +
                                 a4)*Temp +
                                 a3)*Temp +
                                 a2)*Temp +
                                 a1)*Temp
    else
      TypK_Temp2Volt := ((((((((b9*Temp +
                                b8)*Temp +
                                b7)*Temp +
                                b6)*Temp +
                                b5)*Temp +
                                b4)*Temp +
                                b3)*Temp +
                                b2)*Temp +
                                b1)*Temp +
                                b0 +
                                c0 * exp(c1*(Temp - c2)*(Temp - c2));
    if (Temp = 0) then
      TypK_Temp2Volt := 0;
  end;

function TypK_Volt2Temp (Volt: real) : real;

  const
    a1  =  2.5173462E+01;
    a2  = -1.1662878E+00;
    a3  = -1.0833638E+00;
    a4  = -8.9773540E-01;
    a5  = -3.7342377E-01;
    a6  = -8.6632643E-02;
    a7  = -1.0450598E-02;
    a8  = -5.1920577E-04;

    b1  =  2.508355E+01;
    b2  =  7.860106E-02;
    b3  = -2.503131E-01;
    b4  =  8.315270E-02;
    b5  = -1.228034E-02;
    b6  =  9.804036E-04;
    b7  = -4.413030E-05;
    b8  =  1.057734E-06;
    b9  = -1.052755E-08;

    c0  = -1.318058E+02;
    c1  =  4.830222E+01;
    c2  = -1.646031E+00;
    c3  =  5.464731E-02;
    c4  = -9.650715E-04;
    c5  =  8.802193E-06;
    c6  = -3.110810E-08;

  begin
    if (Volt <= 0) then
      TypK_Volt2Temp := (((((((a8*Volt +
                               a7)*Volt +
                               a6)*Volt +
                               a5)*Volt +
                               a4)*Volt +
                               a3)*Volt +
                               a2)*Volt +
                               a1)*Volt;
    if (Volt > 0) then
      TypK_Volt2Temp := ((((((((b9*Volt +
                                b8)*Volt +
                                b7)*Volt +
                                b6)*Volt +
                                b5)*Volt +
                                b4)*Volt +
                                b3)*Volt +
                                b2)*Volt +
                                b1)*Volt;
    if (Volt > 20.644) then
      TypK_Volt2Temp := (((((c6*Volt +
                             c5)*Volt +
                             c4)*Volt +
                             c3)*Volt +
                             c2)*Volt +
                             c1)*Volt +
                             c0;
  end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  CheckLanguage: TLanguage;
begin
  CheckLanguage := Low(TLanguage);
  while CheckLanguage < High(TLanguage) do
  begin
    if PreferenceData.Language = LanguageShortString[CheckLanguage] then
      Language := CheckLanguage;
    CheckLanguage := succ(CheckLanguage);
  end;
  if PreferenceData.Language = LanguageShortString[CheckLanguage] then
    Language := CheckLanguage;

  QuitButton.Height := PF_ButtonHeight;
{$IF Defined(DARWIN)}
  MainMenu := TMainMenu.Create(MainForm);

  ApplicationMenu := TMenuItem.Create(MainMenu);
  ApplicationMenu.Caption := '';
  MainMenu.Items.add(ApplicationMenu);

  AboutMenu := TMenuItem.Create(ApplicationMenu);
  AboutMenu.Caption := 'About Heat Wizard';
  ApplicationMenu.add(AboutMenu);

  LayoutLine := TMenuItem.Create(ApplicationMenu);
  LayoutLine.Caption := '-';
  ApplicationMenu.add(LayoutLine);

  PreferencesMenu := TMenuItem.Create(ApplicationMenu);
  PreferencesMenu.Caption  := 'Preferences ...';
  PreferencesMenu.Shortcut := shortcut($BC, [ssMeta]);
  ApplicationMenu.add(PreferencesMenu);
{$IFEND}

  TranslateTexts(LanguageShortString[Language]);
end;

procedure TMainForm.UpdateDisplay;
begin
  VoltageEdit.Text               := FormatFloat('0.000', Voltage);
  TemperatureCelsiusEdit.Text    := FormatFloat('0.00', TemperatureCelsius);
  TemperatureKelvinEdit.Text     := FormatFloat('0.00', TemperatureKelvin);
  TemperatureFahrenheitEdit.Text := FormatFloat('0.00', TemperatureFahrenheit);
  ReferenceCelsiusEdit.Text      := FormatFloat('0.00', ReferenceCelsius);
  ReferenceKelvinEdit.Text       := FormatFloat('0.00', ReferenceKelvin);
  ReferenceFahrenheitEdit.Text   := FormatFloat('0.00', ReferenceFahrenheit);
end;

procedure TMainForm.TranslateTexts(const locale: string);
var
  MOFile: TMOFile;
  LanguageFileDir : string;
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
    Logger.Output ('MainForm', 'Could not find the Resources directory in the application bundle.');
  end
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceDir, true, Path, PathNameLength);
    getApplicationResourcesDirPath := Path;
    Logger.Output ('MainForm', 'Resources directory found as: ' + Path);
  end;
end;
{$ELSEIF Defined(WINDOWS)}
function getApplicationResourcesDirPath: string;
const
  NonGlobalDirectory = false;
begin
  getApplicationResourcesDirPath := GetAppConfigDir(NonGlobalDirectory);
end;
{$ELSE}
function getApplicationResourcesDirPath: string;
const
  NonGlobalDirectory = true;
begin
  getApplicationResourcesDirPath := GetEnvironmentVariable('HOME') + '/.heatwizard/';
end;
{$ENDIF}

begin
{$IF Defined(DARWIN)}
  LanguageFileBasePath := getApplicationResourcesDirPath + '/languages/';
  LanguageFileDir := LanguageFileBasePath + locale + '/LC_MESSAGES/';
{$ELSEIF Defined(WINDOWS)}
  LanguageFileDir := getApplicationResourcesDirPath + 'languages\' + locale + '\LC_MESSAGES\';
{$ELSE}
  LanguageFileBasePath := getApplicationResourcesDirPath + 'languages/';
  LanguageFileDir := LanguageFileBasePath + locale + '/LC_MESSAGES/';
{$IFEND}
  if not DirectoryExists(LanguageFileDir) then
    Logger.Output ('MainForm', 'Directory ' + LanguageFileDir + ' not found!')
  else
  begin
    LanguageFilePath := LanguageFileDir + 'heatwizard.mo';
    if not FileExists(LanguageFilePath) then
    begin
      Logger.Output ('MainForm', 'File ' + LanguageFilePath + ' not found!');
      Logger.Output ('MainForm', 'Continuing with default language, i.e. English!');
    end
    else
    begin
  try
    MOFile := TMOFile.Create(LanguageFilePath);
  except
   on EMOFileError do
     Logger.Output ('MainForm', 'Invalid .mo file header');
  end;
  if assigned(MOFile) then
  begin
    VoltageEdit.EditLabel.Caption            := MOFile.translate('Voltage');
    TemperatureCelsiusEdit.EditLabel.Caption := MOFile.translate('Temperature');
    ReferenceCelsiusEdit.EditLabel.Caption   := MOFile.translate('Reference Temperature');
    QuitButton.Caption := MOFile.translate('Quit');
    TypeBox.Text       := MOFile.translate('Type K');
    Warning.Caption    := MOFile.translate('illegal input try again');
    MOFile.Destroy;
  end;
    end;
  end;
end;

procedure TMainForm.VoltageEditKeyDown(Sender:  TObject;
                                       var Key: Word;
                                       Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(VoltageEdit.Text, input) and (-10 <= input) and (input <= 60) then
    begin
      Voltage               := input;
      TemperatureCelsius    := TypK_Volt2Temp(Voltage + TypK_Temp2Volt(ReferenceCelsius));
      TemperatureKelvin     := TemperatureCelsius + 273.15;
      TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
      LastChange            := VoltageChange;
      Warning.Visible       := false;
    end
    else
      Warning.Visible       := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.QuitButtonClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.PreferenceCircleMouseMove(Sender: TObject;
                                              Shift:  TShiftState;
                                              X, Y:   Integer);
begin
  PreferenceCircle.Brush.Style := bsSolid;
end;

procedure TMainForm.InfoCircleMouseMove(Sender: TObject;
                                        Shift:  TShiftState;
                                        X, Y:   Integer);
begin
    InfoCircle.Brush.Style := bsSolid;
end;

procedure TMainForm.PreferenceButtonClick(Sender: TObject);
begin
  MainForm.Visible             := false;
  PreferencesForm.Visible      := true;
  PreferenceCircle.Brush.Style := bsClear;
end;


procedure TMainForm.InfoButtonClick(Sender: TObject);
begin
  MainForm.Visible       := false;
  AboutForm.Visible      := true;
  InfoCircle.Brush.Style := bsClear;
end;

procedure TMainForm.TemperatureFahrenheitEditDblClick(Sender: TObject);
begin

end;

procedure TMainForm.TemperatureFahrenheitEditEditingDone(Sender: TObject);
begin

end;

procedure TMainForm.InfoClick(Sender: TObject);
begin
  MainForm.Visible       := false;
  AboutForm.Visible      := true;
  InfoCircle.Brush.Style := bsClear;
end;

procedure TMainForm.FormMouseMove(Sender: TObject;
                                  Shift:  TShiftState;
                                  X, Y:   Integer);
begin
  PreferenceCircle.Brush.Style := bsClear;
  InfoCircle.Brush.Style       := bsClear;
end;

function RGB(const R, G, B: Word): Integer;
begin
  RGB := R*256*256 + G*256 + B;
end;

procedure TMainForm.FormPaint(Sender: TObject);
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

procedure TMainForm.ReferenceCelsiusEditKeyDown(Sender:  TObject;
                                                var Key: Word;
                                                Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(ReferenceCelsiusEdit.Text, input) and (-273.15 <= input) and (input <= 1500) then
    begin
      ReferenceCelsius := input;
      ReferenceKelvin  := ReferenceCelsius + 273.15;
      ReferenceFahrenheit  := ReferenceCelsius * 1.8 + 32;
      case lastChange of
        VoltageChange:       // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius := TypK_Volt2Temp(Voltage + TypK_Temp2Volt(ReferenceCelsius));
          TemperatureKelvin  := TemperatureCelsius + 273.15;
          TemperatureFahrenheit  := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:   // Since temperature was changed last, it makes sense to keep it and change the voltage
        Voltage := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
    end;
      Warning.Visible := false;
    end
    else
      Warning.Visible := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.ReferenceKelvinEditKeyDown(Sender:  TObject;
                                               var Key: Word;
                                               Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(ReferenceKelvinEdit.Text, input) and (0 <= input) and (input <= 1800) then
    begin
      ReferenceKelvin  := input;
      ReferenceCelsius := ReferenceKelvin - 273.15;
      ReferenceFahrenheit := ReferenceKelvin * 1.8 - 459.67;
      case lastChange of
        VoltageChange:      // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius := TypK_Volt2Temp(Voltage + TypK_Temp2Volt(ReferenceCelsius));
          TemperatureKelvin  := TemperatureCelsius + 273.15;
          TemperatureFahrenheit  := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:  // Since temperature was changed last, it makes sense to keep it and change the voltage
        Voltage := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
      end;
      Warning.Visible := false;
    end
    else
      Warning.Visible := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.ReferenceFahrenheitEditKeyDown(Sender:  TObject;
                                               var Key: Word;
                                               Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(ReferenceFahrenheitEdit.Text, input) and (0 <= input) and (input <= 1800) then
    begin
      ReferenceFahrenheit  := input;
      ReferenceCelsius := (ReferenceFahrenheit - 32) / 1.8;
      ReferenceKelvin  := (ReferenceFahrenheit + 459.67) / 1.8;
      case lastChange of
        VoltageChange:      // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius := TypK_Volt2Temp(Voltage + TypK_Temp2Volt(ReferenceCelsius));
          TemperatureKelvin  := TemperatureCelsius + 273.15;
          TemperatureFahrenheit  := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:  // Since temperature was changed last, it makes sense to keep it and change the voltage
        Voltage := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
      end;
      Warning.Visible := false;
    end
    else
      Warning.Visible := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.TemperatureCelsiusEditKeyDown(Sender:  TObject;
                                                  var Key: Word;
                                                  Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(TemperatureCelsiusEdit.Text, input) and  (-273.15 <= input) and (input <= 1500)  then
    begin
      TemperatureCelsius := input;
      TemperatureKelvin  := TemperatureCelsius + 273.15;
      TemperatureFahrenheit  := TemperatureCelsius * 1.8 + 32;
      Voltage            := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
      LastChange         := TemperatureChange;
      Warning.Visible    := false;
    end
    else
      Warning.Visible    := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.TemperatureKelvinEditKeyDown(Sender:  TObject;
                                                 var Key: Word;
                                                 Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(TemperatureKelvinEdit.Text, input) and (0 <= input) and (input <= 1800) then
    begin
      TemperatureKelvin  := input;
      TemperatureCelsius := TemperatureKelvin - 273.15;
      TemperatureFahrenheit := TemperatureKelvin * 1.8 - 459.67;
      Voltage            := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
      LastChange         := TemperatureChange;
      Warning.Visible    := false;
    end
    else
      Warning.Visible    := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.TemperatureFahrenheitEditKeyDown(Sender:  TObject;
                                                 var Key: Word;
                                                 Shift:   TShiftState);
var
  input: real;
begin
  if (Key = 13) and (Shift = []) then
  begin
    if TryStrToFloat(TemperatureFahrenheitEdit.Text, input) and (0 <= input) and (input <= 1800) then
    begin
      TemperatureFahrenheit  := input;
      TemperatureCelsius := (TemperatureFahrenheit - 32) / 1.8;
      TemperatureKelvin  := (TemperatureFahrenheit + 459.67) /1.8;
      Voltage            := TypK_Temp2Volt(TemperatureCelsius) - TypK_Temp2Volt(ReferenceCelsius);
      LastChange         := TemperatureChange;
      Warning.Visible    := false;
    end
    else
      Warning.Visible    := true;
    UpdateDisplay;
  end;
end;

initialization
  {$I HeatWizardPanel.lrs}
end.

