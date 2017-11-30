unit Login;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Login Interface
// Author��      lksoulman
// Date��        2017-9-27
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ServiceType;

type

  // Login Interface
  ILogin = interface(IInterface)
    ['{FBCEB4C9-C2BC-43D6-AD62-F5CBFCBAF990}']
    // Login
    function Login: Boolean;
    // IsLogin
    function IsLogin(AServiceType: TServiceType): Boolean;
  end;

implementation

end.
