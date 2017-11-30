unit ProAuth;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� ProAuth Interface
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

  // ProAuth Interface
  IProAuth = Interface(IInterface)
    ['{AC942CE8-E759-4DEF-8841-765FC692A7F9}']
    // Update
    procedure Update;
    // GetIsHasAuth
    function GetIsHasAuth(AFuncNo: Integer): Boolean;
  end;

implementation

end.
