unit QuoteTime;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Graphics,
  Messages,
  ExtCtrls,
  GR32,
  G32Graphic,
  QuoteManagerEx,
  QuoteStruct,
  WNDataSetInf,
  GFDataSet,
  Utils,
  QuoteTimeStruct,
  QuoteTimeDisplay,
  QuoteTimeData,
  QuoteTimeGraph,
  QuoteTimeHandle,
  QuoteTimeMinute,
  QuoteTimeVolume,
  QuoteTimeMenu,
  QuoteCommLibrary,
  QuoteTimeMenuIntf,
  QuoteCommStack,
  QuoteTimeSQL,
  AppContext,
  SecuMain;

type

  TQuoteTime = class(TCustomControl)
  private
    FAppContext: IAppContext;
//    FOnChangeStock: TOnChangeStockEvent;
//    FGilAppController: IGilAppController;
//    FMineGFData: IGFData;
//    FTradeGFData: IGFData;
//    FNotifySvr: INotifyServices;
//    FNotify: INotify;
    FBuffer: TBitmap32; // 双缓冲类对象
    FG32Graphic: TG32Graphic; // 画图工具类对象  (负责 在FBuffer上画线 实线、点线、柱状等)
    FDisplay: TQuoteTimeDisplay; // 配置类对象  (皮肤 , 状态等)
    FQuoteTimeData: TQuoteTimeData; // 行情数据订阅、接收、推送
    FTimeGraphs: TQuoteTimeGraphs;
    FTimeOperates: TQuoteTimeOperates; // 键盘 鼠标 等操作拦截类
    FTimeMenu: TQuoteTimeMenu; // 右键菜单
    FGFQueryTimer: TTimer;
    FInnerCode: Integer;
    FGFInnerCode: Integer;
    FFundInnerCodes: string;

    procedure RequestGFData;
//    procedure GFQuery;
//    procedure GFDataArrive(const GFData: IGFData);
//    procedure AssetGFDataArrive(const GFData: IGFData);
//    procedure DoRangeChange(NotifyType: NotifyTypeEnum; Param: NativeUInt);
    procedure DoDataInvalidate;
    procedure DoGFQueryTimer(Sender: TObject);
    procedure AddGraph;

    procedure SetBorderLine(BorderLine: TQuoteBorderLine);
    function GetBorderLine: TQuoteBorderLine;
    function GetStackForm: TQuoteStack;
    function GetCrossVisible: Boolean;
    procedure SetCrossVisible(_Visible: Boolean);
    function GetMineVisible: Boolean;
    procedure SetMineVisible(_Visible: Boolean);
    function GetAuctionVisible: Boolean;
    procedure SetAuctionVisible(_Visible: Boolean);
    function GetCurrentPriceVisible: Boolean;
    procedure SetCurrentPriceVisible(_Visible: Boolean);
    function GetTradePointVisible: Boolean;
    procedure SetTradePointVisible(_Visible: Boolean);
