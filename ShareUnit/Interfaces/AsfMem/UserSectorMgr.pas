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
    // UpdateNotify
    procedure UpdateNotify;
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetUserSector(AIndex: Integer): TUserSector;
    // Add
    function Add(AName: string): TUserSector;
    // Delete
    function Delete(AName: string): Boolean;
    // GetUserSectorByName
    function GetUserSectorByName(AName: string): TUserSector;
    // GetUserSectorStockFlag
    function GetUserSectorStockFlag(AInnerCode: Integer): Integer;
    // GetUserPositionStockFlag
    function GetUserPositionStockFlag(AInnerCode: Integer): Integer;
  end;

  // UserSectorMgrUpdate Interface
  IUserSectorMgrUpdate = interface(IInterface)
    ['{27E7C506-24AC-4E22-9A93-BC72C33EF260}']
    // RemoveDic
    procedure RemoveDic(AName: string);
    // AddDicUserSector
    procedure AddDic(AUserSector: TUserSector);
  end;


implementation

end.
