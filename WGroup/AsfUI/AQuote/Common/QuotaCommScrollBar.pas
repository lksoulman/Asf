unit QuotaCommScrollBar;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Controls,
  StdCtrls,
  ExtCtrls,
  CommonFunc,
  AppContext,
  GR32,
  Vcl.Imaging.pngimage,
  GR32_RangeBars,
  Math, types,
  Forms,
  Graphics,
  QuoteCommLibrary;

const

  CONST_Handle_Horz = 'Controls_ScrollBar_Horz';
  CONST_Handle_Horz_Down = 'Controls_ScrollBar_Horz_Down';
  CONST_Handle_Horz_Hot = 'Controls_ScrollBar_Horz_Hot';
  CONST_Handle_Vertical = 'Controls_ScrollBar_Vertical';
  CONST_Handle_Vertical_Down = 'Controls_ScrollBar_Vertical_Down';
  CONST_Handle_Vertical_Hot = 'Controls_ScrollBar_Vertical_Hot';

  Const_VerScroll_HandleSize = 100;
  Con_ScrollStep = 5;
type
//  TQuoteBorderLine = set of (blLeft, blTop, blRight, blBottom);

  TDisplaySCrollBar = class
    ScrollBarColor: TColor;
    ScrollBarButtonColor: TColor;

    //滑块颜色
    ScrollBarHandleColor: TColor;
    ScrollBarHandleHotColor: TColor;
    ScrollBarHandleDownColor: TColor;
    ScrollBarHighLightColor: TColor;
    ScrollBarBorderColor: TColor;
    ScrollBarShadowColor: TColor;
    ScrollBarArrowColor: TColor;
    ScrollEnabledButtonColor: TColor;
    ScrollBarHandleGrip: boolean;
    ScrollWidth: Integer;
    ScrollHeight: Integer;
  public
    constructor Create;
    procedure UpdateSkin(AContext: IAppContext);
  end;


  // 表格滚动条，覆盖了绘制buuton的函数，使得小箭头的颜色可以自选
  TGaugeBarEx = class(TGaugeBar)
  protected
    FInstance: HInst;
    FPngImage: TPngImage;
    FBorderLines: TQuoteBorderLine;
    FHorzImgHeight: integer;
    FVertImgWidth: integer;
    FScrollType: TScrollBarKind;
    procedure Paint; override;
    // 绘制滚动条两端的按钮
    procedure DoDrawButton(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean); override;
    procedure DoDrawHandle(R: TRect; Horz: Boolean; Pushed, Hot: Boolean); override;
    procedure DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean); override;
    procedure ChangeSize;
    procedure SetBorderLines(ALines: TQuoteBorderLine);
    procedure SetScrollType(AScrollType: TScrollBarKind);
    property Kind;
    function LoadSourcePng(ASourceName: string): Boolean;
  public
    Display: TDisplaySCrollBar;
    ArrowColor: TColor;
    HandleHotColor: TColor;
    HandleDownColor: TColor;
    HeightAbsolute: Integer;   //绝对高度（实际）
    WidthAbsolute: Integer;    //绝对宽度（实际）

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateSkin(AContext: IAppContext);
    procedure SetInstance(AInstance: HInst); virtual;
    function GetClientRect: TRect; override;
  published
    property Canvas;
    property Instance: HInst read FInstance write SetInstance;
    property BorderLines: TQuoteBorderLine read FBorderLines write SetBorderLines;
    property ScrollType: TScrollBarKind read FScrollType write SetScrollType;
  end;

implementation

{ TQuoteSimpleGridBar }
procedure TGaugeBarEx.Paint;
const
  CPrevDirs: array[Boolean] of TRBDirection = (drUp, drLeft);
  CNextDirs: array[Boolean] of TRBDirection = (drDown, drRight);
var
  vButtonSize: Integer;
  vShowEnabled, vShowHandle: Boolean;
  vClientRect, vBtnRect, vHandleRect: TRect;
  vHorz: Boolean;
begin
//  Self.Enabled := not (Self.Min + 1 = Self.Max);

  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(0, 0, Width, Height));

  vClientRect := ClientRect;
  vHorz := Kind = sbHorizontal;
  vShowEnabled := DrawEnabled;
  vButtonSize := GetButtonSize;
