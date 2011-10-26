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
 
 unit HeatWizardPanel;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Menus,
  UThermoCouple;

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
    InfoButton:        TLabel;
    Warning:           TLabel;
    PreferenceButton:  TLabel;
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
    ThermocoupleLabel:         TLabel;
    TypeBox:                   TComboBox;
    QuitButton:                TButton;
    InfoCircle:                TShape;
    PreferenceCircle:          TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
    procedure LayoutClick(Sender: TObject);
    procedure TypeBoxChange(Sender: TObject);
    procedure VoltageEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceCelsiusEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceKelvinEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReferenceFahrenheitEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureCelsiusEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureKelvinEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TemperatureFahrenheitEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InfoCircleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PreferenceButtonClick(Sender: TObject);
    procedure PreferenceCircleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure QuitButtonClick(Sender: TObject);
    procedure UpdateDisplay;
    procedure FormPaint(Sender: TObject);
    procedure TranslateTexts(const locale: string);
    {$IF Defined(DARWIN)}
    procedure AboutMenuClick(Sender: TObject);
    procedure PreferencesMenuClick(Sender: TObject);
    {$IFEND}
  private
    { private declarations }
  public
    { public declarations }
  end; 

type
  TLanguage = (en, de, es, fi, fr);

var
  MainForm: TMainForm;
  Language: TLanguage;
  LanguageLongString:  array[TLanguage] of string = ('English', 'German', 'Spanish', 'Finnish', 'French');
  LanguageShortString: array[TLanguage] of string = ('en', 'de', 'es', 'fi', 'fr');
  ThermoCouple: TThermoCouple;

implementation

{ TMainForm }

uses
  gettext,
  typinfo,
  AppKit, lobjc, foundation,
  UAbout,
  UFormPainter,
  ULog,
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

procedure TMainForm.FormCreate(Sender: TObject);
var
  CheckLanguage: TLanguage;
  index: integer;
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
  Top  := PreferenceData.FormsPosition.Top;
  Left := PreferenceData.FormsPosition.Left;
{$IF Defined(DARWIN)}
  MainMenu := TMainMenu.Create(Self);

  ApplicationMenu := TMenuItem.Create(MainMenu);
  ApplicationMenu.Caption := '';
  MainMenu.Items.add(ApplicationMenu);

  AboutMenu := TMenuItem.Create(ApplicationMenu);
  AboutMenu.Caption := 'About ' + Application.Title;
  AboutMenu.OnClick := @AboutMenuClick;
  ApplicationMenu.add(AboutMenu);

  LayoutLine := TMenuItem.Create(ApplicationMenu);
  LayoutLine.Caption := '-';
  ApplicationMenu.add(LayoutLine);

  PreferencesMenu := TMenuItem.Create(ApplicationMenu);
  PreferencesMenu.Caption  := 'Preferences ...';
  PreferencesMenu.Shortcut := shortcut($BC, [ssMeta]);
  PreferencesMenu.OnClick  := @PreferencesMenuClick;
  ApplicationMenu.add(PreferencesMenu);
{$IFEND}

  ThermoCouple := TThermoCouple.Create;

  TypeBox.Clear;
  for index := ord(low(TThermoElementType)) to ord(high(TThermoElementType)) do
    TypeBox.Items.Add('Type ' + GetEnumName(TypeInfo(TThermoElementType), index));
  TypeBox.ItemIndex := 3;
  ThermoCouple.ThermoElementType := K;

  TranslateTexts(LanguageShortString[Language]);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  PreferenceData.FormsPosition.Top  := Top;
  PreferenceData.FormsPosition.Left := Left;
  PreferenceData.Save;
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
  TypeBox.ItemIndex              := ord(ThermoCouple.ThermoElementType);
end;

procedure TMainForm.TranslateTexts(const locale: string);
var
  LanguageFilePath: string;
  MOFile          : TMOFile;
  index           : integer;
//  CocoaMenu: Pobjc_object;
  CocoaMenu: NSMenu;
  CocoaApp: NSApplication;
  pool: NSAutoreleasePool;

begin
  LanguageFilePath := getLanguageFilePath(locale);
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
      ThermocoupleLabel.Caption                := MOFile.translate('Thermocouple');
      QuitButton.Caption                       := MOFile.translate('Quit');
      for index := ord(low(TThermoElementType)) to ord(high(TThermoElementType)) do
        TypeBox.Items.Strings[index] := MOFile.translate('Type') + ' ' + GetEnumName(TypeInfo(TThermoElementType), index);
      Warning.Caption                          := MOFile.translate('illegal input try again');
      {$IF Defined(DARWIN)}
      AboutMenu.Caption := MOFile.translate('About ') + Application.Title;
      PreferencesMenu.Caption  := MOFile.translate('Preferences ...');
//      pool := NSAutoreleasePool.Create;
//      NSApp := NSApplication.sharedApplication;
//      NSApplicationLoad();
      CocoaApp := NSApplication.sharedApplication;
//      CocoaApp.hideOtherApplications(Nil); //works
//      CocoaMenu := NSMenu(CocoaApp.mainMenu);
      CocoaMenu := NSMenu(CocoaApp.servicesMenu);
