unit QuoteStruct;

interface

uses Windows, QuoteConst, SysUtils, Ansistrings, QuoteMngr_TLB, Messages, QuoteLibrary;

const
  // ��Ϣ����
  WM_HandleEvent = WM_USER + 5000;
  WM_DataArrive = WM_USER + 5001;
  WM_DataReset = WM_USER + 5002;

type
  // ��Ʊ����ṹ
  HSMarketDataType = USHORT; // �г�������������
  PCodeInfo = ^TCodeInfo;

  TCodeInfo = packed record
    m_cCodeType: HSMarketDataType; // ֤ȯ����
    m_cCode: array [0 .. 5] of AnsiChar; // ֤ȯ����
  end;

  // ����/�������� DEFINE BEGIN
  // �г�����壺
  // ��λ�����ʾ���£�
  // 15                   12                8                                        0
  // |                        |                    |                                        |
  // | ���ڷ���        |�г����� |        ����Ʒ�ַ���        |
  TSrvFileType = // ������·������

    (Srv_BlockUserStock, // ��顢��ѡ��
    Srv_Setting, // ����...
    Srv_Setting_File, // �����ļ�
    Srv_FinancialData, Srv_ClientFileUpdate, // �ͻ����ļ�����
    Srv_UserManagerDBF, // �û�����
    Srv_UserConfig, // �û���Ӧ�������ļ�
    Srv_sysInfoData, // ϵͳ����״̬�ļ�
    Srv_AcceptFilePath, // �յ��ϴ����ļ�
    Srv_DFxPath, // ����1.5�����������ļ�Ŀ¼
    Srv_Gif, // gif�ļ�Ŀ¼
    Srv_Config, // gif�ļ�����Ŀ¼
    Srv_Dynamic_File, // ���̱���
    Srv_ExterDll); // dll·��

  Tm_Oper = packed record
    case integer of
      0:
        (m_cOperator: AnsiChar); // �ͻ���ʹ�ã���������=1ʱ����ǰ����������壬=0ʱ�����
      // �ͻ���ʹ�ã���ǰ�����ķ��������ָ��CEV_Connect_HQ_�ȵĶ��塣
      1:
        (m_cSrv: AnsiChar); // ������ʹ��
  end;

  TCodeInfos = array [0 .. MaxCount] of TCodeInfo;
  PCodeInfos = ^TCodeInfos;

  // ��֤����
  HSPrivateKey = packed record
    m_pCode: TCodeInfo; // ��Ʒ����
  end;

  // ���ذ�ͷ�ṹ
  PDataHead = ^TDataHead;

  TDataHead = packed record
    m_nType: USHORT; // �������ͣ����������ݰ�һ��
    m_nIndex: Byte; // �������������������ݰ�һ��
    m_Oper: Tm_Oper;
    m_lKey: LongInt; // һ����ʶ��ͨ��Ϊ���ھ��
    m_nPrivateKey: HSPrivateKey; // ������ʶ
  end;

  // ѹ�����ذ���ʽ
  PTransZipData = ^TTransZipData;

  TTransZipData = packed record
    m_nType: USHORT; // ��������,��ΪRT_ZIPDATA
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_lZipLen: LongInt; // ѹ����ĳ���
    m_lOrigLen: LongInt; // ѹ��ǰ�ĳ���
    m_cData: array [0 .. 0] of AnsiChar; // ѹ���������
  end;

  TStockOtherDataDetailTime = packed record
    m_nTime: USHORT;
    m_nSecond: USHORT;
  end;

  TStockOtherData_Time = packed record
    case integer of
      0:
        (m_nTimeOld: ULONG); // ����ʱ��
      1:
        (m_nTime: USHORT); // ����ʱ��
      2:
        (m_sDetailTime: TStockOtherDataDetailTime);
  end;

  TStockOtherData_Data = packed record
    case integer of
      0:
        (m_lKaiCang: ULONG); // �񿪲�,�����Ʊ���ʳɽ���,�۹ɽ�������
      1:
        (m_lPreClose: ULONG); // �������ʱ������������
  end;

  TStockOtherData_Data1 = packed record
    case integer of
      0:
        (m_rate_status: ULONG); // �������ʱ������״̬
      // ���ڹ�Ʊ����Ϣ״̬��־,
      // MAKELONG(MAKEWORD(nStatus1,nStatus2),MAKEWORD(nStatus3,nStatus4))
      1:
        (m_lPingCang: ULONG); // ��ƽ
  end;

  // ����Ʊ��������
  TStockOtherData = packed record
    m_Time: TStockOtherData_Time;

    m_lCurrent: ULONG; // ��������
    m_lOutside: ULONG; // ����
    m_lInside: ULONG; // ����
    m_Data: TStockOtherData_Data;
    m_Data1: TStockOtherData_Data1;
  end;

  // ��Ʊ��������
  TStockTypeName = packed record
    m_szName: array [0 .. 19] of AnsiChar; // ��Ʊ��������
  end;

  /// *
  // ���ؽṹ��
  // ��������֤�ͳ�ʼ��Ӧ��
  // ��Ʊ��ʼ����Ϣ
  // */
  /// * ������Ʊ��Ϣ */
  PStockInitInfo = ^TStockInitInfo;

  TStockInitInfo = packed record
    m_cStockName: array [0 .. STOCK_NAME_SIZE - 1] of AnsiChar; // ��Ʊ����
    m_ciStockCode: TCodeInfo; // ��Ʊ����ṹ
    m_lPrevClose: LongInt; // ����
    m_l5DayVol: LongInt; // 5����(�Ƿ���ڴ˼���ɽ���λ����������
  end;

  /// * ������Ʊ��Ϣ �䳤 ������Ȩ*/
  PStockInitInfo_VarCode = ^TStockInitInfo_VarCode;

  TStockInitInfo_VarCode = packed record
    m_lPrevClose: Cardinal; // ����
    m_l5DayVol: Cardinal; // 5����(�Ƿ���ڴ˼���ɽ���λ����������
    m_cStockCode: array [0 .. 0] of AnsiChar;
    // ��Ʊ���ƣ��������롢Ӣ������������;˳��Ϊ�����롢��������Ӣ����;���д��롢Ӣ�������������ĳ��ȶ���;��CommBourseInfo_VarCode�ṹ��,����Ӧ����Ϊ0�����޶�Ӧ�ֶ�
  end;

  PStockInitInfoSimple = ^TStockInitInfoSimple;

  TStockInitInfoSimple = packed record

    m_ciStockCode: TCodeInfo; // ��Ʊ����ṹ
    m_lPrevClose: LongInt; // ����
    m_l5DayVol: LongInt; // 5����(�Ƿ���ڴ˼���ɽ���λ����������
    m_nSize: short; // ���Ƴ���
    m_cStockName: array [0 .. STOCK_NAME_SIZE - 1] of AnsiChar; // ��Ʊ����
  end;

  // ֤ȯ��Ϣ
  THSTypeTime = packed record
    m_nOpenTime: short; // ǰ����ʱ��
    m_nCloseTime: short; // ǰ����ʱ��
  end;

  THSTypeTime_Unoin = packed record

    m_nAheadOpenTime: short; // ǰ����ʱ��
    m_nAheadCloseTime: short; // ǰ����ʱ��
    m_nAfterOpenTime: short; // ����ʱ��
    m_nAfterCloseTime: short; // �����ʱ��

    m_nTimes: array [0 .. 8] of THSTypeTime; // �¼������α߽�,���߽�Ϊ-1ʱ��Ϊ��Ч����

    m_nPriceDecimal: THSTypeTime; // С��λ, < 0
  end;

  PStockType = ^TStockType;

  TStockType = packed record
    m_stTypeName: TStockTypeName; // ��Ӧ���������
    m_nStockType: short; // ֤ȯ����
    m_nTotal: short; // ֤ȯ����
    m_nOffset: short; // ƫ����
    m_nPriceUnit: short; // �۸�λ
    m_nTotalTime: short; // �ܿ���ʱ�䣨���ӣ�
    m_nCurTime: short; // ����ʱ�䣨���ӣ�
    case integer of
      0:
        (m_nNewTimes: array [0 .. 10] of THSTypeTime);
      1:
        (m_union: THSTypeTime_Unoin);
  end;

  //
  // ͨѶ����ʽ˵��:
  //
  // ����������ṹ
  // ˵����
  // 1��        m_nIndex��m_cOperor��m_lKey��m_nPrivateKeyΪ�ͻ���ר�õ�һЩ��Ϣ��
  // �������˴���ʱֱ�ӿ�������,��ͬ��
  // 2��        �궨�壺HS_SUPPORT_UNIX_ALIGNΪʹ����UNIX������4�ֽڶ���ʹ�ã���ͬ��
  // 3��        �������󶼷��ʹ˰�������m_nType���;��������ȷ��m_nSize��m_pCode[1]
  // ������ʵ�ָ��ָ���������
  // 4��        ��������ָ����m_nSizeȡֵΪn����m_pCode[1]����ֻ��n��CodeInfo��
  // ��ֻ����n����Ʊ���ݣ�����m_nType��ʶ���������͡�
  //
  PAskData = ^TAskData;

  TAskData = packed record
    m_nType: USHORT; // �������ͣ����������ݰ�һ��
    m_nIndex: Byte; // �������������������ݰ�һ��
    m_Oper: Tm_Oper;
    m_lKey: LongInt; // һ����ʶ��ͨ��Ϊ���ھ��
    m_nPrivateKey: HSPrivateKey; // ������ʶ
    m_nSize: short; // ����֤ȯ������С����ʱ��
    m_nOption: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
  end;

  //
  // ��������: RT_BULLETIN
  // ����˵��: ���ƽ�������
  // ��          ע:
  //
  // ����ṹ : ������
  // ���ؽṹ
  PAnsBulletin = ^TAnsBulletin;

  TAnsBulletin = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // �������ݳ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_cData: array [0 .. 0] of AnsiChar; // ��������
  end;

  //
  // ��������: RT_SERVERINFO
  // ����˵��: ��վ��Ϣ
  // ��          ע:
  //
  // ����ṹ : ��������
  //
  // ���ؽṹ :
  // ��վ������Ϣ�ṹ
  //
  PAnsServerInfo = ^TAnsServerInfo;

  TAnsServerInfo = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_pName: array [0 .. 31] of AnsiChar; // ��������
    m_pSerialNo: array [0 .. 11] of AnsiChar; // ���кţ���֤������
    m_lTotalCount: LongInt; // �����ӹ�������
    m_lToDayCount: LongInt; // ������������
    m_lNowCount: LongInt; // ��ǰ������
  end;

  // ͨ���ļ�ͷ�ṹ
  PHSCommonFileHead = ^THSCommonFileHead;

  THSCommonFileHead = packed record
    m_lFlag: LongInt; // �ļ����ͱ�ʶ
    m_lDate: Double; // �ļ���������(����:32bit)
    m_lVersion: LongInt; // �ļ��ṹ�汾��ʶ
    m_lCount: LongInt; // �����ܸ���
  end;

  //
  // ��������: RT_LOGIN��RT_LOGIN_INFO��RT_LOGIN_HK��RT_LOGIN_FUTURES��RT_LOGIN_FOREIGN
  // ����˵��: �ͻ��˵�¼����
  // ��          ע:
  //
  // ����ṹ
  PReqLogin = ^TReqLogin;

  TReqLogin = packed record
    m_szUser: array [0 .. 63] of AnsiChar; // �û���
    m_szPWD: array [0 .. 63] of AnsiChar; // ����
  end;

  // �ͻ��˵�¼ ���ؽṹ
  PAnsLogin = ^TAnsLogin;

  TAnsLogin = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nError: short; // �����
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_nSize: integer; // ����
    m_szRet: array [0 .. 0] of AnsiChar; // �����ļ����ݻ��߷��ش�����Ϣ�ַ���
  end;

  // Level2Ӧ�����ṹ
  PAnsLoginLevel2 = ^TAnsLoginLevel2;

  TAnsLoginLevel2 = packed record
    m_nError: short; // �����ʶ 0: У��ͨ�� 1:�û������������
    // 2:�ͻ��ѵ�½ 3:δ��ͨ 4:���ڵȵ�
    m_nGrant: integer; // Ȩ��λ ������λ��ÿλ����һ��Ȩ�ޣ�����Ȩ�ް�����
    m_nValidDay: integer; // ��Ч����,�ṩ�ͻ��˿쵽������ʹ��
  end;

  //
  // /*
  // ��������: RT_INITIALINFO
  // ����˵��: ��������֤�ͳ�ʼ��
  // ��          ע:
  // */
  //
  /// *
  // ����ṹ��
  // ��������֤�ͳ�ʼ������
  // */
  PReqInitSrv = ^TReqInitSrv;

  TReqInitSrv = packed record
    m_nSrvCompareSize: short; // �������Ƚϸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    // m_sServerCompare[1]: ServerCompare;   // �������Ƚ���Ϣ
  end;

  // ������֤ȯ�����Ϣ
  PServerCompare = ^TServerCompare;

  TServerCompare = packed record
    m_cBourse: HSMarketDataType; // ֤ȯ��������
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_dwCRC: UINT; // CRCУ����
  end;

  TServerCompares = array [0 .. MaxCount] of TServerCompare;
  PServerCompares = ^TServerCompares;

  // �г���Ϣ�ṹ
  PCommBourseInfo = ^TCommBourseInfo;

  TCommBourseInfo = packed record
    m_stTypeName: TStockTypeName; // �г�����(��Ӧ�г����)
    m_nMarketType: short; // �г����(�����λ)
    m_cCount: short; // ��Ч��֤ȯ���͸���
    m_lDate: LongInt; // �������ڣ�19971230��
    m_dwCRC: UINT; // CRCУ���루���ࣩ
    m_stNewType: array [0 .. 0] of TStockType; // ֤ȯ��Ϣ
  end;

  // �г���Ϣ�ṹ  �䳤 ������Ȩ
  PCommBourseInfo_VarCode = ^TCommBourseInfo_VarCode;

  TCommBourseInfo_VarCode = packed record
    m_stTypeName: TStockTypeName; // �г�����(��Ӧ�г����)
    m_nMarketType: short; // �г����(�����λ)
    m_cCount: short; // ��Ч��֤ȯ���͸���

    m_nCodeLen: short; // ��Ʊ����ĳ��� �붨���4�ı��������ֶβ���Ϊ0
    m_nChNameLen: short; // ��Ʊ���������� �붨���4�ı�����Ϊ0����������
    m_nEnNameLen: short; // ��ƱӢ�������� �붨���4�ı�����Ϊ0����Ӣ����
    m_nDSTFlag: short; // ����ʱ��־ 0��������ʱ��1������ʱ��
    m_nTimeZone: short; // ʱ����ʽ��HHMM �綫����Ϊ800����11��Ϊ-1100��
    m_nEncodingType: short; // ���ı������� �μ�ENCODING_*һϵ�к궨��
    m_nHand: short; // ÿ������

    m_lDate: LongInt; // �������ڣ�19971230��
    m_dwCRC: UINT; // CRCУ���루���ࣩ
    m_stNewType: array [0 .. 0] of TStockType; // ֤ȯ��Ϣ
  end;

  PStockInitData = ^TStockInitData;

  TStockInitData = packed record
    m_nSize: short; // ��Ʊ������
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pstInfo: array [0 .. 0] of TStockInitInfo; // (m_biInfo����ָ������Ĵ�������
  end;

  // �䳤(��Ȩ)
  PStockInitData_VarCode = ^TStockInitData_VarCode;

  TStockInitData_VarCode = packed record
    m_nSize: short; // ��Ʊ������
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pstInfo: array [0 .. 0] of TStockInitInfo_VarCode; // (m_biInfo����ָ������Ĵ�������
  end;

  POneMarketData = ^TOneMarketData;

  TOneMarketData = packed record
    m_biInfo: TCommBourseInfo; // �г���Ϣ
    m_pstData: TStockInitData;
  end;

  // �䳤(��Ȩ)
  POneMarketData_VarCode = ^TOneMarketData_VarCode;

  TOneMarketData_VarCode = packed record
    m_biInfo: TCommBourseInfo_VarCode; // �г���Ϣ
    m_nSize: short; // ��Ʊ������
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pstInfo: array [0 .. 0] of TStockInitInfo_VarCode; // (m_biInfo����ָ������Ĵ�������
  end;

  TInitialOper = packed record
    case integer of
      0:
        (m_nAlignment: short); // �Ƿ�Ϊ���Ƴ�ʼ����(0�������ʼ��������0�����Ƴ�ʼ����)
      1:
        (m_nOpertion: short); // ����ѡ��,�μ�:AnsInitialData_All ����
  end;

  // ��ʼ�����ؽṹ
  PAnsInitialData = ^TAnsInitialData;

  TAnsInitialData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // �г�����
    m_Oper: TInitialOper; // �Ƿ�Ϊ���Ƴ�ʼ����(0�������ʼ��������0�����Ƴ�ʼ����)
    // ����ѡ��,�μ�:AnsInitialData_All ����
    m_sOneMarketData: array [0 .. 0] of TOneMarketData; // �г�����
  end;

  // �䳤��ʼ�����ؽṹ (������Ȩ)
  PAnsInitialData_VarCode = ^TAnsInitialData_VarCode;

  TAnsInitialData_VarCode = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // �г�����
    m_Oper: TInitialOper; // �Ƿ�Ϊ���Ƴ�ʼ����(0�������ʼ��������0�����Ƴ�ʼ����)
    // ����ѡ��,�μ�:AnsInitialData_All ����
    m_sOneMarketData: array [0 .. 0] of TOneMarketData_VarCode; // �г�����
  end;

  // ʵʱ����
  THSStockRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG; // �ɽ���(��λ:��)
    m_fAvgPrice: Single; // �ɽ����
    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: ULONG; // ��һ��
    m_lBuyPrice2: LongInt; // �����
    m_lBuyCount2: ULONG; // �����
    m_lBuyPrice3: LongInt; // ������
    m_lBuyCount3: ULONG; // ������
    m_lBuyPrice4: LongInt; // ���ļ�
    m_lBuyCount4: ULONG; // ������
    m_lBuyPrice5: LongInt; // �����
    m_lBuyCount5: ULONG; // ������
    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: ULONG; // ��һ��
    m_lSellPrice2: LongInt; // ������
    m_lSellCount2: ULONG; // ������
    m_lSellPrice3: LongInt; // ������
    m_lSellCount3: ULONG; // ������
    m_lSellPrice4: LongInt; // ���ļ�
    m_lSellCount4: ULONG; // ������
    m_lSellPrice5: LongInt; // �����
    m_lSellCount5: ULONG; // ������

    m_nHand: LongInt; // ÿ�ֹ���(�Ƿ�ɷ��������У���������
    m_lNationalDebtRatio: LongInt; // ��ծ����,����ֵ
  end;

  // ָ����ʵʱ����
  THSIndexRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG; // �ɽ���
    m_fAvgPrice: Single; // �ɽ����(ָ�����ݵ�λ��Ԫ)

    m_nRiseCount: short; // ���Ǽ���
    m_nFallCount: short; // �µ�����
    m_nTotalStock1: LongInt;
    /// * �����ۺ�ָ�������й�Ʊ - ָ��   ���ڷ���ָ���������Ʊ���� */
    m_lBuyCount: ULONG; // ί����
    m_lSellCount: ULONG; // ί����
    m_nType: short; // ָ�����ࣺ0-�ۺ�ָ�� 1-A�� 2-B��
    m_nLead: short; // ����ָ��
    m_nRiseTrend: short; // ��������
    m_nFallTrend: short; // �µ�����
    m_nNo2: array [0 .. 4] of short; // ����
    m_nTotalStock2: short; // �����ۺ�ָ����A�� + B��   ���ڷ���ָ����0 */
    m_lADL: LongInt; // ADL ָ��
    m_lNo3: array [0 .. 2] of LongInt; // ����
    m_nHand: LongInt; // ÿ�ֹ���
  end;

  THSHKStockRealTime_union = packed record
    case integer of
      0:
        (m_lYield: LongInt); // ��Ϣ�� ��Ʊ���
      1:
        (m_lOverFlowPrice: LongInt); // ���% �Ϲ�֤���
    // �Ϲ�֤����ۣ����Ϲ�֤�ּۡ��һ����ʣ���ʹ�ۣ�����ʲ��ּۣ�/����ʲ��ּۡ�100
    // �Ϲ�֤����ۣ����Ϲ�֤�ּۡ��һ����ʣ���ʹ�ۣ�����ʲ��ּۣ�/����ʲ��ּۡ�100
  end;

  THSHKStockRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���³ɽ���

    m_lTotal: ULONG; // ��ǰ�ܳɽ������ɣ�
    m_fAvgPrice: Single; // ��ǰ�ܳɽ����(Ԫ)

    m_lBuyPrice: LongInt; // �������  //��1�ۣ���������1��������2��3��4��5��ۣ��ɿͻ��˼��㲢��ʾ
    m_lBuySpread: LongInt; // ��۲�
    m_lSellPrice: LongInt; // ��������  //��1�ۣ���������1��������2��3��4��5���ۣ��ɿͻ��˼��㲢��ʾ
    m_lSellSpread: LongInt; // ���۲�

    m_lBuyCount1: LongInt; // ��һ��
    m_lBuyCount2: LongInt; // �����
    m_lBuyCount3: LongInt; // ������
    m_lBuyCount4: LongInt; // ������
    m_lBuyCount5: LongInt; // ������

    m_lSellCount1: LongInt; // ��һ��
    m_lSellCount2: LongInt; // ������
    m_lSellCount3: LongInt; // ������
    m_lSellCount4: LongInt; // ������
    m_lSellCount5: LongInt; // ������

    m_lHand: LongInt; // ÿ�ֹ���
    m_lIEV: LongInt; // Ԥ��
  end;

  // û�гɽ���ͳɽ����ۣ��ɽ����۴�m_lNominalFlatȡ��
  THSQHRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�

    m_lTotal: ULONG; // �ɽ���(��λ:��Լ��λ)
    m_lChiCangLiang: LongInt; // �ֲ���(��λ:��Լ��λ)

    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: LongInt; // ��һ��
    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: LongInt; // ��һ��

    m_lPreJieSuanPrice: LongInt; // ������

    m_lJieSuanPrice: LongInt; // �ֽ����
    m_lCurrentCLOSE: LongInt; // ������
    m_lHIS_HIGH: LongInt; // ʷ���
    m_lHIS_LOW: LongInt; // ʷ���
    m_lUPPER_LIM: LongInt; // ��ͣ��
    m_lLOWER_LIM: LongInt; // ��ͣ��

    m_nHand: LongInt; // ÿ�ֹ���
    m_lPreCloseChiCang: LongInt; // ��ֲ���(��λ:��Լ��λ)

    m_llongintPositionOpen: LongInt; // ��ͷ��(��λ:��Լ��λ)
    m_llongintPositionFlat: LongInt; // ��ͷƽ(��λ:��Լ��λ)
    m_lNominalOpen: LongInt; // ��ͷ��(��λ:��Լ��λ)
    m_lNominalFlat: LongInt; // ���ɽ����ۣ�

    m_lPreClose: LongInt; // ǰ������????
  end;

  THSWHRealTime = packed record
    m_lOpen: LongInt; // ����(1/10000Ԫ)
    m_lMaxPrice: LongInt; // ��߼�(1/10000Ԫ)
    m_lMinPrice: LongInt; // ��ͼ�(1/10000Ԫ)
    m_lNewPrice: LongInt; // ���¼�(1/10000Ԫ)

    m_lBuyPrice: LongInt; // ���(1/10000Ԫ)
    m_lSellPrice: LongInt; // ����(1/10000Ԫ)
  end;

  THSQHRealTime_Min = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�

    m_lTotal: ULONG; // �ɽ���(��λ:��Լ��λ)
    m_lChiCangLiang: LongInt; // �ֲ���(��λ:��Լ��λ)

    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: LongInt; // ��һ��
    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: LongInt; // ��һ��

    m_lPreJieSuanPrice: LongInt; // ������
  end;
  // ˵����
  // 1��	���ò�衢���ʽ�ع�����Ѻʽ�ع����г������ʴ洢����Ӧ�ļ۸��ֶ��У�
  // 2��	��Ѻʽ�ع��г��ĳɽ�������100����

  THSIBRealTime = packed record
    m_nTradeMethodNumber: AnsiChar; // �ɽ���ʽ���ο�CMDS��10317�ֶ�
    m_nReserved: AnsiChar; // Ԥ��
    m_nOption: short; // Ԥ��
    m_lOpenPrice: long; // ����
    m_lMaxPrice: long; // ��߾���
    m_lMinPrice: long; // ��;���
    m_lNewPrice: long; // ���¾���
    m_lWeightedPrice: long; // ��Ȩƽ����
    m_lAvgPrice: long; // ���۾���
    m_lOpenRate: long; // ����������
    m_lMaxRate: long; // ��߾���������
    m_lMinRate: long; // ��;���������
    m_lNewRate: long; // ���¾���������
    m_lWeightedRate: long; // ��Ȩƽ����������
    m_lRise: long; // �Ƿ�
    m_lInterest: long; // Ӧ����Ϣ
    m_lCBPrice: long; // ��ծ��ֵ����
    m_lCBRate: long; // ��ծ��ֵ����������
    m_lCBDuration: long; // ��ծ��ֵ��������
    m_lCBConvexity: long; // ��ծ��ֵ͹��
    m_lCBBasisPointValue: long; // ��ծ��ֵ�����ֵ

    m_lPreClosePrice: long; // �����̾���
    m_lPreCloseRate: long; // �����̾���������
    m_lPreInterest: long; // ��Ӧ����Ϣ
    m_llVolume: int64; // ȯ���ܶ�(Ԫ)
  end;

  // ������Ȩ
  TOrderUnit = packed record
    price: integer; // ί�м�
    qty: Single; // ί����(��λ:��Լ��λ)
  end;

  THSOPTRealTime_Simple = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�

    m_lJieSuanPrice: LongInt; // �ֽ����
    m_lAutionPrice: LongInt; // ��̬�ο���

    m_lTotal: Single; // �ɽ���(��λ:��Լ��λ)
    m_fMoney: Single; // �ܳɽ���

    m_lPreJieSuanPrice: LongInt; // �����--�Դ˼����ǵ���
    m_fAutionQty: Single; // ����ƥ������
    m_lTotalLongPosition: Single; // δƽ�ֺ�Լ��

    m_Bid: TOrderUnit; // ί��
    m_Offer: TOrderUnit; // ί��

    m_cTradingPhase: array [0 .. 3] of Char; // ��Ʒʵʩ�׶α�־--�ο�v1.03
    m_nHand: LongInt; // ��Լ����
  end;

  THSOPTRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�

    m_lJieSuanPrice: LongInt; // �ֽ����
    m_lAutionPrice: LongInt; // ��̬�ο���

    m_lTotal: Single; // �ɽ���(��λ:��Լ��λ)
    m_fMoney: Single; // �ܳɽ���

    m_lPreJieSuanPrice: LongInt; // �����--�Դ˼����ǵ���
    m_fAutionQty: Single; // ����ƥ������
    m_lTotalLongPosition: Single; // δƽ�ֺ�Լ��

    m_Bid: array [0 .. 4] of TOrderUnit; // ί��
    m_Offer: array [0 .. 4] of TOrderUnit; // ί��

    m_cTradingPhase: array [0 .. 3] of Char; // ��Ʒʵʩ�׶α�־--�ο�v1.03
    m_nHand: LongInt; // ��Լ����
  end;

  // *** ����ʵʱ *** //
  THSUSStockRealTime = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: int64; // �ɽ���(��λ:��)
    m_fMoney: Single; // �ɽ����
    m_lMaxPrice52: LongInt; // 52����߼�
    m_lMinPrice52: LongInt; // 52����ͼ�
    m_lWeightedAveragePx: LongInt; // ��Ȩƽ����
    m_Bid: array [0 .. 0] of TOrderUnit; // ί��
    m_Offer: array [0 .. 0] of TOrderUnit; // ί��
    m_nHand: LongInt; // ÿ�ֹ���
    m_nDelayflag: short; // �Ƿ����ӳ����飬��Ҫ�������ֵ�ǰ�ɽ����ͳɽ����Ƿ�����ʱ����
    m_nTrandCond: short; // ���������-1��ͣ�� 0����ǰ��1�����У�2���̺�
    m_ltime: LongInt; // ��ǰ/�̺���ʱ�䣬��ʽΪhhmmss
    m_lPrice: LongInt; // ��ǰ/�̺�۸�
    m_lVolume: int64; // ��ǰ/�̺�ɽ���
    m_lRise: LongInt; // ��ǰ/�̺��ǵ���
    m_lRiseRatio: LongInt; // ��ǰ/�̺��ǵ���
  end;

  // *** ������ʱ *** //
  THSUSStockRealTimeDelay = packed record
	  m_lNewPrice: LongInt;  // ���¼�
	  m_lTotalL: Int64;			 // �ɽ���(��λ:��)
	  m_fMoney: Single;			 // �ɽ����
	  m_lWeightedAveragePx: LongInt;	//��Ȩƽ����
  end;


  // ʵʱ���ݷ���
  TShareRealTimeData = packed record
    case integer of
      0:
        (m_nowData: THSStockRealTime); // ����ʵʱ��������
      1:
        (m_stStockData: THSStockRealTime);
      2:
        (m_indData: THSIndexRealTime); // ָ��ʵʱ��������
      3:
        (m_hkData: THSHKStockRealTime); // �۹�ʵʱ��������
      4:
        (m_qhData: THSQHRealTime); // �ڻ�ʵʱ��������
      5:
        (m_whData: THSWHRealTime); // ���ʵʱ��������
      6:
        (m_qhMin: THSQHRealTime_Min);
      7:
        (m_HSIB: THSIBRealTime); // ���м�֤ȯʵʱ��������.
