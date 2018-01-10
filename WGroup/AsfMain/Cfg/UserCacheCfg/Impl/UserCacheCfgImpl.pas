unit UserCacheCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserCacheCfg Implementation
// Author£º      lksoulman
// Date£º        2017-7-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  UserCacheCfg,
  Generics.Collections;

type

  // ServerCacheInfo
  TServerCacheInfo = packed record
    FID: string;
    FType: Integer;
    FName: string;
    FKey: string;
    FValue: string;
    FVersion: string;
  end;

  // ServerCacheInfo
  PServerCacheInfo = ^TServerCacheInfo;

  // UserCacheCfg Implementation
  TUserCacheCfgImpl = class(TBaseInterfacedObject, IUserCacheCfg)
  private
    // CurrentAccountInfo
    FCurrentAccountInfo: TCurrentAccountInfo;
    // LocalCacheCfgDic
    FLocalCacheCfgDic: TDictionary<string, string>;
    // ServerCacheInfos
    FServerCacheInfos: TList<PServerCacheInfo>;
    // ServerCacheCfgDic
    FServerCacheCfgDic: TDictionary<string, PServerCacheInfo>;
  protected
    // ClearServerCacheInfos
    procedure DoClearServerCacheInfos;
    // WriteLocalFile
    procedure DoWriteLocalFile(AKey, AValue: string);
    // UpdateUserCache
    procedure DoUpdateUserCache(AServerCacheInfo: PServerCacheInfo);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserCacheCfg }

    // LoadLocalCfg
    procedure LoadLocalCfg;
    // LoadServerCfg
    procedure LoadServerCfg;
    // LoadCurrentAccountInfo
    procedure LoadCurrentAccountInfo;
    // SaveCurrentAccountInfo
    procedure SaveCurrentAccountInfo;
    // SaveLocal
    procedure SaveLocal(AKey, AValue: WideString);
    // SaveServer
    procedure SaveServer(AKey, AValue, AName: WideString);
    // GetCurrentAcountInfo
    function GetCurrentAcountInfo: PCurrentAccountInfo;
    // GetLocalValue
    function GetLocalValue(AKey: WideString): WideString;
    // GetServerValue
    function GetServerValue(AKey: WideString): WideString;
  end;

implementation

uses
  Cfg,
  Command,
  IniFiles,
  CacheType,
  UserCache,
  WNDataSetInf;

{ TUserCacheCfgImpl }

constructor TUserCacheCfgImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLocalCacheCfgDic := TDictionary<string, string>.Create;
  FServerCacheInfos := TList<PServerCacheInfo>.Create;
  FServerCacheCfgDic := TDictionary<string, PServerCacheInfo>.Create;
end;

destructor TUserCacheCfgImpl.Destroy;
begin
  DoClearServerCacheInfos;
  FServerCacheCfgDic.Free;
  FServerCacheInfos.Free;
  FLocalCacheCfgDic.Free;
  inherited;
end;

procedure TUserCacheCfgImpl.DoClearServerCacheInfos;
var
  LIndex: Integer;
  LServerCacheInfo: PServerCacheInfo;
begin
  for LIndex := 0 to FServerCacheInfos.Count - 1 do begin
    LServerCacheInfo := FServerCacheInfos.Items[LIndex];
    if LServerCacheInfo <> nil then begin
      Dispose(LServerCacheInfo);
    end;
  end;
end;

procedure TUserCacheCfgImpl.DoWriteLocalFile(AKey, AValue: string);
var
  LPath: string;
  LIniFile: TIniFile;
begin
  LPath := FAppContext.GetCfg.GetUserPath;
  if (LPath = '')
    or not DirectoryExists(LPath) then Exit;

  LIniFile := TIniFile.Create(LPath + 'UserCacheCfg.dat');
  try
    LIniFile.WriteString('CfgInfo', AKey, AValue);
  finally
    LIniFile.Free;
  end;
end;

