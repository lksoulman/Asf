unit QuoteCommLibrary;

interface

uses
  System.Classes, Winapi.Windows, System.Math, System.DateUtils,
  System.SysUtils, Vcl.Graphics,Vcl.Imaging.pngimage, NativeXml,
  CommonFunc;

const
  MaxListCount = 1000000;
  TRUE_VALUE = Ord(True);
  FALSE_VALUE = Ord(False);

  Con_UnitWan = '��';
  Con_UnitYi = '��';
  Con_1Wan = 10000;

  Con_YuEbao_EmotionIndex = 64119; // ������ָ��������

  Con_Main = 0; // ��ͼ
  Con_Assistant = 1; // ��ͼ

  Con_FormulaUsageSetting = 'ָ���÷�������';
  Con_Enlarge = '�Ŵ�';
  Con_Narrow = '��С';
  Con_Close = '�ر�';

  //������Ϣ���
  KeyBoard_Press_AltMask = $20000000;

  //���������
  Const_OrgID_ChangJiang = '70002';

  //�û����
  Const_UserName_JY_CN = 'JYUserName_CN'; //�û���Դ�˻����ƣ����ģ�

  // Const Asila
  Const_Asila_QuotePrice = 'QuotePrice';
  Const_Asila_ComplexRank = 'MultiRank';
  Const_Asila_StockSynthesis = 'StockSynthesis';
  Const_Asila_DetailTick = 'DetailTick';
  Const_Asila_DetailPerPrice = 'DetailPerPrice';
  Const_Asila_TickOrPerPrice = 'TickOrPerPrice';
  Const_Asila_QuoteBottomBar = 'BottomBar';
  Const_Asila_Chromium = 'Chromium';
  Const_Asila_WebF10 = 'WebF10';
  Const_Asila_MultiStock = 'MultiStock';
  Const_Asila_ComplexScreen = 'ComplexScreen';
  Const_Asila_UserManual = 'UserManual';

  //�ڲ��б���������url���Լ��滻����
  Constt_Asila_Pop_InnerResearchReport = 'Pop_InnerResearchReport';
  Const_Pop_InnerResearchReport_ReplaceStr_Id = '!id';
  Const_Pop_InnerResearchReport_ReplaceStr_Title = '!title';
  Const_Pop_InnerResearchReport_ReplaceStr_SecuCode = '!secuCode';
  Const_Pop_InnerResearchReport_ReplaceStr_Author = '!author';
  Const_Pop_InnerResearchReport_ReplaceStr_Appendix_id = '!appendix_id';

  // Const Web
  Const_Web_ConfigDLL_ResourceName_ModuleURL = 'Web_ModuleURL';
  Const_Web_Information_FundRank_PageID = 'zx_fund_ranks';
  Const_Web_Information_gzzx_PageID = 'zx_gzzx';
  Const_Web_Information_cjtt_PageID = 'zx_cjtt';
  Const_Web_Information_scdt_PageID = 'zx_scdt';
  Const_Web_Information_jjrl_PageID = 'zx_jjrl';
  Const_Web_Information_ipo_PageID = 'zx_ipo';
  Const_Web_ReplaceStr_ServerIP = '!ServerIP';
  Const_Web_ReplaceStr_InnerCode = '!InnerCode';
  Const_Web_ReplaceStr_SecuName = '!SecuName';
  Const_Web_ReplaceStr_SecuCode = '!SecuCode';
  Const_Web_ReplaceStr_Date = '!Date';
  Const_Web_ReplaceStr_NewDiary = '!NewDiary';
  Const_Web_ReplaceStr_Title = '!title';
  Const_Web_ReplaceStr_SID = '!WEBSID';
  Const_Web_FilePath = 'Web/ModuleURL.xml';
  Const_Web_Module = 'Module';
  Const_Web_ModuleAsila = 'ModuleAslia';
  Const_Web_Caption = 'Caption';
  Const_Web_WebIPName = 'WebIPName';
  Const_Web_WebIPNameSpecial = 'WebIPName2';
  Const_Web_WebIPName_ReplaceStr = '!ServerIP';
  Const_Web_URL = 'URL';
  Const_Web_URLDef = 'URLDef';

  // Const Module GoTo Param
  Const_Module_Goto_MultiStockToStock_Param = 'MarketTimeType';
  Const_Module_Goto_SimplePrice_Param = 'SimplePriceModuleType';

  // ���ò���
  Con_InfMine_NumOfDays = 'infmine=';   // ��Ϣ������Ҫ��ʾ������
  
  // �ֱ���
  Const_ScreenResolution_1080P = '1080P';
  Const_ScreenResolution_768P = '768P';

  //��ѯ�û�o32Ȩ�������л����ָ��
  Const_GetUserO32_Fund_SQL = 'USER_O32RIGHT_FUNDSINFOS';
  //��ѯ�û�o32Ȩ�޻�����������ϵ�ָ��
  Const_GetUserO32_Fund_Combi_SQL = 'C_ASSET_COMBI([!ABBMs])';

  //�����Ƴ�����Ϣ
  Const_Grid_Text_NullValue = '--';
  Const_Grid_Header_Size = 22;
  Const_Grid_Header_Space = 12;
  Const_Grid_Row_Size = 35;
  Const_PriceGrid_DetailInfo_Width_Min = 350;
  Const_PriceGrid_DetailInfo_Width_Max = 700;
  Const_PriceGrid_FundSetting_Width_Min = 195;
  Const_PriceGrid_FundSetting_Width_Max = 390;
  Const_USStock_Sort_Hint = '���ɲ�֧�ֱ�ָ������';

  //�û�PBox�ն�·���ļ�����
  Const_File_PBoxPaths = 'PBoxInfos.xml';

  //֤ȯ������
  Const_ConceptIndex_ZQLB = 930;
  Const_ConceptIndex_ZQLB_S = '930';

  //������ӿڷ������
  Con_Web_NotifyLoadEnd = 'WebNotifyLoadEnd';  //��ҳģ�������������֪ͨ����
  Con_Web_NotifyClose = 'WebNotifyClose';  //��ҳģ�������ɹر�֪ͨ�¼�

  CONST_URL_Blank = 'about:blank';
  CONST_URL_DefaultFlag = 'file:///';
  CONST_URL_DefaultFormat = 'file:///!path?title=!title&cfg=!SkinStyle&fontsize=!fontRatio';
  Const_Default_HtmlContent =
 '<!DOCTYPE html>' + #13#10 +
 '<html>' + #13#10 +
 '<head>' + #13#10 +
 '<meta charset="UTF-8">' + #13#10 +
 '<title>index</title>' + #13#10 +
 '<script type="text/javascript">' + #13#10 +
 'window.onload=function(){' + #13#10 +
 '	var params = window.location.search.substr(1);' + #13#10 +
 '	var cfg = getQueryString(params,"cfg");' + #13#10 +
 '	if(cfg == "000000"){' + #13#10 +
 '		document.body.style.backgroundColor = "#FFFFFF"' + #13#10 +
 '	}else{' + #13#10 +
 '		document.body.style.backgroundColor = "#1C1C1C"' + #13#10 +
 '	}' + #13#10 +
 '}' + #13#10 +
 'function getQueryString(params, paramName) {' + #13#10 +
 '	var reg = new RegExp("(^|&)"+ paramName +"=([^&]*)(&|$)");' + #13#10 +
 '	var r = params.match(reg);' + #13#10 +
 '	if(r!=null) return r[2]; return null;' + #13#10 +
 '}' + #13#10 +
 '</script>' + #13#10 +
 '</head>' + #13#10 +
 '<body>' + #13#10 +
 '' + #13#10 +
 '</body>' + #13#10 +
 '</html>';

