unit AsfHqServicePlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfHqServicePlugInMgr Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
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

  // AsfHqServicePlugInMgr Implementation
  TAsfHqServicePlugInMgrImpl = class(TPlugInMgrImpl)
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
  ServerDataMgrCommandImpl,
  QuoteManagerExCommandImpl;

{ TAsfHqServicePlugInMgrImpl }

constructor TAsfHqServicePlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfHqServicePlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfHqServicePlugInMgrImpl.Load;
begin
  DoAddCommand(TServerDataMgrCommandImpl.Create(ASF_COMMAND_ID_SERVERDATAMGR, 'ServerDataMgr', FAppContext) as ICommand);
  DoAddCommand(TQuoteManagerExCommandImpl.Create(ASF_COMMAND_ID_QUOTEMANAGEREX, 'QuoteManagerEx', FAppContext) as ICommand);
end;

end.
