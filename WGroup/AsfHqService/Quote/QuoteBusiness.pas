unit QuoteBusiness;

interface

uses Windows, Classes, SysUtils, QuoteService, QuoteConst, QuoteStruct, QuoteStructInt64,
  IOCPMemory, QDOMarketMonitor, QDOSingleColValue, QDODDERealTime,
  QuoteLibrary, IniFiles, QuoteDataMngr, QuoteMngr_TLB, BizPacket2Impl;

type
  TOnActiveMessage = procedure(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64) of object;
  TOnActiveMessageCookie = procedure(SendType: QuoteTypeEnum; Cookie: integer) of object;
  TOnResetMessage = procedure(ServerType: ServerTypeEnum) of object;

  // ҵ������������
  TQuoteBusiness = class
  private
    FQuoteService: TQuoteService;
    FQuoteDataMngr: TQuoteDataMngr;

    FOnActiveMessage: TOnActiveMessage;
    FOnResetMessage: TOnResetMessage;
    FOnActiveMessageCookie: TOnActiveMessageCookie;

    FIsInitial: boolean;

    procedure WriteFile(const FileName: string; buff: Pointer; Size: integer);
    procedure ReadFile(const FileName: string; var buff: Pointer; var Size: integer);
    procedure DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64);
    procedure DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
    procedure DoResetMessage(ServerType: ServerTypeEnum);
    procedure UpdateCommRealTime(CommRealTimeData: PCommRealTimeData; Count: integer; Codes: PCodeInfos);

    // ʵʱ
    procedure UpdateCommRealTime_EXT(CommRealTimeData_Ext: PCommRealTimeData_Ext; Count: integer; Codes: PCodeInfos);
    procedure UpdateCommRealTime_Int64EXT(CommRealTimeData_Ext: PCommRealTimeInt64Data_Ext; Count: integer; Codes: PCodeInfos);

    procedure UpdateCommLevelRealTime(RealTimeDataLevel: PRealTimeDataLevel; Count: integer; Codes: PCodeInfos);

    function GetAskData(p: PCodeInfo): PAskData;
    function GetCodeInfos(p: PCodeInfo; Count: integer): PCodeInfo;
    function GetKeyIndex(p: PCodeInfo): integer;
  public
    constructor Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy; override;

    // ���߳� ���� ����ҵ���֧
    procedure DoHandleBusiness(pData: Pointer; Size: integer);
    // ���ݵ���֪ͨ�¼�
    property OnActiveMessage: TOnActiveMessage read FOnActiveMessage write FOnActiveMessage;
    // ��ʼ��֪ͨ�¼�
    property OnResetMessage: TOnResetMessage read FOnResetMessage write FOnResetMessage;
    property OnActiveMessageCookie: TOnActiveMessageCookie read FOnActiveMessageCookie write FOnActiveMessageCookie;
    // ��վ��Ϣ
    procedure AnsServerInfo(AnsServerInfo: PAnsServerInfo);

    // �û��ڻ���½ ����
    procedure ReqFutuesUserLogin;
    // �û���½ Ӧ��
    procedure AnsFutuesUserLogin(AnsLogin: PAnsLogin);

    // �û��۹ɵ�½ ����
    procedure ReqHKUserLogin;
    // �û���½ Ӧ��
    procedure AnsHKUserLogin(AnsLogin: PAnsLogin);
    // �û���½ ����
    procedure ReqUserLogin;
    // �û���½ Ӧ��
    procedure AnsUserLogin(AnsLogin: PAnsLogin);
    // DDE��½����
    procedure ReqDDEUserLogin();
    // DDE��½Ӧ��
    procedure AnsDDEUserLogin(AnsLogin: PAnsLogin);
    // ���ɵ�½����
    procedure ReqUSStockUserLogin();
    // ���ɵ�½Ӧ��
    procedure AnsUSStockUserLogin(AnsLogin: PAnsLogin);

    // ����ͨ�� ����
    procedure ReqKeepActive(ServerType: ServerTypeEnum);
    // ����ͨ�� Ӧ��
    procedure AnsKeepActive(AnsTestSrvData: PTestSrvData);

    // ��ʼ����վ��Ϣ ����
    procedure ReqInitialInfo(ServerType: ServerTypeEnum);
    // ��ʼ����վ��Ϣ Ӧ��
    procedure AnsInitialInfo(AnsInitialData: PAnsInitialData);

    // ���µĲ������� ����
    procedure ReqCurrentFinance;
    // ���µĲ������� Ӧ��
    procedure AnsCurrentFinance(AnsTextData: PAnsTextData);

    // ���µĲ������� �ļ�����
    procedure LoadCurrentFinance; overload;
    // ���µĲ������� �ڴ�����
    procedure LoadCurrentFinance(Data: Pointer; Size: integer); overload;

    // ��Ȩ���� ����
    procedure ReqExRightData;
    // ��Ȩ���� Ӧ��
    procedure AnsExRightData(AnsTextData: PAnsTextData); overload;

    // ��Ȩ���� �ļ�����
    procedure LoadExRight; overload;
    // ��Ȩ���� �ڴ�����
    procedure LoadExRight(Data: Pointer; Size: integer); overload;

    // ������� ����
    procedure ReqBlockData(ServerType: ServerTypeEnum);
    // ������� Ӧ��
    procedure AnsBlockData(AnsTextData: PAnsTextData);

    procedure LoadBlockData;

    // ������  ����
    procedure ReqRealTime(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // ������  Ӧ��
    procedure AnsRealTime(AnsRealTime: PAnsRealTime);

    // ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)  ����
    procedure ReqRealTime_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)   Ӧ��
    procedure AnsRealTime_Ext(AnsRealTime_Ext: PAnsRealTime_Ext);

    // 64λ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)  ����
    procedure ReqRealTime_Int64Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 64λ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)   Ӧ��
    procedure AnsRealTime_Int64Ext(AnsRealTime_Ext: PAnsRealTime_EXT_INT64);

    // ʵʱ����  ����
    procedure ReqAutoPush(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // ʵʱ����  Ӧ��
    procedure AnsAutoPush(AnsRealTime: PAnsRealTime);

    // ʵʱ������չ  ����
    procedure ReqAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // ʵʱ������չ  Ӧ��
    procedure AnsAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);

    // 64λ����Э��ʵʱ������չ  ����
    procedure ReqAutoPush_Int64Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 64λ����Э��ʵʱ������չ  Ӧ��
    procedure AnsAutoPush_Int64Ext(AnsRealTime: PAnsRealTime_EXT_INT64);

    // ��ʱ������չ  ����
    procedure ReqDelayAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // ��ʱ������չ  Ӧ��
    procedure AnsDelayAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);

    // ���ɷ�ʱ  ����
    procedure ReqTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���ɷ�ʱ  Ӧ��
    procedure AnsTrend(AnsTrendData: PAnsTrendData);

    // ���ɷ�ʱ  ����
    procedure ReqTrend_Ext(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���ɷ�ʱ  Ӧ��
    procedure AnsTrend_Ext(AnsTrendData: PAnsTrendData_Ext);

    // ---------------------����ָ�����-------------------------------------------
    // ָ�����ȷ�ʱ  ����
    procedure ReqMILeadData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ָ�����ȷ�ʱ  Ӧ��
    procedure AnsMILeadData(AnsLeadData: PAnsLeadData);
    // ָ����ʱ  ����
    procedure ReqMITickData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ָ����ʱ  Ӧ��
    procedure AnsMITickData(AnsMajorIndexTick: PAnsMajorIndexTick);

    // ������ʷ��ʱ  ����
    procedure ReqHisTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Date, key: LongInt);
    // ������ʷ��ʱ  Ӧ��
    procedure AnsHisTrend(AnsHisTrend: PAnsHisTrend);

    // ���ɼ��Ͼ������� ����
    procedure ReqVirtualAuction(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���ɼ��Ͼ������� Ӧ��
    procedure AnsVirtualAuction(AnsVirtualAuction: PAnsVirtualAuction);

    // ���ɷֱ�  ����
    procedure ReqStockTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���ɷֱ�  Ӧ��
    procedure AnsStockTick(AnsStockTick: PAnsStockTick);

    // ָ������ ���ɷֱ�  ����
    procedure ReqLimitTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Limit: Word);
    // ָ������  ���ɷֱ�  Ӧ��
    procedure AnsLimitTick(AnsStockTick: PAnsStockTick);

    // �̺�������� ����
    procedure ReqTechData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate; Period: short;
      nDay: Word);
    // �̺�������� Ӧ��
    procedure AnsTechData(AnsDayDataEx: PAnsDayDataEx);
    // �ǵ�ͣ���� ����
    procedure ReqSeverCalculate(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // �ǵ�ͣ���� Ӧ��
    procedure AnsSeverCalculate(AnsSeverCalculate: PAnsSeverCalculate);
    // ������ ���� ����
    procedure ReqPeportSort(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer; Cookie: integer;
      ReqReportSort: PReqReportSort);
    // ������ ���� Ӧ��
    procedure AnsPeportSort(AnsReportData: PAnsReportData);

    // �ۺ����� ����
    procedure ReqGeneralSortEx(ServerType: ServerTypeEnum; Cookie: integer; GeneralSortEx: PReqGeneralSortEx);
    // �ۺ����� Ӧ��
    procedure AnsGeneralSortEx(AnsGeneralSortEx: PAnsGeneralSortEx);

    // procedure ReqMarketEvent(ServerType: ServerTypeEnum;Cookie: integer);
    // procedure AnsMaretEvent(AnsMarketEvent:PAnsMarketEvent);
    procedure ReqMarketEventAutoPush(ServerType: ServerTypeEnum);
    procedure AnsMaretEventAutoPush(AnsMarketEvent: PAnsMarketEvent);

    // -- Level2

    // �û���½level2 ����
    procedure ReqLevelUserLogin;
    // �û���½level2 Ӧ��
    procedure AnsLevelUserLogin(AnsLogin: PAnsLogin);

    // Level2ʮ������  ����
    procedure ReqLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
    // Level2ʮ������   Ӧ��
    procedure AnsLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);

    // ʵʱ���� Level2  ����
    procedure ReqAutoPushLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
    // ʵʱ����  Level2 Ӧ��
    procedure AnsAutoPushLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);

    // Level2 ��ʳɽ�  ����
    procedure ReqLevelTransaction(CodeInfo: PCodeInfo; nSize, nPostion: integer);

    procedure AnsLevelTransaction(LevelTransaction: PAnsLevelTransaction);

    // ʵʱ���� Level2  ��ʳɽ�  ����
    procedure ReqAutoPushLevelTransaction(CodeInfos: PCodeInfos; Count: integer);
    // ʵʱ����  Level2 ��ʳɽ�  Ӧ��
    procedure AnsAutoPushLevelTransaction(LevelTransactionAuto: PAnsLevelTransactionAuto);

    // Level2 �̿�����  ����
    procedure ReqLevelOrderQueue(CodeInfo: PCodeInfo; direct: AnsiChar);
    // Level2 �̿�����   Ӧ��
    procedure AnsLevelOrderQueue(QueryOrderQueue: PAnsQueryOrderQueue);

    // ʵʱ���� Level2  �̿�����  ����
    procedure ReqAutoPushLevelOrderQueue(CodeInfos: PCodeInfos; Count: integer; direct: AnsiChar);

    // ʵʱ����  Level2 �̿�����  Ӧ��
    procedure AnsAutoPushLevelOrderQueue(LevelOrderQueueAuto: PAnsLevelOrderQueueAuto);

    // LEVEL2���ʳ�����������  LEVEL2�ۼƳ�����������
    procedure ReqLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
    procedure AnsLevelCancelSINGLEMA(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
    procedure AnsLevelCancelTOTALMAX(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);

    procedure ReqAutoPushLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);

    // ���Ķ��߾�������
    procedure ReqAutoPushMarketEvent(ServerType: ServerTypeEnum);

    procedure AnsAutoPushMarketEvent(pData: PAnsMarketEvent);
    // ���ĵ���������������
    procedure ReqSingleHQColValue(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count, ColCode: UInt;
      Cookie: integer);
    procedure AnsSingleHQColValue(pData: PAnsHQColValue);

    // ������������
    // ��������
    procedure ReqHDA_TradeClassify_ByOrder(CodeInfo: PCodeInfo; Count, ClassifyView: integer);
    procedure AnsHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
    // �������� ����
    procedure ReqAutoPushHDA_TradeClassify_ByOrder(CodeInfos: PCodeInfos; ClassifyView: integer; Count: integer);
    procedure AnsAutoPushHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);

    // ���м�ծȯ  ��½����
    procedure ReqForeignUserLogin;
    // ���м�ծȯ ��½Ӧ��
    procedure AnsForeignUserLogin(AnsLogin: PAnsLogin);

    // ���м�ծȯ  ��ʱ����
    procedure ReqIBTREND(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���м�ծȯ ��ʱӦ��
    procedure AnsIBTREND(AnsIBTrendData: PAnsIBTrendData);

    // ���м�ծȯ  ��������
    procedure ReqForeignTRANS(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // ���м�ծȯ ��������Ӧ��              ReqIBTrans
    procedure AnsForeignTRANS(AnsIBTransData: PAnsIBTransData);

    // ���м�ծȯ  K������
    procedure ReqForeignTECHDATA(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate; Period: short;
      nDay: Word);
    procedure AnsForeignTECHDATA(AnsIBTechData: PAnsIBTechData);

    // ���м�ծȯ ������Ϣ
    procedure ReqForeignBASEINFO(ServerType: ServerTypeEnum);
    procedure AnsForeignBASEINFO(AnsIBBondBaseInfoData: PAnsIBBondBaseInfoData);
  end;

function PeriodToQuoteType(Period: ULONG): QuoteTypeEnum;

implementation

function PeriodToQuoteType(Period: ULONG): QuoteTypeEnum;
begin
  case Period of
    PERIOD_TYPE_MINUTE1:
      Result := QuoteType_TECHDATA_MINUTE1; // �������ڣ�1����
    PERIOD_TYPE_MINUTE5:
      Result := QuoteType_TECHDATA_MINUTE5; // �������ڣ�5����
    PERIOD_TYPE_MINUTE15:
      Result := QuoteType_TECHDATA_MINUTE15;
    PERIOD_TYPE_MINUTE30:
      Result := QuoteType_TECHDATA_MINUTE30;
    PERIOD_TYPE_MINUTE60:
      Result := QuoteType_TECHDATA_MINUTE60;
    // PERIOD_TYPE_WEEK: Result := QuoteType_TECHDATA_WEEK;
    // PERIOD_TYPE_MONTH: Result := QuoteType_TECHDATA_MONTH;
  else
    Result := QuoteType_TECHDATA_DAY;
  end;
end;
{ TQuoteBusiness }

constructor TQuoteBusiness.Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr);
begin
  FQuoteService := QuoteService;
  FQuoteDataMngr := QuoteDataMngr;
end;

destructor TQuoteBusiness.Destroy;
begin
  inherited Destroy;
end;

function TQuoteBusiness.GetAskData(p: PCodeInfo): PAskData;
begin
  // Result := GetMemory();
  GetMemEx(Pointer(Result), SizeOf(TAskData));
  FillMemory(Pointer(Result), SizeOf(TAskData), 0);
  if p <> nil then
    Result.m_nPrivateKey.m_pCode := p^;
end;

function TQuoteBusiness.GetCodeInfos(p: PCodeInfo; Count: integer): PCodeInfo;
var
  len: Cardinal;
begin
  len := SizeOf(TCodeInfo) * Count;
  GetMemEx(Pointer(Result), len);
  CopyMemory(Result, p, len);
end;

function TQuoteBusiness.GetKeyIndex(p: PCodeInfo): integer;
begin
  // Result := -1;
  Result := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[p.m_cCodeType, CodeInfoToCode(p)];
end;

procedure TQuoteBusiness.DoHandleBusiness(pData: Pointer; Size: integer);
var
  pHead: PDataHead;
begin
  pHead := PDataHead(pData);
  // ��ʱ����2�౨��
  case pHead^.m_nType of
    RT_INITIALINFO:
      begin // ��ʼ���г���Ϣ
        // ע��,��ʼ����Ϣ,(�������9:00���һ�ֱ��Ͷ���)
        AnsInitialInfo(PAnsInitialData(pHead));
      end;
    RT_LOGIN:
      begin // �û���½
        AnsUserLogin(PAnsLogin(pHead));
      end;
    RT_Login_DDE:
      begin
        AnsDDEUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_US:
      begin
        AnsUSStockUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_FUTURES:
      begin // �û���½
        AnsFutuesUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_HK:
      begin
        AnsHKUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_FOREIGN:
      AnsForeignUserLogin(PAnsLogin(pHead));
    RT_SERVERINFO:
      AnsServerInfo(PAnsServerInfo(pHead));
    RT_SEVER_CALCULATE:
      AnsSeverCalculate(PAnsSeverCalculate(pHead));
    RT_LOGIN_LEVEL, RT_DISCONNLEVEL2:
      begin
        AnsLevelUserLogin(PAnsLogin(pHead));
      end;

    RT_CURRENTFINANCEDATA or $0010:
      begin // ���²�������
        AnsCurrentFinance(PAnsTextData(pHead));
      end;
    RT_EXRIGHT_DATA or $0010:
      begin // ��Ȩ����
        AnsExRightData(PAnsTextData(pHead));
      end;
    RT_BLOCK_DATA:
      begin // �������
        AnsBlockData(PAnsTextData(pHead));
      end;
    RT_REALTIME:
      begin // ��������
        AnsRealTime(PAnsRealTime(pHead));
      end;
    RT_REALTIME_EXT: // ��չ ��������
      begin
        AnsRealTime_Ext(PAnsRealTime_Ext(pHead));
      end;
    RT_REALTIME_EXT_INT64:  // 64λ��չ ��������
      begin
        AnsRealTime_Int64Ext(PAnsRealTime_EXT_INT64(pHead));
      end;
    RT_AUTOPUSH:
      begin // ʵʱ����
        AnsAutoPush(PAnsRealTime(pHead));
      end;
    RT_AUTOPUSH_EXT: // ��չ����
      AnsAutoPush_Ext(PAnsRealTime_Ext(pHead));
    RT_AUTOPUSH_EXT_INT64: // ��չ����64λ
      AnsAutoPush_Int64Ext(PAnsRealTime_EXT_INT64(pHead));
    RT_AUTOPUSH_EXT_DELAY:
      AnsDelayAutoPush_Ext(PAnsRealTime_Ext(pHead));
    RT_TESTSRV:
      begin // ����
        AnsKeepActive(PTestSrvData(pHead));
      end;
    RT_TREND:
      begin // ��ʱ����
        AnsTrend(PAnsTrendData(pHead));
      end;
    RT_TREND_EXT:
      begin // ��ʱ����
        AnsTrend_Ext(PAnsTrendData_Ext(pHead));
      end;
    RT_HISTREND:
      begin
        AnsHisTrend(PAnsHisTrend(pHead));
      end;
    RT_MAJORINDEXTICK:
      AnsMITickData(PAnsMajorIndexTick(pHead));
    RT_LEAD:
      AnsMILeadData(PAnsLeadData(pHead));
    RT_VIRTUAL_AUCTION:
      AnsVirtualAuction(PAnsVirtualAuction(pHead)); // ���Ͼ��۷�ʱ����
    RT_MARKET_MONITOR_AUTOPUSH:
      AnsAutoPushMarketEvent(PAnsMarketEvent(pHead)); // ���߾�������
    RT_HQCOL_VALUE:
      AnsSingleHQColValue(PAnsHQColValue(pHead)); // ȡ������������
    RT_STOCKTICK:
      begin // ���ɷֱ�
        AnsStockTick(PAnsStockTick(pHead));
      end;
    RT_LIMITTICK:
      begin // ���Ƹ��� ȡ���ɷֱ�
        AnsLimitTick(PAnsStockTick(pHead));
      end;
    RT_TECHDATA, RT_TECHDATA_EX:
      begin // ȡ�̺����
        AnsTechData(PAnsDayDataEx(pHead));
      end;
    RT_REPORTSORT:
      begin
        AnsPeportSort(PAnsReportData(pHead));
      end;
    RT_GENERALSORT_EX:
      begin
        AnsGeneralSortEx(PAnsGeneralSortEx(pHead));
      end;
    RT_LEVEL_REALTIME:
      begin
        AnsLevelRealTime(PAnsHSAutoPushLevel(pHead));
      end;
    RT_LEVEL_AUTOPUSH:
      begin
        AnsAutoPushLevelRealTime(PAnsHSAutoPushLevel(pHead));
      end;
    RT_LEVEL_TRANSACTION:
      begin
        AnsLevelTransaction(PAnsLevelTransaction(pHead));
      end;

    // EVEL2��ʳɽ�����
    RT_LEVEL_TRANSACTION_AUTOPUSH:
      begin
        AnsAutoPushLevelTransaction(PAnsLevelTransactionAuto(pHead));
      end;

    RT_LEVEL_ORDERQUEUE:
      begin
        AnsLevelOrderQueue(PAnsQueryOrderQueue(pHead));
      end;
    // LEVEL2����������������      LEVEL2������������������
    RT_LEVEL_BORDERQUEUE_AUTOPUSH, RT_LEVEL_SORDERQUEUE_AUTOPUSH:
      begin
        AnsAutoPushLevelOrderQueue(PAnsLevelOrderQueueAuto(pHead));
      end;
    RT_LEVEL_TOTALMAX_AUTOPUSH:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_TOTALMAX_AUTOPUSH');
      end;
    RT_LEVEL_SINGLEMA_AUTOPUSH:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_SINGLEMA_AUTOPUSH');
      end;

    RT_LEVEL_TOTALMAX, RT_LEVEL_TOTALMAX or $1000:
      begin
        AnsLevelCancelTOTALMAX(PAnsHsLevelCancelOrder(pHead));
      end;

    RT_LEVEL_SINGLEMAX:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_SINGLEMAX  ' + inttostr(Size) + #13#10 +
          inttostr(SizeOf(TAnsHsLevelCancelOrder)));
        AnsLevelCancelSINGLEMA(PAnsHsLevelCancelOrder(pHead));
      end;
    RT_LEVEL_SINGLEMAX or $1000:
      begin

        AnsLevelCancelSINGLEMA(PAnsHsLevelCancelOrder(pHead));
      end;
    // DDE ��������
    RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY:
      AnsHDA_TradeClassify_ByOrder(PAnsTradeClassify_HDA(pHead));
    // DDE ������������
    RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH:
      AnsAutoPushHDA_TradeClassify_ByOrder(PAnsTradeClassify_HDA(pHead));
    // ���м�ծȯ
    RT_TREND_IB:
      begin
        AnsIBTREND(PAnsIBTrendData(pHead));
      end;
    RT_TRANS_IB:
      begin
        AnsForeignTRANS(PAnsIBTransData(pHead));
      end;
    RT_TECHDATA_IB:
      begin // ���м�ծȯ 	K��
        AnsForeignTECHDATA(PAnsIBTechData(pHead));
      end;
    RT_BOND_BASE_INFO_IB:
      begin // ���м�ծȯ ծȯ������Ϣ
        AnsForeignBASEINFO(PAnsIBBondBaseInfoData(pHead));
      end;

    RT_SEVER_EMPTY:
      begin
        // with PAnsSeverEmpty(pHead) do
        // pHead.m_nType
        FQuoteService.WriteDebug('RT_SEVER_EMPTY');
      end;
    RT_RETURN_EMPTY:
      begin
        FQuoteService.WriteDebug('RT_RETURN_EMPTY');
      end;
  else
    FQuoteService.WriteDebug('--------HandleOneBiz else:' + inttostr(pHead^.m_nType));
  end;
