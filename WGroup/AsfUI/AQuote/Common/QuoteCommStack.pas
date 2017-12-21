unit QuoteCommStack;

{
  <?xml version="1.0" encoding="UTF-8"?>
  <Stack>
  <Version></Version>
  <TypeTime>
  <StackData>
  <InnerCode></InnerCode>
  <StockName></StockName>
  <StackType></StackType>
  <IsStack></IsStack>
  <StackData>
  </TypeTime>

  <TypeMarket>
  <StackData>
  <InnerCode></InnerCode>
  <StockName></StockName>
  <StackType></StackType>
  <IsStack></IsStack>
  <StackData>
  </TypeMarket>
  </Stack>
}

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Controls,
  Graphics,
  StdCtrls,
  Forms,
  Vcl.Imaging.pngimage,
  NativeXml,
  BaseForm,
  Generics.Collections,
  G32Graphic,
  QuoteCommLibrary,
  WNDataSetInf,
  QuoteCommHint, QuoteCommConst, CommonFunc, BaseObject, AppContext, LogLevel;

const
  Const_Stack_Content = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
    '<Stack>' + #13#10 + '<Version>' + #13#10 + '<Version>' + #13#10 +
    '</Stack>';

  // 保存数据的节点信息
  Const_Node_Name_Stack = 'Stack';
  Const_Node_Name_Stack_Version = 'Version';
  Const_Node_Name_Stack_TypeTime = 'TypeTime';
  Const_Node_Name_Stack_TypeMarket = 'TypeMarket';
  Const_Node_Name_Stack_StackData = 'StackData';
  Const_Node_Name_Stack_InnerCode = 'InnerCode';
  Const_Node_Name_Stack_StockName = 'StockName';
  Const_Node_Name_Stack_StackType = 'StackType';
  Const_Node_Name_Stack_IsStack = 'IsStack';

  // 版本值
  Const_Node_Name_Stack_Version_Value = '1.0';

  // 图标资源名称
  Const_ResourceName_Stack_ClearStack = 'StockStack_ClearStack';
  Const_ResourceName_Stack_Search = 'StockStack_Search';
  Const_ResourceName_Stack_DelOne = 'StockStack_DelOne';
  Const_ResourceName_Stack_AddOne = 'StockStack_AddOne';

  // 显示字符串
  Const_Stack_CountHint = '已添加叠加品种:  ';
  Const_Stack_ClearStack = '清空';

  // 查询叠加指数的指标
  Const_Stack_Sql_Index =
    'Select InnerCode, IndexInnerCode, SWFirstIndexCode From ' +
    'DW_Superimposedvariety Where InnerCode = #ReplaceStr';
  Const_Stack_Sql_ReplaceStr = '#ReplaceStr';

  Const_Log_Stack_Prefix = '[StockStack] ';

type

  TStackLoadType = (ltTime, ltMarket); // 区分K线 和 分时
  TStockStackType = (sstUserDefined, sstMarketIndex, sstSWIndex);
  TStackOperateType = (otAdd, otDelete, otDeleteAll, otChangeStock);
  TStackChangeEvent = procedure(OperateType: TStackOperateType;
    InnerCode: Integer) of object;

  TInnerCodes = array of Integer;

  TStackDisplay = class(TBaseObject)
//    FGilAppController: IGilAppController;
    FSkinStyle: string;
    TextFont: TFont;
    DrawPng: TPngImage; // 搜索提示

    BackColor: TColor; // 背景颜色
    EditBackColor: TColor;
    TitleBackColor: TColor; //
    BottomBackColor: TColor; // 底部背景颜色
    BorderLineColor: TColor; // 边框颜色
    EidtFrameLineColor: TColor;
    DivideLineColor: TColor;
    HintFontColor: TColor;
    IndexFontColor: TColor;
    FontColor: TColor;
    ClearAllHintFontColor: TColor;
    FocusRowBackColor: TColor;

    HintFontHeight: Integer; // 提示字体的高度
    FontHeight: Integer; //

    BottomHeight: Integer;
    TitleTopSpace: Integer; // 编辑框的到标题的距离
    LeftSpace: Integer; // 左边距离
    RightSpace: Integer; // 右边距离
    TextLeftSpace: Integer; // 文字左边距离
    IconRightSpace: Integer; // 图标右边的距离
    TextRowSize: Integer; // 文字行高
    EditVertSpace: Integer;
    EditHorzSpace: Integer;
    EditHeight: Integer;
    TotalCount: Integer;
    DivideToFormTopHeight: Integer;

    SearchIconWidth: Integer;
    SearchIconHeight: Integer;
    AddAndDelIconWidth: Integer;
    AddAndDelIconHeight: Integer;
    ClearStackIconWidth: Integer;
    ClearStackIconHeight: Integer;
    XSpace: Integer;

    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;
    function RefreshPng(_ResourceName: string): Boolean;
    procedure UpdateSkin;
  end;

  TStackData = class
  public
    InnerCode: Integer; // 叠加内码
    StockName: string;
    StackType: TStockStackType; // 是不是
    IsStack: Boolean;
    Rect: TRect;
    IconRect: TRect;
    Focused: Boolean;
    IsHint: Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

  TQuoteStack = class(TBaseForm)
  protected
//    FGilAppController: IGilAppController;
    FDisplay: TStackDisplay;
    FBitmap: TBitmap;
    FLoadType: TStackLoadType;
    FStackDatas: TList<TStackData>;
    FStackInnerCodes: TList<Integer>;
    FHint: THintControl;
    FEdit: TEdit;
    FIsResize: Boolean;

    FFocusStackData: TStackData;
    FStackTotalCount: Integer;
    FMainInnerCode: Integer;
    FOnStackChange: TStackChangeEvent;

    procedure InitEdit;
    procedure InitEvent;
    procedure InitData;

    // 处理内部对象的方法
    procedure CleanList(_List: TList<TStackData>);
    procedure SaveStackDatas;
    procedure ReadStackDatas;
    procedure SaveDefaultStackDatas;
    procedure AddDefaultStackDatas;
    procedure StackDataToNode(_Node: TXmlNode; _StackData: TStackData);
    procedure NodeToStackData(_Node: TXmlNode; _StackData: TStackData);
    function StackTypeToValue(_StackType: TStockStackType): Integer;
    function ValueToStackType(_Value: Integer): TStockStackType;
