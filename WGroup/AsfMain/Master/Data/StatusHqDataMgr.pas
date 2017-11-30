unit StatusHqDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusHqDataMgr Interface
// Author£º      lksoulman
// Date£º        2017-11-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // StatusHqData
  TStatusHqData = packed record
    FInnerCode: Integer;      // Secu InnerCode
    FSecuAbbr: string;        // Secu Abbr
    FNowPrice: Double;        // Now Price
    FPreClose: Double;        // Prev Price
    FTurnover: Double;        // Turnover

    // Get Turnover
    function GetTurnover: string;
    // Get NowPriceHL
    function GetNowPriceHL: string;
    // Get ColorValue
    function GetColorValue: Integer;
  end;

  // StatusHqData Pointer
  PStatusHqData = ^TStatusHqData;

  // StatusHqDataMgr
  IStatusHqDataMgr = interface(IInterface)
    ['{F57279ED-EC7D-4624-8A61-1507FF29072B}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PStatusHqData;
  end;

implementation

uses
  Math;

{ TStatusHqData }

function TStatusHqData.GetTurnover: string;
begin
  Result := '--';
end;

function TStatusHqData.GetNowPriceHL: string;
begin
  Result := '-- -- --';
end;

function TStatusHqData.GetColorValue: Integer;
begin
  Result := CompareValue(FNowPrice, FPreClose, 0.000001);
end;

end.
