unit UserFundMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� UserFundMain Implementation
// Author��      lksoulman
// Date��        2017-9-2
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
  UserFundMain;

type

  // UserFundMain Implementation
  TUserFundMainImpl = class(TBaseInterfacedObject, IUserFundMain)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TUserFundMainImpl }

constructor TUserFundMainImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserFundMainImpl.Destroy;
begin

  inherited;
end;

end.
