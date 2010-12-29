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
  Classes;

type
  TConverter = class
  public
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

type
  TThermoelementType = (B, E);
  TThermoCouple = record
    TemperatureRangeLimits: array of double;
  end;

var
  ThermoCouple: array [TThermoelementType] of TThermoCouple;

procedure Limit_assign(const coef: array of single);
var
  i: integer;
begin
  setlength (ThermoCouple[B].TemperatureRangeLimits, length(coef));
  for i := low(coef) to high(coef) do
    ThermoCouple[B].TemperatureRangeLimits[i] := coef[i];
end;

procedure Init;
begin
  Limit_assign(
   [0.000, 630.615, 1820.000]
    );
  readln;
end;

function TypK_Temp2Volt (Temp: double) : double;

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

function TypK_Volt2Temp (Volt: double) : double;

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

function TConverter.GetTemperature(const Voltage, Reference: double; 
				   const ThermoelementType:  char;
				   const TemperatureUnit:    char): double;
begin
  case TemperatureUnit of
    'C': Result :=          TypK_Volt2Temp(Voltage + TypK_Temp2Volt(Reference         ));
    'K': Result := 273.15 + TypK_Volt2Temp(Voltage + TypK_Temp2Volt(Reference - 273.15));
  end;
end;

function TConverter.GetVoltage(const Temperature, Reference: double; 
			       const ThermoelementType:      char;
			       const TemperatureUnit:        char): double;
begin
  case TemperatureUnit of
    'C': Result := TypK_Temp2Volt(Temperature         ) - TypK_Temp2Volt(Reference         );
    'K': Result := TypK_Temp2Volt(Temperature - 273.15) - TypK_Temp2Volt(Reference - 273.15);
  end;
end;

function TConverter.GetReference(const Temperature, Voltage: double; 
				 const ThermoelementType:    char;
				 const TemperatureUnit:      char): double;
begin
  case TemperatureUnit of
    'C': Result :=          TypK_Volt2Temp(Voltage + TypK_Temp2Volt(Temperature         ));
    'K': Result := 273.15 + TypK_Volt2Temp(Voltage + TypK_Temp2Volt(Temperature - 273.15));
  end;
end;

end.