type
  TQuoteFloat = Double;

  TQuoteEvent = procedure of object;
  TCountChangeEvent = procedure(AIncreaseCount: Integer) of object;
  TShowPosEvent = procedure(APoint: TPoint) of object;

  TQuoteBorderLine = set of (blLeft, blTop, blRight, blBottom);

  TSeasonType = (stDay, stWeek, stMonth, { stYear, } stMinute, stMinute5,
    { stMinute10, } stMinute15, stMinute30, stMinute60);

  TQuoteHintType = (htRulerX, htRulerYL, htRulerYR);

  TQuoteMoveType = (mtLeft, mtRight);

  TDrawType = (dtLine, dtColorStick, dtVolStick, dtCircleDot, dtDrawText, dtStickLine, dtPointDot, dtDrawKLine);
  TFormulaType = (ftHold, ftEPS, ftVOL, ftMACD, ftKDJ, ftARBR, ftCR, ftDMA, ftRSI, ftMA, ftBOLL, ftSAR); // ftEMA, ftEMV
//  TDataType = (dtypeHQ, dtypeGF); // ���飬ָ��

  // dtDefine �ڲ� dtOuter ��� dtEmpty ���(û�ж��������)
  TDefType = (dtDefine, dtOuter, dtEmpty);

  TQuoteSortType = (qstAscending, qstDescending);

  // smCommonly��׼ģʽ smSimple��ģʽ smMulitStock���ͬ�� smHistoryTime��ʷ��ʱ smComplexScreen�ۺ���ģʽ  smWSSelfDefinition �Զ���
  TQuoteShowMode = (smNormal, smSimple, smMulitStock, smHistoryTime, smComplexScreen, smWSSelfDefinition);

  // qwNone
  // qwFront -> ǰ��Ȩ �ּ۲���
  // qwBack   <- ��Ȩ �ּ۱�
  TQuotaWeight = (qwNone, qwFront, qwBack);
  TChangeWeightEvent = procedure(AWeight: TQuotaWeight) of object;
  TChangeSeasonTypeEvent = procedure(ASeasonType: TSeasonType) of object;

  TEnumStockCategory = (
    escStock ,    //�����Ʊ
    escHKStock ,  //�۹�
    escUSStock ,  //����
    escNewStock , //������
    escIndex ,    //ָ��
    escIndexForeign, //����ָ��
    escInnerFund, //���ڻ���
    escOuterOpenFund, //�������(�ǻ���)
    escOuterOpenCurrencyFund, //�������(����)
    escBond,      //��ͨծȯ
    escBondHSMarket, //����ծȯ
    escBondBuyBack,  //ծȯ�ع�
    escCommodityFutures ,  //��Ʒ�ڻ�
    escFinancialFutures,  //�����ڻ�
    escConvertibleBond,  //��תծ
    escIndexYuEBao   //������ָ��
  );

  // ������Դ+���ͣ��������ݡ�ָ�꣨������ָ��������ָ����
  TDataSourcesType = (dstQuote, dstIndexYuEbao, dstIndexForeign);

  // ��Ȩ��Ϣ
  TWeightDataRec = packed record
    INBBM: Integer;
    Date: WORD; // ����
    Factor: Double; // ��Ȩ����
    Addend: Double; // ���ͼ���
    ZZ: Byte;
  end;

  ArrayWeightData = array [0 .. MaxListCount] of TWeightDataRec;
  PWeightData = ^ArrayWeightData;

  TInterfaceObj = class(TObject, IInterface)
  protected
    FRefCount: Integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  // *** ѡ����ƵĶ��� *** //
  ISelectedObject = interface
    ['{65884D75-2BFB-4280-991D-E0B417F80911}']
    procedure DrawSelected(ASelected: Boolean); safecall;
    function PtInObject(const P: TPoint; var AInAdjustDot: Boolean): Boolean; safecall;
    function ObjectType: Integer; safecall;
    function ObjectAdress: Integer; safecall;
    function Delete: Boolean; safecall;
  end;

  TArrayFormulaNames = array [TFormulaType] of string;
  TArrayFormulaLineCounts = array [TFormulaType] of Integer;

