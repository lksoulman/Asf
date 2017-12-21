unit KeySearchEngineImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeySearchEngine Implementation
// Author£º      lksoulman
// Date£º        2017-11-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  Command,
  SecuMain,
  CommonLock,
  BaseObject,
  AppContext,
  MsgExSubcriber,
  KeySearchFilter,
  KeySearchEngine,
  MsgExSubcriberImpl,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // KeySearchEngine Implementation
  TKeySearchEngineImpl = class(TBaseInterfacedObject, IKeySearchEngine)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // IsUpdate
    FIsUpdate: Boolean;
    // UpdateVersion
    FUpdateVersion: Integer;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
  protected
    // SetIsUpdate
    procedure SetIsUpdate(AIsUpdate: Boolean);
    // UpdateKeySearchEngine
    procedure DoUpdateKeySearchEngine(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IKeySearchEngine }

    // StopService
    procedure StopService;
    // IsUpdate
    function IsUpdate: Boolean;
    // FuzzySearchKey
    procedure FuzzySearchKey(AKey: string);
    // SetResultCallBack
    procedure SetResultCallBack(AOnResultCallBack: TNotifyEvent);
  end;

implementation

uses
  LogLevel;

{ TKeySearchEngineImpl }

constructor TKeySearchEngineImpl.Create(AContext: IAppContext);
begin
  inherited;
  FIsUpdate := True;
  FUpdateVersion := -1;
  FLock := TCSLock.Create;
  FKeySearchObject := TKeySearchObject.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoUpdateKeySearchEngine);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateSecuMain);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FKeySearchObject.Start;
  FIsStart := True;
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TKeySearchEngineImpl.Destroy;
begin
  StopService;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.Free;
  FKeySearchObject.Free;
  FLock.Free;
  inherited;
end;

procedure TKeySearchEngineImpl.SetIsUpdate(AIsUpdate: Boolean);
begin
  FLock.Lock;
  try
    if AIsUpdate <> FIsUpdate then begin

    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TKeySearchEngineImpl.DoUpdateKeySearchEngine(AObject: TObject);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LSecuMain: ISecuMain;
  LSecuInfo: PSecuInfo;
  LIndex, LVersion: Integer;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    LSecuMain := FAppContext.FindInterface(ASF_COMMAND_ID_SECUMAIN) as ISecuMain;
    if LSecuMain = nil then Exit;

    LSecuMain.Lock;
    try
      LVersion := LSecuMain.GetUpdateVersion;
      if LVersion <> FUpdateVersion then begin
        SetIsUpdate(True);
        try
          FKeySearchObject.ClearSecuInfos;
          for LIndex := 0 to LSecuMain.GetItemCount - 1 do begin
            LSecuInfo := LSecuMain.GetItem(LIndex);
            if LSecuInfo <> nil then begin
              FKeySearchObject.AddSecuInfo(LSecuInfo);
            end;
          end;
          FUpdateVersion := LVersion;
        finally
          SetIsUpdate(False);
        end;
      end;
    finally
      LSecuMain.UnLock;
    end;
    LSecuMain := nil;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TKeySearchEngineImpl][DoUpdateKeySearchEngine] UpdateKeySearchEngine use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TKeySearchEngineImpl.StopService;
begin
  if FIsStart then begin
    FKeySearchObject.ShutDown;
    FIsStart := False;
  end;
end;

function TKeySearchEngineImpl.IsUpdate: Boolean;
begin
  FLock.Lock;
  try
    Result := FIsUpdate;
  finally
    FLock.UnLock;
  end;
end;

procedure TKeySearchEngineImpl.FuzzySearchKey(AKey: string);
begin
  FKeySearchObject.IsStop := False;
  FKeySearchObject.Key := AKey;
  FKeySearchObject.KeyLen := Length(AKey);
end;

procedure TKeySearchEngineImpl.SetResultCallBack(AOnResultCallBack: TNotifyEvent);
begin
  FKeySearchObject.SetResultCallBack(AOnResultCallBack);
end;

end.
