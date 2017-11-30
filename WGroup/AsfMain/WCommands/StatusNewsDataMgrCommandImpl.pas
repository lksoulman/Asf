unit StatusNewsDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusNewsDataMgrCommand Implementation
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
  StatusNewsDataMgr;

type

  // StatusNewsDataMgrCommand Implementation
  TStatusNewsDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusNewsDataMgr
    FStatusNewsDataMgr: IStatusNewsDataMgr;
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
  StatusNewsDataMgrImpl;

{ TStatusNewsDataMgrCommandImpl }

constructor TStatusNewsDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusNewsDataMgrCommandImpl.Destroy;
begin
  if FStatusNewsDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusNewsDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusNewsDataMgrCommandImpl.Execute(AParams: string);
begin
  if FStatusNewsDataMgr = nil then begin
    FStatusNewsDataMgr := TStatusNewsDataMgrImpl.Create(FAppContext) as IStatusNewsDataMgr;
    FAppContext.RegisterInteface(FId, FStatusNewsDataMgr);
  end;
end;

procedure TStatusNewsDataMgrCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TStatusNewsDataMgrCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TStatusNewsDataMgrCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
