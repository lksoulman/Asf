unit SecuMain;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SecuMain Interface
// Author：      lksoulman
// Date：        2017-9-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

const

  INNERCODE_YUEBAO = 64119;                     // 余额宝情绪指数

  { MARGIN }

  // 融资融券常量
  GIL_MARGIN_NONE                           = 0;  // 不可融资不可融券
  GIL_MARGIN_FINANCE                        = 10; // 可融资
  GIL_MARGIN_LOAN                           = 20; // 可融券
  GIL_MARGIN_FINANCE_AND_LOAN               = 30; // 可融资可融券

  // 融资融券常量
  MARGIN_NONE                               = $00; // 不可融资不可融券
  MARGIN_FINANCE                            = $10; // 可融资
  MARGIN_LOAN                               = $20; // 可融券
  MARGIN_FINANCE_AND_LOAN                   = $30; // 可融资可融券
  MARGIN_MASK                               = $F0; // 掩码

  { THROUGH }

  // 港股通标识常量
  GIl_THROUGH_NONE                          = 0;   // 无通标志
  GIl_THROUGH_HK_SH                         = 1;   // 港股通沪
  GIl_THROUGH_SH                            = 2;   // 沪股通
  GIl_THROUGH_SZ                            = 3;   // 深股通
  GIl_THROUGH_HK_SZ                         = 4;   // 港股通深
  GIl_THROUGH_HK_SH_SZ                      = 5;   // 港股通(沪深)

  // 港股通标识常量
  THROUGH_NONE                              = $00; // 无通标志
  THROUGH_HK_SH                             = $01; // 港股通沪
  THROUGH_SH                                = $02; // 沪股通
  THROUGH_SZ                                = $03; // 深股通
  THROUGH_HK_SZ                             = $04; // 港股通深
  THROUGH_HK_SH_SZ                          = $05; // 港股通(沪深)
  THROUGH_MASK                              = $F0; // 掩码

  { LISTEDSTATE }

  // 上市状态
  GIl_LISTEDSTATE_LISTING                   = 1;  //上市	1
  GIl_LISTEDSTATE_PRE_LISTING               = 2;  //预上市	2
  GIl_LISTEDSTATE_STOP                      = 3;  //暂停	3
  GIl_LISTEDSTATE_LISTING_FAILURE           = 4;  //上市失败	4
  GIl_LISTEDSTATE_TERMINATED                = 5;  //终止	5
  GIl_LISTEDSTATE_OTHER                     = 9;  //其他	9
  GIl_LISTEDSTATE_TRADING                   = 10; //交易	10
  GIl_LISTEDSTATE_SUSPENDED                 = 11; //停牌	11
  GIl_LISTEDSTATE_DELIST                    = 12; //摘牌	12

  // 上市状态
  LISTEDSTATE_LISTING                       = 1;  //上市	1
  LISTEDSTATE_PRE_LISTING                   = 2;  //预上市	2
  LISTEDSTATE_STOP                          = 3;  //暂停	3
  LISTEDSTATE_LISTING_FAILURE               = 4;  //上市失败	4
  LISTEDSTATE_TERMINATED                    = 5;  //终止	5
  LISTEDSTATE_OTHER                         = 9;  //其他	9
  LISTEDSTATE_TRADING                       = 10; //交易	10
  LISTEDSTATE_SUSPENDED                     = 11; //停牌	11
  LISTEDSTATE_DELIST                        = 12; //摘牌	12

  { INNERCODE}

  // 固定内码证券
  GIl_INNERCODE_YUEBAO                  = 64119;

  { SECUMARKET }

  {
    SELECT MAX(SecuMarket) FROM SecuMain

    SecuMarket
    NULL
    10
    13
    15
    20
    37
    38
    39
    40
    41
    43
    44
    49
    50
    51
    52
    54
    55
    56
    57
    66
    67
    68
    69
    70
    71
    72
    73
    74
    75
    76
    77
    78
    79
    80
    81
    83
    84
    85
    86
    87
    88
    89
    90
    91
    92
    93
    94
    95
    99
    101
    102
    103
    104
    105
    161
    240
    310  = 254
    320  = 255
  }

  // 证券市场
  GIl_SECUMARKET_310 = 310;
  GIL_SECUMARKET_320 = 320;

  // 证券市场
  SECUMARKET_310 = 254;
  SECUMARKET_320 = 255;

  { SearchType }

  // 搜索分类
  SEARCHTYPE_STOCK_HS           = 10; // 沪深股票
  SEARCHTYPE_STOCK_B            = 11; // B股
  SEARCHTYPE_STOCK_NEWOTC       = 12; // 新三板
  SEARCHTYPE_FUND               = 13; // 基金
  SEARCHTYPE_INDEX              = 14; // 指数
  SEARCHTYPE_BOND               = 15; // 债券
  SEARCHTYPE_FUTURE             = 16; // 期货
  SEARCHTYPE_STOCK_HK           = 17; // 港股
  SEARCHTYPE_STOCK_US           = 18; // 美股


  // Suffix
  SUFFIX_SH       = 'SH';     // 上海
  SUFFIX_SZ       = 'SZ';     // 深圳
  SUFFIX_OC       = 'OC';     // 三板
  SUFFIX_FU       = 'FU';     // 期货
  SUFFIX_HK       = 'HK';     // 港股
  SUFFIX_OT       = 'OT';     // 其他指数
  SUFFIX_IB       = 'IB';     // 银行间证券
  SUFFIX_OPT      = 'OPT';    // 个股期权
  SUFFIX_ZXI      = 'CI';     // 中信指数
  SUFFIX_US       = 'US';     // 美股

