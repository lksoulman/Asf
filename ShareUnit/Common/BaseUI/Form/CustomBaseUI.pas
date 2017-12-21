unit CustomBaseUI;

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
  RenderDC,
  RenderUtil,
  CommonLock,
  BaseObject,
  AppContext,
  ComponentUI,
  Generics.Collections;

const

  // 重绘 NCBars
  WM_NCPAINT_BARS       = WM_USER + 100;

  NC_DRAW_CAPTIONBAR    = 1;

type

  // CustomBaseUI
  TCustomBaseUI = class;

  // CustomNCUI
  TCustomBaseNCUI = class(TBaseObject)
  private
  protected
    // ParentUI
    FParentUI: TCustomBaseUI;
    // WParam
    FWParam: Cardinal;
    // WMPAINT
    FPaintMsg: Cardinal;
    // RenderDC
    FRenderDC: TRenderDC;
    // ComponentsRect
    FComponentsRect: TRect;
    // Components
    FComponents: TList<TComponentUI>;
    // ComponentDic
    FComponentDic: TDictionary<Integer, TComponentUI>;

    // ClearComponents
    procedure DoClearComponents;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; virtual;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); virtual;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); virtual;
    // AddComponent
    procedure DoAddComponent(AComponent: TComponentUI); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TCustomBaseUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Invaliate
    procedure Invalidate(AId: Integer= -1); virtual;
    // Change
    procedure Change(ACommandId: Integer); virtual;
    // Calc
    procedure Calc(ADC: HDC; ARect: TRect); virtual;
    // Draw
    procedure Draw(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); virtual;
    // FindComponent
    function FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; overload; virtual;
    // FindComponent
    function FindComponent(AId: Integer; var AComponent: TComponentUI): Boolean; overload; virtual;

    property ParentUI: TCustomBaseUI read FParentUI;
    property ComponentsRect: TRect read FComponentsRect write FComponentsRect;
  end;

  // CustomItem
  TCustomItem = class(TComponentUI)
  private
  protected
    // ParentUI
    FParentUI: TCustomBaseNCUI;
  public
    // Constructor
    constructor Create(AParentUI: TCustomBaseNCUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
  end;

  // CaptionBarIcon
  TCaptionBarIcon = class(TCustomItem)
  private
  protected
  public
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CaptionBarText
  TCaptionBarText = class(TCustomItem)
  private
  protected
  public
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CaptionBarClose
  TCaptionBarClose = class(TCustomItem)
  private
  protected
  public
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CaptionBarMaximize
  TCaptionBarMaximize = class(TCustomItem)
  private
  protected
  public
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CaptionBarMinimize
  TCaptionBarMinimize = class(TCustomItem)
  private
  protected
  public
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CaptionBarNCUI
  TCaptionBarNCUI = class(TCustomBaseNCUI)
  private
    // CaptionBarIcon
    FCaptionBarIcon: TCaptionBarIcon;
    // CaptionBarText
    FCaptionBarText: TCaptionBarText;
    // CaptionBarClose
    FCaptionBarClose: TCaptionBarClose;
    // CaptionBarMaximize
    FCaptionBarMaximize: TCaptionBarMaximize;
    // CaptionBarMinimize
    FCaptionBarMinimize: TCaptionBarMinimize;
  protected
    // CalcComponentsRect
    procedure DoCalcComponentsRect; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); override;
  end;

  TCaptionBarNCUIClass = class of TCaptionBarNCUI;

  // CustomBaseUI
  TCustomBaseUI = class(TForm)
  private
    // Lock
    FLock: TCSLock;
    // UniqueId
    FUniqueId: Integer;
  protected
    // IsAppWind
    FIsAppWind: Boolean;
    // IsActivate
    FIsActivate: Boolean;
    // IsMaximize
    FIsMaximize: Boolean;
    // IsMinimize
    FIsMinimize: Boolean;
    // IsTracking
    FIsTracking: Boolean;
    // MouseLeavePt
    FMouseLeavePt: TPoint;
    // FormBorderRect
    FFormBorderRect: TRect;
    // CaptionBarRect
    FCaptionBarRect: TRect;
    // BorderWidth
    FBorderWidth: Integer;
    // CaptionHeight
    FCaptionHeight: Integer;
    // NCMouseMoveId
    FNCMouseMoveId: Integer;
    // NCMouseDownId
    FNCMouseDownId: Integer;
    // MinTrackWidth
    FMinTrackWidth: Integer;
    // MinTrackHeight
    FMinTrackHeight: Integer;
    // MouseDownHitTest
    FMouseDownHitTest: Integer;
    // MouseMoveHitTest
    FMouseMoveHitTest: Integer;
    // BorderStyleEx
    FBorderStyleEx: TFormBorderStyle;
    // BorderColor
    FBorderColor: COLORREF;

    // AppContext
    FAppContext: IAppContext;
    // CaptionBarNCUI
    FCaptionBarNCUI: TCaptionBarNCUI;
    // CaptionBarNCUIClass
    FCaptionBarNCUIClass: TCaptionBarNCUIClass;

    // CreateWnd
    procedure CreateWnd; override;
    // CreateParams
    procedure CreateParams(var Params: TCreateParams); override;
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

    // BeforeCreate
    procedure DoBeforeCreate; virtual;
    // CreateNCBarUI
    procedure DoCreateNCBarUI; virtual;
    // DestroyNCBarUI
    procedure DoDestroyNCBarUI; virtual;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; virtual;

    // UpdateHitTest
    procedure DoUpdateHitTest(AHitTest: Integer); virtual;

    // CalcNC
    procedure DoCalcNC; virtual;
    // CalcNCCaptionBar
    procedure DoCalcNCCaptionBar(ADC: HDC; ARect: TRect); virtual;

    // DrawNC
    procedure DoDrawNC(ADC: HDC); virtual;
    // DrawNCCaptionBar
    procedure DoDrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;

    // DoPaintNCBars
    procedure DoWmPaintNCBars(var Message: TMessage); message WM_NCPAINT_BARS;

    // ToNCCaptionBarPt
    function DoToNCCaptionBarPt(APt: TPoint): TPoint;

    // CloseEx
    procedure DoCloseEx; virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle;
    // GetUniqueId
    function GetUniqueId: Integer;

    property IsMaximize: Boolean read FIsMaximize;
    property IsMinimize: Boolean read FIsMinimize;
    property NCMouseMoveId: Integer read FNCMouseMoveId;
    property NCMouseDownId: Integer read FNCMouseDownId;
  end;

