unit WebPopBrowserImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： WebPopBrowser Implementation
// Author：      lksoulman
// Date：        2017-12-26
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  RzTabs,
  Browser,
  BaseObject,
  AppContext,
  CustomBaseUI,
  WebPopBrowser,
  Generics.Collections;

type

  // WebBrowserSheet
  TWebBrowserSheet = class(TRzTabSheet)
  private
    // Url
    FUrl: string;
    // TitlePrefix
    FTitlePrefix: string;
    // Browser
    FBrowser: IBrowser;
    // AppContext
    FAppContext: IAppContext;
  protected
    // WebBrowserChangeSize
    procedure DoWebBrowserChangeSize(AForm: TForm);
    // WebBrowserSheetChangeSize
    procedure DoWebBrowserSheetChangeSize(Sender: TObject);
  public
    // Constructor
    constructor Create(AOwner: TComponent; AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // LoadWebUrl
    procedure LoadWebUrl;

    property Url: string read FUrl write FUrl;
    property TitlePrefix: string read FTitlePrefix write FTitlePrefix;
  end;

  // WebPopBrowserUI
  TWebPopBrowserUI = class(TCustomBaseUI)
  private
    // MaxPageCount
    FMaxPageCount: Integer;
    // BrowserPageControl
    FBrowserPageControl: TRzPageControl;
    // BrowserSheetDic
    FBrowserSheetDic: TDictionary<string, TWebBrowserSheet>;
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
    // ChangeBrowserPage
    procedure DoChangeBrowserPage(Sender: TObject);
    // CloseBrowserPage
    procedure DoCloseBrowserPage(Sender: TObject; var AllowClose: Boolean);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // AddWebUrl
    procedure AddWebUrl(ATitlePrefix, AUrl: string);
  end;

  // WebPopBrowser Implementation
  TWebPopBrowserImpl = class(TBaseSplitStrInterfacedObject, IWebPopBrowser)
  private
    // WebPopBrowserUI
    FWebPopBrowserUI: TWebPopBrowserUI;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IWebPopBrowser }

    // Hide
    procedure Hide;
    // Show
    procedure Show;
    // LoadWebUrl
    procedure LoadWebUrl(ATitlePrefix, AUrl: string);
  end;

implementation

{ TWebBrowserSheet }

constructor TWebBrowserSheet.Create(AOwner: TComponent; AContext: IAppContext);
begin
  inherited Create(AOwner);
  FAppContext := AContext;
  OnResize := DoWebBrowserSheetChangeSize;
end;

destructor TWebBrowserSheet.Destroy;
begin
  FUrl := '';
  FBrowser := nil;
  FAppContext := nil;
  inherited;
end;

procedure TWebBrowserSheet.LoadWebUrl;
var
  LForm: TForm;
begin
  if FBrowser = nil then begin
    FBrowser := FAppContext.CreateBrowser;
    if FBrowser <> nil then begin
      LForm := FBrowser.GetBrowserUI;
      LForm.ParentWindow := Self.Handle;
      LForm.Show;
      DoWebBrowserChangeSize(LForm);
      FBrowser.LoadWebUrl('http://www.baidu.com');  //https://weibo.com/?c=spr_sinamkt_buy_hyww_weibo_t137 // https://www.baidu.com
    end;
  end;
end;

procedure TWebBrowserSheet.DoWebBrowserChangeSize(AForm: TForm);
var
  LWidth, LHeight: Integer;
begin
  LWidth := Self.Width;
  LHeight := Self.Height;
//  if (LWidth <> AForm.Width)
//    and (LHeight <> AForm.Height) then begin
  SetWindowPos(AForm.Handle, 0, 0, 0, LWidth, LHeight, SWP_NOACTIVATE);
//  end;
end;

procedure TWebBrowserSheet.DoWebBrowserSheetChangeSize(Sender: TObject);
begin
  if FBrowser <> nil then begin
    DoWebBrowserChangeSize(FBrowser.GetBrowserUI);
  end;
end;

{ TWebPopBrowserUI }

