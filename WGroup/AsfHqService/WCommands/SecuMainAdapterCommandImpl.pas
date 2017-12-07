unit SecuMainAdapterCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SecuMainAdapterCommand Implementation
// Author£º      lksoulman
// Date£º        2017-12-06
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
  SecuMainAdapter;

type

  // SecuMainAdapterCommand Implementation
  TSecuMainAdapterCommandImpl = class(TCommandImpl)
  private
    // SecuMainAdapter
    FSecuMainAdapter: ISecuMainAdapter;
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
  SecuMainAdapterImpl;

{ TSecuMainAdapterCommandImpl }

constructor TSecuMainAdapterCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;
end;

destructor TSecuMainAdapterCommandImpl.Destroy;
begin
  if FSecuMainAdapter <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FSecuMainAdapter := nil;
  end;
  inherited;
end;

procedure TSecuMainAdapterCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FSecuMainAdapter = nil then begin
    FSecuMainAdapter := TSecuMainAdapterImpl.Create(FAppContext) as ISecuMainAdapter;
    FAppContext.RegisterInteface(FId, FSecuMainAdapter);
  end;

  if (AParams = '')
    or (FSecuMainAdapter = nil) then Exit;

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