type

  // 证券类型
  TSecuType = ( stHSStock,                      // 沪深股票
                stHKStock,                      // 港股
                stUSStock,                      // 美股
                stNewThirdBoardStock,           // 新三板
                stIndex,                        // 指数
                stForeignIndex,                 // 国外指数
                stYuEBaoIndex,                  // 余额宝情绪指数
                stBond,                         // 普通债券
                stHSBond,                       // 沪深债券
                stBuyBackBond,                  // 债券回购
                stConvertibleBond,              // 可转债
                stInnerFund,                    // 场内基金
                stOuterCurrencyFund,            // 场外基金(货币)
                stOuterNonCurrencyFund,         // 场外基金(非货币)
                stCommodityFutures,             // 商品期货
                stFinancialFutures              // 金融期货
                );

  // 融资融券类型
  TMarginType = ( mtNone,                       // 不可融资不可融券
                  mtFinance,                    // 可融资
                  mtLoan,                       // 可融券
                  mtFinanceAndLoan              // 可融资可融券
                 );

  // 通类型
  TThroughType = ( ttNone,
                   ttHKSH,                      // 港股通沪
                   ttHKSZ,                      // 港股通深
                   ttHKSHSZ,                    // 港股通沪深
                   ttSH,                        // 沪股通
                   ttSZ                         // 深股通
                   );

  // 上市状态
  TListedType = ( ltListing,                    // 上市
                  ltDeListing                   // 非上市
                  );

  // SecuInfo
  TSecuInfo = packed record
    FIsUsed: Boolean;                           // 是不是在用
    FInnerCode: Int32;                          // 证券内码
    FSecuMarket: UInt8;                         // 证券市场
    FSearchType: UInt8;                         // 搜索分类
    FListedState: UInt8;                        // 上市状态
    FSecuMarkInfo: UInt8;                       // 证券特殊标记(融资融券，港股通，沪股通，深股通)
    FSecuCategory: UInt16;                      // 证券类别
    FSecuType: TSecuType;                       // 证券类型
    FMarginType: TMarginType;                   // 融资融券类型
    FThroughType: TThroughType;                 // 港股通，沪股通，深股通

    FSecuAbbr: string;                          // 证券简称
    FSecuCode: string;                          // 证券代码
    FSecuSpell: string;                         // 证券拼音
    FSecuSuffix: string;                        // 证券后缀
