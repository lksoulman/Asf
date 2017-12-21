unit QuoteTimeVolume;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  Types,
  Math,
  Generics.Collections,
  G32Graphic,
  QuoteTimeStruct,
  QuoteTimeGraph,
  QuoteTimeData,
  QuoteCommLibrary,
  AppContext;

const

  const_VolumeDelay_Text = '成交量延时15分钟';

type

  TQuoteTimeVolume = class(TQuoteTimeGraph)
  private
    FFormatType: TFormatType;
    FAuctionScaleY: Double;
    FAuctionMaxValue: Double;
    FPillarWidthHalf: Integer; // 离成交量中心线的距离
    FPillarPixel: Double; // 每个成交量柱子的像素

    function FormatUnit(_Value: Double): string;
    function AuctionValueToY(_Value: Double): Integer;

    procedure DrawToolButtons;
  protected
    function GetDrawGraphRect: TRect; override;
    procedure DrawVolume(_Data: TTimeData; _DataKey: TDataKey;
      _StartPos, _Bottom: Integer);
    procedure DrawAuctionVolume(_Data: TTimeData; _DataKey: TDataKey;
      _StartPos, _Bottom: Integer);

    procedure DrawUSStockDelay;
    procedure DrawYRuler; override;

    procedure CalcMaxMin;
    procedure CalcScaleY;
    procedure CalcAuctionScaleY;
    procedure CalcData; override;
    procedure DrawData; override;
    procedure DrawMine; override;
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); reintroduce;
    destructor Destroy; override;

    procedure Draw; override;
    function YToValue(_Y: Double): Double; override;
    function ValueToY(_Value: Double): Integer; override;

    procedure DrawTitle(_DataIndex, _Index: Integer); override;
    function YToYRulerHint(_Y: Integer; var _LHint, _RHint: string)
      : Boolean; override;
    function IndexToRulerHint(_DataIndex, _Index: Integer;
      var _LHint, _RHint: string): Boolean; override;

    procedure DrawTitleFrame; override;
  end;

implementation

{ TQuoteTimeMinute }

procedure TQuoteTimeVolume.CalcData;
begin
  with FTimeGraphs do
  begin
    CalcMaxMin;
    CalcScaleY;
    CalcAuctionScaleY;
    FPillarPixel := MinuteWidth;
    FPillarWidthHalf := Trunc(FPillarPixel / 2 * 0.75);
  end;
end;

procedure TQuoteTimeVolume.CalcMaxMin;
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpIsFirst: Boolean;
begin
  with FTimeGraphs do
  begin
    tmpIsFirst := True;
    FMinValue := 0;
    FMaxValue := 0;
    FAuctionMaxValue := 0;
    for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if tmpIsFirst then
        begin
          FMaxValue := tmpData.MaxVolume;
          tmpIsFirst := False;
        end;
        if FMaxValue < tmpData.MaxVolume then
          FMaxValue := tmpData.MaxVolume;
        if tmpIndex = 0 then
          FAuctionMaxValue := tmpData.MaxAuctionVolume;
      end;
    end;

    if CompareValue(FMaxValue, 0) = 0 then
      FMaxValue := Display.VolumeIncrement;

    if CompareValue(FAuctionMaxValue, 0) = 0 then
      FAuctionMaxValue := Display.VolumeIncrement;

    if FMaxValue < 10000 then
      FFormatType := ftHand
    else if FMaxValue < 100000000 then
      FFormatType := ftWanHand
    else
      FFormatType := ftYiHand;
  end;
end;

procedure TQuoteTimeVolume.CalcScaleY;
begin
  with FTimeGraphs do
    FScaleY := (FGraphItem.m_lGraphRect.Height - FGraphItem.m_lUpBlank) /
      FMaxValue;
end;

procedure TQuoteTimeVolume.CalcAuctionScaleY;
begin
  with FTimeGraphs do
    FAuctionScaleY := (FGraphItem.m_lGraphRect.Height - FGraphItem.m_lUpBlank) *
      0.5 / FAuctionMaxValue;
end;

constructor TQuoteTimeVolume.Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited Create(AContext);
  FTimeGraphs := _TimeGraphs;
  FFormatType := ftHand;
  FGraphItem.m_lUpBlank := 10;
  FGraphItem.m_lDownBlank := 0;
  FGraphItem.m_lPositon := 2;
end;

destructor TQuoteTimeVolume.Destroy;
begin

  inherited;
end;

