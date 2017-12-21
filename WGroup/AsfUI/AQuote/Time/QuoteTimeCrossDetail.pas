unit QuoteTimeCrossDetail;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Graphics,
  Messages,
  Forms,
  GR32,
  G32Graphic,
  QuoteCommLibrary,
  QuoteTimeStruct,
  QuoteTimeGraph,
  QuoteTimeData;

type

  TQuoteTimeCrossDetail = class(TForm)
  private
    FTimeGraphs: TQuoteTimeGraphs;
    FDetailBitmap: TBitmap32;
    FDetailG32Graphic: TG32Graphic;
    FDataIndex: Integer;
    FColIndex: Integer;
    FTextHeight: Integer;
    FIsSetPenetrate: Boolean;
    FCaptions: array [0 .. 5] of TDetailDataKey;

    procedure CalcWH;
    procedure InitCaptions;
    procedure SetPenetrate;
    procedure ResetPos(const _Pt: TPoint);
    procedure SetToPos(const _Pt: TPoint);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure Paint; override;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure Initialize(_TimeGraphs: TQuoteTimeGraphs);

    procedure UpdateShowPos;
    procedure DoDetail(_DataIndex, _ColIndex: Integer; _Pt: TPoint);
    procedure UpdateSkin;
    procedure ResetFormat;
  end;

implementation

{ TQuoteTimeCrossDetail }

constructor TQuoteTimeCrossDetail.CreateNew(AOwner: TComponent;
  Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner, Dummy);
  AlphaBlend := True;
  AlphaBlendValue := 230;

  Visible := False;
  Ctl3D := False;
  AutoScroll := False;
  BorderStyle := bsNone;
  BorderWidth := 0;
  BorderIcons := [];
  DoubleBuffered := True;

  FDetailBitmap := TBitmap32.Create;
  FDetailBitmap.SetSize(1, 1);
  FDetailG32Graphic := TG32Graphic.Create(nil, FDetailBitmap, Self.Canvas);
end;

destructor TQuoteTimeCrossDetail.Destroy;
begin
  if Assigned(FDetailG32Graphic) then
    FreeAndNil(FDetailG32Graphic);
  if Assigned(FDetailBitmap) then
    FreeAndNil(FDetailBitmap);
  inherited;
end;

procedure TQuoteTimeCrossDetail.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := WS_POPUP;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;

    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);

    WndParent := Application.ActiveFormHandle;
    if (WndParent <> 0) and
      (IsIconic(WndParent) or not IsWindowVisible(WndParent) or
      not IsWindowEnabled(WndParent)) then
      WndParent := 0;
    if WndParent = 0 then
      WndParent := Application.Handle;
  end;
end;

procedure TQuoteTimeCrossDetail.Paint;
var
  tmpRect: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FDetailBitmap <> nil) then
  begin
    Canvas.Lock;
    try
      tmpRect := Rect(0, 0, Width, Height);
      DrawCopyRect(Canvas.Handle, tmpRect, FDetailBitmap.Handle, tmpRect);
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TQuoteTimeCrossDetail.InitCaptions;
begin
  with FTimeGraphs do
  begin
    FCaptions[0].m_lCaption := '时   间';
    FCaptions[0].m_lDataKey := dkDate;
    FCaptions[0].m_lFormat := Display.HourMinuteFormat;

    FCaptions[1].m_lCaption := '均   价';
    FCaptions[1].m_lDataKey := dkAveragePrice;
    FCaptions[1].m_lFormat := Display.PriceFormat;

    FCaptions[2].m_lCaption := '价   位';
    FCaptions[2].m_lDataKey := dkPrice;
    FCaptions[2].m_lFormat := Display.PriceFormat;

    FCaptions[3].m_lCaption := '涨   跌';
    FCaptions[3].m_lDataKey := dkHighsLows;
    FCaptions[3].m_lFormat := Display.HightLowsFormatFloat;

    FCaptions[4].m_lCaption := '涨   幅';
    FCaptions[4].m_lDataKey := dkHighsLowsRange;
    FCaptions[4].m_lFormat := Display.HighsLowsRangeFormatFloat;

    FCaptions[5].m_lCaption := '成交量';
    FCaptions[5].m_lDataKey := dkVolume;
    FCaptions[5].m_lFormat := Display.LowWanFormat;

    // FCaptions[6].m_lCaption := '成交额';
    // FCaptions[6].m_lDataKey := dkMoney;
    // FCaptions[6].m_lFormat := Display.LowWanFormat;
  end;
