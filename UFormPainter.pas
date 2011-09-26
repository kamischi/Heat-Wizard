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

unit UFormPainter;

{$mode objfpc}

interface

uses
  Forms;

procedure PaintBackground(Form: TForm);

implementation

function RGB(const R, G, B: Word): integer; inline;
begin
  RGB := R*256*256 + G*256 + B;
end;

procedure PaintBackground(Form: TForm);
  var
    Row, LocalHeight: word;
  begin
    LocalHeight := (Form.ClientHeight + 255) div 256;
    for Row := 0 to 255 do
      with Form.Canvas do
      begin
        Brush.Color := RGB(0, 0, 96 + Row div 2);
        FillRect(0, Row * LocalHeight, Form.ClientWidth, (Row + 1) * LocalHeight);
      end;

  end;

end.

