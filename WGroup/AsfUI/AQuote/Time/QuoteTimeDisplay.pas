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

    ShowMode: TQuoteShowMode; // ��ʱͼģʽ
    MainGraphYAxisType: TAxisType; // Y ��������
    BorderLine: TQuoteBorderLine; // �߿�
    MaxDayCount: Integer; // �����ʾ������

    // ������ʾ����ʾ
    AuctionVisible: Boolean; // ���Ͼ����Ƿ���ʾ
    InfoMineVisible: Boolean; // ��Ϣ�����Ƿ���ʾ
    CrossLineVisible: Boolean; // ʮ�����Ƿ���ʾ
    TradePointVisible: Boolean; // �ɽ�����Ƿ���ʾ
    CurrentPriceVisible: Boolean; // �ּ��Ƿ���ʾ

    // Format������ʽ����
    PriceFormat: string; // �۸� ��ʽ��ʽ
    HighsLowsFormat: string; // �ǵ� ��ʽ��ʽ
    HighsLowsRangeFormat: string; // �ǵ��� ��ʽ��ʽ
    LowWanFormat: string; // С���� ��ʽ��ʽ
    LowWanVolumeFormat: string; // С���� ��ʽ��ʽ
    HighWanFormat: string; // ������ ��ʽ��ʽ
    HighYiFormat: string; // ������ ��ʽ��ʽ

    // FormatFloat������ʽ����
    HightLowsFormatFloat: string;
    HighsLowsRangeFormatFloat: string;

    // �� FormatDateTime ������ʽ
    MonthDayFormat: string; // ĳ�� ��ʽ��ʽ
    HourMinuteFormat: string; // ��ʽСʱ�ͷ���

    // ���
    YAxisCharCount: Integer; // Y ������������ռ�ַ�����
    XAxisScaleIntervalCharCount: Integer; // X ��Ŀ̶���֮�����С���ռ�ַ�����
    CrossDetailCharCount: Integer; // ʮ������ϸ��ʾ���ڿ��ռ�ַ��ĸ���

    // �߶�
    TitleRectHeight: Integer; // ��������ĸ߶�
    IconRectHeight: Integer; // ͼ������ĸ߶�
    GirdLineDistanceHeight: Integer; // ������֮��ĸ߶�

    // ����
    PricePercentIncrement: Double; // ����ʱ����Y���ߣ����ּ�������Сֵ��ͬʱ�Ĺ̶�����
    VolumeIncrement: Integer; // ���ɽ�������Y���ߣ������ɽ���Ϊ0ʱ�Ĺ̶�����

    // ����Ƥ����ɫ
    TextFont: TFont; // �ı���������
    NumberFont: TFont; // ������������

    // ����
    BackColor: TColor; // ���屳����ɫ
    TitleBackColor: TColor; // �������򱳾�ɫ
    HistoryBackColor: TColor; // ��ʷ������ɫ
    AuctionBackColor: TColor; // ���Ͼ��۵ı�����ɫ
    CrossDetailBackColor: TColor; // ʮ������ʾ��ϸ������ɫ
    CrossXYRulerHintBackColor: TColor; // ʮ���߱����ʾ����ɫ
    CurrentPriceHintBackColor: TColor; // �ּ���ʾ����ɫ
    VolumeButtonBackColor: TColor; // �ɽ�����ť������ɫ
    VolumeButtonFocusBackColor: TColor; // �ɽ�����ť�۽�������ɫ

    // ����ɫ
    BorderLineColor: TColor; // �߿�����ɫ
    RegionDivideLineColor: TColor; // ����ָ���
    CenterRegionFrameLineColor: TColor; // ��������߿�����ɫ
    TitleFrameLineColor: TColor; // ������ɫ
    CrossDetailFrameLineColor: TColor; // ʮ������ʾ��ϸ�߿�����ɫ
    CrossXYRulerHintFrameLineColor: TColor; // ʮ���߱����ʾ�߿�����ɫ
    CurrentPriceHintFrameLineColor: TColor; // �ּ���ʾ�߿�����ɫ
    CrossLineColor: TColor; // ʮ������ɫ
    GridLineColor: TColor; // ��������ɫ
    TimeLineColor: TColor; // ��ʱ��������ɫ
    AverageLineColor: TColor; // ������������ɫ

    // ������ɫ
    StopFlagTextColor: TColor; // ͣ��������ɫ
    StockNameTextColor: TColor; // ֤ȯ������ɫ
    SelfStockNameTextColor: TColor; // ��ѡ֤ȯ������ɫ
    SelfStockCodeTextColor: TColor;
    CrossDetailTextColor: TColor; // ʮ������ʾ��ϸ������ɫ
    CrossDetailVolumeColor: TColor; // ��ʾ��ϸ����ɽ�������ɫ
    CrossDetailDateTimeColor: TColor; // ��ʾ��ϸ����ʱ�����ɫ
    CrossXYRulerHintTextColor: TColor; // ʮ���߱����ʾ������ɫ
    YRulerTextColor: TColor; // �ɽ���Y����ʾ������ɫ
    VolumeButtonTextColor: TColor; // �ɽ�����ť������ɫ
    VolumeButtonFocusTextColor: TColor; // �ɽ�����ť�۽�������ɫ

    // ͼ����ɫ
    InfoMineIconColor: TColor; // ��Ϣ������ɫ

    UpColor: TColor; // ������ɫ
    DownColor: TColor; // �µ���ɫ
    EqualColor: TColor; // �����ɫ
    DownEqualUpColors: array [-1 .. 1] of TColor;
    VolumeColors: array [-1 .. 1] of TColor;

    // ������ɫ
    ShadowRValue: Double;
    ShadowGValue: Double;
    ShadowBValue: Double;
    ShadowRValueInc: Double;
    ShadowGValueInc: Double;
    ShadowBValueInc: Double;
    ShadowBackColors: array [1 .. 60] of TColor;

    TitleTextSpace: Integer; // ��ݲ˵�֮��ļ��
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

  // ������ʾ����ʾ
  AuctionVisible := False;
  InfoMineVisible := True;
  CrossLineVisible := True;
  TradePointVisible := True;
  CurrentPriceVisible := True;

  // Format������ʽ����
  PriceFormat := '%0.3f';
  HighsLowsFormat := '%0.3f';
  HighsLowsRangeFormat := '%0.2f%%';
  LowWanFormat := '%0.3f';
  LowWanVolumeFormat := '%.0f';
  HighWanFormat := '%0.3f��';
  HighYiFormat := '%0.3f��';

  // FormatFloat������ʽ����
  HightLowsFormatFloat := '+0.000;-0.000;0.000';
  HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

  // ���
  YAxisCharCount := 9;
  XAxisScaleIntervalCharCount := 5;
  CrossDetailCharCount := 15;

  // �� FormatDateTime ������ʽ
  MonthDayFormat := 'MM"/"DD';
  HourMinuteFormat := 'hh:nn';

  // �߶�
  TitleRectHeight := 22;
  IconRectHeight := 10;
  GirdLineDistanceHeight := 25;

  // ����
  PricePercentIncrement := 0.02;
  VolumeIncrement := 10;

  TitleTextSpace := 10;
  TitleIconSpace := 6;
  YRulerSpace := 5;
  XEdgeSpace := 6;
  YEdgeSpace := 3;

  TextFont := TFont.Create;
  TextFont.Name := '΢���ź�';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -12;

  NumberFont := TFont.Create;
  NumberFont.Name := 'Times New Roman';
  NumberFont.Charset := GB2312_CHARSET;
  NumberFont.Height := -12;

  // white Skin
  // ��䱳��ɫ
  BackColor := $FFFFFF;
  TitleBackColor := $FFFFFF;
  HistoryBackColor := $FFFFFF;
  AuctionBackColor := $F5F5F5;
  CrossDetailBackColor := $F8F8F8;
  CrossXYRulerHintBackColor := $FAFAFA;
  CurrentPriceHintBackColor := $D4EEFF;
  VolumeButtonBackColor := $E1E1E1;
  VolumeButtonFocusBackColor := $0090FD;

  // ����ɫ
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

  // ������ɫ
  StopFlagTextColor := $E1E1E1;
  StockNameTextColor := $404040;
  SelfStockNameTextColor := $E68826;
  CrossDetailTextColor := $000000;
  CrossXYRulerHintTextColor := $404040;
  YRulerTextColor := $404040;
  VolumeButtonTextColor := $969696;
  VolumeButtonFocusTextColor := $FFFFFF;

  // ͼ����ɫ
  InfoMineIconColor := $F1BF27;

  // ���� ƽ �̵�  ��ɫ
  DownColor := $00A80C;
  EqualColor := $404040;
  UpColor := $0000FF;
  DownEqualUpColors[-1] := DownColor;
  DownEqualUpColors[0] := EqualColor;
  DownEqualUpColors[1] := UpColor;

  // ������ɫ
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
  // // ��䱳��ɫ
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
  // // ����ɫ
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
  // // ������ɫ
  // StopFlagTextColor := $E6E6E6;
  // StockNameTextColor := $E6E6E6;
  // SelfStockNameTextColor := $E68826;
  // CrossDetailTextColor := $E6E6E6;
  // CrossXYRulerHintTextColor := $E6E6E6;
  // YRulerTextColor := $E6E6E6;
  // VolumeButtonTextColor := $969696;
  // VolumeButtonFocusTextColor := $FFCC66;
  //
  // // ͼ����ɫ
  // InfoMineIconColor := $F1BF27;
  //
  // // ���� ƽ �̵�  ��ɫ
  // DownColor := $00A80C;
  // EqualColor := $E6E6E6;
  // UpColor := $0000FF;
  // DownEqualUpColors[-1] := DownColor;
  // DownEqualUpColors[0] := EqualColor;
  // DownEqualUpColors[1] := UpColor;
  //
  // // ������ɫ
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
//    // Format������ʽ����
//    PriceFormat := '%0.1f';
//    HighsLowsFormat := '%0.3f';
//    HighsLowsRangeFormat := '%0.2f%%';
//    LowWanFormat := '%0.3f';
//    LowWanVolumeFormat := '%.0f';
//    HighWanFormat := '%0.3f��';
//    HighYiFormat := '%0.3f��';
//
//    // FormatFloat������ʽ����
//    HightLowsFormatFloat := '+0.000;-0.000;0.000';
//    HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';
//
//    // ���
//    YAxisCharCount := 9;
//    XAxisScaleIntervalCharCount := 5;
//    CrossDetailCharCount := 15;
//  end
//  else
//  begin
//    // Format������ʽ����
//    PriceFormat := '%0.3f';
//    HighsLowsFormat := '%0.3f';
//    HighsLowsRangeFormat := '%0.2f%%';
//    LowWanFormat := '%0.3f';
//    LowWanVolumeFormat := '%.0f';
//    HighWanFormat := '%0.3f��';
//    HighYiFormat := '%0.3f��';
//
//    // FormatFloat������ʽ����
//    HightLowsFormatFloat := '+0.000;-0.000;0.000';
//    HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';
//
//    // ���
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
      // Format������ʽ����
      PriceFormat := '%0.1f';
      HighsLowsFormat := '%0.3f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.3f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.3f��';
      HighYiFormat := '%0.3f��';

      // FormatFloat������ʽ����
      HightLowsFormatFloat := '+0.000;-0.000;0.000';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // ���
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else if Decimal = 2 then
    begin
      // Format������ʽ����
      PriceFormat := '%0.2f';
      HighsLowsFormat := '%0.2f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.2f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.2f��';
      HighYiFormat := '%0.2f��';

      // FormatFloat������ʽ����
      HightLowsFormatFloat := '+0.00;-0.00;0.00';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // ���
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else if Decimal = -1 then    // ����
    begin
      // Format������ʽ����
      PriceFormat := '%0.3f';
      HighsLowsFormat := '%0.2f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.2f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.2f��';
      HighYiFormat := '%0.2f��';

      // FormatFloat������ʽ����
      HightLowsFormatFloat := '+0.00;-0.00;0.00';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // ���
      YAxisCharCount := 9;
      XAxisScaleIntervalCharCount := 5;
      CrossDetailCharCount := 15;
    end
    else
    begin
      // Format������ʽ����
      PriceFormat := '%0.3f';
      HighsLowsFormat := '%0.3f';
      HighsLowsRangeFormat := '%0.2f%%';
      LowWanFormat := '%0.3f';
      LowWanVolumeFormat := '%.0f';
      HighWanFormat := '%0.3f��';
      HighYiFormat := '%0.3f��';

      // FormatFloat������ʽ����
      HightLowsFormatFloat := '+0.000;-0.000;0.000';
      HighsLowsRangeFormatFloat := '+0.00%;-0.00%;0.00%';

      // ���
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

      // ����ɫ
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

      // ������ɫ
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

      // ͼ����ɫ
      InfoMineIconColor := GetColorFromConfig('InfoMineIconColor');

      // ���� ƽ �̵�  ��ɫ
      DownColor := GetColorFromConfig('DownColor');
      EqualColor := GetColorFromConfig('EqualColor');
      UpColor := GetColorFromConfig('UpColor');
      DownEqualUpColors[-1] := DownColor;
      DownEqualUpColors[0] := EqualColor;
      DownEqualUpColors[1] := UpColor;
      VolumeColors[-1] := GetColorFromConfig('VolumeDownColor');
      VolumeColors[0] := GetColorFromConfig('VolumeEqualColor');
      VolumeColors[1] := GetColorFromConfig('VolumeUpColor');

      // ������ɫ
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