end;

procedure TQuoteTimeCrossDetail.CalcWH;
var
  tmpCharWidth: Integer;
begin
  with FTimeGraphs do
  begin
    FDetailG32Graphic.UpdateFont(Display.TextFont);
    FDetailG32Graphic.GraphicReset;
    FTextHeight := FDetailG32Graphic.TextHeight('A');
    tmpCharWidth := FDetailG32Graphic.TextWidth('A');
    Width := Display.CrossDetailCharCount * tmpCharWidth;
    Color := Display.CrossDetailBackColor;
  end;
  Height := Length(FCaptions) * FTextHeight + 5;
  FDetailBitmap.SetSize(Width, Height);
end;

procedure TQuoteTimeCrossDetail.Initialize(_TimeGraphs: TQuoteTimeGraphs);
begin
  FTimeGraphs := _TimeGraphs;
  FDataIndex := 0;
  FColIndex := 0;
  FIsSetPenetrate := False;
  InitCaptions;
  CalcWH;
end;

procedure TQuoteTimeCrossDetail.DoDetail(_DataIndex, _ColIndex: Integer;
  _Pt: TPoint);
Const
  Const_Lead_Index_Name = '领   先';
var
  tmpRect: TRect;
  tmpValue: Double;
  tmpData: TTimeData;
  tmpText, tmpCaption: string;
  tmpIndex, tmpCompareValue: Integer;
  function FormatUnit(_Value: Double): string;
  begin
    with FTimeGraphs do
    begin
      if _Value > 100000000 then
        Result := Format(Display.HighYiFormat, [_Value / 100000000])
      else if _Value > 10000 then
        Result := Format(Display.HighWanFormat, [_Value / 10000])
      else
        Result := Format(Display.LowWanVolumeFormat, [_Value]);
    end;
  end;

begin
  ResetPos(_Pt);
  with FTimeGraphs do
  begin
    FDataIndex := _DataIndex;
    FColIndex := _ColIndex;
    tmpRect := Rect(0, 0, Width, Height);
    tmpData := QuoteTimeData.DataIndexToData(FDataIndex);
    if Assigned(tmpData) then
    begin
      FDetailG32Graphic.EmptyPolyText('Detail.Caption');
      FDetailG32Graphic.EmptyPolyPoly('Detail.DrawFrameLine');

      FDetailG32Graphic.BackColor := Display.CrossDetailBackColor;
      FDetailG32Graphic.FillRect(tmpRect);
      FDetailG32Graphic.Clear;

      tmpRect.Top := 3;
      tmpRect.Left := 5;
      tmpRect.Right := tmpRect.Right - 5;

      for tmpIndex := Low(FCaptions) to High(FCaptions) do
      begin
        tmpRect.Bottom := tmpRect.Top + FTextHeight;
        if (tmpIndex = 1) and ((tmpData.InnerCode = Const_InnerCode_Index_SH) or
          (tmpData.InnerCode = Const_InnerCode_Index_SZ)) then
          tmpCaption := Const_Lead_Index_Name
        else
          tmpCaption := FCaptions[tmpIndex].m_lCaption;
        FDetailG32Graphic.AddPolyText('Detail.Caption', tmpRect,
          tmpCaption, gtaLeft);

        FDetailG32Graphic.EmptyPolyText('Detail.Value');

        tmpData.GetValue(FCaptions[tmpIndex].m_lDataKey, FColIndex, tmpValue,
          tmpCompareValue);
        case tmpIndex of
          1:
            begin
              if tmpData.IsStop or (FColIndex < 0) or
                ((tmpData.StockType = stIndex) and tmpData.IsHisData) then
                tmpText := '--'
              else
                tmpText := Format(FCaptions[tmpIndex].m_lFormat, [tmpValue]);
            end;
          2:
            begin
              tmpText := Format(FCaptions[tmpIndex].m_lFormat, [tmpValue]);
            end;
          3, 4:
            tmpText := FormatFloat(FCaptions[tmpIndex].m_lFormat, tmpValue);
          0:
            tmpText := FormatDateTime(FCaptions[tmpIndex].m_lFormat, tmpValue);
          5, 6:
            tmpText := FormatUnit(tmpValue);
        end;
        FDetailG32Graphic.AddPolyText('Detail.Value', tmpRect, tmpText,
          gtaRight);
        if tmpIndex = 0 then
        begin
          FDetailG32Graphic.LineColor := Display.CrossDetailDateTimeColor;
        end
        else if tmpIndex = 5 then
        begin
          FDetailG32Graphic.LineColor := Display.VolumeColors[tmpCompareValue];
        end
        else
          FDetailG32Graphic.LineColor := Display.DownEqualUpColors
            [tmpCompareValue];

        FDetailG32Graphic.DrawPolyText('Detail.Value');

        tmpRect.Top := tmpRect.Bottom;
      end;

      FDetailG32Graphic.AddPolyPoly('Detail.DrawFrameLine',
        Rect(0, 0, Width - 1, Height - 1));

      FDetailG32Graphic.LineColor := Display.CrossDetailTextColor;
      FDetailG32Graphic.DrawPolyText('Detail.Caption');
      FDetailG32Graphic.LineColor := Display.CrossDetailFrameLineColor;
      FDetailG32Graphic.DrawPolyPolyLine('Detail.DrawFrameLine');
    end;
    Invalidate;
  end;
