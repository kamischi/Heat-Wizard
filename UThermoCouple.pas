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

unit UThermoCouple;

{$mode objfpc}
{$H+}

interface

uses
  Classes,
  SysUtils;

type
  TThermoElementType = (B, E, J, K, N, R, S, T);
  TThermoElementError = (NoError, ValueTooLow, ValueTooHigh);
  TThermoCouple = class
  public
    ThermoElementType: TThermoElementType;
    ThermoElementError: TThermoElementError;
    function Temp2Volt (Temp: double) : double;
    function Volt2Temp (Volt: double) : double;
  end;
  
var
  ThermoCouple: TThermoCouple;

implementation

uses
  math;

{$INCLUDE Parametervariable.pas}

function TThermoCouple.Temp2Volt (Temp: double) : double;
var
  i, range: integer;
begin
  ThermoElementError := NoError;
  if Temp = 0.0 then
    exit (0.0);    
  case ThermoElementType of
  B: with Parameters_B do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  E: with Parameters_E do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  J: with Parameters_J do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  K: with Parameters_K do
     begin
       {$INCLUDE Temp2Volt.pas}
       if Temp > 0 then
         Temp2Volt := Temp2Volt +  a[0] * exp(a[1] * (Temp - a[2]) * (Temp - a[2]));
     end;
  N: with Parameters_N do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  R: with Parameters_R do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  S: with Parameters_S do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  T: with Parameters_T do
     begin
       {$INCLUDE Temp2Volt.pas}
     end;
  end;
end;

function TThermoCouple.Volt2Temp (Volt: double) : double;
var
  i, range: integer;
begin
  ThermoElementError := NoError;
  if Volt = 0.0 then
    exit (0.0);
  case ThermoElementType of
  B: with Parameters_B do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  E: with Parameters_E do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  J: with Parameters_J do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  K: with Parameters_K do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  N: with Parameters_N do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  R: with Parameters_R do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  S: with Parameters_S do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  T: with Parameters_T do
     begin
       {$INCLUDE Volt2Temp.pas}
     end;
  end;
end;

end.