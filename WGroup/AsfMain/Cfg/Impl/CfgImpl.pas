unit CfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cfg Implementation
// Author£º      lksoulman
// Date£º        2017-7-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Cfg,
  WebCfg,
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  ServerCfg,
  BaseObject,
  AppContext,
  UserCacheCfg;

type

  // Cfg Implementation
  TCfgImpl = class(TBaseInterfacedObject, ICfg)
  private
    // AppPath
    FAppPath: string;
    // SysCfg
    FSysCfg: ISysCfg;
    // WebCfg
    FWebCfg: IWebCfg;
    // ServerCfg
    FServerCfg: IServerCfg;
    // UserCacheCfg
    FUserCacheCfg: IUserCacheCfg;
  protected

  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICfg }

    // Initialize
    procedure Initialize;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // ReadServerCacheCfg
    procedure ReadServerCacheCfg;
    // GetSysCfg
    function GetSysCfg: ISysCfg;
    // GetWebCfg
    function GetWebCfg: IWebCfg;
    // GetServerCfg
    function GetServerCfg: IServerCfg;
    // GetUserCacheCfg
    function GetUserCacheCfg: IUserCacheCfg;
    // GetAppPath
    function GetAppPath: WideString;
    // GetBinPath
    function GetBinPath: WideString;
    // GetCfgPath
    function GetCfgPath: WideString;
    // GetLogPath
    function GetLogPath: WideString;
    // GetSkinPath
    function GetSkinPath: WideString;
    // GetUserPath
    function GetUserPath: WideString;
    // GetUsersPath
    function GetUsersPath: WideString;
    // GetUserCfgPath
    function GetUserCfgPath: WideString;
    // GetCachePath
    function GetCachePath: WideString;
    // GetHQCachePath
    function GetHQCachePath: WideString;
    // GetBaseCachePath
    function GetBaseCachePath: WideString;
    // GetUserCachePath
    function GetUserCachePath: WideString;
    // GetSysUpdatePath
    function GetSysUpdatePath: WideString;
  end;

implementation

uses
  Json,
  Utils,
  IniFiles,
  SysCfgImpl,
  WebCfgImpl,
  ServerCfgImpl,
  UserCacheCfgImpl;

{ TCfgImpl }

constructor TCfgImpl.Create(AContext: IAppContext);
begin
  inherited;
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');

  if not DirectoryExists(GetLogPath) then begin
    ForceDirectories(GetLogPath);
  end;

  if not DirectoryExists(GetCachePath) then begin
    ForceDirectories(GetCachePath);
  end;

  if not DirectoryExists(GetHQCachePath) then begin
    ForceDirectories(GetHQCachePath);
  end;

  if not DirectoryExists(GetBaseCachePath) then begin
    ForceDirectories(GetBaseCachePath);
  end;

  if not DirectoryExists(GetUsersPath) then begin
    ForceDirectories(GetUsersPath);
  end;

end;

destructor TCfgImpl.Destroy;
begin
  FSysCfg := nil;
  FWebCfg := nil;
  FServerCfg := nil;
  FUserCacheCfg := nil;
  inherited;
end;

procedure TCfgImpl.Initialize;
begin
  FSysCfg := TSysCfgImpl.Create(FAppContext) as ISysCfg;
  FWebCfg := TWebCfgImpl.Create(FAppContext) as IWebCfg;
  FServerCfg := TServerCfgImpl.Create(FAppContext) as IServerCfg;
  FUserCacheCfg := TUserCacheCfgImpl.Create(FAppContext) as IUserCacheCfg;

  FUserCacheCfg.LoadCurrentAccountInfo;
  FSysCfg.ReadCurrentAccountInfo;
  FUserCacheCfg.LoadLocalCfg;
  FSysCfg.ReadLocalCacheCfg;
end;

procedure TCfgImpl.WriteLocalCacheCfg;
begin
  if not DirectoryExists(GetUserPath) then begin
    ForceDirectories(GetUserPath);
  end;

  if not DirectoryExists(GetUserCfgPath) then begin
    ForceDirectories(GetUserCfgPath);
  end;

  if not DirectoryExists(GetUserCachePath) then begin
    ForceDirectories(GetUserCachePath);
  end;

  FUserCacheCfg.SaveCurrentAccountInfo;
  FSysCfg.WriteLocalCacheCfg;
end;

procedure TCfgImpl.ReadServerCacheCfg;
begin
  FUserCacheCfg.LoadServerCfg;
  FSysCfg.ReadServerCacheCfg;
end;

function TCfgImpl.GetSysCfg: ISysCfg;
begin
  Result := FSysCfg;
end;

function TCfgImpl.GetWebCfg: IWebCfg;
begin
  Result := FWebCfg;
end;

function TCfgImpl.GetServerCfg: IServerCfg;
begin
  Result := FServerCfg;
end;

function TCfgImpl.GetUserCacheCfg: IUserCacheCfg;
begin
  Result := FUserCacheCfg;
end;

function TCfgImpl.GetAppPath: WideString;
begin
  Result := FAppPath;
end;

function TCfgImpl.GetBinPath: WideString;
begin
  Result := FAppPath + 'Bin\';
end;

function TCfgImpl.GetCfgPath: WideString;
begin
  Result := FAppPath + 'Cfg\';
end;

function TCfgImpl.GetLogPath: WideString;
begin
  Result := FAppPath + 'Log\';
end;

function TCfgImpl.GetSkinPath: WideString;
begin
  Result := FAppPath + 'Skin\';
end;

function TCfgImpl.GetUserPath: WideString;
begin
  Result := FSysCfg.GetUserInfo.GetDir;
end;

function TCfgImpl.GetUsersPath: WideString;
begin
  Result := FAppPath + 'Users\';
end;

function TCfgImpl.GetCachePath: WideString;
begin
  Result := FAppPath + 'Cache\';
end;

function TCfgImpl.GetHQCachePath: WideString;
begin
  Result := FAppPath + 'Cache\HQ\';
end;

function TCfgImpl.GetBaseCachePath: WideString;
begin
  Result := FAppPath + 'Cache\Base\';
end;

function TCfgImpl.GetSysUpdatePath : WideString;
begin
  Result := FAppPath + 'Update\';
end;

function TCfgImpl.GetUserCfgPath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cfg\';
  end;
end;

function TCfgImpl.GetUserCachePath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cache\';
  end;
end;

end.
