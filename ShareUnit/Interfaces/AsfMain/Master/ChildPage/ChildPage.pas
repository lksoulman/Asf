unit ChildPage;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ChildPage Interface
// Author£º      lksoulman
// Date£º        2017-12-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms;

type

  // ChildPage
  IChildPage = interface(IInterface)
    // GetActive
    function GetActive: Boolean;
    // GetHandle
    function GetHandle: Cardinal;
    // GetCaption
    function GetCaption: string;
    // SetCaption
    procedure SetCaption(ACaption: string);
//    // GetParent
//    function GetParent: TWinControl;
//    // SetParent
//    procedure SetParent(AParent: TWinControl);
    // GetCommandId
    function GetCommandId: Integer;
    // SetCommandId
    procedure SetCommandId(ACommandId: Integer);


    // GoBack (True is Response, False Is not Response)
    function GoBack: Boolean;
    // GoForward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // GoSendToBack
    function GoSendToBack: Boolean;
    // GetChildPageUI
    function GetChildPageUI: TForm;
    // GoBringToFront
    function GoBringToFront(AParams: string): Boolean;


    property Active: Boolean read GetActive;
    property Handle: Cardinal read GetHandle;
//    property Parent: TWinControl read GetParent write SetParent;
    property Caption: string read GetCaption write SetCaption;
    property CommandId: Integer read GetCommandId write SetCommandId;
  end;

implementation

end.
