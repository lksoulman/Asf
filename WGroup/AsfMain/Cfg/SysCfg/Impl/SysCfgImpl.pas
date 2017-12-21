unit SysCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SystemCfg Implementation
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  ProxyInfo,
  SystemInfo,
  BaseObject,
  AppContext,
  CompanyInfo;

type

  // SystemCfg Implementation
  TSysCfgImpl = class(TBaseInterfacedObject, ISysCfg)
  private
    // UserInfo
    FUserInfo: IUserInfo;
    // ProxyInfo
    FProxyInfo: IProxyInfo;
    // SystemInfo
    FSystemInfo: ISystemInfo;
    // CompanyInfo
    FCompanyInfo: ICompanyInfo;
  protected
    // ReadSysCfg
    procedure DoReadSysCfg;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

     { ISysCfg }

    // ReadLocalCacheCfg
    procedure ReadLocalCacheCfg;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // WriteUserCacheSysCfg
    procedure ReadServerCacheCfg;
    // ReadCurrentAccountInfo
    procedure ReadCurrentAccountInfo;
    // GetUserInfo
    function GetUserInfo: IUserInfo;
    // GetProxyInfo
    function GetProxyInfo: IProxyInfo;
    // GetSyscfgInfo
    function GetSystemInfo: ISystemInfo;
    // GetCompanyInfo
    function GetCompanyInfo: ICompanyInfo;
  end;


implementation

uses
  Cfg,
  LogLevel,
  IniFiles,
  UserInfoImpl,
  ProxyInfoImpl,
  SystemInfoImpl,
  CompanyInfoImpl;

{ TSysCfgImpl }

constructor TSysCfgImpl.Create(AContext: IAppContext);
begin
  inherited;
  FUserInfo := TUserInfoImpl.Create(FAppContext) as IUserInfo;
  FProxyInfo := TProxyInfoImpl.Create(FAppContext) as IProxyInfo;
  FSystemInfo := TSystemInfoImpl.Create(FAppContext) as ISystemInfo;
  FCompanyInfo := TCompanyInfoImpl.Create(FAppContext) as ICompanyInfo;

  DoReadSysCfg;
end;

destructor TSysCfgImpl.Destroy;
begin
  FUserInfo := nil;
  FProxyInfo := nil;
  FSystemInfo := nil;
  FCompanyInfo := nil;
  inherited;
end;

procedure TSysCfgImpl.DoReadSysCfg;
var
  LFile: string;
  LIniFile: TIniFile;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'CfgSys.ini';
  if FileExists(LFile) then begin
    LIniFile := TIniFile.Create(LFile);
    try
      FUserInfo.ReadSysCfg(LIniFile);
      FProxyInfo.ReadSysCfg(LIniFile);
      FSystemInfo.ReadSysCfg(LIniFile);
      FCompanyInfo.ReadSysCfg(LIniFile);
    finally
      LIniFile.Free;
    end;
  end else begin
    FAppContext.SysLog(llERROR, Format('[TSysCfgImpl][DoInitInfos] Load file %s is not exist.', [LFile]));
  end;
end;

procedure TSysCfgImpl.ReadLocalCacheCfg;
begin
  FUserInfo.ReadLocalCacheCfg;
  FProxyInfo.ReadLocalCacheCfg;
  FSystemInfo.ReadLocalCacheCfg;
end;

procedure TSysCfgImpl.WriteLocalCacheCfg;
begin
  FUserInfo.WriteLocalCacheCfg;
  FProxyInfo.WriteLocalCacheCfg;
  FSystemInfo.WriteLocalCacheCfg;
end;

procedure TSysCfgImpl.ReadServerCacheCfg;
begin
  FUserInfo.ReadServerCacheCfg;
  FProxyInfo.ReadServerCacheCfg;
  FSystemInfo.ReadServerCacheCfg;
end;

procedure TSysCfgImpl.ReadCurrentAccountInfo;
begin
  FUserInfo.ReadCurrentAccountInfo;
  FProxyInfo.ReadCurrentAccountInfo;
  FSystemInfo.ReadCurrentAccountInfo;
end;

function TSysCfgImpl.GetUserInfo: IUserInfo;
begin
  Result := FUserInfo;
end;

function TSysCfgImpl.GetProxyInfo: IProxyInfo;
begin
  Result := FProxyInfo;
end;

function TSysCfgImpl.GetSystemInfo: ISystemInfo;
begin
  Result := FSystemInfo;
end;

function TSysCfgImpl.GetCompanyInfo: ICompanyInfo;
begin
  Result := FCompanyInfo;
end;

end.
