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
  AppContext,
  MsgExSubcriber,
  KeySearchFilter,
  KeySearchEngine,
  AppContextObject,
  MsgExSubcriberImpl,
  Generics.Collections;

type

  // KeySearchEngine Implementation
  TKeySearchEngineImpl = class(TAppContextObject, IKeySearchEngine)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // IsUpdate
    FIsUpdate: Boolean;
    // UpdateVersion
    FUpdateVersion: Integer;
    // MsgExSubcriber
    FMsgExSubcriber: IMsgExSubcriber;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
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
  FMsgExSubcriber := TMsgExSubcriberImpl.Create(DoUpdateKeySearchEngine);
  FMsgExSubcriber.SetActive(True);
  FAppContext.Subcriber(MSG_BASECACHE_TABLE_SECUMAIN_UPDATE, FMsgExSubcriber);
  FKeySearchObject.Start;
  FIsStart := True;
end;

destructor TKeySearchEngineImpl.Destroy;
begin
  StopService;
  FMsgExSubcriber.SetActive(False);
  FAppContext.UnSubcriber(MSG_BASECACHE_TABLE_SECUMAIN_UPDATE, FMsgExSubcriber);
  FMsgExSubcriber := nil;
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
  LIndex, LVersion: Integer;
  LSecuMainItem: PSecuMainItem;
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
          FKeySearchObject.ClearSecuMainItems;
          for LIndex := 0 to LSecuMain.GetItemCount - 1 do begin
            LSecuMainItem := LSecuMain.GetItem(LIndex);
            if LSecuMainItem <> nil then begin
              FKeySearchObject.AddSecuMainItem(LSecuMainItem);
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