const
  Con_FormulaNames: TArrayFormulaNames = ('�ֲ�', 'ӯ��Ԥ��', 'VOL', 'MACD', 'KDJ', 'ARBR', 'CR', 'DMA', 'RSI', 'MA', 'BOLL', 'SAR');
  Con_FormulaLineCounts: TArrayFormulaLineCounts = (1, 1, 3, 3, 3, 2, 5, 2, 3, 10, 3, 1);

procedure FreeAndClean(Lists: TList);

// �㵽��ľ���
function PPDistance(P1, P2: TPoint): Double;
// �㵽ֱ�ߵľ���
function PLDistance(P, LP1, LP2: TPoint): Double;
function ScalcCountBuilderEx(Count: Integer; ZoomIn: Boolean): Integer;

function CDayOfWeek(RQ: TDate): string;
function NextStep(Const OldStep: Double): Double;

function IntToDateTime(RQ: Integer): TDateTime;
function IntToTime(Time: Integer): TDateTime;
function TimeToInt(Time: TDateTime): Integer;

// ������ת���ɴ�������ڵ��ַ���
function UnitConversion(AFormat: string; ACurrValue: TQuoteFloat; ATakeUnit: Boolean = True): string;
// ������ת���ɴ�������ڵĵ�λ��ϵ��
function UnitConversionRatio(ACurrValue: TQuoteFloat; out AUnit: string): TQuoteFloat;
// �����ں�ʱ��ϲ���TDateTime
function EncodeDateAndTime(ADate: TDate; ATime: TTime): TDateTime;

