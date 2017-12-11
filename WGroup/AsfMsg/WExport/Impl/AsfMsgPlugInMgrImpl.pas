unit AsfMsgPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfMsgPlugInMgr Implementation
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  PlugInMgrImpl;

type

  // AsfMsgPlugInMgr Implementation
  TAsfMsgPlugInMgrImpl = class(TPlugInMgrImpl)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IPlugInMgr }

    // Load
    procedure Load; override;
  end;

implementation

uses
  MsgExServiceCommandImpl;

{ TAsfMsgPlugInMgrImpl }

constructor TAsfMsgPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfMsgPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfMsgPlugInMgrImpl.Load;
begin
  DoAddCommand(TMsgExServiceCommandImpl.Create(ASF_COMMAND_ID_MSGEXSERVICE, 'MsgExService', FAppContext) as ICommand);
end;

end.
