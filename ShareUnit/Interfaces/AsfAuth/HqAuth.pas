unit HqAuth;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� HqAuth Interface
// Author��      lksoulman
// Date��        2017-8-30
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // HqAuth Interface
  IHqAuth = Interface(IInterface)
    ['{4BBA61C3-8BEB-41EB-B989-586239664BE4}']
    // Update
    procedure Update;
    // GetIsHasHKReal
    function GetIsHasHKReal: Boolean;
    // GetIsHasLevel2
    function GetIsHasLevel2: Boolean;
    // GetLevel2UserName
    function GetLevel2UserName: WideString;
    // GetLevel2Password
    function GetLevel2Password: WideString;
  end;

implementation

end.
