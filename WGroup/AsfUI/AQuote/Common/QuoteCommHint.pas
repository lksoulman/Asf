unit QuoteCommHint;

interface

uses
  Windows,
  Classes,
  Messages,
  Graphics,
  Controls,
  Types,
  Forms,
  StdCtrls,
  ExtCtrls,
  Vcl.Themes;

type

  THintControl = class(TComponent)
  private
    FHint: string;
    HintWindow: THintWindow;
    HintTimer: TTimer;
    FComponent: TControl;
    FIsAutoHide: Boolean;
    FMaxWidth: Integer;
  protected
    procedure DoHideHint(Sender: TObject); virtual;
    procedure SetIsAutoHide(ABool: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IsAutoHide: Boolean read FIsAutoHide write SetIsAutoHide;
    property Hint: string read FHint write FHint;
    property Component: TControl read FComponent write FComponent;
    procedure ShowHint(AHint: string); overload; virtual;
    procedure ShowHint(AHint: string; AComponent: TControl); overload; virtual;
    procedure ShowHint(AHint: string; X, Y: Integer); overload; virtual;
    procedure HideHint; virtual;

    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
  end;

  THintWindowEx = class(THintWindow)
  protected
    FIsCustomDraw: Boolean;
    FHintFont: TFont;
    FHintColor: TColor;

    procedure NCPaint(DC: HDC); override;
    procedure Paint; override;
    procedure SetHintFont(AFont: TFont); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property  IsCustomDraw: Boolean read FIsCustomDraw write FIsCustomDraw;
    property  HintFont: TFont read FHintFont write SetHintFont;
    property  HintColor: TColor read FHintColor write FHintColor;
  end;
//******************************************************************************

  //可以自己设置背景色，字体颜色，边框线颜色的提示框
  THintControlEx = class(THintControl)
  protected
    FIsCustomDraw: Boolean;
    FHeight: Integer;

    procedure SetCustomDraw(AValue: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeforeInit; virtual;
    procedure ShowHint(AHint: string; X, Y: Integer); overload; override;
    procedure UpdateSkin(AHintFont: TFont; AHintColor: TColor); overload; virtual;

    property HintWin: THintWindow read HintWindow write HintWindow;
    property  IsCustomDraw: Boolean read FIsCustomDraw write SetCustomDraw;
    property  Height: Integer read FHeight write FHeight;
  end;
//******************************************************************************
implementation

{ THintControl }

procedure THintControl.ShowHint(AHint: string);
begin
  ShowHint(AHint, FComponent);
end;

procedure THintControl.ShowHint(AHint: string; AComponent: TControl);
var
  vPoint: TPoint;
begin
  if AHint <> '' then
  begin
    if not Windows.IsWindowVisible(HintWindow.Handle) or
      (HintWindow.Caption <> AHint) then
    begin
      vPoint := AComponent.ClientToScreen(AComponent.ClientRect.BottomRight);
      ShowHint(AHint, vPoint.X, vPoint.Y);
    end;
  end
  else
    ShowWindow(HintWindow.Handle, SW_HIDE);
end;

procedure THintControl.SetIsAutoHide(ABool: Boolean);
begin
  FIsAutoHide := ABool;

  if Assigned(HintTimer) then
  begin
    HintTimer.Enabled := ABool;
  end
  else if ABool then
  begin
    HintTimer := TTimer.Create(nil);
    HintTimer.OnTimer := DoHideHint;
    HintTimer.Interval := Application.HintHidePause;
  end;
end;

procedure THintControl.ShowHint(AHint: string; X, Y: Integer);
var
  vRect: TRect;
begin
  if AHint <> '' then
  begin
    if not Windows.IsWindowVisible(HintWindow.Handle) or
      (HintWindow.Caption <> AHint) then
    begin
      vRect := HintWindow.CalcHintRect(FMaxWidth, AHint, nil);
      Inc(vRect.Left, X);
      Inc(vRect.Right, X);
      Inc(vRect.Top, Y);
      Inc(vRect.Bottom, Y);
      HintWindow.ActivateHint(vRect, AHint);
      if FIsAutoHide then
        HintTimer.Enabled := true;
    end;
  end
  else
    ShowWindow(HintWindow.Handle, SW_HIDE);
end;

constructor THintControl.Create(AOwner: TComponent);
begin
  inherited;
  HintWindow := HintWindowClass.Create(nil);
  HintWindow.Color := Application.HintColor;
  IsAutoHide := False;
  FMaxWidth := 400;
end;

destructor THintControl.Destroy;
begin
  // sleep(HintTimer.Interval);
  HintTimer.Free;
  HintWindow.Free;
  inherited;
end;

procedure THintControl.HideHint;
begin
  ShowWindow(HintWindow.Handle, SW_HIDE);
end;

procedure THintControl.DoHideHint(Sender: TObject);
begin
  TTimer(Sender).Enabled := False;
  HideHint;
end;
//******************************************************************************

constructor THintWindowEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsCustomDraw := False;
  FHintColor := RGB(51, 51, 51);
  FHintFont := TFont.Create;
end;

destructor THintWindowEx.Destroy;
begin
  if(Assigned(FHintFont))then
    FHintFont.Free;
  inherited Destroy;
end;

procedure THintWindowEx.NCPaint(DC: HDC);
var
  FrameBrush: HBRUSH;
begin
  if not(FIsCustomDraw)then
  begin
    inherited NCPaint(DC);
  end
  else
  begin
    FrameBrush := CreateSolidBrush(ColorToRGB(FHintColor));
    FrameRect(DC, Rect(0, 0, Width, Height), FrameBrush);
    DeleteObject(FrameBrush);
  end;
end;

procedure THintWindowEx.Paint;
var
  R: TRect;
begin
  if not(FIsCustomDraw)then
  begin
    inherited Paint;
  end
  else
  begin
    R := ClientRect;
    Canvas.Brush.Color := FHintColor;
    Canvas.Pen.Color := FHintColor;
    Canvas.FillRect(Rect(0, 0, Width, Height));

    Inc(R.Left, 2);
//    Inc(R.Top, 2);
    if (Assigned(FHintFont)) then
    begin
      Canvas.Font.Color := FHintFont.Color;
      Canvas.Font.Height := FHintFont.Height;
    end
    else
      Canvas.Font.Color := Screen.HintFont.Color;
    DrawText(Canvas.Handle, Caption, -1, R, DT_LEFT or DT_NOPREFIX or DT_WORDBREAK or DrawTextBiDiModeFlagsReadingOnly);
  end;
end;

procedure THintWindowEx.SetHintFont(AFont: TFont);
begin
  if(Assigned(AFont))then
  begin
    FHintFont.Assign(AFont);
    Canvas.Font.Color := AFont.Color;
    Canvas.Font.Height := AFont.Height;
  end
  else
    Canvas.Font.Color := Screen.HintFont.Color;
end;
//******************************************************************************

constructor THintControlEx.Create(AOwner: TComponent);
begin
  BeforeInit;
  inherited Create(AOwner);
  FIsCustomDraw := False;
  FHeight := 0;
end;

procedure THintControlEx.BeforeInit;
begin
  HintWindowClass := THintWindowEx;
end;

procedure THintControlEx.ShowHint(AHint: string; X, Y: Integer);
var
  vRect: TRect;
begin
  if AHint <> '' then
  begin
    if not Windows.IsWindowVisible(HintWindow.Handle) or
      (HintWindow.Caption <> AHint) then
    begin
      vRect := HintWindow.CalcHintRect(FMaxWidth, AHint, nil);
      if(FHeight > 0)then
        vRect.Bottom := vRect.Top + FHeight;
      Inc(vRect.Left, X);
      Inc(vRect.Right, X);
      Inc(vRect.Top, Y);
      Inc(vRect.Bottom, Y);
      HintWindow.ActivateHint(vRect, AHint);
      if FIsAutoHide then
        HintTimer.Enabled := true;
    end;
  end
  else
    ShowWindow(HintWindow.Handle, SW_HIDE);
end;

procedure THintControlEx.UpdateSkin(AHintFont: TFont; AHintColor: TColor);
var
  AHintWindow: THintWindowEx;
begin
  if(Assigned(HintWindow))then
  begin
    AHintWindow := THintWindowEx(HintWindow);
    AHintWindow.HintFont := AHintFont;
    AHintWindow.HintColor := AHintColor;
    AHintWindow.Invalidate;
  end;
end;

procedure THintControlEx.SetCustomDraw(AValue: Boolean);
var
  AHintWindow: THintWindowEx;
begin
  if(AValue <> FIsCustomDraw)then
  begin
    FIsCustomDraw := AValue;
    if(Assigned(HintWindow))then
    begin
      AHintWindow := THintWindowEx(HintWindow);
      AHintWindow.IsCustomDraw := AValue;
      AHintWindow.Invalidate;
    end;
  end;
end;

end.