procedure TUserCacheCfgImpl.DoUpdateUserCache(AServerCacheInfo: PServerCacheInfo);
var
  LSql, LValue: string;
  LValueStr: AnsiString;
  LUserCache: IUserCache;
begin
  LUserCache := FAppContext.FindInterface(ASF_COMMAND_ID_USERCACHE) as IUserCache;
  if LUserCache = nil then Exit;
  try
    LValueStr := AServerCacheInfo^.FValue;
    LValueStr := FAppContext.GetEDCrypt.StringEncodeBase64(LValueStr);
    LValue := LValueStr;
    LSql := Format('INSERT OR REPLACE INTO UserConfig VALUES (''%s'',%d,''%s'',''%s'',''%s'',''%s'',1)',
      [AServerCacheInfo^.FID,
       AServerCacheInfo^.FType,
       AServerCacheInfo^.FName,
       AServerCacheInfo^.FKey,
       LValue,
       AServerCacheInfo^.FVersion]);
    LUserCache.ExecuteSql('UserConfig', LSql);
  finally
    LUserCache := nil;
  end;
end;

procedure TUserCacheCfgImpl.LoadLocalCfg;
var
  LIndex: Integer;
  LIniFile: TIniFile;
  LStringList: TStringList;
  LFile, LKey, LValue, LPath: string;
begin
  LPath := FAppContext.GetCfg.GetUserPath;
  if LPath = '' then Exit;
  LFile := LPath + 'UserCacheCfg.dat';
  if FileExists(LFile) then begin
    LIniFile := TIniFile.Create(LFile);
    LStringList := TStringList.Create;
    try
      LIniFile.ReadSection('CfgInfo', LStringList);
      for LIndex := 0 to LStringList.Count - 1 do begin
        LKey := LStringList.Strings[LIndex];
        if LKey <> '' then begin
          LValue := LIniFile.ReadString('CfgInfo', LKey, '');
          FLocalCacheCfgDic.AddOrSetValue(LKey, LValue);
        end;
      end;
    finally
      LStringList.Free;
      LIniFile.Free;
    end;
  end;
end;

procedure TUserCacheCfgImpl.LoadServerCfg;
var
  LSql: string;
  LDataSet: IWNDataSet;
  LValueStr: AnsiString;
  LServerCacheInfo: PServerCacheInfo;
  LID, LType, LName, LKey, LValue, LVersion: IWNField;
begin
  LSql := 'SELECT ID,Type,Name,Key,Value,Version FROM UserConfig';
  LDataSet := FAppContext.CacheSyncQuery(ctUserData, LSql);
  if (LDataSet <> nil)
    and (LDataSet.RecordCount > 0) then begin
    LID := LDataSet.FieldByName('ID');
    LType := LDataSet.FieldByName('Type');
    LName := LDataSet.FieldByName('Name');
    LKey := LDataSet.FieldByName('Key');
    LValue := LDataSet.FieldByName('Value');
    LVersion := LDataSet.FieldByName('Version');

    if (LID <> nil)
      and (LType <> nil)
      and (LName <> nil)
      and (LKey <> nil)
      and (LValue <> nil)
      and (LVersion <> nil) then begin

      while not LDataSet.Eof do begin
        if LKey.AsString <> '' then begin
          New(LServerCacheInfo);
          if LServerCacheInfo <> nil then begin
            LServerCacheInfo^.FID := LID.AsString;
            LServerCacheInfo^.FType := LType.AsInteger;
            LServerCacheInfo^.FName := LName.AsString;
            LServerCacheInfo^.FKey := LKey.AsString;
            LValueStr := LValue.AsString;
            LValueStr := FAppContext.GetEDCrypt.StringDecodeBase64(LValueStr);
            LServerCacheInfo^.FValue := LValueStr;
            LServerCacheInfo^.FVersion := LVersion.AsString;
            FServerCacheInfos.Add(LServerCacheInfo);
            FServerCacheCfgDic.AddOrSetValue(LServerCacheInfo^.FKey, LServerCacheInfo);
          end;
        end;
        LDataSet.Next;
      end;
    end;
  end;