procedure TQuoteTimeVolume.Draw;
begin
  CalcData;
  if FTimeGraphs.Display.ShowMode = smNormal then
    DrawUSStockDelay;
  DrawYRuler;
  DrawData;
  if FTimeGraphs.Display.ShowMode = smNormal then
    DrawMine;
end;

procedure TQuoteTimeVolume.DrawTitleFrame;
var
  tmpIsDraw: Boolean;
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    if Display.ShowMode <> smHistoryTime then
      tmpIsDraw := True
    else
      tmpIsDraw := not FTimeGraphs.HisDataIsNull;
    if tmpIsDraw then
    begin
      tmpRect := TitleRect;
      tmpRect.Left := CenterRect.Left;
      tmpRect.Right := CenterRect.Right;
      G32Graphic.EmptyPolyPoly('Volume.DrawTitleFrameLine');

      G32Graphic.AddPolyPoly('Volume.DrawTitleFrameLine',
        [Point(tmpRect.Left, tmpRect.Top), Point(tmpRect.Right, tmpRect.Top)]);
      G32Graphic.AddPolyPoly('Volume.DrawTitleFrameLine',
        [Point(tmpRect.Left, tmpRect.Top + 1), Point(tmpRect.Right,
        tmpRect.Top + 1)]);

      G32Graphic.GraphicReset;
      G32Graphic.LineColor := Display.RegionDivideLineColor;
      G32Graphic.DrawPolyPolyLine('Volume.DrawTitleFrameLine');
    end;
  end;
  DrawToolButtons;
end;

procedure TQuoteTimeVolume.DrawToolButtons;
begin

end;

procedure TQuoteTimeVolume.DrawData;
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpStartPos: Double;
begin
  with FTimeGraphs do
  begin
    // 画集合竞价
    if FGraphItem.m_lCallAuctionWidth > 0 then
    begin;
      tmpData := QuoteTimeData.MainData;
      if tmpData <> nil then
      begin
        DrawAuctionVolume(tmpData, dkAuctionVolume,
          FGraphItem.m_lGraphRect.Left, FGraphItem.m_lGraphRect.Bottom);
      end;
    end;
    tmpStartPos := FGraphItem.m_lGraphRect.Left +
      FGraphItem.m_lCallAuctionWidth + 1;
    for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
      if tmpData <> nil then
      begin
        DrawVolume(tmpData, dkVolume, Trunc(tmpStartPos),
          FGraphItem.m_lGraphRect.Bottom);
      end;
      tmpStartPos := tmpStartPos + SingleDayWidth;
    end;
  end;
end;

procedure TQuoteTimeVolume.DrawMine;
begin

end;

procedure TQuoteTimeVolume.DrawTitle(_DataIndex, _Index: Integer);
begin

end;

procedure TQuoteTimeVolume.DrawAuctionVolume(_Data: TTimeData;
  _DataKey: TDataKey; _StartPos, _Bottom: Integer);
const
  const_DrawKeys: array [-1 .. 1] of string = ('Volume.DrawVolumeLine.Down',
    'Volume.DrawVolumeLine.Equal', 'Volume.DrawVolumeLine.Up');
var
  tmpIsDrawLine: Boolean;
  tmpPos, tmpVolume: Double;
  tmpIndex, tmpCompValue, tmpOldCompValue, tmpAuctionCount, tmpX: Integer;
begin
  with FTimeGraphs do
  begin
    tmpOldCompValue := 1;
    tmpIsDrawLine := (FPillarPixel < 3);
    tmpPos := _StartPos + FPillarPixel / 2;
    tmpAuctionCount := _Data.AuctionMinuteCount;

    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
      G32Graphic.EmptyPolyPoly(const_DrawKeys[tmpIndex]);

    for tmpIndex := 0 to _Data.VADataCount - 1 do
    begin
      _Data.GetValue(_DataKey, tmpIndex - tmpAuctionCount, tmpVolume,
        tmpCompValue);

      // 现价和上一分钟现价相同 和 成交量的颜色就和上一分钟的颜色相同
      if tmpCompValue = 0 then
        tmpCompValue := tmpOldCompValue;
      tmpOldCompValue := tmpCompValue;

      tmpX := Trunc(tmpPos);
      if tmpIsDrawLine then
      begin
        G32Graphic.AddPolyPoly(const_DrawKeys[tmpCompValue],
          [Point(tmpX, _Bottom), Point(tmpX, AuctionValueToY(tmpVolume))]);
      end
      else
      begin
        G32Graphic.AddPolyPoly(const_DrawKeys[tmpCompValue],
          Rect(tmpX - FPillarWidthHalf, AuctionValueToY(tmpVolume),
          tmpX + FPillarWidthHalf, _Bottom + 1));
      end;
      tmpPos := tmpPos + FPillarPixel;
    end;

    G32Graphic.GraphicReset;
    G32Graphic.Antialiased := True;
    G32Graphic.Alpha := 160;
    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
    begin
      if tmpIsDrawLine then
      begin
        G32Graphic.LineColor := Display.VolumeColors[tmpIndex];
        G32Graphic.DrawPolyPolyLine(const_DrawKeys[tmpIndex]);
      end
      else
      begin
        G32Graphic.BackColor := Display.VolumeColors[tmpIndex];
        G32Graphic.DrawPolyPolyFill(const_DrawKeys[tmpIndex]);
      end;
    end;
  end;
