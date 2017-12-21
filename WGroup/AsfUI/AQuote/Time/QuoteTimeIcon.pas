unit QuoteTimeIcon;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  Controls,
  DateUtils,
  G32Graphic,
  WNDataSetInf,
  Generics.Collections,
  Vcl.Imaging.pngimage,
  QuoteTimeData,
  QuoteTimeStruct,
  QuoteCommLibrary,
  QuoteTimeGraph, QuoteTimeButton,
  QuoteTimeTradeDetail,
  QuoteCommMine,
  QuoteCommHint,
  BaseObject,
  AppContext,
  LogLevel;

const
  Const_TimeIcon_Information = 'Information';
  Const_TimeIcon_Transaction = 'Transaction';

type

  TTranType = (ttUpTriangle, ttDownTriangle);

  TQuoteTimeIcon = class(TBaseObject)
  protected
    FName: string;
    FDatas: TList;

    FAlign: TAlign;
    FTimeGraphs: TQuoteTimeGraphs;
    FIconRect: TRect;

    function GetDatas(_Index: Integer): TIconButton;

    procedure CleanList(_List: TList);

    procedure InitData; virtual;
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); reintroduce; virtual;
    destructor Destroy; override;
    procedure UpdataRect; virtual;
    procedure AddData(_Rect: TRect);
    procedure DrawIcons; virtual;

    procedure DataArrive(_DataSet: IWNDataSet); virtual;
    function MouseMoveOperate(Shift: TShiftState; _Pt: TPoint)
      : Boolean; virtual;
    function MouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint): Boolean; virtual;
    procedure MouseLeave; virtual;
    procedure ClearData; virtual;
    procedure DoSendToBack; virtual;
    function GetVisible: Boolean; virtual;
    procedure UpdateSkin; virtual;

    property Name: string read FName write FName;
    property IconRect: TRect read FIconRect write FIconRect;
    property Align: TAlign read FAlign write FAlign;
    property IconButtons[_Index: Integer]: TIconButton read GetDatas;
  end;

  TQuoteInformation = class(TQuoteTimeIcon)
  protected
    FQuoteMine: TQuoteMine;
    FMineHash: TDictionary<Integer, TList<TMineData>>;

    procedure CleanListMine(_List: TList<TMineData>);
    procedure CleanHash;
    procedure InitData; override;

    procedure DrawDiamond(_DrawKey: string; _IconButton: TIconButton);
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); override;
    destructor Destroy; override;
    procedure UpdataRect; override;
    procedure DrawIcons; override;

    procedure CalcData(_DataSet: IWNDataSet);
    procedure DataArrive(_DataSet: IWNDataSet); override;
    function MouseMoveOperate(Shift: TShiftState; _Pt: TPoint)
      : Boolean; override;
    function MouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint): Boolean; override;
    procedure MouseLeave; override;
    procedure ClearData; override;
    function GetVisible: Boolean; override;
    procedure DoSendToBack; override;
    procedure UpdateSkin; override;
  end;

  TQuoteTransaction = class(TQuoteTimeIcon)
  protected
    FTradeDetail: TTradeDetail;
    FTradeHash: TDictionary<Integer, TABData>;

    procedure CleanHash;
    procedure InitData; override;

    procedure DrawTriangle(_DrawKey: string; _IconButton: TIconButton;
      _TranType: TTranType);
    function DirectionTypeToValue(DirType: TDirectionType): Integer;
    function ValueToDirectionType(_Value: Integer): TDirectionType;
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); override;
    destructor Destroy; override;
    procedure UpdataRect; override;
    procedure DrawIcons; override;

    procedure CalcData(_DataSet: IWNDataSet);
    procedure DataArrive(_DataSet: IWNDataSet); override;

    function MouseMoveOperate(Shift: TShiftState; _Pt: TPoint)
      : Boolean; override;
    function MouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint): Boolean; override;
    procedure MouseLeave; override;
    procedure ClearData; override;
    procedure DoSendToBack; override;
    function GetVisible: Boolean; override;
    procedure UpdateSkin; override;
  end;

  TQuoteTitleButtons = class(TQuoteTimeIcon)
  protected
    FDrawPng: TPngImage;
    FLastFocusButton: TTitleButton;
    FHint: THintControl;

    procedure InitData; override;
    procedure DoClickEnlarge(Sender: TObject);
    procedure DoClickNarraw(Sender: TObject);
    function CalcButton(_Pt: TPoint; var _Button: TTitleButton): Boolean;
    procedure DrawButton(_Canvas: TCanvas; _Button: TTitleButton;
      _ResName: string);
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); override;
    destructor Destroy; override;

    procedure UpdataRect; override;
    procedure DrawIcons; override;

    function MouseMoveOperate(Shift: TShiftState; _Pt: TPoint)
      : Boolean; override;
    function MouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint): Boolean; override;
    procedure MouseLeave; override;
  end;

