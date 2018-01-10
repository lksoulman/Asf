unit UserSectorUpdate;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorUpdate Interface
// Author£º      lksoulman
// Date£º        2018-1-4
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserSector,
  AppContext;

type

  // UserSectorInfo
  TUserSectorInfo = packed record
    FID: string;
    FCID: Integer;
    FName: string;
    FOrderNo: Integer;
    FInnerCodes: string;
    FIndex: Integer;
    FIsUsed: Boolean;
    FIsNameChange: Boolean;
  end;

  // UserSectorInfo Pointer
  PUserSectorInfo = ^TUserSectorInfo;

  // UserSectorUpdate
  IUserSectorUpdate = interface(IInterface)
    ['{1A840024-FA9F-49E7-AF2B-49265FB003B7}']

    // GetUserSectorInfo
    function GetUserSectorInfo: PUserSectorInfo;
    // CompareAssign
    function CompareAssign(AUserSectorInfo: PUserSectorInfo): Boolean;

    property UserSectorInfo: PUserSectorInfo read GetUserSectorInfo;
  end;

implementation

end.
