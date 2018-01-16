unit QuotePriceDisplayInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, System.Classes, System.types, Graphics,
  Controls, Forms, Winapi.ActiveX, AppControllerInf, CommonFunc, QuoteCommLibrary;

type
  TQuoteDisplayInfo = class
  public
    ColumnFont: TFont;
    ColumnHeight: integer;
    ColumnBackgroundColor: TColor;
    ColumnSpecialFontColor: TColor; //��ͷ�������ݵ���ɫ
    ColumnGridColor: TColor;
    ColumnGridColor1: TColor; //��ͷtop��bottom�߿�����ɫ
    ColumnGridColor2: TColor;
    GridLineColor: TColor;

    HintFont: TFont;  //��ʾ��Ϣ����
    HintColor: TColor; //��ʾ��Ϣ����ɫ

    RowFont: TFont;
    RowHeight: integer;
    RowBackgroundColor1: TColor; // ������1
    RowBackgroundColor2: TColor; // ������1
    RowGridColor: TColor;
    SignTextBackColor: TColor;
    SignTextFontColor: TColor;
    StockSignSize: integer;

    CellFlashColor1: TColor; // ���ݱ仯��ʾ��ɫ
    CellFlashColor2: TColor; // ���ݱ仯��ʾ��ɫ

    SelectedBackgroundColor: TColor; // ��ǰ�б���
    SelectedGridColor: TColor; // ��ǰ�б����
    MouseInColor: TColor; // ����ڱ��ǰ��Χʱ�ı���ɫ
    BorderColor: TColor; // �ؼ��ı߿�����ɫ

    // ������ɫ
    FixTextColor: TColor; // �̶�������ɫ ��ŵ�
    CustomStockColor: TColor; // ��ѡ����ɫ
    StockNameColor: TColor; // ��Ʊ������ɫ
    IllumTextColor: TColor; // ������ɫ
    ShadeTextColor: TColor; // ���� ��ɫ
    EqualTextColor: TColor; // ƽ��
    SortArrowColor: TColor; // �����ͷ��ɫ
    SortArrowSize: integer;
    GridUnderlineColor: TColor; // ����»��ߵ���ɫ
    AddPlateColor: TColor;
    AddPlateFocusedColor: TColor;

    IconSpace: integer; // ����ͼƬ���ַ���ո�

    CutLine: string; // �ı����ݷָ���
    UnderLineWidth: integer; // �»��߿��

    FAppPath: string;
    FHoldingIconImg, FShanghaiHKIconImg, FMarginTradingIconImg, FPriceHintIconImg: string; // �������ͼƬ����
    FAddPlateImg: string;

    FRowsSpace: integer;
    FBeforeRowSpace: integer;

    FMoveFirstImg, FAddStockImg, FAlertImg: string;
    FLoadingImg: string;
    FMinHandleSize: integer;

    constructor Create; virtual;
    destructor Destroy; override;
    procedure UpdateSkin(AGilAppController: IGilAppController); virtual;
  end;

  TDisplayInfoClass = class of TQuoteDisplayInfo;
  // ******************************************************************************

implementation

constructor TQuoteDisplayInfo.Create;
begin
  ColumnFont := TFont.Create;
  RowFont := TFont.Create;
  HintFont:= TFont.Create;

  ColumnFont.Charset := GB2312_CHARSET;
  ColumnFont.Color := RGB(51, 51, 51); // clWhite;
  ColumnFont.Height := -15;
  ColumnFont.Name := '΢���ź�';

  HintColor := RGB(51, 51, 51);
  HintFont.Color := RGB(11, 174, 255);
  HintFont.Height := -10;

  ColumnHeight := 24;
  ColumnBackgroundColor := RGB(243, 243, 243); // $00211C00;
  ColumnSpecialFontColor := RGB(245, 10, 10);
  ColumnGridColor := RGB(230, 230, 230);
  ColumnGridColor1 := RGB(238, 238, 238);
  GridLineColor := RGB(231, 231, 231);

  RowFont.Charset := GB2312_CHARSET;
  RowFont.Color := RGB(124, 124, 124); // clYellow;
  RowFont.Height := -15;
  RowFont.Name := '΢���ź�';

  RowHeight := 34;
  RowBackgroundColor1 := RGB(255, 255, 255); // ������1
  RowBackgroundColor2 := RGB(255, 255, 255); // $00040404; //������2
  RowGridColor := RGB(205, 219, 236); // RGB(193, 230, 243);

  SelectedBackgroundColor := RGB(252, 231, 204); // ��ǰ�б���
  SelectedGridColor := RGB(193, 230, 243);
  MouseInColor := RGB(252, 231, 204);
  BorderColor := RGB(172, 182, 190); // �ؼ��ı߿�����ɫ
  SortArrowColor := RGB(253, 163, 49); // �����ͷ��ɫ
  SortArrowSize := 10;
  GridUnderlineColor := RGB(253, 163, 49);
  AddPlateColor := $cccccc;
  AddPlateFocusedColor := $e6e6e6;
  UnderLineWidth := 2;
  CellFlashColor1 := RGB(241, 199, 203); // $00680100;  //���ݱ仯��ʾ��ɫ
  CellFlashColor2 := RGB(195, 231, 205); // $002C0100;  //���ݱ仯��ʾ��ɫ
  SignTextBackColor := RGB(255, 255, 255);
  SignTextFontColor := RGB(253, 143, 0);
  StockSignSize := 16;
  FMinHandleSize := 20;

  // ������ɫ
  FixTextColor := RGB(0,0,0); // clWhite;      //�̶�������ɫ ��ŵ�
  CustomStockColor := RGB(38, 136, 230); // ��ѡ����ɫ  ��Ʊ���� ������ɫ
  StockNameColor := RGB(58, 62, 65); // ��Ʊ����
  IllumTextColor := RGB(245, 10, 10); // ������ɫ
  ShadeTextColor := RGB(10, 169, 0); // ���� ��ɫ
  EqualTextColor := RGB(124, 124, 124); // ƽ��

  FAppPath := ExtractFilePath(Application.ExeName);
  FHoldingIconImg := 'QuoteGrid_holding2Big';
  FShanghaiHKIconImg := 'QuoteGrid_ShanghaiHK2Big';
  FMarginTradingIconImg := 'QuoteGrid_marginTrading2Big';
  FPriceHintIconImg := 'QuoteGrid_PriceHint';
  FMoveFirstImg := 'PriceGridMenu_MoveFirst';
  FAddStockImg := 'PriceGridMenu_AddStock';
  FAlertImg := 'PriceGridMenu_Alert';
  FAddPlateImg := 'QuoteGrid_AddPlate';
  FLoadingImg := 'QuoteGrid_Loading';
  CutLine := '-';

  FRowsSpace := 5;
  FBeforeRowSpace := 10;
  IconSpace := 2;