implementation

{ TQuoteTimeIcon }

constructor TQuoteTimeIcon.Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited Create(AContext);
  FDatas := TList.Create;
  FTimeGraphs := _TimeGraphs;
  FAlign := alTop;
  InitData;
end;

destructor TQuoteTimeIcon.Destroy;
begin
  if Assigned(FDatas) then
  begin
    CleanList(FDatas);
    FDatas.Free;
  end;
  inherited;
end;

procedure TQuoteTimeIcon.InitData;
begin

end;

procedure TQuoteTimeIcon.AddData(_Rect: TRect);
begin

end;

procedure TQuoteTimeIcon.CleanList(_List: TList);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      TObject(_List[tmpIndex]).Free;
    _List.Clear;
  end;
end;

procedure TQuoteTimeIcon.ClearData;
begin

end;

procedure TQuoteTimeIcon.DoSendToBack;
begin

end;

function TQuoteTimeIcon.GetDatas(_Index: Integer): TIconButton;
begin
  Result := nil;
  if Assigned(FDatas) and (_Index >= 0) and (_Index < FDatas.Count) then
    Result := TIconButton(FDatas.Items[_Index]);
end;

function TQuoteTimeIcon.GetVisible: Boolean;
begin
  Result := False;
end;

procedure TQuoteTimeIcon.UpdataRect;
begin

end;

procedure TQuoteTimeIcon.DrawIcons;
begin

end;

procedure TQuoteTimeIcon.DataArrive(_DataSet: IWNDataSet);
begin

end;

procedure TQuoteTimeIcon.MouseLeave;
begin

end;

function TQuoteTimeIcon.MouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint): Boolean;
begin
  Result := False;
end;

function TQuoteTimeIcon.MouseUpOperate(Button: TMouseButton; Shift: TShiftState;
  _Pt: TPoint): Boolean;
begin
  Result := False;
end;

procedure TQuoteTimeIcon.UpdateSkin;
begin

end;

{ TQuoteInformation }

constructor TQuoteInformation.Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited;
  FQuoteMine := TQuoteMine.CreateNew(nil, AContext);
  FMineHash := TDictionary < Integer, TList < TMineData >>.Create(2);
end;

destructor TQuoteInformation.Destroy;
begin
  if Assigned(FMineHash) then
  begin
    CleanHash;
    FMineHash.Free;
  end;
  if Assigned(FQuoteMine) then
    FQuoteMine.Free;
  inherited;
end;

procedure TQuoteInformation.DoSendToBack;
begin
  if Assigned(FQuoteMine) and FQuoteMine.Showing then
    FQuoteMine.Hide;
end;

procedure TQuoteInformation.InitData;
begin
  inherited;
  FName := 'Infomation';
  FAlign := alTop;
end;

procedure TQuoteInformation.UpdataRect;
var
  tmpMainData: TTimeData;
  tmpGraph: TQuoteTimeGraph;
  tmpIconButton: TIconButton;
  tmpIndex, tmpSize, tmpX, tmpDataIndex: Integer;
begin
  with FTimeGraphs do
  begin
    tmpSize := (IconRect.Height - 4) div 2;
    tmpDataIndex := 0;
    tmpMainData := QuoteTimeData.MainData;
    tmpGraph := GraphsHash[const_minutekey];
    if Assigned(tmpMainData) and Assigned(tmpGraph) and Assigned(FDatas) then
    begin
      for tmpIndex := 0 to FDatas.Count - 1 do
      begin
        tmpIconButton := TIconButton(FDatas.Items[tmpIndex]);
        if Assigned(tmpIconButton) then
        begin
          tmpX := IndexToX(tmpDataIndex,
            tmpMainData.TimeToIndex(tmpIconButton.Time));
          tmpIconButton.Rect := Rect(tmpX - tmpSize, IconRect.Top + 2,
            tmpX - tmpSize + IconRect.Height - 4, IconRect.Bottom - 2);
        end;
      end;
    end;
  end;
end;

procedure TQuoteInformation.DrawDiamond(_DrawKey: string;
  _IconButton: TIconButton);
var
  tmpRect: TRect;
  tmpX, tmpY: Integer;
begin
  with FTimeGraphs do
  begin
    tmpRect := _IconButton.Rect;
    tmpX := (tmpRect.Left + tmpRect.Right) div 2;
    tmpY := (tmpRect.Top + tmpRect.Bottom) div 2;
    G32Graphic.EmptyPoly(_DrawKey);

    G32Graphic.AddPoly(_DrawKey, Point(tmpRect.Left, tmpY));
    G32Graphic.AddPoly(_DrawKey, Point(tmpX, tmpRect.Top));
    G32Graphic.AddPoly(_DrawKey, Point(tmpRect.Right, tmpY));
    G32Graphic.AddPoly(_DrawKey, Point(tmpX, tmpRect.Bottom));
    G32Graphic.AddPoly(_DrawKey, Point(tmpRect.Left, tmpY));

    G32Graphic.GraphicReset;
    G32Graphic.BackColor := Display.InfoMineIconColor;
    G32Graphic.DrawPolyFill(_DrawKey);
  end;
