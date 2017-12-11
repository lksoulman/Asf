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
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  LogLevel,
  CacheType,
  CommandMgr,
  ServiceType,
  ResourceCfg,
  ResourceSkin,
  BasicService,
  AssetService,
  WNDataSetInf,
  MsgExSubcriber;

type

  // AppContext Interface
  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
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

end.
