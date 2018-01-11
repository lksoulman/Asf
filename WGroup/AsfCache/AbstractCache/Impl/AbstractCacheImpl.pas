unit AbstractCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cache Implementation
// Author£º      lksoulman
// Date£º        2017-8-8
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  GFData,
  CacheGF,
  Windows,
  Classes,
  SysUtils,
  DateUtils,
  Vcl.Forms,
  NativeXml,
  GFDataSet,
  CacheTable,
  BaseObject,
  AppContext,
  CommonLock,
  ServiceType,
  CommonQueue,
  LiteCallUni,
  MsgExService,
  WNDataSetInf,
  SQLiteAdapter,
  ExecutorThread,
  CacheOperateType,
  Generics.Collections;

const
  DLLNAME_SQLITE = 'AsfLib/AsfSqlite.dll';    //Sqlite.dll
  REPLACE_STR_JSID      = '!JSID';

type

  // AbstractCache Implementation
  TAbstractCacheImpl = class(TBaseInterfacedObject)
  private
  protected
    // CacheName
    FName: string;
    // CfgFile
    FCfgFile: string;
    // IsStopService
    FIsStopService: Boolean;
    // Lock
    FLock: TCSLock;
    // System Table
    FSysTable: TCacheTable;
    // ServiceType
    FServiceType: TServiceType;
    // CacheTables
    FCacheTables: TList<TCacheTable>;
    // CacheTableDic
    FCacheTableDic: TDictionary<string, TCacheTable>;
    // UpdateNotifyCacheTableDic
    FUpdateNotifyCacheTableDic: TDictionary<string, string>;
    // SQLiteAdapter
    FSQLiteAdapter: TSQLiteAdapter;
    // ArriveCacheGFQueue
    FArriveCacheGFQueue: TSafeQueue<TCacheGF>;
    // ProcessCacheGFQueueThread
    FProcessCacheGFQueueThread: TExecutorThread;

    // StopService
    procedure DoStopService; virtual;
    // LoadCfgBefore
    procedure DoLoadCfgBefore; virtual;
    // LoadTablesCfg
    procedure DoLoadTablesCfg;
    // ClearCacheTables;
    procedure DoClearCacheTables;
    // ClearCacheGFQueue
    procedure DoClearCacheGFQueue;
    // ReplaceCreateSysTable
    procedure DoReplaceCreateSysTable;
    // DoReplaceCreateCacheTables
    procedure DoReplaceCreateCacheTables;
    // LoadCacheTableInfoFromSysTable
    procedure DoLoadCacheTableInfoFromSysTable;


    // Get Table By Index
    function GetTableByIndex(AIndex: Integer): TCacheTable;
    // Create Table By Node
    function CreateTableByNode(ANode: TXmlNode): TCacheTable;
    // UpdateSysTable
    procedure DoUpdateSysTable(ATable: TCacheTable);
    // InsertCacheTable
    procedure DoInsertCacheTable(ATable: TCacheTable; ADataSet: IWNDataSet);
    // DeleteCacheTable
    procedure DoDeleteCacheTable(ATable: TCacheTable; ADataSet: IWNDataSet);
    // UpdateDataFromCacheTable
    procedure DoInsertDataSetToCacheTable(ADataSet: IWNDataSet; ATable: TCacheTable;
      AFields: TList<IWNField>; AJSIDField: IWNField);
    // DeleteDataFromCacheTable
    procedure DoDeleteDataSetToCacheTable(ADataSet: IWNDataSet; ATable: TCacheTable;
      AIDField: IWNField; AJSIDField: IWNField);

    // Create Temp Table
    procedure CreateTempTable(ATable: TCacheTable);
    // Delete Temp Table
    procedure DeleteTempTable(ATable: TCacheTable);
    // Create Temp Delete Table
    procedure CreateTempDeleteTable(ATable: TCacheTable);
    // Delete Temp Delete Table
    procedure DeleteTempDeleteTable(ATable: TCacheTable);

    // CommitCacheTables
    procedure DoCommitCacheTables;
    // UpdateCacheTables
    procedure DoUpdateCacheTables;
    // AsyncUpdateCacheTables
    procedure DoAsyncUpdateCacheTables;

    // CommitCacheTable
    procedure DoCommitCacheTable(ATable: TCacheTable); virtual;
    // UpdateCacheTable
    procedure DoUpdateCacheTable(ATable: TCacheTable); virtual;
    // AsyncUpdateCacheTable
    procedure DoAsyncUpdateCacheTable(ATable: TCacheTable); virtual;
    // UpdateNotifyCacheTable
    procedure DoUpdateNotifyCacheTable(ATable: TCacheTable; AInfo: string); virtual;

    // GFUpdateDataArrive
    procedure DoGFUpdateDataArrive(AGFData: IGFData);
    // GFDeleteDataArrive
    procedure DoGFDeleteDataArrive(AGFData: IGFData);
    // ProcessCacheGFQueueExecute
    procedure DoProcessCacheGFQueueExecute(Sender: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    // IsExistCacheTable
    function IsExistCacheTable(AName: string): Boolean;
    // SetAttachDB
    procedure SetAttachDB(ADBFile, ADBAlias, APassword: string);
  end;

implementation

uses
  DB,
  Utils,
  LogLevel,
  Command;

const
  

  FIELD_JSID = 'JSID';

  SYSTABLE_FIELD_TABLENAME = 'TableName';
  SYSTABLE_FIELD_STORAGE = 'Storage';
  SYSTABLE_FIELD_VERSION = 'Version';
  SYSTABLE_FIELD_MAXJSID = 'MaxJSID';
  SYSTABLE_FIELD_DELJSID = 'DelJSID';

  REPLACE_STR_TABLENAME = '#TableName';

  SQL_QUERY_SYSTABLE = 'SELECT TableName, Storage, Version, MaxJSID, DelJSID FROM SysTable';
  SQL_TEMP_TABLE_CREATE = 'CREATE TEMP TABLE IF NOT EXISTS %s AS SELECT * FROM %s LIMIT 0';
  SQL_TEMP_TABLE_DELETE = 'DELETE FROM %s';
  SQL_COPY_TABLE_TO_TABLE = 'INSERT OR REPLACE INTO %s SELECT * FROM %s';
  SQL_TEMP_DEL_TABLE_CREATE = 'CREATE TEMP TABLE IF NOT EXISTS %s ("RecID" BIGINT NOT NULL PRIMARY KEY)';
  SQL_TEMP_DEL_TABLE_INSERT = 'INSERT OR REPLACE INTO %s VALUES (?)';
  SQL_TEMP_DEL_TABLE_DELETE = 'DELETE FROM %s WHERE ID IN (SELECT RecID FROM %s)';


{ TAbstractCacheImpl }

constructor TAbstractCacheImpl.Create(AContext: IAppContext);
begin
  inherited;
  FServiceType := stBasic;
  FLock := TCSLock.Create;
  FCacheTables := TList<TCacheTable>.Create;
  FCacheTableDic := TDictionary<string, TCacheTable>.Create;
  FUpdateNotifyCacheTableDic := TDictionary<string, string>.Create;
  FSQLiteAdapter := TSQLiteAdapter.Create(FAppContext);
  FSQLiteAdapter.DLLName := DLLNAME_SQLITE;
  FSQLiteAdapter.LoadClassName := Self.ClassName;
  FArriveCacheGFQueue := TSafeQueue<TCacheGF>.Create;
  FProcessCacheGFQueueThread := TExecutorThread.Create;
  FProcessCacheGFQueueThread.ThreadMethod := DoProcessCacheGFQueueExecute;
  FProcessCacheGFQueueThread.StartEx;
  FIsStopService := False;
  DoLoadCfgBefore;
  FSQLiteAdapter.ConnectDB;
  DoLoadTablesCfg;
  DoReplaceCreateSysTable;
  DoLoadCacheTableInfoFromSysTable;
end;

destructor TAbstractCacheImpl.Destroy;
begin
  DoStopService;
  FSQLiteAdapter.DisConnectDB;
  DoClearCacheGFQueue;
  DoClearCacheTables;
  FArriveCacheGFQueue.Free;
  FSQLiteAdapter.Free;
  FUpdateNotifyCacheTableDic.Free;
  FCacheTableDic.Free;
  FCacheTables.Free;
  FLock.Free;
  inherited;
end;

function TAbstractCacheImpl.IsExistCacheTable(AName: string): Boolean;
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(AName, LTable)
    and Assigned(LTable) and LTable.IsCreate then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

procedure TAbstractCacheImpl.SetAttachDB(ADBFile, ADBAlias, APassword: string);
begin
  FSQLiteAdapter.SetAttachDB(ADBFile, ADBAlias, APassword);
end;

procedure TAbstractCacheImpl.DoStopService;
begin
  if not FIsStopService then begin
    FProcessCacheGFQueueThread.ShutDown;
    FIsStopService := True;
  end;
end;

procedure TAbstractCacheImpl.DoLoadCfgBefore;
begin

end;

procedure TAbstractCacheImpl.DoLoadTablesCfg;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LNode: TXmlNode;
  LXml: TNativeXml;
  LNodeList: TList;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    if FileExists(FCfgFile) then begin
      LXml := TNativeXml.Create(nil);
      try
        LXml.LoadFromFile(FCfgFile);
        LXml.XmlFormat := xfReadable;
        LNode := LXml.Root;

        FSysTable := CreateTableByNode(LNode.FindNode('SysTable'));
        if FSysTable = nil then begin
          if FAppContext <> nil then begin
            FAppContext.SysLog(llError, Format('[%s][DoLoadTablesCfg][%s] Cache create table is nil.', [Self.ClassName, 'SysTable']));
          end;
          Exit;
        end;

        LNodeList := TList.Create;
        try
          LNode.FindNodes('Table', LNodeList);
          for LIndex := 0 to LNodeList.Count - 1 do begin
            LTable := CreateTableByNode(LNodeList.Items[LIndex]);
            if LTable <> nil then begin
              LTable.IndexID := FCacheTables.Add(LTable);
              FCacheTableDic.AddOrSetValue(LTable.Name, LTable);
            end else begin
              if FAppContext <> nil then begin
                FAppContext.SysLog(llError, Format('[%s][DoLoadTablesCfg] Cache create table is nil.', [Self.ClassName]));
              end;
              Exit;
            end;
          end;
        finally
          LNodeList.Free;
        end;
      finally
        LXml.Free;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][LoadTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

procedure TAbstractCacheImpl.DoClearCacheTables;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FCacheTables.Count - 1 do begin
    if FCacheTables.Items[LIndex] <> nil then begin
      FCacheTables.Items[LIndex].Free;
    end;
  end;
  FCacheTables.Clear;
  FCacheTableDic.Clear;

  if FSysTable <> nil then begin
    FSysTable.Free;
    FSysTable := nil;
  end;
end;

procedure TAbstractCacheImpl.DoClearCacheGFQueue;
var
  LCacheGF: TCacheGF;
begin
  while not FArriveCacheGFQueue.IsEmpty do begin
    LCacheGF := FArriveCacheGFQueue.Dequeue;
    if LCacheGF <> nil then begin
      LCacheGF.Free;
    end;
  end;
end;

procedure TAbstractCacheImpl.DoReplaceCreateSysTable;
begin
  FSQLiteAdapter.ExecuteSql(FSysTable.CreateSql);
end;

procedure TAbstractCacheImpl.DoReplaceCreateCacheTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin
      LTable := FCacheTables.Items[LIndex];
      if (LTable <> nil) and (not LTable.IsCreate) then begin
        FSQLiteAdapter.ExecuteSql(LTable.CreateSql);
        DoUpdateSysTable(LTable);
        LTable.IsCreate := True;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][DoReplaceCreateCacheTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

procedure TAbstractCacheImpl.DoLoadCacheTableInfoFromSysTable;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
  LNameField, LVersionField, LMaxField, LDelField: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FSQLiteAdapter.ExecuteSql(FSysTable.CreateSql);
    LDataSet := FSQLiteAdapter.QuerySql(SQL_QUERY_SYSTABLE);
    if (LDataSet <> nil) then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        LNameField := LDataSet.FieldByName(SYSTABLE_FIELD_TABLENAME);
        LVersionField := LDataSet.FieldByName(SYSTABLE_FIELD_VERSION);
        LMaxField := LDataSet.FieldByName(SYSTABLE_FIELD_MAXJSID);
        LDelField := LDataSet.FieldByName(SYSTABLE_FIELD_DELJSID);
        while not LDataSet.Eof do begin
          if FCacheTableDic.TryGetValue(LNameField.AsString, LTable)
            and (LTable <> nil) then begin
            if LVersionField.AsInteger = LTable.Version then begin
              LTable.IsCreate := True;
            end else begin
              LTable.IsCreate := False;
            end;
            LTable.MaxJSID := LMaxField.AsInt64;
            LTable.DelJSID := LDelField.AsInt64;
          end;
          LDataSet.Next;
        end;
      end;
      LDataSet := nil;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][InitSysTable] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