end;

procedure TQuoteInformation.DrawIcons;
var
  tmpIndex: Integer;
  tmpIconButton: TIconButton;
begin
  with FTimeGraphs do
  begin
    if Assigned(FDatas) then
    begin
      for tmpIndex := 0 to FDatas.Count - 1 do
      begin
        tmpIconButton := TIconButton(FDatas.Items[tmpIndex]);
        if Assigned(tmpIconButton) then
        begin
          DrawDiamond('Infomation', tmpIconButton);
        end;
      end;
    end;
  end;
end;

function TQuoteInformation.GetVisible: Boolean;
begin
  Result := FTimeGraphs.Display.InfoMineVisible;
end;

procedure TQuoteInformation.CleanHash;
var
  tmpList: TList<TMineData>;
  tmpListEnum: TDictionary < Integer, TList < TMineData >>.TPairEnumerator;
begin
  if Assigned(FMineHash) then
  begin
    tmpListEnum := FMineHash.GetEnumerator;
    while tmpListEnum.MoveNext do
    begin
      tmpList := FMineHash[tmpListEnum.Current.Key];
      if Assigned(tmpList) then
      begin
        CleanListMine(tmpList);
        tmpList.Clear;
        tmpList.Free;
      end;
    end;
    FMineHash.Clear;
  end;
end;

procedure TQuoteInformation.CleanListMine(_List: TList<TMineData>);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      TObject(_List[tmpIndex]).Free;
    _List.Clear;
  end;
end;

procedure TQuoteInformation.ClearData;
begin
  CleanList(FDatas);
  CleanHash;
end;

procedure TQuoteInformation.CalcData(_DataSet: IWNDataSet);
var
  tmpMainData: TTimeData;
  tmpMineData: TMineData;
  tmpDateTime: TDateTime;
  tmpMinuteCount: Integer;
  tmpIconButton: TIconButton;
  tmpList: TList<TMineData>;
  tmpPublicDate, tmpMessageType, tmpNow, tmpMineDate, tmpTitle, tmpId: string;
begin
  tmpMainData := FTimeGraphs.QuoteTimeData.MainData;
  if Assigned(_DataSet) and Assigned(tmpMainData) then
  begin
    tmpNow := FormatDateTime('YYYYMMDD', Now);
    _DataSet.First;
    while not _DataSet.Eof do
    begin
      tmpDateTime := _DataSet.FieldByName('recordDate').AsDateTime;
      tmpMineDate := FormatDateTime('YYYYMMDD', tmpDateTime);
      tmpPublicDate := FormatDateTime('MM-DD', _DataSet.FieldByName('dateTime')
        .AsDateTime);
      tmpMessageType := _DataSet.FieldByName('messageType').AsString;
      tmpTitle := _DataSet.FieldByName('title').AsString;
      tmpId := _DataSet.FieldByName('id').AsString;
      if (tmpPublicDate <> '') and (tmpMessageType <> '') and (tmpTitle <> '')
        and (tmpId <> '') then
      begin
        if tmpMineDate < tmpNow then
          tmpMinuteCount := tmpMainData.OpenTradeTime
        else if tmpMineDate = tmpNow then
        begin
          tmpMinuteCount := HourOf(tmpDateTime) * 60 + MinuteOf(tmpDateTime);
          tmpMainData.IntToTradeTime(tmpMinuteCount, tmpMinuteCount);
        end;
        if not FMineHash.TryGetValue(tmpMinuteCount, tmpList) then
        begin
          tmpIconButton := TIconButton.Create;
          tmpIconButton.Time := tmpMinuteCount;
          FDatas.Add(tmpIconButton);

          tmpList := TList<TMineData>.Create;
          FMineHash.Add(tmpMinuteCount, tmpList);
        end;

        if Assigned(tmpList) then
        begin
          tmpMineData := TMineData.Create;
          tmpMineData.PublicDate := tmpPublicDate;
          tmpMineData.InfoType := tmpMessageType;
          tmpMineData.Title := tmpTitle;
          tmpMineData.ID := tmpId;
          tmpList.Add(tmpMineData);
        end;
      end;
      _DataSet.Next;
    end;
  end;
end;

procedure TQuoteInformation.DataArrive(_DataSet: IWNDataSet);
begin
  ClearData;
  CalcData(_DataSet);
end;

procedure TQuoteInformation.MouseLeave;
begin
  // if Assigned(FQuoteMine) and FQuoteMine.Showing then
  // FQuoteMine.Hide;
end;

function TQuoteInformation.MouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint): Boolean;
var
  tmpPt: TPoint;
  tmpRect: TRect;
  tmpIndex: Integer;
  tmpList: TList<TMineData>;
  tmpIconButton: TIconButton;
