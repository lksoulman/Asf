unit QuoteDataObject;

interface

uses Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
  QuoteStructInt64,  QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs,
  QuoteDataMngr,GilQuoteStruct, Generics.collections, QDOBase;

type
  // ��ʱ����
  TQuoteTrend = class(TQuoteSync, IQuoteTrend)
  protected
    FCodeInfo: TCodeInfo;
    FData: array of TTrendDataUnion;
    FTrendInfo: TTrendInfo;
    FCount: Integer;
    FVACount: Integer;
    FVadata: array of TStockVirtualAuction;
    FVarCode: Integer;
    FStockTypeInfo: TStockTypeInfo;
    // FLastVol:UInt32;

    procedure UpdateTrendData(Data: Pointer; size: Integer);
    procedure UpdateTrendData_Ext(Data: Pointer; size: Integer);
    procedure UpdateAutoPush(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext(Data: Pointer; size: Integer);
    procedure UpdateDelayAutoPush_Ext(Data: Pointer; size: Integer);
    procedure UpdateHisTrendData(Data: Pointer; size: Integer);
    // procedure UpdateMultiTrendData(Data: Pointer; size: integer);
    procedure UpdateMILeadData(Data: Pointer; size: Integer);
    procedure UpdateMITickData(Data: Pointer; size: Integer);

    procedure UpdateVAData(Data: Pointer; size: Integer);

    // �������ָ������ָ��ֵ
    function CalcLeadTech(MILead: short): LongInt;

    procedure GetPrevCose(); virtual;
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteTrend }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_IndexToTime(Index: Integer): Integer; safecall;
    function Get_TimeCount: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    function TimeToIndex(Time: Integer): Integer; safecall;
    function GetTrendInfo: Int64; safecall;
    function Get_VADatas: Int64; safecall;
    function Get_VADataCount: Integer; safecall;
    procedure GetVATime(var Begin_: Integer; var End_: Integer); safecall;
    function IsVAData: WordBool; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  THisQuoteTrend = class(TQuoteTrend, IQuoteTrendHis)
  protected
    FDate: Integer;
    procedure ResetDate(ADate: Integer); safecall;
    procedure GetPrevCose(); override;
  end;

  TQuoteMultiTrend = class(TQuoteSync, IQuoteMultiTrend)
  protected
    FCodeInfo: TCodeInfo;
    FData: array of IQuoteTrend;
    FCount: Integer;
    FVarCode: Integer;

    // procedure UpdateMultiTrendDatas(pData:PStockCompDayDataExs;Size:Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;

    { IQuoteMultiTrend }
    function count: Integer; safecall;
    function Get_Datas(Index: Integer): IQuoteTrend; safecall;

    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  // ���ɷֱ�
  TQuoteStockTick = class(TQuoteSync, IQuoteStockTick)
  private
    FCodeInfo: TCodeInfo;
    FData: array of TStockTick;
    FTimes: TIntegerHash;
    FCapacity: Integer;
    FCount: Integer;
    FVarCode: Integer;
    FLastTotal: ULong;
    procedure GrowData(count: Integer);

    procedure UpdateStockTickData(Data: Pointer; size: Integer);
    procedure UpdateAutoPush(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext(Data: Pointer; size: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteStockTick }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_IndexToTime(Index: Integer): Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  // ����������
  TQuoteReportSort = class(TQuoteSync, IQuoteReportSort)
  private
    FReqReportSort: TReqReportSort;
    FCodeInfos: array of TCodeInfo;
    FCount: Integer;

    FData: array of TCodeInfo;
    FVarCode: Integer;

    procedure UpdateReprotSortData(Codes: PCodeInfos; count: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfos: PCodeInfos; count: Integer;
      ReqReportSort: PReqReportSort);
    destructor Destroy; override;

    { IQuoteReportSort }
    function Get_SortType: Integer; safecall;
    function Get_Data: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  // RT_RISE = $0001;  //�Ƿ�����
  // RT_FALL = $0002;  //��������
  // RT_5_RISE = $0004;  //5�����Ƿ�����
  // RT_5_FALL = $0008;  //5���ӵ�������
  // RT_AHEAD_COMM = $0010;  //��������(ί��)��������
  // RT_AFTER_COMM = $0020;  //��������(ί��)��������
  // RT_AHEAD_PRICE = $0040;  //�ɽ��������������
  // RT_AHEAD_VOLBI = $0080;  //�ɽ����仯(����)��������
  // RT_AHEAD_MONEY = $0100;  //�ʽ�������������

  // �ۺ�����
  TQuoteGeneralSort = class(TQuoteSync, IQuoteGeneralSort)
  private
    FReqGeneralSort: TReqGeneralSortEx;
    FTypeCount: Integer;
    FData: array of TGeneralSortData;

    FVarCode: Integer;
    procedure UpdateGeneralSortData(AnsGeneralSortEx: PAnsGeneralSortEx);
    procedure UpdateReqGeneralSort(ReqGeneralSort: PReqGeneralSortEx);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy; override;
    { IQuoteGeneralSort }
    function Get_Count: Integer; safecall;
    function Get_Data: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
    function DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant): WideString;
      override; safecall;
  end;

  // TQuoteTechData ������֯ԭ��
  // ��һ��ԭ��  ��ǰֻ��һ�������, �����ڵȴ����ݷ���ʱ����������, ��¼���ֵ�����ݵ�����ٷ���
  // �ڶ���ԭ��  ������������С�ڵ��ڵ�ǰ����ʱ,ֻ�����첿��(��ֵ�������)
  // ���������������뵱ǰ����ʱ, ȫ������
  TQuoteTechData = class(TQuoteSync, IQuoteTechData)
  private
    FCodeInfo: TCodeInfo;
    FTimes: TIntegerHash;
    FQuoteType: QuoteTypeEnum;
    FData: array of TStockCompDayDataEx;
    FCount: Integer; // ��С
    FCapacity: Integer; // ����
    FCacheDate: UINT;
    FMarkDate: UINT;
    FVarCode: Integer;
    FIsBusy: Integer;
    FWaitCount: Integer;
    FLastVol: ULong;
    FLastMoney: Single;
    procedure GrowData(count: Integer);
    procedure LoadCacheData;
    procedure SaveCacheData;

    procedure UpdateAutoPush_MultiMin(Data: Pointer; size: Integer; MinCount: Integer);
    procedure UpdateAutoPush_Ext_MultiMin(Data: Pointer; size: Integer; MinCount: Integer);

    procedure UpdateATechData(P: PStockCompDayDataEx; InData: PCommRealTimeData; IsNew: Boolean);
    procedure UpdateATechData_Ext(P: PStockCompDayDataEx; InData: PCommRealTimeData_Ext; IsNew: Boolean);
    // ����ȫ������
    procedure UpdateTechData(Data: Pointer; size: Integer);
    // ���� ����
    procedure UpdateAutoPush_Day(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext_Day(Data: Pointer; size: Integer);
    // ���� һ����
    procedure UpdateAutoPush_MINUTE1(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext_MINUTE1(Data: Pointer; size: Integer);
    // ���� �����
    procedure UpdateAutoPush_MINUTE5(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext_MINUTE5(Data: Pointer; size: Integer);

    procedure UpdateAutoPush_WEEK(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext_WEEK(Data: Pointer; size: Integer);

    procedure UpdateAutoPush_MONTH(Data: Pointer; size: Integer);
    procedure UpdateAutoPush_Ext_MONTH(Data: Pointer; size: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo; QuoteType: QuoteTypeEnum);
    destructor Destroy; override;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
    function DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant): WideString;
      override; safecall;
    { IQuoteTechData }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
  end;

  // ������
  TStockInfoIndex = class
  public
    ArrayIndex: Integer;
    InfoIndex: Integer;
  end;

  TStockInfos = array of TStockInfo;

Const
  StockInfo_ARRAY_COUNT = 21;

  SH_STOCK_INDEX = 0; // �Ϻ�������
  SZ_STOCK_INDEX = 1; // ��֤������
  FUTURES_SH_STOCK_INDEX = 2; // �Ϻ��ڻ�������
  FUTURES_DL_STOCK_INDEX = 3; // ������Ʒ������
  FUTURES_ZZ_STOCK_INDEX = 4; // ֣����Ʒ������
  FUTURES_STOCK_STOCK_INDEX = 5; // �����ڻ�������
  HK_STOCK_STOCK_INDEX = 6; // �۹�����
  HK_GE_STOCK_INDEX = 7; // �۹ɴ�ҵ��
  HK_INDEX_STOCK_INDEX = 8; // �۹�ָ��
  A_OTHER_STOCK_INDEX = 9; // ����ָ�� ��֤������ָ��
  FOREIGN_INNER_BANK_BOND_INDEX = 10; // ���м�ծȯ
  FOREIGN_INNER_BANK_CLB_INDEX = 11; // ���ò�� Credit lending /borrowing
  FOREIGN_INNER_BANK_PSR_INDEX = 12; // Pledge-style Repo ��Ѻʽ�ع�
  FOREIGN_INNER_BANK_OR_INDEX = 13; // outright repo   ���ʽ�ع�
  OTHER_SECU_INDEX = 14; // ����֤ȯ
  GZ_STOCK_INDEX = 15; // ������
  OPT_INDEX = 16; // ��Ʊ��Ȩ
  SWI_INDEX = 17; // ����ָ��
  GNBI_INDEX = 18; // ������ָ��
  ZXI_INDEX = 19; // ����ָ��
  US_Index = 20; // ����

type

  TQuoteRealTime = class(TQuoteSync, IQuoteRealTime, IQuoteCodeInfos)
  private
    // Ϊ�˼�����ǰ�Ľӿ�,������HASH��Array��������֤ȯ��Ϣ.
    FStockInfoHash: TObjectDictionary<String, TStockInfoIndex>;
    //ͨ��֤ȯ���Ʋ�ѯ֤ȯ��Ϣ
    FNameToStockInfoHash: TObjectDictionary<String, TStockInfoIndex>;
    //���¸���ָ������ʱ�򴥷����¼�
    FUpdateConceptCodesEvent: TNotifyEvent;
    FStockInfoArrays: array [0 .. StockInfo_ARRAY_COUNT - 1] of TStockInfos;
    FLimitPriceHash: TDictionary<String, PLimitPrice>;
    FLevelData: TDictionary<String, PQuoteL2RealTimeData>;

    FFinances: array of TFinanceInfo;
    FExRights: array of TExRightItem;
    FRightBaseDate: Integer;
    FRealDatas: TList;
    FRealDatasInt64: TList;
    FRealDataHash: TIntegerHash;
    FRealDataHashInt64: TIntegerHash;
    // ���´����
    procedure UpdateCodes(Data: Pointer; MarketType: Integer);
    // �����ǵ�ͣ����
    procedure UpdateServerCalcData(Data: Pointer; size: Integer);
    // ���µ�ǰ����
    procedure UpdateCurrentFinance(Data: Pointer; size: Integer);
    // ���¸�Ȩ
    procedure UpdateExRight(Data: Pointer; size: Integer);
    // ����RealTime����
    procedure UpdateRealTimeData(Data: Pointer; size: Integer);

    // ʵʱ
    procedure UpdateRealTimeDataExt(Data: Pointer; size: Integer);
    procedure UpdateRealTimeInt64DataExt(Data: Pointer; size: Integer);

    procedure UpdateLevelRealTimeData(Data: Pointer; size: Integer);

    // �õ���Ӧ���͵�Index
    // function CodeTypeToIndex(CodeType: Word; const Code: AnsiString): integer;
    // �õ���Ӧ���͵�Stocks
    // function CodeTypeToStocks(CodeType: Word; var Len: integer): PStockInfos;
    // �õ�ȫ��Ψһ��KeyIndex
    function CodeTypeToKeyIndex(CodeType: Word; const Code: string): Integer;

    procedure ResetRealTime;

    procedure DoLimitPriceHashDel(AObject: TObject; const Item: PLimitPrice; Action: TCollectionNotification);
    procedure DoL2LevelData(AObject: TObject; const Item: PQuoteL2RealTimeData; Action: TCollectionNotification);
    function IsIndexToPlateCode(AMarket: USHORT; ASecuCode: string): Boolean; virtual;
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy; override;

    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;

    { IQuoteRealTime }
    function Get_Codes(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_Finances(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_ExRights(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_Datas(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_DatasInt64(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_LevelDatas(CodeType: Smallint; const Code: WideString): Int64; safecall;
    function Get_CodeToKeyIndex(CodeType: Word; const Code: WideString): Integer; safecall;
    function Get_PrevClose(CodeType: Word; const Code: WideString): Integer; safecall;
    function GetStockTypeInfo(CodeType: Word): Int64; safecall;
    // function GetStockInfo(CodeType: Word; const Code: WideString): Int64; safecall;
    function GetInitDate(CodeType: Word): Int64; safecall;
    function GetCodeInfoByKeyStr(const Key: WideString; out CodeInfo: Int64): WordBool; safecall;
    function GetCodeInfoByName(AName: string; out CodeInfo: Int64): WordBool; safecall;
    procedure SetUpdateConceptCodesEvent(AFunc: TNotifyEvent); safecall;
    function GetLimitPrice(CodeType: Word; const Code: WideString): Int64; safecall;
    { IQuoteCodeInfos }
    function Get_CodeInfos(CodeType: CodeTypeEnum; out count: Integer): Int64; safecall;
  end;

  // Level2 ���ɷֱ�
  TQuoteLevelTransaction = class(TQuoteSync, IQuoteLevelTransaction)
  private
    FCodeInfo: TCodeInfo;
    FData: array of TStockTransaction;
    FCapacity: Integer;
    FCount: Integer;
    FVarCode: Integer;
    procedure GrowData(count: Integer);

    procedure UpdateTransactionData(Data: Pointer; size: Integer);
    procedure UpdateAutoPush(Data: Pointer; size: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteLevelTransaction }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  TQuoteLevelOrderQueue = class(TQuoteSync, IQuoteLevelOrderQueue)
  private
    FCodeInfo: TCodeInfo;
    FBuyOrderQueue: PLevelOrderQueue;
    FSellOrderQueue: PLevelOrderQueue;
    FVarCode: Integer;

    procedure UpdateOrderQueueData(Data: Pointer; size: Integer);
    // procedure UpdateAutoPush(Data: Pointer; size: integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteLevelOrderRank }
    function Get_BuyData: Int64; safecall;
    function Get_SellData: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  TQuoteLevelSINGLEMA = class(TQuoteSync, IQuoteLevelSINGLEMA)
  private
    FCodeInfo: TCodeInfo;
    FVarCode: Integer;

    procedure UpdateSINGLEMAData(Data: Pointer; size: Integer);
    procedure UpdateAutoPush(Data: Pointer; size: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteLevelSINGLEMA }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

  TQuoteLevelTOTALMAX = class(TQuoteSync, IQuoteLevelTOTALMAX)
  private
    FCodeInfo: TCodeInfo;
    FVarCode: Integer;

    procedure UpdateTOTALMAXData(Data: Pointer; size: Integer);
    procedure UpdateAutoPush(Data: Pointer; size: Integer);
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
    destructor Destroy; override;
    { IQuoteLevelTOTALMAX }
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; size: Integer); override; safecall;
  end;

implementation

uses ComServ, QuoteService;

var

  G_StringList: TStringList;

  procedure AddLog(ALog: string);
  begin
    G_StringList.Add(ALog);
  end;

  procedure SaveLog(AFile: string);
  begin
    G_StringList.SaveToFile(AFile);
  end;

{ TQuoteRealTime }

// function TQuoteRealTime.CodeTypeToIndex(CodeType: Word; const Code: AnsiString): integer;
// var
// StockHash : TStringHash;
// begin
// result := -1;
// StockHash := nil;
// if HSMarketBourseType(CodeType, STOCK_MARKET, SH_BOURSE)  then begin
// StockHash := FSHStockHash;
// end else if HSMarketBourseType(CodeType, STOCK_MARKET, SZ_BOURSE) then begin
// StockHash := FSZStockHash;
// end else if HSMarketType(CodeType, OTHER_MARKET)  then begin
// StockHash := FOther_Hash;
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, DALIAN_BOURSE) then begin
// StockHash := FFutues_DLHash;
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, SHANGHAI_BOURSE) then begin
// StockHash := FFutues_SHHash;
//
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then begin
// StockHash := FFutues_ZZHash;
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, GUZHI_BOURSE) then begin
//
// StockHash := FFutues_StockHash;
// //�۹�����
// end else if HSMarketBourseType(CodeType, HK_MARKET, HK_BOURSE) then begin
// StockHash := FHK_StockHash
// //�۹�ָ��
// end else if HSMarketBourseType(CodeType, HK_MARKET, GE_BOURSE) then begin
// StockHash := FHK_GEHash
// end else if HSMarketBourseType(CodeType, HK_MARKET, INDEX_BOURSE) then begin
// StockHash := FHK_IndexHash
//
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, YHJZQ_BOURSE) then begin
// StockHash := FForeign_YHJZQHash;        //���м�ծȯ
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, XHCJ_BOURSE) then begin
// StockHash := FForeign_XHCJHash;                      //���ò��
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, ZYSHG_BOURSE) then begin
// StockHash := FForeign_ZYSHGHash;                //��Ѻʽ�ع�
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, MDSHG_BOURSE) then begin
// StockHash := FForeign_MDSHGHash;            //���ʽ�ع�
// end;
//
//
// if StockHash <> nil then begin
// Result := StockHash.ValueOf(CodeInfoKey(CodeType, Code));
// end;
//
// end;

function TQuoteRealTime.CodeTypeToKeyIndex(CodeType: Word; const Code: string): Integer;
var
  AStockInfoIndex: TStockInfoIndex;
