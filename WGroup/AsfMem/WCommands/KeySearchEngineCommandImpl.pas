unit KeySearchEngineCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeySearchEngineCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-14
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
  KeySearchEngine;

type

  // KeySearchEngineCommand Implementation
  TKeySearchEngineCommandImpl = class(TCommandImpl)
  private
    // KeySearchEngine
    FKeySearchEngine: IKeySearchEngine;
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
  KeySearchEngineImpl;

{ TKeySearchEngineCommandImpl }

constructor TKeySearchEngineCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TKeySearchEngineCommandImpl.Destroy;
begin
  if FKeySearchEngine <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FKeySearchEngine := nil;
  end;
  inherited;
end;

procedure TKeySearchEngineCommandImpl.Execute(AParams: string);
begin
  if FKeySearchEngine = nil then begin
    FKeySearchEngine := TKeySearchEngineImpl.Create(FAppContext) as IKeySearchEngine;
    FAppContext.RegisterInteface(FId, FKeySearchEngine);
  end;
end;

end.
