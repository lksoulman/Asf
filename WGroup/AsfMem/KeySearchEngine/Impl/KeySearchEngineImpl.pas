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
    // UpdateLock
    FUpdateLock: TCSLock;
    // IsUpdate
    FIsUpdating: Boolean;
    // IsStopService
    FIsStopService: Boolean;
    // UpdateVersion
    FUpdateVersion: Integer;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // GetIsUpdating
    function GetIsUpdating: Boolean;
    // SetIsUpdating
    procedure SetIsUpdating(AIsUpdating: Boolean);
  protected
    // DoUpdate
    procedure DoUpdate;
    // DoUpdateKeys
    procedure DoUpdateKeys(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IKeySearchEngine }

    // Update
    procedure Update;
    // StopService
    procedure StopService;
    // IsUpdate
    function IsUpdating: Boolean;
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
  FIsUpdating := True;
  FUpdateVersion := -1;
  FLock := TCSLock.Create;
  FUpdateLock := TCSLock.Create;
  FKeySearchObject := TKeySearchObject.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoUpdateKeys);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateSecuMain);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FKeySearchObject.Start;
  FIsStopService := False;
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TKeySearchEngineImpl.Destroy;
begin
  StopService;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.Free;
  FKeySearchObject.Free;
  FUpdateLock.Free;
  FLock.Free;
  inherited;
end;

function TKeySearchEngineImpl.GetIsUpdating: Boolean;
begin
  FUpdateLock.Lock;
  try
    Result := FIsUpdating;
  finally
    FUpdateLock.UnLock;
  end;
end;

procedure TKeySearchEngineImpl.SetIsUpdating(AIsUpdating: Boolean);
begin
  FUpdateLock.Lock;
  try
    FIsUpdating := AIsUpdating;
  finally
    FUpdateLock.UnLock;
  end;
end;

procedure TKeySearchEngineImpl.DoUpdate;
var
  LSecuMain: ISecuMain;
  LSecuInfo: PSecuInfo;
  LIsUpdating: Boolean;
  LIndex, LVersion: Integer;
begin
  LSecuMain := FAppContext.FindInterface(ASF_COMMAND_ID_SECUMAIN) as ISecuMain;
  if LSecuMain = nil then Exit;

  LIsUpdating := LSecuMain.IsUpdating;

  if not LIsUpdating then begin

    LVersion := LSecuMain.GetUpdateVersion;
    if LVersion <> FUpdateVersion then begin

      SetIsUpdating(True);
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
        SetIsUpdating(False);
      end;
    end;
  end;
  LSecuMain := nil;
end;

procedure TKeySearchEngineImpl.DoUpdateKeys(AObject: TObject);
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FLock.Lock;
    try
      DoUpdate;
    finally
      FLock.UnLock;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TKeySearchEngineImpl][DoUpdateKeySearchEngine] UpdateKeySearchEngine use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TKeySearchEngineImpl.Update;
begin
  DoUpdateKeys(nil);
end;

procedure TKeySearchEngineImpl.StopService;
begin
  if not FIsStopService then begin
    FKeySearchObject.ShutDown;
    FIsStopService := True;
  end;
end;

function TKeySearchEngineImpl.IsUpdating: Boolean;
begin
  Result := GetIsUpdating;
end;

procedure TKeySearchEngineImpl.FuzzySearchKey(AKey: string);
begin
  FKeySearchObject.IsStop := False;
  FKeySearchObject.Key := AKey;
  FKeySearchObject.KeyLen := Length(AKey);
  FKeySearchObject.StartSearch;
end;

procedure TKeySearchEngineImpl.SetResultCallBack(AOnResultCallBack: TNotifyEvent);
begin
  FKeySearchObject.SetResultCallBack(AOnResultCallBack);
end;

end.