begin
  result := -1;
  if FStockInfoHash.TryGetValue(CodeInfoKey(CodeType, Code), AStockInfoIndex) then
    result := AStockInfoIndex.ArrayIndex * 1000000 + AStockInfoIndex.InfoIndex;

  { if Index > -1  then begin
    if HSMarketBourseType(CodeType, STOCK_MARKET, SH_BOURSE)  then begin    // �Ϻ�
    Result := SH_BOURSE_Mark + Index
    end else if HSMarketBourseType(CodeType, STOCK_MARKET, SZ_BOURSE) then begin  // ����
    Result := SZ_BOURSE_Mark + Index
    end else if HSMarketBourseType(CodeType, FUTURES_MARKET, DALIAN_BOURSE) then begin
    Result := FUTURES_DALIAN_BOURSE_Mark + Index //����
    end else if HSMarketBourseType(CodeType, FUTURES_MARKET, SHANGHAI_BOURSE) then begin
    Result := FUTURES_SHANGHAI_BOURSE_Mark + Index  //�Ϻ� ��Ʒ
    end else if HSMarketBourseType(CodeType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then begin
    Result := FUTURES_ZHENGZHOU_BOURSE_Mark + Index  //֣�� ��Ʒ
    end else if HSMarketBourseType(CodeType, FUTURES_MARKET, GUZHI_BOURSE) then begin
    Result := FUTURES_GUZHI_BOURSE_Mark + Index       //��ָ�ڻ�
    //�۹�����
    end else if HSMarketBourseType(CodeType, HK_MARKET, HK_BOURSE) then begin
    Result := HK_BOURSE_Mark + Index
    //�۹�ָ��
    end else if HSMarketBourseType(CodeType, HK_MARKET, GE_BOURSE) then begin
    Result := HK_GE_BOURSE_Mark  + Index
    end else if HSMarketBourseType(CodeType, HK_MARKET, INDEX_BOURSE) then begin
    Result := HK_INDEX_BOURSE_Mark + Index
    end else if HSMarketBourseType(CodeType, Foreign_MARKET, YHJZQ_BOURSE) then begin
    Result := YHJZQ_BOURSE_Mark + Index  //���м�ծȯ
    end else if HSMarketBourseType(CodeType, Foreign_MARKET, XHCJ_BOURSE) then begin
    Result := XHCJ_BOURSE_Mark + Index                //���ò��
    end else if HSMarketBourseType(CodeType, Foreign_MARKET, ZYSHG_BOURSE) then begin
    Result := ZYSHG_BOURSE_Mark + Index          //��Ѻʽ�ع�
    end else if HSMarketBourseType(CodeType, Foreign_MARKET, MDSHG_BOURSE) then begin
    Result := MDSHG_BOURSE_Mark + Index            //���ʽ�ع�

    end else if HSMarketType(CodeType, OTHER_MARKET) then begin
    Result := A_OTHER_BOURSE_Mark  + Index
    end
    else
    Result := OTHER_SECU_MARK  + Index;
    end; }
end;

constructor TQuoteRealTime.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteRealTime);
  FStockInfoHash := TObjectDictionary<String, TStockInfoIndex>.Create([doOwnsValues], 20000);
  FNameToStockInfoHash := TObjectDictionary<String, TStockInfoIndex>.Create([doOwnsValues], 1000);
  FUpdateConceptCodesEvent := nil;
  FRightBaseDate := trunc(EncodeDate(1970, 1, 1));
  FRealDatas := TList.Create;
  FRealDatasInt64 := TList.Create;
  FRealDataHash := TIntegerHash.Create;
  FRealDataHashInt64 := TIntegerHash.Create;
  FLimitPriceHash := TDictionary<String, PLimitPrice>.Create(200);
  FLimitPriceHash.OnValueNotify := DoLimitPriceHashDel;
  FLevelData := TDictionary<String, PQuoteL2RealTimeData>.Create(48);
  FLevelData.OnValueNotify := DoL2LevelData;
end;

destructor TQuoteRealTime.Destroy;
var
  i: Integer;
begin
  FreeAndNil(FLimitPriceHash);
  FreeAndNil(FLevelData);
  if FStockInfoHash <> nil then
  begin
    FStockInfoHash.Clear;
    FreeAndNil(FStockInfoHash);
  end;
  if FNameToStockInfoHash <> nil then
  begin
    FNameToStockInfoHash.Clear;
    FreeAndNil(FNameToStockInfoHash);
  end;
  for i := 0 to High(FStockInfoArrays) do
    SetLength(FStockInfoArrays[0], 0);

  if FRealDatas <> nil then
  begin
    for i := 0 to FRealDatas.count - 1 do
      FreeMemEx(FRealDatas[i]);

    FRealDatas.Free;
    FRealDatas := nil;
  end;

  if FRealDatasInt64 <> nil then
  begin
    for i := 0 to FRealDatasInt64.count - 1 do
      FreeMemEx(FRealDatasInt64[i]);

    FRealDatasInt64.Free;
    FRealDatasInt64 := nil;
  end;

  if FRealDataHashInt64 <> nil then
  begin
    FRealDataHashInt64.Free;
    FRealDataHashInt64 := nil;
  end;

  if FRealDataHash <> nil then
  begin
    FRealDataHash.Free;
    FRealDataHash := nil;
  end;

  inherited;
end;

function TQuoteRealTime.Get_CodeInfos(CodeType: CodeTypeEnum; out count: Integer): Int64;
begin
  result := 0;
  count := 0;
  case CodeType of
    SHStock:
      begin // �Ϻ�
        count := Length(FStockInfoArrays[SH_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[SH_STOCK_INDEX]);
      end;
    SZStock:
      begin // ����
        count := Length(FStockInfoArrays[SZ_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[SZ_STOCK_INDEX]);
      end;
    Futues_SH:
      begin // �Ϻ� ��Ʒ
        count := Length(FStockInfoArrays[FUTURES_SH_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[FUTURES_SH_STOCK_INDEX]);
      end;
    Futues_DL:
      begin // ����
        count := Length(FStockInfoArrays[FUTURES_DL_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[FUTURES_DL_STOCK_INDEX]);
      end;
    Futues_ZZ:
      begin // ֣�� ��Ʒ
        count := Length(FStockInfoArrays[FUTURES_ZZ_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[FUTURES_ZZ_STOCK_INDEX]);
      end;
    Futues_Stock:
      begin // ��ָ�ڻ�
        count := Length(FStockInfoArrays[FUTURES_STOCK_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[FUTURES_STOCK_STOCK_INDEX]);
      end;
    HK_Stock:
      begin // �۹�����
        count := Length(FStockInfoArrays[HK_STOCK_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[HK_STOCK_STOCK_INDEX]);
      end;
    HK_GE:
      begin // �۹ɴ�ҵ
        count := Length(FStockInfoArrays[HK_GE_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[HK_GE_STOCK_INDEX]);
      end;
    HK_Index:
      begin // �۹�ָ��
        count := Length(FStockInfoArrays[HK_INDEX_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[HK_INDEX_STOCK_INDEX]);
      end;
    Other_Stock:
      begin // FOther_Hash
        count := Length(FStockInfoArrays[A_OTHER_STOCK_INDEX]);
        result := Int64(@FStockInfoArrays[A_OTHER_STOCK_INDEX]);
      end;
  end;
end;

function TQuoteRealTime.Get_Codes(CodeType: Word; const Code: WideString): Int64;
var
  AStockInfoIndex: TStockInfoIndex;
begin
  BeginRead;
  try
    result := 0;
    if FStockInfoHash.TryGetValue(CodeInfoKey(CodeType, Code), AStockInfoIndex) then
    begin
      result := Int64(@FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex]);
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_CodeToKeyIndex(CodeType: Word; const Code: WideString): Integer;
begin
  BeginRead;
  try
    // ȡȫ��Ψһ��Keyindex
    result := CodeTypeToKeyIndex(CodeType, Code);
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_Finances(CodeType: Word; const Code: WideString): Int64; safecall;
var
  AStockInfoIndex: TStockInfoIndex;
begin
  BeginRead;
  try
    result := 0;
    if FStockInfoHash.TryGetValue(CodeInfoKey(CodeType, Code), AStockInfoIndex) then
    begin
      result := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex;
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_PrevClose(CodeType: Word; const Code: WideString): Integer;
var
  AStockInfoIndex: TStockInfoIndex;
begin
  BeginRead;
  try
    result := 0;
    if FStockInfoHash.TryGetValue(CodeInfoKey(CodeType, Code), AStockInfoIndex) then
    begin
      result := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock.m_lPrevClose;
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.GetStockTypeInfo(CodeType: Word): Int64;
begin
  try

    result := Int64(@FQuoteDataMngr.GetStockTypeInfo(CodeType).StockType);
  finally
  end;
end;

function TQuoteRealTime.GetInitDate(CodeType: Word): Int64;
begin
  try
    result := FQuoteDataMngr.GetBourseInfo(CodeType).m_lDate;
  finally
  end;
end;

function TQuoteRealTime.GetCodeInfoByKeyStr(const Key: WideString; out CodeInfo: Int64): WordBool;
var
  StockInfoIndex: TStockInfoIndex;
begin
  result := FStockInfoHash.TryGetValue(Key, StockInfoIndex);
  if result then
  begin
    CodeInfo := Int64(@FStockInfoArrays[StockInfoIndex.ArrayIndex][StockInfoIndex.InfoIndex].Stock.m_ciStockCode);
  end;
end;

function TQuoteRealTime.GetCodeInfoByName(AName: string; out CodeInfo: Int64): WordBool;
var
  StockInfoIndex: TStockInfoIndex;
begin
  result := FNameToStockInfoHash.TryGetValue(AName, StockInfoIndex);
  if result then
  begin
    CodeInfo := Int64(@FStockInfoArrays[StockInfoIndex.ArrayIndex][StockInfoIndex.InfoIndex].Stock.m_ciStockCode);
  end;
end;

procedure TQuoteRealTime.SetUpdateConceptCodesEvent(AFunc: TNotifyEvent);
begin
  FUpdateConceptCodesEvent := AFunc;
end;

function TQuoteRealTime.GetLimitPrice(CodeType: Word; const Code: WideString): Int64;
var
  P: PLimitPrice;
begin

  result := 0;
  if FLimitPriceHash.TryGetValue(CodeInfoKey(CodeType, Code), P) then
    result := Int64(P);
end;

procedure TQuoteRealTime.ResetRealTime;
var
  i: Integer;
begin

  if FRealDatasInt64 <> nil then
  begin
    for i := 0 to FRealDatasInt64.count - 1 do
      FreeMemEx(FRealDatasInt64[i]);
    FRealDatasInt64.Clear;
  end;

  if FRealDatas <> nil then
  begin
    for i := 0 to FRealDatas.count - 1 do
      FreeMemEx(FRealDatas[i]);
    FRealDatas.Clear;
  end;

  if FRealDataHashInt64 <> nil then
    FRealDataHashInt64.Clear;
  if FRealDataHash <> nil then
    FRealDataHash.Clear;
  if FLevelData <> nil then
    FLevelData.Clear;

  if FLimitPriceHash <> nil then
    FLimitPriceHash.Clear;

end;

procedure TQuoteRealTime.DoLimitPriceHashDel(AObject: TObject; const Item: PLimitPrice; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
    Dispose(Item);
end;

procedure TQuoteRealTime.DoL2LevelData(AObject: TObject; const Item: PQuoteL2RealTimeData;
  Action: TCollectionNotification);
begin
  if Action = cnRemoved then
    Dispose(Item);
end;

function TQuoteRealTime.IsIndexToPlateCode(AMarket: USHORT; ASecuCode: string): Boolean;
const
  Const_IndexToPlate_Code: array [0 .. 5] of string = ('000300', '000903', '000852', '003701', '000906', '000905');
var
  i, ACount: Integer;
begin
  Result := False;
  if(ASecuCode <> '')then
  begin
    if(AMarket = IndexPlate_MARKET)then
    begin
      ACount := Length(Const_IndexToPlate_Code);
      for i := 0 to ACount-1 do
      begin
        if(ASecuCode = Const_IndexToPlate_Code[i])then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;
// function TQuoteRealTime.CodeTypeToStocks(CodeType: Word; var Len: integer): PStockInfos;
// begin
// result := nil; Len := 0;
// if HSMarketBourseType(CodeType, STOCK_MARKET, SH_BOURSE)  then begin    // �Ϻ�
// Len := Length(FSHStocks);
// if Len > 0 then Result := @FSHStocks[0];
// end else if HSMarketBourseType(CodeType, STOCK_MARKET, SZ_BOURSE) then begin  // ����
// Len := Length(FSZStocks);
// if Len > 0 then Result := @FSZStocks[0];
//
// end else if HSMarketType(CodeType, Other_MARKET) then begin  //    FOther_Hash
// Len := Length(FOther_Stocks);
// if Len > 0 then Result := @FOther_Stocks[0];
//
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, DALIAN_BOURSE) then begin  //����
// Len := Length(FFutues_DLStocks);
// if Len > 0 then Result := @FFutues_DLStocks[0];
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, SHANGHAI_BOURSE) then begin  //�Ϻ� ��Ʒ
// Len := Length(FFutues_SHStocks);
// if Len > 0 then Result := @FFutues_SHStocks[0];
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then begin  //֣�� ��Ʒ
// Len := Length(FFutues_ZZStocks);
// if Len > 0 then Result := @FFutues_ZZStocks[0];
// end else if HSMarketBourseType(CodeType, FUTURES_MARKET, GUZHI_BOURSE) then begin //��ָ�ڻ�
// Len := Length(FFutues_StockStocks);
// if Len > 0 then Result := @FFutues_StockStocks[0];
// //�۹�����
// end else if HSMarketBourseType(CodeType, HK_MARKET, HK_BOURSE) then begin
// Len := Length(FHK_StockStocks);
// if Len > 0 then Result := @FHK_StockStocks[0];
// //�۹�ָ��
// end else if HSMarketBourseType(CodeType, HK_MARKET, GE_BOURSE) then begin
// Len := Length(FHK_GEStocks);
// if Len > 0 then Result := @FHK_GEStocks[0];
//
// end else if HSMarketBourseType(CodeType, HK_MARKET, INDEX_BOURSE) then begin
// Len := Length(FHK_IndexStocks);
// if Len > 0 then Result := @FHK_IndexStocks[0];
//
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, YHJZQ_BOURSE) then begin
// Len := Length(FForeign_YHJZQStocks);        //���м�ծȯ
// if Len > 0 then Result := @FForeign_YHJZQStocks[0];
//
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, XHCJ_BOURSE) then begin
// Len := Length(FForeign_XHCJStocks);        //���ò��
// if Len > 0 then Result := @FForeign_XHCJStocks[0];
//
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, ZYSHG_BOURSE) then begin
// Len := Length(FForeign_ZYSHGStocks);        //��Ѻʽ�ع�
// if Len > 0 then Result := @FForeign_ZYSHGStocks[0];
//
// end else if HSMarketBourseType(CodeType, Foreign_MARKET, MDSHG_BOURSE) then begin
// Len := Length(FForeign_MDSHGStocks);        //���ʽ�ع�
// if Len > 0 then Result := @FForeign_MDSHGStocks[0];
//
// end;
// end;

function TQuoteRealTime.Get_ExRights(CodeType: Word; const Code: WideString): Int64; safecall;
var
  AStockInfoIndex: TStockInfoIndex;
begin
  BeginRead;
  try
    result := 0;
    if FStockInfoHash.TryGetValue(CodeInfoKey(CodeType, Code), AStockInfoIndex) then
    begin
      result := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].ExRightIndex;
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_Datas(CodeType: Word; const Code: WideString): Int64; safecall;
var
  KeyIndex, Index: Integer;
begin
  BeginRead;
  try
    result := 0;
    // ȡȫ��Ψһ��KeyIndex
    KeyIndex := CodeTypeToKeyIndex(CodeType, Code);
    if (KeyIndex >= 0) then
    begin
      // �鿴�Ƿ������������
      Index := FRealDataHash.ValueOf(KeyIndex);
      if Index >= 0 then
        result := Int64(FRealDatas[Index]);
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_DatasInt64(CodeType: Word; const Code: WideString): Int64;
var
  KeyIndex, Index: Integer;
begin
  BeginRead;
  try
    result := 0;
    // ȡȫ��Ψһ��KeyIndex
    KeyIndex := CodeTypeToKeyIndex(CodeType, Code);
    if (KeyIndex >= 0) then
    begin
      // �鿴�Ƿ������������
      Index := FRealDataHashInt64.ValueOf(KeyIndex);
      if Index >= 0 then
        result := Int64(FRealDatasInt64[Index]);
    end;
  finally
    EndRead;
  end;
end;

function TQuoteRealTime.Get_LevelDatas(CodeType: Smallint; const Code: WideString): Int64; safecall;
var
  Key: string;
  P: PQuoteL2RealTimeData;
begin
  Key := CodeInfoKey(CodeType, Code);
  if FLevelData.TryGetValue(Key, P) then
    result := Int64(P)
  else
    result := 0;
end;

procedure TQuoteRealTime.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    // ���� ��������
    case DataType of
      Update_RealTime_Codes_SetData:
        UpdateCodes(Pointer(Data), size);
      Update_RealTime_ExRight_SetData:
        UpdateExRight(Pointer(Data), size);
      Update_RealTime_Finance_SetData:
        UpdateCurrentFinance(Pointer(Data), size);
      Update_RealTime_RealTimeData:
        UpdateRealTimeData(Pointer(Data), size);
      Update_RealTime_RealTimeDataExt:
        UpdateRealTimeDataExt(Pointer(Data), size);
      Update_RealTime_RealTimeInt64DataExt:
        UpdateRealTimeInt64DataExt(Pointer(Data), size);
      Update_RealTime_Level_RealTimeData:
        UpdateLevelRealTimeData(Pointer(Data), size);
      Update_RealTime_Server_Calc:
        UpdateServerCalcData(Pointer(Data), size);
    end;
  finally
    EndWrite;
  end;
end;

procedure TQuoteRealTime.UpdateCodes(Data: Pointer; MarketType: Integer);
var
  i, Index: Integer;
  StockInitData: PStockInitData;
  ArrayIndex: Integer;
  AStockInfoIndex, AOtherIndex: TStockInfoIndex;
  AKey, AName: string;
  count: Integer;
  tmpCodeType: HSMarketDataType;
  // F: TextFile;
  // AFile:string;
begin
  ResetRealTime;
  StockInitData := PStockInitData(Data);

  if HSMarketBourseType(MarketType, STOCK_MARKET, SH_BOURSE) then
  begin
    ArrayIndex := SH_STOCK_INDEX; // �Ϻ�������
    // FQuoteDataMngr
  end
  else if HSMarketBourseType(MarketType, STOCK_MARKET, SZ_BOURSE) then
  begin
    ArrayIndex := SZ_STOCK_INDEX; // ��֤������
  end
  else if HSMarketBourseType(MarketType, STOCK_MARKET, GZ_BOURSE) then
  begin
    ArrayIndex := GZ_STOCK_INDEX // ������
  end
  else if HSMarketType(MarketType, OPT_MARKET) then
  begin // ������Ȩ
    ArrayIndex := OPT_INDEX
  end
  else if HSMarketType(MarketType, OTHER_MARKET) then
  begin
    ArrayIndex := A_OTHER_STOCK_INDEX; // ����ָ�� ��֤������ָ��
  end
  else if HSMarketBourseType(MarketType, FUTURES_MARKET, DALIAN_BOURSE) then
  begin
    ArrayIndex := FUTURES_DL_STOCK_INDEX; // ������Ʒ������

  end
  else if HSMarketBourseType(MarketType, FUTURES_MARKET, SHANGHAI_BOURSE) then
  begin
    ArrayIndex := FUTURES_SH_STOCK_INDEX; // �Ϻ��ڻ�������

  end
  else if HSMarketBourseType(MarketType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then
  begin
    ArrayIndex := FUTURES_ZZ_STOCK_INDEX; // ֣����Ʒ������
  end
  else if HSMarketBourseType(MarketType, FUTURES_MARKET, GUZHI_BOURSE) then
  begin

    ArrayIndex := FUTURES_STOCK_STOCK_INDEX; // �����ڻ�������
    // �۹�����
  end
  else if HSMarketBourseType(MarketType, HK_MARKET, HK_BOURSE) then
  begin
    ArrayIndex := HK_STOCK_STOCK_INDEX; // �������

  end
  else if HSMarketBourseType(MarketType, HK_MARKET, GE_BOURSE) then
  begin
    ArrayIndex := HK_GE_STOCK_INDEX; // ��۴�ҵ��

  end
  else if HSMarketBourseType(MarketType, HK_MARKET, INDEX_BOURSE) then
  begin
    ArrayIndex := HK_INDEX_STOCK_INDEX; // ���ָ��
  end
  else if HSMarketBourseType(MarketType, Foreign_MARKET, YHJZQ_BOURSE) then
  begin
    ArrayIndex := FOREIGN_INNER_BANK_BOND_INDEX; // ���м�ծȯ
  end
  else if HSMarketBourseType(MarketType, Foreign_MARKET, XHCJ_BOURSE) then
  begin
    ArrayIndex := FOREIGN_INNER_BANK_CLB_INDEX; // ���ò��
  end
  else if HSMarketBourseType(MarketType, Foreign_MARKET, ZYSHG_BOURSE) then
  begin
    ArrayIndex := FOREIGN_INNER_BANK_PSR_INDEX; // ��Ѻʽ�ع�
  end
  else if HSMarketBourseType(MarketType, Foreign_MARKET, MDSHG_BOURSE) then
  begin
    ArrayIndex := FOREIGN_INNER_BANK_OR_INDEX; // ���ʽ�ع�
  end
  else if HSMarketBourseType(MarketType, OTHER_MARKET, ZZ_BOURSE) then
  begin
    ArrayIndex := SWI_INDEX; // ����ָ��
  end
  else if HSMarketBourseType(MarketType, OTHER_MARKET, GN_BOURSE) then
  begin
    ArrayIndex := GNBI_INDEX; // ������ָ��
  end
  else if HSMarketBourseType(MarketType, OTHER_MARKET, ZX_BORRSE) then
  begin
    ArrayIndex := ZXI_INDEX; // ����ָ��
  end
  else
    ArrayIndex := OTHER_SECU_INDEX; // ����֤ȯ
  count := Length(FStockInfoArrays[ArrayIndex]);
  if count < StockInitData^.m_nSize then
    SetLength(FStockInfoArrays[ArrayIndex], StockInitData^.m_nSize);

  // AFile := format('d:\%x_CodeInfo.text',[MarketType]);
  // AssignFile(F,AFile);
  // try
  // if FileExists(AFile) then append(F)
  // else Rewrite(F);
  //
  // for i := 0 to StockInitData^.m_nSize - 1 do
  // begin
  // writeln(F,Format('%s | %s',[CodeInfoKey(@StockInitData^.m_pstInfo[i].m_ciStockCode),AnsiCharArrayToStr(StockInitData^.m_pstInfo[i].m_cStockName)]));
  // end;
  // finally
  // CloseFile(F);
  // end;
  index := 0;

  for i := 0 to StockInitData^.m_nSize - 1 do
  begin
    // ����Hash��
    // StockHash.Add(CodeInfoKey(@Stocks^[i].Stock.m_ciStockCode), i);
    //�޳����ָ������300���Լ���֤��ϵ��ָ��
    if(IsIndexToPlateCode(StockInitData^.m_pstInfo[i].m_ciStockCode.m_cCodeType,
      AnsiCharArrayToStr(StockInitData^.m_pstInfo[i].m_ciStockCode.m_cCode)))then
    begin
      OutputDebugString(PChar('ָ�����' + ': StockCode=' + AnsiCharArrayToStr(StockInitData^.m_pstInfo[i].m_ciStockCode.m_cCode)));
      Continue;
    end;

    AKey := CodeInfoKey(@StockInitData^.m_pstInfo[i].m_ciStockCode);
    if FStockInfoHash.TryGetValue(AKey, AStockInfoIndex) then
    begin
      tmpCodeType := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock.m_ciStockCode.m_cCodeType;
    end
    else
    begin
      tmpCodeType := 0;
      AStockInfoIndex := TStockInfoIndex.Create;
      AOtherIndex := TStockInfoIndex.Create;
      FStockInfoHash.Add(AKey, AStockInfoIndex);
      if(ArrayIndex = A_OTHER_STOCK_INDEX)and(StockInitData^.m_pstInfo[i].m_ciStockCode.m_cCodeType=ConceptIndex_BORRSE)then
      begin
        AName := AnsiCharArrayToStr(StockInitData^.m_pstInfo[i].m_cStockName);
        if(not FNameToStockInfoHash.ContainsKey(AName))then
          FNameToStockInfoHash.Add(AName, AOtherIndex)
        else
        begin
          FNameToStockInfoHash.AddOrSetValue(AName, AOtherIndex);
        end;
      end;
      AStockInfoIndex.ArrayIndex := ArrayIndex;
      if Length(FStockInfoArrays[ArrayIndex]) < count + index + 1 then
        SetLength(FStockInfoArrays[ArrayIndex], count + index + 20);
      AStockInfoIndex.InfoIndex := count + index;
      AOtherIndex.ArrayIndex := AStockInfoIndex.ArrayIndex;
      AOtherIndex.InfoIndex := AStockInfoIndex.InfoIndex;
      Inc(index);
    end;

    // �����������壬���ҵ�ǰ�Ѵ��ڵ�֤ȯ�г���$2103�򲻸������ݣ�$2103=8451��ʾ��������г�
    if (AStockInfoIndex.ArrayIndex <> HK_STOCK_STOCK_INDEX) or (tmpCodeType <> 8451) then
    begin
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock := StockInitData^.m_pstInfo[i];
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex := -1;
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].ExRightIndex := -1;
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].RightCount := 0;
    end;
    // ��ʾ����
    // Progress('��ʼ�������', StockInitData^.m_nSize, i);
  end;

  if(ArrayIndex = A_OTHER_STOCK_INDEX)and(Assigned(FUpdateConceptCodesEvent))then
      FUpdateConceptCodesEvent(Self);
    // ��ʾ����
  // Progress('��ʼ�������', StockInitData^.m_nSize, StockInitData^.m_nSize);
end;

procedure TQuoteRealTime.UpdateServerCalcData(Data: Pointer; size: Integer);
var
  AStockInfoIndex: TStockInfoIndex;
  i: Integer;
  P: pAnsSeverCalculate;
  pData: PSeverCalculateData;
  pl: PLimitPrice;
begin
  P := pAnsSeverCalculate(Data);
  pData := @P.SeverCalculateData[0];
  for i := 0 to P.m_nSize - 1 do
  begin
    if not FLimitPriceHash.TryGetValue(CodeInfoKey(@pData.m_ciStockCode), pl) then
    begin
      new(pl);
      FLimitPriceHash.Add(CodeInfoKey(@pData.m_ciStockCode), pl);
    end;
    pl.MaxUpPrice := pData.m_fUpPrice;
    pl.MinDownPrice := pData.m_fDownPrice;
    Inc(pData);
  end;
end;

procedure TQuoteRealTime.UpdateCurrentFinance(Data: Pointer; size: Integer);
var
  i, count: Integer;
  AStockInfoIndex: TStockInfoIndex;
  CodeInfo: TCodeInfo;
begin
  count := (size - 8) div SizeOf(TFinanceInfo);
  SetLength(FFinances, count);

  Inc(IntPtr(Data), 8);
  Move(Data^, FFinances[0], SizeOf(TFinanceInfo) * count);
  WriteDebug('RT_CURRENTFINANCEDATA' + '/' + inttostr(count));
  for i := low(FFinances) to high(FFinances) do
  begin
    CodeInfo.m_cCodeType := ATypeToCodeType(string(FFinances[i].m_cAType));
    Move(FFinances[i].m_cCode, CodeInfo.m_cCode, SizeOf(FFinances[i].m_cCode));

    if FStockInfoHash.TryGetValue(CodeInfoKey(@CodeInfo), AStockInfoIndex) then
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex := i;
    Progress('��������', count, i);
  end;
  Progress('��������', count, count);
end;

procedure TQuoteRealTime.UpdateExRight(Data: Pointer; size: Integer);
var
  P, count, Index, rcount: Integer;
  ExRight: PExRight;
  ExRightItem: PExRightItem;
  AStockInfoIndex: TStockInfoIndex;
  CodeInfo: TCodeInfo;
begin
  WriteDebug(Format('RT_EXRIGHT_DATA %d', [size]));

  // Ԥ���Ĵ�С
  count := (size - 8 - 4) div SizeOf(TExRightItem);
  SetLength(FExRights, count);
  P := 8 + 4;
  index := 0;
  Inc(IntPtr(Data), P);
  while (PInteger(Data)^ <> -1) and (P < size) do
  begin
    rcount := 0;

    ExRight := PExRight(Data);

    Inc(IntPtr(Data), SizeOf(TExRight));
    Inc(P, SizeOf(TExRight));

    while (PInteger(Data)^ <> -1) and (P < size) do
    begin
      ExRightItem := PExRightItem(Data);
      FExRights[index] := ExRightItem^;

      FExRights[index].m_nTime := DateToInt(FRightBaseDate + ExRightItem^.m_nTime / 86400);
      // ��ʾ����
      Progress('��Ȩ����', count, index);

      Inc(rcount);
      Inc(index);
      Inc(P, SizeOf(TExRightItem));
      Inc(IntPtr(Data), SizeOf(TExRightItem));
    end;

    if PInteger(Data)^ = -1 then
    begin
      Inc(P, SizeOf(Integer));
      Inc(IntPtr(Data), SizeOf(Integer));
    end;
    // ����ת�� SH -> CodeType
    CodeInfo.m_cCodeType := CTypeToCodeType(string(ExRight^.m_cAType));
    Move(ExRight^.m_cACode, CodeInfo.m_cCode, SizeOf(ExRight^.m_cACode));

    if FStockInfoHash.TryGetValue(CodeInfoKey(@CodeInfo), AStockInfoIndex) then
    begin
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].ExRightIndex :=
        AStockInfoIndex.InfoIndex - rcount;
      FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].RightCount := rcount;
    end;
  end;
  // ��ʾ����
  Progress('��Ȩ����', count, count);
