unit SectorTree;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorTree Interface
// Author£º      lksoulman
// Date£º        2018-1-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // SectorTree
  ISectorTree = interface(IInterface)
    ['{C79C5989-E51B-4E92-B3A3-77603D4C0614}']
    // Show
    procedure Show;
    // Hide
    procedure Hide;
  end;

implementation

end.