//    FFormerAbbr: string;                        // 证券曾用名
//    FFormerSpell: string;                       // 证券曾用名拼音
    FCompanyName: string;                       // 证券公司代码
//    FCodeByAgent: string;                       // CodeByAgent

    // SetUpdate
    function SetUpdate: boolean;
    // GetMargin
    function GetMargin: Integer;
    // GetThrough
    function GetThrough: Integer;
    // GetSecuType
    function GetSecuType: TSecuType;
    // GetMarginType
    function GetMarginType: TMarginType;
    // GetThroughType
    function GetThroughType: TThroughType;
    // GetSearchTypeName
    function GetSearchTypeName: string;
    // ToGilMarket
    function ToGilMarket: Integer;
    // ToGilCategory
    function ToGilCategory: Integer;
    // ToGilGilMarkInfo
    function ToGilMarkInfo(var AMargin, AThrough: Integer): Boolean;
  end;

  // SecuInfo Pointer
  PSecuInfo = ^TSecuInfo;

  // SecuInfo Pointer Array
  TSecuInfoDynArray = Array Of PSecuInfo;

  // SecuMain Interface
  ISecuMain = Interface(IInterface)
    ['{B0E5F129-246A-4537-A142-D745D6D1B859}']
    // StopService
    procedure StopService;
    // Lock
    procedure Lock;
    // Un Lock
    procedure UnLock;
    // Update
    procedure Update;
    // AsyncUpdate
    procedure AsyncUpdate;
    // IsUpdating
    function IsUpdating: Boolean;
    // GetItemCount
    function GetItemCount: Integer;
    // GetUpdateVersion
    function GetUpdateVersion: Integer;
    // GetItem
    function GetItem(AIndex: Integer): PSecuInfo;
    // GetHsCode
    function GetHsCode(AInnerCode: Integer): string;
  end;

  // SecuMainQuery
  ISecuMainQuery = Interface(IInterface)
    ['{CB6B22C8-1BCF-449A-9328-8D9E85046448}']
    // GetSecuInfo
    function GetSecuInfo(AInnerCode: Integer; var ASecuInfo: PSecuInfo): Boolean;
    // GetSecuInfos
    function GetSecuInfos(AInnerCodes: TIntegerDynArray; var ASecuInfos: TSecuInfoDynArray): Integer;
  end;

implementation

{ TSecuInfo }

function TSecuInfo.SetUpdate: boolean;
var
  LSecuMarket: Integer;
begin
  Result := True;
  if FInnerCode = INNERCODE_YUEBAO then begin
    FSecuType := stYuEBaoIndex;
    Exit;
  end;

  LSecuMarket := ToGilMarket;
  case FSecuCategory of
    1, 2:
      begin
        if LSecuMarket = 81 then begin
          FSecuType := stNewThirdBoardStock;
        end;
      end;
    24, 55, 69, 73, 74, 75:
      begin
        case LSecuMarket of
          76, 77, 78, 79:
            begin
              FSecuType := stUSStock;
            end;
          72:
            begin
              FSecuType := stHKStock;
            end;
        end;
      end;
    3, 51, 52, 53, 25, 20, 21, 63, 65, 71, 72:
      begin
        FSecuType := stHKStock;
      end;
    930:
      begin
        FSecuType := stIndex;
      end;
    4, 910, 920:
      begin
        case LSecuMarket of
          // 美洲指数
          76, 77, 78, 79, 80, 54, 56, 55, 220,
            // 欧洲指数
          85, 86, 87, 88, 94, 95, 98, 106, 120, 160, 161, 162, 180, 240, 250, 260, 320, 130, 140, 200, 230, 201,
            // 亚太及其它指数
          45, 50, 52, 57, 58, 65, 66, 67, 68, 69, 70, 72, 75, 107, 109, 110, 190, 210, 270, 280, 290, 300:
            FSecuType := stForeignIndex;
        end;
      end;
    1301, 1302, 82, 84, 85, 86, 61, 62:
      begin
        FSecuType := stInnerFund;
      end;
    81:
      begin
        FSecuType := stOuterCurrencyFund;
      end;
    83:
      begin
        FSecuType := stOuterNonCurrencyFund;
      end;
    6, 7, 11, 14, 18, 17, 28:
      begin
        if (LSecuMarket = 83)
          or (LSecuMarket = 90) then begin
          FSecuType := stBuyBackBond;
        end else begin
          FSecuType := stBond;
        end;
      end;
    9, 29:
      begin
        FSecuType := stConvertibleBond;
      end;
    801, 802:
      begin
        FSecuType := stCommodityFutures;
      end;
    803,804:          //金融期货
      begin
        FSecuType := stFinancialFutures;
      end;
  else
    begin
      FSecuType := stHSStock;
    end;
  end;
