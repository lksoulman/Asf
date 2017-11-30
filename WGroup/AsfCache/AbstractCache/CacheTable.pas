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
  CommonRefCounter,
  Generics.Collections;

const

  OPERATE_NONE      = $0;
  OPERATE_UPDATE    = $1;
  OPERATE_COMMIT    = $2;

type

  TCacheTable = class(TAutoObject)
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
    // ���¼������
    FUpdateSecs: Integer;
    // �ύ�������
    FCommitSecs: Integer;
    // �ϴθ��µ�ʱ��
    FLastUpdateTime: TDateTime;
    // �ϴ��ύ��ʱ��
    FLastCommitTime: TDateTime;
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
    // ������
    FLock: TCSLock;
    // �洢������
    FColFields: TStringList;
  protected
    // ��ȡ��ʱ������
    function GetTempTableName: string;
    // ��ȡ��ʱɾ��������
    function GetTempDelTableName: string;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // SetColFields
    procedure SetColFields(AColFields: string);

    property Name: string read FName write FName;
    property TempName: string read GetTempTableName;
    property TempDelName: string read GetTempDelTableName;
    property IndexID: Integer read FIndexID write FIndexID;
    property Storage: Integer read FStorage write FStorage;
    property Version: Integer read FVersion write FVersion;
    property Operate: Integer read FOperate write FOperate;
    property MaxJSID: Int64 read FMaxJSID write FMaxJSID;
    property DelJSID: Int64 read FDelJSID write FDelJSID;
    property UpdateSecs: Integer read FUpdateSecs write FUpdateSecs;
    property CommitSecs: Integer read FCommitSecs write FCommitSecs;
    property LastUpdateTime: TDateTime read FLastUpdateTime write FLastUpdateTime;
    property LastCommitTime: TDateTime read FLastCommitTime write FLastCommitTime;
    property IsCreate: Boolean read FIsCreate write FIsCreate;
    property CreateSql: string read FCreateSql write FCreateSql;
    property InsertSql: string read FInsertSql write FInsertSql;
    property DeleteSql: string read FDeleteSql write FDeleteSql;
    property Indicator: string read FIndicator write FIndicator;
    property DeleteIndicator: string read FDeleteIndicator write FDeleteIndicator;
    property ColFields: TStringList read FColFields;
  end;

implementation

{ TCacheTable }

constructor TCacheTable.Create;
begin
  inherited;
  FIndexID := 0;
  FStorage := 0;
  FVersion := 0;
  FMaxJSID := 0;
  FDelJSID := 0;
  FUpdateSecs := MaxInt;
  FCommitSecs := MaxInt;
  FLastUpdateTime := 0;
  FLastCommitTime := 0;
  FLock := TCSLock.Create;
  FColFields := TStringList.Create;
end;

destructor TCacheTable.Destroy;
begin
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

procedure TCacheTable.Lock;
begin
  FLock.Lock;
end;

procedure TCacheTable.UnLock;
begin
  FLock.UnLock;
end;

procedure TCacheTable.SetColFields(AColFields: string);
begin
  FColFields.DelimitedText := AColFields;
end;

end.
