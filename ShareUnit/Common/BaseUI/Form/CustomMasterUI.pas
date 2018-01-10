unit CustomMasterUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Base Form UI
// Author：      lksoulman
// Date：        2017-12-13
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Variants,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Controls,
  RenderDC,
  RenderUtil,
  AppContext,
  ComponentUI,
  CustomBaseUI;

const

  // 绘制非客户区 StatusBar
  NC_DRAW_STATUSBAR    = 2;
  // 绘制非客户区 SuperTabBar
  NC_DRAW_SUPERTABBAR  = 3;

type

  // NCStatusBarUI
  TNCStatusBarUI = class(TNCCustomBaseUI)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
  end;

  // NCStatusBarUIClass
  TNCStatusBarUIClass = class of TNCStatusBarUI;

  // NCSuperTabBarUI
  TNCSuperTabBarUI = class(TNCCustomBaseUI)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
  end;

  // NCSuperTabBarUIClass
  TNCSuperTabBarUIClass = class of TNCSuperTabBarUI;

  // CustomMasterUI
  TCustomMasterUI = class(TCustomBaseUI)
  private
  protected
    // StatusBarRect
    FStatusBarRect: TRect;
    // SuperTabBarRect
    FSuperTabBarRect: TRect;
    // StatusBarHeight
    FStatusBarHeight: Integer;
    // SuperTabBarWidth
    FSuperTabBarWidth: Integer;

    // NCSuperTabBarUI
    FNCStatusBarUI: TNCStatusBarUI;
    // NCStatusBarUIClass
    FNCStatusBarUIClass: TNCStatusBarUIClass;
    // NCSuperTabBarUI
    FNCSuperTabBarUI: TNCSuperTabBarUI;
    // NCSuperTabBarUIClass
    FNCSuperTabBarUIClass: TNCSuperTabBarUIClass;

    // 计算非客户区域大小
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;

    // BeforeCreate
    procedure DoBeforeCreate; override;
    // CreateNCBarUI
    procedure DoCreateNCBarUI; override;
    // DestroyNCBarUI
    procedure DoDestroyNCBarUI; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;

    // CalcNC
    procedure DoCalcNC; override;
    // CalcNCStatusBar
    procedure DoCalcNCStatusBar(ADC: HDC; ARect: TRect);
    // CalcNCSuperTabBar
    procedure DoCalcNCSuperTabBar(ADC: HDC; ARect: TRect);

    // DrawNC
    procedure DoDrawNC(ADC: HDC); override;
    // DrawNCStatusBar
    procedure DoDrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer = -1);
    // DrawNCSuperTabBar
    procedure DoDrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer = -1);

    // NCHitTest
    function DoNCHitTest(var Msg: TMessage): Boolean; override;
    // NCLButtonUp
    procedure DoNCLButtonUp(var Message: TWMNCLButtonUp); override;
    // NCLButtonDown
    procedure DoNCLButtonDown(var Message: TWMNCLButtonDown); override;
    // WmPaintNCBarsUI
    procedure DoWmPaintNCBarsUI(var Message: TMessage); message WM_NCPAINT_BARS;

    // ToNCStatusBarPt
    function DoToNCStatusBarPt(APt: TPoint): TPoint;
    // ToNCStatusBarPt
    function DoToNCSuperTabBarPt(APt: TPoint): TPoint;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TNCStatusBarUI }

constructor TNCStatusBarUI.Create(AContext: IAppContext; AParentUI: TCustomBaseUI);
begin
  inherited;
  FWParam := NC_DRAW_STATUSBAR;
  FPaintMsg := WM_NCPAINT_BARS;
end;

destructor TNCStatusBarUI.Destroy;
begin

  inherited;
end;

{ TNCSuperTabBarUI }

constructor TNCSuperTabBarUI.Create(AContext: IAppContext; AParentUI: TCustomBaseUI);
begin
  inherited;
  FWParam := NC_DRAW_SUPERTABBAR;
  FPaintMsg := WM_NCPAINT_BARS;
end;

destructor TNCSuperTabBarUI.Destroy;
begin

  inherited;
end;

{ TCustomMasterUI }

constructor TCustomMasterUI.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TCustomMasterUI.Destroy;
begin

  inherited;
end;

procedure TCustomMasterUI.DoBeforeCreate;
begin
  inherited;
  FIsAppWind := True;
  FMinTrackWidth := 0;
  FMinTrackHeight := 0;
  FStatusBarHeight := 30;
  FSuperTabBarWidth := 60;
  FNCStatusBarUIClass := TNCStatusBarUI;
  FNCSuperTabBarUIClass := TNCSuperTabBarUI;
end;

