unit QuoteTimeData;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  Activex,
  Math,
  DateUtils,
  QuoteLibrary,
  QuoteStruct,
  QuoteMngr_TLB,
  QuoteManagerEx,
  GilQuoteStruct,
  QuoteMessage,
  QuoteCommLibrary,
  QuoteTimeDisplay,
  QuoteTimeStruct,
  CommonFunc,
  BaseObject,
  AppContext,
  LogLevel;

const
  const_typeTimesCount = 10;

  Const_InnerCode_Index_SH = 1;
  Const_InnerCode_Index_SZ = 1055;

type
  THSTypeTimes = array [0 .. 9] of THSTypeTime;

  PHSTypeTimes = ^THSTypeTimes;

  TAuctionData = class
  private
    FItems: TAuctionItems;
    FCount: Integer;
    FCapacity: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GrowData(_Count: Integer);
    property Items: TAuctionItems read FItems write FItems;
    property Count: Integer read FCount write FCount;
  end;

  TQuoteTimeTrendData = class
  private
    FItems: TQuoteTimeTrendItems;
    FCount: Integer;
    FCapacity: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GrowData(_Count: Integer);
    property Items: TQuoteTimeTrendItems read FItems write FItems;
    property Count: Integer read FCount write FCount;
  end;

  TTimeData = class
  private
    FQuoteManager: IQuoteManagerEx;
    FQuoteTrend: IQuoteTrend;
    FQuoteRealTime: IQuoteRealTime;
    FTimeVar: Integer;
    FAuctionData: TAuctionData;
    FTrendData: TQuoteTimeTrendData;
    FInnerCode: Integer;
    FCodeInfo: TCodeInfo;
    FStockType: TStockType;
    FPHSTypeTimes: PHSTypeTimes;
    FStockName: string;
    FIsStop: Boolean; // 是不是停牌
    FIsHisData: Boolean; // 是不是历史数据
    FHasLimitAixs: Boolean; // 是不是有涨停坐标
    FPrevClose: TQuoteFloat;
    FMaxPrice: TQuoteFloat;
    FMinPrice: TQuoteFloat;
    FAuctionMaxPrice: TQuoteFloat;
    FAuctionMinPrice: TQuoteFloat;
    FLimitMaxPrice: TQuoteFloat;
    FLimitMinPrice: TQuoteFloat;
    FMaxVolume: ulong;
    FMaxIndexTrend: Double;
    FMaxAuctionVolume: ulong;
    FPriceScalc: TQuoteFloat;
    FVolumeScalc: TQuoteFloat;
    FRiseCount: Integer; // 上涨家数
    FFlatCount: Integer; // 平家数
    FFallCount: Integer; // 下跌家数

    procedure InitStockType;
    function GetVADataCount: Integer;
    function GetDataCount: Integer;
    function GetAuctionMinuteCount: Integer;
    function GetMinuteCount: Integer;
    function GetData(_DataKey: TDataKey; _Index: Integer): TQuoteFloat;
    function LoadData: Boolean;
    function LoadIndexData: Boolean;
    procedure CalcMaxMin;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ChangeStock(_PCodeInfo: PCodeInfo); overload;
    procedure ChangeStock(InnerCode: Integer); overload;
    function RealTimeDataArrive(const _QuoteManager: IQuoteManagerEx): Boolean;
    function DataArrive(const _QuoteManager: IQuoteManagerEx;
      const _QuoteTrend: IQuoteTrend; IsHisData: Boolean): Boolean;
    function GetValue(_DataKey: TDataKey; _Index: Integer; var _Value: Double;
      var _CompareValue: Integer): Boolean;
    function IsHasAuction: Boolean;
    function NullTimeData: Boolean;
    function QuoteEnd: Boolean;
    function TimeToIndex(_Time: Integer): Integer;
    function IndexToTime(_Index: Integer): Integer;
    function IsStop: Boolean;
    function GetTradeDate(var _DateTime: TDateTime): Boolean;
    function IsInTradeTime(_MinuteCount: Integer): Boolean;
    function IntToTradeTime(_BeforeMinute: Integer;
      var _AfterMinute: Integer): Boolean;
    function OpenTradeTime: Integer;

    property InnerCode: Integer read FInnerCode write FInnerCode;
    property CodeInfo: TCodeInfo read FCodeInfo;
    property StockType: TStockType read FStockType;
    property IsHisData: Boolean read FIsHisData write FIsHisData;
    property PrevClose: TQuoteFloat read FPrevClose;
    property MaxPrice: TQuoteFloat read FMaxPrice;
    property MinPrice: TQuoteFloat read FMinPrice;
    property AuctionMaxPrice: TQuoteFloat read FAuctionMaxPrice;
    property AuctionMinPrice: TQuoteFloat read FAuctionMinPrice;
    property LimitMaxPrice: TQuoteFloat read FLimitMaxPrice;
    property LimitMinPrice: TQuoteFloat read FLimitMinPrice;
    property MaxVolume: ulong read FMaxVolume;
    property MaxIndexTrend: Double read FMaxIndexTrend;
    property MaxAuctionVolume: ulong read FMaxAuctionVolume;
    property VolumeScalc: Double read FVolumeScalc;
    property AuctionMinuteCount: Integer read GetAuctionMinuteCount;
    property MinuteCount: Integer read GetMinuteCount;
    property PHSTimes: PHSTypeTimes read FPHSTypeTimes;
    property StockName: string read FStockName write FStockName;
    property VADataCount: Integer read GetVADataCount;
    property DataCount: Integer read GetDataCount;
    property Datas[_DataKey: TDataKey; _Index: Integer]: TQuoteFloat
      read GetData;
    property HasLimitAixs: Boolean read FHasLimitAixs write FHasLimitAixs;
    property RiseCount: Integer read FRiseCount;
    property FlatCount: Integer read FFlatCount;
    property FallCount: Integer read FFallCount;
  end;

  TQuoteTimeData = class(TBaseHqObject)
  private
//    FGilRanges: IGilRanges; // 自选股相关接口
    FOnInvalidate: TOnInvalidate;
    FMainDatas: TList; // 当日和历史都放在这个里面
    FStackDatas: TList; // 存放历史
    FMainSecuCode: string;
    FMainStockName: string;
    FIsSelfStock: Boolean;
    FNotifyHandle: Integer;
    FIsSubcribeHistory: Boolean; // 是不是订阅历史某一天的数据
    FSubcribeHistoryDay: Integer; // 订阅历史某一天
    FIsVolumeDelay: Boolean;
    FOnChangeValue: TOnChangeValueEvent;
    FStringList: TStringList;

    procedure Clean(_List: TList);
    procedure DoInvalidate;
    function GetMainDatasCount: Integer;
    function GetStackCount: Integer;
    function GetStackDatas(_Index: Integer): TTimeData;
    function GetPHSTypeTimes: PHSTypeTimes;
    function GetMinuteCount: Integer;
    function GetMainData: TTimeData;
    function GetIsSelfStock(_InnerCode: Integer): Boolean;
    function GetHistoryDay: TDateTime;

//    // 订阅之后自动调用
//    procedure DoDataArrive(_QuoteType: QuoteTypeEnum; P: Pointer);
//    procedure DoDataReset(_QuoteType: QuoteTypeEnum; P: Pointer);
//    procedure DoInfoReset(_QuoteType: QuoteTypeEnum; P: Pointer);

    // ReSubcribeHqData
    procedure DoReSubcribeHqData; override;
    // UnSubcirbeHqData
    procedure DoUnSubcirbeHqData; override;
    // InfoReset
    procedure DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
    // DataReset
    procedure DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
    // DataArrive
    procedure DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
  public
    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;

    // 连接行情服务
