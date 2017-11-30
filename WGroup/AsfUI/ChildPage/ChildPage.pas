unit ChildPage;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ChildPage Interface
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // ChildPage
  IChildPage = interface
    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // Close
    procedure Close;
    // Set Activate
    procedure SetActivate;
    // Set No Activate
    procedure SetNoActivate;
    // Bring To Front
    procedure BringToFront;
    // Update Style Skin
    procedure UpdateStyleSkin;
    // Go Back (True is Response, False Is not Response)
    function GoBack: Boolean;
    // Go Forward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // Get Handle
    function GetHandle: Cardinal;
    // Get Command Id
    function GetCommandId: Integer;
  end;

implementation

end.
