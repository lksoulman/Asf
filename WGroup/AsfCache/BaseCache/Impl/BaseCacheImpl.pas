unit BaseCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BaseCache Implementation
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  CacheGF,
  Windows,
  Classes,
  SysUtils,
  BaseCache,
  GFDataSet,
  CacheType,
  AppContext,
  CacheTable,
  WNDataSetInf,
  MsgExService,
  AbstractCacheImpl,
  MsgExSubcriberImpl;

type

  // BaseCache Implementation
  TBaseCacheImpl = class(TAbstractCacheImpl, IBaseCache)
  private
  protected
    // LoadCfgBefore
    procedure DoLoadCfgBefore; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IBaseCache }

    // StopService
    procedure StopService;
    // UpdateTables
    procedure UpdateTables;
    // AsyncUpdate
    procedure AsyncUpdateTables;
    // ReplaceCreateCacheTables
    procedure ReplaceCreateCacheTables;
    // UpdateTable
    procedure UpdateTable(ATable: string);
    // AsyncUpdateTable
    procedure AsyncUpdateTable(ATable: string);
    // NoExistUpdateTable
    procedure NoExistUpdateTable(ATable: string);
    // SyncQuery
    function SyncQuery(ASql: WideString): IWNDataSet;
    // UpdateVersion
    function GetUpdateVersion(ATable: string): Integer;
    // AsyncQuery
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

uses
  Cfg,
  LogLevel;

{ TBaseCacheImpl }

constructor TBaseCacheImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TBaseCacheImpl.Destroy;
begin
  inherited;
end;

procedure TBaseCacheImpl.DoLoadCfgBefore;
begin
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/BaseCfg.xml';
  FSQLiteAdapter.DataBaseName := FAppContext.GetCfg.GetCachePath + 'Base/BaseDB';

  FUpdateNotifyCacheTableDic.AddOrSetValue('ZQZB', '');
end;

procedure TBaseCacheImpl.StopService;
begin
  DoStopService;
end;

procedure TBaseCacheImpl.UpdateTables;
begin
  DoUpdateCacheTables;
end;

procedure TBaseCacheImpl.AsyncUpdateTables;
begin
  DoAsyncUpdateCacheTables;
end;

procedure TBaseCacheImpl.ReplaceCreateCacheTables;
begin
  DoReplaceCreateCacheTables;
end;

procedure TBaseCacheImpl.UpdateTable(ATable: string);
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      DoUpdateCacheTable(LTable);
      LTable.LastUpdateTime := Now;
    finally
      LTable.UnLock;
    end;
  end;
end;

procedure TBaseCacheImpl.AsyncUpdateTable(ATable: string);
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      DoAsyncUpdateCacheTable(LTable);
      LTable.LastUpdateTime := Now;
    finally
      LTable.UnLock;
    end;
  end;
end;

procedure TBaseCacheImpl.NoExistUpdateTable(ATable: string);
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      if not LTable.IsCreate then begin
        FSQLiteAdapter.ExecuteSql(LTable.CreateSql);
        LTable.IsCreate := True;
      end;
      DoUpdateCacheTable(LTable);
      LTable.LastUpdateTime := Now;
    finally
      LTable.UnLock;
    end;
  end;
end;

function TBaseCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

function TBaseCacheImpl.GetUpdateVersion(ATable: string): Integer;
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      Result := LTable.UpdateVersion;
    finally
      LTable.UnLock;
    end;
  end else begin
    Result := -1;
  end;
end;

procedure TBaseCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