//  裁剪区域会 导致 重绘的时候出现问题。
//  vClipRgn := CreateRectRgn(vClientRect.Left, vClientRect.Top, vClientRect.Right, vClientRect.Bottom);
//  SelectClipRgn(Canvas.Handle, vClipRgn);
  try
    try
      if ShowArrows then
      begin
    // left / top button
        vBtnRect := vClientRect;
        with vBtnRect do
          if vHorz then
            Right := Left + vButtonSize
          else
            Bottom := Top + vButtonSize;
        DoDrawButton(vBtnRect, CPrevDirs[vHorz], DragZone = zBtnPrev, vShowEnabled, HotZone = zBtnPrev);

    // right / bottom button
        vBtnRect := vClientRect;
        with vBtnRect do
          if vHorz then
            Left := Right - vButtonSize
          else
            Top := Bottom - vButtonSize;
        DoDrawButton(vBtnRect, CNextDirs[vHorz], DragZone = zBtnNext, vShowEnabled, HotZone = zBtnNext);
      end;

      if vHorz then
        GR32.InflateRect(vClientRect, -vButtonSize, 0)
      else
        GR32.InflateRect(vClientRect, 0, -vButtonSize);
      if vShowEnabled then
      begin
        vHandleRect := GetHandleRect;
      end
      else
        vHandleRect := Rect(0, 0, 0, 0);
      vShowHandle := not GR32.IsRectEmpty(vHandleRect);

      DoDrawTrack(GetZoneRect(zTrackPrev), CPrevDirs[vHorz], DragZone = zTrackPrev, vShowEnabled, HotZone = zTrackPrev);
      DoDrawTrack(GetZoneRect(zTrackNext), CNextDirs[vHorz], DragZone = zTrackNext, vShowEnabled, HotZone = zTrackNext);
      if vShowHandle then
        DoDrawHandle(vHandleRect, vHorz, DragZone = zHandle, HotZone = zHandle);
    finally
//      SelectClipRgn(Canvas.Handle, 0);
//      DeleteObject(vClipRgn);
    end;

    if BorderLines <> [] then
    begin
      with Canvas do
      begin
        Pen.Color := BorderColor;
        if blLeft in BorderLines then
        begin
          MoveTo(0, 0);
          LineTo(0, self.Height - 1);
        end;
        if blTop in BorderLines then
        begin
          MoveTo(0, 0);
          LineTo(self.Width - 1, 0);
        end;
        if blRight in BorderLines then
        begin
          MoveTo(self.Width - 1, 0);
          LineTo(self.Width - 1, self.Height - 1);
        end;
        if blbottom in BorderLines then
        begin
          MoveTo(0, self.Height - 1);
          LineTo(self.Width - 1, self.Height - 1);
        end;
      end;
    end;
  except

  end;
end;

procedure TGaugeBarEx.ChangeSize;
var
  vIncWidth, vIncHeight: SHORT;
begin
  if Instance = 0 then
    Exit;

  try
    if LoadSourcePng(CONST_Handle_Horz) then
      FHorzImgHeight := FPngImage.Height;

    if LoadSourcePng(CONST_Handle_Vertical) then
      FVertImgWidth := FPngImage.Width;
  except
    Exit;
  end;

//  FPngImage.LoadFromFile(const_Path + 'Horz.png');
//  FHorzImgHeight := FPngImage.Height;
//  FPngImage.LoadFromFile(const_Path + 'Vertical.png');
//  FVertImgWidth := FPngImage.Width;

  vIncWidth := 2;
  vIncHeight := 2;
  if FBorderLines <> [] then
  begin
    if blLeft in BorderLines then
    begin
      Inc(vIncWidth);
    end;
    if blRight in BorderLines then
    begin
      Inc(vIncWidth);
    end;

    if blTop in BorderLines then
    begin
      Inc(vIncHeight);
    end;
    if blbottom in BorderLines then
    begin
      Inc(vIncHeight);
    end;
  end;

  if Kind = sbHorizontal then
  begin
    //横向时
    if HeightAbsolute > 0 then
    begin
      Height := HeightAbsolute
    end
    else
    begin
      Height := FHorzImgHeight + vIncHeight;
    end;
  end
  else
  begin
    if WidthAbsolute > 0 then
    begin
      Width := WidthAbsolute;
    end
    else
    begin
      Width := FVertImgWidth + vIncWidth;
    end;
  end;
end;

procedure TGaugeBarEx.SetBorderLines(ALines: TQuoteBorderLine);
begin
  FBorderLines := ALines;
  ChangeSize;
end;

procedure TGaugeBarEx.SetInstance(AInstance: HInst);
begin
  if FInstance <> AInstance then
  begin
    FInstance := AInstance;
    ChangeSize;
  end;
end;

procedure TGaugeBarEx.SetScrollType(AScrollType: TScrollBarKind);
begin
  Kind := AScrollType;
  ChangeSize;
end;

constructor TGaugeBarEx.Create(AOwner: TComponent);
begin
  inherited;
  DoubleBuffered := true;
  ShowArrows := false;
  Ctl3D := false;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  Style := rbsMac;

  FPngImage := TPngImage.Create;

  Display := TDisplaySCrollBar.Create;

  FInstance := 0;
  LargeChange := Max div 5;
  HeightAbsolute := -1;
  WidthAbsolute := -1;
  Width := Display.ScrollWidth;
  Height := Display.ScrollHeight;

  BorderLines := [blLeft, blTop, blRight, blBottom];
