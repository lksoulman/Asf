unit VirtualMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Chrome,
  Command,
  AppContext,
  LoadProcess,
  ProcessSingleton;

type

  // VirtualMainUI
  TVirtualMainUI = class(TForm)
  private
  protected
  public
  end;

  // LoadCmds
  procedure LoadCmds;
  // LoadAuth
  procedure LoadAuth;
  // LoadCache
  procedure LoadCache;
  // LoadMaster
  procedure LoadMaster;
  // LoadCronJobs
  procedure LoadCronJobs;
  // LoadDelayJobs
  procedure LoadDelayJobs;
  // StopServices
  procedure StopServices;
  // CloseShowForms
  procedure CloseShowForms;

var
  // 全局应用程序上下文
  G_AppContext: IAppContext;
  // 全局虚拟启动窗体，不显示
  G_VirtualMainUI: TVirtualMainUI;
  // ProcessSingleton
  G_ProcessSingleton: TProcessSingleton;

implementation

uses
  AppContextImpl;

{$R *.dfm}

  // LoadCmds
  procedure LoadCmds;
  begin
    G_AppContext.LoadDynLibrary('AsfMsg.dll');
    G_AppContext.LoadDynLibrary('AsfService.dll');
    G_AppContext.LoadDynLibrary('AsfAuth.dll');
    G_AppContext.LoadDynLibrary('AsfCache.dll');
    G_AppContext.LoadDynLibrary('AsfMem.dll');
    G_AppContext.LoadDynLibrary('AsfHqService.dll');
    G_AppContext.LoadDynLibrary('AsfUI.dll');
  end;

  // InitUser
  procedure InitUser;
  begin
    G_AppContext.GetCfg.WriteLocalCacheCfg;
  end;

  // LoadAuth
  procedure LoadAuth;
  begin
    // 同步行情权限
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_HQAUTH, 'FuncName=Update');
    // 同步产品权限
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_PROAUTH, 'FuncName=Update');
  end;

  // LoadCache
  procedure LoadCache;
  begin
    {基础数据}
    // 执行未创建的表的脚本
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=ReplaceCreateCacheTables');

    {用户数据}
    // 执行未创建的表的脚本
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=ReplaceCreateCacheTables');
    // 同步用户数据
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_Command_ID_USERCACHE, 'FuncName=InitUpdateTables');
    // 读取同步的用户配置数据
    G_AppContext.GetCfg.ReadServerCacheCfg;
  end;

  // LoadMaster
  procedure LoadMaster;
  begin
    // 创建主窗体
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MASTERMGR, 'FuncName=NewMaster');
  end;

  // LoadCronJobs
  procedure LoadCronJobs;
  begin
    // 状态栏新闻数据获取定时任务
    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'FuncName=Update', 600);

    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=UpdateTables', 60);

//    // 异步方式同步基础缓存数据定时任务
//    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 10);

  end;

  // LoadDelayJobs
  procedure LoadDelayJobs;
  begin
    // 异步方式状态栏新闻数据获取延时任务
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'FuncName=Update', 1);

//    // 异步方式同步基础缓存数据延时任务
//    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 2);

    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_USERSECTORMGR, 'FuncName=Update', 1);

    // 异步方式加载主表数据延时任务
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=AsyncUpdate', 2);
    // 异步方式订阅行情数据延时任务
//    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR, 'FuncName=Subcribe', 3);
  end;

  // StopServices
  procedure StopServices;
  begin
    // 停止Jobs
    G_AppContext.GetCommandMgr.StopJobs;
    // 停止键盘经理服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_KEYSEARCHENGINE, 'FuncName=StopService');
    // 停止行情服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_QUOTEMANAGEREX, 'FuncName=StopService');
    // 停止Basic服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASICSERVICE, 'FuncName=StopService');
    // 停止Asset服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_ASSETSERVICE, 'FuncName=StopService');
    // 停止BaseCache服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=StopService');
    // 停止UserCache服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=StopService');
    // 停止SecuMain内存服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=StopService');
    // 停止MsgEx服务
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MSGEXSERVICE, 'FuncName=StopService');
  end;

  // CloseShowForms
  procedure CloseShowForms;
  begin
    // 关闭键盘精灵窗口
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_KEYFAIRY, 'FuncName=Hide');
    // 关闭弹出式资讯窗口
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_WEBPOP_BROWSER, 'FuncName=Hide');
  end;

initialization

  if G_AppContext = nil then begin
    G_AppContext := TAppContextImpl.Create(nil) as IAppContext;
    G_AppContext.InitLogger;
    G_AppContext.InitChrome;
  end;

  if G_ProcessSingleton = nil then begin
    G_ProcessSingleton := TProcessSingleton.Instance(G_AppContext);
  end;

finalization

  if G_ProcessSingleton <> nil then begin
    G_ProcessSingleton.Free;
    G_ProcessSingleton := nil;
  end;

  if G_AppContext <> nil then begin
    G_AppContext.UnInitChrome;
    G_AppContext.UnInitLogger;
    G_AppContext := nil;
  end;

end.
