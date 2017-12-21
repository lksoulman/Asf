unit QuoteTimeDisplay;

interface

uses
  Windows,
  SysUtils,
  Graphics,
  AppContext,
  QuoteCommLibrary,
  QuoteTimeStruct,
  CommonFunc,
  BaseObject;

type

  // QuoteTimeDisplay
  TQuoteTimeDisplay = class(TBaseObject)
  private
  protected
    function GetColors(_Index: Integer): TColor;
  public
    FSkinStyle: string;

    ShowMode: TQuoteShowMode; // 分时图模式
    MainGraphYAxisType: TAxisType; // Y 轴标尺类型
    BorderLine: TQuoteBorderLine; // 边框
    MaxDayCount: Integer; // 最多显示的天数

    // 控制显示不显示
    AuctionVisible: Boolean; // 集合竞价是否显示
    InfoMineVisible: Boolean; // 信息地雷是否显示
    CrossLineVisible: Boolean; // 十字线是否显示
    TradePointVisible: Boolean; // 成交打点是否显示
    CurrentPriceVisible: Boolean; // 现价是否显示

    // Format函数格式参数
    PriceFormat: string; // 价格 格式方式
    HighsLowsFormat: string; // 涨跌 格式方式
    HighsLowsRangeFormat: string; // 涨跌幅 格式方式
    LowWanFormat: string; // 小于万 格式方式
    LowWanVolumeFormat: string; // 小于万 格式方式
    HighWanFormat: string; // 大于万 格式方式
    HighYiFormat: string; // 大于亿 格式方式

    // FormatFloat函数格式参数
    HightLowsFormatFloat: string;
    HighsLowsRangeFormatFloat: string;

    // 用 FormatDateTime 函数格式
    MonthDayFormat: string; // 某天 格式方式
    HourMinuteFormat: string; // 格式小时和分钟

    // 宽度
    YAxisCharCount: Integer; // Y 轴左右两侧宽度占字符个数
    XAxisScaleIntervalCharCount: Integer; // X 轴的刻度线之间的最小宽度占字符个数
    CrossDetailCharCount: Integer; // 十字线明细提示窗口宽度占字符的个数

    // 高度
    TitleRectHeight: Integer; // 标题区域的高度
    IconRectHeight: Integer; // 图标区域的高度
    GirdLineDistanceHeight: Integer; // 网格线之间的高度

    // 增量
    PricePercentIncrement: Double; // 画分时区域Y轴标尺，当现价最大和最小值相同时的固定增量
    VolumeIncrement: Integer; // 画成交量区域Y轴标尺，当最大成交量为0时的固定增量

    // 配置皮肤颜色
    TextFont: TFont; // 文本类型字体
    NumberFont: TFont; // 数字类型字体

    // 背景
    BackColor: TColor; // 整体背景颜色
    TitleBackColor: TColor; // 标题区域背景色
    HistoryBackColor: TColor; // 历史背景颜色
    AuctionBackColor: TColor; // 集合竞价的背景颜色
    CrossDetailBackColor: TColor; // 十字线提示明细背景颜色
    CrossXYRulerHintBackColor: TColor; // 十字线标尺提示背景色
    CurrentPriceHintBackColor: TColor; // 现价提示背景色
    VolumeButtonBackColor: TColor; // 成交量按钮背景颜色
    VolumeButtonFocusBackColor: TColor; // 成交量按钮聚焦背景颜色

    // 线颜色
    BorderLineColor: TColor; // 边框线颜色
    RegionDivideLineColor: TColor; // 区域分割线
    CenterRegionFrameLineColor: TColor; // 中心区域边框线颜色
    TitleFrameLineColor: TColor; // 标题颜色
    CrossDetailFrameLineColor: TColor; // 十字线提示明细边框线颜色
    CrossXYRulerHintFrameLineColor: TColor; // 十字线标尺提示边框线颜色
    CurrentPriceHintFrameLineColor: TColor; // 现价提示边框线颜色
    CrossLineColor: TColor; // 十字线颜色
    GridLineColor: TColor; // 网格线颜色
    TimeLineColor: TColor; // 分时走势线颜色
    AverageLineColor: TColor; // 均价走势线颜色

    // 字体颜色
    StopFlagTextColor: TColor; // 停牌文字颜色
    StockNameTextColor: TColor; // 证券名称颜色
    SelfStockNameTextColor: TColor; // 自选证券名称颜色
    SelfStockCodeTextColor: TColor;
    CrossDetailTextColor: TColor; // 十字线提示明细文字颜色
    CrossDetailVolumeColor: TColor; // 提示明细窗体成交量的颜色
    CrossDetailDateTimeColor: TColor; // 提示明细窗体时间的颜色
    CrossXYRulerHintTextColor: TColor; // 十字线标尺提示文字颜色
    YRulerTextColor: TColor; // 成交量Y轴提示文字颜色
    VolumeButtonTextColor: TColor; // 成交量按钮文字颜色
    VolumeButtonFocusTextColor: TColor; // 成交量按钮聚焦文字颜色

    // 图标颜色
    InfoMineIconColor: TColor; // 信息地雷颜色

    UpColor: TColor; // 上涨颜色
    DownColor: TColor; // 下跌颜色
    EqualColor: TColor; // 相等颜色
    DownEqualUpColors: array [-1 .. 1] of TColor;
    VolumeColors: array [-1 .. 1] of TColor;

    // 渐进颜色
    ShadowRValue: Double;
    ShadowGValue: Double;
    ShadowBValue: Double;
    ShadowRValueInc: Double;
    ShadowGValueInc: Double;
    ShadowBValueInc: Double;
    ShadowBackColors: array [1 .. 60] of TColor;

    TitleTextSpace: Integer; // 快捷菜单之间的间隔
    TitleIconSpace: Integer;
    YRulerSpace: Integer;
    XEdgeSpace: Integer;
    YEdgeSpace: Integer;
    FDecimal: Integer;

    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;
    procedure ChangeStockType(StockType: TStockType);
    procedure ChangeFutureDecimal(Decimal: Integer);
    procedure UpdateSkin;

    property Colors[_Index: Integer]: TColor read GetColors;
  end;