end;

procedure TQuoteTimeVolume.DrawVolume(_Data: TTimeData; _DataKey: TDataKey;
  _StartPos, _Bottom: Integer);
const
  const_DrawKeys: array [-1 .. 1] of string = ('Volume.DrawVolumeLine.Down',
    'Volume.DrawVolumeLine.Equal', 'Volume.DrawVolumeLine.Up');
var
  tmpIsDrawLine: Boolean;
  tmpPos, tmpVolume: Double;
  tmpIndex, tmpCompValue, tmpOldCompValue, tmpX: Integer;
begin
  with FTimeGraphs do
  begin
    tmpOldCompValue := 1;
    tmpIsDrawLine := (FPillarPixel < 3);
    tmpPos := _StartPos + FPillarPixel / 2;

    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
      G32Graphic.EmptyPolyPoly(const_DrawKeys[tmpIndex]);

    for tmpIndex := 0 to _Data.DataCount - 1 do
    begin
      _Data.GetValue(_DataKey, tmpIndex, tmpVolume, tmpCompValue);
      // 现价和上一分钟现价相同 和 成交量的颜色就和上一分钟的颜色相同
      if tmpCompValue = 0 then
        tmpCompValue := tmpOldCompValue;
      tmpOldCompValue := tmpCompValue;

      tmpX := Trunc(tmpPos);
      if tmpIsDrawLine then
      begin
        G32Graphic.AddPolyPoly(const_DrawKeys[tmpCompValue],
          [Point(tmpX, _Bottom), Point(tmpX, ValueToY(tmpVolume))]);
      end
      else
      begin
        G32Graphic.AddPolyPoly(const_DrawKeys[tmpCompValue],
          Rect(tmpX - FPillarWidthHalf, ValueToY(tmpVolume),
          tmpX + FPillarWidthHalf, _Bottom + 1));
      end;
      tmpPos := tmpPos + FPillarPixel;
    end;

    G32Graphic.GraphicReset;
    G32Graphic.Antialiased := True;
    G32Graphic.Alpha := 160;
    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
    begin
      if tmpIsDrawLine then
      begin
        G32Graphic.LineColor := Display.VolumeColors[tmpIndex];
        G32Graphic.DrawPolyPolyLine(const_DrawKeys[tmpIndex]);
      end
      else
      begin
        G32Graphic.BackColor := Display.VolumeColors[tmpIndex];
        G32Graphic.DrawPolyPolyFill(const_DrawKeys[tmpIndex]);
      end;
    end;
  end;
end;

function TQuoteTimeVolume.FormatUnit(_Value: Double): string;
begin
  with FTimeGraphs do
  begin
    case FFormatType of
      ftHand:
        Result := Format(Display.LowWanVolumeFormat, [_Value]);
      ftWanHand:
        Result := Format(Display.HighWanFormat, [_Value / 10000]);
    else
      Result := Format(Display.HighYiFormat, [_Value / 100000000]);
    end;
  end;
end;

function TQuoteTimeVolume.GetDrawGraphRect: TRect;
begin
  with FTimeGraphs do
  begin
    Result := FGraphItem.m_lGraphRect;
    Result.Top := Result.Top + FGraphItem.m_lUpBlank;
  end;
end;

procedure TQuoteTimeVolume.DrawUSStockDelay;
var
  tmpRect: TRect;
  tmpWidth, tmpHeight: Integer;
