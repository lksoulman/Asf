unit UserInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserInfo Interface
// Author£º      lksoulman
// Date£º        2017-7-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // Account Type
  TAccountType = (atUFX,          // UFX
                  atGIL,          // GIl
                  atPBOX);        // PBox

  // Bind Info
  TBindInfo = packed record
    FLicense: string;
    FOrgSign: string;
  end;

  // Bind Info Pointer
  PBindInfo = ^TBindInfo;

  // Account Info
  TAccountInfo = packed record
    FUserName: string;
    FPassword: string;
  end;

  // Account Info Pointer
  PAccountInfo = ^TAccountInfo;

  // UserInfo Interface
  IUserInfo = Interface(IInterface)
    ['{D1DB6423-8030-4125-9EFF-D63DF03957FC}']
    // Reset
    procedure ResetBindInfo;
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
    // GetDir
    function GetDir: WideString;
    // Get Product No
    function GetProNo: WideString;
    // Get Org No
    function GetOrgNo: WideString;
    // Get Asset No
    function GetAssetNo: WideString;
    // Get Bind Info
    function GetBindInfo: PBindInfo;
    // Get Save Password
    function GetSavePassword: Boolean;
    // Get Account Type
    function GetAccountType: TAccountType;
    // Get Gil AccountInfo
    function GetGilAccountInfo: PAccountInfo;
    // Get UFX AccountInfo
    function GetUFXAccountInfo: PAccountInfo;
    // Get PBox AccountInfo
    function GetPBoxAccountInfo: PAccountInfo;
    // Get Gil Ciper Password
    function GetGilCipherPassword: WideString;
    // Get UFX Ciper Password
    function GetUFXCipherPassword: WideString;
    // Get PBox Ciper Password
    function GetPBoxCipherPassword: WideString;
    // Get Password Expire
    function GetPasswordExpire: boolean;
    // Get Password Expire Days
    function GetPasswordExpireDays: Integer;
    // Set Password Expire Days
    procedure SetPasswordExpireDays(ADay: Integer);
    // Set Save Password
    procedure SetSavePassword(ASavePassword: boolean);
    // Set Password Info
    procedure SetPasswordInfo(APasswordInfo: WideString);
    // Set Password Expire
    procedure SetPasswordExpire(APasswordExpire: boolean);
  end;

implementation

end.