//    procedure ConnectQuoteManager(const _GilAppController: IGilAppController;
//      const _QuoteManager: IQuoteManagerEx; const _GilRanges: IGilRanges);
//    procedure DisConnectQuoteManager;
    procedure Subscribe; overload;
    procedure Subscribe(_InnerCode: Integer; _DayCount: Integer = 1); overload;
    procedure SubscribeNDay(_DayCount: Integer);
    procedure SubscribeStack(_InnerCode: Integer); overload;
    procedure SubscribeStack(_InnerCodes: array of Integer;
      _Count: Integer); overload;
    procedure SubscribeHistory(_InnerCode: Integer; _Day: Integer); overload;
    procedure SubscribeHistory; overload;
    procedure SubscribeLimitAxis;
    procedure CleanStack;
    procedure CleanMain;
    procedure CancelSubcribe(_ClearData: Boolean);
    function DataIndexToData(_DataIndex: Integer): TTimeData;
    function SelfStockOperate(_SelfStockOperate: TSelfStockOperate): Boolean;
    procedure DoChangeSelfStock;

    property MainDatasCount: Integer read GetMainDatasCount;
    property StackCount: Integer read GetStackCount;
    property StackDatas[_Index: Integer]: TTimeData read GetStackDatas;
    property PHSTimes: PHSTypeTimes read GetPHSTypeTimes;
    property MinuteCount: Integer read GetMinuteCount;
    property MainData: TTimeData read GetMainData;
    property OnInvalidate: TOnInvalidate read FOnInvalidate write FOnInvalidate;
    property MainSecuCode: string read FMainSecuCode write FMainSecuCode;
    property MainStockName: string read FMainStockName write FMainStockName;
    property IsSelfStock: Boolean read FIsSelfStock;
    property NotifyHandle: Integer read FNotifyHandle write FNotifyHandle;
    property HistoryDay: TDateTime read GetHistoryDay;
    property IsVolumeDelay: Boolean read FIsVolumeDelay write FIsVolumeDelay;
    property OnChangeValue: TOnChangeValueEvent read FOnChangeValue write FOnChangeValue;
  end;

function IntToHourMinTime(_Time: Integer): TDateTime;

implementation

function IntToHourMinTime(_Time: Integer): TDateTime;
begin
  Result := IncMinute(0, _Time);
end;

{ TAuctionData }

constructor TAuctionData.Create;
begin
  FCapacity := 0;
  FCount := 0;
end;

destructor TAuctionData.Destroy;
begin

  inherited;
end;

procedure TAuctionData.GrowData(_Count: Integer);
begin
  if _Count >= FCapacity then
  begin
    FCapacity := _Count + 5;
    SetLength(FItems, FCapacity);
  end;
end;

{ TQuoteTimeTrendData }

constructor TQuoteTimeTrendData.Create;
begin
  FCapacity := 0;
  FCount := 0;
end;

destructor TQuoteTimeTrendData.Destroy;
begin

  inherited;
end;

procedure TQuoteTimeTrendData.GrowData(_Count: Integer);
begin
  if _Count >= FCapacity then
  begin
    FCapacity := _Count + 45;
    SetLength(FItems, FCapacity);
  end;
end;

{ TTimeData }

constructor TTimeData.Create;
begin
  FTrendData := TQuoteTimeTrendData.Create;
  FAuctionData := TAuctionData.Create;
  FIsHisData := False;
  FHasLimitAixs := False;
  FStockType := stStock;
  FStockName := '';
  FPHSTypeTimes := nil;
  FQuoteManager := nil;
  FQuoteTrend := nil;
  FQuoteRealTime := nil;
end;

destructor TTimeData.Destroy;
begin
  FQuoteTrend := nil;
  FQuoteRealTime := nil;
  FQuoteManager := nil;
  FPHSTypeTimes := nil;
  if Assigned(FTrendData) then
    FreeAndNil(FTrendData);
  if Assigned(FAuctionData) then
    FAuctionData.Free;
  inherited;
end;

procedure TTimeData.ChangeStock(InnerCode: Integer);
begin
  FInnerCode := InnerCode;
end;

procedure TTimeData.ChangeStock(_PCodeInfo: PCodeInfo);
begin
  FCodeInfo := _PCodeInfo^;
  FQuoteTrend := nil;
  FQuoteRealTime := nil;
  FStockName := '';
  FTimeVar := 0;
  FIsStop := False;
  InitStockType;
  // FHasLimitAixs := (FStockType = stStock);
  FAuctionData.Count := 0;
  FTrendData.Count := 0;
  FLimitMinPrice := 0;
  FLimitMaxPrice := 0;
  FMaxPrice := 0;
  FMinPrice := 0;
  FMaxVolume := 0;
  FPrevClose := 0;
  FMaxIndexTrend := 0;
  FMaxAuctionVolume := 0;

  FRiseCount := -1;
  FFlatCount := -1;
  FFallCount := -1;
end;

procedure TTimeData.InitStockType;
begin
  case GetRealTimeSC(@FCodeInfo) of
    rscSTOCK:
      FStockType := stStock;
    rscINDEX:
      FStockType := stIndex;
    rscHKSTOCK:
      FStockType := stHKStock;
    rscUS:
      FStockType := stUSStock;
    rscFUTURES:
      FStockType := stFutures;
    rscOPTION:
      FStockType := stOption;
    rscIB:
      FStockType := stBond;
  else
    FStockType := stExchange;
  end;
end;

function TTimeData.IsHasAuction: Boolean;
begin
  Result := False;
  if FQuoteTrend <> nil then
    Result := FQuoteTrend.IsVAData;
end;

function TTimeData.IsInTradeTime(_MinuteCount: Integer): Boolean;
var
  tmpPTypeTimes: PHSTypeTimes;
  tmpIndex, tmpOpenTime, tmpCloseTime, tmpCount: Integer;
begin
  Result := False;
  tmpPTypeTimes := FPHSTypeTimes;
  if Assigned(tmpPTypeTimes) then
  begin
    for tmpIndex := 0 to const_typeTimesCount - 1 do
    begin
      tmpOpenTime := tmpPTypeTimes^[tmpIndex].m_nOpenTime;
      tmpCloseTime := tmpPTypeTimes^[tmpIndex].m_nCloseTime;
      if (tmpOpenTime <> -1) and (tmpCloseTime <> -1) and
        (tmpOpenTime <= _MinuteCount) and (tmpCloseTime >= _MinuteCount) then
      begin
        tmpCount := TimeToIndex(_MinuteCount);
        if tmpCount <= DataCount then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

function TTimeData.OpenTradeTime: Integer;
var
  tmpOpenTime: Integer;
begin
  Result := 570;
  if Assigned(FPHSTypeTimes) then
  begin
    tmpOpenTime := FPHSTypeTimes^[0].m_nOpenTime;
    if tmpOpenTime <> -1 then
      Result := tmpOpenTime;
  end;
end;

function TTimeData.IntToTradeTime(_BeforeMinute: Integer;
  var _AfterMinute: Integer): Boolean;
var
  tmpPTypeTimes: PHSTypeTimes;
  tmpIndex, tmpOpenTime, tmpCloseTime, tmpNextOpenTime, tmpNextCloseTime,
    tmpLastCloseTime: Integer;
