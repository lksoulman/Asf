unit Behavior;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Behavior Interface
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Behavior Interface
  IBehavior = Interface(IInterface)
    ['{45E8FE12-B9DA-4370-BFBD-FB91CDC3E407}']
    // Add Behavior
    procedure Add(ABehavior: WideString); safecall;
  end;

implementation

end.
