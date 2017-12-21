unit QuoteTimeMinute;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  Controls,
  Types,
  Math,
  G32Graphic,
  Vcl.Imaging.pngimage,
  Generics.Collections,
  QuoteCommLibrary,
  QuoteTimeStruct,
  WNDataSetInf,
  QuoteTimeGraph,
  QuoteTimeData,
  QuoteTimeButton,
  QuoteTimeIcon,
  AppContext;

type
  TQuoteTimeMinute = class(TQuoteTimeGraph)
  private
    FTimeIconsHash: TDictionary<string, TQuoteTimeIcon>; // 保存分时图上图标信息和画图标的对象
    FTitleButtons: TQuoteTitleButtons;

    FMinutePixel: Double; // 每分钟的像素宽度

    procedure FreeTimeIconsHash;
    procedure AddTimeIcons;
    procedure AddTimeIcon(_Key: string; _Icon: TQuoteTimeIcon);
    function GetIconsCount(_Align: TAlign): Integer;
    function CalcPerValue(_Value: Double; _PerValue: Integer): Double;
    procedure DrawTitleBack;
    procedure DrawTitleNormal;
    procedure DrawTitleMultiStock;
    procedure DrawTitleQuotePrice;
    procedure DrawTitleHistory;
    procedure DrawTitleComplexScreen;
    procedure DrawTitleSelfDefinition;
    procedure DrawToolButtons;
  protected
    FBaseValue: Double;
    FMaxTrendValue: Double;
    FTrendScaleY: Double;

    procedure DrawYRulerScale(_DrawKey, _Value: string;
      _LeftPos, _RightPos, _Y: Integer; Align: TTextAlign); override;
    // 画集合竞价线
    procedure DrawAuctionLine(_Data: TTimeData; _LineColor: TColor;
      _DataKey: TDataKey; _StartPos, _EndPos: Integer);
    // 只画线
    procedure DrawLine(_Data: TTimeData; _LineColor: TColor; _DataKey: TDataKey;
      _StartPos, _EndPos, _Bottom: Integer; _IsGradientFill, _Horz: Boolean);
    //
    procedure DrawGradientFill(_Data: TTimeData; _DataKey: TDataKey;
      _StartPos, _EndPos, _Bottom: Integer; _Horz: Boolean);
    // 画叠加线
    procedure DrawStackLine(_Data: TTimeData; _LineColor: TColor;
      _DataKey: TDataKey; _StartPos, _EndPos: Integer);
    // 画现价
    procedure DrawCurrentPrice(_Data: TTimeData; _StartPos, _EndPos: Integer);
    // 画指数上涨和下跌趋势
    procedure DrawIndexTrend(_Data: TTimeData; _StartPos: Integer);
    procedure DrawYRuler; override;
    procedure DrawSymmetryYRuler; // 画普通坐标轴
    procedure DrawFullAxisYRuler; // 画满占坐标轴
    procedure DrawLimitAxisYRuler; // 画涨停坐标
    procedure DrawStopFlag(_Rect: TRect);
    procedure CalcIconsData;
    procedure CalcMaxMin;
    procedure CalcSymmetryMaxMin;
    procedure CalcFullAxisMaxMin;
    procedure CalcLimitAxisMaxMin;
    procedure CalcScaleY;
    procedure CalcData; override;
    procedure DrawData; override;
    procedure DrawMine; override;
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController
//      : IGilAppController); override;
//    procedure DisConnectQuoteManager; override;
    function YToValue(_Y: Double): Double; override;
    function ValueToY(_Value: Double): Integer; override;
    function TrendValueToY(_Value: Double): Integer;
    procedure DrawTitle(_DataIndex, _Index: Integer); override;
    function YToYRulerHint(_Y: Integer; var _LHint, _RHint: string)
      : Boolean; override;
    function IndexToRulerHint(_DataIndex, _Index: Integer;
      var _LHint, _RHint: string): Boolean; override;
    procedure DrawTitleFrame; override;
    procedure DataArrive(_DataSet: IWNDataSet; _DataTag: Integer); override;
    procedure ToolsMouseMoveOperate(Shift: TShiftState; _Pt: TPoint); override;
    procedure ToolsMouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint); override;
    procedure MouseLeave; override;
    procedure ClearData; override;
    procedure DoSendToBack; override;
    procedure UpdateSkin; override;
  end;

implementation

{ TQuoteTimeMinute }

procedure TQuoteTimeMinute.AddTimeIcons;
begin
  AddTimeIcon(Const_TimeIcon_Information,
    TQuoteInformation.Create(FAppContext, FTimeGraphs));
  AddTimeIcon(Const_TimeIcon_Transaction,
    TQuoteTransaction.Create(FAppContext, FTimeGraphs));
end;

procedure TQuoteTimeMinute.FreeTimeIconsHash;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
  try
    while tmpTimeIconEnum.MoveNext do
    begin
      tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
      if Assigned(tmpTimeIcon) then
        tmpTimeIcon.Free;
    end;
  finally
    FreeAndNil(tmpTimeIconEnum);
  end;
  FTimeIconsHash.Clear;
  FTimeIconsHash.Free;
end;

procedure TQuoteTimeMinute.AddTimeIcon(_Key: string; _Icon: TQuoteTimeIcon);
begin
  if Assigned(FTimeIconsHash) then
    FTimeIconsHash.Add(_Key, _Icon);
end;

function TQuoteTimeMinute.GetIconsCount(_Align: TAlign): Integer;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  Result := 0;
  if Assigned(FTimeIconsHash) then
  begin
    tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
    try
      while tmpTimeIconEnum.MoveNext do
      begin
        tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
        if Assigned(tmpTimeIcon) and (tmpTimeIcon.Align = alTop) then
          Inc(Result);
      end;
    finally
      FreeAndNil(tmpTimeIconEnum);
    end;
  end;
end;

procedure TQuoteTimeMinute.CalcData;
begin
  with FTimeGraphs do
  begin
    CalcIconsData;
    CalcMaxMin;
    CalcScaleY;
    FMinutePixel := MinuteWidth;
  end;
end;

procedure TQuoteTimeMinute.CalcIconsData;
var
  tmpRect: TRect;
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  with FTimeGraphs do
  begin
    if Assigned(FTimeIconsHash) then
    begin
      tmpRect := FGraphItem.m_lGraphRect;
      tmpRect.Top := tmpRect.Top + FGraphItem.m_lTitleHeight;
      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
      try
        while tmpTimeIconEnum.MoveNext do
        begin
          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
          if Assigned(tmpTimeIcon) and (tmpTimeIcon.Align = alTop) then
          begin
            tmpRect.Bottom := tmpRect.Top + Display.IconRectHeight;
            tmpTimeIcon.IconRect := tmpRect;
            tmpRect.Top := tmpRect.Bottom;
          end;
        end;
      finally
        FreeAndNil(tmpTimeIconEnum);
      end;
    end;
  end;
end;

procedure TQuoteTimeMinute.ClearData;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  if Assigned(FTimeIconsHash) then
  begin
    tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
    try
      while tmpTimeIconEnum.MoveNext do
      begin
        tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
        if Assigned(tmpTimeIcon) then
          tmpTimeIcon.ClearData;
      end;
    finally
      FreeAndNil(tmpTimeIconEnum);
    end;
  end;
end;

procedure TQuoteTimeMinute.DoSendToBack;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  if Assigned(FTimeIconsHash) then
  begin
    tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
    try
      while tmpTimeIconEnum.MoveNext do
      begin
        tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
        if Assigned(tmpTimeIcon) then
          tmpTimeIcon.DoSendToBack;
      end;
    finally
      FreeAndNil(tmpTimeIconEnum);
    end;
  end;
end;

procedure TQuoteTimeMinute.CalcSymmetryMaxMin;
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpIsMaxFirst, tmpIsMinFirst: Boolean;
  tmpValue, tmpStackBase, tmpMax, tmpMin: Double;
