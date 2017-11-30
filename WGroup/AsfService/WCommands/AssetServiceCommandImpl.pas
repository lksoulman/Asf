unit AssetServiceCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AssetServiceCommand Implementation
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
  AssetService;

type

  // AssetServiceCommand Implementation
  TAssetServiceCommandImpl = class(TCommandImpl)
  private
    // AssetService
    FAssetService: IAssetService;
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
  AssetServiceImpl;

{ TAssetServiceCommandImpl }

constructor TAssetServiceCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TAssetServiceCommandImpl.Destroy;
begin
  if FAssetService <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FAssetService := nil;
  end;
  inherited;
end;

procedure TAssetServiceCommandImpl.Execute(AParams: string);
begin
  if FAssetService = nil then begin
    FAssetService := TAssetServiceImpl.Create(FAppContext) as IAssetService;
    FAppContext.RegisterInteface(FId, FAssetService);
  end;
end;

procedure TAssetServiceCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TAssetServiceCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TAssetServiceCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
