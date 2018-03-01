unit QuoteCodeInfosEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-27
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // CodeInfo �ӿ�
  IQuoteCodeInfosEx = Interface
    ['{A7EE98C5-CFD6-4D54-BC8E-94508567DAD4}']
    // GetCount
    function GetCount: Integer;
    // GetPCodeInfo
    function GetPCodeInfo(AIndex: Integer): Int64;
    // GetInnerCode
    function GetInnerCode(AIndex: Integer): Integer;
  end;

implementation

end.
