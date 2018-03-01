unit UserPositionSet;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserPositionSet Interface
// Author£º      lksoulman
// Date£º        2018-1-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // UserPositionSet
  IUserPositionSet = interface(IInterface)
    ['{E19D6762-3FA6-449A-96D2-753A842F791F}']
    // Show
    procedure Show;
    // Hide
    procedure Hide;
  end;

implementation

end.