//      8:
//        (m_OPTData: THSOPTRealTime); // ������Ȩ�����û���õ�������֮ǰû�ж��壬Ϊ�˺�TShareRealTimeData_Ext�Ľṹͳһ�����Զ��������
      9:
        (m_USData: THSUSStockRealTime); // ����ʵʱ��������
      10:
        (m_USDelayData: THSUSStockRealTimeDelay); // ������ʱ����
    // ghm add level2
    // LevelRealTimem_levelNowData;// ����level2ʵʱ����
  end;

  // ��������: RT_REALTIME
  // ����˵��: ���鱨�۱�--1-6Ǭ¡������
  // ��  ע:
  // */
  /// * ����ṹ : ��������*/
  /// * ���鱨�۱������� */
  PCommRealTimeData = ^TCommRealTimeData;

  TCommRealTimeData = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_othData: TStockOtherData; // ʵʱ��������
    m_cNowData: TShareRealTimeData; // ָ��ShareRealTimeData������һ��
  end;

  /// * ���ؽṹ */
  PAnsRealTime = ^TAnsRealTime;

  TAnsRealTime = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ���۱����ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pnowData: array [0 .. 0] of TCommRealTimeData; // ���۱�����
  end;

  PAnsHSAutoPushData = ^TAnsHSAutoPushData;

  TAnsHSAutoPushData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ���۱����ݸ���
    m_pnowData: array [0 .. 0] of TCommRealTimeData; // ���۱�����
  end;

  PPriceVolItem = ^TPriceVolItem;

  TPriceVolItem = packed record
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG; // �ɽ���(�����ʱ����������)
  end;

  TPriceVolItems = array [0 .. MaxCount] of TPriceVolItem;
  PPriceVolItems = ^TPriceVolItems;
  /// *
  // ��������: RT_TREND_EXT
  // ����˵��: ��ʱ����
  // ��	  ע:
  // */
  /// *����ṹ����������AskData */
  /// *���ؽṹ*/

  PAnsTrendData = ^TAnsTrendData;

  TAnsTrendData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // ��ʱ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_othData: TStockOtherData;
    m_cNowData: TShareRealTimeData; // ָ��ShareRealTimeData������һ��
    m_pHisData: array [0 .. 0] of TPriceVolItem; // ��ʷ��ʱ����
  end;

  // ���Ͼ��۷�ʱ����
  PStockVirtualAuction = ^TStockVirtualAuction;

  TStockVirtualAuction = packed record
    m_lTime: LongInt; // ����ƥ���ʱ�䣬��ʽΪhhmmssxxx
    m_lPrice: LongInt; // ����ƥ��۸�
    m_fQty: Single; // ����ƥ����
    m_fQtyLeft: Single; // ����δƥ���������Ϊ��������ʾί���δƥ���������Ϊ��������ʾί����δƥ����
  end;

  /// *
  // ��������: RT_VIRTUAL_AUCTION
  // ����˵��: ���Ͼ�������
  // */
  /// /����ṹ���������� AskData
  /// /���ؽṹ�����Ͼ��۷��ذ�
  ///
  PAnsVirtualAuction = ^TAnsVirtualAuction;

  TAnsVirtualAuction = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: long; // ���⾺��ƥ��Ĵ���������ù�Ʊû��ƥ�䣬�򣬸�ֵΪ0��
    m_vaData: array [0 .. 0] of TStockVirtualAuction; // ÿ�����⾺�۵���ϸ��Ϣ
  end;

  /// *
  // ��������: RT_STOCKTICK
  // ����˵��: ���ɷֱʡ�������ϸ�ķֱ�����
  // */
  /// /����ṹ���������� AskData
  /// /���ؽṹ�����ɷֱʷ��ذ�
  ///
  TStockTickDetailTime = packed record
    m_nBuyOrSell: AnsiChar;
    m_nSecond: AnsiChar;
  end;

  TStockTick_Buy = packed record
    case integer of
      0:
        (m_nBuyOrSellOld: short); // �ɵģ�����
      1:
        (m_nBuyOrSell: AnsiChar); // �ǰ��۳ɽ����ǰ����۳ɽ�(1 ����� 0 ������)
      2:
        (m_sDetailTime: TStockTickDetailTime); // ����������
  end;

  // �ֱʼ�¼
  PStockTick = ^TStockTick;

  TStockTick = packed record
    m_nTime: short; // ��ǰʱ�䣨�࿪�̷�������
    m_Buy: TStockTick_Buy;
    m_lNewPrice: LongInt; // �ɽ���
    m_lCurrent: ULONG; // �ɽ���
    m_lBuyPrice: LongInt; // ί���
    m_lSellPrice: LongInt; // ί����
    m_nChiCangLiang: ULONG; // �ֲ���,�����Ʊ���ʳɽ���,�۹ɳɽ��̷���(Y,M,X�ȣ���������Դ��ȷ����
  end;

  TStockTicks = array [0 .. MaxCount] of TStockTick;
  PStockTicks = ^TStockTicks;

  PAnsStockTick = ^TAnsStockTick;

  TAnsStockTick = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ���ݸ���
    m_traData: Array [0 .. 0] of TStockTick; // �ֱ�����
  end;

  // /*
  // ��������: RT_CURRENTFINANCEDATA
  // ����˵��: ���µĲ�������
  // */
  /// * ����ṹ */
  ///
  PReqCurrentFinanceData = ^TReqCurrentFinanceData;

  TReqCurrentFinanceData = packed record
    m_lLastDate: LongInt; // ��������
  end;

  /// * ���ؽṹ */
  PCurrentFinanceData = ^TCurrentFinanceData;

  TCurrentFinanceData = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_nDate: integer; // ����
    m_fFinanceData: array [0 .. 38] of Single; // ������
  end;

  PAnsCurrentFinance = ^TAnsCurrentFinance;

  TAnsCurrentFinance = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // �������ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_sFinanceData: array [0 .. 0] of TCurrentFinanceData; // ��������
  end;

  /// *
  // ��������: RT_HISFINANCEDATA
  // ����˵��: ��ʷ��������
  // ����ṹ: ��������:AskData
  // */
  /// *���ؽṹ*/
  PHisFinanceData = ^THisFinanceData;

  THisFinanceData = packed record
    m_nDate: integer; // ����
    m_fFinanceData: array [0 .. 38] of Single; // ������
  end;

  PAnsHisFinance = ^TAnsHisFinance;

  TAnsHisFinance = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ

    m_nSize: short; // �������ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_sFinanceData: array [0 .. 0] of THisFinanceData; // ��������
  end;

  /// *
  // ��������: RT_FILEDOWNLOAD
  //
  // ����˵��:
  // �����ļ���������Ӧ��Ŀǰ��Ҫ������������
  // */
  /// *����ṹ*/

  PReqFileTransferData = ^TReqFileTransferData;

  TReqFileTransferData = packed record // �����������ļ�����
    m_lCRC: LongInt; // �ãң�ֵ��У��ȫ���ļ�����
    m_lOffsetPos: LongInt; // �ļ���ƫ�ƣ��ֽڣ�
    m_lCheckCRC: LongInt; // �Ƿ����У��ãңá��ǣ�����У�飬����У�飬
    m_cFilePath: array [0 .. 255] of AnsiChar; // �ļ���/·��
  end;
  // ·���о���"$ml30"�ִ�ʱ����������Ǯ�����ݵľ���·���滻

  PAnsFileTransferData = ^TAnsFileTransferData;

  TAnsFileTransferData = packed record // �����������ļ�����
    m_dhHead: TDataHead; // ���ݰ�ͷ
    m_lCRC: LongInt; // �ãң�ֵ
    m_nSize: ULONG; // ���ݳ���
    m_cData: array [0 .. 0] of AnsiChar; // ����
  end;

  PReqFileTransferData2 = ^TReqFileTransferData2;

  TReqFileTransferData2 = packed record // �����������ļ�����
    m_nType: short; // ���,�μ�SrvFileType����
    m_nReserve: short;
    m_lCRC: LongInt; // �ãң�ֵ��У��ȫ���ļ�����
    m_lOffsetPos: LongInt; // �ļ���ƫ�ƣ��ֽڣ�
    m_lCheckCRC: LongInt; // �Ƿ����У��ãңá��ǣ�����У�飬����У�飬
    m_cFilePath: array [0 .. 255] of AnsiChar; // �ļ���/·��
    // ·���о���"$ml30"�ִ�ʱ����������Ǯ�����ݵľ���·���滻
  end;

  /// *
  // ��������: RT_BUYSELLPOWER
  // ����˵��: ��������
  // ��  ע:
  // */
  /// *����ṹ����������AskData */
  //
  /// *���ؽṹ */
  /// * �������������� */

  PBuySellPowerData = ^TBuySellPowerData;

  TBuySellPowerData = packed record
    m_lBuyCount: LongInt; // ����
    m_lSellCount: LongInt; // ����
  end;

  PAnsBuySellPower = ^TAnsBuySellPower;

  TAnsBuySellPower = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // �������ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pHisData: array [0 .. 0] of TBuySellPowerData; // ��������
  end;

  /// *
  // ��������: RT_BUYSELLORDER
  // ����˵��: ����������
  // */

  // ����ṹ��
  PReqBuySellOrder = ^TReqBuySellOrder;

  TReqBuySellOrder = packed record // ���������������
    m_pCode: TCodeInfo; // ����
    m_nOffsetSize: short; // m_nOffsetSize = -1ȫ������; m_nOffsetSize >= 0�������ʼλ��
    m_nCount: short; // ��Ҫ���صĳ���
    m_lDate: LongInt; // ����,��ʽ:19990101,
  end;

  // ���ؽṹ��
  PBuySellOrderData = ^TBuySellOrderData;

  TBuySellOrderData = packed record
    m_nTime: short; // ����ʱ��
    m_nHand: short; // ��/��
    m_lCurrent: ULONG; // ��������
    m_lNewPrice: LongInt; // ���¼�
    m_lPrevClose: LongInt; // ������
    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: LongInt; // ��һ��
    m_lBuyPrice2: LongInt; // �����
    m_lBuyCount2: LongInt; // �����
    m_lBuyPrice3: LongInt; // ������
    m_lBuyCount3: LongInt; // ������
    m_lBuyPrice4: LongInt; // ���ļ�
    m_lBuyCount4: LongInt; // ������
    m_lBuyPrice5: LongInt; // �����
    m_lBuyCount5: LongInt; // ������

    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: LongInt; // ��һ��
    m_lSellPrice2: LongInt; // ������
    m_lSellCount2: LongInt; // ������
    m_lSellPrice3: LongInt; // ������
    m_lSellCount3: LongInt; // ������
    m_lSellPrice4: LongInt; // ���ļ�
    m_lSellCount4: LongInt; // ������
    m_lSellPrice5: LongInt; // �����
    m_lSellCount5: LongInt; // ������
  end;

  PAnsBuySellOrder = ^TAnsBuySellOrder;

  TAnsBuySellOrder = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ

    m_nOffsetSize: short; // ��Ӧ�����
    m_nCount: short; // ��Ӧ�����
    m_lDate: LongInt; // ����,��ʽ:19990101

    m_nSize: LongInt; // ���ݸ���
    // short  m_nAlignment;// Ϊ��4�ֽڶ������ӵ��ֶ�
    m_sBuySellOrderData: array [0 .. 0] of TBuySellOrderData; // ����������
  end;

  // ���ؽṹ��ͬ�ֱʽṹ

  /// *
  // ��������: RT_MAJORINDEXTICK
  // ����˵��: ������ϸ
  // ����ṹ���������� AskData
  // */
  // ���ؽṹ��
  PMajorIndexItem = ^TMajorIndexItem;

  TMajorIndexItem = packed record
    m_lNewPrice: LongInt; // ���¼ۣ�ָ����
    m_lTotal: ULONG; // �ɽ���
    m_fAvgPrice: Single; // �ɽ���
    m_nRiseCount: short; // ���Ǽ���
    m_nFallCount: short; // �µ�����
  end;

  PAnsMajorIndexTick = ^TAnsMajorIndexTick;

  TAnsMajorIndexTick = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_ntrData: array [0 .. 0] of TMajorIndexItem; // ����һ���ӳɽ���ϸ
  end;

  /// *
  // ��������: RT_LEAD
  // ����˵��: ��������ָ��
  // ����ṹ: ��������AskData
  // */
  // ���ؽṹ��
  PStockLeadData = ^TStockLeadData;

  TStockLeadData = packed record
    m_lNewPrice: LongInt; // ���¼�(ָ��)
    m_lTotal: ULONG; // �ɽ���
    m_nLead: short; // ����ָ��
    m_nRiseTrend: short; // ��������
    m_nFallTrend: short; // �µ�����
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
  end;

  PAnsLeadData = ^TAnsLeadData;

  TAnsLeadData = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_indData: THSIndexRealTime; // ָ��ʵʱ����

    m_nHisLen: short; // �������ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pHisData: array [0 .. 0] of TStockLeadData; // ��������
  end;

  // /*
  // ��������: RT_MAJORINDEXTREND
  // ����˵��: ��������
  // ����ṹ: ��������AskData
  // */
  /// *���ؽṹ*/

  PAnsMajorIndexTrend = ^TAnsMajorIndexTrend;

  TAnsMajorIndexTrend = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_indData: THSIndexRealTime; // ��֤30����ָ֤��NOW����

    m_nHisLen: short; // �������ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pHisData: array [0 .. 0] of TPriceVolItem; // ��ʱ���� ��˵��
  end;

  //
  // /*
  // ��������: RT_MAJORINDEXADL
  // ����˵��: ����ADL
  // ����ṹ: ��������AskData
  // */
  /// *���ؽṹ��
  // ˵��:
  // ���ذ�ΪAnsMajorIndexTrend��ʹ�ô˽ṹ����AnsMajorIndexTrend�ṹ
  // m_pHisData[1];һ��
  // */
  PADLItem = ^TADLItem;

  TADLItem = packed record

    m_lNewPrice: LongInt; // ָ��
    m_lTotal: ULONG; // �ɽ���
    m_lADL: LongInt; // ADLֵ���㷨:ADL = �����Ǽ��� - �µ��������ۼ�ֵ��
  end;

  /// *
  // ��������: RT_MAJORINDEXBBI
  // ����˵��: ���̶��ָ��BBI
  // ����ṹ: ��������AskData
  // */
  /// *���ؽṹ��
  // ˵��:
  // ���ذ�ΪAnsMajorIndexTrend��ʹ�ô˽ṹ����AnsMajorIndexTrend�ṹm_pHisData[1];һ��
  // */
  PLeadItem = ^TLeadItem;

  TLeadItem = packed record
    m_lNewPrice: LongInt; // ���¼ۣ�ָ����
    m_lTotal: ULONG; // �ɽ���

    m_nLead: short; // ����ָ��
    m_nRiseTrend: short; // ��������
    m_nFallTrend: short; // �µ�����
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
  end;

  /// *
  // ��������: RT_MAJORINDEXBUYSELL
  // ����˵��: ������������
  // ����ṹ: ��������AskData
  // */
  /// *���ؽṹ��
  // ���ذ�ΪAnsMajorIndexTrend��ʹ�ô˽ṹ����AnsMajorIndexTrend�ṹ
  // m_pHisData[1];һ��
  // */
  PMajorIndexBuySellPowerItem = ^TMajorIndexBuySellPowerItem;

  TMajorIndexBuySellPowerItem = packed record
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG; // �ɽ���
    m_lBuyCount: LongInt; // ����
    m_lSellCount: LongInt; // ����
  end;

  //
  /// *��������: RT_VALUE
  // ����:������Ӧ����ʾ�ڿͻ�����Сͼ��ֵ��������(��Ʊ)
  // */
  // ����ṹ����������
  // ���ؽṹ��
  TCalcData_Share = packed record // ��Ʊ����
    m_lMa10: LongInt; // 10�죬20�죬50�����̾���
    m_lMa20: LongInt;
    m_lMa50: LongInt;
    m_lMonthMax: LongInt; // ��������
    m_lMonthMin: LongInt;
    m_lYearMax: LongInt; // ��������
    m_lYearMin: LongInt;
    m_lHisAmplitude: LongInt; // ��ʷ����(ʹ��ʱ��1000Ϊ�ٷֱ�����
  end;

  PAnsValueData = ^TAnsValueData;

  TAnsValueData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ

    m_nTime: LongInt; // ʱ�䣬���뿪�̷�����
    m_lTotal: ULONG; // ����
    m_fAvgPrice: Single; // �ܽ��
    m_lNewPrice: LongInt; // ���¼�
    m_lTickCount: LongInt; // �ɽ�����
    case integer of
      0:
        (m_lMa10: LongInt; // 10�죬20�죬50�����̾���
          m_lMa20: LongInt;
          m_lMa50: LongInt;
          m_lMonthMax: LongInt; // ��������
          m_lMonthMin: LongInt;
          m_lYearMax: LongInt; // ��������
          m_lYearMin: LongInt;
          m_lHisAmplitude: LongInt; // ��ʷ����(ʹ��ʱ��1000Ϊ�ٷֱ�����
        );
      1:
        (m_Share: TCalcData_Share)
  end;

  // ������Ѷ��������Ѷ����������
  TTextMarkData = packed record
    m_lCRC: LongInt; // �ãң�ֵ
    m_lBeginPos: LongInt; // ��ʼλ�ã�ֱ����������ļ��������ļ���ƫ�ƣ��ֽڣ�
    m_lEndPos: LongInt; // ��ֹλ��,ͬ��,�μ�˵��
    m_lCheckCRC: LongInt; // �Ƿ����У��ãңá��ǣ�����У�飬����У�飬
    // *ָ���ִ�,�ͻ���ʹ��,�ִ���ʽΪ: aa;bb;cc;dd
    // ����aaΪ:
    // #define INFO_PATH_KEY_F10 "F10-%i"
    // #define INFO_PATH_KEY_TREND "TREND-%i"
    // #define INFO_PATH_KEY_TECH "TECH-%i"
    // #define INFO_PATH_KEY_REPORT "REPORT-%i"
    // ����bbΪ: ���õĶ���
    // ����ccΪ: ���õ�ȡֵ��
    // ����ddΪ: �����ļ���*/
    m_szInfoCfg: array [0 .. 127] of AnsiChar; // ���������ļ����Ƶ���Ϣ���ַ������ͻ���ʹ��
    m_cTitle: array [0 .. 63] of AnsiChar; // ����,�ͻ��˱���ʹ��
    m_cFilePath: array [0 .. 191] of AnsiChar; // �ļ���/·��
  end;

  // ����ṹ
  PReqTextData = ^TReqTextData;

  TReqTextData = packed record // ���������������
    m_sMarkData: TTextMarkData; // У��������
  end;

  // ���ؽṹ
  PAnsTextData = ^TAnsTextData;

  TAnsTextData = packed record // ��ϸ�ı���Ϣ����
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_sMarkData: TTextMarkData; // ����������
    m_nSize: ULONG; // ���ݳ���
    m_cData: array [0 .. 0] of AnsiChar; // ����
  end;

  //
  // ��������: RT_TECHDATA / RT_TECHDATA_EX
  // ����˵��: �̺����
  // */
  //
  /// *����ṹ*/
  PReqDayData = ^TReqDayData;

  TReqDayData = packed record
    m_nPeriodNum: short; // ���ڳ���,����������
    m_nSize: USHORT; // �������ݵ�ǰ�Ѿ���ȡ������ʼ����,����������
    m_lBeginPosition: LongInt; // ��ʼ������0 ��ʾ��ǰλ�á� �����������Ѿ����صĸ�����
    m_nDay: USHORT; // ����ĸ���
    m_cPeriod: short; // ��������
    m_ciCode: TCodeInfo; // ����Ĺ�Ʊ����
  end;

  // ���RT_TECHDATA_EX���󷵻�
  PStockCompDayDataEx = ^TStockCompDayDataEx;

  TStockCompDayDataEx = packed record
    m_lDate: ULONG; // ����
    m_lOpenPrice: LongInt; // ��
    m_lMaxPrice: LongInt; // ��
    m_lMinPrice: LongInt; // ��
    m_lClosePrice: LongInt; // ��
    m_lMoney: ULONG; // �ɽ�����λǧԪ��
    m_lTotal: ULONG; // �ɽ���
    m_lNationalDebtRatio: LongInt; // ��ծ����(��λΪ0.1��),����ֵ(��λΪ0.1��), ������ʱ���뽫����Ϊ0 2004��2��26�ռ���
  end;

  TStockCompDayDataExs = array [0 .. MaxCount] of TStockCompDayDataEx;
  PStockCompDayDataExs = ^TStockCompDayDataExs;

  PAnsDayDataEx = ^TAnsDayDataEx;

  TAnsDayDataEx = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: LongInt; // �������ݸ���
    m_sdData: array [0 .. 0] of TStockCompDayDataEx; // ��������
  end;

  /// *
  // ��������: RT_HISTREND
  // ����˵��: ��ʷ���䡢���շ�ʱ����Сͼ�·�ʱ����
  // ��  ע:
  // */
  /// *����ṹ*/
  PReqHisTrend = ^TReqHisTrend;

  TReqHisTrend = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_lDate: LongInt; // ���� ��RT_HISTREND˵��1
  end;

  // ��ʷ��ʱ��������
  TStockHistoryTrendHead = packed record
    m_lDate: LongInt; // ����
    m_lPrevClose: LongInt; // ����
    m_Data: TShareRealTimeData;
    m_nSize: short; // ÿ�������ܸ���
    m_nAlignment: short; // ������
  end;

  // ��ʷ��ʱ1��������
  PStockCompHistoryData = ^TStockCompHistoryData;

  TStockCompHistoryData = packed record
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG;
    /// * �ɽ��� //���ڹ�Ʊ(��λ:��)
    m_fAvgPrice: Single;
    /// *�ɽ���� */
    m_lBuyCount: LongInt; // ί����
    m_lSellCount: LongInt; // ί����
  end;

  /// *
  // RT_HISTREND˵��1:
  // m_lDate��
  // ��Ϊ������ָ��������,��ʽ��20030701
  // ��Ϊ��������m_lDate�����ĵ����ʱ���ƣ���-10�򷵻ص�����10��ģ�
  // �����0,Ϊ����
  // */
  PHisTrendData = ^THisTrendData;

  THisTrendData = packed record
    m_shHead: TStockHistoryTrendHead; // ��ʷ��ʱ��������(2004��6��23�� �Ķ��� �ṹ��ͬ��
    m_shData: array [0 .. 0] of TStockCompHistoryData; // ������ʷ����
  end;

  /// *���ؽṹ*/
  PAnsHisTrend = ^TAnsHisTrend;

  TAnsHisTrend = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_shTend: THisTrendData; // ��ʱ����
  end;

  PReqBlockData = ^TReqBlockData;

  TReqBlockData = packed record
    m_lLastDate: LongInt; // ��������
  end;

  PReqExRightData = ^TReqExRightData;

  TReqExRightData = packed record
    m_lLastDate: LongInt; // ��������
  end;

  // ���ؽṹ��
  PAnsExRightData = ^TAnsExRightData;

  TAnsExRightData = packed record

    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ��������������
    m_cData: array [0 .. 0] of AnsiChar; // ��Ȩ����������ʽͬ�ļ����μ�����Ȩ�ļ��ṹ
  end;

  PHSExRight = ^THSExRight;

  THSExRight = packed record
    m_CodeInfo: TCodeInfo;
    m_lLastDate: LongInt; // ��������
    m_lCount: LongInt; // �ο�ʹ��
  end;

  // ��Ȩ���ݽṹ
  PHSExRightItem = ^THSExRightItem;

  THSExRightItem = packed record
    m_nTime: integer; // ʱ��
    m_fGivingStock: Single; // �͹�
    m_fPlacingStock: Single; // ���
    m_fGivingPrice: Single; // �͹ɼ�
    m_fBonus: Single; // �ֺ�
  end;

  /// *
  // ˵�� : �������ƣ���ǰ������ָ����
  // ���� : RT_AUTOPUSHSIMP
  // */
  /// *����ṹ*/
  /// / ���������
  //
  /// *���ؽṹ*/
  TSimplifyIndexNowData = packed record // ָ���ྫ������
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: ULONG; // �ɽ���
    m_fAvgPrice: Single; // �ɽ����

    m_nRiseCount: short; // ���Ǽ���
    m_nFallCount: short; // �µ�����
    m_nLead: short; // ����ָ��
    m_nRiseTrend: short; // ��������
    m_nFallTrend: short; // �µ�����
    m_nTotalStock2: short; // �����ۺ�ָ����A�� + B��
  end;

  PSimplifyStockItem = ^TSimplifyStockItem;

  TSimplifyStockItem = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_sSimplifyIndexNowData: TSimplifyIndexNowData; // ����
  end;

  PAnsSimplifyAutoPushData = ^TAnsSimplifyAutoPushData;

  TAnsSimplifyAutoPushData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pstData: array [0 .. 0] of TSimplifyStockItem; // ����ʵʱ���͵�����
  end;

  /// *
  // ˵��: ��������  ���ڿͻ�������������ҳ�棩
  // ����: RT_AUTOPUSH
  //
  // ˵��: �������ƣ�Ŀǰ����Ԥ��
  // ����: RT_REQAUTOPUSH
  // */
  /// *���ؽṹ*/


  // ��������: RT_LIMITTICK
  // ����˵��: ָ�����ȵķֱ�����

  // ����ṹ��
  PReqLimitTick = ^TReqLimitTick;

  TReqLimitTick = packed record
    m_pCode: TCodeInfo; // ����
    m_nCount: short; // ��Ҫ���صĳ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
  end;

  // RT_KEEPACTIVE˵�� BEGIN
  // ˵��������ͨ��
  // ���ͣ�RT_KEEPACTIVE
  // ����ṹ:
  PReqKeepActive = ^TReqKeepActive;

  TReqKeepActive = packed record
    m_nType: USHORT; // �������ͣ����������ݰ�һ��

    m_nIndex: WORD; // �������������������ݰ�һ��
    m_cOperator: WORD; // ������0����� 1:�����)
  end;

  // ���ؽṹ
  PAnsKeepActive = ^TAnsKeepActive;

  TAnsKeepActive = packed record
    m_nType: USHORT; // �������ͣ����������ݰ�һ��
    m_nIndex: AnsiChar; // �������������������ݰ�һ��
    m_cOperator: AnsiChar; // ������0����� 1:�����)
    m_nDateTime: integer; // ��ǰʱ��(time_t,��1970/1/1 0:0:0��ʼ�������)
  end;

  /// *
  // RT_REPORTSORT˵��1:
  // m_cCodeType�����¼��ַ��ࣺ
  // 1��	��׼���ࣺ��A����A
  // m_nSize = 0��m_sAnyReportData��ָ���κζ���
  // 2��	ϵͳ��飺SysBK_Bourse -- ��ǰ�汾��ʱ��֧����֤��顣
  // m_sAnyReportDataָ��ReqOneBlock
  // ����ļ����������ļ��������ļ���ʽ���ͻ�������ʱ�����CRCУ���뷢�͸���������������	�����������CRC��ͻ��˰��CRC���м�飬������߲�ƥ�䣬����ϵͳ���ѹ�����ݰ���Ȼ���ͱ������ݣ�����ֱ�ӷ��ͱ������ݡ�
  // 3��	��ѡ�ɺ��Զ����飺UserDefBk_Bourse
  // m_sAnyReportDataָ��AnyReportData
  // */
  //
  // #define BLOCK_NAME_LENGTH		32			// ������Ƴ���
  /// * ����ṹ �����������*/
  PReqOneBlock = ^TReqOneBlock;

  TReqOneBlock = packed record
    m_lCRC: LongInt; // ���CRC
    m_szBlockName: array [0 .. BLOCK_NAME_LENGTH - 1] of AnsiChar; // �����
  end;

  PAnyReportData = ^TAnyReportData;

  TAnyReportData = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
  end;

  TAnyReportDatas = array [0 .. MaxCount] of TAnyReportData;
  PAnyReportDatas = ^TAnyReportDatas;

  PReqAnyReport = ^TReqAnyReport;

  TReqAnyReport = packed record
    m_cCodeType: HSMarketDataType; // ��𣬼�RT_REPORTSORT˵��1
    m_nBegin: short; // ��ʾ��ʼ
    m_nCount: short; // ��ʾ����
    m_bAscending: Byte; // ����/����
    m_cAlignment: AnsiChar; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_nColID: integer; // ������id
    m_nSize: short; // ����
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    // m_sAnyReportData: TAnyReportData; //�ͻ��˸��ο����ݸ���������  ��RT_REPORTSORT˵��1*/
  end;

  // ˵��:
  // 1���������յ�RT_KEEPACTIVE����ʱ�����Ӧ�𻺳������з������ݣ���ɲ�����˰������÷��ء�
  // 2���������յ��˰�ʱ�����ɰ�ͨ������ķ�ʽ�������յ�������ʱ����Ӧ������󻺳�����
  // RT_KEEPACTIVE˵�� END

  // RT_SEVER_EMPTY
  // ������û������ʱ���ؿհ������һ������������ʱ
  PAnsSeverEmpty = ^TAnsSeverEmpty;

  TAnsSeverEmpty = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nOldType: USHORT; // ������������
    m_nAlignment: USHORT; //
    m_nSize: integer;
    m_cData: array [0 .. 0] of AnsiChar;
  end;

  // ��������
  // 1   �ܹɱ�       2   ���ҹ�    3   �����˷��˹� 4   ���˹�     5   B��        6   H��       7   ��ͨA��
  // 8   ְ����       9   A2ת���  10  ���ʲ���     11  �����ʲ�   12  �̶��ʲ�   13  �����ʲ�
  // 14  ����Ͷ��     15  ������ծ  16  ���ڸ�ծ     17  �ʱ������� 18  ÿ�ɹ����� 19  �ɶ�Ȩ��
  // 20	��Ӫ����     21	��Ӫ����   22	��������      23	Ӫҵ����   24	Ͷ������    25	��������   26	Ӫҵ����֧
  // 27	����������� 28	�����ܶ�   29	˰������      30	������     31	δ��������   32	ÿ��δ����
  // 33	ÿ������     34	ÿ�ɾ��ʲ� 35	����ÿ�ɾ���  36	�ɶ�Ȩ��� 37	����������

  PFinanceInfo = ^TFinanceInfo;

  TFinanceInfo = packed Record
    m_cAType: Array [0 .. 1] of AnsiChar;
    m_cAUnknow: Array [0 .. 1] of AnsiChar;
    m_cCode: Array [0 .. 5] of AnsiChar;
    m_fFinanceData: array [0 .. 38] of Single; // ������
  end;

  PExRight = ^TExRight;

  TExRight = packed Record
    m_cAType: Array [0 .. 1] of AnsiChar;
    m_cACode: Array [0 .. 5] of AnsiChar;
    m_cAUnknow: Array [0 .. 1] of integer;
  end;

  PExRightItem = ^TExRightItem;

  TExRightItem = packed Record
    m_nTime: integer;
    m_fSg: Single;
    m_fPg: Single;
    m_fPgPrice: Single;
    m_fGive: Single;
  end;

  // Level 2 ��������
  PLevelRealTime = ^TLevelRealTime;

  TLevelRealTime = packed record
    m_lOpen: LongInt; // ��
    m_lMaxPrice: LongInt; // ��
    m_lMinPrice: LongInt; // ��
    m_lNewPrice: LongInt; // ��
    m_lTotal: ULONG; // �ɽ���
    m_fAvgPrice: Single; // 6�ɽ���(��λ: ��Ԫ)

    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: ULONG; // ��һ��
    m_lBuyPrice2: LongInt; // �����
    m_lBuyCount2: ULONG; // �����
    m_lBuyPrice3: LongInt; // ������
    m_lBuyCount3: ULONG; // ������
    m_lBuyPrice4: LongInt; // ���ļ�
    m_lBuyCount4: ULONG; // ������
    m_lBuyPrice5: LongInt; // �����
    m_lBuyCount5: ULONG; // ������

    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: ULONG; // ��һ��
    m_lSellPrice2: LongInt; // ������
    m_lSellCount2: ULONG; // ������
    m_lSellPrice3: LongInt; // ������
    m_lSellCount3: ULONG; // ������
    m_lSellPrice4: LongInt; // ���ļ�
    m_lSellCount4: ULONG; // ������
    m_lSellPrice5: LongInt; // �����
    m_lSellCount5: ULONG; // ������

    m_lBuyPrice6: LongInt; // ������
    m_lBuyCount6: ULONG; // ������
    m_lBuyPrice7: LongInt; // ���߼�
    m_lBuyCount7: ULONG; // ������
    m_lBuyPrice8: LongInt; // ��˼�
    m_lBuyCount8: ULONG; // �����
    m_lBuyPrice9: LongInt; // ��ż�
    m_lBuyCount9: ULONG; // �����
    m_lBuyPrice10: LongInt; // ��ʮ��
    m_lBuyCount10: ULONG; // ��ʮ��

    m_lSellPrice6: LongInt; // ������
    m_lSellCount6: ULONG; // ������
    m_lSellPrice7: LongInt; // ���߼�
    m_lSellCount7: ULONG; // ������
    m_lSellPrice8: LongInt; // ���˼�
    m_lSellCount8: ULONG; // ������
    m_lSellPrice9: LongInt; // ���ż�
    m_lSellCount9: ULONG; // ������
    m_lSellPrice10: LongInt; // ��ʮ��
    m_lSellCount10: ULONG; // ��ʮ��

    m_lTickCount: ULONG; // �ɽ�����

    m_fBuyTotal: Single; // ί����������
    WeightedAvgBidPx: Single; // ��Ȩƽ��ί��۸�
    AltWeightedAvgBidPx: Single;

    m_fSellTotal: Single; // ί����������
    WeightedAvgOfferPx: Single; // ��Ȩƽ��ί���۸�
    AltWeightedAvgOfferPx: Single;

    m_IPOVETFIPOV: Single; //

    m_Time: ULONG; // ʱ���
  end;

  // ����ƱLevel2��������
  TLevelStockOtherData = packed record
    m_nTime: Record
    case integer of 0: (m_nTimeOld: ULONG); // ����ʱ��
      1: (m_nTime: USHORT); // ����ʱ��
      2: (m_sDetailTime: TStockOtherDataDetailTime);
    end;

    m_lCurrent: ULONG; // ��������
    m_lOutside: ULONG; // ����
    m_lInside: ULONG; // ����

    m_KaiPre: Record
    case integer of
      0:
        (m_lKaiCang: ULONG); // �񿪲�,�����Ʊ���ʳɽ���,�۹ɽ�������
      1:
        (m_lPreClose: ULONG); // �������ʱ������������
    end;

    status: Record
    case integer of
      0:
        (m_rate_status: ULONG); // �������ʱ������״̬
      // ���ڹ�Ʊ����Ϣ״̬��־,
      // MAKELONG(MAKEWORD(nStatus1,nStatus2),MAKEWORD(nStatus3,nStatus4))
      1:
        (m_lPingCang: ULONG); // ��ƽ��
    end;
  end;

  PReqReportSort = ^TReqReportSort;

  TReqReportSort = packed record
    m_nBegin: short; // ��ʾ��ʼ
    m_nCount: short; // ��ʾ����
    m_bAscending: Byte; // ����/����  1������ 0������
    m_nColID: integer; // ������id
  end;

  PRealTimeDataLevel = ^TRealTimeDataLevel;

  TRealTimeDataLevel = packed record
    m_ciStockCode: TCodeInfo; // ����
    m_othData: TLevelStockOtherData; // ʵʱ��������
    m_sLevelRealTime: TLevelRealTime; //
  end;

  THSStockRealTimeOther = packed record
    m_lExt1: LongInt; // Ŀǰֻ��ETFʱ���ã�Ϊ��IOPVֵ������510050ʱΪ510051�����¼ۣ�
    m_lStopFlag: LongInt; // ͣ�̱�־��0��������1����ͣ�� 2����ͣ
    // case integer of
    m_fSpeedUp: Single; // ���������
    m_lRes: array [0 .. 1] of LongInt; // Ԥ��
    // m_lOther: array[0..2] of LongInt;	// Ԥ��
    // end;
  end;

  THKBSOrder = packed record
    m_lBuyCount: array [0 .. 4] of LongInt; // ��6~��10��
    m_lSellCount: array [0 .. 4] of LongInt; // ��6~��10��
  end;

  THSHKStockRealTime_Ext = packed record
    m_baseReal: THSHKStockRealTime; // 5������ʵʱ
    m_extBuySell: THKBSOrder; // 5����չί������������/������
  end;

  // ��չָ���г�ʵʱ��չ����
  THSIndexRealTimeOther = packed record
    m_szRiseCode: array [0 .. 7] of AnsiChar; // ���Ǵ���
    m_szFallCode: array [0 .. 7] of AnsiChar; // �������
    m_szClassifiedCode: array [0 .. 7] of AnsiChar; // ָ���ּ����룬Ŀǰ��֪��ʲô��;����ʱ����
    m_lRise: LongInt; // ���Ǵ����Ƿ�
    m_lFall: LongInt; // ����������
  end;

  // ��Ʊʵʱ������չ
  THSStockRealTime_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_stockRealTime: THSStockRealTime; // ʵʱ����
    m_stockOther: THSStockRealTimeOther; // ��չ����
  end;

  // ��չָ���г�ʵʱ���� ��չ
  THSIndexRealTime_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_indexRealTime: THSIndexRealTime; // ʵʱ����
    m_indexRealTimeOther: THSIndexRealTimeOther; // ��չ����
  end;

  // ʵʱ���ݷ���
  PShareRealTimeData_Ext = ^TShareRealTimeData_Ext;

  TShareRealTimeData_Ext = packed record
    case integer of
      0:
        (m_nowDataExt: THSStockRealTime_Ext); // ����ʵʱ��������
      1:
        (m_stStockDataExt: THSStockRealTime_Ext);
      2:
        (m_indData: THSIndexRealTime_Ext); // ��չָ��ʵʱ��������
      3:
        (m_hkData: THSHKStockRealTime_Ext); // �۹�ʵʱ��������
      4:
        (m_qhData: THSQHRealTime); // �ڻ�ʵʱ��������
      5:
        (m_whData: THSWHRealTime); // ���ʵʱ��������
      6:
        (m_qhMin: THSQHRealTime_Min);
      7:
        (m_IBData: THSIBRealTime); // ���м�ծȯ
      8:
        (m_OPTData: THSOPTRealTime); // ������Ȩ
      9:
        (m_USData: THSUSStockRealTime); // ����ʵʱ��������
      10:
        (m_USDelayData: THSUSStockRealTimeDelay); // ������ʱ����
  end;

  PCommRealTimeData_Ext = ^TCommRealTimeData_Ext;

  TCommRealTimeData_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_othData: TStockOtherData; // ʵʱ��������
    m_cNowData: TShareRealTimeData_Ext; // ָ��ShareRealTimeData_Ext������һ��
  end;

  // ��չʵʱ����RT_REALTIME_EXT
  PAnsRealTime_EXT = ^TAnsRealTime_EXT;

  TAnsRealTime_EXT = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ���۱����ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pnowData: array [0 .. 0] of TCommRealTimeData_Ext; // ���۱�����
  end;

  // PAnsHSAutoPushData_Ext = ^TAnsHSAutoPushData_Ext;
  // TAnsHSAutoPushData_Ext = packed record
  // m_dhHead:TDataHead;				// ���ݱ�ͷ
  // m_nSize:long;				// ���ݸ���
  // m_pnowData:array[0..0] of TCommRealTimeData_Ext;	// ����ʵʱ���͵�����
  // end;

  // level���� rt_level_realtime or rt_level_autopush
  PAnsHSAutoPushLevel = ^TAnsHSAutoPushLevel;

  TAnsHSAutoPushLevel = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ���ݸ���
    m_pstData: array [0 .. 0] of TRealTimeDataLevel; // ����ʵʱ���͵�����
  end;

  // ��ʳɽ� ��ѯ����
  PReqLevelTransaction = ^TReqLevelTransaction;

  TReqLevelTransaction = packed record
    m_CodeInfo: TCodeInfo;
    m_nSize: LongInt;
    m_nPostion: LongInt;
  end;

  TStockTransaction = packed record
    m_TradeRef: LongInt; // �ɽ����
    m_TradeTime: LongInt; // �ɽ�ʱ��
    m_TradePrice: LongInt; // �ɽ��۸�
    m_TradeQty: LongInt; // �ɽ�����
    m_TradeMoney: LongInt; // �ɽ����
  end;

  TStockTransactions = array [0 .. MaxCount] of TStockTransaction;
  PStockTransactions = ^TStockTransactions;

  /// *
  // ˵��: ��������  ���ڿͻ�������������ҳ�棩
  // ����: RT_AUTOPUSH
  //
  // ˵��: �������ƣ�Ŀǰ����Ԥ��
  // ����: RT_REQAUTOPUSH
  // */
  /// *���ؽṹ*/

  /// *
  // RT_GENERALSORT˵��1:
  // m_nSortType�������£�����ȡ��ֵ��
  // 1��RT_RISE			�Ƿ�����
  // 2��RT_FALL			��������
  // 3��RT_5_RISE		5�����Ƿ�����
  // 4��RT_5_FALL		5���ӵ�������
  // 5��RT_AHEAD_COMM	�������ί�ȣ���������
  // 6��RT_AFTER_COMM	�������ί�ȣ���������
  // 7��RT_AHEAD_PRICE	�ɽ��������������
  // 8��RT_AHEAD_VOLBI	�ɽ����仯�����ȣ���������
  // 9��RT_AHEAD_MONEY	�ʽ�������������
  // */
  //
  /// * �ۺ��������������� */
  /// *
  // ��������: RT_GENERALSORT_EX
  // ����˵��: �ۺ���������(�����˼�������������)
  // ��	  ע:
  // */
  /// * ����ṹ */
  ///
  PReqGeneralSortEx = ^TReqGeneralSortEx;

  TReqGeneralSortEx = packed record

    m_cCodeType: HSMarketDataType; // �г����
    m_nRetCount: short; // ��������
    m_nSortType: short; // �������� ��RT_GENERALSORT˵��1
    m_nMinuteCount: short; // �����ۺ������п����������ڵļ������������á�
    // 0 ʹ�÷�����Ĭ�Ϸ�����
    // 1 ... 15Ϊ�Ϸ�ȡֵ(һ����ܵ�ȡֵΪ1,2,3,4,5,10,15)
  end;

  // �ۺ��������������� */
  TGeneralSortData = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_lNewPrice: LongInt; // ���¼�
    m_lValue: LongInt; // ����ֵ
  end;

  TGeneralSortDatas = array [0 .. MaxCount] of TGeneralSortData;
  PGeneralSortDatas = ^TGeneralSortDatas;

  /// *���ؽṹ*/
  PAnsGeneralSortEx = ^TAnsGeneralSortEx;

  TAnsGeneralSortEx = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSortType: short; // ��������
    m_nSize: short; // �����Ӱ���������GeneralSortData����
    // ��m_ nSortTypeΪ��ֵʱ��ֻ��һλΪ1��,
    // ��ʾm_prptData����ĸ���Ϊm_nSize����
    // ��m_ nSortTypeΪ��ֵ���ʱ����NλΪ1������ʾ�˷��ذ����N���Ӱ���
    // ÿ���Ӱ�����GeneralSortData����Ϊm_nSize������m_prptData�ĳ���ΪN*m_nSize��
    m_nAlignment: short; // �ֽڶ���
    m_nMinuteCount: short; // �����ۺ������п����������ڵļ������������á�
    // 0 ʹ�÷�����Ĭ�Ϸ�����
    // 1 ... 15Ϊ�Ϸ�ȡֵ(һ����ܵ�ȡֵΪ1,2,3,4,5,10,15)
    m_prptData: array [0 .. 0] of TGeneralSortData; // ����
  end;

  // ���ؽṹ */
  PAnsReportData = ^TAnsReportData;

  TAnsReportData = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: short; // ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_prptData: array [0 .. 0] of TCommRealTimeData; // ����
  end;

  // ��ʳɽ��ṹ
  PLevelTransaction = ^TLevelTransaction;

  TLevelTransaction = packed record
    m_CodeInfo: TCodeInfo; // ����
    m_nSize: LongInt; // ��ʳɽ�����
    m_Data: array [0 .. 0] of TStockTransaction; // ��ʳɽ�����
  end;

  // �۹���ʳɽ� ���ؽṹ
  PAnsLevelTick = ^TAnsLevelTick;

  TAnsLevelTick = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: LongInt; // ������ʵĸ�������
    m_Data: array [0 .. 0] of TLevelTransaction; // �������
  end;

  TLevelTransactions = array [0 .. MaxCount] of TLevelTransaction;
  PLevelTransactions = ^TLevelTransactions;

  // ��ʳɽ�
  PAnsLevelTransaction = ^TAnsLevelTransaction;

  TAnsLevelTransaction = packed record
    m_ciStockCode: TDataHead; // ����ͷ
    m_nSize: LongInt; // ���ش������
    m_Data: array [0 .. 0] of TStockTransaction; // ��ʳɽ���������
  end;

  // ��ʳɽ����ķ��ذ�
  PAnsLevelTransactionAuto = ^TAnsLevelTransactionAuto;

  TAnsLevelTransactionAuto = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: LongInt; // ���ش������
    m_Data: array [0 .. 0] of TLevelTransaction; // ��ʳɽ���������
  end;

  TSingleCacellation = packed record
    m_nRanking: integer; // �������
    m_cCode: array [0 .. 5] of AnsiChar; // ֤ȯ����
    m_MarketType: HSMarketDataType; // �г�����
    m_nOrderEntryTime: LongInt; // ί��ʱ��
    m_nQuantity: LongInt; // ί������
    m_nPrice: LongInt; // ί�м۸�
  end;

  TOrderCacellaion = packed record
    m_nRanking: integer; // �������
    m_cCode: array [0 .. 5] of AnsiChar; // ֤ȯ����
    m_MarketType: HSMarketDataType; // �г�����
    m_lTotalWD: LongInt; // �����ۼ���
    m_nTime: LongInt; // ��ǰʱ��
  end;

  TCancelOrder = packed record
    case integer of
      0:
        (SingleRanking: TSingleCacellation);
      1:
        (ConsolidatedRanking: TOrderCacellaion);
  end;

  POrderCancelRanking = ^TOrderCancelRanking;

  TOrderCancelRanking = packed record
    side: AnsiChar; // ��������
    size: integer; // ��������
    ctype: integer; // ��������  1:Single 2:Consolidated
    orderRanking: array [0 .. 0] of TCancelOrder;
  end;

  // ����������������Ӧ�������DataHead������Ϣ�Ž�������
  PAnsHsLevelCancelOrder = ^TAnsHsLevelCancelOrder;

  TAnsHsLevelCancelOrder = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_pData: TOrderCancelRanking; // ����
  end;

  // �����̿�
  PLevelOrderQueue = ^TLevelOrderQueue;

  TLevelOrderQueue = packed record
    m_Side: AnsiChar; // ��������
    m_Price: LongInt; // �۸�ˮƽ
    m_nActualOrderNum: short; // ί�б���	��ʾʵ��ί�б��������ܱ�50�ʶ�
    m_noOrders: short; // ��֤ͨ�ƹ����ı���  ���50��	FASTЭ�����100��
    m_lData: array [0 .. 0] of LongInt; // ����ָ�룬ָ�������Ϊ��������
  end;

  PAnsQueryOrderQueue = ^TAnsQueryOrderQueue;

  TAnsQueryOrderQueue = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_pstData: TLevelOrderQueue; // ����
  end;

  // ������������
  PReqOrderQueue = ^TReqOrderQueue;

  TReqOrderQueue = packed record
    m_CodeInfo: TCodeInfo; // ����
    m_direct: integer; // 1Ϊ��2Ϊ��
  end;

  POrderQueueData = ^TOrderQueueData;

  TOrderQueueData = packed record
    m_CodeInfo: TCodeInfo; // ����
    m_Data: TLevelOrderQueue; // ����
  end;

  // ����̿���������Ӧ�������DataHead������Ϣ�Ž�������
  PAnsLevelOrderQueueAuto = ^TAnsLevelOrderQueueAuto;

  TAnsLevelOrderQueueAuto = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: LongInt; // ��������
    m_pstData: array [0 .. 0] of TOrderQueueData; // ����end;
  end;

  PTestSrvData = ^TTestSrvData;

  TTestSrvData = packed record
    m_nType: USHORT; // �������ͣ����������ݰ�һ��
    m_nIndex: WORD; // �������������������ݰ�һ��
    m_cOperator: WORD; // ������0����� 1:�����)
  end;

  // ʵʱ����
  HSStockRealTime_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_stockRealTime: THSStockRealTime; // ʱʱ����
    m_stockOther: THSStockRealTimeOther; // ��չ����
  end;

  // ��������: RT_TREND_EXT
  // ����˵��: ��ʱ����
  // ��	  ע:
  //
  // ����ṹ����������AskData
  TPriceVolItem_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_pvi: TPriceVolItem;
    // long			    m_lNewPrice;	// ���¼�
    // unsigned long		m_lTotal;		// �ɽ���(�����ʱ����������)
    m_lExt1: LongInt; // Ŀǰֻ��ETFʱ���ã�Ϊ��IOPVֵ������510050ʱΪ510051�����¼ۣ�
    m_lStopFlag: LongInt; // ͣ�̱�־��0��������1��ͣ��
  end;

  // ���ؽṹ
  PAnsTrendData_Ext = ^TAnsTrendData_Ext;

  TAnsTrendData_Ext = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // ��ʱ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_othData: TStockOtherData;
    m_cNowData: TShareRealTimeData_Ext; // ָ��ShareRealTimeData������һ��
    m_pHisData: array [0 .. 0] of TPriceVolItem_Ext; // ��ʷ��ʱ����
  end;

  // ������������
  TBigOrderItem = packed record
    m_TransType: short; // ��С����λ��Ϣ(0-��С����1-���е���2-��󵥣�3-���ش󵥣�4-��С����5-���е���6-���󵥣�7-���ش�)
    m_Volume: Single; // ��ǰ��λ��С���ɽ���
    m_Money: Single; // ��ǰ��λ��С���ɽ����
    m_Count: ULONG; // ��ǰ��λ��С���ɽ�����
  end;

  TBigOrderItems = array [0 .. 0] of TBigOrderItem;
  PBigOrderItems = ^TBigOrderItems;

  PBigOrderData = ^TBigOrderData;

  TBigOrderData = packed record
    m_ciStockCode: TCodeInfo;
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  PAnsHSAutoPushBigOrder = ^TAnsHSAutoPushBigOrder;

  TAnsHSAutoPushBigOrder = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: long; // ���ݸ���;
    m_pstArray: array [0 .. 0] of TBigOrderData; // Level2��ʵʱ��С������
  end;

  PAnsHSBigOrder = ^TAnsHSBigOrder;

  TAnsHSBigOrder = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nType: short;
    m_nSize: long; // ���ݸ���;
    m_pstArray: array [0 .. 0] of TBigOrderData; // Level2��ʵʱ��С������
  end;

  // ���ɶ�����ʷ��������  ����ṹ
  TRegHSBigOrder = packed record
    m_lBeginPosition: long; // ��ʼ������0��ʾ��ǰλ��
    m_nDay: USHORT; // ����ĸ���
    m_nReqType: short; // ��������
    m_ciCode: TCodeInfo; // ����Ĺ�Ʊ����
  end;

  TBigOrderHisData = packed record
    m_lDate: ULONG;
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  // ���ɶ�����ʷ��������  ���ؽṹ
  TAnsBigOrderHis = packed record

    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_nDate: long; // ��С����������ʱ��
    m_nType: short; // ��С���㷨���ͣ�0-��ʣ�1-�𵥣�
    m_nSize: long; // ���ݸ���
    m_pstArray: array [0 .. 0] of TBigOrderHisData;
  end;

  // DDE Level2������� ����ṹ��
  PReqDDETransByTrans = ^TReqDDETransByTrans;

  TReqDDETransByTrans = packed record
    m_CodeInfo: TCodeInfo; // ����
    m_nSize: integer; // �������ʵĸ���
    m_nPostion: integer; // ��ʼ������ʵ���ʼλ�ã�Ŀǰ��Ϊ0����ʾ�����¿�ʼ����
  end;

  TReqDDETransByTranss = array [0 .. 0] of TReqDDETransByTrans;
  PReqDDETransByTranss = ^TReqDDETransByTranss;

  TTransDataByTrans = packed record
    m_TradeIdx: ULONG; // �ɽ�����������������������������Ž��б���
    m_TradeTime: ULONG; // �ɽ�ʱ��
    m_TradePx: long; // �ɽ��۸�
    m_TradeQty: long; // �ɽ�����
    m_TradeMoney: Single; // �ɽ����
    m_TransType: short; // ��ʳɽ�������,0-��С����1-���е���2-��󵥣�3-���ش󵥣�4-��С����5-���е���6-���󵥣�7-���ش�
  end;

  // DDE Level2�������  ���ؽṹ��
  PAnsDDETransByTrans = ^TAnsDDETransByTrans;

  TAnsDDETransByTrans = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nType: short;
    m_nSize: LongInt; // ������ʵĸ�������
    m_CodeInfo: TCodeInfo; // ����
    m_Data: array [0 .. 0] of TTransDataByTrans; // ��ʳɽ���������
  end;

  // Level2��Ʊ��ʳɽ� ����ṹ��
  TReqDDETransByOrder = packed record
    m_CodeInfo: TCodeInfo; // ����
    m_nSize: integer; // �������ʵĸ���
    m_nPostion: integer; // ��ʼ������ʵ���ʼλ�ã�Ŀǰ��Ϊ0����ʾ�����¿�ʼ����
  end;

  // ���ؽṹ��

  TTransDataByOrder = packed record
    m_TradeIdx: ULONG; // �ɽ�����������������������������Ž��б���
    m_TradeTime: ULONG; // �ɽ�ʱ��
    m_TradePx: long; // �ɽ��۸�
    m_TradeQty: long; // �ɽ�����
    m_TradeMoney: Single; // �ɽ����
    m_OrderType: short; // �𵥳ɽ�������,��8λ������ҵ��Ĵ���𣬵�8λ�������ҵ��Ĵ���𣬴������ͬ��ʳɽ�������
    m_SeriesNum: short; // ��ҵ���������ţ�����������ʼ�ĳɽ����������ֹҵ��Ƿ�����
    m_OfferSeriesNum: short; // ���ҵ���������ţ�����������ʼ�ĳɽ����������ֹҵ��Ƿ�����
    m_BidOrderQty: Single; // ��ҵ���
    m_OfferOrderQty: Single; // ���ҵ���
    m_TransSide: AnsiChar; // �ɽ����շ���˵����ֻ�������㷨��������ʳɽ�����������������
    m_SearchSide: AnsiChar; // ��ҵ����ҷ���1-��ǰ�ң�2-�����,0:Ĭ��,������
    m_OfferSearchSide: AnsiChar; // ���ҵ����ҷ���1-��ǰ�ң�2-�����,0:Ĭ��,������
  end;

  PAnsDDETransByOrder = ^TAnsDDETransByOrder;

  TAnsDDETransByOrder = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nType: short;
    m_nSize: long; // ������ʵĸ�������
    m_CodeInfo: TCodeInfo; // ����
    m_Data: array [0 .. 0] of TTransDataByOrder; // ��ʳɽ���������
  end;

  // DDE ί�ж��� ����ṹ��
  TReqDDEOrderQueue = packed record
    m_nSize: integer; // ����ί�ж��еĸ���
    m_nPostion: integer; // ��ʼ����ί�е���ʼλ�ã�Ŀǰ��Ϊ0����ʾ�����¿�ʼ����
    m_CodeInfo: TCodeInfo; // ����
  end;

  TOrderQueueItem = packed record
    m_Side: AnsiChar; // ��������
    m_Price: long; // �۸�ˮƽ
    m_nTime: long; // ί�ж���ʱ��
    m_nActualOrderNum: short; // ί�б�����ʾʵ��ί�б��������ܱ�50�ʶ�
    m_noOrders: short; // ��֤ͨ�ƹ����ı������50��;FASTЭ�����100��
    m_lData: array [0 .. 0] of long; // ����ָ�룬ָ�������Ϊ��������
    m_lDataType: array [0 .. 0] of long; // ����ָ�룬ָ�������Ϊ�����Ĵ�С������
  end;

  // DDE ί�ж��з��ؽṹ��
  TAnsDDEOrderQueue = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_CodeInfo: TCodeInfo; // ����
    m_nSeq: long; // ����ί�б仯���
    m_nSize: long; // ����ί�ж��еĸ���
    m_Data: TOrderQueueItem; // ί�ж�������
  end;

  // ��ʷDDEָ�������DDX��DDY��DDZ
  // ����DDEָ�꣺����Ʊ����DDE����
  PReqHisDDE = ^TReqHisDDE;

  TReqHisDDE = packed record
    m_lBeginPosition: long; // ��ʼ������0 ��ʾ��ǰλ��
    m_nDay: USHORT; // ����ĸ���
    m_ciCode: TCodeInfo; // ����Ĺ�Ʊ����
  end;

  // ���ؽṹ��
  THisDDEData = packed record
    m_lDate: ULONG;
    m_ddx: Single; // DDX
    m_ddy: Single; // DDY
    m_ddz: Single; // DDZ
  end;

  THisDDEDatas = array [0 .. 0] of THisDDEData;
  PHisDDEDatas = ^THisDDEDatas;

  TAnsHisDDE = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: long; // ���ݸ���
    m_ciStockCode: TCodeInfo; // ����
    m_pstArray: array [0 .. 0] of THisDDEData; // ����ʵʱ���͵�����
  end;
  // ��ʷDDEָ�������DDX��DDY��DDZ
  // ��5��DDX��5��DDY��5��DDZָ�ꣻ60��DDX��60��DDY��60��DDZָ�ꣻ
  // DDXƮ��������10�ڣ���DDXƮ��������������
  // ����DDE���ߣ����Ʊ����DDE���ݣ��г���DDEָ��

  TDDEDecisionData = packed record
    m_ciStockCode: TCodeInfo; // ����
    m_ddx: Single; // DDX
    m_ddy: Single; // DDY
    m_ddz: Single; // DDZ
    m_5ddx: Single; // 5��DDX
    m_5ddy: Single; // 5��DDY
    m_5ddz: Single; // 5��DDZ
    m_60ddx: Single; // 60��DDX
    m_60ddy: Single; // 60��DDY
    m_60ddz: Single; // 60��DDZ
    m_10days: short; // 10��DDXƮ������
    m_days: short; // 10��DDXƮ��������������
  end;

  TDDEDecisionDatas = array [0 .. 0] of TDDEDecisionData;
  PDDEDecisionDatas = ^TDDEDecisionDatas;

  PAnsDDEDecision = ^TAnsDDEDecision;

  TAnsDDEDecision = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: long; // ���ݸ���
    m_pstArray: array [0 .. 0] of TDDEDecisionData; // ����ʵʱ���͵�����
  end;

  PAnsHisDDETrend = ^TAnsHisDDETrend;

  TAnsHisDDETrend = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // ��ʱ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_pstArray: array [0 .. 0] of THisDDEData; // ����ʵʱ���͵�����
  end;

  // ���ɵ��շ�ʱ��С������ɽ�ͳ������

  TBigOrderTrendData = packed record
    m_nSize: long;
    m_pstData: array [0 .. 0] of TBigOrderItem;
  end;

  TAnsBigOrderTrend = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // ��ʱ���ݸ���
    m_nType: short; // ��С���㷨���ͣ�0-��ʣ�1-�𵥣�
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_pstArray: array [0 .. 0] of TBigOrderTrendData; // ����ʵʱ���͵�����
  end;

  // ��ʷ������������ɽ�ͳ������
  // ������ʷ��������ͳ�����ݣ�����������
  TReqHisMass = packed record
    m_lBeginPosition: long; // ��ʼ������0 ��ʾ��ǰλ��
    m_nDay: USHORT; // ����ĸ���
    m_ciCode: TCodeInfo; // ����Ĺ�Ʊ����
  end;

  TMassData = packed record
    m_TotalVolume: Single; // �ܳɽ���
    m_TotalMoney: Single; // �ܳɽ���
    m_TotalCount: Single; // �ܳɽ�����
    m_MfVolume: Single; // note="�������ɽ���" />
    m_MfMoney: Single; // note="�������ɽ���" />
    m_MfCount: Single; // note="�������ɽ�����" />
    m_MfOrderCount: Single; // note="�������ҵ���" />
    m_InsVolume: Single; // note="������ɽ���" />
    m_InsMoney: Single; // note="������ɽ���" />
    m_InsCount: Single; // note="������ɽ�����" />
    m_InsOrderCount: Single; // note="������ҵ���" />
    m_OfferMfVolume: Single; // note="�������ɽ���" />
    m_OfferMfMoney: Single; // note="�������ɽ���" />
    m_OfferMfCount: Single; // note="�������ɽ�����" />
    m_0fferMfOrderCount: Single; // note="�������ҵ���" />
    m_OfferInsVolume: Single; // note="�������ɽ���" />
    m_OfferInsMoney: Single; // note="�������ɽ���" />
    m_OfferInsCount: Single; // note="�������ɽ�����" />
    m_OfferInsOrderCount: Single; // note="�������ҵ���" />
  end;

  // ���ؽṹ��
  TAnsHisMass = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_ciStockCode: TCodeInfo; // ����
    m_nSize: long; // ���ݸ���
    m_pstArray: array [0 .. 0] of TMassData; // ����ʵʱ���͵�����
  end;

  // ����������������
  TMassDecisionData = packed record
    m_ciStockCode: TCodeInfo; // ����
    m_TotalVolume: Single; // �ܳɽ���
    m_TotalMoney: Single; // �ܳɽ���
    m_TotalCount: Single; // �ܳɽ�����
    m_MfVolume: Single; // note="�������ɽ���" />
    m_MfMoney: Single; // note="�������ɽ���" />
    m_MfCount: Single; // note="�������ɽ�����" />
    m_MfOrderCount: Single; // note="�������ҵ���" />
    m_InsVolume: Single; // note="������ɽ���" />
    m_InsMoney: Single; // note="������ɽ���" />
    m_InsCount: Single; // note="������ɽ�����" />
    m_InsOrderCount: Single; // note="������ҵ���" />
    m_OfferMfVolume: Single; // note="�������ɽ���" />
    m_OfferMfMoney: Single; // note="�������ɽ���" />
    m_OfferMfCount: Single; // note="�������ɽ�����" />
    m_0fferMfOrderCount: Single; // note="�������ҵ���" />
    m_OfferInsVolume: Single; // note="�������ɽ���" />
    m_OfferInsMoney: Single; // note="�������ɽ���" />
    m_OfferInsCount: Single; // note="�������ɽ�����" />
    m_OfferInsOrderCount: Single; // note="�������ҵ���" />
  end;

  TAnsMassDecision = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: long; // ��Ʊ��������
    m_pstArray: array [0 .. 0] of TMassDecisionData; // ����ʵʱ���͵�����
  end;

  // ���շ�ʱ������������ɽ�ͳ������
  TAnsMassTrend = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nHisLen: short; // ��ʱ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_pstArray: array [0 .. 0] of TMassData; // ����ʵʱ���͵�����
  end;

  TOrderQueueDetailItem = packed record
    m_Side: AnsiChar; // ��������
    m_LevelOp: AnsiChar; // �۸�λ����
    m_Type: AnsiChar; // ��С����ʶ
    m_none: AnsiChar;
    m_nSeq: long; // ί�б仯���
    m_nIndex: long; // ί�е��±�
    m_nOrderNum: long; // ί�е�����
  end;

  // ��ǰ�𵥴�С��ͳ�ƿ���
  TAnsDDEOrderQueueDetail = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: short; // ����ί�ж��еĸ���
    m_nAlignment: short;
    m_ciStockCode: TCodeInfo; // ����
    m_nPrice: long; // ��λ�۸�
    m_Data: array [0 .. 0] of TOrderQueueDetailItem; // ί�������仯����
  end;

  { //���ɾ�����Ϣ
    TMonitionData = packed record
    m_ciStockCode: TCodeInfo;    // ����
    m_nTime: Long;//ʱ��
    m_nType: short;//��������
    m_nAlignment: short ;    //Ϊ��4�ֽڶ������ӵ��ֶ�
    m_Value1: uint64     ;//����ֵ1
    m_Value2: uint64     ;//����ֵ2
    end;


    TAnsMonition = packed record
    m_dhHead: TDataHead ;// ���ݱ�ͷ
    m_nSize: long ;// ���ݸ���
    m_pstArray: array [0..0] of TMonitionData  ;// ����ʵʱ���͵�����
    end; }

  // ***************************H5 DDE V1.1 Begin****************************************/
  // ���ܺŶ���
