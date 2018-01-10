unit UserCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserCache Implementation
// Author：      lksoulman
// Date：        2017-8-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  LogLevel,
  UserCache,
  CacheType,
  CacheTable,
  BaseObject,
  AppContext,
  CommonPool,
  ServiceType,
  WNDataSetInf,
  ExecutorThread,
  AbstractCacheImpl,
  Generics.Collections;

type

  // UserCache Implementation
  TUserCacheImpl = class(TAbstractCacheImpl, IUserCache)
  private
    // UpLoadServerThread
    FUpLoadServerThread: TExecutorThread;
  protected
    // LoadCfgBefore
    procedure DoLoadCfgBefore; override;

    // UpLoadUserSector
    procedure DoUpLoadUserSector;
    // UpLoadUserConfig
    procedure DoUpLoadUserConfig;
    // UpdateDataSetToDB
    procedure DoUpdateUserSectorToDB(ATable: TCacheTable; ADataSet: IWNDataSet; ANames: string);
    // UpdateDataSetToDB
    procedure DoUpdateUserConfigToDB(ATable: TCacheTable; ADataSet: IWNDataSet);
    // UserSectorDataSetJson
    function DoUserSectorDataSetJson(ADataSet: IWNDataSet; var ANames: string): string;
    // UserConfigDataSetJson
    function DoUserConfigDataSetJson(ADataSet: IWNDataSet): string;
    // UpLoadServerThread
    procedure DoUpLoadServerThread(AObject: TObject);

    // StopService
    procedure DoStopService; override;
    // AddDefaultUserSector
    procedure DoAddDefaultUserSector;
    // DeleteNotInUserSector
    procedure DoDeleteNotInUserSector(ADataSet: IWNDataSet);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserCache }

    // StopService
    procedure StopService;
    // UpdateTables
    procedure UpdateTables;
    // InitUpdateTables
    procedure InitUpdateTables;
    // ReplaceCreateCacheTables
    procedure ReplaceCreateCacheTables;
    // ExecuteSql
    procedure ExecuteSql(ATable, ASql: string);
    // SyncQuery
    function SyncQuery(ASql: WideString): IWNDataSet;
    // UpdateVersion
    function GetUpdateVersion(ATable: string): Integer;
    // AsyncQuery
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

uses
  Cfg,
  Json;

{ TUserCacheImpl }

constructor TUserCacheImpl.Create(AContext: IAppContext);
begin
  inherited;
  FUpLoadServerThread := TExecutorThread.Create;
  FUpLoadServerThread.ThreadMethod := DoUpLoadServerThread;
  FUpLoadServerThread.StartEx;
end;

destructor TUserCacheImpl.Destroy;
begin

  inherited;
end;

procedure TUserCacheImpl.DoStopService;
begin
  if not FIsStopService then begin
    FProcessCacheGFQueueThread.ShutDown;
    FUpLoadServerThread.ShutDown;
    FIsStopService := True;
  end;
end;

procedure TUserCacheImpl.DoAddDefaultUserSector;
//var
//  LSql: string;
//  LDataSet: IWNDataSet;
begin
//  LDataSet := FSQLiteAdapter.QuerySql(LSql);
//  if LDataSet <> nil
//    and (LDataSet.RecordCount <= 0) then begin
//    LSql := Format('INSERT OR REPLACE INTO #TableName VALUES (''%s'',%d,''%s'',%d,''%s'',1)',
//      ['', 1, '自选股', 0, '1,1055,1752']);
//    FSQLiteAdapter.ExecuteSql(LSql);
//  end;
end;

procedure TUserCacheImpl.DoDeleteNotInUserSector(ADataSet: IWNDataSet);
var
  LCID: IWNField;
  LCIDs, LSql: string;
