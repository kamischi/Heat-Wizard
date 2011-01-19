unit UPlatform;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils; 

{$IF Defined(WINDOWS)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
{$ELSEIF Defined(DARWIN)}
const
  PF_ButtonHeight = 20;
  PF_AboutTextFontSize = 0;
{$ELSE}
const
  PF_ButtonHeight = 22;
  PF_AboutTextFontSize = -7;
{$IFEND}

implementation

end.
