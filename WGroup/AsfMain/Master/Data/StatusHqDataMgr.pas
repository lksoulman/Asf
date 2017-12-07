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
  SysUtils,
  QuoteStruct;

type

  // StatusHqData
  TStatusHqData = packed record
    FInnerCode: Integer;      // Secu InnerCode
    FSecuAbbr: string;        // Secu Abbr
    FNowPrice: Double;        // Now Price
    FPreClose: Double;        // Prev Price
    FTurnover: Double;        // Turnover
    FCodeInfo: TCodeInfo;     // CodeInfo
    FIsHasCodeInfo: Boolean;  // IsHasCodeInfo
    FColorValue: Integer;
    FTurnoverStr: string;
    FNowPriceHLStr: string;


    // Calc
    procedure Calc;
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
    // Subcribe
    procedure Subcribe;
    // GetCount
    function GetDataCount: Integer;
    // GetData
    function GetData(AIndex: Integer): PStatusHqData;
  end;

implementation

uses
  Math;

{ TStatusHqData }

procedure TStatusHqData.Calc;
var
  LPriceHL: Double;
  LNowPriceHLStr: string;
begin
  if FPreClose > 0 then begin
    if FTurnover >= 100000000 then begin
      FTurnoverStr := FormatFloat('0.ÒÚ', FTurnover / 100000000);
    end else if FTurnover >= 10000 then begin
      FTurnoverStr := FormatFloat('0.Íò', FTurnover / 10000);
    end else begin
      FTurnoverStr := FormatFloat('0.', FTurnover);
    end;


    if FNowPrice > 0 then begin
      LPriceHL := FNowPrice - FPreClose;
      LNowPriceHLStr := FormatFloat('0.000', FNowPrice);
      LNowPriceHLStr := LNowPriceHLStr + ' ' + FormatFloat('+0.000;-0.000;0.000', LPriceHL);
      LNowPriceHLStr := LNowPriceHLStr + ' ' + FormatFloat('+0.00%;-0.00%;0.00%', (LPriceHL * 100 / FPreClose) );
      FColorValue := CompareValue(LPriceHL, 0);
    end else begin
      FColorValue := 0;
      LNowPriceHLStr := '--  --  --';
    end;
    FNowPriceHLStr := LNowPriceHLStr;

  end else begin
    FColorValue := 0;
    FTurnoverStr := '--';
    FNowPriceHLStr := '--  --  --';
  end;
end;

function TStatusHqData.GetTurnover: string;
begin
  Result := FTurnoverStr;
end;

function TStatusHqData.GetNowPriceHL: string;
begin
  Result := FNowPriceHLStr;
end;

function TStatusHqData.GetColorValue: Integer;
begin

  Result := FColorValue;
end;

end.
