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

program HeatWizard;

{$mode objfpc}
{$H+}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  { you can add units after this }
  HeatWizardPanel,
  UAbout,
  ULog,
  UPath,
  UPreferences,
  UPreferenceData, UPlatform;

{$IFDEF WINDOWS}
{$R HeatWizard.rc}
{$R Icon.rc}
{$ENDIF}

begin
  Application.Title:='Heat Wizard';
  Logger := TLogger.Create;

  PreferenceData := TPreferenceData.Create;
  PreferenceData.Read;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPreferencesForm, PreferencesForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.

