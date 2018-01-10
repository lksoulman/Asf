unit QuoteManagerExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： QuoteManagerEx Implementation
// Author：      lksoulman
// Date：        2017-12-05
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ComObj,
  ActiveX,
  Windows,
  Classes,
  SysUtils,
  StrUtils,
  Proxy,
  SecuMain,
  BaseObject,
  AppContext,
  CommonLock,
  ServerDataMgr,
  QuoteMngr_TLB,
  QuoteManagerEx,
  ExecutorThread,
  QuoteCodeInfosEx,
  QuoteManagerEvents,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // QuoteManagerEx Implementation
  TQuoteManagerExImpl = class(TBaseInterfacedObject, IQuoteManagerEx)
  private
    // Lock
    FLock: TCSLock;
    // Active
    FActive: Boolean;
    // Version
    FVersion: Integer;
    // ComLib
    FTypeLib: ITypeLib;
    // IsStopService
    FIsStopService: Boolean;
    // QuoteManager
    FQuoteManager: IQuoteManager;
    // QuoteRealTime
    FQuoteRealTime: IQuoteRealTime;
    // ServerDataMgr
    FServerDataMgr: IServerDataMgr;
    // QuoteManagerEvent
    FQuoteManagerEvent: TQuoteManagerEvents;
    // ConnectStatusMonitorThread
    FConnectStatusMonitorThread: TExecutorThread;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // SecuMarket20Dic
    FSecuMarket20Dic: TDictionary<Integer, string>;
    // ConceptCodeInfoStrDic
    FConceptCodeInfoStrDic: TDictionary<string, string>;
    // PreConceptCodeInfoStrDic
    FPreConceptCodeInfoStrDic: TDictionary<string, string>;
    // InnerCodeToCodeInfoStrDic
    FInnerCodeToCodeInfoStrDic: TDictionary<Integer, string>;
    // CodeInfoStrToInnerCodeDic
    FCodeInfoStrToInnerCodeDic: TDictionary<string, PSecuInfo>;

    // ToProxyKindEnum
    function ToProxyKindEnum(AType: TProxyType): ProxyKindEnum;
    // ToCodeInfoStr
    function ToCodeInfoStr(ASecuMain: ISecuMain; ASecuInfo: PSecuInfo): string;
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


    // AddSecuMarket20HsCodes
    procedure DoAddSecuMarket20HsCodes;
    // UpdateSubcribeInfo
    procedure DoUpdateSubcribeInfo(AObject: TObject);
    // UpdateSecuInfo
    procedure DoUpdateCodeInfoBySecuInfo(ASecuMain: ISecuMain; ASecuInfo: PSecuInfo);

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

    // StopService
    procedure StopService;
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
  MsgEx,
  Forms,
  Command,
  Manager,
  LogLevel,
  ProxyInfo,
  QuoteConst,
  QuoteStruct,
  MsgExSubcriberImpl,
  QuoteCodeInfosExImpl;

{ TQuoteManagerExImpl }

constructor TQuoteManagerExImpl.Create(AContext: IAppContext);
begin
  inherited;
  FServerDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SERVERDATAMGR) as IServerDataMgr;
  FActive := False;
  FVersion := -1;
  FLock := TCSLock.Create;
  FSecuMarket20Dic := TDictionary<Integer, string>.Create(27);
  FConceptCodeInfoStrDic := TDictionary<string, string>.Create(1000);
  FPreConceptCodeInfoStrDic := TDictionary<string, string>.Create(1000);
  FInnerCodeToCodeInfoStrDic := TDictionary<Integer, string>.Create(210000);
  FCodeInfoStrToInnerCodeDic := TDictionary<string, PSecuInfo>.Create(210000);
  FConnectStatusMonitorThread := TExecutorThread.Create;
  FConnectStatusMonitorThread.ThreadMethod := DoConnectStatusMonitorExecute;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoUpdateSubcribeInfo);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateSecuMain);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  DoAddSecuMarket20HsCodes;
  DoInitTypeLib;
  DoInitQuoteManager;
  FConnectStatusMonitorThread.StartEx;
  FIsStopService := False;
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TQuoteManagerExImpl.Destroy;
begin
  StopService;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  FServerDataMgr := nil;
  FTypeLib := nil;
  DoUnInitQuoteManager;
  FLock.Free;
  inherited;
end;

function TQuoteManagerExImpl.ToProxyKindEnum(AType: TProxyType): ProxyKindEnum;
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