implementation

uses
  Math,
  MultiMon,
  Vcl.Imaging.pngimage;

{$R *.dfm}

{ TCustomBaseNCUI }

constructor TCustomBaseNCUI.Create(AContext: IAppContext; AParentUI: TCustomBaseUI);
begin
  inherited Create(AContext);
  FWParam := 0;
  FPaintMsg := 0;
  FParentUI := AParentUI;
  FRenderDC := TRenderDC.Create;
  FComponents := TList<TComponentUI>.Create;
  FComponentDic := TDictionary<Integer, TComponentUI>.Create;
end;

destructor TCustomBaseNCUI.Destroy;
begin
  DoClearComponents;
  FComponentDic.Free;
  FComponents.Free;
  FRenderDC.Free;
  inherited;
end;

procedure TCustomBaseNCUI.DoClearComponents;
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponent := FComponents.Items[LIndex];
    if LComponent <> nil then begin
      LComponent.Free;
    end;
  end;
  FComponents.Clear;
end;

procedure TCustomBaseNCUI.DoCalcComponentsRect;
begin

end;

procedure TCustomBaseNCUI.DoDrawBK(ARenderDC: TRenderDC);
begin

end;

procedure TCustomBaseNCUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponent := FComponents.Items[LIndex];
    if LComponent.Visible
      and LComponent.RectExIsValid then begin
      LComponent.Draw(ARenderDC);
    end;
  end;