begin
  Result := True;
  tmpLastCloseTime := -1;
  tmpPTypeTimes := FPHSTypeTimes;
  _AfterMinute := _BeforeMinute;
  if Assigned(tmpPTypeTimes) then
  begin
    for tmpIndex := 0 to const_typeTimesCount - 2 do
    begin
      tmpOpenTime := tmpPTypeTimes^[tmpIndex].m_nOpenTime;
      tmpCloseTime := tmpPTypeTimes^[tmpIndex].m_nCloseTime;
      tmpNextOpenTime := tmpPTypeTimes^[tmpIndex + 1].m_nOpenTime;
      tmpNextCloseTime := tmpPTypeTimes^[tmpIndex + 1].m_nCloseTime;
      if (tmpOpenTime <> -1) and (tmpCloseTime <> -1) and
        (_BeforeMinute < tmpOpenTime) then
      begin
        _AfterMinute := tmpOpenTime;
        Exit;
      end;
      if (tmpCloseTime <> -1) and (tmpNextOpenTime <> -1) and
        (_BeforeMinute > tmpCloseTime) and (_BeforeMinute < tmpNextOpenTime)
      then
      begin
        _AfterMinute := tmpNextOpenTime;
        Exit;
      end;
      if tmpNextCloseTime <> -1 then
        tmpLastCloseTime := tmpNextCloseTime;
    end;
    if (tmpLastCloseTime <> -1) and (_BeforeMinute > tmpLastCloseTime) then
      _AfterMinute := tmpLastCloseTime;
  end;
end;

function TTimeData.IsStop: Boolean;
begin
  Result := FIsStop;
end;

function TTimeData.RealTimeDataArrive(const _QuoteManager
  : IQuoteManagerEx): Boolean;
var
  tmpHand: Integer;
  tmpTrendInfo: PTrendInfo;
  tmpPCommRealTime: PQuoteRealTimeData;
  tmpPStockType: PStockType;
  tmpPStockInfo: PStockInfo;
  tmpPLimitPrice: PLimitPrice;
begin
  Result := False;
  FStockName := '';
  FPriceScalc := 0.001;
  FVolumeScalc := 0.01;
  FMaxIndexTrend := 0;
  FIsStop := False;

  FQuoteManager := _QuoteManager;

  if FQuoteManager = nil then
    Exit;

  FQuoteRealTime := FQuoteManager.QueryData(QuoteType_REALTIME,
    Int64(@FCodeInfo)) as IQuoteRealTime;
  if FQuoteRealTime <> nil then
  begin
    FQuoteRealTime.BeginRead;
    try
      if not FIsHisData then
      begin
        FPrevClose := FQuoteRealTime.PrevClose[FCodeInfo.m_cCodeType,
          CodeInfoToCode(@FCodeInfo)]
      end;

      tmpPStockInfo := PStockInfo(FQuoteRealTime.Codes[FCodeInfo.m_cCodeType,
        CodeInfoToCode(@FCodeInfo)]);
      if tmpPStockInfo <> nil then
        FStockName := string(tmpPStockInfo^.Stock.m_cStockName);
      tmpPStockType :=
        PStockType(FQuoteRealTime.GetStockTypeInfo(FCodeInfo.m_cCodeType));
      if (tmpPStockType <> nil) then
      begin
        FPHSTypeTimes := @tmpPStockType.m_nNewTimes;
        if tmpPStockType^.m_nPriceUnit > 0 then
          FPriceScalc := 1 / tmpPStockType^.m_nPriceUnit;
      end;

      tmpPCommRealTime := PQuoteRealTimeData
        (FQuoteRealTime.Datas[FCodeInfo.m_cCodeType,
        CodeInfoToCode(@FCodeInfo)]);
      if Assigned(tmpPCommRealTime) then
      begin
        tmpHand := GetSharesPerHand(@FCodeInfo, tmpPCommRealTime);
        FIsStop := (tmpPCommRealTime.CommExtData.m_StockExt.m_lStopFlag = 1);
        if FStockType = stFutures then
          FPrevClose := tmpPCommRealTime.m_cNowData.m_qhData.m_lPreJieSuanPrice;

        if (FInnerCode = Const_InnerCode_Index_SH) or
          (FInnerCode = Const_InnerCode_Index_SZ) then
        begin
          FRiseCount := tmpPCommRealTime.m_cNowData.m_indData.m_nRiseCount;
          if FRiseCount < 0 then
            FRiseCount := 0;
          FFallCount := tmpPCommRealTime.m_cNowData.m_indData.m_nFallCount;
          if FFallCount < 0 then
            FFallCount := 0;
          FFlatCount := tmpPCommRealTime.m_cNowData.m_indData.m_nTotalStock2 -
            FRiseCount - FFallCount;
          if FFlatCount < 0 then
            FFlatCount := 0;
        end;
      end
      else
        tmpHand := 100;

      if (FStockType <> stHKStock) and (tmpHand <> 0) then
        FVolumeScalc := 1 / tmpHand
      else
        FVolumeScalc := 1;

      tmpPLimitPrice :=
        PLimitPrice(FQuoteRealTime.GetLimitPrice(FCodeInfo.m_cCodeType,
        CodeInfoToCode(@FCodeInfo)));
      if tmpPLimitPrice <> nil then
      begin
        Result := True;
        FLimitMinPrice := tmpPLimitPrice.MinDownPrice * FPriceScalc;
        FLimitMaxPrice := tmpPLimitPrice.MaxUpPrice * FPriceScalc;
      end
      else
      begin
        FLimitMinPrice := 0;
        FLimitMaxPrice := 0;
      end;
    finally
      FQuoteRealTime.EndRead;
    end;
  end;

  if FIsHisData then
  begin
    tmpTrendInfo := PTrendInfo(FQuoteTrend.GetTrendInfo);
    if Assigned(tmpTrendInfo) then
    begin
      FPrevClose := tmpTrendInfo.PrevClose;
      FIsStop := (tmpTrendInfo.StopFlag = 1);
    end;
  end;

  FPrevClose := FPrevClose * FPriceScalc;
  FMaxPrice := FPrevClose;
  FMinPrice := FPrevClose;

  if (FInnerCode = Const_InnerCode_Index_SH) or
    (FInnerCode = Const_InnerCode_Index_SZ) then
  begin
    FStockType := stIndex;
  end
  else if FStockType = stIndex then
  begin
    FStockType := stStock;
  end;
end;

function TTimeData.DataArrive(const _QuoteManager: IQuoteManagerEx;
  const _QuoteTrend: IQuoteTrend; IsHisData: Boolean): Boolean;
begin
  FPrevClose := 0;
  Result := False;
  FIsHisData := IsHisData;
  FQuoteTrend := _QuoteTrend;
  if FQuoteTrend = nil then
    Exit;

  FQuoteManager := _QuoteManager;
  if FQuoteManager = nil then
    Exit;
  RealTimeDataArrive(FQuoteManager);
  if FStockType = stIndex then
  begin
    Result := LoadIndexData
  end
  else
  begin
    Result := LoadData;
  end;
  CalcMaxMin;
end;

procedure TTimeData.CalcMaxMin;
var
  tmpIndex: Integer;
  tmpIsFirst, tmpAdvFirst: Boolean;
  tmpPrice, tmpAdvPrice, tmpMaxAdvPrice, tmpMinAdvPrice, tmpIndexTrend: Double;