//    function IsHasStackData(_StockInfoRec: StockInfoRec;
//      var _StackData: TStackData): Boolean;
//    function AddStackData(_StockInfoRec: StockInfoRec;
//      IsStack: Boolean): Boolean;

    // 计算方法
    procedure CalcEidtPos;
    procedure CalcStackDatasRect;
    function CalcStackCount: Integer;
    function CalcStackData(_Pt: TPoint; var _StackData: TStackData): Boolean;
    function CalcStackDataEx(_Pt: TPoint; var _StackData: TStackData): Boolean;
    function GetEditFrameRect: TRect;
    function GetDrawSearchPt: TPoint;
    function GetClearStackRect: TRect;
    function GetBottomRect: TRect;
    function GetStackHintRect: TRect;
    function GetStackData(_StackType: TStockStackType;
      var _StackData: TStackData): Boolean;
    function GetIndexInnerCode(var _MarketInnercode, _SWInnerCode
      : Integer): Boolean;
    function ClearAllStacks(var _IsSave, _IsDraw: Boolean): Boolean;

    // 处理画的方法
    procedure DoInvaildate;
    procedure Draw;
    procedure DrawBack;
    procedure DrawFrameLine;
    procedure DrawStackDatas;
    procedure DrawStackData(_Canvas: TCanvas; _StackData: TStackData;
      _BackColor, _FontColor: TColor);
    procedure DrawFocusStackData(_Canvas: TCanvas; _StackData: TStackData);
    procedure EraseRect(_Rect: TRect);
    procedure EraseRectFocusStackData;

    // 基类方法
    procedure DoCreate; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
    // 自己增加事件
    procedure DoEditKeyPress(Sender: TObject; var Key: Char);
    procedure DoStackChange(_IsSave: Boolean);
    procedure ChangeStockInnerCodes;
  public
    constructor Create(AContext: IAppContext; _StackLoadType: TStackLoadType); reintroduce;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController);
//    procedure DisConnectQuoteManager;
    procedure ChangeStock(InnerCode: Integer);
    function GetStackInnerCodes(var _InnerCodes: TInnerCodes): Boolean;
    procedure UpdateSkin; override;

    property OnStackChange: TStackChangeEvent read FOnStackChange
      write FOnStackChange;
  end;

implementation

{ TStackDisplay }

constructor TStackDisplay.Create(AContext: IAppContext);
begin
  inherited;
  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -12;

  DrawPng := TPngImage.Create;

  HintFontHeight := -14;
  FontHeight := -16;

  BackColor := $FFFFFF;
  EditBackColor := $FFFFFF;
  BottomBackColor := $EDEDED;
  TitleBackColor := $FFFFFF;
  BorderLineColor := $999999;
  EidtFrameLineColor := $CCCCCC;
  DivideLineColor := $E6E6E6;
  HintFontColor := $6B6B6B;
  IndexFontColor := $6B6B6B;
  FontColor := $333333;
  FocusRowBackColor := $DCECF9;
  ClearAllHintFontColor := $5A5A5A;

  // BackColor := $444444;
  // EditBackColor := $333333;
  // BottomBackColor := $383838;
  // TitleBackColor := $444444;
  // BorderLineColor := $171717;
  // EidtFrameLineColor := $646464;
  // DivideLineColor := $3A3A3A;
  // HintFontColor := $C8C8C8;
  // IndexFontColor := $DCDCDC;
  // FontColor := $FFFFFF;
  // FocusRowBackColor := $737373;
  // ClearAllHintFontColor := $C2C2C2;

  BottomHeight := 28;
  TitleTopSpace := 10; // 编辑框距离标题距离
  LeftSpace := 10; // 左边距离
  RightSpace := 10; // 右边距离
  TextLeftSpace := 20; // 文字左边距离
  IconRightSpace := 40; // 图标右边的距离
  TextRowSize := 30; // 文字行高
  EditVertSpace := 2;
  EditHorzSpace := 3;
  EditHeight := 18;
  TotalCount := 5;
  DivideToFormTopHeight := 90;

  SearchIconWidth := 14;
  SearchIconHeight := 14;
  AddAndDelIconWidth := 15;
  AddAndDelIconHeight := 15;
  ClearStackIconWidth := 12;
  ClearStackIconHeight := 14;
  XSpace := 10;
end;

destructor TStackDisplay.Destroy;
begin
  if Assigned(TextFont) then
    TextFont.Free;
  if Assigned(DrawPng) then
    DrawPng.Free;
  inherited;
end;

function TStackDisplay.RefreshPng(_ResourceName: string): Boolean;
begin
  Result := False;
  try
    if Assigned(FAppContext) and (_ResourceName <> '') then
    begin
      DrawPng.LoadFromResourceName(FAppContext.GetResourceSkin.GetInstance, //FGilAppController.GetSkinInstance,
        _ResourceName);
      Result := True;
    end;
  except
    on Ex: Exception do
    begin
//      if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
//      then
//      begin
//        FGilAppController.GetLogWriter.Log(llError, Const_Log_Stack_Prefix +
//          '没有资源' + _ResourceName);
//      end
      FAppContext.SysLog(llError, Const_Log_Stack_Prefix +
          '没有资源' + _ResourceName);
    end;
  end;
end;

procedure TStackDisplay.UpdateSkin;
const
  Const_StockStack_Prefix = 'StockStack_';
var
  tmpSkinStyle: string;
  function GetStrFromConfig(_Key: WideString): string;
  begin
    Result := FAppContext.GetResourceSkin.GetConfig(Const_StockStack_Prefix + _Key);