end;

procedure TQuoteRealTime.UpdateLevelRealTimeData(Data: Pointer; size: Integer);
var
  Key: string;
  InData: PRealTimeDataLevel;
  CurrData: PQuoteL2RealTimeData;
  AStockInfoIndex: TStockInfoIndex;
begin
  CurrData := nil;
  InData := PRealTimeDataLevel(Data);
  Key := CodeInfoKey(@InData.m_ciStockCode);
  if not FLevelData.TryGetValue(Key, CurrData) then
  begin
    new(CurrData);
    ZeroMemory(CurrData, SizeOf(TQuoteL2RealTimeData));
    FLevelData.Add(Key, CurrData);
  end;
  if CurrData.m_LevelothData.m_nTime.m_nTimeOld <> InData^.m_othData.m_nTime.m_nTimeOld then
  begin
    CurrData.m_LevelothData := InData^.m_othData;
    CurrData.m_LevelcNowData := InData^.m_sLevelRealTime;
    Inc(CurrData.VarCode);
  end;

  { CurrData := nil;
    InData := PRealTimeDataLevel(Data);
    //ȡȫ��Ψһ��Keyindex
    KeyIndex := CodeTypeToKeyIndex(InData^.m_ciStockCode.m_cCodeType, CodeInfoToCode(@InData^.m_ciStockCode));
    if KeyIndex >= 0 then begin
    //�鿴�Ƿ������������
    Index := FRealDataHash.ValueOf(KeyIndex);
    if Index >= 0 then begin
    CurrData := PQuoteRealTimeData(FRealDatas[Index]);
    end else begin
    if FStockInfoHash.TryGetValue(CodeInfoKey(@InData^.m_ciStockCode),AStockInfoIndex) then begin
    GetMemEx(Pointer(CurrData), SizeOf(TQuoteRealTimeData));
    FillMemory(CurrData, SizeOf(TQuoteRealTimeData), 0);

    Index := FRealDatas.Add(CurrData);
    FRealDataHash.Add(KeyIndex, Index);
    CurrData^.StockInitInfo := @FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock;
    FinIndex := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex;
    if  (FinIndex >= Low(FFinances)) and (FinIndex <= High(FFinances))  then
    CurrData^.FinanceInfo := @FFinances[FinIndex];
    end;
    end;
    if (CurrData <> nil) and (CurrData^.m_othData.m_Time.m_nTimeOld <> InData^.m_othData.m_nTime.m_nTimeOld) then begin
    CurrData^.m_LevelothData := InData^.m_othData;
    CurrData^.m_LevelcNowData:= InData^.m_sLevelRealTime;
    inc(CurrData^.VarCode);
    end;
    end; }
end;

procedure TQuoteRealTime.UpdateRealTimeData(Data: Pointer; size: Integer);
var
  KeyIndex, Index, FinIndex: Integer;
  InData: PCommRealTimeData;
  CurrData: PQuoteRealTimeData;
  AStockInfoIndex: TStockInfoIndex;
begin
  CurrData := nil;
  InData := PCommRealTimeData(Data);

  // ȡȫ��Ψһ��Keyindex
  KeyIndex := CodeTypeToKeyIndex(InData^.m_ciStockCode.m_cCodeType, CodeInfoToCode(@InData^.m_ciStockCode));
  if KeyIndex >= 0 then
  begin
    // �鿴�Ƿ������������
    Index := FRealDataHash.ValueOf(KeyIndex);
    if Index >= 0 then
    begin
      CurrData := PQuoteRealTimeData(FRealDatas[Index]);
    end
    else
    begin
      // ֻȡ�������͵� Stocks
      if FStockInfoHash.TryGetValue(CodeInfoKey(@InData^.m_ciStockCode), AStockInfoIndex) then
      begin
        GetMemEx(Pointer(CurrData), SizeOf(TQuoteRealTimeData));
        FillMemory(CurrData, SizeOf(TQuoteRealTimeData), 0);

        Index := FRealDatas.Add(CurrData);
        FRealDataHash.Add(KeyIndex, Index);
        CurrData^.StockInitInfo := @FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock;
        FinIndex := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex;
        if (FinIndex >= Low(FFinances)) and ((FinIndex <= High(FFinances))) then
          CurrData^.FinanceInfo := @FFinances[FinIndex];
      end;
    end;

    // ʱ�䲻�� ���ݲ��ø���
    if (CurrData <> nil) and not CompareMem(@CurrData^.m_cNowData, @InData^.m_cNowData, SizeOf(TShareRealTimeData)) then
    begin
      // (CurrData^.m_othData.m_Time.m_nTimeOld <> InData^.m_othData.m_Time.m_nTimeOld)  then begin

      if HSMarketType(InData^.m_ciStockCode.m_cCodeType, FUTURES_MARKET) and (CurrData^.StockInitInfo.m_lPrevClose = 0)
      then
        CurrData^.StockInitInfo.m_lPrevClose := InData^.m_cNowData.m_qhData.m_lPreJieSuanPrice;

      CurrData^.m_othData := InData^.m_othData;
      CurrData^.m_cNowData := InData^.m_cNowData;
      Inc(CurrData^.VarCode);
    end;
  end;
end;

procedure TQuoteRealTime.UpdateRealTimeDataExt(Data: Pointer; size: Integer);
var
  KeyIndex, Index, FinIndex: Integer;
  InData: PCommRealTimeData_Ext;
  CurrData: PQuoteRealTimeData;
  AStockInfoIndex: TStockInfoIndex;
  CodeType: ushort;
