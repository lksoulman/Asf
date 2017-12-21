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
  CommCtrl,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Controls,
  GDIPOBJ,
  GDIPAPI,
  RenderDC,
  RenderUtil,
  AppContext,
  CommonLock,
  ComponentUI,
  CommonRefCounter, Vcl.ExtCtrls;

const

  WM_NCPAINT_STATUSBAR      = WM_USER + 101;
  WM_NCPAINT_CAPTIONBAR     = WM_USER + 102;
  WM_NCPAINT_SUPERTABBAR    = WM_USER + 103;

  NCMASK_STATUSBAR          = 1;
  NCMASK_CAPTIONBAR         = 2;
  NCMASK_SUPERTABBAR        = 3;

type

  // CustomMasterUI
  TCustomMasterUI = class(TForm)
  private
  protected
    // IsMaxBox
    FIsMaxBox: Boolean;
    // IsMinBox
    FIsMinBox: Boolean;
    // IsMaster
    FIsMaster: Boolean;
    // IsActivate
    FIsActivate: Boolean;
    // IsTracking
    FIsTracking: Boolean;
    // HitTest
    FHitTest: Integer;
    // MouseDownHit
    FDownHitTest: Integer;
    // MouseMoveId
    FMouseMoveId: Integer;
    // MouseDownId
    FMouseDownId: Integer;
    // MouseLeavePoint
    FMouseLeavePt: TPoint;
    // MinWidth
    FMinWidth: Integer;
    // MinHeight
    FMinHeight: Integer;
    // BorderWidth
    FBorderWidth: Integer;
    // CaptionHeight
    FCaptionHeight: Integer;
    // StatusBarHeight
    FStatusBarHeight: Integer;
    // SuperTabBarWidth
    FSuperTabBarWidth: Integer;
    // FormBorderStyle
    FBorderStyleEx: TFormBorderStyle;
    // MasterRect
    FMasterRect: TRect;
    // ClientRect
    FClientRect: TRect;
    // StatusBarRect
    FStatusBarRect: TRect;
    // CaptionBarRect
    FCaptionBarRect: TRect;
    // SuperTabBarRect
    FSuperTabBarRect: TRect;
    // AppContext
    FAppContext: IAppContext;
    // ComponentId
    FComponentId: TComponentId;
    // BorderColor
    FBorderColor: COLORREF;
    // CaptionBackColor
    FCaptionBackColor: COLORREF;
    // CaptionTextColor
    FCaptionTextColor: COLORREF;

    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; virtual;
    // DrawClient
    procedure DoPaintC(Sender: TObject); virtual;
    // DrawClient
    procedure DrawC(ADC: HDC; ARect: TRect); virtual;
    // DrawBackground
    procedure DrawBK(ADC: HDC; ARect: TRect; AColorRef: COLORREF); virtual;


    // CalcNCStatusBar
    procedure CalcNCStatusBar(ADC: HDC; ARect: TRect); virtual;
    // CalcNCCaptionBar
    procedure CalcNCCaptionBar(ADC: HDC; ARect: TRect); virtual;
    // CalcNCSuperTabBar
    procedure CalcNCSuperTabBar(ADC: HDC; ARect: TRect); virtual;
    // DrawNCStatusBar
    procedure DrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // DrawNCCaptionBar
    procedure DrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // DrawNCStatusBar
    procedure DrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // NCPaintStatusBar
    procedure DoNCPaintStatusBar(AId: Integer = -1);
    // NCPaintCaptionBar
    procedure DoNCPaintCaptionBar(AId: Integer = -1);
    // NCPaintSuperTabBar
    procedure DoNCPaintSuperTabBar(AId: Integer = -1);
    // WMNCPaintStatusBar
    procedure WMNCPaintStatusBar(var Message: TMessage); message WM_NCPAINT_STATUSBAR;
    // WMNCPaintCaptionBar
    procedure WMNCPaintCaptionBar(var Message: TMessage); message WM_NCPAINT_CAPTIONBAR;
    // WMNCPaintSuperTabBar
    procedure WMNCPaintSuperTabBar(var Message: TMessage); message WM_NCPAINT_SUPERTABBAR;

    // UpdateHitTest
    procedure DoUpdateHitTest(AHitTest: Integer); virtual;
    // UpdateBarHitTest
    procedure DoUpdateBarHitTest(AMouseMoveId, AMouseDownId: Integer); virtual;

    // 创建句柄
    procedure CreateWnd; override;
    // 设置标题消息响应
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    // 响应程序激活消息
    procedure OnActivateApp(var message: TWMACTIVATEAPP); message WM_ACTIVATEAPP;
    // 响应激活消息
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    // 获取最大值最小值信息
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    // 窗口大小变化
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    // 绘制非客户区域
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    // 非客户区点击测试
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    // 响应非客户区激活消息
    procedure WMNCActivate(var Message: TWMNCActivate); message WM_NCACTIVATE;
    // 计算非客户区域大小
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    // 响应鼠标离开非客户区消息
    procedure WMNCMouseLeave(var Message: TMessage); message WM_NCMOUSELEAVE;
    // 响应在非客户区移动鼠标消息
    procedure WMNCMouseMove(var Message: TWMMouseMove); message WM_NCMOUSEMOVE;
    // 非客户去左键抬起消息响应
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // 非客户去左键按下消息响应
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
    // 双击非客户区域
    procedure WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk); message WM_NCLBUTTONDBLCLK;
    // 修改窗体创建参数
    procedure CreateParams(var Params: TCreateParams); override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // BeforeCreate
    procedure BeforeCreate; virtual;
    // UpdateSkinStyle
    procedure UpdateSkinStyle;

    property IsActivate: Boolean read FIsActivate;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MinHeight: Integer read FMinHeight write FMinHeight;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property CaptionHeight: Integer read FCaptionHeight write FCaptionHeight;
    property ComponentId: TComponentId read FComponentId;
    property IsMaxBox: Boolean read FIsMaxBox write FIsMaxBox;
    property IsMinBox: Boolean read FIsMinBox write FIsMinBox;
    property MouseMoveId: Integer read FMouseMoveId write FMouseMoveId;
    property MouseDownId: Integer read FMouseDownId write FMouseDownId;
  end;

