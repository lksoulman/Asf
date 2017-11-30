unit StatusHqDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusHqDataMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Command,
  SysUtils,
  AppContext,
  CommandImpl,
  StatusHqDataMgr;

type

  // StatusHqDataMgrCommand Implementation
  TStatusHqDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusHqDataMgr
    FStatusHqDataMgr: IStatusHqDataMgr;
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
  StatusHqDataMgrImpl;

{ TStatusHqDataMgrCommandImpl }

constructor TStatusHqDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusHqDataMgrCommandImpl.Destroy;
begin
  if FStatusHqDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusHqDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusHqDataMgrCommandImpl.Execute(AParams: string);
begin
  if FStatusHqDataMgr = nil then begin
    FStatusHqDataMgr := TStatusHqDataMgrImpl.Create(FAppContext) as IStatusHqDataMgr;
    FAppContext.RegisterInteface(FId, FStatusHqDataMgr);
  end;
end;

end.
