unit UserFundMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserFundMain Implementation
// Author£º      lksoulman
// Date£º        2017-9-2
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  UserFundMain,
  AppContextObject;

type

  // UserFundMain Implementation
  TUserFundMainImpl = class(TAppContextObject, IUserFundMain)
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