//    Result := FGilAppController.Config(ctSkin, Const_StockStack_Prefix + _Key);
  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_StockStack_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_StockStack_Prefix + _Key), 0));
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;
      TextFont.Name := GetStrFromConfig('TextFontName');
      BackColor := GetColorFromConfig('BackColor');
      EditBackColor := GetColorFromConfig('EditBackColor');
      BottomBackColor := GetColorFromConfig('BottomBackColor');
      TitleBackColor := GetColorFromConfig('TitleBackColor');
      BorderLineColor := GetColorFromConfig('BorderLineColor');
      EidtFrameLineColor := GetColorFromConfig('EidtFrameLineColor');
      DivideLineColor := GetColorFromConfig('DivideLineColor');
      HintFontColor := GetColorFromConfig('HintFontColor');
      IndexFontColor := GetColorFromConfig('IndexFontColor');
      FontColor := GetColorFromConfig('FontColor');
      FocusRowBackColor := GetColorFromConfig('FocusRowBackColor');
      ClearAllHintFontColor := GetColorFromConfig('ClearAllHintFontColor');
    end;
//  end;
end;

{ TStackData }

constructor TStackData.Create;
begin
  StockName := '';
  StackType := sstUserDefined;
  IsStack := False;
  InnerCode := -1;
  Focused := False;
  IsHint := False;
end;

destructor TStackData.Destroy;
begin

  inherited;
end;

{ TQuoteStack }

constructor TQuoteStack.Create(AContext: IAppContext; _StackLoadType: TStackLoadType);
begin
  inherited CreateNew(nil, AContext);
  FLoadType := _StackLoadType;
  FDisplay := TStackDisplay.Create(AContext);
  FBitmap := TBitmap.Create;
  FStackDatas := TList<TStackData>.Create;
  FStackInnerCodes := TList<Integer>.Create;
  FHint := THintControl.Create(nil);
  FEdit := TEdit.Create(nil);
  InitData;
  ReadStackDatas;
end;

destructor TQuoteStack.Destroy;
begin
  if Assigned(FEdit) then
    FEdit.Free;
  if Assigned(FHint) then
    FHint.Free;
  if Assigned(FStackInnerCodes) then
    FStackInnerCodes.Free;
  if Assigned(FStackDatas) then
  begin
    CleanList(FStackDatas);
    FStackDatas.Free;
  end;
  if Assigned(FBitmap) then
    FBitmap.Free;
  if Assigned(FDisplay) then
    FDisplay.Free;
  inherited;
end;

//procedure TQuoteStack.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//begin
//  FGilAppController := GilAppController;
//  FTitleBar.ConnectQuoteManager(FGilAppController);
//  FDisplay.ConnectQuoteManager(FGilAppController);
//  ReadStackDatas;
//  UpdateSkin;
//end;

//procedure TQuoteStack.DisConnectQuoteManager;
//begin
//  FDisplay.DisConnectQuoteManager;
//  FGilAppController := nil;
//end;

procedure TQuoteStack.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := WS_POPUP;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;

    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
  Params.WndParent := Screen.ActiveForm.Handle;
  if (Params.WndParent <> 0) and
    (IsIconic(Params.WndParent) or not IsWindowVisible(Params.WndParent) or
    not IsWindowEnabled(Params.WndParent)) then
    Params.WndParent := 0;
  if Params.WndParent = 0 then
    Params.WndParent := Application.Handle;
end;

procedure TQuoteStack.CleanList(_List: TList<TStackData>);
var
  tmpIndex: Integer;
begin
  FFocusStackData := nil;
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
    begin
      if Assigned(_List.Items[tmpIndex]) then
        TObject(_List.Items[tmpIndex]).Free;
    end;
    FStackDatas.Clear;
  end;
end;

function TQuoteStack.ClearAllStacks(var _IsSave, _IsDraw: Boolean): Boolean;
var
  tmpIndex: Integer;
  tmpStackData: TStackData;
begin
  Result := False;
  _IsDraw := False;
  _IsSave := False;
  for tmpIndex := FStackDatas.Count - 1 downto 0 do
  begin
    tmpStackData := FStackDatas.Items[tmpIndex];
    if Assigned(tmpStackData) then
    begin
      if tmpStackData.StackType = sstUserDefined then
      begin
        Result := True;
        _IsSave := True;
        if tmpStackData.IsStack then
          _IsDraw := True;
        FreeAndNil(tmpStackData);
        FStackDatas.Delete(tmpIndex);
      end
      else
      begin
        if tmpStackData.IsStack then
        begin
          Result := True;
          _IsSave := True;
          _IsDraw := True;
          tmpStackData.IsStack := False;
        end;
      end;
    end;
  end;
end;

procedure TQuoteStack.ReadStackDatas;
var
  tmpIndex: Integer;
  tmpXML: TNativeXml;
  tmpNodeList: TList;
  tmpStackData: TStackData;
  tmpContent, tmpTypeString: string;
  tmpRoot, tmpNode, tmpChildNode: TXmlNode;
begin
//  if Assigned(FGilAppController) then
//  begin
    if FLoadType = ltTime then
      tmpTypeString := Const_Node_Name_Stack_TypeTime
    else
      tmpTypeString := Const_Node_Name_Stack_TypeMarket;
    tmpContent := FAppContext.GetCfg.GetUserCacheCfg.GetServerValue(Const_Key_StockStack_StockInfo);
