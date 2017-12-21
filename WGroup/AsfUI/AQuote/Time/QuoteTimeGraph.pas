unit QuoteTimeGraph;

interface

uses
  Windows,
  Classes,
  Graphics,
  SysUtils,
  Controls,
  Types,
  Math,
  G32Graphic,
  Generics.Collections,
  AppContext,
  WNDataSetInf,
  QuoteStruct,
  QuoteTimeStruct, QuoteCommLibrary, QuoteTimeDisplay, QuoteTimeButton,
  QuoteTimeData,
  BaseObject;

{
  Area of the control is divided into the following areas as follows:

  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                         CenterRect                            |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   |                                                               |   |
  |   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   |
  |   |                                                               |   |
  |   |                          XRulerRect                           |   |
  |   |                                                               |   |
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  The central area will be divided into a number of graph area;
  Each Graph Include the structure of a graphitem;
  Each Graph is structured as follows:

  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  |                                                 ↑     |           ↑
  |                                           titleHeight |           |
  |                                                 ↓     |           |
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -           |
  |                  |                                    |           |
  |                  |                                    |  GraphRect.Height
  |                  |                                    |           |
  | CallAuctionRect  |                                    |           |
  |                  |                                    |           |
  |                  |                                    |           |
  |                  |                                    |           ↓
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  |                  |                                    |
  |←CallAuctionWidth→|                                    |
  |                                                       |
  |← - - - - - - - - GraphRect.Width - - - - - - - - - - →|

}

const
  const_minutekey = 'minuteRect';
  const_volumekey = 'volumeRect';
  const_formulabuttons = 'const_formulabuttons';

  const_timeUnitValue = 30;

type
  TQuoteTimeGraphs = class;

  TGraphType = (gtMinute, gtFormula, gtButtons);

  PGraphItem = ^TGraphItem;

  { m_lPositon identifies a graph showing what position in the central area }
  TGraphItem = packed record
    m_lGraphRect: TRect;
    m_lCallAuctionWidth: Integer;
    m_lTitleHeight: Integer;
    m_lPositon: Integer;
    m_lUpBlank: Integer;
    m_lDownBlank: Integer;
  end;

  TQuoteTimeGraph = class(TBaseObject)
  protected
    FTimeGraphs: TQuoteTimeGraphs;
    FGraphKey: string;

    FGraphItem: TGraphItem;
    FMaxValue: Double;
    FMinValue: Double;
    FScaleY: Double;

    function GetLineCount(_Height: Integer): Integer;
    function GetTitleRect: TRect;
    function GetDrawGraphRect: TRect; virtual;

    procedure DrawYRulerLine(_DrawKey: string; _StartPos, _EndPos, _Y: Integer);
    procedure DrawYRulerScale(_DrawKey, _Value: string;
      _LeftPos, _RightPos, _Y: Integer; Align: TTextAlign); virtual;
    procedure DrawText(_Rect: TRect; _TitleItems: TTitleItems);

    procedure CalcData; virtual; abstract;
    procedure DrawYRuler; virtual; abstract;
    procedure DrawData; virtual; abstract;
    procedure DrawMine; virtual; abstract;
  public
    constructor Create(AContext: IAppContext);
    destructor Destroy; override;

    function YToValue(_Y: Double): Double; virtual; abstract;
    function ValueToY(_Value: Double): Integer; virtual; abstract;
    function YToYRulerHint(_Y: Integer; var _LHint, _RHint: string): Boolean;
      virtual; abstract;
    function IndexToRulerHint(_DataIndex, _Index: Integer;
      var _LHint, _RHint: string): Boolean; virtual; abstract;
    procedure DrawTitle(_DataIndex, _Index: Integer); virtual; abstract;

    procedure DrawTitleFrame; virtual;
    procedure Draw; virtual;

    procedure DataArrive(_DataSet: IWNDataSet; _DataTag: Integer); virtual;
    procedure ToolsMouseMoveOperate(Shift: TShiftState; _Pt: TPoint); virtual;
    procedure ToolsMouseDownOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint); virtual;
    procedure ToolsMouseUpOperate(Button: TMouseButton; Shift: TShiftState;
      _Pt: TPoint); virtual;
//    procedure ConnectQuoteManager(const GilAppController
//      : IGilAppController); virtual;
//    procedure DisConnectQuoteManager; virtual;
    procedure MouseLeave; virtual;
    procedure ClearData; virtual;
    procedure DoSendToBack; virtual;
    procedure UpdateSkin; virtual;

    property GraphItem: TGraphItem read FGraphItem;
    property LineCount[_Height: Integer]: Integer read GetLineCount;
    property TitleRect: TRect read GetTitleRect;
    property DrawGraphRect: TRect read GetDrawGraphRect;
    property GraphKey: string read FGraphKey write FGraphKey;
  end;

  TQuoteTimeGraphs = class(TBaseObject)
  private
