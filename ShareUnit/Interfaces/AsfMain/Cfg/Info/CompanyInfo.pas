unit CompanyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CompanyInfo Interface
// Author£º      lksoulman
// Date£º        2017-7-20
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

  // CompanyInfo
  TCompanyInfo = packed record
    FEmail: WideString;
    FPhone: WideString;
    FWebsite: WideString;
    FCopyright: WideString;
  end;

  // CompanyInfo Pointer
  PCompanyInfo = ^TCompanyInfo;

  // CompanyInfo Interface
  ICompanyInfo = Interface(IInterface)
    ['{8266E637-A200-4CD9-A9B6-7FCD35B79318}']
    // ReadSysCfg
    procedure ReadSysCfg(AFile: TIniFile);
    // Get Company Info
    function GetCompanyInfo: PCompanyInfo;
  end;

implementation

end.
