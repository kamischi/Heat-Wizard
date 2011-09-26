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

