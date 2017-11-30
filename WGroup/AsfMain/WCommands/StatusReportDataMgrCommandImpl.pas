unit StatusReportDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusReportDataMgrCommand Implementation
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
  StatusReportDataMgr;

type

  // StatusReportDataMgrCommand Implementation
  TStatusReportDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusReportDataMgr
    FStatusReportDataMgr: IStatusReportDataMgr;
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
  StatusReportDataMgrImpl;

{ TStatusReportDataMgrCommandImpl }

constructor TStatusReportDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusReportDataMgrCommandImpl.Destroy;
begin
  if FStatusReportDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusReportDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusReportDataMgrCommandImpl.Execute(AParams: string);
begin
  if FStatusReportDataMgr = nil then begin
    FStatusReportDataMgr := TStatusReportDataMgrImpl.Create(FAppContext) as IStatusReportDataMgr;
    FAppContext.RegisterInteface(FId, FStatusReportDataMgr);
  end;
end;

procedure TStatusReportDataMgrCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TStatusReportDataMgrCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TStatusReportDataMgrCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