//    function IsHasLimitAxis(_InnerCode: Integer;
//      var _StockInfoRec: StockInfoRec): Boolean;
    function IsHasLimitAxis(ASecuInfo: PSecuInfo): Boolean;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure WMErase(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;

    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMContextMenu(var Message: TWMContextMenu);
      message WM_CONTEXTMENU;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
  public
    constructor Create(AContext: IAppContext; AShowMode: TQuoteShowMode);
      reintroduce;
    destructor Destroy; override;

//    procedure ConnectQuoteManager(const GilAppController: IGilAppController;
//      const QuoteManager: IQuoteManagerEx; const NotifySvr: INotifyServices);
//    procedure DisConnectQuoteManager;
    procedure DoSendToBack;
    procedure DoBringToFront;
    procedure UpdateSkin;

//    procedure HistoryDayChangeStock(InnerCode, Day: Integer);
//    procedure ChangeStock(InnerCode: Integer;
//      SubcribeType: TSubcribeType); overload;
//    procedure ChangeStock(InnerCode: Integer; SubcribeType: TSubcribeType;
//      _StockInfoRec: StockInfoRec); overload;
    procedure ChangeStock(SubcribeType: TSubcribeType;
      ASecuInfo: PSecuInfo);
    procedure ChangFund(_FundInnerCodes: string);
    procedure CancelSubcribe(AClearData: Boolean);
    procedure Enlarge;
    procedure Narrow;
    function GetDataNull: Boolean;
    procedure SetVertMinHeight(_Height: Integer);

    property StackForm: TQuoteStack read GetStackForm;
    property ShowCross: Boolean read GetCrossVisible write SetCrossVisible;
    property ShowMine: Boolean read GetMineVisible write SetMineVisible;
    property ShowCurrentPriceHint: Boolean read GetCurrentPriceVisible
      write SetCurrentPriceVisible;
    property ShowAuction: Boolean read GetAuctionVisible
      write SetAuctionVisible;
    property ShowTradePoint: Boolean read GetTradePointVisible
      write SetTradePointVisible;
    property DataNull: Boolean read GetDataNull;
    property BorderLine: TQuoteBorderLine read GetBorderLine
      write SetBorderLine;
//    property OnChangeStock: TOnChangeStockEvent read FOnChangeStock
//      write FOnChangeStock;
    property OnMouseDown;
    property OnKeyDown;
  end;

implementation

{ TQuoteTime }

constructor TQuoteTime.Create(AContext: IAppContext; AShowMode: TQuoteShowMode);
begin
  inherited Create(nil);
  FAppContext := AContext;
  ControlStyle := ControlStyle + [csOpaque, csDisplayDragImage];
  TabStop := true;
  FDisplay := TQuoteTimeDisplay.Create(FAppContext);
  FBuffer := TBitmap32.Create;
  FBuffer.SetSize(1, 1);
  FG32Graphic := TG32Graphic.Create(Self, FBuffer, Self.Canvas);
  FQuoteTimeData := TQuoteTimeData.Create(FAppContext);
  FQuoteTimeData.OnInvalidate := DoDataInvalidate;
  FQuoteTimeData.OnChangeValue := FDisplay.ChangeFutureDecimal;
  FTimeGraphs := TQuoteTimeGraphs.Create(FAppContext, FG32Graphic, Self.Canvas,
    FQuoteTimeData, FDisplay);
  FDisplay.ShowMode := AShowMode;
  if FDisplay.ShowMode = smNormal then
  begin
    FTimeMenu := TQuoteTimeMenu.Create(FAppContext, FTimeGraphs);
    FTimeMenu.AddMenus;
    FGFQueryTimer := TTimer.Create(nil);
    FGFQueryTimer.OnTimer := DoGFQueryTimer;
    FGFQueryTimer.Interval := 5 * 60 * 1000;
    FGFQueryTimer.Enabled := False;
  end
  else if FDisplay.ShowMode in [smSimple, smComplexScreen] then
  begin
    FDisplay.GirdLineDistanceHeight := FDisplay.GirdLineDistanceHeight - 5;
  end;
  FTimeOperates := TQuoteTimeOperates.Create(FTimeGraphs, FTimeMenu);
  AddGraph;
  FGFInnerCode := -1;
end;

destructor TQuoteTime.Destroy;
begin
  if Assigned(FGFQueryTimer) then
  begin
    FGFQueryTimer.Enabled := False;
    FGFQueryTimer.Free;
  end;
  if Assigned(FTimeOperates) then
    FreeAndNil(FTimeOperates);
  if Assigned(FTimeGraphs) then
    FreeAndNil(FTimeGraphs);
  if Assigned(FQuoteTimeData) then
    FreeAndNil(FQuoteTimeData);
  if Assigned(FG32Graphic) then
    FreeAndNil(FG32Graphic);
  if Assigned(FBuffer) then
    FreeAndNil(FBuffer);
  if Assigned(FDisplay) then
    FreeAndNil(FDisplay);
  FAppContext := nil;
  inherited;
end;

//procedure TQuoteTime.ConnectQuoteManager(const GilAppController
//  : IGilAppController; const QuoteManager: IQuoteManagerEx;
//  const NotifySvr: INotifyServices);
//var
//  Unknown: IInterface;
//  tmpGilRanges: IGilRanges;
//  tmpNotify: TNotifyMessage;
//begin
//  FGilAppController := GilAppController;
//  if FGilAppController.QueryInterface(IGilRanges, Unknown) then
//    tmpGilRanges := Unknown as IGilRanges;
//  FDisplay.ConnectQuoteManager(FGilAppController);
//  FTimeGraphs.ConnectQuoteManager(FGilAppController);
//  FQuoteTimeData.ConnectQuoteManager(FGilAppController, QuoteManager,
//    tmpGilRanges);
//  if Assigned(FTimeMenu) then
//    FTimeMenu.ConnectQuoteManager(GilAppController, NotifySvr);
//
//  FNotifySvr := NotifySvr;
//  tmpNotify := TNotifyMessage.Create(NotifySvr, FGilAppController, 'TQuoteTime');
//  tmpNotify.OnRangeChange := DoRangeChange;
//  FNotify := tmpNotify;
//  FNotify.Connect();
//  FQuoteTimeData.NotifyHandle := FNotify.Get_Handle;
//  UpdateSkin;
//end;

//procedure TQuoteTime.DisConnectQuoteManager;
//begin
//  FNotifySvr := nil;
//  FGilAppController := nil;
//  if Assigned(FMineGFData) then
//  begin
//    FMineGFData.CancelQuery;
//    FMineGFData := nil;
//  end;
//  if Assigned(FTradeGFData) then
//  begin
//    FTradeGFData.CancelQuery;
//    FTradeGFData := nil;
//  end;
//  if Assigned(FNotify) then
//  begin
//    FNotify.DisConnect;
//    FNotify := nil;
//  end;
//  if Assigned(FTimeMenu) then
//    FTimeMenu.DisConnectQuoteManager;
//  FQuoteTimeData.DisConnectQuoteManager;
//  FTimeGraphs.DisConnectQuoteManager;
//end;

procedure TQuoteTime.DoDataInvalidate;
begin
  if HandleAllocated then
  begin
    FTimeGraphs.CalcFrame;
    FTimeOperates.PaintTime;

    Invalidate;
  end;
end;

procedure TQuoteTime.DoGFQueryTimer(Sender: TObject);
begin
//  if FGFInnerCode <> -1 then
//    GFQuery;
end;

procedure TQuoteTime.RequestGFData;
var
  tmpGraph: TQuoteTimeGraph;
begin
//  if Assigned(FGilAppController) {and (FGFInnerCode <> FInnerCode)} then
//  begin
//    tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
//    if Assigned(tmpGraph) then
//      tmpGraph.ClearData;
//    FGFInnerCode := FInnerCode;
//    GFQuery;
//  end;
end;

//procedure TQuoteTime.GFQuery;
//var
//  Event: Int64;
//  tmpSql: string;
//  // tmpDataSet: IWNDataSet;
//  tmpLogWriter: ILogWriter;
//  // tmpGraph: TQuoteTimeGraph;
//begin
//  // 请求信息地雷指标
//  tmpSql := Const_Sql_Mine;
//  tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_InnerCode,
//    IntToStr(FGFInnerCode), [rfReplaceAll]);
//  Event := 0;
//  TOnGFDataArrive(Event) := GFDataArrive;
//  tmpLogWriter := FGilAppController.GetLogWriter;
//  if Assigned(tmpLogWriter) then
//    tmpLogWriter.Log(llDebug, '[Time InfoMine]' + tmpSql);
//  FMineGFData := FGilAppController.GFQueryData(Self.Handle, tmpSql, Event,
//    FGFInnerCode); // Const_IndexTag_MinePoint);
//
//  // tmpSql := Const_Sql_Trade;
//  tmpSql := Const_Sql_Trade_New;
//  TOnGFDataArrive(Event) := AssetGFDataArrive;
//  tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_InnerCode,
//    IntToStr(FGFInnerCode), [rfReplaceAll]);
//  tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_FundInnerCodes,
//    FFundInnerCodes, [rfReplaceAll]);
//  if Assigned(tmpLogWriter) then
//    tmpLogWriter.Log(llDebug, '[Time PointData]' + tmpSql);
//  FTradeGFData := FGilAppController.AssetGFQueryData(Self.Handle, tmpSql, Event,
//    FGFInnerCode); // Const_IndexTag_TradePoint);
//
//  // tmpSql := Const_Sql_PointData;
//  // tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_InnerCode,
//  // IntToStr(FGFInnerCode), [rfReplaceAll]);
//  // if Assigned(tmpLogWriter) then
//  // tmpLogWriter.Log(llDebug, '[Time PointData]' + tmpSql);
//  // tmpDataSet := FGilAppController.CacheQueryData(C_QueryUFXData, tmpSql);
//  // tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
//  // if Assigned(tmpGraph) then
//  // tmpGraph.DataArrive(tmpDataSet, Const_IndexTag_TradePoint);
//end;

//procedure TQuoteTime.GFDataArrive(const GFData: IGFData);
//var
//  tmpDataSet: IWNDataSet;
//  tmpGraph: TQuoteTimeGraph;
//begin
//  if GFData.Succeed and (GFData.Tag = FInnerCode) then
//  begin
//    tmpDataSet := IGFData2IDataSet(GFData);
//    if Assigned(tmpDataSet) then
//    begin
//      tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
//      if Assigned(tmpGraph) then
//        tmpGraph.DataArrive(tmpDataSet, Const_IndexTag_MinePoint);
//      DoDataInvalidate;
//    end;
//  end;
//end;
//
//procedure TQuoteTime.AssetGFDataArrive(const GFData: IGFData);
//var
//  tmpDataSet: IWNDataSet;
//  tmpGraph: TQuoteTimeGraph;
//begin
//  if GFData.Succeed and (GFData.Tag = FInnerCode) then
//  begin
//    tmpDataSet := IGFData2IDataSet(GFData);
//    tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
//    if Assigned(tmpGraph) then
//      tmpGraph.DataArrive(tmpDataSet, Const_IndexTag_TradePoint);
//    DoDataInvalidate;
//  end;
//end;

//procedure TQuoteTime.DoRangeChange(NotifyType: NotifyTypeEnum;
//  Param: NativeUInt);
//begin
//  FQuoteTimeData.DoChangeSelfStock;
//  DoDataInvalidate;
//end;

procedure TQuoteTime.AddGraph;
begin
  if FDisplay.ShowMode <> smComplexScreen then
    FTimeGraphs.AddGraph(const_volumekey, TQuoteTimeVolume.Create(FAppContext, FTimeGraphs));
  FTimeGraphs.AddGraph(const_minutekey, TQuoteTimeMinute.Create(FAppContext, FTimeGraphs));
end;

//procedure TQuoteTime.HistoryDayChangeStock(InnerCode, Day: Integer);
//var
//  tmpStockInfoRec: StockInfoRec;
//begin
//  if Assigned(FQuoteTimeData.MainData) then
//  begin
//    FQuoteTimeData.MainData.HasLimitAixs := IsHasLimitAxis(InnerCode,
//      tmpStockInfoRec);
//    if tmpStockInfoRec.ZQSC in [76, 77, 78, 79] then
//      FQuoteTimeData.IsVolumeDelay := true
//    else
//      FQuoteTimeData.IsVolumeDelay := False;
//  end;
//  FQuoteTimeData.SubscribeHistory(InnerCode, Day);
//  if Assigned(FQuoteTimeData.MainData) then
//    FDisplay.ChangeStockType(FQuoteTimeData.MainData.StockType);
//  DoDataInvalidate;
//end;

//function TQuoteTime.IsHasLimitAxis(_InnerCode: Integer;
//  var _StockInfoRec: StockInfoRec): Boolean;
//var
//  tmpStr: string;
//begin
//  Result := False;
//  if Assigned(FGilAppController) then
//  begin
//    FGilAppController.QueryStockInfo(_InnerCode, _StockInfoRec);
//    case _StockInfoRec.ZQLB of
//      1, 2, 82, 84, 85, 86, 1301, 1302, 62:
//        begin
//          tmpStr := _StockInfoRec.GPDM;
//          if Pos('.OC', tmpStr) > 0 then
//            Result := False
//          else
//            Result := true;
//        end;
//    else
//      Result := False;
//    end;
//  end;
//end;

function TQuoteTime.IsHasLimitAxis(ASecuInfo: PSecuInfo): Boolean;
begin
  case ASecuInfo^.FSecuCategory of
    1, 2, 82, 84, 85, 86, 1301, 1302, 62:
      begin
//        tmpStr := ASecuInfo^.FSecuCode;
        if Pos('.OC', ASecuInfo^.FSecuCode) > 0 then
          Result := False
        else
          Result := true;
      end;
  else
    Result := False;
  end;
end;

procedure TQuoteTime.CancelSubcribe(AClearData: Boolean);
begin
  FInnerCode := -1;
  FQuoteTimeData.MainSecuCode := '';
  FQuoteTimeData.MainStockName := '';
  FQuoteTimeData.CancelSubcribe(AClearData);
  if AClearData then
    DoDataInvalidate;
end;

//procedure TQuoteTime.ChangeStock(InnerCode: Integer;
//  SubcribeType: TSubcribeType; _StockInfoRec: StockInfoRec);
//var
//  tmpStockInfoRec: StockInfoRec;
//begin
//  if Assigned(FQuoteTimeData.MainData) then
//  begin
//    FQuoteTimeData.MainData.HasLimitAixs := IsHasLimitAxis(InnerCode,
//      tmpStockInfoRec);
//    if tmpStockInfoRec.ZQSC in [76, 77, 78, 79] then
//      FQuoteTimeData.IsVolumeDelay := true
//    else
//      FQuoteTimeData.IsVolumeDelay := False;
//  end;
//  if Assigned(FGFQueryTimer) and FGFQueryTimer.Enabled then
//    FGFQueryTimer.Enabled := False;
//  if Assigned(FTimeMenu) then
//    FTimeMenu.ChangeStock(InnerCode);
//  if FDisplay.ShowMode in [smMulitStock, smHistoryTime, smWSSelfDefinition] then
//  begin
//    FQuoteTimeData.MainSecuCode := '';
//    FQuoteTimeData.MainStockName := '';
//    if FGilAppController.QueryStockInfo(InnerCode, _StockInfoRec) then
//    begin
//      FQuoteTimeData.MainSecuCode := _StockInfoRec.GPDM;
//      FQuoteTimeData.MainStockName := _StockInfoRec.ZQJC;
//    end;
////    if Assigned(FOnChangeStock) then
////      FOnChangeStock(_StockInfoRec);
//  end;
//  if SubcribeType = stSingleDay then
//    FQuoteTimeData.Subscribe(InnerCode)
//  else
//    FQuoteTimeData.Subscribe(InnerCode, FDisplay.MaxDayCount);
//  if Assigned(FQuoteTimeData.MainData) then
//    FDisplay.ChangeStockType(FQuoteTimeData.MainData.StockType);
//  if FDisplay.ShowMode = smNormal then
//  begin
//    FInnerCode := InnerCode;
//    RequestGFData;
//    if Assigned(FGFQueryTimer) and (not FGFQueryTimer.Enabled) then
//      FGFQueryTimer.Enabled := true;
//  end;
//  DoDataInvalidate;
//end;

procedure TQuoteTime.ChangeStock(SubcribeType: TSubcribeType;
  ASecuInfo: PSecuInfo);
begin
  if Assigned(FQuoteTimeData.MainData) then
  begin
    FQuoteTimeData.MainData.HasLimitAixs := IsHasLimitAxis(ASecuInfo);
    if ASecuInfo.ToGilMarket in [76, 77, 78, 79] then
      FQuoteTimeData.IsVolumeDelay := true
    else
      FQuoteTimeData.IsVolumeDelay := False;
  end;
  if Assigned(FGFQueryTimer) and FGFQueryTimer.Enabled then
    FGFQueryTimer.Enabled := False;
  if Assigned(FTimeMenu) then
    FTimeMenu.ChangeStock(ASecuInfo^.FInnerCode);
  if FDisplay.ShowMode in [smMulitStock, smHistoryTime, smWSSelfDefinition] then
  begin
    FQuoteTimeData.MainSecuCode := '';
    FQuoteTimeData.MainStockName := '';
//    if FGilAppController.QueryStockInfo(InnerCode, _StockInfoRec) then
//    begin
      FQuoteTimeData.MainSecuCode := ASecuInfo^.FSecuCode; //_StockInfoRec.GPDM;
      FQuoteTimeData.MainStockName := ASecuInfo^.FSecuAbbr; //_StockInfoRec.ZQJC;
//    end;
//    if Assigned(FOnChangeStock) then
//      FOnChangeStock(_StockInfoRec);
  end;
  if SubcribeType = stSingleDay then
    FQuoteTimeData.Subscribe(ASecuInfo^.FInnerCode)
  else
    FQuoteTimeData.Subscribe(ASecuInfo^.FInnerCode, FDisplay.MaxDayCount);
  if Assigned(FQuoteTimeData.MainData) then
    FDisplay.ChangeStockType(FQuoteTimeData.MainData.StockType);
  if FDisplay.ShowMode = smNormal then
  begin
    FInnerCode := ASecuInfo^.FInnerCode;
//    RequestGFData;
//    if Assigned(FGFQueryTimer) and (not FGFQueryTimer.Enabled) then
//      FGFQueryTimer.Enabled := true;
  end;
  DoDataInvalidate;
end;

//procedure TQuoteTime.ChangeStock(InnerCode: Integer;
//  SubcribeType: TSubcribeType);
//var
//  tmpStockInfoRec: StockInfoRec;
//begin
//  if Assigned(FQuoteTimeData.MainData) then
//  begin
//    FQuoteTimeData.MainData.HasLimitAixs := IsHasLimitAxis(InnerCode,
//      tmpStockInfoRec);
//    if tmpStockInfoRec.ZQSC in [76, 77, 78, 79] then
//      FQuoteTimeData.IsVolumeDelay := true
//    else
//      FQuoteTimeData.IsVolumeDelay := False;
//  end;
//  if Assigned(FGFQueryTimer) and FGFQueryTimer.Enabled then
//    FGFQueryTimer.Enabled := False;
//  if Assigned(FTimeMenu) then
//    FTimeMenu.ChangeStock(InnerCode);
//  if SubcribeType = stSingleDay then
//    FQuoteTimeData.Subscribe(InnerCode)
//  else
//    FQuoteTimeData.Subscribe(InnerCode, FDisplay.MaxDayCount);
//  if Assigned(FQuoteTimeData.MainData) then
//    FDisplay.ChangeStockType(FQuoteTimeData.MainData.StockType);
//  if Assigned(FTimeOperates) then
//    FTimeOperates.ResetFormat;
//  if FDisplay.ShowMode = smNormal then
//  begin
//    FInnerCode := InnerCode;
//    RequestGFData;
//    if Assigned(FGFQueryTimer) and (not FGFQueryTimer.Enabled) then
//      FGFQueryTimer.Enabled := true;
//  end;
//  DoDataInvalidate;
//end;

procedure TQuoteTime.ChangFund(_FundInnerCodes: string);
//var
//  Event: Int64;
//  tmpSql: string;
//  tmpLogWriter: ILogWriter;
begin
//  if FDisplay.ShowMode = smNormal then
//  begin
//    FFundInnerCodes := _FundInnerCodes;
//    if Visible then
//    begin
//      tmpSql := Const_Sql_Trade_New;
//      TOnGFDataArrive(Event) := AssetGFDataArrive;
//      tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_InnerCode,
//        IntToStr(FGFInnerCode), [rfReplaceAll]);
//      tmpSql := StringReplace(tmpSql, Const_Sql_ReplaceStr_FundInnerCodes,
//        FFundInnerCodes, [rfReplaceAll]);
//      if Assigned(tmpLogWriter) then
//        tmpLogWriter.Log(llDebug, '[Time PointData]' + tmpSql);
//      FTradeGFData := FGilAppController.AssetGFQueryData(Self.Handle, tmpSql,
//        Event, FGFInnerCode);
//    end;
//  end;
end;

procedure TQuoteTime.CMEnter(var Message: TCMEnter);
begin

end;

procedure TQuoteTime.CMExit(var Message: TCMExit);
begin

end;

procedure TQuoteTime.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FTimeOperates.CMMouseLeave(Message);
end;

procedure TQuoteTime.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  FTimeOperates.KeyDown(Key, Shift);
end;

procedure TQuoteTime.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  FTimeOperates.KeyUp(Key, Shift);
end;

procedure TQuoteTime.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FTimeOperates.MouseDown(Button, Shift, X, Y);
end;

procedure TQuoteTime.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  FTimeOperates.MouseMove(Shift, X, Y);
end;

procedure TQuoteTime.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FTimeOperates.MouseUp(Button, Shift, X, Y);
end;

procedure TQuoteTime.Paint;
var
  R: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FBuffer <> nil) then
  begin
    Canvas.Lock;
    try
      R := Rect(0, 0, Width, Height);
      // 所有的画操作都是在 FBuffer上面的，最后会拷贝到主画布上的
      DrawCopyRect(Canvas.Handle, R, FBuffer.Handle, R);
      // 所有在主画布上绘画行情到达后都会消失，所以要在Buffer拷贝
      // 到主画布之后做重新画在主画布上
      FTimeOperates.DrawOperates;
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TQuoteTime.Resize;
const
  BufferOversize = 5;
