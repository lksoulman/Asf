unit QuoteManagerEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º QuoteManagerEx Interface
// Author£º      lksoulman
// Date£º        2017-12-05
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ActiveX,
  Windows,
  Classes,
  SysUtils,
  QuoteMngr_TLB,
  QuoteCodeInfosEx;

type

  // QuoteManagerEx Interface
  IQuoteManagerEx = interface
    ['{74F4FFC9-A8B0-427C-8BFE-477809B2A4CB}']
    // GetActive
    function GetActive: WordBool;
    // GetTypeLib
    function GetTypeLib: ITypeLib;
    // GetIsLevel2
    function GetIsLevel2(AInnerCode: Integer): WordBool;
    // ConnectMessage
    procedure ConnectMessage(AQuoteMessage: IQuoteMessage);
    // DisconnectMessage
    procedure DisconnectMessage(AQuoteMessage: IQuoteMessage);
    // QueryData
    function QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown;
    // GetCodeInfoByInnerCode
    function GetCodeInfoByInnerCode(AInnerCode: Int64; APCodeInfo: Int64): WordBool;
    // GetCodeInfosByInnerCodes
    function GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx;
    // GetCodeInfosByInnerCodesEx
    procedure GetCodeInfosByInnerCodesEx(APCodeInfos: Int64; Count: Integer; AInnerCodes: Int64);
    // Subscribe
    function Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool;
  end;

implementation

end.