constructor TWebPopBrowserUI.Create(AContext: IAppContext);
begin
  inherited;
  Self.Width := 800;
  Self.Height := 500;

  FMaxPageCount := 6;
  FBrowserPageControl := TRzPageControl.Create(nil);
  FBrowserPageControl.Parent := Self;
  FBrowserPageControl.Align := alClient;
  FBrowserPageControl.OnChange := DoChangeBrowserPage;
  FBrowserPageControl.OnClose := DoCloseBrowserPage;
  FBrowserPageControl.Height := 35;
  FBrowserPageControl.TabWidth := 130;
  FBrowserPageControl.Margin := 4;
  FBrowserPageControl.TabOverlap := -4;
  FBrowserPageControl.TabStyle := tsSquareCorners;
  FBrowserPageControl.TabHints := True; // 显示提示
  FBrowserPageControl.ShowHint := True; // 显示提示
  FBrowserPageControl.BoldCurrentTab := True; // 加粗显示激活标签
  FBrowserPageControl.UseGradients := False; // 不使用渐变色
  FBrowserPageControl.ShowFullFrame := False; // 不显示Frame边框
  FBrowserPageControl.ShowFocusRect := False; // 不显示焦点矩形边框
  FBrowserPageControl.ShowCloseButtonOnActiveTab := True; // 显示激活页签关闭按钮

  FBrowserPageControl.TextColors.Selected := RGB(255, 255, 255); // 选择页签文字颜色
  FBrowserPageControl.TextColors.UnSelected := RGB(205, 205, 205); // 未选中页签文字颜色
  FBrowserPageControl.BackgroundColor := RGB(68, 68, 68); // page背景色
  FBrowserPageControl.FlatColor := RGB(33, 33, 33);  // page线颜色
  FBrowserPageControl.Color := RGB(68, 68, 68);      // 激活tab颜色
  FBrowserPageControl.TabColors.UnSelected := RGB(68, 68, 68); // 为选择的tab颜色

  FBrowserSheetDic := TDictionary<string, TWebBrowserSheet>.Create;
end;

destructor TWebPopBrowserUI.Destroy;
begin
  FBrowserSheetDic.Free;
  FBrowserPageControl.Free;
  inherited;
end;

procedure TWebPopBrowserUI.DoBeforeCreate;
begin
  inherited;
  FIsAppWind := True;
  FIsMaximize := False;
  FIsMinimize := False;
end;

procedure TWebPopBrowserUI.DoChangeBrowserPage(Sender: TObject);
var
  LWebBrowserSheet: TWebBrowserSheet;
begin
  LWebBrowserSheet := TWebBrowserSheet(FBrowserPageControl.ActivePage);
  if LWebBrowserSheet <> nil then begin
    FNCCaptionBarUI.Caption := LWebBrowserSheet.FTitlePrefix;
    LWebBrowserSheet.LoadWebUrl;
  end;
end;

procedure TWebPopBrowserUI.DoCloseBrowserPage(Sender: TObject; var AllowClose: Boolean);
begin
  if FBrowserPageControl.PageCount = 1 then begin
    Self.Close;
  end;
  AllowClose := True;
end;

procedure TWebPopBrowserUI.AddWebUrl(ATitlePrefix, AUrl: string);
var
  LUrl: string;
  LWebBrowserSheet: TWebBrowserSheet;
begin
  LUrl := AUrl;
  if FBrowserSheetDic.TryGetValue(LUrl, LWebBrowserSheet) then begin
    FBrowserPageControl.ActivePageIndex := LWebBrowserSheet.PageIndex;
  end else begin
    LWebBrowserSheet := TWebBrowserSheet.Create(FBrowserPageControl, FAppContext);
    LWebBrowserSheet.Url := AUrl;
    LWebBrowserSheet.TitlePrefix := ATitlePrefix;
    LWebBrowserSheet.PageControl := FBrowserPageControl;
    LWebBrowserSheet.Caption := AUrl;
    FBrowserPageControl.ActivePageIndex := LWebBrowserSheet.PageIndex;
  end;
end;

{ TWebPopBrowserImpl }

constructor TWebPopBrowserImpl.Create(AContext: IAppContext);
begin
  inherited;
  FWebPopBrowserUI := TWebPopBrowserUI.Create(FAppContext);
end;

destructor TWebPopBrowserImpl.Destroy;
begin
  FWebPopBrowserUI.Free;
  inherited;
end;

procedure TWebPopBrowserImpl.Hide;
begin

end;

procedure TWebPopBrowserImpl.Show;
var
  LRect: TRect;
  LMonitor: TMonitor;
begin
  if FWebPopBrowserUI.WindowState = wsMinimized then begin
    FWebPopBrowserUI.WindowState := wsNormal;
  end;
  LMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
  if LMonitor = nil then begin
    LMonitor := FWebPopBrowserUI.Monitor;
  end;
  LRect := LMonitor.WorkareaRect;
  FWebPopBrowserUI.Top := (LRect.Top + LRect.Bottom - FWebPopBrowserUI.Height) div 2;
  FWebPopBrowserUI.Left := (LRect.Left + LRect.Right - FWebPopBrowserUI.Width) div 2;
  if not FWebPopBrowserUI.Showing then begin
    FWebPopBrowserUI.Show;
  end else begin
    FWebPopBrowserUI.BringToFront;
  end;
end;

procedure TWebPopBrowserImpl.LoadWebUrl(ATitlePrefix, AUrl: string);
begin
  FWebPopBrowserUI.AddWebUrl(ATitlePrefix, AUrl);
end;

end.