var
  NewWidth, NewHeight, W, H: Integer;
begin
  if not(csDesigning in ComponentState) and (FBuffer <> nil) then
  begin

    NewWidth := Width;
    NewHeight := Height;

    if NewWidth < 0 then
      NewWidth := 0;
    if NewHeight < 0 then
      NewHeight := 0;

    W := FBuffer.Width;

    if NewWidth > W then
      W := NewWidth + BufferOversize
    else if NewWidth < W - BufferOversize then
      W := NewWidth;

    if W < 1 then
      W := 1;

    H := FBuffer.Height;

    if NewHeight > H then
      H := NewHeight + BufferOversize
    else if NewHeight < H - BufferOversize then
      H := NewHeight;

    if H < 1 then
      H := 1;

    if (W <> FBuffer.Width) or (H <> FBuffer.Height) then
    begin
      FBuffer.Lock;
      try
        FBuffer.SetSize(W, H);
      finally
        FBuffer.UnLock;
      end;
    end;
    FTimeGraphs.CalcFrame;
    FTimeOperates.PaintTime;
    FTimeOperates.Resize;
  end;
  inherited Resize;
end;

function TQuoteTime.GetStackForm: TQuoteStack;
begin
  Result := nil;
  if Assigned(FTimeMenu) then
    Result := FTimeMenu.QuoteStack;
