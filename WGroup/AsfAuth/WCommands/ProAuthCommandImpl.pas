unit ProAuthCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ProAuthCommand Implementation
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
  ProAuth,
  Command,
  AppContext,
  CommandImpl;

type

  // ProAuthCommand Implementation
  TProAuthCommandImpl = class(TCommandImpl)
  private
    // ProAuth
    FProAuth: IProAuth;
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
  ProAuthImpl;

{ TProAuthCommandImpl }

constructor TProAuthCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TProAuthCommandImpl.Destroy;
begin
  if FProAuth <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FProAuth := nil;
  end;
  inherited;
end;

procedure TProAuthCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FProAuth = nil then begin
    FProAuth := TProAuthImpl.Create(FAppContext) as IProAuth;
    FAppContext.RegisterInteface(FId, FProAuth);
  end;

  if (AParams = '')
    or (FProAuth = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FProAuth.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

procedure TProAuthCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TProAuthCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TProAuthCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
