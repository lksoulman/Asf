unit QuoteTimeMovePt;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  ExtCtrls,
  Vcl.Imaging.pngimage,
  Generics.Collections,
  AppContext,
  QuoteCommLibrary,
  G32Graphic,
  QuoteTimeStruct,
  QuoteTimeGraph,
  QuoteTimeData;

const
  Const_ResourceName_MovePt: array [-1 .. 3] of string = ('Time_GreenPt',
    'Time_FlatPt', 'Time_RedPt', 'Time_NowPricePt', 'Time_AveragePricePt');
  Const_LinePtSize = 10;
  Const_ArrivePtSize = 6;

  // 输出日志前缀
  Const_Log_Output_Time_MovePt_Prefix = ' [Time_MovePt] ';

type

  TEraseAfterOperateEvent = procedure of object;

  TMovePointType = (mptNowPricePt, mptAveragePricePt, mptArriveDataPt);

  TQuoteTimeMovePt = class
  private
    FTimeGraphs: TQuoteTimeGraphs;
    FOperateEvents: TList<TEraseAfterOperateEvent>;
    FTimer: TTimer;

    FMovePointType: TMovePointType;
    FDrawPng: TPngImage;
    FResourceName: string;
    FIsDrawPt: Boolean;
    FDrawRect: TRect;
    FLastPoint_X: Integer;
    FOffsetSize: Integer;

    procedure DoTimer(Sender: TObject);
    function RefreshPng(_ResourceName: string): Boolean;
    function CalcRect(var _X: Integer; var _Rect: TRect): Boolean;
    function CalcArriveDataRect(var _Rect: TRect;
      var _ResourceNameIndex: Integer): Boolean;
    procedure DrawMovePt(_Canvas: TCanvas; _Rect: TRect); overload;
  public
    constructor Create(_MovePointType: TMovePointType;
      _TimeGraphs: TQuoteTimeGraphs);
    destructor Destroy; override;
    procedure AddEraseAfterOperate(_OperateEvent: TEraseAfterOperateEvent);

    procedure DrawMovePt(_Pt: TPoint); overload;
    procedure DrawArriveDataPt;
    procedure ReDrawMovePt;
    procedure EraseMovePt;
  end;

implementation

{ TQuoteTimeMovePt }

constructor TQuoteTimeMovePt.Create(_MovePointType: TMovePointType;
  _TimeGraphs: TQuoteTimeGraphs);
begin
  FMovePointType := _MovePointType;
  FTimeGraphs := _TimeGraphs;
  FDrawPng := TPngImage.Create;
  FIsDrawPt := False;
  FOffsetSize := Const_LinePtSize div 2;
  case FMovePointType of
    mptNowPricePt:
      FResourceName := Const_ResourceName_MovePt[2];
    mptAveragePricePt:
      FResourceName := Const_ResourceName_MovePt[3];
  else
    begin
      FTimer := TTimer.Create(nil);
      FTimer.Interval := 50;
      FTimer.Enabled := False;
      FTimer.OnTimer := DoTimer;
      FOperateEvents := TList<TEraseAfterOperateEvent>.Create;
      FOffsetSize := Const_ArrivePtSize div 2;
    end;
  end;
end;

destructor TQuoteTimeMovePt.Destroy;
begin
  if Assigned(FOperateEvents) then
  begin
    FOperateEvents.Clear;
    FOperateEvents.Free;
  end;
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FreeAndNil(FTimer);
  end;
  if Assigned(FDrawPng) then
    FDrawPng.Free;
  inherited;
end;

procedure TQuoteTimeMovePt.DoTimer(Sender: TObject);
begin
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    EraseMovePt;
  end;
end;

function TQuoteTimeMovePt.CalcRect(var _X: Integer; var _Rect: TRect): Boolean;
var
  tmpValue: Double;
  tmpData: TTimeData;
  tmpGraph: TQuoteTimeGraph;
  tmpDataIndex, tmpIndex, tmpCompareValue, tmpY: Integer;
begin
  Result := False;
  with FTimeGraphs do
  begin
    tmpDataIndex := 0;
    if XToIndex(_X, tmpDataIndex, tmpIndex) then
    begin
      tmpData := QuoteTimeData.DataIndexToData(tmpDataIndex);
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if (FMovePointType = mptAveragePricePt) and
          (tmpData.StockType = stIndex) and (tmpData.IsHisData) then
          Exit;
        if FMovePointType = mptNowPricePt then
          tmpData.GetValue(dkPrice, tmpIndex, tmpValue, tmpCompareValue)
        else if FMovePointType = mptAveragePricePt then
          tmpData.GetValue(dkAveragePrice, tmpIndex, tmpValue, tmpCompareValue);
        tmpGraph := GraphsHash[const_minutekey];
        if Assigned(tmpGraph) then
        begin
          tmpY := tmpGraph.ValueToY(tmpValue);
          _Rect := Rect(_X - FOffsetSize, tmpY - FOffsetSize,
            _X + FOffsetSize + 1, tmpY + FOffsetSize + 1);
          Result := True;
        end;
      end;
    end;
  end;