begin
  CurrData := nil;
  InData := PCommRealTimeData_Ext(Data);
  // ȡȫ��Ψһ��Keyindex
  CodeType := InData^.m_ciStockCode.m_cCodeType;
  KeyIndex := CodeTypeToKeyIndex(CodeType, CodeInfoToCode(@InData^.m_ciStockCode));
  if KeyIndex >= 0 then
  begin
    // �鿴�Ƿ������������
    Index := FRealDataHash.ValueOf(KeyIndex);
    if Index >= 0 then
    begin
      CurrData := PQuoteRealTimeData(FRealDatas[Index]);
    end
    else
    begin
      // ֻȡ�������͵� Stocks
      if FStockInfoHash.TryGetValue(CodeInfoKey(@InData^.m_ciStockCode), AStockInfoIndex) then
      begin
        GetMemEx(Pointer(CurrData), SizeOf(TQuoteRealTimeData));
        FillMemory(CurrData, SizeOf(TQuoteRealTimeData), 0);

        Index := FRealDatas.Add(CurrData);
        FRealDataHash.Add(KeyIndex, Index);
        CurrData^.StockInitInfo := @FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock;
        FinIndex := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex;
        if (FinIndex >= Low(FFinances)) and ((FinIndex <= High(FFinances))) then
          CurrData^.FinanceInfo := @FFinances[FinIndex];
      end;
    end;

    // ʱ�䲻�� ���ݲ��ø���
    if (CurrData <> nil) and not CompareMem(@CurrData^.m_cNowData, @InData^.m_cNowData, SizeOf(TShareRealTimeData_Ext))
    then
    begin
      // (CurrData^.m_othData.m_Time.m_nTimeOld <> InData^.m_othData.m_Time.m_nTimeOld)  then begin
      if HSMarketType(InData^.m_ciStockCode.m_cCodeType, FUTURES_MARKET) and (CurrData^.StockInitInfo.m_lPrevClose = 0)
      then
        CurrData^.StockInitInfo.m_lPrevClose := InData^.m_cNowData.m_qhData.m_lPreJieSuanPrice;

      CurrData^.m_othData := InData^.m_othData;
      if HSMarketType(CodeType, OTHER_MARKET) then // ָ��
      begin
        CurrData.CommExtData.m_IndexExt := InData.m_cNowData.m_indData.m_indexRealTimeOther;
        // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice := InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
        CurrData.m_cNowData.m_indData := InData.m_cNowData.m_indData.m_indexRealTime;
        // CurrData.m_cNowData.m_indData.m_fAvgPrice := CurrData.m_cNowData.m_indData.m_fAvgPrice * 100;
      end
      else if HSMarketType(CodeType, HK_MARKET) then // ���
      begin
        CurrData.CommExtData.m_HKStockExt := InData.m_cNowData.m_hkData.m_extBuySell;
        CurrData.m_cNowData.m_hkData := InData.m_cNowData.m_hkData.m_baseReal;
      end
      else if HSMarketType(CodeType, US_MARKET) then // ����
      begin
        CurrData.CommExtData.m_StockExt := InData.m_cNowData.m_stStockDataExt.m_stockOther;
        CurrData.m_cNowData.m_USData := InData.m_cNowData.m_USData;
      end
      else if HSMarketType(CodeType, OPT_MARKET) then // ������Ȩ
        CurrData.m_cOPTNowData := InData.m_cNowData.m_OPTData
      else if HSMarketType(CodeType, FUTURES_MARKET) then // �ڻ�
        CurrData.m_cNowData.m_qhData := InData.m_cNowData.m_qhData
      else if HSMarketType(CodeType, Foreign_MARKET) then
      begin
        if HSBourseType(CodeType, YHJZQ_BOURSE) or // ���м�
          HSBourseType(CodeType, XHCJ_BOURSE) or HSBourseType(CodeType, ZYSHG_BOURSE) or
          HSBourseType(CodeType, MDSHG_BOURSE) then

          CurrData.m_cNowData.m_HSIB := InData.m_cNowData.m_IBData
        else // ���
          CurrData.m_cNowData.m_whData := InData.m_cNowData.m_whData
      end
      else
      begin
        if HSKindType(CodeType, KIND_INDEX) then
        begin
          CurrData.CommExtData.m_StockExt := InData.m_cNowData.m_stStockDataExt.m_stockOther;
          // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
          // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
          CurrData.m_cNowData.m_indData := InData.m_cNowData.m_indData.m_indexRealTime;
        end
        else // A B ��
        begin
          CurrData.CommExtData.m_StockExt := InData.m_cNowData.m_stStockDataExt.m_stockOther;
          CurrData.m_cNowData.m_stStockData := InData.m_cNowData.m_stStockDataExt.m_stockRealTime;
        end;
      end;
      // CurrData^.m_cNowData := InData^.m_cNowData;
      Inc(CurrData^.VarCode);
    end;
  end;
end;

procedure TQuoteRealTime.UpdateRealTimeInt64DataExt(Data: Pointer; size: Integer);
var
  KeyIndex, Index, FinIndex: Integer;
  InData: PCommRealTimeInt64Data_Ext;
  CurrData: PQuoteRealTimeDataInt64;
  AStockInfoIndex: TStockInfoIndex;
  CodeType: ushort;
begin
  CurrData := nil;
  InData := PCommRealTimeInt64Data_Ext(Data);
  // ȡȫ��Ψһ��Keyindex
  CodeType := InData^.m_ciStockCode.m_cCodeType;
  KeyIndex := CodeTypeToKeyIndex(CodeType, CodeInfoToCode(@InData^.m_ciStockCode));
  if KeyIndex >= 0 then
  begin
    // �鿴�Ƿ������������
    Index := FRealDataHashInt64.ValueOf(KeyIndex);
    if Index >= 0 then
    begin
      CurrData := PQuoteRealTimeDataInt64(FRealDatasInt64[Index]);
    end
    else
    begin
      // ֻȡ�������͵� Stocks
      if FStockInfoHash.TryGetValue(CodeInfoKey(@InData^.m_ciStockCode), AStockInfoIndex) then
      begin
        GetMemEx(Pointer(CurrData), SizeOf(TQuoteRealTimeDataInt64));
        FillMemory(CurrData, SizeOf(TQuoteRealTimeDataInt64), 0);

        Index := FRealDatasInt64.Add(CurrData);
        FRealDataHashInt64.Add(KeyIndex, Index);
        CurrData^.StockInitInfo := @FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].Stock;
        FinIndex := FStockInfoArrays[AStockInfoIndex.ArrayIndex][AStockInfoIndex.InfoIndex].FinanceIndex;
        if (FinIndex >= Low(FFinances)) and ((FinIndex <= High(FFinances))) then
          CurrData^.FinanceInfo := @FFinances[FinIndex];
      end;
    end;

    // ʱ�䲻�� ���ݲ��ø���
    if (CurrData <> nil) and not CompareMem(@CurrData^.m_cNowData, @InData^.m_cNowData, SizeOf(TShareRealTimeInt64Data_Ext))
    then
    begin
      CurrData^.m_othData := InData^.m_othData;
      if HSMarketType(CodeType, OTHER_MARKET) then // ָ��
      begin
        CurrData.CommExtData.m_IndexExt := InData.m_cNowData.m_indData.m_indexRealTimeOther;
        // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice := InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
        CurrData.m_cNowData.m_indData := InData.m_cNowData.m_indData;
        // CurrData.m_cNowData.m_indData.m_fAvgPrice := CurrData.m_cNowData.m_indData.m_fAvgPrice * 100;
      end
      else
      begin
        if HSKindType(CodeType, KIND_INDEX) then
        begin
          CurrData.CommExtData.m_StockExt := InData.m_cNowData.m_stStockDataExt.m_stockOther;
          // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
          // InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
          CurrData.m_cNowData.m_indData := InData.m_cNowData.m_indData;
        end
        else // A B ��
        begin
          CurrData.CommExtData.m_StockExt := InData.m_cNowData.m_stStockDataExt.m_stockOther;
          CurrData.m_cNowData.m_nowDataExt := InData.m_cNowData.m_stStockDataExt;
        end;
      end;
      // CurrData^.m_cNowData := InData^.m_cNowData;
      Inc(CurrData^.VarCode);
    end;
  end;
end;

{ TQuoteTrend }

constructor TQuoteTrend.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteTrend);
  FCodeInfo := CodeInfo^;
  FStockTypeInfo := QuoteDataMngr.GetStockTypeInfo(CodeInfo.m_cCodeType);
  SetLength(FData, FStockTypeInfo.Times.Tag);
  FCount := 0;
  if IsVAData then
    SetLength(FVadata, 11);
  FVACount := 0;
  // FProvClose := 0;
  // ����ָ����Ҫ�õ�ǰ���̼�
  { if IsStockMajorIndex(@FCodeInfo) then }
  GetPrevCose;
end;

destructor TQuoteTrend.Destroy;
begin
  FData := nil;
  inherited;
end;

function TQuoteTrend.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteTrend.Get_Count: Integer;
begin
  result := FCount;
end;

function TQuoteTrend.Get_Datas: Int64;
begin
  if FCount > 0 then
    result := Int64(@FData[0])
  else
    result := 0;

end;

function TQuoteTrend.Get_IndexToTime(Index: Integer): Integer;
begin
  result := FStockTypeInfo.Times.ValueOf(index);
end;

function TQuoteTrend.Get_TimeCount: Integer;
begin
  result := Length(FData);
end;

function TQuoteTrend.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteTrend.UpdateTrendData(Data: Pointer; size: Integer);
var
  TrendData: PAnsTrendData;
  i: Integer;
  AvgPrice: Single;
  LastVol: ULong;
  // realTime:PQuoteRealTimeData;
begin
  if size > Length(FData) then
  begin
    FQuoteDataMngr.WriteDebug(Format('[ERROR] CodeType:%d Code:%s ��ʱ��������(%d)�����ڳ�ʼ������(%d).',
      [FCodeInfo.m_cCodeType, CodeInfoToCode(@FCodeInfo), size, FCount]));
    SetLength(FData, size);
  end;
  TrendData := PAnsTrendData(Data);
  FTrendInfo.PrevClose := TrendData.m_othData.m_Data.m_lPreClose;
  // ��ֵ
  // move(Data^, FData[0], Size * Sizeof(TPriceVolItem));
  if size > 0 then
  begin
    LastVol := 0;
    FCount := size;
    AvgPrice := TrendData.m_pHisData[0].m_lNewPrice;
    for i := 0 to FCount - 1 do
    begin
      FData[i].CommonTrendData.Price := TrendData.m_pHisData[i].m_lNewPrice;
      TrendData.m_pHisData[i].m_lTotal := max(TrendData.m_pHisData[i].m_lTotal, LastVol);

      FData[i].CommonTrendData.Vol := TrendData.m_pHisData[i].m_lTotal - LastVol;
      // FData[i].CommonTrendData.AvgPrice :=
      // trunc((AvgPrice * i + FData[i].CommonTrendData.Price) / (i + 1));

      if (TrendData.m_pHisData[i].m_lTotal <> 0) and (FData[i].CommonTrendData.Price <> 0) then
      begin
        FData[i].CommonTrendData.AvgPrice :=
          trunc((1.0 * LastVol * AvgPrice + 1.0 * FData[i].CommonTrendData.Price * FData[i].CommonTrendData.Vol) /
          TrendData.m_pHisData[i].m_lTotal);
        // FData[i].CommonTrendData.Money := TrendData.m_cNowData.m_nowData.m_fAvgPrice;
        // FData[i].CommonTrendData.AvgPrice := Trunc(FData[i].CommonTrendData.Money / TrendData.m_pHisData[i].m_lTotal);
      end
      else
        FData[i].CommonTrendData.AvgPrice := AvgPrice;

      FData[i].CommonTrendData.Money := 1.0 * FData[i].CommonTrendData.Vol * FData[i].CommonTrendData.Price;

      LastVol := TrendData.m_pHisData[i].m_lTotal;
      AvgPrice := FData[i].CommonTrendData.AvgPrice;

      // FData[i].ETFTrendData.IPOV := TrendData.m_pHisData[i].m_lExt1;
      // FTrendInfo.StopFlag :=  TrendData.m_pHisData[i].m_lStopFlag;
    end;
  end;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateTrendData_Ext(Data: Pointer; size: Integer);
var
  TrendData: PAnsTrendData_Ext;
  i: Integer;
  AvgPrice: Single;
  LastVol: ULong;
  // realTime:PQuoteRealTimeData;
begin
  Exit;
  if size > Length(FData) then
  begin
    FQuoteDataMngr.WriteDebug(Format('[ERROR] CodeType:%d Code:%s ��ʱ��������(%d)�����ڳ�ʼ������(%d).',
      [FCodeInfo.m_cCodeType, CodeInfoToCode(@FCodeInfo), size, FCount]));
    SetLength(FData, size);
  end;
  TrendData := PAnsTrendData_Ext(Data);
  FTrendInfo.PrevClose := TrendData.m_othData.m_Data.m_lPreClose;
  // ��ֵ
  // move(Data^, FData[0], Size * Sizeof(TPriceVolItem));
  if size > 0 then
  begin
    LastVol := 0;
    FCount := size;
    AvgPrice := TrendData.m_pHisData[0].m_pvi.m_lNewPrice;

    for i := 0 to FCount - 1 do
    begin
      AddLog(Format('NewPrice=%d, Total=%d', [TrendData.m_pHisData[i].m_pvi.m_lNewPrice, TrendData.m_pHisData[i].m_pvi.m_lTotal]));
      FData[i].CommonTrendData.Price := TrendData.m_pHisData[i].m_pvi.m_lNewPrice;

      TrendData.m_pHisData[i].m_pvi.m_lTotal := max(LastVol, TrendData.m_pHisData[i].m_pvi.m_lTotal);

      FData[i].CommonTrendData.Vol := TrendData.m_pHisData[i].m_pvi.m_lTotal - LastVol;
      // FData[i].CommonTrendData.AvgPrice :=
      // Trunc((AvgPrice * i + FData[i].CommonTrendData.Price) / (i + 1));

      if (TrendData.m_pHisData[i].m_pvi.m_lTotal <> 0) and (FData[i].CommonTrendData.Price <> 0) then
      begin
        FData[i].CommonTrendData.AvgPrice :=
          trunc((1.0 * LastVol * AvgPrice + 1.0 * FData[i].CommonTrendData.Price * FData[i].CommonTrendData.Vol) /
          TrendData.m_pHisData[i].m_pvi.m_lTotal);
      end
      else
        FData[i].CommonTrendData.AvgPrice := AvgPrice;

      FData[i].CommonTrendData.Money := 1.0 * FData[i].CommonTrendData.Vol * FData[i].CommonTrendData.Price;
      if TrendData.m_pHisData[i].m_pvi.m_lTotal > 0 then
        LastVol := TrendData.m_pHisData[i].m_pvi.m_lTotal;

      AvgPrice := FData[i].CommonTrendData.AvgPrice;
      FData[i].ETFTrendData.IPOV := TrendData.m_pHisData[i].m_lExt1;
      FTrendInfo.StopFlag := TrendData.m_pHisData[i].m_lStopFlag;
    end;
  end;
  Inc(FVarCode);

  SaveLog('F:\time.log');
end;

procedure TQuoteTrend.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    case DataType of
      Update_Trend_TrendData:
        UpdateTrendData(Pointer(Data), size);
      Update_Trend_TrendData_Ext: // ������ʱ����
        UpdateTrendData_Ext(Pointer(Data), size);
      Update_Trend_AutoPush:
        UpdateAutoPush(Pointer(Data), size);
      Update_Trend_AutoPush_Ext:
        UpdateAutoPush_Ext(Pointer(Data), size);
      Update_Trend_DelayAutoPush_Ext: // ��ʱ����
        UpdateDelayAutoPush_Ext(Pointer(Data), size);
      Update_Trend_HisTrendData:
        UpdateHisTrendData(Pointer(Data), size);
      // Update_Trend_MultiTrendData:UpdateMultiTrendData(pointer(Data),size);
      Update_Trend_MAjorIndexLeadData:
        UpdateMILeadData(Pointer(Data), size);
      Update_Trend_MAjorIndexTickData:
        UpdateMITickData(Pointer(Data), size);
      Update_Trend_VirtualAuction:
        UpdateVAData(Pointer(Data), size);
    end;
  finally
    EndWrite;
  end;
end;

// procedure TQuoteTrend.UpdateMultiTrendData(Data: Pointer; size: integer);
// var
// pData:PStockCompDayDataExs;
// i:Integer;
// AvgPrice:LongInt;
// begin
// if size < 1 then Exit;
// pData :=  PStockCompDayDataExs(Data);
// if Length(FData) < size then SetLength(FData,size);
// FCount := SIZE;
// AvgPrice := pData[0].m_lClosePrice;
// for I := 1 to size - 1 do
// begin
// FData[i].CommonTrendData.Price := pData[i].m_lClosePrice;
// FData[i].CommonTrendData.Vol := pData[i].m_lTotal;
// FData[i].CommonTrendData.Money := pData[i].m_lMoney;
// FData[i].CommonTrendData.AvgPrice := (i*AvgPrice + pData[i].m_lClosePrice) div (i+1);
// AvgPrice := Fdata[i].CommonTrendData.AvgPrice;
// end;
// Inc(FVarCode);
// end;

procedure TQuoteTrend.UpdateAutoPush(Data: Pointer; size: Integer);
var
  InData: PCommRealTimeData;
  Index, i: Integer;
  S, C: Integer;
  bt, et: Integer;
  LastMoney: Single;
  SecuCate: TRealTime_Secu_Category;
  Total: cardinal;
  Money: Single;
  LastVol: ULong;
  LastAvgPrice: Single;
