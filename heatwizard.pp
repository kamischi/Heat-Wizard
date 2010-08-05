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
  UResultHandler;

var
  CommandlineHandler: TCommandlineHandler;
  Converter:          TConverter;
  ResultHandler:      TResultHandler;

begin
  CommandlineHandler := TCommandlineHandler.Create;
  CommandlineHandler.Debug := true;
  CommandlineHandler.AddOption('-h', '');
  CommandlineHandler.AddOption('-t', '298');
  CommandlineHandler.AddOption('-r', '273');
  CommandlineHandler.AddOption('-v', '0');
  CommandlineHandler.AddOption('-T', 'K');
  CommandlineHandler.Tokenize;
  CommandlineHandler.Parse;
  writeln ('-h is set to: ', CommandlineHandler.GetOptionIsSet('-h'));
  writeln ('-t is set to: ', CommandlineHandler.GetOptionIsSet('-t'));
  writeln ('-r is set to: ', CommandlineHandler.GetOptionIsSet('-r'));
  writeln ('-v is set to: ', CommandlineHandler.GetOptionIsSet('-v'));
  writeln ('-T is set to: ', CommandlineHandler.GetOptionIsSet('-T'));
  writeln ('Value of -h is: ', CommandlineHandler.GetOptionValue('-h'));
  writeln ('Value of -t is: ', CommandlineHandler.GetOptionValue('-t'));
  writeln ('Value of -r is: ', CommandlineHandler.GetOptionValue('-r'));
  writeln ('Value of -v is: ', CommandlineHandler.GetOptionValue('-v'));
  writeln ('Value of -T is: ', CommandlineHandler.GetOptionValue('-T'));
  CommandlineHandler.Destroy;
  Converter := TConverter.Create;
  Converter.Destroy;
  ResultHandler := TResultHandler.Create;
  ResultHandler.Destroy;
end.