end;

procedure TQuoteBusiness.DoResetMessage(ServerType: ServerTypeEnum);
begin
  if Assigned(FOnResetMessage) then
    FOnResetMessage(ServerType);
end;

procedure TQuoteBusiness.DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64);
begin
  if Assigned(FOnActiveMessage) then
    FOnActiveMessage(MaskType, SendType, Keys, KeysIndex);
end;

procedure TQuoteBusiness.DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
begin
  if Assigned(FOnActiveMessageCookie) then
    FOnActiveMessageCookie(SendType, Cookie);

end;

procedure TQuoteBusiness.ReadFile(const FileName: string; var buff: Pointer; var Size: integer);
var
  FileStrm: TFileStream;
begin
  // ɾԭ�ȵ��ļ�
  buff := nil;
  if FileExists(FileName) then
  begin
    FileStrm := TFileStream.Create(FileName, fmOpenRead);
    try
      Size := FileStrm.Size;
      GetMemEx(buff, Size);

      FileStrm.Position := 0;
      FileStrm.Read(buff^, Size);
    finally
      FileStrm.Free;
    end;
  end;
end;

procedure TQuoteBusiness.ReqAutoPush(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ����
  AskData^.m_nType := RT_AUTOPUSH;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// ʵʱ������չ  ����
procedure TQuoteBusiness.ReqAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
// RT_AUTOPUSH_EXT
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��չ����
  AskData^.m_nType := RT_AUTOPUSH_EXT;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Code^ := CodeInfo^;

  if direct = '1' then // 1:Single 2:Consolidated
    AskData^.m_nType := RT_LEVEL_SINGLEMA_AUTOPUSH
  else
    AskData^.m_nType := RT_LEVEL_TOTALMAX_AUTOPUSH;
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  AskData^.m_nSize := 1;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Code, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);
end;

