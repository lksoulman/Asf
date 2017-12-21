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

  // CommandMgr
  ICommandMgr = interface(IInterface)
    ['{69F78D56-A9C5-45C7-B475-4AACC4806827}']
    // StopJobs
    procedure StopJobs;
    // Register
    function RegisterCmd(ACommand: ICommand): Boolean;
    // UnRegister
    function UnRegisterCmd(ACommand: ICommand): Boolean;
    // ExecuteCmd
    function ExecuteCmd(ACommandId: Cardinal; AParams: string): Boolean;
    // RegisterCmdInterceptor
    function RegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
    // UnRegisterCmdInterceptor
    function UnRegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
    // DelayExecuteCmd
    function DelayExecuteCmd(ACommandId: Cardinal; AParams: string; ADelaySecs: Cardinal): Boolean;
    // FixedExecuteCmd
    function FixedExecuteCmd(ACommandId: Cardinal; AParams: string; AFixedSecs: Cardinal): Boolean;
  end;

implementation

end.
