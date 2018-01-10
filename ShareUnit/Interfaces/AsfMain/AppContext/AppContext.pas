unit AppContext;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AppContext Interface
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
  Browser,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  SecuMain,
  LogLevel,
  CacheType,
  CommandMgr,
  ServiceType,
  ResourceCfg,
  ResourceSkin,
  BasicService,
  AssetService,
  WNDataSetInf,
  CommonObject,
  MsgExSubcriber;

type

  // AppContext Interface
  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
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
    // GetConfig
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

end.
