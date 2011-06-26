program commandlineHandlerTest;

{$mode objfpc}
{$H+}

uses
  UCommandlineHandler;

var
  CommandlineHandler: TCommandlineHandler;

begin
  CommandlineHandler := TCommandlineHandler.Create;
  CommandlineHandler.Debug := true;
  CommandlineHandler.AddOption('-h', '');
  CommandlineHandler.AddOption('-o', '4123');
  CommandlineHandler.Tokenize;
  CommandlineHandler.Parse;
  writeln ('Option -h is set to: ', CommandlineHandler.GetOptionIsSet('-h'));
  writeln ('Option -o is set to: ', CommandlineHandler.GetOptionIsSet('-o'));
  writeln ('Value of -h is: ', CommandlineHandler.GetOptionValue('-h'));
  writeln ('Value of -o is: ', CommandlineHandler.GetOptionValue('-o'));
  writeln ('Value of -e is: ', CommandlineHandler.GetOptionValue('-e'));
  CommandlineHandler.Destroy;
end.
