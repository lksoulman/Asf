unit AsfUIPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfUIPlugInMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-15
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

  // AsfUIPlugInMgr Implementation
  TAsfUIPlugInMgrImpl = class(TPlugInMgrImpl)
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
  HomePageCommandImpl,
  WebPopBrowserCommandImpl,
  WebPopNewsCommandImpl,
  WebPopAnnouncementCommandImpl,
  WebPopResearchReportCommandImpl,
  WebEmbedAssetsCommandImpl,
  SimpleHqTestTimeCommandImpl,
  SimpleHqTestMarketCommandImpl;

{ TAsfUIPlugInMgrImpl }

constructor TAsfUIPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfUIPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfUIPlugInMgrImpl.Load;
begin
  DoAddCommand(THomePageCommandImpl.Create(ASF_COMMAND_ID_HOMEPAGE, 'HomePage', FAppContext));
  DoAddCommand(TWebPopBrowserCommandImpl.Create(ASF_COMMAND_ID_WEBPOP_BROWSER, 'WebPopBrowser', FAppContext));
  DoAddCommand(TWebPopNewsCommandImpl.Create(ASF_COMMAND_ID_WEBPOP_NEWS, 'WebPopNews', FAppContext));
  DoAddCommand(TWebPopAnnouncementCommandImpl.Create(ASF_COMMAND_ID_WEBPOP_ANNOUNCEMENT, 'WebPopAnnouncement', FAppContext));
  DoAddCommand(TWebPopResearchReportCommandImpl.Create(ASF_COMMAND_ID_WEBPOP_RESEARCHREPORT, 'WebPopResearchReport', FAppContext));
  DoAddCommand(TWebEmbedAssetsCommandImpl.Create(ASF_COMMAND_ID_WEBEMBED_ASSETS, 'WebEmbedAssets', FAppContext));
  DoAddCommand(TSimpleHqTestTimeCommandImpl.Create(ASF_COMMAND_ID_SIMPLEHQTIMETEST, 'SimpleHqTimeTest', FAppContext));
  DoAddCommand(TSimpleHqTestMarketCommandImpl.Create(ASF_COMMAND_ID_SIMPLEHQMARKETTEST + 1, 'SimpleHqMarketTest', FAppContext));
end;

end.