end;

procedure TQuoteTimeCrossDetail.SetPenetrate;
var
  tmpExStyle: DWORD;
begin
  tmpExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
  tmpExStyle := tmpExStyle or WS_EX_TRANSPARENT or WS_EX_LAYERED;
  SetWindowLong(Handle, GWL_EXSTYLE, tmpExStyle);
end;

procedure TQuoteTimeCrossDetail.ResetFormat;
begin
  with FTimeGraphs do
  begin
    FCaptions[0].m_lFormat := Display.HourMinuteFormat;
    FCaptions[1].m_lFormat := Display.PriceFormat;
    FCaptions[2].m_lFormat := Display.PriceFormat;
    FCaptions[3].m_lFormat := Display.HightLowsFormatFloat;
    FCaptions[4].m_lFormat := Display.HighsLowsRangeFormatFloat;
    FCaptions[5].m_lFormat := Display.LowWanFormat;
  end;
end;

procedure TQuoteTimeCrossDetail.ResetPos(const _Pt: TPoint);
var
  tmpNewPoint: TPoint;
begin
  with FTimeGraphs do
  begin
    if CenterRect.Width > Self.Width then
    begin
      tmpNewPoint := GR32.Point(-1, -1);
      if (_Pt.X > CenterRect.Left) and
        (_Pt.X < CenterRect.Left + Self.Width + 30) then
        tmpNewPoint := GR32.Point(CenterRect.Right - Self.Width, CenterRect.Top)
      else if (_Pt.X > CenterRect.Right - Self.Width - 30) and
        (_Pt.X < CenterRect.Right) then
        tmpNewPoint := CenterRect.TopLeft;
      tmpNewPoint.Y := tmpNewPoint.Y + 1;
      if (tmpNewPoint.X <> -1) and (tmpNewPoint.Y <> -1) then
        SetToPos(tmpNewPoint);
    end;
  end;
end;

procedure TQuoteTimeCrossDetail.SetToPos(const _Pt: TPoint);
var
  tmpPoint: TPoint;
begin
  with FTimeGraphs do
  begin
    tmpPoint := G32Graphic.Control.ClientToScreen(_Pt);
    Top := tmpPoint.Y + FTimeGraphs.TextHeight + 1;
    Left := tmpPoint.X;
  end;
end;

procedure TQuoteTimeCrossDetail.UpdateShowPos;
begin
  if not FIsSetPenetrate then
  begin
    FIsSetPenetrate := True;
    SetPenetrate; // 鼠标穿透
  end;
  SetToPos(FTimeGraphs.CenterRect.TopLeft);
  ShowWindow(Self.Handle, SW_SHOWNOACTIVATE);
end;

procedure TQuoteTimeCrossDetail.UpdateSkin;
begin
  CalcWH;
end;

procedure TQuoteTimeCrossDetail.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_ACTIVATE:
      begin
        Message.Result := MA_NOACTIVATE;
      end;
    WM_SETFOCUS:
      begin
        Windows.SetFocus(FTimeGraphs.G32Graphic.Control.Handle);
      end;
  else
    inherited WndProc(Message);
  end;
end;

end.
