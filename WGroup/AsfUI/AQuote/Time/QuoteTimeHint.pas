unit QuoteTimeHint;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  QuoteCommLibrary,
  GR32,
  G32Graphic,
  QuoteTimeGraph;

type

  TQuoteTimeHint = class
  private
    FTimeGraphs: TQuoteTimeGraphs; // 引用公共对象  不用释放

    FHintBitMap: TBitmap32;
    FHintG32Graphic: TG32Graphic;
    FHintType: TQuoteHintType; // 提示类型
    FDrawHintRect: TRect; // 保存上次画的矩形
    FIsDraw: Boolean;
    FText: string;

    function CalcRect(_Point: TPoint): TRect;
    function EraseRect(_Rect: TRect): Boolean;
    procedure ReDrawHint(_Text: string); overload;
  public
    constructor Create(_TimeGraphs: TQuoteTimeGraphs;
      _HintType: TQuoteHintType);
    destructor Destroy; override;
    procedure UpdateSkin;

    procedure DrawHint(_Point: TPoint; _Text: string; _ReDraw: Boolean);
    procedure ReDrawHint; overload;
    procedure EraseHint;
  end;

implementation

{ TQuoteTimeHint }

constructor TQuoteTimeHint.Create(_TimeGraphs: TQuoteTimeGraphs;
  _HintType: TQuoteHintType);
begin
  FTimeGraphs := _TimeGraphs;
  with FTimeGraphs do
  begin
    FHintBitMap := TBitmap32.Create;
    FHintG32Graphic := TG32Graphic.Create(nil, FHintBitMap, Canvas);
    FHintBitMap.SetSize(CharWidth * Display.YAxisCharCount, TextHeight);
    FHintG32Graphic.GraphicReset;
    FHintG32Graphic.UpdateFont(Display.TextFont);
    FHintType := _HintType;
    FIsDraw := False;
    FText := '00:00';
  end;
end;

destructor TQuoteTimeHint.Destroy;
begin
  if Assigned(FHintG32Graphic) then
    FreeAndNil(FHintG32Graphic);
  if Assigned(FHintBitMap) then
    FreeAndNil(FHintBitMap);
  inherited;
end;

procedure TQuoteTimeHint.DrawHint(_Point: TPoint; _Text: string;
  _ReDraw: Boolean);
var
  tmpRect: TRect;
begin
  tmpRect := CalcRect(_Point);
  if _ReDraw then
    EraseRect(tmpRect);
  FIsDraw := True;
  FDrawHintRect := tmpRect;
  FText := _Text;
  ReDrawHint(_Text);
end;

procedure TQuoteTimeHint.EraseHint;
begin
  if FIsDraw then
    DrawCopyRect(FTimeGraphs.Canvas.Handle, FDrawHintRect,
      FTimeGraphs.MCanvas.Handle, FDrawHintRect);
  FIsDraw := False;
end;

function TQuoteTimeHint.EraseRect(_Rect: TRect): Boolean;
var
  tmpRect: TRect;
begin
  Result := False;
  case FHintType of
    htRulerX:
      begin
        if _Rect.Left <> FDrawHintRect.Left then
        begin
          Result := True;
          tmpRect := FDrawHintRect;
        end;
      end;
    htRulerYL, htRulerYR:
      begin
        if _Rect.Top <> FDrawHintRect.Top then
        begin
          Result := True;
          tmpRect := FDrawHintRect;
        end;
      end;
  end;
  if Result then
    DrawCopyRect(FTimeGraphs.Canvas.Handle, tmpRect,
      FTimeGraphs.MCanvas.Handle, tmpRect);
end;

procedure TQuoteTimeHint.ReDrawHint;
begin
  if FIsDraw then
    ReDrawHint(FText);
end;

procedure TQuoteTimeHint.ReDrawHint(_Text: string);
var
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    tmpRect := Rect(0, 0, FDrawHintRect.Width, FDrawHintRect.Height);
    FHintG32Graphic.EmptyPolyText('DrawHint');
    FHintG32Graphic.EmptyPolyPoly('DrawHintFrameLine');
    FHintG32Graphic.BackColor := FTimeGraphs.Display.CrossXYRulerHintBackColor;
    FHintG32Graphic.FillRect(tmpRect);

    FHintG32Graphic.AddPolyText('DrawHint', tmpRect, _Text, gtaCenter);
    FHintG32Graphic.AddPolyPoly('DrawHintFrameLine',
      Rect(0, 0, tmpRect.Right - 1, tmpRect.Bottom - 1));

    FHintG32Graphic.GraphicReset;
    FHintG32Graphic.UpdateFont(Display.TextFont);
    FHintG32Graphic.LineColor := FTimeGraphs.Display.CrossXYRulerHintTextColor;
    FHintG32Graphic.DrawPolyText('DrawHint');
    FHintG32Graphic.LineColor :=
      FTimeGraphs.Display.CrossXYRulerHintFrameLineColor;
    FHintG32Graphic.DrawPolyPolyLine('DrawHintFrameLine');
    DrawCopyRect(FTimeGraphs.Canvas.Handle, FDrawHintRect,
      FHintBitMap.Handle, tmpRect);
  end;
end;

procedure TQuoteTimeHint.UpdateSkin;
begin
  with FTimeGraphs do
  begin
    FHintBitMap.SetSize(CharWidth * Display.YAxisCharCount, TextHeight);
  end;
end;

function TQuoteTimeHint.CalcRect(_Point: TPoint): TRect;
begin
  with FTimeGraphs do
  begin
    case FHintType of
      htRulerX:
        begin
          Result := XRulerRect;
          if (Result.Right - _Point.X) > YRulerWidth then
            Result.Left := _Point.X
          else
            Result.Left := Result.Right - YRulerWidth;
          Result.Right := Result.Left + YRulerWidth;
        end;
      htRulerYL, htRulerYR:
        begin
          if FHintType = htRulerYL then
            Result := YLRulerRect
          else
            Result := YRRulerRect;
          if (Result.Bottom - _Point.Y) > TextHeight then
            Result.Top := _Point.Y
          else
            Result.Top := Result.Bottom - TextHeight;
          Result.Bottom := Result.Top + TextHeight;
        end;
    end;
  end;
end;

end.