implementation

{ TQuoteTimeDisplay }

constructor TQuoteTimeDisplay.Create(AContext: IAppContext);
var
  tmpIndex: Integer;
begin
  inherited;
  FSkinStyle := '';
  ShowMode := smSimple;
  MainGraphYAxisType := atSymmetry;
  BorderLine := [];
  MaxDayCount := 8;

  // 控制显示不显示
  AuctionVisible := False;
  InfoMineVisible := True;
  CrossLineVisible := True;
  TradePointVisible := True;
  CurrentPriceVisible := True;

  // Format函数格式参数
  PriceFormat := '%0.3f';
  HighsLowsFormat := '%0.3f';
  HighsLowsRangeFormat := '%0.2f%%';
  LowWanFormat := '%0.3f';
  LowWanVolumeFormat := '%.0f';
  HighWanFormat := '%0.3f万';
  HighYiFormat := '%0.3f亿';

  // FormatFloat函数格式参数
  HightLowsFormatFloat := '+0.000;-0.000;0.000';
  HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

  // 宽度
  YAxisCharCount := 9;
  XAxisScaleIntervalCharCount := 5;
  CrossDetailCharCount := 15;

  // 用 FormatDateTime 函数格式
  MonthDayFormat := 'MM"/"DD';
  HourMinuteFormat := 'hh:nn';

  // 高度
  TitleRectHeight := 22;
  IconRectHeight := 10;
  GirdLineDistanceHeight := 25;

  // 增量
  PricePercentIncrement := 0.02;
  VolumeIncrement := 10;

  TitleTextSpace := 10;
  TitleIconSpace := 6;
  YRulerSpace := 5;
  XEdgeSpace := 6;
  YEdgeSpace := 3;

  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -12;

  NumberFont := TFont.Create;
  NumberFont.Name := 'Times New Roman';
  NumberFont.Charset := GB2312_CHARSET;
  NumberFont.Height := -12;

  // white Skin
  // 填充背景色
  BackColor := $FFFFFF;
  TitleBackColor := $FFFFFF;
  HistoryBackColor := $FFFFFF;
  AuctionBackColor := $F5F5F5;
  CrossDetailBackColor := $F8F8F8;
  CrossXYRulerHintBackColor := $FAFAFA;
  CurrentPriceHintBackColor := $D4EEFF;
  VolumeButtonBackColor := $E1E1E1;
  VolumeButtonFocusBackColor := $0090FD;

  // 线颜色
  BorderLineColor := $CCCCCC;
  RegionDivideLineColor := $BEBEBE;
  CenterRegionFrameLineColor := $E5E5E5;
  TitleFrameLineColor := $E8E8E8;
  CrossDetailFrameLineColor := $D2D2D2;
  CrossXYRulerHintFrameLineColor := $C8C8C8;
  CurrentPriceHintFrameLineColor := $098AFD;
  CrossLineColor := $BEB6B2;
  GridLineColor := $E5E5E5;
  TimeLineColor := $CC8535;
  AverageLineColor := $2D96FF;

  // 字体颜色
  StopFlagTextColor := $E1E1E1;
  StockNameTextColor := $404040;
  SelfStockNameTextColor := $E68826;
  CrossDetailTextColor := $000000;
  CrossXYRulerHintTextColor := $404040;
  YRulerTextColor := $404040;
  VolumeButtonTextColor := $969696;
  VolumeButtonFocusTextColor := $FFFFFF;

  // 图标颜色
  InfoMineIconColor := $F1BF27;

  // 红涨 平 绿跌  颜色
  DownColor := $00A80C;
  EqualColor := $404040;
  UpColor := $0000FF;
  DownEqualUpColors[-1] := DownColor;
  DownEqualUpColors[0] := EqualColor;
  DownEqualUpColors[1] := UpColor;

  // 渐进颜色
  ShadowRValue := 255;
  ShadowGValue := 255;
  ShadowBValue := 255;
  ShadowRValueInc := -2;
  ShadowGValueInc := -1;
  ShadowBValueInc := 0;
  for tmpIndex := Low(ShadowBackColors) to High(ShadowBackColors) do
  begin
    ShadowBackColors[tmpIndex] := RGB(Trunc(ShadowRValue), Trunc(ShadowGValue),
      Trunc(ShadowBValue));
    ShadowRValue := ShadowRValue + ShadowRValueInc;
    ShadowGValue := ShadowGValue + ShadowGValueInc;
    ShadowBValue := ShadowBValue + ShadowBValueInc;
  end;

  // // black Skin
  // // 填充背景色
  // BackColor := $1A1A1A;
  // TitleBackColor := $1A1A1A;
  // HistoryBackColor := $1A1A1A;
  // AuctionBackColor := $1A1A1A;
  // CrossDetailBackColor := $242424;
  // CrossXYRulerHintBackColor := $524336;
  // CurrentPriceHintBackColor := $524336;
  // VolumeButtonBackColor := $6D6058;
  // VolumeButtonFocusBackColor := $BF6A20;
  //
  // // 线颜色
  // BorderLineColor := $535353;
  // RegionDivideLineColor := $0D0D0D;
  // CenterRegionFrameLineColor := $131313;
  // TitleFrameLineColor := $131313;
  // CrossDetailFrameLineColor := $131313;
  // CrossXYRulerHintFrameLineColor := $524336;
  // CurrentPriceHintFrameLineColor := $524336;
  // CrossLineColor := $716252;
  // GridLineColor := $131313;
  // TimeLineColor := $CC8535;
  // AverageLineColor := $2D96FF;
  //
  // // 字体颜色
  // StopFlagTextColor := $E6E6E6;
  // StockNameTextColor := $E6E6E6;
  // SelfStockNameTextColor := $E68826;
  // CrossDetailTextColor := $E6E6E6;
  // CrossXYRulerHintTextColor := $E6E6E6;
  // YRulerTextColor := $E6E6E6;
  // VolumeButtonTextColor := $969696;
  // VolumeButtonFocusTextColor := $FFCC66;
  //
  // // 图标颜色
  // InfoMineIconColor := $F1BF27;
  //
  // // 红涨 平 绿跌  颜色
  // DownColor := $00A80C;
  // EqualColor := $E6E6E6;
  // UpColor := $0000FF;
  // DownEqualUpColors[-1] := DownColor;
  // DownEqualUpColors[0] := EqualColor;
  // DownEqualUpColors[1] := UpColor;
  //
  // // 渐进颜色
  // ShadowRValue := 26;
  // ShadowGValue := 46;
  // ShadowBValue := 26;
  // ShadowRValueInc := 0.5;
  // ShadowGValueInc := -0.5;
  // ShadowBValueInc := 1;
  // for tmpIndex := Low(ShadowBackColors) to High(ShadowBackColors) do
  // begin
  // ShadowBackColors[tmpIndex] := RGB(Trunc(ShadowRValue), Trunc(ShadowGValue),
  // Trunc(ShadowBValue));
  // ShadowRValue := ShadowRValue + ShadowRValueInc;
  // ShadowGValue := ShadowGValue + ShadowGValueInc;
  // ShadowBValue := ShadowBValue + ShadowBValueInc;
  // end;
