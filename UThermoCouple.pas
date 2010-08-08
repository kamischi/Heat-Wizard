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

unit UThermoCouple;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils; 

type
  TThermoelementType = (B, E, J, K, N, R, S, T);
  TThermoCouple = class
    TemperatureRangeLimits: array of double;
    TemperatureRangeLimitsV2T: array of double;
    aT2V: array of double;
    bT2V: array of double;
    cT2V: array of double;
    aV2T: array of double;
    bV2T: array of double;
    cV2T: array of double;
    procedure InitBase(RT, aT, bT, cT, VT, aV, bV, cV: array of double);
    procedure Init;
//    function Temp2Volt (Temp: real) : real;
//    function Volt2Temp (Volt: real) : real;
  end;

var
  Thermocouple: array[TThermoelementType] of TThermoCouple;

implementation

uses
  math;

procedure TThermoCouple.InitBase(RT, aT, bT, cT, VT, aV, bV, cV: array of double);
var
  i: integer;
begin
  setlength (TemperatureRangeLimits, length(RT));
  for i := low(RT) to high(RT) do
    TemperatureRangeLimits[i] := RT[i];
  setlength (aT2V, length(aT));
  for i := low(aT) to high(aT) do
    aT2V[i] := aT[i];
  setlength (bT2V, length(bT));
  for i := low(bT) to high(bT) do
    bT2V[i] := bt[i];
  setlength (cT2V, length(cT));
  for i := low(cT) to high(cT) do
    cT2V[i] := cT[i];
  setlength (TemperatureRangeLimits, length(VT));
  for i := low(VT) to high(VT) do
    TemperatureRangeLimits[i] := VT[i];
  setlength (aV2T, length(aV));
  for i := low(aV) to high(aV) do
    aV2T[i] := aV[i];
  setlength (bV2T, length(bV));
  for i := low(bV) to high(bV) do
    bV2T[i] := bV[i];
  setlength (cV2T, length(cV));
  for i := low(cV) to high(cV) do
    cV2T[i] := cV[i];
end;

procedure TThermoCouple.Init;
begin
    {
  Thermocouple[B].InitBase(
    ( 0.000, 630.615, 1820.000),
    ( 0.000000000000,
     -0.246508183460E-03,
      0.590404211710E-05,
     -0.132579316360E-08,
      0.156682919010E-11,
     -0.169445292400E-14,
      0.629903470940E-18),
    (-0.389381686210E+01,
      0.285717474700E-01,
     -0.848851047850E-04,
      0.157852801640E-06,
     -0.168353448640E-09,,
      0.111097940130E-12,
     -0.445154310330E-16
      0.989756408210E-20,
     -0.937913302890E-24),
    ( 250.000, 700.000, 1820.000),
    ( 9.8423321E+01,
      6.9971500E+02,
     -8.4765304E+02,
      1.0052644E+03,
     -8.3345952E+02,
      4.5508542E+02,
     -1.5523037E+02,
      2.9886750E+01,
     -2.4742860E+00),
    ( 2.1315071E+02,
      2.8510504E+02,
     -5.2742887E+01,
      9.9160804E+00,
     -1.2965303E+00,
      1.1195870E-01,
     -6.0625199E-03,
      1.8661696E-04,
     -2.4878585E-06)     
    (),
    ()
  );
  }
end;

var
  rangelimitsB: array [0..2] of double = (   0.000,  630.615, 1820.000);
  rangelimitsE: array [0..2] of double = (-270.000,    0.000, 1000.000);
  rangelimitsJ: array [0..2] of double = (-210.000,  760.000, 1200.000);
  rangelimitsK: array [0..2] of double = (-270.000,    0.000, 1372.000);
  rangelimitsN: array [0..2] of double = (-270.000,    0.000, 1300.000);
  rangelimitsR: array [0..3] of double = ( -50.000, 1064.180, 1664.500, 1768.1);
  rangelimitsS: array [0..3] of double = ( -50.000, 1064.180, 1664.500, 1768.1);
  rangelimitsT: array [0..2] of double = (-270.000,    0.000,  400.000);

  alpha: array [TThermoelementType] of array [1..10] of double = (
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    ),
    ( 0.394501280250E-01,
      0.236223735980E-04,
     -0.328589067840E-06,
     -0.499048287770E-08,
     -0.675090591730E-10,
     -0.574103274280E-12,
     -0.310888728940E-14,
     -0.104516093650E-16,
     -0.198892668780E-19,
     -0.163226974860E-22
    )
  );

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

end.

