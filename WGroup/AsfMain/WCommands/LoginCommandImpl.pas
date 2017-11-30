unit LoginCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� LoginCommand Implementation
// Author��      lksoulman
// Date��        2017-11-14
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Login,
  Command,
  AppContext,
  CommandImpl;

type

  // LoginCommand Implementation
  TLoginCommandImpl = class(TCommandImpl)
  private
    // Login
    FLogin: ILogin;
  protected
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Execute
    procedure Execute(AParams: string); override;
  end;

implementation

uses
  LoginImpl;

{ TLoginCommandImpl }

constructor TLoginCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TLoginCommandImpl.Destroy;
begin
  if FLogin <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FLogin := nil;
  end;
  inherited;
end;

procedure TLoginCommandImpl.Execute(AParams: string);
begin
  if FLogin = nil then begin
    FLogin := TLoginImpl.Create(FAppContext) as ILogin;
    FAppContext.RegisterInteface(FId, FLogin);
  end;
end;

end.
