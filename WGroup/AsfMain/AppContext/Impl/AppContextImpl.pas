unit AppContextImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AppContext Implementation
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Cfg,
  Login,
  GFData,
  GdiMgr,
  Chrome,
  Logger,
  Browser,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  Behavior,
  SecuMain,
  Vcl.Forms,
  CacheType,
  BaseCache,
  UserCache,
  PlugInMgr,
  CommandMgr,
  AppContext,
  WDLLFactory,
  ServiceType,
  ResourceCfg,
  CommonObject,
  ResourceSkin,
  BasicService,
  AssetService,
  WNDataSetInf,
  MsgExService,
  MsgExSubcriber,
  CommonRefCounter,
  Generics.Collections;

type

  // AppContext Implementation
  TAppContextImpl = class(TAutoInterfacedObject, IAppContext)
  private
    // Cfg
    FCfg: ICfg;
    // Login
    FLogin: ILogin;
    // Logger
    FLogger: ILogger;
    // GdiMgr
    FGdiMgr: IGdiMgr;
    // Chrome
    FChrome: IChrome;
    // EDCrypt
    FEDCrypt: IEDCrypt;
    // CommandMgr
    FCommandMgr: ICommandMgr;
    // WDLLFactory
    FWDLLFactory: IWDLLFactory;
    // ResourceCfg
    FResourceCfg: IResourceCfg;
    // ResourceSkin
    FResourceSkin: IResourceSkin;
    // BaseCache
    FBaseCache: IBaseCache;
    // UserCache
    FUserCache: IUserCache;
    // MsgExService
    FMsgExService: IMsgExService;
    // BasicService
    FBasicService: IBasicService;
    // AssetService
    FAssetService: IAssetService;
    // SecuMainQuery
    FSecuMainQuery: ISecuMainQuery;
    // InterfaceDic
    FInterfaceDic: TDictionary<Integer, IUnknown>;
  protected
  public
    // Constructor
    constructor Create(AMain: TForm); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IAppContext }

    // InitLogger
    procedure InitLogger;
    // UnInitLogger
    procedure UnInitLogger;
    // InitChrome
    procedure InitChrome;
    // UnInitChrome
    procedure UnInitChrome;
    // Initialize
    procedure Initialize;
    // UnInitialize
    procedure UnInitialize;
    // InitMsgExService
    procedure InitMsgExService;
    // UnInitMsgExService
    procedure UnInitMsgExService;
    // ExitApp
    procedure ExitApp;
    // GetCfg
    function GetCfg: ICfg;
    // Login
    function Login: Boolean;
    // IsLogin
    function IsLogin(AServiceType: TServiceType): Boolean;
    // GetGdiMgr
    function GetGdiMgr: IGdiMgr;
    // GetEDCrypt
    function GetEDCrypt: IEDCrypt;
    // CreateBrowser
    function CreateBrowser: IBrowser;
    // GetCommandMgr
    function GetCommandMgr: ICommandMgr;
    // GetResourceCfg
    function GetResourceCfg: IResourceCfg;
    // GetResourceSkin
    function GetResourceSkin: IResourceSkin;
    // LoadDynLibrary
    function LoadDynLibrary(AFile: WideString): Boolean;
    // AddBehavior
    function AddBehavior(ABehavior: WideString): Boolean;
    // GetErrorInfo
    function GetErrorInfo(AErrorCode: Integer): WideString;
    // FindInterface
    function FindInterface(ACommandId: Integer): IInterface;
    // UnRegisterInterface
    function UnRegisterInterface(ACommandId: Integer): Boolean;
    // Register
    function RegisterInteface(ACommandId: Integer; AInterface: IInterface): Boolean;
    // Subcriber
    procedure Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // UnSubcriber
    procedure UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // SendMsgEx
    procedure SendMsgEx(AMsgId: Integer; AMsgInfo: string; ADelaySecs: Cardinal = 0);
    // HQLog
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // WebLog
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // SysLog
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // IndicatorLog
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // QuerySecuInfo
    function QuerySecuInfo(AInnerCode: Integer; var ASecuInfo: PSecuInfo): Boolean;
    // QuerySecuInfos
    function QuerySecuInfos(AInnerCodes: TIntegerDynArray; var ASecuInfos: TSecuInfoDynArray): Integer;
    // CacheSyncQuery
    function CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet;
    // GFSyncQuery
    function GFSyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
    // GFAsyncQuery
    function GFAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
    // GFPrioritySyncQuery
    function GFPrioritySyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
    // GFPriorityAsyncQuery
    function GFPriorityAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
  end;

implementation

uses
  Utils,
  HqAuth,
  ProAuth,
  CfgImpl,
  Command,
  ErrorCode,
  LoggerImpl,
  ChromeImpl,
  GdiMgrImpl,
  EDCryptImpl,
  CommandMgrImpl,
  ResourceCfgImpl,
  WDLLFactoryImpl,
  ResourceSkinImpl,
  AsfMainPlugInMgrImpl;

