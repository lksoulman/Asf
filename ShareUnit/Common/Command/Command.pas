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
  ASF_COMMAND_ID_LOADPROCESS               = 10000001;
  ASF_COMMAND_ID_LOGIN                     = 10000002;
  ASF_COMMAND_ID_KEYFAIRY                  = 10000003;
  ASF_COMMAND_ID_MASTERMGR                 = 10000004;
  ASF_COMMAND_ID_SHORTKEYDATAMGR           = 10000005;
  ASF_COMMAND_ID_SUPERTABDATAMGR           = 10000006;
  ASF_COMMAND_ID_STATUSHQDATAMGR           = 10000007;
  ASF_COMMAND_ID_STATUSNEWSDATAMGR         = 10000008;
  ASF_COMMAND_ID_STATUSALARMDATAMGR        = 10000009;
  ASF_COMMAND_ID_STATUSSERVERDATAMGR       = 10000010;
  ASF_COMMAND_ID_STATUSREPORTDATAMGR       = 10000011;

  // AsfService.dll
  ASF_COMMAND_ID_BASICSERVICE              = 20000001;
  ASF_COMMAND_ID_ASSETSERVICE              = 20000002;

  // AsfAuth.dll
  ASF_COMMAND_ID_HQAUTH                    = 30000001;
  ASF_COMMAND_ID_PROAUTH                   = 30000002;

  // AsfCache.dll
  ASF_COMMAND_ID_BASECACHE                 = 40000001;
  ASF_COMMAND_ID_USERCACHE                 = 40000002;

  // AsfMem.dll
  ASF_COMMAND_ID_SECUMAIN                  = 50000001;
  ASF_COMMAND_ID_KEYSEARCHENGINE           = 50000002;
  ASF_COMMAND_ID_USERSECTORMGR             = 50000003;
  ASF_COMMAND_ID_SECTORMGR                 = 50000004;

  // AsfHqService.dll
  ASF_COMMAND_ID_QUOTEMANAGEREX            = 60000001;
  ASF_COMMAND_ID_SERVERDATAMGR             = 60000002;
  ASF_COMMAND_ID_SECUMAINADAPTER           = 60000003;

  // AsfMsg.dll
  ASF_COMMAND_ID_MSGEXSERVICE              = 70000001;

  // AsfUI.dll {}
  ASF_COMMAND_ID_HOMEPAGE                  = 80000001;

  // AsfUI.dll {WebPop}
  ASF_COMMAND_ID_WEBPOP_BROWSER            = 80010000;
  ASF_COMMAND_ID_WEBPOP_NEWS               = 80010001;
  ASF_COMMAND_ID_WEBPOP_ANNOUNCEMENT       = 80010002;
  ASF_COMMAND_ID_WEBPOP_RESEARCHREPORT     = 80010003;

  // AsfUI.dll {WebEmbed}
  ASF_COMMAND_ID_WEBEMBED_ASSETS           = 80020001;
//  ASF_COMMAND_ID_WEBEMBED_

  // AsfUI.dll Test
  ASF_COMMAND_ID_SIMPLEHQTIMETEST         = 89000001;
  ASF_COMMAND_ID_SIMPLEHQMARKETTEST       = 89000002;

type

  // Command Interface
  ICommand = interface
    // GetId
    function GetId: Cardinal;
    // GetBasicId
    function GetBasicId: Int64;
    // GetCaption
    function GetCaption: string;
    // GetVisible
    function GetVisible: Boolean;
    // GetShortKey
    function GetShortKey: Integer;
    // Execute
    procedure Execute(AParams: string);
  end;

  // CmdInterceptor Interface
  ICmdInterceptor = interface(IInterface)
    // ExecuteCmdAfter
    procedure ExecuteCmdAfter(ACommandId: Integer; AParams: string);
    // ExecuteCmdBefore
    procedure ExecuteCmdBefore(ACommandId: Integer; AParams: string);
  end;

implementation


end.
