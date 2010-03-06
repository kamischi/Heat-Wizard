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

unit UBundlePathTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    ResourceDirButton:   TButton;
    ResourceFileButton1: TButton;
    MainBundleButton:    TButton;
    ResourceFileButton2: TButton;
    MainBundlePathStaticText:    TStaticText;
    ResourceDirPathStaticText:   TStaticText;
    ResourceFilePath1StaticText: TStaticText;
    ResourceFilePath2StaticText: TStaticText;
    procedure MainBundleButtonClick(Sender: TObject);
    procedure ResourceDirButtonClick(Sender: TObject);
    procedure ResourceFileButton1Click(Sender: TObject);
    procedure ResourceFileButton2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;

implementation

{ TMainForm }

uses
  MacOSAll;

procedure TMainForm.MainBundleButtonClick(Sender: TObject);
var
  mainBundle: CFBundleRef;
  BundleURL:  CFURLRef;
  Path:       PChar;
begin
  Path       := StrAlloc(255);
  mainBundle := CFBundleGetMainBundle;
  if mainBundle = NIL then
    MainBundlePathStaticText.Caption := 'NIL'
  else
  begin
    BundleURL := CFBundleCopyBundleURL(mainBundle);
    CFURLGetFileSystemRepresentation(BundleURL, false, Path, 255);
    MainBundlePathStaticText.Caption := Path;
  end;
end;

procedure TMainForm.ResourceDirButtonClick(Sender: TObject);
var
  mainBundle:  CFBundleRef;
  ResourceDir: CFURLRef;
  Path:        PChar;
begin
  Path        := StrAlloc(255);
  mainBundle  := CFBundleGetMainBundle;
  ResourceDir := CFBundleCopyResourcesDirectoryURL(mainBundle);
  if ResourceDir = NIL then
    ResourceDirPathStaticText.Caption := 'NIL'
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceDir, true, Path, 255);
    ResourceDirPathStaticText.Caption := Path;
  end;
end;

procedure TMainForm.ResourceFileButton1Click(Sender: TObject);
var
  mainBundle:   CFBundleRef;
  ResourceFile: CFURLRef;
  Path:         PChar;
begin
  Path         := StrAlloc(255);
  mainBundle   := CFBundleGetMainBundle;
  ResourceFile := CFBundleCopyResourceURL(mainBundle, CFSTR('heatwizard'), CFSTR('mo'), CFSTR(''));
  if ResourceFile = NIL then
    ResourceFilePath1StaticText.Caption := 'NIL'
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceFile, true, Path, 255);
    ResourceFilePath1StaticText.Caption := Path;
  end;
end;

procedure TMainForm.ResourceFileButton2Click(Sender: TObject);
var
  mainBundle:   CFBundleRef;
  ResourceFile: CFURLRef;
  Path:         PChar;
begin
  Path         := StrAlloc(255);
  mainBundle   := CFBundleGetMainBundle;
  ResourceFile := CFBundleCopyResourceURL(mainBundle, CFSTR('heatwizard_de'), CFSTR('mo'), CFSTR('languages/de/LC_MESSAGES'));
  if ResourceFile = NIL then
    ResourceFilePath2StaticText.Caption := 'NIL'
  else
  begin
    CFURLGetFileSystemRepresentation(ResourceFile, true, Path, 255);
    ResourceFilePath2StaticText.Caption := Path;
  end;
end;

initialization
  {$I UBundlePathTest.lrs}

end.

