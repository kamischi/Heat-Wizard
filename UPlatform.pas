{* Copyright (C) 2011 Karl-Michael Schindler
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

unit UPlatform;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils; 

{$IF Defined(WINDOWS)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
  LanguageFileBasePath = 'languages';
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = 'heatwizard.xml';
{$ELSEIF Defined(DARWIN)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
var
  PreferenceDirName:    string = '';
  PreferenceFileName:   string = '';
  LanguageFileBasePath: string;   // path is constructed in Translate
{$ELSEIF Defined(UNIX)}
const
  PF_ButtonHeight = 22;
  PF_AboutTextFontSize = -7;
var
  PreferenceDirName:    string = '/.heatwizard/';     // GetEnvironmentVariable('HOME') added where used
  PreferenceFileName:   string = 'heatwizard.xml';
  LanguageFileBasePath: string = '/.heatwizard/locale/';
{$IFEND}

implementation

end.
