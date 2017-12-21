unit ServerDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ServerDataMgr Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqAuth,
  Command,
  BaseObject,
  AppContext,
  CommonLock,
  QuoteMngr_TLB,
  ServerDataMgr,
  Generics.Collections;

type

  // ServerDataMgr Implementation
  TServerDataMgrImpl = class(TBaseInterfacedObject, IServerDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // HqAuth
    FHqAuth: IHqAuth;
    // HqServerInfos
    FHqServerInfos: TList<THqServerInfo>;
    // HqServerInfoDic
    FHqServerInfoDic: TDictionary<TServerType, THqServerInfo>;
    // HqServerInfoEnumDic
    FHqServerInfoEnumDic: TDictionary<ServerTypeEnum, THqServerInfo>;
  protected
    // AddTestData;
    procedure DoAddTestData;
    // DoAdd
    procedure DoAdd(AHqServerInfo: THqServerInfo);
    // DoRemove
    procedure DoRemove(AHqServerInfo: THqServerInfo);
    // ClearHqServerInfos
    procedure DoClearHqServerInfos;
    // GetIsHKReal
    function GetIsHKReal: Boolean;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IServerDataMgr }
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // GetCount
    function GetCount: Integer;
    // GetIsLevel2
    function GetIsLevel2: Boolean;
    // GetServerInfo
    function GetServerInfo(AIndex: Integer): THqServerInfo;
    // GetServerInfoEx
    function GetServerInfoEx(AServerType: TServerType): THqServerInfo;
    // GetServerInfoByEnum
    function GetServerInfoByEnum(AServerEnum: ServerTypeEnum): THqServerInfo;
  end;

implementation

{ TServerDataMgrImpl }

constructor TServerDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FHqAuth := FAppContext.FindInterface(ASF_COMMAND_ID_HQAUTH) as IHqAuth;
  FHqServerInfos := TList<THqServerInfo>.Create;
  FHqServerInfoDic := TDictionary<TServerType, THqServerInfo>.Create;
  FHqServerInfoEnumDic := TDictionary<ServerTypeEnum, THqServerInfo>.Create;
  DoAddTestData;
end;

destructor TServerDataMgrImpl.Destroy;
begin
  DoClearHqServerInfos;
  FHqServerInfoEnumDic.Free;
  FHqServerInfoDic.Free;
  FHqServerInfos.Free;
  FLock.Free;
  FHqAuth := nil;
  inherited;
end;

procedure TServerDataMgrImpl.DoAddTestData;
var
  LHqServerInfo: THqServerInfo;
begin
  LHqServerInfo := THqServerInfo.Create;
  LHqServerInfo.ServerType := st_LevelI;
  LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
  DoAdd(LHqServerInfo);

  if GetIsLevel2 then begin
    LHqServerInfo := THqServerInfo.Create;
    LHqServerInfo.ServerType := st_Level2;
    LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
    DoAdd(LHqServerInfo);
  end;

  if GetIsHKReal then begin
    LHqServerInfo := THqServerInfo.Create;
    LHqServerInfo.UserName := FHqAuth.GetLevel2UserName;
    LHqServerInfo.Password := FHqAuth.GetLevel2Password;
    LHqServerInfo.ServerType := st_HKReal;
    LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
    DoAdd(LHqServerInfo);
  end else begin
    LHqServerInfo := THqServerInfo.Create;
    LHqServerInfo.ServerType := st_HKDelay;
    LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
    DoAdd(LHqServerInfo);
  end;

  LHqServerInfo := THqServerInfo.Create;
  LHqServerInfo.ServerType := st_DDE;
  LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
  DoAdd(LHqServerInfo);

  LHqServerInfo := THqServerInfo.Create;
  LHqServerInfo.ServerType := st_Futures;
  LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
  DoAdd(LHqServerInfo);
end;

procedure TServerDataMgrImpl.DoAdd(AHqServerInfo: THqServerInfo);
begin
  FHqServerInfos.Add(AHqServerInfo);
  FHqServerInfoDic.Add(AHqServerInfo.ServerType, AHqServerInfo);
  FHqServerInfoEnumDic.AddOrSetValue(AHqServerInfo.ServerEnum, AHqServerInfo);
end;