end;

procedure TCustomBaseNCUI.DoAddComponent(AComponent: TComponentUI);
begin
  if FComponents.IndexOf(AComponent) < 0 then begin
    AComponent.Id := FParentUI.GetUniqueId;
    FComponents.Add(AComponent);
    FComponentDic.AddOrSetValue(AComponent.Id, AComponent);
  end;
end;

procedure TCustomBaseNCUI.Invalidate(AId: Integer);
begin
  if FPaintMsg = 0 then Exit;

  if FParentUI.Showing then begin
    PostMessage(FParentUI.Handle, FPaintMsg, FWParam, AId);
  end;
end;

procedure TCustomBaseNCUI.Change(ACommandId: Integer);
begin

end;

procedure TCustomBaseNCUI.Calc(ADC: HDC; ARect: TRect);
begin
  if not FRenderDC.IsInit then begin
    FRenderDC.SetDC(ADC);
  end;

  if FRenderDC.MemDC = 0 then Exit;

  FComponentsRect := ARect;
  FRenderDC.SetBounds(ADC, FComponentsRect);
  if FComponentsRect.Left < FComponentsRect.Right then begin
    DoCalcComponentsRect;
  end;
end;

procedure TCustomBaseNCUI.Draw(ADC: HDC; ARect: TRect; AId: Integer);
var
  LComponentUI: TComponentUI;
begin
  if FRenderDC.MemDC = 0 then Exit;

  if AId = -1 then begin
    if FComponentsRect.Left < FComponentsRect.Right - 10 then begin
      DoDrawBK(FRenderDC);
      DoDrawComponents(FRenderDC);
    end;
  end else begin
    if FComponentDic.TryGetValue(AId, LComponentUI) then begin
      LComponentUI.Draw(FRenderDC);
    end;
  end;

  FRenderDC.BitBltX(ADC, ARect);
end;

procedure TCustomBaseNCUI.LButtonClickComponent(AComponent: TComponentUI);
begin

end;

function TCustomBaseNCUI.FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FComponents.Count - 1 do begin
    AComponent := FComponents.Items[LIndex];
    if AComponent.Visible
      and AComponent.RectExIsValid
      and AComponent.PtInRectEx(APt) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TCustomBaseNCUI.FindComponent(AId: Integer; var AComponent: TComponentUI): Boolean;
begin
  if FComponentDic.TryGetValue(AId, AComponent) then begin
    Result := True;
  end else begin
    Result := False;
    AComponent := nil;
  end;
end;

{ TCustomItem }

constructor TCustomItem.Create(AParentUI: TCustomBaseNCUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FRectEx := Rect(0, 0, 0, 0);
end;

destructor TCustomItem.Destroy;
begin

  inherited;
end;

function TCustomItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TCustomItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

{ TCaptionBarIcon }

function TCaptionBarIcon.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TCaptionBarIcon.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect, LDesRect: TRect;
  LResourceStream: TResourceStream;
begin
  LDesRect := FRectEx;

  LResourceStream := FParentUI.FAppContext.GetGdiMgr.GetImgAppLogoS;
  if LResourceStream = nil then Exit;

  LDesRect.Inflate(-7, -7);
  LSrcRect := Rect(0, 0, 14, 14);
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, LDesRect, LSrcRect);
end;

{ TCaptionBarText }

function TCaptionBarText.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TCaptionBarText.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOBJ: HGDIOBJ;
  LCaption: string;
begin
  LCaption := FParentUI.ParentUI.Caption;
  if LCaption = '' then Exit;

  LOBJ := SelectObject(ARenderDC.MemDC, FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, LCaption,
      FParentUI.FAppContext.GetGdiMgr.GetColorRefMasterCaptionText, dtaLeft, False, True);
  finally
    SelectObject(ARenderDC.MemDC, LOBJ);
  end;
