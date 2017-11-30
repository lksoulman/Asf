unit SectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SectorMgr Implementation
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
  CommonLock,
  AppContextObject;

type

  // SectorMgr Implementation
  TSectorMgrImpl = class(TAppContextObject)
  private
  protected
    // 用户根结点板块
    FRootSector: ISector;
    // 读写锁
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

uses
  SectorImpl;

{ TSectorMgrImpl }

constructor TSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FRootSector := TSectorImpl.Create as ISector;
end;

destructor TSectorMgrImpl.Destroy;
begin
  FRootSector := nil;
  FReadWriteLock.Free;
  inherited;
end;

end.
