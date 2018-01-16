unit G32GaugeBar;

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
  Graphics,
  AppContext;

const

  HANDLE_HORZ = 'Controls_ScrollBar_Horz';
  HANDLE_HORZ_DOWN = 'Controls_ScrollBar_Horz_Down';
  HANDLE_HORZ_HOT = 'Controls_ScrollBar_Horz_Hot';
  HANDLE_VERT = 'Controls_ScrollBar_Vertical';
  HANDLE_VERT_DOWN = 'Controls_ScrollBar_Vertical_Down';
  HANDLE_VERT_HOT = 'Controls_ScrollBar_Vertical_Hot';

type

  // G32GaugeBar
  TG32GaugeBar = class(TGaugeBar)
  protected
    // BackColor
    FBackColor: TColor;
    // BorderColor
    FBorderColor: TColor;
    // HandleColor
    FHandleColor: TColor;
    // HandleHotColor
    FHandleHotColor: TColor;
    // HandleDownColor
    FHandleDownColor: TColor;
    // ScrollSize
    FScrollSize: Integer;
    // BorderValue
    FBorderValue: Integer;
    // ResourceInstance
    FResourceInstance: HInst;
    // ResourceWidth
    FResourceWidth: Integer;
    // ResourceHeight
    FResourceHeight: Integer;
    // AppContext
    FAppContext: IAppContext;
    // ResourceImage
    FResourceImage: TPngImage;
    // ResourceImageHot
    FResourceImageHot: TPngImage;
    // ResourceImageDown
    FResourceImageDown: TPngImage;

    // Paint
    procedure Paint; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // DrawHandle
    procedure DoDrawHandle(R: TRect; Horz: Boolean; Pushed, Hot: Boolean); override;
    // DrawTrack
    procedure DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean); override;
  public
    // Constructor
    constructor Create(AOwner: TComponent; AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // GetClientRect
    function GetClientRect: TRect; override;
    // RefreshBar
    procedure RefreshBar;
    // UpdateSkinStyle
    procedure UpdateSkinStyle;

    property ScrollSize: Integer read FScrollSize;
    property BackColor: TColor read FBackColor write FBackColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
//    property HandleColor: TColor read FHandleColor write FHandleColor;
    property HandleHotColor: TColor read FHandleHotColor write FHandleHotColor;
    property HandleDownColor: TColor read FHandleDownColor write FHandleDownColor;
  end;

implementation

{ TG32GaugeBar }

constructor TG32GaugeBar.Create(AOwner: TComponent; AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited Create(AOwner);
  DoubleBuffered := True;
  ShowArrows := False;
  Ctl3D := False;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  Style := rbsMac;

  FScrollSize := 11;
  FResourceInstance := 0;
  FBorderValue := 15;

  FResourceImage := TPngImage.Create;
  FResourceImageHot := TPngImage.Create;
  FResourceImageDown := TPngImage.Create;
end;

destructor TG32GaugeBar.Destroy;
begin
  FResourceImageDown.Free;
  FResourceImageHot.Free;
  FResourceImage.Free;
  inherited;
  FAppContext := nil;
end;

function TG32GaugeBar.GetClientRect: TRect;
begin
  Result.Left := 1;
  Result.Top := 1;
  Result.Right := Width - 1;
  Result.Bottom := Height - 1;

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

procedure TG32GaugeBar.RefreshBar;
var
  LWidth, LHeight: SHORT;
begin
  LWidth := 0;
  LHeight := 0;

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
    FResourceWidth := 6;
    FResourceHeight := 9;
  end else begin
    Width := FScrollSize + LWidth;
    FResourceWidth := 9;
    FResourceHeight := 6;
  end;
end;

procedure TG32GaugeBar.UpdateSkinStyle;
begin
  DoUpdateSkinStyle;
end;

procedure TG32GaugeBar.Paint;
const
  CPrevDirs: array[Boolean] of TRBDirection = (drUp, drLeft);
  CNextDirs: array[Boolean] of TRBDirection = (drDown, drRight);
var
  LButtonSize: Integer;
  LClientRect, LHandleRect: TRect;
  LShowEnabled, LShowHandle, LHorz: Boolean;
begin
  LClientRect := ClientRect;
  Canvas.Brush.Color := FBackColor;
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

procedure TG32GaugeBar.DoUpdateSkinStyle;
var
  LInstance: HINST;
  LPngImage: TPngImage;
begin
  LInstance := FAppContext.GetResourceSkin.GetInstance;

  if (LInstance <> FResourceInstance)
    and (LInstance <> 0) then begin
    if Kind = sbHorizontal then begin
      FResourceImage.LoadFromResourceName(LInstance, HANDLE_HORZ);
      FResourceImageHot.LoadFromResourceName(LInstance, HANDLE_HORZ_HOT);
      FResourceImageDown.LoadFromResourceName(LInstance, HANDLE_HORZ_DOWN);
    end else begin
      FResourceImage.LoadFromResourceName(LInstance, HANDLE_VERT);
      FResourceImageHot.LoadFromResourceName(LInstance, HANDLE_VERT_HOT);
      FResourceImageDown.LoadFromResourceName(LInstance, HANDLE_VERT_DOWN);
    end;
    FResourceInstance := LInstance;
  end;
  FBackColor := RGB(33, 33, 33);
  FHandleColor := RGB(64, 64, 64);
  FHandleHotColor := RGB(56, 56, 56);
  FHandleDownColor := RGB(51, 51, 51);
end;

procedure TG32GaugeBar.DoDrawTrack(R: TRect; Direction: TRBDirection; Pushed, Enabled, Hot: Boolean);
begin
  if Style = rbsMac then begin
    Canvas.Brush.Color := FBackColor;
    Canvas.FillRect(R);
  end else begin
    inherited;
  end;
end;

procedure TG32GaugeBar.DoDrawHandle(R: TRect; Horz, Pushed, Hot: Boolean);
var
  LHandleColor: TColor;
  LRect, LImageRect: TRect;

  procedure DrawHorzHandle(AImage: TPngImage);
  begin
    if AImage = nil then Exit;

    // Left Round
    LImageRect.Left := R.Left;
    LImageRect.Top := R.Top + (R.Height - FResourceHeight) div 2;
    LImageRect.Height := FResourceHeight;
    LImageRect.Width := FResourceWidth;
    Canvas.Draw(LImageRect.Left, LImageRect.Top, FResourceImage);

    // Right Round
    GR32.OffsetRect(LImageRect, R.Width - FResourceWidth, 0);
    Canvas.Draw(LImageRect.Left, LImageRect.Top, FResourceImage);

    // Draw Handle Rectangle
    LRect := R;
    LRect.Left := R.Left + FResourceWidth div 2;
    LRect.Right := R.Right - FResourceWidth div 2;

    Canvas.Brush.Color := LHandleColor;
    Canvas.FillRect(LRect);
  end;

  procedure DrawVertHandle(AImage: TPngImage);
  begin
    if AImage = nil then Exit;

    // Up Round
    LImageRect.Left := R.Left;
    LImageRect.Top := R.Top;
    LImageRect.Height := FResourceHeight div 2;
    LImageRect.Width := FResourceWidth;
    Canvas.Draw(LImageRect.Left, LImageRect.Top, AImage);

    // Down Round
    GR32.OffsetRect(LImageRect, 0, R.Height - LImageRect.Height);
    Canvas.Draw(LImageRect.Left, LImageRect.Top, AImage);

    // Draw Handle Rectangle
    LRect := R;
    LRect.Top := R.Top + FResourceHeight div 2;
    LRect.Height := R.Height - FResourceHeight div 2;

    Canvas.Brush.Color := LHandleColor;
    Canvas.FillRect(LRect);
  end;

begin
  if Style = rbsMac then begin
    if Pushed then begin
      LHandleColor := HandleDownColor;
      if Horz then begin
        DrawHorzHandle(FResourceImageDown);
      end else begin
        DrawVertHandle(FResourceImageDown);
      end;
    end else if Hot then begin
      LHandleColor := HandleHotColor;
      if Horz then begin
        DrawHorzHandle(FResourceImageHot);
      end else begin
        DrawVertHandle(FResourceImageHot);
      end;
    end else begin
      LHandleColor := FHandleColor;
      if Horz then begin
        DrawHorzHandle(FResourceImage);
      end else begin
        DrawVertHandle(FResourceImage);
      end;
    end;
  end else begin
    inherited;
  end;
end;

end.

