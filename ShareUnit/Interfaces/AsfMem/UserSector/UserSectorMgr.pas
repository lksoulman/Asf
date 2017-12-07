unit UserSectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorMgr Interface
// Author£º      lksoulman
// Date£º        2017-12-04
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

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
    // GetRootSector
    function GetRootSector: ISector;
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetSector(AIndex: Integer): ISector;
  end;

implementation

end.
