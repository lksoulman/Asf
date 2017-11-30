unit MasterUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Form UI
// Author：      lksoulman
// Date：        2017-10-16
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Variants,
  Graphics,
  Controls,
  Dialogs,
  Vcl.Forms,
  Vcl.ExtCtrls,
  GDIPOBJ,
  SecuMain,
  KeyFairy,
  RenderGDI,
  RenderUtil,
  AppContext,
  BaseFormUI,
  StatusBarUI,
  ShortKeyBarUI,
  SuperTabBarUI;

type

  // ClickComponent
  TOnClickComponent = procedure (AMainForm: TObject; AItem: TObject) of object;

  // MasterUI
  TMasterUI = class(TBaseFormUI)
    PnlSuperTab: TPanel;
    PnlChildPages: TPanel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    // KeyFairy
    FKeyFairy: IKeyFairy;
    // StatusBarUI
    FStatusBarUI: TStatusBarUI;
    // ShortKeyBarUI
    FShortKeyBarUI: TShortKeyBarUI;
    // SuperTabBarUI
    FSuperTabBarUI: TSuperTabBarUI;
  protected
    procedure AfterConstruction; override;
    // Update Skin Style
    procedure DoUpdateSkinStyle; override;
    // NC Short Key Menu
    procedure DrawNCShortKeyMenu(ADC: HDC; var ARect: TRect); override;
    // Update Hit Test
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1); override;
    // ShortKey Menu Hit Test
    function NCShortKeyMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean; override;

    // Create Wnd
    procedure CreateWnd; override;
    // NC Left Button Up
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // NC Left Button Down
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

uses
  Command;

{$R *.dfm}

{ TAppMainFormUI }

procedure TMasterUI.AfterConstruction;
begin
  inherited;
//  Self.PopupChildren;
end;

constructor TMasterUI.Create(AContext: IAppContext);
begin
  inherited;
  FIsMaster := True;
  Caption := '梵思';

  FShortKeyBarUI := TShortKeyBarUI.Create(AContext);
  FShortKeyBarUI.ParentHandle := Self.Handle;

  FSuperTabBarUI := TSuperTabBarUI.Create(AContext);
  FSuperTabBarUI.ParentHandle := Self.Handle;
  FSuperTabBarUI.Align := alClient;
  FSuperTabBarUI.Parent := PnlSuperTab;
  FSuperTabBarUI.Width := 60;

  FStatusBarUI := TStatusBarUI.Create(AContext);
  FStatusBarUI.ParentHandle := Self.Handle;
  FStatusBarUI.Align := alBottom;
  FStatusBarUI.Parent := PnlChildPages;
  FStatusBarUI.Height := 30;
end;

destructor TMasterUI.Destroy;
begin
  if FKeyFairy <> nil then begin
    FKeyFairy := nil;
  end;

  FSuperTabBarUI.Free;
  FStatusBarUI.Free;
  FShortKeyBarUI.Free;
  inherited;
end;

procedure TMasterUI.DoUpdateSkinStyle;
begin
  inherited;
end;

procedure TMasterUI.DrawNCShortKeyMenu(ADC: HDC; var ARect: TRect);
begin
  if FShortKeyBarUI = nil then Exit;
  ARect.Left := ARect.Left + 10;
  FShortKeyBarUI.Draw(FNCRenderDC, ARect);
end;

procedure TMasterUI.FormKeyPress(Sender: TObject; var Key: Char);
var
  LKey: string;
  LSecuMainItem: PSecuMainItem;
begin
//  inherited;
//  if FKeyFairy = nil then begin
//    FKeyFairy := FAppContext.FindInterface(ASF_COMMAND_ID_KEYFAIRY) as IKeyFairy;
//  end;
//
//  if FKeyFairy = nil then Exit;
//
//  LKey := Char(Key);
//  FKeyFairy.Display(Self.Handle, LKey, LSecuMainItem);
end;

procedure TMasterUI.UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1);
begin
  if FShortKeyBarUI <> nil then begin
    if (FHitTest <> AHitTest)
      or (FShortKeyBarUI.HitId <> AHitMenu) then begin
      FHitTest := AHitTest;
      FShortKeyBarUI.HitId := AHitMenu;
      if FShortKeyBarUI.DownHitId <> AHitMenu then begin
        FShortKeyBarUI.DownHitId := -1;
      end;
      SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
    end;
  end else begin
    inherited;
  end;
end;

function TMasterUI.NCShortKeyMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean;
var
  LMousePt: TPoint;
  LShortKeyItem: TShortKeyItem;
begin
  Result := False;
  if FShortKeyBarUI = nil then Exit;

  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  if FShortKeyBarUI.GetMenuItemByPt(ANCRect, LMousePt, LShortKeyItem) then begin
    Result := True;
    Msg.Result := HTMENU;
    UpdateHitTest(Msg.Result, LShortKeyItem.Id);
  end;
end;

procedure TMasterUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FDownHitTest := Message.HitTest;
  if FShortKeyBarUI <> nil then begin
    FShortKeyBarUI.DownHitId := FShortKeyBarUI.HitId;
  end;
  SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  // 点击激活
  if not Self.IsActivate then begin
    PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
  end;
  // 调用inherited会导致 WMNCLButtonUp 不响应,所以屏蔽一些，但窗体大小拖动还需要 Inherited
  if (Message.HitTest <> HTCAPTION)
    and (Message.HitTest <> HTCLOSE)
    and (Message.HitTest <> HTMENU)
    and (Message.HitTest <> HTMAXBUTTON)
    and (Message.HitTest <> HTMINBUTTON)
    and (WindowState <> wsMaximized) then begin
    inherited;
  end;
end;

procedure TMasterUI.CreateWnd;
begin
  inherited;
  // 设置在任务栏显示应用程序图标
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
end;

procedure TMasterUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
var
  LShortKeyItem: TShortKeyItem;
begin
  // 如果抬起时和按下时位置一致
  if Message.HitTest = FDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          if FShortKeyBarUI <> nil then begin
            if FShortKeyBarUI.HitId = FShortKeyBarUI.DownHitId then begin
              LShortKeyItem := FShortKeyBarUI.GetMenuItemById(FShortKeyBarUI.HitId);
              FShortKeyBarUI.ClickItem(LShortKeyItem);
            end;
            FShortKeyBarUI.DownHitId := -1;
            SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
          end;
        end;
      HTCLOSE:
        begin
          Self.Close;
          FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MASTERMGR, Format('FuncName=DelMaster@Handle=%d', [Self.Handle]));
        end;
      HTMAXBUTTON:
        begin
          FHitTest := HTNOWHERE;
          if Self.WindowState = wsNormal then begin
            Self.WindowState := wsMaximized
          end else begin
            self.WindowState := wsNormal;
          end;
        end;
      HTMINBUTTON:
        Self.WindowState := wsMinimized;
    end;
  end;
  FDownHitTest := HTNOWHERE;
  inherited;
end;

end.