end;

function TQuoteTimeMovePt.CalcArriveDataRect(var _Rect: TRect;
  var _ResourceNameIndex: Integer): Boolean;
var
  tmpValue: Double;
  tmpData: TTimeData;
  tmpGraph: TQuoteTimeGraph;
  tmpDataIndex, tmpCompareValue, tmpX, tmpY: Integer;
begin
  Result := False;
  with FTimeGraphs do
  begin
    tmpDataIndex := 0;
    tmpData := QuoteTimeData.DataIndexToData(tmpDataIndex);
    if Assigned(tmpData) and (not tmpData.NullTimeData) and
      (tmpData.DataCount > 0) then
    begin
      tmpX := IndexToX(tmpDataIndex, tmpData.DataCount - 1);
      tmpData.GetValue(dkArrivePtCurrentPrice, tmpData.DataCount - 1, tmpValue,
        tmpCompareValue);
      tmpGraph := GraphsHash[const_minutekey];
      if Assigned(tmpGraph) then
      begin
        tmpY := tmpGraph.ValueToY(tmpValue);
        _Rect := Rect(tmpX - FOffsetSize, tmpY - FOffsetSize,
          tmpX + FOffsetSize + 1, tmpY + FOffsetSize + 1);
        _ResourceNameIndex := tmpCompareValue;
        Result := True;
      end;
    end;
  end;
end;

procedure TQuoteTimeMovePt.DrawMovePt(_Canvas: TCanvas; _Rect: TRect);
begin
  _Canvas.Draw(_Rect.Left, _Rect.Top, FDrawPng);
end;

procedure TQuoteTimeMovePt.DrawMovePt(_Pt: TPoint);
var
  tmpRect: TRect;
begin
  if CalcRect(_Pt.X, tmpRect) then
  begin
    FLastPoint_X := _Pt.X;
    EraseMovePt;
    FDrawRect := tmpRect;
    if RefreshPng(FResourceName) then
    begin
      DrawMovePt(FTimeGraphs.Canvas, FDrawRect);
      FIsDrawPt := True;
    end;
  end;
end;

procedure TQuoteTimeMovePt.DrawArriveDataPt;
var
  tmpRect: TRect;
  tmpResourceIndex: Integer;
begin
  if CalcArriveDataRect(tmpRect, tmpResourceIndex) then
  begin
    FDrawRect := tmpRect;
    if RefreshPng(Const_ResourceName_MovePt[tmpResourceIndex]) then
    begin
      DrawMovePt(FTimeGraphs.Canvas, FDrawRect);
      FIsDrawPt := True;
      if Assigned(FTimer) then
        FTimer.Enabled := True;
    end;
  end;
end;

procedure TQuoteTimeMovePt.AddEraseAfterOperate(_OperateEvent
  : TEraseAfterOperateEvent);
begin
  if Assigned(FOperateEvents) then
    FOperateEvents.Add(_OperateEvent);
end;

procedure TQuoteTimeMovePt.EraseMovePt;
var
  tmpIndex: Integer;
  tmpOperateEvent: TEraseAfterOperateEvent;
begin
  if FIsDrawPt then
  begin
    DrawCopyRect(FTimeGraphs.Canvas.Handle, FDrawRect,
      FTimeGraphs.MCanvas.Handle, FDrawRect);
    FIsDrawPt := False;
    if (FMovePointType = mptArriveDataPt) and Assigned(FOperateEvents) then
    begin
      for tmpIndex := 0 to FOperateEvents.Count - 1 do
      begin
        tmpOperateEvent := FOperateEvents.Items[tmpIndex];
        if Assigned(tmpOperateEvent) then
          tmpOperateEvent();
      end;
    end;
  end;
end;

procedure TQuoteTimeMovePt.ReDrawMovePt;
var
  tmpRect: TRect;
begin
  if FIsDrawPt then
  begin
    CalcRect(FLastPoint_X, tmpRect);
    FDrawRect := tmpRect;
    DrawMovePt(FTimeGraphs.Canvas, FDrawRect);
  end;
end;

function TQuoteTimeMovePt.RefreshPng(_ResourceName: string): Boolean;
begin
  Result := False;
//  if Assigned(FTimeGraphs.GilAppController) then
//  begin
//    try
//      FDrawPng.LoadFromResourceName
//        (FTimeGraphs.GilAppController.GetSkinInstance, _ResourceName);
//      Result := True;
//    except
//      on Ex: Exception do
//      begin
//        if Assigned(FTimeGraphs.GilAppController) and
//          Assigned(FTimeGraphs.GilAppController.GetLogWriter) then
//        begin
//          FTimeGraphs.GilAppController.GetLogWriter.Log(llError,
//            Const_Log_Output_Time_MovePt_Prefix + '没有资源' + _ResourceName);
//        end;
//      end;
//    end;
//  end;
end;

end.
