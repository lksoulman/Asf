unit Browser;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Browser Interface
// Author£º      lksoulman
// Date£º        2017-12-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms;

type

  // Browser Interface
  IBrowser = interface(IInterface)
    ['{66174479-5FA4-483C-AD38-7D97023ACF12}']
    // StopLoad
    procedure StopLoad;
    // GetUrl
    function GetUrl: string;
    // GoBack
    function GoBack: Boolean;
    // GoForward
    function GoForward: Boolean;
    // CanGoBack
    function CanGoBack: Boolean;
    // CanGoForward
    function CanGoForward: Boolean;
    // GetBrowserUI
    function GetBrowserUI: TForm;
    // LoadWebUrl
    procedure LoadWebUrl(AUrl: string);
    // NotifyExValChange
    procedure NotifyExValChange(AKey: string);
    // ExecuteJavaScript
    procedure ExecuteJavaScript(AJavaScript: string);
  end;

implementation

end.
