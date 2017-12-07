unit QuoteDataMngr;

interface

uses windows, SysUtils, Classes, IniFiles, QuoteMngr_TLB, QuoteLibrary, QuoteConst,
  QuoteStruct, QuoteService, generics.Collections;

type
  TDataInfo = class
  public
    procedure Clear; virtual;
  end;

  // Ʒ����Ϣ ��ӦƷ�ֽ�����Ϣ�ṹ TStockType
  TStockTypeInfo = class(TDataInfo)
  private
  protected
    FStockType: TStockType;
    FTimes: TIntegerHash;
    FTimesList: TIntegerList;
  public

    // procedure AddTradingPeriod(HSTypeTime:THSTypeTime);
    procedure Clear; override;

    constructor create();
    destructor Destroy(); override;

    property StockType: TStockType read FStockType write FStockType;
    property Times: TIntegerHash read FTimes;
    // property  TimesList: TIntegerList read FTimesList;
  end;

  TQuoteDataMngr = class
  private
    // ������ʵʱ����
    FQuoteRealTime: IQuoteRealTime;
    FQuoteDDERealTime: IQuoteDDERealTime;
    FQuoteService: TQuoteService;
    FBourseInfoHash: TDictionary<USHORT, PCommBourseInfo>;
    FStockTypeInfoHash: TObjectDictionary<USHORT, TStockTypeInfo>;

    // ��д��
    FQuoteDataSync: TMultiReadExclusiveWriteSynchronizer;
    FQuoteDataObjs: TInterfaceList;
    FQuoteDataHash: TStringHash;

    FAppPath: string;
    FLevelPass: string;
    FLevelUser: string; //

    function Get_QuoteDataObjs(QuoteType: QuoteTypeEnum; Stock: PCodeInfo): IUnknown;
    procedure Set_QuoteDataObjs(QuoteType: QuoteTypeEnum; Stock: PCodeInfo; const Value: IUnknown);
    function Get_QuoteDataObjsByKey(QuoteType: QuoteTypeEnum; const Key: string): IUnknown;
    procedure Set_QuoteDataObjsByKey(QuoteType: QuoteTypeEnum; const Key: string; const Value: IUnknown);
  public
    constructor create(QuoteService: TQuoteService);
    destructor Destroy; override;

    function QuoteTypeToString(QuoteType: QuoteTypeEnum): string;

    procedure DoBourseInfoHashNotify(Sender: TObject; const p: PCommBourseInfo; Action: TCollectionNotification);
    function GetBourseInfo(m_nMarketType: USHORT): PCommBourseInfo;
    function GetStockTypeInfo(m_nMarketType: USHORT): TStockTypeInfo;

    property QuoteDataObjs[QuoteType: QuoteTypeEnum; Stock: PCodeInfo]: IUnknown read Get_QuoteDataObjs
      write Set_QuoteDataObjs;
    property QuoteDataObjsByKey[QuoteType: QuoteTypeEnum; const Key: string]: IUnknown read Get_QuoteDataObjsByKey
      write Set_QuoteDataObjsByKey;

    property QuoteRealTime: IQuoteRealTime read FQuoteRealTime;
    property QuoteDDERealTime: IQuoteDDERealTime read FQuoteDDERealTime;

    // ���յ�ʵʼ��֪ͨʱ ��������ڴ�����
    procedure InitDataMngr;

    procedure WriteDebug(const Value: string);
    procedure Progress(const Msg: string; Max, Value: Integer);

    procedure BeginWrite;
    procedure EndWrite;

    procedure BeginRead;
    procedure EndRead;

    property AppPath: string read FAppPath write FAppPath;
    property LevelUser: string read FLevelUser write FLevelUser;
    property LevelPass: string read FLevelPass write FLevelPass;
  end;

implementation

uses QuoteDataObject, QDODDERealTime;

{ TDataInfo }

procedure TDataInfo.Clear;
begin

end;

procedure TStockTypeInfo.Clear;
begin
  inherited;
  Times.Clear;
end;

constructor TStockTypeInfo.create;
begin
  inherited;
  FTimes := TIntegerHash.create(256);
end;

destructor TStockTypeInfo.Destroy;
begin
  FreeAndNil(FTimes);
  inherited;
end;

{ TQuoteDataMngr }

constructor TQuoteDataMngr.create(QuoteService: TQuoteService);
var
  FileName: string;