end;

destructor TQuoteTimeDisplay.Destroy;
begin
  if Assigned(NumberFont) then
    NumberFont.Free;
  if Assigned(TextFont) then
    TextFont.Free;
  inherited;
end;

procedure TQuoteTimeDisplay.ChangeStockType(StockType: TStockType);
begin
//  if StockType = stFutures then
//  begin
//    // Format函数格式参数
//    PriceFormat := '%0.1f';
//    HighsLowsFormat := '%0.3f';
//    HighsLowsRangeFormat := '%0.2f%%';
//    LowWanFormat := '%0.3f';
//    LowWanVolumeFormat := '%.0f';
//    HighWanFormat := '%0.3f万';
//    HighYiFormat := '%0.3f亿';
//
//    // FormatFloat函数格式参数
//    HightLowsFormatFloat := '+0.000;-0.000;0.000';
//    HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';
//
//    // 宽度
//    YAxisCharCount := 9;
//    XAxisScaleIntervalCharCount := 5;
//    CrossDetailCharCount := 15;
//  end
//  else
//  begin
//    // Format函数格式参数
//    PriceFormat := '%0.3f';
//    HighsLowsFormat := '%0.3f';
//    HighsLowsRangeFormat := '%0.2f%%';
//    LowWanFormat := '%0.3f';
//    LowWanVolumeFormat := '%.0f';
//    HighWanFormat := '%0.3f万';
//    HighYiFormat := '%0.3f亿';
//
//    // FormatFloat函数格式参数
//    HightLowsFormatFloat := '+0.000;-0.000;0.000';
//    HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';
//
//    // 宽度
//    YAxisCharCount := 9;
//    XAxisScaleIntervalCharCount := 5;
//    CrossDetailCharCount := 15;
//  end;