begin { wisz 2016-10-14 �����������ֻ�����м����� }
  InData := PCommRealTimeData(Data);
  // ���Ͼ���.
  if IsVAData and (InData.m_cNowData.m_nowData.m_lBuyPrice1 = InData.m_cNowData.m_nowData.m_lSellPrice1) then
  begin
    // if FVACount >= Length(FVadata) then SetLength(FVadata,FVACount + 12);
    GetVATime(bt, et);
    index := InData.m_othData.m_Time.m_sDetailTime.m_nTime - bt;
    if index < 0 then
      index := 0;
    if index < Length(FVadata) then
    begin
      FVadata[index].m_lTime := InData.m_othData.m_Time.m_sDetailTime.m_nTime;
      FVadata[index].m_lPrice := InData.m_cNowData.m_nowData.m_lNewPrice;
      FVadata[index].m_fQty := InData.m_cNowData.m_nowData.m_lTotal;
      if InData.m_cNowData.m_stStockData.m_lBuyCount1 <> 0 then
        FVadata[index].m_fQtyLeft := InData.m_cNowData.m_stStockData.m_lBuyCount1
      else
        FVadata[index].m_fQtyLeft := -InData.m_cNowData.m_stStockData.m_lSellCount1;
      FVACount := index + 1;
      Inc(FVarCode);
    end;
    Exit;
  end;

  SecuCate := GetRealTimeSC(@FCodeInfo);
  case SecuCate of
    rscSTOCK:
      begin
        Total := InData^.m_cNowData.m_nowData.m_lTotal;
        Money := InData^.m_cNowData.m_nowData.m_fAvgPrice;
      end;
    rscINDEX:
      begin
        Total := InData^.m_cNowData.m_indData.m_lTotal;
        Money := InData^.m_cNowData.m_indData.m_fAvgPrice; // �ɽ���
      end;
    rscHKSTOCK:
      begin
        Total := InData^.m_cNowData.m_hkData.m_lTotal;
        Money := InData^.m_cNowData.m_hkData.m_fAvgPrice; // �ɽ���
      end;
    rscUS:
      begin
        Total := InData^.m_cNowData.m_USData.m_lTotal;
        Money := InData^.m_cNowData.m_USData.m_fMoney; // ��Ȩ����
      end;
    rscFUTURES:
      begin
        Total := InData^.m_cNowData.m_qhData.m_lTotal;
        Money := InData^.m_cNowData.m_qhData.m_lTotal * InData^.m_cNowData.m_qhData.m_lNominalFlat div 1000;
      end;
    rscOPTION:
      begin

      end;
  end;

  index := min(InData^.m_othData.m_Time.m_nTime, Length(FData) - 1);
  if index = -1 then
    Exit;
  LastMoney := 0;
  LastVol := 0;
  LastAvgPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
  for i := 0 to Index - 1 do
  begin
    // LastMoney := LastMoney + FData[I].CommonTrendData.Money;
    LastVol := LastVol + FData[i].CommonTrendData.Vol;
    if FData[i].CommonTrendData.AvgPrice <> 0 then
      LastAvgPrice := FData[i].CommonTrendData.AvgPrice;
  end;
  LastMoney := LastVol * LastAvgPrice;
  while FCount - 1 < Index do
    Inc(FCount);
  FData[index].CommonTrendData.Price := InData.m_cNowData.m_nowData.m_lNewPrice;

  Total := max(Total, LastVol);
  { Money := Max(Money, LastMoney); 2016-10-13 wisz �޸� }
  FData[index].CommonTrendData.Vol := Total - LastVol; // InData.m_cNowData.m_nowData.m_lTotal - LastVol;
  FData[index].CommonTrendData.Money := Money - LastMoney;

  if IsStockMajorIndex(@FCodeInfo) then
  begin
    FData[index].IndexTrendData.RiseTrend := InData.m_cNowData.m_indData.m_nRiseTrend;
    FData[index].IndexTrendData.FallTrend := InData.m_cNowData.m_indData.m_nFallTrend;
    FData[index].IndexTrendData.riseCount := InData.m_cNowData.m_indData.m_nRiseCount;
    FData[index].IndexTrendData.FallCount := InData.m_cNowData.m_indData.m_nFallCount;
    FData[index].IndexTrendData.Money := InData.m_cNowData.m_nowData.m_fAvgPrice * 1000 - LastMoney;

    FData[index].IndexTrendData.AdvPrice := CalcLeadTech(InData.m_cNowData.m_indData.m_nLead);
  end
  else
  begin
    if (index > 0) and (Total <> 0) then
    begin
      FData[index].CommonTrendData.AvgPrice :=
        trunc((LastMoney + FData[index].CommonTrendData.Vol * FData[index].CommonTrendData.Price) /
        (FData[index].CommonTrendData.Vol + LastVol));
    end
    else if index > 0 then
      FData[index].CommonTrendData.AvgPrice := FData[index - 1].CommonTrendData.AvgPrice
    else
    begin
      if FData[index].CommonTrendData.Price > 0 then
        FData[index].CommonTrendData.AvgPrice := FData[index].CommonTrendData.Price
      else
        FData[index].CommonTrendData.Price := FTrendInfo.PrevClose;
    end;

  end;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateAutoPush_Ext(Data: Pointer; size: Integer);
var
  InData: PCommRealTimeData_Ext;
  Index, i: Integer;
  S, C: Integer;
  bt, et: Integer;
  LastMoney: Single;
  SecuCate: TRealTime_Secu_Category;
  Total: cardinal;
  Money: Single;
  LastVol: ULong;
  LastPrice: Integer;
  LastAvgPrice: Single;
begin
  InData := PCommRealTimeData_Ext(Data);
  // ���Ͼ���.
  if IsVAData and (InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lBuyPrice1 = InData.m_cNowData.m_nowDataExt.
    m_stockRealTime.m_lSellPrice1) then
  begin
    // if FVACount >= Length(FVadata) then SetLength(FVadata,FVACount + 12);
    GetVATime(bt, et);
    index := InData.m_othData.m_Time.m_sDetailTime.m_nTime - bt;
    if index < 0 then
      index := 0;
    if index < Length(FVadata) then
    begin
      FVadata[index].m_lTime := InData.m_othData.m_Time.m_sDetailTime.m_nTime;
      FVadata[index].m_lPrice := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lNewPrice;
      FVadata[index].m_fQty := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal;
      if InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lBuyCount1 <> 0 then
        FVadata[index].m_fQtyLeft := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lBuyCount1
      else
        FVadata[index].m_fQtyLeft := -InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lSellCount1;
      FVACount := index + 1;
      Inc(FVarCode);
    end;
    Exit;
  end;

  SecuCate := GetRealTimeSC(@FCodeInfo);
  case SecuCate of
    rscSTOCK:
      begin
        Total := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal;
        Money := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_fAvgPrice;
        LastPrice := InData.m_cNowData.m_nowDataExt.m_stockRealTime.m_lNewPrice;
      end;
    rscINDEX:
      begin
        Total := InData.m_cNowData.m_indData.m_indexRealTime.m_lTotal;
        Money := InData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice;
        LastPrice := InData.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice;
      end;
    rscHKSTOCK:
      begin
        Total := InData.m_cNowData.m_hkData.m_baseReal.m_lTotal;
        Money := InData.m_cNowData.m_hkData.m_baseReal.m_fAvgPrice; // �ɽ���
        LastPrice := InData.m_cNowData.m_hkData.m_baseReal.m_lNewPrice;
      end;
    rscUS:
      begin
        Total := InData.m_cNowData.m_USData.m_lTotal;
        Money := InData.m_cNowData.m_USData.m_fMoney; // ��ʾ��Ȩ����
        LastPrice := InData.m_cNowData.m_USData.m_lNewPrice;
      end;
    rscFUTURES:
      begin
        Total := InData.m_cNowData.m_qhData.m_lTotal;
        { Money := InData.m_cNowData.m_qhData.m_lTotal * InData^.m_cNowData.m_qhData.m_lNominalFlat div 1000; 2017-4-17 wisz �޸� �����ʱ����ʷ��ʵʱ����ת����ͳһ������}
        Money := InData.m_cNowData.m_qhData.m_lTotal * InData^.m_cNowData.m_qhData.m_lNominalFlat;
        LastPrice := InData.m_cNowData.m_qhData.m_lNewPrice;
      end;
    rscOPTION:
      begin

      end;
  end;

  index := min(InData^.m_othData.m_Time.m_nTime, Length(FData) - 1);

  if index = -1 then
    Exit;
  LastMoney := 0;
  LastVol := 0;
  LastAvgPrice := LastPrice;
  for i := 0 to Index - 1 do
  begin
    // LastMoney := LastMoney + FData[I].CommonTrendData.Money;
    LastVol := LastVol + FData[i].CommonTrendData.Vol;
    if FData[i].CommonTrendData.AvgPrice <> 0 then
      LastAvgPrice := FData[i].CommonTrendData.AvgPrice;
  end;
  LastMoney := LastVol * LastAvgPrice;
  while FCount - 1 < Index do
    Inc(FCount);
  FData[index].CommonTrendData.Price := LastPrice;

  Total := max(Total, LastVol);
  { Money := Max(Money,LastMoney); 2016-9-12 wisz �޸� }
  if not HSMarketType(FCodeInfo.m_cCodeType, US_MARKET) then // ������
    FData[index].CommonTrendData.Vol := Total - LastVol; // InData.m_cNowData.m_nowData.m_lTotal - LastVol;
  { FData[index].CommonTrendData.Money := Money - LastMoney; 2016-9-12 wisz �޸��㷨���£� }
  FData[index].CommonTrendData.Money := Money; // ÿһ�����ﱣ������ܳɽ���

  if IsStockMajorIndex(@FCodeInfo) then
  begin

    FData[index].IndexTrendData.RiseTrend := InData.m_cNowData.m_indData.m_indexRealTime.m_nRiseTrend;
    FData[index].IndexTrendData.FallTrend := InData.m_cNowData.m_indData.m_indexRealTime.m_nFallTrend;
    FData[index].IndexTrendData.riseCount := InData.m_cNowData.m_indData.m_indexRealTime.m_nRiseCount;
    FData[index].IndexTrendData.FallCount := InData.m_cNowData.m_indData.m_indexRealTime.m_nFallCount;
    { FData[index].IndexTrendData.Money := Money * 1000 - LastMoney; 2016-9-12 wisz �޸��㷨���£� }
    if index > 0 then
      FData[index].IndexTrendData.Money := Money * 1000 - FData[index - 1].IndexTrendData.Money
    else
      FData[index].IndexTrendData.Money := Money * 1000;

    FData[index].IndexTrendData.AdvPrice := CalcLeadTech(InData.m_cNowData.m_indData.m_indexRealTime.m_nLead);
  end
  else
  begin
    { if (index > 0) and (Total <> 0) then
      begin
      FData[index].CommonTrendData.AvgPrice :=
      Trunc((LastMoney + FData[index].CommonTrendData.Vol * FData[index].CommonTrendData.Price)/ (FData[index].CommonTrendData.Vol + LastVol));
      end
      else if index > 0 then
      FData[index].CommonTrendData.AvgPrice := FData[index - 1].CommonTrendData.AvgPrice
      else
      begin
      { if FData[index].CommonTrendData.Price > 0 then
      FData[index].CommonTrendData.AvgPrice := FData[index].CommonTrendData.Price
      else
      FData[index].CommonTrendData.Price := FTrendInfo.PrevClose;
      end;  2016-9-12 wisz �޸��㷨���£� }
    if (index > 0) then
    begin
      if Total = 0 then
        FData[index].CommonTrendData.AvgPrice := FData[index - 1].CommonTrendData.AvgPrice
      else
      begin
        if SecuCate = rscUS then
          FData[index].CommonTrendData.AvgPrice := Money
        else
          FData[index].CommonTrendData.AvgPrice := Money / Total;
      end;
    end
    else
    begin
      if FData[index].CommonTrendData.Price <= 0 then
        FData[index].CommonTrendData.Price := FTrendInfo.PrevClose;
      if Total = 0 then
        FData[index].CommonTrendData.AvgPrice := 0
      else
      begin
        if SecuCate = rscUS then
          FData[index].CommonTrendData.AvgPrice := Money
        else
          FData[index].CommonTrendData.AvgPrice := Money / Total;
      end;
    end;
  end;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateDelayAutoPush_Ext(Data: Pointer; size: Integer);
var
  tmpInData: PCommRealTimeData_Ext;
  tmpIndex: Integer;
  tmpVol: UInt32;
begin
  tmpInData := PCommRealTimeData_Ext(Data);

  tmpIndex := tmpInData^.m_othData.m_Time.m_nTime;

  if (tmpIndex = -1) or (tmpIndex > Length(FData)) then
    Exit;

  if tmpIndex = 0 then
    tmpVol := tmpInData.m_cNowData.m_USDelayData.m_lTotalL
  else
    tmpVol := tmpInData.m_cNowData.m_USDelayData.m_lTotalL - FData[tmpIndex - 1].CommonTrendData.Vol;
  FData[tmpIndex].CommonTrendData.Price := tmpInData.m_cNowData.m_USDelayData.m_lNewPrice;
  FData[tmpIndex].CommonTrendData.Vol := tmpVol;
  FData[tmpIndex].CommonTrendData.AvgPrice := tmpInData.m_cNowData.m_USDelayData.m_lWeightedAveragePx;

  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateHisTrendData(Data: Pointer; size: Integer);
var
  TrendData: PHisTrendData;
  i: Integer;
  LastVol: UInt32;
  AvgPrice: Single;
  LastMoney: Single;
begin
  TrendData := PHisTrendData(Data);

  FTrendInfo.StopFlag := 0;
  FTrendInfo.PrevClose := TrendData.m_shHead.m_lPrevClose;
  FTrendInfo.TradeDate := TrendData.m_shHead.m_lDate;

  // ��ֵ
  // move(Data^, FData[0], Size * Sizeof(TPriceVolItem));
  FCount := TrendData.m_shHead.m_nSize;
  if Length(FData) < FCount then
    SetLength(FData, FCount);

  if FCount > 0 then
  begin
    LastVol := 0;
    LastMoney := 0;
    AvgPrice := TrendData.m_shData[0].m_lNewPrice;
    for i := 0 to FCount - 1 do
    begin
      FData[i].CommonTrendData.Price := TrendData.m_shData[i].m_lNewPrice;

      if TrendData.m_shData[i].m_lTotal > LastVol then
        FData[i].CommonTrendData.Vol := TrendData.m_shData[i].m_lTotal - LastVol
      else
        FData[i].CommonTrendData.Vol := 0;

      if (TrendData.m_shData[i].m_lTotal <> 0) and (FData[i].CommonTrendData.Price <> 0) then
      begin
        if HSMarketType(FCodeInfo.m_cCodeType, FUTURES_MARKET) then // �ڻ�
        begin
          FData[i].CommonTrendData.AvgPrice :=
            trunc((1.0 * LastVol * AvgPrice + 1.0 * FData[i].CommonTrendData.Price * FData[i].CommonTrendData.Vol) /
            TrendData.m_shData[i].m_lTotal);
          FData[i].CommonTrendData.Money := TrendData.m_shData[i].m_fAvgPrice - LastMoney;
        end
        else if HSMarketType(FCodeInfo.m_cCodeType, US_MARKET) then // ����
        begin
          FData[i].CommonTrendData.AvgPrice := TrendData.m_shData[i].m_fAvgPrice;
          FData[i].CommonTrendData.Money := TrendData.m_shData[i].m_fAvgPrice;
        end
        else if HSMarketType(FCodeInfo.m_cCodeType, OTHER_MARKET) then  // ����ָ��
        begin
          FData[i].CommonTrendData.AvgPrice := 0;
          FData[i].CommonTrendData.Money := TrendData.m_shData[i].m_fAvgPrice;
        end
        else
        begin
          FData[i].CommonTrendData.AvgPrice := TrendData.m_shData[i].m_fAvgPrice / TrendData.m_shData[i].m_lTotal;
          FData[i].CommonTrendData.Money := TrendData.m_shData[i].m_fAvgPrice;
        end;
      end
      else
        { FData[i].CommonTrendData.AvgPrice := AvgPrice; ���Ͼ���ʱ�Σ�9:30�ľ��۲��� }
        FData[i].CommonTrendData.AvgPrice := 0;

      AvgPrice := FData[i].CommonTrendData.AvgPrice;

      LastVol := TrendData.m_shData[i].m_lTotal;
      LastMoney := TrendData.m_shData[i].m_fAvgPrice;
    end;
    if HSMarketType(FCodeInfo.m_cCodeType, US_MARKET) and (FCount > 1) then // ���ɵĵڸ���������������
    begin
      FTrendInfo.PrevClose := FData[0].CommonTrendData.Price;
      FData[0].CommonTrendData.Price := FData[1].CommonTrendData.Price;
      FData[0].CommonTrendData.Vol := 0; // FData[1].CommonTrendData.Vol;
      FData[0].CommonTrendData.AvgPrice := FData[1].CommonTrendData.AvgPrice;
      FData[0].CommonTrendData.Money := FData[1].CommonTrendData.Money;
    end;
  end;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateMILeadData(Data: Pointer; size: Integer);
var
  pData: pAnsLeadData;
  StockLeadData: PStockLeadData;
  i: Integer;
begin
  pData := pAnsLeadData(Data);
  StockLeadData := @pData.m_pHisData[0];
  if Length(FData) < pData.m_nHisLen then
    SetLength(FData, pData.m_nHisLen);
  for i := 0 to pData.m_nHisLen - 1 do
  begin
    FData[i].IndexTrendData.AdvPrice := CalcLeadTech(StockLeadData.m_nLead);
    FData[i].IndexTrendData.RiseTrend := StockLeadData.m_nRiseTrend;
    FData[i].IndexTrendData.FallTrend := StockLeadData.m_nFallTrend;
    Inc(StockLeadData);
  end;
  // FCount := pData.m_nHisLen;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateMITickData(Data: Pointer; size: Integer);
var
  pData: PAnsMajorIndexTick;
  VolItem: PMajorIndexItem;
  i: Integer;
  LastMoney: Single;
  LastVol: ULong;
begin
  pData := PAnsMajorIndexTick(Data);
  VolItem := @pData.m_ntrData[0];
  LastVol := 0;
  LastMoney := 0;
  if Length(FData) < pData.m_nSize then
    SetLength(FData, pData.m_nSize);
  for i := 0 to pData.m_nSize - 1 do
  begin
    FData[i].IndexTrendData.Price := VolItem.m_lNewPrice;
    FData[i].IndexTrendData.Money := (VolItem.m_fAvgPrice - LastMoney) * 100000;
    LastMoney := VolItem.m_fAvgPrice;
    FData[i].IndexTrendData.Vol := VolItem.m_lTotal - LastVol;
    LastVol := VolItem.m_lTotal;
    FData[i].IndexTrendData.riseCount := VolItem.m_nRiseCount;
    FData[i].IndexTrendData.FallCount := VolItem.m_nFallCount;
    // FData[i].IndexTrendData.SameCount := pData.
    Inc(VolItem);
  end;
  FCount := pData.m_nSize;
  Inc(FVarCode);
end;

procedure TQuoteTrend.UpdateVAData(Data: Pointer; size: Integer);
var
  AnsVA: PAnsVirtualAuction;
  P: PStockVirtualAuction;
  i: Integer;
  t, Index: Integer;
  bt, et: Integer;
begin
  if Data = nil then
    Exit;
  GetVATime(bt, et);
  AnsVA := PAnsVirtualAuction(Data);
  P := @AnsVA.m_vaData[0];
  // if AnsVA.m_nSize > Length(FVadata) then SetLength(FVadata,AnsVA.m_nSize);
  FVACount := 0;
  t := 0;
  Index := -1;
  for i := 0 to AnsVA.m_nSize - 1 do
  begin
    // FVadata[i] := p^;
    t := P.m_lTime div 100000;
    t := (t div 100) * 60 + t mod 100;
    t := max(bt, t);
    t := min(et, t);
    Index := t - bt;
    if Index >= Length(FVadata) then
      Index := Length(FVadata) - 1;
    FVadata[Index] := P^;
    FVadata[Index].m_lTime := t;
    // FVadata[i].m_lTime := t shl 16 + p.m_lTime div 1000 mod 1000; //hhmmssxxx ת��Ϊ  TStockOtherData_Time
    // inc(FVACount);
    Inc(P);
  end;
  FVACount := Index + 1;
  Inc(FVarCode);
end;

procedure TQuoteTrend.GetPrevCose;
var
  P: PStockInitInfo;
begin
  P := PStockInitInfo(FQuoteDataMngr.QuoteRealTime.Codes[FCodeInfo.m_cCodeType, CodeInfoToCode(@FCodeInfo)]);
  if P <> nil then // ��������ָ���ֵ
    FTrendInfo.PrevClose := P.m_lPrevClose;
end;

function TQuoteTrend.CalcLeadTech(MILead: short): LongInt;
begin
  result := trunc((MILead * 0.0001 + 1) * FTrendInfo.PrevClose);
end;

function TQuoteTrend.TimeToIndex(Time: Integer): Integer;
var
  i: Integer;
  nCount: Integer;
  pST: PStockType;
begin
  result := -1;
  nCount := 0;

  pST := @FStockTypeInfo.StockType;
  for i := 0 to Length(pST.m_nNewTimes) - 1 do
  begin
    if pST.m_nNewTimes[i].m_nOpenTime = -1 then
      Exit;
    if (pST.m_nNewTimes[i].m_nOpenTime <= Time) and (Time <= pST.m_nNewTimes[i].m_nCloseTime) then
      Exit(nCount + Time - pST.m_nNewTimes[i].m_nOpenTime);
    Inc(nCount, pST.m_nNewTimes[i].m_nCloseTime - pST.m_nNewTimes[i].m_nOpenTime);
  end;
end;

function TQuoteTrend.GetTrendInfo: Int64;
begin
  result := Int64(@FTrendInfo);
end;

function TQuoteTrend.Get_VADatas: Int64;
begin
  if Length(FVadata) = 0 then
    result := 0
  else
    result := Int64(@FVadata[0]);
end;

function TQuoteTrend.Get_VADataCount: Integer;
begin
  result := FVACount;
end;

procedure TQuoteTrend.GetVATime(var Begin_: Integer; var End_: Integer);
begin
  if IsVAData then
  begin
    Begin_ := 555;
    End_ := 565;
  end
  else
  begin
    Begin_ := -1;
    End_ := -1;
  end;
end;

function TQuoteTrend.IsVAData(): WordBool;
begin
  result := (HSMarketBourseType(FCodeInfo.m_cCodeType, STOCK_MARKET, SH_BOURSE) or
    HSMarketBourseType(FCodeInfo.m_cCodeType, STOCK_MARKET, SZ_BOURSE)) and
    (not HSKindType(FCodeInfo.m_cCodeType, KIND_INDEX));
end;

{ TQuoteMultiTrend }
constructor TQuoteMultiTrend.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteMultiTrend);
  FCodeInfo := CodeInfo^;
  SetLength(FData, 10);
  FData[0] := TQuoteTrend.Create(QuoteDataMngr, CodeInfo);
  FCount := 1;
