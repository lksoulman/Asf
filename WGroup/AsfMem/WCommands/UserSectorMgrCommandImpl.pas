unit UserSectorMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorMgrCommand Implementation
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
  Command,
  AppContext,
  CommandImpl,
  UserSectorMgr;

type

  // UserSectorMgrCommand Implementation
  TUserSectorMgrCommandImpl = class(TCommandImpl)
  private
    // UserSectorMgr
    FUserSectorMgr: IUserSectorMgr;
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
  UserSectorMgrImpl;

{ TUserSectorMgrCommandImpl }

constructor TUserSectorMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserSectorMgrCommandImpl.Destroy;
begin
  if FUserSectorMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    (FUserSectorMgr as IUserSectorMgrUpdate).ClearUserSectors;
    FUserSectorMgr := nil;
  end;
  inherited;
end;

procedure TUserSectorMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FUserSectorMgr = nil then begin
    FUserSectorMgr := TUserSectorMgrImpl.Create(FAppContext) as IUserSectorMgr;
    FAppContext.RegisterInteface(FId, FUserSectorMgr);
  end;

  if (AParams = '')
    or (FUserSectorMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FUserSectorMgr.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
