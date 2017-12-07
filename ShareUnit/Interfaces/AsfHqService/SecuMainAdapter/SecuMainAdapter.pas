unit SecuMainAdapter;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SecuMainAdapter Interface
// Author��      lksoulman
// Date��        2017-12-05
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain,
  QuoteMngr_TLB;

type

  // SecuMainAdapter
  ISecuMainAdapter = interface(IInterface)
    ['{BD0F9F9F-00C6-4CD3-AF20-C86C1F36D462}']
    // UpdateConceptCodes
    procedure UpdateConceptCodes;
    // AddSecuMainItem
    procedure AddSecuMainItem(ASecuMainItem: PSecuMainItem);
    // SetQuoteRealTime
    procedure SetQuoteRealTime(AQuoteRealTime: IQuoteRealTime);
    // GetInnerCodeByCodeInfoStr
    function GetInnerCodeByCodeInfoStr(ACodeInfoStr: string; AInnerCode: Int64): WordBool;
    // GetCodeInfoStrByInnerCode
    function GetCodeInfoStrByInnerCode(AInnerCode: Int64; var ACodeInfoStr: string): WordBool;
  end;

implementation

end.
