unit StatusAlarmDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusAlarmDataMgrCommand Implementation
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
  StatusAlarmDataMgr;

type

  // StatusAlarmDataMgrCommand Implementation
  TStatusAlarmDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusAlarmDataMgr
    FStatusAlarmDataMgr: IStatusAlarmDataMgr;
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
  StatusAlarmDataMgrImpl;

{ TStatusAlarmDataMgrCommandImpl }

constructor TStatusAlarmDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusAlarmDataMgrCommandImpl.Destroy;
begin
  if FStatusAlarmDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusAlarmDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusAlarmDataMgrCommandImpl.Execute(AParams: string);
begin
  if FStatusAlarmDataMgr = nil then begin
    FStatusAlarmDataMgr := TStatusAlarmDataMgrImpl.Create(FAppContext) as IStatusAlarmDataMgr;
    FAppContext.RegisterInteface(FId, FStatusAlarmDataMgr);
  end;
end;

procedure TStatusAlarmDataMgrCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TStatusAlarmDataMgrCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TStatusAlarmDataMgrCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
