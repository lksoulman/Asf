unit AssetServiceCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AssetServiceCommand Implementation
// Author��      lksoulman
// Date��        2017-11-14
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  Command,
  CommandImpl,
  AssetService;

type

  // AssetServiceCommand Implementation
  TAssetServiceCommandImpl = class(TCommandImpl)
  private
    // AssetService
    FAssetService: IAssetService;
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
  AssetServiceImpl;

{ TAssetServiceCommandImpl }

constructor TAssetServiceCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TAssetServiceCommandImpl.Destroy;
begin
  if FAssetService <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FAssetService := nil;
  end;
  inherited;
end;

procedure TAssetServiceCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FAssetService = nil then begin
    FAssetService := TAssetServiceImpl.Create(FAppContext) as IAssetService;
    FAppContext.RegisterInteface(FId, FAssetService);
  end;

  if (AParams = '')
    or (FAssetService = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'StopService' then begin
      FAssetService.StopService;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