begin
  with FTimeGraphs do
  begin
    tmpIsMaxFirst := True;
    tmpIsMinFirst := True;
    FMinValue := 0;
    FMaxValue := 0;
    FMaxTrendValue := 0;
    FBaseValue := QuoteTimeData.MainData.PrevClose;
    for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if tmpData.MaxPrice > 0 then
        begin
          if not tmpIsMaxFirst then
          begin
            if tmpData.MaxPrice > FMaxValue then
              FMaxValue := tmpData.MaxPrice;
          end
          else
          begin
            tmpIsMaxFirst := False;
            FMaxValue := tmpData.MaxPrice;
          end;
        end;

        if tmpData.MinPrice > 0 then
        begin
          if not tmpIsMinFirst then
          begin
            if tmpData.MinPrice < FMinValue then
              FMinValue := tmpData.MinPrice;
          end
          else
          begin
            tmpIsMinFirst := False;
            FMinValue := tmpData.MinPrice;
          end;
        end;
        if (tmpIndex = 0) and (tmpData.StockType = stIndex) then
          FMaxTrendValue := tmpData.MaxIndexTrend;
      end;
    end;

    if (FGraphItem.m_lCallAuctionWidth <> 0) then
    begin
      if (FMaxValue < QuoteTimeData.MainData.AuctionMaxPrice) and
        (QuoteTimeData.MainData.AuctionMaxPrice > 0) then
        FMaxValue := QuoteTimeData.MainData.AuctionMaxPrice;
      if (FMinValue > QuoteTimeData.MainData.AuctionMinPrice) and
        (QuoteTimeData.MainData.AuctionMinPrice > 0) then
        FMinValue := QuoteTimeData.MainData.AuctionMinPrice;
    end;

    if FMinValue = 0 then
      FMinValue := FBaseValue;
    if FMaxValue = 0 then
      FMaxValue := FBaseValue;

    if (FMaxValue = FMinValue) and (FMaxValue = FBaseValue) then
    begin
      FMaxValue := FBaseValue + Display.PricePercentIncrement * FBaseValue;
      FMinValue := FBaseValue - Display.PricePercentIncrement * FBaseValue;
    end
    else
    begin
      tmpValue := Max(Abs(FMaxValue - FBaseValue), Abs(FBaseValue - FMinValue));
      FMaxValue := FBaseValue + tmpValue;
      FMinValue := FBaseValue - tmpValue;
    end;

    for tmpIndex := 0 to QuoteTimeData.StackCount - 1 do
    begin
      tmpData := QuoteTimeData.StackDatas[tmpIndex];
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        tmpStackBase := tmpData.PrevClose;
        if tmpStackBase * FBaseValue <> 0 then
        begin
          tmpMax := FBaseValue + (tmpData.MaxPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;
          tmpMin := FBaseValue + (tmpData.MinPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;

          if (tmpMax > 0) and (tmpMax > FMaxValue) then
          begin
            FMaxValue := tmpMax;
          end;
          if (tmpMin > 0) and (tmpMin < FMinValue) then
          begin
            FMinValue := tmpMin;
          end;
        end;
      end;
    end;

    if QuoteTimeData.StackCount > 0 then
    begin
      tmpValue := Max(Abs(FMaxValue - FBaseValue), Abs(FBaseValue - FMinValue));
      FMaxValue := FBaseValue + tmpValue;
      FMinValue := FBaseValue - tmpValue;
    end;

    if CompareValue(FMaxTrendValue, 0) = 0 then
      FMaxTrendValue := 1000;
  end;
end;

procedure TQuoteTimeMinute.CalcFullAxisMaxMin;
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpIsMaxFirst, tmpIsMinFirst: Boolean;
  tmpStackBase, tmpMax, tmpMin, tmpValue, tmpMaxValue: Double;
begin
  with FTimeGraphs do
  begin
    tmpIsMaxFirst := True;
    tmpIsMinFirst := True;
    FMaxValue := 0;
    FMinValue := 0;
    FBaseValue := QuoteTimeData.MainData.PrevClose;
    FMaxTrendValue := 0;
    for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if tmpData.MaxPrice > 0 then
        begin
          if not tmpIsMaxFirst then
          begin
            if tmpData.MaxPrice > FMaxValue then
              FMaxValue := tmpData.MaxPrice;
          end
          else
          begin
            tmpIsMaxFirst := False;
            FMaxValue := tmpData.MaxPrice;
          end;
        end;

        if tmpData.MinPrice > 0 then
        begin
          if not tmpIsMinFirst then
          begin
            if tmpData.MinPrice < FMinValue then
              FMinValue := tmpData.MinPrice;
          end
          else
          begin
            tmpIsMinFirst := False;
            FMinValue := tmpData.MinPrice;
          end;
        end;
        if (tmpIndex = 0) and (tmpData.StockType = stIndex) then
          FMaxTrendValue := tmpData.MaxIndexTrend;
      end;
    end;

    if (FGraphItem.m_lCallAuctionWidth <> 0) then
    begin
      if (FMaxValue < QuoteTimeData.MainData.AuctionMaxPrice) and
        (QuoteTimeData.MainData.AuctionMaxPrice > 0) then
        FMaxValue := QuoteTimeData.MainData.AuctionMaxPrice;
      if (FMinValue > QuoteTimeData.MainData.AuctionMinPrice) and
        (QuoteTimeData.MainData.AuctionMinPrice > 0) then
        FMinValue := QuoteTimeData.MainData.AuctionMinPrice;
    end;

    if FMinValue = 0 then
      FMinValue := FBaseValue;
    if FMaxValue = 0 then
      FMaxValue := FBaseValue;

    if (FMaxValue = FMinValue) then
    begin
      if FMaxValue = FBaseValue then
      begin
        FMaxValue := FMaxValue + Display.PricePercentIncrement * FBaseValue;
        FMinValue := FMinValue - Display.PricePercentIncrement * FBaseValue;
      end
      else
      begin
        tmpMaxValue := FMaxValue;
        FMaxValue := tmpMaxValue + Display.PricePercentIncrement * tmpMaxValue;
        FMinValue := tmpMaxValue - Display.PricePercentIncrement * tmpMaxValue;

        // tmpValue := Max(Abs(FMaxValue - FBaseValue),
        // Abs(FBaseValue - FMinValue));
        // FMaxValue := FMaxValue + tmpValue;
        // FMinValue := FMaxValue - tmpValue;
      end;
    end;

    for tmpIndex := 0 to QuoteTimeData.StackCount - 1 do
    begin
      tmpData := QuoteTimeData.StackDatas[tmpIndex];
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        tmpStackBase := tmpData.PrevClose;
        if tmpStackBase * FBaseValue <> 0 then
        begin
          tmpMax := FBaseValue + (tmpData.MaxPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;
          tmpMin := FBaseValue + (tmpData.MinPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;

          if (tmpMax > 0) and (tmpMax > FMaxValue) then
          begin
            FMaxValue := tmpMax;
          end;
          if (tmpMin > 0) and (tmpMin < FMinValue) then
          begin
            FMinValue := tmpMin;
          end;
        end;
      end;
    end;

    if CompareValue(FMaxTrendValue, 0) = 0 then
      FMaxTrendValue := 1000;
  end;
end;

procedure TQuoteTimeMinute.CalcLimitAxisMaxMin;
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpStackBase, tmpMax, tmpMin: Double;
  tmpIsMaxFirst, tmpIsMinFirst: Boolean;
begin
  with FTimeGraphs do
  begin
    tmpIsMaxFirst := True;
    tmpIsMinFirst := True;
    FMaxValue := 0;
    FMinValue := 0;
    FMaxTrendValue := 0;
    FBaseValue := QuoteTimeData.MainData.PrevClose;
    for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if tmpIndex = 0 then
        begin
          if tmpData.LimitMaxPrice > FMaxValue then
            FMaxValue := tmpData.LimitMaxPrice;
          if (tmpData.LimitMinPrice > 0) then
          begin
            if (FMinValue = 0) then
            begin
              FMinValue := tmpData.LimitMinPrice;
            end
            else if (FMinValue > 0) and (FMinValue > tmpData.LimitMinPrice) then
            begin
              FMinValue := tmpData.LimitMinPrice;
            end;
          end;

          if tmpData.StockType = stIndex then
            FMaxTrendValue := tmpData.MaxIndexTrend;
        end
        else
        begin
          if tmpData.MaxPrice > 0 then
          begin
            if not tmpIsMaxFirst then
            begin
              if tmpData.MaxPrice > FMaxValue then
                FMaxValue := tmpData.MaxPrice;
            end
            else
            begin
              tmpIsMaxFirst := False;
              FMaxValue := tmpData.MaxPrice;
            end;
          end;

          if tmpData.MinPrice > 0 then
          begin
            if not tmpIsMinFirst then
            begin
              if tmpData.MinPrice < FMinValue then
                FMinValue := tmpData.MinPrice;
            end
            else
            begin
              tmpIsMinFirst := False;
              FMinValue := tmpData.MinPrice;
            end;
          end;
        end;
      end;
    end;

    if (FGraphItem.m_lCallAuctionWidth <> 0) then
    begin
      if (FMaxValue < QuoteTimeData.MainData.AuctionMaxPrice) and
        (QuoteTimeData.MainData.AuctionMaxPrice > 0) then
        FMaxValue := QuoteTimeData.MainData.AuctionMaxPrice;
      if (FMinValue > QuoteTimeData.MainData.AuctionMinPrice) and
        (QuoteTimeData.MainData.AuctionMinPrice > 0) then
        FMinValue := QuoteTimeData.MainData.AuctionMinPrice;
    end;

    if FMinValue = 0 then
      FMinValue := FBaseValue;
    if FMaxValue = 0 then
      FMaxValue := FBaseValue;

    if FMaxValue = FMinValue then
    begin
      FMaxValue := FBaseValue + Display.PricePercentIncrement * FBaseValue;
      FMinValue := FBaseValue - Display.PricePercentIncrement * FBaseValue;
    end;

    for tmpIndex := 0 to QuoteTimeData.StackCount - 1 do
    begin
      tmpData := QuoteTimeData.StackDatas[tmpIndex];
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        tmpStackBase := tmpData.PrevClose;
        if tmpStackBase * FBaseValue <> 0 then
        begin
          tmpMax := FBaseValue + (tmpData.MaxPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;
          tmpMin := FBaseValue + (tmpData.MinPrice - tmpStackBase) /
            tmpStackBase * FBaseValue;
          if tmpMax > FMaxValue then
            FMaxValue := tmpMax;
          if (tmpMin > 0) and (tmpMin < FMinValue) then
            FMinValue := tmpMin;
        end;
      end;
    end;

    if CompareValue(FMaxTrendValue, 0) = 0 then
      FMaxTrendValue := 1000;
  end;
end;

procedure TQuoteTimeMinute.CalcMaxMin;
var
  tmpMainData: TTimeData;
begin
  with FTimeGraphs do
  begin
    if Display.MainGraphYAxisType = atSymmetry then
      CalcSymmetryMaxMin
    else if Display.MainGraphYAxisType = atFullAxis then
      CalcFullAxisMaxMin
    else if Display.MainGraphYAxisType = atLimitAxis then
    begin
      tmpMainData := QuoteTimeData.MainData;
      if Assigned(tmpMainData) and tmpMainData.HasLimitAixs then
        CalcLimitAxisMaxMin
      else
        CalcSymmetryMaxMin;
    end;
  end;
end;

function TQuoteTimeMinute.CalcPerValue(_Value: Double;
  _PerValue: Integer): Double;
var
  tmpMainData: TTimeData;
begin
  with FTimeGraphs do
  begin
    tmpMainData := QuoteTimeData.MainData;
    if (FBaseValue <> 0) and Assigned(tmpMainData) and
      (not tmpMainData.NullTimeData) then
      Result := (_Value - FBaseValue) * _PerValue / FBaseValue
    else
      Result := 0;
  end;
end;

procedure TQuoteTimeMinute.CalcScaleY;
begin
  with FTimeGraphs do
  begin
    if FMinValue = FMaxValue then
      FScaleY := 0.005
    else
      FScaleY := DrawGraphRect.Height / (FMinValue - FMaxValue);

    FTrendScaleY := DrawGraphRect.Height * 0.25 / FMaxTrendValue;
  end;
end;

constructor TQuoteTimeMinute.Create(AContext: IAppContext;_TimeGraphs: TQuoteTimeGraphs);
begin
  inherited Create(AContext);

  FTimeGraphs := _TimeGraphs;
  FGraphItem.m_lPositon := 1;
  FGraphItem.m_lUpBlank := 10;
  FGraphItem.m_lDownBlank := 10;
  FMaxValue := 0;
  FMinValue := 0;

  FTimeIconsHash := TDictionary<string, TQuoteTimeIcon>.Create(2);
  if FTimeGraphs.Display.ShowMode = smNormal then
  begin
    FTitleButtons := TQuoteTitleButtons.Create(FAppContext, _TimeGraphs);

    AddTimeIcons;
    if GetIconsCount(alTop) > 0 then
    begin
      FGraphItem.m_lUpBlank := GetIconsCount(alTop) *
        FTimeGraphs.Display.IconRectHeight;
    end;
  end;
end;

destructor TQuoteTimeMinute.Destroy;
begin
  if Assigned(FTitleButtons) then
    FTitleButtons.Free;
  if Assigned(FTimeIconsHash) then
    FreeTimeIconsHash;
  inherited;
end;

//procedure TQuoteTimeMinute.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//var
//  tmpTimeIcon: TQuoteTimeIcon;
//  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
//begin
//  with FTimeGraphs do
//  begin
//    if (Display.ShowMode = smNormal) then
//    begin
//      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
//      try
//        while tmpTimeIconEnum.MoveNext do
//        begin
//          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
//          if Assigned(tmpTimeIcon) then
//            tmpTimeIcon.ConnectQuoteManager(GilAppController);
//        end;
//      finally
//        FreeAndNil(tmpTimeIconEnum);
//      end;
//    end;
//  end;
//end;

//procedure TQuoteTimeMinute.DisConnectQuoteManager;
//var
//  tmpTimeIcon: TQuoteTimeIcon;
//  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
//begin
//  with FTimeGraphs do
//  begin
//    if (Display.ShowMode = smNormal) then
//    begin
//      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
//      try
//        while tmpTimeIconEnum.MoveNext do
//        begin
//          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
//          if Assigned(tmpTimeIcon) then
//            tmpTimeIcon.DisConnectQuoteManager;
//        end;
//      finally
//        FreeAndNil(tmpTimeIconEnum);
//      end;
//    end;
//  end;
//end;

procedure TQuoteTimeMinute.DrawData;
var
  tmpIndex, tmpStackIndex, tmpBottom: Integer;
  tmpStartPos, tmpEndPos: Double;
  tmpData, tmpStackData: TTimeData;
begin
  with FTimeGraphs do
  begin
    // 画集合竞价
    if FBaseValue > 0 then
    begin
      if FGraphItem.m_lCallAuctionWidth <> 0 then
      begin
        tmpEndPos := FGraphItem.m_lGraphRect.Left +
          FGraphItem.m_lCallAuctionWidth;
        tmpStartPos := FGraphItem.m_lGraphRect.Left + 1;
        tmpData := QuoteTimeData.MainData;
        if (tmpData <> nil) and tmpData.IsHasAuction then
          DrawAuctionLine(tmpData, Display.TimeLineColor, dkAuctionPrice,
            Trunc(tmpStartPos), Trunc(tmpEndPos));
      end;

      tmpStartPos := FGraphItem.m_lGraphRect.Left +
        FGraphItem.m_lCallAuctionWidth + 1;
      tmpBottom := FGraphItem.m_lGraphRect.Bottom;

      // 画分时线部分
      for tmpIndex := QuoteTimeData.MainDatasCount - 1 downto 0 do
      begin
        tmpData := QuoteTimeData.DataIndexToData(tmpIndex);
        tmpEndPos := tmpStartPos + SingleDayWidth;
        if tmpData <> nil then
        begin

          // // 画渐进
          // DrawGradientFill(tmpData, dkPrice, Trunc(tmpStartPos),
          // Trunc(tmpEndPos), tmpBottom, False);

          // 画叠加的分时线
          if tmpIndex = 0 then
          begin
            // 是指数时画上涨下跌趋势
            if tmpData.StockType = stIndex then
              DrawIndexTrend(tmpData, Trunc(tmpStartPos));

            // 画现价
            if FTimeGraphs.Display.CurrentPriceVisible then
              DrawCurrentPrice(tmpData, FGraphItem.m_lGraphRect.Left,
                FGraphItem.m_lGraphRect.Right - 1);

            for tmpStackIndex := 0 to QuoteTimeData.StackCount - 1 do
            begin
              tmpStackData := QuoteTimeData.StackDatas[tmpStackIndex];
              if tmpStackData <> nil then
                DrawStackLine(tmpStackData, Display.Colors[tmpStackIndex],
                  dkPrice, Trunc(tmpStartPos), Trunc(tmpEndPos));
            end;
          end;

          // 画均线
          if tmpIndex = 0 then
          begin
            if tmpData.IsStop then
            begin
              DrawStopFlag(Rect(Trunc(tmpStartPos), FGraphItem.m_lGraphRect.Top
                + FGraphItem.m_lTitleHeight, Trunc(tmpEndPos),
                FGraphItem.m_lGraphRect.Bottom));
            end;
            DrawLine(tmpData, Display.AverageLineColor, dkAveragePrice,
              Trunc(tmpStartPos), Trunc(tmpEndPos), tmpBottom, False, False);
          end
          else if tmpIndex > 0 then
          begin
            if (tmpData.InnerCode <> Const_InnerCode_Index_SH) and
              (tmpData.InnerCode <> Const_InnerCode_Index_SZ) then
              DrawLine(tmpData, Display.AverageLineColor, dkAveragePrice,
                Trunc(tmpStartPos), Trunc(tmpEndPos), tmpBottom, False, False);
          end;
          // 画分时线
          DrawLine(tmpData, Display.TimeLineColor, dkPrice, Trunc(tmpStartPos),
            Trunc(tmpEndPos), tmpBottom, True, False);
        end;
        tmpStartPos := tmpStartPos + SingleDayWidth;
      end;
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawMine;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  with FTimeGraphs do
  begin
    if (Display.ShowMode = smNormal) then
    begin
      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
      try
        while tmpTimeIconEnum.MoveNext do
        begin
          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
          if Assigned(tmpTimeIcon) and tmpTimeIcon.GetVisible then
          begin
            tmpTimeIcon.UpdataRect;
            tmpTimeIcon.DrawIcons;
          end;
        end;
      finally
        FreeAndNil(tmpTimeIconEnum);
      end;
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawYRulerScale(_DrawKey, _Value: string;
  _LeftPos, _RightPos, _Y: Integer; Align: TTextAlign);
var
  tmpHeight: Integer;
begin
  with FTimeGraphs do
  begin
    if FBaseValue > 0 then
    begin
      tmpHeight := Trunc(TextHeight / 2);
      G32Graphic.AddPolyText(_DrawKey, Rect(_LeftPos, _Y - tmpHeight, _RightPos,
        _Y + tmpHeight), _Value, Align);
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawAuctionLine(_Data: TTimeData; _LineColor: TColor;
  _DataKey: TDataKey; _StartPos, _EndPos: Integer);
var
  tmpPos, tmpValue: Double;
  tmpIndex, tmpCompareValue, tmpAuctionCount: Integer;
begin
  with FTimeGraphs do
  begin
    tmpPos := _StartPos + FMinutePixel / 2;
    tmpAuctionCount := _Data.AuctionMinuteCount;

    G32Graphic.EmptyPoly('Graph.Minute.DrawAuctionLine');

    if _Data.VADataCount > 0 then
    begin
      _Data.GetValue(_DataKey, (0 - tmpAuctionCount), tmpValue,
        tmpCompareValue);
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawAuctionLine',
          Point(_StartPos, ValueToY(tmpValue)));
    end;

    for tmpIndex := 0 to _Data.VADataCount - 1 do
    begin
      // 集合竞价的数据的下标用 负数区分 所以 tmpIndex - tmpVADataCount
      _Data.GetValue(_DataKey, (tmpIndex - tmpAuctionCount), tmpValue,
        tmpCompareValue);

      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawAuctionLine',
          Point(Trunc(tmpPos), ValueToY(tmpValue)));
      tmpPos := tmpPos + FMinutePixel;
    end;

    if _Data.VADataCount >= tmpAuctionCount then
    begin
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawAuctionLine',
          Point(_EndPos, ValueToY(tmpValue)));
    end;

    G32Graphic.GraphicReset;
    G32Graphic.LineColor := _LineColor;
    G32Graphic.Antialiased := True;
    G32Graphic.DrawPolyLine('Graph.Minute.DrawAuctionLine');
  end;
end;

procedure TQuoteTimeMinute.DrawLine(_Data: TTimeData; _LineColor: TColor;
  _DataKey: TDataKey; _StartPos, _EndPos, _Bottom: Integer;
  _IsGradientFill, _Horz: Boolean);
var
  tmpPos, tmpValue: Double;
  tmpIndex, tmpCompareValue: Integer;
begin
  with FTimeGraphs do
  begin
    tmpPos := _StartPos + FMinutePixel / 2;
    G32Graphic.EmptyPoly('Graph.Minute.DrawLine');

    // 补画剩下的空隙
    if _Data.DataCount > 0 then
    begin
      _Data.GetValue(_DataKey, 0, tmpValue, tmpCompareValue);
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawLine',
          Point(_StartPos, ValueToY(tmpValue)));
    end;

    for tmpIndex := 0 to _Data.DataCount - 1 do
    begin
      _Data.GetValue(_DataKey, tmpIndex, tmpValue, tmpCompareValue);
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawLine',
          Point(Trunc(tmpPos), ValueToY(tmpValue)));
      tmpPos := tmpPos + FMinutePixel;
    end;

    // 补画剩下的空隙
    if _Data.DataCount >= _Data.MinuteCount then
    begin
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawLine',
          Point(_EndPos, ValueToY(tmpValue)));
    end;

    G32Graphic.GraphicReset;
    G32Graphic.LineColor := _LineColor;
    G32Graphic.Antialiased := True;
    G32Graphic.DrawPolyLine('Graph.Minute.DrawLine');
  end;
