unit CacheTable;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-8
// Comments：
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
    // 表名称
    FName: string;
    // 表 ID
    FIndexID: Integer;
    // 存储方式
    FStorage: Integer;
    // 表版本
    FVersion: Integer;
    // Operate
    FOperate: Integer;
    // 更新间隔秒数
    FUpdateSecs: Integer;
    // 提交间隔秒数
    FCommitSecs: Integer;
    // 上次更新的时间
    FLastUpdateTime: TDateTime;
    // 上次提交的时间
    FLastCommitTime: TDateTime;
    // 更新最大 JSID
    FMaxJSID: Int64;
    // 删除最大 JSID
    FDelJSID: Int64;
    // 表是不是已经创建
    FIsCreate: Boolean;
    // 创建表 Sql
    FCreateSql: string;
    // 插入数据 sql
    FInsertSql: string;
    // 删除数据 sql
    FDeleteSql: string;
    // 请求数据的指标
    FIndicator: string;
    // 请求删除数据的指标
    FDeleteIndicator: string;
    // 数据锁
    FLock: TCSLock;
    // 存储列明的
    FColFields: TStringList;
  protected
    // 获取临时表名称
    function GetTempTableName: string;
    // 获取临时删除表名称
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