end;

{ TCaptionBarClose }

function TCaptionBarClose.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := FParentUI.FAppContext.GetGdiMgr.GetImgAppClose;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = FParentUI.ParentUI.NCMouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = FParentUI.ParentUI.NCMouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TCaptionBarMaximize }

function TCaptionBarMaximize.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := FParentUI.FAppContext.GetGdiMgr.GetImgAppMaximize;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = FParentUI.ParentUI.NCMouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = FParentUI.ParentUI.NCMouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TCaptionBarMinimize }

function TCaptionBarMinimize.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := FParentUI.FAppContext.GetGdiMgr.GetImgAppMinimize;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = FParentUI.ParentUI.NCMouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = FParentUI.ParentUI.NCMouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TCaptionBarNCUI }

constructor TCaptionBarNCUI.Create(AContext: IAppContext; AParentUI: TCustomBaseUI);
begin
  inherited;
  FWParam := NC_DRAW_CAPTIONBAR;
  FPaintMsg := WM_NCPAINT_BARS;

  FCaptionBarIcon := TCaptionBarIcon.Create(Self);
  DoAddComponent(FCaptionBarIcon);

  FCaptionBarText := TCaptionBarText.Create(Self);
  DoAddComponent(FCaptionBarText);

  FCaptionBarClose := TCaptionBarClose.Create(Self);
  DoAddComponent(FCaptionBarClose);

  if AParentUI.IsMaximize then begin
    FCaptionBarMaximize := TCaptionBarMaximize.Create(Self);
    DoAddComponent(FCaptionBarMaximize);
  end;

  if AParentUI.IsMinimize then begin
    FCaptionBarMinimize := TCaptionBarMinimize.Create(Self);
    DoAddComponent(FCaptionBarMinimize);
  end;
end;

destructor TCaptionBarNCUI.Destroy;
begin

  inherited;
end;

procedure TCaptionBarNCUI.DoCalcComponentsRect;
var
  LSize: TSize;
  LCaption: string;
//  LLeft, LRight: Integer;
  LRect, LTempRect: TRect;
begin
  LRect := FComponentsRect;
  LTempRect := LRect;

  // CalcIcon
  LTempRect.Right := LTempRect.Left + 30;
  FCaptionBarIcon.RectEx := LTempRect;

  // CalcCaption
  LTempRect.Left := LTempRect.Right;
  LCaption := FParentUI.Caption;
  if GetTextSizeX(FRenderDC.MemDC, FAppContext.GetGdiMgr.GetFontObjHeight20, LCaption, LSize) then begin
    LTempRect.Right := LTempRect.Left + LSize.cx;
  end;
  if LTempRect.Right > LRect.Right then begin
    LTempRect.Right := LRect.Right;
  end;
  FCaptionBarText.RectEx := LTempRect;

  // Left
//  LLeft := LTempRect.Right;

  LTempRect := LRect;
  LTempRect.Left := LTempRect.Right - 30;
  FCaptionBarClose.RectEx := LTempRect;

  if FCaptionBarMaximize <> nil then begin
    if LTempRect.Left <= LRect.Left then begin
      LTempRect.Left := LRect.Left;
      LTempRect.Right := LRect.Left;
      FCaptionBarMaximize.RectEx := LTempRect;
      if FCaptionBarMinimize <> nil then begin
        FCaptionBarMinimize.RectEx := LTempRect;
      end;
    end else begin
      LTempRect.Right := LTempRect.Left;
      LTempRect.Left := LTempRect.Right - 30;
      FCaptionBarMaximize.RectEx := LTempRect;
      if FCaptionBarMinimize <> nil then begin
        if LTempRect.Left <= LRect.Left then begin
          LTempRect.Left := LRect.Left;
          LTempRect.Right := LRect.Left;
          FCaptionBarMinimize.RectEx := LTempRect;
        end else begin
          LTempRect.Right := LTempRect.Left;
          LTempRect.Left := LTempRect.Right - 30;
          FCaptionBarMinimize.RectEx := LTempRect;
        end;
      end;
    end;
  end else begin
    if FCaptionBarMinimize <> nil then begin
      if LTempRect.Left <= LRect.Left then begin
        LTempRect.Left := LRect.Left;
        LTempRect.Right := LRect.Left;
        FCaptionBarMinimize.RectEx := LTempRect;
      end else begin
        LTempRect.Right := LTempRect.Left;
        LTempRect.Left := LTempRect.Right - 30;
        FCaptionBarMinimize.RectEx := LTempRect;
      end;
    end;
  end;

  // Right
