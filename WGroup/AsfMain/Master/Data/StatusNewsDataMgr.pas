unit StatusNewsDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusNewsDataMgr Interface
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

  // StatusNewsData
  TStatusNewsData = packed record
    FId: Int64;
    FTitle: string;
    FWidth: Integer;
    FDateTimeStr: string;
    FDateTime: TDateTime;
  end;

  // StatusNewsData
  PStatusNewsData = ^TStatusNewsData;

  // StatusNewsDataMgr
  IStatusNewsDataMgr = interface(IInterface)
    ['{3A39A1C5-7445-4F5F-8686-9A2CAA1AEE4C}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get StatusNewsDataCount
    function GetDataCount: Integer;
    // Get StatusNewsData
    function GetData(AIndex: Integer): PStatusNewsData;
    // Find Data
    function FindData(AId: Integer): PStatusNewsData;
  end;

implementation

end.

