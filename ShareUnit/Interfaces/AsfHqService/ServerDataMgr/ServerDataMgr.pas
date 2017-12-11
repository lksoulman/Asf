unit ServerDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ServerDataMgr Interface
// Author£º      lksoulman
// Date£º        2017-12-05
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  QuoteMngr_TLB,
  CommonRefCounter;

type

  // ServerType
  TServerType = (st_LevelI,                 // LevelI
                 st_Level2,                 // Level2
                 st_DDE,                    // Futures
                 st_HKReal,                 // HKReal
                 st_HKDelay,                // HKDelay
                 st_Futures,                // Futures
                 st_USStock);               // USStock

  // ConnectStatus
  TConnectStatus = (csInitConnect,         // InitConnect
                    csConnecting,          // Connecting
                    csDisConnect,          // csDisConnect
                    csConnected            // csConnectd
                    );

  // HqServerInfo
  THqServerInfo = class(TAutoObject)
  private
    // IsUsed
    FIsUsed: Boolean;
    // UserName
    FUserName: string;
    // Password
    FPassword: string;
    // ServerUrls
    FServerUrls: string;
    // ServerIndex
    FServerIndex: Integer;
    // LastHeartTick
    FLastHeartTick: Cardinal;
    // ServerType
    FServerType: TServerType;
    // ConnectStatus
    FConnectStatus: TConnectStatus;
  protected
    // GetServerName
    function GetServerName: string;
    // GetServerTypeEnum
    function GetServerTypeEnum: ServerTypeEnum;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    property ServerName: string read GetServerName;
    property IsUsed: Boolean read FIsUsed write FIsUsed;
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
    property ServerEnum: ServerTypeEnum read GetServerTypeEnum;
    property ServerUrls: string read FServerUrls write FServerUrls;
    property ServerIndex: Integer read FServerIndex write FServerIndex;
    property ServerType: TServerType read FServerType write FServerType;
    property LastHeartTick: Cardinal read FLastHeartTick write FLastHeartTick;
    property ConnectStatus: TConnectStatus read FConnectStatus write FConnectStatus;
  end;

  // ServerDataMgr Interface
  IServerDataMgr = interface(IInterface)
    ['{E47B3148-BE42-4F68-944B-E89D3B27FC96}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // GetCount
    function GetCount: Integer;
    // GetIsLevel2
    function GetIsLevel2: Boolean;
    // GetServerInfo
    function GetServerInfo(AIndex: Integer): THqServerInfo;
    // GetServerInfoEx
    function GetServerInfoEx(AServerType: TServerType): THqServerInfo;
    // GetServerInfoByEnum
    function GetServerInfoByEnum(AServerEnum: ServerTypeEnum): THqServerInfo;
  end;

implementation

{ THqServerInfo }

constructor THqServerInfo.Create;
begin
  inherited;
  FIsUsed := False;
  FServerIndex := 0;
  FLastHeartTick := 0;
  FConnectStatus := csInitConnect;
end;

destructor THqServerInfo.Destroy;
begin

  inherited;
end;

function THqServerInfo.GetServerName: string;
begin
  case FServerType of
    st_LevelI:
      begin
        Result := 'LevelI';
      end;
    st_Level2:
      begin
        Result := 'Level2';
      end;
    st_DDE:
      begin
        Result := 'DDE';
      end;
    st_HKReal:
      begin
        Result := 'HKReal';
      end;
    st_HKDelay:
      begin
        Result := 'HKDelay';
      end;
    st_Futures:
      begin
        Result := 'Future';
      end;
    st_USStock:
      begin
        Result := 'USStock';
      end;
  end;
end;

function THqServerInfo.GetServerTypeEnum: ServerTypeEnum;
begin
  case FServerType of
    st_LevelI:
      begin
        Result := stStockLevelI;
      end;
    st_Level2:
      begin
        Result := stStockLevelII;
      end;
    st_DDE:
      begin
        Result := stDDE;
      end;
    st_HKReal:
      begin
        Result := stStockHK;
      end;
    st_HKDelay:
      begin
        Result := stHKDelay;
      end;
    st_Futures:
      begin
        Result := stFutues;
      end;
  else
    begin
      Result := stUSStock;
    end;
  end;
end;

end.
