unit QuoteManagerExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º QuoteManagerEx Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ComObj,
  ActiveX,
  Windows,
  Classes,
  SysUtils,
  Proxy,
  AppContext,
  CommonLock,
  ServerDataMgr,
  QuoteMngr_TLB,
  QuoteManagerEx,
  ExecutorThread,
  SecuMainAdapter,
  AppContextObject,
  QuoteCodeInfosEx,
  CommonRefCounter,
  QuoteManagerEvents,
  Generics.Collections;

type

  // QuoteManagerEx Implementation
  TQuoteManagerExImpl = class(TAppContextObject, IQuoteManagerEx)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // Active
    FActive: Boolean;
    // ComLib
    FTypeLib: ITypeLib;
    // QuoteManager
    FQuoteManager: IQuoteManager;
    // QuoteRealTime
    FQuoteRealTime: IQuoteRealTime;
    // ServerDataMgr
    FServerDataMgr: IServerDataMgr;
    // SecuMainAdapter
    FSecuMainAdapter: ISecuMainAdapter;
    // QuoteManagerEvent
    FQuoteManagerEvent: TQuoteManagerEvents;
    // ConnectStatusMonitorThread
    FConnectStatusMonitorThread: TExecutorThread;

    // TypeToProxyKindEnum
    function TypeToProxyKindEnum(AType: TProxyType): ProxyKindEnum;
  protected
    // SetProxy
    procedure DoSetProxy;
    // InitTypeLib
    procedure DoInitTypeLib;
    // InitQuoteManager
    procedure DoInitQuoteManager;
    // UnInitQuoteManager
    procedure DoUnInitQuoteManager;
    // SetServers
    procedure DoSetServers;
    // ConnectServers
    procedure DoConnectServers;
    // DisConnectServers
    procedure DoDisConnectServers;
    // UpdateConceptCodes
    procedure DoUpdateConceptCodes(Sender: TObject);
    // ConnectStatusMonitorExecute
    procedure DoConnectStatusMonitorExecute(AObject: TObject);
    // WriteLog
    procedure DoWriteLog(const ALog: WideString);
    // Progress
    procedure DoProgress(const AMsg: WideString; AMax, AValue: Integer);
    // Connected
    procedure DoConnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
    // DisConnected
    procedure DoDisconnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IQuoteManagerEx }

    // GetActive
    function GetActive: WordBool;
    // GetTypeLib
    function GetTypeLib: ITypeLib;
    // GetIsLevel2
    function GetIsLevel2(AInnerCode: Integer): WordBool;
    // ConnectMessage
    procedure ConnectMessage(AQuoteMessage: IQuoteMessage);
    // DisconnectMessage
    procedure DisconnectMessage(AQuoteMessage: IQuoteMessage);
    // QueryData
    function QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown;
    // GetCodeInfoByInnerCode
    function GetCodeInfoByInnerCode(AInnerCode: Int64; APCodeInfo: Int64): WordBool;
    // GetCodeInfosByInnerCodes
    function GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx;
    // GetCodeInfosByInnerCodesEx
    procedure GetCodeInfosByInnerCodesEx(APCodeInfos: Int64; Count: Integer; AInnerCodes: Int64);
    // Subscribe
    function Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool;
  end;

implementation

uses
  Cfg,
  Forms,
  Command,
  Manager,
  LogLevel,
  ProxyInfo,
  QuoteConst,
  QuoteStruct,
  QuoteCodeInfosExImpl;

{ TQuoteManagerExImpl }

constructor TQuoteManagerExImpl.Create(AContext: IAppContext);
begin
  inherited;
  FServerDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SERVERDATAMGR) as IServerDataMgr;
  FSecuMainAdapter := FAppContext.FindInterface(ASF_COMMAND_ID_SECUMAINADAPTER) as ISecuMainAdapter;
  FActive := False;
  FLock := TCSLock.Create;
  FConnectStatusMonitorThread := TExecutorThread.Create;
  FConnectStatusMonitorThread.ThreadMethod := DoConnectStatusMonitorExecute;
  DoInitTypeLib;
  DoInitQuoteManager;
  FConnectStatusMonitorThread.StartEx;
end;

destructor TQuoteManagerExImpl.Destroy;
begin
  FConnectStatusMonitorThread.ShutDown;
  FSecuMainAdapter := nil;
  FServerDataMgr := nil;
  DoUnInitQuoteManager;
  FTypeLib := nil;
  FLock.Free;
  inherited;
end;