function TQuoteManagerExImpl.ToCodeInfoStr(ASecuMain: ISecuMain; ASecuInfo: PSecuInfo): string;
var
  LHSCode: string;
  LSecuMarket, LSecuCategory, LListedState: Integer;

  function GetCodeInfoStr(AHSCode: string): string;
  begin
    if (LSecuMarket in [76,77,78,79]) then begin
      Result := AHSCode;
    end else begin
      Result := Copy(AHSCode, 1, 6);
    end;
    if LSecuCategory = 110 then begin
      Result := AHSCode + '_' + SUFFIX_OPT; // 个股期权
      Exit;
    end;

    case LSecuMarket of
      83:
        begin // 上海市场
          if (LSecuCategory = 4) then begin // 指数
            if (Pos('2D', AHsCode) = 1)
              or (ASecuInfo.FSecuSuffix = 'CSI') then begin// 中证/申万指数
              Result := Result + '_' + SUFFIX_OT
            end else if (Pos('CI', AHsCode) = 1) then begin // 中信指数
              Result := Copy(AHsCode, 3, 100) + '_' + SUFFIX_ZXI
            end else begin
              Result := Result + '_' + SUFFIX_SH;
            end;
          end else begin  // 上海证券交易所
            Result := Result + '_' + SUFFIX_SH;
          end;
        end;
      90:
        Result := Result + '_' + SUFFIX_SZ; // 深圳证券交易所
      81:
        Result := Result + '_' + SUFFIX_OC; // 三板市场
      10, 13, 15, 19, 20:
        Result := Result + '_' + SUFFIX_FU; // 期货
      72:
        Result := Result + '_' + SUFFIX_HK; // 香港联交所
      76,77,78,79:
        Result := Result + '_' + SUFFIX_US; // 美股
      84:
        begin
          case LSecuCategory of
            910, 930:
              begin
                Result := Copy(Result, 3, 6) + '_' + SUFFIX_OT; // 概念板块去掉前面的28
              end;
            920:
              begin
                Result := 'DY' + Copy(AHsCode, 5, 6) + '_' + SUFFIX_OT; // 地域板块前面的2800替换为DY
              end;
          else
            Result := Result + '_' + SUFFIX_OT; // 其他指数
          end;
        end;
      89:
        Result := AHsCode + '_' + SUFFIX_IB; // 银行间债券
          0:
        case LSecuCategory of
          910, 930:
            begin
              Result := Copy(Result, 3, 6) + '_' + SUFFIX_OT; // 概念板块去掉前面的28
            end;
          920:
            begin
              Result := 'DY' + Copy(AHsCode, 5, 6) + '_' + SUFFIX_OT; // 地域板块前面的2800替换为DY
            end;
        end;
    end;
  end;
begin
  Result := '';
  LSecuMarket := ASecuInfo^.ToGilMarket;
  LListedState := ASecuInfo^.FListedState;
  LSecuCategory := ASecuInfo^.ToGilCategory;

  if ((LSecuMarket in [83,90,81,10,13,15,19,20,72,89,76,77,78,79]) and (LListedState in [1, 3]))
    or ((LSecuMarket = 84) and (LSecuCategory = 4) and (LListedState = 1))
    or ((LSecuCategory = 920) and (LListedState = 1))
    or ((LSecuCategory = 930) and (LListedState = 1))
    or ((LSecuCategory = 1) and (LSecuMarket = 9)) then begin

    if (ASecuInfo^.FSecuSuffix = 'CSI') then begin  // 中证指数
      LHSCode := '';
    end else if LSecuCategory = 110 then begin        // 个股期权
      LHSCode := ASecuInfo^.FCompanyName;
    end else begin
      if LSecuMarket = 20 then begin // 中金所
        if not FSecuMarket20Dic.TryGetValue(ASecuInfo^.FInnerCode, LHSCode) then begin
          LHSCode := '';
        end;
      end else if (LSecuMarket = 83) then begin // 根据恒生提供的转换规则，对沪深指数中以‘000’开头的指数代码做转化
        if (Pos('000', ASecuInfo^.FSecuCode) = 1)
          and (LSecuCategory = 4) then begin
          if (ASecuInfo^.FSecuCode = '000001') then begin
            LHSCode := '1A0001'
          end else if (ASecuInfo^.FSecuCode = '000002') then begin
            LHSCode := '1A0002'
          end else if (ASecuInfo^.FSecuCode = '000003') then begin
            LHSCode := '1A0003'
          end else begin
            LHSCode := ReplaceStr(ASecuInfo^.FSecuCode, '000', '1B0');
          end;
        end else begin
          LHSCode := ASecuMain.GetHsCode(ASecuInfo.FInnerCode);
        end;
      end else begin
        LHSCode := ASecuMain.GetHsCode(ASecuInfo.FInnerCode);
      end;
    end;

    if Trim(LHSCode) = '' then begin
      LHSCode := ASecuInfo^.FSecuCode;
    end;

    Result := GetCodeInfoStr(LHSCode);
  end;
end;