//    FGilAppController: IGilAppController;
    FG32Graphic: TG32Graphic;
    FDisplay: TQuoteTimeDisplay;
    FQuoteTimeData: TQuoteTimeData;
    FCanvas: TCanvas;

    FGraphs: TList; // 保存所有的要展示的Graph （如分时线图形 成交量图 等，）支持扩充多个窗口
    // hash方式也保存一份 所有的要展示的Graph
    // 可以快速找到对应的Graph 和支持一些其他功能
    FGraphsHash: TDictionary<string, TQuoteTimeGraph>;
    FVolumeHideButton: TIconButton; // 成交量隐藏显示按钮
    FVolumeVisible: Boolean;
    FVolumeButtonFocused: Boolean;

    FCenterRect: TRect;
    FFormulaButtonRect: TRect;
    FYRulerWidth: Integer;
    FCallAuctionWidth: Integer;
    FXRulerMinWidth: Integer;

    function GetYRRulerRect: TRect;
    function GetYLRulerRect: TRect;
    function GetXRulerRect: TRect;

    function GetMCanvas: TCanvas;

    function GetGraphs(_Index: Integer): TQuoteTimeGraph;
    function GetGraphsHash(_Key: string): TQuoteTimeGraph;

    function GetGraphCount(_GraphType: TGraphType): Integer;
    function GetTextHeight: Integer;
    function GetCharWidth: Integer;
    function GetSingleDayWidth: Double;
    function GetMinuteWidth: Double;

    procedure FreeGraphs;
    procedure FreeGraphsHash;
    procedure AddGraphHash(_Key: string; _Graph: TQuoteTimeGraph);

    // 计算集合竞价的宽度
    procedure CalcAuctionWidth;
    // 计算矩形位置  和  一些固定变量的值的初始化
    procedure CalcRectData;
    // 计算 所有Graph对象的 FGraphItem 结构的值, FGraphItem是 每一个Graph对象的核心结构体
    procedure CalcGraphsData;

    procedure DrawStopFlag;
    procedure DrawXRuler;
    procedure DrawXRulerScale(_DrawKey, _Format: string; _DateTime: TDateTime;
      _Top, _Bottom, _Pos: Integer);
    procedure DrawSingleDayXRuler(_DataIndex, _StartPos, _EndPos: Integer;
      _CenterRect: TRect; _IsDrawDate: Boolean);
    procedure DrawTitleFrame;
    procedure DrawNullData;

    function InsertGraph(_Graph: TQuoteTimeGraph): Boolean;
    function DeleteGraph(_Key: string): Boolean;
  public
    constructor Create(AContext: IAppContext; _G32Graphic: TG32Graphic; _Canvas: TCanvas;
      _QuoteTimeData: TQuoteTimeData; _Display: TQuoteTimeDisplay);
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController);
//    procedure DisConnectQuoteManager;

    procedure AddGraph(_Key: string; _Graph: TQuoteTimeGraph);
    procedure VolumeGraphVisible(_Visible: Boolean);
    procedure DrawVolumeButton;
    procedure EraseRect(_Rect: TRect);

    procedure CalcFrame;
    procedure DrawFrame;
    procedure DrawData;

    function XToIndex(_X: Integer; var _DataIndex: Integer; var _Index: Integer): Boolean;
    function XToIndexEx(_X: Integer; var _DataIndex: Integer; var _Index: Integer): Boolean;
    function IndexToX(_DataIndex, _Index: Integer): Integer;
    function XToXRulerHint(_X: Integer): string; overload;
    function XToXRulerHint(_DataIndex, _Index: Integer): string; overload;
    function YToYRulerHint(_Y: Integer; _Graph: TQuoteTimeGraph;
      var _LHint, _RHint: string): Boolean;
    function PtInGraphs(_Pt: TPoint; var _Graph: TQuoteTimeGraph): Boolean;
    function GetCrossMoveMaxX: Integer;
    function HisDataIsNull: Boolean; // 历史某天数据是不是空
    procedure Enlarge;
    procedure Narrow;
    procedure MouseLeave;
    procedure UpdateSkin;

    property Graphs[_Index: Integer]: TQuoteTimeGraph read GetGraphs;
    property GraphsHash[_Key: string]: TQuoteTimeGraph read GetGraphsHash;
    property VolumeHideButton: TIconButton read FVolumeHideButton;
    property VolumeButtonFocused: Boolean read FVolumeButtonFocused
      write FVolumeButtonFocused;
    property VolumeVisible: Boolean read FVolumeVisible write FVolumeVisible;
    property CenterRect: TRect read FCenterRect;
    property FormulaButtonRect: TRect read FFormulaButtonRect;
    property YRRulerRect: TRect read GetYRRulerRect;
    property YLRulerRect: TRect read GetYLRulerRect;
    property XRulerRect: TRect read GetXRulerRect;
    property YRulerWidth: Integer read FYRulerWidth;
    property TextHeight: Integer read GetTextHeight;
    property CharWidth: Integer read GetCharWidth;
    property SingleDayWidth: Double read GetSingleDayWidth;
    property MinuteWidth: Double read GetMinuteWidth;
    property GraphCount[_GraphType: TGraphType]: Integer read GetGraphCount;

    property AppContext: IAppContext read FAppContext;
//    property GilAppController: IGilAppController read FGilAppController;
    property G32Graphic: TG32Graphic read FG32Graphic;
    property Display: TQuoteTimeDisplay read FDisplay;
    property QuoteTimeData: TQuoteTimeData read FQuoteTimeData;
    property Canvas: TCanvas read FCanvas;
    property MCanvas: TCanvas read GetMCanvas;
  end;

function GetPositon(_GraphType: TGraphType): Integer;

function GetGraphType(_Value: Integer): TGraphType;

implementation

function GetPositon(_GraphType: TGraphType): Integer;
begin
  case _GraphType of
    gtMinute:
      Result := 1;
    gtFormula:
      Result := 2;
    gtButtons:
      Result := 3;
  else
    Result := 3;
  end;
end;

function GetGraphType(_Value: Integer): TGraphType;
begin
  case _Value of
    1:
      Result := gtMinute;
    2:
      Result := gtFormula;
    3:
      Result := gtButtons;
  else
    Result := gtButtons;
  end;
end;

{ TQuoteTimeGraph }

constructor TQuoteTimeGraph.Create(AContext: IAppContext);
begin
  inherited;
  FGraphKey := '';
end;

destructor TQuoteTimeGraph.Destroy;
begin

  inherited;
end;

procedure TQuoteTimeGraph.DataArrive(_DataSet: IWNDataSet; _DataTag: Integer);
begin

end;


//
//procedure TQuoteTimeGraph.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//begin
//
//end;
//
//procedure TQuoteTimeGraph.DisConnectQuoteManager;
//begin
//
//end;

procedure TQuoteTimeGraph.Draw;
begin
  CalcData;

  DrawYRuler;
  DrawData;
  if FTimeGraphs.Display.ShowMode = smNormal then
    DrawMine;
end;

procedure TQuoteTimeGraph.DrawText(_Rect: TRect; _TitleItems: TTitleItems);
var
  tmpIndex: Integer;
  tmpRect: TRect;
  tmpFontStyles: TFontStyles;
  tmpFontHeight: Integer;
begin
  with FTimeGraphs do
  begin
    tmpRect := _Rect;
    G32Graphic.GraphicReset;
    tmpFontStyles := FDisplay.TextFont.Style;
    tmpFontHeight := FDisplay.TextFont.Height;
    for tmpIndex := Low(_TitleItems) to High(_TitleItems) do
    begin
      G32Graphic.EmptyPolyText('DrawTitle');

      FDisplay.TextFont.Style := _TitleItems[tmpIndex].m_lFontStyles;
      FDisplay.TextFont.Height := _TitleItems[tmpIndex].m_lHeight;
      G32Graphic.UpdateFont(FDisplay.TextFont);

      if _TitleItems[tmpIndex].m_lIsNeedSpace then
        tmpRect.Left := tmpRect.Left + Display.TitleTextSpace;
      tmpRect.Right := tmpRect.Left + G32Graphic.TextWidth
        (_TitleItems[tmpIndex].m_lText);

      G32Graphic.AddPolyText('DrawTitle', tmpRect,
        _TitleItems[tmpIndex].m_lText, gtaLeft);

      G32Graphic.LineColor := _TitleItems[tmpIndex].m_lColor;
      G32Graphic.DrawPolyText('DrawTitle');
      tmpRect.Left := tmpRect.Right;
    end;
    FDisplay.TextFont.Style := tmpFontStyles;
    FDisplay.TextFont.Height := tmpFontHeight;
    G32Graphic.UpdateFont(FDisplay.TextFont);
    DrawCopyRect(Canvas.Handle, _Rect, MCanvas.Handle, tmpRect);
  end;
end;

procedure TQuoteTimeGraph.DrawTitleFrame;
begin

end;

function TQuoteTimeGraph.GetTitleRect: TRect;
var
  tmpBorderLine: Integer;