begin
  Result := False;
  if FTimeGraphs.Display.InfoMineVisible then
  begin
    for tmpIndex := 0 to FDatas.Count - 1 do
    begin
      tmpIconButton := IconButtons[tmpIndex];
      if Assigned(tmpIconButton) and PtInRect(tmpIconButton.Rect, _Pt) then
      begin
        Result := true;
        if FMineHash.TryGetValue(tmpIconButton.Time, tmpList) then
        begin
          if Assigned(tmpList) and (not FQuoteMine.Visible) then
          begin
            tmpPt := tmpIconButton.Rect.BottomRight;
            tmpPt.X := (tmpIconButton.Rect.Left + tmpPt.X) div 2;
            FQuoteMine.UpdateShow(tmpList,
              FTimeGraphs.G32Graphic.Control.ClientToScreen(tmpPt),
              FTimeGraphs.QuoteTimeData.MainData.InnerCode);
          end;
        end;
        Break;
      end;
    end;

    if Assigned(FQuoteMine) and FQuoteMine.Visible then
    begin
      tmpRect := FQuoteMine.GetMouseMoveRect;
      if not PtInRect(tmpRect, FTimeGraphs.G32Graphic.Control.ClientToScreen
        (_Pt)) then
      begin
        FQuoteMine.Hide;
      end;
    end;
  end;
end;

function TQuoteInformation.MouseUpOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint): Boolean;
begin
  Result := False;
end;

procedure TQuoteInformation.UpdateSkin;
begin
  if Assigned(FQuoteMine) then
    FQuoteMine.UpdateSkin;
end;

{ TQuoteTransaction }

constructor TQuoteTransaction.Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited;
  FTradeDetail := TTradeDetail.CreateNew(nil, AContext);
  FTradeHash := TDictionary<Integer, TABData>.Create();
end;

destructor TQuoteTransaction.Destroy;
begin
  if Assigned(FTradeHash) then
  begin
    CleanHash;
    FTradeHash.Free;
  end;
  if Assigned(FTradeDetail) then
    FTradeDetail.Free;
  inherited;
end;

function TQuoteTransaction.DirectionTypeToValue
  (DirType: TDirectionType): Integer;
begin
  case DirType of
    dtBuy:
      Result := Const_Direction_Buy;
    dtSell:
      Result := Const_Direction_Sell;
  else
    Result := -1;
  end;
end;

procedure TQuoteTransaction.DoSendToBack;
begin
  if Assigned(FTradeDetail) and FTradeDetail.Showing then
    FTradeDetail.Hide;
end;

procedure TQuoteTransaction.InitData;
begin
  inherited;
  FAlign := alNone;
end;

procedure TQuoteTransaction.UpdataRect;
var
  tmpMainData: TTimeData;
  tmpGraph: TQuoteTimeGraph;
  tmpIconButton: TIconButton;
  tmpIndex, tmpSize, tmpX, tmpY, tmpDataIndex, tmpColIndex, tmpSpace, tmpTop,
    tmpBottom, tmpCompareValue: Integer;
  tmpValue: Double;
  function CalcIconRect(_IconButton: TIconButton; _X, _Y: Integer): TRect;
  begin
    if _IconButton.DirectionType = dtBuy then
      _Y := _Y + tmpSpace
    else
      _Y := _Y - tmpSpace;
    Result := Rect(_X, _Y, _X + 1, _Y + 1);
    Result.Inflate(tmpSize, tmpSize);
    if Result.Top < tmpTop then
      Result.Offset(Point(0, tmpTop - Result.Top + 2));
    if Result.Bottom > tmpBottom then
      Result.Offset(Point(0, tmpBottom - Result.Top - 2));
  end;

begin
  with FTimeGraphs do
  begin
    tmpSize := 5;
    tmpSpace := 20;
    tmpDataIndex := 0;
    tmpMainData := QuoteTimeData.MainData;
    tmpGraph := GraphsHash[const_minutekey];
    tmpTop := tmpGraph.DrawGraphRect.Top;
    tmpBottom := tmpGraph.DrawGraphRect.Bottom;
    if Assigned(tmpMainData) and Assigned(tmpGraph) and Assigned(FDatas) then
    begin
      for tmpIndex := 0 to FDatas.Count - 1 do
      begin
        tmpIconButton := TIconButton(FDatas.Items[tmpIndex]);
        if Assigned(tmpIconButton) and tmpMainData.IsInTradeTime
          (tmpIconButton.Time) then
        begin
          tmpColIndex := tmpMainData.TimeToIndex(tmpIconButton.Time);
          tmpX := IndexToX(tmpDataIndex,
            tmpMainData.TimeToIndex(tmpIconButton.Time));
          tmpMainData.GetValue(dkPrice, tmpColIndex, tmpValue, tmpCompareValue);
          tmpY := tmpGraph.ValueToY(tmpValue);
          tmpIconButton.Rect := CalcIconRect(tmpIconButton, tmpX, tmpY);
        end;
      end;
    end;
  end;