//    tmpContent := string(FGilAppController.GetConfigOprateIntf.GetUserConfig
//      (Const_Key_StockStack_StockInfo));
    if tmpContent <> '' then
    begin
      tmpXML := TNativeXml.Create(nil);
      try
        tmpXML.ReadFromString(UTF8String(tmpContent));
        tmpXML.XmlFormat := xfReadable;
        tmpRoot := tmpXML.Root;
        tmpNode := tmpRoot.FindNode(UTF8String(Const_Node_Name_Stack_Version));
        if Assigned(tmpNode) and
          (tmpNode.Value = Const_Node_Name_Stack_Version_Value) then
        begin
          tmpNode := tmpRoot.FindNode(UTF8String(tmpTypeString));
          if Assigned(tmpNode) then
          begin
            tmpNodeList := TList.Create;
            try
              tmpNode.FindNodes(UTF8String(Const_Node_Name_Stack_StackData),
                tmpNodeList);
              if tmpNodeList.Count > 0 then
              begin
                for tmpIndex := 0 to tmpNodeList.Count - 1 do
                begin
                  tmpChildNode := TXmlNode(tmpNodeList.Items[tmpIndex]);
                  if Assigned(tmpChildNode) then
                  begin
                    tmpStackData := TStackData.Create;
                    FStackDatas.Add(tmpStackData);
                    NodeToStackData(tmpChildNode, tmpStackData);
                  end;
                end;
              end
              else
                SaveDefaultStackDatas;
            finally
              if Assigned(tmpNodeList) then
                tmpNodeList.Free;
            end;
          end
          else
            SaveDefaultStackDatas;
        end
        else
          SaveDefaultStackDatas;
      finally
        if Assigned(tmpXML) then
          tmpXML.Free;
      end;
    end
    else
      SaveDefaultStackDatas;
//  end;
end;

procedure TQuoteStack.SaveDefaultStackDatas;
begin
//  if Assigned(FGilAppController) then
//  begin
    AddDefaultStackDatas;
    SaveStackDatas;
//  end;
end;

procedure TQuoteStack.SaveStackDatas;
var
  tmpIndex: Integer;
  tmpXML: TNativeXml;
  tmpStackData: TStackData;
  tmpContent, tmpTypeString: string;
  tmpRoot, tmpNode, tmpChildNode: TXmlNode;
begin
//  if Assigned(FGilAppController) then
//  begin
    tmpXML := TNativeXml.Create(nil);
    try
      if FLoadType = ltTime then
        tmpTypeString := Const_Node_Name_Stack_TypeTime
      else
        tmpTypeString := Const_Node_Name_Stack_TypeMarket;
      tmpContent := FAppContext.GetCfg.GetUserCacheCfg.GetServerValue(Const_Key_StockStack_StockInfo);
//      tmpContent := FGilAppController.GetConfigOprateIntf.GetUserConfig
//        (Const_Key_StockStack_StockInfo);
      if tmpContent <> '' then
        tmpXML.ReadFromString(UTF8String(tmpContent))
      else
        tmpXML.ReadFromString(UTF8String(Const_Stack_Content));
      tmpXML.XmlFormat := xfReadable;
      tmpRoot := tmpXML.Root;
      // 保存版本值
      tmpNode := tmpRoot.FindNode(Const_Node_Name_Stack_Version);
      if Assigned(tmpNode) then
        tmpNode.Value := UTF8String(Const_Node_Name_Stack_Version_Value);

      // 删除之前的数据
      tmpNode := tmpRoot.FindNode(UTF8String(tmpTypeString));
      if Assigned(tmpNode) then
        tmpNode.Delete;

      tmpNode := tmpRoot.NodeNew(UTF8String(tmpTypeString));
      if Assigned(tmpNode) then
      begin
        for tmpIndex := 0 to FStackDatas.Count - 1 do
        begin
          tmpStackData := FStackDatas.Items[tmpIndex];
          tmpChildNode := tmpNode.NodeNew
            (UTF8String(Const_Node_Name_Stack_StackData));
          if Assigned(tmpStackData) then
            StackDataToNode(tmpChildNode, tmpStackData);
        end;
      end;
      FAppContext.GetCfg.GetUserCacheCfg.SaveServer(Const_Key_StockStack_StockInfo,
        '', tmpXML.WriteToLocalUnicodeString);
//      FGilAppController.GetConfigOprateIntf.SetUserConfig
//        (Const_Key_StockStack_StockInfo, '', tmpXML.WriteToLocalUnicodeString);
    finally
      if Assigned(tmpXML) then
      begin
        tmpXML.Clear;
        tmpXML.Free;
      end;
    end;
//  end;
end;

function TQuoteStack.StackTypeToValue(_StackType: TStockStackType): Integer;
begin
  case _StackType of
    sstMarketIndex:
      Result := 1;
    sstSWIndex:
      Result := 2;
  else
    Result := 0;
  end;
end;

function TQuoteStack.ValueToStackType(_Value: Integer): TStockStackType;
begin
  case _Value of
    1:
      Result := sstMarketIndex;
    2:
      Result := sstSWIndex;
  else
    Result := sstUserDefined;
  end;
end;

//function TQuoteStack.IsHasStackData(_StockInfoRec: StockInfoRec;
//  var _StackData: TStackData): Boolean;
//var
//  tmpIndex: Integer;
//begin
//  Result := False;
//  for tmpIndex := 0 to FStackDatas.Count - 1 do
//  begin
//    _StackData := FStackDatas.Items[tmpIndex];
//    if Assigned(_StackData) and (_StackData.StackType = sstUserDefined) and
//      (_StackData.InnerCode = _StockInfoRec.NBBM) then
//    begin
//      Result := True;
//      Break;
//    end;
//  end;
//end;
//
//function TQuoteStack.AddStackData(_StockInfoRec: StockInfoRec;
//  IsStack: Boolean): Boolean;
//var
//  tmpStackData: TStackData;
//begin
//  Result := False;
//  if (not IsHasStackData(_StockInfoRec, tmpStackData)) then
//  begin
//    if (FStackDatas.Count < FStackTotalCount) then
//    begin
//      Result := True;
//      tmpStackData := TStackData.Create;
//      tmpStackData.InnerCode := _StockInfoRec.NBBM;
//      tmpStackData.StockName := _StockInfoRec.ZQJC;
//      tmpStackData.IsStack := True;
//      FStackDatas.Add(tmpStackData);
//    end;
//  end
//  else
//  begin
//    if Assigned(tmpStackData) and (not tmpStackData.IsStack) then
//    begin
//      Result := True;
//      tmpStackData.IsStack := True;
//    end;
//  end;
//end;