function TAbstractCacheImpl.CreateTableByNode(ANode: TXmlNode): TCacheTable;
begin
  Result := nil;
  if ANode = nil then Exit;

  Result := TCacheTable.Create;
  Result.Name := Utils.GetStringByChildNodeName(ANode, 'Name');
  Result.Version := Utils.GetIntegerByChildNodeName(ANode, 'Version', Result.Version);
  Result.UpdateSecs := Utils.GetIntegerByChildNodeName(ANode, 'UpdateSecs', MaxInt);
  Result.CommitSecs := Utils.GetIntegerByChildNodeName(ANode, 'CommitSecs', MaxInt);
  Result.CreateSql := Utils.GetStringByChildNodeName(ANode, 'CreateSql');
  Result.InsertSql := Utils.GetStringByChildNodeName(ANode, 'InsertSql');
  Result.DeleteSql := Utils.GetStringByChildNodeName(ANode, 'DeleteSql');
  Result.Indicator := Utils.GetStringByChildNodeName(ANode, 'Indicator');
  Result.DeleteIndicator := Utils.GetStringByChildNodeName(ANode, 'DeleteIndicator');
  Result.ColFields.DelimitedText := Utils.GetStringByChildNodeName(ANode, 'ColFields');
end;

function TAbstractCacheImpl.GetTableByIndex(AIndex: Integer): TCacheTable;
begin
  if (AIndex >= 0) and (AIndex < FCacheTables.Count) then begin
    Result := FCacheTables.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

