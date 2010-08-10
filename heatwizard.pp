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
  UCommandlineHandler,
  UConverter,
  SysUtils;

type
  TEvaluate = (Ttemperature, Treference, Tvoltage);
var
  CommandlineHandler: TCommandlineHandler;
  Converter:          TConverter;
  temperature, reference, voltage: double;
  tempUnit, coupleType: char;
  Evaluate: Set of TEvaluate;

begin
  CommandlineHandler := TCommandlineHandler.Create;
  CommandlineHandler.Debug := false;
  CommandlineHandler.AddOption('-h', '', TNone);
  CommandlineHandler.AddOption('-t', '', TReal);
  CommandlineHandler.AddOption('-r', '', TReal);
  CommandlineHandler.AddOption('-u', '', TChar);
  CommandlineHandler.AddOption('-v', '', TReal);
  CommandlineHandler.AddOption('-T', '', TChar);
  CommandlineHandler.Tokenize;
  CommandlineHandler.Parse;
  writeln ('Option -h is set to : ', CommandlineHandler.GetOptionIsSet('-h'));
  temperature := 25.0;
  reference   := 25.0;
  tempUnit    :=  'C';
  voltage     :=  0.0;
  coupleType  :=  'K';
  Evaluate := [Ttemperature, Treference, Tvoltage];
  if CommandlineHandler.GetOptionIsSet('-t') then
  begin
    temperature := strToFloat(CommandlineHandler.GetOptionValue('-t'));
    Evaluate    := Evaluate - [Ttemperature];
  end;
  if CommandlineHandler.GetOptionIsSet('-r') then
  begin
    reference   := strToFloat(CommandlineHandler.GetOptionValue('-r'));
    Evaluate    := Evaluate - [Treference];
  end;
  if CommandlineHandler.GetOptionIsSet('-u') then
  begin
    tempUnit    :=            CommandlineHandler.GetOptionValue('-u')[1];
  end;
  if CommandlineHandler.GetOptionIsSet('-v') then
  begin
    voltage     := strToFloat(CommandlineHandler.GetOptionValue('-v'));
    Evaluate    := Evaluate - [Tvoltage];
  end;
  if CommandlineHandler.GetOptionIsSet('-T') then
  begin
    coupleType  :=            CommandlineHandler.GetOptionValue('-T')[1];
  end;
  CommandlineHandler.Destroy;
  writeln ('Value of -t is: ', temperature);
  writeln ('Value of -r is: ', reference);
  writeln ('Value of -u is: ', tempUnit);
  writeln ('Value of -v is: ', voltage);
  writeln ('Value of -T is: ', coupleType);
  Converter := TConverter.Create;
  if Ttemperature in Evaluate then
  begin
    Temperature := Converter.GetTemperature(Voltage, Reference, coupleType, tempUnit);
    writeln ('Voltage: ', voltage:8:3, ' mV, ', 'Reference: ', reference:8:3, ' ', tempUnit, ', Type: ', coupleType);
    writeln ('TEMPERATURE: ', temperature:8:3, ' ', tempUnit);
  end
  else if Tvoltage in Evaluate then
  begin
    Voltage := Converter.GetVoltage(Temperature, Reference, coupleType, tempUnit);
    writeln ('Temperature: ', temperature:8:3, ' ', tempUnit, ', Reference: ', reference:8:3, ' ', tempUnit, ', Type: ', coupleType);
    writeln ('VOLTAGE: ', voltage:8:3, ' mV');
  end
  else if Treference in Evaluate then
  begin
    Reference := Converter.GetReference(Temperature, Voltage, coupleType, tempUnit);
    writeln ('Temperature: ', temperature:8:3, ' ', tempUnit, ', Voltage: ', voltage:8:3, ' mV', ', Type: ', coupleType);
    writeln ('REFERENCE: ', reference:8:3, ' ', tempUnit);
  end
  else
  begin
     
  end;
  Converter.Destroy;

end.

