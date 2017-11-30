unit StatusServerDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� StatusServerDataMgrCommand Implementation
// Author��      lksoulman
// Date��        2017-11-20
// Comments��
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
  StatusServerDataMgr;

type

  // StatusServerDataMgrCommand Implementation
  TStatusServerDataMgrCommandImpl = class(TCommandImpl)
  private
    // StatusServerDataMgr
    FStatusServerDataMgr: IStatusServerDataMgr;
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
  StatusServerDataMgrImpl;

{ TStatusServerDataMgrCommandImpl }

constructor TStatusServerDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TStatusServerDataMgrCommandImpl.Destroy;
begin
  if FStatusServerDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FStatusServerDataMgr := nil;
  end;
  inherited;
end;

procedure TStatusServerDataMgrCommandImpl.Execute(AParams: string);
begin
  if FStatusServerDataMgr = nil then begin
    FStatusServerDataMgr := TStatusServerDataMgrImpl.Create(FAppContext) as IStatusServerDataMgr;
    FAppContext.RegisterInteface(FId, FStatusServerDataMgr);
  end;
end;

end.