end;

function TQuoteTransaction.ValueToDirectionType(_Value: Integer)
  : TDirectionType;
begin
  case _Value of
    Const_Direction_Buy:
      Result := dtBuy;
    Const_Direction_Sell:
      Result := dtSell;
  else
    Result := dtBuy;
  end;
end;

procedure TQuoteTransaction.DrawIcons;
var
  tmpIndex: Integer;
  tmpMainData: TTimeData;
  tmpIconButton: TIconButton;
begin
  with FTimeGraphs do
  begin
    tmpMainData := QuoteTimeData.MainData;
    if Assigned(FDatas) and Assigned(tmpMainData) then
    begin
      for tmpIndex := 0 to FDatas.Count - 1 do
      begin
        tmpIconButton := TIconButton(FDatas.Items[tmpIndex]);
        if Assigned(tmpIconButton) and tmpMainData.IsInTradeTime
          (tmpIconButton.Time) then
        begin
          if tmpIconButton.DirectionType = dtBuy then
            DrawTriangle('Transaction', tmpIconButton, ttUpTriangle)
          else
            DrawTriangle('Transaction', tmpIconButton, ttDownTriangle);
        end;
      end;
    end;
  end;
end;

procedure TQuoteTransaction.DrawTriangle(_DrawKey: string;
  _IconButton: TIconButton; _TranType: TTranType);
var
  tmpX, tmpY, tmpIndex, tmpCount: Integer;
begin
  with FTimeGraphs do
  begin
    tmpX := (_IconButton.Rect.Left + _IconButton.Rect.Right) div 2;
    if _TranType = ttUpTriangle then
    begin
      tmpY := _IconButton.Rect.Top;
      MCanvas.Pen.Color := Display.UpColor;
      for tmpIndex := 0 to _IconButton.Rect.Height do
      begin
        tmpCount := tmpIndex div 2;
        MCanvas.MoveTo(tmpX - tmpCount, tmpY + tmpIndex);
        MCanvas.LineTo(tmpX + tmpCount, tmpY + tmpIndex);
      end;
    end
    else if _TranType = ttDownTriangle then
    begin
      tmpY := _IconButton.Rect.Bottom;
      MCanvas.Pen.Color := Display.DownColor;
      for tmpIndex := 0 to _IconButton.Rect.Height do
      begin
        tmpCount := tmpIndex div 2;
        MCanvas.MoveTo(tmpX - tmpCount, tmpY - tmpIndex);
        MCanvas.LineTo(tmpX + tmpCount, tmpY - tmpIndex);
      end;
    end;
  end;
end;

function TQuoteTransaction.GetVisible: Boolean;
begin
  Result := FTimeGraphs.Display.TradePointVisible;
end;

procedure TQuoteTransaction.CleanHash;
var
  tmpABData: TABData;
  tmpEnum: TDictionary<Integer, TABData>.TPairEnumerator;
begin
  if Assigned(FTradeHash) then
  begin
    tmpEnum := FTradeHash.GetEnumerator;
    while tmpEnum.MoveNext do
    begin
      tmpABData := FTradeHash[tmpEnum.Current.Key];
      if Assigned(tmpABData) then
        tmpABData.Free;
    end;
    FTradeHash.Clear;
  end;
end;

procedure TQuoteTransaction.ClearData;
begin
  CleanList(FDatas);
  CleanHash;
end;

procedure TQuoteTransaction.CalcData(_DataSet: IWNDataSet);
const
  Const_Format = '0.00';
  Const_Log_Out_TransactionPoint = '[ TransactionPoint ] ';
var
  tmpKey: Integer;
  tmpABData: TABData;
  tmpData: TTradeData;
  tmpDirection: Integer;
  tmpDateTime: TDateTime;
  tmpIconButton: TIconButton;
  tmpFormat, tmpTradeDate, tmpDate: string;
  tmpVolume, tmpAvgPrice, tmpMoney, tmpVolumeScalc: Double;

  function IntToMinuteCount(_Int: Integer): Integer;
  begin
    Result := _Int div 100 * 60 + _Int mod 100;
  end;

  function VolumeToValue(_Volume: Double): string;
  begin
    _Volume := tmpVolumeScalc * _Volume;
    if (_Volume >= 10000) and (_Volume < 100000000) then
    begin
      tmpFormat := Const_Format + '万手';
      _Volume := _Volume / 10000;
    end
    else if _Volume >= 100000000 then
    begin
      tmpFormat := Const_Format + '亿手';
      _Volume := _Volume / 100000000;
    end
    else
      tmpFormat := Const_Format;
    Result := FormatFloat(tmpFormat, _Volume);
  end;

  function PriceToValue(_Money: Double): string;
  begin
    if (_Money >= 10000) and (_Money < 100000000) then
    begin
      tmpFormat := Const_Format + '万元';
      _Money := _Money / 10000;
    end
    else if _Money >= 100000000 then
    begin
      tmpFormat := Const_Format + '亿元';
      _Money := _Money / 100000000;
    end
    else
      tmpFormat := Const_Format;
    Result := FormatFloat(tmpFormat, _Money);
  end;

  function FieldByName(_Name: string): string;
  begin
    try
      Result := _DataSet.FieldByName(_Name).AsString
    except
      on Ex: Exception do
      begin
