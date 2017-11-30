unit HqAuthCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º HqAuthCommand Implementation
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
  HqAuth,
  Command,
  AppContext,
  CommandImpl;

type

  // HqAuthCommand Implementation
  THqAuthCommandImpl = class(TCommandImpl)
  private
    // HqAuth
    FHqAuth: IHqAuth;
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
  HqAuthImpl;

{ THqAuthCommandImpl }

constructor THqAuthCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor THqAuthCommandImpl.Destroy;
begin
  if FHqAuth <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FHqAuth := nil;
  end;
  inherited;
end;

procedure THqAuthCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FHqAuth = nil then begin
    FHqAuth := THqAuthImpl.Create(FAppContext) as IHqAuth;
    FAppContext.RegisterInteface(FId, FHqAuth);
  end;

  if (AParams = '')
    or (FHqAuth = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FHqAuth.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

procedure THqAuthCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure THqAuthCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure THqAuthCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