const
  // HDAʵʱ�����ѯ
  RT_HDA_REALTIME_QUERY = $0910;
  // HDAʵʱ��������
  RT_HDA_REALTIME_AUTOPUSH = $0A20;
  // HDA��ʱ��ѯ
  RT_HDA_TREND_QUERY = $0911;
  // �ɽ������ѯ(��������)-��
  RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY = $0912;
  // �ɽ������ѯ(��������)-���
  RT_HDA_TRADE_CLASSIFY_BYTRNAS_QUERY = $0915;
  // �ɽ���������-��
  RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH = $0A21;
  // �ɽ���������-���
  RT_HDA_TRADE_CALSSIFY_BYTRNAS_AUTOPUSH = $0A22;
  // HDAָ��K�߲�ѯ
  RT_HDA_CANDLE_QUERY = $0913;
  // HDA�ɽ�����K�߲�ѯ
  RT_HDA_CLASSIFY_CANDLE_QUERY = $0914;

  // HDAָ��С��λ����
  HDA_DECIMAL = 5;

  // K���������� ��
  PERIOD_TYPE_DAY = $0010;

  // �ɽ�����ͳ�Ƶ��ӽ�
  HDA_CLASSIFY_VIEW_TRANS = 0; // ���
  HDA_CLASSIFY_VIEW_ORDER = 1; // ��
  HDA_CLASSIFY_VIEW_FENBI = 2; // Only For Level1, Not Use In Current Verion.

  // �ɽ�����Ĺ�ģ
  HDA_CLASSIFY_COUNT = 4;