begin
  if ADataSet.RecordCount > 0 then begin
    LCID := ADataSet.FieldByName('cid');
    if LCID = nil then Exit;

    LCIDs := '';
    ADataSet.First;
    while not ADataSet.Eof do begin
      if LCID.AsString <> '' then  begin
        if LCIDs = '' then begin
          LCIDs := LCID.AsString;
        end else begin
          LCIDs := LCIDs + ',' + LCID.AsString;
        end;
      end;
      ADataSet.Next;
    end;
    if LCIDs <> '' then begin
      LSql := Format('DELETE FROM UserSector WHERE ID <> '''' and not(CID in (%s))', [LCIDs]);
      FSQLiteAdapter.ExecuteSql(LSql);
    end;
  end else begin
    LSql := Format('DELETE FROM UserSector WHERE ID <> ''''', [LCIDs]);
    FSQLiteAdapter.ExecuteSql(LSql);
  end;
end;

procedure TUserCacheImpl.DoLoadCfgBefore;
begin
  FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/UserCfg.xml';
  FSQLiteAdapter.DataBaseName := (FAppContext.GetCfg as ICfg).GetUserCachePath + 'UserDB';
end;

procedure TUserCacheImpl.DoUpLoadUserSector;
var
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
  LUpLoadVersion: Integer;
  LSql, LUpLoadData, LNames, LTableName: string;
begin
  LTableName := 'UserSector';
  if FCacheTableDic.TryGetValue(LTableName, LTable)
    and (LTable.CurrUpLoadVersion < LTable.UpLoadVersion) then begin
    // Sql 这样写为了兼容老的  select ID,C_ID,SelectName,OrderNum,SelectSecu,IsEdit from MY_SelectStock where IsEdit > 0
    LSql := Format('SELECT ID, CID AS C_ID, Name AS SelectName, OrderNo AS OrderNum,'
     + 'Innercodes AS SelectSecu,UpLoadValue AS IsEdit FROM %s WHERE UpLoadValue > 0', [LTable.Name]);
    LTable.Lock;
    try
      LUpLoadVersion := LTable.UpLoadVersion;
      LDataSet := FSQLiteAdapter.QuerySql(LSql);
    finally
      LTable.UnLock;
    end;

    if (LDataSet = nil) or (LDataSet.RecordCount <= 0) then Exit;

    if FUpLoadServerThread.IsTerminated then Exit;

    LUpLoadData := DoUserSectorDataSetJson(LDataSet, LNames);
    if LUpLoadData = '' then Exit;
    LSql := Format('C_CLIENT_MYSELECTSTOCK_SAVE4delphi("%s")', [LUpLoadData]);

    if FUpLoadServerThread.IsTerminated then Exit;

    LDataSet := FAppContext.GFPrioritySyncQuery(stBasic, LSql, INFINITE);
    if LDataSet <> nil then begin
      //
      DoUpdateUserSectorToDB(LTable, LDataSet, LNames);
      // 更新上传版本
      LTable.CurrUpLoadVersion := LUpLoadVersion;
    end;
  end;
end;

procedure TUserCacheImpl.DoUpLoadUserConfig;
var
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
  LUpLoadVersion: Integer;
  LSql, LUpLoadData, LTableName: string;
begin
  LTableName := 'UserConfig';
  if FCacheTableDic.TryGetValue(LTableName, LTable)
    and (LTable.CurrUpLoadVersion < LTable.UpLoadVersion) then begin
    // Sql 这样写为了兼容老的  select ID,ConfigName,ConfigType,ConfigKey,Content,Version,IsEdit from MY_Config where IsEdit > 0 and ConfigType = 2
    LSql := Format('SELECT ID, Name AS ConfigName, Type AS ConfigType, Key AS ConfigKey, Value AS Content,'
      + 'Version, UpLoadValue AS IsEdit FROM %s WHERE UpLoadValue > 0 AND Type = 2', [LTable.Name]);

    LTable.Lock;
    try
      LUpLoadVersion := LTable.UpLoadVersion;
      LDataSet := FSQLiteAdapter.QuerySql(LSql);
    finally
      LTable.UnLock;
    end;
    if (LDataSet = nil) or (LDataSet.RecordCount <= 0) then Exit;

    if FUpLoadServerThread.IsTerminated then Exit;

    LUpLoadData := DoUserConfigDataSetJson(LDataSet);
    if LUpLoadData = '' then Exit;
    LSql := Format('C_CLIENT_MYCONFIG_SAVE4delphi("%s")', [LUpLoadData]);

    if FUpLoadServerThread.IsTerminated then Exit;

    LDataSet := FAppContext.GFPrioritySyncQuery(stBasic, LSql, INFINITE);
    if LDataSet <> nil then begin
      DoUpdateUserConfigToDB(LTable, LDataSet);
      // 更新上传版本
      LTable.CurrUpLoadVersion := LUpLoadVersion;
    end;
  end;