begin
  with FTimeGraphs do
  begin
    tmpBorderLine := 0;
    Result := FGraphItem.m_lGraphRect;
    Result.Top := Result.Top + tmpBorderLine;
    Result.Bottom := Result.Top + FGraphItem.m_lTitleHeight;
    Result.Left := Result.Left - YRulerWidth + tmpBorderLine;
    if FDisplay.ShowMode <> smMulitStock then
      Result.Right := Result.Right + YRulerWidth - tmpBorderLine
    else
      Result.Right := Result.Right - tmpBorderLine;
  end;
end;

function TQuoteTimeGraph.GetDrawGraphRect: TRect;
begin
  Result := FGraphItem.m_lGraphRect;
  Result.Top := Result.Top + FGraphItem.m_lTitleHeight + FGraphItem.m_lUpBlank;
  Result.Bottom := Result.Bottom - FGraphItem.m_lDownBlank;
end;

function TQuoteTimeGraph.GetLineCount(_Height: Integer): Integer;
begin
  with FTimeGraphs do
  begin
    Result := 1;
    while ((_Height div (Result + 1)) > Display.GirdLineDistanceHeight) do
      Inc(Result);
  end;
end;

procedure TQuoteTimeGraph.DrawYRulerLine(_DrawKey: string;
  _StartPos, _EndPos, _Y: Integer);
begin
  with FTimeGraphs do
    G32Graphic.AddPolyPoly(_DrawKey, [Point(_StartPos, _Y),
      Point(_EndPos, _Y)]);
end;

procedure TQuoteTimeGraph.DrawYRulerScale(_DrawKey, _Value: string;
  _LeftPos, _RightPos, _Y: Integer; Align: TTextAlign);
var
  tmpHeight: Integer;
begin
  with FTimeGraphs do
  begin
    tmpHeight := Trunc(TextHeight / 2);
    G32Graphic.AddPolyText(_DrawKey, Rect(_LeftPos, _Y - tmpHeight, _RightPos,
      _Y + tmpHeight), _Value, Align);
  end;
end;

procedure TQuoteTimeGraph.ToolsMouseDownOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint);
begin

end;

procedure TQuoteTimeGraph.ToolsMouseMoveOperate(Shift: TShiftState;
  _Pt: TPoint);
begin

end;

procedure TQuoteTimeGraph.ToolsMouseUpOperate(Button: TMouseButton;
  Shift: TShiftState; _Pt: TPoint);
begin

end;

procedure TQuoteTimeGraph.UpdateSkin;
begin

end;

procedure TQuoteTimeGraph.MouseLeave;
begin

end;

procedure TQuoteTimeGraph.ClearData;
begin

end;

procedure TQuoteTimeGraph.DoSendToBack;
begin

end;

{ TQuoteTimeGraphs }

constructor TQuoteTimeGraphs.Create(AContext: IAppContext; _G32Graphic: TG32Graphic; _Canvas: TCanvas;
  _QuoteTimeData: TQuoteTimeData; _Display: TQuoteTimeDisplay);
begin
  inherited Create(AContext);
  FGraphs := TList.Create;
  FGraphsHash := TDictionary<string, TQuoteTimeGraph>.Create;
  FVolumeHideButton := TIconButton.Create;
  FG32Graphic := _G32Graphic;
  FCanvas := _Canvas;
  FQuoteTimeData := _QuoteTimeData;
  FDisplay := _Display;
  FG32Graphic.GraphicReset;
  FG32Graphic.UpdateFont(FDisplay.TextFont);
  FCallAuctionWidth := 0;
  FXRulerMinWidth := 0;
  FYRulerWidth := 0;
  FVolumeVisible := True;
  FVolumeButtonFocused := False;
end;

destructor TQuoteTimeGraphs.Destroy;
begin
  if Assigned(FVolumeHideButton) then
    FVolumeHideButton.Free;
  FreeGraphsHash;
  FreeGraphs;
  inherited;
end;

//procedure TQuoteTimeGraphs.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//var
//  tmpGraph: TQuoteTimeGraph;
//begin
//  FGilAppController := GilAppController;
//  tmpGraph := FGraphsHash[const_minutekey];
//  if Assigned(tmpGraph) then
//    tmpGraph.ConnectQuoteManager(FGilAppController);
//end;
//
//procedure TQuoteTimeGraphs.DisConnectQuoteManager;
//var
//  tmpGraph: TQuoteTimeGraph;
//begin
//  tmpGraph := FGraphsHash[const_minutekey];
//  if Assigned(tmpGraph) then
//    tmpGraph.DisConnectQuoteManager;
//  FGilAppController := nil;
//end;

procedure TQuoteTimeGraphs.AddGraph(_Key: string; _Graph: TQuoteTimeGraph);
var
  tmpIndex: Integer;
  tmpIsInsert: Boolean;
begin
  tmpIsInsert := False;
  _Graph.GraphKey := _Key;
  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    if Graphs[tmpIndex].GraphItem.m_lPositon > _Graph.GraphItem.m_lPositon then
    begin
      FGraphs.Insert(tmpIndex, _Graph);
      tmpIsInsert := True;
      Break;
    end;
  end;

  if not tmpIsInsert then
    FGraphs.Add(_Graph);

  AddGraphHash(_Key, _Graph);
end;

procedure TQuoteTimeGraphs.AddGraphHash(_Key: string; _Graph: TQuoteTimeGraph);
var
  tmpGraph: TQuoteTimeGraph;
begin
  if not FGraphsHash.TryGetValue(_Key, tmpGraph) then
    FGraphsHash.Add(_Key, _Graph);
end;

function TQuoteTimeGraphs.InsertGraph(_Graph: TQuoteTimeGraph): Boolean;
var
  tmpIndex: Integer;
  tmpIsInsert: Boolean;
begin
  Result := False;
  tmpIsInsert := False;
  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    if Graphs[tmpIndex].GraphKey = _Graph.GraphKey then
      Exit;
    if Graphs[tmpIndex].GraphItem.m_lPositon > _Graph.GraphItem.m_lPositon then
    begin
      FGraphs.Insert(tmpIndex, _Graph);
      Result := True;
      tmpIsInsert := True;
      Break;
    end;
  end;

  if not tmpIsInsert then
  begin
    FGraphs.Add(_Graph);
    Result := True;
  end;
end;

procedure TQuoteTimeGraphs.MouseLeave;
var
  tmpGraph: TQuoteTimeGraph;
  tmpGraphEnum: TDictionary<string, TQuoteTimeGraph>.TPairEnumerator;
begin
  if FGraphsHash <> nil then
  begin
    tmpGraphEnum := FGraphsHash.GetEnumerator;
    try
      while tmpGraphEnum.MoveNext do
      begin
        tmpGraph := FGraphsHash[tmpGraphEnum.Current.Key];
        if Assigned(tmpGraph) then
          tmpGraph.MouseLeave;
      end;
    finally
      FreeAndNil(tmpGraphEnum);
    end;
  end;
end;

function TQuoteTimeGraphs.DeleteGraph(_Key: string): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;
  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    if Graphs[tmpIndex].GraphKey = _Key then
    begin
      FGraphs.Delete(tmpIndex);
      Result := True;
      Break;
    end;
  end;
