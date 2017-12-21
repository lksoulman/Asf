unit MasterUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： MasterUI
// Author：      lksoulman
// Date：        2017-12-12
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
  Vcl.Forms,
  RenderUtil,
  AppContext,
  ComponentUI,
  StatusBarUI,
  CaptionBarUI,
  SuperTabBarUI,
  CustomMasterUI,
  KeySearchEngine;

type

  // MasterUI
  TMasterUI = class(TCustomMasterUI)
  private
    // StatusBarUI
    FStatusBarUI: TStatusBarUI;
    // CaptionBarUI
    FCaptionBarUI: TCaptionBarUI;
    // SuperTabBarUI
    FSuperTabBarUI: TSuperTabBarUI;
  protected
    // Update Skin Style
    procedure DoUpdateSkinStyle; override;
    // ToStatusBarPt
    function ToStatusBarPt(APt: TPoint): TPoint;
    // ToCaptionBarPt
    function ToCaptionBarPt(APt: TPoint): TPoint;
    // ToSuperTabBarPt
    function ToSuperTabBarPt(APt: TPoint): TPoint;
    // CalcNCStatusBar
    procedure CalcNCStatusBar(ADC: HDC; ARect: TRect); override;
    // CalcNCCaptionBar
    procedure CalcNCCaptionBar(ADC: HDC; ARect: TRect); override;
    // CalcNCSuperTabBar
    procedure CalcNCSuperTabBar(ADC: HDC; ARect: TRect); override;
    // DrawNCStatusBar
    procedure DrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer = -1); override;
    // DrawNCCaptionBar
    procedure DrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer = -1); override;
    // DrawNCStatusBar
    procedure DrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer = -1); override;
    // UpdateBarHitTest
    procedure DoUpdateBarHitTest(AMouseMoveId, AMouseDownId: Integer); override;

    // Create Wnd
    procedure CreateWnd; override;
    // 非客户区点击测试
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    // NCLeftButtonUp
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // NCLeftButtonDown
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // BeforeCreate
    procedure BeforeCreate; override;
    // Change
    procedure Change(ACommandId: Integer);
  end;

implementation

uses
  Command;

{$R *.dfm}

{ TAppMainFormUI }

constructor TMasterUI.Create(AContext: IAppContext);
begin
  inherited;
  FIsMaster := True;
  Caption := '梵思';
end;

destructor TMasterUI.Destroy;
begin
  FSuperTabBarUI.Free;
  FCaptionBarUI.Free;
  FStatusBarUI.Free;
  inherited;
end;

procedure TMasterUI.BeforeCreate;
begin
  inherited;
  FStatusBarUI := TStatusBarUI.Create(FAppContext, Self);
  FCaptionBarUI := TCaptionBarUI.Create(FAppContext, Self);
  FSuperTabBarUI := TSuperTabBarUI.Create(FAppContext, Self);
end;

procedure TMasterUI.Change(ACommandId: Integer);
begin
  FStatusBarUI.Change(ACommandId);
  FCaptionBarUI.Change(ACommandId);
  FSuperTabBarUI.Change(ACommandId);
end;

procedure TMasterUI.CreateWnd;
begin
  inherited;
  // 设置在任务栏显示应用程序图标
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
end;

procedure TMasterUI.DoUpdateSkinStyle;
begin
  inherited;
end;

procedure TMasterUI.CalcNCStatusBar(ADC: HDC; ARect: TRect);
begin
  if FStatusBarUI = nil then Exit;

  FStatusBarUI.Calc(ADC, ARect);
end;

procedure TMasterUI.CalcNCCaptionBar(ADC: HDC; ARect: TRect);
begin
  if FCaptionBarUI = nil then Exit;

  FCaptionBarUI.Calc(ADC, ARect);
end;

procedure TMasterUI.CalcNCSuperTabBar(ADC: HDC; ARect: TRect);
begin
  if FSuperTabBarUI = nil then Exit;

  FSuperTabBarUI.Calc(ADC, ARect);
end;