type
  // �ɽ�����Ĺ�ģ
  THDA_CLASSIFY_TYPE = (emSIZE_SUPER = 0, // ����
    emSIZE_LARGE = 1, // ��
    emSIZE_MEDIUM = 2, // �е�
    emSIZE_LITTLE = 3); // С��

  // HDA���������
  THDA_Item = packed record
    m_nDDX: integer;
    m_nDDY: integer;
    m_nDDZ: integer;
  end;

  PHDA_Items = ^THDA_Items;
  THDA_Items = array [0 .. 0] of THDA_Item;

  // HDAʵʱ����
  THDA_RealTime = packed record
    m_LastHDA: THDA_Item;
    m_5DayHDA: THDA_Item;
    m_60DayHDA: THDA_Item;
    m_nRiseDays: integer; // DDX����Ʈ������
    m_nRiseDayPast10: integer; // 10����Ʈ������
  end;

  // HDA�ɽ�������
  THDA_ClassifyItem = packed record
    m_nVolume: int64; // �ɽ���
    m_nTurnOver: int64; // �ɽ���
    m_nTransCount: Cardinal; // �����
    m_nOrderCount: Cardinal; // ί�е���
  end;

  // HDA-K��
  THDA_Candle_Item = packed record
    m_lDate: Cardinal;
    m_nDDX: integer;
    m_nDDY: integer;
    m_nDDZ: integer;
  end;

  PHDA_Candle_Items = ^THDA_Candle_Items;
  THDA_Candle_Items = array [0 .. 0] of THDA_Candle_Item;

  // HDA-�ɽ�ͳ��K��
  THDA_Classify_Candle_Item = packed record
    m_lDate: Cardinal;
    m_ayOfferClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_Candle_Item;
    m_ayBidClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_Candle_Item;
  end;

  // HDAʵʱ��������: CodeInfo,
  // HDAʵʱ����Ӧ��AnsRealTime_HDA
  // ���ܺ�:
  // ��ѯ: RT_HDA_REALTIME_QUERY
  // ����: RT_HDA_REALTIME_AUTOPUSH
  PHDARealTimeData = ^THDARealTimeData;

  THDARealTimeData = packed record
    m_StockCode: TCodeInfo; // ��Ʊ����
    m_OtherData: TStockOtherData;
    m_RealTime: THDA_RealTime;
  end;

  THDARealTimeDatas = array [0 .. 0] of THDARealTimeData;
  PHDARealTimeDatas = ^THDARealTimeDatas;

  PAnsRealTime_HDA = ^TAnsRealTime_HDA;

  TAnsRealTime_HDA = packed record
    m_DataHead: TDataHead;
    m_nSize: integer;
    m_lpRealTime: array [0 .. 0] of THDARealTimeData;
  end;

  // �ͻ�����չ(������)ʹ�ã�CodeInfoתNBBM
  PHDARealTimeDataEx = ^THDARealTimeDataEx;

  THDARealTimeDataEx = packed record
    m_RealTimeData: THDARealTimeData;
    NBBM: integer;
  end;

  THDARealTimeDataExs = array [0 .. 0] of THDARealTimeDataEx;
  PHDARealTimeDataExs = ^THDARealTimeDataExs;

  // ����-Ӧ��ṹ
  // HDA��ʱ����: ReqTrend_HDA
  // HDA��ʱӦ��AnsTrend_HDA
  // ���ܺ�:
  // ��ѯ: RT_HDA_TREND_QUERY
  PReqTrend_HDA = ^TReqTrend_HDA;

  TReqTrend_HDA = packed record
    m_CodeInfo: TCodeInfo;
    m_lDate: integer; // >0ΪҪ���������, <=0Ϊƫ�Ƶ���ʷ��ʱ����,0:Ϊ����
  end;

  PAnsTrend_HDA = ^TAnsTrend_HDA;

  TAnsTrend_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_nDate: integer;
    m_nSize: integer;
    m_lpTrends: array [0 .. 0] of THDA_Item;
  end;

  // �ɽ�����(��������)����: AskData
  // �ɽ�����(��������)Ӧ��: AnsTradeClassify_HDA
  // ���ܺ�:
  // ��ѯ: RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY,RT_HDA_TRADE_CLASSIFY_BYTRANS_QUERY
  // ����: RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH,RT_HDA_TRADE_CALSSIFY_BYTRANS_AUTOPUSH
  PHDATradeClassifyData = ^THDATradeClassifyData;

  THDATradeClassifyData = packed record
    m_StockCode: TCodeInfo;
    m_OtherData: TStockOtherData;
    m_emView: integer; // �����ӽ�
    m_OfferClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_ClassifyItem;
    m_BidClassify: array [emSIZE_SUPER .. emSIZE_LITTLE] of THDA_ClassifyItem;
  end;

  PAnsTradeClassify_HDA = ^TAnsTradeClassify_HDA;

  TAnsTradeClassify_HDA = packed record
    m_DataHead: TDataHead;
    m_nSize: integer;
    m_lpClassify: array [0 .. 0] of THDATradeClassifyData;
  end;

  // HDA-K������: ReqCandle_HDA
  // HDA-K��Ӧ��: AnsCandle_HDA
  // ���ܺ�:
  // ��ѯ: RT_HDA_CANDLE_QUERY
  // Note: Ŀǰ�ʽ���ֻֻ֧�ֵ���ʷ��K��
  PReqCandle_HDA = ^TReqCandle_HDA;

  TReqCandle_HDA = packed record
    m_cPeriod: short; // K���������ͣ�Ŀǰ��֧������(PERIOD_TYPE_DAY)
    m_nSize: WORD; // ����K�ߵĸ���
    m_nAlignment: WORD; // Ԥ���ֶ�
    m_lBeginPosition: integer; // ��ʼλ�ã�-1 ��ʾ��ǰλ��
    m_ciCode: TCodeInfo;
  end;

  PAnsCandle_HDA = ^TAnsCandle_HDA;

  TAnsCandle_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_cPeriod: short; // K������������һ��
    m_nCount: integer;
    m_lpItems: array [0 .. 0] of THDA_Candle_Item;
  end;

  // HDA-K������: ReqCandle_HDA
  // HDA-K��Ӧ��: AnsCandle_Classify_HDA
  // ���ܺ�:
  // ��ѯ: RT_HDA_CLASSIFY_CANDLE_QUERY
  // Note: Ŀǰ�ʽ���ֻֻ֧�ֵ���ʷ��K��
  TAnsCandle_Classify_HDA = packed record
    m_DataHead: TDataHead;
    m_StockCode: TCodeInfo;
    m_cPeriod: short; // K������������һ��
    m_nCount: integer;
    m_lpItems: array [0 .. 0] of THDA_Classify_Candle_Item;
  end;
  // ***************************DDE V1.1 End************************************/

  // ***************************INTER BANK BEGIN********************************/

  // ��ʱ����
  PPriceVolItem_IB = ^TPriceVolItem_IB;

  TPriceVolItem_IB = packed record
    m_lNewPrice: integer; // ���¾���
    m_lBuyPrice: integer; // ί�򾻼�
    m_lSellPrice: integer; // ί������
    m_llVolume: int64; // �ɽ���(Ԫ)
  end;

  // ��ʱӦ��
  PAnsIBTrendData = ^TAnsIBTrendData;

  TAnsIBTrendData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nCount: short; // ��ʱ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pVolData: array [0 .. 0] of TPriceVolItem_IB; // ��ʱ����
  end;

  // ���м�ծȯ ��������
  PReqIBTrans = ^TReqIBTrans;

  TReqIBTrans = packed record
    m_ciStockCode: TCodeInfo; // ֤ȯ��Ϣ
    m_nSize: long; // ����ֱ�������С�ڵ���0ʱ����ʾ����ȫ��
  end;

  // ������������
  PIBTransData = ^TIBTransData;

  TIBTransData = packed record
    m_nTime: USHORT; // ���뿪�̵ķ�����
    m_nSecond: AnsiChar; // ����
    m_nTradeMethodNumber: AnsiChar; // �ɽ���ʽ
    m_lNewPrice: long; // ���¾���
    m_lNewRate: long; // ���¾���������
    m_lRise: long; // �Ƿ�
    m_lWeightPrice: long; // ��Ȩ����
    m_lWeightRate: long; // ��Ȩ����������
    m_llVolume: int64; // ȯ���ܶ�(Ԫ)
  end;

  TIBTransDatas = array [0 .. 0] of TIBTransData;
  PIBTransDatas = ^TIBTransDatas;

  PAnsIBTransData = ^TAnsIBTransData;

  TAnsIBTransData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ����Data�ṹ������
    m_nAlignment: short; // Ԥ���ֶ�
    m_pData: array [0 .. 0] of TIBTransData; //
  end;

  // K������
  PReqIBTechData = ^TReqIBTechData;

  TReqIBTechData = packed record
    m_nDataType: short; // �������ͣ�1Ϊ���ۣ�2Ϊ���������ʣ�3Ϊ��ծ��ֵ
    m_cPeriod: short; // K���������ͣ�ͬReqDayData
    m_nSize: USHORT; // ����K�ߵĸ���
    m_nAlignment: USHORT; // Ԥ���ֶ�
    m_lBeginPosition: long; // ��ʼλ�ã�0��ʾ�ӵ�ǰ��������ʾ��ǰƫ��
    m_ciCode: TCodeInfo; // ����Ĺ�Ʊ����
  end;

  // K������
  PIBTechData = ^TIBTechData;

  TIBTechData = packed record
    m_lDate: ULONG; // ����
    m_lOpen: long; // ��
    m_lMax: long; // ��
    m_lMin: long; // ��
    m_lClose: long; // �գ����յ�ȡ����
    m_lInterest: long; // Ӧ����Ϣ
    m_llVolume: int64; // �ɽ���
  end;

  TIBTechDatas = array [0 .. 0] of TIBTechData;
  PIBTechDatas = ^TIBTechDatas;

  // K��Ӧ��
  PAnsIBTechData = ^TAnsIBTechData;

  TAnsIBTechData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nDataType: short; // �������ͣ�1Ϊ���ۣ�2Ϊ���������ʣ�3Ϊ��ծ��ֵ
    m_nSize: short; // ����Data�ṹ������
    m_pData: array [0 .. 0] of TIBTechData; // ��������
  end;

  TIBBondBaseInfoData = packed record
    m_ciStockCode: TCodeInfo; // ֤ȯ��Ϣ
    m_nCouponType: short; // ��Ϣ����1�̶�2����3��Ϣ4����
    m_nPaymentFequency: short; // ��ϢƵ��
    m_nCouponRate: long; // Ʊ������
    m_lFaceValue: long; // ծȯ���
    m_lIssuePrice: long; // ���м۸�
    m_lCashPrice: long; // �Ҹ��۸�
    m_lIssueAmount: int64; // �����ܶ�
    m_lDelistingDate: long; // ծȯժ����
  end;

  PAnsIBBondBaseInfoData = ^TAnsIBBondBaseInfoData;

  TAnsIBBondBaseInfoData = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ����Data�ṹ������
    m_nAlignment: short; // Ԥ���ֶ�
    m_pData: array [0 .. 0] of TIBBondBaseInfoData; //
  end;

  PSeverCalculateData = ^TSeverCalculateData;

  TSeverCalculateData = packed record
    m_ciStockCode: TCodeInfo; // ֤ȯ��Ϣ
    m_fUpPrice: Single; // ��ͣ���
    m_fDownPrice: Single; // ��ͣ���
  end;

  PAnsSeverCalculate = ^TAnsSeverCalculate;

  TAnsSeverCalculate = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: integer; // ���ݸ���
    SeverCalculateData: array [0 .. 0] of TSeverCalculateData end;

    PMarketMonitor = ^TMarketMonitor;
    TMarketMonitor = Packed record m_nMarketType: USHORT;
  end;

  // ���߾�����������
  // ֧���г���ѯУ������
  { ����չ���Ƶ�һ����
    AskData::m_nOption�ֶα�ʾ���ĵ����ࣺ
    0: ���Ƕ��ģ�
    1: ׷�Ӷ��ģ�
    2: ȡ�����ġ� }
  PReqMarketMonitor = ^TReqMarketMonitor;

  TReqMarketMonitor = Packed record
    m_nMktCount: USHORT; // �����г��ĸ���
    m_nReserved: USHORT; // ����
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // ���ĵ��г��б�
  end;

  // ֧���г���ѯУ��Ӧ��
  PAnsMarketMonitor = ^TAnsMarketMonitor;

  TAnsMarketMonitor = Packed record
    m_dhHead: TDataHead;
    m_nMktCount: USHORT; // ֧���г��ĸ���
    m_nReserved: USHORT; // ����
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // ����֧�ֵ��г��б�
  end;

  // ���߾����¼��ṹ
  PMarketEvent = ^TMarketEvent;

  TMarketEvent = Packed record
    m_nEventID: USHORT; // ������ID��������Ӧ��ʽ��
    m_nReserved: USHORT; // ����
    m_nTime: UINT; // �¼�ʱ��hhmmss(�ͻ���Ŀǰ��չʾ��)
    m_CodeInfo: TCodeInfo; // ������Ϣ
    m_cDirection: Byte; // ����1 ����0 ƽ��-1 ����������Ӧ��ʾ��Ϣ����ɫ
    m_cValueCount: Byte; // ��Чֵ�ĸ���(ȡֵΪ: 0, 1, 2)
    m_cValue1Scale: Byte; // ֵ1����10�Ķ��ٴη�
    m_cValue2Scale: Byte; // ֵ2����10�Ķ��ٴη�
    m_nValue1: integer; // ֵ1       //���¼� or �ǵ���
    m_nValue2: integer; // ֵ2       //����
  end;
  // ������ID
  { <event id="0" name="�������" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="1" name="����͹�" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <!--
    <event id="2" name="���ٷ���" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="3" name="��̨��ˮ" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="4" name="��������" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    <event id="5" name="�����µ�" decimal1="2" decimal2="0" suffix="%" seperator="/" />
    -->
    <event id="6" name="�������" decimal1="2" decimal2="0" suffix="" seperator="/" />
    <event id="7" name="�������" decimal1="2" decimal2="0" suffix="" seperator="/" />
    <event id="8" name="����ͣ��" decimal1="2" decimal2="0" suffix="Ԫ" seperator="/" />
    <event id="9" name="���ͣ��" decimal1="2" decimal2="0" suffix="Ԫ" seperator="/" />
    <event id="10" name="����ͣ" decimal1="2" decimal2="0" suffix="Ԫ" seperator="/" />
    <event id="11" name="�򿪵�ͣ" decimal1="2" decimal2="0" suffix="Ԫ" seperator="/" />
    <!--
    <event id="12" name="�д�����" decimal1="0" decimal2="0" suffix="��" seperator="/" />
    <event id="13" name="�д�����" decimal1="0" decimal2="0" suffix="��" seperator="/" />
    --> }

  // ���߾�������Ӧ��
  PAnsMarketEvent = ^TAnsMarketEvent;

  TAnsMarketEvent = Packed record
    m_dhHead: TDataHead;
    m_nDate: UINT; // ����yyyymmdd
    m_nSize: UINT; // MarketEvent�ĸ���
    m_MarketEvents: Array [0 .. 0] of TMarketEvent;
  end;

  // ��ֻ��Ʊ���������¼� ����     //Ӧ��ṹΪAnsMarketEvent
  TReqStockMarketEvent = Packed record
    m_CodeInfo: TCodeInfo; // ������Ϣ
    m_nOffset: UINT; // �����ƫ��
    m_nCount: UINT; // ������¼�����
  end;

  // �����ں��г�������߾����¼�����  //Ӧ��ṹΪAnsMarketEvent
  PReqDateMarketEvent = ^TReqDateMarketEvent;

  TReqDateMarketEvent = Packed Record
    m_nDate: UINT; // ����yyyymmdd
    m_nOffset: UINT; // �����ƫ��
    m_nCount: UINT; // ������¼�����
    m_nMktCount: USHORT; // ��Ҫ��ѯ�г��ĸ���
    m_nReserved: USHORT; // ����
    m_sMarkets: array [0 .. 0] of TMarketMonitor; // ��Ҫ��ѯ���г��б�
  end;

  // RT_HQCOL_VALUE ��ѯ�����ֶ�ֵ ����ṹ
  PReqHQColValue = ^TReqHQColValue;

  TReqHQColValue = Packed record
    m_lHQColCount: UINT; // ��Ч�ֶθ���
    m_lHQCols: Array [0 .. MAX_HQCOL_COUNT - 1] of UINT; // �����ֶ�,����ͬ�����ֶ��ж���
    m_lCodeSize: USHORT; // �����֤ȯ��������
    m_nReserved: USHORT; // ����
    m_pCode: Array [0 .. 0] of TCodeInfo; // ֤ȯ��������
  end;

  THQColField = Packed Record
    m_lField: UINT; // ������ID
    m_lFieldWidth: USHORT; // ������ֵ�Ŀ��,Ŀǰ��ѡ4 ���� 8,�ֱ��Ӧ32λ(4�ֽ�),64λ(8�ֽ�)
    m_nSortPrecision: USHORT; // ��ʾ�Ŵ�10�Ķ��ٴη�.��ɽ������ֶ�������Ҫ�Ŵ�,����Ϊ0,�����г����ڰ�ԭ�����Ŵ��ֵȥ����
  end;

  // RT_HQCOL_VALUE ��ѯ�����ֶ�ֵ Ӧ��ṹ
  PAnsHQColValue = ^TAnsHQColValue;

  TAnsHQColValue = Packed record
    m_dhHead: TDataHead; // ����ͷ
    m_lHQColCount: UINT; // ��Ч�ֶ�����
    m_HQColFields: Array [0 .. MAX_HQCOL_COUNT - 1] of THQColField; // �����ֶ�,����ͬ�����ֶ��ж���
    m_lColCodeSize: USHORT; // ֤ȯ��������
    m_nReserved: USHORT; // ����
    m_pData: array [0 .. 0] of Char; // ����ָ���ֶ�����.
  end; // ��ʽΪCodeInfo + m_lFieldSize�������ֶ�����(��Ӧ�ֶεĿ��Ϊm_ColFields.m_FieldWidth),
  // �����ֵ������,����0,�Ա�֤ÿ���������ݳ���һ��
  // ÿ��֤ȯ�����ݸ�ʽ��СΪ
  // sizeof(TCodeInfo) + m_FieldSize���ֶγ���֮��,
  // ����ÿ���ֶγ���Ϊm_ColFieldS[i].m_lFieldWidth,iΪ��ǰ���±�.


  // AnsiChar6 = array [0..5] of AnsiChar;