begin
  FQuoteService := QuoteService;

  SetLength(FileName, MAX_PATH);
  GetModuleFileName(HInstance, PChar(FileName), MAX_PATH);
  FAppPath := ExtractFilePath(PChar(FileName));

  // �������ݶ���
  FQuoteDataSync := TMultiReadExclusiveWriteSynchronizer.create;
  FQuoteDataObjs := TInterfaceList.create;
  FQuoteDataHash := TStringHash.create;

  // ���� �����ƶ���
  FQuoteRealTime := TQuoteRealTime.create(self);
  FBourseInfoHash := TDictionary<USHORT, PCommBourseInfo>.create(20);
  FBourseInfoHash.OnValueNotify := DoBourseInfoHashNotify;
  FStockTypeInfoHash := TObjectDictionary<USHORT, TStockTypeInfo>.create([doOwnsValues], 100);
  FQuoteDDERealTime := TQuoteDDERealTimeData.create(self);
end;

destructor TQuoteDataMngr.Destroy;
begin
  FreeAndNil(FBourseInfoHash);
  FreeAndNil(FStockTypeInfoHash);
  FQuoteRealTime := nil;
  FQuoteDDERealTime := nil;
  inherited Destroy;
end;

procedure TQuoteDataMngr.InitDataMngr;
begin
  FQuoteDataSync.BeginWrite;
  try
    if FQuoteRealTime <> nil then
    begin
      //
    end;

    FQuoteDataObjs.Clear;
    FQuoteDataHash.Clear;
  finally
    FQuoteDataSync.EndWrite;
  end;
end;

procedure TQuoteDataMngr.Progress(const Msg: string; Max, Value: Integer);
begin
  { if FQuoteService <> nil then
    FQuoteService.Progress(Msg, Max, Value); }
end;

procedure TQuoteDataMngr.BeginWrite;
begin
  FQuoteDataSync.BeginWrite;
end;

procedure TQuoteDataMngr.EndWrite;
begin
  FQuoteDataSync.EndWrite;
end;

procedure TQuoteDataMngr.BeginRead;
begin
  FQuoteDataSync.BeginRead;
end;

procedure TQuoteDataMngr.EndRead;
begin
  FQuoteDataSync.EndRead;
end;

function TQuoteDataMngr.Get_QuoteDataObjs(QuoteType: QuoteTypeEnum; Stock: PCodeInfo): IUnknown;
var
  i: Integer;
begin
  result := nil;

  if (QuoteType = QuoteType_REALTIME) or(QuoteType = QuoteType_REALTIMEInt64) or
    (QuoteType = QuoteType_Level_REALTIME) or (QuoteType = QuoteType_CODEINFOS) then
    result := FQuoteRealTime
  else if (QuoteType = QuoteType_DDEBigOrderRealTimeByOrder) then
    result := FQuoteDDERealTime
  else
  begin
    FQuoteDataSync.BeginRead;
    try
      i := FQuoteDataHash.ValueOf(QuoteTypeToString(QuoteType) + CodeInfoKey(Stock^.m_cCodeType, CodeInfoToCode(Stock)));
      if (i <> -1) and (i < FQuoteDataObjs.Count) then
        result := FQuoteDataObjs[i];
    finally
      FQuoteDataSync.EndRead;
    end;
  end;
end;

function TQuoteDataMngr.Get_QuoteDataObjsByKey(QuoteType: QuoteTypeEnum; const Key: string): IUnknown;
var
  i: Integer;
begin
  result := nil;

  // if (QuoteType = QuoteType_REALTIME) or (QuoteType = QuoteType_Level_REALTIME) then
  // result := FQuoteRealTime
  // else if  then
  // result := FQuoteDDERealTime;
  // else begin
  FQuoteDataSync.BeginRead;
  try
    i := FQuoteDataHash.ValueOf(QuoteTypeToString(QuoteType) + Key);
    if (i <> -1) and (i < FQuoteDataObjs.Count) then
      result := FQuoteDataObjs[i];
  finally
    FQuoteDataSync.EndRead;
  end;
  // end;
end;

