unit ProxyInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： ProxyInfo Implementation
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  ProxyInfo,
  AppContext,
  AppContextObject,
  CommonRefCounter;

type

  // ProxyInfo Implementation
  TProxyInfoImpl = class(TAppContextObject, IProxyInfo)
  private
    // Proxy
    FProxy: TProxy;
    // Is Use Proxy
    FIsUseProxy: Integer;     // 0 表示不启用 1 表示用
  protected
    // ProxyTypeToInt
    function ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
    // IntToProxyType
    function IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IProxyInfo }

    // Restore Default
    procedure RestoreDefault;
    // ReadLocalCacheCfg
    procedure ReadLocalCacheCfg;
    // ReadServerCacheCfg
    procedure ReadServerCacheCfg;
    // ReadCurrentAccountInfo
    procedure ReadCurrentAccountInfo;
    // WriteLocalCacheCfg
    procedure WriteLocalCacheCfg;
    // WriteServerCacheCfg
    procedure WriteServerCacheCfg;
    // ReadSysCfg
    procedure ReadSysCfg(AFile: TIniFile);
    // ReadUserSysCfg
    procedure ReadUserSysCfg(AFile: TIniFile);
    // WriteUserSysCfg
    procedure WriteUserSysCfg(AFile: TIniFile);
    // Get Proxy
    function GetProxy: PProxy;
    // Get Is Use Proxy
    function GetIsUseProxy: boolean;
    // Set Is Use Proxy
    procedure SetIsUseProxy(AIsUseProxy: Boolean);
  end;

implementation

uses
  Cfg;

{ TProxyInfoImpl }

constructor TProxyInfoImpl.Create(AContext: IAppContext);
begin
  inherited;
  RestoreDefault;
end;

destructor TProxyInfoImpl.Destroy;
begin

  inherited;
end;

procedure TProxyInfoImpl.RestoreDefault;
begin

end;

procedure TProxyInfoImpl.ReadLocalCacheCfg;
var
  LStringList: TStringList;
begin
  LStringList := TStringList.Create;
  try
    LStringList.Delimiter := ';';
    LStringList.DelimitedText := FAppContext.GetCfg.GetUserCacheCfg.GetLocalValue('ProxyInfo');
    if LStringList.DelimitedText <> '' then begin
      FIsUseProxy := StrToIntDef(LStringList.Values['Use'], 0);
      FProxy.FIP := LStringList.Values['IP'];
      FProxy.FPort := StrToIntDef(LStringList.Values['Port'], 0);
      FProxy.FUserName := LStringList.Values['UserName'];
      FProxy.FPassword := LStringList.Values['Password'];
      FProxy.FIsUseNTLM := StrToIntDef(LStringList.Values['IsUseNTLM'], 0);
      FProxy.FNTLMDomain := LStringList.Values['NTLMDomain'];
      FProxy.FType := IntToProxyType(StrToIntDef(LStringList.Values['ProxyType'], 0), ptNo);
    end;
  finally
    LStringList.Free;
  end;
end;

procedure TProxyInfoImpl.ReadServerCacheCfg;
begin

end;

procedure TProxyInfoImpl.ReadCurrentAccountInfo;
begin

end;

procedure TProxyInfoImpl.WriteLocalCacheCfg;
var
  LValue: string;
begin
  LValue := Format('IsUseProxy=%d;'
                 + 'IP=%s;'
                 + 'Port=%d;'
                 + 'UserName=%s;'
                 + 'Password=%s;'
                 + 'IsUseNTLM=%d;'
                 + 'NTLMDomain=%s;'
                 + 'Type=%d',
                [FIsUseProxy,
                 FProxy.FIP,
                 FProxy.FPort,
                 FProxy.FUserName,
                 FProxy.FPassword,
                 FProxy.FIsUseNTLM,
                 FProxy.FNTLMDomain,
                 ProxyTypeToInt(FProxy.FType, 0)]);
//  (FAppContext.GetCfg as ICfg).GetUserCacheCfg.GetLocalValue('ProxyInfo', LValue);
end;

procedure TProxyInfoImpl.WriteServerCacheCfg;
begin

end;

procedure TProxyInfoImpl.ReadSysCfg(AFile: TIniFile);
begin
  if AFile = nil then Exit;

end;

procedure TProxyInfoImpl.ReadUserSysCfg(AFile: TIniFile);
begin

end;

procedure TProxyInfoImpl.WriteUserSysCfg(AFile: TIniFile);
begin

end;

function TProxyInfoImpl.GetProxy: PProxy;
begin
  Result := @FProxy;
end;

function TProxyInfoImpl.GetIsUseProxy: boolean;
begin
  Result := (FIsUseProxy = 1);
end;

procedure TProxyInfoImpl.SetIsUseProxy(AIsUseProxy: Boolean);
begin
  if AIsUseProxy then begin
    FIsUseProxy := 1;
  end else begin
    FIsUseProxy := 0;
  end;
end;

function TProxyInfoImpl.ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
begin
  case AProxyType of
    ptNo:
      Result := 0;
    ptHttp:
      Result := 1;
    ptSocket4:
      Result := 2;
    ptSocket5:
      Result := 3;
  else
    Result := ADefault;
  end;
end;

function TProxyInfoImpl.IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
begin
  case AValue of
    0:
      begin
        Result := ptNo;
      end;
    1:
      begin
        Result := ptHttp;
      end;
    2:
      begin
        Result := ptSocket4;
      end;
    3:
      begin
        Result := ptSocket5;
      end;
  else
    Result := ADefault;
  end;
end;

end.
