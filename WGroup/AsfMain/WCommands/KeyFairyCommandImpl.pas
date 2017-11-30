unit KeyFairyCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairyCommand Implementation
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
  KeyFairy,
  AppContext,
  CommandImpl;

type

  // KeyFairyCommand Implementation
  TKeyFairyCommandImpl = class(TCommandImpl)
  private
    // KeyFairy
    FKeyFairy: IKeyFairy;
  protected
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Execute
    procedure Execute(AParams: string); override;
    // Execute
    procedure ExecuteEx(AParams: array of string); override;
    // Execute
    procedure ExecuteAsync(AParams: string); override;
    // Execute
    procedure ExecuteAsyncEx(AParams: array of string); override;
  end;

implementation

uses
  KeyFairyImpl;

{ TKeyFairyCommandImpl }

constructor TKeyFairyCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TKeyFairyCommandImpl.Destroy;
begin
  if FKeyFairy <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FKeyFairy := nil;
  end;
  inherited;
end;

procedure TKeyFairyCommandImpl.Execute(AParams: string);
begin
  if FKeyFairy = nil then begin
    FKeyFairy := TKeyFairyImpl.Create(FAppContext) as IKeyFairy;
    FAppContext.RegisterInteface(FId, FKeyFairy);
  end;
end;

procedure TKeyFairyCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TKeyFairyCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TKeyFairyCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
