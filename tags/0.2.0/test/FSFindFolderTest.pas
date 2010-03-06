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

program FSFindFolderTest;

uses
  SysUtils,
  MacOSAll;
  
const
  PathNameLength = 200;

var
  foundRef: FSRef;
  Path:     CStringPtr;
  Error:    OSStatus;

begin
  Error := FSFindFolder(kUserDomain, kDomainLibraryFolderType, kDontCreateFolder, foundRef);
  if Error <> noErr then
  begin
    writeln ('FSFindFolder Error: ', Error);
    halt;
  end;
  Path :=  StrAlloc (PathNameLength + 1);  // null termination needs one more character 
  Error := FSRefMakePath(foundRef, Path, PathNameLength);
  if Error <> noErr then
  begin
    writeln ('FSRefMakePath Error: ', Error);
    if Error = -2110 then
      writeln ('Length of path name is to short. Increase PathNameLength.');
    halt;
  end;
  writeln (Path);
end.