end;

procedure TQuoteTimeGraphs.FreeGraphs;
begin
  if FGraphs <> nil then
  begin
    FGraphs.Clear;
    FreeAndNil(FGraphs);
  end;
end;

procedure TQuoteTimeGraphs.FreeGraphsHash;
var
  tmpGraph: TQuoteTimeGraph;
  tmpGraphEnum: TDictionary<string, TQuoteTimeGraph>.TPairEnumerator;
begin
  if FGraphsHash <> nil then
  begin
    tmpGraphEnum := FGraphsHash.GetEnumerator;
    try
      while tmpGraphEnum.MoveNext do
      begin
        tmpGraph := FGraphsHash[tmpGraphEnum.Current.Key];
        if Assigned(tmpGraph) then
          tmpGraph.Free;
      end;
    finally
      FreeAndNil(tmpGraphEnum);
    end;
    FGraphsHash.Clear;
    FreeAndNil(FGraphsHash);
  end;
end;

function TQuoteTimeGraphs.GetGraphCount(_GraphType: TGraphType): Integer;
var
  tmpIndex: Integer;
begin
  Result := 0;
  for tmpIndex := 0 to FGraphs.Count - 1 do
    if GetGraphType(Graphs[tmpIndex].GraphItem.m_lPositon) = _GraphType then
      Inc(Result);
end;

function TQuoteTimeGraphs.GetGraphs(_Index: Integer): TQuoteTimeGraph;
begin
  Result := nil;
  if (_Index >= 0) and (_Index < FGraphs.Count) then
    Result := TQuoteTimeGraph(FGraphs.Items[_Index]);
end;

function TQuoteTimeGraphs.GetGraphsHash(_Key: string): TQuoteTimeGraph;
begin
  FGraphsHash.TryGetValue(_Key, Result);
end;

function TQuoteTimeGraphs.GetTextHeight: Integer;
begin
  Result := FG32Graphic.TextHeight('A');
end;

function TQuoteTimeGraphs.GetXRulerRect: TRect;
begin
  Result := Rect(FCenterRect.Left, FCenterRect.Bottom, FCenterRect.Right,
    FCenterRect.Bottom + TextHeight);
end;

function TQuoteTimeGraphs.GetYLRulerRect: TRect;
begin
  Result := Rect(FCenterRect.Left - FYRulerWidth, FCenterRect.Top + TextHeight,
    FCenterRect.Left, FCenterRect.Bottom);
end;

function TQuoteTimeGraphs.GetYRRulerRect: TRect;
begin
  Result := Rect(FCenterRect.Right, FCenterRect.Top + TextHeight,
    FCenterRect.Right + FYRulerWidth, FCenterRect.Bottom);
end;

function TQuoteTimeGraphs.HisDataIsNull: Boolean;
begin
  Result := False;
  if Assigned(FQuoteTimeData.MainData) and FQuoteTimeData.MainData.IsHisData and
    (FQuoteTimeData.MainData.PrevClose = 0) then
    Result := True;
end;

function TQuoteTimeGraphs.GetCharWidth: Integer;
begin
  Result := FG32Graphic.TextWidth('A');
end;

function TQuoteTimeGraphs.GetSingleDayWidth: Double;
begin
  Result := (FCenterRect.Width - FCallAuctionWidth) /
    (FQuoteTimeData.MainDatasCount);
end;

function TQuoteTimeGraphs.GetMinuteWidth: Double;
var
  tmpMinuteCount: Integer;
begin
  Result := 0;
  tmpMinuteCount := FQuoteTimeData.MainData.MinuteCount;
  if tmpMinuteCount > 0 then
    Result := SingleDayWidth / tmpMinuteCount;
end;

function TQuoteTimeGraphs.GetMCanvas: TCanvas;
begin
  Result := FG32Graphic.Bitmap32.Canvas;
end;

procedure TQuoteTimeGraphs.CalcAuctionWidth;
var
  tmpCount, tmpAuctionCount: Integer;
begin
  FCallAuctionWidth := 0;
  if FDisplay.AuctionVisible and (FQuoteTimeData.MainData <> nil) and
    (FDisplay.ShowMode = smNormal) then
  begin
    if FQuoteTimeData.MainData.IsHasAuction and
      (FQuoteTimeData.MainDatasCount = 1) then
    begin
      tmpAuctionCount := FQuoteTimeData.MainData.AuctionMinuteCount;
      tmpCount := FQuoteTimeData.MainData.MinuteCount + tmpAuctionCount;
      FCallAuctionWidth := Trunc(FCenterRect.Width / tmpCount *
        tmpAuctionCount);
    end;
  end;
end;

procedure TQuoteTimeGraphs.CalcRectData;
var
  tmpWidth, tmpHeight: Integer;
begin
  tmpWidth := FG32Graphic.Control.Width;
  tmpHeight := FG32Graphic.Control.Height;
  FXRulerMinWidth := FDisplay.XAxisScaleIntervalCharCount * CharWidth;
  FYRulerWidth := FDisplay.YAxisCharCount * CharWidth;

  if FDisplay.ShowMode <> smMulitStock then
  begin
    FCenterRect := Rect(FYRulerWidth, 0, tmpWidth - FYRulerWidth,
      tmpHeight - TextHeight);

    FVolumeHideButton.Rect := Rect(FDisplay.XEdgeSpace,
      tmpHeight - FDisplay.YEdgeSpace - TextHeight,
      FYRulerWidth - 4 * FDisplay.XEdgeSpace, tmpHeight - FDisplay.YEdgeSpace);
  end
  else
    FCenterRect := Rect(FYRulerWidth, 0, tmpWidth - 5, tmpHeight - TextHeight);
end;

procedure TQuoteTimeGraphs.CalcGraphsData;
var
  tmpGraphRect: TRect;
  tmpGraphHeight: Double;
  tmpPGraphItem: PGraphItem;
  tmpIndex, tmpGraphCount, tmpTitleHeight, tmpMinuteTitleHeight: Integer;
begin
  tmpGraphRect := FCenterRect;
  tmpGraphCount := GetGraphCount(gtMinute) + GetGraphCount(gtFormula);
  tmpGraphHeight := tmpGraphRect.Height / (tmpGraphCount + 1);
  tmpTitleHeight := 0;
  if FDisplay.ShowMode = smSimple then
    tmpMinuteTitleHeight := 0
  else if FDisplay.ShowMode in [smMulitStock, smComplexScreen] then
    tmpMinuteTitleHeight := TextHeight + 5
  else
    tmpMinuteTitleHeight := TextHeight + 2;

  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    tmpPGraphItem := @Graphs[tmpIndex].GraphItem;
    if GetGraphType(tmpPGraphItem^.m_lPositon) = gtMinute then
    begin
      tmpGraphRect.Bottom := Trunc(tmpGraphRect.Top + tmpGraphHeight * 2);
      tmpPGraphItem^.m_lGraphRect := tmpGraphRect;
      tmpPGraphItem^.m_lCallAuctionWidth := FCallAuctionWidth;
      tmpPGraphItem^.m_lTitleHeight := tmpMinuteTitleHeight;
      tmpGraphRect.Top := tmpGraphRect.Bottom;
    end
    else if GetGraphType(tmpPGraphItem^.m_lPositon) = gtFormula then
    begin
      if tmpIndex < FGraphs.Count - 2 then
        tmpGraphRect.Bottom := Trunc(tmpGraphRect.Top + tmpGraphHeight)
      else
        tmpGraphRect.Bottom := FCenterRect.Bottom - 1;
      tmpPGraphItem^.m_lGraphRect := tmpGraphRect;
      tmpPGraphItem^.m_lCallAuctionWidth := FCallAuctionWidth;
      tmpPGraphItem^.m_lTitleHeight := tmpTitleHeight;
      tmpGraphRect.Top := tmpGraphRect.Bottom;
    end;
  end;
