unit SectorMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SectorMain Implementation
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
  SectorMain;

type

  // SectorMain Implementation
  TSectorMainImpl = class(TBaseInterfacedObject, ISectorMain)
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