// ���Ķ��߾�������
procedure TQuoteBusiness.ReqAutoPushMarketEvent(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqMarketMonitor: PReqMarketMonitor;
  len: integer;
  MarketMonitor: PMarketMonitor;
begin
  if ServerType = stStockLevelI then
  begin
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(AskData, SizeOf(TAskData), 0);
    len := SizeOf(TReqMarketMonitor) + SizeOf(TMarketMonitor);

    GetMemEx(Pointer(ReqMarketMonitor), len);
    FillMemory(ReqMarketMonitor, len, 0);

    AskData.m_nType := RT_MARKET_MONITOR_AUTOPUSH;
    AskData.m_nSize := FloorSize(len, SizeOf(TCodeInfo));

    ReqMarketMonitor.m_nMktCount := 2;
    ReqMarketMonitor.m_sMarkets[0].m_nMarketType := STOCK_MARKET or SH_BOURSE; // �Ϻ��г�
    MarketMonitor := PMarketMonitor(int64(ReqMarketMonitor) + SizeOf(TReqMarketMonitor));
    MarketMonitor.m_nMarketType := STOCK_MARKET or SZ_BOURSE; // �����г�

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqMarketMonitor, nil, SizeOf(TAskData), len, 0);
  end;
end;

procedure TQuoteBusiness.AnsAutoPushMarketEvent(pData: PAnsMarketEvent);
var
  Inf: IQuoteUpdate;
begin
  Inf := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_MarketMonitor, ''] as IQuoteUpdate;
  if Inf <> nil then
    Inf.Update(UPDATE_MARKET_EVENT, int64(@pData.m_MarketEvents[0]), pData.m_nSize);
  DoActiveMessage(QuoteType_MarketMonitor, QuoteType_MarketMonitor, nil, -1);
end;

procedure TQuoteBusiness.ReqSingleHQColValue(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count, ColCode: UInt;
  Cookie: integer);
var
  AskData: PAskData;
  len: integer;
  ReqHQColValue: PReqHQColValue;
begin
  if (Count = 0) or (CodeInfos = nil) then
    exit;
  GetMemEx(PAnsiChar(AskData), SizeOf(TAskData));
  FillMemory(AskData, SizeOf(TAskData), 0);
  len := SizeOf(TReqHQColValue) + (Count - 1) * SizeOf(TCodeInfo);
  GetMemEx(PAnsiChar(ReqHQColValue), len);
  FillMemory(ReqHQColValue, len, 0);

  AskData.m_nType := RT_HQCOL_VALUE;
  AskData.m_nSize := FloorSize(len, SizeOf(TCodeInfo));
  AskData.m_lKey := Cookie;

  ReqHQColValue.m_lHQColCount := 1;
  ReqHQColValue.m_lHQCols[0] := ColCode;
  ReqHQColValue.m_lCodeSize := Count;
  CopyMemory(@ReqHQColValue.m_pCode[0], CodeInfos, SizeOf(TCodeInfo) * Count);
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqHQColValue, nil, SizeOf(TAskData), len, 0);
end;

procedure TQuoteBusiness.AnsSingleHQColValue(pData: PAnsHQColValue);
var
  Inf: IQuoteUpdate;
begin
  if pData.m_lColCodeSize <= 0 then
    exit;
  Inf := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_SingleColValue, inttostr(pData.m_dhHead.m_lKey)] as IQuoteUpdate;
  if Inf = nil then
    exit;
  Inf.Update(UPDATE_COLVELUE_DATA, int64(pData), pData.m_lColCodeSize);
  DoActiveMessageCookie(QuoteType_SingleColValue, pData.m_dhHead.m_lKey);
end;

procedure TQuoteBusiness.ReqHDA_TradeClassify_ByOrder(CodeInfo: PCodeInfo; Count, ClassifyView: integer);
var
  AskData: PAskData;
  Codes: PCodeInfo;
begin
  // Count := 1;
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfo^, Codes^, SizeOf(TCodeInfo) * Count);

  AskData^.m_nType := RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY;
  AskData^.m_nSize := Count;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;
  FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.AnsHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
var
  i, keyIndex: integer;
  QuotaUpdateData: IQuoteUpdate;
  KeysIndex: int64;
  Keys: TIntegerList;
  p: PHDATradeClassifyData;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  QuotaUpdateData := FQuoteDataMngr.QuoteDDERealTime as IQuoteUpdate;
  QuotaUpdateData.BeginWrite;
  try
    for i := 0 to AnsTradeClassify.m_nSize - 1 do
    begin
      p := PHDATradeClassifyData(int64(@AnsTradeClassify.m_lpClassify[0]) + i * SizeOf(THDATradeClassifyData));
      keyIndex := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[p.m_StockCode.m_cCodeType, CodeInfoToCode(@p.m_StockCode)];
      if KeysIndex >= 0 then
      begin
        QuotaUpdateData.Update(UPDATE_DDE_BIGORDER_BYORDER, int64(p), 1);
        Keys.Add(keyIndex);
        StocksBit64Index(KeysIndex, keyIndex);
      end;
    end;
    // ֪ͨ���ݵ���
    DoActiveMessage(QuoteType_DDEBigOrderRealTimeByOrder, QuoteType_DDEBigOrderRealTimeByOrder, Keys, KeysIndex);
  finally
    QuotaUpdateData.EndWrite;
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPushHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
begin
  AnsHDA_TradeClassify_ByOrder(AnsTradeClassify);
end;

procedure TQuoteBusiness.ReqAutoPushHDA_TradeClassify_ByOrder(CodeInfos: PCodeInfos; ClassifyView, Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  AskData^.m_nType := RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelOrderQueue(CodeInfos: PCodeInfos; Count: integer; direct: AnsiChar);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);
  if direct = '1' then
    AskData^.m_nType := RT_LEVEL_BORDERQUEUE_AUTOPUSH
  else
    AskData^.m_nType := RT_LEVEL_SORDERQUEUE_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_LEVEL_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);

end;

procedure TQuoteBusiness.ReqAutoPushLevelTransaction(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // �������
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_LEVEL_TRANSACTION_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqBlockData(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqBlockData: PReqBlockData;
begin
  // �������
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqBlockData), SizeOf(TReqBlockData));
  FillMemory(Pointer(ReqBlockData), SizeOf(TReqBlockData), 0);
  ReqBlockData^.m_lLastDate := 19700101; // ����

  AskData^.m_nType := RT_BLOCK_DATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqBlockData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqBlockData), nil,
    SizeOf(TAskData), SizeOf(TReqBlockData), 0);
end;

procedure TQuoteBusiness.ReqCurrentFinance;
var
  AskData: PAskData;
  ReqCurrentFinanceData: PReqCurrentFinanceData;
begin
  // ���µĲ�������
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqCurrentFinanceData), SizeOf(TReqCurrentFinanceData));
  FillMemory(Pointer(ReqCurrentFinanceData), SizeOf(TReqCurrentFinanceData), 0);
  ReqCurrentFinanceData^.m_lLastDate := 0; // ����

  AskData^.m_nType := RT_CURRENTFINANCEDATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqCurrentFinanceData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex, AskData, ReqCurrentFinanceData, nil, SizeOf(TAskData),
    SizeOf(TReqCurrentFinanceData), 0);
end;

procedure TQuoteBusiness.ReqExRightData;
var
  AskData: PAskData;
  ReqExRightData: PReqExRightData;
begin
  // ��Ȩ����
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqExRightData), SizeOf(TReqExRightData));
  FillMemory(Pointer(ReqExRightData), SizeOf(TReqExRightData), 0);
  ReqExRightData^.m_lLastDate := 0; // ����

  AskData^.m_nType := RT_EXRIGHT_DATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqExRightData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex, Pointer(AskData), Pointer(ReqExRightData), nil, SizeOf(TAskData),
    SizeOf(TReqExRightData), 0);
end;

procedure TQuoteBusiness.ReqGeneralSortEx(ServerType: ServerTypeEnum; Cookie: integer; GeneralSortEx: PReqGeneralSortEx);
var
  AskData: PAskData;
  ReqGeneralSortEx: PReqGeneralSortEx;
begin
  // ����������
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqGeneralSortEx), SizeOf(TReqGeneralSortEx));
  FillMemory(Pointer(ReqGeneralSortEx), SizeOf(TReqGeneralSortEx), 0);

  // ������ֵ
  ReqGeneralSortEx^ := GeneralSortEx^;
  // ��վ��Ϣ
  AskData^.m_nType := RT_GENERALSORT_EX;
  AskData^.m_nSize := FloorSize(SizeOf(TReqGeneralSortEx), SizeOf(TCodeInfo));
  AskData^.m_lKey := Cookie;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqGeneralSortEx, nil, SizeOf(TAskData),
    SizeOf(TReqGeneralSortEx), 0);
end;

// ָ�����ȷ�ʱ  ����
procedure TQuoteBusiness.ReqMILeadData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  AskData := GetAskData(CodeInfo);
  Code := GetCodeInfos(CodeInfo, 1);
  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_LEAD;
  AskData^.m_nSize := 1;
  // AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

// ָ�����ȷ�ʱ  Ӧ��
procedure TQuoteBusiness.AnsMILeadData(AnsLeadData: PAnsLeadData);
var
  TrendUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsLeadData.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin
    TrendUpdate.Update(Update_Trend_MAjorIndexLeadData, int64(AnsLeadData), 0);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    keyIndex := GetKeyIndex(@AnsLeadData.m_dhHead.m_nPrivateKey.m_pCode);
    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

// ָ����ʱ  ����
procedure TQuoteBusiness.ReqMITickData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  AskData := GetAskData(CodeInfo);
  Code := GetCodeInfos(CodeInfo, 1);
  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_MAJORINDEXTICK;
  AskData^.m_nSize := 1;
  // AskData^.m_nPrivateKey.m_pCode := CodeInfo^;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

// ָ����ʱ  Ӧ��
procedure TQuoteBusiness.AnsMITickData(AnsMajorIndexTick: PAnsMajorIndexTick);
var
  TrendUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsMajorIndexTick.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin
    TrendUpdate.Update(Update_Trend_MAjorIndexTickData, int64(AnsMajorIndexTick), AnsMajorIndexTick.m_nSize);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    keyIndex := GetKeyIndex(@AnsMajorIndexTick.m_dhHead.m_nPrivateKey.m_pCode);
    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;

end;

// ��ʱ
procedure TQuoteBusiness.ReqHisTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Date, key: LongInt);
var
  AskData: PAskData;
  ReqHisTrend: PReqHisTrend;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqHisTrend), SizeOf(TReqHisTrend));

  Move(ReqHisTrend^, ReqHisTrend^, SizeOf(TReqHisTrend));

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_HISTREND;
  AskData.m_lKey := key;
  AskData^.m_nSize := FloorSize(SizeOf(TReqHisTrend), SizeOf(TCodeInfo));
  ReqHisTrend^.m_ciStockCode := CodeInfo^;
  ReqHisTrend^.m_lDate := Date;

  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqHisTrend, nil, SizeOf(TAskData),
    SizeOf(TReqHisTrend), 0);
end;

// ���ɼ��Ͼ������� ����
procedure TQuoteBusiness.ReqVirtualAuction(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
begin
  AskData := GetAskData(CodeInfo);
  AskData.m_nType := RT_VIRTUAL_AUCTION;
  AskData.m_nSize := 1;
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  CodeInfo := GetCodeInfos(CodeInfo, 1);
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, CodeInfo, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);
end;

// ���ɼ��Ͼ������� Ӧ��
procedure TQuoteBusiness.AnsVirtualAuction(AnsVirtualAuction: PAnsVirtualAuction);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
    TrendUpdate.Update(Update_Trend_VirtualAuction, int64(AnsVirtualAuction), 0);
  // ֪ͨ���ݵ���
  if TrendUpdate <> nil then
  begin
    if FQuoteDataMngr.QuoteRealTime <> nil then
    begin
      with AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode)];
      if keyIndex <> -1 then
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND or QuoteType_TREND, nil, keyIndex);
    end;
  end;
end;

// procedure TQuoteBusiness.ReqMarketEvent(ServerType: ServerTypeEnum;Cookie: integer);
// begin
//
//
// end;
//
// procedure TQuoteBusiness.AnsMaretEvent(AnsMarketEvent:PAnsMarketEvent);
// begin
//
// end;

procedure TQuoteBusiness.ReqMarketEventAutoPush(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqMarketMonitor: PReqMarketMonitor;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);
  // CodeInfo ��
  GetMemEx(Pointer(ReqMarketMonitor), SizeOf(TReqMarketMonitor) + SizeOf(TMarketMonitor));
  FillMemory(Pointer(ReqMarketMonitor), SizeOf(TReqDayData) + SizeOf(TMarketMonitor), 0);
  AskData.m_nType := RT_MARKET_MONITOR_AUTOPUSH;

end;

procedure TQuoteBusiness.AnsMaretEventAutoPush(AnsMarketEvent: PAnsMarketEvent);
begin