end;

destructor TGaugeBarEx.Destroy;
begin
  FreeAndNil(Display);
  FreeAndNil(FPngImage);
  inherited;
end;

procedure TGaugeBarEx.UpdateSkin(AContext: IAppContext);
begin
  if AContext = nil then Exit;
  Display.UpdateSkin(AContext);

  Color := Display.ScrollBarColor;
  ButtonColor := Display.ScrollBarButtonColor;
  HandleColor := Display.ScrollBarHandleColor;
  HandleHotColor := Display.ScrollBarHandleHotColor;
  HandleDownColor := Display.ScrollBarHandleDownColor;
  HighLightColor := Display.ScrollBarHighLightColor;
  BorderColor := Display.ScrollBarBorderColor;
  ShadowColor := Display.ScrollBarShadowColor;
  ArrowColor := Display.ScrollBarArrowColor;
  ShowHandleGrip := Display.ScrollBarHandleGrip;

//  Instance := AContext.GetResourceSkin.// AGilAppController.GetSkinInstance;
end;

procedure TGaugeBarEx.DoDrawButton(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean);

  procedure DrawArrow(AARect: TRect; AADirection: TRBDirection; AAColor: TColor);
  var
    vCenterX, vCenterY, vSize: Integer;
  begin
    vCenterX := (AARect.Left + AARect.Right) div 2;
    vCenterY := (AARect.Top + AARect.Bottom) div 2;
    vSize := (Math.min(vCenterX - AARect.Left, vCenterY - AARect.Top)) * 3 div 4;
    if vSize = 0 then
      vSize := 1;

    Canvas.Pen.Color := AAColor;
    Canvas.Brush.Color := AAColor;
    case AADirection of
      drUp:
        begin
          Canvas.Polygon([GR32.Point(vCenterX + vSize, vCenterY), GR32.Point(vCenterX, vCenterY - vSize), GR32.Point(vCenterX - vSize, vCenterY)]);
        end;
      drDown:
        begin
          Canvas.Polygon([GR32.Point(vCenterX + vSize, vCenterY), GR32.Point(vCenterX, vCenterY + vSize), GR32.Point(vCenterX - vSize, vCenterY)]);
        end;
      drLeft:
        begin
          Canvas.Polygon([GR32.Point(vCenterX, vCenterY + vSize), GR32.Point(vCenterX - vSize, vCenterY), GR32.Point(vCenterX, vCenterY - vSize)]);
        end;
      drRight:
        begin
          Canvas.Polygon([GR32.Point(vCenterX, vCenterY + vSize), GR32.Point(vCenterX + vSize, vCenterY), GR32.Point(vCenterX, vCenterY - vSize)]);
        end;
    end;
  end;

begin
  if Style = rbsMac then
  begin
    if not DrawEnabled then
    begin
      //DrawArrow(R, Direction, Color);
    end
    else
    begin
      if Pushed then
      begin
        DrawArrow(R, Direction, HandleDownColor);
      end
      else if Hot then
      begin
        DrawArrow(R, Direction, HandleHotColor);
      end
      else
      begin
        DrawArrow(R, Direction, HandleColor);
      end;
    end;
  end
  else
  begin
    inherited DoDrawButton(R, Direction, Pushed, Enabled, Hot);
  end;
end;

procedure TGaugeBarEx.DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean);
begin
  if Style = rbsMac then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(R);
  end
  else
  begin
    inherited;
  end;
end;

function TGaugeBarEx.GetClientRect: TRect;
begin
  Result.Left := 1;
  Result.Top := 1;
  Result.Right := Width - 1;
  Result.Bottom := Height - 1;

  if BorderLines <> [] then
  begin
    if blLeft in BorderLines then
    begin
      Result.Left := Result.Left + 1;
    end;
    if blTop in BorderLines then
    begin
      Result.Top := Result.Top + 1;
    end;
    if blRight in BorderLines then
    begin
      Result.Right := Result.Right - 1;
    end;
    if blbottom in BorderLines then
    begin
      Result.bottom := Result.bottom - 1;
    end;
  end;
end;

function TGaugeBarEx.LoadSourcePng(ASourceName: string): Boolean;
begin
  Result := True;
  try
    if FInstance <> 0 then
      FPngImage.LoadFromResourceName(FInstance, ASourceName)
    else
      Result := False;
  except
    Result := False;
  end;
end;

