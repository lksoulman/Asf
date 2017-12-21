unit Master;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Master
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  ChildPage;

type

  // Master
  IMaster = interface(IInterface)
    ['{22C6E574-2100-4D8C-9867-757EB660D93F}']
    // GetHandle
    function GetHandle: Cardinal;
    // GetWindowState
    function GetWindowState: TWindowState;
    // SetWindowState
    procedure SetWindowState(AWindowState: TWindowState);

    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // GoBack (True is Response, False Is not Response)
    function GoBack: Boolean;
    // GoForward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // IsHasChildPage
    function IsHasChildPage(ACommandId: Integer): Boolean;
    // AddChildPage
    function AddChildPage(AChildPage: IChildPage): Boolean;
    // AddCmdCookie
    function AddCmdCookie(ACommandId: Integer; AParams: string): Boolean;
    // BringToFrontChildPage
    function BringToFrontChildPage(ACommandId: Integer; AParams: string): Boolean;

    property Handle: Cardinal read GetHandle;
    property WindowState: TWindowState read GetWindowState write SetWindowState;
  end;

implementation

end.
