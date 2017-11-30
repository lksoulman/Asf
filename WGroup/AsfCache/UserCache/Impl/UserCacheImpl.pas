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

    // UpdateTables
    procedure UpdateTables;
    // AsyncUpdateTables
    procedure AsyncUpdateTables;
    // AsyncUpdateTable
    procedure AsyncUpdateTable(AName: string);
    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet;
    // Asynchronous query data
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
  FSQLiteAdapter.DataBaseName := (FAppContext.GetCfg as ICfg).GetUserCachePath + 'UserDB';
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/UserCfg.xml';
end;

procedure TUserCacheImpl.UpdateTables;
begin
  DoUpdateCacheTables;
end;

procedure TUserCacheImpl.AsyncUpdateTables;
begin
  DoAsyncUpdateCacheTables;
end;

procedure TUserCacheImpl.AsyncUpdateTable(AName: string);
begin
  DoAsyncUpdateCacheTable(AName);
end;
function TUserCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

procedure TUserCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
