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
  // ȫ��Ӧ�ó���������
  G_AppContext: IAppContext;
  // ȫ�������������壬����ʾ
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
    // ͬ������Ȩ��
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_HQAUTH, 'FuncName=Update');
    // ͬ����ƷȨ��
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_PROAUTH, 'FuncName=Update');
  end;

  // LoadCache
  procedure LoadCache;
  begin
    {��������}
    // ִ��δ�����ı�Ľű�
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=ReplaceCreateCacheTables');

    {�û�����}
    // ִ��δ�����ı�Ľű�
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=ReplaceCreateCacheTables');
    // ͬ���û�����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_Command_ID_USERCACHE, 'FuncName=InitUpdateTables');
    // ��ȡͬ�����û���������
    G_AppContext.GetCfg.ReadServerCacheCfg;
  end;

  // LoadMaster
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

    G_AppContext.GetCommandMgr.FixedExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=UpdateTables', 60);

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

    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_USERSECTORMGR, 'FuncName=Update', 1);

    // �첽��ʽ��������������ʱ����
    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=AsyncUpdate', 2);
    // �첽��ʽ��������������ʱ����
//    G_AppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_STATUSSERVERDATAMGR, 'FuncName=Subcribe', 3);
  end;

  // StopServices
  procedure StopServices;
  begin
    // ֹͣJobs
    G_AppContext.GetCommandMgr.StopJobs;
    // ֹͣ���̾������
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_KEYSEARCHENGINE, 'FuncName=StopService');
    // ֹͣ�������
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_QUOTEMANAGEREX, 'FuncName=StopService');
    // ֹͣBasic����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASICSERVICE, 'FuncName=StopService');
    // ֹͣAsset����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_ASSETSERVICE, 'FuncName=StopService');
    // ֹͣBaseCache����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_BASECACHE, 'FuncName=StopService');
    // ֹͣUserCache����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERCACHE, 'FuncName=StopService');
    // ֹͣSecuMain�ڴ����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECUMAIN, 'FuncName=StopService');
    // ֹͣMsgEx����
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MSGEXSERVICE, 'FuncName=StopService');
  end;

  // CloseShowForms
  procedure CloseShowForms;
  begin
    // �رռ��̾��鴰��
    G_AppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_KEYFAIRY, 'FuncName=Hide');
    // �رյ���ʽ��Ѷ����
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
