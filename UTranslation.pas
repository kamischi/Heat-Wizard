unit UTranslation;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils;

implementation

uses
  gettext;

var
  MOFile: TMOFile;

begin
  MOFile.Create('languages/strings.de.po');
  MOFile.Destroy;
end.
