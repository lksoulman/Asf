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
//  ChildPage,
  Vcl.Forms;

type

  // Master
  IMaster = interface(IInterface)
    ['{22C6E574-2100-4D8C-9867-757EB660D93F}']
    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // Go Back (True is Response, False Is not Response)
    function GoBack: Boolean;
    // Go Forward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // Get Handle
    function GetHandle: Cardinal;
    // Get Count
    function GetPageCount: Integer;
    // Get Active Page
//    function GetActivePage: IChildPage;
//    // Find Page
//    function FindPage(ACommandId: Integer): IChildPage;
//    // Set ActivatePage
//    procedure SetActivatePage(AChildPage: IChildPage);
    // Set WindowState
    procedure SetWindowState(AWindowState: TWindowState);
  end;

implementation

end.
