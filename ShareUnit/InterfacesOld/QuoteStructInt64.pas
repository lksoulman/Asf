unit QuoteStructInt64;

interface

uses
  Windows, QuoteConst, SysUtils, Ansistrings, QuoteMngr_TLB, Messages, QuoteLibrary,
  QuoteStruct;

type
  // 返回包头结构
  PDataHead = ^TDataHead;

  // 各股票其他数据
  TStockOtherInt64Data = packed record
    m_Time: TStockOtherData_Time;

    m_lCurrent: Int64; // 现在总手
    m_lOutside: Int64; // 外盘
    m_lInside: Int64; // 内盘
    m_Data: TStockOtherData_Data;
    m_Data1: TStockOtherData_Data1;
  end;

  // 实时数据
  THSStockRealTimeInt64 = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: Int64; // 成交量(单位:股)
    m_fAvgPrice: Int64; // 成交金额
    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: Int64; // 买一量
    m_lBuyPrice2: LongInt; // 买二价
    m_lBuyCount2: Int64; // 买二量
    m_lBuyPrice3: LongInt; // 买三价
    m_lBuyCount3: Int64; // 买三量
    m_lBuyPrice4: LongInt; // 买四价
    m_lBuyCount4: Int64; // 买四量
    m_lBuyPrice5: LongInt; // 买五价
    m_lBuyCount5: Int64; // 买五量
    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: Int64; // 卖一量
    m_lSellPrice2: LongInt; // 卖二价
    m_lSellCount2: Int64; // 卖二量
    m_lSellPrice3: LongInt; // 卖三价
    m_lSellCount3: Int64; // 卖三量
    m_lSellPrice4: LongInt; // 卖四价
    m_lSellCount4: Int64; // 卖四量
    m_lSellPrice5: LongInt; // 卖五价
    m_lSellCount5: Int64; // 卖五量

    m_nHand: LongInt; // 每手股数(是否可放入代码表中？？？？）
    m_lNationalDebtRatio: LongInt; // 国债利率,基金净值
  end;

  // 指标类实时数据
  THSIndexRealTimeInt64 = packed record
    m_lOpen: LongInt; // 今开盘
    m_lMaxPrice: LongInt; // 最高价
    m_lMinPrice: LongInt; // 最低价
    m_lNewPrice: LongInt; // 最新价
    m_lTotal: Int64; // 成交量
    m_fAvgPrice: Int64; // 成交金额(指数数据单位百元)

    m_nRiseCount: short; // 上涨家数
    m_nFallCount: short; // 下跌家数
    m_nTotalStock1: LongInt;
    /// * 对于综合指数：所有股票 - 指数   对于分类指数：本类股票总数 */
    m_lBuyCount: ULONG; // 委买数
    m_lSellCount: ULONG; // 委卖数
    m_nType: short; // 指数种类：0-综合指数 1-A股 2-B股
    m_nLead: short; // 领先指标
    m_nRiseTrend: short; // 上涨趋势
    m_nFallTrend: short; // 下跌趋势
    m_nNo2: array [0 .. 4] of short; // 保留
    m_nTotalStock2: short; // 对于综合指数：A股 + B股   对于分类指数：0 */
    m_lADL: LongInt; // ADL 指标
    m_lNo3: array [0 .. 2] of LongInt; // 保留
    m_nHand: LongInt; // 每手股数
  end;

  // 股票实时数据扩展
  THSStockRealTime_Int64Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_stockRealTime: THSStockRealTimeInt64; // 实时数据
    m_stockOther: THSStockRealTimeOther; // 扩展数据
  end;

  // 扩展指数市场实时数据 扩展
  THSIndexRealTime_Int64Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_indexRealTime: THSIndexRealTimeInt64; // 实时数据
    m_indexRealTimeOther: THSIndexRealTimeOther; // 扩展数据
  end;

  // 实时数据分类
  TShareRealTimeInt64Data = packed record
    case integer of
      0:
        (m_nowData: THSStockRealTime_Int64Ext); // 个股实时基本数据
      1:
        (m_stStockData: THSStockRealTime_Int64Ext);
      2:
        (m_indData: THSIndexRealTime_Int64Ext); // 指数实时基本数据
  end;

  // 请求类型: RT_REALTIME_Int64
  // 功能说明: 64位行情协议行情报价表--1-6乾隆操作键
  // 备  注:
  // */
  /// * 请求结构 : 常用请求*/
  /// * 行情报价表数据项 */
  PCommRealTimeInt64Data = ^TCommRealTimeInt64Data;

  TCommRealTimeInt64Data = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherInt64Data; // 实时其它数据
    m_cNowData: TShareRealTimeInt64Data; // 指向ShareRealTimeData的任意一个
  end;

  // 实时数据分类
  PShareRealTimeInt64Data_Ext = ^TShareRealTimeInt64Data_Ext;

  TShareRealTimeInt64Data_Ext = packed record
    case integer of
      0:
        (m_nowDataExt: THSStockRealTime_Int64Ext); // 个股实时基本数据
      1:
        (m_stStockDataExt: THSStockRealTime_Int64Ext);
      2:
        (m_indData: THSIndexRealTime_Int64Ext); // 扩展指数实时基本数据
  end;

  PCommRealTimeInt64Data_Ext = ^TCommRealTimeInt64Data_Ext;

  TCommRealTimeInt64Data_Ext = packed record
    m_cSize: USHORT; // 结构体长度
    m_nVersion: USHORT; // 版本号
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherInt64Data; // 实时其它数据
    m_cNowData: TShareRealTimeInt64Data_Ext; // 指向ShareRealTimeData_Ext的任意一个
  end;

  // 64位扩展实时数据RT_REALTIME_EXT_INT64
  PAnsRealTime_EXT_INT64 = ^TAnsRealTime_EXT_INT64;

  TAnsRealTime_EXT_INT64 = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: short; // 报价表数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_pnowData: array [0 .. 0] of TCommRealTimeInt64Data_Ext; // 报价表数据
  end;

  // Level 2 行情数据
  PLevelRealTimeInt64 = ^TLevelRealTimeInt64;

  TLevelRealTimeInt64 = packed record
    m_lOpen: LongInt; // 开
    m_lMaxPrice: LongInt; // 高
    m_lMinPrice: LongInt; // 低
    m_lNewPrice: LongInt; // 新
    m_lTotal: ULONG; // 成交量
    m_fAvgPrice: Single; // 6成交额(单位: 百元)

    m_lBuyPrice1: LongInt; // 买一价
    m_lBuyCount1: Int64; // 买一量
    m_lBuyPrice2: LongInt; // 买二价
    m_lBuyCount2: Int64; // 买二量
    m_lBuyPrice3: LongInt; // 买三价
    m_lBuyCount3: Int64; // 买三量
    m_lBuyPrice4: LongInt; // 买四价
    m_lBuyCount4: Int64; // 买四量
    m_lBuyPrice5: LongInt; // 买五价
    m_lBuyCount5: Int64; // 买五量

    m_lSellPrice1: LongInt; // 卖一价
    m_lSellCount1: Int64; // 卖一量
    m_lSellPrice2: LongInt; // 卖二价
    m_lSellCount2: Int64; // 卖二量
    m_lSellPrice3: LongInt; // 卖三价
    m_lSellCount3: Int64; // 卖三量
    m_lSellPrice4: LongInt; // 卖四价
    m_lSellCount4: Int64; // 卖四量
    m_lSellPrice5: LongInt; // 卖五价
    m_lSellCount5: Int64; // 卖五量

    m_lBuyPrice6: LongInt; // 买六价
    m_lBuyCount6: Int64; // 买六量
    m_lBuyPrice7: LongInt; // 买七价
    m_lBuyCount7: Int64; // 买七量
    m_lBuyPrice8: LongInt; // 买八价
    m_lBuyCount8: Int64; // 买八量
    m_lBuyPrice9: LongInt; // 买九价
    m_lBuyCount9: Int64; // 买九量
    m_lBuyPrice10: LongInt; // 买十价
    m_lBuyCount10: Int64; // 买十量

    m_lSellPrice6: LongInt; // 卖六价
    m_lSellCount6: Int64; // 卖六量
    m_lSellPrice7: LongInt; // 卖七价
    m_lSellCount7: Int64; // 卖七量
    m_lSellPrice8: LongInt; // 卖八价
    m_lSellCount8: Int64; // 卖八量
    m_lSellPrice9: LongInt; // 卖九价
    m_lSellCount9: Int64; // 卖九量
    m_lSellPrice10: LongInt; // 卖十价
    m_lSellCount10: Int64; // 卖十量

    m_lTickCount: ULONG; // 成交笔数

    m_fBuyTotal: Int64; // 委托买入总量
    WeightedAvgBidPx: Single; // 加权平均委买价格
    AltWeightedAvgBidPx: Single;

    m_fSellTotal: Int64; // 委托卖出总量
    WeightedAvgOfferPx: Single; // 加权平均委卖价格
    AltWeightedAvgOfferPx: Single;

    m_IPOVETFIPOV: Single; //

    m_Time: ULONG; // 时间戳
  end;

  // 各股票Level2其他数据
  TLevelStockOtherInt64Data = packed record
    m_nTime: Record
    case integer of 0: (m_nTimeOld: ULONG); // 现在时间
      1: (m_nTime: USHORT); // 现在时间
      2: (m_sDetailTime: TStockOtherDataDetailTime);
    end;

    m_lCurrent: Int64; // 现在总手
    m_lOutside: Int64; // 外盘
    m_lInside: Int64; // 内盘

    m_KaiPre: Record
    case integer of
      0:
        (m_lKaiCang: ULONG); // 今开仓,深交所股票单笔成交数,港股交易宗数
      1:
        (m_lPreClose: ULONG); // 对于外汇时，昨收盘数据
    end;

    status: Record
    case integer of
      0:
        (m_rate_status: ULONG); // 对于外汇时，报价状态
      // 对于股票，信息状态标志,
      // MAKELONG(MAKEWORD(nStatus1,nStatus2),MAKEWORD(nStatus3,nStatus4))
      1:
        (m_lPingCang: ULONG); // 今平仓
    end;
  end;

  PRealTimeDataLevelInt64 = ^TRealTimeDataLevelInt64;

  TRealTimeDataLevelInt64 = packed record
    m_ciStockCode: TCodeInfo; // 代码
    m_othData: TLevelStockOtherInt64Data; // 实时其它数据
    m_sLevelRealTime: TLevelRealTimeInt64; //
  end;

  // level主推 rt_level_realtime or rt_level_autopush
  PAnsHSAutoPushLevelInt64 = ^TAnsHSAutoPushLevelInt64;

  TAnsHSAutoPushLevelInt64 = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 数据个数
    m_pstData: array [0 .. 0] of TRealTimeDataLevelInt64; // 主机实时发送的数据
  end;

  /// *
  // 请求类型: RT_STOCKTICK
  // 功能说明: 个股分笔、个股详细的分笔数据
  // */
  /// /请求结构：常用请求 AskData
  /// /返回结构：个股分笔返回包
  ///
  // 分笔记录
  PStockTickInt64 = ^TStockTickInt64;

  TStockTickInt64 = packed record
    m_nTime: short; // 当前时间（距开盘分钟数）
    m_Buy: TStockTick_Buy;
    m_lNewPrice: LongInt; // 成交价
    m_lCurrent: Int64; // 成交量
    m_lBuyPrice: LongInt; // 委买价
    m_lSellPrice: LongInt; // 委卖价
    m_nChiCangLiang: ULONG; // 持仓量,深交所股票单笔成交数,港股成交盘分类(Y,M,X等，根据数据源再确定）
  end;

  TStockTicksInt64 = array [0 .. MaxCount] of TStockTickInt64;
  PStockTicksInt64 = ^TStockTicksInt64;

  PAnsStockTickInt64 = ^TAnsStockTickInt64;

  TAnsStockTickInt64 = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSize: LongInt; // 数据个数
    m_traData: Array [0 .. 0] of TStockTickInt64; // 分笔数据
  end;

  // 64位协议综合排名报表数据项 */
  TGeneralSortInt64Data = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_lNewPrice: LongInt; // 最新价
    m_lValue: Int64; // 计算值
  end;

  TGeneralSortInt64Datas = array [0 .. MaxCount] of TGeneralSortInt64Data;
  PGeneralSortInt64Datas = ^TGeneralSortInt64Datas;

  /// *返回结构*/
  PAnsGeneralSortInt64Ex = ^TAnsGeneralSortInt64Ex;

  TAnsGeneralSortInt64Ex = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nSortType: short; // 排序类型
    m_nSize: short; // 单个子包所含数据GeneralSortData个数
    // 当m_ nSortType为单值时（只有一位为1）,
    // 表示m_prptData数组的个数为m_nSize个。
    // 当m_ nSortType为多值相或时（如N位为1），表示此返回包针对N个子包，
    // 每个子包所含GeneralSortData个数为m_nSize，数组m_prptData的长度为N*m_nSize。
    m_nAlignment: short; // 字节对齐
    m_nMinuteCount: short; // 用于综合排名中快速排名窗口的几份钟排名设置。
    // 0 使用服务器默认分钟数
    // 1 ... 15为合法取值(一般可能的取值为1,2,3,4,5,10,15)
    m_prptData: array [0 .. 0] of TGeneralSortInt64Data; // 数据
  end;

  // 64位行情排序返回结构 */
  PAnsReportInt64Data = ^TAnsReportInt64Data;

  TAnsReportInt64Data = packed record
    m_dhHead: TDataHead; // 数据头
    m_nSize: short; // 数据个数
    m_nAlignment: short; // 为了4字节对齐而添加的字段
    m_prptData: array [0 .. 0] of TCommRealTimeInt64Data_Ext; // 数据
  end;

implementation

end.
