unit ShortKeyDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ShortKeyDataMgrCommand Implementation
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
  ShortKeyDataMgr;

type

  // ShortKeyDataMgrCommand Implementation
  TShortKeyDataMgrCommandImpl = class(TCommandImpl)
  private
    // ShortKeyDataMgr
    FShortKeyDataMgr: IShortKeyDataMgr;
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
  ShortKeyDataMgrImpl;

{ TShortKeyDataMgrCommandImpl }

constructor TShortKeyDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TShortKeyDataMgrCommandImpl.Destroy;
begin
  if FShortKeyDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FShortKeyDataMgr := nil;
  end;
  inherited;
end;

procedure TShortKeyDataMgrCommandImpl.Execute(AParams: string);
begin
  if FShortKeyDataMgr = nil then begin
    FShortKeyDataMgr := TShortKeyDataMgrImpl.Create(FAppContext) as IShortKeyDataMgr;
    FAppContext.RegisterInteface(FId, FShortKeyDataMgr);
  end;
end;

procedure TShortKeyDataMgrCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TShortKeyDataMgrCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TShortKeyDataMgrCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
