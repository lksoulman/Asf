unit UserAssetCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserAssetCache Implementation
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
  CacheType,
  AppContext,
  WNDataSetInf,
  UserAssetCache,
  AbstractCacheImpl;

type

  // UserAssetCache Implementation
  TUserAssetCacheImpl = class(TAbstractCacheImpl, IUserAssetCache)
  private
  protected
  public
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
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

uses
  Cfg;

{ TUserAssetCacheImpl }

constructor TUserAssetCacheImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserAssetCacheImpl.Destroy;
begin

  inherited;
end;

procedure TUserAssetCacheImpl.DoLoadCfgBefore;
begin
  FSQLiteAdapter.DataBaseName := (FAppContext.GetCfg as ICfg).GetUserCachePath + 'UserDB';
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/UserCfg.xml';
end;

procedure TUserAssetCacheImpl.UpdateTables;
begin
  DoUpdateCacheTables;
end;

procedure TUserAssetCacheImpl.AsyncUpdateTables;
begin
  DoAsyncUpdateCacheTables;
end;

procedure TUserAssetCacheImpl.AsyncUpdateTable(AName: string);
begin
//  DoAsyncUpdateCacheTable(AName);
end;
function TUserAssetCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

procedure TUserAssetCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
