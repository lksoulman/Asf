unit SectorTreeImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorTree Implementation
// Author£º      lksoulman
// Date£º        2018-1-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SectorTree,
  BaseObject,
  AppContext,
  SectortreeUI;

type

  // SectorTree Implementation
  TSectorTreeImpl = class(TBaseInterfacedObject, ISectorTree)
  private
  protected
    // AppContext
    FAppContext: IAppContext;
    // SectortreeUI
    FSectortreeUI: TSectortreeUI;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISectorTree }

    // Show
    procedure Show;
    // Hide
    procedure Hide;
  end;

implementation

{ TSectorTreeImpl }

constructor TSectorTreeImpl.Create(AContext: IAppContext);
begin
  inherited;
  FSectortreeUI := TSectortreeUI.Create(AContext);
end;

destructor TSectorTreeImpl.Destroy;
begin
  FSectortreeUI.Free;
  inherited;
end;

procedure TSectorTreeImpl.Show;
begin
  FSectortreeUI.ShowEx;
end;

procedure TSectorTreeImpl.Hide;
begin
  FSectortreeUI.Hide;
end;

end.