procedure TAbstractCacheImpl.DoUpdateSysTable(ATable: TCacheTable);
begin
  FSQLiteAdapter.ExecuteSql(Format(FSysTable.InsertSql, [ATable.Name,
      ATable.Storage, ATable.Version, ATable.MaxJSID, ATable.DelJSID]));
end;

procedure TAbstractCacheImpl.DoInsertCacheTable(ATable: TCacheTable; ADataSet: IWNDataSet);
var
  LIndex: Integer;
  LIsUpdate: Boolean;
  LFields: TList<IWNField>;
  LField, LJSIDField: IWNField;
begin
  LFields := TList<IWNField>.Create;
  try
    LIsUpdate := True;
    LJSIDField := ADataSet.FieldByName(FIELD_JSID);
    for LIndex := 0 to ATable.ColFields.Count - 1 do begin
      LField := ADataSet.FieldByName(ATable.ColFields.Strings[LIndex]);
      if LField <> nil then begin
        LFields.Add(LField);
      end else begin
        LIsUpdate := False;
        break;
      end;
    end;
    if LIsUpdate then begin
      DoInsertDataSetToCacheTable(ADataSet, ATable, LFields, LJSIDField);
    end;
  finally
    LFields.Free;
  end;
end;

procedure TAbstractCacheImpl.DoDeleteCacheTable(ATable: TCacheTable; ADataSet: IWNDataSet);
var
  LFields: TList<IWNField>;
  LIDField, LJSIDField: IWNField;
