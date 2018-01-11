unit AsfCachePlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfCachePlugInMgr Implementation
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

  // AsfCachePlugInMgr Implementation
  TAsfCachePlugInMgrImpl = class(TPlugInMgrImpl)
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
  BaseCacheCommandImpl,
  UserCacheCommandImpl;

{ TAsfCachePlugInMgrImpl }

constructor TAsfCachePlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfCachePlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfCachePlugInMgrImpl.Load;
begin
  DoAddCommand(TBaseCacheCommandImpl.Create(ASF_COMMAND_ID_BASECACHE, 'BaseCache', FAppContext) as ICommand);
  DoAddCommand(TUserCacheCommandImpl.Create(ASF_COMMAND_ID_USERCACHE, 'UserCache', FAppContext) as ICommand);
end;

end.
