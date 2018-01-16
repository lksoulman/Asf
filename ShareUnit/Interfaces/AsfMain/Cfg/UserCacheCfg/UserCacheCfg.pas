unit UserCacheCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserCacheCfg Interface
// Author£º      lksoulman
// Date£º        2017-7-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  CACHECFG_KEY_UserAttention = 'UserAttention';


type

  // CurrentAccountInfo
  TCurrentAccountInfo = packed record
    FUserName: string;
    FUserSession: string;
  end;

  // CurrentAccountInfo Pointer
  PCurrentAccountInfo = ^TCurrentAccountInfo;

  // UserCacheCfg Interface
  IUserCacheCfg = Interface(IInterface)
    ['{865B342F-C51B-40FA-82D0-3DEF0D058E73}']
    // LoadLocalCfg
    procedure LoadLocalCfg;
    // LoadServerCfg
    procedure LoadServerCfg;
    // LoadCurrentAccountInfo
    procedure LoadCurrentAccountInfo;
    // SaveCurrentAccountInfo
    procedure SaveCurrentAccountInfo;
    // SaveLocal
    procedure SaveLocal(AKey, AValue: WideString);
    // SaveServer
    procedure SaveServer(AKey, AValue, AName: WideString);
    // GetCurrentAcountInfo
    function GetCurrentAcountInfo: PCurrentAccountInfo;
    // GetLocalValue
    function GetLocalValue(AKey: WideString): WideString;
    // GetServerValue
    function GetServerValue(AKey: WideString): WideString;
  end;

implementation

end.