function TQuoteManagerExImpl.TypeToProxyKindEnum(AType: TProxyType): ProxyKindEnum;
begin
  case AType of
    ptHttp:
      begin
        Result := ProxyKind_HTTPProxy;
      end;
    ptSocket4:
      begin
        Result := ProxyKind_SOCKS4Proxy;
      end;
    ptSocket5:
      begin
        Result := ProxyKind_SOCKS5Proxy;
      end;
  else
    begin
      Result := ProxyKind_NoProxy;
    end;
  end;
end;

function TQuoteManagerExImpl.GetActive: WordBool;
begin
  Result := FQuoteManager.Active;
end;

function TQuoteManagerExImpl.GetTypeLib: ITypeLib;
begin
  Result := FTypeLib;
end;

function TQuoteManagerExImpl.GetIsLevel2(AInnerCode: Integer): WordBool;
var
  LCodeInfo: TCodeInfo;
begin
  Result := False;
  if FServerDataMgr = nil then Exit;
  Result := FServerDataMgr.GetIsLevel2;
  if Result then begin
    if GetCodeInfoByInnerCode(Int64(@AInnerCode), Int64(@LCodeInfo)) then begin
      Result := HSMarketBourseType(LCodeInfo.m_cCodeType, STOCK_MARKET, SH_BOURSE)
        or HSMarketBourseType(LCodeInfo.m_cCodeType, STOCK_MARKET, SZ_BOURSE);
    end;
  end;
end;

procedure TQuoteManagerExImpl.ConnectMessage(AQuoteMessage: IQuoteMessage);
begin
  FQuoteManager.ConnectMessage(AQuoteMessage);
end;

procedure TQuoteManagerExImpl.DisconnectMessage(AQuoteMessage: IQuoteMessage);
begin
  FQuoteManager.DisconnectMessage(AQuoteMessage);
end;

function TQuoteManagerExImpl.GetCodeInfoByInnerCode(AInnerCode: Int64; APCodeInfo: Int64): WordBool;
var
  LTmp: Int64;
  LCodeInfoStr: string;
  LPCodeInfo: PCodeInfo;
begin
  Result := False;
  if (APCodeInfo = 0)
    or (FSecuMainAdapter = nil) then Exit;

  LTmp := 0;
  FillMemory(PCodeInfo(APCodeInfo), SizeOf(TCodeInfo), 0);
  if FSecuMainAdapter.GetCodeInfoStrByInnerCode(AInnerCode, LCodeInfoStr) then begin
    FQuoteRealTime.GetCodeInfoByKeyStr(LCodeInfoStr, LTmp);
    LPCodeInfo := PCodeInfo(LTmp);
    if LPCodeInfo <> nil then begin
      PCodeInfo(APCodeInfo)^ := LPCodeInfo^;
      Result := True;
    end;
  end;
end;

function TQuoteManagerExImpl.GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx;
var
  LTmp: Int64;
  LIndex: Integer;
  LCodeInfoStr: string;
  LPCodeInfo: PCodeInfo;
  LPInnerCode: PInteger;
  LQuoteCodeInfosExImpl: TQuoteCodeInfosExImpl;
begin
  LQuoteCodeInfosExImpl := TQuoteCodeInfosExImpl.Create(ACount);
  if FSecuMainAdapter <> nil then begin
    LPInnerCode := PInteger(AInnerCodes);
    for LIndex := 0 to ACount - 1 do begin
      if FSecuMainAdapter.GetCodeInfoStrByInnerCode(LPInnerCode^, LCodeInfoStr) then begin
        FQuoteRealTime.GetCodeInfoByKeyStr(LCodeInfoStr, LTmp);
        LPCodeInfo := PCodeInfo(LTmp);
        if LPCodeInfo <> nil then begin
          LQuoteCodeInfosExImpl.AddElement(LPInnerCode^, LPCodeInfo);
        end;
      end;
      Inc(LPInnerCode);
    end;
  end;
  Result := LQuoteCodeInfosExImpl as IQuoteCodeInfosEx;
end;

procedure TQuoteManagerExImpl.GetCodeInfosByInnerCodesEx(APCodeInfos: Int64; Count: Integer; AInnerCodes: Int64);
var
  LIndex: Integer;
  LPInnerCode: PInteger;
  LPCodeInfo: PCodeInfo;
begin
  if FSecuMainAdapter = nil then Exit;

  LPCodeInfo := PCodeInfo(APCodeInfos);
  LPInnerCode := PInteger(AInnerCodes);
  for LIndex := 0 to Count - 1 do begin
    FSecuMainAdapter.GetInnerCodeByCodeInfoStr(CodeInfoKey(LPCodeInfo), Int64(LPInnerCode));
    Inc(LPInnerCode);
    Inc(LPCodeInfo);
  end;