begin
  with FTimeGraphs do
  begin
    if QuoteTimeData.IsVolumeDelay and Assigned(QuoteTimeData.MainData) and
      (QuoteTimeData.MainData.MinuteCount > QuoteTimeData.MainData.DataCount)
    then
    begin
      tmpRect := TitleRect;
      tmpRect.Right := DrawGraphRect.Right;
      tmpWidth := G32Graphic.TextWidth(const_VolumeDelay_Text);
      tmpHeight := G32Graphic.TextHeight(const_VolumeDelay_Text);
      tmpRect.Left := tmpRect.Right - tmpWidth;
      tmpRect.Bottom := tmpRect.Top + tmpHeight;
      G32Graphic.EmptyPolyText('Volume.DelayText');
      G32Graphic.AddPolyText('Volume.DelayText', tmpRect,
        const_VolumeDelay_Text, gtaRight);

      G32Graphic.LineColor := Display.InfoMineIconColor;
      G32Graphic.DrawPolyText('Volume.DelayText');
    end;
  end;
end;

procedure TQuoteTimeVolume.DrawYRuler;
var
  tmpLineCount, tmpIndex, tmpRulerLeft, tmpRulerRight: Integer;
  tmpUnitHeight, tmpY: Double;
  tmpValue: string;
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    tmpRect := DrawGraphRect;
    tmpRulerLeft := tmpRect.Left - Display.YRulerSpace;
    tmpRulerRight := tmpRect.Right + Display.YRulerSpace;
    tmpLineCount := LineCount[tmpRect.Height];
    tmpUnitHeight := tmpRect.Height / tmpLineCount;
    tmpY := FGraphItem.m_lGraphRect.Bottom;

    G32Graphic.EmptyPolyPoly('Volume.DrawYRulerLine');
    G32Graphic.EmptyPolyText('Volume.DrawYRulerScale');

    for tmpIndex := 1 to tmpLineCount do
    begin
      tmpY := tmpY - tmpUnitHeight;
      DrawYRulerLine('Volume.DrawYRulerLine', tmpRect.Left, tmpRect.Right,
        Trunc(tmpY));
      tmpValue := FormatUnit(YToValue(Trunc(tmpY)));
      DrawYRulerScale('Volume.DrawYRulerScale', tmpValue,
        tmpRect.Left - YRulerWidth, tmpRulerLeft, Trunc(tmpY), gtaRight);
      tmpValue := FormatUnit(YToValue(Trunc(tmpY)));
      DrawYRulerScale('Volume.DrawYRulerScale', tmpValue, tmpRulerRight,
        tmpRect.Right + YRulerWidth, Trunc(tmpY), gtaLeft);
    end;

    G32Graphic.GraphicReset;
    G32Graphic.BackColor := Display.BackColor;
    G32Graphic.LineColor := Display.GridLineColor;
    G32Graphic.DrawPolyPolyLine('Volume.DrawYRulerLine');
    // G32Graphic.DrawPolyPolyDotLine('Volume.DrawYRulerLine');
    G32Graphic.LineColor := Display.YRulerTextColor;
    G32Graphic.DrawPolyText('Volume.DrawYRulerScale');
  end;
end;

function TQuoteTimeVolume.ValueToY(_Value: Double): Integer;
begin
  Result := FGraphItem.m_lGraphRect.Bottom - Trunc(_Value * FScaleY);
end;

function TQuoteTimeVolume.AuctionValueToY(_Value: Double): Integer;
begin
  Result := FGraphItem.m_lGraphRect.Bottom - Trunc(_Value * FAuctionScaleY);
end;

function TQuoteTimeVolume.YToValue(_Y: Double): Double;
begin
  Result := 0;
  if CompareValue(FScaleY, 0) > 0 then
    Result := (FGraphItem.m_lGraphRect.Bottom - _Y) / FScaleY;
end;

function TQuoteTimeVolume.YToYRulerHint(_Y: Integer;
  var _LHint, _RHint: string): Boolean;
begin
  Result := True;
  _LHint := FormatUnit(YToValue(_Y));
  _RHint := FormatUnit(YToValue(_Y));
end;

function TQuoteTimeVolume.IndexToRulerHint(_DataIndex, _Index: Integer;
  var _LHint, _RHint: string): Boolean;
var
  tmpValue: Double;
  tmpData: TTimeData;
  tmpCompareValue: Integer;
begin
  Result := False;
  _LHint := '';
  _RHint := '';
  with FTimeGraphs do
  begin
    tmpData := QuoteTimeData.DataIndexToData(_DataIndex);
    if Assigned(tmpData) then
    begin
      tmpData.GetValue(dkVolume, _Index, tmpValue, tmpCompareValue);
      _LHint := FormatUnit(tmpValue);
      _RHint := FormatUnit(tmpValue);
    end;
  end;
end;

end.
