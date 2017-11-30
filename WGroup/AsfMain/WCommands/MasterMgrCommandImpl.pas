unit MasterMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Command,
  SysUtils,
  MasterMgr,
  AppContext,
  CommandImpl;

type

  // MasterMgrCommand Implementation
  TMasterMgrCommandImpl = class(TCommandImpl)
  private
    // MasterMgr
    FMasterMgr: IMasterMgr;
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
  MasterMgrImpl;

{ TMasterMgrCommandImpl }

constructor TMasterMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TMasterMgrCommandImpl.Destroy;
begin
  if FMasterMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FMasterMgr := nil;
  end;
  inherited;
end;

procedure TMasterMgrCommandImpl.Execute(AParams: string);
var
  LHandle: Integer;
  LFuncName, LParam: string;
begin
  if FMasterMgr = nil then begin
    FMasterMgr := TMasterMgrImpl.Create(FAppContext) as IMasterMgr;
    FAppContext.RegisterInteface(FId, FMasterMgr);
  end;

  if (AParams = '')
    or (FMasterMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'NewMaster' then begin
      FMasterMgr.NewMaster;
    end else if LFuncName = 'DelMaster' then begin
      ParamsVal('Handle', LParam);
      LHandle := StrToIntDef(LParam, 0);
      FMasterMgr.DelMaster(LHandle);
    end;
  finally
    EndSplitParams;
  end;
end;

procedure TMasterMgrCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TMasterMgrCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TMasterMgrCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