//        if Assigned(FTimeGraphs.GilAppController) and
//          Assigned(FTimeGraphs.GilAppController.GetLogWriter) then
//        begin
//          FTimeGraphs.GilAppController.GetLogWriter.Log(llError,
//            Const_Log_Out_TransactionPoint + ' 分时成交打点字段报错 ' + _Name);
//        end;
        FAppContext.SysLog(llError, Const_Log_Out_TransactionPoint + ' 分时成交打点字段报错 ' + _Name);
      end;
    end;
  end;

  function FieldByNameEx(_Name: string): TDateTime;
  begin
    try
      Result := StrToDateTimeDef(_DataSet.FieldByName(_Name).AsString, 0);
    except
      on Ex: Exception do
      begin
//        if Assigned(FTimeGraphs.GilAppController) and
//          Assigned(FTimeGraphs.GilAppController.GetLogWriter) then
//        begin
//          FTimeGraphs.GilAppController.GetLogWriter.Log(llError,
//            Const_Log_Out_TransactionPoint + ' 分时成交打点字段报错 ' + _Name);
//        end;
        FAppContext.SysLog(llError, Const_Log_Out_TransactionPoint + ' 分时成交打点字段报错 ' + _Name);
      end;
    end;
  end;

  function ValueToDirection(_Value: string): Integer;
  begin
    // 期货业务 委托方向
    // V – 买入开仓
    // W – 卖出平仓
    // X – 卖出开仓
    // Y – 买入平仓

    // 交易所业务 委托方向
    // 股票、基金、权证等证券
    // 1 – 买入
    // 2 – 卖出
    // 债券
    // 3 – 债券买入
    // 4 – 债券卖出
    // r-债券认购
    // 新股申购
    // C – 申购
    // 质押
    // T – 提交质押
    // U – 转回质押
    // 回购
    // 5 – 融资回购
    // 6 – 融券回购
    if (_Value = 'V') or (_Value = 'Y') then
    begin
      Result := 1;
    end
    else if (_Value = 'W') or (_Value = 'X') then
    begin
      Result := 2;
    end
    else
    begin
      Result := StrToIntDef(_Value, 0);
      case Result of
        1, 2:
          ;
        3:
          Result := 1;
        4:
          Result := 2;
      else
        Result := 1;
      end;
    end
  end;

begin
  if Assigned(_DataSet) and (_DataSet.RecordCount > 0) then
  begin
    if Assigned(FTimeGraphs.QuoteTimeData.MainData) then
    begin
      tmpVolumeScalc := FTimeGraphs.QuoteTimeData.MainData.VolumeScalc;
      FTimeGraphs.QuoteTimeData.MainData.GetTradeDate(tmpDateTime);
      tmpTradeDate := FormatDateTime('YYYYMMDD', tmpDateTime);
      _DataSet.First;
      while not _DataSet.Eof do
      begin
        // tmpKey := IntToMinuteCount(StrToIntDef(FieldByName('deal_time'), 0));
        // tmpDirection := StrToIntDef(FieldByName('entrust_direction'), 0);
        // tmpVolume := StrToFloatDef(FieldByName('deal_amount'), 0);
        // tmpMoney := StrToFloatDef(FieldByName('deal_balance'), 0);
        // tmpAvgPrice := StrToFloatDef(FieldByName('deal_price'), 0);
        //
        // tmpData := TTradeData.Create;
        // tmpData.FundName := FieldByName('account_name');
        // tmpData.Direction := tmpDirection;
        // tmpData.Volume := VolumeToValue(tmpVolume);
        // tmpData.Money := PriceToValue(tmpMoney);
        // tmpData.AvgPrice := PriceToValue(tmpAvgPrice);

        tmpDateTime := FieldByNameEx('dateTime');
        if tmpDateTime <> 0 then
        begin
          tmpDate := FormatDateTime('YYYYMMDD', tmpDateTime);
          if tmpDate = tmpTradeDate then
          begin
            tmpKey := IntToMinuteCount
              (StrToIntDef(FormatDateTime('hhnn', tmpDateTime), 0));
            tmpDirection := ValueToDirection(FieldByName('dealDirection'));
            tmpVolume := StrToFloatDef(FieldByName('dealVolume'), 0);
            tmpMoney := StrToFloatDef(FieldByName('dealPrice'), 0);
            tmpAvgPrice := StrToFloatDef(FieldByName('dealAvePrice'), 0);

            tmpData := TTradeData.Create;
            tmpData.FundName := FieldByName('fundName');
            tmpData.Direction := tmpDirection;
            tmpData.Volume := VolumeToValue(tmpVolume);
            tmpData.Money := PriceToValue(tmpMoney);
            tmpData.AvgPrice := PriceToValue(tmpAvgPrice);

            if not FTradeHash.TryGetValue(tmpKey, tmpABData) then
            begin
              tmpABData := TABData.Create;
              tmpIconButton := TIconButton.Create;
              tmpIconButton.Time := tmpKey;
              tmpABData.Date := FormatDateTime('hh:nn', tmpDateTime);
              tmpABData.ObjectRef := tmpIconButton;
              FDatas.Add(tmpIconButton);
              FTradeHash.Add(tmpKey, tmpABData);
            end;
            tmpABData.Datas.Add(tmpData);

            if tmpDirection = Const_Direction_Buy then
              tmpABData.Money := tmpABData.Money + tmpMoney
            else if tmpDirection = Const_Direction_Sell then
              tmpABData.Money := tmpABData.Money - tmpMoney;
            if Assigned(tmpABData.ObjectRef) then
            begin
              if tmpABData.Money >= 0 then
                TIconButton(tmpABData.ObjectRef).DirectionType := dtBuy
              else
                TIconButton(tmpABData.ObjectRef).DirectionType := dtSell;
            end;
          end;
        end;
        _DataSet.Next;
      end;
    end;
  end;
