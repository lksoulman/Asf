unit AsfServicePlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfServicePlugInMgr Implementation
// Author£º      lksoulman
// Date£º        2017-8-10
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

  // AsfServicePlugInMgr Implementation
  TAsfServicePlugInMgrImpl = class(TPlugInMgrImpl)
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
  BasicServiceCommandImpl,
  AssetServiceCommandImpl;

{ TAsfServicePlugInMgrImpl }

constructor TAsfServicePlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfServicePlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfServicePlugInMgrImpl.Load;
begin
  DoAddCommand(TBasicServiceCommandImpl.Create(ASF_COMMAND_ID_BASICSERVICE, 'Basic Service', FAppContext) as ICommand);
  DoAddCommand(TAssetServiceCommandImpl.Create(ASF_COMMAND_ID_ASSETSERVICE, 'Asset Service', FAppContext) as ICommand);
end;

end.