begin
  tmpIsFirst := True;
  tmpAdvFirst := True;
  tmpMaxAdvPrice := 0;
  tmpMinAdvPrice := 0;

  FMaxPrice := 0;
  FMinPrice := 0;
  FAuctionMaxPrice := 0;
  FAuctionMinPrice := 0;
  FMaxIndexTrend := 0;
  FMaxVolume := 0;
  FMaxAuctionVolume := 0;

  for tmpIndex := 0 to FAuctionData.Count - 1 do
  begin
    tmpPrice := FAuctionData.Items[tmpIndex].m_lPrice;
    if tmpPrice > 0 then
    begin
      if tmpIsFirst then
      begin
        FAuctionMaxPrice := tmpPrice;
        FAuctionMinPrice := tmpPrice;
        tmpIsFirst := False;
      end
      else
      begin
        if CompareValue(tmpPrice, FAuctionMaxPrice) > 0 then
          FAuctionMaxPrice := tmpPrice;
        if CompareValue(tmpPrice, FAuctionMinPrice) < 0 then
          FAuctionMinPrice := tmpPrice;
      end;
    end;
    if FAuctionData.Items[tmpIndex].m_lVolume > FMaxAuctionVolume then
      FMaxAuctionVolume := FAuctionData.Items[tmpIndex].m_lVolume;
  end;

  tmpIsFirst := True;
  for tmpIndex := 0 to FTrendData.Count - 1 do
  begin
    tmpPrice := FTrendData.Items[tmpIndex].m_lPrice;
    if tmpPrice > 0 then
    begin
      if tmpIsFirst then
      begin
        FMaxPrice := tmpPrice;
        FMinPrice := tmpPrice;
        tmpIsFirst := False;
      end
      else
      begin
        if tmpPrice > FMaxPrice then
          FMaxPrice := tmpPrice;
        if tmpPrice < FMinPrice then
          FMinPrice := tmpPrice;
      end;
    end;

    if FStockType = stIndex then
    begin
      tmpAdvPrice := FTrendData.Items[tmpIndex].m_lAveragePrice;
      if tmpAdvPrice <> 0 then
      begin
        if tmpAdvFirst then
        begin
          tmpMaxAdvPrice := tmpAdvPrice;
          tmpMinAdvPrice := tmpAdvPrice;
          tmpAdvFirst := False;
        end
        else
        begin
          if CompareValue(tmpAdvPrice, tmpMaxAdvPrice) > 0 then
            tmpMaxAdvPrice := tmpAdvPrice;
          if CompareValue(tmpAdvPrice, tmpMinAdvPrice) < 0 then
            tmpMinAdvPrice := tmpAdvPrice;
        end;
      end;

      tmpIndexTrend := abs(FTrendData.Items[tmpIndex].m_lUpTrend -
        FTrendData.Items[tmpIndex].m_lDownTrend) * 10;
      if CompareValue(tmpIndexTrend, FMaxIndexTrend) > 0 then
        FMaxIndexTrend := tmpIndexTrend;
    end;

    if FTrendData.Items[tmpIndex].m_lVolume > FMaxVolume then
      FMaxVolume := FTrendData.Items[tmpIndex].m_lVolume;

    if not FIsHisData then
    begin
      if (tmpMaxAdvPrice <> 0) and (CompareValue(tmpMaxAdvPrice, FMaxPrice) > 0)
      then
        FMaxPrice := tmpMaxAdvPrice;
      if (tmpMinAdvPrice <> 0) and (CompareValue(tmpMinAdvPrice, FMinPrice) < 0)
      then
        FMinPrice := tmpMinAdvPrice;
    end;
  end;
end;

function TTimeData.LoadData: Boolean;
var
  tmpIsFirst: Boolean;
  tmpData: PTrendDataUnion;
  tmpAuctionData: PStockVirtualAuction;
  tmpIndex, tmpStartTime, tmpEndTime: Integer;
  tmpPrevPrice, tmpAveragePrice, tmpFirstPrice: TQuoteFloat;
begin
  Result := False;
  tmpIsFirst := True;
  if (FQuoteTrend <> nil) and (FQuoteTrend.VarCode <> FTimeVar) then
  begin
    FQuoteTrend.BeginRead;
    try
      Result := True;
      tmpPrevPrice := 0;
      tmpFirstPrice := 0;

      if FQuoteTrend.IsVAData and (FQuoteTrend.VADatas <> 0) then
      begin
        FAuctionData.Count := FQuoteTrend.VADataCount;
        FAuctionData.GrowData(FAuctionData.Count);
        tmpAuctionData := PStockVirtualAuction(FQuoteTrend.VADatas);

        FQuoteTrend.GetVATime(tmpStartTime, tmpEndTime);

        for tmpIndex := 0 to FAuctionData.Count - 1 do
        begin
          if tmpAuctionData.m_lPrice <> 0 then
          begin
            tmpPrevPrice := tmpAuctionData.m_lPrice * FPriceScalc;
            FAuctionData.Items[tmpIndex].m_lPrice := tmpPrevPrice;
            if tmpIsFirst then
            begin
              tmpIsFirst := False;
              tmpFirstPrice := tmpPrevPrice;
            end;
          end
          else
            FAuctionData.Items[tmpIndex].m_lPrice := tmpPrevPrice;
          if tmpAuctionData.m_lTime <> 0 then
            FAuctionData.Items[tmpIndex].m_lTime := tmpAuctionData.m_lTime
          else
            FAuctionData.Items[tmpIndex].m_lTime := tmpStartTime;

          FAuctionData.Items[tmpIndex].m_lVolume :=
            Trunc(tmpAuctionData.m_fQty * FVolumeScalc);
          // if FAuctionData.Items[tmpIndex].m_lVolume < 0 then
          // FAuctionData.Items[tmpIndex].m_lVolume := 0;
          Inc(tmpStartTime);
          Inc(tmpAuctionData);
        end;

        if not tmpIsFirst then
        begin
          for tmpIndex := FAuctionData.Count - 1 downto 0 do
          begin
            if FAuctionData.Items[tmpIndex].m_lPrice = 0 then
            begin
              FAuctionData.Items[tmpIndex].m_lPrice := tmpFirstPrice;
            end;
          end;
        end;
      end;

      tmpPrevPrice := FPrevClose;
      tmpAveragePrice := 0;
      FTrendData.Count := FQuoteTrend.Count;
      FTrendData.GrowData(FTrendData.Count);
      tmpData := PTrendDataUnion(FQuoteTrend.Datas);
      for tmpIndex := 0 to FTrendData.Count - 1 do
      begin
        if tmpData.CommonTrendData.Price > 0 then
        begin
          tmpPrevPrice := tmpData.CommonTrendData.Price * FPriceScalc;
          FTrendData.Items[tmpIndex].m_lPrice := tmpPrevPrice;
        end
        else
          FTrendData.Items[tmpIndex].m_lPrice := tmpPrevPrice;

        if tmpData.CommonTrendData.AvgPrice > 0 then
        begin
          if FStockType in [stUSStock, stFutures] then
            tmpAveragePrice := tmpData.CommonTrendData.AvgPrice * FPriceScalc
          else
            tmpAveragePrice := tmpData.CommonTrendData.AvgPrice;
          FTrendData.Items[tmpIndex].m_lAveragePrice := tmpAveragePrice;
        end
        else
          FTrendData.Items[tmpIndex].m_lAveragePrice := tmpAveragePrice;

        FTrendData.Items[tmpIndex].m_lVolume :=
          Trunc(tmpData.CommonTrendData.Vol * FVolumeScalc);

        FTrendData.Items[tmpIndex].m_lMoney := tmpData.CommonTrendData.Money *
          FPriceScalc;

        Inc(tmpData);
      end;
      FTimeVar := FQuoteTrend.VarCode;
    finally
      FQuoteTrend.EndRead;
    end;
  end;
end;

function TTimeData.LoadIndexData: Boolean;
var
  tmpIndex: Integer;
  tmpData: PTrendDataUnion;
  tmpPrevPrice, tmpAveragePrice: TQuoteFloat;