begin
  LFields := TList<IWNField>.Create;
  try
    if (ADataSet.RecordCount > 0)
      and (ADataSet.FieldCount > 0) then begin
      LIDField := ADataSet.Fields(0);
      if LIDField <> nil then begin
        LJSIDField := ADataSet.FieldByName(FIELD_JSID);
        DoDeleteDataSetToCacheTable(ADataSet, ATable, LIDField, LJSIDField);
      end;
    end;
  finally
    LFields.Free;
  end;
end;

procedure TAbstractCacheImpl.DoInsertDataSetToCacheTable(ADataSet: IWNDataSet; ATable: TCacheTable;
  AFields: TList<IWNField>; AJSIDField: IWNField);
var
  LIndex: Integer;
  LSql: AnsiString;
  LIsSuccess: Boolean;
  LAPIStmt: pSQLite3Stmt;
  LRetCode, LMaxJSID: Int64;
begin
  LIsSuccess := False;
  LMaxJSID := ATable.MaxJSID;
  FSQLiteAdapter.BeginWrite;
  try
    FSQLiteAdapter.StartTransaction;
    try
      try
        CreateTempTable(ATable);
        DeleteTempTable(ATable);
        LSql := AnsiString(StringReplace(ATable.InsertSql, REPLACE_STR_TABLENAME,
          ATable.TempName, [rfReplaceAll]));
        LRetCode := FSQLiteAdapter.Prepare(LSql, LAPIStmt);
        if LRetCode = 0 then begin
          ADataSet.First;
          while not ADataSet.Eof do begin
            FSQLiteAdapter.Reset(LAPIStmt);
            for LIndex := 0 to ATable.ColFields.Count - 1 do begin
              FSQLiteAdapter.BindField(LAPIStmt, AFields[LIndex], LIndex + 1);
            end;
            FSQLiteAdapter.Step(LAPIStmt);
            if (AJSIDField <> nil)
              and (not AJSIDField.IsNull)
              and (AJSIDField.AsInt64 > ATable.MaxJSID) then begin
              ATable.MaxJSID := AJSIDField.AsInt64;
            end;
            ADataSet.Next;
          end;
          FSQLiteAdapter.ExecuteSql(Format(SQL_COPY_TABLE_TO_TABLE, [ATable.Name,
            ATable.TempName]));
          DeleteTempTable(ATable);
          DoUpdateSysTable(ATable);
          FSQLiteAdapter.Commit;
          LIsSuccess := True;
        end;
      except
        on Ex: Exception do begin
          if FAppContext <> nil then begin
            FAppContext.SysLog(llERROR, Format('[%s][DoUpdateDataFromCacheTable] Update is exception, exception is %s.', [Self.ClassName, Ex.Message]));
          end;
        end;
      end;
    finally
      if not LIsSuccess then begin
        ATable.MaxJSID := LMaxJSID;
        FSQLiteAdapter.Rollback;
      end;
      if Assigned(LAPIStmt) then begin
        FSQLiteAdapter.Finalize(LAPIStmt);
      end;
    end;
  finally
    FSQLiteAdapter.EndWrite;
  end;
