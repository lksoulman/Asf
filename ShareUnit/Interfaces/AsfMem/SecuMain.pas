unit SecuMain;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SecuMain Interface
// Author��      lksoulman
// Date��        2017-9-2
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

const

  INNERCODE_YUEBAO = 64119;                     // ������ָ��

  { MARGIN }

  // ������ȯ����
  GIL_MARGIN_NONE                           = 0;  // �������ʲ�����ȯ
  GIL_MARGIN_FINANCE                        = 10; // ������
  GIL_MARGIN_LOAN                           = 20; // ����ȯ
  GIL_MARGIN_FINANCE_AND_LOAN               = 30; // �����ʿ���ȯ

  // ������ȯ����
  MARGIN_NONE                               = $00; // �������ʲ�����ȯ
  MARGIN_FINANCE                            = $10; // ������
  MARGIN_LOAN                               = $20; // ����ȯ
  MARGIN_FINANCE_AND_LOAN                   = $30; // �����ʿ���ȯ
  MARGIN_MASK                               = $F0; // ����

  { THROUGH }

  // �۹�ͨ��ʶ����
  GIl_THROUGH_NONE                          = 0;   // ��ͨ��־
  GIl_THROUGH_HK_SH                         = 1;   // �۹�ͨ��
  GIl_THROUGH_SH                            = 2;   // ����ͨ
  GIl_THROUGH_SZ                            = 3;   // ���ͨ
  GIl_THROUGH_HK_SZ                         = 4;   // �۹�ͨ��
  GIl_THROUGH_HK_SH_SZ                      = 5;   // �۹�ͨ(����)

  // �۹�ͨ��ʶ����
  THROUGH_NONE                              = $00; // ��ͨ��־
  THROUGH_HK_SH                             = $01; // �۹�ͨ��
  THROUGH_SH                                = $02; // ����ͨ
  THROUGH_SZ                                = $03; // ���ͨ
  THROUGH_HK_SZ                             = $04; // �۹�ͨ��
  THROUGH_HK_SH_SZ                          = $05; // �۹�ͨ(����)
  THROUGH_MASK                              = $F0; // ����

  { LISTEDSTATE }

  // ����״̬
  GIl_LISTEDSTATE_LISTING                   = 1;  //����	1
  GIl_LISTEDSTATE_PRE_LISTING               = 2;  //Ԥ����	2
  GIl_LISTEDSTATE_STOP                      = 3;  //��ͣ	3
  GIl_LISTEDSTATE_LISTING_FAILURE           = 4;  //����ʧ��	4
  GIl_LISTEDSTATE_TERMINATED                = 5;  //��ֹ	5
  GIl_LISTEDSTATE_OTHER                     = 9;  //����	9
  GIl_LISTEDSTATE_TRADING                   = 10; //����	10
  GIl_LISTEDSTATE_SUSPENDED                 = 11; //ͣ��	11
  GIl_LISTEDSTATE_DELIST                    = 12; //ժ��	12

  // ����״̬
  LISTEDSTATE_LISTING                       = 1;  //����	1
  LISTEDSTATE_PRE_LISTING                   = 2;  //Ԥ����	2
  LISTEDSTATE_STOP                          = 3;  //��ͣ	3
  LISTEDSTATE_LISTING_FAILURE               = 4;  //����ʧ��	4
  LISTEDSTATE_TERMINATED                    = 5;  //��ֹ	5
  LISTEDSTATE_OTHER                         = 9;  //����	9
  LISTEDSTATE_TRADING                       = 10; //����	10
  LISTEDSTATE_SUSPENDED                     = 11; //ͣ��	11
  LISTEDSTATE_DELIST                        = 12; //ժ��	12

  { INNERCODE}

  // �̶�����֤ȯ
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

  // ֤ȯ�г�
  GIl_SECUMARKET_310 = 310;
  GIL_SECUMARKET_320 = 320;

  // ֤ȯ�г�
  SECUMARKET_310 = 254;
  SECUMARKET_320 = 255;

  { SearchType }

  // ��������
  SEARCHTYPE_STOCK_HS           = 10; // �����Ʊ
  SEARCHTYPE_STOCK_B            = 11; // B��
  SEARCHTYPE_STOCK_NEWOTC       = 12; // ������
  SEARCHTYPE_FUND               = 13; // ����
  SEARCHTYPE_INDEX              = 14; // ָ��
  SEARCHTYPE_BOND               = 15; // ծȯ
  SEARCHTYPE_FUTURE             = 16; // �ڻ�
  SEARCHTYPE_STOCK_HK           = 17; // �۹�
  SEARCHTYPE_STOCK_US           = 18; // ����


  // Suffix
  SUFFIX_SH       = 'SH';     // �Ϻ�
  SUFFIX_SZ       = 'SZ';     // ����
  SUFFIX_OC       = 'OC';     // ����
  SUFFIX_FU       = 'FU';     // �ڻ�
  SUFFIX_HK       = 'HK';     // �۹�
  SUFFIX_OT       = 'OT';     // ����ָ��
  SUFFIX_IB       = 'IB';     // ���м�֤ȯ
  SUFFIX_OPT      = 'OPT';    // ������Ȩ
  SUFFIX_ZXI      = 'CI';     // ����ָ��
  SUFFIX_US       = 'US';     // ����

