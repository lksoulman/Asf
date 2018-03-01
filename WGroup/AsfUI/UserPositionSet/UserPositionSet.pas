unit UserPositionSet;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� UserPositionSet Interface
// Author��      lksoulman
// Date��        2018-1-22
// Comments��
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