end;

procedure TQuoteTimeDisplay.ChangeFutureDecimal(Decimal: Integer);
begin
  if FDecimal <> Decimal then
  begin
    if Decimal = 1 then
    begin
      // Format函数格式参数
      PriceFormat := '%0.1f';
      HighsLowsFormat := '%0.3f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.3f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.3f万';
      HighYiFormat := '%0.3f亿';

      // FormatFloat函数格式参数
      HightLowsFormatFloat := '+0.000;-0.000;0.000';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // 宽度
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else if Decimal = 2 then
    begin
      // Format函数格式参数
      PriceFormat := '%0.2f';
      HighsLowsFormat := '%0.2f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.2f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.2f万';
      HighYiFormat := '%0.2f亿';

      // FormatFloat函数格式参数
      HightLowsFormatFloat := '+0.00;-0.00;0.00';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // 宽度
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else if Decimal = -1 then    // 美股
    begin
      // Format函数格式参数
      PriceFormat := '%0.3f';
      HighsLowsFormat := '%0.2f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.2f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.2f万';
      HighYiFormat := '%0.2f亿';

      // FormatFloat函数格式参数
      HightLowsFormatFloat := '+0.00;-0.00;0.00';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // 宽度
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else
    begin
      // Format函数格式参数
      PriceFormat := '%0.3f';
      HighsLowsFormat := '%0.3f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.3f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.3f万';
      HighYiFormat := '%0.3f亿';

      // FormatFloat函数格式参数
      HightLowsFormatFloat := '+0.000;-0.000;0.000';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // 宽度
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end;
    FDecimal := Decimal;
  end;
end;

function TQuoteTimeDisplay.GetColors(_Index: Integer): TColor;
begin
  case _Index of
    0:
      Result := RGB(178, 94, 235);
    1:
      Result := RGB(255, 72, 0);
    2:
      Result := RGB(73, 173, 133);
    3:
      Result := RGB(69, 233, 255);
  else
    Result := RGB(12, 168, 0);
  end;
end;

procedure TQuoteTimeDisplay.UpdateSkin;
const
  Const_Time_Prefix = 'Time_';
var
  tmpIndex: Integer;
  tmpSkinStyle: string;

//  function GetStrFromConfig(_Key: WideString): string;
//  begin
//    Result := FAppContext.GetResourceSkin.get;//FGilAppController.Config(ctSkin, Const_Time_Prefix + _Key);
//  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_Time_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_Time_Prefix + _Key), 0));
  end;

