program StringListTest;

{$mode objfpc}
{$H+}

uses
  Classes;

var
  TestList: TStringList;
  index: integer;

begin
  TestList := TStringList.Create;
  TestList.CaseSensitive := true;
  TestList.Add('-h');
  TestList.Add('-t');
  TestList.Add('-r');
  TestList.Add('-v');
  TestList.Add('-T');

  writeln ('Index String');
  for index := 0 to TestList.Count-1 do
  begin
    writeln (index:3, '   ', TestList[index]);
  end;

  writeln ('Found: ', TestList.IndexOf('-h'));
  writeln ('Found: ', TestList.IndexOf('-t'));
  writeln ('Found: ', TestList.IndexOf('-r'));
  writeln ('Found: ', TestList.IndexOf('-v'));
  writeln ('Found: ', TestList.IndexOf('-T'));
  writeln ('Found: ', TestList.IndexOf('-v'));
  writeln ('Found: ', TestList.IndexOf('-r'));
  writeln ('Found: ', TestList.IndexOf('-t'));
  writeln ('Found: ', TestList.IndexOf('-h'));
  writeln;

  writeln ('Found: ', TestList.IndexOf('-a'));

  TestList.Destroy;
end.

