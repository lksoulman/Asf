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
  WebInfo,
  Windows,
  Classes,
  SysUtils;

type


  // WebCfg Interface
  IWebCfg = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // GetUrl
    function GetUrl(AWebID: Integer): WideString;
    // GetUrlInfo
    function GetUrlInfo(AWebID: Integer): IWebInfo;
  end;

implementation

end.