end;

procedure TQuoteTimeGraphs.CalcFrame;
begin
  FG32Graphic.UpdateFont(FDisplay.TextFont);
  CalcRectData;
  CalcAuctionWidth;
  CalcGraphsData;
end;

procedure TQuoteTimeGraphs.DrawFrame;
var
  tmpMainData: TTimeData;
  tmpWidth, tmpHeight, tmpBorderWidth, tmpTitleHeight: Integer;
begin
  with FDisplay do
  begin
    tmpWidth := FG32Graphic.Control.Width;
    tmpHeight := FG32Graphic.Control.Height;
    tmpBorderWidth := 1;

    if ShowMode = smSimple then
      tmpTitleHeight := 0
    else
      tmpTitleHeight := TextHeight;

    FG32Graphic.GraphicReset;
    FG32Graphic.BackColor := FDisplay.BackColor;
    FG32Graphic.Clear;

    // 先画X轴尺子

    tmpMainData := FQuoteTimeData.MainData;
    if FDisplay.ShowMode <> smHistoryTime then
    begin
      if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
        DrawXRuler;
    end
    else
    begin
      if not HisDataIsNull then
        DrawXRuler
      else
        DrawNullData;
    end;

    FG32Graphic.EmptyPolyPoly('OuterFrameLine');
    FG32Graphic.EmptyPolyPoly('CenterFrameLine');

    if blTop in BorderLine then
      FG32Graphic.AddPolyPoly('OuterFrameLine',
        [Point(0, 0), Point(tmpWidth, 0)]);
    if blRight in BorderLine then
      FG32Graphic.AddPolyPoly('OuterFrameLine',
        [Point(tmpWidth - tmpBorderWidth, 0), Point(tmpWidth - tmpBorderWidth,
        tmpHeight)]);
    if blBottom in BorderLine then
      FG32Graphic.AddPolyPoly('OuterFrameLine',
        [Point(0, tmpHeight - tmpBorderWidth), Point(tmpWidth,
        tmpHeight - tmpBorderWidth)]);
    if blLeft in BorderLine then
      FG32Graphic.AddPolyPoly('OuterFrameLine',
        [Point(0, 0), Point(0, tmpHeight)]);

    // 可以不画最中心区域最上面的线

    FG32Graphic.AddPolyPoly('CenterFrameLine',
      [Point(FCenterRect.Right, FCenterRect.Top + tmpTitleHeight),
      Point(FCenterRect.Right, FCenterRect.Bottom)]);
    FG32Graphic.AddPolyPoly('CenterFrameLine',
      [Point(FCenterRect.Right, FCenterRect.Bottom), Point(FCenterRect.Left,
      FCenterRect.Bottom)]);
    FG32Graphic.AddPolyPoly('CenterFrameLine',
      [Point(FCenterRect.Left, FCenterRect.Bottom), Point(FCenterRect.Left,
      FCenterRect.Top + tmpTitleHeight)]);

    FG32Graphic.LineColor := Display.GridLineColor;
    FG32Graphic.DrawPolyPolyLine('CenterFrameLine');
    // FG32Graphic.DrawPolyPolyDotLine('CenterFrameLine');

    if ShowMode in [smNormal, smHistoryTime, smWSSelfDefinition] then
      DrawVolumeButton;

    DrawTitleFrame;

    FG32Graphic.LineColor := BorderLineColor;
    FG32Graphic.DrawPolyPolyLine('OuterFrameLine');
  end;
end;

procedure TQuoteTimeGraphs.DrawData;
var
  tmpIndex: Integer;
  tmpMainData: TTimeData;
begin
  tmpMainData := QuoteTimeData.MainData;
  if FDisplay.ShowMode <> smHistoryTime then
  begin
    if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) and
      (FCenterRect.Height > 0) then
    begin
      for tmpIndex := 0 to FGraphs.Count - 1 do
        Graphs[tmpIndex].Draw;
    end;
  end
  else
  begin
    if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) and
      (FCenterRect.Height > 0) and (not HisDataIsNull) then
    begin
      for tmpIndex := 0 to FGraphs.Count - 1 do
        Graphs[tmpIndex].Draw;
    end;
  end;
end;

function TQuoteTimeGraphs.PtInGraphs(_Pt: TPoint;
  var _Graph: TQuoteTimeGraph): Boolean;
var
  tmpRect: TRect;
  tmpIndex: Integer;
begin
  _Graph := nil;
  Result := False;
  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    _Graph := Graphs[tmpIndex];
    tmpRect := _Graph.GraphItem.m_lGraphRect;
    tmpRect.Top := _Graph.TitleRect.Bottom;
    Result := Result or PtInRect(tmpRect, _Pt);
    if Result then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TQuoteTimeGraphs.UpdateSkin;
var
  tmpGraph: TQuoteTimeGraph;
begin
  tmpGraph := FGraphsHash[const_minutekey];
  if Assigned(tmpGraph) then
    tmpGraph.UpdateSkin;
end;

function TQuoteTimeGraphs.XToIndex(_X: Integer;
  var _DataIndex: Integer; var _Index: Integer): Boolean;
var
  tmpWidth: Integer;
  tmpMainData: TTimeData;
  tmpSingleDayWidth, tmpMinuteWidth: Double;
begin
  Result := False;
  _Index := 0;
  _DataIndex := 0;
  tmpMainData := FQuoteTimeData.MainData;
  if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
  begin
    tmpMinuteWidth := MinuteWidth;
    tmpSingleDayWidth := SingleDayWidth;
    tmpWidth := _X - FCenterRect.Left - FCallAuctionWidth + 1;
    if (tmpSingleDayWidth > 0) and (CompareValue(tmpMinuteWidth, 0) > 0) then
    begin
      _DataIndex := Trunc((_X - FCenterRect.Left - FCallAuctionWidth) /
        tmpSingleDayWidth);
      _Index := Trunc((tmpWidth - tmpSingleDayWidth * _DataIndex) /
        tmpMinuteWidth);
      _DataIndex := FQuoteTimeData.MainDatasCount - 1 - _DataIndex;
      Result := True;
    end;
  end;
end;

