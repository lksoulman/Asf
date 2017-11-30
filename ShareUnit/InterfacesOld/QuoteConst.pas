unit QuoteConst;

interface

uses Windows, Messages;

const

  SH_MajorIndex_HSCODE = '1A0001'; // ��ָ֤����������
  SZ_MajorIndex_HSCODE = '2A01'; // ��֤��ָ��������

  MaxCount = 100000;
  MAX_MULTITREND_COUNT = 10;

  PATH_Setting = 'Setting\'; // ��������Ŀ¼��
  PATH_Block = 'Block\'; // ϵͳ���Ŀ¼��
  PATH_UserBlock = 'UserBlock\'; // �û����Ŀ¼��
  PATH_Data = 'Data\'; // ����Ŀ¼��

  PATH_Data_SH_Day = 'Data\sh\day\';
  PATH_Data_SH_min1 = 'Data\sh\min1\';
  PATH_Data_SH_min5 = 'Data\sh\min5\';

  PATH_Data_SZ_Day = 'Data\sz\day\';
  PATH_Data_SZ_min1 = 'Data\sz\min1\';
  PATH_Data_SZ_min5 = 'Data\sz\min5\';

  EX_RIGHT_FILE = 'exright.dat'; // ��Ȩ�����ļ�
  CURRENT_FINANCE_FILE = 'curfinance.fin'; // ���²�������
  HIS_FINANCE_DAT_FILE = 'hisfinance.dat'; // ��ʷ���񱨱������ļ�
  BLOCK_DEF_FILE = 'block.def';

  PYJC_MAX_LENGTH = 16; // ƴ������
  STOCK_NAME_SIZE = 16; // ��Ʊ���Ƴ���
  MAX_HQCOL_COUNT = 8; // RT_HQCOL_VALUE һ�β�ѯ����������ֶ���

  // Update_RealTime begin
  // ��������
  Update_RealTime_Codes_SetData = $0002;
  // ��Ȩ����
  Update_RealTime_ExRight_SetData = $0003;
  // ��������
  Update_RealTime_Finance_SetData = $0004;
  // ������������
  Update_RealTime_RealTimeData = $0005;
  // ����Level2 ������
  Update_RealTime_Level_RealTimeData = $0006;

  Update_RealTime_RealTimeDataExt = $0007;

  Update_RealTime_Server_Calc = $0008;

  Update_RealTime_DelayDataExt = $0009;

  // Update_RealTime end

  // Update_TechData begin
  // ������ʱ����
  Update_Trend_TrendData = $0001;

  Update_Trend_TrendData_Ext = $0008;
  // ��������
  Update_Trend_AutoPush = $0002;
  // ��ʷ��ʱ
  Update_Trend_HisTrendData = $0003;

  Update_Trend_MultiHisTrendData = $0004;

  Update_Trend_MAjorIndexLeadData = $0005;

  Update_Trend_MAjorIndexTickData = $0006;

  Update_Trend_VirtualAuction = $0007;

  Update_Trend_AutoPush_Ext = $0009;

  Update_Trend_DelayAutoPush_Ext = $000A;
  // Update_TechData end

  // Update_StockTick begin
  // �����ֱ�����
  Update_StockTick_StockTickData = $0001;
  // ��������
  Update_StockTick_AutoPush = $0002;

  Update_StockTick_AutoPush_Ext = $0003;
  // Update_StockTick  end;

  // Update_Tech begin
  // ������ǰ����
  Update_Tech_TechData = $0001;
  // ������ʷ����
  Update_Tech_DiffData = $0002;
  // ��������
  Update_Tech_AutoPush = $0003;

  Update_Tech_Busy = $0004;

  Update_Tech_WaitCount = $0005;

  Update_Tech_ResetWaitCount = $0006;

  Update_Tech_TechCurrData = $0007;

  Update_Tech_AutoPush_Ext = $0008;

  // ���ݳ���
  State_Tech_DataLen = $0101;
  // �汾��
  State_Tech_VarCode = $0102;

  State_Tech_IsBusy = $0103;

  State_Tech_WaitCount = $0104;
  // Update_Tech end

  // Update_ReprotSort begin
  Update_ReprotSort_Data = $0001;
  // Update_ReprotSort end

  // Update_GeneralSort begin
  Update_GeneralSort_ReqGeneralSort = $0001;

  Update_GeneralSort_Data = $0002;

  State_GeneralSort_RefCount = $0101;

  // Update_GeneralSort end

  // Update_Transaction begin
  Update_Transaction_Data = $0001;
  Update_TransactionAuto_Data = $0002;

  // Update_Transaction end

  // Update_OrderQueue begin
  Update_OrderQueue_Data = $0001;

  // Update_OrderQueue end

  // Update_TOTALMAX begin
  Update_TOTALMAX_Data = $0001;
  Update_TOTALMAXAuto_Data = $0002;
  // Update_TOTALMAX end

  // Update_SINGLEMA begin
  Update_SINGLEMA_Data = $0001;
  Update_SINGLEMAAuto_Data = $0002;
  // Update_SINGLEMA end
  RT_BEGIN = $0100;
  RT_END = $8FFF;

  BLOCK_NAME_LENGTH = 32;

  RT_COMPASKDATA = $8FFE; // �����������
  RT_ZIPDATA = $8001; // ѹ�����ذ�����

  RT_JAVA_MARK = $0010; // JAVA��¼ | RT_LOGIN_*
  RT_WINCE_MARK = $0020; // WINCE��¼ | RT_LOGIN_*
  RT_NOTZIP = $0040; // ��ʹ��ѹ�����ݴ���
  RT_DEBUG = $0080; // ��¼�ͻ�������־ maxy add 20090908

  RT_INITIALINFO = $0101; // �ͻ����������г�ʼ��
  RT_LOGIN = $0102; // �ͻ��˵�¼���������
  RT_SERVERINFO = $0103; // ��վ��Ϣ
  RT_BULLETIN = $0104; // ��������(����)
  RT_PARTINITIALINFO = $0105; // �ͻ������ݲ��ֳ�ʼ��
  RT_ETF_INIT = $0106; // 52ֻ��Ʊ����(ETF)
  RT_LOGIN_HK = $0107; // �ͻ��˵�¼�۹ɷ�����
  RT_LOGIN_FUTURES = $0108; // �ͻ��˵�¼�ڻ�������
  RT_LOGIN_FOREIGN = $0109; // �ͻ��˵�¼��������
  RT_LOGIN_WP = $010A; // �ͻ��˵�¼���̷�����
  RT_LOGIN_INFO = $010B; // �ͻ��˵�¼��Ѷ������
  RT_CHANGE_PWD = $010C; // �޸�����

  // ghm add level2 ��½����
  RT_LOGIN_LEVEL = $010D; // level2��½����
  RT_SERVERINFO2 = $010E; // ��վ��Ϣ2
  RT_VERIFYINFO = $010F; // �û���֤��Ϣ����
  RT_MODIFY_LV2PWD = $0112; // �޸�Level2�û�����
  RT_DISCONNLEVEL2 = $0113; // level2����
  RT_INITIALINFO_VARCODE = $0134; // �䳤����ĳ�ʼ����Ϣ
  RT_LOGIN_DDE = $0122; // �ͻ��˵�¼DDE���������
  RT_LOGIN_US = $0124; // ���ɵ�½���������

  RT_REALTIME = $0201; // ���鱨�۱�:1-6Ǭ¡������
  RT_DYNREPORT = $0202; // ǿ������;ָ������;���Ű�����;�������;����ƹ�Ʊ�б�����;Ԥ��
  RT_REPORTSORT = $0203; // �������۱�:61-66�����������
  RT_GENERALSORT = $0204; // �ۺ���������:81-86
  RT_GENERALSORT_EX = $0205; // �ۺ���������:81-86�����Զ����������
  RT_SEVER_EMPTY = $0206; // �����������ݷ��ؿհ�
  RT_SEVER_CALCULATE = $0207; // �������������ݰ�,������ͣ����ͣ
  RT_ANS_BYTYPE = $0208; // �������ͷ������ݰ�
  RT_QHMM_REALTIME = $0209; // �ڻ�������
  RT_LEVEL_REALTIME = $020A; // level
  RT_CLASS_REALTIME = $020B; // ���ݷ�������ȡ���鱨��
  // ghm add level2�������ݲ�ѯ��Ϣ
  RT_LEVEL_ORDERQUEUE = $020C; // level2��������
  RT_LEVEL_TRANSACTION = $020D; // LEVEL2��ʳɽ�
  RT_QHARB_REALTIME = $020E; // �ڻ��������� maxy add
  RT_REALTIME_EXT = $020F; // ��չ�����鱨���� maxy add

  RT_REALTIME_EXT_DELAY = $0223; // ����������ʱ

  RT_QZINFO = $0211; // Ȩ֤��Ϣ

  RT_HQCOL_VALUE = $0216; // ��������ID��ѯ�����ֶ�ֵ

  RT_TREND = $0301; // ��ʱ����
  RT_ADDTREND = $0302; // ����ͼ���ӡ����ͬ��
  RT_BUYSELLPOWER = $0303; // ��������
  RT_HISTREND = $0304; // ��ʷ����;���շ�ʱ;��Сͼ�·�ʱ����
  RT_TICK = $0305; // TICKͼ
  RT_ETF_TREND = $0306; // ETF��ʱ����
  RT_ETF_NOWDATA = $0307; // ETFʱʱ����
  RT_ETF_TREND_TECH = $0308; // ETFtech��ʱ����
  RT_HISTREND_INDEX = $0309; // ���ڴ�������-��ʷ����;���շ�ʱ;��Сͼ�·�ʱ����
  RT_AUTOARBPUSH = $030A; // �ڻ��������� maxy add
  RT_TREND_EXT = $030B; // ��չ�ķ�ʱ���� maxy add
  RT_VIRTUAL_AUCTION = $030E; // ���Ͼ�����������

  RT_TECHDATA = $0400; // �̺����
  RT_FILEDOWNLOAD = $0401; // �ļ������̺��������أ�
  RT_TECHDATA_EX = $0402; // �̺������չ -- ֧�ֻ���ֵ
  RT_DATA_WEIHU = $0403; // ����ά������
  RT_FILEDOWNLOAD2 = $0404; // ���ط�����ָ��Ŀ¼�ļ�
  RT_FILED_CFG = $0405; // �����ļ�����/����
  RT_FILL_DATA = $0406; // ���ߴ���
  RT_TECHDATA_BYPERIOD = $0407; // �̺������չ -- ֧�ֲ�ͬ����ת��
  RT_TECHDATA_INCREMENT = $0408; // �̺������չ -- ������������
  RT_TECHDATA_RANGE = $0410; // �ֶ��̺���� add by maxy 20090714

  RT_MARKET_MONITOR_SUPPORT_QUERY = $0907; // ���߾���֧���г���ѯУ��
  RT_MARKET_MONITOR_AUTOPUSH = $0A17; // ���߾�������
  RT_MARKET_MONITOR_STOCK_QUERY = $0908; // ��ѯ��ֻ��Ʊ���ж��߾����¼�
  RT_MARKET_MONITOR_DATE_QUERY = $0909; // �����ں��г���ѯ���߾����¼�

  RT_TEXTDATAWITHINDEX_PLUS = $0501; // ������Ѷ��������
  RT_TEXTDATAWITHINDEX_NEGATIVE = $0502; // ������Ѷ��������
  RT_BYINDEXRETDATA = $0503; // ��Ѷ��������
  RT_USERTEXTDATA = $0504; // �Զ�����Ѷ������˵��ȣ�
  RT_FILEREQUEST = $0505; // �����ļ��ļ�
  RT_FILESimplify = $0506; // �����ļ�����
  RT_ATTATCHDATA = $0507; // ��������
  RT_PROMPT_INFO = $0508; // ���������õ���ʾ��Ϣ
  RT_CODELINK_INFO = $0509; // ������Ʊ maxy add

  RT_STOCKTICK = $0601; // ���ɷֱʡ�������ϸ�ķֱ�����
  RT_BUYSELLORDER = $0602; // ����������
  RT_LIMITTICK = $0603; // ָ�����ȵķֱ�����
  RT_HISTORYTICK = $0604; // ��ʷ�ķֱ�����
  RT_MAJORINDEXTICK = $0605; // ������ϸ
  RT_VALUE = $0606; // ��Сͼ��ֵ��
  RT_BUYSELLORDER_HK = $0607; // ����������(�۹ɣ�
  RT_BUYSELLORDER_FUTURES = $0608; // ����������(�ڻ���
  RT_VALUE_HK = $0609; // ��Сͼ��ֵ��(�۹�),��СͼҲ��������
  RT_VALUE_FUTURES = $060A; // ��Сͼ��ֵ��(�ڻ�),����СͼҲ��������
  RT_TOTAL = $060B; // �ܳ������

  RT_LEAD = $0702; // ��������ָ��
  RT_MAJORINDEXTREND = $0703; // ��������
  RT_MAJORINDEXADL = $0704; // �������ƣ�ADL
  RT_MAJORINDEXBBI = $0705; // �������ƣ����ָ��
  RT_MAJORINDEXBUYSELL = $0706; // �������ƣ���������
  RT_SERVERFILEINFO = $0707; // �������Զ�����Ҫ���µ��ļ���Ϣ
  RT_DOWNSERVERFILEINFO = $0708; // ����-�������Զ�����Ҫ���µ��ļ���Ϣ

  RT_CURRENTFINANCEDATA = $0801; // ���µĲ�������
  RT_HISFINANCEDATA = $0802; // ��ʷ��������
  RT_EXRIGHT_DATA = $0803; // ��Ȩ����
  RT_HK_RECORDOPTION = $0804; // �۹���Ȩ
  RT_BROKER_HK = $0805; // �۹ɾ���ϯλ��ί�����;  // �����ǵķ������Ƿ����ɴ�����
  RT_BLOCK_DATA = $0806; // �������
  RT_USER_BLOKC_DATA = $0810;
  RT_STATIC_HK = $0807; // �۹ɾ�̬����

  // zxw add ����������������ݺͳ�Ȩ����
  RT_FINANCE_BYCODE = $0808;
  RT_EXRIGHT_BYCODE = $0809;

  RT_ONE_BLOCKDATA = $0408; // һ�������������

  RT_MASSDATA = $0901; // ��
  RT_SERVERTIME = $0902; // ��������ǰʱ��
  RT_KEEPACTIVE = $0903; // ����ͨ�Ű�
  RT_TEST = $0904; // ����ͨ�Ű�
  RT_TESTSRV = $0905; // ���Կͻ��˵��������Ƿ�ͨ��
  RT_PUSHINFODATA = $0906; // ��Ѷʵʱ����

  RT_AUTOPUSH = $0A01; // ��������;  // ��RealTimeData Ϊ CommRealTimeData
  RT_AUTOPUSHSIMP = $0A02; // ��������;  // ��Ϊ��������
  RT_REQAUTOPUSH = $0A03; // ��������,Ӧ���ڣ�Ԥ���������;  // ��RealTimeData Ϊ CommRealTimeData
  RT_ETF_AUTOPUSH = $0A04; // ETF����
  RT_AUTOBROKER_HK = $0A05; // ��������
  RT_AUTOTICK_HK = $0A06; // �۹ɷֱ�����
  RT_AUTOPUSH_QH = $0A07; // �ڻ���С����
  RT_PUSHREALTIMEINFO = $0A08; // ʵʱ��������
  RT_RAW_AUTOPUSH = $0A09; // ����Դԭʼ��������

  RT_QHMM_AUTOPUSH = $0A0A; // �ڻ�����������
  RT_LEVEL_AUTOPUSH = $0A0B; // level����
  // ghm add level2��������������Ϣ
  RT_LEVEL_BORDERQUEUE_AUTOPUSH = $0A0C; // LEVEL2����������������
  RT_LEVEL_SORDERQUEUE_AUTOPUSH = $0A0D; // LEVEL2������������������
  RT_LEVEL_TRANSACTION_AUTOPUSH = $0A0E; // LEVEL2��ʳɽ�����
  RT_AUTOPUSH_EXT = $0A0F; // ��չ�ĳ������� maxy add

  RT_AUTOPUSH_EXT_DELAY = $0A1F; // ��ʱ��չ���ƣ���Ҫ��������

  // ������������
  RT_DDE_BIGORDER_REALTIME_BYTRANS = $091C;
  RT_DDE_BIGORDER_REALTIME_BYORDER = $0910;
  // ���ɶ�����ʷ��������
  RT_DDE_BIGORDER_HIS = $0911;

  // DDE Level2�������
  RT_DDE_TRANSACTION_BYTRANS = $0912;
  RT_DDE_TRANSACTION_BYORDER = $0913;

  // DDE ί�ж���
  RT_DDE_ORDEQUEUE = $0914;
  // ��ʷDDEָ�������DDX��DDY��DDZ
  // ����DDEָ�꣺����Ʊ����DDE����
  RT_DDE_HISTORY = $0915;
  // ��ʷDDEָ�������DDX��DDY��DDZ
  // ��5��DDX��5��DDY��5��DDZָ�ꣻ60��DDX��60��DDY��60��DDZָ�ꣻ
  // DDXƮ��������10�ڣ���DDXƮ��������������
  // ����DDE���ߣ����Ʊ����DDE���ݣ��г���DDEָ��

  RT_DDE_REALTIME = $0916;

  // ���շ�ʱDDEָ�꣺DDX��DDY��DDZ
  RT_DDE_TREND = $0917;

  // ���ɵ��շ�ʱ��С������ɽ�ͳ������
  RT_DDE_BIGORDER_TREND = $0918;

  // ��ʷ������������ɽ�ͳ������
  // ������ʷ��������ͳ�����ݣ�����������
  RT_DDE_MASS_HISTORY = $0919;

  // ����������������
  RT_DDE_MASS_REALTIME = $091A;

  // ���շ�ʱ������������ɽ�ͳ������
  RT_DDE_MASS_TREND = $091B;

  // Level2������ʣ�������㷨��С����ʶ
  RT_DDE_TRANSACTION_BYTRANS_AUTOPUSH = $0A20;
  // Level2������ʣ������㷨��С����ʶ��
  RT_DDE_TRANSACTION_BYORDER_AUTOPUSH = $0A21;
  // ί�ж��п���
  RT_DDE_ORDERQUEUE_AUTOPUSH = $0A22;
  // ί�ж��������仯��Ϣ
  RT_DDE_ORDERQUEUE_DETAIL_AUTOPUSH = $0A23;
  // ����Level2��ȷ�����ʴ�С��ͳ�ƿ������ݡ���Ҫ���ڸ��������������ͳ�ƽ��档
  RT_DDE_BIGORDER_BYTRANS_AUTOPUSH = $0A24;
  // ��ǰ�𵥴�С��ͳ�ƿ���
  RT_DDE_BIGORDER_BYORDER_AUTOPUSH = $0A25;
  // ���ɾ�����Ϣ
  // ����Level2��ȷ�����һЩ�йش�С�������������ļ����Ϣ�������������󵥡������򵥡����������������Ի��������»���
  RT_DDE_MONITION = $0A26;

  // zxw add level2Cancellation ����
  RT_LEVEL_TOTALMAX_AUTOPUSH = $0A10; // LEVEL2���ʳ�����������
  RT_LEVEL_SINGLEMA_AUTOPUSH = $0A11; // LEVEL2�ۼƳ�����������

  RT_AUTOPUSH_RES = $0A12; // Ԥ���ĳ������� maxy add
  RT_AUTOPUSH_LV2RES = $0A13; // Ԥ����level2���� maxy add

  // zxw add
  RT_LEVEL_TOTALMAX = $2001; // ��ѯ
  RT_LEVEL_SINGLEMAX = $2002;

  RT_UPDATEDFINANCIALDATA = $0B01; // �����Ĳ��񱨱�����
  RT_SYNCHRONIZATIONDATA = $0B02; // ����ͬ������

  //
  RT_Send_Notice = $0C01; // ������
  RT_Send_ScrollText = $0C02; // ���������Ϣ
  RT_Change_program = $0C03; // ���ķ���������
  RT_Send_File_Data = $0C04; // �����ļ���������
  RT_RequestDBF = $0C05; // ����DBF�ļ�

  RT_InfoSend = $0C06; // ������Ϣ
  RT_InfoUpdateIndex = $0C07; // ������Ϣ����
  RT_InfoUpdateOneIndex = $0C08; // ����һ����Ϣ����
  RT_NoteMsgData = $0C09; // ���ƶ������ݴ���
  RT_InfoDataTransmit = $0C0A; // ��֤ת��
  RT_InfoCheckPurview = $0C0B; // ����ע����ϸ������Ϣ
  RT_InfoClickTime = $0C0C; // �������

  RT_REPORTSORT_Simple = $0D01; // �������۱�:61-66����������򣨾���
  RT_PARTINITIALINFO_Simple = $0D02; // ���뷵��
  RT_RETURN_EMPTY = $0D03; // ���ؿյ����ݰ�
  RT_InfoDataRailing = $0D04; // ������Ŀ

  // wince ���
  RT_WINCE_FIND = $0E01; // ���Ҵ���
  RT_WINCE_UPDATE = $0E02; // CE�汾����
  RT_WINCE_ZIXUN = $0E03; // CE��Ѷ����

  RT_Srv_SrvStatus = $0F01; // ��̨��������״̬

  // wince �ͻ���ʹ�õ�Э��
  Session_Socket = $0001; // socket
  Session_Http = $0002; // http

  WINCEZixun_StockInfo = $1000; // ������Ѷ


  // AskData �� m_nOption ָ�������

  // ������Ϣ����
  Notice_Option_WinCE = $0001; // ������Ϣֻ��WinCE�û�//
  Notice_Option_SaveSrv = $0002; // ������Ϣ�ڷ������Զ����档
  Login_Option_Password = $0004; // ��½ʱʹ���µļ��ܷ�ʽ��
  Login_Option_NotCheck = $0008; // ������û���

  // AskData �� m_nOption ָ�������,Ϊ������
  ByType_LevelStatic = $1000; // �������� LevelStatic
  ByType_LevelRealTime = $2000; // �������� LevelRealTime

  // �г�������ת��
  Market_STOCK_MARKET = $0001; // ��Ʊ
  Market_HK_MARKET = $0002; // �۹�
  Market_WP_MARKET = $0004; // ����
  Market_FUTURES_MARKET = $0008; // �ڻ�
  Market_FOREIGN_MARKET = $0010; // ���

  Market_Address_Changed = $0020; // ��ǰ��������Ҫ��ַ�л�
  Market_Client_ForceUpdate = $0040; // ��ǰ�ͻ��˱����������ܹ�ʹ��
  Market_DelayUser = $0080; // ��ǰ�û�Ϊ��ʱ�û����ڸ۹�����ʱʹ��
  Market_TestSrvData = $0100; // �Ƿ�֧�ֲ���
  Market_UserCheck = $0200; // ���������а����û���ѶȨ����Ϣ
  Market_LOGIN_INFO = $0400; // ��Ѷ

  Market_STOCK_LEVEL = $0800; // level2
  Market_SrvInfo = $2000; // ������������Ϣ,�μ��ṹ��TestSrvInfoData

  // Market_SrvLoad = $0800 ;  // ��Ҫ���������ظ�����Ϣ,�μ��ṹ��TestSrvLoadData
  // Market_SrvCheckError = $1000 ;  // ��½��֤������ʧ��

  // Market_STOCK_MARKET_CH = $0100;  // ��Ʊ�ı�
  // Market_HK_MARKET_CH = $0200 ;  // �۹ɸı�
  // Market_WP_MARKET_CH = $0400 ;  // ���̸ı�
  // Market_FUTURES_MARKET_CH = $0800 ;  // �ڻ��ı�
  // Market_FOREIGN_MARKET_CH = $1000 ;  // ���ı�

  // ������
  //
  RT_Srv_Sub_Restart = $0001; // ������������
  RT_Srv_Sub_Replace = $0002; // �滻����

  RT_Srv_Sub_DownCFG = $0003; // ���������ļ�
  RT_Srv_Sub_UpCFG = $0004; // �ϴ������ļ�

  RT_Srv_Sub_DownUserDB = $0005; // �����û������ļ��ļ�
  RT_Srv_Sub_UpUserDB = $0006; // �ϴ��û������ļ��ļ�

  RT_Srv_Sub_DownReport = $0007; // ���غ�̨���򱨸��ļ�
  RT_Srv_Sub_LimitPrompt = $0008; // Ȩ�޴�����ʾ

  RT_Srv_Sub_Succ = $1000; // �����ɹ���ʾ


  // ����/���� DEFINE END

  // ʵʱ���ݰ��롡DEFINE BEGIN
  MASK_REALTIME_DATA_OPEN = $00000001; // ����
  MASK_REALTIME_DATA_MAXPRICE = $00000002; // ��߼�
  MASK_REALTIME_DATA_MINPRICE = $00000004; // ��ͼ�
  MASK_REALTIME_DATA_NEWPRICE = $00000008; // ���¼�

  MASK_REALTIME_DATA_TOTAL = $00000010; // �ɽ���(��λ:��)
  MASK_REALTIME_DATA_MONEY = $00000020; // �ɽ����(��λ:Ԫ)

  MASK_REALTIME_DATA_BUYPRICE1 = $00000040; // �򣱼�
  MASK_REALTIME_DATA_BUYCOUNT1 = $00000080; // ����
  MASK_REALTIME_DATA_BUYPRICE2 = $00000100; // �򣲼�
  MASK_REALTIME_DATA_BUYCOUNT2 = $00000200; // ����
  MASK_REALTIME_DATA_BUYPRICE3 = $00000400; // �򣳼�
  MASK_REALTIME_DATA_BUYCOUNT3 = $00000800; // ����
  MASK_REALTIME_DATA_BUYPRICE4 = $00001000; // �򣴼�
  MASK_REALTIME_DATA_BUYCOUNT4 = $00002000; // ����
  MASK_REALTIME_DATA_BUYPRICE5 = $00004000; // �򣵼�
  MASK_REALTIME_DATA_BUYCOUNT5 = $00008000; // ����

  MASK_REALTIME_DATA_SELLPRICE1 = $00010000; // ������
  MASK_REALTIME_DATA_SELLCOUNT1 = $00020000; // ������
  MASK_REALTIME_DATA_SELLPRICE2 = $00040000; // ������
  MASK_REALTIME_DATA_SELLCOUNT2 = $00080000; // ������
  MASK_REALTIME_DATA_SELLPRICE3 = $00100000; // ������
  MASK_REALTIME_DATA_SELLCOUNT3 = $00200000; // ������
  MASK_REALTIME_DATA_SELLPRICE4 = $00400000; // ������
  MASK_REALTIME_DATA_SELLCOUNT4 = $00800000; // ������
  MASK_REALTIME_DATA_SELLPRICE5 = $01000000; // ������
  MASK_REALTIME_DATA_SELLCOUNT5 = $02000000; // ������

  MASK_REALTIME_DATA_PERHAND = $04000000; // ��/�� ��λ
  MASK_REALTIME_DATA_NATIONAL_DEBT_RATIO = $08000000; // ��ծ����
  // ����Ϊ��32λ  m_lReqMask1 ��ӦStockOtherData�ṹ
  MASK_REALTIME_DATA_TIME = $00000001; // �࿪�̷�����
  MASK_REALTIME_DATA_CURRENT = $00000002; // ����
  MASK_REALTIME_DATA_OUTSIDE = $00000004; // ����
  MASK_REALTIME_DATA_INSIDE = $00000008; // ����
  MASK_REALTIME_DATA_OPEN_POSITION = $00000010; // �񿪲�
  MASK_REALTIME_DATA_CLEAR_POSITION = $00000020; // ��ƽ��
  MASK_REALTIME_DATA_CODEINFO = $10000000; // ����

  // �����ж���˵��
  MASK_REALTIME_DATA_BUYORDER1 = $00000080; // ��1����
  MASK_REALTIME_DATA_BUYORDER2 = $00000100; // ��2����
  MASK_REALTIME_DATA_BUYORDER3 = $00000200; // ��3����
  MASK_REALTIME_DATA_BUYORDER4 = $00000400; // ��4����
  MASK_REALTIME_DATA_BUYORDER5 = $00000800; // ��5����

  MASK_REALTIME_DATA_SELLORDER1 = $00001000; // ��1����
  MASK_REALTIME_DATA_SELLORDER2 = $00002000; // ��2����
  MASK_REALTIME_DATA_SELLORDER3 = $00004000; // ��3����
  MASK_REALTIME_DATA_SELLORDER4 = $00008000; // ��4����
  MASK_REALTIME_DATA_SELLORDER5 = $00010000; // ��5����


  // ʵʱ���ݰ��롡DEFINE END

  // �ۺ����������������� DEFINE BEGIN
  RT_RISE = $0001; // �Ƿ�����
  RT_FALL = $0002; // ��������
  RT_5_RISE = $0004; // 5�����Ƿ�����
  RT_5_FALL = $0008; // 5���ӵ�������
  RT_AHEAD_COMM = $0010; // ��������(ί��)��������
  RT_AFTER_COMM = $0020; // ��������(ί��)��������
  RT_AHEAD_PRICE = $0040; // �ɽ��������������
  RT_AHEAD_VOLBI = $0080; // �ɽ����仯(����)��������
  RT_AHEAD_MONEY = $0100; // �ʽ�������������
  // �ۺ����������������� DEFINE END

  // K��������������� BEGIN
  PERIOD_TYPE_DAY = $0010; // �������ڣ���
  PERIOD_TYPE_MINUTE1 = $00C0; // �������ڣ�1����
  PERIOD_TYPE_MINUTE5 = $0030; // �������ڣ�5����
  PERIOD_TYPE_MINUTE15 = $0040;
  PERIOD_TYPE_MINUTE30 = $0050;
  PERIOD_TYPE_MINUTE60 = $0060;
  PERIOD_TYPE_WEEK = $0080;
  PERIOD_TYPE_MONTH = $0090;

  // K��������������� END

  // ���ڴ���
  OPT_MARKET = $7000; // ������Ȩ

  OPT_SH_BOURSE = $0100; // �Ϻ�
  OPT_SZ_BOURSE = $0200; // ����

  STOCK_MARKET = $1000; // ��Ʊ
  SH_BOURSE = $0100; // �Ϻ�
  SZ_BOURSE = $0200; // ����
  BK_BOURES = $0300; // ���
  SYSBK_BOURSE = $0400; // ϵͳ���
  USERDEF_BOURSE = $0800; // �Զ��壨��ѡ�ɻ����Զ����飩
  GZ_BOURSE = $0C00; // �������г�
  KIND_INDEX = $0000; // ָ��
  KIND_STOCKA = $0001; // A��
  KIND_STOCKB = $0002; // B��
  KIND_BOND = $0003; // ծȯ
  KIND_FUND = $0004; // ����
  KIND_THREEBOAD = $0005; // ����
  KIND_SMALLSTOCK = $0006; // ��С�̹�
  KIND_PLACE = $0007; // ����
  KIND_LOF = $0008; // LOF
  KIND_ETF = $0009; // ETF
  KIND_QuanZhen = $000A; // Ȩ֤
  KIND_VENTURE = $000D; // ��ҵ��

  KIND_OtherIndex = $000E; // ������������࣬��:����ָ��

  SC_Others = $000F; // ���� = $09
  KIND_USERDEFINE = $0010; // �Զ���ָ��

  // �۹��г�
  HK_MARKET = $2000; // �۹ɷ���
  HK_BOURSE = $0100; // �����г�
  GE_BOURSE = $0200; // ��ҵ���г�(Growth Enterprise Market)
  INDEX_BOURSE = $0300; // ָ���г�
  HK_KIND_INDEX = $0000; // ��ָ
  HK_KIND_FUTURES_INDEX = $0001; // ��ָ
  // KIND_Option = $0002	;        // �۹���Ȩ

  HK_KIND_BOND = $0000; // ծȯ
  HK_KIND_MulFund = $0001; // һ�����Ϲ�֤
  HK_KIND_FUND = $0002; // ����
  KIND_WARRANTS = $0003; // �Ϲ�֤
  KIND_JR = $0004; // ����
  KIND_ZH = $0005; // �ۺ�
  KIND_DC = $0006; // �ز�
  KIND_LY = $0007; // ����
  KIND_GY = $0008; // ��ҵ
  KIND_GG = $0009; // ����
  KIND_QT = $000A; // ����

  // �ڻ�����
  FUTURES_MARKET = $4000; // �ڻ�
  DALIAN_BOURSE = $0100; // ����
  KIND_BEAN = $0001; // ����
  KIND_YUMI = $0002; // ��������
  KIND_SHIT = $0003; // ����ʳ��
  KIND_DZGY = $0004; // ���ڹ�ҵ1
  KIND_DZGY2 = $0005; // ���ڹ�ҵ2
  KIND_DOUYOU = $0006; // ������
  KIND_JYX = $0007; // ����ϩ
  KIND_ZTY = $0008; // �����

  SHANGHAI_BOURSE = $0200; // �Ϻ�
  KIND_METAL = $0001; // �Ϻ�����
  KIND_RUBBER = $0002; // �Ϻ���
  KIND_FUEL = $0003; // �Ϻ�ȼ��
  // KIND_GUZHI = $0004;        // ��ָ�ڻ�
  KIND_QHGOLD = $0005; // �Ϻ��ƽ�

  ZHENGZHOU_BOURSE = $0300; // ֣��
  KIND_XIAOM = $0001; // ֣��С��
  KIND_MIANH = $0002; // ֣���޻�
  KIND_BAITANG = $0003; // ֣�ݰ���
  KIND_PTA = $0004; // ֣��PTA
  KIND_CZY = $0005; // ������

  HUANGJIN_BOURSE = $0400; // �ƽ�����
  KIND_GOLD = $0001; // �Ϻ��ƽ�

  GUZHI_BOURSE = $0500; // ��ָ�ڻ�
  KIND_GUZHI = $0001; // ��ָ�ڻ�

  // ����ָ�� ��֤������ָ��
  OTHER_MARKET = $A000; // ����ָ��
  ConceptIndex_BORRSE = $A502; // ����ָ��
  // SW_BOURSE = $0200;   //����ָ��
  ZZ_BOURSE = $0100; // ����/��ָ֤������
  GN_BOURSE = $0500; // ������/������
  ZX_BORRSE = $0800; // ����ָ��

  //ָ�����
  IndexPlate_MARKET = $A505; // ����300ָ����ָ�����

  // ���̴���
  WP_MARKET = $5000; // ����
  WP_INDEX = $0100; // ����ָ��;        // ������
  WP_LME = $0200; // LME;        // ������
  WP_LME_CLT = $0210; // "����ͭ";
  WP_LME_CLL = $0220; // "������";
  WP_LME_CLM = $0230; // "������";
  WP_LME_CLQ = $0240; // "����Ǧ";
  WP_LME_CLX = $0250; // "����п";
  WP_LME_CWT = $0260; // "������";
  WP_LME_CW = $0270; // "����";
  WP_LME_SUB = $0000;

  WP_CBOT = $0300; // CBOT
  WP_NYMEX = $0400; // NYMEX
  WP_NYMEX_YY = $0000; // "ԭ��";
  WP_NYMEX_RY = $0001; // "ȼ��";
  WP_NYMEX_QY = $0002; // "����";

  WP_COMEX = $0500; // COMEX
  WP_TOCOM = $0600; // TOCOM
  WP_IPE = $0700; // IPE
  WP_NYBOT = $0800; // NYBOT
  WP_NOBLE_METAL = $0900; // �����
  WP_NOBLE_METAL_XH = $0000; // "�ֻ�";
  WP_NOBLE_METAL_HJ = $0001; // "�ƽ�";
  WP_NOBLE_METAL_BY = $0002; // "����";

  WP_FUTURES_INDEX = $0A00; // ��ָ
  WP_SICOM = $0B00; // SICOM
  WP_LIBOR = $0C00; // LIBOR
  WP_NYSE = $0D00; // NYSE
  WP_CEC = $0E00; // CEC

  WP_INDEX_AZ = $0110; // "����";
  WP_INDEX_OZ = $0120; // "ŷ��";
  WP_INDEX_MZ = $0130; // "����";
  WP_INDEX_TG = $0140; // "̩��";
  WP_INDEX_YL = $0150; // "ӡ��";
  WP_INDEX_RH = $0160; // "�պ�";
  WP_INDEX_XHP = $0170; // "�¼���";
  WP_INDEX_FLB = $0180; // "���ɱ�";
  WP_INDEX_CCN = $0190; // "�й���½";
  WP_INDEX_TW = $01A0; // "�й�̨��";
  WP_INDEX_MLX = $01B0; // "��������";
  WP_INDEX_SUB = $0000;

  // ������
  FOREIGN_MARKET = $8000; // ���
  WH_BASE_RATE = $0100; // ��������
  WH_ACROSS_RATE = $0200; // �������
  FX_TYPE_AU = $0000; // AU	��Ԫ
  FX_TYPE_CA = $0001; // CA	��Ԫ
  FX_TYPE_CN = $0002; // CN	�����
  FX_TYPE_DM = $0003; // DM	���
  FX_TYPE_ER = $0004; // ER	ŷԪ
  FX_TYPE_HK = $0005; // HK	�۱�
  FX_TYPE_SF = $0006; // SF	��ʿ
  FX_TYPE_UK = $0007; // UK	Ӣ��
  FX_TYPE_YN = $0008; // YN	��Ԫ

  WH_FUTURES_RATE = $0300; // �ڻ�

  YHJZQ_BOURSE = $0200; // ���м���ȯ�г�
  XHCJ_BOURSE = $0300; // ���ò��
  ZYSHG_BOURSE = $0400; // ��Ѻʽ�ع�
  MDSHG_BOURSE = $0500; // ���ʽ�ع�

  // *** ���� *** //
  US_MARKET = $9000; // �����г�
  AMEX_BOURSE = $0100; // ����֤ȯ������(AMEX)
  NYSE_BOURSE = $0200; // ŦԼ֤ȯ������(NYSE)
  NASDAQ_BOURSE = $0300; // ��˹���֤ȯ�г�(NASDAQ)

  COLUMN_BEGIN = 10000;
  COLUMN_END = (COLUMN_BEGIN + 999);
  { �������� COLUMN_HQ_BASE_ DEFINE BEGIN }
  COLUMN_HQ_BASE_BEGIN = COLUMN_BEGIN;
  COLUMN_HQ_BASE_END = (COLUMN_HQ_BASE_BEGIN + 100);

  COLUMN_HQ_BASE_NAME = (COLUMN_HQ_BASE_BEGIN + 47); // ��Ʊ����
  COLUMN_HQ_BASE_OPEN = (COLUMN_HQ_BASE_BEGIN + 48); // ���̼۸�
  COLUMN_HQ_BASE_NEW_PRICE = (COLUMN_HQ_BASE_BEGIN + 49); // �ɽ��۸�
  COLUMN_HQ_BASE_RISE_VALUE = (COLUMN_HQ_BASE_BEGIN + 50); // �ǵ�ֵ
  COLUMN_HQ_BASE_TOTAL_HAND = (COLUMN_HQ_BASE_BEGIN + 51); // ����
  COLUMN_HQ_BASE_HAND = (COLUMN_HQ_BASE_BEGIN + 52); // ����
  COLUMN_HQ_BASE_MAX_PRICE = (COLUMN_HQ_BASE_BEGIN + 53); // ��߼۸�
  COLUMN_HQ_BASE_MIN_PRICE = (COLUMN_HQ_BASE_BEGIN + 54); // ��ͼ۸�
  COLUMN_HQ_BASE_BUY_PRICE = (COLUMN_HQ_BASE_BEGIN + 55); // ����۸�
  COLUMN_HQ_BASE_SELL_PRICE = (COLUMN_HQ_BASE_BEGIN + 56); // �����۸�
  COLUMN_HQ_BASE_RISE_RATIO = (COLUMN_HQ_BASE_BEGIN + 57); // �ǵ���
  COLUMN_HQ_BASE_CODE = (COLUMN_HQ_BASE_BEGIN + 58); // ��Ʊ����

  COLUMN_HQ_BASE_PRECLOSE = (COLUMN_HQ_BASE_BEGIN + 59); // ����
  COLUMN_HQ_BASE_VOLUME_RATIO = (COLUMN_HQ_BASE_BEGIN + 60); // ����
  COLUMN_HQ_BASE_ORDER_BUY_PRICE = (COLUMN_HQ_BASE_BEGIN + 61); // ί���
  COLUMN_HQ_BASE_ORDER_BUY_VOLUME = (COLUMN_HQ_BASE_BEGIN + 62); // ί����
  COLUMN_HQ_BASE_ORDER_SELL_PRICE = (COLUMN_HQ_BASE_BEGIN + 63); // ί����
  COLUMN_HQ_BASE_ORDER_SELL_VOLUME = (COLUMN_HQ_BASE_BEGIN + 64); // ί����
  COLUMN_HQ_BASE_IN_HANDS = (COLUMN_HQ_BASE_BEGIN + 65); // ����
  COLUMN_HQ_BASE_OUT_HANDS = (COLUMN_HQ_BASE_BEGIN + 66); // ����
  COLUMN_HQ_BASE_MONEY = (COLUMN_HQ_BASE_BEGIN + 67); // �ɽ����
  COLUMN_HQ_BASE_RISE_SPEED = (COLUMN_HQ_BASE_BEGIN + 68); // ���٣����ã�
  COLUMN_HQ_BASE_AVERAGE_PRICE = (COLUMN_HQ_BASE_BEGIN + 69); // ����
  COLUMN_HQ_BASE_RANGE = (COLUMN_HQ_BASE_BEGIN + 70); // ���
  COLUMN_HQ_BASE_ORDER_RATIO = (COLUMN_HQ_BASE_BEGIN + 71); // ί��
  COLUMN_HQ_BASE_ORDER_DIFF = (COLUMN_HQ_BASE_BEGIN + 72); // ί��
  COLUMN_HQ_BASE_SPEEDUP = (COLUMN_HQ_BASE_BEGIN + 78); // �µ�����
  { �������� COLUMN_HQ_BASE_ DEFINE END }

  { ��չ���� COLUMN_HQ_EX_ DEFINE BEGIN }
  COLUMN_HQ_EX_BEGIN = (COLUMN_HQ_BASE_END + 1);
  COLUMN_HQ_EX_END = (COLUMN_HQ_EX_BEGIN + 50);

  COLUMN_HQ_EX_BUY_PRICE1 = (COLUMN_HQ_EX_BEGIN + 1); // ����۸�һ
  COLUMN_HQ_EX_BUY_VOLUME1 = (COLUMN_HQ_EX_BEGIN + 2); // ��������һ
  COLUMN_HQ_EX_BUY_PRICE2 = (COLUMN_HQ_EX_BEGIN + 3); // ����۸��
  COLUMN_HQ_EX_BUY_VOLUME2 = (COLUMN_HQ_EX_BEGIN + 4); // ����������
  COLUMN_HQ_EX_BUY_PRICE3 = (COLUMN_HQ_EX_BEGIN + 5); // ����۸���
  COLUMN_HQ_EX_BUY_VOLUME3 = (COLUMN_HQ_EX_BEGIN + 6); // ����������
  COLUMN_HQ_EX_BUY_PRICE4 = (COLUMN_HQ_EX_BEGIN + 7); // ����۸���
  COLUMN_HQ_EX_BUY_VOLUME4 = (COLUMN_HQ_EX_BEGIN + 8); // ����������
  COLUMN_HQ_EX_BUY_PRICE5 = (COLUMN_HQ_EX_BEGIN + 9); // ����۸���
  COLUMN_HQ_EX_BUY_VOLUME5 = (COLUMN_HQ_EX_BEGIN + 10); // ����������

  COLUMN_HQ_EX_SELL_PRICE1 = (COLUMN_HQ_EX_BEGIN + 11); // �����۸�һ
  COLUMN_HQ_EX_SELL_VOLUME1 = (COLUMN_HQ_EX_BEGIN + 12); // ��������һ
  COLUMN_HQ_EX_SELL_PRICE2 = (COLUMN_HQ_EX_BEGIN + 13); // �����۸��
  COLUMN_HQ_EX_SELL_VOLUME2 = (COLUMN_HQ_EX_BEGIN + 14); // ����������
  COLUMN_HQ_EX_SELL_PRICE3 = (COLUMN_HQ_EX_BEGIN + 15); // �����۸���
  COLUMN_HQ_EX_SELL_VOLUME3 = (COLUMN_HQ_EX_BEGIN + 16); // ����������
  COLUMN_HQ_EX_SELL_PRICE4 = (COLUMN_HQ_EX_BEGIN + 17); // �����۸���
  COLUMN_HQ_EX_SELL_VOLUME4 = (COLUMN_HQ_EX_BEGIN + 18); // ����������
  COLUMN_HQ_EX_SELL_PRICE5 = (COLUMN_HQ_EX_BEGIN + 19); // �����۸���
  COLUMN_HQ_EX_SELL_VOLUME5 = (COLUMN_HQ_EX_BEGIN + 20); // ����������

  COLUMN_HQ_EX_EXHAND_RATIO = (COLUMN_HQ_EX_BEGIN + 21); // ������
  COLUMN_HQ_EX_5DAY_AVGVOLUME = (COLUMN_HQ_EX_BEGIN + 22); // 5��ƽ����
  COLUMN_HQ_EX_PE_RATIO = (COLUMN_HQ_EX_BEGIN + 23); // ��ӯ��
  COLUMN_HQ_EX_DIRECTION = (COLUMN_HQ_EX_BEGIN + 24); // �ɽ�����

  { ��չ���� COLUMN_HQ_EX_ DEFINE END }

  SH_BOURSE_Mark = 100000; // �Ϻ�
  SZ_BOURSE_Mark = 200000; // ����
  // �ڻ�
  FUTURES_DALIAN_BOURSE_Mark = 400000; // ���� ��Ʒ
  FUTURES_SHANGHAI_BOURSE_Mark = 500000; // �Ϻ� ��Ʒ
  FUTURES_ZHENGZHOU_BOURSE_Mark = 600000; // ֣�� ��Ʒ
  FUTURES_GUZHI_BOURSE_Mark = 700000; // ��ָ�ڻ�
  // ���
  HK_BOURSE_Mark = 800000; // �������
  HK_GE_BOURSE_Mark = 900000; // ��۴�ҵ��
  HK_INDEX_BOURSE_Mark = 1000000; // ���ָ��
  // ����ָ��
  A_OTHER_BOURSE_Mark = 1100000; // ���� ��֤
  // ���м�ծȯ
  YHJZQ_BOURSE_Mark = 1200000; // ���м���ȯ�г�
  XHCJ_BOURSE_Mark = 1300000; // ���ò��
  ZYSHG_BOURSE_Mark = 1400000; // ��Ѻʽ�ع�
  MDSHG_BOURSE_Mark = 1500000; // ���ʽ�ع�
  // ����
  OTHER_SECU_MARK = 1600000; // ����֤ȯ

  RT_TREND_IB = $1003; // ���м�ծȯ��ʱ
  RT_TRANS_IB = $1004; // ���м�ծȯ	��������
  RT_TECHDATA_IB = $1005; // ���м�ծȯ 	K��
  RT_BOND_BASE_INFO_IB = $1006; // ���м�ծȯ ծȯ������Ϣ

  COLUMN_FUTURES_BEGIN = (COLUMN_HQ_EX_END + 1);
  COLUMN_FUTURES_END = (COLUMN_FUTURES_BEGIN + 50);

  COLUMN_INTERBANK_BEGIN = (COLUMN_FUTURES_END + 1);
  COLUMN_INTERBANK_END = (COLUMN_INTERBANK_BEGIN + 50);

  COLUMN_INTERBANK_OPEN_RATE = (COLUMN_INTERBANK_BEGIN + 0); // ���̾���������
  COLUMN_INTERBANK_HIGH_RATE = (COLUMN_INTERBANK_BEGIN + 1); // ��߾���������
  COLUMN_INTERBANK_LOW_RATE = (COLUMN_INTERBANK_BEGIN + 2); // ��;���������
  COLUMN_INTERBANK_NEW_RATE = (COLUMN_INTERBANK_BEGIN + 3); // ���¾���������
  COLUMN_INTERBANK_WEIGHT_PRICE = (COLUMN_INTERBANK_BEGIN + 4); // ��Ȩ����
  COLUMN_INTERBANK_WEIGHT_RATE = (COLUMN_INTERBANK_BEGIN + 5); // ��Ȩ����������
  COLUMN_INTERBANK_TURNOVER = (COLUMN_INTERBANK_BEGIN + 6); // ������
  COLUMN_INTERBANK_TOTAL = (COLUMN_INTERBANK_BEGIN + 7); // ȯ���ܶ�
  COLUMN_INTERBANK_TOTAL_JY = (COLUMN_INTERBANK_BEGIN + 8); // ��Դ����ɽ���
  COLUMN_INTERBANK_MONEY_JY = (COLUMN_INTERBANK_BEGIN + 9); // ��Դ������
  COLUMN_INTERBANK_SETTLE_MONEY_JY = (COLUMN_INTERBANK_BEGIN + 10); // ��Դ���������

  // ��׺
  SH_Suffix = 'SH'; // �Ϻ�
  SZ_Suffix = 'SZ'; // ����
  OC_Suffix = 'OC'; // ����
  FU_Suffix = 'FU'; // �ڻ�
  HK_Suffix = 'HK'; // �۹�
  OT_Suffix = 'OT'; // ����ָ��
  IB_Suffix = 'IB'; // ���м�֤ȯ
  OPT_Suffix = 'OPT'; // ������Ȩ
  ZXI_Suffix = 'CI'; // ����ָ��
  US_Suffix = 'US'; // ����

implementation

end.