//  LRight := LTempRect.Left;
end;

procedure TCaptionBarNCUI.LButtonClickComponent(AComponent: TComponentUI);
begin
  inherited;

end;

{ TCustomBaseUI }

constructor TCustomBaseUI.Create(AContext: IAppContext);
begin
  FAppContext := AContext;
  DoBeforeCreate;
  DoCreateNCBarUI;
  DoUpdateSkinStyle;
  inherited Create(nil);
//  if BorderStyle <> bsNone then begin
//    BorderStyle := bsNone;
//  end;
end;

destructor TCustomBaseUI.Destroy;
begin
  DoDestroyNCBarUI;
  FAppContext := nil;
  inherited;
end;

procedure TCustomBaseUI.UpdateSkinStyle;
begin
  DoUpdateSkinStyle;

end;

function TCustomBaseUI.GetUniqueId: Integer;
begin
  FLock.Lock;
  try
    Result := FUniqueId;
    Inc(FUniqueId);
  finally
    FLock.UnLock;
  end;
end;

procedure TCustomBaseUI.DoBeforeCreate;
begin
  FIsAppWind := False;
  FIsActivate := False;
  FIsMaximize := True;
  FIsMinimize := True;
  FIsTracking := False;
  FUniqueId := 0;
  FBorderWidth := 1;
  FCaptionHeight := 30;
  FNCMouseMoveId := -1;
  FNCMouseDownId := -1;
  FMinTrackWidth := 0;
  FMinTrackHeight := 0;
  FMouseDownHitTest := -1;
  FMouseMoveHitTest := -1;
  FBorderStyleEx := bsSizeable;
  FCaptionBarNCUIClass := TCaptionBarNCUI;
end;

procedure TCustomBaseUI.DoCreateNCBarUI;
begin
  FLock := TCSLock.Create;
  if FCaptionHeight > 0 then begin
    FCaptionBarNCUI := FCaptionBarNCUIClass.Create(FAppContext, Self);
  end;
end;

procedure TCustomBaseUI.DoDestroyNCBarUI;
begin
  if FCaptionBarNCUI <> nil then begin
    FCaptionBarNCUI.Free;
  end;
  FLock.Free;
end;

procedure TCustomBaseUI.DoUpdateSkinStyle;
begin
  FBorderColor := clRed;
end;

procedure TCustomBaseUI.DoUpdateHitTest(AHitTest: Integer);
begin
  if (FMouseMoveHitTest <> AHitTest) then begin
    FMouseMoveHitTest := AHitTest;
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomBaseUI.DoCalcNC;
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

    finally
      ReleaseDC(Handle, LDC);
    end;
    SendMessage(Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomBaseUI.DoCalcNCCaptionBar(ADC: HDC; ARect: TRect);
begin
  if FCaptionBarNCUI = nil then Exit;

  FCaptionBarNCUI.Calc(ADC, ARect);
end;

procedure TCustomBaseUI.DoDrawNC(ADC: HDC);
var
  LRect: TRect;
begin
  DoDrawNCCaptionBar(ADC, FCaptionBarRect);
  if FBorderWidth > 0 then begin
    LRect := FFormBorderRect;
    Dec(LRect.Right);
    Dec(LRect.Bottom);
    DrawBorder(ADC, FBorderColor, LRect, 15);
  end;
end;

procedure TCustomBaseUI.DoDrawNCCaptionBar(ADC: HDC; ARect: TRect; AId: Integer = -1);
begin
  if FCaptionBarNCUI = nil then Exit;

  FCaptionBarNCUI.Draw(ADC, ARect, AId);
end;

procedure TCustomBaseUI.DoWmPaintNCBars(var Message: TMessage);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Self.Handle);
  try
    case Message.WParam of
      NC_DRAW_CAPTIONBAR:
        begin
          DoDrawNCCaptionBar(LDC, FCaptionBarRect, Message.LParam);
        end;
    end;
  finally
    ReleaseDC(Self.Handle, LDC);
  end;
