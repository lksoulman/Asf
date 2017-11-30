unit G32Graphic;

interface

uses windows, Classes, SysUtils, Vcl.Controls, Graphics, Generics.Collections, System.Math,
  GR32, GR32_Image, GR32_Polygons, GR32_Blend, GR32_lines, GR32_Misc, GR32_Backends, GR32_Text;

const
  MaxListCount = 1000000;

type

  TTextAlign = (gtaTopLeft, gtaTop, gtaTopRight, gtaLeft, gtaCenter, gtaRight, gtaBottomLeft, gtaBottom,
    gtaBottomRight);

  TGilFillMode = (gpfAlternate, gpfWinding);
  TGilAntialiasMode = (gam32times, gam16times, gam8times, gam4times, gam2times, gamNone);

  PPointList = ^TPointList;
  TPointList = array [0 .. MaxListCount] of TPoint;

  PTypeList = ^TTypeList;
  TTypeList = array [0 .. MaxListCount] of DWord;

  TTextRec = record
    R: TRect;
    Text: string[255];
    Align: TTextAlign;
  end;

  PTextList = ^TTextList;
  TTextList = array [0 .. MaxListCount] of TTextRec;

  // *** 由若干个点绘制的一条线 ***
  TPolyLine = class
  private
    FPoints: PPointList;
    FCapacity: Integer; // 容量
    FCount: Integer; // 个数
    function DeltaCount(value: Integer): Integer;
    procedure Clean; virtual;

    /// <summary>
    /// 确定容量并申请内存
    /// </summary>
    procedure GrowList; virtual;

    /// <summary>
    /// 容量有变化，重新申请内存。value为新容量的值。
    /// </summary>
    procedure GrowListEx(value: Integer);

    procedure AddPoints(Points: PPointList; PCount: Integer); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(X, Y: Integer); overload; virtual;
    procedure Add(P: TPoint); overload; virtual;

    procedure EmptyPoint; virtual;
    function Count: Integer; virtual;
    property Points: PPointList read FPoints;
  end;

  // *** 在TPolyLine的基础上增加类型列表 ***
  TPolyPolyLine = class(TPolyLine)
  private
    FTypeList: PTypeList; // 线的类型
    FTypeCapacity: Integer; // 容量
    FTypeCount: Integer; // 类型个数
    procedure GrowTypeList;
    procedure Clean; override;
    procedure AddType(TypeCount: DWord);
  public
    procedure Add(Rect: TRect); overload;
    procedure AddPoints(Points: PPointList; PCount: Integer); override;
    procedure EmptyPoint; override;
    property TypeList: PTypeList read FTypeList;
    property TypeCount: Integer read FTypeCount;
  end;

  TPolyText = class
  private
    FTexts: PTextList; // 文本内容
    FCapacity: Integer; // 容量
    FCount: Integer; // 个数
    function DeltaCount(value: Integer): Integer;
    procedure Clean; virtual;
    procedure GrowList; virtual;
    procedure GrowListEx(value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(R: TRect; const Text: string; Align: TTextAlign); virtual;
    procedure AddTexts(Texts: PTextList; PCount: Integer); virtual;

    procedure EmptyText; virtual;
    function Count: Integer; virtual;
    property Texts: PTextList read FTexts;
  end;

  TG32Graphic = class
  private
    FLineWidth: Integer;
    FLineColor: TColor;
    FAlpha: Integer;
    FBackColor: TColor;
    // 填充模式  pfAlternate（and ） , pfWinding （or ）
    FFillMode: TGilFillMode;
    // 抗据齿   据齿级别
    FAntialiased: Boolean;
    FAntialiasMode: TGilAntialiasMode;
    FClosed: Boolean;
    FXorColor: Boolean;
    FControl: TCustomControl;
    FBitmap32: TBitmap32;
    FCanvas: TCanvas;
    FPolyItems: TDictionary<String, TPolyLine>;
    FPolyPolyItems: TDictionary<String, TPolyPolyLine>;
    FPolyTextItems: TDictionary<String, TPolyText>;
    // 快速定位
    FPKey: string;
    FPolyLine: TPolyLine;

    FPPKey: string;
    FPolyPolyLine: TPolyPolyLine;

    FPTKey: string;
    FPolyText: TPolyText;
    FEllipsis: Boolean; // 文本长度超出显示区域时，是否显示省略号
    FSingleLine: Boolean; // 文本是否为单行显示

    FClipRgn: HRGN;

    FTransparent: Boolean; // 绘制文字时，是否背景透明
    procedure PolyFreeItem;
    procedure PolyPolyFreeItem;
    procedure PolyTextFreeItem;
    function GetPolyItems(const PKey: string): TPolyLine;
    function GetPolyPolyItems(const PPKey: string): TPolyPolyLine;
    function GetPolyTextItems(const PTKey: string): TPolyText;
    function G32FillMode: TPolyFillMode;
    function G32AntialiasMode: TAntialiasMode;

  public
    constructor Create(Control: TCustomControl; Bitmap32: TBitmap32; Canvas: TCanvas);
    destructor Destroy; override;
    procedure GraphicReset;
    function G32LineColor: TColor32;
    function G32BackColor: TColor32;
    property LineWidth: Integer read FLineWidth write FLineWidth;
    property LineColor: TColor read FLineColor write FLineColor;
    property XorColor: Boolean read FXorColor write FXorColor;
    property Alpha: Integer read FAlpha write FAlpha;
    property BackColor: TColor read FBackColor write FBackColor;
    property FillMode: TGilFillMode read FFillMode write FFillMode;
    property Antialiased: Boolean read FAntialiased write FAntialiased;
    property AntialiasMode: TGilAntialiasMode read FAntialiasMode write FAntialiasMode;
    property Closed: Boolean read FClosed write FClosed;

    property PolyItems[const PKey: string]: TPolyLine read GetPolyItems;
    property PolyTextItems[const PKey: string]: TPolyText read GetPolyTextItems;
    property PolyPolyItems[const PPKey: string]: TPolyPolyLine read GetPolyPolyItems;

    // 文字
    procedure UpdateFont(FontName: TFontName; FontSize: Integer; FontColor: TColor; FontSytle: TFontStyles;
      Charset: TFontCharset = GB2312_CHARSET); overload;
    procedure UpdateFont(Font: TFont); overload;
    function TextHeight(const Text: string): Integer;
    function TextWidth(const Text: string): Integer;
    // Fill
    procedure FillRect(R: TRect);
    procedure Clear;
    // 裁剪区域
    procedure SelectClipRgn(R: TRect);
    procedure DeleteClipRgn;
    // 路径
    procedure BeginPath;
    procedure EndPath;
    procedure FillPath;
    // 多边型  去锯齿  线类型点线，实心
    procedure DrawPolyPolyLine(const PPKey: string);
    procedure DrawPolyPolyDotLine(const PPKey: string);
    procedure DrawPolyPolyFill(const PPKey: string); overload;
    // 带阴影
    procedure DrawPolyPolyShadowFill(const PPKey: string);
    // 画线
    procedure DrawPolyLine(const PKey: string);
    procedure DrawPolyDotLine(const PKey: string);

    procedure DrawPolyFill(const PKey: string);
    procedure DrawPolyShadowFill(const PKey: string);
    procedure DrawPolyGradientFill(const PKey: string; const Colors: array Of TColor; Horz: Boolean);
    // 画边框
    procedure DrawPolyEdge(const PKey: string);

    // 多边型
    procedure AddPolyPoly(const PPKey: string; Rect: TRect); overload;

    procedure AddPolyPoly(const PPKey: string; Points: array of TPoint); overload;
    procedure AddPolyPoly(const PPKey, PolyKey: string); overload; // 把PolyKey对应的点添加到PPKey对应的列表里

    procedure FreePolyPoly(const PPKey: string);
    procedure EmptyPolyPoly(const PPKey: string);

    // 单线
    procedure AddPoly(const PKey: string; P: TPoint); overload;
    procedure AddPoly(const PKey: string; X, Y: Integer); overload;
    procedure AddPoly(const PKey: string; R: TRect); overload;

    procedure EmptyPoly(const PKey: string);
    procedure FreePoly(const PKey: string);
    function CountPoly(const PKey: string): Integer;

    // 文字
    procedure AddPolyText(const PTKey: string; R: TRect; const Text: string; Align: TTextAlign);

    // 画文字
    procedure DrawPolyText(const PTKey: string);

    procedure EmptyPolyText(const PTKey: string);
    procedure FreePolyText(const PTKey: string);
    function CountPolyText(const PTKey: string): Integer;

    property Ellipsis: Boolean read FEllipsis write FEllipsis;
    property SingleLine: Boolean read FSingleLine write FSingleLine;
    property Bitmap32: TBitmap32 read FBitmap32 write FBitmap32;
    property Canvas: TCanvas read FCanvas;
    property Control: TCustomControl read FControl;
    property Transparent: Boolean read FTransparent write FTransparent;
  end;

  // 点到点的距离
function PPDistance(P1, P2: TPoint): Double;
// 点到直线的距离
function PLDistance(P, LP1, LP2: TPoint): Double;

procedure DrawRectangle(DC: HDC; const R: TRect);
function StretchRect(R: TRect; X, Y: Integer): TRect;

procedure DrawCopyRect(DestDC: HDC; const DestR: TRect; SrcDC: HDC; const SrcR: TRect);
procedure DrawTextOut(DC: HDC; R: TRect; const Text: string; Align: TTextAlign; AEllipsis: Boolean = False; ASingleLine: Boolean = True);

function XorBackColor(BColor, Color: TColor): Integer;

implementation

// 点到点的距离
function PPDistance(P1, P2: TPoint): Double;
var
  X, Y: Double;
begin
  X := (P1.X - P2.X) / 5000000;
  Y := (P1.Y - P2.Y) / 5000000;
  Result := (SQRT(SQR(X) + SQR(Y))) * 5000000;

  // result := Sqrt((P1.X - P2.X) * (P1.X - P2.X) + (P1.Y - P2.Y) * (P1.Y - P2.Y));
end;

// 点到直线的距离
function PLDistance(P, LP1, LP2: TPoint): Double;
var
  K, X, Y: Double;
begin
  // 直线方程为y=kx+b;
  // l=abs((y2-y1) x + (x1_x2) y +x2 * y1 - x1 * y2) / sqrt(sqr(y2-y1)+sqr(x1-x2))

  Result := MaxInt;
  if LP1.X = LP2.X then
  begin
    if (P.Y >= Min(LP1.Y, LP2.Y)) and (P.Y <= Max(LP1.Y, LP2.Y)) then
      Result := Abs(LP2.X - P.X)
  end
  else if LP1.Y = LP2.Y then
  begin
    if (P.X >= Min(LP1.X, LP2.X)) and (P.X <= Max(LP1.X, LP2.X)) then
      Result := Abs(LP2.Y - P.Y)
  end
  else
  begin
    if (P.X >= Min(LP1.X, LP2.X)) and (P.X <= Max(LP1.X, LP2.X)) and (P.Y >= Min(LP1.Y, LP2.Y)) and
      (P.Y <= Max(LP1.Y, LP2.Y)) then
    begin
      K := (LP2.Y - LP1.Y) / (LP2.X - LP1.X);
      X := (K * LP1.X + 1 / K * P.X + P.Y - LP1.Y) / (K + 1 / K);
      Y := -1 / K * (X - P.X) + P.Y;
      Result := SQRT(SQR(P.X - X) + SQR(P.Y - Y));
    end;

  end;
end;

function XorBackColor(BColor, Color: TColor): Integer;
begin
  Result := ColorToRGB(BColor) xor ColorToRGB(Color);
end;

procedure DrawCopyRect(DestDC: HDC; const DestR: TRect; SrcDC: HDC; const SrcR: TRect);
begin
  StretchBlt(DestDC, DestR.Left, DestR.Top, DestR.Right - DestR.Left, DestR.Bottom - DestR.Top, SrcDC, SrcR.Left,
    SrcR.Top, SrcR.Right - SrcR.Left, SrcR.Bottom - SrcR.Top, cmSrcCopy);
end;

function StretchRect(R: TRect; X, Y: Integer): TRect;
begin
  with Result do
  begin
    Left := R.Left - X;
    Top := R.Top - Y;
    Right := R.Right + X;
    Bottom := R.Bottom + Y;
  end;
end;

procedure DrawTextOut(DC: HDC; R: TRect; const Text: string; Align: TTextAlign; AEllipsis, ASingleLine: Boolean);
var
  tmpFormat: Cardinal;
begin
  case Align of
    gtaTopLeft:
      tmpFormat := DT_TOP + DT_LEFT;
    gtaTop:
      tmpFormat := DT_TOP + DT_CENTER;
    gtaTopRight:
      tmpFormat := DT_TOP + DT_RIGHT;
    gtaLeft:
      tmpFormat := DT_LEFT + DT_VCENTER;
    gtaCenter:
      tmpFormat := DT_CENTER + DT_VCENTER;
    gtaRight:
      tmpFormat := DT_RIGHT + DT_VCENTER;
    gtaBottomLeft:
      tmpFormat := DT_BOTTOM + DT_LEFT;
    gtaBottom:
      tmpFormat := DT_BOTTOM + DT_CENTER;
    gtaBottomRight:
      tmpFormat := DT_BOTTOM + DT_RIGHT;
  else
    tmpFormat := 0;
  end;
  if ASingleLine then
    tmpFormat := tmpFormat + DT_SINGLELINE
  else
    tmpFormat := tmpFormat + DT_WORDBREAK;
  if AEllipsis then
    tmpFormat := tmpFormat + DT_END_ELLIPSIS;
  DrawText(DC, PChar(Text), Length(Text), R, tmpFormat + DT_NOPREFIX);
end;

procedure DrawRectangle(DC: HDC; const R: TRect);
begin
  Rectangle(DC, R.Left, R.Top, R.Right, R.Bottom);
end;

{ TPolyLine }

procedure TPolyLine.Add(X, Y: Integer);
begin
  if FCount = FCapacity then
    GrowList;
  FPoints^[FCount].X := X { shl 16 };
  FPoints^[FCount].Y := Y { shl 16 };
  Inc(FCount);
end;

procedure TPolyLine.Add(P: TPoint);
begin
  Add(P.X, P.Y);
end;

procedure TPolyLine.AddPoints(Points: PPointList; PCount: Integer);
begin
  if FCapacity - FCount < PCount then
    GrowListEx(FCapacity + PCount);

  Move(Points^[0], FPoints^[FCount], SizeOf(TPoint) * PCount);
  Inc(FCount, PCount);
end;

procedure TPolyLine.Clean;
begin
  if Assigned(FPoints) then
    FreeMem(FPoints, 0);
  FPoints := nil;
  FCapacity := 0;
  FCount := 0;
end;

function TPolyLine.Count: Integer;
begin
  Result := FCount;
end;

constructor TPolyLine.Create;
begin
  Clean;
end;

function TPolyLine.DeltaCount(value: Integer): Integer;
begin
  if value > 64 then
    Result := value + value div 4
  else if value > 8 then
    Result := value + 16
  else
    Result := value + 4;
end;

destructor TPolyLine.Destroy;
begin
  Clean;
  inherited Destroy;
end;

procedure TPolyLine.EmptyPoint;
begin
  FCount := 0;
end;

procedure TPolyLine.GrowList;
begin
  FCapacity := DeltaCount(FCapacity);
  ReallocMem(FPoints, FCapacity * SizeOf(TPoint));
end;

procedure TPolyLine.GrowListEx(value: Integer);
begin
  FCapacity := value;
  ReallocMem(FPoints, FCapacity * SizeOf(TPoint));
end;

{ TPolyPolyLine }

procedure TPolyPolyLine.Add(Rect: TRect);
begin
  inherited Add(Rect.Left, Rect.Top);
  inherited Add(Rect.Right, Rect.Top);
  inherited Add(Rect.Right, Rect.Bottom);
  inherited Add(Rect.Left, Rect.Bottom);
  inherited Add(Rect.Left, Rect.Top);
  AddType(5);
end;

procedure TPolyPolyLine.AddPoints(Points: PPointList; PCount: Integer);
begin
  if PCount > 1 then
  begin
    inherited AddPoints(Points, PCount);
    AddType(PCount);
  end;
end;

procedure TPolyPolyLine.AddType(TypeCount: DWord);
begin
  if TypeCount > 0 then
  begin
    if FTypeCount = FTypeCapacity then
      GrowTypeList;
    FTypeList^[FTypeCount] := TypeCount;
    Inc(FTypeCount);
  end;
end;

procedure TPolyPolyLine.Clean;
begin
  inherited Clean;
  if Assigned(FTypeList) then
    FreeMem(FTypeList, 0);
  FTypeCount := 0; // 个数
  FTypeList := nil;
end;

procedure TPolyPolyLine.EmptyPoint;
begin
  inherited EmptyPoint;
  FTypeCount := 0;
end;

procedure TPolyPolyLine.GrowTypeList;
begin
  FTypeCapacity := DeltaCount(FTypeCapacity);
  ReallocMem(FTypeList, FTypeCapacity * SizeOf(DWord));
end;

{ TPolyText }

procedure TPolyText.Add(R: TRect; const Text: string; Align: TTextAlign);
begin
  if FCount = FCapacity then
    GrowList;

  // OutputDebugString(pchar('TPolyText.Add:' + inttostr(FCount) + 'c: ' + Text ));

  FTexts^[FCount].R := R;

  FTexts^[FCount].Text := ShortString(Text);
  FTexts^[FCount].Align := Align;

  Inc(FCount);
end;

procedure TPolyText.AddTexts(Texts: PTextList; PCount: Integer);
var
  i: Integer;
begin
  if FCapacity - FCount < PCount then
    GrowListEx(FCapacity + PCount);

  // 批量增加
  for i := 0 to PCount - 1 do
    Add(Texts^[i].R, string(Texts^[i].Text), Texts^[i].Align);
end;

procedure TPolyText.Clean;
begin
  if Assigned(FTexts) then
    FreeMem(FTexts, 0);
  FTexts := nil;
  FCapacity := 0;
  FCount := 0;
end;

function TPolyText.Count: Integer;
begin
  Result := FCount;
end;

constructor TPolyText.Create;
begin
  Clean;
end;

function TPolyText.DeltaCount(value: Integer): Integer;
begin
  if value > 64 then
    Result := value + value div 4
  else if value > 8 then
    Result := value + 16
  else
    Result := value + 4;
end;

destructor TPolyText.Destroy;
begin
  Clean;
  inherited Destroy;
end;

procedure TPolyText.EmptyText;
begin
  FCount := 0;
end;

procedure TPolyText.GrowList;
begin
  FCapacity := DeltaCount(FCapacity);
  ReallocMem(FTexts, FCapacity * SizeOf(TTextRec));
end;

procedure TPolyText.GrowListEx(value: Integer);
begin
  FCapacity := value;
  ReallocMem(FTexts, FCapacity * SizeOf(TTextRec));
end;

{ TG32Graphic }

procedure TG32Graphic.BeginPath;
begin

end;

constructor TG32Graphic.Create(Control: TCustomControl; Bitmap32: TBitmap32; Canvas: TCanvas);
begin
  FBitmap32 := Bitmap32;
  FCanvas := Canvas;
  FControl := Control;
  FTransparent := True;
  FEllipsis := False;
  FSingleLine := True;
  FPolyItems := TDictionary<String, TPolyLine>.Create;
  FPolyPolyItems := TDictionary<String, TPolyPolyLine>.Create;
  FPolyTextItems := TDictionary<String, TPolyText>.Create;
  // 初始参数
  GraphicReset;
end;

destructor TG32Graphic.Destroy;
begin

  if FPolyItems <> nil then
  begin
    PolyFreeItem;
    FreeAndNil(FPolyItems);
  end;

  if FPolyPolyItems <> nil then
  begin
    PolyPolyFreeItem;
    FreeAndNil(FPolyPolyItems);
  end;
  if FPolyTextItems <> nil then
  begin
    PolyTextFreeItem;
    FreeAndNil(FPolyTextItems);
  end;

  if FClipRgn <> 0 then
  begin
    windows.DeleteObject(FClipRgn);
    FClipRgn := 0;
  end;
  inherited Destroy;
end;

function TG32Graphic.G32AntialiasMode: TAntialiasMode;
begin
  if FAntialiased then
    Result := TAntialiasMode(FAntialiasMode)
  else
    Result := amNone;
end;

function TG32Graphic.G32BackColor: TColor32;
begin
  if FAlpha = 255 then
    Result := Color32(FBackColor)
  else
    Result := SetAlpha(Color32(FBackColor), FAlpha);
end;

function TG32Graphic.G32FillMode: TPolyFillMode;
begin
  Result := TPolyFillMode(FFillMode);
end;

function TG32Graphic.G32LineColor: TColor32;
begin
  if FAlpha = 255 then
    Result := Color32(FLineColor)
  else
    Result := SetAlpha(Color32(FLineColor), FAlpha);

  if FXorColor then
    Result := Result and $00FFFFFF + $A0000000;
end;

function TG32Graphic.GetPolyItems(const PKey: string): TPolyLine;
begin
  if (PKey = FPKey) and (FPolyLine <> nil) then
    Result := FPolyLine
  else
  begin
    if not FPolyItems.TryGetValue(PKey, Result) then
    begin
      Result := TPolyLine.Create;
      FPolyItems.Add(PKey, Result);
    end;

    FPKey := PKey;
    FPolyLine := Result;
  end;
end;

function TG32Graphic.GetPolyPolyItems(const PPKey: string): TPolyPolyLine;
begin
  if (PPKey = FPPKey) and (FPolyPolyLine <> nil) then
    Result := FPolyPolyLine
  else
  begin
    if not FPolyPolyItems.TryGetValue(PPKey, Result) then
    begin
      Result := TPolyPolyLine.Create;
      FPolyPolyItems.Add(PPKey, Result);
    end;

    FPPKey := PPKey;
    FPolyPolyLine := Result;
  end;
end;

function TG32Graphic.GetPolyTextItems(const PTKey: string): TPolyText;
begin
  if (PTKey = FPTKey) and (FPolyText <> nil) then
    Result := FPolyText
  else if not FPolyTextItems.TryGetValue(PTKey, Result) then
  begin
    Result := TPolyText.Create;
    FPolyTextItems.Add(PTKey, Result);

    FPTKey := PTKey;
    FPolyText := Result;
  end;

  if (PTKey = FPTKey) and (FPolyText <> nil) then
    Result := FPolyText
  else
  begin
    if not FPolyTextItems.TryGetValue(PTKey, Result) then
    begin
      Result := TPolyText.Create;
      FPolyTextItems.Add(PTKey, Result);
    end;

    FPTKey := PTKey;
    FPolyText := Result;
  end;
end;

procedure TG32Graphic.GraphicReset;
begin
  FLineWidth := 1;
  FLineColor := clBlack;
  FAlpha := 255;

  FBackColor := clWhite;
  // 填充模式  pfAlternate（and ） , pfWinding （or ）
  FFillMode := gpfAlternate;
  // 抗据齿   据齿级别
  FAntialiased := False;
  FAntialiasMode := gam4times;
  FClosed := False;

  XorColor := False;
end;

procedure TG32Graphic.AddPoly(const PKey: string; P: TPoint);
begin
  // PolyItems 肯定有值回来
  AddPoly(PKey, P.X, P.Y);
end;

procedure TG32Graphic.AddPoly(const PKey: string; X, Y: Integer);
begin
  // PolyItems 肯定有值回来
  PolyItems[PKey].Add(Fixed(X), Fixed(Y));
end;

procedure TG32Graphic.Clear;
begin
  FBitmap32.Clear(G32BackColor);
end;

function TG32Graphic.CountPoly(const PKey: string): Integer;
begin
  // PolyItems 肯定有值回来
  Result := PolyItems[PKey].Count;
end;

procedure TG32Graphic.EmptyPoly(const PKey: string);
begin
  // PolyItems 肯定有值回来
  PolyItems[PKey].EmptyPoint;
end;

procedure TG32Graphic.FreePoly(const PKey: string);
var
  PolyLine: TPolyLine;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin
    FPolyItems.Remove(PKey);
    PolyLine.Free;
  end;
end;

procedure TG32Graphic.PolyFreeItem;
var
  PolyEnum: TDictionary<string, TPolyLine>.TPairEnumerator;
  CurrPoly: TPolyLine;
begin
  if FPolyItems <> nil then
  begin
    PolyEnum := FPolyItems.GetEnumerator;
    try
      while PolyEnum.MoveNext do
      begin
        CurrPoly := FPolyItems[PolyEnum.Current.Key];
        CurrPoly.Free;
      end;
    finally
      FreeAndNil(PolyEnum);
    end;
    FPolyItems.Clear;
  end;
end;

procedure TG32Graphic.PolyPolyFreeItem;
var
  PolyPolyEnum: TDictionary<string, TPolyPolyLine>.TPairEnumerator;
  CurrPolyPoly: TPolyPolyLine;
begin
  if FPolyPolyItems <> nil then
  begin
    PolyPolyEnum := FPolyPolyItems.GetEnumerator;
    try
      while PolyPolyEnum.MoveNext do
      begin
        CurrPolyPoly := FPolyPolyItems[PolyPolyEnum.Current.Key];
        CurrPolyPoly.Free;
      end;
    finally
      FreeAndNil(PolyPolyEnum);
    end;

    FPolyPolyItems.Clear;
  end;
end;

procedure TG32Graphic.AddPolyText(const PTKey: string; R: TRect; const Text: string; Align: TTextAlign);
begin
  // PolyItems 肯定有值回来
  PolyTextItems[PTKey].Add(R, Text, Align);
end;

function TG32Graphic.CountPolyText(const PTKey: string): Integer;
begin
  // PolyTextItems 肯定有值回来
  Result := PolyTextItems[PTKey].Count;
end;

procedure TG32Graphic.EmptyPolyText(const PTKey: string);
begin
  // PolyTextItems 肯定有值回来
  PolyTextItems[PTKey].EmptyText;
end;

procedure TG32Graphic.FreePolyText(const PTKey: string);
var
  PolyText: TPolyText;
begin
  if FPolyTextItems.TryGetValue(PTKey, PolyText) then
  begin
    FPolyTextItems.Remove(PTKey);
    PolyText.Free;
  end;
end;

procedure TG32Graphic.PolyTextFreeItem;
var
  PolyEnum: TDictionary<string, TPolyText>.TPairEnumerator;
  CurrPoly: TPolyText;
begin
  if FPolyTextItems <> nil then
  begin
    PolyEnum := FPolyTextItems.GetEnumerator;
    try
      while PolyEnum.MoveNext do
      begin
        CurrPoly := FPolyTextItems[PolyEnum.Current.Key];
        CurrPoly.Free;
      end;
    finally
      FreeAndNil(PolyEnum);
    end;
    FPolyTextItems.Clear;
  end;
end;

procedure TG32Graphic.AddPolyPoly(const PPKey: string; Rect: TRect);
begin
  Rect.Left := Fixed(Rect.Left);
  Rect.Top := Fixed(Rect.Top);
  Rect.Right := Fixed(Rect.Right);
  Rect.Bottom := Fixed(Rect.Bottom);

  PolyPolyItems[PPKey].Add(Rect);
end;

procedure TG32Graphic.AddPolyPoly(const PPKey, PolyKey: string);
var
  PolyLine: TPolyLine;
begin
  // 取取polyLine, 如果存在 把 FPoints 加到  PolyPolyLine里
  if FPolyItems.TryGetValue(PolyKey, PolyLine) then
    PolyPolyItems[PPKey].AddPoints(PolyLine.FPoints, PolyLine.Count);
end;

procedure TG32Graphic.AddPolyPoly(const PPKey: string; Points: array of TPoint);
var
  i: Integer;
begin
  // 对数据fixed
  for i := low(Points) to High(Points) do
  begin
    Points[i].X := Fixed(Points[i].X);
    Points[i].Y := Fixed(Points[i].Y);
  end;

  PolyPolyItems[PPKey].AddPoints(@Points[0], Length(Points));
end;

procedure TG32Graphic.EmptyPolyPoly(const PPKey: string);
begin
  PolyPolyItems[PPKey].EmptyPoint;
end;

procedure TG32Graphic.FreePolyPoly(const PPKey: string);
var
  PolyPolyLine: TPolyPolyLine;
begin
  if FPolyPolyItems.TryGetValue(PPKey, PolyPolyLine) then
  begin
    FPolyPolyItems.Remove(PPKey);
    PolyPolyLine.Free;
  end;
end;

procedure TG32Graphic.DrawPolyDotLine(const PKey: string);
var
  i: Integer;
  Line32: TLine32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
  BColor, LColor: TColor32;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin

    if FLineWidth = 1 then
    begin

      BColor := G32BackColor;
      LColor := G32LineColor;

      FBitmap32.StippleStep := 1;

      FBitmap32.SetStipple([BColor, LColor, BColor]);
      if PolyLine.Count > 1 then
      begin
        FBitmap32.MoveToX(PolyLine.FPoints^[0].X, PolyLine.FPoints^[0].Y);
        for i := 1 to PolyLine.Count - 1 do
          FBitmap32.LineToXSP(PolyLine.FPoints^[i].X, PolyLine.FPoints^[i].Y);
      end;
    end
    else
    begin
      Line32 := TLine32.Create;
      try
        FixedPoint := @PolyLine.FPoints^[0];
        Line32.AddPoints(FixedPoint^, PolyLine.Count);
        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Line32.FillMode := G32FillMode;
        // 抗据齿   据齿级别
        Line32.AntialiasMode := G32AntialiasMode;
        FBitmap32.StippleStep := 1;
        BColor := G32BackColor;
        LColor := G32LineColor;
        Line32.Draw(FBitmap32, LineWidth, [BColor, LColor, BColor]);
      finally
        Line32.Free;
      end;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyEdge(const PKey: string);
var
  Polygon32, OutLines, TmpLines: TPolygon32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
  C32: TColor32;
begin
  // SimpleFill 参考
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin

    Polygon32 := TPolygon32.Create;
    try
      FixedPoint := @PolyLine.FPoints^[0];
      Polygon32.AddPoints(FixedPoint^, PolyLine.Count);
      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;
      C32 := G32LineColor;
      if FLineWidth = 1 then
      begin
        Polygon32.DrawEdge(FBitmap32, C32);
      end
      else
      begin
        TmpLines := Polygon32.Outline;
        try
          OutLines := TmpLines.Grow(Fixed(FLineWidth * 0.5), 0.5);
          try
            // 填充模式  pfAlternate（and ） , pfWinding （or ）
            OutLines.FillMode := G32FillMode;
            // 抗据齿   据齿级别
            OutLines.Antialiased := FAntialiased;
            OutLines.AntialiasMode := G32AntialiasMode;
            OutLines.Closed := FClosed;
            C32 := G32LineColor;
            OutLines.DrawFill(FBitmap32, C32);
          finally
            OutLines.Free;
          end;
        finally
          TmpLines.Free;
        end;
      end;
    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyFill(const PKey: string);
var
  Polygon32: TPolygon32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
  C32: TColor32;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin
    Polygon32 := TPolygon32.Create;
    try
      FixedPoint := @PolyLine.FPoints^[0];
      Polygon32.AddPoints(FixedPoint^, PolyLine.Count);

      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;
      C32 := G32BackColor;

      Polygon32.Draw(FBitmap32, C32, C32);
    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyGradientFill(const PKey: string; const Colors: array Of TColor; Horz: Boolean);
var
  i: Integer;
  Polygon32: TPolygon32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
  Colors32: array Of TColor32;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin
    Polygon32 := TPolygon32.Create;
    try
      FixedPoint := @PolyLine.FPoints^[0];
      Polygon32.AddPoints(FixedPoint^, PolyLine.Count);

      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;

      Setlength(Colors32, Length(Colors));
      for i := Low(Colors) to High(Colors) do
        if FAlpha = 255 then
          Colors32[i] := Color32(Colors[i])
        else
          Colors32[i] := SetAlpha(Color32(Colors[i]), FAlpha);

      // 渐变填充
      if Horz then
        SimpleGradientFill(FBitmap32, Polygon32.Points, 0, Colors32, 180)
      else
        SimpleGradientFill(FBitmap32, Polygon32.Points, 0, Colors32, 90);

      // SimpleRadialFill(FBitmap32, Polygon32.Points, Colors32);
    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyLine(const PKey: string);
var
  Polygon32: TPolygon32;
  Line32: TLine32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin
    if FLineWidth = 1 then
    begin
      Polygon32 := TPolygon32.Create;
      try
        FixedPoint := @PolyLine.FPoints^[0];
        Polygon32.AddPoints(FixedPoint^, PolyLine.Count);

        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Polygon32.FillMode := G32FillMode;

        // 抗据齿   据齿级别
        Polygon32.Antialiased := FAntialiased;
        Polygon32.AntialiasMode := G32AntialiasMode;
        Polygon32.Closed := FClosed;

        Polygon32.Draw(FBitmap32, G32LineColor, 0);
      finally
        Polygon32.Free;
      end;
    end
    else
    begin
      Line32 := TLine32.Create;
      try
        FixedPoint := @PolyLine.FPoints^[0];
        Line32.AddPoints(FixedPoint^, PolyLine.Count);

        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Line32.FillMode := G32FillMode;

        // 抗据齿   据齿级别
        Line32.AntialiasMode := G32AntialiasMode;
        Line32.LineWidth := LineWidth;

        Line32.Draw(FBitmap32, LineWidth, G32LineColor);
      finally
        Line32.Free;
      end;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyShadowFill(const PKey: string);
var
  Polygon32: TPolygon32;
  PolyLine: TPolyLine;
  FixedPoint: ^TFixedPoint;
  C32: TColor32;
begin
  if FPolyItems.TryGetValue(PKey, PolyLine) then
  begin
    Polygon32 := TPolygon32.Create;
    try
      FixedPoint := @PolyLine.FPoints^[0];
      Polygon32.AddPoints(FixedPoint^, PolyLine.Count);

      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;
      C32 := G32LineColor;

      SimpleShadow(FBitmap32, Polygon32.Points, 1, 1, 1, C32);

      // SimpleFill(FBitmap32, Polygon32.Points,  clred32, clred32);

      // 斑马线
      // SimpleStippleFill(FBitmap32,   Polygon32.Points[0], [$EEFFFF00,$2033FFFF], 1, 0);

      // 渐变填充
      // SimpleGradientFill(FBitmap32, Polygon32.Points, clRed32, [SetAlpha(clBlack32, 235), SetAlpha(clred32, 235)], 190);

      // 射线渐变   Fill
      // SimpleRadialFill(FBitmap32, Polygon32.Points, [$EEFFFF00,$2033FFFF]);

    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyText(const PTKey: string);
var
  i: Integer;
  PolyText: TPolyText;
  pTextRec: ^TTextRec;
begin
  if FPolyTextItems.TryGetValue(PTKey, PolyText) then
  begin
    if FBitmap32.Canvas.HandleAllocated then // 选择字体
      SelectObject(FBitmap32.Canvas.Handle, FBitmap32.Font.Handle);

    if FTransparent then
      SetBkMode(FBitmap32.Handle, windows.Transparent) // 背景透明
    else
      SetBkColor(FBitmap32.Handle, FBackColor); // 设置背景色

    SetTextColor(FBitmap32.Handle, FLineColor);

    for i := 0 to PolyText.Count - 1 do // 一个一个画
    begin
      pTextRec := @PolyText.Texts^[i];
      DrawTextOut(FBitmap32.Handle, pTextRec^.R, String(pTextRec^.Text), pTextRec^.Align, FEllipsis, FSingleLine);
    end;
  end;
end;

procedure TG32Graphic.DrawPolyPolyDotLine(const PPKey: string);
var
  i, v, c, index: Integer;
  Line32: TLine32;
  PolyPolyLine: TPolyPolyLine;
  FixedPoint: ^TFixedPoint;
  BColor, LColor: TColor32;
begin
  if FPolyPolyItems.TryGetValue(PPKey, PolyPolyLine) then
  begin

    if FLineWidth = 1 then
    begin

      BColor := G32BackColor;
      LColor := G32LineColor;

      FBitmap32.StippleStep := 1;
      FBitmap32.SetStipple([BColor, LColor, BColor]);

      index := 0;
      for i := 0 to PolyPolyLine.TypeCount - 1 do
      begin
        c := PolyPolyLine.TypeList^[i];

        if c > 1 then
        begin
          FBitmap32.MoveToX(PolyPolyLine.Points^[index].X, PolyPolyLine.Points^[index].Y);
          for v := 1 to c - 1 do
            FBitmap32.LineToXSP(PolyPolyLine.Points^[index + v].X, PolyPolyLine.Points^[index + v].Y);
        end;
        Inc(index, c);
      end;

    end
    else
    begin
      Line32 := TLine32.Create;
      try

        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Line32.FillMode := G32FillMode;

        // 抗据齿   据齿级别
        Line32.AntialiasMode := G32AntialiasMode;
        FBitmap32.StippleStep := 1;
        BColor := G32BackColor;
        LColor := G32LineColor;

        index := 0;
        for i := 0 to PolyPolyLine.TypeCount - 1 do
        begin
          Line32.Clear;

          c := PolyPolyLine.TypeList^[i];
          FixedPoint := @PolyPolyLine.Points^[index];
          Line32.AddPoints(FixedPoint^, c);

          Line32.Draw(FBitmap32, LineWidth, [BColor, LColor, BColor]);

          Inc(index, c);
        end;
      finally
        Line32.Free;
      end;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyPolyFill(const PPKey: string);
var
  i, c, index: Integer;
  Polygon32: TPolygon32;
  PolyPolyLine: TPolyPolyLine;
  FixedPoint: ^TFixedPoint;
  BColor: TColor32;
begin
  if FPolyPolyItems.TryGetValue(PPKey, PolyPolyLine) then
  begin

    Polygon32 := TPolygon32.Create;
    try
      index := 0;
      for i := 0 to PolyPolyLine.TypeCount - 1 do
      begin
        c := PolyPolyLine.TypeList^[i];
        FixedPoint := @PolyPolyLine.Points^[index];
        Polygon32.AddPoints(FixedPoint^, c);
        Polygon32.NewLine;
        Inc(index, c);
      end;

      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;

      BColor := G32BackColor;

      Polygon32.Draw(FBitmap32, 0, BColor);
    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyPolyLine(const PPKey: string);
var
  i, c, index: Integer;
  Polygon32: TPolygon32;
  Line32: TLine32;
  PolyPolyLine: TPolyPolyLine;
  FixedPoint: ^TFixedPoint;
begin
  if FPolyPolyItems.TryGetValue(PPKey, PolyPolyLine) then
  begin
    if FLineWidth = 1 then
    begin
      Polygon32 := TPolygon32.Create;
      try
        index := 0;
        for i := 0 to PolyPolyLine.TypeCount - 1 do
        begin
          c := PolyPolyLine.TypeList^[i];
          FixedPoint := @PolyPolyLine.Points^[index];
          Polygon32.AddPoints(FixedPoint^, c);
          Polygon32.NewLine;

          Inc(index, c);
        end;

        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Polygon32.FillMode := G32FillMode;

        // 抗据齿   据齿级别
        Polygon32.Antialiased := FAntialiased;
        Polygon32.AntialiasMode := G32AntialiasMode;
        Polygon32.Closed := FClosed;

        Polygon32.Draw(FBitmap32, G32LineColor, 0);
      finally
        Polygon32.Free;
      end;
    end
    else
    begin
      Line32 := TLine32.Create;
      try
        // 填充模式  pfAlternate（and ） , pfWinding （or ）
        Line32.FillMode := G32FillMode;
        // 抗据齿   据齿级别
        // Line32.AntialiasMode := G32AntialiasMode;

        index := 0;
        for i := 0 to PolyPolyLine.TypeCount - 1 do
        begin
          Line32.Clear;

          c := PolyPolyLine.TypeList^[i];
          FixedPoint := @PolyPolyLine.Points^[index];
          Line32.AddPoints(FixedPoint^, c);

          Line32.Draw(FBitmap32, LineWidth, G32LineColor);

          Inc(index, c);
        end;
      finally
        Line32.Free;
      end;
    end;
  end;
end;

procedure TG32Graphic.DrawPolyPolyShadowFill(const PPKey: string);
var
  i, c, index: Integer;
  Polygon32: TPolygon32;
  PolyPolyLine: TPolyPolyLine;
  FixedPoint: ^TFixedPoint;
begin
  if FPolyPolyItems.TryGetValue(PPKey, PolyPolyLine) then
  begin
    Polygon32 := TPolygon32.Create;
    try
      index := 0;
      for i := 0 to PolyPolyLine.TypeCount - 1 do
      begin
        c := PolyPolyLine.TypeList^[i];
        FixedPoint := @PolyPolyLine.Points^[index];
        Polygon32.AddPoints(FixedPoint^, c);
        Polygon32.NewLine;

        Inc(index, c);
      end;

      // 填充模式  pfAlternate（and ） , pfWinding （or ）
      Polygon32.FillMode := G32FillMode;

      // 抗据齿   据齿级别
      Polygon32.Antialiased := FAntialiased;
      Polygon32.AntialiasMode := G32AntialiasMode;
      Polygon32.Closed := FClosed;

      // SimpleShadow
      SimpleShadow(FBitmap32, Polygon32.Points, 2, 2, 2, G32LineColor);
    finally
      Polygon32.Free;
    end;
  end;
end;

procedure TG32Graphic.DeleteClipRgn;
begin
  if FClipRgn <> 0 then
  begin
    windows.DeleteObject(FClipRgn);
    FClipRgn := 0;
  end;
  FBitmap32.ResetClipRect;
  windows.SelectClipRgn(FBitmap32.Handle, 0);
end;

procedure TG32Graphic.SelectClipRgn(R: TRect);
begin
  // FFixedClipRect

  if FClipRgn <> 0 then
  begin
    windows.DeleteObject(FClipRgn);
  end;
  FClipRgn := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
  windows.SelectClipRgn(FBitmap32.Handle, FClipRgn);
  FBitmap32.ClipRect := R;
end;

function TG32Graphic.TextHeight(const Text: string): Integer;
begin
  Result := FBitmap32.TextHeight(Text);
end;

function TG32Graphic.TextWidth(const Text: string): Integer;
begin
  Result := FBitmap32.TextWidth(Text);
end;

procedure TG32Graphic.UpdateFont(Font: TFont);
begin
  FBitmap32.Font.Assign(Font);

  FBitmap32.UpdateFont;
end;

procedure TG32Graphic.UpdateFont(FontName: TFontName; FontSize: Integer; FontColor: TColor; FontSytle: TFontStyles;
  Charset: TFontCharset = GB2312_CHARSET);
var
  Font: TFont;
begin
  Font := FBitmap32.Font;

  Font.Name := FontName;
  Font.Size := FontSize;
  Font.Color := FontColor;
  Font.Style := FontSytle;
  Font.Charset := Charset;

  FBitmap32.UpdateFont;
end;

procedure TG32Graphic.EndPath;
begin
end;

procedure TG32Graphic.FillPath;
begin
end;

procedure TG32Graphic.FillRect(R: TRect);
begin
  FBitmap32.FillRectTS(R, G32BackColor);
end;

procedure TG32Graphic.AddPoly(const PKey: string; R: TRect);
begin
  AddPoly(PKey, R.Left, R.Top);
  AddPoly(PKey, R.Right, R.Top);
  AddPoly(PKey, R.Right, R.Bottom);
  AddPoly(PKey, R.Left, R.Bottom);
  AddPoly(PKey, R.Left, R.Top);
end;

end.
