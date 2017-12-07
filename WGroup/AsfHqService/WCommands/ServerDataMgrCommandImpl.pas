unit ServerDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ServerDataMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
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
  ServerDataMgr;

type

  // ServerDataMgrCommand Implementation
  TServerDataMgrCommandImpl = class(TCommandImpl)
  private
    // ServerDataMgr
    FServerDataMgr: IServerDataMgr;
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
  ServerDataMgrImpl;

{ TServerDataMgrCommandImpl }

constructor TServerDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TServerDataMgrCommandImpl.Destroy;
begin
  if FServerDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FServerDataMgr := nil;
  end;
  inherited;
end;

procedure TServerDataMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FServerDataMgr = nil then begin
    FServerDataMgr := TServerDataMgrImpl.Create(FAppContext) as IServerDataMgr;
    FAppContext.RegisterInteface(FId, FServerDataMgr);
  end;

  if (AParams = '')
    or (FServerDataMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin

    end;
  finally
    EndSplitParams;
  end;
end;

end.
