unit LoginMainUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Login Main UI
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
  Vcl.Imaging.pngimage,
  Mask,
  Forms,
  RzEdit,
  RzPanel,
  RzButton,
  RzRadChk,
  RzPrgres,
  Cfg,
  AppContext;

const
  CONST_ReLogin_Times = 1;

type

  // ��¼�ص�����
  TCallBackLoginFunc = function: Boolean of Object;

  // ��¼����
  TLoginMainUI = class(TForm)
    // ��¼ͼƬ
    imgLogin: TImage;
    // �ر�ͼƬ
    imgClose: TImage;
    // ����ͼƬ
    imgSetting: TImage;
    // ����ͼƬ
    imgBackground: TImage;
    // ��¼������Ϣ��ʾ��ǩ
    lblLoadInfo: TLabel;
    // ��¼���ؽ�����ʾ��ǩ
    lblLoadProgress: TLabel;
    // �û����������
    edtUserName: TEdit;
    // �û��������������
    edtPlainPassword: TEdit;
    // �û��������������
    edtCipherPassword: TEdit;
    // �ǲ��Ǳ������븴ѡ��
    ckbIsSavePassword: TRzCheckBox;
    // �Զ����Ե�¼
    tmrAutoAttemptLogin: TTimer;
    // ���ڹر�ʱ��
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    // ���ڴ�С�仯
    procedure FormResize(Sender: TObject);
    // ���� Show
    procedure FormShow(Sender: TObject);
    // ���ڰ��¼���
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    // ���ڹر�ʱ��
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    // �������¼ͼƬ
    procedure imgLoginMouseEnter(Sender: TObject);
    // ����뿪��¼ͼƬ
    procedure imgLoginMouseLeave(Sender: TObject);
    // ����������ͼƬ
    procedure imgSettingMouseEnter(Sender: TObject);
    // ����뿪����ͼƬ
    procedure imgSettingMouseLeave(Sender: TObject);
    // ��굥����¼ͼƬ
    procedure imgLoginClick(Sender: TObject);
    // ��굥���ر�ͼƬ
    procedure imgCloseClick(Sender: TObject);
    // ��굥������ͼƬ
    procedure imgSettingClick(Sender: TObject);
    // ��갴�±���ͼƬ
    procedure imgBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    // �������û��������
    procedure edtUserNameEnter(Sender: TObject);
    // ���뿪�û��������
    procedure edtUserNameExit(Sender: TObject);
    // ���������û��������ı�
    procedure edtUserNameChange(Sender: TObject);
    // �������������������
    procedure edtCipherPasswordEnter(Sender: TObject);
    // ���뿪�������������
    procedure edtCipherPasswordExit(Sender: TObject);
    // ���뿪����������������ı�
    procedure edtCipherPasswordChange(Sender: TObject);
  private
    // ���ýӿ�
    FCfg: ICfg;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��¼�ص�����
    FLoginFunc: TCallBackLoginFunc;
  protected
    // ��ʼ������ؼ�λ�úʹ�С
    procedure DoInitWindow;
    // ����Բ�Ǵ���
    procedure DoCreateRoundWindow;
    // ��ʼ��ͼƬ������
    procedure DoInitWindowImages;
    // �����û���Ϣ����¼����
    procedure DoSetUserInfoToWindow;
    // ���õ�¼�������Ϣ���û���Ϣ
    procedure DoSetWindowToUserInfo;
    // ��У��У��
    function DoSimpleCheck(var AErrorMsg: string): Boolean;
    // ����ͼƬ
    procedure DoLoadImage(AImage: TImage; AImageName: string);
    // չʾ���ؽ���
    procedure DoShowLoadProcess(AMsg: string; AProcessValue: Integer);
  public
    // ���캯��
    constructor Create(AContext: IAppContext); reintroduce;
    // ��������
    Destructor Destroy; override;
    // չʾ��¼
    function ShowLogin: Integer;
    // ��¼������չʾ�󶨴���
    function ShowLoginBindUI: Integer;
    // ��¼������չʾ��¼��Ϣ
    procedure ShowLoginInfo(AMsg: string);
    // ���õ�¼�ص�����
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
  end;

