unit Log;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Log Interface
// Author��      lksoulman
// Date��        2017-7-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LogLevel;

type

  // Log Interface
  ILog = Interface(IInterface)
    ['{7A0EBA9F-BD2C-4CB5-9090-1CC9D1229818}']
    // Force Write Disk
    procedure ForceWriteDisk; safecall;
    // Set Log Level
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Sys Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

end.

