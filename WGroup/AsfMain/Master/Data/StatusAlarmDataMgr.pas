unit StatusAlarmDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� StatusAlarmDataMgr Interface
// Author��      lksoulman
// Date��        2017-11-22
// Comments��
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