{ TAppContextImpl }

constructor TAppContextImpl.Create(AMain: TForm);
begin
  inherited Create;
  FInterfaceDic := TDictionary<Integer, IUnknown>.Create;
end;

destructor TAppContextImpl.Destroy;
begin
  FInterfaceDic.Free;
  inherited;
end;

procedure TAppContextImpl.InitLogger;
begin
  if FLogger = nil then begin
    FLogger := TLoggerImpl.Create(Self) as ILogger;
  end;
end;

procedure TAppContextImpl.UnInitLogger;
begin
  if FLogger <> nil then begin
    FLogger := nil;
  end;
end;

procedure TAppContextImpl.InitChrome;
begin
  if FChrome = nil then begin
    FChrome := TChromeImpl.Create(Self) as IChrome;
    FChrome.InitChrome;
  end;
end;

procedure TAppContextImpl.UnInitChrome;
begin
  if FChrome <> nil then begin
    FChrome := nil;
  end;
end;

procedure TAppContextImpl.Initialize;
begin
  FEDCrypt := TEDCryptImpl.Create(Self) as IEDCrypt;
  FResourceCfg := TResourceCfgImpl.Create(Self) as IResourceCfg;
  FResourceSkin := TResourceSkinImpl.Create(Self) as IResourceSkin;
  FCfg := TCfgImpl.Create(Self) as ICfg;
  FCfg.Initialize;
  FResourceSkin.ChangeSkin;
  FGdiMgr := TGdiMgrImpl.Create(Self) as IGdiMgr;
  FCommandMgr := TCommandMgrImpl.Create(Self) as ICommandMgr;
  FWDLLFactory := TWDLLFactoryImpl.Create(Self) as IWDLLFactory;
end;

procedure TAppContextImpl.UnInitialize;
begin
  FLogin := nil;
  FBaseCache := nil;
  FUserCache := nil;
  FBasicService := nil;
  FAssetService := nil;
  FSecuMainQuery := nil;
  FWDLLFactory := nil;
  FCommandMgr := nil;
  FChrome := nil;
  FGdiMgr := nil;
  FCfg := nil;
  FResourceSkin := nil;
  FResourceCfg := nil;
  FEDCrypt := nil;
end;

procedure TAppContextImpl.InitMsgExService;
begin
  FMsgExService := FindInterface(ASF_COMMAND_ID_MSGEXSERVICE) as IMsgExService;
end;

procedure TAppContextImpl.UnInitMsgExService;
begin
  FMsgExService := nil;
end;

procedure TAppContextImpl.ExitApp;
begin
  Application.Terminate;
end;

function TAppContextImpl.GetCfg: ICfg;
begin
  Result := FCfg;
end;

function TAppContextImpl.Login: Boolean;
begin
  Result := False;
  if FLogin = nil then begin
    FLogin := FindInterface(ASF_COMMAND_ID_LOGIN) as ILogin;
  end;

  if FLogin = nil then Exit;

  Result := FLogin.Login;
  if Result then begin
    FCfg.WriteLocalCacheCfg;
  end;
end;

function TAppContextImpl.IsLogin(AServiceType: TServiceType): Boolean;
begin
  Result := False;
  if FLogin = nil then begin
    FLogin := FindInterface(ASF_COMMAND_ID_LOGIN) as ILogin;
  end;

  if FLogin = nil then Exit;

  Result := FLogin.IsLogin(AServiceType);
end;

function TAppContextImpl.GetGdiMgr: IGdiMgr;
begin
  Result := FGdiMgr;
end;

function TAppContextImpl.GetEDCrypt: IEDCrypt;
begin
  Result := FEDCrypt;
end;

function TAppContextImpl.CreateBrowser: IBrowser;
begin
  if FChrome <> nil then begin
    Result := FChrome.CreateBrowser;
  end else begin
    Result := nil;
  end;
end;

function TAppContextImpl.GetCommandMgr: ICommandMgr;
begin
  Result := FCommandMgr;
end;

function TAppContextImpl.GetResourceCfg: IResourceCfg;
begin
  Result := FResourceCfg;
end;

function TAppContextImpl.GetResourceSkin: IResourceSkin;
begin
  Result := FResourceSkin;
end;

function TAppContextImpl.LoadDynLibrary(AFile: WideString): Boolean;
begin
  Result := False;
  if FWDLLFactory = nil then Exit;
  FWDLLFactory.Load(AFile);
end;

function TAppContextImpl.AddBehavior(ABehavior: WideString): Boolean;
begin
  Result := False;
end;