implementation

uses
  UserInfo,
  LoginBindUI,
  LoginSettingUI;

const
  PROGRESS_MAX = 8;
  // ��¼�û��������Ĭ����ʾ����
  LOGIN_USERNAME = '�û���';
  // ��¼���������Ĭ����ʾ����
  LOGIN_PASSWORD = '��  ��';

{$R *.dfm}

{ TLoginMainUI }

constructor TLoginMainUI.Create(AContext: IAppContext);
begin
  inherited Create(nil);
  FAppContext := AContext;
  edtUserName.TabOrder := 0;
  edtCipherPassword.TabOrder := 1;
  ckbIsSavePassword.TabOrder := 2;
  // ��XP�����£�������ʾȫ������������λ���������á�
  DoInitWindow;
  FCfg := FAppContext.GetCfg;
  DoInitWindowImages;
end;

destructor TLoginMainUI.Destroy;
begin
  FCfg := nil;
  inherited;
end;

function TLoginMainUI.ShowLogin: Integer;
begin
  DoSetUserInfoToWindow;
  if ShowModal = mrOk then begin
    Result := mrOk;
  end else begin
    Result := mrCancel;
  end;
end;

function TLoginMainUI.ShowLoginBindUI: Integer;
var
  LLoginBindUI: TLoginBindUI;
begin
  LLoginBindUI := TLoginBindUI.Create(nil);
  try
    LLoginBindUI.PopupParent := Self;
    if LLoginBindUI.ShowModal = mrOk then begin
      if FCfg <> nil then begin
        FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName := LLoginBindUI.GetBindAccount;
      end;
      Result := mrOk;
    end else begin
      Result := mrCancel;
    end;
  finally
    LLoginBindUI.Free;
  end;
end;

procedure TLoginMainUI.ShowLoginInfo(AMsg: string);
begin
  lblLoadProgress.Visible := True;
  lblLoadProgress.Caption := AMsg;
  Application.ProcessMessages;
end;

procedure TLoginMainUI.SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
begin
  FLoginFunc := ALoginFunc;
end;

procedure TLoginMainUI.DoCreateRoundWindow;
var
  RGN: HRGN;
begin
  RGN := CreateRoundRectRGN(0, 0, Width + 1, Height + 1, 15, 15);
  SetWindowRgn(Handle, RGN, True);
  DeleteObject(RGN);
end;

procedure TLoginMainUI.DoInitWindowImages;
begin
  DoLoadImage(imgBackground, 'LoginBack.png');
  DoLoadImage(imgSetting, 'Setting.png');
  DoLoadImage(imgClose, 'Close.png');
  DoLoadImage(imgLogin, 'LoginBtn.png');
  SetWindowLong(Self.Handle, GWL_EXSTYLE, GetWindowLong(Self.Handle, GWL_EXSTYLE) { or WS_EX_TOPMOST } or
    WS_EX_APPWINDOW);
end;

procedure TLoginMainUI.DoSetUserInfoToWindow;
var
  LUserName: string;
  LPassword: string;
begin
  if FCfg <> nil then begin
    case FCfg.GetSysCfg.GetUserInfo.GetAccountType of
      atUFX:
        begin
          LUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
          if FCfg.GetSysCfg.GetUserInfo.GetSavePassword then begin
            LPassword := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
      atGIL:
        begin
          LUserName := FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName;
          if FCfg.GetSysCfg.GetUserInfo.GetSavePassword then begin
            LPassword := FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
      atPBOX:
        begin
          LUserName := FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FUserName;
          if FCfg.GetSysCfg.GetUserInfo.GetSavePassword then begin
            LPassword := FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
    end;
  end;

  if LUserName = '' then begin
    edtUserName.Font.Color := $00B7B7B7;
    edtUserName.Text := LOGIN_USERNAME;
  end else begin
    edtUserName.Font.Color := $00333333;
    edtUserName.Text := LUserName;
  end;

  if LPassword = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end else begin
    edtCipherPassword.Font.Color := $00333333;
    edtCipherPassword.PasswordChar := '*';
    edtCipherPassword.Text := LPassword;
  end;
