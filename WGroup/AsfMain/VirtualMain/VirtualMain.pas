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
    G_AppContext.LoadDynLibrary('AsfCache.dll');
    G_AppContext.LoadDynLibrary('AsfAuth.dll');
    G_AppContext.LoadDynLibrary('AsfMem.dll');
    G_AppContext.LoadDynLibrary('AsfUI.dll');
  end;

  // LoadAuth
  procedure LoadAuth;
  begin

    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_HQAUTH, 'FuncName=Update');
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_PROAUTH, 'FuncName=Update');
  end;

  // Load Cache
  procedure LoadCache;
  begin
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, '');
  end;

  // Load Memory
  procedure LoadMemory;
  begin
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=Update');
  end;

  // Load Master
  procedure LoadMaster;
  begin
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MASTERMGR, 'FuncName=NewMaster');
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
