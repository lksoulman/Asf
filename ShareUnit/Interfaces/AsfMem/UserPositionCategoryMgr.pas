unit UserPositionCategoryMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserPositionCategoryMgr Interface
// Author£º      lksoulman
// Date£º        2018-1-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PositionCategory;

type

  // UserPositionCategoryMgr
  IUserPositionCategoryMgr = interface(IInterface)
    ['{7CB9624C-43C0-4FE3-8361-41267654CD71}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // SaveData
    procedure SaveData;
    // ClearData
    procedure ClearData;
    // Add
    procedure Add(AId: Integer; AName: string);
    // GetCount
    function GetCount: Integer;
    // GetPositionCategory
    function GetPositionCategory(AIndex: Integer): TPositionCategory;
  end;

implementation

end.