function TAppContextImpl.GetErrorInfo(AErrorCode: Integer): WideString;
begin
  Result := '';
end;

function TAppContextImpl.FindInterface(ACommandId: Integer): IInterface;
begin
  if FInterfaceDic.TryGetValue(ACommandId, Result) then Exit;

  FCommandMgr.ExecuteCmd(ACommandId, '');
  FInterfaceDic.TryGetValue(ACommandId, Result);
end;

function TAppContextImpl.UnRegisterInterface(ACommandId: Integer): Boolean;
begin
  if FInterfaceDic.ContainsKey(ACommandId) then begin
    Result := True;
    FInterfaceDic.Remove(ACommandId);
  end else begin
    Result := False;
  end;
end;

function TAppContextImpl.RegisterInteface(ACommandId: Integer; AInterface: IInterface): Boolean;
var
  LInterface: IInterface;
begin
  Result := False;
  if AInterface = nil then Exit;

  if FInterfaceDic.TryGetValue(ACommandId, LInterface) then begin
    MessageBox(0, PWideChar('ÃüÁî±àÂëÖØ¸´:' + IntToStr(ACommandId)),
      '×¢²áÃüÁîµÄ½Ó¿Ú', MB_OK or MB_ICONWARNING);
    Exit;
  end else begin
    Result := True;
    FInterfaceDic.AddOrSetValue(ACommandId, AInterface);
  end;
end;

procedure TAppContextImpl.Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
begin
  if FMsgExService = nil then Exit;

  FMsgExService.Subcriber(AMsgExId, ASubcriber);
end;

procedure TAppContextImpl.UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
var
  LMsgExService: IMsgExService;
begin

  if FMsgExService <> nil then begin
    FMsgExService.UnSubcriber(AMsgExId, ASubcriber);
  end else begin
    LMsgExService := FindInterface(ASF_COMMAND_ID_MSGEXSERVICE) as IMsgExService;
    if LMsgExService = nil then Exit;
    LMsgExService.UnSubcriber(AMsgExId, ASubcriber);
    LMsgExService := nil;
  end;
end;

procedure TAppContextImpl.SendMsgEx(AMsgId: Integer; AMsgInfo: string; ADelaySecs: Cardinal = 0);
var
  LParams: string;
begin
  if FMsgExService = nil then Exit;

  if ADelaySecs > 0 then begin
    LParams := 'FuncName=SendMessageEx@Id=' + IntToStr(AMsgId) + '@Info=' + AMsgInfo;
    FCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_MSGEXSERVICE, LParams , 2);
  end else begin
    FMsgExService.SendMessageEx(AMsgId, AMsgInfo);
  end;
end;

procedure TAppContextImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if FLogger <> nil then begin
    FLogger.HQLog(ALevel, ALog, AUseTime);
  end;
end;

procedure TAppContextImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if FLogger <> nil then begin
    FLogger.WebLog(ALevel, ALog, AUseTime);
  end;
end;

procedure TAppContextImpl.SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if FLogger <> nil then begin
    FLogger.SysLog(ALevel, ALog, AUseTime);
  end;
end;

procedure TAppContextImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if FLogger <> nil then begin
    FLogger.IndicatorLog(ALevel, ALog, AUseTime);
  end;
end;

function TAppContextImpl.QuerySecuInfo(AInnerCode: Integer; var ASecuInfo: PSecuInfo): Boolean;
begin
  if FSecuMainQuery <> nil then begin
    Result := FSecuMainQuery.GetSecuInfo(AInnerCode, ASecuInfo);
  end else begin
    FSecuMainQuery := FindInterface(ASF_COMMAND_ID_SECUMAIN) as ISecuMainQuery;
    if FSecuMainQuery <> nil then begin
      Result := FSecuMainQuery.GetSecuInfo(AInnerCode, ASecuInfo);
    end else begin
      Result := False;
    end;
  end;
end;

function TAppContextImpl.QuerySecuInfos(AInnerCodes: TIntegerDynArray; var ASecuInfos: TSecuInfoDynArray): Integer;
begin
  if FSecuMainQuery <> nil then begin
    Result := FSecuMainQuery.GetSecuInfos(AInnerCodes, ASecuInfos);
  end else begin
    FSecuMainQuery := FindInterface(ASF_COMMAND_ID_SECUMAIN) as ISecuMainQuery;
    if FSecuMainQuery <> nil then begin
      Result := FSecuMainQuery.GetSecuInfos(AInnerCodes, ASecuInfos);
    end else begin
      Result := 0;
    end;
  end;
end;

