unit UserPositionCategoryMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserPositionCategoryMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2018-1-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  CommandImpl,
  UserPositionCategoryMgr;

type

  // UserPositionCategoryMgrCommand Implementation
  TUserPositionCategoryMgrCommandImpl = class(TCommandImpl)
  private
    // UserPositionCategoryMgr
    FUserPositionCategoryMgr: IUserPositionCategoryMgr;
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
  UserPositionCategoryMgrImpl;

{ TUserPositionCategoryMgrCommandImpl }

constructor TUserPositionCategoryMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserPositionCategoryMgrCommandImpl.Destroy;
begin
  if FUserPositionCategoryMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FUserPositionCategoryMgr := nil;
  end;
  inherited;
end;

procedure TUserPositionCategoryMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FUserPositionCategoryMgr = nil then begin
    FUserPositionCategoryMgr := TUserPositionCategoryMgrImpl.Create(FAppContext) as IUserPositionCategoryMgr;
    FAppContext.RegisterInteface(FId, FUserPositionCategoryMgr);
  end;

  if (AParams = '')
    or (FUserPositionCategoryMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FUserPositionCategoryMgr.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