procedure LoadResourceIcon(AIcon: TIcon; AName: string);
// ����AConfigStr�еĹؼ���ΪAKey��ֵ
//function ParseStrings(AGilAppController: IGilAppController; AKey: string): string;

function LoadFromResourceName(ATPngImage: TPngImage;AInstance: HInst; ASrcName: string): Boolean;
function LoadFromResourceID(ATPngImage: TPngImage;AInstance: HInst; ResID: Integer): Boolean;
function LoadFromStream(ATPngImage: TPngImage; AStream: TStream): Boolean;

//ͨ��������ModuleURL�ļ��ж�ȡ��Ӧ��Url
//function GetWebUrlFromAlias(AControll: IGilAppController; AAlias: string): string;

//function GetDefaultUrl(AControll: IGilAppController = nil; ATitle: string = ''): string;
// �ж�ָ����֤ȯ����֤ȯ�г��Ƿ�Ϊ����ָ��
function IsForeignIndex(ASecuCategory, ASecuMarket: Integer): Boolean;

//function GetCategoryOf(AGilAppController: IGilAppController;AInnerCode:Integer):TEnumStockCategory; overload;
//function GetCategoryOf(AStockInfoRec: StockInfoRec):TEnumStockCategory; overload;

resourcestring

  RC_ShortDay_1 = '��';
  RC_ShortDay_2 = 'һ';
  RC_ShortDay_3 = '��';
  RC_ShortDay_4 = '��';
  RC_ShortDay_5 = '��';
  RC_ShortDay_6 = '��';
  RC_ShortDay_7 = '��';

implementation

procedure FreeAndClean(Lists: TList);
var
  i: Integer;
begin
  for i := 0 to Lists.Count - 1 do
    TObject(Lists[i]).Free;
  Lists.Clear;
end;

function NextStep(Const OldStep: Double): Double;
begin
  if OldStep >= 10 then
    Result := 10 * NextStep(0.1 * OldStep)
  else if OldStep < 1 then
    Result := 0.1 * NextStep(OldStep * 10)
  else if OldStep < 2 then
    Result := 2
  else if OldStep < 5 then
    Result := 5
  else
    Result := 10
end;

// �㵽��ľ���
function PPDistance(P1, P2: TPoint): Double;
var
  X, Y: Double;
begin
  X := (P1.X - P2.X) / 5000000;
  Y := (P1.Y - P2.Y) / 5000000;
  Result := (SQRT(SQR(X) + SQR(Y))) * 5000000;

  // result := Sqrt((P1.X - P2.X) * (P1.X - P2.X) + (P1.Y - P2.Y) * (P1.Y - P2.Y));