end;

procedure TQuoteTimeMinute.DrawGradientFill(_Data: TTimeData;
  _DataKey: TDataKey; _StartPos, _EndPos, _Bottom: Integer; _Horz: Boolean);
var
  tmpIsFirst: Boolean;
  tmpIndex, tmpCompareValue: Integer;
  tmpPos, tmpLastPos, tmpValue, tmpLastValue: Double;
begin
  with FTimeGraphs do
  begin
    tmpIsFirst := True;
    tmpPos := _StartPos + FMinutePixel / 2;
    tmpLastPos := tmpPos;

    G32Graphic.EmptyPoly('Graph.Minute.DrawGradientFill');

    for tmpIndex := 0 to _Data.DataCount - 1 do
    begin
      _Data.GetValue(_DataKey, tmpIndex, tmpValue, tmpCompareValue);
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
      begin
        if tmpIsFirst then
        begin
          G32Graphic.AddPoly('Graph.Minute.DrawGradientFill',
            Trunc(_StartPos), _Bottom);
          G32Graphic.AddPoly('Graph.Minute.DrawGradientFill', Trunc(_StartPos),
            ValueToY(tmpValue));
          tmpIsFirst := False;
        end;
        tmpLastValue := tmpValue;
        G32Graphic.AddPoly('Graph.Minute.DrawGradientFill', Trunc(tmpPos),
          ValueToY(tmpValue));
        tmpLastPos := Trunc(tmpPos);
      end;
      tmpPos := tmpPos + FMinutePixel;
    end;

    if _Data.DataCount >= _Data.MinuteCount then
    begin
      tmpLastPos := _EndPos;
      G32Graphic.AddPoly('Graph.Minute.DrawGradientFill', _EndPos,
        Trunc(tmpLastValue));
    end;

    if not tmpIsFirst then
    begin
      G32Graphic.AddPoly('Graph.Minute.DrawGradientFill',
        Trunc(tmpLastPos), _Bottom);
    end;

    G32Graphic.GraphicReset;
    G32Graphic.Alpha := 100;
    G32Graphic.DrawPolyGradientFill('Graph.Minute.DrawGradientFill',
      Display.ShadowBackColors, _Horz);
  end;