function CodeInfoKey(CodeInfo: PCodeInfo): string; overload;

function CodeInfoKey(CodeType: short; const Code: string): string; overload;
// �г�
function CodeInfoKey(cAType: string; const Code: string): string; overload;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string): string; overload;
function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string; Suffix: string): string; overload;

function ATypeToCodeType(cAType: string): short;
function CTypeToCodeType(ctype: string): USHORT;

// ���ڷ���
function HSMarketType(CodeType: HSMarketDataType; Market: integer): boolean;
// �г�����
function HSBourseType(CodeType: HSMarketDataType; Bourse: integer): boolean;
// ����Ʒ�ַ���
function HSKindType(CodeType: HSMarketDataType; Kind: integer): boolean;

// ���ڷ��� + �г�����
function HSMarketBourseType(CodeType: HSMarketDataType; Market, Bourse: integer): boolean;
// ���� + �г�+ Ʒ�ַ���
function HSMarketBourseKindType(CodeType: HSMarketDataType; Market, Bourse, Kind: integer): boolean;

function ToServerType(CodeType: HSMarketDataType): ServerTypeEnum;

function ServerTypeToStr(ServerType: ServerTypeEnum): string;

function CodeInfoToCode(P: PCodeInfo): string;
Function AnsiCharArrayToStr(Arr: Array of AnsiChar): string;