end;

procedure TQuoteBusiness.ReqHKUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    //��������¼������������
//    ReqLogin.m_szUser := 'fs-test';
//    ReqLogin.m_szPWD := 'NSB+JzYgJw==';

    // �ͻ��˵�¼
    AskData^.m_nType := RT_LOGIN_HK;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stStockHK), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.LoadBlockData;
var
  FileName: string;
begin
  // �������
  FileName := FQuoteDataMngr.AppPath + PATH_Block + BLOCK_DEF_FILE;
  // if FBlocks <> nil then begin
  // FBlocks.Free;
  // FBlocks := nil;
  // end;
  // if FileExists(FileName) then begin
  // //����INI�ļ�
  // FBlocks := TMemIniFile.Create(FileName);
  // end;
end;

procedure TQuoteBusiness.LoadCurrentFinance(Data: Pointer; Size: integer);
// var
// i, count, index: integer;
begin
  // count := (size - 8 ) div SizeOf(TFinanceInfo);
  // SetLength(FFinances, count);
  // inc(Integer(Data), 8);
  // Move(Data^, FFinances[0],  sizeof(TFinanceInfo) * Count);
  // //FillMemory(@FStockList[0], SizeOf(TStockInfo) * v, 0);
  // FQuoteService.WriteDebug('RT_CURRENTFINANCEDATA' +'/'+ inttostr(count));
  // for i := low(FFinances) to high(FFinances) do begin
  //
  // index := FStockHash.ValueOf(CodeInfoKey(string(FFinances[i].m_cAType), string(FFinances[i].m_cCode)));
  // if index >= 0 then begin
  // FStockList[index].FinanceIndex := i + 1;
  // end;
  // FQuoteService.Progress('��������', count, i);
  // end;
  // FQuoteService.Progress('��������', count, count);
end;

procedure TQuoteBusiness.LoadExRight;
var
  FileName: string;
  buff: Pointer;
  Size: integer;
begin
  // ���²�������
  FileName := FQuoteDataMngr.AppPath + PATH_Setting + EX_RIGHT_FILE;
  // ɾԭ�ȵ��ļ�
  buff := nil;
  Size := 0;
  ReadFile(FileName, buff, Size);
  if Size <> 0 then
    try
      LoadExRight(buff, Size);
    finally
      // �ͷ��ڴ�
      if buff <> nil then
        FreeMemEx(buff)
    end;
end;

procedure TQuoteBusiness.LoadExRight(Data: Pointer; Size: integer);
// var
// p, count, i, index, rcount: integer;
// ExRight: PExRight;
// ExRightItem: PExRightItem;
begin
  // FQuoteService.WriteDebug(Format('RT_EXRIGHT_DATA %d', [size]));
  //
  // //Ԥ���Ĵ�С
  // count := (size - 8 - 4) div SizeOf(TExRightItem);
  // SetLength(FExRights, Count);
  // p := 8 + 4; index := 0;
  // inc(Integer(Data), p);
  // while (PInteger(Data)^ <> -1) and (p < Size) do begin
  // ExRight := PExRight(Data);
  // rcount := 0;
  // inc(Integer(Data), Sizeof(TExRight));
  // inc(P, Sizeof(TExRight));
  //
  // while (PInteger(Data)^ <> -1) and (p < Size) do begin
  // ExRightItem := PExRightItem(Data);
  // FExRights[index] := ExRightItem^;
  //
  // FExRights[index].m_nTime := DateToInt(FRightBaseDate + ExRightItem^.m_nTime / 86400);
  //
  // FQuoteService.Progress('��Ȩ����', count, index);
  // inc(rcount); inc(index);
  // inc(P, Sizeof(TExRightItem));
  // inc(integer(Data), Sizeof(TExRightItem));
  // end;
  //
  // if PInteger(Data)^ = -1 then begin
  // inc(P, Sizeof(Integer));
  // inc(integer(Data), Sizeof(Integer));
  // end;
  //
  // i := FStockHash.ValueOf(string(ExRight^.m_cACode) + '_' + string(ExRight^.m_cAType));
  // if i >= 0 then begin
  // FStockList[i].ExRightIndex := index - rcount + 1;
  // FStockList[i].RightCount := rcount;
  // end;
  // end;
  //
  // FQuoteService.Progress('��Ȩ����', Count, Count);
end;

procedure TQuoteBusiness.LoadCurrentFinance;
var
  FileName: string;
  buff: Pointer;
  Size: integer;
begin
  // ���²�������
  FileName := FQuoteDataMngr.AppPath + PATH_Setting + CURRENT_FINANCE_FILE;
  buff := nil;
  Size := 0;
  ReadFile(FileName, buff, Size);
  if Size <> 0 then
    try
      LoadCurrentFinance(buff, Size);
    finally
      // �ͷ��ڴ�
      if buff <> nil then
        FreeMemEx(buff)
    end;
end;

procedure TQuoteBusiness.ReqInitialInfo(ServerType: ServerTypeEnum);
var
  Count: integer;
  AskData: PAskData;
  ReqInitSrv: PReqInitSrv;
  ServerCompares: PServerCompares;
begin
  if FQuoteService.Active then
  begin
    // �ͻ������ݳ�ʼ��ϵ��
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // ��������֤�ͳ�ʼ����
    GetMemEx(Pointer(ReqInitSrv), SizeOf(TReqInitSrv));
    FillMemory(Pointer(ReqInitSrv), SizeOf(TReqInitSrv), 0);
    ReqInitSrv.m_nSrvCompareSize := 0;

    // ��������֤�ͳ�ʼ����
    if ServerType = stStockLevelI then
      Count := 2
    else
      Count := 1;

    GetMemEx(Pointer(ServerCompares), SizeOf(TServerCompare) * Count);
    FillMemory(Pointer(ServerCompares), SizeOf(TServerCompare) * Count, 0);

    // ��Ʊ
    case ServerType of
      stStockLevelI:
        begin
          ServerCompares^[0].m_cBourse := STOCK_MARKET;
          ServerCompares^[1].m_cBourse := OTHER_MARKET;
          ServerCompares^[1].m_dwCRC := 0;
        end;
      stFutues:
        ServerCompares^[0].m_cBourse := FUTURES_MARKET;
      stStockHK:
        ServerCompares^[0].m_cBourse := HK_MARKET;
      stForeign:
        ServerCompares^[0].m_cBourse := FOREIGN_MARKET;
      stUSStock:
        ServerCompares^[0].m_cBourse := US_MARKET;
    else
      ServerCompares^[0].m_cBourse := STOCK_MARKET;
    end;

    ServerCompares^[0].m_dwCRC := 0;

    // �ͻ������ݳ�ʼ��ϵ��
    AskData^.m_nType := RT_INITIALINFO;
    // �����ϴ�������
    AskData^.m_nSize := FloorSize(SizeOf(TReqInitSrv) + SizeOf(TServerCompare) * Count, SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqInitSrv, ServerCompares, SizeOf(TAskData),
      SizeOf(TReqInitSrv), SizeOf(TServerCompare) * Count);
  end;
end;

procedure TQuoteBusiness.ReqKeepActive(ServerType: ServerTypeEnum);
var
  TestSrvData: PTestSrvData;
begin
  if FQuoteService.Active then
  begin

    GetMemEx(Pointer(TestSrvData), SizeOf(TTestSrvData));
    FillMemory(Pointer(TestSrvData), SizeOf(TTestSrvData), 0);

    // �ͻ��˵�¼               RT_TESTSRV
    TestSrvData^.m_nType := RT_TESTSRV;
    TestSrvData^.m_nIndex := ServerType;

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(TestSrvData), nil, nil,
      SizeOf(TTestSrvData), 0, 0);

    FQuoteService.WriteDebug('��������....' + ServerTypeToStr(ServerType));
  end;
end;

procedure TQuoteBusiness.ReqLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  // ReqOrderQueue: PReqOrderQueue;
  Code: PCodeInfo;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Code^ := CodeInfo^;

  { GetMemEx(pointer(ReqOrderQueue), SizeOf(TReqOrderQueue));
    ReqOrderQueue.m_CodeInfo := CodeInfo^;
    ReqOrderQueue.m_direct := direct; }
  AskData^.m_nType := $0B04;

  { if direct = '1' then      //   1:Single 2:Consolidated
    AskData^.m_nType := $0B04
    else AskData^.m_nType := RT_LEVEL_TOTALMAX;
  }
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  AskData^.m_nSize := 1;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Code, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);

end;

procedure TQuoteBusiness.ReqLevelOrderQueue(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  ReqOrderQueue: PReqOrderQueue;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqOrderQueue), SizeOf(TReqOrderQueue));
  ReqOrderQueue.m_CodeInfo := CodeInfo^;
  ReqOrderQueue.m_direct := ord(direct);

  AskData^.m_nType := RT_LEVEL_ORDERQUEUE;
  AskData^.m_nSize := FloorSize(SizeOf(TReqOrderQueue), SizeOf(TCodeInfo));;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, ReqOrderQueue, nil, SizeOf(TAskData),
    SizeOf(TReqOrderQueue), 0);
end;

procedure TQuoteBusiness.ReqLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_LEVEL_REALTIME;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);

end;

procedure TQuoteBusiness.ReqLevelTransaction(CodeInfo: PCodeInfo; nSize, nPostion: integer);
var
  AskData: PAskData;
  ReqLevelTransaction: PReqLevelTransaction;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqLevelTransaction), SizeOf(TReqLevelTransaction));
  FillMemory(Pointer(ReqLevelTransaction), SizeOf(TReqLevelTransaction), 0);
  ReqLevelTransaction^.m_CodeInfo := CodeInfo^;
  ReqLevelTransaction^.m_nSize := nSize;
  ReqLevelTransaction^.m_nPostion := nPostion;

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_LEVEL_TRANSACTION;
  AskData^.m_nSize := FloorSize(SizeOf(TReqLevelTransaction), SizeOf(TCodeInfo));
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, ReqLevelTransaction, nil, SizeOf(TAskData),
    SizeOf(TReqLevelTransaction), 0);
end;

procedure TQuoteBusiness.ReqLimitTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Limit: Word);
var
  AskData: PAskData;
  ReqLimitTick: PReqLimitTick;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqLimitTick), SizeOf(TReqLimitTick));
  FillMemory(Pointer(ReqLimitTick), SizeOf(TReqLimitTick), 0);

  ReqLimitTick^.m_pCode := CodeInfo^;
  ReqLimitTick^.m_nCount := Limit;

  // ���ɷֱ�
  AskData^.m_nType := RT_LIMITTICK;
  AskData^.m_nSize := FloorSize(SizeOf(TReqLimitTick), SizeOf(TCodeInfo));;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqLimitTick, nil, SizeOf(TAskData),
    SizeOf(TReqLimitTick), 0);
end;

procedure TQuoteBusiness.ReqPeportSort(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer; Cookie: integer;
  ReqReportSort: PReqReportSort);
var
  AskData: PAskData;
  ReqAnyReport: PReqAnyReport;
  AnyReportDatas: PAnyReportDatas;
begin
  // ����������
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqAnyReport), SizeOf(TReqAnyReport));

  FillMemory(Pointer(ReqAnyReport), SizeOf(TReqAnyReport), 0);

  // ���ƹ�Ʊ
  GetMemEx(Pointer(AnyReportDatas), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], AnyReportDatas^[0], SizeOf(TCodeInfo) * Count);

  ReqAnyReport^.m_cCodeType := USERDEF_BOURSE;
  ReqAnyReport^.m_nColID := ReqReportSort^.m_nColID;
  ReqAnyReport^.m_bAscending := ReqReportSort^.m_bAscending;
  ReqAnyReport^.m_nBegin := ReqReportSort^.m_nBegin;
  ReqAnyReport^.m_nCount := ReqReportSort^.m_nCount;
  ReqAnyReport^.m_nSize := Count;

  AskData^.m_nType := RT_REPORTSORT;
  AskData^.m_lKey := Cookie; // ����Cookie
  AskData^.m_nSize := FloorSize(SizeOf(TReqAnyReport) + SizeOf(TAnyReportData) * Count, SizeOf(TCodeInfo));
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqAnyReport, AnyReportDatas, SizeOf(TAskData),
    SizeOf(TReqAnyReport), SizeOf(TAnyReportData) * Count);
end;

procedure TQuoteBusiness.ReqRealTime(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_REALTIME;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.AnsRealTime(AnsRealTime: PAnsRealTime);
begin
  // FQuoteService.WriteDebug('RT_REALTIME' +'/'+ inttostr(AnsRealTime^.m_nSize));
  if AnsRealTime^.m_nSize > 0 then
    UpdateCommRealTime(@AnsRealTime^.m_pnowData[0], AnsRealTime.m_nSize, nil);
end;

// ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)  ����
procedure TQuoteBusiness.ReqRealTime_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_REALTIME_EXT;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)   Ӧ��
procedure TQuoteBusiness.AnsRealTime_Ext(AnsRealTime_Ext: PAnsRealTime_Ext);
begin
  if AnsRealTime_Ext^.m_nSize > 0 then
    UpdateCommRealTime_EXT(@AnsRealTime_Ext.m_pnowData[0], AnsRealTime_Ext.m_nSize, nil);
