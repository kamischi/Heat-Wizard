program array_assign_test;

{$mode objfpc}
{$H+}

type
  ta_record = record
    erstes: single;
    zweite: char;
    dritte: boolean
  end;

var
  ThermoCouple: array of single;
  a_record: ta_record;

procedure array_assign(const coef: array of single);
var
  i: integer;
begin
  setlength (ThermoCouple, length(coef));
  for i := low(coef) to high(coef) do
    ThermoCouple[i] := coef[i];
end;

procedure record_assign(const coef: ta_record);
begin
  a_record.erstes := coef.erstes;
  a_record.zweite := coef.zweite;
  a_record.dritte := coef.dritte;
end;

procedure Init;
begin
  array_assign(
    [0.000, 630.615, 1820.000]
    );
#  record_assign(
#    (erstes=
#    1.0, zweite:'a', dritte:2.0]
#    );
end;

begin
  Init;
  writeln (length(ThermoCouple));
  writeln (ThermoCouple[0], ThermoCouple[1], ThermoCouple[2]);
end.