end;

procedure TLoginMainUI.DoSetWindowToUserInfo;
begin
  if FCfg <> nil then begin
    case FCfg.GetSysCfg.GetUserInfo.GetAccountType of
      atUFX:
        begin
          FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo^.FUserName := edtUserName.Text;
          FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo^.FPassword := edtCipherPassword.Text;
          FCfg.GetSysCfg.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
      atGIL:
        begin
          FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo^.FUserName := edtUserName.Text;
          FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo^.FPassword := edtCipherPassword.Text;
          FCfg.GetSysCfg.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
      atPBOX:
        begin
          FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo^.FUserName := edtUserName.Text;
          FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo^.FPassword := edtCipherPassword.Text;
          FCfg.GetSysCfg.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
    end;
  end;
end;

function TLoginMainUI.DoSimpleCheck(var AErrorMsg: string): Boolean;
begin
  AErrorMsg := '';
  Result := False;
  if (edtUserName.Text = '')
    or (edtUserName.Text = LOGIN_USERNAME) then begin
    AErrorMsg := '�������¼�û�';
    if (edtCipherPassword.Text = '')
      or (edtCipherPassword.Text = LOGIN_PASSWORD) then begin
      AErrorMsg := AErrorMsg + '������';
    end;
    Exit;
  end else begin
    if (edtCipherPassword.Text = '')
      or (edtCipherPassword.Text = LOGIN_PASSWORD) then begin
      AErrorMsg := '�������¼����';
      Exit;
    end;
  end;
  Result := True;
end;

procedure TLoginMainUI.DoLoadImage(AImage: TImage; AImageName: string);
var
  LFile: string;
begin
  if AImage = nil then Exit;
  if FCfg = nil then Exit;

  LFile := FCfg.GetSkinPath + 'Login\' + AImageName;
  if FileExists(LFile) then begin
    AImage.Picture.LoadFromFile(LFile);
  end;
end;

procedure TLoginMainUI.DoInitWindow;
begin
  Self.Width := 460;
  Self.Height := 350;

  with imgLogin do begin
    Left := 109;
    Top := 275;
    Width := 242;
    Height := 32;
  end;

  with imgSetting do begin
    Left := 407;
    Top := 1;
    Width := 26;
    Height := 26;
  end;

  with imgClose do begin
    Left := 434;
    Top := 1;
    Width := 26;
    Height := 26;
  end;

  with edtUserName do begin
    Left := 149;
    Top := 192;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with edtPlainPassword do begin
    Left := 149;
    Top := 231;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with edtCipherPassword do begin
    Left := 149;
    Top := 231;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with ckbIsSavePassword do begin
    Left := 360;
    Top := 233;
  end;

  with lblLoadInfo do begin
    Left := 144;
    Top := 312;
    Width := 57;
    Height := 33;
    Font.Height := -12;
  end;

  with lblLoadProgress do begin
    Left := 72;
    Top := 312;
    Width := 345;
    Height := 33;
    Font.Height := -12;
  end;
end;

procedure TLoginMainUI.DoShowLoadProcess(AMsg: string; AProcessValue: Integer);
begin
  lblLoadProgress.Caption := Format('%d%%  ', [AProcessValue]) + AMsg;
  Update;
end;

procedure TLoginMainUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetWindowRgn(Handle, 0, False);
end;

procedure TLoginMainUI.FormResize(Sender: TObject);
begin
  DoCreateRoundWindow;
end;

procedure TLoginMainUI.FormShow(Sender: TObject);
begin
  Caption := 'FAIS��½';
  Enabled := True;
  lblLoadProgress.Visible := False;
  edtPlainPassword.Visible := False;
  edtCipherPassword.Visible := True;
end;

procedure TLoginMainUI.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  AnimateWindow(Handle, 300, AW_BLEND or AW_HIDE);
end;

procedure TLoginMainUI.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and IsWindowEnabled(Self.Handle) then begin
    imgLoginClick(nil);
  end;
end;

procedure TLoginMainUI.imgBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // ��갴������ƶ�����
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TLoginMainUI.imgCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  if FAppContext <> nil then begin
    FAppContext.ExitApp;
  end;
