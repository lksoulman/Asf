unit VirtualMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Command,
  AppContext,
  LoadProcess;

type

  // VirtualMainUI
  TVirtualMainUI = class(TForm)
  private
  protected
  public
  end;

  // Load Cmds
  procedure LoadCmds;
  // LoadAuth
  procedure LoadAuth;
  // Load Cache
  procedure LoadCache;
  // Load Memory
  procedure LoadMemory;
  // Load Master
  procedure LoadMaster;
  // LoadCronJobs
  procedure LoadCronJobs;
  // LoadDelayJobs
  procedure LoadDelayJobs;
  // Load ProcessEx
  procedure LoadProcessEx;
  // UnLoad ProcessEx
  procedure UnLoadProcessEx;
  // LoopWaitLoadEnd
  procedure LoopWaitLoadEnd;

var
  // 是不是加载结束
  G_IsLoadEnd: Boolean;
  // 全局应用程序上下文
  G_AppContext: IAppContext;
  // 全局显示加载进度
  G_LoadProcess: ILoadProcess;
  // 全局虚拟启动窗体，不显示
  G_VirtualMainUI: TVirtualMainUI;



implementation

uses
  AppContextImpl;

{$R *.dfm}


  // Load Cmds
  procedure LoadCmds;
  begin
    G_AppContext.LoadDynLibrary('AsfService.dll');
    G_AppContext.LoadDynLibrary('AsfAuth.dll');
    G_AppContext.LoadDynLibrary('AsfCache.dll');
    G_AppContext.LoadDynLibrary('AsfHqService.dll');
    G_AppContext.LoadDynLibrary('AsfMem.dll');
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

  // Load Cache
  procedure LoadCache;
  begin
    {基础数据}
    // 同步ZQZB数据
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=NoExistUpdateTable@Params=ZQZB');
    // 执行未创建的表的脚本
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=ReplaceCreateCacheTables');

    {用户数据}
    // 执行未创建的表的脚本
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=ReplaceCreateCacheTables');
    // 同步用户数据
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_Command_ID_USERCACHE, 'FuncName=UpdateTables');
    // 读取同步的用户配置数据
    G_AppContext.GetCfg.ReadServerCacheCfg;
  end;

  // Load Memory
  procedure LoadMemory;
  begin
    // 同步更新内存主表
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=Update');
  end;

  // Load Master
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

    // 异步方式同步基础缓存数据定时任务
    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 10);
  end;

  // LoadDelayJobs
  procedure LoadDelayJobs;
  begin
    // 异步方式状态栏新闻数据获取延时任务
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'FuncName=Update', 5);
    // 异步方式同步基础缓存数据延时任务
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 30);
    // 异步方式订阅行情数据延时任务
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR, 'FuncName=Subcribe', 10);
  end;

  // LoadProcessEx
  procedure LoadProcessEx;
  begin
    G_LoadProcess := G_AppContext.FindInterface(ASF_COMMAND_ID_LOADPROCESS) as ILoadProcess;
  end;

  // UnLoadProcessEx
  procedure UnLoadProcessEx;
  begin
    if G_LoadProcess <> nil then begin
      G_LoadProcess := nil;
    end;
  end;

  // LoopWaitLoadEnd
  procedure LoopWaitLoadEnd;
  begin
    while not G_IsLoadEnd do begin
      case WaitForSingleObject(G_LoadProcess.GetWaitEvent, 50) of
        WAIT_OBJECT_0:
          begin
            G_IsLoadEnd := True;
          end;
      else
        begin
          Application.ProcessMessages;
        end;
      end;
    end;
  end;


initialization
  if G_AppContext = nil then begin
    G_AppContext := TAppContextImpl.Create(nil) as IAppContext;
  end;

finalization

  if G_AppContext = nil then begin
    G_AppContext := nil;
  end;

end.
