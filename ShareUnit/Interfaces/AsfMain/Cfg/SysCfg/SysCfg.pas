unit SysCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� System Cfg Interface
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  ProxyInfo,
  SystemInfo,
  CompanyInfo;

type

  // System Cfg Interface
  ISysCfg = interface(IInterface)
    ['{8C9E0C7A-9BD2-4592-A38C-E9E4F6ABAD97}']
    // ReadLocalCacheCfg
    procedure ReadLocalCacheCfg;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // WriteUserCacheSysCfg
    procedure ReadServerCacheCfg;
    // ReadCurrentAccountInfo
    procedure ReadCurrentAccountInfo;
    // GetUserInfo
    function GetUserInfo: IUserInfo;
    // GetProxyInfo
    function GetProxyInfo: IProxyInfo;
    // GetSyscfgInfo
    function GetSystemInfo: ISystemInfo;
    // GetCompanyInfo
    function GetCompanyInfo: ICompanyInfo;
  end;

implementation

end.
