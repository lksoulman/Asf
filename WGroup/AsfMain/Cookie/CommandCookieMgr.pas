unit CommandCookieMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CommandCookieMgr Interface
// Author£º      lksoulman
// Date£º        2017-11-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // CmdCookie Pointer
  PCmdCookie = ^TCmdCookie;

  // CmdCookie
  TCmdCookie = packed record
    FId: Integer;
    FParams: string;
    FPrev: PCmdCookie;
    FNext: PCmdCookie;
  end;

  // CommandCookieMgr
  ICommandCookieMgr = interface(IInterface)
    ['{D6098D77-8CB5-4DC6-8052-D823AD32E4CB}']
    // CanPrev
    function CanPrev(AHandle: Integer): Boolean;
    // CanNext
    function CanNext(AHandle: Integer): Boolean;
    // Allocate
    function Allocate(AHandle: Integer): PCmdCookie;
    // Push
    function Push(AHandle: Integer; ACookie: PCmdCookie): Boolean;
    // Prev
    function Prev(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
    // Next
    function Next(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
  end;

implementation

end.
