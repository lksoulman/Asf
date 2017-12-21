unit QuoteTimeStruct;

interface

uses
  Windows,
  SysUtils,
  Graphics;

const
  Const_IndexTag_MinePoint = 101;
  Const_IndexTag_TradePoint = 102;

  Const_Time_TrendLine_Name = '分时走势';
  Const_Time_AverageLine_Name = '均线';
  Const_Time_LeadLine_Name = '领先指标';

type

  TSubcribeType = (stSingleDay, stMultiDay);

//  TOnChangeStockEvent = procedure(_StockInfoRec: StockInfoRec) of object;

  TOnChangeValueEvent = procedure(Value: Integer) of object;

  TOnInvalidate = procedure of object;

  TSelfStockOperate = (ssoAdd, ssoDel);

  TCrossMoveType = (cmtLeft, cmtRight, cmtHome, cmtEnd);

  TAxisType = (atSymmetry, atFullAxis, atLimitAxis);

  TStockType = (stStock, stIndex, stBond, stHKStock, stUSStock, stFutures, stOption,
    stExchange);

  TDataKey = (dkPrice, dkCurrentPrice, dkVolume, dkAveragePrice, dkMoney,
    dkTurnover, dkDate, dkHighsLows, dkHighsLowsRange, dkArrivePtCurrentPrice,
    dkIndexUpTrend, dkIndexDownTrend, dkIndexTrend, dkAuctionPrice,
    dkAuctionVolume);

  TFormatType = (ftHand, ftWanHand, ftYiHand);

  TQuoteTimeTrendItem = packed record
    m_lPrice: Double;
    m_lVolume: ulong;
    m_lAveragePrice: Double;
    m_lMoney: Double;
    m_lUpTrend: Integer;
    m_lDownTrend: Integer;
    m_lUpStockCount: SHORT;
    m_lDownStockCount: SHORT;
  end;

  TQuoteTimeTrendItems = array of TQuoteTimeTrendItem;

  TAuctionItem = packed record
    m_lTime: Integer;
    m_lPrice: Double;
    m_lVolume: ulong;
    m_lfQty: long;
    m_fQtyLeft: long;
  end;

  TAuctionItems = array of TAuctionItem;

  TDetailDataKey = packed record
    m_lCaption: string;
    m_lDataKey: TDataKey;
    m_lFormat: string;
  end;

  TTitleItem = packed record
    m_lColor: TColor;
    m_lText: string;
    m_lFontStyles: TFontStyles;
    m_lHeight: Integer;
    m_lIsNeedSpace: Boolean;
  end;

  TTitleItems = array of TTitleItem;

  TButtonItem = packed record
    m_lName: string;
    m_lSelected: Boolean;
  end;

  TButtonItems = array of TButtonItem;

implementation

end.
