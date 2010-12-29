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

unit UCommandlineHandler;

{$mode objfpc}
{$H+}

interface

uses
  Classes;

type
  TValueType = (TNone,
                TRealOptional, TIntegerOptional, TCharOptional,
                TRealMust,     TIntegerMust,     TCharMust
               );

  TCommandlineHandler = class
  public
    Debug: boolean;
    constructor Create;
    destructor Destroy;
    procedure AddOption(const NewShortOption: string);
    procedure AddOption(const NewShortOption: string; const NewValueType: TValueType);
    procedure AddOption(const NewShortOption: string; const NewLongOption: string);
    procedure AddOption(const NewShortOption: string; const NewLongOption: string; const NewValueType: TValueType);
    procedure AddOption(const NewShortOption: string; const NewLongOption: string; const NewDefaultValue: string; const NewValueType: TValueType);
    function GetOptionIsSet(const query: string): boolean;
    function GetOptionIsSet(const queryChar: char; const queryString: string): boolean;
    function GetOptionValue(const query: string): string;
    function GetOptionValue(const queryChar: char; const queryString: string): string;
    function CheckOptions: string;
  private
    ShortOption:  string;
    LongOption:   TStringList;
    DefaultValue: TStringList;
    Value:        TStringList;
    ValueType:    array of TValueType;
    OptionIsSet:  array of boolean;
  end;

implementation

uses
  CustApp, StrUtils, SysUtils;

var
  HeatWizardApplication: TCustomApplication;

constructor TCommandlineHandler.Create;
begin
  Inherited;
  Debug := false;
  LongOption   := TStringList.Create;
  DefaultValue := TStringList.Create;
  Value        := TStringList.Create;
  HeatWizardApplication := TCustomApplication.Create(Nil);
end;

destructor TCommandlineHandler.Destroy;
begin
  Inherited;
  HeatWizardApplication.Destroy;
end;

function TCommandlineHandler.GetOptionIsSet(const query: string): boolean;
begin
  Result := HeatWizardApplication.HasOption(query);
end;

function TCommandlineHandler.GetOptionIsSet(const queryChar: char; const queryString: string): boolean;
begin
  Result := HeatWizardApplication.HasOption(queryChar, queryString);
end;

function TCommandlineHandler.GetOptionValue(const query: string): string;
begin
  Result := HeatWizardApplication.GetOptionValue(query);
end;

function TCommandlineHandler.GetOptionValue(const queryChar: char; const queryString: string): string;
begin
  Result := HeatWizardApplication.GetOptionValue(queryChar, queryString);
end;

function TCommandlineHandler.CheckOptions: string;
var
  index: integer;
  valueString: string;
  integerTest: integer;
  realTest: real;
begin
  Result := HeatWizardApplication.CheckOptions(ShortOption, LongOption);
  if Result = '' then
    for index := 0 to LongOption.Count - 1 do
    begin
      //write (DelChars(ShortOption, ':')[index+1], ', ');
      //writeln (LongOption[index]);
      //writeln (HeatWizardApplication.GetOptionValue(DelChars(ShortOption, ':')[index+1], Copy2Symb(LongOption[index], ':')));
      valueString := HeatWizardApplication.GetOptionValue(DelChars(ShortOption, ':')[index+1], Copy2Symb(LongOption[index], ':'));
      if valueString <> '' then
      begin
        case valueType[index] of
         TRealOptional, TRealMust: if not (TryStrToFloat(valueString, realTest)) then
                                     Result := 'Error: "' + valuestring + '" could not be converted to a real number.';
         TIntegerOptional, TIntegerMust : if not (TryStrToInt(valueString, integerTest)) then
                                            Result := 'Error: "' + valuestring + '" could not be converted to an integer number.';
        end;
      end;
    end;
end;

procedure TCommandlineHandler.AddOption(const NewShortOption: string);
begin
  AddOption(NewShortOption, '', '', TNone);
end;

procedure TCommandlineHandler.AddOption(const NewShortOption: string; const NewValueType: TValueType);
begin
  AddOption(NewShortOption, '', '', NewValueType);
end;

procedure TCommandlineHandler.AddOption(const NewShortOption: string; const NewLongOption: string);
begin
  AddOption(NewShortOption, NewLongOption, '', TNone);
end;

procedure TCommandlineHandler.AddOption(const NewShortOption: string; const NewLongOption: string; const  NewValueType: TValueType);
begin
  AddOption(NewShortOption, NewLongOption, '', NewValueType);
end;

procedure TCommandlineHandler.AddOption(const NewShortOption: string; const NewLongOption: string; const NewDefaultValue: string;const NewValueType: TValueType);
begin
  case NewValueType of
    TRealMust, TIntegerMust, TCharMust:
    begin
      ShortOption := ShortOption + NewShortOption[2] + ':';
      LongOption.Add(copy(NewLongOption,3,Length(NewLongOption)-2) + ':');
    end;
    TRealOptional, TIntegerOptional, TCharOptional:
    begin
      ShortOption := ShortOption + NewShortOption[2] + '::';
      LongOption.Add(copy(NewLongOption,3,Length(NewLongOption)-2) + '::');
    end;
    else
    begin
      ShortOption := ShortOption + NewShortOption[2];
      LongOption.Add(copy(NewLongOption,3,Length(NewLongOption)-2));
    end;
  end;
  DefaultValue.Add(NewDefaultValue);
  Value.Add(NewDefaultValue);
  SetLength(ValueType, Length(ValueType) + 1);
  ValueType[high(ValueType)] := NewValueType;
  SetLength(OptionIsSet, Length(OptionIsSet) + 1);
  if NewDefaultValue <> '' then
    OptionIsSet[high(OptionIsSet)] := true;
end;

end.
