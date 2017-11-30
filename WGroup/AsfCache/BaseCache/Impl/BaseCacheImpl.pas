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
    // AsyncUpdateTables
    procedure AsyncUpdateTables;
    // AsyncUpdateTable
    procedure AsyncUpdateTable(AName: string);
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
  FSQLiteAdapter.DataBaseName := FAppContext.GetCfg.GetCachePath + 'Base/BaseDB';
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/BaseCfg.xml';
end;

procedure TBaseCacheImpl.UpdateTables;
begin
  DoUpdateCacheTables;
end;

procedure TBaseCacheImpl.AsyncUpdateTables;
begin
  DoAsyncUpdateCacheTables;
end;

procedure TBaseCacheImpl.AsyncUpdateTable(AName: string);
begin
  DoAsyncUpdateCacheTable(AName);
end;

function TBaseCacheImpl.Query(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

procedure TBaseCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