function TMasterUI.ToStatusBarPt(APt: TPoint): TPoint;
begin
  Result := APt;
  if FBorderWidth > 0 then begin
    Result.X := APt.X - FBorderWidth;
    Result.Y := APt.Y - FBorderWidth - FClientRect.Height;
  end;
  if FCaptionHeight > 0 then begin
    Result.Y := Result.Y - FCaptionHeight;
  end;
  if FSuperTabBarWidth > 0 then begin
    Result.X := Result.X - FSuperTabBarWidth;
  end;
end;

function TMasterUI.ToCaptionBarPt(APt: TPoint): TPoint;
begin
  Result := APt;
  if FBorderWidth > 0 then begin
    Result.X := APt.X - FBorderWidth;
    Result.Y := APt.Y - FBorderWidth;
  end;
end;

function TMasterUI.ToSuperTabBarPt(APt: TPoint): TPoint;
begin
  Result := APt;
  if FBorderWidth > 0 then begin
    Result.X := APt.X - FBorderWidth;
    Result.Y := APt.Y - FBorderWidth;
  end;
  if FCaptionHeight > 0 then begin
    Result.Y := Result.Y - FCaptionHeight;
  end;
end;

procedure TMasterUI.DoUpdateBarHitTest(AMouseMoveId, AMouseDownId: Integer);
var
  LMsg: Cardinal;
  LComponent: TComponentUI;
begin
  if (FMouseMoveId <> AMouseMoveId)
    or (FMouseDownId <> AMouseDownId) then begin
    if FCaptionBarUI.FindComponent(FMouseMoveId, LComponent) then begin
      LMsg := WM_NCPAINT_CAPTIONBAR;
    end else if FSuperTabBarUI.FindComponent(FMouseMoveId, LComponent) then begin
      LMsg := WM_NCPAINT_SUPERTABBAR;
    end else if FStatusBarUI.FindComponent(FMouseMoveId, LComponent) then begin
      LMsg := WM_NCPAINT_STATUSBAR;
    end else begin
      LMsg := WM_NCPAINT;
    end;
    FMouseMoveId := AMouseMoveId;
    FMouseDownId := AMouseDownId;
    SendMessage(Handle, LMsg, 0, 0);
  end;
end;

procedure TMasterUI.DrawNCStatusBar(ADC: HDC; ARect: TRect; AId: Integer);
begin
  if FStatusBarUI = nil then Exit;

  FStatusBarUI.Draw(ADC, ARect, AId);
end;

procedure TMasterUI.DrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer);
begin
  if FCaptionBarUI = nil then Exit;

  FCaptionBarUI.Draw(ADC, ARect, AId);
end;

procedure TMasterUI.DrawNCSuperTabBar(ADC: HDC; ARect: TRect; AId: Integer);
begin
  if FSuperTabBarUI = nil then Exit;

  FSuperTabBarUI.Draw(ADC, ARect, AId);
end;

procedure TMasterUI.WMNCHitTest(var Msg: TMessage);
var
  LMousePt: TPoint;
  LIsPaint: Boolean;
  LComponent: TComponentUI;
  LRect, LBorderRect: TRect;
