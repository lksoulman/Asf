unit BaseObject;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� BaseObject
// Author��      lksoulman
// Date��        2017-12-18
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter;

type

  // BaseObject
  TBaseObject = class(TAutoObject)
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

  // BaseInterfacedObject
  TBaseInterfacedObject = class(TAutoInterfacedObject)
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

{ TBaseObject }

constructor TBaseObject.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TBaseObject.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

{ TBaseInterfacedObject }

constructor TBaseInterfacedObject.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TBaseInterfacedObject.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

end.