implementation

uses
  Math,
  Vcl.Imaging.pngimage,
  MultiMon;

{$R *.dfm}

{ TCustomMasterUI }

constructor TCustomMasterUI.Create(AContext: IAppContext);
begin
  FAppContext := AContext;
  BeforeCreate;
  inherited Create(nil);
  OnPaint := DoPaintC;
  FIsMaster := False;
  FIsActivate := False;
  FIsTracking := False;
  FHitTest := HTNOWHERE;
  FDownHitTest := HTNOWHERE;
  FIsTracking := False;
  DoUpdateSkinStyle;
end;

destructor TCustomMasterUI.Destroy;
begin
  FComponentId.Free;
  FAppContext := nil;
  inherited;
end;

procedure TCustomMasterUI.BeforeCreate;
begin
  FIsMaxBox := True;
  FIsMinBox := True;
  FBorderWidth := 1;
  FMouseMoveId := -1;
  FMouseDownId := -1;
  FCaptionHeight := 30;
  FStatusBarHeight := 30;
  FSuperTabBarWidth := 60;
  FDownHitTest := HTNOWHERE;
  FComponentId := TComponentId.Create;
end;

procedure TCustomMasterUI.UpdateSkinStyle;
begin
  DoUpdateSkinStyle;
  Invalidate;
end;

procedure TCustomMasterUI.DoUpdateSkinStyle;
begin
  if FIsMaster then begin
    if Color <> TColor(FAppContext.GetGdiMgr.GetColorRefMasterBack) then begin
      Color := FAppContext.GetGdiMgr.GetColorRefMasterBack;
    end;
    FBorderColor := FAppContext.GetGdiMgr.GetColorRefMasterBorder;
    FCaptionBackColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionBack;
    FCaptionTextColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionText;
  end;
end;

procedure TCustomMasterUI.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if FIsMinBox then begin
    Params.Style := Params.Style or WS_MINIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MINIMIZEBOX));
  end;

  if FIsMaxBox then begin
    Params.Style := Params.Style or WS_MAXIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MAXIMIZEBOX));
  end;
