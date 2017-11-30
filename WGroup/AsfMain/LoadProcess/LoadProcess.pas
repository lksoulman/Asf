unit LoadProcess;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º LoadProcess Interface
// Author£º      lksoulman
// Date£º        2017-11-17
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // LoadProcess Interface
  ILoadProcess = interface(IInterface)
    ['{C9C307A5-BE11-4849-8727-3FEA808D1B55}']
    // Show
    function Show: Boolean;
    // Is Showing
    function IsShowing: Boolean;
    // Get Wait Event
    function GetWaitEvent: Cardinal;
    // Show
    procedure ShowInfo(AInfo: string);
  end;

implementation

end.
