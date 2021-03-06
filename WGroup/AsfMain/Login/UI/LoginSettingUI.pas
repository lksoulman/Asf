unit LoginSettingUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-12
// Comments：
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

  // 登录设置窗体
  TLoginSettingUI = class(TForm)
    // 设置 pagecontrol
    pagecontrolSetting: TRzPageControl;
    // 服务器设置页签
    sheetServerSetting: TRzTabSheet;
    // 代理设置页签
    sheetProxySetting: TRzTabSheet;
    // 底部
    pnlBottom: TPanel;
    // 确定 按钮
    btnOk: TRzButton;
    // 取消按钮
    btnCancel: TRzButton;
    // 服务器列表标签
    lblServerList: TLabel;
    // 单选列表
    cmbServerList: TRzComboBox;
    // NTLM 分组
    gpbxNTLM: TGroupBox;
    // 用户信息分组
    gpbxUserInfo: TGroupBox;
    // 代理类型分组
    gpbxProxyType: TGroupBox;
    // 是不是启用代理分组
    gpbxIsUserProxy: TGroupBox;
    // 代理服务IP标签
    lblProxyIP: TLabel;
    // 代理服务器端口标签
    lblProxyPort: TLabel;
    // 代理服务器类型标签
    lblProxyType: TLabel;
    // 代理服务用户信息标签
    lblUserInfo: TLabel;
    // 代理服务的用户名标签
    lblUserName: TLabel;
    // 代理服务的用户名标签
    lblPassword: TLabel;
    // 代理服务的域名标签
    lblDomain: TLabel;
    // 代理服务的域名输入框
    edtDomain: TRzEdit;
    // 代理服务IP输入框
    edtProxyIP: TRzEdit;
    // 代理服务的用户名输入框
    edtUserName: TRzEdit;
    // 代理服务的密码输入框
    edtPassword: TRzEdit;
    // 代理服务的端口输入框
    sedtProxyPort: TRzSpinEdit;
    // NTLM 复选框
    chkIsNTLM: TRzCheckBox;
    // 是不是使用代理
    chkIsUseProxy: TRzCheckBox;
    // sock5代理单选框
    rdbtnSocks5: TRzRadioButton;
    // sock4代理单选框
    rdbtnSocks4: TRzRadioButton;
    // Http代理单选框
    rdbtnHttpProxy: TRzRadioButton;
    // 窗口创建
    procedure FormCreate(Sender: TObject);
    // 窗口 Show
    procedure FormShow(Sender: TObject);
    // 键盘按下
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    // 单击确认
    procedure btnOkClick(Sender: TObject);
    // 单击取消
    procedure btnCancelClick(Sender: TObject);
    // 单击 NTLM
    procedure chkIsNTLMClick(Sender: TObject);
    // 单击是不是使用代理服务
    procedure chkIsUseProxyClick(Sender: TObject);
  private
    // 配置接口
    FCfg: ICfg;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
    // 初始化用户的设置数据到登录设置窗体
    procedure DoInitUserDataToSettingWindows;
  public
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext);
    // 释放不需要的资源
    procedure UnInitialize;
    // 更新登录设置数据到用户数据
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
    FCfg.GetSysCfg.GetProxyInfo.WriteLocalCacheCfg;
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