end;

procedure TCustomMasterUI.CreateWnd;
begin
  if FBorderStyleEx = bsNone then begin
    FBorderStyleEx := Self.BorderStyle;
  end;
  BorderStyle := bsNone;
  inherited;
end;

procedure TCustomMasterUI.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in Self.ComponentState) then begin
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomMasterUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
  if not message.Active then begin
    SendMessage(Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomMasterUI.WMActivate(var Message: TWMActivate);
begin
  if message.Active in [WA_ACTIVE, WA_CLICKACTIVE] then begin
    FIsActivate := True;
  end else begin
    FIsActivate := False;
  end;
  SendMessage(Handle, WM_NCPAINT, 0, 0);
  inherited;
end;

procedure TCustomMasterUI.WMNCActivate(var Message: TWMNCActivate);
begin
  message.Result := 1;          //去掉默认响应，关闭默认标题栏绘制
end;

procedure TCustomMasterUI.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  //如果原来没有边框，则不设置非客户区域
  if FBorderStyleEx = bsNone then begin
    inherited;
    Exit;
  end;

  Message.CalcSize_Params.rgrc[0].Left := Message.CalcSize_Params.rgrc[0].Left + FBorderWidth + FSuperTabBarWidth;
  Message.CalcSize_Params.rgrc[0].Right := Message.CalcSize_Params.rgrc[0].Right - FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Top := Message.CalcSize_Params.rgrc[0].Top + FBorderWidth + FCaptionHeight;
  Message.CalcSize_Params.rgrc[0].Bottom := Message.CalcSize_Params.rgrc[0].Bottom - FBorderWidth - FStatusBarHeight;

//  if Message.CalcValidRects then begin
//    Message.CalcSize_Params.rgrc[0].Left := Message.CalcSize_Params.rgrc[0].Left + FBorderWidth + FSuperTabBarWidth;
//    Message.CalcSize_Params.rgrc[0].Right := Message.CalcSize_Params.rgrc[0].Right - FBorderWidth;
//    Message.CalcSize_Params.rgrc[0].Top := Message.CalcSize_Params.rgrc[0].Top + FBorderWidth + FCaptionHeight;
//    Message.CalcSize_Params.rgrc[0].Bottom := Message.CalcSize_Params.rgrc[0].Bottom - FBorderWidth - FStatusBarHeight;
//  end;
end;

procedure TCustomMasterUI.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
//  LMonitor: TMonitor;
  LMonitor: HMONITOR;
  LMonitorInfo: MONITORINFO;
begin
  if FBorderStyleEx <> bsNone then begin
    Message.MinMaxInfo.ptMinTrackSize.X := FMinWidth;
    Message.MinMaxInfo.ptMinTrackSize.Y := FMinHeight;
//    // 调整窗口最大化时高度，避免窗口最大化时盖住主屏任务栏
    LMonitorInfo.cbSize := SizeOf(MONITORINFO);

    LMonitor := MonitorFromWindow(Handle, MONITOR_DEFAULTTONULL);
    if LMonitor <> 0 then begin
      GetMonitorInfo(LMonitor, @LMonitorInfo);
      // ptMaxSize的默认大小为主屏的分辨率，在不同分辨率的屏幕上是以默认大小为基准按比例设置的。
      // 如主屏分辨率X1*Y1,副屏分辨率X2*Y2，如果该值设为x*y，在副屏上计算的实际大小是x*X2/X1和y*Y2/Y1

      Message.MinMaxInfo.ptMaxSize.X :=
        Min(LMonitorInfo.rcWork.Right - LMonitorInfo.rcWork.Left, Message.MinMaxInfo.ptMaxSize.X);
      Message.MinMaxInfo.ptMaxSize.Y :=
        Min(LMonitorInfo.rcWork.Bottom - LMonitorInfo.rcWork.Top, Message.MinMaxInfo.ptMaxSize.Y);
    end;
//    LMonitor := Screen.MonitorFromWindow(Self.Handle);
//    if LMonitor <> nil then begin
//      Message.MinMaxInfo.ptMaxSize.X   :=   LMonitor.WorkareaRect.Width - 600;
//      Message.MinMaxInfo.ptMaxSize.Y   :=   LMonitor.WorkareaRect.Height - 300;
//      Message.Result   :=   0;
//    end;
  end;
//  Message.Result := 0;
  inherited;
end;

procedure TCustomMasterUI.WMNCHitTest(var Msg: TMessage);
begin
  inherited;
end;

procedure TCustomMasterUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FDownHitTest := Message.HitTest;
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

procedure TCustomMasterUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
begin
  inherited;
end;

procedure TCustomMasterUI.WMNCMouseMove(var Message: TWMMouseMove);
var
  LEvent: TTrackMouseEvent;
  LPosX, LPosY, LWidth: Integer;
begin
  if (Abs(FMouseLeavePt.X - Message.XPos) > 3)
    or (Abs(FMouseLeavePt.Y - Message.YPos) > 3) then begin
    if FDownHitTest = HTCAPTION then begin
      //如果窗体最大化状态，则拖动还原
      if (FBorderStyleEx = bsSizeable)
        and (Self.WindowState = wsMaximized) then begin
        LPosX := Self.Left;
        LPosY := Self.Top;
        LWidth := Self.Width;
        Self.WindowState := wsNormal;
        //收缩窗体后按比例计算窗体的位置
        LPosX := LPosX + (Message.XPos - LPosX) * Self.Width div LWidth;
        SetBounds(LPosX, LPosY, Width, Height);
      end;
      FMouseLeavePt.X := Message.XPos;
      FMouseLeavePt.Y := Message.YPos;
      SendMessage(Self.Handle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION, 0);
      Exit;
    end;
  end;

  inherited;
  //跟踪鼠标移开非客户区消息，如果无此操作，则收不到 WM_NCMOUSELEAVE 消息
  if not FIsTracking then begin
    FIsTracking := True;
    LEvent.cbSize := SizeOf(TTrackMouseEvent);
    //Flag 需指定 TME_NONCLIENT，否则只会发送离开客户区域消息
    LEvent.dwFlags := TME_LEAVE or TME_NONCLIENT;
    LEvent.hwndTrack := Handle;
    LEvent.dwHoverTime := 20;
    //发送离开非客户区消息
    TrackMouseEvent(LEvent);
  end;
end;

procedure TCustomMasterUI.WMNCMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsTracking := False;
  DoUpdateHitTest(HHT_NOWHERE);
  DoUpdateBarHitTest(-1, -1);
end;

procedure TCustomMasterUI.WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk);
begin
  if (FBorderStyleEx = bsSizeable)
    and (Message.HitTest = HTCAPTION) then begin
    if Self.WindowState = wsMaximized then begin
      Self.WindowState := wsNormal
    end else begin
      Self.WindowState := wsMaximized;
    end;
  end;
  DoUpdateHitTest(HHT_NOWHERE);
  DoUpdateBarHitTest(-1, -1);