//      MainMenu.Items[0].Items[3].Caption := MOFile.translate('Services');;
{
      if MOFile.translate('Hide ')[1] = ' ' then
        MainMenu.Items[0].Items[4].Caption := Application.Title + MOFile.translate('Hide ')
      else
        MainMenu.Items[0].Items[4].Caption := MOFile.translate('Hide ') + Application.Title;
}
//      MainMenu.Items[0].Items[5].Caption := MOFile.translate('Hide others');
//      MainMenu.Items[0].Items[6].Caption := MOFile.translate('Show all');
{
      if MOFile.translate('Quit ')[1] = ' ' then
        MainMenu.Items[0].Items[7].Caption := Application.Title + MOFile.translate('Quit ')
      else
        MainMenu.Items[0].Items[7].Caption := MOFile.translate('Quit ') + Application.Title;
}
      {$IFEND}
      MOFile.Destroy;
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
      TemperatureCelsius    := ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(ReferenceCelsius));
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
  PreferenceData.Save;
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
  PreferencesForm.Left         := MainForm.Left;
  PreferencesForm.Top          := MainForm.Top;
  PreferencesForm.Visible      := true;
  MainForm.Visible             := false;
  PreferenceCircle.Brush.Style := bsClear;
end;

procedure TMainForm.InfoButtonClick(Sender: TObject);
begin
  AboutForm.Left         := MainForm.Left;
  AboutForm.Top          := MainForm.Top;
  AboutForm.Visible      := true;
  MainForm.Visible       := false;
  InfoCircle.Brush.Style := bsClear;
end;

procedure TMainForm.LayoutClick(Sender: TObject);
begin
  AboutForm.Left         := MainForm.Left;
  AboutForm.Top          := MainForm.Top;
  AboutForm.Visible      := true;
  MainForm.Visible       := false;
  InfoCircle.Brush.Style := bsClear;
end;

procedure TMainForm.TypeBoxChange(Sender: TObject);
begin
  ThermoCouple.ThermoElementType := TThermoElementType(TypeBox.ItemIndex);
  case lastChange of
    VoltageChange:      // Since voltage was changed last, it makes sense to keep it and change the temperature
    begin
      TemperatureCelsius    := ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(ReferenceCelsius));
      TemperatureKelvin     := TemperatureCelsius + 273.15;
      TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
    end;
    TemperatureChange:  // Since temperature was changed last, it makes sense to keep it and change the voltage
      Voltage := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
  end;
  UpdateDisplay;
end;

procedure TMainForm.FormMouseMove(Sender: TObject;
                                  Shift:  TShiftState;
                                  X, Y:   Integer);
begin
  PreferenceCircle.Brush.Style := bsClear;
  InfoCircle.Brush.Style       := bsClear;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  PaintBackground(Self)
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
      ReferenceCelsius    := input;
      ReferenceKelvin     := ReferenceCelsius + 273.15;
      ReferenceFahrenheit := ReferenceCelsius * 1.8 + 32;
      case lastChange of
        VoltageChange:       // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius    := ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(ReferenceCelsius));
          TemperatureKelvin     := TemperatureCelsius + 273.15;
          TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:   // Since temperature was changed last, it makes sense to keep it and change the voltage
          Voltage := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
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
      ReferenceKelvin     := input;
      ReferenceCelsius    := ReferenceKelvin - 273.15;
      ReferenceFahrenheit := ReferenceKelvin * 1.8 - 459.67;
      case lastChange of
        VoltageChange:      // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius    := ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(ReferenceCelsius));
          TemperatureKelvin     := TemperatureCelsius + 273.15;
          TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:  // Since temperature was changed last, it makes sense to keep it and change the voltage
          Voltage := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
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
      ReferenceFahrenheit := input;
      ReferenceCelsius    := (ReferenceFahrenheit - 32) / 1.8;
      ReferenceKelvin     := (ReferenceFahrenheit + 459.67) / 1.8;
      case lastChange of
        VoltageChange:      // Since voltage was changed last, it makes sense to keep it and change the temperature
        begin
          TemperatureCelsius    := ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(ReferenceCelsius));
          TemperatureKelvin     := TemperatureCelsius + 273.15;
          TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
        end;
        TemperatureChange:  // Since temperature was changed last, it makes sense to keep it and change the voltage
          Voltage := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
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
      TemperatureCelsius    := input;
      TemperatureKelvin     := TemperatureCelsius + 273.15;
      TemperatureFahrenheit := TemperatureCelsius * 1.8 + 32;
      Voltage               := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
      LastChange            := TemperatureChange;
      Warning.Visible       := false;
    end
    else
      Warning.Visible       := true;
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
      TemperatureKelvin     := input;
      TemperatureCelsius    := TemperatureKelvin - 273.15;
      TemperatureFahrenheit := TemperatureKelvin * 1.8 - 459.67;
      Voltage               := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
      LastChange            := TemperatureChange;
      Warning.Visible       := false;
    end
    else
      Warning.Visible       := true;
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
      TemperatureFahrenheit := input;
      TemperatureCelsius    := (TemperatureFahrenheit - 32) / 1.8;
      TemperatureKelvin     := (TemperatureFahrenheit + 459.67) / 1.8;
      Voltage               := ThermoCouple.Temp2Volt(TemperatureCelsius) - ThermoCouple.Temp2Volt(ReferenceCelsius);
      LastChange            := TemperatureChange;
      Warning.Visible       := false;
    end
    else
      Warning.Visible       := true;
    UpdateDisplay;
  end;
end;

procedure TMainForm.AboutMenuClick(Sender: TObject);
begin
  AboutForm.Left          := MainForm.Left;
  AboutForm.Top           := MainForm.Top;
  AboutForm.Visible       := true;
  MainForm.Visible        := false;
  PreferencesForm.Visible := false;
end;

procedure TMainForm.PreferencesMenuClick(Sender: TObject);
begin
  PreferencesForm.Left         := MainForm.Left;
  PreferencesForm.Top          := MainForm.Top;
  PreferencesForm.Visible      := true;
  AboutForm.Visible            := false;
  MainForm.Visible             := false;
end;

{$R *.lfm}

end.

