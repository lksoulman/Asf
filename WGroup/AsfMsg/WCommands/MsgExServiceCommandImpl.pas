unit MsgExServiceCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExServiceCommand Implementation
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
  MsgExService;

type

  // MsgExServiceCommand Implementation
  TMsgExServiceCommandImpl = class(TCommandImpl)
  private
    // MsgExService
    FMsgExService: IMsgExService;
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
  MsgExServiceImpl;

{ TMsgExServiceCommandImpl }

constructor TMsgExServiceCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;
end;

destructor TMsgExServiceCommandImpl.Destroy;
begin
  if FMsgExService <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FMsgExService := nil;
  end;
  inherited;
end;

procedure TMsgExServiceCommandImpl.Execute(AParams: string);
var
  LId: Integer;
  LFuncName, LIdStr, LInfo: string;
begin
  if FMsgExService = nil then begin
    FMsgExService := TMsgExServiceImpl.Create(FAppContext) as IMsgExService;
    FAppContext.RegisterInteface(FId, FMsgExService);
  end;

  if (AParams = '')
    or (FMsgExService = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'SendMessageEx' then begin
      ParamsVal('Id', LIdStr);
      LId := StrToIntDef(LIdStr, 0);
      if LId <> 0 then begin
        ParamsVal('Info', LInfo);
        FMsgExService.SendMessageEx(LId, LInfo);
      end;
    end else if LFuncName = 'StopService' then begin
      FMsgExService.StopService;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
