unit UserCacheCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserCacheCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserCache,
  Command,
  AppContext,
  CommandImpl;

type

  // UserCacheCommand Implementation
  TUserCacheCommandImpl = class(TCommandImpl)
  private
    // UserCache
    FUserCache: IUserCache;
  protected
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Execute
    procedure Execute(AParams: string); override;
  end;

implementation

uses
  UserCacheImpl;

{ TUserCacheCommandImpl }

constructor TUserCacheCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserCacheCommandImpl.Destroy;
begin
  if FUserCache <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FUserCache := nil;
  end;
  inherited;
end;

procedure TUserCacheCommandImpl.Execute(AParams: string);
var
  LFuncName, LParam: string;
begin
  if FUserCache = nil then begin
    FUserCache := TUserCacheImpl.Create(FAppContext) as IUserCache;
    FAppContext.RegisterInteface(FId, FUserCache);
  end;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'UpdateTables' then begin
      FUserCache.UpdateTables;
    end else if LFuncName = 'InitUpdateTables' then begin
      FUserCache.InitUpdateTables;
    end else if LFuncName = 'ReplaceCreateCacheTables' then begin
      FUserCache.ReplaceCreateCacheTables;
    end else if LFuncName = 'StopService' then begin
      FUserCache.StopService;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