end;

// 64λ��չʵʱ����(��Ҫ���ڸ�����Ȩ,����ETF)  ����
procedure TQuoteBusiness.ReqRealTime_Int64Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_REALTIME_EXT_INT64;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// 64λ��չʵʱ����(��Ҫ����ָ����֤ȯ)   Ӧ��
procedure TQuoteBusiness.AnsRealTime_Int64Ext(AnsRealTime_Ext: PAnsRealTime_EXT_INT64);
begin
  if AnsRealTime_Ext^.m_nSize > 0 then
    UpdateCommRealTime_Int64EXT(@AnsRealTime_Ext.m_pnowData[0], AnsRealTime_Ext.m_nSize, nil);
end;

procedure TQuoteBusiness.ReqStockTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // ����������һ��ֻ��ȡһ��
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // ���ɷֱ�
  AskData^.m_nType := RT_STOCKTICK;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.ReqTechData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate;
  Period: short; nDay: Word);
var
  AskData: PAskData;
  ReqDayData: PReqDayData;
  StateCount: int64;
  SValue: WideString;
  OValue: OleVariant;
begin
  // ������æµ��׼ �������������ϲ� ���������������

  // ȡ���ӽ��쿪ʼ��Ч������
  TechData.DataState(State_Tech_DataLen, StateCount, SValue, OValue);
  if nDay < StateCount then
  begin // ��Ҫ�����ݱȻ������ݶ� ȫ����ȡ
    // 1���� 5���Ӷ�Ҫ����ȡ     Max(������, ������)
    if Period <> PERIOD_TYPE_DAY then
    begin
      nDay := StateCount; // ����� 1 ���� 5���� ȡһ�� �ͻᲹ���µ����ݻ���
      // �����߲�Ҫ��ȡ
    end
    else
      nDay := 0;
  end;

  if nDay > 0 then
  begin

    // ���æµ
    TechData.Update(Update_Tech_Busy, 0, 0);

    // �̺����
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // CodeInfo ��
    GetMemEx(Pointer(ReqDayData), SizeOf(TReqDayData));
    FillMemory(Pointer(ReqDayData), SizeOf(TReqDayData), 0);

    // Э�鶨��������,���Ǵ�ͷȡ���� ��������ȡ,
    // ������ 1������ 5�����ߵ�����,���ݳ��ȱ仯 ʵ������������
    // ���Զ���ͷ��ʼȡ(�˷Ѱ�)

    // AskData.m_lKey :=
    ReqDayData^.m_ciCode := CodeInfo^;
    ReqDayData^.m_cPeriod := Period;
    ReqDayData^.m_lBeginPosition := 0; // �����ڿ�ʼ
    ReqDayData^.m_nDay := nDay; // ���ٸ�

    // ��վ��Ϣ
    AskData^.m_nType := RT_TECHDATA_EX;

    // ��������״̬
    AskData^.m_lKey := Period;

    // if StateCount = 0 then AskData^.m_nIndex := 1  //ȡȫ������
    // else AskData^.m_nIndex := 2;    //ȡ��������

    AskData^.m_nSize := FloorSize(SizeOf(TReqDayData), SizeOf(TCodeInfo));
    AskData^.m_nPrivateKey.m_pCode := ReqDayData^.m_ciCode;
    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqDayData), nil,
      SizeOf(TAskData), SizeOf(TReqDayData), 0);
  end;
end;

// ���ɷ�ʱ  ����
procedure TQuoteBusiness.ReqTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_TREND;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.ReqTrend_Ext(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_TREND_EXT;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.AnsAutoPush(AnsRealTime: PAnsRealTime);
var
  i, keyIndex: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData;
  Keys: TIntegerList;
begin
  // FQuoteService.WriteDebug('RT_AUTOPUSH' +'/'+ inttostr(AnsRealTime^.m_nSize));
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];

        // ָ���ɽ��λ��ΪԪ
        if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
          (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
          HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice := CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice * 100;

        // ���±�����
        if keyIndex >= 0 then
        begin
          RealTimeUpdate.Update(Update_RealTime_RealTimeData, int64(CommRealTimeData), 0);

          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        // ���·�ʱ��
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���·ֱ�
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush, int64(CommRealTimeData), 0);
        end;

        // ���� ���� �ֱ�
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� ����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_DAY, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� 1����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE1, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� 5����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE5, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� 15����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE15, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� 30����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE30, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // ���� 60����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE60, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;
        // ������
        // QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_WEEK,
        // @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        // if QuoteUpdate <> nil then
        // begin
        // QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        // end;
        // // ������
        // QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MONTH,
        // @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        // if QuoteUpdate <> nil then
        // begin
        // QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        // end;

        // ʵ����� λ������  ָ��
        if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, OTHER_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIndexRealTime));

        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, HK_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSHKStockRealTime));
        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIBRealTime));

          // �ڻ�
        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSQHRealTime))
        end
        else
        begin // ��Ʊ
          if HSKindType(CommRealTimeData^.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIndexRealTime))
            // A B ��
          else
            inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSStockRealTime));
        end;
      end;

      // ���ݵ���֪ͨ
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_LIMITTICK or
        QuoteType_TECHDATA_MINUTE1 or QuoteType_TECHDATA_MINUTE5 or QuoteType_TECHDATA_DAY or
        QuoteType_TECHDATA_MINUTE15 or QuoteType_TECHDATA_MINUTE30 or QuoteType_TECHDATA_MINUTE60 { or
          QuoteType_TECHDATA_WEEK or QuoteType_TECHDATA_MONTH } , QuoteType_REALTIME, Keys, KeysIndex); // ������  ��ʱ����  �ֱʳɽ�
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);
var
  i, keyIndex, OffSet: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData_Ext;
  Keys: TIntegerList;
begin
  // FQuoteService.WriteDebug('RT_AUTOPUSH' +'/'+ inttostr(AnsRealTime^.m_nSize));
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];

        // ָ���ɽ��λ��ΪԪ
        if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
          (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
          HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
            CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;

        // ���±�����
        if keyIndex >= 0 then
        begin
          RealTimeUpdate.Update(Update_RealTime_RealTimeDataExt, int64(CommRealTimeData), 0);

          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        // ���·�ʱ��
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���·ֱ�
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush_Ext, int64(CommRealTimeData), 0);
        end;

        // ���� ���� �ֱ�
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� ����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_DAY, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� 1����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE1, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� 5����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE5, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� 15����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE15, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� 30����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE30, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ���� 60����
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE60, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;
        // ������
        { QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_WEEK,
          @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
          if QuoteUpdate <> nil then
          begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
          end;
          // ������
          QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MONTH,
          @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
          if QuoteUpdate <> nil then
          begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
          end; }

        // ʵ����� λ������  ָ��
        if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // ָ��
          // CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, HK_MARKET) then // ���
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSHKStockRealTime_EXT))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OPT_MARKET) then // ������Ȩ
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSOPTRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // �ڻ�
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSQHRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, US_MARKET) then // ����
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSUSStockRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          if HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // ���м�
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSIBRealTime))
          else // ���
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSWHRealTime));
        end
        else
        begin
          if HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext))
          else // A B ��
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext));
        end;
      end;

      // ���ݵ���֪ͨ
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_LIMITTICK or
        QuoteType_TECHDATA_MINUTE1 or QuoteType_TECHDATA_MINUTE5 or QuoteType_TECHDATA_DAY or
        QuoteType_TECHDATA_MINUTE15 or QuoteType_TECHDATA_MINUTE30 or QuoteType_TECHDATA_MINUTE60 { or
          QuoteType_TECHDATA_WEEK or QuoteType_TECHDATA_MONTH } , QuoteType_REALTIME, Keys, KeysIndex); // ������  ��ʱ����  �ֱʳɽ�
    end;
  finally
    Keys.Free;
  end;
end;

// 64λ����Э��ʵʱ������չ  ����
procedure TQuoteBusiness.ReqAutoPush_Int64Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��չ����
  AskData^.m_nType := RT_AUTOPUSH_EXT_INT64;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// 64λ����Э��ʵʱ������չ  Ӧ��
procedure TQuoteBusiness.AnsAutoPush_Int64Ext(AnsRealTime: PAnsRealTime_EXT_INT64);
var
  i, keyIndex, OffSet: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeInt64Data_Ext;
  Keys: TIntegerList;
begin
  // FQuoteService.WriteDebug('RT_AUTOPUSH' +'/'+ inttostr(AnsRealTime^.m_nSize));
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherInt64Data) + 2 * SizeOf(uShort);
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];

        // ָ���ɽ��λ��ΪԪ
        if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
          (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
          HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
            CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;

        // ���±�����
        if keyIndex >= 0 then
        begin
          RealTimeUpdate.Update(Update_RealTime_RealTimeInt64DataExt, int64(CommRealTimeData), 0);

          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        // ʵ����� λ������  ָ��
        if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // ָ��
          // CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Int64Ext))
        else
        begin
          if HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Int64Ext))
          else // A B ��
            CommRealTimeData := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Int64Ext));
        end;
      end;

      // ���ݵ���֪ͨ
      DoActiveMessage(QuoteType_REALTIMEInt64,
        QuoteType_REALTIMEInt64, Keys, KeysIndex); // ������  ��ʱ����  �ֱʳɽ�

//      DoActiveMessage(QuoteType_REALTIMEInt64 or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_LIMITTICK or
//        QuoteType_TECHDATA_MINUTE1 or QuoteType_TECHDATA_MINUTE5 or QuoteType_TECHDATA_DAY or
//        QuoteType_TECHDATA_MINUTE15 or QuoteType_TECHDATA_MINUTE30 or QuoteType_TECHDATA_MINUTE60,
//        QuoteType_REALTIMEInt64, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPushLevelOrderQueue(LevelOrderQueueAuto: PAnsLevelOrderQueueAuto);
var
  i, keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  OrderQueueUpdate: IQuoteUpdate;
  // LevelTransaction: PLevelTransaction;
  OrderQueue: POrderQueueData;
begin
  FQuoteService.WriteDebug('AnsAutoPushLevelOrderQueue' + inttostr(LevelOrderQueueAuto^.m_nSize));
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  keyIndex := -1;
  for i := 0 to LevelOrderQueueAuto^.m_nSize - 1 do
  begin
    OrderQueue := @LevelOrderQueueAuto^.m_pstData[i];

    OrderQueueUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_ORDERQUEUE, @OrderQueue^.m_CodeInfo] as IQuoteUpdate;
    if OrderQueueUpdate <> nil then
    begin
      // ���ݸ���
      OrderQueueUpdate.Update(Update_OrderQueue_Data, int64(@OrderQueue^.m_Data), 1);

      QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
      if QuoteRealTime <> nil then
        with OrderQueue^.m_CodeInfo do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType, CodeInfoToCode(@OrderQueue^.m_CodeInfo)];
    end;
  end;
  // ֪ͨ���ݵ���
  if keyIndex <> -1 then
    DoActiveMessage(QuoteType_Level_ORDERQUEUE, QuoteType_Level_ORDERQUEUE, nil, keyIndex);

end;

procedure TQuoteBusiness.AnsAutoPushLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);
begin
  if LevelRealTime^.m_nSize > 0 then
    UpdateCommLevelRealTime(@LevelRealTime^.m_pstData[0], LevelRealTime.m_nSize, nil);
end;

procedure TQuoteBusiness.AnsAutoPushLevelTransaction(LevelTransactionAuto: PAnsLevelTransactionAuto);
var
  i, keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TransactionUpdate: IQuoteUpdate;
  LevelTransaction: PLevelTransaction;
begin
  FQuoteService.WriteDebug('AnsAutoPushLevelTransaction' + inttostr(LevelTransactionAuto^.m_nSize));
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  keyIndex := -1;
  for i := 0 to LevelTransactionAuto^.m_nSize - 1 do
  begin
    LevelTransaction := @LevelTransactionAuto^.m_Data[i];
    TransactionUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TRANSACTION, @LevelTransaction^.m_CodeInfo]
      as IQuoteUpdate;
    if TransactionUpdate <> nil then
    begin
      // ���ݸ���
      TransactionUpdate.Update(Update_TransactionAuto_Data, int64(@LevelTransaction^.m_Data), LevelTransaction^.m_nSize);

      if QuoteRealTime <> nil then
        with LevelTransaction^.m_CodeInfo do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType, CodeInfoToCode(@LevelTransaction^.m_CodeInfo)];
    end;
  end;
  // ֪ͨ���ݵ���
  if keyIndex <> -1 then
    DoActiveMessage(QuoteType_Level_TRANSACTION, QuoteType_Level_TRANSACTION, nil, keyIndex);
