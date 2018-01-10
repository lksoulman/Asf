unit UserSectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorMgr Interface
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
  UserSector;

type

  // UserSectorMgr Interface
  IUserSectorMgr = Interface(IInterface)
    ['{32740B2F-6FDB-415C-917A-2F09F98840DF}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // NotifyMsgEx
    procedure NotifyMsgEx;
    // UserSectorsSortByOrderNo
    procedure UserSectorsSortByOrderNo;
    // DeleteUserSector
    procedure DeleteUserSector(AName: string);
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetSector(AIndex: Integer): IUserSector;
    // IsExistUserSector
    function IsExistUserSector(AName: string): Boolean;
    // AddUserSector
    function AddUserSector(AName: string): IUserSector;
    // GetSelfStockFlag
    function GetSelfStockFlag(AInnerCode: Integer): Integer;
  end;

  // UserSectorMgrUpdate Interface
  IUserSectorMgrUpdate = interface(IInterface)
    ['{27E7C506-24AC-4E22-9A93-BC72C33EF260}']
    // ClearUserSectors
    procedure ClearUserSectors;
    // UpdateAllSelfStockFlag
    procedure UpdateSelfStockFlagAll;
    // UpdateSelfStockFlag
    procedure AddSelfStockFlag(AIndex, AInnerCode: Integer);
    // DeleteSelfStockFlag
    procedure DeleteSelfStockFlag(AIndex, AInnerCode: Integer);
  end;


implementation

end.
