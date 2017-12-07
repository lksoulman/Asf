unit UserSectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserSectorMgr Implementation
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
  SysUtils,
  AppContext,
  UserSector,
  SectorMgrImpl;

type

  // UserSectorMgr Implementation
  TUserSectorMgrImpl = class(TSectorMgrImpl, IUserSectorMgr)
  private
  protected
  public
    // Constructor method
    constructor Create(AContext: IAppContext); override;
    // Destructor method
    destructor Destroy; override;

    { ISectorUserMgr }

    // 读加锁
    procedure BeginRead; safecall;
    // 读解锁
    procedure EndRead; safecall;
    // 写加锁
    procedure BeginWrite; safecall;
    // 写解锁
    procedure EndWrite; safecall;
    // 获取根结点板块
    function GetRootSector: ISector; safecall;
  end;

implementation

{ TUserSectorMgrImpl }

constructor TUserSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserSectorMgrImpl.Destroy;
begin

  inherited;
end;

procedure TUserSectorMgrImpl.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TUserSectorMgrImpl.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TUserSectorMgrImpl.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TUserSectorMgrImpl.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

function TUserSectorMgrImpl.GetRootSector: ISector;
begin
  Result := FRootSector;
end;

end.