end;

// �㵽ֱ�ߵľ���
function PLDistance(P, LP1, LP2: TPoint): Double;
var
  K, X, Y: Double;
begin
  // ֱ�߷���Ϊy=kx+b;
  // l=abs((y2-y1) x + (x1_x2) y +x2 * y1 - x1 * y2) / sqrt(sqr(y2-y1)+sqr(x1-x2))

  Result := MaxInt;
  if LP1.X = LP2.X then
  begin
    if (P.Y >= Min(LP1.Y, LP2.Y)) and (P.Y <= Max(LP1.Y, LP2.Y)) then
      Result := Abs(LP2.X - P.X)
  end
  else if LP1.Y = LP2.Y then
  begin
    if (P.X >= Min(LP1.X, LP2.X)) and (P.X <= Max(LP1.X, LP2.X)) then
      Result := Abs(LP2.Y - P.Y)
  end
  else
  begin
    if (P.X >= Min(LP1.X, LP2.X)) and (P.X <= Max(LP1.X, LP2.X)) and (P.Y >= Min(LP1.Y, LP2.Y)) and
      (P.Y <= Max(LP1.Y, LP2.Y)) then
    begin
      K := (LP2.Y - LP1.Y) / (LP2.X - LP1.X);
      X := (K * LP1.X + 1 / K * P.X + P.Y - LP1.Y) / (K + 1 / K);
      Y := -1 / K * (X - P.X) + P.Y;
      Result := SQRT(SQR(P.X - X) + SQR(P.Y - Y));
    end;

  end;
end;

function ScalcCountBuilderEx(Count: Integer; ZoomIn: Boolean): Integer;
const
  CalcScalc: array [0 .. 13] of Integer = (5, 10, 20, 40, 60, 100, 150, 200, 300, 500, 800, 1200, 1700, 2700);
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to 13 do
  begin
    if Count <= CalcScalc[i] then
    begin
      // �Ŵ�
      if ZoomIn then
      begin
        if i = 0 then
          Result := 5
        else
          Result := Count - (CalcScalc[i] - CalcScalc[i - 1])
      end
      else
      begin
        if i = 13 then
          Result := Count + 1000
        else
          Result := Count + CalcScalc[i + 1] - CalcScalc[i];
      end;
      Break;
    end;
  end;

  if Result = 0 then
  begin
    if ZoomIn then
      Result := Count - 1000
    else
      Result := Count + 1000;
  end;

  if Result < 5 then
    Result := 5;
end;

{ TInterfaceObj }

function TInterfaceObj._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TInterfaceObj._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

function TInterfaceObj.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function CDayOfWeek(RQ: TDate): string;
begin
  case DayOfTheWeek(RQ) of
    1:
      Result := RC_ShortDay_2;
    2:
      Result := RC_ShortDay_3;
    3:
      Result := RC_ShortDay_4;
    4:
      Result := RC_ShortDay_5;
    5:
      Result := RC_ShortDay_6;
    6:
      Result := RC_ShortDay_7;
    7:
      Result := RC_ShortDay_1;
  else
    Result := '';
  end;
end;

function IntToDateTime(RQ: Integer): TDateTime;
var
  Yea, Mon, Day: WORD;
begin
  Yea := RQ div 10000;
  Mon := (RQ) div 100 mod 100;
  Day := RQ mod 100;
  try
    if Yea < 1 then
      Result := Now
    else
      Result := EncodeDateTime(Yea, Mon, Day, 0, 0, 0, 0);
  except
    Result := Now;
  end;
end;

function IntToTime(Time: Integer): TDateTime;
var
  Hour, Min, Sec: WORD;
begin
  Hour := Time div 10000;
  Min := (Time - Hour * 10000) div 100;
  Sec := Time - Hour * 10000 - Min * 100;
  Result := EncodeTime(Hour, Min, Sec, 0);
