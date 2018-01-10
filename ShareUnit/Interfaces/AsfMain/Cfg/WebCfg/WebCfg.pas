unit WebCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� WebCfg Interface
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // WebInfo
  TWebInfo = packed record
    FUrl: string;                   // Url
    FWebID: Integer;                // Web ID
    FServerName: string;            // Server Name
    FDescription: string;           // Description
  end;

  // WebInfo Pointer
  PWebInfo = ^TWebInfo;

  // WebCfg Interface
  IWebCfg = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // GetUrl
    function GetUrl(ACommandID: Integer): WideString;
    // GetWebInfo
    function GetWebInfo(ACommandID: Integer): PWebInfo;
  end;

implementation

end.
