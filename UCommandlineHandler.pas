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
  TCommandlineHandler = class
  public
    Debug: boolean;
    constructor Create;
    procedure AddOption(NewShortOption: string; NewDefaultValue: string);
    procedure Tokenize;
    procedure Parse;
    function GetOptionIsSet(query: string): boolean;
    function GetOptionValue(query: string): string;
  private
    NumberOfTokens: integer;
    Token:        TStringList;
    ShortOption:  TStringList;
    DefaultValue: TStringList;
    Value:        TStringList;
    OptionIsSet:  array of boolean;
  end;

implementation

uses
  StrUtils;

constructor TCommandlineHandler.Create;
begin
  Inherited;
  Debug := false;
  Token        := TStringList.Create;
  ShortOption  := TStringList.Create;
  DefaultValue := TStringList.Create;
  Value        := TStringList.Create;
  ShortOption.CaseSensitive := true;
end;

procedure TCommandlineHandler.AddOption(NewShortOption: string; NewDefaultValue: string);
begin
  ShortOption.Add(NewShortOption);
  DefaultValue.Add(NewDefaultValue);
  Value.Add(NewDefaultValue);
  SetLength(OptionIsSet, Length(OptionIsSet) + 1);
  if NewDefaultValue <> '' then
    OptionIsSet[high(OptionIsSet)] := true;
end;

procedure TCommandlineHandler.Tokenize;
var
  index, position: integer;

begin
  NumberOfTokens := Paramcount;
  if Debug then
    writeln ('Number of command-line parameters: ', NumberOfTokens);
  for index := 0 to NumberOfTokens do
  begin
    if Debug then
      writeln ('Parameter ', index, ': ', ParamStr(index));
    Token.Add(ParamStr(index));
    // check for '=' in the option and separate the value to a new token
    position := Pos('=', Token[index]);
    if position > 0 then
    begin
      Token.Add(copy(Token[index], position+1, length(Token[index])));
      if Debug then
        writeln ('Option value in new token:', Token[index+1]);
      Token[index] := copy(Token[index], 1, position-1);
      if Debug then
        writeln ('Option name only in shortened token:', Token[index]);
    end;
  end;
end;

procedure TCommandlineHandler.Parse;
var
  index, position, lastOption: integer;
  acceptOptionValue: boolean;
  inputString: string;

begin
   // the first token with index 0 is the command
   // so, start with token index 1
  if Debug then
  begin
    writeln ('Start parsing. Number of tokens: ', Token.Count);
    for index := 0 to Token.Count-1 do
      writeln ('Token[', index, ']: ', Token[index]);
  end;
{
  index := 1;
  while index < Token.Count do
  begin
    if Length(Token[index]) > 2 then
    begin
      writeln ('Error: Option name', index, ' (', Token[index], ') ', 'should have only one character.');
      writeln ('Enter replacement for (', Token[index], ') :');
      readln (inputString);
      Token[index] := inputString;
    end;
    index := index + 1;
  end;
}
  acceptOptionValue := false;
  for index := 1 to Token.Count-1 do
  begin
    if Debug then
      writeln ('Checking token ', index, ' Tokenstring: ', Token[index]);
    position := ShortOption.IndexOf(Token[index]);
    if position <> -1 then
    begin
      if Debug then
        writeln ('Match with option ', position, ' (', ShortOption[position],') found for token[', index, '] (', Token[index],').');
      OptionIsSet[position] := true;
      lastOption := position;
      acceptOptionValue := true;
      if Debug then
        writeln ('Option ', ShortOption[position], ' ', position, ' set');
    end
    else
    begin
      if acceptOptionValue and (Token[index][1] <> '-') then
      begin
        Value[lastOption] := Token[index];
	acceptOptionValue := false;
      end
      else
      begin
        if Debug then
          writeln ('No match with any option found for token[', index, '] (', Token[index],').');
      end;
    end;
  end;
  if Debug then
  begin
    writeln ('index option isSet Value');
    for index := 0 to ShortOption.Count-1 do
    begin
      write (index:3);
      write (ShortOption[index]:6);
      write (OptionIsSet[index]:9);
      write (' ', Value[index]);
      writeln;
    end;
  end;
end;

function TCommandlineHandler.GetOptionIsSet(query: string): boolean;
var
  position: integer;
  
begin
  position := ShortOption.IndexOf(query);
  if Debug then
    writeln ('Found option #', position);
  if position <> -1 then
    Result := OptionIsSet[position]
  else
    Result := false;
end;

function TCommandlineHandler.GetOptionValue(query: string): string;
var
  position: integer;
  
begin
  Result := '';
  position :=  ShortOption.IndexOf(query);
  if position <> -1 then
  begin
    Result := Value[position];
    if Debug then
      writeln ('Found value for option ', query, ': ', Result);
  end
  else
    if Debug then
      writeln ('No value found for option "', query, '". Position: ', position, ' Length of ShortOptionsList: ', ShortOption.Count);
end;

end.