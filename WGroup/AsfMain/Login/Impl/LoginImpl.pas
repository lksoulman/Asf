unit LoginImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Login Implementation
// Author£º      lksoulman
// Date£º        2017-9-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Login,
  Windows,
  Classes,
  SysUtils,
  Controls,
  AppContext,
  ServiceType,
  AbstractLogin,
  AppContextObject;

type

  // Login Implementation
  TLoginImpl = class(TAppContextObject, ILogin)
  private
    // Login
    FLogin: TAbstractLogin;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ILogin }

    // Login
    function Login: Boolean;
    // IsLogin
    function IsLogin(AServiceType: TServiceType): Boolean;
  end;

implementation

uses
  Cfg,
  SysCfg,
  UserInfo,
  UFXAccountLogin,
  GilAccountLogin,
  PBoxAccountLogin;

{ TLoginImpl }

constructor TLoginImpl.Create(AContext: IAppContext);
begin
  inherited;
  if FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetAccountType = atGIL then begin
    FLogin := TGilAccountLogin.Create(FAppContext);
  end else if FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetAccountType = atPBOX then begin
    FLogin := TPBoxAccountLogin.Create(FAppContext);
  end else begin
    FLogin := TUFXAccountLogin.Create(FAppContext);
  end;
end;

destructor TLoginImpl.Destroy;
begin
  FLogin.Free;
  inherited;
end;

function TLoginImpl.Login: Boolean;
begin
  if FLogin.ShowLoginMainUI = mrOk then begin
    if FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetSavePassword then begin
      FAppContext.GetCfg.GetSysCfg.GetUserInfo.SaveCache;
    end;
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TLoginImpl.IsLogin(AServiceType: TServiceType): Boolean;
begin
  Result := FLogin.IsLogin(AServiceType);
end;

end.