begin
  Result := False;

  if (FQuoteTrend <> nil) and (FQuoteTrend.VarCode <> FTimeVar) then
  begin
    FQuoteTrend.BeginRead;
    try
      Result := True;
      // 指数的时候 没有集合竞价
      FAuctionData.Count := 0;

      tmpPrevPrice := FPrevClose;
      tmpAveragePrice := 0;
      FMaxIndexTrend := 0;

      FTrendData.Count := FQuoteTrend.Count;
      FTrendData.GrowData(FTrendData.Count);
      tmpData := PTrendDataUnion(FQuoteTrend.Datas);
      for tmpIndex := 0 to FTrendData.Count - 1 do
      begin
        if tmpData.IndexTrendData.Price <> 0 then
        begin
          tmpPrevPrice := tmpData.IndexTrendData.Price * FPriceScalc;
          FTrendData.Items[tmpIndex].m_lPrice := tmpPrevPrice;
        end
        else
          FTrendData.Items[tmpIndex].m_lPrice := tmpPrevPrice;
        if tmpData.IndexTrendData.AdvPrice <> 0 then
        begin
          tmpAveragePrice := tmpData.IndexTrendData.AdvPrice * FPriceScalc;
          FTrendData.Items[tmpIndex].m_lAveragePrice := tmpAveragePrice;
        end
        else
          FTrendData.Items[tmpIndex].m_lAveragePrice := tmpAveragePrice;

        FTrendData.Items[tmpIndex].m_lVolume :=
          Trunc(tmpData.IndexTrendData.Vol * FVolumeScalc);

        FTrendData.Items[tmpIndex].m_lMoney := tmpData.IndexTrendData.Money *
          FPriceScalc;

        FTrendData.Items[tmpIndex].m_lUpTrend :=
          tmpData.IndexTrendData.RiseTrend;
        FTrendData.Items[tmpIndex].m_lDownTrend :=
          tmpData.IndexTrendData.FallTrend;

        Inc(tmpData);
      end;
      FTimeVar := FQuoteTrend.VarCode;
    finally
      FQuoteTrend.EndRead;
    end;
  end;
end;

function TTimeData.NullTimeData: Boolean;
begin
  Result := True;
  if Assigned(FQuoteTrend) then
    Result := FQuoteTrend.TimeCount = 0;
end;

function TTimeData.QuoteEnd: Boolean;
begin
  Result := True;
  if Assigned(FQuoteTrend) then
    Result := (FTrendData.Count = FQuoteTrend.TimeCount);
end;

function TTimeData.GetVADataCount: Integer;
begin
  Result := 0;
  if FAuctionData <> nil then
    Result := FAuctionData.Count;
end;

function TTimeData.GetDataCount: Integer;
begin
  Result := 0;
  if FTrendData <> nil then
    Result := FTrendData.Count;
end;

function TTimeData.GetAuctionMinuteCount: Integer;
var
  tmpBegin, tmpEnd: Integer;
begin
  Result := 0;
  if FQuoteTrend <> nil then
  begin
    FQuoteTrend.GetVATime(tmpBegin, tmpEnd);
    if (tmpBegin <> -1) and (tmpEnd <> -1) then
      Result := tmpEnd - tmpBegin;
  end;
end;

function TTimeData.GetMinuteCount: Integer;
begin
  Result := 1;
  if FQuoteTrend <> nil then
    Result := FQuoteTrend.TimeCount;
end;

function TTimeData.GetTradeDate(var _DateTime: TDateTime): Boolean;
var
  tmpPTrendInfo: PTrendInfo;
begin
  _DateTime := Now;
  Result := False;
  if FIsHisData then
  begin
    if (FQuoteTrend <> nil) and (not NullTimeData) then
    begin
      FQuoteTrend.BeginRead;
      try
        tmpPTrendInfo := PTrendInfo(FQuoteTrend.GetTrendInfo);
        if Assigned(tmpPTrendInfo) and (tmpPTrendInfo^.TradeDate <> 0) then
        begin
          _DateTime := IntToDateTime(tmpPTrendInfo^.TradeDate);
          Result := True;
        end;
      finally
        FQuoteTrend.EndRead;
      end;
    end;
  end
  else
  begin
    if (FQuoteRealTime <> nil) and (not NullTimeData) then
    begin
      FQuoteRealTime.BeginRead;
      try
        _DateTime := IntToDateTime
          (FQuoteRealTime.GetInitDate(FCodeInfo.m_cCodeType));
        Result := True;
      finally
        FQuoteRealTime.EndRead;
      end;
    end;
  end;
end;

function TTimeData.GetData(_DataKey: TDataKey; _Index: Integer): TQuoteFloat;
begin
  Result := 0;
  if (_Index < 0) or (_Index >= FTrendData.Count) then
    Exit;
  case _DataKey of
    dkPrice:
      Result := FTrendData.Items[_Index].m_lPrice;
    dkVolume:
      Result := FTrendData.Items[_Index].m_lVolume;
    dkAveragePrice:
      Result := FTrendData.Items[_Index].m_lAveragePrice;
    dkMoney:
      Result := FTrendData.Items[_Index].m_lMoney;
    dkIndexUpTrend:
      Result := FTrendData.Items[_Index].m_lUpTrend;
    dkIndexDownTrend:
      Result := FTrendData.Items[_Index].m_lDownTrend;
  end;
end;

function TTimeData.GetValue(_DataKey: TDataKey; _Index: Integer;
  var _Value: Double; var _CompareValue: Integer): Boolean;
var
  tmpIndex: Integer;
  tmpPrevPrice, tmpPrice: Double;
begin
  _Value := 0;
  _CompareValue := 0;
  Result := False;
  if NullTimeData then
    Exit;
  if _Index >= 0 then
  begin
    if _Index > DataCount - 1 then
      tmpIndex := DataCount - 1
    else
      tmpIndex := _Index;

    case _DataKey of
      dkPrice:
        begin
          Result := True;
          if DataCount > 0 then
            _Value := Datas[dkPrice, tmpIndex];
          if _Value <= 0 then
            _Value := FPrevClose;
          _CompareValue := CompareValue(_Value, FPrevClose);
        end;
      dkCurrentPrice:
        begin
          Result := True;

          if (not FIsStop) and (DataCount > 0) then
          begin
            _Value := Datas[dkPrice, DataCount - 1];
            if _Value > 0 then
              _CompareValue := CompareValue(_Value, PrevClose);
          end;
          if _Value = 0 then
            _Value := PrevClose;
        end;
      dkVolume:
        begin
          Result := True;
          if DataCount > 0 then
            _Value := Datas[dkVolume, tmpIndex];
          if tmpIndex > 0 then
            tmpPrevPrice := Datas[dkPrice, tmpIndex - 1]
          else
            tmpPrevPrice := FPrevClose;
          tmpPrice := Datas[dkPrice, tmpIndex];
          _CompareValue := CompareValue(tmpPrice, tmpPrevPrice);
        end;
      dkAveragePrice:
        begin
          Result := True;
          if DataCount > 0 then
            _Value := Datas[dkAveragePrice, tmpIndex]
          else
            _Value := PrevClose;
          _CompareValue := CompareValue(_Value, PrevClose);
        end;
      dkDate:
        begin
          Result := True;
          _Value := IntToHourMinTime(IndexToTime(tmpIndex));
        end;
      dkHighsLows:
        begin
          Result := True;
          if not FIsStop then
          begin
            if (DataCount > 0) and (Datas[dkPrice, tmpIndex] > 0) then
              _Value := Datas[dkPrice, tmpIndex] - PrevClose;
            _CompareValue := CompareValue(_Value, 0);
          end;
        end;
      dkHighsLowsRange:
        begin
          Result := True;
          if not FIsStop then
          begin
            if (DataCount > 0) and (PrevClose > 0) then
            begin
              tmpPrice := Datas[dkPrice, tmpIndex];
              if tmpPrice > 0 then
              begin
                _Value := (tmpPrice - PrevClose) * 100 / PrevClose;
                _CompareValue := CompareValue(_Value, 0);
              end;
            end;
          end;
        end;
      dkMoney:
        begin
          Result := True;
          if (DataCount > 0) then
            _Value := Datas[dkMoney, tmpIndex];
        end;
      dkArrivePtCurrentPrice:
        begin
          Result := True;
          if DataCount > 0 then
          begin
            _Value := Datas[dkPrice, DataCount - 1];
            if DataCount > 1 then
              _CompareValue := CompareValue(_Value,
                Datas[dkPrice, DataCount - 2])
            else if DataCount = 1 then
              _CompareValue := CompareValue(_Value, PrevClose);
          end;
        end;
      dkIndexTrend:
        begin
          Result := True;
          if DataCount > 0 then
            _Value := (Datas[dkIndexUpTrend, tmpIndex] - Datas[dkIndexDownTrend,
              tmpIndex]) * 10; // 之前的算法就是这样  * 10；
          _CompareValue := CompareValue(_Value, 0);
        end;
    end;
  end
  else
  begin
    tmpIndex := _Index + AuctionMinuteCount;
    if tmpIndex > VADataCount - 1 then
      tmpIndex := VADataCount - 1;
    if tmpIndex < 0 then
      tmpIndex := 0;
    if (tmpIndex >= 0) and (AuctionMinuteCount > 0) then
    begin
      case _DataKey of
        dkDate:
          begin
            Result := True;
            _Value := IntToHourMinTime(IndexToTime(_Index));
          end;
        dkPrice:
          begin
            Result := True;
            if not FIsStop then
            begin
              if FAuctionData.Count > 0 then
              begin
                _Value := FAuctionData.Items[tmpIndex].m_lPrice;
                _CompareValue := CompareValue(_Value, FPrevClose);
              end;
            end
            else
            begin
              _Value := FPrevClose;
            end;
          end;
        dkHighsLows:
          begin
            Result := True;
            if not FIsStop then
            begin
              if DataCount > 0 then
                _Value := FAuctionData.Items[tmpIndex].m_lPrice - PrevClose;
              _CompareValue := CompareValue(_Value, 0);
            end;
          end;
        dkHighsLowsRange:
          begin
            Result := True;
            if not FIsStop then
            begin
              if (DataCount > 0) and (PrevClose > 0) then
                _Value := (FAuctionData.Items[tmpIndex].m_lPrice - PrevClose) *
                  100 / PrevClose;
              _CompareValue := CompareValue(_Value, 0);
            end;
          end;
        dkAuctionPrice:
          begin
            if FAuctionData.Count > 0 then
            begin
              _Value := FAuctionData.Items[tmpIndex].m_lPrice;
              _CompareValue := CompareValue(_Value, FPrevClose);
            end;
          end;
        dkAuctionVolume:
          begin
            _Value := FAuctionData.Items[tmpIndex].m_lVolume;
            if tmpIndex > 0 then
              tmpPrevPrice := FAuctionData.Items[tmpIndex - 1].m_lPrice
            else
              tmpPrevPrice := FPrevClose;
            tmpPrice := FAuctionData.Items[tmpIndex].m_lPrice;
            _CompareValue := CompareValue(tmpPrice, tmpPrevPrice);
          end;
      end;
    end;
  end;