end;

procedure TLoginMainUI.imgLoginClick(Sender: TObject);
var
  LResult: Boolean;
  LErrorMsg: string;
begin
  LResult := False;
  Enabled := False;
  try
    if DoSimpleCheck(LErrorMsg) then begin
      DoSetWindowToUserInfo;
      if Assigned(FLoginFunc) then begin
        LResult := FLoginFunc;
      end else begin
        LResult := True;
      end;
    end else begin
      ShowLoginInfo(LErrorMsg);
    end;
  finally
    Enabled := True;
  end;
  // ��ʾ��¼�ɹ�
  if LResult then begin
    ModalResult := mrOk;
  end;
end;

procedure TLoginMainUI.imgLoginMouseEnter(Sender: TObject);
begin
  if imgLogin.Enabled then begin
    DoLoadImage(imgLogin, 'LoginBtn_Hot.png');
  end;
end;

procedure TLoginMainUI.imgLoginMouseLeave(Sender: TObject);
begin
  DoLoadImage(imgLogin, 'LoginBtn.png');
end;

procedure TLoginMainUI.imgSettingClick(Sender: TObject);
var
  LRect: TRect;
  LMonitor: TMonitor;
  LLoginSettingUI: TLoginSettingUI;
begin
  LLoginSettingUI := TLoginSettingUI.Create(nil);
  try
    LLoginSettingUI.Parent := Self;
    LLoginSettingUI.Initialize(FAppContext);
    LMonitor := Screen.MonitorFromWindow(Self.Handle);
    if LMonitor = nil then begin
      LMonitor := Self.Monitor;
    end;
    LRect := LMonitor.WorkareaRect;
    LLoginSettingUI.Top := (LRect.Height - LLoginSettingUI.Height) div 2;
    LLoginSettingUI.Left := (LRect.Width - LLoginSettingUI.Width) div 2;
    if LLoginSettingUI.ShowModal = mrOK then begin
      LLoginSettingUI.UpdateLoginSettingDataToUserData;
    end;
  finally
    LLoginSettingUI.UnInitialize;
    LLoginSettingUI.Free;
  end;
end;

procedure TLoginMainUI.imgSettingMouseEnter(Sender: TObject);
begin
  if (Sender as TImage).Tag = 0 then begin
    DoLoadImage(imgSetting, 'Setting_Hot.png')
  end else begin
    DoLoadImage(imgClose, 'Close_Hot.png');
  end;
end;

procedure TLoginMainUI.imgSettingMouseLeave(Sender: TObject);
begin
  if not Self.Visible then Exit;

  if (Sender as TImage).Tag = 0 then begin
    DoLoadImage(imgSetting, 'Setting.png')
  end else begin
    DoLoadImage(imgClose, 'Close.png');
  end;
end;

procedure TLoginMainUI.edtUserNameEnter(Sender: TObject);
begin
  if edtUserName.Text = LOGIN_USERNAME then begin
    edtUserName.Font.Color := $333333;
    edtUserName.Text := '';
  end;
end;

procedure TLoginMainUI.edtUserNameExit(Sender: TObject);
begin
  if edtUserName.Text = '' then begin
    edtUserName.Font.Color := $B7B7B7;
    edtUserName.Text := LOGIN_USERNAME;
  end;
end;

procedure TLoginMainUI.edtUserNameChange(Sender: TObject);
begin
  if edtUserName.Text = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end;
end;

procedure TLoginMainUI.edtCipherPasswordEnter(Sender: TObject);
begin
  if edtCipherPassword.Text = LOGIN_PASSWORD then begin
    edtCipherPassword.Font.Color := $00333333;
    edtCipherPassword.PasswordChar := '*';
    edtCipherPassword.Text := '';
  end;
  edtCipherPassword.SetFocus;
end;

procedure TLoginMainUI.edtCipherPasswordExit(Sender: TObject);
begin
  if edtCipherPassword.Text = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end;
end;

procedure TLoginMainUI.edtCipherPasswordChange(Sender: TObject);
begin
  // ��¼�иı�

end;

end.
