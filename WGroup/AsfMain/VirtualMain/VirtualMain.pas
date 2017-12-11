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
  // Load ProcessEx
  procedure LoadProcessEx;
  // UnLoad ProcessEx
  procedure UnLoadProcessEx;
  // LoopWaitLoadEnd
  procedure LoopWaitLoadEnd;

var
  // �ǲ��Ǽ��ؽ���
  G_IsLoadEnd: Boolean;
  // ȫ��Ӧ�ó���������
  G_AppContext: IAppContext;
  // ȫ����ʾ���ؽ���
  G_LoadProcess: ILoadProcess;
  // ȫ�������������壬����ʾ
  G_VirtualMainUI: TVirtualMainUI;



implementation

uses
  AppContextImpl;

{$R *.dfm}


  // Load Cmds
  procedure LoadCmds;
  begin
    G_AppContext.LoadDynLibrary('AsfMsg.dll');
    G_AppContext.LoadDynLibrary('AsfService.dll');
    G_AppContext.LoadDynLibrary('AsfAuth.dll');
    G_AppContext.LoadDynLibrary('AsfCache.dll');
    G_AppContext.LoadDynLibrary('AsfMem.dll');
    G_AppContext.LoadDynLibrary('AsfHqService.dll');
//    G_AppContext.LoadDynLibrary('AsfUI.dll');
  end;

  // InitUser
  procedure InitUser;
  begin
    G_AppContext.GetCfg.WriteLocalCacheCfg;
  end;

  // LoadAuth
  procedure LoadAuth;
  begin
    // ͬ������Ȩ��
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_HQAUTH, 'FuncName=Update');
    // ͬ����ƷȨ��
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_PROAUTH, 'FuncName=Update');
  end;

  // Load Cache
  procedure LoadCache;
  begin
    {��������}
    // ִ��δ�����ı�Ľű�
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=ReplaceCreateCacheTables');

    {�û�����}
    // ִ��δ�����ı�Ľű�
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=ReplaceCreateCacheTables');
    // ͬ���û�����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_Command_ID_USERCACHE, 'FuncName=UpdateTables');
    // ��ȡͬ�����û���������
    G_AppContext.GetCfg.ReadServerCacheCfg;
  end;

  // Load Master
  procedure LoadMaster;
  begin
    // ����������
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MASTERMGR, 'FuncName=NewMaster');
  end;

  // LoadCronJobs
  procedure LoadCronJobs;
  begin
    // ״̬���������ݻ�ȡ��ʱ����
    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'FuncName=Update', 600);

//    // �첽��ʽͬ�������������ݶ�ʱ����
//    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 10);
  end;

  // LoadDelayJobs
  procedure LoadDelayJobs;
  begin
    // �첽��ʽ״̬���������ݻ�ȡ��ʱ����
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'FuncName=Update', 1);

//    // �첽��ʽͬ����������������ʱ����
//    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=AsyncUpdateTables', 2);

    // �첽��ʽ��������������ʱ����
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=AsyncUpdate', 2);
    // �첽��ʽ��������������ʱ����
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR, 'FuncName=Subcribe', 3);
  end;

  procedure StopServices;
  begin
    // ֹͣ���̾������
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_KEYSEARCHENGINE, 'FuncName=StopService');
    // ֹͣ�������
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_QUOTEMANAGEREX, 'FuncName=StopService');
    // ֹͣBasic����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASICSERVICE, 'FuncName=StopService');
    // ֹͣAsset����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_ASSETSERVICE, 'FuncName=StopService');
    // ֹͣMsgEx����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MSGEXSERVICE, 'FuncName=StopService');
    // ֹͣBaseCache����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=StopService');
    // ֹͣUserCache����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=StopService');
    // ֹͣSecuMain�ڴ����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=StopService');
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

  if G_AppContext <> nil then begin
    G_AppContext := nil;
  end;

end.