procedure TCustomMasterUI.DoCreateNCBarUI;
begin
  inherited;
  if FStatusBarHeight > 0 then begin
    FNCStatusBarUI := FNCStatusBarUIClass.Create(FAppContext, Self);
  end;

  if FSuperTabBarWidth > 0 then begin
    FNCSuperTabBarUI := FNCSuperTabBarUIClass.Create(FAppContext, Self);
  end;
end;

procedure TCustomMasterUI.DoDestroyNCBarUI;
begin
  if FNCSuperTabBarUI <> nil then begin
    FNCSuperTabBarUI.Free;
  end;

  if FNCStatusBarUI <> nil then begin
    FNCStatusBarUI.Free;
  end;
  inherited;
end;

procedure TCustomMasterUI.DoUpdateSkinStyle;
begin
  inherited;
  FBorderPen := FAppContext.GetGdiMgr.GetBrushObjMasterBorder;
  FCaptionBackColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionBack;
  FCaptionTextColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionText;
end;

procedure TCustomMasterUI.DoCalcNC;
var
  LDC: HDC;
  LIsWindowRect: Boolean;
  LRect, LNoBorderRect, LTempRect: TRect;
begin
  LIsWindowRect := GetWindowRect(Handle, LRect);
  if LIsWindowRect then begin
    LDC := GetWindowDC(Handle);
    try
      OffsetRect(LRect, -LRect.Left, -LRect.Top);

      LNoBorderRect := LRect;
      if FBorderWidth > 0 then begin
        LNoBorderRect.Inflate(-FBorderWidth, -FBorderWidth);
      end;

      FFormBorderRect := LRect;

      if FCaptionHeight > 0 then begin
        LTempRect := LNoBorderRect;
        LTempRect.Bottom := LNoBorderRect.Top + FCaptionHeight;
        FCaptionBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        DoCalcNCCaptionBar(LDC, LTempRect);
      end;

      if FStatusBarHeight > 0 then begin
        LTempRect := LNoBorderRect;
        LTempRect.Top := LNoBorderRect.Bottom - FStatusBarHeight;
        if FSuperTabBarWidth > 0 then begin
          LTempRect.Left := LNoBorderRect.Left + FSuperTabBarWidth;
        end;
        FStatusBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        DoCalcNCStatusBar(LDC, LTempRect);
      end;

      if FSuperTabBarWidth > 0 then begin
        LTempRect := LNoBorderRect;
        if FCaptionHeight > 0 then begin
          LTempRect.Top := LNoBorderRect.Top + FCaptionHeight;
        end;
        LTempRect.Right := LNoBorderRect.Left + FSuperTabBarWidth;
        FSuperTabBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        DoCalcNCSuperTabBar(LDC, LTempRect);
      end;

    finally
      ReleaseDC(Handle, LDC);
    end;
    SendMessage(Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomMasterUI.DoCalcNCStatusBar(ADC: HDC; ARect: TRect);
begin
  if FNCStatusBarUI = nil then Exit;

  FNCStatusBarUI.Calc(ADC, ARect);
end;

procedure TCustomMasterUI.DoCalcNCSuperTabBar(ADC: HDC; ARect: TRect);
begin
  if FNCSuperTabBarUI = nil then Exit;

  FNCSuperTabBarUI.Calc(ADC, ARect);
end;

procedure TCustomMasterUI.DoDrawNC(ADC: HDC);
var
  LRect: TRect;
begin
  DoDrawNCStatusBar(ADC, FStatusBarRect);
  DoDrawNCCaptionBar(ADC, FCaptionBarRect);
  DoDrawNCSuperTabBar(ADC, FSuperTabBarRect);
  if FBorderWidth > 0 then begin
    LRect := FFormBorderRect;
    Dec(LRect.Right);
    Dec(LRect.Bottom);
    DrawBorder(ADC, FBorderPen, LRect, 15);
  end;
end;

procedure TCustomMasterUI.DoDrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer);
begin
  if FNCStatusBarUI = nil then Exit;

  FNCStatusBarUI.Draw(ADC, ARect, AId);
end;

procedure TCustomMasterUI.DoDrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer);
begin
  if FNCSuperTabBarUI = nil then Exit;

  FNCSuperTabBarUI.Draw(ADC, ARect, AId);
end;

function TCustomMasterUI.DoNCHitTest(var Msg: TMessage): Boolean;
var
  LMousePt: TPoint;
  LMouseMoveId: Integer;
  LComponent: TComponentUI;
  LRect, LBorderRect: TRect;
