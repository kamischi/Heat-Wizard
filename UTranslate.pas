unit UTranslate;

{$mode objfpc}

interface

uses
  Classes, SysUtils; 

type
  TTranslator = class
  public
    constructor Create; // we need the ceation of a singleton here. and maybe we should reconsider a start/stop of the translator
    function translate(const In: String): String;
  end;

implementation

uses
  Ulog,
  UPLatform;

function TTranslator.translate(const In: String): String;
    var
      LanguageFilePath: string;
      MOFile:           TMOFile;
      index:            integer;
    begin
      TTranslator.translate := In;
      LanguageFilePath := getLanguageFilePath(locale);
      if not FileExists(LanguageFilePath) then
      begin
        Logger.Output ('PreferencesForm', 'File ' + LanguageFilePath + ' not found!');
        Logger.Output ('PreferencesForm', 'Continuing with default language, i.e. English!');
      end
      else
      begin
        try
          MOFile := TMOFile.Create(LanguageFilePath);
        except
         on EMOFileError do
           Logger.Output ('PreferencesForm', 'Invalid .mo file header');
        end;
        if assigned(MOFile) then
        begin
          TTranslator.translate := MOFile.translate(In);
          MOFile.Destroy;
        end;
  end;
end.

