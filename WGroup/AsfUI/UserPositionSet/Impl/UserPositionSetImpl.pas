unit UserPositionSetImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� UserPositionSet Implementation
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
  UserPositionSet,
  UserPositionSetUI;

type

  // UserPositionSet Implementation
  TUserPositionSetImpl = class(TBaseInterfacedObject, IUserPositionSet)
  private
    // UserPositionSetUI
    FUserPositionSetUI: TUserPositionSetUI;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserPositionSet }

    // Show
    procedure Show;
    // Hide
    procedure Hide;
  end;

implementation

{ TUserPositionSetImpl }

constructor TUserPositionSetImpl.Create(AContext: IAppContext);
begin
  inherited;
  FUserPositionSetUI := TUserPositionSetUI.Create(FAppContext);
end;

destructor TUserPositionSetImpl.Destroy;
begin
  FUserPositionSetUI.Free;
  inherited;
end;

procedure TUserPositionSetImpl.Show;
begin
  FUserPositionSetUI.ShowEx;
end;

procedure TUserPositionSetImpl.Hide;
begin
  FUserPositionSetUI.Hide;
end;

end.
