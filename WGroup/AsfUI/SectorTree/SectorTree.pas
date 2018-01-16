unit SectorTree;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SectorTree Interface
// Author��      lksoulman
// Date��        2018-1-11
// Comments��
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
