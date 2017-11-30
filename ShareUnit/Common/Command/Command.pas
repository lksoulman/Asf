unit Command;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Command Interface
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  // AsfMain.exe
  ASF_COMMAND_ID_LOADPROCESS              = 10000001;
  ASF_COMMAND_ID_LOGIN                    = 10000002;
  ASF_COMMAND_ID_KEYFAIRY                 = 10000003;
  ASF_COMMAND_ID_MASTERMGR                = 10000004;
  ASF_COMMAND_ID_SHORTKEYDATAMGR          = 10000005;
  ASF_COMMAND_ID_SUPERTABDATAMGR          = 10000006;
  ASF_COMMAND_ID_STATUSHQDATAMGR          = 10000007;
  ASF_COMMAND_ID_STATUSNEWSDATAMGR        = 10000008;
  ASF_COMMAND_ID_STATUSALARMDATAMGR       = 10000009;
  ASF_COMMAND_ID_STATUSSERVERDATAMGR      = 10000010;
  ASF_COMMAND_ID_STATUSREPORTDATAMGR      = 10000011;

  // AsfService.dll
  ASF_COMMAND_ID_BASICSERVICE             = 20000001;
  ASF_COMMAND_ID_ASSETSERVICE             = 20000002;

  // AsfAuth.dll
  ASF_COMMAND_ID_HQAUTH                   = 30000001;
  ASF_COMMAND_ID_PROAUTH                  = 30000002;

  // AsfCache.dll
  ASF_COMMAND_ID_BASECACHE                = 40000001;
  ASF_COMMAND_ID_USERCACHE                = 40000002;

  // AsfMem.dll
  ASF_COMMAND_ID_SECUMAIN                 = 50000001;
  ASF_COMMAND_ID_KEYSEARCHENGINE          = 50000002;

  // AsfUI.dll



type

  // Command Interface
  ICommand = interface
    // Get Id
    function GetId: Cardinal;
    // Get Basic Id
    function GetBasicId: Int64;
    // Get Caption
    function GetCaption: string;
    // Get Visible
    function GetVisible: Boolean;
    // Get Short Key
    function GetShortKey: Integer;
    // Execute
    procedure Execute(AParams: string);
    // Execute
    procedure ExecuteEx(AParams: array of string);
    // Execute
    procedure ExecuteAsync(AParams: string);
    // Execute
    procedure ExecuteAsyncEx(AParams: array of string);
  end;

implementation


end.
