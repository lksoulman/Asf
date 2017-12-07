unit QuoteStructInt64;

interface

uses
  Windows, QuoteConst, SysUtils, Ansistrings, QuoteMngr_TLB, Messages, QuoteLibrary,
  QuoteStruct;

type
  // ���ذ�ͷ�ṹ
  PDataHead = ^TDataHead;

  // ����Ʊ��������
  TStockOtherInt64Data = packed record
    m_Time: TStockOtherData_Time;

    m_lCurrent: Int64; // ��������
    m_lOutside: Int64; // ����
    m_lInside: Int64; // ����
    m_Data: TStockOtherData_Data;
    m_Data1: TStockOtherData_Data1;
  end;

  // ʵʱ����
  THSStockRealTimeInt64 = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: Int64; // �ɽ���(��λ:��)
    m_fAvgPrice: Int64; // �ɽ����
    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: Int64; // ��һ��
    m_lBuyPrice2: LongInt; // �����
    m_lBuyCount2: Int64; // �����
    m_lBuyPrice3: LongInt; // ������
    m_lBuyCount3: Int64; // ������
    m_lBuyPrice4: LongInt; // ���ļ�
    m_lBuyCount4: Int64; // ������
    m_lBuyPrice5: LongInt; // �����
    m_lBuyCount5: Int64; // ������
    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: Int64; // ��һ��
    m_lSellPrice2: LongInt; // ������
    m_lSellCount2: Int64; // ������
    m_lSellPrice3: LongInt; // ������
    m_lSellCount3: Int64; // ������
    m_lSellPrice4: LongInt; // ���ļ�
    m_lSellCount4: Int64; // ������
    m_lSellPrice5: LongInt; // �����
    m_lSellCount5: Int64; // ������

    m_nHand: LongInt; // ÿ�ֹ���(�Ƿ�ɷ��������У���������
    m_lNationalDebtRatio: LongInt; // ��ծ����,����ֵ
  end;

  // ָ����ʵʱ����
  THSIndexRealTimeInt64 = packed record
    m_lOpen: LongInt; // ����
    m_lMaxPrice: LongInt; // ��߼�
    m_lMinPrice: LongInt; // ��ͼ�
    m_lNewPrice: LongInt; // ���¼�
    m_lTotal: Int64; // �ɽ���
    m_fAvgPrice: Int64; // �ɽ����(ָ�����ݵ�λ��Ԫ)

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

  // ��Ʊʵʱ������չ
  THSStockRealTime_Int64Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_stockRealTime: THSStockRealTimeInt64; // ʵʱ����
    m_stockOther: THSStockRealTimeOther; // ��չ����
  end;

  // ��չָ���г�ʵʱ���� ��չ
  THSIndexRealTime_Int64Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_indexRealTime: THSIndexRealTimeInt64; // ʵʱ����
    m_indexRealTimeOther: THSIndexRealTimeOther; // ��չ����
  end;

  // ʵʱ���ݷ���
  TShareRealTimeInt64Data = packed record
    case integer of
      0:
        (m_nowData: THSStockRealTime_Int64Ext); // ����ʵʱ��������
      1:
        (m_stStockData: THSStockRealTime_Int64Ext);
      2:
        (m_indData: THSIndexRealTime_Int64Ext); // ָ��ʵʱ��������
  end;

  // ��������: RT_REALTIME_Int64
  // ����˵��: 64λ����Э�����鱨�۱�--1-6Ǭ¡������
  // ��  ע:
  // */
  /// * ����ṹ : ��������*/
  /// * ���鱨�۱������� */
  PCommRealTimeInt64Data = ^TCommRealTimeInt64Data;

  TCommRealTimeInt64Data = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_othData: TStockOtherInt64Data; // ʵʱ��������
    m_cNowData: TShareRealTimeInt64Data; // ָ��ShareRealTimeData������һ��
  end;

  // ʵʱ���ݷ���
  PShareRealTimeInt64Data_Ext = ^TShareRealTimeInt64Data_Ext;

  TShareRealTimeInt64Data_Ext = packed record
    case integer of
      0:
        (m_nowDataExt: THSStockRealTime_Int64Ext); // ����ʵʱ��������
      1:
        (m_stStockDataExt: THSStockRealTime_Int64Ext);
      2:
        (m_indData: THSIndexRealTime_Int64Ext); // ��չָ��ʵʱ��������
  end;

  PCommRealTimeInt64Data_Ext = ^TCommRealTimeInt64Data_Ext;

  TCommRealTimeInt64Data_Ext = packed record
    m_cSize: USHORT; // �ṹ�峤��
    m_nVersion: USHORT; // �汾��
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_othData: TStockOtherInt64Data; // ʵʱ��������
    m_cNowData: TShareRealTimeInt64Data_Ext; // ָ��ShareRealTimeData_Ext������һ��
  end;

  // 64λ��չʵʱ����RT_REALTIME_EXT_INT64
  PAnsRealTime_EXT_INT64 = ^TAnsRealTime_EXT_INT64;

  TAnsRealTime_EXT_INT64 = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: short; // ���۱����ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_pnowData: array [0 .. 0] of TCommRealTimeInt64Data_Ext; // ���۱�����
  end;

  // Level 2 ��������
  PLevelRealTimeInt64 = ^TLevelRealTimeInt64;

  TLevelRealTimeInt64 = packed record
    m_lOpen: LongInt; // ��
    m_lMaxPrice: LongInt; // ��
    m_lMinPrice: LongInt; // ��
    m_lNewPrice: LongInt; // ��
    m_lTotal: ULONG; // �ɽ���
    m_fAvgPrice: Single; // 6�ɽ���(��λ: ��Ԫ)

    m_lBuyPrice1: LongInt; // ��һ��
    m_lBuyCount1: Int64; // ��һ��
    m_lBuyPrice2: LongInt; // �����
    m_lBuyCount2: Int64; // �����
    m_lBuyPrice3: LongInt; // ������
    m_lBuyCount3: Int64; // ������
    m_lBuyPrice4: LongInt; // ���ļ�
    m_lBuyCount4: Int64; // ������
    m_lBuyPrice5: LongInt; // �����
    m_lBuyCount5: Int64; // ������

    m_lSellPrice1: LongInt; // ��һ��
    m_lSellCount1: Int64; // ��һ��
    m_lSellPrice2: LongInt; // ������
    m_lSellCount2: Int64; // ������
    m_lSellPrice3: LongInt; // ������
    m_lSellCount3: Int64; // ������
    m_lSellPrice4: LongInt; // ���ļ�
    m_lSellCount4: Int64; // ������
    m_lSellPrice5: LongInt; // �����
    m_lSellCount5: Int64; // ������

    m_lBuyPrice6: LongInt; // ������
    m_lBuyCount6: Int64; // ������
    m_lBuyPrice7: LongInt; // ���߼�
    m_lBuyCount7: Int64; // ������
    m_lBuyPrice8: LongInt; // ��˼�
    m_lBuyCount8: Int64; // �����
    m_lBuyPrice9: LongInt; // ��ż�
    m_lBuyCount9: Int64; // �����
    m_lBuyPrice10: LongInt; // ��ʮ��
    m_lBuyCount10: Int64; // ��ʮ��

    m_lSellPrice6: LongInt; // ������
    m_lSellCount6: Int64; // ������
    m_lSellPrice7: LongInt; // ���߼�
    m_lSellCount7: Int64; // ������
    m_lSellPrice8: LongInt; // ���˼�
    m_lSellCount8: Int64; // ������
    m_lSellPrice9: LongInt; // ���ż�
    m_lSellCount9: Int64; // ������
    m_lSellPrice10: LongInt; // ��ʮ��
    m_lSellCount10: Int64; // ��ʮ��

    m_lTickCount: ULONG; // �ɽ�����

    m_fBuyTotal: Int64; // ί����������
    WeightedAvgBidPx: Single; // ��Ȩƽ��ί��۸�
    AltWeightedAvgBidPx: Single;

    m_fSellTotal: Int64; // ί����������
    WeightedAvgOfferPx: Single; // ��Ȩƽ��ί���۸�
    AltWeightedAvgOfferPx: Single;

    m_IPOVETFIPOV: Single; //

    m_Time: ULONG; // ʱ���
  end;

  // ����ƱLevel2��������
  TLevelStockOtherInt64Data = packed record
    m_nTime: Record
    case integer of 0: (m_nTimeOld: ULONG); // ����ʱ��
      1: (m_nTime: USHORT); // ����ʱ��
      2: (m_sDetailTime: TStockOtherDataDetailTime);
    end;

    m_lCurrent: Int64; // ��������
    m_lOutside: Int64; // ����
    m_lInside: Int64; // ����

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

  PRealTimeDataLevelInt64 = ^TRealTimeDataLevelInt64;

  TRealTimeDataLevelInt64 = packed record
    m_ciStockCode: TCodeInfo; // ����
    m_othData: TLevelStockOtherInt64Data; // ʵʱ��������
    m_sLevelRealTime: TLevelRealTimeInt64; //
  end;

  // level���� rt_level_realtime or rt_level_autopush
  PAnsHSAutoPushLevelInt64 = ^TAnsHSAutoPushLevelInt64;

  TAnsHSAutoPushLevelInt64 = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ���ݸ���
    m_pstData: array [0 .. 0] of TRealTimeDataLevelInt64; // ����ʵʱ���͵�����
  end;

  /// *
  // ��������: RT_STOCKTICK
  // ����˵��: ���ɷֱʡ�������ϸ�ķֱ�����
  // */
  /// /����ṹ���������� AskData
  /// /���ؽṹ�����ɷֱʷ��ذ�
  ///
  // �ֱʼ�¼
  PStockTickInt64 = ^TStockTickInt64;

  TStockTickInt64 = packed record
    m_nTime: short; // ��ǰʱ�䣨�࿪�̷�������
    m_Buy: TStockTick_Buy;
    m_lNewPrice: LongInt; // �ɽ���
    m_lCurrent: Int64; // �ɽ���
    m_lBuyPrice: LongInt; // ί���
    m_lSellPrice: LongInt; // ί����
    m_nChiCangLiang: ULONG; // �ֲ���,�����Ʊ���ʳɽ���,�۹ɳɽ��̷���(Y,M,X�ȣ���������Դ��ȷ����
  end;

  TStockTicksInt64 = array [0 .. MaxCount] of TStockTickInt64;
  PStockTicksInt64 = ^TStockTicksInt64;

  PAnsStockTickInt64 = ^TAnsStockTickInt64;

  TAnsStockTickInt64 = packed record
    m_dhHead: TDataHead; // ���ݱ�ͷ
    m_nSize: LongInt; // ���ݸ���
    m_traData: Array [0 .. 0] of TStockTickInt64; // �ֱ�����
  end;

  // 64λЭ���ۺ��������������� */
  TGeneralSortInt64Data = packed record
    m_ciStockCode: TCodeInfo; // ��Ʊ����
    m_lNewPrice: LongInt; // ���¼�
    m_lValue: Int64; // ����ֵ
  end;

  TGeneralSortInt64Datas = array [0 .. MaxCount] of TGeneralSortInt64Data;
  PGeneralSortInt64Datas = ^TGeneralSortInt64Datas;

  /// *���ؽṹ*/
  PAnsGeneralSortInt64Ex = ^TAnsGeneralSortInt64Ex;

  TAnsGeneralSortInt64Ex = packed record
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
    m_prptData: array [0 .. 0] of TGeneralSortInt64Data; // ����
  end;

  // 64λ�������򷵻ؽṹ */
  PAnsReportInt64Data = ^TAnsReportInt64Data;

  TAnsReportInt64Data = packed record
    m_dhHead: TDataHead; // ����ͷ
    m_nSize: short; // ���ݸ���
    m_nAlignment: short; // Ϊ��4�ֽڶ������ӵ��ֶ�
    m_prptData: array [0 .. 0] of TCommRealTimeInt64Data_Ext; // ����
  end;

implementation

end.