Function IsStockMajorIndex(CodeInfo: PCodeInfo): boolean;

implementation

function CodeInfoToCode(P: PCodeInfo): string;
var
  IBCode: Array [0 .. 20] of AnsiChar;
  tmp: Cardinal;
begin
  // if p = nil then exit('');
  if HSMarketType(P.m_cCodeType, Foreign_MARKET) then
  begin
    if HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, YHJZQ_BOURSE) or // ���м�ծȯ
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, XHCJ_BOURSE) Or // ���ò��
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, ZYSHG_BOURSE) or // ��Ѻʽ�ع�
      HSMarketBourseType(P.m_cCodeType, Foreign_MARKET, MDSHG_BOURSE) // ���ʽ�ع�
    then
    begin
      ZeroMemory(@IBCode[0], Length(IBCode));
      decodeInterbankBondCode(AnsiChar6(P.m_cCode), @IBCode[0], Length(IBCode));
      Result := AnsiCharArrayToStr(IBCode);
    end;
  end
  else if HSMarketBourseType(P.m_cCodeType, OPT_MARKET, OPT_SH_BOURSE) or // ������Ȩ �Ϻ�
    HSMarketBourseType(P.m_cCodeType, OPT_MARKET, OPT_SZ_BOURSE) then // ������Ȩ ����
  begin
    CopyMemory(@tmp, @P.m_cCode[0], SizeOf(integer));
    Result := IntToStr(tmp);
  end
  else
    Result := AnsiCharArrayToStr(P.m_cCode);