function TQuoteTimeGraphs.XToIndexEx(_X: Integer; var _DataIndex: Integer; var _Index: Integer): Boolean;
var
  tmpWidth: Integer;
  tmpMainData: TTimeData;
  tmpSingleDayWidth, tmpMinuteWidth: Double;
begin
  Result := False;
  _Index := 0;
  _DataIndex := 0;
  tmpMainData := FQuoteTimeData.MainData;
  if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
  begin
    tmpMinuteWidth := MinuteWidth;
    tmpSingleDayWidth := SingleDayWidth;
    tmpWidth := _X - FCenterRect.Left - FCallAuctionWidth + 1;
    if (tmpSingleDayWidth > 0) and (CompareValue(tmpMinuteWidth, 0) > 0) then
    begin
      _DataIndex := Trunc((_X - FCenterRect.Left - FCallAuctionWidth) /
        tmpSingleDayWidth);
      _Index := Trunc((tmpWidth - tmpSingleDayWidth * _DataIndex) /
        tmpMinuteWidth);
      _DataIndex := FQuoteTimeData.MainDatasCount - 1 - _DataIndex;
      Result := True;
    end;

    if _Index >= tmpMainData.DataCount then
      _Index := tmpMainData.DataCount - 1;
  end;
end;

function TQuoteTimeGraphs.IndexToX(_DataIndex, _Index: Integer): Integer;
var
  tmpMainData: TTimeData;
begin
  Result := FCenterRect.Left + FCallAuctionWidth + 1;
  tmpMainData := FQuoteTimeData.MainData;
  if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
  begin
    Result := Result + Trunc((FQuoteTimeData.MainDatasCount - 1 - _DataIndex) *
      SingleDayWidth + _Index * MinuteWidth + MinuteWidth / 2);
  end;
end;

function TQuoteTimeGraphs.GetCrossMoveMaxX: Integer;
var
  tmpData: TTimeData;
  tmpIndex, tmpDataIndex: Integer;
begin
  tmpIndex := 0;
  tmpDataIndex := 0;
  tmpData := FQuoteTimeData.MainData;
  if Assigned(tmpData) then
  begin
    if tmpData.DataCount - 1 >= 0 then
      tmpIndex := tmpData.DataCount - 1;
  end;
  Result := IndexToX(tmpDataIndex, tmpIndex);
end;

function TQuoteTimeGraphs.XToXRulerHint(_X: Integer): string;
var
  tmpDataIndex, tmpIndex, tmpTime: Integer;
  tmpMainData, tmpData: TTimeData;
begin
  Result := '00:00';
  tmpMainData := FQuoteTimeData.MainData;
  if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
  begin
    XToIndex(_X, tmpDataIndex, tmpIndex);
    tmpData := FQuoteTimeData.DataIndexToData(tmpDataIndex);
    if tmpData <> nil then
    begin
      tmpTime := tmpData.IndexToTime(tmpIndex);
      Result := FormatDateTime('hh:nn', IntToHourMinTime(tmpTime));
    end;
  end;
end;

function TQuoteTimeGraphs.XToXRulerHint(_DataIndex, _Index: Integer): string;
var
  tmpTime: Integer;
  tmpMainData, tmpData: TTimeData;
begin
  Result := '00:00';
  tmpMainData := FQuoteTimeData.MainData;
  if Assigned(tmpMainData) and (not tmpMainData.NullTimeData) then
  begin
    tmpData := FQuoteTimeData.DataIndexToData(_DataIndex);
    if tmpData <> nil then
    begin
      tmpTime := tmpData.IndexToTime(_Index);
      Result := FormatDateTime('hh:nn', IntToHourMinTime(tmpTime));
    end;
  end;
end;

function TQuoteTimeGraphs.YToYRulerHint(_Y: Integer; _Graph: TQuoteTimeGraph;
  var _LHint, _RHint: string): Boolean;
begin
  Result := False;
  if _Graph <> nil then
    _Graph.YToYRulerHint(_Y, _LHint, _RHint);
end;

procedure TQuoteTimeGraphs.DrawNullData;
const
  Const_Time_DataNull = '没有该天数据';
begin
  FG32Graphic.EmptyPolyText('Graph.Minute.DrawNullData');
  FG32Graphic.AddPolyText('Graph.Minute.DrawNullData', FCenterRect,
    Const_Time_DataNull, gtaCenter);
  FG32Graphic.LineColor := Display.StockNameTextColor;
  FG32Graphic.DrawPolyText('Graph.Minute.DrawNullData');
end;

procedure TQuoteTimeGraphs.DrawTitleFrame;
var
  tmpIndex: Integer;
begin
  for tmpIndex := 0 to FGraphs.Count - 1 do
  begin
    Graphs[tmpIndex].DrawTitleFrame;
  end;
end;

procedure TQuoteTimeGraphs.VolumeGraphVisible(_Visible: Boolean);
var
  tmpResult: Boolean;
  tmpGraph: TQuoteTimeGraph;
begin
  tmpResult := False;
  FVolumeVisible := _Visible;
  if FVolumeVisible then
  begin
    tmpGraph := GraphsHash[const_volumekey];
    if Assigned(tmpGraph) then
    begin
      tmpResult := InsertGraph(tmpGraph);
    end;
  end
  else
  begin
    tmpResult := DeleteGraph(const_volumekey);
  end;
  if tmpResult then
  begin
    FQuoteTimeData.OnInvalidate;
  end;
end;

procedure TQuoteTimeGraphs.DrawVolumeButton;
var
  tmpX, tmpWidth: Integer;
  tmpTextSize: TSize;
  tmpRect: TRect;
  tmpBackColor, tmpColor: TColor;
  tmpFontStyles: TFontStyles;