end;

function TQuoteManagerExImpl.QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown;
begin
  Result := FQuoteManager.QueryData(AQuoteType, APCodeInfo);
end;

function TQuoteManagerExImpl.Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool;
begin
  Result := FQuoteManager.Subscribe(AQuoteType, APCodeInfos, ACount, ACookie, AValue);
end;

procedure TQuoteManagerExImpl.DoSetProxy;
var
  LProxy: PProxy;
begin
  if FAppContext.GetCfg.GetSysCfg.GetProxyInfo.GetIsUseProxy then begin
    LProxy := FAppContext.GetCfg.GetSysCfg.GetProxyInfo.GetProxy;
    FQuoteManager.Proxy1Setting(TypeToProxyKindEnum(LProxy.FType),
                                LProxy.FIP,
                                LProxy.FPort,
                                LProxy.FUserName,
                                LProxy.FPassword);
  end;
end;

procedure TQuoteManagerExImpl.DoInitTypeLib;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LModule: HMODULE;
  LFileName: string;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    LModule := HInstance;
    SetLength(LFileName, MAX_PATH);
    GetModuleFileName(LModule, PChar(LFileName), MAX_PATH);
    try
      OLEcheck(LoadTypeLibEx(PChar(LFileName), REGKIND_NONE, FTypeLib));
    except
      on Ex: Exception do begin
        FAppContext.HQLog(llError, Format('[TQuoteManagerExImpl][DoInitTypeLib] Load data is exception, exception is %s.', [Ex.Message]));
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.HQLog(llSLOW, Format('[TQuoteManagerExImpl][DoInitTypeLib] Execute use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoInitQuoteManager;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FQuoteManager := TQuoteManager.Create;
    FQuoteManager.SetWorkPath(FAppContext.GetCfg.GetHQCachePath);
    FQuoteManagerEvent := TQuoteManagerEvents.Create(nil);
    FQuoteManagerEvent.ConnectTo(FQuoteManager);
    FQuoteManagerEvent.OnConnected := DoConnected;
    FQuoteManagerEvent.OnDisconnected := DoDisconnected;
    FQuoteManagerEvent.OnWriteLog := DoWriteLog;
    FQuoteManagerEvent.OnProgress := DoProgress;
    FQuoteManager.ClearSetting;
    FQuoteManager.ConcurrentSetting(1);
    DoSetProxy;
    DoSetServers;
    FQuoteManager.StartService;
    DoConnectServers;

    FQuoteRealTime := FQuoteManager.QueryData(QuoteType_REALTIME, 0) as IQuoteRealTime;
    FQuoteRealTime.OnUpdateConceptCodes := DoUpdateConceptCodes;
    if FSecuMainAdapter <> nil then begin
      FSecuMainAdapter.SetQuoteRealTime(FQuoteRealTime);
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.HQLog(llSLOW, Format('[TQuoteManagerExImpl][DoInitQuoteManager] Execute use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoUnInitQuoteManager;
begin
  FQuoteRealTime := nil;
  if FQuoteManagerEvent <> nil then begin
    FQuoteManagerEvent.DisConnect;
    FQuoteManagerEvent.Free;
    FQuoteManagerEvent := nil;
  end;
  if FQuoteManager <> nil then begin
    FQuoteManager.StopService;
    FQuoteManager := nil;
  end;
end;

procedure TQuoteManagerExImpl.DoSetServers;
var
  LIP: string;
  LStringList: TStringList;
  LHqServerInfo: THqServerInfo;
  I, J, LPos, LPort: Integer;
begin
  LStringList := TStringList.Create;
  try
    LStringList.Delimiter := ';';
    for I := 0 to FServerDataMgr.GetCount - 1 do begin
      LHqServerInfo := FServerDataMgr.GetServerInfo(I);
      if LHqServerInfo <> nil then begin
        LStringList.DelimitedText := LHqServerInfo.ServerUrls;
        for J := 0 to LStringList.Count - 1 do begin
          LPos := Pos(':', LStringList.Strings[J]);
          LIP := Trim(Copy(LStringList.Strings[J], 1, LPos - 1));
          LPort := StrToIntDef(Trim(Copy(LStringList.Strings[J], LPos + 1, 16)), 0);
          if (LIP <> '') and (LPort <> 0) then begin
            FQuoteManager.ServerSetting(LIP, LPort, LHqServerInfo.ServerEnum);
          end;
        end;
      end;
    end;
  finally
    LStringList.Free;
  end;
end;

procedure TQuoteManagerExImpl.DoConnectServers;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LHqServerInfo: THqServerInfo;
  LIndex, LIntervalTick: Integer;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    if FServerDataMgr <> nil then begin
      FServerDataMgr.Lock;
      try
        for LIndex := 0 to FServerDataMgr.GetCount - 1 do begin
          LHqServerInfo := FServerDataMgr.GetServerInfo(LIndex);
          if LHqServerInfo <> nil then begin
            if LHqServerInfo.ConnectStatus in [csInitConnect, csDisConnect] then begin
              LHqServerInfo.ConnectStatus := csConnecting;
              LHqServerInfo.LastHeartTick := GetTickCount;
              FQuoteManager.Connect(LHqServerInfo.ServerEnum);
            end else if LHqServerInfo.ConnectStatus = csConnecting then begin
              LIntervalTick := LHqServerInfo.LastHeartTick - GetTickCount;
              if LIntervalTick > 9000 then begin
                FQuoteManager.Connect(LHqServerInfo.ServerEnum);
                LHqServerInfo.LastHeartTick := GetTickCount;
              end;
            end;
          end;
        end;
      finally
        FServerDataMgr.UnLock;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.HQLog(llSLOW, Format('[TQuoteManagerExImpl][DoConnectServers] Execute use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoDisConnectServers;
var
  LIndex: Integer;
  LHqServerInfo: THqServerInfo;
begin
  if FServerDataMgr = nil then Exit;

  FServerDataMgr.Lock;
  try
    for LIndex := 0 to FServerDataMgr.GetCount - 1 do begin
      LHqServerInfo := FServerDataMgr.GetServerInfo(LIndex);
      if (LHqServerInfo <> nil)
        and (LHqServerInfo.ConnectStatus in [csConnecting, csConnected]) then begin
        FQuoteManager.Disconnect(LHqServerInfo.ServerEnum);
      end;
    end;
  finally
    FServerDataMgr.UnLock;
  end;
end;

procedure TQuoteManagerExImpl.DoConnectStatusMonitorExecute(AObject: TObject);
begin
  while not FConnectStatusMonitorThread.IsTerminated do begin
    if FConnectStatusMonitorThread.IsTerminated then Exit;
    case FConnectStatusMonitorThread.WaitForEx(500) of
      WAIT_OBJECT_0:
        begin

        end;
      WAIT_TIMEOUT:
        begin
          DoConnectServers;
        end;
    end;
  end;
end;

procedure TQuoteManagerExImpl.DoUpdateConceptCodes(Sender: TObject);
begin
  if FSecuMainAdapter = nil then Exit;

  FSecuMainAdapter.UpdateConceptCodes;
end;

procedure TQuoteManagerExImpl.DoWriteLog(const ALog: WideString);
begin
  FAppContext.HQLog(llWARN, Format('[TQuoteManagerExImpl][DoWriteLog] [%s] HqServer Connected.',[ALog]));
end;

procedure TQuoteManagerExImpl.DoProgress(const AMsg: WideString; AMax, AValue: Integer);
begin
  FAppContext.HQLog(llWARN, Format('[TQuoteManagerExImpl][DoProgress] [%s][%d][%d] .',[AMsg, AMax, AValue]));
end;

procedure TQuoteManagerExImpl.DoConnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
var
  LHqServerInfo: THqServerInfo;
begin
  if FServerDataMgr = nil then Exit;

  FServerDataMgr.Lock;
  try
    LHqServerInfo := FServerDataMgr.GetServerInfoByEnum(AServerType);
    if LHqServerInfo <> nil then begin
      LHqServerInfo.ConnectStatus := csConnected;
      FAppContext.HQLog(llINFO, Format('[TQuoteManagerExImpl][DoConnected] [%s][%s][%d] HqServer Connected.',[LHqServerInfo.ServerName, AIP, APort]));
    end;
  finally
    FServerDataMgr.UnLock;
  end;
end;

procedure TQuoteManagerExImpl.DoDisconnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
var
  LHqServerInfo: THqServerInfo;
begin
  if FServerDataMgr = nil then Exit;

  FServerDataMgr.Lock;
  try
    LHqServerInfo := FServerDataMgr.GetServerInfoByEnum(AServerType);
    if LHqServerInfo <> nil then begin
      LHqServerInfo.ConnectStatus := csConnected;
      FAppContext.HQLog(llINFO, Format('[TQuoteManagerExImpl][DoDisconnected] [%s][%s][%d] HqServer DisConnected.',[LHqServerInfo.ServerName, AIP, APort]));
    end;
  finally
    FServerDataMgr.UnLock;
  end;
end;

end.