end;

procedure TQuoteTime.SetBorderLine(BorderLine: TQuoteBorderLine);
begin
  FDisplay.BorderLine := BorderLine;
  DoDataInvalidate;
end;

function TQuoteTime.GetBorderLine: TQuoteBorderLine;
begin
  Result := FDisplay.BorderLine;
end;

procedure TQuoteTime.SetCrossVisible(_Visible: Boolean);
begin
  FDisplay.CrossLineVisible := _Visible;
  FTimeOperates.TimeCross.IsDrawCross := _Visible;
end;

function TQuoteTime.GetCrossVisible: Boolean;
begin
  Result := FDisplay.CrossLineVisible;
end;

procedure TQuoteTime.SetCurrentPriceVisible(_Visible: Boolean);
begin
  FDisplay.CurrentPriceVisible := _Visible;
  if Visible then
    DoDataInvalidate;
end;

function TQuoteTime.GetCurrentPriceVisible: Boolean;
begin
  Result := FDisplay.CurrentPriceVisible;
end;

function TQuoteTime.GetDataNull: Boolean;
begin
  Result := true;
  if Assigned(FQuoteTimeData.MainData) then
    Result := FQuoteTimeData.MainData.NullTimeData;
end;

procedure TQuoteTime.SetAuctionVisible(_Visible: Boolean);
begin
  FDisplay.AuctionVisible := _Visible;
  if Visible then
    DoDataInvalidate;