begin
  Result := False;

  // 没有标题没有边框
  if (FCaptionHeight = 0)
    and (FBorderWidth = 0) then begin
    Msg.Result := HTTRANSPARENT;
    Exit;
  end;

  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  GetWindowRect(Handle, LRect);
  // 如果窗体处在一般状态且可拖动大小，则判断鼠标是否点击在边框
  if (WindowState = wsNormal)
    and (FBorderStyleEx = bsSizeable) then begin

    LBorderRect := LRect;
    InflateRect(LBorderRect, -4, -4);

    // 如果鼠标在边框区域
    if not PtInRect(LBorderRect, LMousePt) then begin
      if LMousePt.Y <= LBorderRect.Top then begin
        if LMousePt.X < LRect.Left + 8 then begin
          Msg.Result := HTTOPLEFT
        end else if LMousePt.X > LRect.Right - 8 then begin
          Msg.Result := HTTOPRIGHT
        end else begin
          Msg.Result := HTTOP;
        end;
      end else if LMousePt.Y >= LBorderRect.Bottom then begin
        if LMousePt.X < LRect.Left + 8 then begin
          Msg.Result := HTBOTTOMLEFT
        end else if LMousePt.X > LRect.Right - 8 then begin
          Msg.Result := HTBOTTOMRIGHT
        end else begin
          Msg.Result := HTBOTTOM;
        end;
      end else if LMousePt.X <= LBorderRect.Left then begin
        if LMousePt.Y < LRect.Top + 8 then begin
          Msg.Result := HTTOPLEFT
        end else if LMousePt.Y > LRect.Bottom - 8 then begin
          Msg.Result := HTBOTTOMLEFT
        end else begin
          Msg.Result := HTLEFT;
        end;
      end else begin
        if LMousePt.Y < LRect.Top + 8 then begin
          Msg.Result := HTTOPRIGHT
        end else if LMousePt.Y > LRect.Bottom - 8 then begin
          Msg.Result := HTBOTTOMRIGHT
        end else begin
          Msg.Result := HTRIGHT;
        end;
      end;

      Result := True;
      DoUpdateHitTest(Msg.Result);
      Exit;
    end;
  end;

  LMousePt.X := LMousePt.X - LRect.Left;
  LMousePt.Y := LMousePt.Y - LRect.Top;
  LMouseMoveId := -1;
  if (FNCCaptionBarUI <> nil)
    and PtInRect(FNCCaptionBarUI.ComponentsRect, DoToNCCaptionBarPt(LMousePt)) then begin

    if FNCCaptionBarUI.FindComponent(DoToNCCaptionBarPt(LMousePt), LComponent) then begin
      if LComponent is TCaptionBarClose then begin
        Msg.Result := HTCLOSE;
      end else if LComponent is TCaptionBarMaximize then begin
        Msg.Result := HTMAXBUTTON;
      end else if LComponent is TCaptionBarMinimize then begin
        Msg.Result := HTMINBUTTON;
      end else begin
        Msg.Result := HTMENU;
      end;

      LMouseMoveId := LComponent.Id;
    end else begin
      Msg.Result := HTCAPTION;
    end;

    Result := True;

    if (FNCMouseMoveId <> LMouseMoveId)
      or (FNCMouseDownId <> LMouseMoveId) then begin
      FNCMouseMoveId := LMouseMoveId;
      FNCMouseDownId := -1;
      FNCCaptionBarUI.Invalidate;
    end;
  end else if (FNCSuperTabBarUI <> nil)
    and PtInRect(FNCSuperTabBarUI.ComponentsRect, DoToNCSuperTabBarPt(LMousePt)) then begin

    if FNCSuperTabBarUI.FindComponent(DoToNCSuperTabBarPt(LMousePt), LComponent) then begin

      Result := True;
      LMouseMoveId := LComponent.Id;
      Msg.Result := HTMENU;
    end;
    if (FNCMouseMoveId <> LMouseMoveId)
      or (FNCMouseDownId <> LMouseMoveId) then begin
      FNCMouseMoveId := LMouseMoveId;
      FNCMouseDownId := -1;
      FNCSuperTabBarUI.Invalidate;
    end;
  end else if (FNCStatusBarUI <> nil)
    and PtInRect(FNCStatusBarUI.ComponentsRect, DoToNCStatusBarPt(LMousePt)) then begin

    if FNCStatusBarUI.FindComponent(DoToNCStatusBarPt(LMousePt), LComponent) then begin
      Result := True;
      LMouseMoveId := LComponent.Id;
      Msg.Result := HTMENU;
    end;
    if (FNCMouseMoveId <> LMouseMoveId)
      or (FNCMouseDownId <> LMouseMoveId) then begin
      FNCMouseMoveId := LMouseMoveId;
      FNCMouseDownId := -1;
      FNCStatusBarUI.Invalidate;
    end;
  end;
end;

procedure TCustomMasterUI.DoNCLButtonUp(var Message: TWMNCLButtonUp);
var
  LComponent: TComponentUI;
