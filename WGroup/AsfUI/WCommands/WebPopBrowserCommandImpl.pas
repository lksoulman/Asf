unit WebPopBrowserCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º WebPopBrowserCommand Implementation
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
  WebPopBrowser;

type

  // WebPopBrowserCommand Implementation
  TWebPopBrowserCommandImpl = class(TCommandImpl)
  private
    // WebPopBrowser
    FWebPopBrowser: IWebPopBrowser;
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
  WebPopBrowserImpl;

{ TWebPopBrowserCommandImpl }

constructor TWebPopBrowserCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TWebPopBrowserCommandImpl.Destroy;
begin
  if FWebPopBrowser <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FWebPopBrowser := nil;
  end;
  inherited;
end;

procedure TWebPopBrowserCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if AParams = '' then begin
    if FWebPopBrowser = nil then begin
      FWebPopBrowser := TWebPopBrowserImpl.Create(FAppContext) as IWebPopBrowser;
      FAppContext.RegisterInteface(FId, FWebPopBrowser);
    end;
  end else begin
    BeginSplitParams(AParams);
    try
      ParamsVal('FuncName', LFuncName);
      if LFuncName <> 'Hide' then begin
        if FWebPopBrowser <> nil then begin
          FWebPopBrowser.Hide;
        end;
      end;
    finally
      EndSplitParams;
    end;
  end;
end;

end.