end;

function TCustomBaseUI.DoToNCCaptionBarPt(APt: TPoint): TPoint;
begin
  Result := APt;
  if FBorderWidth > 0 then begin
    Result.X := APt.X - FBorderWidth;
    Result.Y := APt.Y - FBorderWidth;
  end;
end;

procedure TCustomBaseUI.DoCloseEx;
begin

end;

procedure TCustomBaseUI.CreateWnd;
begin
  BorderStyle := bsNone;
  inherited;
  if FIsAppWind then begin
    // 设置在任务栏显示应用程序图标
    SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  end;
end;

procedure TCustomBaseUI.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if FIsMinimize then begin
    Params.Style := Params.Style or WS_MINIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MINIMIZEBOX));
  end;

  if FIsMaximize then begin
    Params.Style := Params.Style or WS_MAXIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MAXIMIZEBOX));
  end;
end;

procedure TCustomBaseUI.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in Self.ComponentState) then begin
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomBaseUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
  if not message.Active then begin
    SendMessage(Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TCustomBaseUI.WMActivate(var Message: TWMActivate);
begin
  if message.Active in [WA_ACTIVE, WA_CLICKACTIVE] then begin
    FIsActivate := True;
  end else begin
    FIsActivate := False;
  end;
  SendMessage(Handle, WM_NCPAINT, 0, 0);
  inherited;
end;

procedure TCustomBaseUI.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  LMonitor: HMONITOR;
  LMonitorInfo: MONITORINFO;
begin
  Message.MinMaxInfo.ptMinTrackSize.X := FMinTrackWidth;
  Message.MinMaxInfo.ptMinTrackSize.Y := FMinTrackHeight;
    //调整窗口最大化时高度，避免窗口最大化时盖住主屏任务栏
  LMonitorInfo.cbSize := SizeOf(MONITORINFO);
  LMonitor := MonitorFromWindow(Handle, MONITOR_DEFAULTTONULL);
  if LMonitor <> 0 then
  begin
    GetMonitorInfo(LMonitor, @LMonitorInfo);
    //ptMaxSize的默认大小为主屏的分辨率，在不同分辨率的屏幕上是以默认大小为基准按比例设置的。
    //如主屏分辨率X1*Y1,副屏分辨率X2*Y2，如果该值设为x*y，在副屏上计算的实际大小是x*X2/X1和y*Y2/Y1
    Message.MinMaxInfo.ptMaxSize.X := Min(LMonitorInfo.rcWork.Right - LMonitorInfo.rcWork.Left, Message.MinMaxInfo.ptMaxSize.X);
    Message.MinMaxInfo.ptMaxSize.Y := Min(LMonitorInfo.rcWork.Bottom - LMonitorInfo.rcWork.Top, Message.MinMaxInfo.ptMaxSize.Y);
  end;
  inherited;
end;

procedure TCustomBaseUI.WMSize(var Message: TWMSize);
begin
  inherited;
  DoCalcNC;
end;

procedure TCustomBaseUI.WMNCPaint(var Message: TMessage);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Handle);
  try
    DoDrawNC(LDC);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomBaseUI.WMNCHitTest(var Msg: TMessage);
var
  LMousePt: TPoint;
  LMouseMoveId: Integer;
  LComponent: TComponentUI;
  LRect, LBorderRect: TRect;
