unit SecuMainCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SecuMainCommand Implementation
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
  SecuMain,
  AppContext,
  CommandImpl;

type

  // SecuMainCommand Implementation
  TSecuMainCommandImpl = class(TCommandImpl)
  private
    // SecuMain
    FSecuMain: ISecuMain;
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
  SecuMainImpl;

{ TSecuMainCommandImpl }

constructor TSecuMainCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSecuMainCommandImpl.Destroy;
begin
  if FSecuMain <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FSecuMain := nil;
  end;
  inherited;
end;

procedure TSecuMainCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FSecuMain = nil then begin
    FSecuMain := TSecuMainImpl.Create(FAppContext) as ISecuMain;
    FAppContext.RegisterInteface(FId, FSecuMain);
  end;

  if (AParams = '')
    or (FSecuMain = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FSecuMain.Update;
    end else if LFuncName = 'AsyncUpdate' then begin
      FSecuMain.AsyncUpdate;
    end else if LFuncName = 'StopService' then begin
      FSecuMain.StopService;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