end;

procedure TUserCacheCfgImpl.LoadCurrentAccountInfo;
var
  LIni: TIniFile;
  LFile, LUserSession: string;
begin
  LFile := FAppContext.GetCfg.GetUsersPath + 'CfgSys.dat';
  if FileExists(LFile) then begin
    LIni := TIniFile.Create(LFile);
    try
      FCurrentAccountInfo.FUserName := LIni.ReadString('UserInfo', 'UserName', '');
      LUserSession := LIni.ReadString('UserInfo', 'UserSession', '');
      FCurrentAccountInfo.FUserSession := LUserSession;
    finally
      LIni.Free;
    end;
  end;
end;

procedure TUserCacheCfgImpl.SaveCurrentAccountInfo;
var
  LIni: TIniFile;
  LFile, LUserSession: string;
begin
  LFile := FAppContext.GetCfg.GetUsersPath + 'CfgSys.dat';
  if FileExists(LFile) then begin
    LIni := TIniFile.Create(LFile);
    try
      LIni.WriteString('UserInfo', 'UserName', FCurrentAccountInfo.FUserName);
      LUserSession := FCurrentAccountInfo.FUserSession;
      LIni.WriteString('UserInfo', 'UserSession', LUserSession);
    finally
      LIni.Free;
    end;
  end;
end;

procedure TUserCacheCfgImpl.SaveLocal(AKey, AValue: WideString);
var
  LValue: string;
  LIsUpdate: Boolean;
begin
  if AKey = '' then Exit;

  LIsUpdate := False;
  if FLocalCacheCfgDic.TryGetValue(AKey, LValue) then begin
    if LValue <> AValue then  begin
      LIsUpdate := True;
      FLocalCacheCfgDic.AddOrSetValue(AKey, AValue);
    end;
  end else begin
    LIsUpdate := True;
    FLocalCacheCfgDic.AddOrSetValue(AKey, AValue);
  end;

  if LIsUpdate then begin
    DoWriteLocalFile(AKey, AValue);
  end;
end;

procedure TUserCacheCfgImpl.SaveServer(AKey, AValue, AName: WideString);
var
  LServerCacheInfo: PServerCacheInfo;
begin
  if AKey = '' then Exit;

  if FServerCacheCfgDic.TryGetValue(AKey, LServerCacheInfo) then begin
    if (LServerCacheInfo^.FValue <> AValue)
      or (LServerCacheInfo^.FName <> AName) then  begin
      DoUpdateUserCache(LServerCacheInfo);
    end;
  end else begin
    New(LServerCacheInfo);
    if LServerCacheInfo <> nil then begin
      LServerCacheInfo^.FID := '';
      LServerCacheInfo^.FType := 2;
      LServerCacheInfo^.FName := AName;
      LServerCacheInfo^.FKey := AKey;
      LServerCacheInfo^.FValue := AValue;
      FServerCacheInfos.Add(LServerCacheInfo);
      FServerCacheCfgDic.AddOrSetValue(AKey, LServerCacheInfo);
      DoUpdateUserCache(LServerCacheInfo);
    end;
  end;
end;

function TUserCacheCfgImpl.GetCurrentAcountInfo: PCurrentAccountInfo;
begin
  Result := @FCurrentAccountInfo;
end;

function TUserCacheCfgImpl.GetLocalValue(AKey: WideString): WideString;
var
  LValue: string;
begin
  if FLocalCacheCfgDic.TryGetValue(AKey, LValue) then begin
    Result := LValue;
  end else begin
    Result := '';
  end;
end;

function TUserCacheCfgImpl.GetServerValue(AKey: WideString): WideString;
var
  LServerCacheInfo: PServerCacheInfo;
begin
  if FServerCacheCfgDic.TryGetValue(AKey, LServerCacheInfo) then begin
    Result := LServerCacheInfo^.FValue;
  end else begin
    Result := '';
  end;
end;



end.
