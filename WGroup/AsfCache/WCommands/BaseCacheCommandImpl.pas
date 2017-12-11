unit BaseCacheCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BaseCacheCommand Implementation
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
  BaseCache,
  Command,
  AppContext,
  CommandImpl;

type

  // BaseCacheCommand Implementation
  TBaseCacheCommandImpl = class(TCommandImpl)
  private
    // BaseCache
    FBaseCache: IBaseCache;
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
  BaseCacheImpl;

{ TBaseCacheCommandImpl }

constructor TBaseCacheCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TBaseCacheCommandImpl.Destroy;
begin
  if FBaseCache <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FBaseCache := nil;
  end;
  inherited;
end;

procedure TBaseCacheCommandImpl.Execute(AParams: string);
var
  LFuncName, LParam: string;
begin
  if FBaseCache = nil then begin
    FBaseCache := TBaseCacheImpl.Create(FAppContext) as IBaseCache;
    FAppContext.RegisterInteface(FId, FBaseCache);
  end;

  if (AParams = '')
    or (FBaseCache = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'UpdateTables' then begin
      FBaseCache.UpdateTables;
    end else if LFuncName = 'AsyncUpdateTables' then begin
      FBaseCache.AsyncUpdateTables;
    end else if LFuncName = 'AsyncUpdateTable' then begin
      ParamsVal('Name', LParam);
      if LParam <> '' then begin
        FBaseCache.AsyncUpdateTable(LParam);
      end;
    end else if LFuncName = 'ReplaceCreateCacheTables' then begin
      FBaseCache.ReplaceCreateCacheTables;
    end else if LFuncName = 'StopService' then begin
      FBaseCache.StopService;
    end;

  finally
    EndSplitParams;
  end;
end;

end.