procedure TServerDataMgrImpl.DoRemove(AHqServerInfo: THqServerInfo);
begin
  FHqServerInfos.Remove(AHqServerInfo);
  FHqServerInfoDic.Remove(AHqServerInfo.ServerType);
  FHqServerInfoEnumDic.Remove(AHqServerInfo.ServerEnum);
end;

procedure TServerDataMgrImpl.DoClearHqServerInfos;
var
  LIndex: Integer;
  LHqServerInfo: THqServerInfo;
begin
  for LIndex := 0 to FHqServerInfos.Count - 1 do begin
    LHqServerInfo := FHqServerInfos.Items[LIndex];
    if LHqServerInfo <> nil then begin
      LHqServerInfo.Free;
    end;
  end;
end;

function TServerDataMgrImpl.GetIsHKReal: Boolean;
begin
  Result := (FHqAuth <> nil) and (FHqAuth.GetIsHasHKReal);
end;

function TServerDataMgrImpl.GetIsLevel2: Boolean;
begin
  Result := (FHqAuth <> nil) and (FHqAuth.GetIsHasLevel2);
end;

procedure TServerDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TServerDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TServerDataMgrImpl.Update;
var
  LHqServerInfo: THqServerInfo;
begin
  FLock.Lock;
  try
    if GetIsLevel2 then begin
      if not FHqServerInfoDic.TryGetValue(st_Level2, LHqServerInfo) then begin
        LHqServerInfo := THqServerInfo.Create;
        LHqServerInfo.ServerType := st_Level2;
        LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
        DoAdd(LHqServerInfo);
      end;
      if (LHqServerInfo <> nil) and (FHqAuth <> nil) then begin
        LHqServerInfo.UserName := FHqAuth.GetLevel2UserName;
        LHqServerInfo.Password := FHqAuth.GetLevel2Password;
      end;
    end else begin
      if FHqServerInfoDic.TryGetValue(st_Level2, LHqServerInfo) then begin
        DoRemove(LHqServerInfo);
        LHqServerInfo.Free;
      end;
    end;

    if GetIsHKReal then begin
      if FHqServerInfoDic.TryGetValue(st_HKReal, LHqServerInfo) then begin
        if FHqServerInfoDic.TryGetValue(st_HKDelay, LHqServerInfo) then begin
          DoRemove(LHqServerInfo);
          LHqServerInfo.Free;
        end;
      end else begin
        LHqServerInfo := THqServerInfo.Create;
        LHqServerInfo.ServerType := st_HKReal;
        LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
        DoAdd(LHqServerInfo);
      end;
    end else begin
      if FHqServerInfoDic.TryGetValue(st_HKDelay, LHqServerInfo) then begin
        if FHqServerInfoDic.TryGetValue(st_HKReal, LHqServerInfo) then begin
          DoRemove(LHqServerInfo);
          LHqServerInfo.Free;
        end;
      end else begin
        LHqServerInfo := THqServerInfo.Create;
        LHqServerInfo.ServerType := st_HKDelay;
        LHqServerInfo.ServerUrls := FAppContext.GetCfg.GetServerCfg.GetServerUrls(LHqServerInfo.ServerName);
        DoAdd(LHqServerInfo);
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TServerDataMgrImpl.GetCount: Integer;
begin
  Result := FHqServerInfos.Count;
end;

function TServerDataMgrImpl.GetServerInfo(AIndex: Integer): THqServerInfo;
begin
  if (AIndex >= 0)
    and (AIndex < FHqServerInfos.Count) then begin
    Result := FHqServerInfos.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TServerDataMgrImpl.GetServerInfoEx(AServerType: TServerType): THqServerInfo;
var
  LHqServerInfo: THqServerInfo;
begin
  FLock.Lock;
  try
    if FHqServerInfoDic.TryGetValue(AServerType, LHqServerInfo) then begin
      Result := LHqServerInfo;
    end else begin
      Result := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TServerDataMgrImpl.GetServerInfoByEnum(AServerEnum: ServerTypeEnum): THqServerInfo;
var
  LHqServerInfo: THqServerInfo;
begin
  FLock.Lock;
  try
    if FHqServerInfoEnumDic.TryGetValue(AServerEnum, LHqServerInfo) then begin
      Result := LHqServerInfo;
    end else begin
      Result := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
