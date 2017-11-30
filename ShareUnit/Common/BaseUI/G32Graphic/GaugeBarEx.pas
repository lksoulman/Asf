unit GaugeBarEx;

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Controls,
  StdCtrls,
  ExtCtrls,
  Vcl.Imaging.pngimage,
  GR32,
  GR32_RangeBars,
  Math,
  Types,
  Forms,
  Graphics;

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


  // Gauge Bar
  TGaugeBarEx = class(TGaugeBar)
  protected
    // Back Color
    FBackColor: TColor;
    // Border Color
    FBorderColor: TColor;
    // Handle Color
    FHandleColor: TColor;
    // Handle Hot Color
    FHandleHotColor: TColor;
    // Handle Down Color
    FHandleDownColor: TColor;
    // Scroll Size
    FScrollSize: Integer;
    // Border Value
    FBorderValue: Integer;
    // Resource Instance
    FResourceInstance: HInst;
    // Resource Width
    FResourceWidth: Integer;
    // Resource Height
    FResourceHeight: Integer;
    // Resource Image
    FResourceImage: TPngImage;
    // Resource Image Hot
    FResourceImageHot: TPngImage;
    // Resource Image Down
    FResourceImageDown: TPngImage;

    // Paint
    procedure Paint; override;
    // Draw Handle
    procedure DoDrawHandle(R: TRect; Horz: Boolean; Pushed, Hot: Boolean); override;
    // Draw Track
    procedure DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean); override;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;
    // Get Client Rect
    function GetClientRect: TRect; override;
    // Refresh Bar
    procedure RefreshBar;
    // Refresh Resource
    procedure RefreshResource;

    property ResourceInstance: HInst read FResourceInstance write FResourceInstance;
    property BackColor: TColor read FBackColor write FBackColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
//    property HandleColor: TColor read FHandleColor write FHandleColor;
    property HandleHotColor: TColor read FHandleHotColor write FHandleHotColor;
    property HandleDownColor: TColor read FHandleDownColor write FHandleDownColor;
  end;

implementation

{ TGaugeBarEx }

constructor TGaugeBarEx.Create(AOwner: TComponent);
begin
  inherited;
  Ctl3D := False;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  DoubleBuffered := True;

  Style := rbsMac;
  ShowArrows := False;

  FScrollSize := 11;
  FResourceInstance := 0;
//  FResourceImage := TPngImage.Create;
  RefreshResource;
end;

destructor TGaugeBarEx.Destroy;
begin
//  FResourceImage.Free;
  inherited;
end;

function TGaugeBarEx.GetClientRect: TRect;
begin
  Result.Inflate(-1, -1);

  if (FBorderValue and 1) > 0 then begin
    Result.Top := Result.Top + 1;
  end;

  if (FBorderValue and 4) > 0 then begin
    Result.Bottom := Result.Bottom - 1;
  end;

  if (FBorderValue and 2) > 0 then begin
    Result.Right := Result.Right - 1;
  end;

  if (FBorderValue and 8) > 0 then begin
    Result.Left := Result.Left + 1;
  end;
end;

procedure TGaugeBarEx.RefreshBar;
var
  LWidth, LHeight: SHORT;
begin
  LWidth := 2;
  LHeight := 2;

  if (FBorderValue and 1) > 0 then begin
    Inc(LHeight);
  end;

  if (FBorderValue and 4) > 0 then begin
    Inc(LHeight);
  end;

  if (FBorderValue and 2) > 0 then begin
    Inc(LWidth);
  end;

  if (FBorderValue and 8) > 0 then begin
    Inc(LWidth);
  end;

  if Kind = sbHorizontal then begin
    Height := FScrollSize + LHeight;
  end else begin
    Width := FScrollSize + LWidth;
  end;
end;

procedure TGaugeBarEx.RefreshResource;
begin
  if FResourceInstance = 0 then Exit;

  FBackColor := RGB(33, 33, 33);
  FHandleColor := RGB(64, 64, 64);
  FHandleHotColor := RGB(56, 56, 56);
  FHandleDownColor := RGB(51, 51, 51);
end;

procedure TGaugeBarEx.Paint;
const
  CPrevDirs: array[Boolean] of TRBDirection = (drUp, drLeft);
  CNextDirs: array[Boolean] of TRBDirection = (drDown, drRight);
var
  LButtonSize: Integer;
  LClientRect, LHandleRect: TRect;
  LShowEnabled, LShowHandle, LHorz: Boolean;