end;

function TTimeData.IndexToTime(_Index: Integer): Integer;
var
  tmpBegin, tmpEnd: Integer;
begin
  Result := 0;
  if FQuoteTrend <> nil then
  begin
    if (_Index >= 0) and (_Index < FQuoteTrend.TimeCount) then
      Result := FQuoteTrend.IndexToTime[_Index]
    else if (_Index < 0) and IsHasAuction and (AuctionMinuteCount > 0) then
    begin
      FQuoteTrend.GetVATime(tmpBegin, tmpEnd);
      Result := tmpEnd + _Index;
    end;
  end
end;

function TTimeData.TimeToIndex(_Time: Integer): Integer;
begin
  if FQuoteTrend <> nil then
    Result := FQuoteTrend.TimeToIndex(_Time)
  else
    Result := 0;
end;

{ TQuoteTimeData }

constructor TQuoteTimeData.Create(AContext: IAppContext);
begin
  inherited;
  FMainDatas := TList.Create;
  FMainDatas.Add(TTimeData.Create);
  FStackDatas := TList.Create;
  FMainSecuCode := '';
  FMainStockName := '';
  FIsSelfStock := False;
  FIsSubcribeHistory := False;
  FSubcribeHistoryDay := 0;
  FStringList := TStringList.Create;
end;

destructor TQuoteTimeData.Destroy;
begin
  if Assigned(FMainDatas) then
  begin
    Clean(FMainDatas);
    FMainDatas.Free;
  end;

  if Assigned(FStackDatas) then
  begin
    Clean(FStackDatas);
    FStackDatas.Free;
  end;
  inherited;
end;

procedure TQuoteTimeData.Clean(_List: TList);
var
  tmpIndex: Integer;
begin
  for tmpIndex := 0 to _List.Count - 1 do
    TObject(_List[tmpIndex]).Free;
  _List.Clear;
end;

//procedure TQuoteTimeData.ConnectQuoteManager(const _GilAppController
//  : IGilAppController; const _QuoteManager: IQuoteManagerEx;
//  const _GilRanges: IGilRanges);
//var
//  tmpLib: IUnknown;
//  QuoteMessage: TQuoteMessage;
//begin
//  FGilAppController := _GilAppController;
//  FQuoteManager := _QuoteManager;
//  tmpLib := _QuoteManager.GetTypeLib();
//  QuoteMessage := TQuoteMessage.Create(tmpLib as ITypeLib);
//  FQuoteMessage := QuoteMessage;
//  QuoteMessage.OnDataArrive := DoDataArrive;
//  QuoteMessage.OnDataReset := DoDataReset;
//  QuoteMessage.OnInfoReset := DoInfoReset;
//  FQuoteManager.ConnectMessage(FQuoteMessage);
//
//  FGilRanges := _GilRanges;
//end;

//procedure TQuoteTimeData.DisConnectQuoteManager;
//begin
//  FQuoteManager.Subscribe(QuoteType_TREND, 0, 0, FQuoteMessage.MsgCookie, 0);
//  FQuoteManager.Subscribe(QuoteType_HISTREND, 0, 0, FQuoteMessage.MsgCookie, 0);
//  FQuoteManager.DisconnectMessage(FQuoteMessage);
//  FQuoteMessage := nil;
//  FGilRanges := nil;
//end;

procedure TQuoteTimeData.DoChangeSelfStock;
begin
  if Assigned(MainData) then
    FIsSelfStock := GetIsSelfStock(MainData.InnerCode);
end;

procedure TQuoteTimeData.DoReSubcribeHqData;
begin

end;

procedure TQuoteTimeData.DoUnSubcirbeHqData;
begin
  if FQuoteManagerEx = nil then Exit;

  FQuoteManagerEx.Subscribe(QuoteType_TREND, 0, 0, FQuoteMessage.MsgCookie, 0);
  FQuoteManagerEx.Subscribe(QuoteType_HISTREND, 0, 0, FQuoteMessage.MsgCookie, 0);
end;

procedure TQuoteTimeData.DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TQuoteTimeData.DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin
  if not FIsSubcribeHistory then
    Subscribe
  else
    SubscribeHistory;
end;

procedure TQuoteTimeData.DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer);
var
  Ref: Boolean;
  tmpIndex, tmpI: Integer;
  tmpData: TTimeData;
  QuoteTrend: IQuoteTrend;
  QuoteMultiTrend: IQuoteMultiTrend;