begin
  with FDisplay do
  begin
    tmpWidth := 8;
    tmpRect := FVolumeHideButton.Rect;
    FG32Graphic.EmptyPolyText('VolumeButtonText');

    tmpTextSize := MCanvas.TextExtent('VOL');
    tmpRect.Top := tmpRect.Top + 4;
    tmpRect.Bottom := tmpRect.Bottom - 5;
    tmpRect.Left := (tmpRect.Left + tmpRect.Right - tmpWidth - tmpTextSize.cx
      - 2) div 2;
    tmpRect.Right := tmpRect.Left + tmpWidth;

    tmpX := (tmpRect.Left + tmpRect.Right) div 2;

    if not FVolumeButtonFocused then
    begin
      tmpBackColor := VolumeButtonBackColor;
      tmpColor := VolumeButtonTextColor;
    end
    else
    begin
      tmpBackColor := VolumeButtonFocusBackColor;
      tmpColor := VolumeButtonFocusTextColor;
    end;

    FG32Graphic.GraphicReset;
    FG32Graphic.BackColor := tmpBackColor;
    FG32Graphic.FillRect(FVolumeHideButton.Rect);

    MCanvas.Pen.Color := tmpColor;
    if FVolumeVisible then
    begin
      MCanvas.MoveTo(tmpRect.Left, tmpRect.Bottom);
      MCanvas.LineTo(tmpRect.Right, tmpRect.Bottom);

      MCanvas.MoveTo(tmpX - 1, tmpRect.Top);
      MCanvas.LineTo(tmpX - 1, tmpRect.Bottom - 1);
      MCanvas.MoveTo(tmpX, tmpRect.Top);
      MCanvas.LineTo(tmpX, tmpRect.Bottom - 1);

      MCanvas.MoveTo(tmpX - 2, tmpRect.Bottom - 3);
      MCanvas.LineTo(tmpX + 2, tmpRect.Bottom - 3);
      MCanvas.MoveTo(tmpX - 3, tmpRect.Bottom - 4);
      MCanvas.LineTo(tmpX + 3, tmpRect.Bottom - 4);
      MCanvas.MoveTo(tmpX - 4, tmpRect.Bottom - 5);
      MCanvas.LineTo(tmpX + 4, tmpRect.Bottom - 5);
    end
    else
    begin
      MCanvas.MoveTo(tmpRect.Left, tmpRect.Top);
      MCanvas.LineTo(tmpRect.Right, tmpRect.Top);

      MCanvas.MoveTo(tmpX - 1, tmpRect.Bottom);
      MCanvas.LineTo(tmpX - 1, tmpRect.Top + 1);
      MCanvas.MoveTo(tmpX, tmpRect.Bottom);
      MCanvas.LineTo(tmpX, tmpRect.Top + 1);

      MCanvas.MoveTo(tmpX - 2, tmpRect.Top + 3);
      MCanvas.LineTo(tmpX + 2, tmpRect.Top + 3);
      MCanvas.MoveTo(tmpX - 3, tmpRect.Top + 4);
      MCanvas.LineTo(tmpX + 3, tmpRect.Top + 4);
      MCanvas.MoveTo(tmpX - 4, tmpRect.Top + 5);
      MCanvas.LineTo(tmpX + 4, tmpRect.Top + 5);
    end;
    tmpX := tmpRect.Right + 2;
    tmpRect := FVolumeHideButton.Rect;
    tmpRect.Left := tmpX;

    FG32Graphic.AddPolyText('VolumeButtonText', tmpRect, 'VOL', gtaLeft);

    FG32Graphic.LineColor := tmpColor;
    tmpFontStyles := TextFont.Style;
    TextFont.Style := [fsBold];
    FG32Graphic.UpdateFont(TextFont);

    FG32Graphic.DrawPolyText('VolumeButtonText');

    TextFont.Style := tmpFontStyles;
    FG32Graphic.UpdateFont(TextFont);
  end;
end;

procedure TQuoteTimeGraphs.DrawXRuler;
var
  tmpIsDrawDate: Boolean;
  tmpStartPos, tmpSingleDayWidth: Double;
  tmpIndex, tmpDateWidth, tmpDrawDatePos: Integer;
begin
  tmpStartPos := FCenterRect.Left + FCallAuctionWidth; // 从集合竞价位置开始
  tmpSingleDayWidth := SingleDayWidth;
  tmpDateWidth := CharWidth * 5;
  // MM/DD 5个字符
  tmpDrawDatePos := 0;

  FG32Graphic.EmptyPolyText('DrawXRulerScale');
  FG32Graphic.EmptyPolyPoly('DrawXRuler_ScaleLine');
  FG32Graphic.EmptyPolyPoly('DrawXRuler_ScaleLine_Dot');

  for tmpIndex := FQuoteTimeData.MainDatasCount - 1 downto 0 do
  begin
    tmpIsDrawDate := (Trunc(tmpStartPos - tmpDrawDatePos) > tmpDateWidth);
    DrawSingleDayXRuler(tmpIndex, Trunc(tmpStartPos),
      Trunc(tmpStartPos + tmpSingleDayWidth), FCenterRect, tmpIsDrawDate);
    if tmpIsDrawDate then
      tmpDrawDatePos := Trunc(tmpStartPos);
    tmpStartPos := tmpStartPos + tmpSingleDayWidth;
  end;

  FG32Graphic.GraphicReset;
  FG32Graphic.BackColor := FDisplay.BackColor;
  FG32Graphic.LineColor := FDisplay.GridLineColor;
  FG32Graphic.DrawPolyPolyLine('DrawXRuler_ScaleLine');
  FG32Graphic.DrawPolyPolyDotLine('DrawXRuler_ScaleLine_Dot');
  FG32Graphic.LineColor := FDisplay.EqualColor;
  FG32Graphic.DrawPolyText('DrawXRulerScale');
end;

procedure TQuoteTimeGraphs.DrawSingleDayXRuler(_DataIndex, _StartPos,
  _EndPos: Integer; _CenterRect: TRect; _IsDrawDate: Boolean);
var
  tmpData: TTimeData;
  tmpIsGetDate: Boolean;
  tmpDateTime: TDateTime;
  tmpPTypeTimes: PHSTypeTimes;
  tmpTimeIndex, tmpX, tmpDrawX, tmpCount: Integer;
  tmpOpenTime, tmpCloseTime, tmpDrawTime, tmpDiffTime: Integer;