end;

procedure TCustomMasterUI.WMSize(var Message: TWMSize);
var
  LDC: HDC;
  LIsGetRect: Boolean;
  LBorderWidth: Integer;
  LRect, LNoBorderRect, LTempRect: TRect;
begin
  inherited;
  LIsGetRect := GetWindowRect(Handle, LRect);
  if LIsGetRect then begin
    LDC := GetWindowDC(Handle);
    try
      OffsetRect(LRect, -LRect.Left, -LRect.Top);

      LBorderWidth := FBorderWidth;

      FMasterRect := LRect;

      LNoBorderRect := LRect;
      LNoBorderRect.Inflate(-LBorderWidth, -LBorderWidth);

      if FCaptionHeight > 0 then begin
        LTempRect := LNoBorderRect;
        LTempRect.Bottom := LNoBorderRect.Top + FCaptionHeight;
        FCaptionBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        CalcNCCaptionBar(LDC, LTempRect);
      end;

      if FStatusBarHeight > 0 then begin
        LTempRect := LNoBorderRect;
        LTempRect.Top := LNoBorderRect.Bottom - FStatusBarHeight;
        if FSuperTabBarWidth > 0 then begin
          LTempRect.Left := LNoBorderRect.Left + FSuperTabBarWidth;
        end;
        FStatusBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        CalcNCStatusBar(LDC, LTempRect);
      end;

      if FSuperTabBarWidth > 0 then begin
        LTempRect := LNoBorderRect;
        LTempRect.Right := LNoBorderRect.Left + FSuperTabBarWidth;
        if FCaptionHeight > 0 then begin
          LTempRect.Top := LNoBorderRect.Top + FCaptionHeight;
        end;
        FSuperTabBarRect := LTempRect;
        OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
        CalcNCSuperTabBar(LDC, LTempRect);
      end;

      FClientRect := LNoBorderRect;
      if FCaptionHeight > 0 then begin
        FClientRect.Top := LNoBorderRect.Top + FCaptionHeight;
      end;
      if FSuperTabBarWidth > 0 then begin
        FClientRect.Left := LNoBorderRect.Left + FSuperTabBarWidth;
      end;
      if FStatusBarHeight > 0 then begin
        FClientRect.Bottom := LNoBorderRect.Bottom - FStatusBarHeight;
      end;
    finally
      ReleaseDC(Handle, LDC);
    end;
    SendMessage(Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomMasterUI.WMNCPaint(var Message: TMessage);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Handle);
  try
    DrawNCStatusBar(LDC, FStatusBarRect);
    DrawNCCaptionBar(LDC, FCaptionBarRect);
    DrawNCSuperTabBar(LDC, FSuperTabBarRect);
    DrawBorder(LDC, FBorderColor, FMasterRect, 15);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomMasterUI.DoPaintC(Sender: TObject);
