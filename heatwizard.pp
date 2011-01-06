{* Copyright (C) 2010 Karl-Michael Schindler
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

program heatwizard;

{$mode objfpc}
{$H+}

uses
  SysUtils,
  UCommandlineHandler,
  UConverter;

type
  TEvaluate = (Ttemperature, Treference, Tvoltage);
var
  CommandlineHandler: TCommandlineHandler;
  Converter:          TConverter;
  temperature, reference, voltage: double;
  tempUnitString, optionValueString: string;
  tempUnit, coupleType: char;
  Evaluate: set of TEvaluate;

procedure writeUsage;
begin
  writeln ('heatwizard: converts a themocouple voltage to a temperature and vice versa.');
  writeln ('Usage: heatwizard [-hrstuvT]');
  writeln ('         [--help]');
  writeln ('         [--short]');
  writeln ('         [--temperature=<temperature>]');
  writeln ('         [--reference=<reference temperature>]');
  writeln ('         [--voltage=<thermovoltage>]');
  writeln ('         [--unit=<temperature unit (C, K, F)>]');
  writeln ('         [--type=<thermocouple type (B, E, J, K, N, R, S, T)>]');
end;

begin
  CommandlineHandler := TCommandlineHandler.Create;
  CommandlineHandler.Debug := false;
  CommandlineHandler.AddOption('-h', '--help', TNone);
  CommandlineHandler.AddOption('-?', TNone);
  CommandlineHandler.AddOption('-t', '--temperature', '', TRealOptional);
  CommandlineHandler.AddOption('-r', '--reference',   '', TRealOptional);
  CommandlineHandler.AddOption('-u', '--unit',        '', TCharOptional);
  CommandlineHandler.AddOption('-v', '--voltage',     '', TRealOptional);
  CommandlineHandler.AddOption('-T', '--type',        '', TCharOptional);
  CommandlineHandler.AddOption('-s', '--short', TNone);
//  writeln ('Option -h is set?: ', CommandlineHandler.GetOptionIsSet('h'));
//  writeln ('Option --help is set?: ', CommandlineHandler.GetOptionIsSet('help'));
//  writeln ('Option --help or -h is set?: ', CommandlineHandler.GetOptionIsSet('h', 'help'));
  temperature := 25.0;
  reference   := 25.0;
  tempUnit    :=  'C';
  tempUnitString := '°C';
  voltage     :=  0.0;
  coupleType  :=  'K';
//  writeln (CommandlineHandler.CheckOptions);
  if ParamCount > 0 then
  if ( CommandlineHandler.CheckOptions = '' )
     and not ( CommandlineHandler.GetOptionIsSet('h', 'help') )
     and not ( CommandlineHandler.GetOptionIsSet('?') ) then
  begin
    Evaluate := [Ttemperature, Treference, Tvoltage];
    if CommandlineHandler.GetOptionIsSet('u', 'unit') then
    begin
      optionValueString :=  CommandlineHandler.GetOptionValue('u', 'unit');
      if length (optionValueString) >= 1 then
        tempUnit :=  optionValueString[1];
      case tempUnit of
        'K' : begin
               tempUnitString := 'K';
               reference      := reference   + double(273.15);
               temperature    := temperature + double(273.15);
              end;
        'F' : begin
               tempUnitString := '°F';
               reference      := reference   * double(1.8) + double(32.0);
               temperature    := temperature * double(1.8) + double(32.0);
              end;
        'C' : tempUnitString := '°C';
      end;
    end;
    if CommandlineHandler.GetOptionIsSet('t', 'temperature') then
    begin
      temperature := strToFloat(CommandlineHandler.GetOptionValue('t', 'temperature'));
      Evaluate    := Evaluate - [Ttemperature];
    end;
    if CommandlineHandler.GetOptionIsSet('r', 'reference') then
    begin
      reference   := strToFloat(CommandlineHandler.GetOptionValue('r', 'reference'));
      Evaluate    := Evaluate - [Treference];
    end;
    if CommandlineHandler.GetOptionIsSet('v', 'voltage') then
    begin
      voltage     := strToFloat(CommandlineHandler.GetOptionValue('v', 'voltage'));
      Evaluate    := Evaluate - [Tvoltage];
    end;
    if CommandlineHandler.GetOptionIsSet('T', 'type') then
    begin
      optionValueString :=  CommandlineHandler.GetOptionValue('T', 'type');
      if length (optionValueString) >= 1 then
        coupleType :=  optionValueString[1];
    end;

    Converter := TConverter.Create;
    if Ttemperature in Evaluate then
    begin
      Temperature := Converter.GetTemperature(Voltage, Reference, coupleType, tempUnit);
      if CommandlineHandler.GetOptionIsSet('s', 'short') then
        writeln (temperature:8:3)
      else
      begin
        writeln ('Voltage: ', voltage:8:3, ' mV, ', 'Reference: ', reference:8:3, ' ', tempUnitString, ', Type: ', coupleType);
        writeln ('TEMPERATURE: ', temperature:8:3, ' ', tempUnitString);
      end;
    end
    else if Tvoltage in Evaluate then
    begin
      Voltage := Converter.GetVoltage(Temperature, Reference, coupleType, tempUnit);
      if CommandlineHandler.GetOptionIsSet('s', 'short') then
        writeln (voltage:8:3)
      else
      begin
        writeln ('Temperature: ', temperature:8:3, ' ', tempUnitString, ', Reference: ', reference:8:3, ' ', tempUnitString, ', Type: ', coupleType);
        writeln ('VOLTAGE: ', voltage:8:3, ' mV');
      end;
    end
    else if Treference in Evaluate then
    begin
      Reference := Converter.GetReference(Temperature, Voltage, coupleType, tempUnit);
      if CommandlineHandler.GetOptionIsSet('s', 'short') then
        writeln (reference:8:3)
      else
      begin
        writeln ('Temperature: ', temperature:8:3, ' ', tempUnitString, ', Voltage: ', voltage:8:3, ' mV', ', Type: ', coupleType);
        writeln ('REFERENCE: ', reference:8:3, ' ', tempUnitString);
      end;
    end;

    CommandlineHandler.Destroy;
    Converter.Destroy;
  end
  else
  writeUsage
  else
  writeUsage;
end.

