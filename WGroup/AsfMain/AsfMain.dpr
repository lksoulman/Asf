program AsfMain;

uses
  Vcl.Forms,
  WExport in 'WExport\WExport.pas',
  AsfMainPlugInMgrImpl in 'WExport\Impl\AsfMainPlugInMgrImpl.pas',
  CommandMgrImpl in 'CommandMgr\Impl\CommandMgrImpl.pas',
  AppContextImpl in 'AppContext\Impl\AppContextImpl.pas',
  LogImpl in 'Log\Impl\LogImpl.pas',
  EDCryptImpl in 'EDCrypt\Impl\EDCryptImpl.pas',
  CfgImpl in 'Cfg\Impl\CfgImpl.pas',
  WebCfgImpl in 'Cfg\WebCfg\Impl\WebCfgImpl.pas',
  CacheCfgImpl in 'Cfg\CacheCfg\Impl\CacheCfgImpl.pas',
  ServerCfgImpl in 'Cfg\ServerCfg\Impl\ServerCfgImpl.pas',
  SysCfgImpl in 'Cfg\SysCfg\Impl\SysCfgImpl.pas',
  WebInfoImpl in 'Cfg\Info\Impl\WebInfoImpl.pas',
  UserInfoImpl in 'Cfg\Info\Impl\UserInfoImpl.pas',
  ProxyInfoImpl in 'Cfg\Info\Impl\ProxyInfoImpl.pas',
  SystemInfoImpl in 'Cfg\Info\Impl\SystemInfoImpl.pas',
  ServerInfoImpl in 'Cfg\Info\Impl\ServerInfoImpl.pas',
  CompanyInfoImpl in 'Cfg\Info\Impl\CompanyInfoImpl.pas',
  CrtExport in 'Cfg\CrtExport.pas',
  HardWareUtil in 'Cfg\HardWareUtil.pas',
  AbstractLogin in 'Login\AbstractLogin.pas',
  UFXAccountLogin in 'Login\UFXAccountLogin.pas',
  GilAccountLogin in 'Login\GilAccountLogin.pas',
  PBoxAccountLogin in 'Login\PBoxAccountLogin.pas',
  LoginMainUI in 'Login\UI\LoginMainUI.pas' {LoginMainUI},
  LoginBindUI in 'Login\UI\LoginBindUI.pas' {LoginBindUI},
  LoginSettingUI in 'Login\UI\LoginSettingUI.pas' {LoginSettingUI},
  LoginImpl in 'Login\Impl\LoginImpl.pas',
  ResourceCfgImpl in 'Resource\Impl\ResourceCfgImpl.pas',
  ResourceSkinImpl in 'Resource\Impl\ResourceSkinImpl.pas',

  LoginCommandImpl in 'WCommands\LoginCommandImpl.pas',
  WDLLFactory in 'WDLLFactory\WDLLFactory.pas',
  WDLLFactoryImpl in 'WDLLFactory\Impl\WDLLFactoryImpl.pas',
  GdiMgrImpl in 'GdiMgr\Impl\GdiMgrImpl.pas',
  LoadProcess in 'LoadProcess\LoadProcess.pas',
  LoadProcessImpl in 'LoadProcess\Impl\LoadProcessImpl.pas',
  LoadProcessUI in 'LoadProcess\LoadProcessUI.pas' {LoadProcessUI},
  LoadProcessCommandImpl in 'WCommands\LoadProcessCommandImpl.pas',
  CommandCookieMgr in 'Cookie\CommandCookieMgr.pas',
  CommandCookieMgrImpl in 'Cookie\Impl\CommandCookieMgrImpl.pas',
  CommandCookieMgrCommandImpl in 'WCommands\CommandCookieMgrCommandImpl.pas',
  VirtualMain in 'VirtualMain\VirtualMain.pas' {VirtualMainUI},
  Master in 'Master\Master.pas',
  MasterMgr in 'Master\MasterMgr.pas',
  MasterImpl in 'Master\Impl\MasterImpl.pas',
  MasterMgrImpl in 'Master\Impl\MasterMgrImpl.pas',
  MasterUI in 'Master\UI\MasterUI.pas' {MasterUI},
  StatusBarUI in 'Master\UI\StatusBarUI\StatusBarUI.pas',
  ShortKeyBarUI in 'Master\UI\ShortKeyBarUI\ShortKeyBarUI.pas',
  SuperTabBarUI in 'Master\UI\SuperTabBarUI\SuperTabBarUI.pas',
  KeyFairyCommandImpl in 'WCommands\KeyFairyCommandImpl.pas',
  MasterMgrCommandImpl in 'WCommands\MasterMgrCommandImpl.pas',
  ShortKeyDataMgrCommandImpl in 'WCommands\ShortKeyDataMgrCommandImpl.pas',
  StatusAlarmDataMgrCommandImpl in 'WCommands\StatusAlarmDataMgrCommandImpl.pas',
  StatusHqDataMgrCommandImpl in 'WCommands\StatusHqDataMgrCommandImpl.pas',
  StatusNewsDataMgrCommandImpl in 'WCommands\StatusNewsDataMgrCommandImpl.pas',
  StatusReportDataMgrCommandImpl in 'WCommands\StatusReportDataMgrCommandImpl.pas',
  StatusServerDataMgrCommandImpl in 'WCommands\StatusServerDataMgrCommandImpl.pas',
  SuperTabDataMgrCommandImpl in 'WCommands\SuperTabDataMgrCommandImpl.pas',
  ShortKeyDataMgr in 'Master\Data\ShortKeyDataMgr.pas',
  SuperTabDataMgr in 'Master\Data\SuperTabDataMgr.pas',
  StatusHqDataMgr in 'Master\Data\StatusHqDataMgr.pas',
  StatusNewsDataMgr in 'Master\Data\StatusNewsDataMgr.pas',
  StatusAlarmDataMgr in 'Master\Data\StatusAlarmDataMgr.pas',
  StatusReportDataMgr in 'Master\Data\StatusReportDataMgr.pas',
  StatusServerDataMgr in 'Master\Data\StatusServerDataMgr.pas',
  KeyFairyUI in 'KeyFairy\UI\KeyFairyUI.pas' {KeyFairyUI},
  KeyReportUI in 'KeyFairy\UI\KeyReportUI.pas',
  KeyFairy in 'KeyFairy\KeyFairy.pas',
  KeyFairyImpl in 'KeyFairy\Impl\KeyFairyImpl.pas',
  SuperTabDataMgrImpl in 'Master\Data\Impl\SuperTabDataMgrImpl.pas',
  ShortKeyDataMgrImpl in 'Master\Data\Impl\ShortKeyDataMgrImpl.pas',
  StatusHqDataMgrImpl in 'Master\Data\Impl\StatusHqDataMgrImpl.pas',
  StatusNewsDataMgrImpl in 'Master\Data\Impl\StatusNewsDataMgrImpl.pas',
  StatusAlarmDataMgrImpl in 'Master\Data\Impl\StatusAlarmDataMgrImpl.pas',
  StatusReportDataMgrImpl in 'Master\Data\Impl\StatusReportDataMgrImpl.pas',
  StatusServerDataMgrImpl in 'Master\Data\Impl\StatusServerDataMgrImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  try
    Application.ShowMainForm := False;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TVirtualMainUI, G_VirtualMainUI);
    G_AppContext.Initialize;
    try
      LoadCmds;
      if G_AppContext.Login then begin
        LoadAuth;
//        LoadCache;
//        LoadMemory;
        LoadMaster;
        Application.Run;
      end;
    finally
      UnLoadProcessEx;
      G_AppContext.UnInitialize;
    end;
  except
    Halt(0);
  end;
end.
