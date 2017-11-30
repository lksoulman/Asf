unit WebCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Web Cfg Interface
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


  // Web Cfg Interface
  IWebCfg = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Get url
    function GetUrl(AWebID: Integer): WideString;
    // Get UrlInfo
    function GetUrlInfo(AWebID: Integer): IWebInfo;
  end;

implementation

end.