end;

procedure TQuoteTransaction.DataArrive(_DataSet: IWNDataSet);
begin
  ClearData;
  CalcData(_DataSet);
end;

function TQuoteTransaction.MouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint): Boolean;
var
  tmpPt: TPoint;
  tmpRect: TRect;
  tmpIndex: Integer;
  tmpIconButton: TIconButton;
  tmpABData: TABData;
begin
  Result := False;
  for tmpIndex := 0 to FDatas.Count - 1 do
  begin
    tmpIconButton := IconButtons[tmpIndex];
    if Assigned(tmpIconButton) and PtInRect(tmpIconButton.Rect, _Pt) then
    begin
      Result := true;
      if (not FTradeDetail.Visible) then
      begin
        FTradeHash.TryGetValue(tmpIconButton.Time, tmpABData);
        tmpPt := FTimeGraphs.G32Graphic.Control.ClientToScreen
          (tmpIconButton.Rect.BottomRight);
        FTradeDetail.UpdateShow(tmpABData, tmpPt);
      end;
      Break;
    end;
  end;
  if Assigned(FTradeDetail) and FTradeDetail.Visible then
  begin
    tmpPt := Mouse.CursorPos;
    tmpRect := FTradeDetail.GetMouseMoveRect;
    if not PtInRect(tmpRect, tmpPt) then
      FTradeDetail.Hide;
  end;
end;

function TQuoteTransaction.MouseUpOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint): Boolean;
begin
  Result := False;
end;

procedure TQuoteTransaction.MouseLeave;
var
  tmpPt: TPoint;
begin
  tmpPt := Mouse.CursorPos;
  if not PtInRect(FTradeDetail.GetMouseMoveRect, tmpPt) and
    Assigned(FTradeDetail) and FTradeDetail.Showing then
    FTradeDetail.Hide;
end;

procedure TQuoteTransaction.UpdateSkin;
begin
  if Assigned(FTradeDetail) then
    FTradeDetail.UpdateSkin;
end;

{ TQuoteTitleButtons }

constructor TQuoteTitleButtons.Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited;
  FDrawPng := TPngImage.Create;
  FHint := THintControl.Create(nil);
end;

destructor TQuoteTitleButtons.Destroy;
begin
  if Assigned(FHint) then
    FHint.Free;
  if Assigned(FDrawPng) then
    FDrawPng.Free;
  inherited;
end;

procedure TQuoteTitleButtons.InitData;
var
  tmpButton: TTitleButton;
begin
  inherited;
  tmpButton := TTitleButton.Create;
  tmpButton.Hint := '缩小';
  tmpButton.ResName := 'Time_Narrow';
  tmpButton.HotResName := 'Time_NarrowHot';
  tmpButton.OnClick := DoClickNarraw;
  FDatas.Add(tmpButton);

  tmpButton := TTitleButton.Create;
  tmpButton.Hint := '放大';
  tmpButton.ResName := 'Time_Enlarge';
  tmpButton.HotResName := 'Time_EnlargeHot';
  tmpButton.OnClick := DoClickEnlarge;
  FDatas.Add(tmpButton);
end;

procedure TQuoteTitleButtons.UpdataRect;
var
  tmpRect: TRect;
  tmpIndex, tmpSize: Integer;
  tmpButton: TTitleButton;
  tmpGraph: TQuoteTimeGraph;