procedure TQuoteStack.AddDefaultStackDatas;
var
  tmpStackData: TStackData;
begin
  CleanList(FStackDatas);
  tmpStackData := TStackData.Create;
  tmpStackData.StackType := sstMarketIndex;
  tmpStackData.StockName := '大盘指数';
  tmpStackData.IsStack := False;
  tmpStackData.InnerCode := 0;
  FStackDatas.Add(tmpStackData);

  tmpStackData := TStackData.Create;
  tmpStackData.StackType := sstSWIndex;
  tmpStackData.StockName := '申万一级指数';
  tmpStackData.IsStack := False;
  tmpStackData.InnerCode := 0;
  FStackDatas.Add(tmpStackData);
end;

procedure TQuoteStack.StackDataToNode(_Node: TXmlNode; _StackData: TStackData);
var
  tmpNode: TXmlNode;
begin
  tmpNode := _Node.NodeNew(UTF8String(Const_Node_Name_Stack_InnerCode));
  if Assigned(tmpNode) then
    tmpNode.Value := UTF8String(IntToStr(_StackData.InnerCode));

  tmpNode := _Node.NodeNew(UTF8String(Const_Node_Name_Stack_StockName));
  if Assigned(tmpNode) then
    tmpNode.Value := UTF8String(_StackData.StockName);

  tmpNode := _Node.NodeNew(UTF8String(Const_Node_Name_Stack_StackType));
  if Assigned(tmpNode) then
    tmpNode.Value :=
      UTF8String(IntToStr(StackTypeToValue(_StackData.StackType)));

  tmpNode := _Node.NodeNew(UTF8String(Const_Node_Name_Stack_IsStack));
  if Assigned(tmpNode) then
    tmpNode.Value := UTF8String(BoolToStr(_StackData.IsStack));
end;

procedure TQuoteStack.NodeToStackData(_Node: TXmlNode; _StackData: TStackData);
var
  tmpNode: TXmlNode;
begin
  tmpNode := _Node.FindNode(Const_Node_Name_Stack_InnerCode);
  if Assigned(tmpNode) then
    _StackData.InnerCode := StrToIntDef(string(tmpNode.Value), -1);

  tmpNode := _Node.FindNode(Const_Node_Name_Stack_StockName);
  if Assigned(tmpNode) then
    _StackData.StockName := string(tmpNode.Value);

  tmpNode := _Node.FindNode(Const_Node_Name_Stack_StackType);
  if Assigned(tmpNode) then
    _StackData.StackType := ValueToStackType
      (StrToIntDef(string(tmpNode.Value), 0));

  tmpNode := _Node.FindNode(Const_Node_Name_Stack_IsStack);
  if Assigned(tmpNode) then
    _StackData.IsStack := StrToBoolDef(string(tmpNode.Value), False);
end;

procedure TQuoteStack.CMMouseLeave(var Message: TMessage);
begin
  EraseRectFocusStackData;
  FHint.HideHint;
end;

procedure TQuoteStack.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TQuoteStack.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpPt: TPoint;
  tmpStackData: TStackData;
begin
  inherited;
  with FBitmap, FDisplay do
  begin
    if CalcStackData(Point(X, Y), tmpStackData) then
    begin
      if not tmpStackData.Focused then
      begin
        EraseRectFocusStackData;
        DrawFocusStackData(Self.Canvas, tmpStackData);
        FFocusStackData := tmpStackData;
        tmpStackData.Focused := True;

        if tmpStackData.IsHint then
        begin
          tmpPt := Self.ClientToScreen(Point(X, Y + 10));
          FHint.ShowHint(tmpStackData.StockName, tmpPt.X, tmpPt.Y);
        end;
      end;
    end
    else
    begin
      EraseRectFocusStackData;
      FHint.HideHint;
    end;
  end;
end;

procedure TQuoteStack.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  tmpStackData: TStackData;
  tmpIsSave, tmpIsDraw: Boolean;
begin
  inherited;
  if CalcStackDataEx(Point(X, Y), tmpStackData) then
  begin
    tmpStackData.IsStack := not tmpStackData.IsStack;
    DoStackChange(True);
  end;

  if PtInRect(GetClearStackRect, Point(X, Y)) then
  begin
    if ClearAllStacks(tmpIsSave, tmpIsDraw) then
    begin
      FFocusStackData := nil;
      DoStackChange(tmpIsSave);
    end;
  end;
end;

procedure TQuoteStack.Paint;
var
  tmpRect: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FBitmap <> nil) then
  begin
    Canvas.Lock;
    try
      tmpRect := Rect(0, 0, Width, Height);
      DrawCopyRect(Canvas.Handle, tmpRect, FBitmap.Canvas.Handle, tmpRect);
      if Assigned(FFocusStackData) and FFocusStackData.Focused then
        DrawFocusStackData(Self.Canvas, FFocusStackData);
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TQuoteStack.Resize;
begin
  if (Width <> FBitmap.Width) or (Height <> FBitmap.Height) then
  begin
    FBitmap.Canvas.Lock;
    try
      FBitmap.SetSize(Width, Height);
    finally
      FBitmap.Canvas.UnLock;
    end;
  end;
  DoInvaildate;
  inherited;
end;

procedure TQuoteStack.DoCreate;
begin

end;

procedure TQuoteStack.DoEditKeyPress(Sender: TObject; var Key: Char);
var
  tmpPt: TPoint;