end;

procedure TUserCacheImpl.DoUpdateUserSectorToDB(ATable: TCacheTable; ADataSet: IWNDataSet; ANames: string);
var
  LScript: string;
  LMaxJSID: Int64;
  LID, LCID, LJSID: IWNField;
begin
  LID := ADataSet.FieldByName('id');
  LCID := ADataSet.FieldByName('cid');
  LJSID := ADataSet.FieldByName('jsid');

  if (LID = nil)
    or (LCID = nil)
    or (LJSID = nil) then Exit;

  LScript := '';
  LMaxJSID := 0;

  ADataSet.First;
  while not ADataSet.Eof do begin

    if LJSID.AsInt64 > LMaxJSID then begin
      LMaxJSID := LID.AsInt64;
    end;

    if LScript = '' then begin
      LScript := Format('UPDATE %s SET UpLoadValue = 0, ID = ''%s'' WHERE CID = %s;',
        [ATable.Name, LID.AsString, LCID.AsString]);
    end else begin
      LScript := LScript + Format('UPDATE %s SET UpLoadValue = 0, ID = ''%s'' WHERE CID = %s;',
        [ATable.Name, LID.AsString, LCID.AsString]);
    end;

    ADataSet.Next;
  end;

  if LScript <> '' then begin

    if LMaxJSID > ATable.MaxJSID then begin
      ATable.MaxJSID := LMaxJSID;
      DoUpdateSysTable(ATable);
    end;
    FSQLiteAdapter.ExecuteScript(LScript);
  end;
end;

procedure TUserCacheImpl.DoUpdateUserConfigToDB(ATable: TCacheTable; ADataSet: IWNDataSet);
var
  LMaxJSID: Int64;
  LTable: TCacheTable;
  LID, LKey, LJSID: IWNField;
  LTableName, LScript: string;
begin
  LID := ADataSet.FieldByName('id');
  LKey := ADataSet.FieldByName('configKey');
  LJSID := ADataSet.FieldByName('jsid');

  if (LID = nil)
    or (LKey = nil)
    or (LJSID = nil) then Exit;

  LScript := '';
  LMaxJSID := 0;
  LTableName := 'UserConfig';

  ADataSet.First;
  while not ADataSet.Eof do begin

    if LID.AsInt64 > LMaxJSID then begin
      LMaxJSID := LID.AsInt64;
    end;

    if LScript = '' then begin
      LScript := Format('UPDATE %s SET UpdateValue = 0, ID = ''%s'' WHERE Key = %s;',
        [LTableName, LID.AsString, LKey.AsString]);
    end else begin
      LScript := LScript + Format('UPDATE %s SET UpdateValue = 0, ID = ''%s'' WHERE CID = %s;',
        [LTableName, LID.AsString, LKey.AsString]);
    end;

    ADataSet.Next;
  end;

  if LScript <> '' then begin

    if FCacheTableDic.TryGetValue(LTableName, LTable) then begin
      if LMaxJSID > LTable.MaxJSID then begin
        LTable.MaxJSID := LMaxJSID;
        DoUpdateSysTable(LTable);
      end;
      FSQLiteAdapter.ExecuteScript(LScript);
    end;
  end;