procedure TGaugeBarEx.DoDrawHandle(R: TRect; Horz, Pushed, Hot: Boolean);
var
  vColor: TColor;
  vPngRect, vRect: TRect;
  vIsLoadPng: Boolean;

  procedure DrawHorzHandle;
  begin
//    vPath := const_Path + 'Horz' + vPath;
//    FPngImage.LoadFromFile(vPath);
    vRect := R;
    if vIsLoadPng then
    begin
      //画左半圆
      vPngRect.Left := R.Left;
      vPngRect.Top := R.Top + (R.Height - FPngImage.Height) div 2;
      vPngRect.Height := FPngImage.Height;
      vPngRect.Width := FPngImage.Width div 2;
      vRect := vPngRect;
      Canvas.Draw(vPngRect.Left, vPngRect.Top, FPngImage);

      //画右半圆
      GR32.OffsetRect(vPngRect, R.Width - FPngImage.Width, 0);
      Canvas.Draw(vPngRect.Left, vPngRect.Top, FPngImage);

      //画中间矩形
      vRect.Left := R.Left + FPngImage.Width div 2;
      vRect.Width := R.Width - FPngImage.Width;
    end;
    Canvas.Brush.Color := vColor;
    Canvas.FillRect(vRect);
  end;

  procedure DrawVerticalHandle;
  begin
//    vPath := const_Path + 'Vertical' + vPath;
//    FPngImage.LoadFromFile(vPath);

    vRect := R;
    if vIsLoadPng then
    begin
      //画上半圆
      vPngRect.Left := R.Left + (R.Width - FPngImage.Width) div 2;
      vPngRect.Top := R.Top;
      vPngRect.Height := FPngImage.Height;
      vPngRect.Width := FPngImage.Width;
      vRect := vPngRect;
      Canvas.Draw(vPngRect.Left, vPngRect.Top, FPngImage);

      //画下半圆
      GR32.OffsetRect(vPngRect, 0, R.Height - vPngRect.Height);
      Canvas.Draw(vPngRect.Left, vPngRect.Top, FPngImage);

      //画中间矩形
      vRect.Top := R.Top + FPngImage.Height div 2;
      vRect.Height := R.Height - FPngImage.Height;
    end;
    Canvas.Brush.Color := vColor;
    Canvas.FillRect(vRect);
  end;

begin
  if Style = rbsMac then
  begin
    if Pushed then
    begin
      vColor := HandleDownColor;
      if Horz then
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Horz_Down);
      end
      else
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Vertical_Down);
      end;
//      vPath := '_Down.png';
    end
    else if Hot then
    begin
      vColor := HandleHotColor;
      if Horz then
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Horz_Hot);
      end
      else
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Vertical_Hot);
      end;
//      vPath := '_Hot.png';
    end
    else
    begin
      vColor := HandleColor;
      if Horz then
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Horz);
      end
      else
      begin
        vIsLoadPng := LoadSourcePng(CONST_Handle_Vertical);
      end;
//      vPath := '.png';
    end;

    if Horz then
    begin
      DrawHorzHandle;
    end
    else
    begin
      DrawVerticalHandle
    end;
  end
  else
    inherited;
end;


{ TDisplaySCrollBar }

constructor TDisplaySCrollBar.Create;
begin
  ScrollBarHandleGrip := true;

  ScrollWidth := 11;
  ScrollHeight := 11;
end;

procedure TDisplaySCrollBar.UpdateSkin(AContext: IAppContext);
//  function GetColorFromConfig(AKey: WideString): TColor;
//  begin
//    Result := TColor(HexToIntDef(AGilAppController.Config(ctSkin, AKey), 0));
//  end;
begin
//  if Assigned(AGilAppController) then
//  with AGilAppController do
  begin
//    ScrollBarColor := AContext GetColorFromConfig('Control_ScrollBar_ScrollBarColor');
//    ScrollBarButtonColor := GetColorFromConfig('Control_ScrollBar_ScrollBarButtonColor');
//    ScrollBarHandleColor := GetColorFromConfig('Control_ScrollBar_ScrollBarHandleColor');
//    ScrollBarHandleHotColor := GetColorFromConfig('Control_ScrollBar_ScrollBarHandleHotColor');
//    ScrollBarHandleDownColor := GetColorFromConfig('Control_ScrollBar_ScrollBarHandleDownColor');
//    ScrollBarBorderColor := GetColorFromConfig('Control_ScrollBar_ScrollBarBorderColor');
//    ScrollBarHighLightColor := GetColorFromConfig('Control_ScrollBar_ScrollBarHighLightColor');
//    ScrollBarShadowColor := GetColorFromConfig('Control_ScrollBar_ScrollBarShadowColor');
//    ScrollBarArrowColor := GetColorFromConfig('Control_ScrollBar_ScrollBarArrowColor');
  end;
end;

end.

