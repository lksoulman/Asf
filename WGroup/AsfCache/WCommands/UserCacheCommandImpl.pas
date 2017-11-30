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
    // Execute
    procedure ExecuteEx(AParams: array of string); override;
    // Execute
    procedure ExecuteAsync(AParams: string); override;
    // Execute
    procedure ExecuteAsyncEx(AParams: array of string); override;
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
    end else if LFuncName = 'AsyncUpdateTables' then begin
      FUserCache.AsyncUpdateTables;
    end else if LFuncName = 'AsyncUpdateTable' then begin
      ParamsVal('Name', LParam);
      if LParam <> '' then begin
        FUserCache.AsyncUpdateTable(LParam);
      end;
    end;
  finally
    EndSplitParams;
  end;
end;

procedure TUserCacheCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TUserCacheCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TUserCacheCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
