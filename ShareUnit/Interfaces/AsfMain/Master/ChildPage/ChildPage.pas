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
    // GetMasterHandle
    function GetMasterHandle: Cardinal;
    // GetCommandId
    function GetCommandId: Integer;
    // SetCommandId
    procedure SetCommandId(ACommandId: Integer);


    // GoBack
    function GoBack: Boolean;
    // GoForward
    function GoForward: Boolean;
    // GoSendToBack
    function GoSendToBack: Boolean;
    // GetChildPageUI
    function GetChildPageUI: TForm;
    // GoBringToFront
    function GoBringToFront(AParams: string): Boolean;

    property Active: Boolean read GetActive;
    property Handle: Cardinal read GetHandle;
    property MasterHandle: Cardinal read GetMasterHandle;
    property Caption: string read GetCaption write SetCaption;
    property CommandId: Integer read GetCommandId write SetCommandId;
  end;

implementation

end.
