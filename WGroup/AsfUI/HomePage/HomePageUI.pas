unit HomePageUI;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Vcl.Forms,
  RenderDC,
  RenderUtil,
  AppContext,
  CustomBaseUI;

type

  // HomePageUI
  THomePageUI = class(TCustomBaseUI)
  private
  protected
    // Infos
    FInfos: string;
    // InfoRect
    FInfoRect: TRect;
    // ClientRect
    FClientRect: TRect;
    // CRenderDC
    FCRenderDC: TRenderDC;

    // BeforeCreate
    procedure DoBeforeCreate; override;
    // CreateNCBarUI
    procedure DoCreateNCBarUI; override;
    // DestroyNCBarUI
    procedure DoDestroyNCBarUI; override;

    // CalcNC
    procedure DoCalcNC; override;
    // DoCalcInfo
    procedure DoCalcInfo(ADC: HDC);

    // DrawC
    procedure DoDrawC;
    // DrawCBK
    procedure DoDrawCBK;
    // PaintC
    procedure DoPaintC(Sender: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ShowInfo
    procedure ShowInfo(AInfo: string);
  end;

implementation

const
  INFO_WIDTH  = 300;
  INFO_HEIGHT = 60;

{ THomePageUI }

constructor THomePageUI.Create(AContext: IAppContext);
begin
  inherited;
  OnPaint := DoPaintC;
end;

destructor THomePageUI.Destroy;
begin
  FInfos := '';
  inherited;
end;

procedure THomePageUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderWidth := 0;
  FCaptionHeight := 0;
  FBorderStyleEx := bsNone;
end;

procedure THomePageUI.DoCalcNC;
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

      LTempRect := LNoBorderRect;
      if FCaptionHeight > 0 then begin
        LTempRect.Top := LNoBorderRect.Top + FCaptionHeight;
      end;
      FClientRect := LTempRect;
      OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
      DoCalcInfo(LDC);

    finally
      ReleaseDC(Handle, LDC);
    end;
    if (FCaptionHeight > 0)
      or (FBorderWidth > 0) then begin
      SendMessage(Handle, WM_NCPAINT, 0, 0);
    end;
  end;
end;

procedure THomePageUI.DoCalcInfo(ADC: HDC);
var
  LRect: TRect;
begin
  LRect := FClientRect;
  OffsetRect(LRect, -LRect.Left, -LRect.Top);

  if not FCRenderDC.IsInit then begin
    FCRenderDC.SetDC(ADC);
  end;
  FCRenderDC.SetBounds(ADC, LRect);

  if LRect.Height > INFO_HEIGHT then begin
    FInfoRect.Top := (LRect.Top + LRect.Bottom - INFO_HEIGHT) div 2;
    FInfoRect.Bottom := FInfoRect.Top + INFO_HEIGHT;
  end else begin
    FInfoRect.Top := LRect.Top;
    FInfoRect.Bottom := LRect.Bottom;
  end;

  if LRect.Width > INFO_WIDTH then begin
    FInfoRect.Left := (LRect.Left + LRect.Right - INFO_WIDTH) div 2;
    FInfoRect.Right := FInfoRect.Left + INFO_WIDTH;
  end else begin
    FInfoRect.Left := LRect.Left;
    FInfoRect.Right := LRect.Right;
  end;
  Invalidate;
end;

procedure THomePageUI.DoCreateNCBarUI;
begin
  FCRenderDC := TRenderDC.Create;
end;

procedure THomePageUI.DoDestroyNCBarUI;
begin
  FCRenderDC.Free;
end;

procedure THomePageUI.DoDrawC;
begin
  if (FInfoRect.Left < FInfoRect.Right - 20)
    and (FInfoRect.Top < FInfoRect.Bottom - 20) then begin
    DrawTextX(FCRenderDC.MemDC, FInfoRect, FInfos,
      FAppContext.GetGdiMgr.GetColorRefLoadProcessCaptionText, dtaLeft, False, True);
  end;
end;

procedure THomePageUI.DoDrawCBK;
var
  LRect: TRect;
begin
  LRect := FClientRect;
  OffsetRect(LRect, -LRect.Left, -LRect.Top);
  FillSolidRect(FCRenderDC.MemDC, @LRect, FAppContext.GetGdiMgr.GetColorRefLoadProcessBack);
end;

procedure THomePageUI.DoPaintC(Sender: TObject);
var
  LDC: HDC;
begin
  if FCRenderDC.MemDC = 0 then Exit;
  
  LDC := GetWindowDC(Self.Handle);
  try
    DoDrawCBK;
    DoDrawC;
    FCRenderDC.BitBltX(LDC, FClientRect);
  finally
    ReleaseDC(Self.Handle, LDC);
  end;
end;

procedure THomePageUI.ShowInfo(AInfo: string);
begin
  if FInfos <> AInfo then begin
    FInfos := AInfo;
    Invalidate;
  end;
end;

end.