end;

function UnZipBlockFile(Data: PAnsiChar; len: integer): TMemoryStream;
begin
  // var
  // ms: TMemoryStream;
  // num: Integer;
  // begin
  Result := nil;
  // if (Data = nil) or (len = 0) then exit;
  // ms := TMemoryStream.Create;
  // try
  // ms.Write(Data^,len);
  // ds := TDecompressionStream.Create(ms);
  // try
  // //ds.Write(Data^,len);
  // //ds.Read(ms.Memory^, num);
  // ms.Clear;
  // ms.CopyFrom(ds,ds.Size);
  // Result := ms;
  // finally
  // ds.Free;
  // end;
  // except
  // ms.Free;
  // end;

end;

procedure TQuoteBusiness.AnsBlockData(AnsTextData: PAnsTextData);
var
  fs: TMemoryStream;
  FileName: string;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // ��ѹ�������
    FileName := FQuoteDataMngr.AppPath + PATH_Block + BLOCK_DEF_FILE;
    fs := TMemoryStream.Create;
    fs.Write(AnsTextData^.m_cData[0], AnsTextData^.m_nSize);
    fs.SaveToFile(FileName);
    fs.Free;
    // ms := UnZipBlockFile(@AnsTextData^.m_cData[0], AnsTextData^.m_nSize);
    // if ms = nil then Exit;
    //
    //
    // ms.SaveToFile(FileName);
    // ms.Free;
    // ����������
    LoadBlockData;
  end;
end;

procedure TQuoteBusiness.AnsCurrentFinance(AnsTextData: PAnsTextData);
var
  FileName: string;
  RealTimeUpdate: IQuoteUpdate;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // ���²�������
    FileName := FQuoteDataMngr.AppPath + PATH_Setting + CURRENT_FINANCE_FILE;

    // д���ļ�
    WriteFile(FileName, @AnsTextData^.m_cData[0], AnsTextData^.m_nSize);

    // ���뵱ǰ��������
    // ��ȡ  IQuoteUpdate ��ʼ��������
    RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
    if RealTimeUpdate <> nil then
      RealTimeUpdate.Update(Update_RealTime_Finance_SetData, int64(@AnsTextData^.m_cData[0]), AnsTextData^.m_nSize);

  end;
end;

procedure TQuoteBusiness.AnsExRightData(AnsTextData: PAnsTextData);
var
  FileName: string;
  RealTimeUpdate: IQuoteUpdate;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // ��Ȩ���� Ӧ��
    FileName := FQuoteDataMngr.AppPath + PATH_Setting + EX_RIGHT_FILE;
    // д���ļ�
    WriteFile(FileName, @AnsTextData^.m_cData[0], AnsTextData^.m_nSize);

    // �����Ȩ����
    // ��ȡ  IQuoteUpdate ��ʼ��������
    RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
    if RealTimeUpdate <> nil then
      RealTimeUpdate.Update(Update_RealTime_ExRight_SetData, int64(@AnsTextData^.m_cData[0]), AnsTextData^.m_nSize);
  end;
end;

procedure TQuoteBusiness.AnsGeneralSortEx(AnsGeneralSortEx: PAnsGeneralSortEx);
var
  GeneralSortUpdate: IQuoteUpdate;

begin
  // ���±���������
  if AnsGeneralSortEx^.m_nSize > 0 then
  begin

    // ������������
    GeneralSortUpdate := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_GENERALSORT,
      inttostr(AnsGeneralSortEx^.m_dhHead.m_lKey)] as IQuoteUpdate;
    if GeneralSortUpdate <> nil then
    begin
      GeneralSortUpdate.BeginWrite;
      try
        GeneralSortUpdate.Update(Update_GeneralSort_Data, int64(AnsGeneralSortEx), 0);
      finally
        GeneralSortUpdate.EndWrite;
      end;
      DoActiveMessageCookie(QuoteType_GENERALSORT, AnsGeneralSortEx^.m_dhHead.m_lKey);
    end;
  end;
end;

procedure TQuoteBusiness.AnsHisTrend(AnsHisTrend: PAnsHisTrend);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  // ���շ�ʱ
  if AnsHisTrend.m_dhHead.m_lKey < 0 then
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_MultiHisTrendData, int64(@AnsHisTrend.m_shTend), AnsHisTrend.m_dhHead.m_lKey);
  end
  else if AnsHisTrend.m_dhHead.m_lKey = 99999 then
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_HisTrendData, int64(@AnsHisTrend.m_shTend), 0);
  end
  else
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_HisTREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_HisTrendData, int64(@AnsHisTrend.m_shTend), 0);
  end;
  // ֪ͨ���ݵ���
  if TrendUpdate <> nil then
  begin
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode)];
    if keyIndex <> -1 then
      if AnsHisTrend.m_dhHead.m_lKey < 0 then // ֪ͨ��ʱ(����)
      begin
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
      end
      else if AnsHisTrend.m_dhHead.m_lKey = 99999 then
      begin
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
      end
      else
      begin
        DoActiveMessage(QuoteType_HisTREND, QuoteType_HisTREND, nil, keyIndex);
      end;
  end;
end;

procedure TQuoteBusiness.AnsHKUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('HK ��½�ɹ�!');
  FQuoteService.SendEvent(etLoginHK, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsInitialInfo(AnsInitialData: PAnsInitialData);
var
  i, J, v, index, OpenTime, CloseTime: integer;
  OneMarketData: POneMarketData;
  StockInitData: PStockInitData;
  RealTimeUpdate: IQuoteUpdate;
  ServerType: ServerTypeEnum;
  p: PCommBourseInfo;
  AStockTypeInfo: TStockTypeInfo;
begin
  ServerType := stStockLevelI;
  // ��ʼ�� �������������
  FQuoteDataMngr.InitDataMngr;

  FQuoteService.WriteDebug('RT_INITIALINFO' + '/' + inttostr(AnsInitialData^.m_nSize));
  RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
  // ��ʼ��Ӧ�� �г���Ϣ�ṹ
  if (AnsInitialData^.m_nSize > 0) and (RealTimeUpdate <> nil) then
  begin
    OneMarketData := @AnsInitialData^.m_sOneMarketData[0];
    i := 0;
    while i < AnsInitialData^.m_nSize do
    begin

      FQuoteDataMngr.BeginWrite;
      try
        p := FQuoteDataMngr.GetBourseInfo(OneMarketData.m_biInfo.m_nMarketType);
        CopyMemory(p, @OneMarketData.m_biInfo, SizeOf(TCommBourseInfo));
        // ��ʼ�� ��ʱ����
        for v := 0 to OneMarketData.m_biInfo.m_cCount - 1 do
        begin
          if (OneMarketData.m_biInfo.m_stNewType[v].m_nTotal <> 0) and
            (OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[0].m_nOpenTime <> -1) then
          begin
            AStockTypeInfo := FQuoteDataMngr.GetStockTypeInfo(OneMarketData.m_biInfo.m_stNewType[v].m_nStockType);
            if AStockTypeInfo = nil then
              continue;

            AStockTypeInfo.StockType := OneMarketData.m_biInfo.m_stNewType[v];
            AStockTypeInfo.Times.Clear;
            index := 0;
            for J := 0 to 9 do
            begin
              OpenTime := OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[J].m_nOpenTime;
              CloseTime := OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[J].m_nCloseTime;
              if OpenTime = -1 then
                break;
              // �м����� ǰһʱ�䲻���� 11:30 13:00    13:00 �Ͳ�����
              if J > 0 then
                inc(OpenTime);

              while OpenTime <= CloseTime do
              begin
                AStockTypeInfo.Times.Add(index, OpenTime);
                inc(OpenTime);
                inc(index);
              end;
            end;
            AStockTypeInfo.Times.tag := index;
          end;
        end;
      finally
        FQuoteDataMngr.EndWrite;
      end;

      if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, STOCK_MARKET, SH_BOURSE) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, STOCK_MARKET, SZ_BOURSE) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, YHJZQ_BOURSE) then
      begin
        ServerType := stForeign;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, XHCJ_BOURSE) then
      begin
        ServerType := stForeign; // ���ò��
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, ZYSHG_BOURSE) then
      begin
        ServerType := stForeign; // ��Ѻʽ�ع�
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, MDSHG_BOURSE) then
      begin
        ServerType := stForeign; // ���ʽ�ع�
      end
      else if HSMarketType(OneMarketData.m_biInfo.m_nMarketType, OTHER_MARKET) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, DALIAN_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, SHANGHAI_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, GUZHI_BOURSE) then
      begin
        ServerType := stFutues;
        // �۹�����
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, HK_BOURSE) then
      begin
        ServerType := stStockHK;
        // �۹�ָ��
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, GE_BOURSE) then
      begin
        ServerType := stStockHK;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, INDEX_BOURSE) then
      begin
        ServerType := stStockHK;
      end
      else if HSMarketType(OneMarketData.m_biInfo.m_nMarketType, US_MARKET) then
        ServerType := stUSStock
      else
        ServerType := stStockLevelI;

      // ��λ StockInitData
      StockInitData := Pointer(IntPtr(@OneMarketData^.m_biInfo.m_stNewType[0]) + SizeOf(TStockType) *
        OneMarketData^.m_biInfo.m_cCount);

      // ��������
      RealTimeUpdate.Update(Update_RealTime_Codes_SetData, int64(StockInitData), OneMarketData.m_biInfo.m_nMarketType);

      // ��λ
      OneMarketData := Pointer(IntPtr(@StockInitData^.m_pstInfo[0]) + SizeOf(TStockInitInfo) * StockInitData^.m_nSize);
      inc(i);
    end;

    // if ServerType in [stStockLevelI,stFutues] then
    // ReqSeverCalculate(ServerType);
    // �ȴ��ļ������
    // LoadCurrentFinance;
    // LoadExRight;

    // ������� ��ȡ
    // ReqBlockData;

    // �����������
    // ReqCurrentFinance;
    // �����Ȩ����
    // ReqExRightData;
    // ��ʷ�������� ???

    // ���Ϊ�ѳ�ʼ���
    FIsInitial := true;
    if ServerType = stStockLevelI then
      FQuoteService.SendEvent(etInited, nil, '', 0, ServerType);

    // ֪ͨ��ʼ�� �ɹ�  �������connter
    FQuoteService.WriteDebug(format('������%s�ɹ���ʼ��.', [ServerTypeToStr(ServerType)]));
    DoResetMessage(ServerType);
  end;
end;

procedure TQuoteBusiness.AnsKeepActive(AnsTestSrvData: PTestSrvData);
begin
  // FQuoteService.WriteDebug('RT_KEEPACTIVE' +'/'+ inttostr(AnsKeepActive^.m_nDateTime));
  FQuoteService.WriteDebug('RT_KEEPACTIVE ' + ServerTypeToStr(AnsTestSrvData.m_nIndex));
  FQuoteService.SendEvent(etAnsKeepActive, nil, '', 0, AnsTestSrvData.m_nIndex);
end;

procedure TQuoteBusiness.AnsLevelCancelSINGLEMA(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  SINGLEMAUpdate: IQuoteUpdate;
begin
  SINGLEMAUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_SINGLEMA,
    @AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if SINGLEMAUpdate <> nil then
  begin
    // ���ݸ���
    if AnsHsLevelCancelOrder^.m_pData.ctype in [1, 2] then
    begin
      SINGLEMAUpdate.Update(Update_SINGLEMA_Data, int64(@AnsHsLevelCancelOrder^.m_pData), 0);
      keyIndex := -1;
      QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
      if QuoteRealTime <> nil then
        with AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
            CodeInfoToCode(@AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode)];

      // ֪ͨ���ݵ���
      if keyIndex <> -1 then
        DoActiveMessage(QuoteType_Level_SINGLEMA, QuoteType_Level_SINGLEMA, nil, keyIndex);
    end;
  end;
end;

procedure TQuoteBusiness.AnsLevelCancelTOTALMAX(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TOTALMAXUpdate: IQuoteUpdate;
begin
  TOTALMAXUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TOTALMAX,
    @AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if TOTALMAXUpdate <> nil then
  begin
    // ���ݸ���
    TOTALMAXUpdate.Update(Update_TOTALMAX_Data, int64(@AnsHsLevelCancelOrder^.m_pData), 0);
    keyIndex := -1;
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_TOTALMAX, QuoteType_Level_TOTALMAX, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLevelOrderQueue(QueryOrderQueue: PAnsQueryOrderQueue);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  OrderQueueUpdate: IQuoteUpdate;

begin
  OrderQueueUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_ORDERQUEUE,
    @QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if OrderQueueUpdate <> nil then
  begin

    // ���ݸ���
    OrderQueueUpdate.Update(Update_OrderQueue_Data, int64(@QueryOrderQueue^.m_pstData), 1);
    keyIndex := -1;
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_ORDERQUEUE, QuoteType_Level_ORDERQUEUE, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);
begin
  if LevelRealTime^.m_nSize > 0 then
    UpdateCommLevelRealTime(@LevelRealTime^.m_pstData[0], LevelRealTime.m_nSize, nil);