//  tmpKeyFairyMng: IKeyFairyMng;
//  tmpStockInfoRec: StockInfoRec;
begin
//  if not(AnsiChar(Key) in [#8, #13, #10]) then
//  begin
//    if Assigned(FGilAppController) then
//    begin
//      tmpPt := ClientToScreen(Point(FEdit.Left, FEdit.Top + FEdit.Height + 5));
//      tmpKeyFairyMng := FGilAppController.GetKeyFairyMng;
//      if Assigned(tmpKeyFairyMng) then
//      begin
//        if tmpKeyFairyMng.KeyFairyChooseStock(FEdit.Handle, Key, '', '',
//          tmpPt.X, tmpPt.Y, tmpStockInfoRec) and (tmpStockInfoRec.ZQJC <> '')
//        then
//        begin
//          if AddStackData(tmpStockInfoRec, True) then
//          begin
//            DoStackChange(True);
//            FEdit.SetFocus;
//          end;
//        end;
//      end;
//      Key := #0;
//    end;
//  end;
end;

procedure TQuoteStack.DoStackChange(_IsSave: Boolean);
begin
  if _IsSave then
    SaveStackDatas;
  ChangeStockInnerCodes;
  DoInvaildate;
  if Assigned(FOnStackChange) then
    FOnStackChange(otChangeStock, -1);
end;

function TQuoteStack.CalcStackCount: Integer;
var
  tmpIndex: Integer;
  tmpStackData: TStackData;
begin
  Result := 0;
  for tmpIndex := 0 to FStackDatas.Count - 1 do
  begin
    tmpStackData := FStackDatas.Items[tmpIndex];
    if Assigned(tmpStackData) and tmpStackData.IsStack then
      Inc(Result);
  end;
end;

procedure TQuoteStack.CalcEidtPos;
begin
  with FDisplay do
  begin
    FEdit.Top := FTitleBar.Height + TitleTopSpace;
    FEdit.Left := LeftSpace + 2 * EditHorzSpace + SearchIconWidth;
    FEdit.Width := Width - FEdit.Left - LeftSpace - EditHorzSpace * 2;
  end;
end;

procedure TQuoteStack.CalcStackDatasRect;
var
  tmpIndex, tmpTop, tmpIconRight, tmpIconLeft: Integer;
  tmpStackData: TStackData;
begin
  with FDisplay do
  begin
    tmpTop := DivideToFormTopHeight;
    tmpIconRight := Width - IconRightSpace;
    tmpIconLeft := tmpIconRight - AddAndDelIconWidth;
    for tmpIndex := 0 to FStackDatas.Count - 1 do
    begin
      tmpStackData := FStackDatas.Items[tmpIndex];
      if Assigned(tmpStackData) then
      begin
        tmpStackData.Rect := Rect(TextLeftSpace, tmpTop, Width - RightSpace,
          tmpTop + TextRowSize);
        tmpStackData.IconRect.Left := tmpIconLeft;
        tmpStackData.IconRect.Right := tmpIconRight;
        tmpStackData.IconRect.Top :=
          (tmpStackData.Rect.Top + tmpStackData.Rect.Bottom -
          AddAndDelIconHeight) div 2;
        tmpStackData.IconRect.Bottom := tmpStackData.IconRect.Top +
          AddAndDelIconHeight;
        tmpTop := tmpStackData.Rect.Bottom;
      end;
    end;
  end;
end;

function TQuoteStack.GetEditFrameRect: TRect;
begin
  with FDisplay do
  begin
    Result := Rect(FEdit.Left - 2 * EditHorzSpace - SearchIconWidth,
      FEdit.Top - EditVertSpace, FEdit.Left + FEdit.Width + EditHorzSpace,
      FEdit.Top + FEdit.Height + EditVertSpace);
  end;
end;

function TQuoteStack.GetIndexInnerCode(var _MarketInnercode,
  _SWInnerCode: Integer): Boolean;
var
  tmpSql: string;
  tmpDataSet: IWNDataSet;
  tmpMarketStackData, tmpSWStackData: TStackData;
begin
  Result := False;
  _MarketInnercode := -1;
  _SWInnerCode := -1;
//  if Assigned(FGilAppController) then
//  begin
//    GetStackData(sstMarketIndex, tmpMarketStackData);
//    GetStackData(sstSWIndex, tmpSWStackData);
//    if Assigned(tmpMarketStackData) and Assigned(tmpSWStackData) and
//      (tmpMarketStackData.IsStack or tmpSWStackData.IsStack) then
//    begin
//      tmpSql := StringReplace(Const_Stack_Sql_Index, Const_Stack_Sql_ReplaceStr,
//        IntToStr(FMainInnerCode), [rfReplaceAll]);
//      tmpDataSet := FGilAppController.CacheQueryData('', tmpSql);
//      if Assigned(tmpDataSet) and (tmpDataSet.RecordCount > 0) then
//      begin
//        try
//          tmpDataSet.First;
//          if tmpMarketStackData.IsStack and
//            (not tmpDataSet.FieldByName('IndexInnerCode').IsNull) then
//            _MarketInnercode := tmpDataSet.FieldByName('IndexInnerCode')
//              .AsInteger;
//        except
//          on Ex: Exception do
//          begin
//            if Assigned(FGilAppController.GetLogWriter) then
//            begin
//              FGilAppController.GetLogWriter.Log(llError,
//                Const_Log_Stack_Prefix +
//                '表 DW_Superimposedvariety 字段IndexInnerCode有问题');
//            end;
//          end;
//        end;
//        try
//          if tmpSWStackData.IsStack and
//            (not tmpDataSet.FieldByName('SWFirstIndexCode').IsNull) then
//            _SWInnerCode := tmpDataSet.FieldByName('SWFirstIndexCode')
//              .AsInteger;
//        except
//          on Ex: Exception do
//          begin
//            if Assigned(FGilAppController.GetLogWriter) then
//            begin
//              FGilAppController.GetLogWriter.Log(llError,
//                Const_Log_Stack_Prefix +
//                '表 DW_Superimposedvariety 字段SWFirstIndexCode有问题');
//            end;
//          end;
//        end;
//      end;
//    end;
//  end;
end;

function TQuoteStack.GetStackData(_StackType: TStockStackType;
  var _StackData: TStackData): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  for tmpIndex := 0 to FStackDatas.Count - 1 do
  begin
    _StackData := FStackDatas.Items[tmpIndex];
    if Assigned(_StackData) and (_StackData.StackType = _StackType) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TQuoteStack.GetStackHintRect: TRect;
