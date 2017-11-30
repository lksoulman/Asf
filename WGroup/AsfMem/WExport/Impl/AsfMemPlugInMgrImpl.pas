unit AsfMemPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AsfMemPlugInMgr Implementation
// Author��      lksoulman
// Date��        2017-11-14
// Comments��
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
  KeySearchEngineCommandImpl;

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
  DoAddCommand(TKeySearchEngineCommandImpl.Create(ASF_COMMAND_ID_KEYSEARCHENGINE, 'KeySearchEngine', FAppContext) as ICommand);
end;

end.