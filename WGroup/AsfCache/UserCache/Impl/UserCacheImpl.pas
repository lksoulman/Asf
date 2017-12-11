unit UserCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserCache Implementation
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserCache,
  CacheType,
  CacheTable,
  AppContext,
  WNDataSetInf,
  AbstractCacheImpl;

type

  // UserCache Implementation
  TUserCacheImpl = class(TAbstractCacheImpl, IUserCache)
  private
  protected
    // LoadCfgBefore
    procedure DoLoadCfgBefore; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserCache }

    // StopService
    procedure StopService;
    // UpdateTables
    procedure UpdateTables;
    // AsyncUpdateTables
    procedure AsyncUpdateTables;
    // ReplaceCreateCacheTables
    procedure ReplaceCreateCacheTables;
    // AsyncUpdateTable
    procedure AsyncUpdateTable(ATable: string);
    // ExecuteSql
    procedure ExecuteSql(ATable, ASql: string);
    // SyncQuery
    function SyncQuery(ASql: WideString): IWNDataSet;
    // UpdateVersion
    function GetUpdateVersion(ATable: string): Integer;
    // AsyncQuery
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

uses
  Cfg;

{ TUserCacheImpl }

constructor TUserCacheImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserCacheImpl.Destroy;
begin

  inherited;
end;

procedure TUserCacheImpl.DoLoadCfgBefore;
begin
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/UserCfg.xml';
  FSQLiteAdapter.DataBaseName := (FAppContext.GetCfg as ICfg).GetUserCachePath + 'UserDB';
end;

procedure TUserCacheImpl.StopService;
begin
  DoStopService;
end;

procedure TUserCacheImpl.UpdateTables;
begin
  DoUpdateCacheTables;
end;

procedure TUserCacheImpl.AsyncUpdateTables;
begin
  DoAsyncUpdateCacheTables;
end;

procedure TUserCacheImpl.ReplaceCreateCacheTables;
begin
  DoReplaceCreateCacheTables;
end;

procedure TUserCacheImpl.AsyncUpdateTable(ATable: string);
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      DoAsyncUpdateCacheTable(LTable);
    finally
      LTable.UnLock;
    end;
  end;
end;

procedure TUserCacheImpl.ExecuteSql(ATable, ASql: string);
var
  LTable: TCacheTable;
begin
  if ASql = '' then Exit;

  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
//      FSQLiteAdapter.ExecuteSql(ASql);
    finally
      LTable.UnLock;
    end;
  end;
end;

function TUserCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

function TUserCacheImpl.GetUpdateVersion(ATable: string): Integer;
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

procedure TUserCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
