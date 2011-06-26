program MOFileReaderTest;

{$mode objfpc}
{$H+}

uses
  gettext;

var
  MOFile: TMOFile;

begin
  writeln;
  writeln ('Program for checking endian problem in .mo files.');
  writeln;
  try
    MOFile := TMOFile.Create('heatwizard-powerpc.de.mo');
  except
    on EMOFileError do
    begin
      writeln ('It does not work! powerpc .mo file header not understood');
      writeln;
      exit;
    end;
  end;
  writeln ('German Translation from powerpc .mo file:');
  writeln;
  writeln ('  ', MOFile.translate('About Text'));
  writeln;
  writeln ('  ', MOFile.translate('Done'));
  MOFile.Destroy;
  writeln;
  try
    MOFile := TMOFile.Create('heatwizard-i386.de.mo');
  except
    on EMOFileError do
    begin
      writeln ('It does not work! i386 .mo file header not understood');
      writeln;
      exit;
    end;
  end;
  writeln ('German Translation from i386 .mo file:');
  writeln;
  writeln ('  ', MOFile.translate('About Text'));
  writeln;
  writeln ('  ', MOFile.translate('Done'));
  MOFile.Destroy;
  writeln;
  writeln ('It works!');
  writeln;
end.