end;

destructor TQuoteMultiTrend.Destroy;
begin
  SetLength(FData, 0);
  FCount := 0;
  inherited;
end;

{ IQuoteMultiTrend }
function TQuoteMultiTrend.count: Integer;
begin
  result := FCount;
end;

function TQuoteMultiTrend.Get_Datas(Index: Integer): IQuoteTrend;
begin
  result := FData[Index];
end;

{ IQuoteUpdate }
procedure TQuoteMultiTrend.Update(DataType: Integer; Data: Int64; size: Integer);
var
  Index: Integer;
begin
  BeginWrite;
  try
    if DataType = Update_Trend_MultiHisTrendData then
    begin
      Index := abs(size);
      if Index < Length(FData) then
      begin
        if FData[Index] = nil then
          FData[Index] := TQuoteTrend.Create(FQuoteDataMngr, @FCodeInfo);
        (FData[Index] as IQuoteUpdate).Update(Update_Trend_HisTrendData, Data, 0);
      end;
      for Index := 0 to Length(FData) - 1 do
      begin
        if FData[Index] <> nil then
        begin
          FCount := Index + 1;
        end
        else
          Break;
      end;
    end
    else
      (FData[0] as IQuoteUpdate).Update(DataType, Data, size);
  finally
    EndWrite;
  end;
end;

{ TQuoteStockTick }

constructor TQuoteStockTick.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteStockTick);
  FCodeInfo := CodeInfo^;
  FTimes := QuoteDataMngr.GetStockTypeInfo(FCodeInfo.m_cCodeType).Times;

end;

destructor TQuoteStockTick.Destroy;
begin
  FData := nil;
  inherited;
end;

function TQuoteStockTick.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteStockTick.Get_Count: Integer;
begin
  result := FCount;
end;

function TQuoteStockTick.Get_Datas: Int64;
begin
  if FCount > 0 then
    result := Int64(@FData[0])
  else
    result := 0;
end;

function TQuoteStockTick.Get_IndexToTime(Index: Integer): Integer;
begin
  if FTimes <> nil then
    result := FTimes.ValueOf(Index)
  else
    result := -1;
end;

function TQuoteStockTick.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteStockTick.GrowData(count: Integer);
begin
  if count >= FCapacity then
  begin
    FCapacity := count + 120;
    SetLength(FData, FCapacity);
  end;
end;

procedure TQuoteStockTick.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_StockTick_StockTickData then
    begin // �����ֱ�����
      UpdateStockTickData(Pointer(Data), size);
    end
    else if DataType = Update_StockTick_AutoPush then
    begin
      UpdateAutoPush(Pointer(Data), size);
    end
    else if DataType = Update_StockTick_AutoPush_Ext then
    begin
      UpdateAutoPush_Ext(Pointer(Data), size);
    end;

  finally
    EndWrite;
  end;
end;

procedure TQuoteStockTick.UpdateAutoPush(Data: Pointer; size: Integer);
var
  InData: PCommRealTimeData;
  SecuCate: TRealTime_Secu_Category;
begin
  InData := PCommRealTimeData(Data);
  if FLastTotal = InData^.m_cNowData.m_nowData.m_lTotal then
    Exit;
  if FCount >= FCapacity then
    GrowData(FCount + 32);
  with FData[FCount] do
  begin
    m_nTime := InData^.m_othData.m_Time.m_nTime; // ��ǰʱ�䣨�࿪�̷�������
    m_Buy.m_sDetailTime.m_nSecond := ansichar(byte(InData^.m_othData.m_Time.m_sDetailTime.m_nSecond));
    // m_Buy.m_nBuyOrSell := InData^.m_cNowData.m_nowData.; // �ǰ��۳ɽ����ǰ����۳ɽ�(1 ����� 0 ������)
    // m_Buy.m_sDetailTime.m_nSecond := InData^.m_othData.m_Time.m_sDetailTime.m_nSecond;

    SecuCate := GetRealTimeSC(@FCodeInfo);
    case SecuCate of
      rscSTOCK:
        begin
          FLastTotal := InData^.m_cNowData.m_nowData.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_nowData.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_nowData.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_nowData.m_lBuyPrice1; // ί���
          m_lSellPrice := InData^.m_cNowData.m_nowData.m_lSellPrice1; // ί����
        end;
      rscINDEX:
        begin
          FLastTotal := InData^.m_cNowData.m_indData.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_indData.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_indData.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_indData.m_lNewPrice; // ί���
          m_lSellPrice := InData^.m_cNowData.m_indData.m_lNewPrice; // ί����
        end;
      rscHKSTOCK:
        begin
          FLastTotal := InData^.m_cNowData.m_hkData.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_hkData.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_hkData.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_hkData.m_lBuyPrice; // ί���
          m_lSellPrice := InData^.m_cNowData.m_hkData.m_lSellPrice; // ί����
        end;
      rscFUTURES:
        begin
          FLastTotal := InData^.m_cNowData.m_qhData.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_qhData.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_qhData.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_qhData.m_lBuyPrice1; // ί���
          m_lSellPrice := InData^.m_cNowData.m_qhData.m_lSellPrice1; // ί����
          m_nChiCangLiang := InData^.m_cNowData.m_qhData.m_lChiCangLiang;
        end;
      rscOPTION:
        begin

        end;
    end;

    // m_nChiCangLiang := InData^.m_othData.m_Data.	   // �ֲ���,�����Ʊ���ʳɽ���,�۹ɳɽ��̷���(Y,M,X�ȣ���������Դ��ȷ����
  end;
  Inc(FCount);
  Inc(FVarCode);
end;

procedure TQuoteStockTick.UpdateAutoPush_Ext(Data: Pointer; size: Integer);
var
  InData: PCommRealTimeData_Ext;
  SecuCate: TRealTime_Secu_Category;
begin
  InData := PCommRealTimeData_Ext(Data);
  // if FLastTotal = InData.m_othData.m_Time  then exit;
  if FCount >= FCapacity then
    GrowData(FCount + 32);
  with FData[FCount] do
  begin
    m_nTime := InData^.m_othData.m_Time.m_nTime; // ��ǰʱ�䣨�࿪�̷�������
    m_Buy.m_sDetailTime.m_nSecond := ansichar(byte(InData^.m_othData.m_Time.m_sDetailTime.m_nSecond));
    // m_Buy.m_nBuyOrSell := InData^.m_cNowData.m_nowData.; // �ǰ��۳ɽ����ǰ����۳ɽ�(1 ����� 0 ������)
    // m_Buy.m_sDetailTime.m_nSecond := InData^.m_othData.m_Time.m_sDetailTime.m_nSecond;

    SecuCate := GetRealTimeSC(@FCodeInfo);
    case SecuCate of
      rscSTOCK:
        begin
          // FLastTotal := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lBuyPrice1; // ί���
          m_lSellPrice := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lSellPrice1; // ί����
        end;
      rscINDEX:
        begin
          // FLastTotal := InData^.m_cNowData.m_indData.m_indexRealTime.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_indData.m_indexRealTime.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice; // ί���
          m_lSellPrice := InData^.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice; // ί����
        end;
      rscHKSTOCK:
        begin
          // FLastTotal := InData^.m_cNowData.m_hkData.m_baseReal.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_hkData.m_baseReal.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_hkData.m_baseReal.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_hkData.m_baseReal.m_lBuyPrice; // ί���
          m_lSellPrice := InData^.m_cNowData.m_hkData.m_baseReal.m_lSellPrice; // ί����
        end;
      rscFUTURES:
        begin
          // FLastTotal := InData^.m_cNowData.m_qhData.m_lTotal;
          m_lNewPrice := InData^.m_cNowData.m_qhData.m_lNewPrice; // �ɽ���
          m_lCurrent := InData^.m_cNowData.m_qhData.m_lTotal; // �ɽ���
          m_lBuyPrice := InData^.m_cNowData.m_qhData.m_lBuyPrice1; // ί���
          m_lSellPrice := InData^.m_cNowData.m_qhData.m_lSellPrice1; // ί����
          m_nChiCangLiang := InData^.m_cNowData.m_qhData.m_lChiCangLiang;
        end;
      rscOPTION:
        begin

        end;
    end;

    // m_nChiCangLiang := InData^.m_othData.m_Data.	   // �ֲ���,�����Ʊ���ʳɽ���,�۹ɳɽ��̷���(Y,M,X�ȣ���������Դ��ȷ����
  end;
  if FLastTotal <> FData[FCount].m_lCurrent then
  begin
    FLastTotal := FData[FCount].m_lCurrent;
  end
  else
  begin
    // �ɽ������ϱ�һ�� �����������
    ZeroMemory(@FData[FCount], SizeOf(FData[FCount]));
    Exit;
  end;

  Inc(FCount);
  Inc(FVarCode);
end;

procedure TQuoteStockTick.UpdateStockTickData(Data: Pointer; size: Integer);
begin
  if size > FCapacity then
    GrowData(size);
  // ��ֵ
  Move(Data^, FData[0], size * SizeOf(TStockTick));
  FCount := size;
  FLastTotal := 0;
  if FCount > 1 then
    FLastTotal := FData[FCount - 1].m_lCurrent;
  Inc(FVarCode);
end;

{ TQuoteTechData }

constructor TQuoteTechData.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo; QuoteType: QuoteTypeEnum);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteTechData);
  FLastVol := 0;
  FLastMoney := 0;
  FCodeInfo := CodeInfo^;

  FQuoteType := QuoteType; // ����

  // ��ȡ��ǰ������ ����ʱ��
  FMarkDate := QuoteDataMngr.GetBourseInfo(FCodeInfo.m_cCodeType).m_lDate;
  FTimes := QuoteDataMngr.GetStockTypeInfo(FCodeInfo.m_cCodeType).Times;

  { //��ȡ��ǰ������ ����ʱ��
    if FCodeInfo.m_cCodeType and SH_BOURSE = SH_BOURSE then begin
    FMarkDate := QuoteDataMngr.SHMarketDate ;
    FTimes := QuoteDataMngr.SHTimes ;
    end else if FCodeInfo.m_cCodeType and SZ_BOURSE = SZ_BOURSE then begin
    FMarkDate := QuoteDataMngr.SZMarketDate ;
    FTimes := QuoteDataMngr.SZTimes ;
    end else FMarkDate := 0; }

  LoadCacheData;
end;

function TQuoteTechData.DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant)
  : WideString;
begin
  BeginRead;
  try
    IValue := 0;
    SValue := '';
    VValue := 0;
    if State = State_Tech_DataLen then
    begin
      if FCacheDate = FMarkDate then
        IValue := FCount;
    end
    else if State = State_Tech_VarCode then
    begin
      IValue := FVarCode;
    end
    else if State = State_Tech_IsBusy then
    begin
      IValue := FIsBusy
    end
    else if State = State_Tech_WaitCount then
    begin
      IValue := FWaitCount
    end;
  finally
    EndRead;
  end;
end;

destructor TQuoteTechData.Destroy;
begin
  FData := nil;
  inherited;
end;

function TQuoteTechData.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteTechData.Get_Count: Integer;
begin
  result := FCount;
end;

function TQuoteTechData.Get_Datas: Int64;
// var
// List:TStringList;
// I:Integer;
begin
  result := Int64(@FData[0]);
  // if FQuoteType = QuoteType_TECHDATA_MINUTE1 then
  // begin
  // List := TStringList.Create;
  // try
  // for I := 0 to FCount - 1 do
  // begin
  // List.Add(Format('%d,%d,%d,%d',[fData[I].m_lOpenPrice,
  // fData[I].m_lMaxPrice,fData[I].m_lMinPrice, fData[I].m_lClosePrice]));
  //
  // end;
  // List.SaveToFile('d:\1min.txt');
  // finally
  // List.Free;
  // end;
  // end;

end;

function TQuoteTechData.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteTechData.GrowData(count: Integer);
begin
  if count >= FCapacity then
  begin
    FCapacity := count + 20;
    SetLength(FData, FCapacity);
  end;
end;

procedure TQuoteTechData.LoadCacheData;
begin
  //
end;

procedure TQuoteTechData.SaveCacheData;
begin
  //
end;

procedure TQuoteTechData.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_Tech_TechData then
    begin // ����ȫ������
      UpdateTechData(Pointer(Data), size);
      FIsBusy := 0;
      // ��������
      SaveCacheData();
    end
    else if DataType = Update_Tech_AutoPush then
    begin
      if Pointer(Data) = nil then
        Exit;
      // ����һ����
      if FQuoteType = QuoteType_TECHDATA_MINUTE1 then
        UpdateAutoPush_MINUTE1(Pointer(Data), size)

        // ���������
      else if FQuoteType = QuoteType_TECHDATA_MINUTE5 then
        UpdateAutoPush_MINUTE5(Pointer(Data), size)

        // ����ʮ�����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE15 then
        // UpdateAutoPush_MINUTECount(Pointer(Data), size, 15)
        // ������ʮ����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE30 then
        // UpdateAutoPush_MINUTECount(Pointer(Data), size, 30)
        // ������ʮ����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE60 then
        // UpdateAutoPush_MINUTECount(Pointer(Data), size, 60)
        // else if FQuoteType = QuoteType_TECHDATA_WEEK then
        // begin
        // UpdateAutoPush_WEEK(Pointer(Data), size);
        // end
        // else if FQuoteType = QuoteType_TECHDATA_MONTH then
        // begin
        // UpdateAutoPush_MONTH(Pointer(Data), size);
        // end
        // ����һ��
      else if FQuoteType = QuoteType_TECHDATA_DAY then
        UpdateAutoPush_Day(Pointer(Data), size);
    end
    else if DataType = Update_Tech_AutoPush_Ext then
    begin
      if Pointer(Data) = nil then
        Exit;
      // ����һ����
      if FQuoteType = QuoteType_TECHDATA_MINUTE1 then
        UpdateAutoPush_Ext_MINUTE1(Pointer(Data), size)

        // ���������
      else if FQuoteType = QuoteType_TECHDATA_MINUTE5 then
        UpdateAutoPush_Ext_MINUTE5(Pointer(Data), size)

        // ����ʮ�����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE15 then
        UpdateAutoPush_Ext_MultiMin(Pointer(Data), size, 15)
        // ������ʮ����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE30 then
        UpdateAutoPush_Ext_MultiMin(Pointer(Data), size, 30)
        // ������ʮ����
      else if FQuoteType = QuoteType_TECHDATA_MINUTE60 then
        UpdateAutoPush_Ext_MultiMin(Pointer(Data), size, 60)
        // else if FQuoteType = QuoteType_TECHDATA_WEEK then
        // begin
        // UpdateAutoPush_Ext_WEEK(Pointer(Data), size);
        // end
        // else if FQuoteType = QuoteType_TECHDATA_MONTH then
        // begin
        // UpdateAutoPush_Ext_MONTH(Pointer(Data), size);
        // end
        // ����һ��
      else if FQuoteType = QuoteType_TECHDATA_DAY then
        UpdateAutoPush_Ext_Day(Pointer(Data), size);
    end
    else if DataType = Update_Tech_WaitCount then
    begin

      if size > FWaitCount then
        FWaitCount := size;

    end
    else if DataType = Update_Tech_ResetWaitCount then
    begin
      FWaitCount := 0;

    end
    else if DataType = Update_Tech_Busy then
    begin
      FIsBusy := 1;
    end;
  finally
    EndWrite;
  end;
