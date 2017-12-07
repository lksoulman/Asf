unit ProxyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ProxyInfo Interface
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // ProxyInfo Interface
  IProxyInfo = Interface(IInterface)
    ['{32F1B998-39F2-4411-87B3-763A1EE39A9A}']
    // Restore Default
    procedure RestoreDefault;
    // ReadLocalCacheCfg
    procedure ReadLocalCacheCfg;
    // ReadServerCacheCfg
    procedure ReadServerCacheCfg;
    // ReadCurrentAccountInfo
    procedure ReadCurrentAccountInfo;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // WriteServerCacheCfg
    procedure WriteServerCacheCfg;
    // ReadSysCfg
    procedure ReadSysCfg(AFile: TIniFile);
    // Get Proxy
    function GetProxy: PProxy;
    // Get Is Use Proxy
    function GetIsUseProxy: boolean;
    // Set Is Use Proxy
    procedure SetIsUseProxy(AIsUseProxy: Boolean);
  end;

implementation

end.
