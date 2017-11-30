unit LoginSettingUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-12
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Graphics,
  Variants,
  Controls,
  StdCtrls,
  ExtCtrls,
  Buttons,
  Dialogs,
  Forms,
  Mask,
  RzTabs,
  RzButton,
  RzRadChk,
  RzSpnEdt,
  RzEdit,
  RzCmboBx,
  Cfg,
  AppContext;

type

  // ��¼���ô���
  TLoginSettingUI = class(TForm)
    // ���� pagecontrol
    pagecontrolSetting: TRzPageControl;
    // ����������ҳǩ
    sheetServerSetting: TRzTabSheet;
    // ��������ҳǩ
    sheetProxySetting: TRzTabSheet;
    // �ײ�
    pnlBottom: TPanel;
    // ȷ�� ��ť
    btnOk: TRzButton;
    // ȡ����ť
    btnCancel: TRzButton;
    // �������б��ǩ
    lblServerList: TLabel;
    // ��ѡ�б�
    cmbServerList: TRzComboBox;
    // NTLM ����
    gpbxNTLM: TGroupBox;
    // �û���Ϣ����
    gpbxUserInfo: TGroupBox;
    // �������ͷ���
    gpbxProxyType: TGroupBox;
    // �ǲ������ô������
    gpbxIsUserProxy: TGroupBox;
    // �������IP��ǩ
    lblProxyIP: TLabel;
    // ����������˿ڱ�ǩ
    lblProxyPort: TLabel;
    // ������������ͱ�ǩ
    lblProxyType: TLabel;
    // ��������û���Ϣ��ǩ
    lblUserInfo: TLabel;
    // ���������û�����ǩ
    lblUserName: TLabel;
    // ���������û�����ǩ
    lblPassword: TLabel;
    // ��������������ǩ
    lblDomain: TLabel;
    // �����������������
    edtDomain: TRzEdit;
    // �������IP�����
    edtProxyIP: TRzEdit;
    // ���������û��������
    edtUserName: TRzEdit;
    // �����������������
    edtPassword: TRzEdit;
    // �������Ķ˿������
    sedtProxyPort: TRzSpinEdit;
    // NTLM ��ѡ��
    chkIsNTLM: TRzCheckBox;
    // �ǲ���ʹ�ô���
    chkIsUseProxy: TRzCheckBox;
    // sock5����ѡ��
    rdbtnSocks5: TRzRadioButton;
    // sock4����ѡ��
    rdbtnSocks4: TRzRadioButton;
    // Http����ѡ��
    rdbtnHttpProxy: TRzRadioButton;
    // ���ڴ���
    procedure FormCreate(Sender: TObject);
    // ���� Show
    procedure FormShow(Sender: TObject);
    // ���̰���
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    // ����ȷ��
    procedure btnOkClick(Sender: TObject);
    // ����ȡ��
    procedure btnCancelClick(Sender: TObject);
    // ���� NTLM
    procedure chkIsNTLMClick(Sender: TObject);
    // �����ǲ���ʹ�ô������
    procedure chkIsUseProxyClick(Sender: TObject);
  private
    // ���ýӿ�
    FCfg: ICfg;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // ��ʼ���û����������ݵ���¼���ô���
    procedure DoInitUserDataToSettingWindows;
  public
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext);
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize;
    // ���µ�¼�������ݵ��û�����
    procedure UpdateLoginSettingDataToUserData;
  end;

implementation

uses
  Proxy,
  ProxyInfo;

{$R *.dfm}

procedure TLoginSettingUI.FormCreate(Sender: TObject);
begin
  pagecontrolSetting.ActivePageIndex := 0;
end;

procedure TLoginSettingUI.FormShow(Sender: TObject);
begin
  SelectNext(pagecontrolSetting, true, true);
end;

procedure TLoginSettingUI.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then begin
    ModalResult := mrCancel;
  end;
end;

procedure TLoginSettingUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCfg := FAppContext.GetCfg;
  DoInitUserDataToSettingWindows;
end;