end;

procedure TQuoteTechData.UpdateAutoPush_Day(Data: Pointer; size: Integer);
var
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData;
  Total: cardinal;
  Money: Single;
  SecuCat: TRealTime_Secu_Category;
begin
  if FCount > 0 then
  begin
    InData := PCommRealTimeData(Data);
    // ȡ������һ������
    CData := @FData[FCount - 1];
    SecuCat := GetRealTimeSC(@FCodeInfo);
    case SecuCat of
      rscSTOCK, rscINDEX, rscHKSTOCK: // ����֤ȯ  //ָ�� //�۹�
        begin
          Total := InData^.m_cNowData.m_nowData.m_lTotal;
          Money := InData^.m_cNowData.m_nowData.m_fAvgPrice;
        end;
      rscFUTURES: // �ڻ�
        begin
          Total := InData^.m_cNowData.m_qhData.m_lTotal;
          Money := InData^.m_cNowData.m_qhData.m_lNominalFlat;
        end;
      rscUS:
        begin
          Total := InData^.m_cNowData.m_USData.m_lTotal;
          Money := InData^.m_cNowData.m_USData.m_fMoney;
        end;
      rscOPTION: // ��Ȩ
        begin
          Total := 0;
          Money := 0;
        end;
      rscIB: // ���м�֤ȯ
        begin

        end;
      rscFX: // ��� of
        begin

        end;

    end;
    // ֻ�������� ��� ������ͬ ����
    if CData^.m_lDate = FMarkDate then
    begin
      if CData^.m_lOpenPrice = 0 then
        Exit;

      CData^.m_lOpenPrice := InData^.m_cNowData.m_nowData.m_lOpen;
      CData^.m_lMaxPrice := InData^.m_cNowData.m_nowData.m_lMaxPrice;
      CData^.m_lMinPrice := InData^.m_cNowData.m_nowData.m_lMinPrice;
      CData^.m_lClosePrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
      CData^.m_lMoney := trunc(Money * 0.001);
      if (InData^.m_cNowData.m_nowData.m_nHand > 0) and (GetRealTimeSC(@FCodeInfo) <> rscINDEX) then
        CData^.m_lTotal := Total div UINT(InData^.m_cNowData.m_nowData.m_nHand)
      else
        CData^.m_lTotal := Total;

      Inc(FVarCode);
    end;
  end;
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_Day(Data: Pointer; size: Integer);
var
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData_Ext;
  Total, AHandle, Open, max, min, Close: cardinal;
  Money: Single;
  SecuCat: TRealTime_Secu_Category;
begin
  if FCount > 0 then
  begin
    InData := PCommRealTimeData_Ext(Data);
    // ȡ������һ������
    AHandle := 1;
    CData := @FData[FCount - 1];
    SecuCat := GetRealTimeSC(@FCodeInfo);
    case SecuCat of
      rscSTOCK: // ����֤ȯ
        begin
          Total := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal;
          Money := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_fAvgPrice;
          AHandle := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_nHand;
          Open := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lOpen;
          max := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lMaxPrice;
          min := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lMinPrice;
          Close := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lNewPrice;
        end;
      rscINDEX: // ָ��
        begin
          Total := InData^.m_cNowData.m_indData.m_indexRealTime.m_lTotal;
          Money := InData^.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice;
          // AHandle := InData^.m_cNowData.m_indData.m_indexRealTime.m_nHand;
          Open := InData^.m_cNowData.m_indData.m_indexRealTime.m_lOpen;
          max := InData^.m_cNowData.m_indData.m_indexRealTime.m_lMaxPrice;
          min := InData^.m_cNowData.m_indData.m_indexRealTime.m_lMinPrice;
          Close := InData^.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice;
        end;
      rscHKSTOCK: // �۹�
        begin
          Total := InData^.m_cNowData.m_hkData.m_baseReal.m_lTotal;
          Money := InData^.m_cNowData.m_hkData.m_baseReal.m_fAvgPrice;
          AHandle := InData^.m_cNowData.m_hkData.m_baseReal.m_lHand;
          Open := InData^.m_cNowData.m_hkData.m_baseReal.m_lOpen;
          max := InData^.m_cNowData.m_hkData.m_baseReal.m_lMaxPrice;
          min := InData^.m_cNowData.m_hkData.m_baseReal.m_lMinPrice;
          Close := InData^.m_cNowData.m_hkData.m_baseReal.m_lNewPrice;
        end;
      rscUS:
        begin
          Total := InData^.m_cNowData.m_USData.m_lTotal;
          Money := InData^.m_cNowData.m_USData.m_fMoney;
          AHandle := InData^.m_cNowData.m_USData.m_nHand;
          Open := InData^.m_cNowData.m_USData.m_lOpen;
          max := InData^.m_cNowData.m_USData.m_lMaxPrice;
          min := InData^.m_cNowData.m_USData.m_lMinPrice;
          Close := InData^.m_cNowData.m_USData.m_lNewPrice;
        end;
      rscFUTURES: // �ڻ�
        begin
          // AHandle := InData^.m_cNowData.m_qhData.m_nHand;
          Total := InData^.m_cNowData.m_qhData.m_lTotal;
          Money := InData^.m_cNowData.m_qhData.m_lNominalFlat * Total div 1000;

          Open := InData^.m_cNowData.m_qhData.m_lOpen;
          max := InData^.m_cNowData.m_qhData.m_lMaxPrice;
          min := InData^.m_cNowData.m_qhData.m_lMinPrice;
          Close := InData^.m_cNowData.m_qhData.m_lNewPrice;
        end;
      rscOPTION: // ��Ȩ
        begin
          Total := 0;
          Money := 0;
        end;
      rscIB: // ���м�֤ȯ
        begin

        end;
      rscFX: // ��� of
        begin

        end;
    end;
    // ֻ�������� ��� ������ͬ ����
    if CData^.m_lDate = FMarkDate then
    begin
      if CData^.m_lOpenPrice = 0 then
        Exit;

      CData^.m_lOpenPrice := Open;
      CData^.m_lMaxPrice := max;
      CData^.m_lMinPrice := min;
      CData^.m_lClosePrice := Close;
      CData^.m_lMoney := trunc(Money * 0.001);
      if (AHandle > 0) and (SecuCat <> rscINDEX) then
        CData^.m_lTotal := Total div UINT(AHandle)
      else
        CData^.m_lTotal := Total;

      Inc(FVarCode);
    end;
  end;
end;

procedure TQuoteTechData.UpdateATechData(P: PStockCompDayDataEx; InData: PCommRealTimeData; IsNew: Boolean);
var
  SecuCate: TRealTime_Secu_Category;
  Total: cardinal;
  Money: Single;
begin
  SecuCate := GetRealTimeSC(@FCodeInfo);
  case SecuCate of
    rscSTOCK:
      begin
        Total := InData^.m_cNowData.m_nowData.m_lTotal;
        Money := InData^.m_cNowData.m_nowData.m_fAvgPrice;
      end;
    rscINDEX:
      begin
        Total := InData^.m_cNowData.m_indData.m_lTotal;
        Money := InData^.m_cNowData.m_indData.m_fAvgPrice; // �ɽ���
      end;
    rscHKSTOCK:
      begin
        Total := InData^.m_cNowData.m_hkData.m_lTotal;
        Money := InData^.m_cNowData.m_hkData.m_lNewPrice; // �ɽ���
      end;
    rscFUTURES:
      begin
        Total := InData^.m_cNowData.m_qhData.m_lTotal;
        Money := InData^.m_cNowData.m_qhData.m_lTotal * InData^.m_cNowData.m_qhData.m_lNominalFlat div 1000;
      end;
    rscUS:
      begin
        Total := InData^.m_cNowData.m_USData.m_lTotal;
        Money := InData^.m_cNowData.m_USData.m_fMoney;
      end;
    rscOPTION:
      begin

      end;
  end;

  if (P = nil) or (InData = nil) then
    Exit;

  P^.m_lClosePrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
  if IsNew then
  begin
    P^.m_lOpenPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
    P^.m_lMaxPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
    P^.m_lMinPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
    P^.m_lMoney := 0;
    P.m_lTotal := 0;
  end
  else
  begin
    if InData^.m_cNowData.m_nowData.m_lNewPrice > P^.m_lMaxPrice then
      P^.m_lMaxPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
    if InData^.m_cNowData.m_nowData.m_lNewPrice < P^.m_lMinPrice then
      P^.m_lMinPrice := InData^.m_cNowData.m_nowData.m_lNewPrice;
  end;
  if (FLastVol > 0) then
    P^.m_lTotal := P^.m_lTotal + (Total - FLastVol);
  FLastVol := Total;
  if FLastMoney > 0 then
    P^.m_lMoney := P^.m_lMoney + trunc((Money - FLastMoney) * 0.001);
  FLastMoney := Money;
end;

procedure TQuoteTechData.UpdateATechData_Ext(P: PStockCompDayDataEx; InData: PCommRealTimeData_Ext; IsNew: Boolean);
var
  SecuCate: TRealTime_Secu_Category;
  Total, LastPrice: cardinal;
  Money: Single;
begin
  SecuCate := GetRealTimeSC(@FCodeInfo);
  case SecuCate of
    rscSTOCK:
      begin
        Total := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lTotal;
        Money := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_fAvgPrice;
        LastPrice := InData^.m_cNowData.m_nowDataExt.m_stockRealTime.m_lNewPrice;
      end;
    rscINDEX:
      begin
        Total := InData^.m_cNowData.m_indData.m_indexRealTime.m_lTotal;
        Money := InData^.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice; // �ɽ���
        LastPrice := InData^.m_cNowData.m_indData.m_indexRealTime.m_lNewPrice;
      end;
    rscHKSTOCK:
      begin
        Total := InData^.m_cNowData.m_hkData.m_baseReal.m_lTotal;
        Money := InData^.m_cNowData.m_hkData.m_baseReal.m_lNewPrice; // �ɽ���
        LastPrice := InData^.m_cNowData.m_hkData.m_baseReal.m_lNewPrice;
      end;
    rscFUTURES:
      begin
        Total := InData^.m_cNowData.m_qhData.m_lTotal;
        Money := InData^.m_cNowData.m_qhData.m_lTotal * InData^.m_cNowData.m_qhData.m_lNominalFlat div 1000;
        LastPrice := InData^.m_cNowData.m_qhData.m_lNewPrice;
      end;
    rscUS:
      begin
        Total := InData^.m_cNowData.m_USData.m_lTotal;
        Money := InData^.m_cNowData.m_USData.m_fMoney;
        LastPrice := InData^.m_cNowData.m_USData.m_lNewPrice;
      end;
    rscOPTION:
      begin

      end;
  end;

  if (P = nil) or (InData = nil) then
    Exit;

  P^.m_lClosePrice := LastPrice;
  if IsNew then
  begin
    P^.m_lOpenPrice := LastPrice;
    P^.m_lMaxPrice := LastPrice;
    P^.m_lMinPrice := LastPrice;
    P^.m_lMoney := 0;
    P.m_lTotal := 0;
  end
  else
  begin
    if LastPrice > P^.m_lMaxPrice then
      P^.m_lMaxPrice := LastPrice;
    if LastPrice < P^.m_lMinPrice then
      P^.m_lMinPrice := LastPrice;
  end;
  if (FLastVol > 0) then
    P^.m_lTotal := P^.m_lTotal + (Total - FLastVol);
  FLastVol := Total;
  if FLastMoney > 0 then
    P^.m_lMoney := P^.m_lMoney + trunc((Money - FLastMoney) * 0.001);
  FLastMoney := Money;
end;

procedure TQuoteTechData.UpdateAutoPush_MINUTE1(Data: Pointer; size: Integer);
var
  iTime: Integer;
  currDate, currMarkDate, currTime: UINT;
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData;
  IsNew: Boolean;
begin
  if (FTimes = nil) or (FCount = 0) then
    Exit;
  IsNew := False;

  InData := PCommRealTimeData(Data);
  // ȡ����ֵ
  CData := @FData[FCount - 1];
  currDate := CData^.m_lDate div 10000;
  currMarkDate := MinuteDateToDate(CData^.m_lDate);
  currTime := CData^.m_lDate mod 10000;

  // ȡ��������
  iTime := FTimes.ValueOf(InData.m_othData.m_Time.m_nTime);
  // ��֤�Ƿ���Ч
  if iTime <> -1 then
  begin
    // �������
    iTime := MinCountToHHMM(iTime);
    if currMarkDate = FMarkDate then
    begin // ������ͬ ???
      // ��һ��������
      if currTime < cardinal(iTime) then
      begin // ��������
        if FCount + 1 > FCapacity then
          GrowData(FCount + 1);
        CData := @FData[FCount];
        Inc(FCount);
        IsNew := True;
      end
      else if currTime > cardinal(iTime) then
      begin // �������� ��׼ȷ
        WriteDebug(Format('UpdateAutoPush_MINUTE1 currTime:%d iTime:%d', [currTime, iTime]));
        CData := nil;
      end;
    end
    else if InData.m_othData.m_Time.m_nTime = 0 then
    begin // һ��ĵ�һ������
      if FCount + 1 > FCapacity then
        GrowData(FCount + 1);
      CData := @FData[FCount];
      Inc(FCount);
      IsNew := True;
      currDate := DateToMinuteDate(FMarkDate);
      iTime := IncHHMMMin(iTime, 1); // �����ߴ�31�ֿ�ʼ
    end;
  end
  else
    CData := nil;

  if CData <> nil then
  begin
    CData^.m_lDate := currDate * 10000 + cardinal(iTime);
    UpdateATechData(CData, InData, IsNew);
    Inc(FVarCode);
  end;
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_MINUTE1(Data: Pointer; size: Integer);
var
  iTime: Integer;
  currDate, currMarkDate, currTime: UINT;
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData_Ext;
  IsNew: Boolean;
begin
  if (FTimes = nil) or (FCount = 0) then
    Exit;
  IsNew := False;

  InData := PCommRealTimeData_Ext(Data);
  // ȡ����ֵ
  CData := @FData[FCount - 1];
  currDate := CData^.m_lDate div 10000;
  currMarkDate := MinuteDateToDate(CData^.m_lDate);
  currTime := CData^.m_lDate mod 10000;

  // ȡ��������
  iTime := FTimes.ValueOf(InData.m_othData.m_Time.m_nTime);
  // ��֤�Ƿ���Ч
  if iTime <> -1 then
  begin
    // �������
    iTime := MinCountToHHMM(iTime);
    if currMarkDate = FMarkDate then
    begin // ������ͬ ???
      // ��һ��������
      if currTime < cardinal(iTime) then
      begin // ��������
        if FCount + 1 > FCapacity then
          GrowData(FCount + 1);
        CData := @FData[FCount];
        Inc(FCount);
        IsNew := True;
      end
      else if currTime > cardinal(iTime) then
      begin // �������� ��׼ȷ
        WriteDebug(Format('UpdateAutoPush_Ext_MINUTE1 currTime:%d iTime:%d', [currTime, iTime]));
        CData := nil;
      end;
    end
    else if InData.m_othData.m_Time.m_nTime = 0 then
    begin // һ��ĵ�һ������
      if FCount + 1 > FCapacity then
        GrowData(FCount + 1);
      CData := @FData[FCount];
      Inc(FCount);
      IsNew := True;
      currDate := DateToMinuteDate(FMarkDate);
      iTime := IncHHMMMin(iTime, 1); // �����ߴ�31�ֿ�ʼ
    end;
  end
  else
    CData := nil;

  if CData <> nil then
  begin
    CData^.m_lDate := currDate * 10000 + cardinal(iTime);
    UpdateATechData_Ext(CData, InData, IsNew);
    Inc(FVarCode);
  end;
end;

procedure TQuoteTechData.UpdateAutoPush_MINUTE5(Data: Pointer; size: Integer);
begin
  UpdateAutoPush_MultiMin(Data, size, 5);
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_MINUTE5(Data: Pointer; size: Integer);
begin
  UpdateAutoPush_Ext_MultiMin(Data, size, 5);
