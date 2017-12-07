unit StatusServerDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusServerDataMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-22
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
  CommonLock,
  ServerDataMgr,
  AppContextObject,
  CommonRefCounter,
  StatusServerDataMgr,
  Generics.Collections;

type

  // StatusServerDataMgr Implementation
  TStatusServerDataMgrImpl = class(TAppContextObject, IStatusServerDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // IsConnected
    FIsConnected: Boolean;
    // ServerDataMgr
    FServerDataMgr: IServerDataMgr;
    // ResourceStream Connect
    FResourceStreamConnect: TResourceStream;
    // ResourceStream Dis Connect
    FResourceStreamDisConnect: TResourceStream;
    // StatusServerDatas
    FStatusServerDatas: TList<PStatusServerData>;
    // StatusServerDataDic
    FStatusServerDataDic: TDictionary<string, PStatusServerData>;
  protected
    // ClearDatas
    procedure DoClearDatas;
    // AddTestDatas
    procedure DoAddTestDatas;
    // Update
    procedure DoUpdate;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IStatusServerDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PStatusServerData;
    // Get IsConnected
    function GetIsConnected: Boolean;
    // Get ResourceStream
    function GetResourceStream(AIsConnected: Boolean): TResourceStream;
  end;

implementation

{ TStatusServerDataMgrImpl }

constructor TStatusServerDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FServerDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SERVERDATAMGR) as IServerDataMgr;
  FLock := TCSLock.Create;
  FStatusServerDatas := TList<PStatusServerData>.Create;
  FStatusServerDataDic := TDictionary<string, PStatusServerData>.Create;
  DoAddTestDatas;
end;

destructor TStatusServerDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FStatusServerDataDic.Free;
  FStatusServerDatas.Free;
  FLock.Free;
  FServerDataMgr := nil;
  inherited;
end;

procedure TStatusServerDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LStatusServerData: PStatusServerData;
begin
  for LIndex := 0 to FStatusServerDatas.Count - 1 do begin
    LStatusServerData := FStatusServerDatas.Items[LIndex];
    if LStatusServerData <> nil then begin
      Dispose(LStatusServerData);
    end;
  end;
  FStatusServerDatas.Clear;
end;

procedure TStatusServerDataMgrImpl.DoAddTestDatas;
begin
  FResourceStreamConnect := FAppContext.GetResourceSkin.GetStream('SKIN_APP_NETWOTK_CONNECT');
  FResourceStreamDisConnect := FAppContext.GetResourceSkin.GetStream('SKIN_APP_NETWORK_DISCONNECT');
end;

procedure TStatusServerDataMgrImpl.DoUpdate;
var
  LIndex: Integer;
  LHqServerInfo: THqServerInfo;
  LStatusServerData: PStatusServerData;
begin
  if FServerDataMgr = nil then Exit;

  FServerDataMgr.Lock;
  try
    FIsConnected := True;
    for LIndex := 0 to FServerDataMgr.GetCount - 1 do begin
      LHqServerInfo := FServerDataMgr.GetServerInfo(LIndex);
      if LHqServerInfo <> nil then begin
        if FStatusServerDataDic.TryGetValue(LHqServerInfo.ServerName, LStatusServerData) then begin
          LStatusServerData.FIsConnected := (LHqServerInfo.ConnectStatus = csConnected);
          FIsConnected := LStatusServerData.FIsConnected and FIsConnected;
        end else begin
          New(LStatusServerData);
          LStatusServerData.FServerName := LHqServerInfo.ServerName;
          LStatusServerData.FIsConnected := (LHqServerInfo.ConnectStatus = csConnected);
          FStatusServerDataDic.AddOrSetValue(LStatusServerData.FServerName, LStatusServerData);
          FIsConnected := LStatusServerData.FIsConnected and FIsConnected;
        end;
      end;
    end;
  finally
    FServerDataMgr.UnLock;
  end;
end;

procedure TStatusServerDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusServerDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusServerDataMgrImpl.Update;
begin
  FLock.Lock;
  try
    DoUpdate;
  finally
    FLock.UnLock;
  end;
end;

function TStatusServerDataMgrImpl.GetDataCount: Integer;
begin
  Result := FStatusServerDatas.Count;
end;

function TStatusServerDataMgrImpl.GetData(AIndex: Integer): PStatusServerData;
begin
  if (AIndex >= 0)
    and (AIndex < FStatusServerDatas.Count) then begin
    Result := FStatusServerDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TStatusServerDataMgrImpl.GetIsConnected: Boolean;
begin
  Result := FIsConnected;
end;

function TStatusServerDataMgrImpl.GetResourceStream(AIsConnected: Boolean): TResourceStream;
begin
  if AIsConnected then begin
    Result := FResourceStreamConnect;
  end else begin
    Result := FResourceStreamDisConnect;
  end;
end;

end.