begin
  with FTimeGraphs do
  begin
    tmpGraph := GraphsHash[const_minutekey];
    if Assigned(tmpGraph) then
    begin
      tmpSize := 14;
      tmpRect := tmpGraph.TitleRect;
      tmpRect.Right := tmpRect.Right - Display.TitleIconSpace;
      tmpRect.Top := (tmpRect.Top + tmpRect.Bottom - tmpSize) div 2;
      tmpRect.Bottom := tmpRect.Top + tmpSize;
      for tmpIndex := 0 to FDatas.Count - 1 do
      begin
        tmpButton := TTitleButton(FDatas.Items[tmpIndex]);
        if Assigned(tmpButton) then
        begin
          tmpRect.Left := tmpRect.Right - tmpSize;
          tmpButton.Rect := tmpRect;
          tmpRect.Right := tmpRect.Left - Display.TitleIconSpace;
        end;
      end;
    end;
  end;
end;

procedure TQuoteTitleButtons.DrawIcons;
var
  tmpIndex: Integer;
  tmpButton: TTitleButton;
begin
  for tmpIndex := 0 to FDatas.Count - 1 do
  begin
    tmpButton := TTitleButton(FDatas.Items[tmpIndex]);
    if Assigned(tmpButton) then
    begin
      if not tmpButton.Focused then
        DrawButton(FTimeGraphs.MCanvas, tmpButton, tmpButton.ResName)
      else
        DrawButton(FTimeGraphs.MCanvas, tmpButton, tmpButton.HotResName);
    end;
  end;
end;

procedure TQuoteTitleButtons.DoClickEnlarge(Sender: TObject);
begin
  FTimeGraphs.Enlarge;
end;

procedure TQuoteTitleButtons.DoClickNarraw(Sender: TObject);
begin
  FTimeGraphs.Narrow;
end;

function TQuoteTitleButtons.CalcButton(_Pt: TPoint;
  var _Button: TTitleButton): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  for tmpIndex := 0 to FDatas.Count - 1 do
  begin
    _Button := TTitleButton(FDatas.Items[tmpIndex]);
    if Assigned(_Button) and PtInRect(_Button.Rect, _Pt) then
    begin
      Result := true;
      Break;
    end;
  end;
end;

procedure TQuoteTitleButtons.DrawButton(_Canvas: TCanvas; _Button: TTitleButton;
  _ResName: string);
begin
//  if FTimeGraphs. <> nil then
//  begin
    FDrawPng.LoadFromResourceName(FAppContext.GetResourceSkin.GetInstance,// .GilAppController.GetSkinInstance,
      _ResName);
    _Canvas.Brush.Color := FTimeGraphs.Display.TitleBackColor;
    _Canvas.FillRect(_Button.Rect);
    _Canvas.Draw(_Button.Rect.Left, _Button.Rect.Top, FDrawPng);
//  end;
end;

procedure TQuoteTitleButtons.MouseLeave;
begin
  FHint.HideHint;
end;

function TQuoteTitleButtons.MouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint): Boolean;
var
  tmpPt: TPoint;
  tmpButton: TTitleButton;
begin
  Result := False;
  if CalcButton(_Pt, tmpButton) then
  begin
    if not tmpButton.Focused then
    begin
      if Assigned(FLastFocusButton) and FLastFocusButton.Focused then
      begin
        DrawButton(FTimeGraphs.MCanvas, tmpButton, tmpButton.ResName);
        FTimeGraphs.EraseRect(FLastFocusButton.Rect);
        FLastFocusButton.Focused := False;
      end;
      DrawButton(FTimeGraphs.Canvas, tmpButton, tmpButton.HotResName);
      FLastFocusButton := tmpButton;
      tmpButton.Focused := true;
    end;
    tmpPt := FTimeGraphs.G32Graphic.Control.ClientToScreen
      (Point(tmpButton.Rect.Right, tmpButton.Rect.Bottom + 15));
    FHint.ShowHint(tmpButton.Hint, tmpPt.X, tmpPt.Y);
  end
  else
  begin
    if Assigned(FLastFocusButton) and FLastFocusButton.Focused then
    begin
      DrawButton(FTimeGraphs.MCanvas, tmpButton, tmpButton.ResName);
      FTimeGraphs.EraseRect(FLastFocusButton.Rect);
      FLastFocusButton.Focused := False;
    end;
    FHint.HideHint;
  end;
end;

function TQuoteTitleButtons.MouseUpOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint): Boolean;
var
  tmpButton: TTitleButton;
begin
  Result := False;
  if (Button = mbLeft) and CalcButton(_Pt, tmpButton) then
  begin
    Result := true;
    if Assigned(tmpButton.OnClick) then
      tmpButton.OnClick(tmpButton);
  end;
end;

end.
