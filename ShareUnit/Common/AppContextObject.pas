unit AppContextObject;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AppContextObject
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // AppContextObject
  TAppContextObject = class(TAutoInterfacedObject)
  private
  protected
    // AppContext
    FAppContext: IAppContext;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TAppContextObject }

constructor TAppContextObject.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TAppContextObject.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

end.
