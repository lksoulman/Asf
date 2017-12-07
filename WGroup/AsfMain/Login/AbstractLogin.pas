unit AbstractLogin;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AbstractLogin
// Author��      lksoulman
// Date��        2017-8-19
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Cfg,
  Windows,
  Classes,
  SysUtils,
  Controls,
  Command,
  AppContext,
  ServiceType,
  LoginMainUI,
  BasicService,
  AssetService,
  CommonRefCounter;

type

  // AbstractLogin
  TAbstractLogin = class(TAutoObject)
  private
  protected
    // Cfg
    FCfg: ICfg;
    // IsLoginedBasic
    FIsLoginedBasic: Boolean;
    // Is Logined Asset
    FIsLoginedAsset: Boolean;
    // AppContext
    FAppContext: IAppContext;
    // Login Main UI
    FLoginMainUI: TLoginMainUI;
    // Basic Service
    FBasicService: IBasicService;
    // Asset Service
    FAssetService: IAssetService;
    // Baisc Bind
    FGilBasicBind: TGilBasicBind;
    // Basic Login
    FGilBasicLogin: TGilBasicLogin;

    // Check Is Need Bind
    function DoCheckIsNeedBind: boolean;
    // Login Basic
    function DoLoginBasic: boolean; virtual;
    // Login Asset
    function DoLoginAsset: Boolean; virtual;
    // Init Login Info
    function DoInitLoginInfos: Boolean; virtual;
    // Login Call Back
    function DoCallBackLoginFunc: Boolean; virtual;
    // Get Error Info
    function GetErrorInfo(AErrorCode: Integer): string;
    // Re Login Basic
    procedure DoReLoginBasic(AErrorCode: Integer; AErrorInfo: WideString); virtual;
    // Re Login Asset
    procedure DoReLoginAsset(AErrorCode: Integer; AErrorInfo: WideString); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Show Login Bind UI
    procedure ShowLoginBindUI;
    // Show Login Main UI
    function ShowLoginMainUI: Integer;
    // Show Login Info
    procedure ShowLoginInfo(AMsg: WideString);
    // Is Login
    function IsLogin(AServiceType: TServiceType): Boolean; virtual;
  end;

implementation

uses
  LogLevel,
  UserInfo,
  ErrorCode,
  ServerCfg,
  ServerInfo;

{ TAbstractLogin }

constructor TAbstractLogin.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FCfg := FAppContext.GetCfg;
  FBasicService := FAppContext.FindInterface(ASF_COMMAND_ID_BASICSERVICE) as IBasicService;
  FAssetService := FAppContext.FindInterface(ASF_COMMAND_ID_ASSETSERVICE) as IAssetService;
 
  FLoginMainUI := TLoginMainUI.Create(FAppContext);
  FLoginMainUI.SetLoginFunc(DoCallBackLoginFunc);

  if FCfg <> nil then begin
    DoInitLoginInfos;
  end;

  if FBasicService <> nil then begin
    FBasicService.SetReLoginEvent(DoReLoginBasic);
  end;

  if FAssetService <> nil then begin
    FAssetService.SetReLoginEvent(DoReLoginAsset);
  end;

  FIsLoginedBasic := False;
  FIsLoginedAsset := False;
end;

destructor TAbstractLogin.Destroy;
begin
  FLoginMainUI.Free;
  FAssetService := nil;
  FBasicService := nil;
  FCfg := nil;
  FAppContext := nil;
  inherited;
end;

function TAbstractLogin.DoCheckIsNeedBind: boolean;
begin
  Result := False;
  if FCfg.GetSysCfg.GetUserInfo <> nil then begin
    if (FCfg.GetSysCfg.GetUserInfo.GetBindInfo^.FLicense = '')
      or (FCfg.GetSysCfg.GetUserInfo.GetBindInfo^.FOrgSign = '') then begin
      Result := True;
    end;
  end;
end;

function TAbstractLogin.DoLoginBasic: boolean;
var
  LServerUrl: string;
  LServerUrlIsNull: Boolean;