type

  // ֤ȯ����
  TSecuType = ( stHSStock,                      // �����Ʊ
                stHKStock,                      // �۹�
                stUSStock,                      // ����
                stNewThirdBoardStock,           // ������
                stIndex,                        // ָ��
                stForeignIndex,                 // ����ָ��
                stYuEBaoIndex,                  // ������ָ��
                stBond,                         // ��ͨծȯ
                stHSBond,                       // ����ծȯ
                stBuyBackBond,                  // ծȯ�ع�
                stConvertibleBond,              // ��תծ
                stInnerFund,                    // ���ڻ���
                stOuterCurrencyFund,            // �������(����)
                stOuterNonCurrencyFund,         // �������(�ǻ���)
                stCommodityFutures,             // ��Ʒ�ڻ�
                stFinancialFutures              // �����ڻ�
                );

  // ������ȯ����
  TMarginType = ( mtNone,                       // �������ʲ�����ȯ
                  mtFinance,                    // ������
                  mtLoan,                       // ����ȯ
                  mtFinanceAndLoan              // �����ʿ���ȯ
                 );

  // ͨ����
  TThroughType = ( ttNone,
                   ttHKSH,                      // �۹�ͨ��
                   ttHKSZ,                      // �۹�ͨ��
                   ttHKSHSZ,                    // �۹�ͨ����
                   ttSH,                        // ����ͨ
                   ttSZ                         // ���ͨ
                   );

  // ����״̬
  TListedType = ( ltListing,                    // ����
                  ltDeListing                   // ������
                  );

  // SecuInfo
  TSecuInfo = packed record
    FIsUsed: Boolean;                           // �ǲ�������
    FInnerCode: Int32;                          // ֤ȯ����
    FSecuMarket: UInt8;                         // ֤ȯ�г�
    FSearchType: UInt8;                         // ��������
    FListedState: UInt8;                        // ����״̬
    FSecuMarkInfo: UInt8;                       // ֤ȯ������(������ȯ���۹�ͨ������ͨ�����ͨ)
    FSecuCategory: UInt16;                      // ֤ȯ���
    FSecuType: TSecuType;                       // ֤ȯ����
    FMarginType: TMarginType;                   // ������ȯ����
    FThroughType: TThroughType;                 // �۹�ͨ������ͨ�����ͨ

    FSecuAbbr: string;                          // ֤ȯ���
    FSecuCode: string;                          // ֤ȯ����
    FSecuSpell: string;                         // ֤ȯƴ��
    FSecuSuffix: string;                        // ֤ȯ��׺
//    FFormerAbbr: string;                        // ֤ȯ������
//    FFormerSpell: string;                       // ֤ȯ������ƴ��
    FCompanyName: string;                       // ֤ȯ��˾����
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
          // ����ָ��
          76, 77, 78, 79, 80, 54, 56, 55, 220,
            // ŷ��ָ��
          85, 86, 87, 88, 94, 95, 98, 106, 120, 160, 161, 162, 180, 240, 250, 260, 320, 130, 140, 200, 230, 201,
            // ��̫������ָ��
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
    803,804:          //�����ڻ�
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
    // �����Ʊ
    SEARCHTYPE_STOCK_HS:
      begin
        Result := '��Ʊ';
      end;
    // B��
    SEARCHTYPE_STOCK_B:
      begin
        Result := '��Ʊ';
      end;
    // ������
    SEARCHTYPE_STOCK_NEWOTC:
      begin
        Result := '������';
      end;
    // ����
    SEARCHTYPE_FUND:
      begin
        Result := '����';
      end;
    // ָ��
    SEARCHTYPE_INDEX:
      begin
        Result := 'ָ��';
      end;
    // ծȯ
    SEARCHTYPE_BOND:
      begin
        Result := 'ծȯ';
      end;
    // �ڻ�
    SEARCHTYPE_FUTURE:
      begin
        Result := '�ڻ�';
      end;
    // �۹�
    SEARCHTYPE_STOCK_HK:
      begin
        Result := '�ڻ�';
      end;
    // ����
    SEARCHTYPE_STOCK_US:
      begin
        Result := '����';
      end;
  else
    Result := '��Ʊ';
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
