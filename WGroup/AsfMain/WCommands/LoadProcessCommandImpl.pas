unit LoadProcessCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º LoadProcessCommand Interface Implementation
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
  LoadProcess,
  CommandImpl;

type

  // LoadProcessCommand Interface Implementation
  TLoadProcessCommandImpl = class(TCommandImpl)
  private
    // LoadProcess
    FLoadProcess: ILoadProcess;
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
  LoadProcessImpl;

{ TLoadProcessCommandImpl }

constructor TLoadProcessCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TLoadProcessCommandImpl.Destroy;
begin
  if FLoadProcess <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FLoadProcess := nil;
  end;
  inherited;
end;

procedure TLoadProcessCommandImpl.Execute(AParams: string);
begin
  if FLoadProcess = nil then begin
    FLoadProcess := TLoadProcessImpl.Create(FAppContext) as ILoadProcess;
    FAppContext.RegisterInteface(FId, FLoadProcess);
  end;

  if FLoadProcess = nil then Exit;

  if not FLoadProcess.IsShowing then begin
    FLoadProcess.Show;
  end;
  FLoadProcess.ShowInfo(AParams);
end;

end.
