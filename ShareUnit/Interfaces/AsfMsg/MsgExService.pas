unit MsgExService;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExService Inteface
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
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