procedure TQuoteManagerExImpl.StopService;
begin
  if not FIsStopService then begin
    FConnectStatusMonitorThread.ShutDown;
    DoDisConnectServers;
    FQuoteManager.StartService;
    FIsStopService := True;
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
  if (APCodeInfo = 0) then Exit;

  LTmp := 0;
  FillMemory(PCodeInfo(APCodeInfo), SizeOf(TCodeInfo), 0);

  if FInnerCodeToCodeInfoStrDic.TryGetValue(PInteger(AInnerCode)^, LCodeInfoStr) then begin
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
  LPInnerCode := PInteger(AInnerCodes);
  for LIndex := 0 to ACount - 1 do begin
    if FInnerCodeToCodeInfoStrDic.TryGetValue(LPInnerCode^, LCodeInfoStr) then begin
      FQuoteRealTime.GetCodeInfoByKeyStr(LCodeInfoStr, LTmp);
      LPCodeInfo := PCodeInfo(LTmp);
      if LPCodeInfo <> nil then begin
        LQuoteCodeInfosExImpl.AddElement(LPInnerCode^, LPCodeInfo);
      end;
    end;
    Inc(LPInnerCode);
  end;
  Result := LQuoteCodeInfosExImpl as IQuoteCodeInfosEx;
end;

procedure TQuoteManagerExImpl.GetCodeInfosByInnerCodesEx(APCodeInfos: Int64; Count: Integer; AInnerCodes: Int64);
var
  LIndex: Integer;
  LPInnerCode: PInteger;
  LPCodeInfo: PCodeInfo;
  LSecuInfo: PSecuInfo;
begin
  LPCodeInfo := PCodeInfo(APCodeInfos);
  LPInnerCode := PInteger(AInnerCodes);
  for LIndex := 0 to Count - 1 do begin
    if FCodeInfoStrToInnerCodeDic.TryGetValue(CodeInfoKey(LPCodeInfo), LSecuInfo) then begin
      LPInnerCode^ := LSecuInfo^.FInnerCode;
    end else begin
      LPInnerCode^ := 0;
    end;
    Inc(LPInnerCode);
    Inc(LPCodeInfo);
  end;
end;

function TQuoteManagerExImpl.QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown;
begin
  Result := nil;
  if FConnectStatusMonitorThread.IsTerminated then Exit;

  Result := FQuoteManager.QueryData(AQuoteType, APCodeInfo);
end;

function TQuoteManagerExImpl.Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool;
begin
  Result := False;
  if FConnectStatusMonitorThread.IsTerminated then Exit;
  
  Result := FQuoteManager.Subscribe(AQuoteType, APCodeInfos, ACount, ACookie, AValue);
end;

procedure TQuoteManagerExImpl.DoSetProxy;
var
  LProxy: PProxy;