begin
  // 没有标题没有边框
  if (FCaptionHeight = 0)
    and (FBorderWidth = 0) then begin
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

  LMousePt.X := LMousePt.X - LRect.Left;
  LMousePt.Y := LMousePt.Y - LRect.Top;
  LMouseMoveId := -1;
  if (FCaptionBarNCUI <> nil)
    and PtInRect(FCaptionBarNCUI.ComponentsRect, DoToNCCaptionBarPt(LMousePt)) then begin
    if FCaptionBarNCUI.FindComponent(DoToNCCaptionBarPt(LMousePt), LComponent) then begin
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
    if (FNCMouseMoveId <> LMouseMoveId)
      or (FNCMouseDownId <> LMouseMoveId) then begin
      FNCMouseDownId := -1;
      FCaptionBarNCUI.Invalidate;
    end;
  end else begin
    inherited;
  end;
end;

procedure TCustomBaseUI.WMNCActivate(var Message: TWMNCActivate);
begin
  message.Result := 1;          //去掉默认响应，关闭默认标题栏绘制
end;

procedure TCustomBaseUI.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  //如果原来没有边框，则不设置非客户区域
  if FBorderStyleEx = bsNone then begin
    inherited;
    Exit;
  end;

  Message.CalcSize_Params.rgrc[0].Left := Message.CalcSize_Params.rgrc[0].Left + FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Right := Message.CalcSize_Params.rgrc[0].Right - FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Top := Message.CalcSize_Params.rgrc[0].Top + FBorderWidth + FCaptionHeight;
  Message.CalcSize_Params.rgrc[0].Bottom := Message.CalcSize_Params.rgrc[0].Bottom - FBorderWidth;
end;

procedure TCustomBaseUI.WMNCMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsTracking := False;
end;

procedure TCustomBaseUI.WMNCMouseMove(var Message: TWMMouseMove);
var
  LEvent: TTrackMouseEvent;
  LPosX, LPosY, LWidth: Integer;
begin
  if (Abs(FMouseLeavePt.X - Message.XPos) > 3)
    or (Abs(FMouseLeavePt.Y - Message.YPos) > 3) then begin
    if FMouseDownHitTest = HTCAPTION then begin
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

procedure TCustomBaseUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
var
  LComponent: TComponentUI;
begin
  // 如果抬起时和按下时位置一致
  if Message.HitTest = FMouseDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          if (FCaptionBarNCUI <> nil)
            and FCaptionBarNCUI.FindComponent(FNCMouseMoveId, LComponent) then begin
            FNCMouseDownId := -1;
            FCaptionBarNCUI.Invalidate(FNCMouseMoveId);
            FCaptionBarNCUI.LButtonClickComponent(LComponent);
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
        Self.WindowState := wsMinimized;
    end;
  end;
  FMouseDownHitTest := HTNOWHERE;
  inherited;
end;

procedure TCustomBaseUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
var
  LPt: TPoint;
  LComponent: TComponentUI;
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FMouseDownHitTest := Message.HitTest;

  if FCaptionBarNCUI <> nil then begin
    if FCaptionBarNCUI.FindComponent(FNCMouseMoveId, LComponent) then begin
      FNCMouseDownId := FNCMouseMoveId;
      FCaptionBarNCUI.Invalidate(FNCMouseMoveId);
    end;

    LPt := DoToNCCaptionBarPt(FMouseLeavePt);
    if PtInRect(FCaptionBarNCUI.ComponentsRect, LPt) then begin
      // 点击激活
      if not FIsActivate then begin
        PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
      end;
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

procedure TCustomBaseUI.WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk);
begin
  if (FBorderStyleEx = bsSizeable)
    and (Message.HitTest = HTCAPTION) then begin
    if Self.WindowState = wsMaximized then begin
      Self.WindowState := wsNormal
    end else begin
      Self.WindowState := wsMaximized;
    end;
  end;
end;

end.

