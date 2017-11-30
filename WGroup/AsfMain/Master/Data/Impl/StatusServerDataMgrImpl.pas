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
  AppContext,
  CommonLock,
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
    // ResourceStream Connect
    FResourceStreamConnect: TResourceStream;
    // ResourceStream Dis Connect
    FResourceStreamDisConnect: TResourceStream;
    // StatusServerDatas
    FStatusServerDatas: TList<PStatusServerData>;
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
  FLock := TCSLock.Create;
  FStatusServerDatas := TList<PStatusServerData>.Create;
  DoAddTestDatas;
end;

destructor TStatusServerDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FStatusServerDatas.Free;
  FLock.Free;
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
begin

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
  DoClearDatas;
  DoAddTestDatas;
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
