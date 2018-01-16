unit AsfMemPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfMemPlugInMgr Implementation
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
  Command,
  AppContext,
  PlugInMgrImpl;

type

  // AsfMemPlugInMgr Implementation
  TAsfMemPlugInMgrImpl = class(TPlugInMgrImpl)
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
  SecuMainCommandImpl,
  SectorMgrCommandImpl,
  UserSectorMgrCommandImpl,
  KeySearchEngineCommandImpl,
  UserAttentionMgrCommandImpl;

{ TAsfMemPlugInMgrImpl }

constructor TAsfMemPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfMemPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfMemPlugInMgrImpl.Load;
begin
  DoAddCommand(TSecuMainCommandImpl.Create(ASF_COMMAND_ID_SECUMAIN, 'SecuMain', FAppContext) as ICommand);
  DoAddCommand(TSectorMgrCommandImpl.Create(ASF_COMMAND_ID_SECTORMGR, 'SectorMgr', FAppContext) as ICommand);
  DoAddCommand(TUserSectorMgrCommandImpl.Create(ASF_COMMAND_ID_USERSECTORMGR, 'UserSectorMgr', FAppContext) as ICommand);
  DoAddCommand(TKeySearchEngineCommandImpl.Create(ASF_COMMAND_ID_KEYSEARCHENGINE, 'KeySearchEngine', FAppContext) as ICommand);
  DoAddCommand(TUserAttentionMgrCommandImpl.Create(ASF_COMMAND_ID_USERATTENTIONMGR, 'UserAttentionMgr', FAppContext) as ICommand);
end;

end.
