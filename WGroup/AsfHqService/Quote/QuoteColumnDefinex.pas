unit QuoteColumnDefinex;

interface

{*******************************************************************************
* �ļ����ƣ���Ӧ����HSColumnDefinex.h�ļ�
* �ļ���ʶ��ȡ��������ʱ=    RT_HQCOL_VALUE;��ID�Ķ����ļ�
*******************************************************************************}

const
{ ���������ж���				0-9999 }
  HQ_COL_BASE_BEGIN	 =			0;									// 0
  HQ_COL_BASE_END		 = HQ_COL_BASE_BEGIN + 9999;			// 9999

{ ��չ�����ж���				10000-19999 }
  HQ_COL_EX_BEGIN							=    HQ_COL_BASE_END + 1;				// 10000
  HQ_COL_EX_END							=    HQ_COL_EX_BEGIN + 9999;			// 19999

{* Ʒ����������ж���			20000-39999
 *      ָ��					20000-20999
 *      ծȯ					21000-21999
 *      �ڻ�					22000-22999
 *      ����					23000-23999
 *      �۹�					24000-24999
 }
  HQ_COL_KIND_INFO_BEGIN					=    HQ_COL_EX_END + 1;					// 20000
  HQ_COL_KIND_INFO_END					=    HQ_COL_KIND_INFO_BEGIN + 19999;	// 39999

{ Ʒ�����=    ָ��;�����ж���		20000-20999 }
  HQ_COL_INDEX_BEGIN						=    HQ_COL_KIND_INFO_BEGIN;			// 20000
  HQ_COL_INDEX_END						=    HQ_COL_INDEX_BEGIN + 999;			// 20999

{ Ʒ�����=    ծȯ;�����ж���		21000-21999 }
  HQ_COL_BOND_BEGIN						=    HQ_COL_INDEX_END + 1;				// 21000
  HQ_COL_BOND_END							=    HQ_COL_BOND_BEGIN + 999;			// 21999

{ Ʒ�����=    �ڻ�;�����ж���		22000-22999 }
  HQ_COL_FUTURES_BEGIN					=    HQ_COL_BOND_END + 1;				// 22000
  HQ_COL_FUTURES_END						=    HQ_COL_FUTURES_BEGIN + 999;		// 22999

{ Ʒ�����=    ����;�����ж���		23000-23999 }
  HQ_COL_FUND_BEGIN						=    HQ_COL_FUTURES_END + 1;			// 23000
  HQ_COL_FUND_END							=    HQ_COL_FUND_BEGIN + 999;			// 23999

{ Ʒ�����=    �۹�;�����ж���		24000-24999 }
  HQ_COL_HK_BEGIN							=    HQ_COL_FUND_END + 1;				// 24000
  HQ_COL_HK_END							=    HQ_COL_HK_BEGIN + 999;				// 24999

{ Ʒ�����=    �ֻ�;�����ж���		25000-25999 }
  HQ_COL_SPOT_BEGIN						=    HQ_COL_HK_END + 1;					// 25000
  HQ_COL_SPOT_END							=    HQ_COL_SPOT_BEGIN + 999;			// 25999

{ Ʒ�����=    ��Ȩ;�����ж���		26000-26999 }
  HQ_COL_OPTION_BEGIN						=    HQ_COL_SPOT_END + 1;			    // 26000
  HQ_COL_OPTION_END						=    HQ_COL_OPTION_BEGIN + 999;			// 26999

{ Ʒ�����=    �ɷ�ת��;�����ж��� 27000-27999 }
  HQ_COL_NEEQ_BEGIN						=    HQ_COL_OPTION_END + 1;			    // 27000
  HQ_COL_NEEQ_END						    =    HQ_COL_NEEQ_BEGIN + 999;			// 27999

{ �ɱ����������ж���			40000-49999 }
  HQ_COL_CAPITALIZATION_BEGIN				=    HQ_COL_KIND_INFO_END + 1;			// 40000
  HQ_COL_CAPITALIZATION_END				=    HQ_COL_CAPITALIZATION_BEGIN + 9999;// 49999

{ ���������������ֶζ���		50000-59999 }
  HQ_COL_FINANCE_BEGIN					=    HQ_COL_CAPITALIZATION_END + 1;		// 50000
  HQ_COL_FINANCE_END						=    HQ_COL_FINANCE_BEGIN + 9999;		// 59999

{ ��̬�����������ֶζ���		60000-69999 }
  HQ_COL_DYNAMIC_BEGIN                    =    HQ_COL_FINANCE_END + 1;            // 60000
  HQ_COL_DYNAMIC_END                      =    HQ_COL_DYNAMIC_BEGIN + 9999;       // 69999

{ ���۽����������ֶζ���       70000-79999 }
  HQ_COL_FIXEDPRICE_BEGIN                 =    HQ_COL_DYNAMIC_END + 1;            // 70000
  HQ_COL_FIXEDPRICE_END                   =    HQ_COL_FIXEDPRICE_BEGIN + 9999;    // 79999