end;

procedure TAbstractCacheImpl.DoDeleteDataSetToCacheTable(ADataSet: IWNDataSet; ATable: TCacheTable; AIDField: IWNField; AJSIDField: IWNField);
var
  LRetCode: Int64;
  LSql: AnsiString;
  LDelJSID: Integer;
  LIsSuccess: Boolean;
  LAPIStmt: pSQLite3Stmt;
begin
  LIsSuccess := False;
  LDelJSID := ATable.DelJSID;
  FSQLiteAdapter.BeginWrite;
  try
    FSQLiteAdapter.StartTransaction;
    try
      try
        CreateTempDeleteTable(ATable);
        DeleteTempDeleteTable(ATable);
        LSql := AnsiString(Format(SQL_TEMP_DEL_TABLE_INSERT, [ATable.TempDelName]));
        LRetCode := FSQLiteAdapter.Prepare(LSql, LAPIStmt);
        if LRetCode = 0 then begin
          ADataSet.First;
          while not ADataSet.Eof do begin
            FSQLiteAdapter.Reset(LAPIStmt);
            FSQLiteAdapter.BindField(LAPIStmt, AIDField, 1);
            FSQLiteAdapter.Step(LAPIStmt);
            if (AJSIDField <> nil)
              and (not AJSIDField.IsNull)
              and (AJSIDField.AsInt64 > ATable.DelJSID) then begin
              ATable.DelJSID := AJSIDField.AsInt64;
            end;
            ADataSet.Next;
          end;
          FSQLiteAdapter.ExecuteSql(Format(SQL_TEMP_DEL_TABLE_DELETE, [ATable.Name, ATable.TempDelName]));
          DeleteTempDeleteTable(ATable);
          DoUpdateSysTable(ATable);
          FSQLiteAdapter.Commit;
          LIsSuccess := True;
        end;
      except
        on Ex: Exception do begin
          if FAppContext <> nil then begin
            FAppContext.SysLog(llERROR, Format('[%s][DoDeleteDataFromCacheTable] Delete is exception, exception is %s.', [Self.ClassName, Ex.Message]));
          end;
        end;
      end;
    finally
      if not LIsSuccess then begin
        ATable.DelJSID := LDelJSID;
        FSQLiteAdapter.Rollback;
      end;
      if Assigned(LAPIStmt) then begin
        FSQLiteAdapter.Finalize(LAPIStmt);
      end;
    end;
  finally
    FSQLiteAdapter.EndWrite;
  end;