function TAppContextImpl.CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet;
begin
  case ACacheType of
    ctBaseData:
      begin
        if FBaseCache <> nil then begin
          Result := FBaseCache.SyncQuery(ASql);
        end else begin
          FBaseCache := FindInterface(ASF_COMMAND_ID_BASECACHE) as IBaseCache;
          if FBaseCache <> nil then begin
            Result := FBaseCache.SyncQuery(ASql);
          end else begin
            Result := nil;
          end;
        end;
      end;
    ctUserData:
      begin
        if FUserCache <> nil then begin
          Result := FUserCache.SyncQuery(ASql);
        end else begin
          FUserCache := FindInterface(ASF_COMMAND_ID_USERCACHE) as IUserCache;
          if FUserCache <> nil then begin
            Result := FUserCache.SyncQuery(ASql);
          end else begin
            Result := nil;
          end;
        end;
      end;
  end;
end;

function TAppContextImpl.GFSyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LGFData: IGFData;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          if FBasicService <> nil then begin
            LGFData := FBasicService.SyncPost(AIndicator, AWaitTime);
          end else begin
            FBasicService := FindInterface(ASF_COMMAND_ID_BASICSERVICE) as IBasicService;
            if FBasicService <> nil then begin
              LGFData := FBasicService.SyncPost(AIndicator, AWaitTime);
            end else begin
              LGFData := nil;
            end;
          end;
        end;
      stAsset:
        begin
          if FAssetService <> nil then begin
            LGFData := FAssetService.SyncPost(AIndicator, AWaitTime);
          end else begin
            FAssetService := FindInterface(ASF_COMMAND_ID_ASSETSERVICE) as IAssetService;
            if FAssetService <> nil then begin
              LGFData := FAssetService.SyncPost(AIndicator, AWaitTime);
            end else begin
              LGFData := nil;
            end;
          end;
        end;
    end;
    Result := Utils.GFData2WNDataSet(LGFData);
    if LGFData <> nil then begin
      LGFData := nil;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFSyncQuery] FBasicService.SyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFSyncQuery] FAssetService.SyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          if FBasicService <> nil then begin
            Result := FBasicService.AsyncPOST(AIndicator, AEvent, AKey);
          end else begin
            FBasicService := FindInterface(ASF_COMMAND_ID_BASICSERVICE) as IBasicService;
            if FBasicService <> nil then begin
              Result := FBasicService.AsyncPOST(AIndicator, AEvent, AKey);
            end else begin
              Result := nil;
            end;
          end;
        end;
      stAsset:
        begin
          if FAssetService <> nil then begin
            Result := FAssetService.AsyncPOST(AIndicator, AEvent, AKey);
          end else begin
            FAssetService := FindInterface(ASF_COMMAND_ID_ASSETSERVICE) as IAssetService;
            if FAssetService <> nil then begin
              Result := FAssetService.AsyncPOST(AIndicator, AEvent, AKey);
            end else begin
              Result := nil;
            end;
          end;
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFAsyncQuery] FBasicService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFAsyncQuery] FAssetService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFPrioritySyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LGFData: IGFData;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          if FBasicService <> nil then begin
            LGFData := FBasicService.PrioritySyncPost(AIndicator, AWaitTime);
          end else begin
            FBasicService := FindInterface(ASF_COMMAND_ID_BASICSERVICE) as IBasicService;
            if FBasicService <> nil then begin
              LGFData := FBasicService.PrioritySyncPost(AIndicator, AWaitTime);
            end else begin
              LGFData := nil;
            end;
          end;
        end;
      stAsset:
        begin
          if FAssetService <> nil then begin
            LGFData := FAssetService.PrioritySyncPost(AIndicator, AWaitTime);
          end else begin
            FAssetService := FindInterface(ASF_COMMAND_ID_ASSETSERVICE) as IAssetService;
            if FAssetService <> nil then begin
              LGFData := FAssetService.PrioritySyncPost(AIndicator, AWaitTime);
            end else begin
              LGFData := nil;
            end;
          end;
        end;
    end;
    Result := Utils.GFData2WNDataSet(LGFData);
    if LGFData <> nil then begin
      LGFData := nil;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPrioritySyncQuery] FBasicService.PrioritySyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPrioritySyncQuery] FBasicService.PrioritySyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFPriorityAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          if FBasicService <> nil then begin
            Result := FBasicService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
          end else begin
            FBasicService := FindInterface(ASF_COMMAND_ID_BASICSERVICE) as IBasicService;
            if FBasicService <> nil then begin
              Result := FBasicService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
            end else begin
              Result := nil;
            end;
          end;
        end;
      stAsset:
        begin
          if FAssetService <> nil then begin
            Result := FAssetService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
          end else begin
            FAssetService := FindInterface(ASF_COMMAND_ID_ASSETSERVICE) as IAssetService;
            if FAssetService <> nil then begin
              Result := FAssetService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
            end else begin
              Result := nil;
            end;
          end;
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPriorityAsyncQuery] FBasicService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPriorityAsyncQuery] FAssetService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

end.