end;

procedure TQuoteBusiness.AnsLevelTransaction(LevelTransaction: PAnsLevelTransaction);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TransactionUpdate: IQuoteUpdate;
begin

  TransactionUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TRANSACTION,
    @LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if TransactionUpdate <> nil then
  begin
    // ���ݸ���
    keyIndex := -1;
    TransactionUpdate.Update(Update_Transaction_Data, int64(@LevelTransaction^.m_Data[0]), LevelTransaction^.m_nSize);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_TRANSACTION, QuoteType_Level_TRANSACTION, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLimitTick(AnsStockTick: PAnsStockTick);
var
  StockTickUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;

  StockTickUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if StockTickUpdate <> nil then
  begin

    StockTickUpdate.Update(Update_StockTick_StockTickData, int64(@AnsStockTick^.m_traData), AnsStockTick^.m_nSize);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_LIMITTICK, QuoteType_LIMITTICK, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsPeportSort(AnsReportData: PAnsReportData);
var
  PeportSortUpdate: IQuoteUpdate;
  Codes: array of TCodeInfo;
begin
  // ���±���������
  if AnsReportData^.m_nSize > 0 then
  begin
    SetLength(Codes, AnsReportData^.m_nSize);
    UpdateCommRealTime(@AnsReportData^.m_prptData[0], AnsReportData^.m_nSize, @Codes[0]);
    // ������������
    PeportSortUpdate := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(AnsReportData^.m_dhHead.m_lKey)
      ] as IQuoteUpdate;
    if PeportSortUpdate <> nil then
    begin
      PeportSortUpdate.BeginWrite;
      try
        PeportSortUpdate.Update(Update_ReprotSort_Data, int64(@Codes[0]), AnsReportData^.m_nSize);
      finally
        PeportSortUpdate.EndWrite;
      end;
      // ֪ͨ���ݵ���
      DoActiveMessageCookie(QuoteType_REPORTSORT, AnsReportData^.m_dhHead.m_lKey);
      // DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  end;
end;

procedure TQuoteBusiness.AnsServerInfo(AnsServerInfo: PAnsServerInfo);
begin
  FQuoteService.WriteDebug(format('��վ��Ϣ %s %s �����ӹ�������%d ������������%d ��ǰ������%d', [AnsServerInfo^.m_pName,
    AnsServerInfo^.m_pSerialNo, AnsServerInfo^.m_lTotalCount, AnsServerInfo^.m_lToDayCount, AnsServerInfo^.m_lNowCount]));
end;

procedure TQuoteBusiness.AnsStockTick(AnsStockTick: PAnsStockTick);
var
  StockTickUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  StockTickUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if StockTickUpdate <> nil then
  begin

    StockTickUpdate.Update(Update_StockTick_StockTickData, int64(@AnsStockTick^.m_traData), AnsStockTick^.m_nSize);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_STOCKTICK, QuoteType_STOCKTICK, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsTechData(AnsDayDataEx: PAnsDayDataEx);
var
  keyIndex: integer;
  QuoteType: QuoteTypeEnum;
  QuoteRealTime: IQuoteRealTime;
  QuoteTechData: IQuoteUpdate;
  ivalue: int64;
  SValue: WideString;
  vvalue: OleVariant;
  CodeInfo: PCodeInfo;
begin
  // ȷ���ĸ����͵�
  QuoteType := PeriodToQuoteType(AnsDayDataEx.m_dhHead.m_lKey);

  // ȡ�����¶���
  QuoteTechData := FQuoteDataMngr.QuoteDataObjs[QuoteType, @AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if QuoteTechData <> nil then
  begin
    QuoteTechData.BeginWrite;
    try
      // ȡȫ������
      QuoteTechData.Update(Update_Tech_TechData, int64(@AnsDayDataEx^.m_sdData[0]), AnsDayDataEx^.m_nSize);

      // ���Ƿ� ����������Ҫ��ȡ
      QuoteTechData.DataState(State_Tech_WaitCount, ivalue, SValue, vvalue);
      if ivalue <> 0 then
      begin
        // �ȴ��������
        QuoteTechData.Update(Update_Tech_ResetWaitCount, 0, 0);
        // ���¶���
        CodeInfo := @AnsDayDataEx^.m_dhHead.m_nPrivateKey;
        ReqTechData(ToServerType(CodeInfo^.m_cCodeType), @AnsDayDataEx^.m_dhHead.m_nPrivateKey, QuoteTechData,
          AnsDayDataEx.m_dhHead.m_lKey, ivalue)
      end;
    finally
      QuoteTechData.EndWrite;
    end;

    keyIndex := -1;
    // ֪ͨ ���벿��
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType, QuoteType, nil, keyIndex);
  end;
  // if QuoteType = PERIOD_TYPE_MINUTE1 then
  // begin
  // QuoteTechData := FQuoteDataMngr.QuoteDataObjs[QuoteType_MULTITREND,
  // @AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  // if QuoteTechData <> nil then
  // begin
  // QuoteTechData.Update(Update_Trend_MultiTrendData,
  // int64(@AnsDayDataEx^.m_sdData[0]), AnsDayDataEx^.m_nSize);
  // keyIndex := -1;
  // // ֪ͨ ���벿��
  // QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  // if QuoteRealTime <> nil then
  // with AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode do
  // keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
  // CodeInfoToCode(@AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode)];
  //
  // // ֪ͨ���ݵ���
  // if keyIndex <> -1 then
  // DoActiveMessage(QuoteType_MULTITREND, QuoteType_MULTITREND, nil,
  // keyIndex);
  // end;
  // end;
end;

// �ǵ�ͣ���� ����
procedure TQuoteBusiness.ReqSeverCalculate(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  pCodes: PCodeInfo;
begin
  if Count = 0 then
    exit;
  AskData := GetAskData(nil);
  pCodes := GetCodeInfos(@CodeInfos[0], Count);
  AskData.m_nType := RT_SEVER_CALCULATE;
  AskData.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, pCodes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// �ǵ�ͣ���� Ӧ��
procedure TQuoteBusiness.AnsSeverCalculate(AnsSeverCalculate: PAnsSeverCalculate);
var
  Update: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex, i: integer;
  KeysIndex: int64;
  p: PSeverCalculateData;
  Keys: TIntegerList;
begin
  if AnsSeverCalculate.m_nSize < 1 then
    exit;
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    Update := FQuoteDataMngr.QuoteRealTime as IQuoteUpdate;
    Update.Update(Update_RealTime_Server_Calc, int64(AnsSeverCalculate), 0);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    p := @AnsSeverCalculate.SeverCalculateData[0];
    for i := 0 to AnsSeverCalculate.m_nSize - 1 do
    begin
      keyIndex := QuoteRealTime.CodeToKeyIndex[p.m_ciStockCode.m_cCodeType, CodeInfoToCode(@p.m_ciStockCode)];
      Keys.Add(keyIndex);
      StocksBit64Index(KeysIndex, keyIndex);
      inc(p);
    end;
    DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
  finally
    QuoteRealTime := nil;
    Keys.Free;
  end;
end;

// ���ɷ�ʱ  Ӧ��
procedure TQuoteBusiness.AnsTrend(AnsTrendData: PAnsTrendData);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    TrendUpdate.Update(Update_Trend_TrendData, int64(AnsTrendData), AnsTrendData.m_nHisLen);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsTrend_Ext(AnsTrendData: PAnsTrendData_Ext);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    TrendUpdate.Update(Update_Trend_TrendData_Ext, int64(AnsTrendData), AnsTrendData.m_nHisLen);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.ReqForeignBASEINFO(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);
  AskData^.m_nType := RT_BOND_BASE_INFO_IB;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, nil, nil, SizeOf(TAskData), 0, 0);
end;

procedure TQuoteBusiness.ReqForeignTECHDATA(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate;
  Period: short; nDay: Word);
var
  AskData: PAskData;
  ReqIBTechData: PReqIBTechData;
begin
  // ������æµ��׼ �������������ϲ� ���������������

  // ȡ���ӽ��쿪ʼ��Ч������
  { TechData.DataState(State_Tech_DataLen, StateCount, SValue, OValue);
    if nDay < StateCount then  begin//��Ҫ�����ݱȻ������ݶ� ȫ����ȡ
    //1���� 5���Ӷ�Ҫ����ȡ     Max(������, ������)
    if Period <> PERIOD_TYPE_DAY then begin
    nDay := StateCount;   // ����� 1 ���� 5���� ȡһ�� �ͻᲹ���µ����ݻ���
    //�����߲�Ҫ��ȡ
    end else nDay := 0;
    end; }

  if nDay > 0 then
  begin

    // ���æµ
    // TechData.Update(Update_Tech_Busy, 0, 0);

    // �̺����
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // CodeInfo ��
    GetMemEx(Pointer(ReqIBTechData), SizeOf(TReqIBTechData));
    FillMemory(Pointer(ReqIBTechData), SizeOf(TReqIBTechData), 0);

    // Э�鶨��������,���Ǵ�ͷȡ���� ��������ȡ,
    // ������ 1������ 5�����ߵ�����,���ݳ��ȱ仯 ʵ������������
    // ���Զ���ͷ��ʼȡ(�˷Ѱ�)

    ReqIBTechData^.m_ciCode := CodeInfo^;
    ReqIBTechData^.m_nDataType := 1; // �������ͣ�1Ϊ���ۣ�2Ϊ���������ʣ�3Ϊ��ծ��ֵ

    ReqIBTechData^.m_cPeriod := PERIOD_TYPE_DAY;
    ReqIBTechData^.m_lBeginPosition := 0; // �����ڿ�ʼ
    ReqIBTechData^.m_nSize := nDay; // ���ٸ�

    // ��վ��Ϣ
    AskData^.m_nType := RT_TECHDATA_IB;

    // ��������״̬
    AskData^.m_lKey := Period;

    // if StateCount = 0 then AskData^.m_nIndex := 1  //ȡȫ������
    // else AskData^.m_nIndex := 2;    //ȡ��������

    AskData^.m_nSize := FloorSize(SizeOf(TReqDayData), SizeOf(TCodeInfo));
    AskData^.m_nPrivateKey.m_pCode := ReqIBTechData^.m_ciCode;
    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqIBTechData), nil,
      SizeOf(TAskData), SizeOf(TReqIBTechData), 0);
  end;
end;

procedure TQuoteBusiness.ReqForeignTRANS(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  ReqIBTrans: PReqIBTrans;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqIBTrans), SizeOf(TReqIBTrans));

  ReqIBTrans.m_ciStockCode := CodeInfo^;
  ReqIBTrans.m_nSize := 0;

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_TRANS_IB;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqIBTrans, nil, SizeOf(TAskData),
    SizeOf(TReqIBTrans), 0);

end;

procedure TQuoteBusiness.ReqIBTREND(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // ���鱨�۱�
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // ��ȡ������ ��������Ϣ
  AskData^.m_nType := RT_TREND_IB;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);

end;

procedure TQuoteBusiness.ReqForeignUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // �ͻ��˵�¼
    AskData^.m_nType := RT_LOGIN_FOREIGN;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stForeign), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqFutuesUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // �ͻ��˵�¼
    AskData^.m_nType := RT_LOGIN_FUTURES;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stFutues), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // �ͻ��˵�¼

    AskData^.m_nType := RT_LOGIN;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex, Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