begin
  LClientRect := ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(0, 0, Width, Height));

  LHorz := Kind = sbHorizontal;
  LButtonSize := GetButtonSize;
  if LHorz then begin
    GR32.InflateRect(LClientRect, -LButtonSize, 0)
  end else begin
    GR32.InflateRect(LClientRect, 0, -LButtonSize);
  end;

  LShowEnabled := DrawEnabled;
  DoDrawTrack(GetZoneRect(zTrackPrev), CPrevDirs[LHorz], DragZone = zTrackPrev, LShowEnabled, HotZone = zTrackPrev);
  DoDrawTrack(GetZoneRect(zTrackNext), CNextDirs[LHorz], DragZone = zTrackNext, LShowEnabled, HotZone = zTrackNext);

  if LShowEnabled then begin
    LHandleRect := GetHandleRect;
  end else begin
    LHandleRect := Rect(0, 0, 0, 0);
  end;
  LShowHandle := not GR32.IsRectEmpty(LHandleRect);
  if LShowHandle then begin
    DoDrawHandle(LHandleRect, LHorz, DragZone = zHandle, HotZone = zHandle);
  end;

  if FBorderValue > 0 then begin
    Canvas.Pen.Color := BorderColor;

    if (FBorderValue and 1) > 0 then begin
      Canvas.MoveTo(0, 0);
      Canvas.LineTo(Width - 1, 0);
    end;

    if (FBorderValue and 4) > 0 then begin
      Canvas.MoveTo(Width - 1, 0);
      Canvas.LineTo(Width - 1, Height - 1);
    end;

    if (FBorderValue and 2) > 0 then begin
      Canvas.MoveTo(0, Height - 1);
      Canvas.LineTo(Width - 1, Height - 1);
    end;

    if (FBorderValue and 8) > 0 then begin
      Canvas.MoveTo(0, 0);
      Canvas.LineTo(0, Height - 1);
    end;
  end;
end;

procedure TGaugeBarEx.DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean);
begin
  if Style = rbsMac then begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(R);
  end else begin
    inherited;
  end;
end;

procedure TGaugeBarEx.DoDrawHandle(R: TRect; Horz, Pushed, Hot: Boolean);
var
  LHandleColor: TColor;
  LRect, LImageRect: TRect;

  procedure DrawHorzHandle(AImage: TPngImage);
  begin
    LRect := R;

    // Left Round
    LImageRect.Left := R.Left;
    LImageRect.Top := R.Top + (R.Height - FResourceHeight) div 2;
    LImageRect.Height := FResourceHeight;
    LImageRect.Width := FResourceWidth div 2;
    LRect := LImageRect;
    Canvas.Draw(LImageRect.Left, LImageRect.Top, FResourceImage);

    // Right Round
    GR32.OffsetRect(LImageRect, R.Width - FResourceWidth, 0);
    Canvas.Draw(LImageRect.Left, LImageRect.Top, FResourceImage);

    // Draw Handle Rectangle
    LRect.Left := R.Left + FResourceWidth div 2;
    LRect.Width := R.Width - FResourceWidth;
    Canvas.Brush.Color := LHandleColor;
    Canvas.FillRect(LRect);
  end;

  procedure DrawVerticalHandle(AImage: TPngImage);
  begin
    LRect := R;
    // Up Round
    LImageRect.Left := R.Left + (R.Width - FResourceWidth) div 2;
    LImageRect.Top := R.Top;
    LImageRect.Height := FResourceHeight;
    LImageRect.Width := FResourceWidth;

    LRect := LImageRect;
    Canvas.Draw(LImageRect.Left, LImageRect.Top, AImage);

    // Down Round
    GR32.OffsetRect(LImageRect, 0, R.Height - LImageRect.Height);
    Canvas.Draw(LImageRect.Left, LImageRect.Top, AImage);

    // Draw Handle Rectangle

    LRect.Top := R.Top + AImage.Height div 2;
    LRect.Height := R.Height - FResourceHeight;

    Canvas.Brush.Color := LHandleColor;
    Canvas.FillRect(LRect);
  end;

begin
  if Style = rbsMac then begin
    if Pushed then begin
      LHandleColor := HandleDownColor;
      if Horz then begin
//        DrawHorzHandle(FResourceImageDown);
      end else begin
//        DrawVerticalHandle(FResourceImageDown);
      end;
    end else if Hot then begin
      LHandleColor := HandleHotColor;
      if Horz then begin
//        DrawHorzHandle(FResourceImageHot);
      end else begin
//        DrawVerticalHandle(FResourceImageHot);
      end;
    end else begin
      LHandleColor := HandleColor;
      if Horz then begin
//        DrawHorzHandle(FResourceImage);
      end else begin
//        DrawVerticalHandle(FResourceImage);
      end;
    end;
  end else begin
    inherited;
  end;
end;

end.

