unit BrowserImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Browser Implementation
// Author£º      lksoulman
// Date£º        2017-12-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  Chrome,
  Browser,
  BaseObject,
  AppContext,
  CustomBaseUI,
  DcefB.Cef3.Types,
  DcefB.Cef3.Classes,
  DcefB.Cef3.Interfaces,
  DcefB.Core.DcefBrowser;

type

  // BrowserUI
  TBrowserUI = class(TCustomBaseUI)
  private
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

  // Browser Implementation
  TBrowserImpl = class(TBaseInterfacedObject, IBrowser)
  private
    // Chrome
    FChrome: IChrome;
    // BrowserUI
    FBrowserUI: TBrowserUI;
    // DcefBrowser
    FDcefBrowser: TDcefBrowser;
  protected
    // BrowserBeforeContextMenu
    procedure DoBrowserBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    // BrowserBeforePopup
    procedure DoBrowserBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo; var client: ICefClient;
      var settings: TCefBrowserSettings; var noJavascriptAccess: Boolean; var Cancel: Boolean;
      var CancelDefaultEvent: Boolean);
    // BrowserBeforeDownload
    procedure DoBrowserBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback; var CancelDefaultEvent: Boolean);
    // BrowserDownloadUpdated
    procedure DoBrowserDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback);
    // BrowserPreKeyEvent
    procedure DoBrowserPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; var isKeyboardShortcut: Boolean; var Cancel: Boolean; var CancelDefaultEvent: Boolean);
    // BrowserLoadStart
    procedure DoBrowserLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
    // BrowserLoadEnd
    procedure DoBrowserLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    // BrowserCertificateError
    procedure DoBrowserCertificateError(const browser: ICefBrowser; certError: TCefErrorcode; const requestUrl: ustring;
      const sslInfo: ICefSslInfo; const callback: ICefRequestCallback; out Cancel: Boolean);
    // BrowserBeforeResourceLoad
    procedure DoBrowserBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame; const request: ICefRequest;
      const callback: ICefRequestCallback; out Result: TCefReturnValue);
    // BrowserKeyEvent
    procedure DoBrowserKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent; osEvent: TCefEventHandle;
      var Cancel: Boolean);
  public
    // Constructor
    constructor Create(AContext: IAppContext; AChrome: IChrome); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IBrowser }

    // StopLoad
    procedure StopLoad;
    // GetUrl
    function GetUrl: string;
    // GoBack
    function GoBack: Boolean;
    // GoForward
    function GoForward: Boolean;
    // CanGoBack
    function CanGoBack: Boolean;
    // CanGoForward
    function CanGoForward: Boolean;
    // GetBrowserUI
    function GetBrowserUI: TForm;
    // LoadWebUrl
    procedure LoadWebUrl(AUrl: string);
    // NotifyExValChange
    procedure NotifyExValChange(AKey: string);
    // ExecuteJavaScript
    procedure ExecuteJavaScript(AJavaScript: string);
  end;

implementation

{ TBrowserUI }

constructor TBrowserUI.Create(AContext: IAppContext);
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderWidth := 0;
  FCaptionHeight := 0;
  FBorderStyleEx := bsNone;
end;

destructor TBrowserUI.Destroy;
begin

  inherited;
end;

procedure TBrowserUI.DoBeforeCreate;
begin
  inherited;
  FCaptionHeight := 0;
  FBorderStyleEx := bsNone;
end;

{ TBrowserImpl }

constructor TBrowserImpl.Create(AContext: IAppContext; AChrome: IChrome);
begin
  inherited Create(AContext);
//  FChrome := AChrome;
  FBrowserUI := TBrowserUI.Create(FAppContext);
  FDcefBrowser := TDcefBrowser.Create(nil);
  FDcefBrowser.Parent := FBrowserUI;
  FDcefBrowser.Align := alClient;
  FDcefBrowser.OnBeforeContextMenu := DoBrowserBeforeContextMenu;
  FDcefBrowser.OnBeforePopup := DoBrowserBeforePopup;
  FDcefBrowser.OnBeforeDownload := DoBrowserBeforeDownload;
  FDcefBrowser.OnDownloadUpdated := DoBrowserDownloadUpdated;
  FDcefBrowser.OnPreKeyEvent := DoBrowserPreKeyEvent;
  FDcefBrowser.OnLoadStart := DoBrowserLoadStart;
  FDcefBrowser.OnLoadEnd := DoBrowserLoadEnd;
  FDcefBrowser.OnCertificateError := DoBrowserCertificateError;
  FDcefBrowser.OnBeforeResourceLoad := DoBrowserBeforeResourceLoad;
  FDcefBrowser.OnKeyEvent := DoBrowserKeyEvent;
end;

destructor TBrowserImpl.Destroy;
begin
  FDcefBrowser.StopLoad;
  FDcefBrowser.Free;
  FBrowserUI.Free;
//  FChrome := nil;
  inherited;
end;

procedure TBrowserImpl.StopLoad;
begin
  FDcefBrowser.StopLoad;
end;

function TBrowserImpl.GetUrl: string;
begin
  Result := FDcefBrowser.URL;
end;

function TBrowserImpl.GoBack: Boolean;
begin
  Result := True;
  FDcefBrowser.GoBack;
end;

function TBrowserImpl.GoForward: Boolean;
begin
  Result := True;
  FDcefBrowser.GoForward;
end;

function TBrowserImpl.CanGoBack: Boolean;
begin
  Result := FDcefBrowser.CanGoBack;
end;

function TBrowserImpl.CanGoForward: Boolean;
begin
  Result := FDcefBrowser.CanGoForward;
end;

function TBrowserImpl.GetBrowserUI: TForm;
begin
  Result := FBrowserUI;
end;

procedure TBrowserImpl.LoadWebUrl(AUrl: string);
begin
  FDcefBrowser.Load(AUrl);
end;

procedure TBrowserImpl.NotifyExValChange(AKey: string);
begin
  FDcefBrowser.ExecuteJavaScript(Format('OnExValChanged("%s")', [AKey]));
end;

procedure TBrowserImpl.ExecuteJavaScript(AJavaScript: string);
begin
  FDcefBrowser.ExecuteJavaScript(AJavaScript);
end;

procedure TBrowserImpl.DoBrowserBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  model.Clear;
end;

procedure TBrowserImpl.DoBrowserBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
  const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings; var noJavascriptAccess: Boolean; var Cancel: Boolean;
  var CancelDefaultEvent: Boolean);
begin

end;

procedure TBrowserImpl.DoBrowserBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
  const suggestedName: ustring; const callback: ICefBeforeDownloadCallback; var CancelDefaultEvent: Boolean);
begin
  callback.Cont('', True);
end;

procedure TBrowserImpl.DoBrowserDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if downloadItem.IsComplete then begin

  end;
end;

procedure TBrowserImpl.DoBrowserPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
  osEvent: TCefEventHandle; var isKeyboardShortcut: Boolean; var Cancel: Boolean; var CancelDefaultEvent: Boolean);
begin

end;

procedure TBrowserImpl.DoBrowserLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
begin

end;

procedure TBrowserImpl.DoBrowserLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin

end;

procedure TBrowserImpl.DoBrowserCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
  const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback; out Cancel: Boolean);
begin
  callback.Cont(True);
  Cancel := True;
end;

procedure TBrowserImpl.DoBrowserBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const callback: ICefRequestCallback; out Result: TCefReturnValue);
begin

end;

procedure TBrowserImpl.DoBrowserKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent; osEvent: TCefEventHandle;
  var Cancel: Boolean);
begin

end;

end.