procedure TLoginSettingUI.UnInitialize;
begin
  FCfg := nil;
  FAppContext := nil;
end;

procedure TLoginSettingUI.DoInitUserDataToSettingWindows;
var
  LPProxy: PProxy;
begin
  if FCfg <> nil then begin
    LPProxy := FCfg.GetSysCfg.GetProxyInfo.GetProxy;
    chkIsUseProxy.Checked := FCfg.GetSysCfg.GetProxyInfo.GetIsUseProxy;
    edtProxyIP.Text := LPProxy^.FIP;
    sedtProxyPort.IntValue := LPProxy^.FPort;
    edtUserName.Text := LPProxy^.FUserName;
    edtPassword.Text := LPProxy^.FPassword;
    chkIsNTLM.Checked := (LPProxy^.FIsUseNTLM = 1);
    edtDomain.Text := LPProxy^.FNTLMDomain;
    if LPProxy^.FType = ptHttp then begin
      rdbtnHttpProxy.Checked := True;
    end else if LPProxy^.FType = ptSocket4 then begin
      rdbtnSocks4.Checked := True;
    end else if LPProxy^.FType = ptSocket5 then begin
      rdbtnSocks5.Checked := True;
    end else begin

    end;
    chkIsUseProxyClick(nil);
    chkIsNTLMClick(nil);
  end;
end;

procedure TLoginSettingUI.UpdateLoginSettingDataToUserData;
var
  LPProxy: PProxy;
begin
  if FCfg <> nil then begin
    LPProxy := FCfg.GetSysCfg.GetProxyInfo.GetProxy;
    FCfg.GetSysCfg.GetProxyInfo.SetIsUseProxy(chkIsUseProxy.Checked);
    LPProxy^.FIP := edtProxyIP.Text;
    LPProxy^.FPort := sedtProxyPort.IntValue;
    LPProxy^.FUserName := edtUserName.Text;
    LPProxy^.FPassword := edtPassword.Text;
    if chkIsNTLM.Checked then begin
      LPProxy^.FIsUseNTLM := 1;
    end else begin
      LPProxy^.FIsUseNTLM := 0;
    end;
    LPProxy^.FNTLMDomain := edtDomain.Text;
    if rdbtnHttpProxy.Checked then begin
      LPProxy^.FType := ptHttp;
    end else if rdbtnSocks4.Checked then begin
      LPProxy^.FType := ptSocket4;
    end else if rdbtnSocks4.Checked then begin
      LPProxy^.FType := ptSocket5;
    end else begin
      LPProxy^.FType := ptNo;
    end;
    FCfg.GetSysCfg.GetProxyInfo.SaveCache;
  end;
end;

procedure TLoginSettingUI.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TLoginSettingUI.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TLoginSettingUI.chkIsNTLMClick(Sender: TObject);
begin
  lblDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
  edtDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
end;

procedure TLoginSettingUI.chkIsUseProxyClick(Sender: TObject);
begin
  lblProxyIP.Enabled := chkIsUseProxy.Checked;
  edtProxyIP.Enabled := chkIsUseProxy.Checked;

  lblProxyPort.Enabled := chkIsUseProxy.Checked;
  sedtProxyPort.Enabled := chkIsUseProxy.Checked;

  lblProxyType.Enabled := chkIsUseProxy.Checked;
  rdbtnHttpProxy.Enabled := chkIsUseProxy.Checked;
  rdbtnSocks5.Enabled := chkIsUseProxy.Checked;
  rdbtnSocks4.Enabled := chkIsUseProxy.Checked;

  lblUserInfo.Enabled := chkIsUseProxy.Checked;

  lblUserName.Enabled := chkIsUseProxy.Checked;
  edtUserName.Enabled := chkIsUseProxy.Checked;

  lblPassword.Enabled := chkIsUseProxy.Checked;
  edtPassword.Enabled := chkIsUseProxy.Checked;

  chkIsNTLM.Enabled := chkIsUseProxy.Checked;
  lblDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
  edtDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
end;

end.