end;

procedure TQuoteTimeMinute.DrawStackLine(_Data: TTimeData; _LineColor: TColor;
  _DataKey: TDataKey; _StartPos, _EndPos: Integer);
var
  tmpPos, tmpValue: Double;
  tmpIndex, tmpCompareValue: Integer;
begin
  with FTimeGraphs do
  begin
    tmpPos := _StartPos + FMinutePixel;
    G32Graphic.EmptyPoly('Graph.Minute.DrawStackLine');

    if _Data.DataCount > 0 then
    begin
      _Data.GetValue(_DataKey, 0, tmpValue, tmpCompareValue);
      if _Data.PrevClose > 0 then
        tmpValue := FBaseValue + (tmpValue - _Data.PrevClose) / _Data.PrevClose
          * FBaseValue;
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawStackLine',
          Point(_StartPos, ValueToY(tmpValue)));
    end;

    for tmpIndex := 0 to _Data.DataCount - 1 do
    begin
      _Data.GetValue(_DataKey, tmpIndex, tmpValue, tmpCompareValue);
      if _Data.PrevClose > 0 then
        tmpValue := FBaseValue + (tmpValue - _Data.PrevClose) / _Data.PrevClose
          * FBaseValue;
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawStackLine',
          Point(Trunc(tmpPos), ValueToY(tmpValue)));

      tmpPos := tmpPos + FMinutePixel;
      if (Trunc(tmpPos) > _EndPos) then
        Break;
    end;

    if (_Data.DataCount >= _Data.MinuteCount) or (Trunc(tmpPos) > _EndPos) then
      if (tmpValue >= FMinValue) and (tmpValue <= FMaxValue) then
        G32Graphic.AddPoly('Graph.Minute.DrawStackLine',
          Point(_EndPos, ValueToY(tmpValue)));

    G32Graphic.GraphicReset;
    G32Graphic.LineColor := _LineColor;
    G32Graphic.Antialiased := True;
    G32Graphic.DrawPolyLine('Graph.Minute.DrawStackLine');
  end;