end;

function TUserCacheImpl.DoUserSectorDataSetJson(ADataSet: IWNDataSet; var ANames: string): string;
var
  LIndex: Integer;
  LField: IWNField;
  LJsonObject: TJSONObject;
  LJsonArray, LJsonArrayRow: TJSONArray;
begin
  Result := '';
  ANames := '';
  LField := ADataSet.FieldByName('SelectName');
  if LField = nil then Exit;

  LJsonObject := TJSONObject.Create;
  try
    ADataSet.First;
    LJsonArray := TJSONArray.Create;
    LJsonObject.AddPair('Fields', LJsonArray);
    for LIndex := 0 to ADataSet.FieldCount - 1 do begin
      LJsonArray.Add(ADataSet.Fields(LIndex).FieldName);
    end;

    LJsonArray := TJSONArray.Create;
    LJsonObject.AddPair('Data', LJsonArray);
    while not ADataSet.Eof do begin

      if FUpLoadServerThread.IsTerminated then Exit;

      LJsonArrayRow := TJSONArray.Create;
      LJsonArray.Add(LJsonArrayRow);
      for LIndex := 0 to ADataSet.FieldCount - 1 do begin

        if ADataSet.Fields(LIndex).IsNull then begin
          LJsonArrayRow.AddElement(TJSONNull.Create);
        end else begin
          case ADataSet.Fields(LIndex).FieldType of
            fteInteger:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsInteger));
              end;
            fteInteger64:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsInt64));
              end;
            fteFloat:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsFloat));
              end;
            fteDatetime:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsDateTime));
              end;
            fteBool:
              begin
                if ADataSet.Fields(LIndex).AsBoolean then begin
                  LJsonArrayRow.AddElement(TJSONTrue.Create());
                end else begin
                  LJsonArrayRow.AddElement(TJSONFalse.Create());
                end;
              end;
          else
            LJsonArrayRow.Add(ADataSet.Fields(LIndex).AsString);
          end;
        end;
      end;

      if ANames = '' then begin
        ANames := '"' + LField.AsString + '"';
      end else begin
        ANames := ANames + ',"' + LField.AsString + '"';
      end;

      ADataSet.Next;
    end;
    Result := StringReplace(LJsonObject.ToString, '"', '""', [rfReplaceAll]);
  finally
    LJsonObject.Free;
  end;
end;

function TUserCacheImpl.DoUserConfigDataSetJson(ADataSet: IWNDataSet): string;
var
  LIndex: Integer;
  LJsonObject: TJSONObject;
  LJsonArray, LJsonArrayRow: TJSONArray;
begin
  Result := '';
  LJsonObject := TJSONObject.Create;
  try
    ADataSet.First;
    LJsonArray := TJSONArray.Create;
    LJsonObject.AddPair('Fields', LJsonArray);
    for LIndex := 0 to ADataSet.FieldCount - 1 do begin
      LJsonArray.Add(ADataSet.Fields(LIndex).FieldName);
    end;

    LJsonArray := TJSONArray.Create;
    LJsonObject.AddPair('Data', LJsonArray);
    while not ADataSet.Eof do begin

      if FUpLoadServerThread.IsTerminated then Exit;

      LJsonArrayRow := TJSONArray.Create;
      LJsonArray.Add(LJsonArrayRow);
      for LIndex := 0 to ADataSet.FieldCount - 1 do begin

        if ADataSet.Fields(LIndex).IsNull then begin
          LJsonArrayRow.AddElement(TJSONNull.Create);
        end else begin
          case ADataSet.Fields(LIndex).FieldType of
            fteInteger:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsInteger));
              end;
            fteInteger64:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsInt64));
              end;
            fteFloat:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsFloat));
              end;
            fteDatetime:
              begin
                LJsonArrayRow.AddElement(TJSONNumber.Create(ADataSet.Fields(LIndex).AsDateTime));
              end;
            fteBool:
              begin
                if ADataSet.Fields(LIndex).AsBoolean then begin
                  LJsonArrayRow.AddElement(TJSONTrue.Create());
                end else begin
                  LJsonArrayRow.AddElement(TJSONFalse.Create());
                end;
              end;
          else
            LJsonArrayRow.Add(ADataSet.Fields(LIndex).AsString);
          end;
        end;
      end;

      ADataSet.Next;
    end;
    Result := StringReplace(LJsonObject.ToString, '"', '""', [rfReplaceAll]);
  finally
    LJsonObject.Free;
  end;
