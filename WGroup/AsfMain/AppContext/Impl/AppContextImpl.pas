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
  Log,
  Cfg,
  Login,
  GFData,
  GdiMgr,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  Behavior,
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
    // Log
    FLog: ILog;
    // Cfg
    FCfg: ICfg;
    // Main
    FMain: TForm;
    // Login
    FLogin: ILogin;
    // GdiMgr
    FGdiMgr: IGdiMgr;
    // EDCrypt
    FEDCrypt: IEDCrypt;
    // CommandMgr
    FCommandMgr: ICommandMgr;
    // WDLLFactory
    FWDLLFactory: IWDLLFactory;
    // Resource Cfg
    FResourceCfg: IResourceCfg;
    // Resource Skin
    FResourceSkin: IResourceSkin;
    // Base Cache
    FBaseCache: IBaseCache;
    // User Cache
    FUserCache: IUserCache;
    // Basic Service
    FBasicService: IBasicService;
    // Asset Service
    FAssetService: IAssetService;
    // InterfaceDic
    FInterfaceDic: TDictionary<Integer, IUnknown>;
  protected
  public
    // Constructor
    constructor Create(AMain: TForm); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IAppContext }

    // Initialize
    procedure Initialize;
    // UnInitialize
    procedure UnInitialize;
    // Exit App
    procedure ExitApp;
    // Get Config
    function GetCfg: ICfg;
    // Login
    function Login: Boolean;
    // IsLogin
    function IsLogin(AServiceType: TServiceType): Boolean;
    // GetMain
    function GetMain: TForm;
    // Get GdiMgr
    function GetGdiMgr: IGdiMgr;
    // Get EDCrypt
    function GetEDCrypt: IEDCrypt;
    // Get CommandMgr
    function GetCommandMgr: ICommandMgr;
    // Get Resource Cfg
    function GetResourceCfg: IResourceCfg;
    // Get Resource Skin
    function GetResourceSkin: IResourceSkin;
    // Load Dyn Library
    function LoadDynLibrary(AFile: WideString): Boolean;
    // Add Behavior
    function AddBehavior(ABehavior: WideString): Boolean;
    // Get Error Info
    function GetErrorInfo(AErrorCode: Integer): WideString;
    // Find Interface
    function FindInterface(ACommandId: Integer): IInterface;
    // Un Register Interface
    function UnRegisterInterface(ACommandId: Integer): Boolean;
    // Register
    function RegisterInteface(ACommandId: Integer; AInterface: IInterface): Boolean;
    // Subcriber
    procedure Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // UnSubcriber
    procedure UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // Sys Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
    // Cache Synchronous Query
    function CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet;
    // Synchronous POST
    function GFSyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
    // Asynchronous POST
    function GFAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
    // Priority Synchronous POST
    function GFPrioritySyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
    // Priority Asynchronous POST
    function GFPriorityAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
  end;

implementation

uses
  Utils,
  HqAuth,
  ProAuth,
  LogImpl,
  CfgImpl,
  Command,
  SecuMain,
  ErrorCode,
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
  FMain := AMain;
  FInterfaceDic := TDictionary<Integer, IUnknown>.Create;
end;

destructor TAppContextImpl.Destroy;
begin
  FInterfaceDic.Free;
  inherited;
end;

procedure TAppContextImpl.Initialize;
begin
  FLog := TLogImpl.Create(Self) as ILog;
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
  FWDLLFactory := nil;
  FCommandMgr := nil;
  FGdiMgr := nil;
  FCfg := nil;
  FResourceSkin := nil;
  FResourceCfg := nil;
  FEDCrypt := nil;
  FLog := nil;
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

function TAppContextImpl.GetMain: TForm;
begin
  Result := FMain;
end;

function TAppContextImpl.GetGdiMgr: IGdiMgr;
begin
  Result := FGdiMgr;
end;

function TAppContextImpl.GetEDCrypt: IEDCrypt;
begin
  Result := FEDCrypt;
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
var
  LMsgExService: IMsgExService;
begin
  LMsgExService := FindInterface(ASF_COMMAND_ID_MSGEXSERVICE) as IMsgExService;
  if LMsgExService = nil then Exit;

  LMsgExService.Subcriber(AMsgExId, ASubcriber);
  LMsgExService := nil;
end;

procedure TAppContextImpl.UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
var
  LMsgExService: IMsgExService;
begin
  LMsgExService := FindInterface(ASF_COMMAND_ID_MSGEXSERVICE) as IMsgExService;
  if LMsgExService = nil then Exit;

  LMsgExService.UnSubcriber(AMsgExId, ASubcriber);
  LMsgExService := nil;
end;

procedure TAppContextImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.HQLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.WebLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.SysLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.IndicatorLog(ALevel, ALog, AUseTime);
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
