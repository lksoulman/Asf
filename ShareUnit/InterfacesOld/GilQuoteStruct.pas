unit GilQuoteStruct;

interface

uses sysutils, QuoteStruct, QuoteConst, ansistrings, windows;

type
  // �����ж�֤ȯʹ��TShareRealTimeData�ṹ���е��ĸ��ṹ.
  TRealTime_Secu_Category = (rscSTOCK, // ����֤ȯ
    rscBSTOCKSH,  //��֤B��
    rscBSTOCKSZ, //��֤B��
    rscINDEX, // ָ��
    rscHKSTOCK, // �۹�
    rscFinFUTURES, //�����ڻ�
    rscFUTURES, // �ڻ�
    rscOPTION, // ��Ȩ
    rscIB, // ���м�֤ȯ
    rscFX, // ���
    rscUS, // ����
    rscTHREEBOAD // ������
    );

  PStockInfo = ^TStockInfo;

  TStockInfo = packed record
    Stock: TStockInitInfo;
    FinanceIndex: integer;
    ExRightIndex: integer;
    RightCount: WORD;
  end;

  PLimitPrice = ^TLimitPrice;

  TLimitPrice = packed record
    MaxUpPrice: single;
    MinDownPrice: single;
  end;

  TStockInfos = array [0 .. MaxCount] of TStockInfo;
  PStockInfos = ^TStockInfos;

  TCommonTrendData = packed record
    Price: LongInt;
    AvgPrice: single;
    Money: single;
    Vol: UInt32;
  end;

  TIndexTrendData = packed record
    Price: LongInt;
    AdvPrice: LongInt;
    Money: single;
    Vol: UInt32;
    RiseTrend: short; // ��������
    FallTrend: short; // �µ�����
    RiseCount: short; // ���Ǽ���
    FallCount: short; // �µ�����
    // SameCount:short; //ƽ�̼���
    // Alignment:short; //Ԥ�� ����
  end;

  TETFTrendData = packed record
    Price: LongInt;
    AvgPrice: LongInt;
    Money: single;
    Vol: UInt32;
    IPOV: LongInt;
  end;

  PTrendDataUnion = ^TTrendDataUnion;

  TTrendDataUnion = packed record
    case integer of
      0:
        (CommonTrendData: TCommonTrendData);
      1:
        (IndexTrendData: TIndexTrendData);
      2:
        (ETFTrendData: TETFTrendData);
  end;

  PTrendInfo = ^TTrendInfo;

  TTrendInfo = packed record
    StopFlag: LongInt; // 0���� 1ͣ��
    PrevClose: LongInt;
    TradeDate: LongInt;
  end;

  TQuoteCommExtData = packed record
    case integer of
      0:
        (m_StockExt: THSStockRealTimeOther); // ��Ʊ
      1:
        (m_HKStockExt: THKBSOrder); // �۹�
      2:
        (m_IndexExt: THSIndexRealTimeOther); // ָ��
  end;

  PQuoteRealTimeData = ^TQuoteRealTimeData;

  TQuoteRealTimeData = packed record
    StockInitInfo: PStockInitInfo;
    FinanceInfo: PFinanceInfo;
    m_othData: TStockOtherData; // ʵʱ��������
    // Level
    // m_LevelothData: TLevelStockOtherData; // ʵʱ��������
    // m_LevelcNowData: TLevelRealTime;      //
    VarCode: integer;
    CommExtData: TQuoteCommExtData; // ��Ʊ,�۹�,ָ����Ч(�۹���ʱΪ��)
    case integer of
      0:
        (m_cNowData: TShareRealTimeData); // ָ��ShareRealTimeData������һ��
      1:
        (m_cOPTNowData: THSOPTRealTime);
  end;

  PQuoteL2RealTimeData = ^TQuoteL2RealTimeData;

  TQuoteL2RealTimeData = packed record
    // Level
    m_LevelothData: TLevelStockOtherData; // ʵʱ��������
    m_LevelcNowData: TLevelRealTime; //
    VarCode: integer;
  end;

  // IQuoteColValue��Datas���صĽṹָ��
  PGilQuoteColValues = ^TGilQuoteColValues;

  TGilQuoteColValues = packed record
    m_CodeInfo: TCodeInfo;
    case integer of
      0:
        (IntValue: integer);
      1:
        (UIntValue: UInt);
      2:
        (SingleValue: single);
      3:
        (DoubleValue: Double);
      4:
        (Int64Value: Int64);
      5:
        (UInt64Value: UInt64);
  end;

  PGilQuoteColValue32 = ^TGilQuoteColValue32;

  TGilQuoteColValue32 = packed record
    m_CodeInfo: TCodeInfo;
    m_Value: integer;
  end;

  PGilQuoteColValue64 = ^TGilQuoteColValue64;

  TGilQuoteColValue64 = packed record
    m_CodeInfo: TCodeInfo;
    m_Value: Int64;
  end;

  PDDERealtimeData = ^TDDERealtimeData;

  TDDERealtimeData = packed record
    VarCode: integer;
    DDEBigOrderData: THDATradeClassifyData; // ������������ QuoteType_DDEBigOrderRealTimeByOrder ����õ�
  end;

