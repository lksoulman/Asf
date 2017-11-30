unit BasicServiceCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BasicServiceCommand Implementation
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
  AppContext,
  Command,
  CommandImpl,
  BasicService;

type

  // BasicServiceCommand Implementation
  TBasicServiceCommandImpl = class(TCommandImpl)
  private
    // BasicService
    FBasicService: IBasicService;
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
  BasicServiceImpl;

{ TBasicServiceCommandImpl }

constructor TBasicServiceCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TBasicServiceCommandImpl.Destroy;
begin
  if FBasicService <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FBasicService := nil;
  end;
  inherited;
end;

procedure TBasicServiceCommandImpl.Execute(AParams: string);
begin
  if FBasicService = nil then begin
    FBasicService := TBasicServiceImpl.Create(FAppContext) as IBasicService;
    FAppContext.RegisterInteface(FId, FBasicService);
  end;
end;

procedure TBasicServiceCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TBasicServiceCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TBasicServiceCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
