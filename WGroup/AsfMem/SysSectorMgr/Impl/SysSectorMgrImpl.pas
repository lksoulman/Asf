unit SysSectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： System Sector Manager Interface implementation
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
  SysSectorMgr,
  SectorMgrImpl;

type

  // System Sector Manager Interface implementation
  TSysSectorMgrImpl = class(TSectorMgrImpl, ISysSectorMgr)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
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

{ TSysSectorMgrImpl }

constructor TSysSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TSysSectorMgrImpl.Destroy;
begin

  inherited;
end;

procedure TSysSectorMgrImpl.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TSysSectorMgrImpl.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TSysSectorMgrImpl.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TSysSectorMgrImpl.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

function TSysSectorMgrImpl.GetRootSector: ISector;
begin
  Result := FRootSector;
end;

end.
