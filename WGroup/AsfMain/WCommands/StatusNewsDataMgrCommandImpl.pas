unit StatusNewsDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusNewsDataMgrCommand Implementation
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
  AppContext,
  CommandImpl,
  StatusNewsDataMgr;

type

  // StatusNewsDataMgrCommand Implementation
  TStatusNewsDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusNewsDataMgr
    FStatusNewsDataMgr: IStatusNewsDataMgr;
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
  StatusNewsDataMgrImpl;

{ TStatusNewsDataMgrCommandImpl }

constructor TStatusNewsDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusNewsDataMgrCommandImpl.Destroy;
begin
  if FStatusNewsDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusNewsDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusNewsDataMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FStatusNewsDataMgr = nil then begin
    FStatusNewsDataMgr := TStatusNewsDataMgrImpl.Create(FAppContext) as IStatusNewsDataMgr;
    FAppContext.RegisterInteface(FId, FStatusNewsDataMgr);
  end;

  if (AParams = '')
    or (FStatusNewsDataMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FStatusNewsDataMgr.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