{      ������ID								������IDֵ							// �ֶκ���					�ֶ���Դ							�ֶλ�ȡ�� }

{ ���������ж���				0-9999
  HQ_COL_BASE_BEGIN						=    0;									// 0
  HQ_COL_BASE_END							=    HQ_COL_BASE_BEGIN + 9999;			// 9999
 }
  HQ_COL_BASE_NUMBER						=    HQ_COL_BASE_BEGIN + 1;				// ���						��ǰ���Ĺ�Ʊ���						����
  HQ_COL_BASE_ARROW						=    HQ_COL_BASE_BEGIN + 2;				// ���¼�ͷ					�ǵ����=    �ǣ��ϼ�ͷ�������¼�ͷ;		����
  HQ_COL_BASE_CODE						=    HQ_COL_BASE_BEGIN + 3;				// ��Ʊ����					CodeInfo::m_cCode[6]					����
  HQ_COL_BASE_NAME						=    HQ_COL_BASE_BEGIN + 4;				// ��Ʊ����					StockUserInfo::m_cStockName				����
  HQ_COL_BASE_PRECLOSE					=    HQ_COL_BASE_BEGIN + 5;				// ����						StockUserInfo::m_lPrevClose				����/������
  HQ_COL_BASE_OPEN						=    HQ_COL_BASE_BEGIN + 6;				// ���̼۸�					HSStockRealTime::m_lOpen				������
  HQ_COL_BASE_MAX_PRICE					=    HQ_COL_BASE_BEGIN + 7;				// ��߼�					HSStockRealTime::m_lMaxPrice			������
  HQ_COL_BASE_MIN_PRICE					=    HQ_COL_BASE_BEGIN + 8;				// ��ͼ�					HSStockRealTime::m_lMinPrice			������
  HQ_COL_BASE_NEW_PRICE					=    HQ_COL_BASE_BEGIN + 9;				// �ɽ���=    �ּۡ����¼�;	HSStockRealTime::m_lNewPrice			������
  HQ_COL_BASE_TOTAL_HAND					=    HQ_COL_BASE_BEGIN + 10;			// ����						HSStockRealTime::m_lTotal				������
  HQ_COL_BASE_MONEY						=    HQ_COL_BASE_BEGIN + 11;			// �ɽ����=    �ܽ��;		HSStockRealTime::m_fAvgPrice			������
  HQ_COL_BASE_ORDER_BUY_VOLUME			=    HQ_COL_BASE_BEGIN + 12;			// ί����=    ��һ��;			HSStockRealTime::m_lBuyCount1			������
  HQ_COL_BASE_ORDER_SELL_VOLUME			=    HQ_COL_BASE_BEGIN + 13;			// ί����=    ��һ��;			HSStockRealTime::m_lSellCount1			������
  HQ_COL_BASE_ORDER_BUY_PRICE				=    HQ_COL_BASE_BEGIN + 14;			// ί���=    ��һ��;			HSStockRealTime::m_lBuyPrice1			������
  HQ_COL_BASE_ORDER_SELL_PRICE			=    HQ_COL_BASE_BEGIN + 15;			// ί����=    ��һ��;			HSStockRealTime::m_lSellPrice1			������
  HQ_COL_BASE_HAND						=    HQ_COL_BASE_BEGIN + 16;			// ÿ�ֹ���					HSStockRealTime::m_nHand				������
  HQ_COL_BASE_CUR_HANDS					=    HQ_COL_BASE_BEGIN + 17;			// ����						StockOtherData::m_lCurrent				������
  HQ_COL_BASE_IN_HANDS					=    HQ_COL_BASE_BEGIN + 18;			// ����						StockOtherData::m_lInside				������
  HQ_COL_BASE_OUT_HANDS					=    HQ_COL_BASE_BEGIN + 19;			// ����						StockOtherData::m_lOutside				������
  HQ_COL_BASE_SPEEDUP						=    HQ_COL_BASE_BEGIN + 20;			// ����=    ʹ�øù��ܺ�;		HSStockRealTimeOther::m_fSpeedUp		������
//  HQ_COL_BASE_STOP_FLAG					=    HQ_COL_BASE_BEGIN + 21;			// ͣ�̱�־					HSStockRealTimeOther::m_lStopFlag		������
  HQ_COL_BASE_AVERAGE_PRICE				=    HQ_COL_BASE_BEGIN + 22;			// ����						�ܳɽ���� / �ܳɽ���					������
  HQ_COL_BASE_RISE_VALUE					=    HQ_COL_BASE_BEGIN + 23;			// �ǵ�ֵ					�ּ� - ����								������
  HQ_COL_BASE_RANGE						=    HQ_COL_BASE_BEGIN + 24;			// ���						=    ��߼� - ��ͼ�;/ ����					������
  HQ_COL_BASE_RISE_RATIO					=    HQ_COL_BASE_BEGIN + 25;			// �ǵ���=    ����;			=    �ּ� - ����;/ ����						������
  HQ_COL_BASE_ORDER_RATIO					=    HQ_COL_BASE_BEGIN + 26;			// ί��						=    ί�� - ί��;/ =    ί�� + ί��;			������
  HQ_COL_BASE_ORDER_DIFF					=    HQ_COL_BASE_BEGIN + 27;			// ί��						ί�� - ί��								������
  HQ_COL_BASE_VOLUME_RATIO				=    HQ_COL_BASE_BEGIN + 28;			// ����						�ɽ��� * ��ʱ�� / =    ������ * ����ʱ��;	������
  HQ_COL_BASE_INFO_MARK                   =    HQ_COL_BASE_BEGIN + 29;            // ��Ϣ����

{ ��չ�����ж���				10000-19999
  HQ_COL_EX_BEGIN							=    HQ_COL_BASE_END + 1;				// 10000
  HQ_COL_EX_END							=    HQ_COL_EX_BEGIN + 9999;			// 19999
}
  HQ_COL_EX_BUY_PRICE1					=    HQ_COL_EX_BEGIN + 1;				// ����۸�һ				HSStockRealTime::m_lBuyPrice1			����/������
  HQ_COL_EX_BUY_PRICE2					=    HQ_COL_EX_BEGIN + 2;				// ����۸��				HSStockRealTime::m_lBuyPrice2			����/������
  HQ_COL_EX_BUY_PRICE3					=    HQ_COL_EX_BEGIN + 3;				// ����۸���				HSStockRealTime::m_lBuyPrice3			����/������
  HQ_COL_EX_BUY_PRICE4					=    HQ_COL_EX_BEGIN + 4;				// ����۸���				HSStockRealTime::m_lBuyPrice4			����/������
  HQ_COL_EX_BUY_PRICE5					=    HQ_COL_EX_BEGIN + 5;				// ����۸���				HSStockRealTime::m_lBuyPrice5			����/������
  HQ_COL_EX_BUY_VOLUME1					=    HQ_COL_EX_BEGIN + 6;				// ��������һ				HSStockRealTime::m_lBuyCount1			����/������
  HQ_COL_EX_BUY_VOLUME2					=    HQ_COL_EX_BEGIN + 7;				// ����������				HSStockRealTime::m_lBuyCount2			����/������
  HQ_COL_EX_BUY_VOLUME3					=    HQ_COL_EX_BEGIN + 8;				// ����������				HSStockRealTime::m_lBuyCount3			����/������
  HQ_COL_EX_BUY_VOLUME4					=    HQ_COL_EX_BEGIN + 9;				// ����������				HSStockRealTime::m_lBuyCount4			����/������
  HQ_COL_EX_BUY_VOLUME5					=    HQ_COL_EX_BEGIN + 10;				// ����������				HSStockRealTime::m_lBuyCount5			����/������
  HQ_COL_EX_SELL_PRICE1					=    HQ_COL_EX_BEGIN + 11;				// �����۸�һ				HSStockRealTime::m_lSellPrice1			����/������
  HQ_COL_EX_SELL_PRICE2					=    HQ_COL_EX_BEGIN + 12;				// �����۸��				HSStockRealTime::m_lSellPrice2			����/������
  HQ_COL_EX_SELL_PRICE3					=    HQ_COL_EX_BEGIN + 13;				// �����۸���				HSStockRealTime::m_lSellPrice3			����/������
  HQ_COL_EX_SELL_PRICE4					=    HQ_COL_EX_BEGIN + 14;				// �����۸���				HSStockRealTime::m_lSellPrice4			����/������
  HQ_COL_EX_SELL_PRICE5					=    HQ_COL_EX_BEGIN + 15;				// �����۸���				HSStockRealTime::m_lSellPrice5			����/������
  HQ_COL_EX_SELL_VOLUME1					=    HQ_COL_EX_BEGIN + 16;				// ��������һ				HSStockRealTime::m_lSellCount1			����/������
  HQ_COL_EX_SELL_VOLUME2					=    HQ_COL_EX_BEGIN + 17;				// ����������				HSStockRealTime::m_lSellCount2			����/������
  HQ_COL_EX_SELL_VOLUME3					=    HQ_COL_EX_BEGIN + 18;				// ����������				HSStockRealTime::m_lSellCount3			����/������
  HQ_COL_EX_SELL_VOLUME4					=    HQ_COL_EX_BEGIN + 19;				// ����������				HSStockRealTime::m_lSellCount4			����/������
  HQ_COL_EX_SELL_VOLUME5					=    HQ_COL_EX_BEGIN + 20;				// ����������				HSStockRealTime::m_lSellCount5			����/������
  HQ_COL_EX_5DAY_AVGVOLUME				=    HQ_COL_EX_BEGIN + 21;				// 5��ƽ���� 				StockUserInfo::m_l5DayVol				����/������
  HQ_COL_EX_UPPRICE						=    HQ_COL_EX_BEGIN + 22;				// ��ͣ���					SeverCalculateData::m_fUpPrice			����/������
  HQ_COL_EX_DOWNPRICE						=    HQ_COL_EX_BEGIN + 23;				// ��ͣ���					SeverCalculateData::m_fDownPrice		����/������
//  HQ_COL_EX_MARKETNAME					=    HQ_COL_EX_BEGIN + 24;				// �г�����					�ùɵ��г�����=    ȫ��;					����
//  HQ_COL_EX_MARKETSHORTNAME				=    HQ_COL_EX_BEGIN + 25;				// �г����					�ùɵ��г�����=    ���;					����
  HQ_COL_EX_SPECIAL_MARKER				=    HQ_COL_EX_BEGIN + 26;				// ��ʾ��Ʊ�������Եı���ֶΣ����Ƿ�Ϊ�۹�ͨ��
	///��������HQ_COL_EX_SPECIAL_MARKER ֵ�ĺ���
	  SM_DELIST_WARNING    =       $01;  ///< ���о�ʾ���
	  SM_RISK_WARNING      =       $02;  ///< ���վ�ʾ���
	  SM_CRD_BUY           =       $04;  ///< ���ʱ��
	  SM_CRD_SELL          =       $08;  ///< ��ȯ���
	  SM_SH2HK             =       $10;  ///< ����ͨ���=    �������;
	  SM_HK2SH             =       $20;  ///< �۹�ͨ���=    �������;
	  SM_SH2HK_ONLY_SELL   =       $40;  ///< ����ͨ���=    ֻ����;
	  SM_HK2SH_ONLY_SELL   =       $80;  ///< �۹�ͨ���=    ֻ����;

// ֮ǰ����֤�ص�ָ���ķ�Χ �����Ѿ����͵�ָ�� ��Щ���ֶη�Χ�ճ���
  HQ_COL_EX_EXHAND_RATIO			  	    =    HQ_COL_EX_BEGIN + 33;			    // ������ 					�ɽ���=    ��λ����; / �ܹɱ�		��������֧��
{ �����ֶη�������֧�� }
  HQ_COL_EX_PE_RATIO  					=    HQ_COL_EX_BEGIN + 34;				// ��ӯ�� 					���¼� / ÿ��������				��������֧��
  HQ_COL_EX_PB							=    HQ_COL_EX_BEGIN + 35;				// �о���					���¼� / ÿ�ɾ��ʲ�				��������֧��
//  HQ_COL_EX_DIRECTION   				=    HQ_COL_EX_BEGIN + 36;				// �ɽ�����					��ʾ������ʵ���������					��֧��
  HQ_COL_EX_MARKET_CAPITALIZATION			=    HQ_COL_EX_BEGIN + 37;				// ��ͨ��ֵ					���¼� * ��ͨA��						������
  HQ_COL_EX_TOTAL_MARKET_CAPITALIZATION	=    HQ_COL_EX_BEGIN + 38;				// ����ֵ					���¼� * �ܹɱ�							������
//  HQ_COL_EX_ORDER_BUY_AVGPRICE			=    HQ_COL_EX_BEGIN + 39;				// ί�����															������
//  HQ_COL_EX_ORDER_SELL_AVGPRICE			=    HQ_COL_EX_BEGIN + 40;				// ί������															������
//  HQ_COL_EX_ORDER_BUY_TOTAL_VOLUME		=    HQ_COL_EX_BEGIN + 41;				// ί������															������
//  HQ_COL_EX_ORDER_SELL_TOTAL_VOLUME		=    HQ_COL_EX_BEGIN + 42;				// ί������															������
  HQ_COL_EX_BUY_ORDER_COUNT				=    HQ_COL_EX_BEGIN + 43;				// ���뵥��															������
  HQ_COL_EX_SELL_ORDER_COUNT			    =    HQ_COL_EX_BEGIN + 44;				// ��������															������
  HQ_COL_EX_BUY_ORDER_MID				    =    HQ_COL_EX_BEGIN + 45;				// �е�����															������
  HQ_COL_EX_BUY_ORDER_BIG				    =    HQ_COL_EX_BEGIN + 46;				// ������															������
  HQ_COL_EX_BUY_ORDER_HUGE				=    HQ_COL_EX_BEGIN + 47;				// �ش�����															������
  HQ_COL_EX_SELL_ORDER_MID				=    HQ_COL_EX_BEGIN + 48;				// �е�����															������
  HQ_COL_EX_SELL_ORDER_BIG				=    HQ_COL_EX_BEGIN + 49;				// ������															������
  HQ_COL_EX_SELL_ORDER_HUGE				=    HQ_COL_EX_BEGIN + 50;				// �ش�����															������
  HQ_COL_EX_BUY_ORDER_INSTITUTION		    =    HQ_COL_EX_BEGIN + 51;				// �����򵥳Ի���			ί���л����ҵ�������					������
  HQ_COL_EX_SELL_ORDER_INSTITUTION		=    HQ_COL_EX_BEGIN + 52;				// ���������Ի���			ί�����л����ҵ�������					������
  HQ_COL_EX_ORDER_DIFF_INSTITUTION		=    HQ_COL_EX_BEGIN + 53;				// ����������				�����򵥳Ի��� - ���������Ի���			������
//  HQ_COL_EX_BUY_INSTITUTION				=    HQ_COL_EX_BEGIN + 54;				// �����Ի���				�����򵥳ɽ��ĵ���						������
//  HQ_COL_EX_SELL_INSTITUTION			=    HQ_COL_EX_BEGIN + 55;				// �����»���				���������ɽ��ĵ���						������
//  HQ_COL_EX_BUY_HAND_INSTITUTION		=    HQ_COL_EX_BEGIN + 56;				// �����Ի���				�������������							������
//  HQ_COL_EX_SELL_HAND_INSTITUTION		=    HQ_COL_EX_BEGIN + 57;				// �����»���				��������������							������
//  HQ_COL_EX_BUY_AVGRAGE_INSTITUTION		=    HQ_COL_EX_BEGIN + 58;				// �����Ի�����			�����Ի��� * ÿ�ֹ��� / �����Ի��� * �ּ�	������
//  HQ_COL_EX_SELL_AVGRAGE_INSTITUTION	=    HQ_COL_EX_BEGIN + 59;				// �����»�����			�����»��� * ÿ�ֹ��� / �����»��� * �ּ�	������
  HQ_COL_EX_DDX							=    HQ_COL_EX_BEGIN + 60;				// DDX
  HQ_COL_EX_DDY							=    HQ_COL_EX_BEGIN + 61;				// DDY
  HQ_COL_EX_DDZ							=    HQ_COL_EX_BEGIN + 62;				// DDZ
  HQ_COL_EX_DDX_5DAY						=    HQ_COL_EX_BEGIN + 63;				// 5��DDX
  HQ_COL_EX_DDY_5DAY						=    HQ_COL_EX_BEGIN + 64;				// 5��DDY
  HQ_COL_EX_DDX_60DAY						=    HQ_COL_EX_BEGIN + 65;				// 60��DDX
  HQ_COL_EX_DDY_60DAY						=    HQ_COL_EX_BEGIN + 66;				// 60��DDY
  HQ_COL_EX_10DAY_RED						=    HQ_COL_EX_BEGIN + 67;				// 10����Ʈ������
  HQ_COL_EX_10DAY_RED_CONSTANCY			=    HQ_COL_EX_BEGIN + 68;				// 10��������Ʈ������
  HQ_COL_EX_MAX_PRICE64                   =    HQ_COL_EX_BEGIN + 69;              // ��߱���=    64λ;
  HQ_COL_EX_MAX_VOLUME64                  =    HQ_COL_EX_BEGIN + 70;              // �������=    64λ;
  HQ_COL_EX_DDZ_5DAY	                    =    HQ_COL_EX_BEGIN + 71;              // 5��DDZ
  HQ_COL_EX_DDZ_60DAY	                    =    HQ_COL_EX_BEGIN + 72;              // 60��DDZ
  HQ_COL_EX_DDE_VOLUME	                =    HQ_COL_EX_BEGIN + 73;              // DDE�ɽ���
  HQ_COL_EX_DDE_TRADE	                    =    HQ_COL_EX_BEGIN + 74;	            // DDE�ɽ���
  HQ_COL_EX_BUY_ORDER_SMALL_AMOUNT        =    HQ_COL_EX_BEGIN + 75;              // С������
  HQ_COL_EX_BUY_ORDER_MID_AMOUNT          =    HQ_COL_EX_BEGIN + 76;              // �е�����
  HQ_COL_EX_BUY_ORDER_BIG_AMOUNT          =    HQ_COL_EX_BEGIN + 77;              // ������
  HQ_COL_EX_SELL_ORDER_SMALL_AMOUNT       =    HQ_COL_EX_BEGIN + 78;              // С������
  HQ_COL_EX_SELL_ORDER_MID_AMOUNT         =    HQ_COL_EX_BEGIN + 79;              // �е�����
  HQ_COL_EX_SELL_ORDER_BIG_AMOUNT         =    HQ_COL_EX_BEGIN + 80;              // ������

  HQ_COL_EX_AH_TOTAL_MARKET_CAPITALIZATION =    HQ_COL_EX_BEGIN + 81;				// AH����ֵ
  HQ_COL_EX_AH_PREMIUM_VALUE				=    HQ_COL_EX_BEGIN + 82;				// AH���
  HQ_COL_EX_AH_PREMIUM_RATE				=    HQ_COL_EX_BEGIN + 83;				// AH�����

{ Ʒ�����=    ָ��;�����ж���		20000-20999
  HQ_COL_INDEX_BEGIN						=    HQ_COL_KIND_INFO_BEGIN;			// 20000
  HQ_COL_INDEX_END						=    HQ_COL_INDEX_BEGIN + 999;			// 20999
}
  HQ_COL_INDEX_RISE_COUNT					=    HQ_COL_INDEX_BEGIN + 1;			// ���Ǽ���					HSIndexRealTime::m_nRiseCount			������
  HQ_COL_INDEX_FALL_COUNT					=    HQ_COL_INDEX_BEGIN + 2;			// �µ�����					HSIndexRealTime::m_nFallCount			������
  HQ_COL_INDEX_TOTAL_STOCK1				=    HQ_COL_INDEX_BEGIN + 3;			// �ۺ�ָ�������й�Ʊ-ָ��	HSIndexRealTime::m_nTotalStock1			������
  HQ_COL_INDEX_TOTAL_STOCK2				=    HQ_COL_INDEX_BEGIN + 4;			// �ۺ�ָ����A��+B�� ����ָ����0	HSIndexRealTime::m_nTotalStock2	������
//  HQ_COL_INDEX_TYPE						=    HQ_COL_INDEX_BEGIN + 5;			// ָ�����ࣺ0-�ۺ�ָ��1-A��2-B��	HSIndexRealTime::m_nType		������
//  HQ_COL_INDEX_LEAD						=    HQ_COL_INDEX_BEGIN + 6;			// ����ָ��					HSIndexRealTime::m_nLead				������
//  HQ_COL_INDEX_RISE_TREND				=    HQ_COL_INDEX_BEGIN + 7;			// ��������					HSIndexRealTime::m_nRiseTrend			������
//  HQ_COL_INDEX_FALL_TREND				=    HQ_COL_INDEX_BEGIN + 8;			// �µ�����					HSIndexRealTime::m_nFallTrend			������
{ �����ֶη������ݲ�֧�� }
  HQ_COL_INDEX_EQUAL_COUNT				=    HQ_COL_INDEX_BEGIN + 9;			// ƽ�̼���					���ǻ����ֶΣ��ͻ����Լ���		��������֧��
  HQ_COL_INDEX_SAMPLE_COUNT				=    HQ_COL_INDEX_BEGIN + 10;			// ��������					��֤�ص�ָ������������					����
  HQ_COL_INDEX_SAMPLE_AVERAGE				=    HQ_COL_INDEX_BEGIN + 11;			// ��������					��֤�ص�ָ������������					����
  HQ_COL_INDEX_TURNOVER					=    HQ_COL_INDEX_BEGIN + 12;			// �ɽ���=    ��Ԫ;			��֤�ص�ָ���ĳɽ���=    ��Ԫ;				����
  HQ_COL_INDEX_AVERAGE_EQUITY				=    HQ_COL_INDEX_BEGIN + 13;			// ƽ���ɱ�=    �ڹ�;			��֤�ص�ָ����ƽ���ɱ�=    �ڹ�;			����
  HQ_COL_INDEX_MARKET_VALUE				=    HQ_COL_INDEX_BEGIN + 14;			// ����ֵ=    ����;			��֤�ص�ָ��������ֵ=    ����;				����
  HQ_COL_INDEX_RATIO						=    HQ_COL_INDEX_BEGIN + 15;			// ռ��=    %;					��֤�ص�ָ����ռ��=    %;					����
  HQ_COL_INDEX_STATIC_PER					=    HQ_COL_INDEX_BEGIN + 16;			// ��̬��ӯ��				��֤�ص�ָ���ľ�̬��ӯ��				����
// ���ָ������
  HQ_COL_INDEX_RISE_CODE					=    HQ_COL_INDEX_BEGIN + 17;           // ���ǹ�Ʊ����			HSIndexRealTimeOther::m_szRiseCode		����
  HQ_COL_INDEX_RISE_FLUCTUATION		    =    HQ_COL_INDEX_BEGIN + 18;           // ���ǹ�Ʊ�Ƿ�			HSIndexRealTimeOther::m_lRise			����
  HQ_COL_INDEX_FALL_CODE                  =    HQ_COL_INDEX_BEGIN + 19;           // �����Ʊ����			HSIndexRealTimeOther::m_szFallCode		����
  HQ_COL_INDEX_FALL_FLUCTUATION           =    HQ_COL_INDEX_BEGIN + 20;           // �����Ʊ����			HSIndexRealTimeOther::m_lFall			����
  HQ_COL_INDEX_INDUSTRY_LEVEL				=    HQ_COL_INDEX_BEGIN + 21;			// ��ҵ�ּ�					HSIndexRealTimeOther::m_nNo2[0]			����
  HQ_COL_INDEX_CLASSIFIED_CODE			=    HQ_COL_INDEX_BEGIN + 22;			// �ּ�����

{ Ʒ�����=    ծȯ;�����ж���		21000-21999
  HQ_COL_BOND_BEGIN						=    HQ_COL_INDEX_END + 1;				// 21000
  HQ_COL_BOND_END							=    HQ_COL_BOND_BEGIN + 999;			// 21999
}
  HQ_COL_BOND_ACCRUAL 					=    HQ_COL_BOND_BEGIN + 1;				// ��Ϣ						HSStockRealTime::m_lNationalDebtRatio	������
{ �����ֶη������ݲ�֧�� }
  HQ_COL_BOND_TOTAL_VALUE					=    HQ_COL_BOND_BEGIN + 2;				// ȫ��						��Ϣ + �ּ�						��������֧��

{ Ʒ�����=    �ڻ�;�����ж���		22000-22999
  HQ_COL_FUTURES_BEGIN					=    HQ_COL_BOND_END + 1;				// 22000
  HQ_COL_FUTURES_END						=    HQ_COL_FUTURES_BEGIN + 999;		// 22999
}
  HQ_COL_FUTURES_AMOUNT					=    HQ_COL_FUTURES_BEGIN + 1;			// �ֲ���					HSQHRealTime::m_lChiCangLiang			������
  HQ_COL_FUTURES_PREAMOUNT				=    HQ_COL_FUTURES_BEGIN + 2;			// ��ֲ���					HSQHRealTime::m_lPreCloseChiCang		������
  HQ_COL_FUTURES_SETTLE					=    HQ_COL_FUTURES_BEGIN + 3;			// �����					HSQHRealTime::m_lJieSuanPrice			������
  HQ_COL_FUTURES_PRESETTLE				=    HQ_COL_FUTURES_BEGIN + 4;			// ������					HSQHRealTime::m_lPreJieSuanPrice		������
  HQ_COL_FUTURES_HIS_HIGH					=    HQ_COL_FUTURES_BEGIN + 5;			// ʷ���					HSQHRealTime::m_lHIS_HIGH				������
  HQ_COL_FUTURES_HIS_LOW					=    HQ_COL_FUTURES_BEGIN + 6;			// ʷ���					HSQHRealTime::m_lHIS_LOW				������
  HQ_COL_FUTURES_CURRENT_CLOSE			=    HQ_COL_FUTURES_BEGIN + 7;			// ������					HSQHRealTime::m_lCurrentCLOSE			������
  HQ_COL_FUTURES_PRE_CLOSE				=    HQ_COL_FUTURES_BEGIN + 8;			// ǰ������					HSQHRealTime::m_lPreClose				������
{ �ֶη������ݲ�֧�� }
  HQ_COL_FUTURES_OPEN_INTEREST_DAY		=    HQ_COL_FUTURES_BEGIN + 9;			// ������					�ֲ��� - ��ֲ���			    	    ��������֧��
{ }
  HQ_COL_FUTURES_CONTRACT_MULTIPLIER_UNIT =    HQ_COL_FUTURES_BEGIN + 10;         // ��Լ����                 �����ֶ�����                            ������

{ Ʒ�����=    ����;�����ж���		23000-23999
  HQ_COL_FUND_BEGIN						=    HQ_COL_FUTURES_END + 1;			// 23000
  HQ_COL_FUND_END							=    HQ_COL_FUND_BEGIN + 999;			// 23999
}
  HQ_COL_FUND_NETVALUE					=    HQ_COL_FUND_BEGIN + 1;				// ����ֵ					HSStockRealTime::m_lNationalDebtRatio	������


{ Ʒ�����=    �۹�;�����ж���		24000-24999
  HQ_COL_HK_BEGIN							=    HQ_COL_FUND_END + 1;				// 24000
  HQ_COL_HK_END							=    HQ_COL_HK_BEGIN + 999;				// 24999
}
  HQ_COL_HK_BUY_PRICE						=    HQ_COL_HK_BEGIN + 1;				// �������					HSHKStockRealTime::m_lBuyPrice			������
  HQ_COL_HK_BUY_SPEED						=    HQ_COL_HK_BEGIN + 2;				// ��۲�					HSHKStockRealTime::m_lBuySpread			������
  HQ_COL_HK_SELL_PRICE					=    HQ_COL_HK_BEGIN + 3;				// ��������					HSHKStockRealTime::m_lSellPrice			������
  HQ_COL_HK_SELL_SPEED					=    HQ_COL_HK_BEGIN + 4;				// ���۲�					HSHKStockRealTime::m_lSellSpread		������
  HQ_COL_HK_IEV							=    HQ_COL_HK_BEGIN + 5;				// �������̼�				HSHKStockRealTime::m_lIEV				������
  HQ_COL_HK_H_CODE						=    HQ_COL_HK_BEGIN + 6;				// H�ɴ���					CodeInfo::m_cCode[6]					����
  HQ_COL_HK_H_NAME						=    HQ_COL_HK_BEGIN + 7;				// H������					StockUserInfo::m_cStockName				����
  HQ_COL_HK_H_RISE_RATIO					=    HQ_COL_HK_BEGIN + 8;				// H���ǵ���=    ����;			=    �ּ� - ����;/ ����					������
  HQ_COL_HK_H_NEW_PRICE					=    HQ_COL_HK_BEGIN + 9;				// H�ɳɽ���=    �ּۡ����¼�;HSStockRealTime::m_lNewPrice			������
  HQ_COL_HK_H_EXHAND_RATIO			  	=    HQ_COL_HK_BEGIN + 10;			    // H�ɻ����� 				�ɽ���=    ��λ����; / �ܹɱ�				��������֧��

{ Ʒ�����=    ��Ʒ;�����ж���		25000-25999
  HQ_COL_SPOT_BEGIN						=    HQ_COL_HK_END + 1;					// 25000
  HQ_COL_SPOT_END							=    HQ_COL_SPOT_BEGIN + 999;			// 25999
}
  HQ_COL_SPOT_ORDER_AMOUNT				=    HQ_COL_SPOT_BEGIN + 1;				// ������					HSSpotRealTime::m_lOrderAmount			������
  HQ_COL_SPOT_DAILY_END_PRICE	            =    HQ_COL_SPOT_BEGIN + 2;	            // ����ֹ��					HSSpotRealTime::m_lReserved				uint32
  HQ_COL_SPOT_DAILY_INCREASED_VOL	        =    HQ_COL_SPOT_BEGIN + 3;	            // ������					��										uint64
  HQ_COL_SPOT_DAILY_DECREASED_VOL	        =    HQ_COL_SPOT_BEGIN + 4;	            // �ռ���					��										uint64



{ Ʒ�����=    ��Ȩ;�����ж���		26000-26999
  HQ_COL_OPTION_BEGIN						=    HQ_COL_SPOT_END + 1;			    // 26000
  HQ_COL_OPTION_END					    =    HQ_COL_OPTION_BEGIN + 999;			// 26999
}
  HQ_COL_OPTION_TREATY_CODE               =    HQ_COL_OPTION_BEGIN + 1;           // ��Լ����
  HQ_COL_OPTION_DEADLINE                  =    HQ_COL_OPTION_BEGIN + 2;           // ��������
  HQ_COL_OPTION_EXEPRICE					=    HQ_COL_OPTION_BEGIN + 3;           // ��Ȩ��
  HQ_COL_OPTION_UNDERLYING_CODE	        =    HQ_COL_OPTION_BEGIN + 4;           // ��Ĵ���															����
  HQ_COL_OPTION_UNDERLYING_CLOSE	        =    HQ_COL_OPTION_BEGIN + 5;           // �������															����
  HQ_COL_OPTION_DELTA	                    =    HQ_COL_OPTION_BEGIN + 6;           // ��ȨDeltaֵ														����
  HQ_COL_OPTION_THETA	                    =    HQ_COL_OPTION_BEGIN + 7;			// ��ȨThetaֵ														����
  HQ_COL_OPTION_GAMMA						=    HQ_COL_OPTION_BEGIN + 8;			// ��ȨGammaֵ														����
  HQ_COL_OPTION_VEGA						=    HQ_COL_OPTION_BEGIN + 9;			// ��ȨVegaֵ														����
  HQ_COL_OPTION_RHO						=    HQ_COL_OPTION_BEGIN + 10;			// ��ȨRhoֵ														����
  HQ_COL_OPTION_EXEDATE                   =    HQ_COL_OPTION_BEGIN + 11;          // ��Ȩʱ��                                                         ����
  HQ_COL_OPTION_STARTDATE                 =    HQ_COL_OPTION_BEGIN + 12;          // ���׿�ʼ                                                         ����
  HQ_COL_OPTION_ENDDATE                   =    HQ_COL_OPTION_BEGIN + 13;          // ���׽���										                    ����
  HQ_COL_OPTION_TYPE                      =    HQ_COL_OPTION_BEGIN + 14;          // ��Ȩ����                                                         ����
  HQ_COL_OPTION_FLAG                      =    HQ_COL_OPTION_BEGIN + 15;          // ������־                                                         ����
  HQ_COL_OPTION_AUCTION_PRICE	            =    HQ_COL_OPTION_BEGIN + 16;          // ��̬�ο���														HSOPTRealTime::m_lAutionPrice	uint32	ȡֵ������
  HQ_COL_OPTION_VIRTURAL_AUCTION_QTY	    =    HQ_COL_OPTION_BEGIN + 17;          // ����ƥ������													    HSOPTRealTime::m_fAutionQty	    uint64	��ȡֵ
  HQ_COL_OPTION_TRADING_PHASE_CODE	    =    HQ_COL_OPTION_BEGIN + 18;	        // ��Ʒʵʩ�׶α�־													HSOPTRealTime::m_cTradingPhase	int32	��ȡֵ
  HQ_COL_OPTION_SYMBOL	                =    HQ_COL_OPTION_BEGIN + 19;	        // ֤ȯ����															��string���� 16�ֽڣ�			        ��ȡֵ
  HQ_COL_OPTION_SECURITY_DESC	            =    HQ_COL_OPTION_BEGIN + 20;	        // ֤ȯ���															��string���� 18�ֽڣ�			        ��ȡֵ
  HQ_COL_OPTION_PRICING                   =    HQ_COL_OPTION_BEGIN + 21;          // ��Ȩ����
// δƽ�ֺ�Լ�����ǳֲ��� ��ȥ��
//   HQ_COL_OPTION_TOTAL_LONG_POSITION       =    HQ_COL_OPTION_BEGIN + 22;          // δƽ�ֺ�Լ��
  HQ_COL_OPTION_NATURE                    =    HQ_COL_OPTION_BEGIN + 23;          // ��Ȩ״̬                                                         ���ر�ʾ��ʵֵ����ֵ��ƽֵ      uint32
  HQ_COL_OPTION_MID_PRICE					=    HQ_COL_OPTION_BEGIN + 30;			// �����м��
  HQ_COL_OPTION_VOLUME					=    HQ_COL_OPTION_BEGIN + 31;			// ������
  HQ_COL_OPTION_SELL_DEPOSIT				=    HQ_COL_OPTION_BEGIN + 32;			// ������֤��
  HQ_COL_OPTION_PRICE_MARGIN				=    HQ_COL_OPTION_BEGIN + 33;			// �������
  HQ_COL_OPTION_TRADE_CODE				=    HQ_COL_OPTION_BEGIN + 34;			// ���״���
//   HQ_COL_OPTION_EMMBEDDED_VALUE_TYPE		=    HQ_COL_OPTION_BEGIN + 35;			// ��ʵ
  HQ_COL_OPTION_TIME_PRICE				=    HQ_COL_OPTION_BEGIN + 36;			// ʱ���ֵ
  HQ_COL_OPTION_INSIDE_PRICE				=    HQ_COL_OPTION_BEGIN + 37;			// ���ڼ�ֵ
  HQ_COL_OPTION_VIRTUAL_AMOUNT			=    HQ_COL_OPTION_BEGIN + 38;			// ��ֵ��
  HQ_COL_OPTION_IMPLIED_VOLATILITY		=    HQ_COL_OPTION_BEGIN + 39;			// ʵʱ����������
  HQ_COL_OPTION_BUY_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 40;			// �������������
  HQ_COL_OPTION_SELL_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 41;			// ��������������
  HQ_COL_OPTION_MID_IMPLIED_VOLATILITY	=    HQ_COL_OPTION_BEGIN + 42;			// �м������������
  HQ_COL_OPTION_VOLATILITY_PRICE_MARGIN	=    HQ_COL_OPTION_BEGIN + 43;			// �����ʲ��
  HQ_COL_OPTION_VEGA2						=    HQ_COL_OPTION_BEGIN + 44;			// ��Ȩvega2ֵ
  HQ_COL_OPTION_THETA2					=    HQ_COL_OPTION_BEGIN + 45;			// ��Ȩtheta2ֵ
  HQ_COL_OPTION_THETA3					=    HQ_COL_OPTION_BEGIN + 46;			// ��Ȩtheta3ֵ
  HQ_COL_OPTION_RHO2						=    HQ_COL_OPTION_BEGIN + 47;			// ��Ȩrho2ֵ
  HQ_COL_OPTION_PHI						=    HQ_COL_OPTION_BEGIN + 48;			// ��Ȩphiֵ
  HQ_COL_OPTION_PHI2						=    HQ_COL_OPTION_BEGIN + 49;			// ��Ȩphi2ֵ
  HQ_COL_OPTION_LAMBDA					=    HQ_COL_OPTION_BEGIN + 50;			// ��Ȩlambdaֵ
  HQ_COL_OPTION_STRIKE_DETLA				=    HQ_COL_OPTION_BEGIN + 51;			// ��Ȩstrike_detlaֵ
  HQ_COL_OPTION_ZETA						=    HQ_COL_OPTION_BEGIN + 52;			// ��Ȩzetaֵ
  HQ_COL_OPTION_D_ZETA_DVOL				=    HQ_COL_OPTION_BEGIN + 53;			// ��Ȩd_zeta_dvolֵ
  HQ_COL_OPTION_D_ZETAD_TIME				=    HQ_COL_OPTION_BEGIN + 54;			// ��Ȩd_zetad_timeֵ
  HQ_COL_OPTION_D_ZETAD_TIME2				=    HQ_COL_OPTION_BEGIN + 55;			// ��Ȩd_zetad_time2ֵ
  HQ_COL_OPTION_D_ZETAD_TIME3				=    HQ_COL_OPTION_BEGIN + 56;			// ��Ȩd_zetad_time3ֵ
  HQ_COL_OPTION_GAMMA_PERCENT				=    HQ_COL_OPTION_BEGIN + 57;			// ��Ȩgamma_percentֵ
  HQ_COL_OPTION_STRIKE_GAMMA				=    HQ_COL_OPTION_BEGIN + 58;			// ��Ȩstrike_gammaֵ
  HQ_COL_OPTION_VANNA						=    HQ_COL_OPTION_BEGIN + 59;			// ��Ȩvannaֵ
  HQ_COL_OPTION_VANNA2					=    HQ_COL_OPTION_BEGIN + 60;			// ��Ȩvanna2ֵ
  HQ_COL_OPTION_CHARM						=    HQ_COL_OPTION_BEGIN + 61;			// ��Ȩcharmֵ
  HQ_COL_OPTION_CHARM2					=    HQ_COL_OPTION_BEGIN + 62;			// ��Ȩcharm2ֵ
  HQ_COL_OPTION_CHARM3					=    HQ_COL_OPTION_BEGIN + 63;			// ��Ȩcharm3ֵ
  HQ_COL_OPTION_VETA						=    HQ_COL_OPTION_BEGIN + 64;			// ��Ȩvetaֵ
  HQ_COL_OPTION_VOMMA						=    HQ_COL_OPTION_BEGIN + 65;			// ��Ȩvommaֵ
  HQ_COL_OPTION_VOMMA2					=    HQ_COL_OPTION_BEGIN + 66;			// ��Ȩvomma2ֵ
  HQ_COL_OPTION_ULTIMA					=    HQ_COL_OPTION_BEGIN + 67;			// ��Ȩultimaֵ
  HQ_COL_OPTION_SPEED						=    HQ_COL_OPTION_BEGIN + 68;			// ��Ȩspeedֵ
  HQ_COL_OPTION_ZOOMA						=    HQ_COL_OPTION_BEGIN + 69;			// ��Ȩzoomaֵ
  HQ_COL_OPTION_COLOR						=    HQ_COL_OPTION_BEGIN + 70;			// ��Ȩcolorֵ

{ Ʒ�����=    �ɷ�ת��;�����ж��� 27000-27999
  HQ_COL_NEEQ_BEGIN						=    HQ_COL_OPTION_END + 1;			    // 27000
  HQ_COL_NEEQ_END						    =    HQ_COL_NEEQ_BEGIN + 999;			// 27999
}
  HQ_COL_NEEQ_TRANSFER_STATUS             =    HQ_COL_NEEQ_BEGIN + 1;             // ת��״̬ ��                                                                                      char    ��ȡֵ   ������ �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� ��
  HQ_COL_NEEQ_MARKET_MAKER_COUNT          =    HQ_COL_NEEQ_BEGIN + 2;             // ����������                                                                                       int32	��ȡֵ	 ������


{ �ɱ����������ж���			40000-49999
  HQ_COL_CAPITALIZATION_BEGIN				=    HQ_COL_KIND_INFO_END + 1;			// 40000
  HQ_COL_CAPITALIZATION_END				=    HQ_COL_CAPITALIZATION_BEGIN + 9999;// 49999
}
  HQ_COL_CAPITALIZATION_TOTAL				=    HQ_COL_CAPITALIZATION_BEGIN + 1;	// �ܹɱ�															����
//  HQ_COL_CAPITALIZATION_UNLIMITED		=    HQ_COL_CAPITALIZATION_BEGIN + 2;	// �����۹ɺϼ�														����
  HQ_COL_CAPITALIZATION_PASS_A			=    HQ_COL_CAPITALIZATION_BEGIN + 3;	// ��ͨA��															����
  HQ_COL_CAPITALIZATION_PASS_B			=    HQ_COL_CAPITALIZATION_BEGIN + 4;	// B��															����
  HQ_COL_CAPITALIZATION_PASS_H			=    HQ_COL_CAPITALIZATION_BEGIN + 5;	// H��															����
//  HQ_COL_CAPITALIZATION_PASS_ABROAD		=    HQ_COL_CAPITALIZATION_BEGIN + 6;	// �������й�														����
//  HQ_COL_CAPITALIZATION_PASS_OTHERS		=    HQ_COL_CAPITALIZATION_BEGIN + 7;	// ������ͨ��														����
//  HQ_COL_CAPITALIZATION_LIMITED			=    HQ_COL_CAPITALIZATION_BEGIN + 8;	// ���۹ɺϼ�														����
  HQ_COL_CAPITALIZATION_NATIONAL			=    HQ_COL_CAPITALIZATION_BEGIN + 9;	// ���й�													����
//  HQ_COL_CAPITALIZATION_CORP			=    HQ_COL_CAPITALIZATION_BEGIN + 10;	// ���ڷ��˹�														����
//  HQ_COL_CAPITALIZATION_PERSON			=    HQ_COL_CAPITALIZATION_BEGIN + 11;	// ������Ȼ�˹�														����
//  HQ_COL_CAPITALIZATION_INITIATOR_OTHERS	=    HQ_COL_CAPITALIZATION_BEGIN + 12;	// ���������˹�														����
  HQ_COL_CAPITALIZATION_INITIATOR			=    HQ_COL_CAPITALIZATION_BEGIN + 13;	// �����˷��˹�														����
//  HQ_COL_CAPITALIZATION_CORP_ABROAD		=    HQ_COL_CAPITALIZATION_BEGIN + 14;	// ���ⷨ�˹�														����
//  HQ_COL_CAPITALIZATION_PERSON_ABROAD	=    HQ_COL_CAPITALIZATION_BEGIN + 15;	// ������Ȼ�˹�														����
//  HQ_COL_CAPITALIZATION_PREFERRED		=    HQ_COL_CAPITALIZATION_BEGIN + 16;	// ���ȹɻ�����														����
  HQ_COL_CAPITALIZATION_CORPORATION		=    HQ_COL_CAPITALIZATION_BEGIN + 17;	// ���˹�															����
  HQ_COL_CAPITALIZATION_EMPLOYEE			=    HQ_COL_CAPITALIZATION_BEGIN + 18;	// ְ����															����
  HQ_COL_CAPITALIZATION_A2_GIVE			=    HQ_COL_CAPITALIZATION_BEGIN + 19;	// A2ת���															����
  HQ_COL_CAPITALIZATION_TOTAL_HK			=    HQ_COL_CAPITALIZATION_BEGIN + 20;	// �۹ɱ�


{ ���������������ֶζ���		50000-59999
  HQ_COL_FINANCE_BEGIN					=    HQ_COL_CAPITALIZATION_END + 1;		// 50000
  HQ_COL_FINANCE_END						=    HQ_COL_FINANCE_BEGIN + 9999;		// 59999
}
//  HQ_COL_FINANCE_PUBLISH_DATE			=    HQ_COL_FINANCE_BEGIN + 1;			// ��������															����
  HQ_COL_FINANCE_REPORT_DATE				=    HQ_COL_FINANCE_BEGIN + 2;			// ������															����
//  HQ_COL_FINANCE_PUBLIC_DATE			=    HQ_COL_FINANCE_BEGIN + 3;			// ��������															����
  HQ_COL_FINANCE_PER_INCOME				=    HQ_COL_FINANCE_BEGIN + 4;			// ÿ������															����
  HQ_COL_FINANCE_PER_ASSETS				=    HQ_COL_FINANCE_BEGIN + 5;			// ÿ�ɾ��ʲ�														����
  HQ_COL_FINANCE_ASSETS_YIELD				=    HQ_COL_FINANCE_BEGIN + 6;			// ���ʲ�������														����
//  HQ_COL_FINANCE_PER_SHARE_CASH			=    HQ_COL_FINANCE_BEGIN + 7;			// ÿ�ɾ�Ӫ�ֽ�														����
  HQ_COL_FINANCE_PER_SHARE_ACCFUND		=    HQ_COL_FINANCE_BEGIN + 8;			// ÿ�ɹ�����														����
  HQ_COL_FINANCE_PER_UNPAID				=    HQ_COL_FINANCE_BEGIN + 9;			// ÿ��δ����														����
  HQ_COL_FINANCE_PARTNER_RIGHT_RATIO  	=    HQ_COL_FINANCE_BEGIN + 10;			// �ɶ�Ȩ���														����
//  HQ_COL_FINANCE_NET_PROFIT_RATIO		=    HQ_COL_FINANCE_BEGIN + 11;			// ������ͬ��														����
//  HQ_COL_FINANCE_MAIN_INCOME_RATIO		=    HQ_COL_FINANCE_BEGIN + 12;			// ��Ӫ����ͬ��														����
//  HQ_COL_FINANCE_SALES_GROSS_MARGIN		=    HQ_COL_FINANCE_BEGIN + 13;			// ����ë����														����
  HQ_COL_FINANCE_ADJUST_PER_ASSETS		=    HQ_COL_FINANCE_BEGIN + 14;			// ����ÿ�ɾ��ʲ�													����
  HQ_COL_FINANCE_TOTAL_ASSETS				=    HQ_COL_FINANCE_BEGIN + 15;			// ���ʲ�															����
  HQ_COL_FINANCE_CURRENT_ASSETS			=    HQ_COL_FINANCE_BEGIN + 16;			// �����ʲ�															����
  HQ_COL_FINANCE_CAPITAL_ASSETS			=    HQ_COL_FINANCE_BEGIN + 17;			// �̶��ʲ�															����
  HQ_COL_FINANCE_UNBODIED_ASSETS			=    HQ_COL_FINANCE_BEGIN + 18;			// �����ʲ�															����
  HQ_COL_FINANCE_CURRENT_LIABILITIES  	=    HQ_COL_FINANCE_BEGIN + 19;			// ������ծ															����
  HQ_COL_FINANCE_LONG_LIABILITIES			=    HQ_COL_FINANCE_BEGIN + 20;			// ���ڸ�ծ															����
//  HQ_COL_FINANCE_TOTAL_DEBT				=    HQ_COL_FINANCE_BEGIN + 21;			// �ܸ�ծ															����
  HQ_COL_FINANCE_PARTNER_RIGHT			=    HQ_COL_FINANCE_BEGIN + 22;			// �ɶ�Ȩ��															����
  HQ_COL_FINANCE_CAPITAL_ACCFUND			=    HQ_COL_FINANCE_BEGIN + 23;			// �ʱ�������														����
//  HQ_COL_FINANCE_OPERATING_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 24;			// ��Ӫ�ֽ�����														����
//  HQ_COL_FINANCE_INVESTMENT_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 25;			// Ͷ���ֽ�����														����
//  HQ_COL_FINANCE_FINANCING_CASH_FLOW	=    HQ_COL_FINANCE_BEGIN + 26;			// �����ֽ�����														����
//  HQ_COL_FINANCE_CASH_INCREASEMENT		=    HQ_COL_FINANCE_BEGIN + 27;			// �ֽ����Ӷ�														����
  HQ_COL_FINANCE_MAIN_INCOME				=    HQ_COL_FINANCE_BEGIN + 28;			// ��Ӫ����															����
  HQ_COL_FINANCE_MAIN_PROFIT				=    HQ_COL_FINANCE_BEGIN + 29;			// ��Ӫ����															����
  HQ_COL_FINANCE_TAKING_PROFIT			=    HQ_COL_FINANCE_BEGIN + 30;			// Ӫҵ����															����
  HQ_COL_FINANCE_YIELD					=    HQ_COL_FINANCE_BEGIN + 31;			// Ͷ������															����
  HQ_COL_FINANCE_OTHER_INCOME				=    HQ_COL_FINANCE_BEGIN + 32;			// Ӫҵ����֧														����
  HQ_COL_FINANCE_TOTAL_PROFIT				=    HQ_COL_FINANCE_BEGIN + 33;			// �����ܶ�															����
  HQ_COL_FINANCE_RETAINED_PROFITS			=    HQ_COL_FINANCE_BEGIN + 34;			// ������															����
  HQ_COL_FINANCE_UNPAID_PROFIT			=    HQ_COL_FINANCE_BEGIN + 35;			// δ��������														����
  HQ_COL_FINANCE_LONG_INVESTMENT			=    HQ_COL_FINANCE_BEGIN + 36;			// ����Ͷ��  														����
  HQ_COL_FINANCE_OTHER_PROFIT				=    HQ_COL_FINANCE_BEGIN + 37;			// �������� 														����
  HQ_COL_FINANCE_SUBSIDY					=    HQ_COL_FINANCE_BEGIN + 38;			// ��������															����
  HQ_COL_FINANCE_LAST_PROFIT_LOSS			=    HQ_COL_FINANCE_BEGIN + 39;			// �����������														����
  HQ_COL_FINANCE_SCOT_PROFIT				=    HQ_COL_FINANCE_BEGIN + 40;			// ˰������															����
  HQ_COL_FINANCE_PER_INCOME_TTM			=    HQ_COL_FINANCE_BEGIN + 41;			// ÿ������TTM
  HQ_COL_FINANCE_PER_DIVIDEND				=    HQ_COL_FINANCE_BEGIN + 42;			// ÿ�ɹ�Ϣ
  HQ_COL_FINANCE_DIVIDEND_RATE			=    HQ_COL_FINANCE_BEGIN + 43;			// ��Ϣ��
  HQ_COL_FINANCE_NET_ASSETS 				=    HQ_COL_FINANCE_BEGIN + 44;			// ���ʲ�

{ ��̬�����������ֶζ���		60000-69999
  HQ_COL_DYNAMIC_BEGIN                    =    HQ_COL_FINANCE_BEGIN + 1;          // 60000
  HQ_COL_DYNAMIC_END                      =    HQ_COL_DYNAMIC_BEGIN + 9999;       // 69999
}
  HQ_COL_DYNAMIC_VALIDTIME                =    HQ_COL_DYNAMIC_BEGIN + 1;          // ������Чʱ��
  HQ_COL_DYNAMIC_LIST_DATE                =    HQ_COL_DYNAMIC_BEGIN + 2;          // ��������
  HQ_COL_DYNAMIC_VALIDREMAIN              =    HQ_COL_DYNAMIC_BEGIN + 3;          // ������Чʣ��ʱ��
  HQ_COL_DYNAMIC_REIMBURSEMENTTIME        =    HQ_COL_DYNAMIC_BEGIN + 4;          // �����ֹʱ��
  HQ_COL_DYNAMIC_LATEST_TIME              =    HQ_COL_DYNAMIC_BEGIN + 5;          // ���±���ʱ��
  HQ_COL_DYNAMIC_REIMBURSEMENTREMAIN      =    HQ_COL_DYNAMIC_BEGIN + 6;          // ����ʣ��ʱ��
  HQ_COL_DYNAMIC_MARGINRATIO              =    HQ_COL_DYNAMIC_BEGIN + 7;          // ��֤�����
  HQ_COL_DYNAMIC_NEW_PRICE64              =    HQ_COL_DYNAMIC_BEGIN + 8;          // 64λ���¼�
  HQ_COL_DYNAMIC_LIST_PRICE               =    HQ_COL_DYNAMIC_BEGIN + 9;          // ���Ƽ۸�

{ ���۽����������ֶζ���       70000-79999
  HQ_COL_FIXEDPRICE_BEGIN                 =    HQ_COL_DYNAMIC_BEGIN + 1;          // 70000
  HQ_COL_FIXEDPRICE_END                   =    HQ_COL_DYNAMIC_END   + 9999;       // 79999
}
  HQ_COL_FIXEDPRICE_LISTVOLUME            =    HQ_COL_FIXEDPRICE_BEGIN + 1;       // ��������
  HQ_COL_FIXEDPRICE_MINDEALRATIO          =    HQ_COL_FIXEDPRICE_BEGIN + 2;       // ��С�ɽ�����
  HQ_COL_FIXEDPRICE_DEALMODE              =    HQ_COL_FIXEDPRICE_BEGIN + 3;       // �ɽ�����
  HQ_COL_FIXEDPRICE_TOTAL_DECLARE_VOLUME  =    HQ_COL_FIXEDPRICE_BEGIN + 4;       // �걨����
















implementation

end.
