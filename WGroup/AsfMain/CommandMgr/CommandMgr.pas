unit CommandMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CommandMgr Interface
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command;

type

  // Command Mgr
  ICommandMgr = interface(IInterface)
    ['{69F78D56-A9C5-45C7-B475-4AACC4806827}']
    // Register
    function RegisterCmd(ACommand: ICommand): Boolean;
    // UnRegister
    function UnRegisterCmd(ACommand: ICommand): Boolean;
    // Execute Command
    function ExecuteCmd(ACommandId: Cardinal; AParams: string): Boolean;
    // Execute Command
    function ExecuteCmdEx(ACommandId: Cardinal; AParams: Array of string): Boolean;
    // Execute Async Command
    function ExecuteAsyncCmd(ACommandId: Cardinal; AParams: string): Boolean;
    // Execute Async Command
    function ExecuteAsyncCmdEx(ACommandId: Cardinal; AParams: Array of string): Boolean;
  end;

implementation

end.