end;

function TSecuInfo.GetMargin: Integer;
var
  LMargin: UInt8;
begin
  LMargin := FSecuMarkInfo and MARGIN_MASK;
  LMargin := LMargin shr 4;
  Result := LMargin;
end;

function TSecuInfo.GetThrough: Integer;
begin
  Result := (FSecuMarkInfo and THROUGH_MASK);
end;

function TSecuInfo.GetSecuType: TSecuType;
begin
  Result := FSecuType;
end;

function TSecuInfo.GetMarginType: TMarginType;
begin
  Result := FMarginType;
end;

function TSecuInfo.GetThroughType: TThroughType;
begin
  Result := FThroughType;
end;

function TSecuInfo.GetSearchTypeName: string;
var
  LSearchType: Integer;
begin
  LSearchType := FSearchType;
  case LSearchType of
    // 沪深股票
    SEARCHTYPE_STOCK_HS:
      begin
        Result := '股票';
      end;
    // B股
    SEARCHTYPE_STOCK_B:
      begin
        Result := '股票';
      end;
    // 新三板
    SEARCHTYPE_STOCK_NEWOTC:
      begin
        Result := '新三板';
      end;
    // 基金
    SEARCHTYPE_FUND:
      begin
        Result := '基金';
      end;
    // 指数
    SEARCHTYPE_INDEX:
      begin
        Result := '指数';
      end;
    // 债券
    SEARCHTYPE_BOND:
      begin
        Result := '债券';
      end;
    // 期货
    SEARCHTYPE_FUTURE:
      begin
        Result := '期货';
      end;
    // 港股
    SEARCHTYPE_STOCK_HK:
      begin
        Result := '期货';
      end;
    // 美股
    SEARCHTYPE_STOCK_US:
      begin
        Result := '美股';
      end;
  else
    Result := '股票';
  end;
end;

function TSecuInfo.ToGilMarket: Integer;
begin
  if FSecuMarket < SECUMARKET_310 then begin
    Result := FSecuMarket;
  end else if FSecuMarket = SECUMARKET_310 then begin
    Result := GIL_SECUMARKET_310;
  end else if FSecuMarket = SECUMARKET_320 then begin
    Result := GIL_SECUMARKET_320;
  end else begin
    Result := 0;
  end;
end;

function TSecuInfo.ToGilCategory: Integer;
begin
  Result := FSecuCategory;
end;

function TSecuInfo.ToGilMarkInfo(var AMargin, AThrough: Integer): Boolean;
var
  LMargin, LThrough: UInt8;
begin
  Result := True;
  LMargin := (FSecuMarkInfo shr 4) and $0F;
  LThrough := FSecuMarkInfo and $0F;
  AMargin := LMargin;
  AThrough := LThrough;
end;

end.
