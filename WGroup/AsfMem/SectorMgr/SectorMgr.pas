unit SectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorMgr Interface
// Author£º      lksoulman
// Date£º        2017-8-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  CommonLock;

type

  // SectorMgr
  ISectorMgr = interface(IInterface)
    ['{557AD3C5-D5D0-4F65-A024-A6FA79068F2D}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // GetVersion
    function GetVersion: Integer;
    // GetRootSector
    function GetRootSector: ISector;
    // GetSector
    function GetSector(AId: Integer): ISector;
    // GetSectorElements
    function GetSectorElements(AId: Integer): string;
  end;

  // SectorMgrUpdate
  ISectorMgrUpdate = interface(IInterface)
    ['{C2086B9D-6041-4233-847B-A598F195BF84}']
    // DeleteSector
    procedure DeleteSector(AId: Integer);
  end;

implementation


end.
