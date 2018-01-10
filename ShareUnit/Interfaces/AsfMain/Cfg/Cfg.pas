unit Cfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cfg Interface
// Author£º      lksoulman
// Date£º        2017-7-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebCfg,
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  ServerCfg,
  UserCacheCfg;

type

  // Config Interface
  ICfg = Interface(IInterface)
    ['{8E49C2C0-9AAC-4855-B3A4-9073AC5B1427}']
    // Initialize
    procedure Initialize;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // ReadServerCacheCfg
    procedure ReadServerCacheCfg;
    // GetSysCfg
    function GetSysCfg: ISysCfg;
    // GetWebCfg
    function GetWebCfg: IWebCfg;
    // GetServerCfg
    function GetServerCfg: IServerCfg;
    // GetUserCacheCfg
    function GetUserCacheCfg: IUserCacheCfg;
    // GetAppPath
    function GetAppPath: WideString;
    // GetBinPath
    function GetBinPath: WideString;
    // GetCfgPath
    function GetCfgPath: WideString;
    // GetLogPath
    function GetLogPath: WideString;
    // GetCefPath
    function GetCefPath: WideString;
    // GetSkinPath
    function GetSkinPath: WideString;
    // GetUserPath
    function GetUserPath: WideString;
    // GetUsersPath
    function GetUsersPath: WideString;
    // GetUserCfgPath
    function GetUserCfgPath: WideString;
    // GetCachePath
    function GetCachePath: WideString;
    // GetHQCachePath
    function GetHQCachePath: WideString;
    // GetCefCachePath
    function GetCefCachePath: WideString;
    // GetBaseCachePath
    function GetBaseCachePath: WideString;
    // GetUserCachePath
    function GetUserCachePath: WideString;
    // GetSysUpdatePath
    function GetSysUpdatePath: WideString;
  end;

implementation

end.