begin
  // 如果抬起时和按下时位置一致
  if Message.HitTest = FMouseDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          if (FNCCaptionBarUI <> nil)
            and FNCCaptionBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
            FNCMouseDownId := -1;
            FNCCaptionBarUI.Invalidate(FNCMouseMoveId);
            FNCCaptionBarUI.LButtonClickComponent(LComponent);
          end else if (FNCSuperTabBarUI <> nil)
            and FNCSuperTabBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
            FNCMouseDownId := -1;
            FNCSuperTabBarUI.Invalidate(FNCMouseMoveId);
            FNCSuperTabBarUI.LButtonClickComponent(LComponent);
          end else if (FNCStatusBarUI <> nil)
            and FNCStatusBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
            FNCMouseDownId := -1;
            FNCStatusBarUI.Invalidate(FNCMouseMoveId);
            FNCStatusBarUI.LButtonClickComponent(LComponent);
          end;
        end;
      HTCLOSE:
        begin
          Self.Close;
          DoCloseEx;
        end;
      HTMAXBUTTON:
        begin
          FMouseMoveHitTest := HTNOWHERE;
          if Self.WindowState = wsNormal then begin
            Self.WindowState := wsMaximized
          end else begin
            self.WindowState := wsNormal;
          end;
        end;
      HTMINBUTTON:
        begin
          FMouseMoveHitTest := HTNOWHERE;
          Self.WindowState := wsMinimized;
        end;
    end;
  end;
end;

procedure TCustomMasterUI.DoNCLButtonDown(var Message: TWMNCLButtonDown);
var
  LPt: TPoint;
  LIsActivate: Boolean;
  LComponent: TComponentUI;
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FMouseDownHitTest := Message.HitTest;
  FNCMouseDownId := FNCMouseMoveId;

  if (FNCCaptionBarUI <> nil)
    and FNCCaptionBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
    FNCCaptionBarUI.Invalidate(FNCMouseMoveId);
    LIsActivate := True;
  end else if (FNCSuperTabBarUI <> nil)
    and FNCSuperTabBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
    LIsActivate := False;
    FNCSuperTabBarUI.Invalidate(FNCMouseMoveId);
  end else if (FNCStatusBarUI <> nil)
    and FNCStatusBarUI.FindComponent(FNCMouseMoveId, LComponent) then begin
    LIsActivate := False;
    FNCStatusBarUI.Invalidate(FNCMouseMoveId);
  end else begin
    LIsActivate := False;
  end;

  if LIsActivate
    or (FMouseDownHitTest = HTCAPTION) then begin
    // 点击激活
    if not FIsActivate then begin
      PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
    end;
  end;
end;

procedure TCustomMasterUI.DoWmPaintNCBarsUI(var Message: TMessage);
var
  LDC: HDC;
  LRect: TRect;
begin
  LDC := GetWindowDC(Self.Handle);
  try
    case Message.WParam of
      NC_DRAW_CAPTIONBAR:
        begin
          DoDrawNCCaptionBar(LDC, FCaptionBarRect, Message.LParam);
        end;
      NC_DRAW_STATUSBAR:
        begin
          DoDrawNCStatusBar(LDC, FStatusBarRect, Message.LParam);
        end;
      NC_DRAW_SUPERTABBAR:
        begin
          DoDrawNCSuperTabBar(LDC, FSuperTabBarRect, Message.LParam);
        end;
    end;
    LRect := FFormBorderRect;
    Dec(LRect.Right);
    Dec(LRect.Bottom);
    DrawBorder(LDC, FBorderPen, LRect, 15);
  finally
    ReleaseDC(Self.Handle, LDC);
  end;
end;

function TCustomMasterUI.DoToNCStatusBarPt(APt: TPoint): TPoint;
begin
  Result.X := APt.X - FStatusBarRect.Left;
  Result.Y := APt.Y - FStatusBarRect.Top;
end;

function TCustomMasterUI.DoToNCSuperTabBarPt(APt: TPoint): TPoint;
begin
  Result.X := APt.X - FSuperTabBarRect.Left;
  Result.Y := APt.Y - FSuperTabBarRect.Top;
end;

procedure TCustomMasterUI.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  //如果原来没有边框，则不设置非客户区域
  if (FCaptionHeight = 0)
    and (FBorderWidth = 0)
    and (FSuperTabBarWidth = 0)
    and (FStatusBarHeight = 0) then begin
    inherited;
    Exit;
  end;

  Message.CalcSize_Params.rgrc[0].Left := Message.CalcSize_Params.rgrc[0].Left + FBorderWidth + FSuperTabBarWidth;
  Message.CalcSize_Params.rgrc[0].Right := Message.CalcSize_Params.rgrc[0].Right - FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Top := Message.CalcSize_Params.rgrc[0].Top + FBorderWidth + FCaptionHeight;
  Message.CalcSize_Params.rgrc[0].Bottom := Message.CalcSize_Params.rgrc[0].Bottom - FBorderWidth - FStatusBarHeight;
end;

end.

