unit StatusServerDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusServerDataMgr Interface
// Author£º      lksoulman
// Date£º        2017-11-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ServerDataMgr;

type

  // PStatusServerDataMgr
  IStatusServerDataMgr = interface(IInterface)
    ['{1C0F6DD6-0BC2-49A1-A500-19E35DD75E1B}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // UpdateConnected
    procedure UpdateConnected(AServerName: string; AIsConnected: Boolean);
    // Get IsConnected
    function GetIsConnected: Boolean;
    // Get ResourceStream
    function GetResourceStream(AIsConnected: Boolean): TResourceStream;
  end;

implementation

end.
