program Record_Test;

{$mode objfpc}

type
  tdata = class
    limits: array of real;
    a: array of real;
    procedure Init (limitsinit: array of real; ainit: array of real);
  end;

var
  data: tdata;
  j: integer;

procedure tdata.Init (limitsinit: array of real; ainit: array of real);
var
  i: integer;
begin
  setlength (limits, length(limitsinit));
  for i := low(limitsinit) to high(limitsinit) do
    limits[i] := limitsinit[i];
  setlength (a, length(ainit));
  for i := low(ainit) to high(ainit) do
    a[i] := ainit[i];
end;

begin
  data := tdata.create;
  data.init ([1,2,3], [4,5,6,7,8]);
  for j := low(data.limits) to high (data.limits) do
    write (data.limits[j]);
  writeln;
  for j := low(data.a) to high (data.a) do
    write (data.a[j]);
  writeln;
end.