end;

procedure TAbstractCacheImpl.CreateTempTable(ATable: TCacheTable);
begin
  FSQLiteAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_CREATE, [ATable.TempName, ATable.Name]));
end;

procedure TAbstractCacheImpl.DeleteTempTable(ATable: TCacheTable);
begin
  FSQLiteAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempName]));
end;

procedure TAbstractCacheImpl.CreateTempDeleteTable(ATable: TCacheTable);
begin
  FSQLiteAdapter.ExecuteSql(Format(SQL_TEMP_DEL_TABLE_CREATE, [ATable.TempDelName]));
end;

procedure TAbstractCacheImpl.DeleteTempDeleteTable(ATable: TCacheTable);
begin
  FSQLiteAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempDelName]));
end;

procedure TAbstractCacheImpl.DoCommitCacheTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin

      Application.ProcessMessages;
      LTable := FCacheTables.Items[LIndex];
      if LTable <> nil then begin
        LTableTick := GetTickCount;
        try
          DoCommitCacheTable(LTable);
        finally
          LTableTick := GetTickCount - LTableTick;
          if FAppContext <> nil then begin
            FAppContext.SysLog(llSLOW, Format('[%s][DoCommitCacheTables][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
          end;
        end;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][DoCommitCacheTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

procedure TAbstractCacheImpl.DoUpdateCacheTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin

      Application.ProcessMessages;
      LTable := FCacheTables.Items[LIndex];
      if LTable <> nil then begin
        LTableTick := GetTickCount;
        try
          LTable.Lock;
          try
            DoUpdateCacheTable(LTable);
            LTable.LastUpdateTime := Now;
          finally
            LTable.UnLock;
          end;
        finally
          LTableTick := GetTickCount - LTableTick;
          if FAppContext <> nil then begin
            FAppContext.SysLog(llSLOW, Format('[%s][DoUpdateCacheTables][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
          end;
        end;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][DoUpdateCacheTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

procedure TAbstractCacheImpl.DoAsyncUpdateCacheTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LIndicator: string;
  LTable: TCacheTable;
  LIndex, LSecs: Integer;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin
      LTable := FCacheTables.Items[LIndex];
      if LTable <> nil then begin
        LTable.Lock;
        try
          DoAsyncUpdateCacheTable(LTable);
        finally
          LTable.UnLock;
        end;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llSLOW, Format('[%s][DoASyncUpdateData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
    end;
  end;
{$ENDIF}
end;

procedure TAbstractCacheImpl.DoCommitCacheTable(ATable: TCacheTable);
begin

end;

procedure TAbstractCacheImpl.DoUpdateCacheTable(ATable: TCacheTable);
var
  LIndicator: string;
  LDataSet: IWNDataSet;
begin
  if ATable.Indicator <> '' then begin
    LIndicator := StringReplace(ATable.Indicator, REPLACE_STR_JSID,
      IntToStr(ATable.MaxJSID), [rfReplaceAll]);
    LDataSet := FAppContext.GFPrioritySyncQuery(FServiceType, LIndicator, INFINITE);
    if LDataSet <> nil then begin
      DoInsertCacheTable(ATable, LDataSet);
      LDataSet := nil;
    end;
  end;

  if ATable.DeleteIndicator <> '' then begin
    LIndicator := StringReplace(ATable.DeleteIndicator, REPLACE_STR_JSID,
      IntToStr(ATable.DelJSID), [rfReplaceAll]);
    LDataSet := FAppContext.GFPrioritySyncQuery(FServiceType, LIndicator, INFINITE);
    if LDataSet <> nil then begin
      DoDeleteCacheTable(ATable, LDataSet);
      LDataSet := nil;
    end;
  end;
end;

procedure TAbstractCacheImpl.DoAsyncUpdateCacheTable(ATable: TCacheTable);
var
  LIndicator: string;
begin
  if ATable.Indicator <> '' then begin
    LIndicator := StringReplace(ATable.Indicator, REPLACE_STR_JSID,
      IntToStr(ATable.MaxJSID), [rfReplaceAll]);
    FAppContext.GFASyncQuery(FServiceType, LIndicator, DoGFUpdateDataArrive, ATable.IndexID);
  end;

  if ATable.DeleteIndicator <> '' then begin
    LIndicator := StringReplace(ATable.DeleteIndicator, REPLACE_STR_JSID,
      IntToStr(ATable.DelJSID), [rfReplaceAll]);
    FAppContext.GFASyncQuery(FServiceType, LIndicator, DoGFUpdateDataArrive, ATable.IndexID);
  end;
end;

procedure TAbstractCacheImpl.DoUpdateNotifyCacheTable(ATable: TCacheTable; AInfo: string);
begin
  if FProcessCacheGFQueueThread.IsTerminated then Exit;

  if FUpdateNotifyCacheTableDic.ContainsKey(ATable.Name) then begin
    FAppContext.SendMsgEx(Msg_AsfCache_ReUpdateBaseCache_SecuMain, AInfo, 2);
  end;
end;

procedure TAbstractCacheImpl.DoGFUpdateDataArrive(AGFData: IGFData);
var
  LCacheGF: TCacheGF;
  LDateSet: IWNDataSet;
begin
  if FProcessCacheGFQueueThread.IsTerminated then Exit;
  
  if AGFData.GetErrorCode = ERROR_SUCCESS then begin
    LDateSet := Utils.GFData2WNDataSet(AGFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGF := TCacheGF.Create;
      LCacheGF.ID := AGFData.GetKey;
      LCacheGF.DataSet := LDateSet;
      LCacheGF.OperateType := coInsert;
      FArriveCacheGFQueue.Enqueue(LCacheGF);
      FProcessCacheGFQueueThread.ResumeEx;
    end;
  end;
end;

procedure TAbstractCacheImpl.DoGFDeleteDataArrive(AGFData: IGFData);
var
  LDateSet: IWNDataSet;
  LCacheGF: TCacheGF;
begin
  if FProcessCacheGFQueueThread.IsTerminated then Exit;

  if AGFData.GetErrorCode = ERROR_SUCCESS then begin
    LDateSet := Utils.GFData2WNDataSet(AGFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGF := TCacheGF.Create;
      LCacheGF.ID := AGFData.GetKey;
      LCacheGF.DataSet := LDateSet;
      LCacheGF.OperateType := coDelete;
      FArriveCacheGFQueue.Enqueue(LCacheGF);
      FProcessCacheGFQueueThread.ResumeEx;
    end;
  end;
end;

procedure TAbstractCacheImpl.DoProcessCacheGFQueueExecute(Sender: TObject);
var
  LCacheGF: TCacheGF;
  LTable: TCacheTable;
begin
  case FProcessCacheGFQueueThread.WaitForEx(INFINITE) of
    WAIT_OBJECT_0:
      begin
        if FProcessCacheGFQueueThread.IsTerminated then Exit;

        if not FArriveCacheGFQueue.IsEmpty then begin
          LCacheGF := FArriveCacheGFQueue.Dequeue;
          if LCacheGF <> nil then begin
            case LCacheGF.OperateType of
              coInsert:
                begin
                  LTable := GetTableByIndex(LCacheGF.ID);
                  if LTable <> nil then begin
                    DoInsertCacheTable(LTable, LCacheGF.DataSet);
                    if LCacheGF.DataSet.RecordCount > 0 then begin
                      LTable.UpdateVersion := LTable.UpdateVersion + 1;
                      DoUpdateNotifyCacheTable(LTable, Format('Table=%s Insert Cache Finish.', [LTable.Name]));
                    end;
                    LCacheGF.DataSet := nil;
                  end;
                end;
              coDelete:
                begin
                  LTable := GetTableByIndex(LCacheGF.ID);
                  if LTable <> nil then begin
                    DoDeleteCacheTable(LTable, LCacheGF.DataSet);
                    if LCacheGF.DataSet.RecordCount > 0 then begin
                      LTable.UpdateVersion := LTable.UpdateVersion + 1;
                      DoUpdateNotifyCacheTable(LTable, Format('Table=%s Delete Cache Finish.', [LTable.Name]));
                    end;
                    LCacheGF.DataSet := nil;
                  end;
                end;
            end;
            LCacheGF.Free;
          end;
        end;
      end;
  end;
end;

end.
