unit BasicService;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Basic Service Interface
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils;

type

  // Gil Basic Bind
  TGilBasicBind = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FLicense: WideString;
    FOrgSign: WideString;
    FGilUserName: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // Gil Basic Bind Pointer
  PGilBasicBind = ^TGilBasicBind;

  // Gil Basic Login
  TGilBasicLogin = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FLicense: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // Gil Basic Login Pointer
  PGilBasicLogin = ^TGilBasicLogin;

  // Basic Password set
  TGilBasicPasswordSet = packed record
    ErrorCode: Integer;
    ErrorInfo: WideString;
    GilUserName: WideString;
    OldPassword: WideString;
    NewPassword: WideString;
  end;

  // Basic Password set Pointer
  PGilBasicPasswordSet = ^TGilBasicPasswordSet;

  // Basic Service Interface
  IBasicService = interface(IInterface)
    ['{787328F5-658A-44E1-9242-E4E1F6F577EB}']
    // StopService
    procedure StopService;
    // IsLogined
    function IsLogined: Boolean;
    // GetSessionId
    function GetSessionId: WideString;
    // GilBind
    function GilBind(APBasicBind: PGilBasicBind): Boolean;
    // GilLogin
    function GilLogin(APBasicLogin: PGilBasicLogin): Boolean;
    // SetReLoginEvent
    function SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean;
    // GilPasswordSet
    function GilPasswordSet(APBasicPasswordSet: PGilBasicPasswordSet): Boolean;
    // SyncPOST
    function SyncPOST(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // AsyncPOST
    function AsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
    // PrioritySyncPOST
    function PrioritySyncPOST(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // PriorityAsyncPOST
    function PriorityAsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
  end;

implementation

end.
