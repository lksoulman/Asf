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
  SysUtils;

type

  // StatusServerData
  TStatusServerData = packed record
    FServerName: string;
    FIsConnected: Boolean;
  end;

  // StatusServerData
  PStatusServerData = ^TStatusServerData;

  // PStatusServerDataMgr
  IStatusServerDataMgr = interface(IInterface)
    ['{1C0F6DD6-0BC2-49A1-A500-19E35DD75E1B}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PStatusServerData;
    // Get IsConnected
    function GetIsConnected: Boolean;
    // Get ResourceStream
    function GetResourceStream(AIsConnected: Boolean): TResourceStream;
  end;

implementation

end.
