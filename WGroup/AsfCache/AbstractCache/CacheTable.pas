unit CacheTable;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-8
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  Generics.Collections;

const

  OPERATE_NONE      = $0;
  OPERATE_UPDATE    = $1;
  OPERATE_COMMIT    = $2;

type

  TCacheTable = class
  private
    // ������
    FName: string;
    // �� ID
    FIndexID: Integer;
    // �洢��ʽ
    FStorage: Integer;
    // ��汾
    FVersion: Integer;
    // Operate
    FOperate: Integer;
    // ���¼��
    FUpdateInterval: Cardinal;
    // �ύ���
    FCommitInterval: Cardinal;
    // LastUpdateTime
    FLastUpdateTime: Cardinal;
    // LastCommitTime
    FLastCommitTime: Cardinal;
    // ������� JSID
    FMaxJSID: Int64;
    // ɾ����� JSID
    FDelJSID: Int64;
    // ���ǲ����Ѿ�����
    FIsCreate: Boolean;
    // ������ Sql
    FCreateSql: string;
    // �������� sql
    FInsertSql: string;
    // ɾ������ sql
    FDeleteSql: string;
    // �������ݵ�ָ��
    FIndicator: string;
    // ����ɾ�����ݵ�ָ��
    FDeleteIndicator: string;

    // �洢������
    FColFields: TStringList;
    // ������
    FLock: TCSLock;
    // ���±��ʱ������ڴ������ (0: ��ʾ������; 1: ��ʾ�����ڴ�����)
    FUpdateMem: Integer;
    // ���µ����ݼ� key ��Ӧ������
    FUpdateMemFieldKey: string;
    // ����ڴ���Ҫ���µ�����
    FUpdateMemDic: TDictionary<string, string>;
  protected
    // ��ȡ��ʱ������
    function GetTempTableName: string;
    // ��ȡ��ʱɾ��������
    function GetTempDelTableName: string;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // �������ݵ�����
    procedure SetColFields(AColFields: string);
    // ��Ӹ������ݵ� Key
    procedure AddUpdateMem(AUpdateKey: string);
    // ��ȡ�������ݵ� Key
    function GetUpdateMemKeys: string;
    // ��ȡ�������ݵ� Key �ĸ���
    function GetUpdateMemKeyCount: Integer;

    property Name: string read FName write FName;
    property TempName: string read GetTempTableName;
    property TempDelName: string read GetTempDelTableName;
    property IndexID: Integer read FIndexID write FIndexID;
    property Storage: Integer read FStorage write FStorage;
    property Version: Integer read FVersion write FVersion;
    property Operate: Integer read FOperate write FOperate;
    property MaxJSID: Int64 read FMaxJSID write FMaxJSID;
    property DelJSID: Int64 read FDelJSID write FDelJSID;
    property UpdateInterval: Cardinal read FUpdateInterval write FUpdateInterval;
    property CommitInterval: Cardinal read FCommitInterval write FCommitInterval;
    property LastUpdateTime: Cardinal read FLastUpdateTime write FLastUpdateTime;
    property LastCommitTime: Cardinal read FLastCommitTime write FLastCommitTime;
    property IsCreate: Boolean read FIsCreate write FIsCreate;
    property CreateSql: string read FCreateSql write FCreateSql;
    property InsertSql: string read FInsertSql write FInsertSql;
    property DeleteSql: string read FDeleteSql write FDeleteSql;
    property Indicator: string read FIndicator write FIndicator;
    property DeleteIndicator: string read FDeleteIndicator write FDeleteIndicator;
    property ColFields: TStringList read FColFields;
    property UpdateMem: Integer read FUpdateMem write FUpdateMem;
    property UpdateMemFieldKey: string read FUpdateMemFieldKey write FUpdateMemFieldKey;
  end;

implementation

{ TCacheTable }

constructor TCacheTable.Create;
begin
  FIndexID := 0;
  FStorage := 0;
  FVersion := 0;
  FMaxJSID := 0;
  FDelJSID := 0;
  FUpdateMem := 0;
  FLock := TCSLock.Create;
  FColFields := TStringList.Create;
  FUpdateMemDic := TDictionary<string, string>.Create;
end;

destructor TCacheTable.Destroy;
begin
  FUpdateMemDic.Free;
  FColFields.Free;
  FLock.Free;
  inherited;
end;

function TCacheTable.GetTempTableName: string;
begin
  Result := 'Temp_' + FName;
end;

function TCacheTable.GetTempDelTableName: string;
begin
  Result := 'TempDel_' + FName;
end;

procedure TCacheTable.SetColFields(AColFields: string);
begin
  FColFields.DelimitedText := AColFields;
end;

procedure TCacheTable.AddUpdateMem(AUpdateKey: string);
begin
  if AUpdateKey = '' then Exit;
  
  FLock.Lock;
  try
    FUpdateMemDic.AddOrSetValue(AUpdateKey, AUpdateKey);
  finally
    FLock.UnLock;
  end;
end;

function TCacheTable.GetUpdateMemKeys: string;
var
  LEnum: TDictionary<string, string>.TPairEnumerator;
begin
  FLock.Lock;
  try
    Result := '';
    if FUpdateMemDic.Count <= 0 then begin
      Exit;
    end;

    LEnum := FUpdateMemDic.GetEnumerator;
    while LEnum.MoveNext do begin
      if Result = '' then begin
        Result := LEnum.Current.Key;
      end else begin
        Result := LEnum.Current.Key + ',' + Result;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TCacheTable.GetUpdateMemKeyCount: Integer;
begin
  FLock.Lock;
  try
    Result := FUpdateMemDic.Count;
  finally
    FLock.UnLock;
  end;
end;

end.
