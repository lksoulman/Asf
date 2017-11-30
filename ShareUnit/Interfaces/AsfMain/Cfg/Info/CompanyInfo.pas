unit CompanyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Company Info Interface
// Author��      lksoulman
// Date��        2017-7-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // Company Info
  TCompanyInfo = packed record
    FEmail: WideString;
    FPhone: WideString;
    FWebsite: WideString;
    FCopyright: WideString;
  end;

  // Company Info Pointer
  PCompanyInfo = ^TCompanyInfo;

  // Company Info Interface
  ICompanyInfo = Interface(IInterface)
    ['{8266E637-A200-4CD9-A9B6-7FCD35B79318}']
    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Load Cache
    procedure LoadCache;
    // Read
    procedure Read(AFile: TIniFile);
    // Get Company Info
    function GetCompanyInfo: PCompanyInfo;
  end;

implementation

end.
