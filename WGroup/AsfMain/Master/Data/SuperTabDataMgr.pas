unit SuperTabDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SuperTabDataMgr Interface
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

  // SuperTabData
  TSuperTabData = packed record
    FCommandId: Integer;
    FResourceName: string;
  end;

  // SuperTabData
  PSuperTabData = ^TSuperTabData;

  // SuperTabDataMgr
  ISuperTabDataMgr = interface(IInterface)
    ['{9186C4C3-79C9-4946-99E6-E916899B05C5}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get DataCount
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PSuperTabData;
    // GetStream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

end.

