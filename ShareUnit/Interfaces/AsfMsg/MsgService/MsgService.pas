unit MsgService;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Service Inteface
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgType,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  MsgReceiver;

type

  // Message Service Inteface
  IMsgService = Interface(IInterface)
    ['{7FE2D77E-1015-4591-815E-960B211D9272}']
    // New Message Receiver Interface
    function NewReceiver(ACallBack: TMsgFuncCallBack): IMsgReceiver; safecall;
    // Subcribe Message Type
    procedure Subcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver); safecall;
    // Cancel Subcribe Message Type
    procedure UnSubcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver); safecall;
    // Post Message Type
    procedure PostMessageEx(AProID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

end.
