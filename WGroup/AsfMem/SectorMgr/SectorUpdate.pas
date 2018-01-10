unit SectorUpdate;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SectorUpdate Interface
// Author��      lksoulman
// Date��        2018-1-9
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

type

  // SectorInfo
  TSectorInfo = packed record
    FId: Integer;
    FName: string;
    FElements: string;
    FVersion: Integer;
  end;

  // SectorInfo
  PSectorInfo = ^TSectorInfo;

  // SectorUpdate
  ISectorUpdate = interface(IInterface)
    ['{CDA9F0AC-0FD8-4698-A6DC-8A455928C58B}']
    // ClearChilds
    function ClearChilds: Boolean;
    // CheckChildVersion
    function CheckChildVersion: Boolean;
    // GetSectorInfo
    function GetSectorInfo: PSectorInfo;
    // AddChild
    function AddChild(AId: Integer): ISector;
  end;

implementation

end.
