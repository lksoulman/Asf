unit ShortKeyDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ShortKeyDataMgr Interface
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

  // ShortKeyData
  TShortKeyData = packed record
    FCommandId: Integer;
    FResourceName: string;
    FCommandParams: string;
  end;

  // ShortKeyData
  PShortKeyData = ^TShortKeyData;

  // ShortKeyDataMgr
  IShortKeyDataMgr = interface(IInterface)
    ['{F57279ED-EC7D-4624-8A61-1507FF29072B}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PShortKeyData;
    // GetStream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

end.