//  function GetIntFromConfig(_Key: WideString): Integer;
//  begin
//    Result := StrToIntDef(FGilAppController.Config(ctSkin,
//      Const_Time_Prefix + _Key), 0);
//  end;

  function GetFloatFromConfig(_Key: WideString): Double;
  begin
    Result := StrToFloatDef(FAppContext.GetResourceSkin.GetConfig(Const_Time_Prefix + _Key), 0);
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;
//      TextFont.Name := GetStrFromConfig('TextFontName');
      // TextFont.Height := GetIntFromConfig('TextFontHeight');

      BackColor := GetColorFromConfig('BackColor');
      TitleBackColor := GetColorFromConfig('TitleBackColor');
      HistoryBackColor := GetColorFromConfig('HistoryBackColor');
      AuctionBackColor := GetColorFromConfig('AuctionBackColor');
      CrossDetailBackColor := GetColorFromConfig('CrossDetailBackColor');
      CrossXYRulerHintBackColor :=
        GetColorFromConfig('CrossXYRulerHintBackColor');
      CurrentPriceHintBackColor :=
        GetColorFromConfig('CurrentPriceHintBackColor');
      VolumeButtonBackColor := GetColorFromConfig('VolumeButtonBackColor');
      VolumeButtonFocusBackColor :=
        GetColorFromConfig('VolumeButtonFocusBackColor');

      // 线颜色
      BorderLineColor := GetColorFromConfig('BorderLineColor');
      RegionDivideLineColor := GetColorFromConfig('RegionDivideLineColor');
      CenterRegionFrameLineColor :=
        GetColorFromConfig('CenterRegionFrameLineColor');
      TitleFrameLineColor := GetColorFromConfig('TitleFrameLineColor');
      CrossDetailFrameLineColor :=
        GetColorFromConfig('CrossDetailFrameLineColor');
      CrossXYRulerHintFrameLineColor :=
        GetColorFromConfig('CrossXYRulerHintFrameLineColor');
      CurrentPriceHintFrameLineColor :=
        GetColorFromConfig('CurrentPriceHintFrameLineColor');
      CrossLineColor := GetColorFromConfig('CrossLineColor');
      GridLineColor := GetColorFromConfig('GridLineColor');
      TimeLineColor := GetColorFromConfig('TimeLineColor');
      AverageLineColor := GetColorFromConfig('AverageLineColor');

      // 字体颜色
      StopFlagTextColor := GetColorFromConfig('StopFlagTextColor');
      StockNameTextColor := GetColorFromConfig('StockNameTextColor');
      SelfStockNameTextColor := GetColorFromConfig('SelfStockNameTextColor');
      SelfStockCodeTextColor := GetColorFromConfig('SelfStockCodeTextColor');
      CrossDetailTextColor := GetColorFromConfig('CrossDetailTextColor');
      CrossDetailVolumeColor := GetColorFromConfig('CrossDetailVolumeColor');
      CrossDetailDateTimeColor :=
        GetColorFromConfig('CrossDetailDateTimeColor');
      CrossXYRulerHintTextColor :=
        GetColorFromConfig('CrossXYRulerHintTextColor');
      YRulerTextColor := GetColorFromConfig('YRulerTextColor');
      VolumeButtonTextColor := GetColorFromConfig('VolumeButtonTextColor');
      VolumeButtonFocusTextColor :=
        GetColorFromConfig('VolumeButtonFocusTextColor');

      // 图标颜色
      InfoMineIconColor := GetColorFromConfig('InfoMineIconColor');

      // 红涨 平 绿跌  颜色
      DownColor := GetColorFromConfig('DownColor');
      EqualColor := GetColorFromConfig('EqualColor');
      UpColor := GetColorFromConfig('UpColor');
      DownEqualUpColors[-1] := DownColor;
      DownEqualUpColors[0] := EqualColor;
      DownEqualUpColors[1] := UpColor;
      VolumeColors[-1] := GetColorFromConfig('VolumeDownColor');
      VolumeColors[0] := GetColorFromConfig('VolumeEqualColor');
      VolumeColors[1] := GetColorFromConfig('VolumeUpColor');

      // 渐进颜色
      ShadowRValue := GetFloatFromConfig('ShadowRValue');
      ShadowGValue := GetFloatFromConfig('ShadowGValue');
      ShadowBValue := GetFloatFromConfig('ShadowBValue');
      ShadowRValueInc := GetFloatFromConfig('ShadowRValueInc');
      ShadowGValueInc := GetFloatFromConfig('ShadowGValueInc');
      ShadowBValueInc := GetFloatFromConfig('ShadowBValueInc');
      for tmpIndex := Low(ShadowBackColors) to High(ShadowBackColors) do
      begin
        ShadowBackColors[tmpIndex] := RGB(Trunc(ShadowRValue),
          Trunc(ShadowGValue), Trunc(ShadowBValue));
        if tmpIndex < 30 then
        begin
          ShadowRValue := ShadowRValue + ShadowRValueInc;
          ShadowGValue := ShadowGValue + ShadowGValueInc;
          ShadowBValue := ShadowBValue + ShadowBValueInc;
        end;
      end;
    end;
    if FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FFontRatio = Const_ScreenResolution_1080P then
    begin
      TextFont.Height := -14;
    end
    else if FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FFontRatio = Const_ScreenResolution_768P then
    begin
      TextFont.Height := -12;
    end;
//  end;
end;

end.