Function GetRealTimeSC(Codeinfo: PcodeInfo): TRealTime_Secu_Category;
function GetSharesPerHand(Codeinfo: PcodeInfo; QuoteRealTimeData: PQuoteRealTimeData): LongInt;

implementation

Function GetRealTimeSC(Codeinfo: PcodeInfo): TRealTime_Secu_Category;
begin
  if HSMarketType(Codeinfo.m_cCodeType, OTHER_MARKET) then // ָ��
    Result := rscINDEX
  else if HSMarketType(Codeinfo.m_cCodeType, HK_MARKET) then // ���
    Result := rscHKSTOCK
  else if HSMarketType(Codeinfo.m_cCodeType, OPT_MARKET) then // ������Ȩ
    Result := rscOPTION
  else if HSMarketType(Codeinfo.m_cCodeType, FUTURES_MARKET) then // �ڻ�
    Result := rscFUTURES
  else if HSMarketType(Codeinfo.m_cCodeType, US_MARKET) then // ����
    Result := rscUS
  else if HSMarketType(Codeinfo.m_cCodeType, FOREIGN_MARKET) then
  begin
    if HSBourseType(Codeinfo.m_cCodeType, YHJZQ_BOURSE) or // ���м�
      HSBourseType(Codeinfo.m_cCodeType, XHCJ_BOURSE) or HSBourseType(Codeinfo.m_cCodeType, ZYSHG_BOURSE) or
      HSBourseType(Codeinfo.m_cCodeType, MDSHG_BOURSE) then

      Result := rscIB
    else // ���
      Result := rscFX;
  end
  else
  begin
    if HSKindType(Codeinfo.m_cCodeType, KIND_INDEX) then // ָ��
      Result := rscINDEX
    else if HSKindType(Codeinfo.m_cCodeType, KIND_THREEBOAD) then  // ����
      Result := rscTHREEBOAD
    else// A B ��
      Result := rscSTOCK;
  end;
end;

function GetSharesPerHand(Codeinfo: PcodeInfo; QuoteRealTimeData: PQuoteRealTimeData): LongInt;
begin
  Result := 1;
  case GetRealTimeSC(Codeinfo) of
    rscSTOCK:
      Result := QuoteRealTimeData.m_cNowData.m_nowData.m_nHand; // ����֤ȯ
    rscINDEX:
      Result := QuoteRealTimeData.m_cNowData.m_indData.m_nHand; // ָ��
    rscHKSTOCK:
      Result := QuoteRealTimeData.m_cNowData.m_hkData.m_lHand; // �۹�
    rscFUTURES:
      Result := QuoteRealTimeData.m_cNowData.m_qhData.m_nHand; // �ڻ�
    rscOPTION:
      Result := QuoteRealTimeData.m_cOPTNowData.m_nHand; // ��Ȩ
    rscIB:
      Result := 1; // ���м�֤ȯ
    rscFX:
      Result := 1; // ���
    rscUS:
      Result := QuoteRealTimeData.m_cNowData.m_USData.m_nHand;
    rscTHREEBOAD:
      Result := QuoteRealTimeData.m_cNowData.m_nowData.m_nHand; // ����֤ȯ
  end;
  if Result = 0 then
    Result := 1;
end;

end.
