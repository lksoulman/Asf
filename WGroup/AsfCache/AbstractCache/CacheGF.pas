unit CacheGF;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-11
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf,
  CacheOperateType;

type

  // ���� GF ����
  TCacheGF = class
  private
    // ���� ID
    FID: Integer;
    // �ǲ��Ǹ��²���(�����״δ�����Ͳ�ѯ�������ݷ�����в��Ǹ��²���)
    FIsUpdate: Boolean;
    // ���ݼ�
    FDataSet: IWNDataSet;
    // �����������
    FOperateType: TCacheOperateType;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property IsUpdate: Boolean read FIsUpdate write FIsUpdate;
    property DataSet: IWNDataSet read FDataSet write FDataSet;
    property OperateType: TCacheOperateType read FOperateType write FOperateType;
  end;

implementation

{ TCacheGF }

constructor TCacheGF.Create;
begin
  FID := 0;
  FDataSet := nil;
  FIsUpdate := False;
end;

destructor TCacheGF.Destroy;
begin
  if FDataSet <> nil then begin
    FDataSet := nil;
  end;
  inherited;
end;

end.