begin
  with FDisplay do
  begin
    Result := Rect(LeftSpace, DivideToFormTopHeight - TextRowSize,
      Width - RightSpace, DivideToFormTopHeight);
  end;
end;

function TQuoteStack.GetStackInnerCodes(var _InnerCodes: TInnerCodes): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  SetLength(_InnerCodes, FStackInnerCodes.Count);
  for tmpIndex := 0 to FStackInnerCodes.Count - 1 do
    _InnerCodes[tmpIndex] := FStackInnerCodes.Items[tmpIndex];
end;

procedure TQuoteStack.ChangeStock(InnerCode: Integer);
begin
  FMainInnerCode := InnerCode;
  DoStackChange(False);
end;

procedure TQuoteStack.ChangeStockInnerCodes;
var
  tmpStackData: TStackData;
  tmpHash: TDictionary<Integer, Integer>;
  tmpIndex, tmpIndexInnerCode, tmpSWIndexInnerCode, tmpValue,
    tmpInnerCode: Integer;
begin
  FStackInnerCodes.Clear;
  GetIndexInnerCode(tmpIndexInnerCode, tmpSWIndexInnerCode);
  tmpHash := TDictionary<Integer, Integer>.Create();
  try
    for tmpIndex := 0 to FStackDatas.Count - 1 do
    begin
      tmpStackData := FStackDatas.Items[tmpIndex];
      if Assigned(tmpStackData) and tmpStackData.IsStack then
      begin
        case tmpStackData.StackType of
          sstMarketIndex:
            tmpInnerCode := tmpIndexInnerCode;
          sstSWIndex:
            tmpInnerCode := tmpSWIndexInnerCode;
        else
          tmpInnerCode := tmpStackData.InnerCode;
        end;
        if (tmpInnerCode <> FMainInnerCode) and (tmpInnerCode <> -1) and
          (not tmpHash.TryGetValue(tmpInnerCode, tmpValue)) then
          FStackInnerCodes.Add(tmpInnerCode);
      end;
    end;
  finally
    if Assigned(tmpHash) then
      tmpHash.Free;
  end;
end;

function TQuoteStack.GetBottomRect: TRect;
begin
  with FDisplay do
  begin
    Result := Rect(0, Height - BottomHeight, Width, Height);
  end;
end;

function TQuoteStack.GetClearStackRect: TRect;
var
  tmpWidth: Integer;
begin
  with FBitmap, FDisplay do
  begin
    tmpWidth := Canvas.TextWidth(' ' + Const_Stack_ClearStack);
    Result := GetBottomRect;
    Result.Left := (Result.Left + Result.Right - tmpWidth -
      ClearStackIconWidth) div 2;
    Result.Right := Result.Left + tmpWidth + ClearStackIconWidth;
  end;
end;

function TQuoteStack.GetDrawSearchPt: TPoint;
var
  tmpRect: TRect;
begin
  with FDisplay do
  begin
    tmpRect := GetEditFrameRect;
    Result.X := (tmpRect.Left + FEdit.Left - SearchIconWidth) div 2;
    Result.Y := (tmpRect.Top + tmpRect.Bottom - SearchIconHeight) div 2;
  end;
end;

procedure TQuoteStack.InitData;
begin
  Width := 270;
  Height := 300;
  Visible := False;
  Ctl3D := True;
  FMouseChangeSize := False;
  AutoScroll := False;
  BorderStyle := bsNone;
  BorderIcons := [];
  FTitleBar.BarButtonTypes := [bbtClose];
  FTitleBar.Caption := '叠加品种'; // (输入代码/名称/拼音)
  FTitleBar.BackColor := FDisplay.TitleBackColor;
  FTitleBar.Height := 28;
  BorderWidth := 1;
  Color := FDisplay.BorderLineColor;

  FBitmap.Canvas.Font.Assign(FDisplay.TextFont);
  Self.Canvas.Font.Assign(FDisplay.TextFont);

  FStackTotalCount := 5;
  FFocusStackData := nil;
  InitEdit;
  InitEvent;
end;

procedure TQuoteStack.InitEdit;
begin
  with FDisplay do
  begin
    FEdit.Align := alCustom;
    FEdit.Parent := Self;
    FEdit.Font.Name := '微软雅黑';
    FEdit.Font.Height := -14;
    FEdit.BorderStyle := bsNone;
    FEdit.AutoSize := False;
    FEdit.Height := EditHeight;
    FEdit.ParentColor := False;
    FEdit.Color := BackColor;

    CalcEidtPos;
  end;
end;

procedure TQuoteStack.InitEvent;
begin
  FEdit.OnKeyPress := DoEditKeyPress;
end;

function TQuoteStack.CalcStackData(_Pt: TPoint;
  var _StackData: TStackData): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  for tmpIndex := 0 to FStackDatas.Count - 1 do
  begin
    _StackData := FStackDatas.Items[tmpIndex];
    if Assigned(_StackData) and PtInRect(_StackData.Rect, _Pt) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TQuoteStack.CalcStackDataEx(_Pt: TPoint;
  var _StackData: TStackData): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  for tmpIndex := 0 to FStackDatas.Count - 1 do
  begin
    _StackData := FStackDatas.Items[tmpIndex];
    if Assigned(_StackData) and PtInRect(_StackData.IconRect, _Pt) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TQuoteStack.DoInvaildate;
begin
  CalcStackDatasRect;
  Draw;

  Invalidate;
end;

procedure TQuoteStack.Draw;
begin
  DrawBack;
  DrawFrameLine;
  DrawStackDatas;
end;

procedure TQuoteStack.DrawBack;
var
  tmpRect: TRect;
begin
  with FBitmap, FDisplay do
  begin
    // 填充窗口整体背景
    tmpRect := Rect(0, 0, Width, Height);
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(tmpRect);

    // 填充底部背景
    tmpRect := GetBottomRect;
    Canvas.Brush.Color := BottomBackColor;
    Canvas.FillRect(GetBottomRect);
  end;
