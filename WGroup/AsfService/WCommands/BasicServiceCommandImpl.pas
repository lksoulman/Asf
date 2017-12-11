unit BasicServiceCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BasicServiceCommand Implementation
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
  AppContext,
  Command,
  CommandImpl,
  BasicService;

type

  // BasicServiceCommand Implementation
  TBasicServiceCommandImpl = class(TCommandImpl)
  private
    // BasicService
    FBasicService: IBasicService;
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
  BasicServiceImpl;

{ TBasicServiceCommandImpl }

constructor TBasicServiceCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TBasicServiceCommandImpl.Destroy;
begin
  if FBasicService <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FBasicService := nil;
  end;
  inherited;
end;

procedure TBasicServiceCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FBasicService = nil then begin
    FBasicService := TBasicServiceImpl.Create(FAppContext) as IBasicService;
    FAppContext.RegisterInteface(FId, FBasicService);
  end;

  if (AParams = '')
    or (FBasicService = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'StopService' then begin
      FBasicService.StopService;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
