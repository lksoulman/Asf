unit Sector;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Sector Interface
// Author£º      lksoulman
// Date£º        2017-8-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Sector
  ISector = Interface(IInterface)
    ['{1CD531FC-3B3F-49BC-B5D3-CD0AE1F59F71}']
    // GetDataPtr
    function GetDataPtr: Pointer;
    // GetSectorID
    function GetSectorID: WideString;
    // GetSectorName
    function GetSectorName: WideString;
    // GetChildSectors
    function GetChildSectors: WideString;
    // GetChildSectorExist
    function GetChildSectorExist: boolean;
    // GetChildSectorCount
    function GetChildSectorCount: Integer;
    // GetChildSector
    function GetChildSector(AIndex: Integer): ISector;
    // GetExistChildSectorName
    function GetExistChildSectorName(AName: WideString): boolean;
    // AddChildSectorByName
    function AddChildSectorByName(AName: WideString): ISector;
    // DeleteChildSectorByName
    procedure DeleteChildSectorByName(AName: WideString);
  end;

implementation

end.
