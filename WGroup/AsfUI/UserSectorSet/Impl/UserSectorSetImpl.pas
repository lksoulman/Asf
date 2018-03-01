unit UserSectorSetImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� UserSectorSet Implementation
// Author��      lksoulman
// Date��        2018-1-17
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  UserSectorSet,
  UserSectorSetUI;

type

  // UserSectorSet Implementation
  TUserSectorSetImpl = class(TBaseInterfacedObject, IUserSectorSet)
  private
    // UserSectorSetUI
    FUserSectorSetUI: TUserSectorSetUI;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserSectorSet }

    // Show
    procedure Show;
    // Hide
    procedure Hide;
  end;

implementation

{ TUserSectorSetImpl }

constructor TUserSectorSetImpl.Create(AContext: IAppContext);
begin
  inherited;
  FUserSectorSetUI := TUserSectorSetUI.Create(FAppContext);
end;

destructor TUserSectorSetImpl.Destroy;
begin
  FUserSectorSetUI.Free;
  inherited;
end;

procedure TUserSectorSetImpl.Show;
begin
  FUserSectorSetUI.ShowEx;
end;

procedure TUserSectorSetImpl.Hide;
begin
  FUserSectorSetUI.Hide;
end;

end.
