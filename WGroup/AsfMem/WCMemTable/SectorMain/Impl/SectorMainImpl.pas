unit SectorMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorMain Implementation
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
  SectorMain,
  AppContextObject;

type

  // SectorMain Implementation
  TSectorMainImpl = class(TAppContextObject, ISectorMain)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TSectorMainImpl }

constructor TSectorMainImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TSectorMainImpl.Destroy;
begin

  inherited;
end;

end.