end;

Function AnsiCharArrayToStr(Arr: Array of AnsiChar): string;
var
  Str: Ansistring;
  Len: integer;
begin
  Len := Length(Arr);
  if Len < 1 then
    Exit('');
  if Arr[Len - 1] = #0 then
    Str := PAnsiChar(@Arr[0])
  else
  begin
    SetLength(Str, Len);
    ZeroMemory(@Str[1], Len);
    CopyMemory(@Str[1], @Arr[0], Len);
  end;
  Result := String(Str);
end;

function ToServerType(CodeType: HSMarketDataType): ServerTypeEnum;
begin
  // ��Ʊ ��Ȩ
  if HSMarketType(CodeType, STOCK_MARKET) or HSMarketType(CodeType, OPT_MARKET) then
  begin
    Result := stStockLevelI;
  end
  else if HSMarketType(CodeType, Other_MARKET) then
  begin
    Result := stStockLevelI;
  end
  else if HSMarketType(CodeType, FUTURES_MARKET) then
  begin
    Result := stFutues;
    // �۹�����
  end
  else if HSMarketType(CodeType, HK_MARKET) then
  begin
    Result := stStockHK;

  end
  else if HSMarketType(CodeType, Foreign_MARKET) then
  begin
    Result := stForeign;
  end
  else if HSMarketType(CodeType, US_MARKET) then
    Result := stUSStock
  else
    Result := stStockLevelI;