begin
  if FAppContext.GetCfg.GetSysCfg.GetProxyInfo.GetIsUseProxy then begin
    LProxy := FAppContext.GetCfg.GetSysCfg.GetProxyInfo.GetProxy;
    FQuoteManager.Proxy1Setting(ToProxyKindEnum(LProxy.FType),
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

procedure TQuoteManagerExImpl.DoAddSecuMarket20HsCodes;
begin
  FSecuMarket20Dic.AddOrSetValue(2006539, 'IC0001');
  FSecuMarket20Dic.AddOrSetValue(2006540, 'IC0002');
  FSecuMarket20Dic.AddOrSetValue(2006541, 'IC0003');
  FSecuMarket20Dic.AddOrSetValue(2006542, 'IC0004');
  FSecuMarket20Dic.AddOrSetValue(2000440, 'IF0001');
  FSecuMarket20Dic.AddOrSetValue(2000441, 'IF0002');
  FSecuMarket20Dic.AddOrSetValue(2000442, 'IF0003');
  FSecuMarket20Dic.AddOrSetValue(2000443, 'IF0004');
  FSecuMarket20Dic.AddOrSetValue(2006535, 'IH0001');
  FSecuMarket20Dic.AddOrSetValue(2006536, 'IH0002');
  FSecuMarket20Dic.AddOrSetValue(2006537, 'IH0003');
  FSecuMarket20Dic.AddOrSetValue(2006538, 'IH0004');
  FSecuMarket20Dic.AddOrSetValue(2006532, 'T0001');
  FSecuMarket20Dic.AddOrSetValue(2006533, 'T0002');
  FSecuMarket20Dic.AddOrSetValue(2006534, 'T0003');
  FSecuMarket20Dic.AddOrSetValue(2004449, 'TF0001');
  FSecuMarket20Dic.AddOrSetValue(2004450, 'TF0002');
  FSecuMarket20Dic.AddOrSetValue(2004441, 'TF0003');
end;

procedure TQuoteManagerExImpl.DoUpdateConceptCodes(Sender: TObject);
var
  LValue: Int64;
  LPCodeInfo: PCodeInfo;
  LSecuInfo: PSecuInfo;
  LCodeInfoStr, LPreCodeInfoStr: string;
  LEnum: TDictionary<string, string>.TPairEnumerator;
begin
  if FQuoteRealTime = nil then Exit;

  FLock.Lock;
  try
    LEnum := FPreConceptCodeInfoStrDic.GetEnumerator;
    while LEnum.MoveNext do begin
      if (FQuoteRealTime.GetCodeInfoByName(LEnum.Current.Key, LValue)) then begin

        LPCodeInfo := PCodeInfo(LValue);
        LCodeInfoStr := CodeInfoKey(LPCodeInfo);
        LPreCodeInfoStr := LEnum.Current.Value;
        if FCodeInfoStrToInnerCodeDic.TryGetValue(LPreCodeInfoStr, LSecuInfo) then begin
          FCodeInfoStrToInnerCodeDic.Remove(LPreCodeInfoStr);
          FConceptCodeInfoStrDic.TryGetValue(LPreCodeInfoStr, LCodeInfoStr);
          FCodeInfoStrToInnerCodeDic.AddOrSetValue(LCodeInfoStr, LSecuInfo);
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TQuoteManagerExImpl.DoUpdateSubcribeInfo(AObject: TObject);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LSecuMain: ISecuMain;
  LSecuInfo: PSecuInfo;
  LIsUpdating: Boolean;
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
      LIsUpdating := LSecuMain.IsUpdating;
    finally
      LSecuMain.UnLock;
    end;

    if not LIsUpdating then begin
      LVersion := LSecuMain.GetUpdateVersion;
      if FVersion <> LVersion then begin
        FLock.Lock;
        try
          for LIndex := 0 to LSecuMain.GetItemCount - 1 do begin
            LSecuInfo := LSecuMain.GetItem(LIndex);
            if LSecuInfo <> nil then begin
              DoUpdateCodeInfoBySecuInfo(LSecuMain, LSecuInfo);
            end;
          end;
        finally
          FLock.UnLock;
        end;
      end;
    end;

    LSecuMain := nil;

    FAppContext.SendMsgEx(Msg_AsfHqService_ReSubcribeHq, 'HqData Update ReSubcribe', 2);

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TQuoteManagerExImpl][DoUpdateSubcribeInfo] UpdateSubcribeInfo use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoUpdateCodeInfoBySecuInfo(ASecuMain: ISecuMain; ASecuInfo: PSecuInfo);
var
  LCodeInfoStr, LSecuAbbr: string;
//  LAnsiName: AnsiString;
begin
  FLock.Lock;
  try
    LCodeInfoStr := ToCodeInfoStr(ASecuMain, ASecuInfo);
    if LCodeInfoStr <> '' then begin
      if not FCodeInfoStrToInnerCodeDic.ContainsKey(LCodeInfoStr) then begin
        FInnerCodeToCodeInfoStrDic.AddOrSetValue(ASecuInfo.FInnerCode, LCodeInfoStr);
        FCodeInfoStrToInnerCodeDic.AddOrSetValue(LCodeInfoStr, ASecuInfo);

        case ASecuInfo.ToGilMarket of
          0, 84:
            begin
              case ASecuInfo.ToGilCategory of
                930:
                  begin
                    LSecuAbbr := AnsiString(ASecuInfo.FSecuAbbr);
                    LSecuAbbr := StringReplace(LSecuAbbr, '(', '（', [rfReplaceAll]);
                    LSecuAbbr := StringReplace(LSecuAbbr, ')', '）', [rfReplaceAll]);
                    LSecuAbbr := LeftStr(LSecuAbbr, 16);
                    FPreConceptCodeInfoStrDic.AddOrSetValue(LSecuAbbr, LCodeInfoStr);

//                    LAnsiName := AnsiString(ASecuInfo.FSecuAbbr);
//                    LAnsiName := StringReplace(LAnsiName, '(', '（', [rfReplaceAll]);
//                    LAnsiName := StringReplace(LAnsiName, ')', '）', [rfReplaceAll]);
//                    LAnsiName := LeftStr(LAnsiName, 16);
//                    FPreConceptCodeInfoStrDic.AddOrSetValue(LAnsiName, LCodeInfoStr);
                  end;
              end;
            end;
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
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
      FAppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR,
        Format('FuncName=UpdateConnected@ServerName=%s@IsConnected=%s',[Msg_AsfHqService_ReConnectServer, LHqServerInfo.ServerName, BoolToStr(True)]), 1);
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
      FAppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR,
        Format('FuncName=UpdateConnected@ServerName=%s@IsConnected=%s',[Msg_AsfHqService_ReConnectServer, LHqServerInfo.ServerName, BoolToStr(False)]), 1);
    end;
  finally
    FServerDataMgr.UnLock;
  end;
end;

end.