begin
  tmpCloseTime := -1;
  tmpDiffTime := 0;
  tmpCount := 0;
  tmpIsGetDate := FQuoteTimeData.DataIndexToData(_DataIndex)
    .GetTradeDate(tmpDateTime);
  tmpDrawX := _StartPos;

  // 画刻度的开始日期

  if _IsDrawDate and tmpIsGetDate then
  begin
    if FCallAuctionWidth > 0 then
      DrawXRulerScale('DrawXRulerScale', FDisplay.MonthDayFormat, tmpDateTime,
        _CenterRect.Bottom, _CenterRect.Bottom + TextHeight,
        _StartPos - FCallAuctionWidth)
    else
      DrawXRulerScale('DrawXRulerScale', FDisplay.MonthDayFormat, tmpDateTime,
        _CenterRect.Bottom, _CenterRect.Bottom + TextHeight, _StartPos);
  end;

  // // 填充历史背景色
  // if _DataIndex > 0 then
  // begin
  // FG32Graphic.GraphicReset;
  // FG32Graphic.BackColor := FDisplay.HistoryBackColor;
  // FG32Graphic.FillRect(Rect(_StartPos, _CenterRect.Top, _EndPos,
  // _CenterRect.Bottom));
  // end;

  // if _DataIndex = 0 then
  // begin
  // tmpData := FQuoteTimeData.MainData;
  // if Assigned(tmpData) and tmpData.IsStop then
  // DrawStopFlag;
  // end;

  // 有集合竞价时
  if (FCallAuctionWidth > 0) then
  begin
    FG32Graphic.GraphicReset;
    // 画集合竞价的背景
    FG32Graphic.BackColor := FDisplay.AuctionBackColor;
    FG32Graphic.FillRect(Rect(_StartPos - FCallAuctionWidth, _CenterRect.Top,
      _StartPos, _CenterRect.Bottom));
    // 有集合竞价的时候要多画一条线
    FG32Graphic.AddPolyPoly('DrawXRuler_ScaleLine',
      [Point(_StartPos, _CenterRect.Top), Point(_StartPos,
      _CenterRect.Bottom)]);
  end;

  for tmpTimeIndex := 0 to const_typeTimesCount - 1 do
  begin
    tmpPTypeTimes := FQuoteTimeData.PHSTimes;
    tmpOpenTime := tmpPTypeTimes^[tmpTimeIndex].m_nOpenTime;
    // 表示 tmpTimeIndex 这个开始的时间段的m_nOpenTime和m_nCloseTime
    // 都用 -1 填充的 不用在处理了
    if (tmpOpenTime = -1) then
      Break;
    // 收盘价 最后有用，必须放到这里 否则会 是 -1
    tmpCloseTime := tmpPTypeTimes^[tmpTimeIndex].m_nCloseTime;

    // 画历史分时刻度的处理方法(当时历史的时 不用画刻度线, 只需要画这一日结束时的线)
    if _DataIndex > 0 then
    begin
      FG32Graphic.AddPolyPoly('DrawXRuler_ScaleLine',
        [Point(_EndPos, _CenterRect.Top), Point(_EndPos, _CenterRect.Bottom)]);
      Break;
    end
    else // 画当日分时标尺的处理方法
    begin
      // 有集合竞价时 需要显示第一个时间段的开盘时间
      // if (FCallAuctionWidth > 0) and tmpIsFirst then
      // begin
      // tmpDateTime := IntToHourMinTime(tmpOpenTime);
      // DrawXRulerScale('DrawXRulerScale', 'hh:nn', tmpDateTime,
      // _CenterRect.Bottom, _CenterRect.Bottom + TextHeight, _StartPos);
      // tmpIsFirst := False;
      // end;
      // 9:30 - 11:30   13:00 - 15:00
      // tmpDiffTime 表示记录上次画的时间 和 上次时间区间段的收盘时间差
      // const_timeUnitValue = 60
      tmpDrawTime := tmpOpenTime + tmpDiffTime;
      while tmpDrawTime < tmpCloseTime do
      begin
        Inc(tmpDrawTime, const_timeUnitValue);
        if tmpDrawTime > tmpCloseTime then
          Break;
        tmpX := IndexToX(_DataIndex, FQuoteTimeData.MainData.TimeToIndex
          (tmpDrawTime));
        if ((tmpX - tmpDrawX) >= FXRulerMinWidth) and
          ((tmpX + FXRulerMinWidth) < _EndPos) then
        begin
          Inc(tmpCount);
          tmpDrawX := tmpX;
          // 偶数画实线  偶数画刻度时间提示     奇数画虚线
          if not Odd(tmpCount) then
          begin
            tmpDateTime := IntToHourMinTime(tmpDrawTime);
            DrawXRulerScale('DrawXRulerScale', 'hh:nn', tmpDateTime,
              _CenterRect.Bottom, _CenterRect.Bottom + TextHeight, tmpDrawX);
            FG32Graphic.AddPolyPoly('DrawXRuler_ScaleLine',
              [Point(tmpDrawX, _CenterRect.Top), Point(tmpDrawX,
              _CenterRect.Bottom)]);
            // FG32Graphic.AddPolyPoly('DrawXRuler_ScaleLine_Dot',
            // [Point(tmpDrawX, _CenterRect.Top), Point(tmpDrawX,
            // _CenterRect.Bottom)]);
          end
          else
            FG32Graphic.AddPolyPoly('DrawXRuler_ScaleLine_Dot',
              [Point(tmpDrawX, _CenterRect.Top), Point(tmpDrawX,
              _CenterRect.Bottom)]);
        end;
      end;
      Dec(tmpDrawTime, const_timeUnitValue);
      tmpDiffTime := tmpDrawTime - tmpCloseTime;
    end;
  end;
  // 画最后一个刻度提示
  if (_DataIndex = 0) and (Display.ShowMode <> smMulitStock) then
    DrawXRulerScale('DrawXRulerScale', 'hh:nn', IntToHourMinTime(tmpCloseTime),
      _CenterRect.Bottom, _CenterRect.Bottom + TextHeight, _EndPos);
end;

procedure TQuoteTimeGraphs.DrawStopFlag;
var
  tmpHeight: Integer;
  tmpRect: TRect;
  tmpGraph: TQuoteTimeGraph;
begin
  tmpGraph := GraphsHash[const_minutekey];
  if Assigned(tmpGraph) then
  begin
    tmpRect := tmpGraph.DrawGraphRect;
    tmpRect.Left := tmpRect.Right - Trunc(SingleDayWidth);
    tmpHeight := FDisplay.TextFont.Height;
    FDisplay.TextFont.Height := Trunc(tmpRect.Width * 0.2);
    FG32Graphic.EmptyPolyText('StopFlag');
    FG32Graphic.AddPolyText('StopFlag', tmpRect, '停牌', gtaCenter);

    FG32Graphic.GraphicReset;
    FG32Graphic.UpdateFont(FDisplay.TextFont);
    FG32Graphic.Alpha := 200;
    FG32Graphic.LineColor := FDisplay.StopFlagTextColor;
    FG32Graphic.DrawPolyText('StopFlag');

    FDisplay.TextFont.Height := tmpHeight;
    FG32Graphic.UpdateFont(FDisplay.TextFont);
  end;
end;

procedure TQuoteTimeGraphs.DrawXRulerScale(_DrawKey, _Format: string;
  _DateTime: TDateTime; _Top, _Bottom, _Pos: Integer);
var
  tmpText: string;
  tmpHalfWidth: Integer;
begin
  tmpText := FormatDateTime(_Format, _DateTime);
  tmpHalfWidth := FG32Graphic.TextWidth(tmpText) div 2 + 1;
  FG32Graphic.AddPolyText(_DrawKey, Rect(_Pos - tmpHalfWidth, _Top,
    _Pos + tmpHalfWidth, _Bottom), tmpText, gtaLeft);
end;

procedure TQuoteTimeGraphs.EraseRect(_Rect: TRect);
begin
  DrawCopyRect(Canvas.Handle, _Rect, MCanvas.Handle, _Rect);
end;

procedure TQuoteTimeGraphs.Enlarge;
begin
  if (QuoteTimeData.MainDatasCount > 1) and Assigned(QuoteTimeData.MainData) and
    (not QuoteTimeData.MainData.NullTimeData) then
  begin
    QuoteTimeData.SubscribeNDay(QuoteTimeData.MainDatasCount - 1);
    if Assigned(QuoteTimeData.OnInvalidate) then
      QuoteTimeData.OnInvalidate;
  end;
end;

procedure TQuoteTimeGraphs.Narrow;
begin
  if (FQuoteTimeData.MainDatasCount < FDisplay.MaxDayCount) and
    Assigned(QuoteTimeData.MainData) and
    (not QuoteTimeData.MainData.NullTimeData) then
  begin
    QuoteTimeData.SubscribeNDay(QuoteTimeData.MainDatasCount + 1);
    if Assigned(QuoteTimeData.OnInvalidate) then
      QuoteTimeData.OnInvalidate;
  end;
end;

end.