end;

function TimeToInt(Time: TDateTime): Integer;
var
  Hour, Min, Sec, MSec: WORD;
begin
  DecodeTime(Time, Hour, Min, Sec, MSec);
  Result := Hour * 10000 + Min * 100 + Sec;
end;

function UnitConversion(AFormat: string; ACurrValue: TQuoteFloat; ATakeUnit: Boolean): string;
var
  tmpUnit: string;
begin
  tmpUnit := '';
  if ACurrValue >= Con_1Wan then
  begin
    ACurrValue := ACurrValue / Con_1Wan;
    tmpUnit := Con_UnitWan;

    if ACurrValue >= Con_1Wan then
    begin
      ACurrValue := ACurrValue / Con_1Wan;
      tmpUnit := Con_UnitYi
    end;
  end;

  Result := FormatFloat(AFormat, ACurrValue);
  if ATakeUnit then
    Result := Result + tmpUnit
end;

function UnitConversionRatio(ACurrValue: TQuoteFloat; out AUnit: string): TQuoteFloat;
begin
  Result := 1;
  if ACurrValue >= Con_1Wan then
  begin
    ACurrValue := ACurrValue / Con_1Wan;
    Result := Con_1Wan;
    AUnit := Con_UnitWan;
    if ACurrValue >= Con_1Wan then
    begin
      Result := Result * Con_1Wan;
      AUnit := Con_UnitYi;
    end;
  end;
end;

function EncodeDateAndTime(ADate: TDate; ATime: TTime): TDateTime;
var
  tmpYear, tmpMonth, tmpDay, tmpHour, tmpMinute, tmpSecond, tmpMilliSecond: Word;
begin
  DecodeDate(ADate, tmpYear, tmpMonth, tmpDay);
  DecodeTime(ATime, tmpHour, tmpMinute, tmpSecond, tmpMilliSecond);
  Result := EncodeDateTime(tmpYear, tmpMonth, tmpDay, tmpHour, tmpMinute, tmpSecond, tmpMilliSecond);
end;

procedure LoadResourceIcon(AIcon: TIcon; AName: string);
var
  AStream: TResourceStream;
begin
  AStream := TResourceStream.Create(HInstance, AName, 'DATA');
  try
    AStream.Position := 0;
    AIcon.LoadFromStream(AStream);
  finally
    AStream.Free;
  end;
end;

//function ParseStrings(AGilAppController: IGilAppController; AKey: string): string;
//var
//  tmpKeyPos: Integer;
//  tmpConfigStr: string;
//  tmpUserSetting: IUserSetting;
//begin
//  Result := '';
//  tmpUserSetting := AGilAppController.GetConfigOprateIntf;
//  if Assigned(tmpUserSetting) then
//  begin
//    tmpConfigStr := tmpUserSetting.GetUserConfig('SystemSet');
//    if (tmpConfigStr = '') then
//      Exit;
//
//    tmpKeyPos := Pos(AKey, tmpConfigStr);
//    if tmpKeyPos > 0 then
//    begin
//      tmpConfigStr := Copy(tmpConfigStr, tmpKeyPos + Length(AKey), $FF);
//      tmpKeyPos := Pos(';', tmpConfigStr);
//      if tmpKeyPos > 0 then
//        tmpConfigStr := Copy(tmpConfigStr, 1, tmpKeyPos - 1);
//      Result := tmpConfigStr;
//    end
//    else
//      Result := '';
//  end;
//end;


function LoadFromResourceName(ATPngImage: TPngImage;AInstance: HInst; ASrcName: string): Boolean;
  procedure ClearPng(AATPngImage: TPngImage);
  begin
    AATPngImage.CreateBlank(COLOR_RGBALPHA,1,0,0);
  end;
begin
  Result := False;
  try
    if (AInstance > 0) and Assigned(ATPngImage) then
    begin
      ATPngImage.LoadFromResourceName(AInstance, ASrcName);
      Result := True;
    end
    else
    begin
      ClearPng(ATPngImage);
    end;
  except
    ClearPng(ATPngImage);
  end;