end;

destructor TQuoteDisplayInfo.Destroy;
begin
  if Assigned(HintFont) then
    FreeAndNil(HintFont);

  if Assigned(ColumnFont) then
    FreeAndNil(ColumnFont);

  if Assigned(RowFont) then
    FreeAndNil(RowFont);

  inherited;
end;

procedure TQuoteDisplayInfo.UpdateSkin(AGilAppController: IGilAppController);
var
  ASkinValue, AFontRatio: string;
  ASkinIValue: Integer;
begin
  if(Assigned(AGilAppController))then
  begin
    AFontRatio := AGilAppController.FontRatio;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnFontName');
    if(ASkinValue <> '')then
    begin
      ColumnFont.Name := ASkinValue;
    end;

    if(AFontRatio = Const_ScreenResolution_1080P)then
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnFontSize_Big')
    else
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnFontSize');
    if(TryStrToInt(ASkinValue, ASkinIValue))then
    begin
      ColumnFont.Height := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnFontColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ColumnFont.Color := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceHintFontSize');
    if(TryStrToInt(ASkinValue, ASkinIValue))then
    begin
      HintFont.Height := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceHintFontColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      HintFont.Color := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceHintColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      HintColor := ASkinIValue;
    end;

    if(AFontRatio = Const_ScreenResolution_1080P)then
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnHeight_Big')
    else
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnHeight');
    if(TryStrToInt(ASkinValue, ASkinIValue))then
    begin
      ColumnHeight := ASkinIValue;
    end;

    if(AFontRatio = Const_ScreenResolution_1080P)then
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowHeight_Big')
    else
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowHeight');
    if(TryStrToInt(ASkinValue, ASkinIValue))then
    begin
      RowHeight := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnBackgroundColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ColumnBackgroundColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceIllumTextColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ColumnSpecialFontColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnGridColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ColumnGridColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceColumnGridColor1');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ColumnGridColor1 := ASkinIValue;
      ColumnGridColor2 := $1d1d1d;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceGridLineColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      GridLineColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowFontName');
    if(ASkinValue <> '')then
    begin
      RowFont.Name := ASkinValue;
    end;

    if(AFontRatio = Const_ScreenResolution_1080P)then
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowFontSize_Big')
    else
      ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowFontSize');
    if(TryStrToInt(ASkinValue, ASkinIValue))then
    begin
      RowFont.Height := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowFontColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      RowFont.Color := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowBackgroundColor1');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      RowBackgroundColor1 := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowBackgroundColor2');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      RowBackgroundColor2 := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceRowGridColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      RowGridColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceSelectedBackgroundColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      SelectedBackgroundColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceSelectedGridColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      SelectedGridColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceMouseInColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      MouseInColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceBorderColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      BorderColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceSortArrowColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      SortArrowColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceGridUnderLineColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      GridUnderlineColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceAddPlateColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      AddPlateColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceAddPlateFocusedColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      AddPlateFocusedColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceCellFlashColor1');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      CellFlashColor1 := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceCellFlashColor2');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      CellFlashColor2 := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceCellSignTextBackColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      SignTextBackColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceCellSignTextFontColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      SignTextFontColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceFixTextColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      FixTextColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceCustomStockColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      CustomStockColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceStockNameColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      StockNameColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceIllumTextColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      IllumTextColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceShadeTextColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      ShadeTextColor := ASkinIValue;
    end;

    ASkinValue := AGilAppController.Config(ctSkin, 'QuotePriceEqualTextColor');
    ASkinIValue := HexToIntDef(ASkinValue, -1);
    if(ASkinIValue >= 0)then
    begin
      EqualTextColor := ASkinIValue;
    end;
  end;
end;
// ******************************************************************************

end.
