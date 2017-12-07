unit UserSector;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserSector Interface
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

type

  // UserSector Interface
  IUserSector = Interface(IInterface)
    ['{339180B9-E14F-4254-B7F1-FAE221385F3D}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    //
    procedure GetCount: Integer;
    // 获取根结点板块
    function GetRootSector: ISector;
  end;

implementation

end.
