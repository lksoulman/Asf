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
  BaseObject,
  AppContext,
  CommonLock,
  ServerDataMgr,
  StatusServerDataMgr,
  Generics.Collections;

type

  // StatusServerDataMgr Implementation
  TStatusServerDataMgrImpl = class(TBaseInterfacedObject, IStatusServerDataMgr)
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
  protected
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
    // UpdateConnected
    procedure UpdateConnected(AServerName: string; AIsConnected: Boolean);
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
  DoAddTestDatas;
end;

destructor TStatusServerDataMgrImpl.Destroy;
begin
  FLock.Free;
  FServerDataMgr := nil;
  inherited;
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
begin
  if FServerDataMgr = nil then Exit;

  FServerDataMgr.Lock;
  try
    FIsConnected := True;
    for LIndex := 0 to FServerDataMgr.GetCount - 1 do begin
      LHqServerInfo := FServerDataMgr.GetServerInfo(LIndex);
      if LHqServerInfo <> nil then begin
        FIsConnected := (LHqServerInfo.ConnectStatus = csConnected) and FIsConnected;
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

procedure TStatusServerDataMgrImpl.UpdateConnected(AServerName: string; AIsConnected: Boolean);
begin
  if FIsConnected then begin
    DoUpdate;
  end else begin
    FIsConnected := False;
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