end;

function LoadFromResourceID(ATPngImage: TPngImage;AInstance: HInst; ResID: Integer): Boolean;
  procedure ClearPng(AATPngImage: TPngImage);
  begin
    AATPngImage.SetSize(0,0);
  end;
begin
  Result := False;
  try
    if (AInstance > 0) and Assigned(ATPngImage) then
    begin
      ATPngImage.LoadFromResourceID(AInstance, ResID);
      Result := True;
    end
    else
    begin
      ClearPng(ATPngImage);
    end;
  except
    ClearPng(ATPngImage);
  end;
end;

function LoadFromStream(ATPngImage: TPngImage; AStream: TStream): Boolean;
  procedure ClearPng(AATPngImage: TPngImage);
  begin
    AATPngImage.SetSize(0,0);
  end;
begin
  Result := False;
  try
    if Assigned(AStream) and Assigned(ATPngImage) then
    begin
      ATPngImage.LoadFromStream(AStream);
      Result := True;
    end
    else
    begin
      ClearPng(ATPngImage);
    end;
  except
    ClearPng(ATPngImage);
  end;
end;

//function GetWebUrlFromAlias(AControll: IGilAppController; AAlias: string): string;
//var
//  i: Integer;
//  AXml: TNativeXml;
//  AList: TList;
//  AFilePath: string;
//  ARoot, ANode, AChildNode: TXmlNode;
//begin
//  Result := '';
//  try
//    if (Assigned(AControll)) and (AAlias <> '') then
//    begin
//      AXml := TNativeXml.Create(nil);
//      try
//        AFilePath := AControll.GetConfigPath + Const_Web_FilePath;
//        if FileExists(AFilePath) then
//        begin
//          AXml.LoadFromFile(AFilePath);
//          AXml.XmlFormat := xfReadable;
//          ARoot := AXml.Root;
//          ARoot.FindNodes(Const_Web_Module, AList);
//          for i := 0 to AList.Count - 1 do
//          begin
//            ANode := TXmlNode(AList.Items[i]);
//            AChildNode := ANode.FindNode(Const_Web_ModuleAsila);
//            if Assigned(AChildNode) and (string(AChildNode.Value) = AAlias) then
//            begin
//              AChildNode := ANode.FindNode(Const_Web_URL);
//              if Assigned(AChildNode) then
//                Result := string(AChildNode.Value);
//              Break;
//            end;
//          end;
//        end;
//      finally
//        if (Assigned(AXml)) then
//          FreeAndNil(AXml);
//      end;
//    end;
//  except
//    on e: Exception do
//      if(Assigned(AControll))then
//        AControll.GetLogWriter.Log(llError, 'GetWebUrlFromAlias: ' + '��ȡURL(' + AAlias + ')ʧ��');
//  end;
//end;

//function GetDefaultUrl(AControll: IGilAppController; ATitle: string): string;
//const
//  const_local_default_html = './config/Web/default.html';
//var
//  vPath: string;
//begin
//  Result := CONST_URL_Blank;
//  if FileExists(const_local_default_html) then
//  begin
//    vPath := ExpandFileName(const_local_default_html);
//  end
//  else
//    Exit;
//  Result := StringReplace(CONST_URL_DefaultFormat,'!path',vPath,[rfReplaceAll]);
//  Result := StringReplace(Result,'!title',ATitle,[rfReplaceAll]);
//  if AControll <> nil then
//    Result := ReplaceURLParam(Result, AControll.Style, AControll.FontRatio())
//  else
//    Result := ReplaceURLParam(Result, '', '');
//end;

