unit CommandCookieMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CommandCookieMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  CommandImpl,
  CommandCookieMgr;

type

  // CommandCookieMgrCommand Implementation
  TCommandCookieMgrCommandImpl = class(TCommandImpl)
  private
    // CommandCookieMgr
    FCommandCookieMgr: ICommandCookieMgr;
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
  CommandCookieMgrImpl;

{ TCommandCookieMgrCommandImpl }

constructor TCommandCookieMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TCommandCookieMgrCommandImpl.Destroy;
begin
  if FCommandCookieMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FCommandCookieMgr := nil;
  end;
  inherited;
end;

procedure TCommandCookieMgrCommandImpl.Execute(AParams: string);
begin
  if FCommandCookieMgr = nil then begin
    FCommandCookieMgr := TCommandCookieMgrImpl.Create(FAppContext) as ICommandCookieMgr;
    FAppContext.RegisterInteface(FId, FCommandCookieMgr);
  end;
end;

end.