var
  LDC: HDC;
begin
//  LDC := GetWindowDC(Handle);
//  try
//    DrawC(FRenderDC.MemDC, FClientRect);
//    FRenderDC.BitBltX(LDC);
//  finally
//    ReleaseDC(Handle, LDC);
//  end;
end;

procedure TCustomMasterUI.DrawC(ADC: HDC; ARect: TRect);
begin
  DrawBK(ADC, ARect, Color);
end;

procedure TCustomMasterUI.DrawBK(ADC: HDC; ARect: TRect; AColorRef: COLORREF);
begin
  FillSolidRect(ADC, @ARect, AColorRef);
end;

procedure TCustomMasterUI.DrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer);
begin

end;

procedure TCustomMasterUI.DrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer);
begin

end;

procedure TCustomMasterUI.DrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer);
begin

end;

procedure TCustomMasterUI.CalcNCStatusBar(ADC: HDC; ARect: TRect);
begin

end;

procedure TCustomMasterUI.CalcNCCaptionBar(ADC: HDC; ARect: TRect);
begin

end;

procedure TCustomMasterUI.CalcNCSuperTabBar(ADC: HDC; ARect: TRect);
begin

end;

procedure TCustomMasterUI.DoNCPaintStatusBar(AId: Integer);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Handle);
  try
    DrawNCStatusBar(LDC, FStatusBarRect, AId);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomMasterUI.DoNCPaintCaptionBar(AId: Integer);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Handle);
  try
    DrawNCCaptionBar(LDC, FCaptionBarRect, AId);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomMasterUI.DoNCPaintSuperTabBar(AId: Integer);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Handle);
  try
    DrawNCSuperTabBar(LDC, FSuperTabBarRect, AId);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomMasterUI.WMNCPaintStatusBar(var Message: TMessage);
begin
  DoNCPaintStatusBar;
end;

procedure TCustomMasterUI.WMNCPaintCaptionBar(var Message: TMessage);
begin
  DoNCPaintCaptionBar;
end;

procedure TCustomMasterUI.WMNCPaintSuperTabBar(var Message: TMessage);
begin
  DoNCPaintSuperTabBar;
end;

procedure TCustomMasterUI.DoUpdateHitTest(AHitTest: Integer);
begin
  if (FHitTest <> AHitTest) then begin
    FHitTest := AHitTest;
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomMasterUI.DoUpdateBarHitTest(AMouseMoveId, AMouseDownId: Integer);
begin

end;

end.

