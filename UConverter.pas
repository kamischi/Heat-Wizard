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

unit UConverter;

{$mode objfpc}
{$H+}

interface

uses
  Classes,
  UThermoCouple;

type
  TConverter = class
  public
    ThermoCouple: TThermoCouple;
    constructor Create;
    function GetTemperature(const Voltage, Reference: double; 
                            const ThermoelementType:  char;
                            const TemperatureUnit:    char): double;
    function GetVoltage(const Temperature, Reference: double;
                        const ThermoelementType:      char;
                        const TemperatureUnit:        char): double;
    function GetReference(const Temperature, Voltage: double;
                          const ThermoelementType:    char;
                          const TemperatureUnit:      char): double;
  end;

implementation

constructor TConverter.Create;
begin
  Inherited;
  ThermoCouple := TThermoCouple.Create;
end;

function TConverter.GetTemperature(const Voltage, Reference: double; 
                                   const ThermoelementType:  char;
                                   const TemperatureUnit:    char): double;
var
  code: word;
begin
  val(ThermoelementType, ThermoCouple.ThermoElementType, code);
  case TemperatureUnit of
    'C': Result :=          ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(Reference         ));
    'K': Result := 273.15 + ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(Reference - 273.15));
  end;
end;

function TConverter.GetVoltage(const Temperature, Reference: double; 
                               const ThermoelementType:      char;
                               const TemperatureUnit:        char): double;
var
  code: word;
begin
  val(ThermoelementType, ThermoCouple.ThermoElementType, code);
  case TemperatureUnit of
    'C': Result := ThermoCouple.Temp2Volt(Temperature         ) - ThermoCouple.Temp2Volt(Reference         );
    'K': Result := ThermoCouple.Temp2Volt(Temperature - 273.15) - ThermoCouple.Temp2Volt(Reference - 273.15);
  end;
end;

function TConverter.GetReference(const Temperature, Voltage: double; 
                                 const ThermoelementType:    char;
                                 const TemperatureUnit:      char): double;
var
  code: word;
begin
  val(ThermoelementType, ThermoCouple.ThermoElementType, code);
  case TemperatureUnit of
    'C': Result :=          ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(Temperature         ));
    'K': Result := 273.15 + ThermoCouple.Volt2Temp(Voltage + ThermoCouple.Temp2Volt(Temperature - 273.15));
  end;
end;

end.