begin
  Ref := False;
  if (FQuoteManagerEx = nil) then Exit;

  try
    if (AQuoteType = QuoteType_TREND) or (AQuoteType = QuoteType_REALTIME) then
    begin
      // 取当日数据和多日数据
      QuoteMultiTrend := FQuoteManagerEx.QueryData(QuoteType_TREND,
        Int64(@MainData.CodeInfo)) as IQuoteMultiTrend;
      if QuoteMultiTrend <> nil then
      begin
        for tmpIndex := 0 to QuoteMultiTrend.Count - 1 do
        begin
          if tmpIndex < FMainDatas.Count then
          begin
            QuoteTrend := QuoteMultiTrend.Datas[tmpIndex];
            tmpData := DataIndexToData(tmpIndex);
            if (QuoteTrend <> nil) and (tmpData <> nil) then
            begin
              Ref := tmpData.DataArrive(FQuoteManagerEx, QuoteTrend,
                (tmpIndex <> 0)) or Ref;
            end;
          end
          else
            Break;
        end;
      end;
      // 取叠加数据
      for tmpIndex := 0 to FStackDatas.Count - 1 do
      begin
        tmpData := StackDatas[tmpIndex];
        QuoteMultiTrend := FQuoteManagerEx.QueryData(QuoteType_TREND,
          Int64(@tmpData.CodeInfo)) as IQuoteMultiTrend;
        if (QuoteMultiTrend <> nil) and (QuoteMultiTrend.Count > 0) then
        begin
          QuoteTrend := QuoteMultiTrend.Datas[0];
          if QuoteTrend <> nil then
            Ref := tmpData.DataArrive(FQuoteManagerEx, QuoteTrend, False) or Ref;
        end;
      end;
    end
    else if AQuoteType = QuoteType_HISTREND then
    begin
      QuoteTrend := FQuoteManagerEx.QueryData(QuoteType_HISTREND,
        Int64(@MainData.CodeInfo)) as IQuoteTrend;
      if (QuoteTrend <> nil) and (FMainDatas.Count > 0) then
      begin
        Ref := MainData.DataArrive(FQuoteManagerEx, QuoteTrend, True) or Ref;
      end;
    end;
    if Ref then
      DoInvalidate;

//    if MainData.InnerCode > 7000000 {7006136} then
//    begin
//      for tmpIndex := 0 to FMainDatas.Count - 1 do begin
//        tmpData := DataIndexToData(tmpIndex);
//        if (tmpData <> nil) then begin
//          FStringList.Add('####################################################');
//          FStringList.Add(Format('StockName=%s, PreClose=%f, MaxPrice=%f, MinPrice=%f, Volume=%d, DataCount=%d',
//            [tmpData.StockName, tmpData.PrevClose, tmpData.MaxPrice, tmpData.MinPrice, tmpData.MaxVolume, tmpData.DataCount]));
//          for tmpI := 0 to tmpData.DataCount - 1 do begin
//            FStringList.Add(Format('Index=%d, NowPrice=%f, Volume=%f',
//              [tmpI, tmpData.Datas[dkPrice, tmpI], tmpData.Datas[dkVolume, tmpI]]));
//          end;
//        end;
//      end;
//
//      FStringList.SaveToFile('F:\time.log');
//    end;

  except
    on Ex: Exception do
    begin
//      if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
//      then
//      begin
      FAppContext.HQLog(llERROR, '[' + Self.ClassName + '] 执行 DoDataArrive 出错');
//        FGilAppController.GetLogWriter.Log(llError, '[' + Self.ClassName +
//          '] 执行 DoDataArrive 出错');
//      end
    end;
  end;
end;

procedure TQuoteTimeData.DoInvalidate;
begin
  if Assigned(FOnInvalidate) then
    FOnInvalidate;
end;

function TQuoteTimeData.GetHistoryDay: TDateTime;
begin
  Result := IntToDateTime(FSubcribeHistoryDay);
end;

function TQuoteTimeData.GetIsSelfStock(_InnerCode: Integer): Boolean;
begin
  Result := False;
//  if Assigned(FGilRanges) and Assigned(MainData) then
//  begin
//    Result := (FGilRanges.GetStockAttributeEx(_InnerCode) > 0);
//  end;
end;

function TQuoteTimeData.GetMainData: TTimeData;
begin
  Result := nil;
  if (FMainDatas <> nil) and (FMainDatas.Count > 0) then
    Result := DataIndexToData(0);
end;

function TQuoteTimeData.GetMainDatasCount: Integer;
begin
  Result := 1;
  if FMainDatas <> nil then
    Result := FMainDatas.Count;
end;

function TQuoteTimeData.GetMinuteCount: Integer;
var
  tmpData: TTimeData;
begin
  Result := 1;
  if FMainDatas <> nil then
  begin
    tmpData := DataIndexToData(0);
    Result := tmpData.MinuteCount;
  end;
end;

function TQuoteTimeData.GetPHSTypeTimes: PHSTypeTimes;
var
  tmpData: TTimeData;
begin
  Result := nil;
  if (FMainDatas <> nil) and (FMainDatas.Count > 0) then
  begin
    tmpData := DataIndexToData(0);
    Result := tmpData.PHSTimes;
  end;
end;

function TQuoteTimeData.GetStackCount: Integer;
begin
  Result := 0;
  if FStackDatas <> nil then
    Result := FStackDatas.Count;
end;

function TQuoteTimeData.GetStackDatas(_Index: Integer): TTimeData;
begin
  Result := nil;
  if FStackDatas <> nil then
    Result := TTimeData(FStackDatas.Items[_Index]);
end;

procedure TQuoteTimeData.Subscribe;
var
  tmpData, tmpMainData: TTimeData;
  tmpCodeInfo: TCodeInfo;
  CodeInfos: array of TCodeInfo;
  tmpIndex, tmpCount: Integer;
begin
  if FQuoteManagerEx = nil then Exit;

  if StackCount > 0 then
  begin
    tmpCount := 0;
    SetLength(CodeInfos, StackCount);
    for tmpIndex := 0 to StackCount - 1 do
    begin
      tmpData := StackDatas[tmpIndex];
      if Assigned(tmpData) then
      begin
        FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@tmpData.InnerCode),
          Int64(@tmpCodeInfo));
        tmpData.ChangeStock(@tmpCodeInfo);
        CodeInfos[tmpCount] := tmpCodeInfo;
        Inc(tmpCount);
      end;
    end;
    // 订阅叠加单日行情
    FQuoteManagerEx.Subscribe(QuoteType_TREND, Int64(@CodeInfos[0]), tmpCount,
      FQuoteMessage.MsgCookie, 0);
  end;

  FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@MainData.InnerCode),
    Int64(@tmpCodeInfo));
  for tmpIndex := 0 to FMainDatas.Count - 1 do
  begin
    tmpData := DataIndexToData(tmpIndex);
    if Assigned(tmpData) then
      tmpData.ChangeStock(@tmpCodeInfo);
  end;
  // 订阅涨停坐标
  SubscribeLimitAxis;
  // 订阅单日多日行情
  FQuoteManagerEx.Subscribe(QuoteType_TREND, Int64(@MainData.CodeInfo), 1,
    FQuoteMessage.MsgCookie, FMainDatas.Count);

  DoDataArrive(QuoteType_TREND, nil);

  tmpMainData := MainData;
  if Assigned(tmpMainData) and Assigned(FOnChangeValue) then
  begin
    if tmpMainData.StockType = stFutures then
    begin
      FOnChangeValue(GetFutureDecimals(tmpMainData.CodeInfo.m_cCode));
    end
    else if tmpMainData.StockType = stUSStock then
    begin
      FOnChangeValue(-1);
    end
    else
    begin
      FOnChangeValue(3);
    end;
  end;
end;

procedure TQuoteTimeData.Subscribe(_InnerCode, _DayCount: Integer);
var
  tmpData: TTimeData;
  tmpIndex: Integer;