begin
  Result := False;
  LServerUrlIsNull := True;
  FCfg.GetServerCfg.GetBasicServerInfo.FirstServer;
  while not FCfg.GetServerCfg.GetBasicServerInfo.IsEOF do begin
    LServerUrl := FCfg.GetServerCfg.GetBasicServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      if LServerUrlIsNull then begin
        LServerUrlIsNull := False;
      end;

      if DoCheckIsNeedBind then begin
        if FLoginMainUI.ShowLoginBindUI = mrOk then begin
          FGilBasicBind.FServerUrl := LServerUrl;
          if FCfg.GetSysCfg.GetUserInfo.GetAccountType = atPBOX then begin
            FGilBasicBind.FUserName := FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FUserName;
          end else begin
            FGilBasicBind.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
          end;
          FGilBasicBind.FGilUserName := FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName;
          Result := FBasicService.GilBind(@FGilBasicBind);
          // Bind Success
          if Result then begin
            FCfg.GetSysCfg.GetUserInfo.GetBindInfo^.FLicense := FGilBasicBind.FLicense;
            FCfg.GetSysCfg.GetUserInfo.GetBindInfo^.FOrgSign := FGilBasicBind.FOrgSign;
            FGilBasicLogin.FServerUrl := LServerUrl;
            FGilBasicLogin.FUserName := FGilBasicBind.FUserName;
            FGilBasicLogin.FLicense := FGilBasicBind.FLicense;
            Result := FBasicService.GilLogin(@FGilBasicLogin);
            if Result then begin
            // Login Success
              Exit;
            end else begin
            // Login Fail
              case FGilBasicLogin.FErrorCode of
                ErrorCode_Service_Wait_Timeout,
                ErrorCode_Service_Wait_Failed,
                ErrorCode_Service_Network_Except,
                ErrorCode_Service_Login_Failed:
                  begin
                    FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                  end;
                ErrorCode_Service_Login_Password_CheckFailed,
                ErrorCode_Service_Login_ElseWhere_Logined:
                  begin
                    FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                    Exit;
                  end;
                ErrorCode_Service_Login_MacCode_CheckFailed:
                  begin
                    FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                    Continue;
                  end;
              end;
            end;
          end else begin
          // Bind Fail
            case FGilBasicBind.FErrorCode of
              ErrorCode_Service_Wait_Timeout,
              ErrorCode_Service_Wait_Failed,
              ErrorCode_Service_Network_Except:
                begin
                  FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
                end;
              ErrorCode_Service_Login_License_Binded,
              ErrorCode_Service_Login_License_Bind_Except,
              ErrorCode_Service_Login_License_Invalid:
                begin
                  FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
                end;
            else
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
              end;
            end;
          end;
        end else begin
          Exit;
        end;
      end else begin
        FGilBasicLogin.FServerUrl := LServerUrl;
        if FCfg.GetSysCfg.GetUserInfo.GetAccountType = atPBOX then begin
          FGilBasicLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FUserName;
        end else begin
          FGilBasicLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
        end;
        FGilBasicLogin.FLicense := FCfg.GetSysCfg.GetUserInfo.GetBindInfo^.FLicense;
        Result := FBasicService.GilLogin(@FGilBasicLogin);
        if Result then begin
        // Login Success
          Exit;
        end else begin
        // Login Fail
          case FGilBasicLogin.FErrorCode of
            ErrorCode_Service_Wait_Timeout,
            ErrorCode_Service_Wait_Failed,
            ErrorCode_Service_Network_Except,
            ErrorCode_Service_Login_Failed:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
              end;
            ErrorCode_Service_Login_Password_CheckFailed,
            ErrorCode_Service_Login_ElseWhere_Logined:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                Exit;
              end;
            ErrorCode_Service_Login_License_Invalid:
              begin
                FCfg.GetSysCfg.GetUserInfo.ResetBindInfo;
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                Continue;
              end;
            ErrorCode_Service_Login_MacCode_CheckFailed:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                Continue;
              end;
          end;
        end;
      end;
    end;
    FCfg.GetServerCfg.GetBasicServerInfo.NextServer;
  end;
end;

function TAbstractLogin.DoLoginAsset: Boolean;
begin
  Result := False;
end;

function TAbstractLogin.DoInitLoginInfos: Boolean;
begin
  Result := True;
  FGilBasicBind.FOrgNo := FCfg.GetSysCfg.GetUserInfo.GetOrgNo;
  FGilBasicBind.FAssetNo := FCfg.GetSysCfg.GetUserInfo.GetAssetNo;
  FGilBasicBind.FHardDiskIdMD5 := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskIdMD5;

  FGilBasicLogin.FOrgNo := FCfg.GetSysCfg.GetUserInfo.GetOrgNo;
  FGilBasicLogin.FAssetNo := FCfg.GetSysCfg.GetUserInfo.GetAssetNo;
  FGilBasicLogin.FHardDiskIdMD5 := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskIdMD5;
end;

function TAbstractLogin.DoCallBackLoginFunc: Boolean;
begin
  Result := False;
  if (FBasicService = nil) then begin
    FAppContext.SysLog(llERROR, Format('[%s][DoCallBackLoginFunc] FBasicService is nil.', [Self.ClassName]));
    Exit;
  end;
  if (FAssetService = nil) then begin
    FAppContext.SysLog(llERROR, Format('[%s][DoCallBackLoginFunc] FAssetService is nil.', [Self.ClassName]));
    Exit;
  end;

  Result := DoLoginAsset;
  FIsLoginedAsset := Result;
  if Result then begin
    Result := DoLoginBasic;
    FIsLoginedBasic := Result;
  end;
end;

function TAbstractLogin.GetErrorInfo(AErrorCode: Integer): string;
begin
  if FAppContext <> nil then begin
    Result := FAppContext.GetErrorInfo(AErrorCode);
  end else begin
    Result := '';
  end;
end;

procedure TAbstractLogin.DoReLoginBasic(AErrorCode: Integer; AErrorInfo: WideString);
begin
  FIsLoginedBasic := False;

end;

procedure TAbstractLogin.DoReLoginAsset(AErrorCode: Integer; AErrorInfo: WideString);
begin
  FIsLoginedAsset := False;

end;

function TAbstractLogin.ShowLoginMainUI: Integer;
begin
  Result := FLoginMainUI.ShowLogin;
end;

procedure TAbstractLogin.ShowLoginBindUI;
begin
  FLoginMainUI.ShowLoginBindUI;
end;

procedure TAbstractLogin.ShowLoginInfo(AMsg: WideString);
begin
  FLoginMainUI.ShowLoginInfo(AMsg);
end;

function TAbstractLogin.IsLogin(AServiceType: TServiceType): Boolean;
begin
  case AServiceType of
    stBasic:
      begin
        if (FBasicService <> nil)
          and FBasicService.IsLogined then begin
          Result := True;
        end else begin
          Result := False;
        end;
      end;
    stAsset:
      begin
        if (FAssetService <> nil)
          and FAssetService.IsLogined then begin
          Result := True;
        end else begin
          Result := False;
        end;
      end;
  else
    begin
      Result := IsLogin(stBasic) and IsLogin(stAsset);
    end;
  end;
end;

end.
