unit LoginBindUI;

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
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  RzButton,
  StdCtrls,
  Mask,
  RzEdit;

type

  // ���û�����
  TLoginBindUI = class(TForm)
    // ���˺�
    edtBindAccount: TRzEdit;
    // ȷ����ť
    btnOk: TRzButton;
    // ȡ����ť
    btnCancel: TRzButton;
    // ����ȷ����ť
    procedure btnOkClick(Sender: TObject);
    // ����ȡ����ť
    procedure btnCancelClick(Sender: TObject);
    // ����չʾ
    procedure FormShow(Sender: TObject);
    // ���̰���
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
    // ���ڴ�������
    procedure CreateParams(var Params: TCreateParams); override;
    // ��ȡ���˺�
    function GetBindAccount: string;
  end;

implementation

{$R *.dfm}

procedure TLoginBindUI.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TLoginBindUI.btnOkClick(Sender: TObject);
begin
  if trim(edtBindAccount.Text) = '' then
  begin
    MessageBox(Self.Handle, 'License����Ϊ�ա�', '��ʾ', MB_OK);
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TLoginBindUI.CreateParams(var Params: TCreateParams);
begin
  Params.ExStyle := Params.ExStyle or WS_EX_TOPMOST;
  inherited;
  edtBindAccount.TabStop := True;
  btnOk.TabStop := True;
  btnCancel.TabStop := True;
  edtBindAccount.TabOrder := 0;
  btnOk.TabOrder := 1;
  btnCancel.TabOrder := 2;
end;

function TLoginBindUI.GetBindAccount: string;
begin
  Result := edtBindAccount.Text;
end;

procedure TLoginBindUI.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
    btnOkClick(nil);
end;

procedure TLoginBindUI.FormShow(Sender: TObject);
begin
  Caption := 'FAIS�ն�License��';
end;

end.