end;
{ var
  iTime, currDate, currTime: integer;
  currMarkDate:UINT;
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData;
  IsNew:Boolean;
  begin
  if (FCount > 0) and (FTimes <> nil) then begin
  InData := PCommRealTimeData(Data);
  //ȡ����ֵ
  CData := @FData[FCount -1];
  currDate := CData^.m_lDate div 10000;
  currMarkDate := MinuteDateToDate(CData^.m_lDate);
  currTime := CData^.m_lDate mod 10000;
  IsNew := False;
  //ȡ��������
  iTime := FTimes.ValueOf(InData.m_othData.m_Time.m_nTime);
  //��֤�Ƿ���Ч
  if iTime <> -1  then begin
  //�������
  if iTime mod 5 > 0 then
  iTime := iTime + (5 - iTime mod 5);
  iTime := (iTime mod (24 * 60) div 60) * 100 + iTime mod 60;
  if currMarkDate = FMarkDate then begin  //������ͬ ???
  //��һ��������
  if currTime < iTime  then begin  //��������
  if FCount+1 > FCapacity then GrowData(FCount + 1);
  CData := @FData[FCount];
  inc(FCount);
  end else if currTime > iTime then begin//�������� ��׼ȷ
  WriteDebug(Format('UpdateAutoPush_MINUTE5 currTime:%d > iTime:%d', [currTime, iTime]));
  CData := nil;
  end;
  end else if InData.m_othData.m_Time.m_nTime = 0 then begin//һ��ĵ�һ������

  if FCount+1 > FCapacity then GrowData(FCount + 1);
  CData := @FData[FCount];
  inc(FCount);

  currDate := DateToMinuteDate(FMarkDate);
  iTime := iTime + (5 - iTime mod 5);  //�����ߴ�35�ֿ�ʼ
  end;
  end else CData := nil;

  if CData <> nil then begin
  if CData^.m_lDate = 0 then begin
  CData^.m_lOpenPrice := InData^.m_cNowData.m_nowData.m_lOpen;
  CData^.m_lMinPrice  := InData^.m_cNowData.m_nowData.m_lMinPrice;
  end else begin
  CData^.m_lMinPrice  := Min(CData^.m_lMinPrice, InData^.m_cNowData.m_nowData.m_lMinPrice);
  end;

  CData^.m_lMaxPrice  := Max(CData^.m_lMaxPrice, InData^.m_cNowData.m_nowData.m_lMaxPrice);
  CData^.m_lClosePrice:= InData^.m_cNowData.m_nowData.m_lNewPrice;

  CData^.m_lDate := currDate  * 10000 + iTime;

  //û����ɽ���� ֻ�ܳ˳���
  CData^.m_lMoney     := trunc(InData^.m_cNowData.m_nowData.m_fAvgPrice * 0.001);
  CData^.m_lTotal     := InData^.m_cNowData.m_nowData.m_lTotal;

  inc(FVarCode);
  end;
  end;
  end; }

procedure TQuoteTechData.UpdateAutoPush_WEEK(Data: Pointer; size: Integer);
begin
  { TODO : ���߸��� }
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_WEEK(Data: Pointer; size: Integer);
begin

end;

procedure TQuoteTechData.UpdateAutoPush_MONTH(Data: Pointer; size: Integer);
begin
  { TODO : ���߸��� }
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_MONTH(Data: Pointer; size: Integer);
begin

end;

procedure TQuoteTechData.UpdateAutoPush_MultiMin(Data: Pointer; size, MinCount: Integer);
var
  iTime: Integer;
  currDate, currMarkDate, currTime: UINT;
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData;
  IsNew: Boolean;
begin
  if (FTimes = nil) or (FCount = 0) then
    Exit;
  IsNew := False;

  InData := PCommRealTimeData(Data);
  // ȡ����ֵ
  CData := @FData[FCount - 1];
  currDate := CData^.m_lDate div 10000;
  currMarkDate := MinuteDateToDate(CData^.m_lDate);
  currTime := CData^.m_lDate mod 10000;
  // ȡ��������
  iTime := FTimes.ValueOf(InData.m_othData.m_Time.m_nTime);
  // ��֤�Ƿ���Ч
  if iTime <> -1 then
  begin
    // �������
    iTime := MinCountToHHMM(iTime);
    if currMarkDate = FMarkDate then
    begin // ������ͬ ???
      // ��һ��������
      if currTime < cardinal(iTime) then
      begin // ��������
        if FCount + 1 > FCapacity then
          GrowData(FCount + 1);
        CData := @FData[FCount];
        Inc(FCount);
        IsNew := True;
        iTime := IncHHMMMin(iTime, MinCount);
      end
      else if currTime > cardinal(iTime) then
      begin // �������� ��׼ȷ
        WriteDebug(Format('UpdateAutoPush_MultiMin currTime:%d iTime:%d', [currTime, iTime]));
        CData := nil;
      end;
    end
    else if InData.m_othData.m_Time.m_nTime = 0 then
    begin // һ��ĵ�һ������
      if FCount + 1 > FCapacity then
        GrowData(FCount + 1);
      CData := @FData[FCount];
      Inc(FCount);
      IsNew := True;
      currDate := DateToMinuteDate(FMarkDate);
      iTime := IncHHMMMin(iTime, MinCount); // �����ߴ�31�ֿ�ʼ
    end;
  end
  else
    CData := nil;

  if CData <> nil then
  begin
    CData^.m_lDate := currDate * 10000 + cardinal(iTime);
    UpdateATechData(CData, InData, IsNew);
    Inc(FVarCode);
  end;
end;

procedure TQuoteTechData.UpdateAutoPush_Ext_MultiMin(Data: Pointer; size: Integer; MinCount: Integer);
var
  iTime: Integer;
  currDate, currMarkDate, currTime: UINT;
  CData: PStockCompDayDataEx;
  InData: PCommRealTimeData_Ext;
  IsNew: Boolean;
begin
  if (FTimes = nil) or (FCount = 0) then
    Exit;
  IsNew := False;

  InData := PCommRealTimeData_Ext(Data);
  // ȡ����ֵ
  CData := @FData[FCount - 1];
  currDate := CData^.m_lDate div 10000;
  currMarkDate := MinuteDateToDate(CData^.m_lDate);
  currTime := CData^.m_lDate mod 10000;
  // ȡ��������
  iTime := FTimes.ValueOf(InData.m_othData.m_Time.m_nTime);
  // ��֤�Ƿ���Ч
  if iTime <> -1 then
  begin
    // �������
    iTime := MinCountToHHMM(iTime);
    if currMarkDate = FMarkDate then
    begin // ������ͬ ???
      // ��һ��������
      if currTime < cardinal(iTime) then
      begin // ��������
        if FCount + 1 > FCapacity then
          GrowData(FCount + 1);
        CData := @FData[FCount];
        Inc(FCount);
        IsNew := True;
        iTime := IncHHMMMin(iTime, MinCount);
      end
      else if currTime > cardinal(iTime) then
      begin // �������� ��׼ȷ
        WriteDebug(Format('UpdateAutoPush_Ext_MultiMin currTime:%d iTime:%d', [currTime, iTime]));
        CData := nil;
      end;
    end
    else if InData.m_othData.m_Time.m_nTime = 0 then
    begin // һ��ĵ�һ������
      if FCount + 1 > FCapacity then
        GrowData(FCount + 1);
      CData := @FData[FCount];
      Inc(FCount);
      IsNew := True;
      currDate := DateToMinuteDate(FMarkDate);
      iTime := IncHHMMMin(iTime, MinCount); // �����ߴ�31�ֿ�ʼ
    end;
  end
  else
    CData := nil;

  if CData <> nil then
  begin
    CData^.m_lDate := currDate * 10000 + cardinal(iTime);
    UpdateATechData_Ext(CData, InData, IsNew);
    Inc(FVarCode);
  end;
end;

procedure TQuoteTechData.UpdateTechData(Data: Pointer; size: Integer);
begin
  // ���������ݸ��ƹ���
  if size > FCapacity then
    GrowData(size);
  FCount := size;

  Move(Data^, FData[0], FCount * SizeOf(TStockCompDayDataEx));
  FCacheDate := FMarkDate;

  Inc(FVarCode);
end;

{ TQuoteReportSort }

constructor TQuoteReportSort.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfos: PCodeInfos; count: Integer;
  ReqReportSort: PReqReportSort);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteReportSort);

  // ����������Ϣ
  FReqReportSort := ReqReportSort^;
  // �����Ʊ����
  FCount := count;
  // �����Ʊ
  SetLength(FCodeInfos, count);
  Move(CodeInfos^, FCodeInfos[0], SizeOf(TCodeInfo) * count);
end;

destructor TQuoteReportSort.Destroy;
begin
  inherited;
end;

function TQuoteReportSort.Get_Count: Integer;
begin
  result := Length(FData);
end;

function TQuoteReportSort.Get_Data: Int64;
begin
  if Length(FData) > 0 then
    result := Int64(@FData[0])
  else
    result := 0;
end;

function TQuoteReportSort.Get_SortType: Integer;
begin
  result := FReqReportSort.m_nColID;
end;

function TQuoteReportSort.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteReportSort.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_ReprotSort_Data then
    begin // ����ȫ������
      UpdateReprotSortData(Pointer(Data), size);
    end;
  finally
    EndWrite;
  end;
end;

procedure TQuoteReportSort.UpdateReprotSortData(Codes: PCodeInfos; count: Integer);
begin
  SetLength(FData, count);
  Move(Codes^, FData[0], SizeOf(TCodeInfo) * count);
  Inc(FVarCode);
end;

{ TQuoteGeneralSort }

constructor TQuoteGeneralSort.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteGeneralSort);

end;

function TQuoteGeneralSort.DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant)
  : WideString;
begin
  BeginRead;
  try
    IValue := 0;
    SValue := '';
    VValue := 0;
    if State = State_GeneralSort_RefCount then
    begin
      IValue := 0;
    end;
  finally
    EndRead;
  end;

end;

destructor TQuoteGeneralSort.Destroy;
begin
  FData := nil;
  inherited Destroy;
end;

function TQuoteGeneralSort.Get_Count: Integer;
begin
  result := Length(FData);
end;

function TQuoteGeneralSort.Get_Data: Int64;
begin
  if Length(FData) > 0 then
    result := Int64(@FData[0])
  else
    result := 0
end;

function TQuoteGeneralSort.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteGeneralSort.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_GeneralSort_ReqGeneralSort then
      UpdateReqGeneralSort(PReqGeneralSortEx(Data))
    else if DataType = Update_GeneralSort_Data then
      UpdateGeneralSortData(PAnsGeneralSortEx(Data))
  finally
    EndWrite;
  end;
end;

procedure TQuoteGeneralSort.UpdateGeneralSortData(AnsGeneralSortEx: PAnsGeneralSortEx);
begin
  if Length(FData) < AnsGeneralSortEx.m_nSize * FTypeCount then
    SetLength(FData, AnsGeneralSortEx.m_nSize * FTypeCount);
  Move(AnsGeneralSortEx^.m_prptData[0], FData[0], SizeOf(TGeneralSortData) * AnsGeneralSortEx.m_nSize * FTypeCount);
end;

procedure TQuoteGeneralSort.UpdateReqGeneralSort(ReqGeneralSort: PReqGeneralSortEx);
  function GetTypeCount(SortType: Integer): Integer;
  begin
    result := 0;
    while SortType > 0 do
    begin
      Inc(result, SortType and 1);
      SortType := SortType shr 1;
    end;
  end;

begin
  if (FReqGeneralSort.m_cCodeType <> ReqGeneralSort^.m_cCodeType) or
    (FReqGeneralSort.m_nRetCount <> ReqGeneralSort^.m_nRetCount) or
    (FReqGeneralSort.m_nSortType <> ReqGeneralSort^.m_nSortType) or
    (FReqGeneralSort.m_nMinuteCount <> ReqGeneralSort^.m_nMinuteCount) then
  begin

    FReqGeneralSort := ReqGeneralSort^;
    // ���
    SetLength(FData, 0);
    FTypeCount := GetTypeCount(ReqGeneralSort.m_nSortType);
    // ��ʼ�����ݸ��� ���ظ���  * 9
    SetLength(FData, FReqGeneralSort.m_nRetCount * FTypeCount);

    Inc(FVarCode);
  end;
end;

{ TQuoteLevelTransaction }

constructor TQuoteLevelTransaction.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteLevelTransaction);
  FCodeInfo := CodeInfo^;
end;

destructor TQuoteLevelTransaction.Destroy;
begin
  SetLength(FData, 0);
  inherited;
end;

function TQuoteLevelTransaction.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteLevelTransaction.Get_Count: Integer;
begin
  result := FCount;
end;

function TQuoteLevelTransaction.Get_Datas: Int64;
begin
  if FCount > 0 then
    result := Int64(@FData[0])
  else
    result := 0;
end;

function TQuoteLevelTransaction.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteLevelTransaction.GrowData(count: Integer);
begin
  if count >= FCapacity then
  begin
    FCapacity := count + 120;
    SetLength(FData, FCapacity);
  end;
end;

procedure TQuoteLevelTransaction.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_Transaction_Data then
    begin // �����ֱ�����
      UpdateTransactionData(Pointer(Data), size);
    end
    else if DataType = Update_TransactionAuto_Data then
    begin
      UpdateAutoPush(Pointer(Data), size);
    end;
  finally
    EndWrite;
  end;
end;

procedure TQuoteLevelTransaction.UpdateAutoPush(Data: Pointer; size: Integer);
begin
  if (FCount + size) > FCapacity then
    GrowData(FCount + size);
  // ��ֵ
  Move(Data^, FData[FCount], size * SizeOf(TStockTransaction));
  Inc(FCount, size);
  Inc(FVarCode);
end;

procedure TQuoteLevelTransaction.UpdateTransactionData(Data: Pointer; size: Integer);
begin
  if FCount + size > FCapacity then
    GrowData(FCount + size);
  // ��ֵ
  Move(Data^, FData[FCount], size * SizeOf(TStockTransaction));
  FCount := size;
  Inc(FVarCode);
end;

{ TQuoteLevelOrderQueue }

constructor TQuoteLevelOrderQueue.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteLevelOrderQueue);

  FCodeInfo := CodeInfo^;
end;

destructor TQuoteLevelOrderQueue.Destroy;
begin
  if FBuyOrderQueue <> nil then
  begin
    FreeMemEx(FBuyOrderQueue);
    FBuyOrderQueue := nil;
  end;

  if FSellOrderQueue <> nil then
  begin
    FreeMemEx(FSellOrderQueue);
    FSellOrderQueue := nil;
  end;
  inherited;
end;

function TQuoteLevelOrderQueue.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteLevelOrderQueue.Get_SellData: Int64;
begin
  if FSellOrderQueue <> nil then
    result := Int64(FSellOrderQueue)
  else
    result := 0;
end;

function TQuoteLevelOrderQueue.Get_BuyData: Int64;
begin
  if FBuyOrderQueue <> nil then
    result := Int64(FBuyOrderQueue)
  else
    result := 0;
end;

function TQuoteLevelOrderQueue.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteLevelOrderQueue.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  BeginWrite;
  try
    if DataType = Update_OrderQueue_Data then
    begin // �����ֱ�����
      UpdateOrderQueueData(Pointer(Data), size);
      // end else if DataType = Update_Trend_AutoPush then begin
      // UpdateAutoPush(Pointer(Data), size);
    end;
  finally
    EndWrite;
  end;
end;

// procedure TQuoteLevelOrderQueue.UpdateAutoPush(Data: Pointer; size: integer);
// begin
//
// end;

procedure TQuoteLevelOrderQueue.UpdateOrderQueueData(Data: Pointer; size: Integer);
var
  POrderQueue: PLevelOrderQueue;
  W: Integer;
begin
  POrderQueue := PLevelOrderQueue(Data);
  W := SizeOf(TLevelOrderQueue) + POrderQueue.m_noOrders * SizeOf(LongInt) - SizeOf(Integer);
  if POrderQueue^.m_Side = '1' then
  begin
    if FBuyOrderQueue <> nil then
      FreeMemEx(FBuyOrderQueue);

    GetMemEx(Pointer(FBuyOrderQueue), W);
    Move(POrderQueue^, FBuyOrderQueue^, W);
  end
  else if POrderQueue^.m_Side = '2' then
  begin
    if FSellOrderQueue <> nil then
      FreeMemEx(FSellOrderQueue);

    GetMemEx(Pointer(FSellOrderQueue), W);
    Move(POrderQueue^, FSellOrderQueue^, W);
  end;
end;

{ TQuoteLevelTOTALMAX }

constructor TQuoteLevelTOTALMAX.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteLevelTOTALMAX);

  FCodeInfo := CodeInfo^;
end;

destructor TQuoteLevelTOTALMAX.Destroy;
begin
  inherited;
end;

function TQuoteLevelTOTALMAX.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteLevelTOTALMAX.Get_Count: Integer;
begin

end;

function TQuoteLevelTOTALMAX.Get_Datas: Int64;
begin
  //
end;

function TQuoteLevelTOTALMAX.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteLevelTOTALMAX.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  if DataType = Update_TOTALMAX_Data then
    UpdateTOTALMAXData(Pointer(Data), size)
  else if DataType = Update_TOTALMAXAuto_Data then
    UpdateAutoPush(Pointer(Data), size);
end;

procedure TQuoteLevelTOTALMAX.UpdateAutoPush(Data: Pointer; size: Integer);
begin

end;

procedure TQuoteLevelTOTALMAX.UpdateTOTALMAXData(Data: Pointer; size: Integer);
begin

end;

{ TQuoteLevelSINGLEMA }

constructor TQuoteLevelSINGLEMA.Create(QuoteDataMngr: TQuoteDataMngr; CodeInfo: PCodeInfo);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteLevelSINGLEMA);

  FCodeInfo := CodeInfo^;
end;

destructor TQuoteLevelSINGLEMA.Destroy;
begin

  inherited;
end;

function TQuoteLevelSINGLEMA.Get_CodeInfo: Int64;
begin
  result := Int64(@FCodeInfo);
end;

function TQuoteLevelSINGLEMA.Get_Count: Integer;
begin

end;

function TQuoteLevelSINGLEMA.Get_Datas: Int64;
begin

end;

function TQuoteLevelSINGLEMA.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteLevelSINGLEMA.Update(DataType: Integer; Data: Int64; size: Integer);
begin
  if DataType = Update_SINGLEMA_Data then
    UpdateSINGLEMAData(Pointer(Data), size)
  else if DataType = Update_SINGLEMAAuto_Data then
    UpdateAutoPush(Pointer(Data), size);
end;

procedure TQuoteLevelSINGLEMA.UpdateAutoPush(Data: Pointer; size: Integer);
begin

end;

procedure TQuoteLevelSINGLEMA.UpdateSINGLEMAData(Data: Pointer; size: Integer);
// var
// SINGLEMAData: POrderCancelRanking;
begin
  // SINGLEMAData := POrderCancelRanking(Data);
end;

{ THisQuoteTrend }

procedure THisQuoteTrend.ResetDate(ADate: Integer);
begin
  if ADate = FDate then
    Exit;
  FDate := ADate;
  FCount := 0;
  GetPrevCose();
  ZeroMemory(@FData[0], Length(FData) * SizeOf(TTrendDataUnion));
end;

procedure THisQuoteTrend.GetPrevCose;
begin
  // inherited;
  FTrendInfo.PrevClose := 0;
end;


initialization

G_StringList := TStringList.Create;

finalization

G_StringList.Free;

end.