end;

procedure TQuoteTimeMinute.DrawStopFlag(_Rect: TRect);
var
  tmpHeight: Integer;
  tmpGraph: TQuoteTimeGraph;
begin
  with FTimeGraphs do
  begin
    tmpHeight := Display.TextFont.Height;
    Display.TextFont.Height := Trunc(_Rect.Width * 0.2);
    G32Graphic.EmptyPolyText('StopFlag');
    G32Graphic.AddPolyText('StopFlag', _Rect, '停牌', gtaCenter);
    G32Graphic.GraphicReset;
    G32Graphic.UpdateFont(Display.TextFont);
    G32Graphic.Alpha := 200;
    G32Graphic.LineColor := Display.StopFlagTextColor;
    G32Graphic.DrawPolyText('StopFlag');
    Display.TextFont.Height := tmpHeight;
    G32Graphic.UpdateFont(Display.TextFont);
  end;
end;

procedure TQuoteTimeMinute.DrawCurrentPrice(_Data: TTimeData;
  _StartPos, _EndPos: Integer);
var
  tmpRect: TRect;
  tmpText: string;
  tmpValue: Double;
  tmpY, tmpHalfHeight, tmpSpace, tmpCompareValue: Integer;
begin
  with FTimeGraphs do
  begin
    tmpHalfHeight := TextHeight div 2;
    tmpSpace := 1;
    _Data.GetValue(dkCurrentPrice, _Data.DataCount - 1, tmpValue,
      tmpCompareValue);
    tmpY := ValueToY(tmpValue) + 1;

    G32Graphic.EmptyPoly('Minute.CurrentPriceFrameLine.Left');
    G32Graphic.EmptyPoly('Minute.CurrentPriceFrameLine.Right');
    G32Graphic.EmptyPolyText('Minute.CurrentPriceText');
    G32Graphic.EmptyPolyPoly('Minute.CurrentPriceLine');

    tmpRect := Rect(_StartPos - YRulerWidth, tmpY - tmpHalfHeight,
      _StartPos - tmpHalfHeight - tmpSpace, tmpY + tmpHalfHeight);

    tmpText := Format(Display.PriceFormat, [tmpValue]);
    G32Graphic.AddPolyText('Minute.CurrentPriceText', tmpRect, tmpText,
      gtaCenter);

    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left', tmpRect.Left,
      tmpRect.Top);
    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left', tmpRect.Right,
      tmpRect.Top);
    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left',
      tmpRect.Right + tmpHalfHeight, tmpY);
    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left', tmpRect.Right,
      tmpRect.Bottom);
    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left', tmpRect.Left,
      tmpRect.Bottom);
    G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Left', tmpRect.Left,
      tmpRect.Top);
    G32Graphic.GraphicReset;
    G32Graphic.BackColor := Display.CurrentPriceHintBackColor;
    G32Graphic.DrawPolyFill('Minute.CurrentPriceFrameLine.Left');
    G32Graphic.LineColor := Display.CurrentPriceHintFrameLineColor;
    G32Graphic.DrawPolyLine('Minute.CurrentPriceFrameLine.Left');

    if Display.ShowMode <> smMulitStock then
    begin
      tmpRect := Rect(_EndPos + tmpHalfHeight + tmpSpace, tmpY - tmpHalfHeight,
        _EndPos + YRulerWidth, tmpY + tmpHalfHeight);

      _Data.GetValue(dkHighsLowsRange, _Data.DataCount - 1, tmpValue,
        tmpCompareValue);
      tmpText := Format(Display.HighsLowsRangeFormat, [tmpValue]);
      G32Graphic.AddPolyText('Minute.CurrentPriceText', tmpRect, tmpText,
        gtaCenter);

      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right', tmpRect.Right,
        tmpRect.Top);
      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right', tmpRect.Left,
        tmpRect.Top);
      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right',
        tmpRect.Left - tmpHalfHeight, tmpY);
      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right', tmpRect.Left,
        tmpRect.Bottom);
      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right', tmpRect.Right,
        tmpRect.Bottom);
      G32Graphic.AddPoly('Minute.CurrentPriceFrameLine.Right', tmpRect.Right,
        tmpRect.Top);

      G32Graphic.BackColor := Display.CurrentPriceHintBackColor;
      G32Graphic.DrawPolyFill('Minute.CurrentPriceFrameLine.Right');
      G32Graphic.LineColor := Display.CurrentPriceHintFrameLineColor;
      G32Graphic.DrawPolyLine('Minute.CurrentPriceFrameLine.Right');
    end;

    G32Graphic.LineColor := Display.DownEqualUpColors[tmpCompareValue];
    G32Graphic.DrawPolyText('Minute.CurrentPriceText');

    G32Graphic.AddPolyPoly('Minute.CurrentPriceLine',
      [Point(_StartPos, tmpY), Point(_EndPos, tmpY)]);
    G32Graphic.LineColor := Display.CurrentPriceHintFrameLineColor;
    G32Graphic.DrawPolyPolyDotLine('Minute.CurrentPriceLine');
  end;
end;

procedure TQuoteTimeMinute.DrawIndexTrend(_Data: TTimeData; _StartPos: Integer);
const
  const_DrawKeys: array [-1 .. 1] of string = ('Minute.DrawIndexTrend.Down',
    'Minute.DrawIndexTrend.Equal', 'Minute.DrawIndexTrend.Up');
var
  tmpValue, tmpPos: Double;
  tmpIndex, tmpCompareValue, tmpBaseY: Integer;
begin
  with FTimeGraphs do
  begin
    tmpPos := _StartPos + FMinutePixel / 2;
    tmpBaseY := (DrawGraphRect.Top + DrawGraphRect.Bottom) div 2;

    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
      G32Graphic.EmptyPolyPoly(const_DrawKeys[tmpIndex]);

    for tmpIndex := 0 to _Data.DataCount - 1 do
    begin
      _Data.GetValue(dkIndexTrend, tmpIndex, tmpValue, tmpCompareValue);
      if tmpCompareValue <> 0 then
        G32Graphic.AddPolyPoly(const_DrawKeys[tmpCompareValue],
          [Point(Trunc(tmpPos), tmpBaseY), Point(Trunc(tmpPos),
          TrendValueToY(tmpValue))]);
      tmpPos := tmpPos + FMinutePixel;
    end;

    G32Graphic.GraphicReset;
    G32Graphic.Antialiased := True;
    G32Graphic.Alpha := 160;
    for tmpIndex := Low(const_DrawKeys) to High(const_DrawKeys) do
    begin
      G32Graphic.LineColor := Display.DownEqualUpColors[tmpIndex];
      G32Graphic.DrawPolyPolyLine(const_DrawKeys[tmpIndex]);
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawTitle(_DataIndex, _Index: Integer);
begin

end;

procedure TQuoteTimeMinute.DrawTitleBack;
var
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    tmpRect := TitleRect;
    if Display.ShowMode <> smSimple then
    begin
      G32Graphic.BackColor := Display.TitleBackColor;
      G32Graphic.FillRect(tmpRect);
    end;

    if Display.ShowMode in [smNormal, smHistoryTime] then
    begin
      G32Graphic.EmptyPolyPoly('Minute.TitleFrameLine');
      G32Graphic.AddPolyPoly('Minute.TitleFrameLine',
        [Point(tmpRect.Left, tmpRect.Bottom), Point(tmpRect.Right,
        tmpRect.Bottom)]);
      G32Graphic.LineColor := Display.TitleFrameLineColor;
      G32Graphic.DrawPolyPolyLine('Minute.TitleFrameLine');
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawTitleComplexScreen;
var
  tmpRect: TRect;
  tmpValue: Double;
  tmpData: TTimeData;
  tmpTitleItems: TTitleItems;
  tmpCompareValue, tmpIndex, tmpCount: Integer;
