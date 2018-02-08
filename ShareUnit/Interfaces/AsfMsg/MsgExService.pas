unit MsgExService;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� MsgExService Inteface
// Author��      lksoulman
// Date��        2017-12-08
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgExSubcriber;

type

  // MsgExService Inteface
  IMsgExService = Interface(IInterface)
    ['{7FE2D77E-1015-4591-815E-960B211D9272}']
    // StopService
    procedure StopService;
    // SendMessageEx
    procedure SendMessageEx(AID: Integer; AInfo: string);
    // Subcriber
    procedure Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // UnSubcriber
    procedure UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
  end;

implementation

end.