function TQuoteDataMngr.QuoteTypeToString(QuoteType: QuoteTypeEnum): string;
begin
  case QuoteType of
    QuoteType_REALTIME:
      result := 'REALTIME_'; // ������
    QuoteType_REPORTSORT:
      result := 'REPORTSORT_'; // �������۱�
    QuoteType_GENERALSORT:
      result := 'GENERALSORT_'; // �ۺ�����
    QuoteType_TREND:
      result := 'TREND_'; // ��ʱ����
    QuoteType_STOCKTICK:
      result := 'STOCKTICK_'; // ���ɷֱ�
    QuoteType_LIMITTICK:
      result := 'LIMITTICK_'; // ���Ʒֱ�
    QuoteType_TECHDATA_MINUTE1:
      result := 'MINUTE1_'; // 1������
    QuoteType_TECHDATA_MINUTE5:
      result := 'MINUTE5_'; // 5������
    QuoteType_TECHDATA_MINUTE15:
      result := 'MINUTE15_'; // 15������
    QuoteType_TECHDATA_MINUTE30:
      result := 'MINUTE30_'; // 30������
    QuoteType_TECHDATA_MINUTE60:
      result := 'MINUTE60_'; // 60������
    QuoteType_TECHDATA_DAY:
      result := 'DAY_'; // ����
    // QuoteType_TECHDATA_WEEK:   result := 'WEEK_';     //����
    // QuoteType_TECHDATA_MONTH:   result := 'MONTH_';     //����
    QuoteType_Level_REALTIME:
      result := 'LevelREALTIME_';
    QuoteType_Level_TRANSACTION:
      result := 'LevelTRANSACTION_';
    QuoteType_Level_ORDERQUEUE:
      result := 'LevelORDERQUEUE_';
    QuoteType_Level_SINGLEMA:
      result := 'LevelSINGLEMA_';
    QuoteType_Level_TOTALMAX:
      result := 'LevelTOTALMAX_';
    QuoteType_HISTREND:
      result := 'HisTrend_';
    QuoteType_CODEINFOS:
      result := 'CodeInfos_';
    QuoteType_SingleColValue:
      result := 'SingleColValue_';
    QuoteType_MarketMonitor:
      result := 'MarketMonitor_';
    QuoteType_LIMITPRICE:
      result := 'LIMITPRICE_';
    QuoteType_DDEBigOrderRealTimeByOrder:
      result := 'DDEBigOrderRealTimeByOrder_';
  else
    result := '_';
  end;
end;

procedure TQuoteDataMngr.Set_QuoteDataObjs(QuoteType: QuoteTypeEnum; Stock: PCodeInfo; const Value: IInterface);
var
  i: Integer;
begin
  FQuoteDataSync.BeginWrite;
  try
    i := FQuoteDataObjs.Add(Value);
    FQuoteDataHash.Add(QuoteTypeToString(QuoteType) + CodeInfoKey(Stock^.m_cCodeType, CodeInfoToCode(Stock)), i);
  finally
    FQuoteDataSync.EndWrite;
  end;

end;

procedure TQuoteDataMngr.Set_QuoteDataObjsByKey(QuoteType: QuoteTypeEnum; Const Key: string; const Value: IInterface);
var

  i: Integer;
begin
  FQuoteDataSync.BeginWrite;
  try
    i := FQuoteDataObjs.Add(Value);
    FQuoteDataHash.Add(QuoteTypeToString(QuoteType) + Key, i);
  finally
    FQuoteDataSync.EndWrite;
  end;
end;

procedure TQuoteDataMngr.WriteDebug(const Value: string);
begin
  if FQuoteService <> nil then
    FQuoteService.WriteDebug(Value);
end;

procedure TQuoteDataMngr.DoBourseInfoHashNotify(Sender: TObject; const p: PCommBourseInfo;
  Action: TCollectionNotification);
begin
  if Action = cnRemoved then
    Dispose(p);
end;

function TQuoteDataMngr.GetBourseInfo(m_nMarketType: USHORT): PCommBourseInfo;
var
  Key: USHORT;
begin
  Key := m_nMarketType and $FF00; // ���ֽ��г�����
  if not FBourseInfoHash.TryGetValue(Key, result) then
  begin
    self.FQuoteDataSync.BeginWrite;
    try
      if not FBourseInfoHash.TryGetValue(Key, result) then
      begin
        new(result);
        FBourseInfoHash.Add(Key, result);
      end;
    finally
      FQuoteDataSync.EndWrite;
    end;
  end;
end;

function TQuoteDataMngr.GetStockTypeInfo(m_nMarketType: USHORT): TStockTypeInfo;
begin

  if not FStockTypeInfoHash.TryGetValue(m_nMarketType, result) then
  begin
    FQuoteDataSync.BeginWrite;
    try
      if not FStockTypeInfoHash.TryGetValue(m_nMarketType, result) then
      begin
        result := TStockTypeInfo.create;
        FStockTypeInfoHash.Add(m_nMarketType, result);
      end;
    finally
      FQuoteDataSync.EndWrite;
    end;
  end;
end;

end.