begin
  FIsSelfStock := GetIsSelfStock(_InnerCode);
  if FQuoteManagerEx = nil then Exit;

  if (_DayCount > 0) and Assigned(MainData) then
  begin
    CancelSubcribe(False);
    if _DayCount = FMainDatas.Count then
    begin
      for tmpIndex := 0 to FMainDatas.Count - 1 do
      begin
        tmpData := DataIndexToData(tmpIndex);
        tmpData.ChangeStock(_InnerCode);
      end;
    end
    else if _DayCount > FMainDatas.Count then
    begin
      FMainDatas.Count := _DayCount;
      for tmpIndex := 0 to FMainDatas.Count - 1 do
      begin
        if FMainDatas.Items[tmpIndex] = nil then
        begin
          tmpData := TTimeData.Create;
          tmpData.ChangeStock(_InnerCode);
          FMainDatas.Items[tmpIndex] := tmpData;
        end
        else
        begin
          tmpData := FMainDatas.Items[tmpIndex];
          tmpData.ChangeStock(_InnerCode);
        end;
      end;
    end
    else
    begin
      for tmpIndex := FMainDatas.Count - 1 downto 0 do
      begin
        tmpData := DataIndexToData(tmpIndex);
        if (tmpData <> nil) and (tmpIndex >= _DayCount) then
        begin
          FMainDatas.Items[tmpIndex] := nil;
          tmpData.Free;
        end
        else
          tmpData.ChangeStock(_InnerCode);
      end;
      FMainDatas.Count := _DayCount;
    end;
    Subscribe;
  end;
end;

procedure TQuoteTimeData.SubscribeNDay(_DayCount: Integer);
var
  tmpIndex: Integer;
  tmpData: TTimeData;
begin
  if FQuoteManagerEx = nil then Exit;

  if (_DayCount > 0) and Assigned(MainData) then
  begin
    CancelSubcribe(False);
    if _DayCount > FMainDatas.Count then
    begin
      FMainDatas.Count := _DayCount;
      for tmpIndex := 0 to FMainDatas.Count - 1 do
      begin
        if FMainDatas.Items[tmpIndex] = nil then
        begin
          tmpData := TTimeData.Create;
          tmpData.ChangeStock(MainData.InnerCode);
          tmpData.ChangeStock(@MainData.InnerCode);
          tmpData.ChangeStock(@MainData.CodeInfo);
          FMainDatas.Items[tmpIndex] := tmpData;
        end;
      end;
    end
    else
    begin
      for tmpIndex := FMainDatas.Count - 1 downto _DayCount do
      begin
        if FMainDatas.Items[tmpIndex] <> nil then
        begin
          tmpData := FMainDatas.Items[tmpIndex];
          FMainDatas.Items[tmpIndex] := nil;
          tmpData.Free;
        end;
      end;
      FMainDatas.Count := _DayCount;
    end;
    Subscribe;
  end;
end;

procedure TQuoteTimeData.SubscribeStack(_InnerCodes: array of Integer;
  _Count: Integer);
var
  tmpIndex: Integer;
  tmpData: TTimeData;
  tmpCodeInfo: TCodeInfo;
begin
  if FQuoteManagerEx = nil then Exit;

  for tmpIndex := Low(_InnerCodes) to High(_InnerCodes) do
  begin
    FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@_InnerCodes[tmpIndex]),
      Int64(@tmpCodeInfo));
    tmpData := TTimeData.Create;
    tmpData.InnerCode := _InnerCodes[tmpIndex];
    FStackDatas.Add(tmpData);
    tmpData.ChangeStock(@tmpCodeInfo);
  end;
  Subscribe;
end;

procedure TQuoteTimeData.SubscribeStack(_InnerCode: Integer);
var
  tmpData: TTimeData;
  tmpCodeInfo: TCodeInfo;
begin
  if FQuoteManagerEx = nil then Exit;

  FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@_InnerCode),
    Int64(@tmpCodeInfo));
  if FStackDatas <> nil then
  begin
    tmpData := TTimeData.Create;
    tmpData.InnerCode := _InnerCode;
    FStackDatas.Add(tmpData);
    tmpData.ChangeStock(@tmpCodeInfo);
  end;
  Subscribe;
end;

procedure TQuoteTimeData.SubscribeHistory(_InnerCode, _Day: Integer);
begin
  FIsSelfStock := GetIsSelfStock(_InnerCode);
  FSubcribeHistoryDay := _Day;
  FIsSubcribeHistory := (FSubcribeHistoryDay <> DateToInt(Now));
  if FIsSubcribeHistory then
  begin
    CancelSubcribe(False);
    if Assigned(MainData) then
    begin
      MainData.ChangeStock(_InnerCode);
      MainData.IsHisData := FIsSubcribeHistory;
    end;
    SubscribeHistory;
    DoDataArrive(QuoteType_HISTREND, nil);
  end
  else
    Subscribe(_InnerCode);
end;

procedure TQuoteTimeData.SubscribeHistory;
var
  tmpCodeInfo: TCodeInfo;
begin
  if FQuoteManagerEx = nil then Exit;

  FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@MainData.InnerCode),
    Int64(@tmpCodeInfo));
  MainData.ChangeStock(@tmpCodeInfo);
  FQuoteManagerEx.Subscribe(QuoteType_HISTREND, Int64(@MainData.CodeInfo), 1,
    FQuoteMessage.MsgCookie, FSubcribeHistoryDay);
end;

procedure TQuoteTimeData.SubscribeLimitAxis;
begin
  if FQuoteManagerEx = nil then Exit;

  if (FMainDatas.Count > 0) and Assigned(MainData) then
  begin
    FQuoteManagerEx.Subscribe(QuoteType_LIMITPRICE, Int64(@MainData.CodeInfo),
      1, FQuoteMessage.MsgCookie, 0);
  end;
end;

function TQuoteTimeData.DataIndexToData(_DataIndex: Integer): TTimeData;
begin
  Result := nil;
  if (FMainDatas <> nil) and (_DataIndex >= 0) and
    (_DataIndex < FMainDatas.Count) then
    Result := TTimeData(FMainDatas.Items[_DataIndex]);
end;

function TQuoteTimeData.SelfStockOperate(_SelfStockOperate
  : TSelfStockOperate): Boolean;
//var
//  tmpUserSelReang: IUserRangeItem;
//  tmpUserItems: IUserRangeItem;
begin
  Result := False;
//  tmpUserItems := FGilRanges.GetUserRange;
//  if tmpUserItems.ItemCount >= 1 then
//  begin
//    tmpUserSelReang := (tmpUserItems.Items(0)) as IUserRangeItem;
//    if _SelfStockOperate = ssoAdd then
//    begin
//      Result := True;
//      tmpUserSelReang.AddSecu(MainData.InnerCode);
//      FIsSelfStock := True;
//    end
//    else if _SelfStockOperate = ssoDel then
//    begin
//      Result := True;
//      tmpUserSelReang.DelSecu(MainData.InnerCode);
//      FIsSelfStock := False;
//    end;
//    FGilRanges.UserRangeChange(FNotifyHandle);
//  end;
end;

procedure TQuoteTimeData.CleanMain;
var
  tmpIndex, tmpCount: Integer;
  tmpCodeInfo: TCodeInfo;
  tmpData: TTimeData;
begin
  // 主分时必须要有一个Data;
  tmpCount := 1;
  for tmpIndex := FMainDatas.Count - 1 downto tmpCount do
  begin
    tmpData := DataIndexToData(tmpIndex);
    if Assigned(tmpData) then
      tmpData.Free;
  end;
  if Assigned(MainData) then
  begin
    MainData.InnerCode := -1;
    MainData.ChangeStock(@tmpCodeInfo);
  end;
  FMainDatas.Count := tmpCount;
end;

procedure TQuoteTimeData.CleanStack;
begin
  if Assigned(FStackDatas) then
    Clean(FStackDatas);
end;

procedure TQuoteTimeData.CancelSubcribe(_ClearData: Boolean);
begin
  DoUnSubcirbeHqData;
  if _ClearData then
  begin
    CleanMain;
    CleanStack;
  end;
end;

end.