end;

procedure TUserCacheImpl.DoUpLoadServerThread(AObject: TObject);
begin
  while not FUpLoadServerThread.IsTerminated do begin
    case FUpLoadServerThread.WaitForEx(1000) of
      WAIT_TIMEOUT:
        begin
          if FUpLoadServerThread.IsTerminated then Exit;

          DoUpLoadUserSector;
          DoUpLoadUserConfig;
        end;
    end;
  end;
end;

procedure TUserCacheImpl.StopService;
begin
  DoStopService;
end;

procedure TUserCacheImpl.UpdateTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndicator: string;
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
  LIndex, LMaxJSID: Integer;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin

      LTable := FCacheTables.Items[LIndex];
      if LTable <> nil then begin
        LTableTick := GetTickCount;
        try
          LTable.Lock;
          try
            if LTable.Indicator <> '' then begin
              LMaxJSID := LTable.MaxJSID;
              LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
                IntToStr(LTable.MaxJSID), [rfReplaceAll]);
              LDataSet := FAppContext.GFPrioritySyncQuery(FServiceType, LIndicator, INFINITE);
              if LDataSet <> nil then begin
                DoInsertCacheTable(LTable, LDataSet);
                if LTable.Name = 'UserSector' then begin
                  if LTable.MaxJSID > LMaxJSID then begin
                    FAppContext.SendMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector, '', 0);
                  end;
                end;
                LDataSet := nil;
              end;
            end;
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

procedure TUserCacheImpl.InitUpdateTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LMaxJSID: Int64;
  LIndicator: string;
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FCacheTables.Count - 1 do begin

      LTable := FCacheTables.Items[LIndex];
      if LTable <> nil then begin
        LTableTick := GetTickCount;
        try
          LTable.Lock;
          try
            if LTable.Indicator <> '' then begin
              if LTable.Name = 'UserSector' then begin
                LMaxJSID := 0;
              end else begin
                LMaxJSID := LTable.MaxJSID;
              end;
              LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
                IntToStr(LMaxJSID), [rfReplaceAll]);
              LDataSet := FAppContext.GFPrioritySyncQuery(FServiceType, LIndicator, INFINITE);
              if LDataSet <> nil then begin
                DoInsertCacheTable(LTable, LDataSet);
                if LTable.Name = 'UserSector' then begin
                  DoDeleteNotInUserSector(LDataSet);
                end;
                LDataSet := nil;
              end;
            end;
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

procedure TUserCacheImpl.ReplaceCreateCacheTables;
begin
  DoReplaceCreateCacheTables;
end;

procedure TUserCacheImpl.ExecuteSql(ATable, ASql: string);
var
  LTable: TCacheTable;
begin
  if ASql = '' then Exit;

  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      FSQLiteAdapter.ExecuteSql(ASql);
    finally
      LTable.UpLoadVersion := LTable.UpLoadVersion + 1;
      LTable.UnLock;
    end;
  end;
end;

function TUserCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FSQLiteAdapter.QuerySql(ASql);
end;

function TUserCacheImpl.GetUpdateVersion(ATable: string): Integer;
var
  LTable: TCacheTable;
begin
  if FCacheTableDic.TryGetValue(ATable, LTable) then begin
    LTable.Lock;
    try
      Result := LTable.UpdateVersion;
    finally
      LTable.UnLock;
    end;
  end else begin
    Result := -1;
  end;
end;

procedure TUserCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