begin
  // 如果是无边框嵌入窗体，则让消息继续传递，解决边框拖动问题
  if FBorderStyleEx = bsNone then begin
    inherited;
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
      DoUpdateHitTest(Msg.Result);
      Exit;
    end;
  end;

  LIsPaint := False;
  LMousePt.X := LMousePt.X - LRect.Left;
  LMousePt.Y := LMousePt.Y - LRect.Top;
  if PtInRect(FCaptionBarUI.ComponentsRect, ToCaptionBarPt(LMousePt)) then begin
    if FCaptionBarUI.FindComponent(ToCaptionBarPt(LMousePt), LComponent) then begin
      if LComponent is TSysCloseItem then begin
        Msg.Result := HTCLOSE;
      end else if LComponent is TSysMaximizeItem then begin
        Msg.Result := HTMAXBUTTON;
      end else if LComponent is TSysMinimizeItem then begin
        Msg.Result := HTMINBUTTON;
      end else begin
        Msg.Result := HTMENU;
      end;
      if FMouseMoveId <> LComponent.Id then begin
        FMouseMoveId := LComponent.Id;
        LIsPaint := True;
      end;
    end else begin
      Msg.Result := HTCAPTION;
      if FMouseMoveId <> - 1 then begin
        FMouseMoveId := -1;
        LIsPaint := True;
      end;
    end;
    if FMouseDownId <> FMouseMoveId then begin
      FMouseDownId := -1;
      LIsPaint := True;
    end;
    if LIsPaint then begin
      if FCaptionHeight > 0 then begin
        SendMessage(Handle, WM_NCPAINT_CAPTIONBAR, 0, 0);
        Exit;
      end;
    end;
  end else if PtInRect(FSuperTabBarUI.ComponentsRect, ToSuperTabBarPt(LMousePt)) then begin
    if FSuperTabBarUI.FindComponent(ToSuperTabBarPt(LMousePt), LComponent) then begin
      Msg.Result := HTMENU;
      if FMouseMoveId <> LComponent.Id then begin
        FMouseMoveId := LComponent.Id;
        LIsPaint := True;
      end;
    end else begin
      if FMouseMoveId <> - 1 then begin
        FMouseMoveId := -1;
        LIsPaint := True;
      end;
    end;
    if FMouseDownId <> FMouseMoveId then begin
      FMouseDownId := -1;
      LIsPaint := True;
    end;
    if LIsPaint then begin
      if FSuperTabBarWidth > 0 then begin
        SendMessage(Handle, WM_NCPAINT_SUPERTABBAR, 0, 0);
        Exit;
      end;
    end;
  end else if PtInRect(FStatusBarUI.ComponentsRect, ToStatusBarPt(LMousePt)) then begin
    if FStatusBarUI.FindComponent(ToStatusBarPt(LMousePt), LComponent) then begin
      Msg.Result := HTMENU;
      if FMouseMoveId <> LComponent.Id then begin
        FMouseMoveId := LComponent.Id;
        LIsPaint := True;
      end;
    end else begin
      if FMouseMoveId <> - 1 then begin
        FMouseMoveId := -1;
        LIsPaint := True;
      end;
    end;
    if FMouseDownId <> FMouseMoveId then begin
      FMouseDownId := -1;
      LIsPaint := True;
    end;
    if LIsPaint then begin
      if FStatusBarHeight > 0 then begin
        SendMessage(Handle, WM_NCPAINT_STATUSBAR, 0, 0);
      end;
      Exit;
    end;
  end else begin
    inherited;
  end;
  DoUpdateBarHitTest(-1, -1);
end;

procedure TMasterUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
var
  LPt: TPoint;
  LComponent: TComponentUI;
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FDownHitTest := Message.HitTest;

  if FCaptionBarUI.FindComponent(FMouseMoveId, LComponent) then begin
    FMouseDownId := FMouseMoveId;
    DoNCPaintCaptionBar(FMouseMoveId);
  end else if FSuperTabBarUI.FindComponent(FMouseMoveId, LComponent) then begin
    FMouseDownId := FMouseMoveId;
    DoNCPaintSuperTabBar(FMouseMoveId);
  end else if FStatusBarUI.FindComponent(FMouseMoveId, LComponent) then begin
    FMouseDownId := FMouseMoveId;
    DoNCPaintStatusBar(FMouseMoveId);
  end;

  LPt := ToCaptionBarPt(FMouseLeavePt);
  if PtInRect(FCaptionBarUI.ComponentsRect, LPt) then begin
    // 点击激活
    if not Self.IsActivate then begin
      PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
    end;
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

procedure TMasterUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
var
  LMousePt: TPoint;
  LComponent: TComponentUI;
begin
  // 如果抬起时和按下时位置一致
  if Message.HitTest = FDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          if FStatusBarUI.FindComponent(FMouseMoveId, LComponent) then begin
            FMouseDownId := -1;
            DoNCPaintStatusBar;
            FStatusBarUI.LButtonClickComponent(LComponent);
          end else if FCaptionBarUI.FindComponent(FMouseMoveId, LComponent) then begin
            FMouseDownId := -1;
            DoNCPaintCaptionBar;
            FCaptionBarUI.LButtonClickComponent(LComponent);
          end else if FSuperTabBarUI.FindComponent(FMouseMoveId, LComponent) then begin
            FMouseDownId := -1;
            DoNCPaintSuperTabBar;
            FSuperTabBarUI.LButtonClickComponent(LComponent);
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
