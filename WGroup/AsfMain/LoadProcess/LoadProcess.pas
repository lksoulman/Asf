unit LoadProcess;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� LoadProcess Interface
// Author��      lksoulman
// Date��        2017-11-17
// Comments��
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