// ���ɵ�½����
procedure TQuoteBusiness.ReqUSStockUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);
    // �ͻ��˵�¼
    AskData^.m_nType := RT_LOGIN_US;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));
    AskData.m_nPrivateKey.m_pCode.m_cCodeType := US_MARKET;
    // CopyMemory(@AskData.m_nPrivateKey.m_pCode.m_cCode[0],@US_Login_Flag[1],Length(US_Login_Flag));

    FQuoteService.SendData(FQuoteService.TCPIndex(stUSStock), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

// DDE��½����
procedure TQuoteBusiness.ReqDDEUserLogin();
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // �ͻ��˵�¼
    AskData^.m_nType := RT_Login_DDE;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqDelayAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // ��ʱ��չ����
  AskData^.m_nType := RT_AUTOPUSH_EXT_DELAY;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqLevelUserLogin;
var
  AskData: PAskData;
  Data: PAnsiChar;
  Biz2Packer: TBiz2Packer;
begin
  Biz2Packer := TBiz2Packer.Create;
  try
    Biz2Packer.BeginPack;
    Biz2Packer.AddStringField('c_login_type', 255);
    Biz2Packer.AddStringField('vc_user', 255);
    Biz2Packer.AddStringField('vc_user_pw', 255);

    Biz2Packer.Field['c_login_type'].Value := '1';

    Biz2Packer.Field['vc_user'].Value := FQuoteDataMngr.LevelUser; // '1017';
    Biz2Packer.Field['vc_user_pw'].Value := FQuoteDataMngr.LevelPass; // '1017';
    Biz2Packer.EndPack();

    GetMemEx(Data, Biz2Packer.DataLength);
    CopyMemory(Data, Biz2Packer.GetData, Biz2Packer.DataLength);

    // �ͻ��˵�¼
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    AskData^.m_nType := RT_LOGIN_LEVEL;
    AskData^.m_nSize := Biz2Packer.DataLength;
    // FloorSize(Biz2Packer.DataLength , Sizeof(TCodeInfo));
    AskData^.m_Oper.m_cOperator := AnsiChar(Login_Option_Password);

    FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), Pointer(AskData), Data, nil, SizeOf(TAskData),
      Biz2Packer.DataLength, 0);

  finally
    Biz2Packer.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommLevelRealTime(RealTimeDataLevel: PRealTimeDataLevel; Count: integer;
  Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
begin

  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
      RealTimeUpdate.BeginWrite; // д�뿪ʼ
      try
        // ��ȡ  IQuoteUpdate ��ʼ��������
        RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

        for i := 0 to Count - 1 do
        begin
          // Codeinfo
          keyIndex := QuoteRealTime.CodeToKeyIndex[RealTimeDataLevel^.m_ciStockCode.m_cCodeType,
            CodeInfoToCode(@RealTimeDataLevel^.m_ciStockCode)];
          // ����
          if keyIndex >= 0 then
          begin
            RealTimeUpdate.Update(Update_RealTime_Level_RealTimeData, int64(RealTimeDataLevel), 0);
            if Codes <> nil then
              Codes^[i] := RealTimeDataLevel^.m_ciStockCode;
            Keys.Add(keyIndex);
            StocksBit64Index(KeysIndex, keyIndex);
          end;

          // ʵ����� λ������

          inc(IntPtr(RealTimeDataLevel), SizeOf(TRealTimeDataLevel));
        end;
      finally
        RealTimeUpdate.EndWrite;
        RealTimeUpdate := nil;
      end;
      // ֪ͨ���ݵ���
      DoActiveMessage(QuoteType_Level_REALTIME, QuoteType_Level_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommRealTime(CommRealTimeData: PCommRealTimeData; Count: integer; Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
  OffSet: integer;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
      RealTimeUpdate.BeginWrite; // д�뿪ʼ
      try
        // ��ȡ  IQuoteUpdate ��ʼ��������
        // RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
        for i := 0 to Count - 1 do
        begin
          // Codeinfo
          keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
            CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];
          // ����
          if keyIndex >= 0 then
          begin
            // ָ���ɽ��λ��ΪԪ
            if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
              (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
              HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
            begin
              // ָ���ɽ����԰�ԪΪ��λ
              CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice :=
                CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice * 100;
            end;

            RealTimeUpdate.Update(Update_RealTime_RealTimeData, int64(CommRealTimeData), 0);
            if Codes <> nil then
              Codes^[i] := CommRealTimeData^.m_ciStockCode;
            Keys.Add(keyIndex);
            StocksBit64Index(KeysIndex, keyIndex);
          end;
          if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // ָ��
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIndexRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, HK_MARKET) then // ���
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSHKStockRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OPT_MARKET) then // ������Ȩ
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSOPTRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // �ڻ�
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSQHRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
          begin
            if HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // ���м�
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIBRealTime))
            else // ���
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSWHRealTime));
          end
          else
          begin
            if HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX) then
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIndexRealTime))
            else // A B ��
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime));
          end;
        end;
      finally
        RealTimeUpdate.EndWrite;
        RealTimeUpdate := nil;
      end;
      // ֪ͨ���ݵ���
      DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommRealTime_EXT(CommRealTimeData_Ext: PCommRealTimeData_Ext; Count: integer;
  Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
  OffSet: integer;
begin
  KeysIndex := 0;
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  if QuoteRealTime = nil then
    exit;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);

    // ��ȡ  IQuoteUpdate ��ʼ��������
    RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
    RealTimeUpdate.BeginWrite; // д�뿪ʼ
    try
      for i := 0 to Count - 1 do
      begin
        // Codeinfo
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData_Ext^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData_Ext^.m_ciStockCode)];
        // ����
        if keyIndex >= 0 then
        begin
          // ָ���ɽ��λ��ΪԪ
          if { HSMarketType(CommRealTimeData_ext.m_ciStockCode.m_cCodeType,OTHER_MARKET) or }
          // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
            (HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
            HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          begin
            // ָ���ɽ����԰�ԪΪ��λ
            CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
              CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
          end;

          RealTimeUpdate.Update(Update_RealTime_RealTimeDataExt, int64(CommRealTimeData_Ext), 0);
          if Codes <> nil then
            Codes^[i] := CommRealTimeData_Ext^.m_ciStockCode;
          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;
        if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // ָ��
          // CommRealTimeData_ext := PCommRealTimeData_Ext(int64(CommRealTimeData_ext) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
            SizeOf(THSStockRealTime_Ext))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, HK_MARKET) then // ���
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
            SizeOf(THSHKStockRealTime_EXT))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, OPT_MARKET) then // ������Ȩ
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSOPTRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // �ڻ�
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSQHRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, US_MARKET) then // ����
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSUSStockRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          if HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // ���м�
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSIBRealTime))
          else // ���
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSWHRealTime));
        end
        else
        begin
          if HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSStockRealTime_Ext))
          else // A B ��
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSStockRealTime_Ext));
        end;
      end;
    finally
      RealTimeUpdate.EndWrite;
      RealTimeUpdate := nil;
    end;
    // ֪ͨ���ݵ���
    DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
  finally
    Keys.Free;
    QuoteRealTime := nil;
  end;
end;

procedure TQuoteBusiness.UpdateCommRealTime_Int64EXT(CommRealTimeData_Ext: PCommRealTimeInt64Data_Ext; Count: integer; Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
  OffSet: integer;
begin
  KeysIndex := 0;
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  if QuoteRealTime = nil then
    exit;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherInt64Data) + 2 * SizeOf(uShort);

    // ��ȡ  IQuoteUpdate ��ʼ��������
    RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
    RealTimeUpdate.BeginWrite; // д�뿪ʼ
    try
      for i := 0 to Count - 1 do
      begin
        // Codeinfo
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData_Ext^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData_Ext^.m_ciStockCode)];
        // ����
        if keyIndex >= 0 then
        begin
          // ָ���ɽ��λ��ΪԪ
          if { HSMarketType(CommRealTimeData_ext.m_ciStockCode.m_cCodeType,OTHER_MARKET) or }
          // ����ָ��������ָ���������顢������ɽ���ĵ�λΪԪ
            (HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
            HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          begin
            // ָ���ɽ����԰�ԪΪ��λ
            CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
              CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
          end;

          RealTimeUpdate.Update(Update_RealTime_RealTimeInt64DataExt, int64(CommRealTimeData_Ext), 0);
          if Codes <> nil then
            Codes^[i] := CommRealTimeData_Ext^.m_ciStockCode;
          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // ָ��
          // CommRealTimeData_ext := PCommRealTimeData_Ext(int64(CommRealTimeData_ext) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData_Ext := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData_Ext) + OffSet +
            SizeOf(THSIndexRealTime_Int64Ext))
        else
        begin
          if HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData_Ext := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSIndexRealTime_Int64Ext))
          else // A B ��
            CommRealTimeData_Ext := PCommRealTimeInt64Data_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSStockRealTime_Int64Ext));
        end;
      end;
    finally
      RealTimeUpdate.EndWrite;
      RealTimeUpdate := nil;
    end;
    // ֪ͨ���ݵ���
    DoActiveMessage(QuoteType_REALTIMEInt64, QuoteType_REALTIMEInt64, Keys, KeysIndex);
  finally
    Keys.Free;
    QuoteRealTime := nil;
  end;
end;

procedure TQuoteBusiness.WriteFile(const FileName: string; buff: Pointer; Size: integer);
var
  FileStrm: TFileStream;
begin
  if Size > 0 then
  begin
    // ɾԭ�ȵ��ļ�
    if FileExists(FileName) then
      DeleteFile(FileName);

    FileStrm := TFileStream.Create(FileName, fmCreate);
    try
      FileStrm.Write(buff^, Size)
    finally
      FileStrm.Free;
    end;
  end;
end;

procedure TQuoteBusiness.AnsForeignBASEINFO(AnsIBBondBaseInfoData: PAnsIBBondBaseInfoData);
begin
  FQuoteService.WriteDebug('AnsForeignBASEINFO:' + inttostr(AnsIBBondBaseInfoData.m_nSize));

end;

procedure TQuoteBusiness.AnsForeignTECHDATA(AnsIBTechData: PAnsIBTechData);
begin
  FQuoteService.WriteDebug('AnsIBTechData:' + inttostr(AnsIBTechData.m_nSize));
end;

procedure TQuoteBusiness.AnsForeignTRANS(AnsIBTransData: PAnsIBTransData);
begin
  FQuoteService.WriteDebug('AnsIBTransData:' + inttostr(AnsIBTransData.m_nSize));
end;

procedure TQuoteBusiness.AnsIBTREND(AnsIBTrendData: PAnsIBTrendData);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    // TrendUpdate.Update(Update_Trend_TrendData, Int64(@AnsIBTrendData^.m_pVolData), AnsIBTrendData^.m_nCount);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // ֪ͨ���ݵ���
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsForeignUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('Foreign ��½�ɹ�!');
  FQuoteService.SendEvent(etLoginForeign, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsFutuesUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('Futues ��½�ɹ�!');
  FQuoteService.SendEvent(etLoginFutues, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('��½�ɹ�!');
  FQuoteService.SendEvent(etLogin, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsUSStockUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('���ɵ�½�ɹ�!');
  FQuoteService.SendEvent(etLoginUSStock, nil, '', 0, 0);
end;

// DDE��½Ӧ��
procedure TQuoteBusiness.AnsDDEUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('DDE��½�ɹ�!');
  FQuoteService.SendEvent(etLoginDDE, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsDelayAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);
var
  i, OffSet: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData_Ext;
  Keys: TIntegerList;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // ��ȡ QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // ��ȡ  IQuoteUpdate ��ʼ��������
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        // ���·�ʱ��
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_DelayAutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // ʵ����� λ������  ָ��
        if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, US_MARKET) then // ����
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSUSStockRealTimeDelay));
      end;

      // ���ݵ���֪ͨ
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsLevelUserLogin(AnsLogin: PAnsLogin);
var
  nErrorNO: integer;
  strErrorInfo: string;
  BizUnpacker: TBiz2Unpacker;
  l_user_no: string;
  vc_User_Nickname: string;
  vc_Product_Name: string;
  vc_service_name: string;
  l_pro_end_date: integer;
  l_date: integer;
  c_pro_status: string;
begin
  if AnsLogin^.m_nError = 0 then
  begin
    nErrorNO := 0;
    strErrorInfo := '';
    l_pro_end_date := 0;
    l_date := 0;
    BizUnpacker := TBiz2Unpacker.Create;
    try
      BizUnpacker.Open(@AnsLogin^.m_szRet[0], AnsLogin^.m_nSize);
      if BizUnpacker.Exist['error_no'] then
      begin

        nErrorNO := BizUnpacker.Field['error_no'].Value;
        strErrorInfo := BizUnpacker.Field['error_info'].Value;
      end
      else if BizUnpacker.Exist['l_user_no'] then
      begin

        l_user_no := BizUnpacker.Field['l_user_no'].Value;
        vc_User_Nickname := BizUnpacker.Field['vc_User_Nickname'].Value;
        vc_Product_Name := BizUnpacker.Field['vc_Product_Name'].Value;
        vc_service_name := BizUnpacker.Field['vc_service_name'].Value;
        l_pro_end_date := BizUnpacker.Field['l_pro_end_date'].Value;
        l_date := BizUnpacker.Field['l_date'].Value;
        c_pro_status := BizUnpacker.Field['c_pro_status'].Value;
      end;

      if nErrorNO = 0 then
      begin
        FQuoteService.WriteDebug
          (format('Level2 ��½�ɹ�! no:%s Nickname:%s Product_Name:%s service_name:%s end_date:%d date:%d status:%s',
          [l_user_no, vc_User_Nickname, vc_Product_Name, vc_service_name, l_pro_end_date, l_date, c_pro_status]));

        FQuoteService.SendEvent(etLoginLevel, nil, '', 0, 0);
        DoResetMessage(stStockLevelII);
      end
      else
      begin
        FQuoteService.WriteDebug(format('[level2��¼ʧ��]�����:%d��������Ϣ:%s', [nErrorNO, strErrorInfo]));

      end;
    finally
      BizUnpacker.Free;
    end;
  end;
end;

end.