end;

procedure TQuoteStack.DrawFrameLine;
var
  tmpPt: TPoint;
  tmpRect: TRect;
begin
  with FBitmap, FDisplay do
  begin
    Canvas.Pen.Color := EidtFrameLineColor;
    Canvas.Brush.Color := EditBackColor;
    Canvas.Rectangle(GetEditFrameRect);

    // 画搜索图片
    tmpPt := GetDrawSearchPt;
    RefreshPng(Const_ResourceName_Stack_Search);
    Canvas.Draw(tmpPt.X, tmpPt.Y, DrawPng);

    // 画清空
    tmpRect := GetClearStackRect;
    tmpPt.X := tmpRect.Left;
    tmpPt.Y := (tmpRect.Top + tmpRect.Bottom - ClearStackIconHeight) div 2;
    RefreshPng(Const_ResourceName_Stack_ClearStack);
    Canvas.Draw(tmpPt.X, tmpPt.Y, DrawPng);
    tmpRect.Left := tmpRect.Left + ClearStackIconWidth;
    Canvas.Brush.Color := BottomBackColor;
    Canvas.Font.Color := ClearAllHintFontColor;
    Canvas.Font.Height := HintFontHeight;
    DrawTextOut(Canvas.Handle, tmpRect, Const_Stack_ClearStack, gtaCenter);
  end;
end;

procedure TQuoteStack.DrawStackDatas;
var
  tmpRect: TRect;
  tmpHint: string;
  tmpIndex, tmpCount: Integer;
  tmpStackData: TStackData;
begin
  with FBitmap, FDisplay do
  begin
    tmpRect := GetStackHintRect;
    Canvas.Brush.Color := BackColor;
    Canvas.Font.Color := HintFontColor;
    Canvas.Font.Height := HintFontHeight;
    tmpCount := FStackInnerCodes.Count;
    tmpHint := Const_Stack_CountHint + IntToStr(tmpCount) + '/' +
      IntToStr(FStackTotalCount);
    Canvas.FillRect(tmpRect);
    DrawTextOut(Canvas.Handle, tmpRect, tmpHint, gtaLeft);

    Canvas.Pen.Color := DivideLineColor;
    Canvas.MoveTo(0, DivideToFormTopHeight - 1);
    Canvas.LineTo(Width, DivideToFormTopHeight - 1);

    for tmpIndex := 0 to FStackDatas.Count - 1 do
    begin
      tmpStackData := FStackDatas.Items[tmpIndex];
      if Assigned(tmpStackData) then
      begin
        case tmpStackData.StackType of
          sstUserDefined:
            DrawStackData(Canvas, tmpStackData, BackColor, FontColor);
          sstMarketIndex, sstSWIndex:
            DrawStackData(Canvas, tmpStackData, BackColor, IndexFontColor);
        end;
      end;
    end;
  end;
end;

procedure TQuoteStack.EraseRect(_Rect: TRect);
begin
  DrawCopyRect(Self.Canvas.Handle, _Rect, FBitmap.Canvas.Handle, _Rect);
end;

procedure TQuoteStack.EraseRectFocusStackData;
var
  tmpRect: TRect;
begin
  if Assigned(FFocusStackData) and FFocusStackData.Focused then
  begin
    tmpRect := FFocusStackData.Rect;
    tmpRect.Left := 0;
    tmpRect.Right := Width;
    EraseRect(tmpRect);
    FFocusStackData.Focused := False;
  end;
end;

procedure TQuoteStack.DrawStackData(_Canvas: TCanvas; _StackData: TStackData;
  _BackColor, _FontColor: TColor);
var
  tmpRect: TRect;
begin
  with FDisplay do
  begin
    _Canvas.Brush.Color := _BackColor;
    _Canvas.Font.Color := _FontColor;
    _Canvas.Font.Height := FontHeight;

    tmpRect := _StackData.Rect;
    tmpRect.Left := 0;
    tmpRect.Right := Width - 1;
    _Canvas.FillRect(tmpRect);

    tmpRect := _StackData.Rect;
    tmpRect.Right := _StackData.IconRect.Left - XSpace;
    DrawTextOut(_Canvas.Handle, tmpRect, _StackData.StockName, gtaLeft, True);

    if _StackData.IsStack then
    begin
      RefreshPng(Const_ResourceName_Stack_DelOne);
      _Canvas.Draw(_StackData.IconRect.Left, _StackData.IconRect.Top, DrawPng)
    end
    else
    begin
      RefreshPng(Const_ResourceName_Stack_AddOne);
      _Canvas.Draw(_StackData.IconRect.Left, _StackData.IconRect.Top, DrawPng);
    end;

    _StackData.IsHint := (_Canvas.TextWidth(_StackData.StockName) >
      (_StackData.IconRect.Left - _StackData.Rect.Left - XSpace));
  end;
end;

procedure TQuoteStack.DrawFocusStackData(_Canvas: TCanvas;
  _StackData: TStackData);
begin
  with FDisplay do
  begin
    case _StackData.StackType of
      sstMarketIndex, sstSWIndex:
        DrawStackData(_Canvas, _StackData, FocusRowBackColor, IndexFontColor);
    else
      DrawStackData(_Canvas, _StackData, FocusRowBackColor, FontColor);
    end;
  end;
end;

procedure TQuoteStack.UpdateSkin;
begin
  with FDisplay do
  begin
    FTitleBar.UpdateSkin;
    FDisplay.UpdateSkin;
    FEdit.Color := FDisplay.EditBackColor;
    FTitleBar.BackColor := FDisplay.TitleBackColor;
    FTitleBar.CaptionColor := FDisplay.FontColor;
    Color := FDisplay.BorderLineColor;
    FBitmap.Canvas.Font.Assign(FDisplay.TextFont);
    Self.Canvas.Font.Assign(FDisplay.TextFont);
    DoInvaildate;
  end;
end;

end.
