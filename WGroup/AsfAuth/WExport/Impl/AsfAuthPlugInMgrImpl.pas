unit AsfAuthPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AsfAuthPlugInMgr Implementation
// Author��      lksoulman
// Date��        2017-11-29
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

  // AsfAuthPlugInMgr Implementation
  TAsfAuthPlugInMgrImpl = class(TPlugInMgrImpl)
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

var
  // Global factory
  G_WFactory: IInterface;

implementation

uses
  HqAuthCommandImpl,
  ProAuthCommandImpl;

{ TAsfAuthPlugInMgrImpl }

constructor TAsfAuthPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfAuthPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfAuthPlugInMgrImpl.Load;
begin
  DoAddCommand(THqAuthCommandImpl.Create(ASF_COMMAND_ID_HQAUTH, 'HqAuth', FAppContext));
  DoAddCommand(TProAuthCommandImpl.Create(ASF_COMMAND_ID_PROAUTH, 'ProAuth', FAppContext));
end;

end.
