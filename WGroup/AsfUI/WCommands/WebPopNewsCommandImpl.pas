unit WebPopNewsCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º WebPopNewsCommand Implementation
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

  // WebPopNewsCommand Implementation
  TWebPopNewsCommandImpl = class(TCommandImpl)
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

{ TWebPopNewsCommandImpl }

constructor TWebPopNewsCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TWebPopNewsCommandImpl.Destroy;
begin
  if FWebPopBrowser <> nil then begin
    FWebPopBrowser := nil;
  end;
  inherited;
end;

procedure TWebPopNewsCommandImpl.Execute(AParams: string);
var
  LFuncName, LUrl: string;
begin
  if FWebPopBrowser = nil then begin
    FWebPopBrowser := FAppContext.FindInterface(ASF_COMMAND_ID_WEBPOP_BROWSER) as IWebPopBrowser;
  end;

  if (AParams = '')
    or (FWebPopBrowser = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'LoadWebUrl' then begin
      ParamsVal('Url', LUrl);
      if LUrl <> '' then begin
        FWebPopBrowser.LoadWebUrl('[ÐÂÎÅ]', LUrl);
      end;
      FWebPopBrowser.Show;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
