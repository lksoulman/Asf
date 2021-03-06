unit SystemInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� System Info Interface
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  LogLevel,
  LanguageType;

type

  // System Info
  TSystemInfo = packed record
    FLogLevel: TLogLevel;                 // LogLevel
    FReLoginTime: Integer;                // ReLogin Time
    FFontRatio: WideString;               // FontRatio
    FSkinStyle: WideString;               // SkinStyle
    FMacAddress: WideString;              // Mac Address
    FHardDiskId: WideString;              // HardDiskId
    FHardDiskIdMD5: WideString;           // HardDiskId MD5
    FLanguageType: TLanguageType;         // Language Type
  end;

  // System Info Pointer
  PSystemInfo = ^TSystemInfo;

  // SysCfg Info Interface
  ISystemInfo = Interface(IInterface)
    ['{694C57FE-D4B2-416B-B33C-16CD955B4113}']
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
    // Get System Info
    function GetSystemInfo: PSystemInfo;
  end;

implementation

end.