function IsForeignIndex(ASecuCategory, ASecuMarket: Integer): Boolean;
begin
  Result := ASecuCategory = 4; // ֤ȯ���Ϊ4��ʾָ��
  if Result then
  begin
    case ASecuMarket of
      // ����ָ��
      76, 77, 78, 79, 80, 54, 56, 55, 220,
      // ŷ��ָ��
      85, 86, 87, 88, 94, 95, 98, 106, 120, 160, 161, 162, 180,
      240, 250, 260, 320, 130, 140, 200, 230, 201,
      // ��̫������ָ��
      49, 50, 52, 57, 58, 65, 66, 67, 68, 69, 75, 107,
      109, 110, 190, 210, 270, 280, 290, 300:
        Result := True;
    else
      Result := False;
    end;
  end;
end;


//function GetCategoryOf(AStockInfoRec: StockInfoRec):TEnumStockCategory;
//begin
//  Result := escStock;
//  case AStockInfoRec.ZQLB of
//    1, 2:         //��Ʊ
//      begin
//        if AStockInfoRec.ZQSC = 81 then
//        begin
//          Result := escNewStock;
//        end;
//      end;
//    24,55,69,73,74,75:
//      begin
//        case AStockInfoRec.ZQSC of
//          76, 77, 78, 79:   //����
//            begin
//              Result := escUSStock;
//            end;
//          72:
//            begin
//              Result := escHKStock;
//            end;
//        end;
//      end;
//    3,51, 52,53,//�۹�
//    25,  20,21,  63,   65,  71,  72:  //�۹�--����
//      begin
//        Result := escHKStock;
//      end;
//    930:     //ָ��
//      begin
//        Result := escIndex;
//      end;
//    4, 910, 920:
//      begin
//        if AStockInfoRec.NBBM = 64119 then
//        begin
//          Result := escIndexYuEBao;
//        end
//        else
//        begin
//          case AStockInfoRec.ZQSC of
//              // ����ָ��
//            76, 77, 78, 79, 80, 54, 56, 55, 220,
//              // ŷ��ָ��
//            85, 86, 87, 88, 94, 95, 98, 106, 120, 160, 161, 162, 180, 240, 250, 260, 320, 130, 140, 200, 230, 201,
//              // ��̫������ָ��
//            45, 50, 52, 57, 58, 65, 66, 67, 68, 69, 70, 72, 75, 107, 109, 110, 190, 210, 270, 280, 290, 300:
//              Result := escIndexForeign;
//          else
//            Result := escIndex;
//          end;
//        end;
//      end;
//    1301, 1302, 82, 84, 85, 86,     //���ڻ���    82,84,62��ETF����
//    61,62:         //�۹�--����
//      begin
//        Result := escInnerFund;
//      end;
//    81:           //����ǻ��һ���
//      begin
//        Result := escOuterOpenFund;
//      end;
//    83:           //������һ���
//      begin
//        Result := escOuterOpenCurrencyFund;
//      end;
//    6, 7, 11, 14,18,17, 28:     //��ͨծȯ
//      begin
//        if (AStockInfoRec.ZQSC = 83) or (AStockInfoRec.ZQSC =90) then
//        begin
//          Result := escBondHSMarket;
//        end
//        else
//          Result := escBond;
//      end;
//    5,12,19,27:     //ծȯ�ع�
//      begin
//        if (AStockInfoRec.ZQSC = 83) or (AStockInfoRec.ZQSC =90) then
//        begin
//          Result := escBondBuyBack;
//        end;
//      end;
//    9, 29:        //��תծ
//      begin
//        Result := escConvertibleBond;
//      end;
//    801,802:          //��Ʒ�ڻ�
//      begin
//        Result := escCommodityFutures;
//      end;
//    803,804:          //�����ڻ�
//      begin
//        Result := escFinancialFutures;
//      end;
//  end;
//end;


//function GetCategoryOf(AGilAppController: IGilAppController;AInnerCode:Integer):TEnumStockCategory;
//var
//  vStockInfoRec: StockInfoRec;
//begin
//  Result := escStock;
//  if Assigned(AGilAppController) then
//  begin
//    AGilAppController.QueryStockInfo(AInnerCode, vStockInfoRec);
//
//    Result := GetCategoryOf(vStockInfoRec);
//  end;
//end;

end.
