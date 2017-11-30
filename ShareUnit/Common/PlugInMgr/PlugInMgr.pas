unit PlugInMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description： PlugInMgr Interface
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // PlugInMgr Interface
  IPlugInMgr = interface(IInterface)
    ['{C0081872-4BB2-4084-9F93-79FF825F630C}']
    // Get Caption
    function GetCaption: string;
    // Load
    procedure Load;
    //设置语言类型(ARefresh : 是否需要刷新窗体)
//    procedure SetLanguage(ALanguage: TLanguageType; ARefresh: Boolean);
  end;

implementation

end.