end;

function TQuoteTime.GetAuctionVisible: Boolean;
begin
  Result := FDisplay.AuctionVisible;
end;

procedure TQuoteTime.SetMineVisible(_Visible: Boolean);
begin
  FDisplay.InfoMineVisible := _Visible;
  if Visible then
    DoDataInvalidate;
end;

procedure TQuoteTime.SetTradePointVisible(_Visible: Boolean);
begin
  FDisplay.TradePointVisible := _Visible;
  if Visible then
    DoDataInvalidate;
end;

procedure TQuoteTime.SetVertMinHeight(_Height: Integer);
begin
  FDisplay.GirdLineDistanceHeight := _Height;
end;

function TQuoteTime.GetTradePointVisible: Boolean;
begin
  Result := FDisplay.TradePointVisible;
end;

function TQuoteTime.GetMineVisible: Boolean;
begin
  Result := FDisplay.InfoMineVisible;
end;

procedure TQuoteTime.WMCancelMode(var Message: TWMCancelMode);
begin
  FTimeOperates.WMCancelMode(Message);
end;

procedure TQuoteTime.WMContextMenu(var Message: TWMContextMenu);
begin
  FTimeOperates.WMContextMenu(Message);
end;

procedure TQuoteTime.WMErase(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TQuoteTime.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS;
end;

procedure TQuoteTime.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      if not(csDesigning in ComponentState) and not Focused then
      begin
        Windows.SetFocus(Handle);
        if not Focused then
          Exit;
      end;
  end;
  inherited WndProc(Message);
end;

procedure TQuoteTime.Enlarge;
begin
  FTimeGraphs.Enlarge;
end;

procedure TQuoteTime.Narrow;
begin
  FTimeGraphs.Narrow;
end;

procedure TQuoteTime.DoSendToBack;
var
  tmpGraph: TQuoteTimeGraph;
begin
//  if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
//  then
//    FGilAppController.GetLogWriter.Log(llDebug, '[' + Self.ClassName +
//      '] 开始调用  DoSendToBack');
  try
    CancelSubcribe(False);
    if Assigned(FTimeMenu) and Assigned(FTimeMenu.QuoteStack) and
      FTimeMenu.QuoteStack.Showing then
      FTimeMenu.QuoteStack.Hide;
    tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
    if Assigned(tmpGraph) then
      tmpGraph.DoSendToBack;
    if Assigned(FGFQueryTimer) and FGFQueryTimer.Enabled then
      FGFQueryTimer.Enabled := False;
  except
    on Ex: Exception do
    begin
//      if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
//      then
//      begin
//        FGilAppController.GetLogWriter.Log(llError, '[' + Self.ClassName +
//          '] 执行  DoSendToBack 出错');
//      end
    end;
  end;
end;

procedure TQuoteTime.DoBringToFront;
begin
//  if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
//  then
//    FGilAppController.GetLogWriter.Log(llDebug, '[' + Self.ClassName +
//      '] 开始调用  DoBringToFront');
end;

procedure TQuoteTime.UpdateSkin;
begin
  FDisplay.UpdateSkin;
  FG32Graphic.UpdateFont(FDisplay.TextFont);
  if Assigned(FTimeMenu) then
    FTimeMenu.UpdateSkin;
  FTimeGraphs.UpdateSkin;
  FTimeOperates.UpdateSkin;
  DoDataInvalidate;
end;

end.
