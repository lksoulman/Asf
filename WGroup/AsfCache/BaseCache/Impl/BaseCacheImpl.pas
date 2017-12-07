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
  AbstractCacheImpl;

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
    // Query
    function Query(ASql: WideString): IWNDataSet;
    // Async Query
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

function TBaseCacheImpl.Query(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

procedure TBaseCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