end;

// ���� + �г�+ Ʒ�ַ���
function HSMarketBourseKindType(CodeType: HSMarketDataType; Market, Bourse, Kind: integer): boolean;
begin
  Result := HSMarketType(CodeType, Market) and HSBourseType(CodeType, Bourse) and HSKindType(CodeType, Kind);
end;

// ���� + �г� ����
function HSMarketBourseType(CodeType: HSMarketDataType; Market, Bourse: integer): boolean;
begin
  Result := HSMarketType(CodeType, Market) and HSBourseType(CodeType, Bourse);
end;

// ���ڷ���
function HSMarketType(CodeType: HSMarketDataType; Market: integer): boolean;
begin
  Result := (CodeType and $F000) = Market;
end;

// �г�����
function HSBourseType(CodeType: HSMarketDataType; Bourse: integer): boolean;
begin
  Result := (CodeType and $0F00) = Bourse;
end;

// ����Ʒ�ַ���
function HSKindType(CodeType: HSMarketDataType; Kind: integer): boolean;
begin
  Result := (CodeType and $00FF) = Kind;
end;

function CodeInfoKey(CodeType: short; const Code: string): string;
begin
  // if True then

  if HSMarketBourseType(CodeType, STOCK_MARKET, SH_BOURSE) then
    Result := Code + '_' + SH_Suffix
  else if HSMarketBourseType(CodeType, STOCK_MARKET, SZ_BOURSE) then
    Result := Code + '_' + SZ_Suffix
  else if HSMarketBourseType(CodeType, STOCK_MARKET, GZ_BOURSE) then // �����г�
    Result := Code + '_' + OC_Suffix
    // else if HSMarketType(CodeType, STOCK_MARKET) then
    // Result := Code + '_'
  else if HSMarketType(CodeType, FUTURES_MARKET) then // �ڻ�
    Result := Code + '_' + FU_Suffix
  else if HSMarketType(CodeType, HK_MARKET) then // �۹�
    Result := Code + '_' + HK_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, ZZ_BOURSE) then // ��֤/����ָ��
    Result := Code + '_' + OT_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, GN_BOURSE) then // ������/������ָ��
    Result := Code + '_' + OT_Suffix
  else if HSMarketBourseType(CodeType, Other_MARKET, ZX_BORRSE) then // ����ָ��
    Result := Code + '_' + ZXI_Suffix
  else if HSMarketType(CodeType, Foreign_MARKET) then // ���м�ծȯ
    Result := Code + '_' + IB_Suffix
  else if HSMarketType(CodeType, OPT_MARKET) then // ������Ȩ
    Result := Code + '_' + OPT_Suffix
  else if HSMarketType(CodeType, US_MARKET) then
    Result := Code + '_' + US_Suffix  //����
  else
    Result := Code;
end;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string): string;
begin
  if (ZQSC in [76,77,78]) then
    Result := Code
  else
    Result := Copy(Code, 1, 6);
  if ZQLB = 110 then
  begin
    Result := Code + '_' + OPT_Suffix; // ������Ȩ
    Exit;
  end;
  case ZQSC of
    83:
      begin // �Ϻ��г�
        if (ZQLB = 4) then // ָ��
        begin
          if (pos('2D', Code) = 1) then // ��֤/����ָ��
            Result := Result + '_' + OT_Suffix
          else if (pos('CI', Code) = 1) then // ����ָ��
            Result := Copy(Code, 3, 100) + '_' + ZXI_Suffix
          else
            Result := Result + '_' + SH_Suffix;
        end
        else
          Result := Result + '_' + SH_Suffix; // �Ϻ�֤ȯ������
      end;
    90:
      Result := Result + '_' + SZ_Suffix; // ����֤ȯ������
    81:
      Result := Result + '_' + OC_Suffix; // �����г�
    10, 13, 15, 19, 20:
      Result := Result + '_' + FU_Suffix; // �ڻ�
    72:
      Result := Result + '_' + HK_Suffix; // ���������
    76,77,78:
      Result := Result + '_' + US_Suffix; // ����
    84:
      begin
        case ZQLB of
          910:
            begin
              Result := Copy(Code, 3, 6) + '_' + OT_Suffix; // ������ȥ��ǰ���28
            end;
          920:
            begin
              Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // ������ǰ���2800�滻ΪDY
            end;
        else
          Result := Result + '_' + OT_Suffix; // ����ָ��
        end;
      end;
    89:
      Result := Code + '_' + IB_Suffix; // ���м�ծȯ
    0:
      case ZQLB of
        910:
          begin
            Result := Copy(Code, 3, 6) + '_' + OT_Suffix; // ������ȥ��ǰ���28
          end;
        920:
          begin
            Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // ������ǰ���2800�滻ΪDY
          end;
      end;
  end;
end;

function GetKeyByZQLB(ZQSC: integer; ZQLB: integer; Code: string; Suffix: string): string;
begin
  if (ZQSC in [76,77,78,79]) then
    Result := Code
  else
    Result := Copy(Code, 1, 6);
  if ZQLB = 110 then
  begin
    Result := Code + '_' + OPT_Suffix; // ������Ȩ
    Exit;
  end;
  case ZQSC of
    83:
      begin // �Ϻ��г�
        if (ZQLB = 4) then // ָ��
        begin
          if (pos('2D', Code) = 1) or (Suffix = 'CSI') then // ��֤/����ָ��
            Result := Result + '_' + OT_Suffix
          else if (pos('CI', Code) = 1) then // ����ָ��
            Result := Copy(Code, 3, 100) + '_' + ZXI_Suffix
          else
            Result := Result + '_' + SH_Suffix;
        end
        else
          Result := Result + '_' + SH_Suffix; // �Ϻ�֤ȯ������
      end;
    90:
      Result := Result + '_' + SZ_Suffix; // ����֤ȯ������
        81:
      Result := Result + '_' + OC_Suffix; // �����г�
        10, 13, 15, 19, 20:
      Result := Result + '_' + FU_Suffix; // �ڻ�
        72:
      Result := Result + '_' + HK_Suffix; // ���������
    76,77,78,79:
      Result := Result + '_' + US_Suffix; // ����
        84:
      begin
        case ZQLB of
          910, 930:
            begin
//              Result := Copy(Code, 3, 6) + '_' + OT_Suffix;
              Result := Copy(Result, 3, 6) + '_' + OT_Suffix; // ������ȥ��ǰ���28
            end;
          920:
            begin
              Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // ������ǰ���2800�滻ΪDY
            end;
        else
          Result := Result + '_' + OT_Suffix; // ����ָ��
        end;
      end;
    89:
      Result := Code + '_' + IB_Suffix; // ���м�ծȯ
        0:
      case ZQLB of
        910, 930:
          begin
//            Result := Copy(Code, 3, 6) + '_' + OT_Suffix;
            Result := Copy(Result, 3, 6) + '_' + OT_Suffix; // ������ȥ��ǰ���28
          end;
        920:
          begin
            Result := 'DY' + Copy(Code, 5, 6) + '_' + OT_Suffix; // ������ǰ���2800�滻ΪDY
          end;
      end;
  end;
end;

function CTypeToCodeType(ctype: string): USHORT;
begin
  if ctype = SH_Suffix then // 83 �Ϻ�֤ȯ������
    Result := STOCK_MARKET or SH_BOURSE
  else if ctype = SZ_Suffix then
    Result := STOCK_MARKET or SZ_BOURSE
  else if ctype = OC_Suffix then // 81�����г�
    Result := STOCK_MARKET or GZ_BOURSE
  else if ctype = FU_Suffix then // �ڻ�  400000
    Result := FUTURES_MARKET
  else if ctype = HK_Suffix then // �۹�  300000
    Result := HK_MARKET
  else if ctype = OT_Suffix then
    Result := Other_MARKET
  else if ctype = IB_Suffix then // ���м�ծȯ
    Result := Foreign_MARKET
  else if ctype = OPT_Suffix then
    Result := OPT_MARKET
  else
    Result := 0;
end;

function ATypeToCodeType(cAType: string): short;
begin
  if cAType = '83' then // 83 �Ϻ�֤ȯ������
    Result := STOCK_MARKET or SH_BOURSE
  else if cAType = '81' then // 81�����г�
    Result := STOCK_MARKET or SZ_BOURSE
  else if cAType = '90' then // 90 ����֤ȯ������
    Result := STOCK_MARKET or SZ_BOURSE
  else
    Result := 0;
end;

function CodeInfoKey(cAType: string; const Code: string): string; overload;
begin
  Result := CodeInfoKey(ATypeToCodeType(cAType), Code);
end;

function CodeInfoKey(CodeInfo: PCodeInfo): string;
begin
  Result := CodeInfoKey(CodeInfo^.m_cCodeType, CodeInfoToCode(CodeInfo));
end;

function ServerTypeToStr(ServerType: ServerTypeEnum): string;
begin
  case ServerType of
    stStockLevelI:
      Result := 'stStockLevelI';
    stStockLevelII:
      Result := 'stStockLevelII';
    stFutues:
      Result := 'stFutues';
    stStockHK:
      Result := 'stStockHK';
    stForeign:
      Result := 'stForeign';
    stDDE:
      Result := 'stDDE';
    stUSStock:
      Result := 'stUSStock';
  else
    Result := 'unknown'
  end;
end;

Function IsStockMajorIndex(CodeInfo: PCodeInfo): boolean;
var
  HSCode: Ansistring;
begin

  Result := HSMarketType(CodeInfo.m_cCodeType, STOCK_MARKET) and HSKindType(CodeInfo.m_cCodeType, KIND_INDEX);
  if Result then
  begin
    HSCode := Ansistring(SH_MajorIndex_HSCODE);
    Result := CompareMem(@CodeInfo.m_cCode[0], @HSCode[1], Length(HSCode));
    if Result then
      Exit;
    HSCode := Ansistring(SZ_MajorIndex_HSCODE);
    Result := CompareMem(@CodeInfo.m_cCode[0], @HSCode[1], Length(HSCode));
  end;
end;

end.
