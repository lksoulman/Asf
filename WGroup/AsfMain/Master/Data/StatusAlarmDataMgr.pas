unit StatusAlarmDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusAlarmDataMgr Interface
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

  // StatusAlarmDataMgr
  IStatusAlarmDataMgr = interface(IInterface)
    ['{977D77DF-6E66-47C5-9187-E48269ABFE13}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // IshasUpdate
    function IsHasUpdate: Boolean;
    // GetResourceStream
    function GetResourceStream: TResourceStream;
  end;

implementation

end.