begin
  with FTimeGraphs do
  begin
    tmpData := QuoteTimeData.MainData;
    if Assigned(tmpData) and (not tmpData.NullTimeData) then
    begin
      SetLength(tmpTitleItems, 3);
      tmpCount := 0;
      tmpIndex := tmpData.DataCount - 1;
      tmpData.GetValue(dkCurrentPrice, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText := Format(Display.PriceFormat,
        [tmpValue]);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpData.GetValue(dkHighsLows, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText :=
        FormatFloat(Display.HightLowsFormatFloat, tmpValue);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpData.GetValue(dkHighsLowsRange, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText :=
        FormatFloat(Display.HighsLowsRangeFormatFloat, tmpValue);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      if (tmpData.InnerCode = Const_InnerCode_Index_SH) or
        (tmpData.InnerCode = Const_InnerCode_Index_SZ) then
      begin
        SetLength(tmpTitleItems, 6);
        if tmpData.RiseCount >= 0 then
        begin
          Inc(tmpCount);
          tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors[1];
          tmpTitleItems[tmpCount].m_lText := IntToStr(tmpData.RiseCount);
          tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
          tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
        end;

        if tmpData.FlatCount >= 0 then
        begin
          Inc(tmpCount);
          tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors[0];
          tmpTitleItems[tmpCount].m_lText :=
            '/' + IntToStr(tmpData.FlatCount) + '/';
          tmpTitleItems[tmpCount].m_lIsNeedSpace := False;
          tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
        end;

        if tmpData.FallCount >= 0 then
        begin
          Inc(tmpCount);
          tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors[-1];
          tmpTitleItems[tmpCount].m_lText := IntToStr(tmpData.FallCount);
          tmpTitleItems[tmpCount].m_lIsNeedSpace := False;
          tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
        end;
      end;
    end;
    tmpRect := TitleRect;
    tmpRect.Left := tmpRect.Left + YRulerWidth;
    DrawText(tmpRect, tmpTitleItems);
  end;
end;

procedure TQuoteTimeMinute.DrawTitleSelfDefinition;
var
  tmpValue: Double;
  tmpData: TTimeData;
  tmpTitleItems: TTitleItems;
  tmpCompareValue, tmpIndex, tmpCount: Integer;
begin
  with FTimeGraphs do
  begin
    SetLength(tmpTitleItems, 5);
    tmpCount := 0;

    if QuoteTimeData.MainStockName <> '' then
    begin
      if QuoteTimeData.IsSelfStock then
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockNameTextColor
      else
        tmpTitleItems[tmpCount].m_lColor := Display.StockNameTextColor;
      tmpTitleItems[tmpCount].m_lText := QuoteTimeData.MainStockName;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lFontStyles := [fsBold];
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height - 2;
    end;

    if QuoteTimeData.MainSecuCode <> '' then
    begin
      Inc(tmpCount);
      if QuoteTimeData.IsSelfStock then
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockCodeTextColor
      else
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockCodeTextColor;
      tmpTitleItems[tmpCount].m_lText := '(' + QuoteTimeData.MainSecuCode + ')';
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
    end;

    tmpData := QuoteTimeData.MainData;
    if Assigned(tmpData) and (not tmpData.NullTimeData) then
    begin
      Inc(tmpCount);
      tmpIndex := tmpData.DataCount - 1;
      tmpData.GetValue(dkCurrentPrice, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText := Format(Display.PriceFormat,
        [tmpValue]);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpIndex := tmpData.DataCount - 1;
      tmpData.GetValue(dkHighsLows, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText := Format(Display.PriceFormat,
        [tmpValue]);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpData.GetValue(dkHighsLowsRange, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText :=
        FormatFloat(Display.HighsLowsRangeFormatFloat, tmpValue);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
    end;
    DrawText(TitleRect, tmpTitleItems);
  end;
end;

procedure TQuoteTimeMinute.DrawTitleFrame;
begin
  with FTimeGraphs do
  begin
    DrawTitleBack;
    if Display.ShowMode = smNormal then
    begin
      DrawTitleNormal;
      DrawToolButtons;
    end
    else if Display.ShowMode = smHistoryTime then
      DrawTitleHistory
    else if Display.ShowMode = smMulitStock then
      DrawTitleMultiStock
    else if Display.ShowMode = smSimple then
      DrawTitleQuotePrice
    else if Display.ShowMode = smComplexScreen then
      DrawTitleComplexScreen
    else if Display.ShowMode = smWSSelfDefinition then
      DrawTitleSelfDefinition;
  end;
end;

procedure TQuoteTimeMinute.DrawTitleNormal;
var
  tmpData: TTimeData;
  tmpTitleItems: TTitleItems;
//  tmpStockInfoSec: StockInfoRec;
  tmpCount, tmpIndex, tmpInnerCode: Integer;
begin
  with FTimeGraphs do
  begin
    if Assigned(QuoteTimeData.MainData) and
      not(QuoteTimeData.MainData.NullTimeData) then
    begin
      tmpInnerCode := QuoteTimeData.MainData.InnerCode;
      SetLength(tmpTitleItems, QuoteTimeData.StackCount + 2);

      tmpCount := 0;
      tmpTitleItems[tmpCount].m_lColor := Display.TimeLineColor;
      tmpTitleItems[tmpCount].m_lText := Const_Time_TrendLine_Name;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpTitleItems[tmpCount].m_lColor := Display.AverageLineColor;
      if (tmpInnerCode = Const_InnerCode_Index_SH) or
        (tmpInnerCode = Const_InnerCode_Index_SZ) then
        tmpTitleItems[tmpCount].m_lText := Const_Time_LeadLine_Name
      else
        tmpTitleItems[tmpCount].m_lText := Const_Time_AverageLine_Name;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      for tmpIndex := 0 to QuoteTimeData.StackCount - 1 do
      begin
        Inc(tmpCount);
        tmpData := QuoteTimeData.StackDatas[tmpIndex];
        tmpTitleItems[tmpCount].m_lColor := Display.Colors[tmpIndex];
        if Assigned(tmpData) then
        begin
//          if (tmpData.StockName = '') and Assigned(FTimeGraphs.GilAppController)
//          then
//          begin
//            FTimeGraphs.GilAppController.QueryStockInfo(tmpData.InnerCode,
//              tmpStockInfoSec);
//            tmpData.StockName := tmpStockInfoSec.ZQJC;
//          end;
          tmpTitleItems[tmpCount].m_lText := '[' + tmpData.StockName + ']';
        end;
        tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
        tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
      end;
      DrawText(TitleRect, tmpTitleItems);
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawTitleMultiStock;
var
  tmpValue: Double;
  tmpData: TTimeData;
  tmpTitleItems: TTitleItems;
  tmpCompareValue, tmpIndex, tmpCount: Integer;
begin
  with FTimeGraphs do
  begin
    SetLength(tmpTitleItems, 4);
    tmpCount := 0;

    if QuoteTimeData.MainStockName <> '' then
    begin
      if QuoteTimeData.IsSelfStock then
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockNameTextColor
      else
        tmpTitleItems[tmpCount].m_lColor := Display.StockNameTextColor;
      tmpTitleItems[tmpCount].m_lText := QuoteTimeData.MainStockName;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lFontStyles := [fsBold];
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height - 2;
    end;

    if QuoteTimeData.MainSecuCode <> '' then
    begin
      Inc(tmpCount);
      if QuoteTimeData.IsSelfStock then
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockCodeTextColor
      else
        tmpTitleItems[tmpCount].m_lColor := Display.SelfStockCodeTextColor;
      tmpTitleItems[tmpCount].m_lText := '(' + QuoteTimeData.MainSecuCode + ')';
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
    end;

    tmpData := QuoteTimeData.MainData;
    if Assigned(tmpData) and (not tmpData.NullTimeData) then
    begin
      Inc(tmpCount);
      tmpIndex := tmpData.DataCount - 1;
      tmpData.GetValue(dkCurrentPrice, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText := Format(Display.PriceFormat,
        [tmpValue]);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpData.GetValue(dkHighsLowsRange, tmpIndex, tmpValue, tmpCompareValue);
      tmpTitleItems[tmpCount].m_lColor := Display.DownEqualUpColors
        [tmpCompareValue];
      tmpTitleItems[tmpCount].m_lText :=
        FormatFloat(Display.HighsLowsRangeFormatFloat, tmpValue);
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;
    end;
    DrawText(TitleRect, tmpTitleItems);
  end;
end;

procedure TQuoteTimeMinute.DrawTitleQuotePrice;
begin

end;

procedure TQuoteTimeMinute.DrawTitleHistory;
var
  tmpIsGetDate: Boolean;
  tmpDateTime: TDateTime;
  tmpTitleItems: TTitleItems;
  tmpCount, tmpInnerCode: Integer;
begin
  with FTimeGraphs do
  begin
    if QuoteTimeData.MainData <> nil then
    begin
      tmpCount := 0;
      tmpInnerCode := QuoteTimeData.MainData.InnerCode;
      SetLength(tmpTitleItems, 3);

      tmpIsGetDate := QuoteTimeData.MainData.GetTradeDate(tmpDateTime);
      tmpTitleItems[tmpCount].m_lColor := Display.TimeLineColor;
      if tmpIsGetDate then
        tmpTitleItems[tmpCount].m_lText := FormatDateTime('YYYY/MM/DD',
          tmpDateTime)
      else
        tmpTitleItems[tmpCount].m_lText := '';
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpTitleItems[tmpCount].m_lColor := Display.TimeLineColor;
      tmpTitleItems[tmpCount].m_lText := Const_Time_TrendLine_Name;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      Inc(tmpCount);
      tmpTitleItems[tmpCount].m_lColor := Display.AverageLineColor;
      if (tmpInnerCode = Const_InnerCode_Index_SH) or
        (tmpInnerCode = Const_InnerCode_Index_SZ) then
        tmpTitleItems[tmpCount].m_lText := Const_Time_LeadLine_Name
      else
        tmpTitleItems[tmpCount].m_lText := Const_Time_AverageLine_Name;
      tmpTitleItems[tmpCount].m_lIsNeedSpace := True;
      tmpTitleItems[tmpCount].m_lHeight := Display.TextFont.Height;

      DrawText(TitleRect, tmpTitleItems);
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawToolButtons;
begin
  if Assigned(FTitleButtons) then
  begin
    FTitleButtons.UpdataRect;
    FTitleButtons.DrawIcons;
  end;
end;

procedure TQuoteTimeMinute.DrawYRuler;
var
  tmpMainData: TTimeData;
begin
  with FTimeGraphs do
  begin
    if (Display.MainGraphYAxisType = atSymmetry) then
      DrawSymmetryYRuler
    else if Display.MainGraphYAxisType = atFullAxis then
      DrawFullAxisYRuler
    else
    begin
      tmpMainData := QuoteTimeData.MainData;
      if Assigned(tmpMainData) and tmpMainData.HasLimitAixs then
        DrawLimitAxisYRuler
      else
        DrawSymmetryYRuler;
    end;
  end;
end;

procedure TQuoteTimeMinute.DrawSymmetryYRuler;
var
  tmpLineCount, tmpIndex, tmpRulerLeft, tmpRulerRight: Integer;
  tmpUnitHeight, tmpUpY, tmpDownY: Double;
  tmpValue: string;
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    tmpRect := DrawGraphRect;
    tmpRulerLeft := tmpRect.Left - Display.YRulerSpace;
    tmpRulerRight := tmpRect.Right + Display.YRulerSpace;
    tmpLineCount := LineCount[Trunc(tmpRect.Height / 2)];
    tmpUnitHeight := tmpRect.Height / (2 * tmpLineCount);
    tmpUpY := tmpRect.Top + tmpRect.Height / 2;
    tmpDownY := tmpUpY;

    G32Graphic.EmptyPolyText('Miunte.DrawYRulerScale.Up');
    G32Graphic.EmptyPolyText('Miunte.DrawYRulerScale.Down');
    G32Graphic.EmptyPolyText('Miunte.DrawYRulerScale.Equal');
    G32Graphic.EmptyPolyPoly('Miunte.DrawYRulerMiddleLine');
    G32Graphic.EmptyPolyPoly('Miunte.DrawYRulerLine');

    // Draw lines in the area in the middle
    DrawYRulerLine('Miunte.DrawYRulerMiddleLine', tmpRect.Left, tmpRect.Right,
      Trunc(tmpUpY));
    DrawYRulerLine('Miunte.DrawYRulerMiddleLine', tmpRect.Left, tmpRect.Right,
      Trunc(tmpUpY) + 1);

    tmpValue := Format(Display.PriceFormat, [FBaseValue]);
    DrawYRulerScale('Miunte.DrawYRulerScale.Equal', tmpValue,
      tmpRect.Left - YRulerWidth, tmpRulerLeft, Trunc(tmpUpY), gtaRight);

    if FTimeGraphs.Display.ShowMode <> smMulitStock then
    begin
      tmpValue := Format(Display.HighsLowsRangeFormat,
        [CalcPerValue(FBaseValue, 100)]);
      DrawYRulerScale('Miunte.DrawYRulerScale.Equal', tmpValue, tmpRulerRight,
        tmpRect.Right + YRulerWidth, Trunc(tmpUpY), gtaLeft);
    end;

    for tmpIndex := 1 to tmpLineCount do
    begin
      tmpUpY := tmpUpY - tmpUnitHeight;
      tmpDownY := tmpDownY + tmpUnitHeight;

      // Draw lines up from the middle area
      DrawYRulerLine('Miunte.DrawYRulerLine', tmpRect.Left, tmpRect.Right,
        Trunc(tmpUpY));
      // Draw lines Down from the middle area
      DrawYRulerLine('Miunte.DrawYRulerLine', tmpRect.Left, tmpRect.Right,
        Trunc(tmpDownY));

      // Draw Left up Scale
      if tmpIndex < tmpLineCount then
        tmpValue := Format(Display.PriceFormat, [YToValue(tmpUpY)])
      else
        tmpValue := Format(Display.PriceFormat, [FMaxValue]);

      DrawYRulerScale('Miunte.DrawYRulerScale.Up', tmpValue,
        tmpRect.Left - YRulerWidth, tmpRulerLeft, Trunc(tmpUpY), gtaRight);

      // Draw Left Down Scale
      if tmpIndex < tmpLineCount then
        tmpValue := Format(Display.PriceFormat, [YToValue(tmpDownY)])
      else
        tmpValue := Format(Display.PriceFormat, [FMinValue]);
      DrawYRulerScale('Miunte.DrawYRulerScale.Down', tmpValue,
        tmpRect.Left - YRulerWidth, tmpRulerLeft, Trunc(tmpDownY), gtaRight);

      if FTimeGraphs.Display.ShowMode <> smMulitStock then
      begin
        // Draw right up Scale
        if tmpIndex < tmpLineCount then
          tmpValue := Format(Display.HighsLowsRangeFormat,
            [CalcPerValue(YToValue(tmpUpY), 100)])
        else
          tmpValue := Format(Display.HighsLowsRangeFormat,
            [CalcPerValue(FMaxValue, 100)]);

        DrawYRulerScale('Miunte.DrawYRulerScale.Up', tmpValue, tmpRulerRight,
          tmpRect.Right + YRulerWidth, Trunc(tmpUpY), gtaLeft);

        // Draw Right Down Scale
        if tmpIndex < tmpLineCount then
          tmpValue := Format(Display.HighsLowsRangeFormat,
            [CalcPerValue(YToValue(tmpDownY), 100)])
        else
          tmpValue := Format(Display.HighsLowsRangeFormat,
            [CalcPerValue(FMinValue, 100)]);

        DrawYRulerScale('Miunte.DrawYRulerScale.Down', tmpValue, tmpRulerRight,
          tmpRect.Right + YRulerWidth, Trunc(tmpDownY), gtaLeft);
      end;
    end;

    G32Graphic.LineColor := Display.RegionDivideLineColor;
    G32Graphic.DrawPolyPolyLine('Miunte.DrawYRulerMiddleLine');

    G32Graphic.BackColor := Display.BackColor;
    G32Graphic.LineColor := Display.GridLineColor;
    G32Graphic.DrawPolyPolyLine('Miunte.DrawYRulerLine');
    // G32Graphic.DrawPolyPolyDotLine('Miunte.DrawYRulerLine');
    G32Graphic.LineColor := Display.EqualColor;
    G32Graphic.DrawPolyText('Miunte.DrawYRulerScale.Equal');
    G32Graphic.LineColor := Display.UpColor;
    G32Graphic.DrawPolyText('Miunte.DrawYRulerScale.Up');
    G32Graphic.LineColor := Display.DownColor;
    G32Graphic.DrawPolyText('Miunte.DrawYRulerScale.Down');
  end;
end;

procedure TQuoteTimeMinute.DrawFullAxisYRuler;
var
  tmpLineCount, tmpIndex, tmpCmp, tmpRulerLeft, tmpRulerRight: Integer;
  tmpUnitHeight, tmpY, tmpValue: Double;
  tmpDrawKey, tmpText: string;
  tmpRect: TRect;
begin
  with FTimeGraphs do
  begin
    tmpRect := DrawGraphRect;
    tmpRulerLeft := tmpRect.Left - Display.YRulerSpace;
    tmpRulerRight := tmpRect.Right + Display.YRulerSpace;
    tmpLineCount := LineCount[tmpRect.Height];
    tmpUnitHeight := tmpRect.Height / tmpLineCount;
    tmpY := tmpRect.Top;

    G32Graphic.EmptyPolyText('Minute.DrawYRulerScale.Up');
    G32Graphic.EmptyPolyText('Minute.DrawYRulerScale.Down');
    G32Graphic.EmptyPolyText('Minute.DrawYRulerScale.Equal');
    G32Graphic.EmptyPolyPoly('Minute.DrawYRulerLine');

    for tmpIndex := 0 to tmpLineCount do
    begin
      if (tmpIndex > 0) and (tmpIndex < tmpLineCount) then
        tmpValue := YToValue(tmpY)
      else if tmpIndex = 0 then
        tmpValue := FMaxValue
      else
        tmpValue := FMinValue;

      tmpCmp := CompareValue(tmpValue, FBaseValue);

      if tmpCmp = 1 then
        tmpDrawKey := 'Minute.DrawYRulerScale.Up'
      else if tmpCmp = -1 then
        tmpDrawKey := 'Minute.DrawYRulerScale.Down'
      else
        tmpDrawKey := 'Minute.DrawYRulerScale.Equal';

      tmpText := Format(Display.PriceFormat, [tmpValue]);
      DrawYRulerScale(tmpDrawKey, tmpText, tmpRect.Left - YRulerWidth,
        tmpRulerLeft, Trunc(tmpY), gtaRight);

      tmpText := Format(Display.HighsLowsRangeFormat,
        [CalcPerValue(tmpValue, 100)]);
      DrawYRulerScale(tmpDrawKey, tmpText, tmpRulerRight,
        tmpRect.Right + YRulerWidth, Trunc(tmpY), gtaLeft);

      DrawYRulerLine('Minute.DrawYRulerLine', tmpRect.Left, tmpRect.Right,
        Trunc(tmpY));
      tmpY := tmpY + tmpUnitHeight;
    end;
    G32Graphic.LineColor := Display.UpColor;
    G32Graphic.DrawPolyText('Minute.DrawYRulerScale.Up');
    G32Graphic.LineColor := Display.DownColor;
    G32Graphic.DrawPolyText('Minute.DrawYRulerScale.Down');
    G32Graphic.LineColor := Display.EqualColor;
    G32Graphic.DrawPolyText('Minute.DrawYRulerScale.Equal');

    G32Graphic.BackColor := Display.BackColor;
    G32Graphic.LineColor := Display.GridLineColor;
    // G32Graphic.DrawPolyPolyLine('Minute.DrawYRulerLine');
    G32Graphic.DrawPolyPolyDotLine('Minute.DrawYRulerLine');
  end;
end;

procedure TQuoteTimeMinute.DrawLimitAxisYRuler;
begin
  DrawSymmetryYRuler;
end;

function TQuoteTimeMinute.ValueToY(_Value: Double): Integer;
begin
  Result := Trunc(DrawGraphRect.Top + (_Value - FMaxValue) * FScaleY);
end;

function TQuoteTimeMinute.YToValue(_Y: Double): Double;
var
  tmpTop: Integer;
begin
  with FTimeGraphs do
  begin
    tmpTop := DrawGraphRect.Top;
    if FScaleY <> 0 then
      Result := (_Y - tmpTop) / FScaleY + FMaxValue
    else
      Result := 0;
  end;
end;

function TQuoteTimeMinute.TrendValueToY(_Value: Double): Integer;
begin
  Result := Trunc((DrawGraphRect.Top + DrawGraphRect.Bottom) div 2 - _Value *
    FTrendScaleY);
end;

procedure TQuoteTimeMinute.UpdateSkin;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  with FTimeGraphs do
  begin
    if (Display.ShowMode = smNormal) then
    begin
      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
      try
        while tmpTimeIconEnum.MoveNext do
        begin
          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
          if Assigned(tmpTimeIcon) then
            tmpTimeIcon.UpdateSkin;
        end;
      finally
        FreeAndNil(tmpTimeIconEnum);
      end;
    end;
  end;
end;

function TQuoteTimeMinute.YToYRulerHint(_Y: Integer;
  var _LHint, _RHint: string): Boolean;
begin
  with FTimeGraphs do
  begin
    Result := True;
    if FBaseValue > 0 then
      _LHint := Format(Display.PriceFormat, [YToValue(_Y)])
    else
      _LHint := '0.00';
    _RHint := Format(Display.HighsLowsRangeFormat,
      [CalcPerValue(YToValue(_Y), 100)]);
  end;
end;

function TQuoteTimeMinute.IndexToRulerHint(_DataIndex, _Index: Integer;
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
      tmpData.GetValue(dkPrice, _Index, tmpValue, tmpCompareValue);
      _LHint := Format(Display.PriceFormat, [tmpValue]);
      _RHint := Format(Display.HighsLowsRangeFormat,
        [CalcPerValue(tmpValue, 100)]);
    end;
  end;
end;

procedure TQuoteTimeMinute.DataArrive(_DataSet: IWNDataSet; _DataTag: Integer);
var
  tmpTimeIcon: TQuoteTimeIcon;
begin
  case _DataTag of
    Const_IndexTag_MinePoint:
      begin
        tmpTimeIcon := FTimeIconsHash[Const_TimeIcon_Information];
        if Assigned(tmpTimeIcon) then
          tmpTimeIcon.DataArrive(_DataSet);
      end;
    Const_IndexTag_TradePoint:
      begin
        tmpTimeIcon := FTimeIconsHash[Const_TimeIcon_Transaction];
        if Assigned(tmpTimeIcon) then
          tmpTimeIcon.DataArrive(_DataSet);
      end;
  else

  end;
end;

procedure TQuoteTimeMinute.ToolsMouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint);
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  with FTimeGraphs do
  begin
    if Display.ShowMode = smNormal then
    begin
      if Assigned(FTitleButtons) then
        FTitleButtons.MouseMoveOperate(Shift, _Pt);

      if Assigned(FTimeIconsHash) then
      begin
        tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
        try
          while tmpTimeIconEnum.MoveNext do
          begin
            tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
            if Assigned(tmpTimeIcon) then
              tmpTimeIcon.MouseMoveOperate(Shift, _Pt);
          end;
        finally
          FreeAndNil(tmpTimeIconEnum);
        end;
      end;
    end;
  end;
end;

procedure TQuoteTimeMinute.ToolsMouseUpOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint);
begin
  if (FTimeGraphs.Display.ShowMode = smNormal) and Assigned(FTitleButtons) then
    FTitleButtons.MouseUpOperate(Button, Shift, _Pt);
end;

procedure TQuoteTimeMinute.MouseLeave;
var
  tmpTimeIcon: TQuoteTimeIcon;
  tmpTimeIconEnum: TDictionary<string, TQuoteTimeIcon>.TPairEnumerator;
begin
  if FTimeGraphs.Display.ShowMode = smNormal then
  begin
    if Assigned(FTitleButtons) then
      FTitleButtons.MouseLeave;
    if Assigned(FTimeIconsHash) then
    begin
      tmpTimeIconEnum := FTimeIconsHash.GetEnumerator;
      try
        while tmpTimeIconEnum.MoveNext do
        begin
          tmpTimeIcon := FTimeIconsHash[tmpTimeIconEnum.Current.Key];
          if Assigned(tmpTimeIcon) then
            tmpTimeIcon.MouseLeave;
        end;
      finally
        FreeAndNil(tmpTimeIconEnum);
      end;
    end;
  end;
end;

end.
