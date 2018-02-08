unit QuoteTimeTradeDetail;

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
  ExtCtrls,
  Generics.Collections,
  G32Graphic,
  BaseForm,
  QuoteCommLibrary,
  QuotaCommScrollBar,
  QuoteCommHint, System.Math, CommonFunc, AppContext, BaseObject;

Const
  Const_Scroll_StepSize = 20;
  Const_Column_Name_FundName = 'FundName';
  Const_Column_Name_Direction = 'Direction';
  Const_Column_Name_Volume = 'Volume';
  Const_Column_Name_Money = 'Money';
  Const_Column_Name_AvgPrice = 'AvgPrice';
  Const_Column_HeaderCaption_FundName = '基金名称';
  Const_Column_HeaderCaption_Direction = '方向';
  Const_Column_HeaderCaption_Volume = '成交数量';
  Const_Column_HeaderCaption_Money = '成交金额';
  Const_Column_HeaderCaption_AvgPrice = '成交均价';
  Const_Column_Width_FundName = 120;
  Const_Column_Width_Direction = 40;
  Const_Column_Width_Volume = 95;
  Const_Column_Width_Money = 95;
  Const_Column_Width_AvgPrice = 95;

  Const_Direction_Buy = 1;
  Const_Direction_Sell = 2;

type

  TABDisplay = class(TBaseObject)
  public
//    FGilAppController: IGilAppController;
    FSkinStyle: string;
    TextFont: TFont;
    BorderLineColor: TColor;
    TitleBackColor: TColor;
    BackColor: TColor;
    HeaderBackColor: TColor;
    TitleCaptionColor: TColor;
    HeaderFontColor: TColor;
    FontColor: TColor;
    UpColor: TColor;
    DownColor: TColor;
    RowBottomLineColor: TColor;

    HeaderHeight: Integer;
    RowHeight: Integer;
    MaxRowCount: Integer;
    MinHandleSize: Integer;
    XSpace: Integer;

    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;
    procedure UpdateSkin;
  end;

  TABCell = class
  private
    FValue: string;
    FIntValue: Integer;
    FIsHint: Boolean;
  public
    constructor Create();
    destructor Destroy; override;

    property Value: string read FValue write FValue;
    property IntValue: Integer read FIntValue write FIntValue;
    property IsHint: Boolean read FIsHint write FIsHint;
  end;

  TABColumn = class
  protected
    FABCells: TList;

    FName: string;
    FTop: Integer;
    FLeft: Integer;
    FWidth: Integer;
    FColumnIndex: Integer;
    FTextAlign: TTextAlign;
    FHeaderCaption: string;
    FHeaderTextAlign: TTextAlign;

    procedure CleanList(_List: TList);
    function GetCells(_Index: Integer): TABCell;
  public
    constructor Create();
    destructor Destroy; override;
    function AddCell: TABCell;
    procedure ClearCells;

    property Top: Integer read FTop write FTop;
    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Width: Integer read FWidth write FWidth;
    property TextAlign: TTextAlign read FTextAlign write FTextAlign;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property HeaderCaption: string read FHeaderCaption write FHeaderCaption;
    property HeaderTextAlign: TTextAlign read FHeaderTextAlign
      write FHeaderTextAlign;
    property Cells: TList read FABCells;
  end;

  TABGrid = class
  protected
    FDisplay: TABDisplay;
    FColumns: TList;
    FHashColumns: TDictionary<string, TABColumn>;

    FXSpace: Integer;
    FRowCount: Integer;
    FBodyRect: TRect;
    FHeaderRect: TRect;
    FRowHeight: Integer;
    FLineColor: TColor;

    FFundNameColumn: TABColumn;
    FDirectionColumn: TABColumn;
    FVolumeColumn: TABColumn;
    FMoneyColumn: TABColumn;
    FAvgPriceColumn: TABColumn;

    procedure CleanList(_List: TList);

    function GetGridWidth: Integer;
    function GetCells(_ColumnIndex, _RowIndex: Integer): TABCell;
    function GetHashCells(_ColumnName: string; _RowIndex: Integer): TABCell;
    function GetRowCount: Integer;
    procedure DrawGridHeader(_Canvas: TCanvas; _BackColor, _FontColor: TColor);
    procedure DrawGridBody(_Canvas: TCanvas; _Offset: Integer;
      _BackColor, _FontColor: TColor);
    procedure DrawRows(_Canvas: TCanvas; _Offset: Integer);
    procedure DrawHeaders(_Canvas: TCanvas);
    procedure DrawHeaderCell(_Canvas: TCanvas; _Column: TABColumn;
      _CellRect: TRect);
    procedure DrawCell(_Canvas: TCanvas; _Column: TABColumn; _Cell: TABCell;
      _CellRect: TRect; _Row, _Col: Integer);
    procedure DrawGrid(_Canvas: TCanvas; _Offset: Integer);
    function CalcHint(_Pt: TPoint; _Offset: Integer; var _Cell: TABCell;
      var _CellRect: TRect): Boolean;
  public
    constructor Create(_Display: TABDisplay);
    destructor Destroy; override;
    procedure AddColumn(_Column: TABColumn);
    procedure AddRow;
    procedure ClearRows;
    procedure AddColumns;

    property Columns: TList read FColumns;
    property HashColumns: TDictionary<string, TABColumn> read FHashColumns;
    property XSpace: Integer read FXSpace write FXSpace;
    property Width: Integer read GetGridWidth;
    property BodyRect: TRect read FBodyRect write FBodyRect;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property HeaderRect: TRect read FHeaderRect write FHeaderRect;
    property LineColor: TColor read FLineColor write FLineColor;
    property RowCount: Integer read GetRowCount;
    property Cells[_ColumnIndex, _RowIndex: Integer]: TABCell read GetCells;
    property HashCells[_ColumnName: string; _RowIndex: Integer]: TABCell
      read GetHashCells;

    property FundNameColumn: TABColumn read FFundNameColumn;
    property DirectionColumn: TABColumn read FDirectionColumn;
    property VolumeColumn: TABColumn read FVolumeColumn;
    property MoneyColumn: TABColumn read FMoneyColumn;
    property AvgPriceColumn: TABColumn read FAvgPriceColumn;
  end;

  TTradeData = class
  public
    FundName: string;
    Direction: Integer;
    Volume: string;
    Money: string;
    AvgPrice: string;

    constructor Create;
    destructor Destroy; override;
  end;

  TABHeader = class
  public
    Name: string;
    Caption: string;

    constructor Create;
    destructor Destroy; override;
  end;

  TABData = class
  public
    Date: string;
    Money: Double;
    Datas: TList;
    ObjectRef: TObject;

    procedure CleanList(_List: TList);
    constructor Create;
    destructor Destroy; override;
  end;


  TTradeDetail = class(TBaseForm)
  protected
    FAppContext: IAppContext;
//    FGilAppController: IGilAppController;
    FDisplay: TABDisplay;
    FGrid: TABGrid;
    FBitmap: TBitmap;
    FVScrollBar: TGaugeBarEx;
    FHideTimer: TTimer;
    FHint: THintControl;

    procedure InitData;

    procedure DoClearCanvas;
    procedure DoCalcScrollData;
    procedure DoInvaildate;
    procedure DoCalcDrawGrid;

    procedure WndProc(var Message: TMessage); override;
    procedure CreateParams(var Params: TCreateParams); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    procedure CMMouseEnter(var Message: TMessage); Message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Resize; override;
    procedure Paint; override;
    procedure DoVScrollChange(Sender: TObject);
    procedure DoHideTimer(Sender: TObject);
    procedure UpdateData(_ABData: TABData);
  public
    constructor CreateNew(AOwner: TComponent; AContext: IAppContext); override;
    destructor Destroy; override;
    procedure UpdateShow(_ABData: TABData; _Pt: TPoint);
    procedure UpdateSkin; override;

    function GetMouseMoveRect: TRect;
//    property GilAppController: IGilAppController read FGilAppController;
  end;

implementation

{ TABDisplay }

constructor TABDisplay.Create(AContext: IAppContext);
begin
  inherited;
  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -14;

  HeaderHeight := 30;
  RowHeight := 28;
  MaxRowCount := 5;
  MinHandleSize := 30;
  XSpace := 10;

  BackColor := $FFFFFF;
  TitleBackColor := $F5F5F5;
  HeaderBackColor := $F3F3F3;
  BorderLineColor := $969696;
  TitleCaptionColor := $1A1A1A;
  HeaderFontColor := $323232;
  FontColor := $404040;
  UpColor := $3127F5;
  DownColor := $29B81E;
  RowBottomLineColor := $E6E6E6;

  // BackColor := $444444;
  // TitleBackColor := $444444;
  // HeaderBackColor := $303030;
  // BorderLineColor := $0F0F0F;
  // TitleCaptionColor := $E6E6E6;
  // HeaderFontColor := $FFFFFF;
  // FontColor := $E6E6E6;
  // UpColor := $3127F5;
  // DownColor := $29B81E;
  // RowBottomLineColor := $3B3B3B;
end;

destructor TABDisplay.Destroy;
begin
  inherited;
end;

//procedure TABDisplay.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//begin
//  FGilAppController := GilAppController;
//end;
//
//procedure TABDisplay.DisConnectQuoteManager;
//begin
//  FGilAppController := nil;
//end;

procedure TABDisplay.UpdateSkin;
const
  Const_TimeTradeDetail_Prefix = 'TimeTradeDetail_';
var
  tmpSkinStyle: string;
  function GetStrFromConfig(_Key: WideString): string;
  begin
    Result := FAppContext.GetResourceSkin.GetConfig(Const_TimeTradeDetail_Prefix + _Key);
//    Result := FGilAppController.Config(ctSkin,
//      Const_TimeTradeDetail_Prefix + _Key);
  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_TimeTradeDetail_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_TimeTradeDetail_Prefix + _Key), 0));
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;
//      TextFont.Name := GetStrFromConfig('TextFontName');
      BackColor := GetColorFromConfig('BackColor');
      TitleBackColor := GetColorFromConfig('TitleBackColor');
      HeaderBackColor := GetColorFromConfig('HeaderBackColor');
      BorderLineColor := GetColorFromConfig('BorderLineColor');
      TitleCaptionColor := GetColorFromConfig('TitleCaptionColor');
      HeaderFontColor := GetColorFromConfig('HeaderFontColor');
      FontColor := GetColorFromConfig('FontColor');
      UpColor := GetColorFromConfig('UpColor');
      DownColor := GetColorFromConfig('DownColor');
      RowBottomLineColor := GetColorFromConfig('RowBottomLineColor');
    end;
//  end;
end;

{ TABCell }

constructor TABCell.Create;
begin
  FValue := '';
end;

destructor TABCell.Destroy;
begin

  inherited;
end;

{ TABColumn }

constructor TABColumn.Create;
begin
  FABCells := TList.Create;
  FTextAlign := gtaCenter;
  FHeaderTextAlign := gtaCenter;
end;

destructor TABColumn.Destroy;
begin
  if Assigned(FABCells) then
  begin
    CleanList(FABCells);
    FABCells.Free;
  end;
  inherited;
end;

procedure TABColumn.CleanList(_List: TList);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      if Assigned(_List.Items[tmpIndex]) then
        TObject(_List.Items[tmpIndex]).Free;
    _List.Clear;
  end;
end;

procedure TABColumn.ClearCells;
begin
  CleanList(FABCells);
end;

function TABColumn.GetCells(_Index: Integer): TABCell;
begin
  if (_Index >= 0) and (_Index < FABCells.Count) then
    Result := TABCell(FABCells.Items[_Index])
  else
    Result := nil;
end;

function TABColumn.AddCell: TABCell;
begin
  Result := TABCell.Create;
  FABCells.Add(Result);
end;

{ TABGrid }

constructor TABGrid.Create(_Display: TABDisplay);
begin
  FDisplay := _Display;
  FRowCount := 0;
  FColumns := TList.Create;
  FHashColumns := TDictionary<string, TABColumn>.Create;
end;

destructor TABGrid.Destroy;
begin
  if Assigned(FHashColumns) then
  begin
    FHashColumns.Clear;
    FHashColumns.Free;
  end;
  if Assigned(FColumns) then
  begin
    CleanList(FColumns);
    FColumns.Free;
  end;
  inherited;
end;

function TABGrid.CalcHint(_Pt: TPoint; _Offset: Integer; var _Cell: TABCell;
  var _CellRect: TRect): Boolean;
var
  tmpColumn: TABColumn;
  tmpRow, tmpCol, tmpTop, tmpBottom: Integer;
begin
  Result := False;
  if PtInRect(FBodyRect, _Pt) then
  begin
    for tmpCol := 0 to FColumns.Count - 1 do
    begin
      tmpColumn := FColumns.Items[tmpCol];
      if Assigned(tmpColumn) then
      begin
        if (_Pt.X >= tmpColumn.Left) and
          (_Pt.X < (tmpColumn.Left + tmpColumn.Width)) then
        begin
          tmpTop := FHeaderRect.Bottom - _Offset;
          for tmpRow := 0 to FRowCount - 1 do
          begin
            tmpBottom := tmpTop + FRowHeight;
            if (_Pt.Y > tmpTop) and (_Pt.Y <= tmpBottom) then
            begin
              _Cell := Cells[tmpCol, tmpRow];
              if Assigned(_Cell) and _Cell.IsHint then
              begin
                _CellRect := Rect(tmpColumn.Left, tmpTop,
                  tmpColumn.Left + tmpColumn.Width, tmpBottom);
                Result := True;
                Exit;
              end;
            end;
            tmpTop := tmpBottom;
          end;
        end;
      end;
    end;
  end;
end;

procedure TABGrid.CleanList(_List: TList);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      if Assigned(_List.Items[tmpIndex]) then
        TObject(_List.Items[tmpIndex]).Free;
    _List.Clear;
  end;
end;

procedure TABGrid.AddColumn(_Column: TABColumn);
var
  tmpColumn: TABColumn;
begin
  _Column.ColumnIndex := FColumns.Add(_Column);
  if not FHashColumns.TryGetValue(_Column.Name, tmpColumn) then
    FHashColumns.Add(_Column.Name, _Column);
end;

function TABGrid.GetRowCount: Integer;
begin
  Result := FRowCount;
end;

function TABGrid.GetCells(_ColumnIndex, _RowIndex: Integer): TABCell;
var
  tmpColumn: TABColumn;
begin
  Result := nil;
  if (_ColumnIndex >= 0) and (_ColumnIndex < FColumns.Count) then
  begin
    tmpColumn := FColumns.Items[_ColumnIndex];
    if Assigned(tmpColumn) and Assigned(tmpColumn.Cells) and (_RowIndex >= 0)
      and (_RowIndex < tmpColumn.Cells.Count) then
      Result := TABCell(tmpColumn.Cells.Items[_RowIndex]);
  end
end;

function TABGrid.GetGridWidth: Integer;
var
  tmpIndex: Integer;
  tmpColumn: TABColumn;
begin
  Result := 0;
  for tmpIndex := 0 to FColumns.Count - 1 do
  begin
    tmpColumn := TABColumn(FColumns.Items[tmpIndex]);
    if Assigned(tmpColumn) then
      Result := Result + tmpColumn.Width;
  end;
end;

function TABGrid.GetHashCells(_ColumnName: string; _RowIndex: Integer): TABCell;
var
  tmpColumn: TABColumn;
begin
  Result := nil;
  if FHashColumns.TryGetValue(_ColumnName, tmpColumn) and Assigned(tmpColumn)
  then
  begin
    if Assigned(tmpColumn.Cells) and (_RowIndex >= 0) and
      (_RowIndex < tmpColumn.Cells.Count) then
      Result := TABCell(tmpColumn.Cells.Items[_RowIndex]);
  end;
end;

procedure TABGrid.DrawCell(_Canvas: TCanvas; _Column: TABColumn; _Cell: TABCell;
  _CellRect: TRect; _Row, _Col: Integer);
var
  tmpRect: TRect;
  tmpCell: TABCell;
  tmpValueString: string;
  tmpValue, tmpLeft, tmpRight: Integer;

  function ValueToColor(_Value: Integer): TColor;
  begin
    with FDisplay do
    begin
      case _Value of
        Const_Direction_Buy:
          Result := UpColor;
        Const_Direction_Sell:
          Result := DownColor;
      else
        Result := FontColor;
      end;
    end;
  end;

  function ValueToDirection(_Value: Integer): string;
  begin
    case _Value of
      Const_Direction_Buy:
        Result := '买';
      Const_Direction_Sell:
        Result := '卖';
    else
      Result := '';
    end;
  end;

begin
  with FDisplay do
  begin
    tmpRect := _CellRect;
    tmpRight := _CellRect.Right;
    tmpRect.Inflate(-FXSpace, 0);
    tmpValueString := _Cell.Value;
    if _Col <> FFundNameColumn.ColumnIndex then
    begin
      if _Col <> FDirectionColumn.ColumnIndex then
      begin
        tmpCell := Cells[FDirectionColumn.ColumnIndex, _Row];
        if Assigned(tmpCell) then
        begin
          tmpValue := tmpCell.IntValue;
          _Canvas.Font.Color := ValueToColor(tmpValue);
        end;
      end
      else
      begin
        tmpValue := _Cell.IntValue;
        tmpValueString := ValueToDirection(tmpValue);
        _Canvas.Font.Color := ValueToColor(tmpValue);
      end;
    end
    else
      _Canvas.Font.Color := FontColor;
    _Cell.IsHint := _Canvas.TextWidth(tmpValueString) > tmpRect.Width;
    DrawTextOut(_Canvas.Handle, tmpRect, tmpValueString,
      _Column.TextAlign, True);
    if (_Column.ColumnIndex > 0) then
      tmpLeft := _CellRect.Left
    else
      tmpLeft := tmpRect.Left;
    if _Column.ColumnIndex = FColumns.Count - 1 then
      tmpRight := tmpRect.Right;
    _Canvas.Pen.Color := RowBottomLineColor;
    _Canvas.MoveTo(tmpLeft, tmpRect.Bottom);
    _Canvas.LineTo(tmpRight, tmpRect.Bottom);
  end;
end;

procedure TABGrid.DrawGridHeader(_Canvas: TCanvas;
  _BackColor, _FontColor: TColor);
begin
  _Canvas.Brush.Color := _BackColor;
  _Canvas.FillRect(FHeaderRect);
  DrawHeaders(_Canvas);
end;

procedure TABGrid.DrawHeaderCell(_Canvas: TCanvas; _Column: TABColumn;
  _CellRect: TRect);
var
  tmpRect: TRect;
begin
  with FDisplay do
  begin
    tmpRect := _CellRect;
    if _Column.ColumnIndex <> FDirectionColumn.ColumnIndex then
      tmpRect.Inflate(-FXSpace, 0);
    _Canvas.Font.Color := FontColor;
    DrawTextOut(_Canvas.Handle, tmpRect, _Column.HeaderCaption,
      _Column.TextAlign, True);
  end;
end;

procedure TABGrid.DrawHeaders(_Canvas: TCanvas);
var
  tmpRect: TRect;
  tmpColumn: TABColumn;
  tmpIndex, tmpLeft: Integer;
begin
  tmpLeft := FBodyRect.Left;
  tmpRect := FHeaderRect;
  for tmpIndex := 0 to FColumns.Count - 1 do
  begin
    tmpColumn := TABColumn(FColumns.Items[tmpIndex]);
    if Assigned(tmpColumn) then
    begin
      tmpColumn.Left := tmpLeft;
      tmpLeft := tmpColumn.Left + tmpColumn.Width;
      tmpRect.Left := tmpColumn.Left;
      tmpRect.Right := tmpRect.Left + tmpColumn.Width;
      DrawHeaderCell(_Canvas, tmpColumn, tmpRect);
      if tmpIndex > 0 then
      begin
        _Canvas.Pen.Color := FDisplay.RowBottomLineColor;
        _Canvas.MoveTo(tmpColumn.Left, tmpRect.Top);
        _Canvas.LineTo(tmpColumn.Left, tmpRect.Bottom);
      end;
    end;
  end;
end;

procedure TABGrid.DrawRows(_Canvas: TCanvas; _Offset: Integer);
var
  tmpRect: TRect;
  tmpCell: TABCell;
  tmpColumn: TABColumn;
  tmpRow, tmpCol, tmpTop: Integer;
begin
  tmpTop := FHeaderRect.Bottom - _Offset;
  for tmpRow := 0 to FRowCount - 1 do
  begin
    for tmpCol := 0 to FColumns.Count - 1 do
    begin
      tmpColumn := FColumns.Items[tmpCol];
      tmpCell := Cells[tmpCol, tmpRow];
      if Assigned(tmpColumn) and Assigned(tmpCell) then
      begin
        tmpRect := Rect(tmpColumn.Left, tmpTop,
          tmpColumn.Left + tmpColumn.Width, tmpTop + FRowHeight);
        DrawCell(_Canvas, tmpColumn, tmpCell, tmpRect, tmpRow, tmpCol);
      end;
    end;
    tmpTop := tmpRect.Bottom;
  end;
end;

procedure TABGrid.DrawGridBody(_Canvas: TCanvas; _Offset: Integer;
  _BackColor, _FontColor: TColor);
var
  tmpClipRgn: HRGN;
begin
  tmpClipRgn := CreateRectRgn(FBodyRect.Left, FBodyRect.Top, FBodyRect.Right,
    FBodyRect.Bottom);
  SelectClipRgn(_Canvas.Handle, tmpClipRgn);
  try
    _Canvas.Brush.Color := _BackColor;
    _Canvas.FillRect(FBodyRect);
    DrawRows(_Canvas, _Offset);
  finally
    SelectClipRgn(_Canvas.Handle, 0);
    DeleteObject(tmpClipRgn);
  end;
end;

procedure TABGrid.DrawGrid(_Canvas: TCanvas; _Offset: Integer);
begin
  with FDisplay do
  begin
    DrawGridHeader(_Canvas, HeaderBackColor, HeaderFontColor);
    DrawGridBody(_Canvas, _Offset, BackColor, FontColor);
  end;
end;

procedure TABGrid.AddColumns;
var
  tmpColumn: TABColumn;
begin
  tmpColumn := TABColumn.Create;
  tmpColumn.Name := Const_Column_Name_FundName;
  tmpColumn.Width := Const_Column_Width_FundName;
  tmpColumn.HeaderCaption := Const_Column_HeaderCaption_FundName;
  tmpColumn.TextAlign := gtaLeft;
  tmpColumn.HeaderTextAlign := gtaLeft;
  AddColumn(tmpColumn);
  FFundNameColumn := tmpColumn;

  tmpColumn := TABColumn.Create;
  tmpColumn.Name := Const_Column_Name_Direction;
  tmpColumn.Width := Const_Column_Width_Direction;
  tmpColumn.HeaderCaption := Const_Column_HeaderCaption_Direction;
  tmpColumn.TextAlign := gtaCenter;
  tmpColumn.HeaderTextAlign := gtaCenter;
  AddColumn(tmpColumn);
  FDirectionColumn := tmpColumn;

  tmpColumn := TABColumn.Create;
  tmpColumn.Name := Const_Column_Name_Volume;
  tmpColumn.Width := Const_Column_Width_Volume;
  tmpColumn.HeaderCaption := Const_Column_HeaderCaption_Volume;
  tmpColumn.TextAlign := gtaRight;
  tmpColumn.HeaderTextAlign := gtaRight;
  AddColumn(tmpColumn);
  FVolumeColumn := tmpColumn;

  tmpColumn := TABColumn.Create;
  tmpColumn.Name := Const_Column_Name_Money;
  tmpColumn.Width := Const_Column_Width_Money;
  tmpColumn.HeaderCaption := Const_Column_HeaderCaption_Money;
  tmpColumn.TextAlign := gtaRight;
  tmpColumn.HeaderTextAlign := gtaRight;
  AddColumn(tmpColumn);
  FMoneyColumn := tmpColumn;

  tmpColumn := TABColumn.Create;
  tmpColumn.Name := Const_Column_Name_AvgPrice;
  tmpColumn.Width := Const_Column_Width_AvgPrice;
  tmpColumn.HeaderCaption := Const_Column_HeaderCaption_AvgPrice;
  tmpColumn.TextAlign := gtaRight;
  tmpColumn.HeaderTextAlign := gtaRight;
  AddColumn(tmpColumn);
  FAvgPriceColumn := tmpColumn;
end;

procedure TABGrid.AddRow;
var
  tmpIndex: Integer;
  tmpColumn: TABColumn;
begin
  for tmpIndex := 0 to FColumns.Count - 1 do
  begin
    tmpColumn := TABColumn(FColumns.Items[tmpIndex]);
    if Assigned(tmpColumn) then
      tmpColumn.AddCell;
  end;
  Inc(FRowCount);
end;

procedure TABGrid.ClearRows;
var
  tmpIndex: Integer;
  tmpColumn: TABColumn;
begin
  for tmpIndex := 0 to FColumns.Count - 1 do
  begin
    tmpColumn := TABColumn(FColumns.Items[tmpIndex]);
    if Assigned(tmpColumn) then
      tmpColumn.ClearCells;
  end;
  FRowCount := 0;
end;

{ TTradeData }

constructor TTradeData.Create;
begin

end;

destructor TTradeData.Destroy;
begin

  inherited;
end;

{ TABHeader }

constructor TABHeader.Create;
begin

end;

destructor TABHeader.Destroy;
begin

  inherited;
end;

{ TTradeDetail }

constructor TTradeDetail.CreateNew(AOwner: TComponent; AContext: IAppContext);
begin
  inherited;
  FAppContext := AContext;
  FDisplay := TABDisplay.Create(AContext);
  FGrid := TABGrid.Create(FDisplay);
  FBitmap := TBitmap.Create;
  FVScrollBar := TGaugeBarEx.Create(nil);
  FHideTimer := TTimer.Create(nil);
  FHint := THintControl.Create(nil);
  InitData;
end;

destructor TTradeDetail.Destroy;
begin
  if Assigned(FHint) then
    FreeAndNil(FHint);
  if Assigned(FHideTimer) then
  begin
    FHideTimer.Enabled := False;
    FreeAndNil(FHideTimer);
  end;
  if Assigned(FVScrollBar) then
    FreeAndNil(FVScrollBar);
  if Assigned(FGrid) then
    FreeAndNil(FGrid);
  if Assigned(FDisplay) then
    FreeAndNil(FDisplay);
  FAppContext := nil;
  inherited;
end;

procedure TTradeDetail.InitData;
begin
  Visible := False;
  FTitleBar.BarButtonTypes := [bbtClose];
  FTitleBar.Caption := '成交明细';
  FTitleBar.BackColor := FDisplay.TitleBackColor;
  FTitleBar.Height := 28;
  BorderWidth := 1;
  Color := FDisplay.BorderLineColor;
  FMouseChangeSize := False;

  FHideTimer.Enabled := False;
  FHideTimer.Interval := 50;
  FHideTimer.OnTimer := DoHideTimer;

  with FVScrollBar do
  begin
    Parent := Self;
    Align := alCustom;
    Kind := sbVertical;
    ShowArrows := False;
    BorderLines := [blLeft, blTop, blRight, blBottom];
    BorderStyle := bsNone;
    OnChange := DoVScrollChange;
    LargeChange := 10;
    Visible := True;
  end;

  FBitmap.Canvas.Font.Assign(FDisplay.TextFont);
  Self.Canvas.Font.Assign(FDisplay.TextFont);

  FGrid.AddColumns;
  Width := FGrid.Width + FVScrollBar.Width;
end;

procedure TTradeDetail.CreateParams(var Params: TCreateParams);
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

//  Params.WndParent := Screen.ActiveForm.Handle;
//  if (Params.WndParent <> 0) and
//    (IsIconic(Params.WndParent) or not IsWindowVisible(Params.WndParent) or
//    not IsWindowEnabled(Params.WndParent)) then
//    Params.WndParent := 0;
//  if Params.WndParent = 0 then
//    Params.WndParent := Application.Handle;
end;

procedure TTradeDetail.DoCalcScrollData;
begin
  with FDisplay do
  begin
    if Assigned(FGrid) then
    begin
      FVScrollBar.Enabled := FGrid.RowCount > MaxRowCount;
      if FVScrollBar.Enabled then
      begin
        FVScrollBar.Max := (FGrid.RowCount * RowHeight) - MaxRowCount *
          RowHeight;
        FVScrollBar.Min := 0;
        FVScrollBar.HandleSize :=
          Max(MinHandleSize, FVScrollBar.Height * FVScrollBar.Height div
          (FGrid.RowCount * RowHeight));
        FVScrollBar.Left := Width - FVScrollBar.Width - 1;
        FVScrollBar.Top := FTitleBar.Height + HeaderHeight - 1;
        FVScrollBar.Height := Height - FTitleBar.Height - HeaderHeight;
      end
      else
      begin
        FVScrollBar.Position := 0;
        FVScrollBar.Min := 0;
        FVScrollBar.Max := 0;
        FVScrollBar.Left := Width - FVScrollBar.Width - 1;
        FVScrollBar.Top := FTitleBar.Height + HeaderHeight - 1;
        FVScrollBar.Height := 0;
      end;
    end;
  end;
end;

procedure TTradeDetail.DoClearCanvas;
var
  tmpRect: TRect;
begin
  tmpRect := Rect(0, FTitleBar.Height, Width, Height);
  FBitmap.Canvas.Brush.Color := FDisplay.BackColor;
  FBitmap.Canvas.FillRect(tmpRect);
end;

procedure TTradeDetail.DoCalcDrawGrid;
var
  tmpRect: TRect;
begin
  with FBitmap, FDisplay do
  begin
    if Assigned(FGrid) then
    begin
      FGrid.XSpace := XSpace;
      FGrid.RowHeight := RowHeight;
      FGrid.HeaderRect := Rect(0, FTitleBar.Height, Width,
        FTitleBar.Height + HeaderHeight);
      FGrid.BodyRect := Rect(0, FTitleBar.Height + HeaderHeight,
        Width - FVScrollBar.Width, Height);
      FGrid.DrawGrid(Canvas, FVScrollBar.Position);
      tmpRect := Rect(0, FTitleBar.Height, Width, Height);
      DrawCopyRect(Self.Canvas.Handle, tmpRect, FBitmap.Canvas.Handle, tmpRect);
    end;
  end;
end;

procedure TTradeDetail.DoInvaildate;
begin
  DoCalcDrawGrid;

  // Invalidate;
end;

function TTradeDetail.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := True;
  if FVScrollBar.Enabled then
  begin
    if (FVScrollBar.Position + Const_Scroll_StepSize) < FVScrollBar.Max then
      FVScrollBar.Position := FVScrollBar.Position + Const_Scroll_StepSize
    else
      FVScrollBar.Position := FVScrollBar.Max;
  end;
end;

function TTradeDetail.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := True;
  if FVScrollBar.Enabled then
  begin
    if (FVScrollBar.Position - Const_Scroll_StepSize) > FVScrollBar.Min then
      FVScrollBar.Position := FVScrollBar.Position - Const_Scroll_StepSize
    else
      FVScrollBar.Position := FVScrollBar.Min;
  end;
end;

procedure TTradeDetail.DoHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  FHint.HideHint;
  Hide;
end;

procedure TTradeDetail.DoVScrollChange(Sender: TObject);
begin
  if FVScrollBar.Max <> FVScrollBar.Min then
    DoInvaildate;
end;

procedure TTradeDetail.CMMouseEnter(var Message: TMessage);
begin
  // if FHideTimer.Enabled then
  // FHideTimer.Enabled := False;
end;

procedure TTradeDetail.CMMouseLeave(var Message: TMessage);
// var
// tmpPt: TPoint;
// tmpRect, tmpTitleRect: TRect;
begin
  // tmpPt := ScreenToClient(Mouse.CursorPos);
  // tmpRect := Rect(FVScrollBar.Left, FVScrollBar.Top,
  // FVScrollBar.Left + FVScrollBar.Width, FVScrollBar.Top + FVScrollBar.Height);
  // tmpTitleRect := Rect(FTitleBar.Left, FTitleBar.Top,
  // FTitleBar.Left + FTitleBar.Width, FTitleBar.Top + FTitleBar.Height);
  // if (not PtInRect(tmpRect, tmpPt)) and (not PtInRect(tmpTitleRect, tmpPt)) then
  // FHideTimer.Enabled := True;
  FHint.HideHint;
end;

procedure TTradeDetail.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TTradeDetail.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpPt: TPoint;
  tmpRect: TRect;
  tmpCell: TABCell;
begin
  inherited;
  if FGrid.CalcHint(Point(X, Y), FVScrollBar.Position, tmpCell, tmpRect) then
  begin
    tmpPt := ClientToScreen(Point(tmpRect.Right, tmpRect.Bottom - 10));
    FHint.ShowHint(tmpCell.Value, tmpPt.X, tmpPt.Y);
  end
  else
    FHint.HideHint;
end;

procedure TTradeDetail.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TTradeDetail.Paint;
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
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TTradeDetail.Resize;
begin
  if (FBitmap.Width <> Width) or (FBitmap.Height <> Height) then
  begin
    FBitmap.Canvas.Lock;
    try
      FBitmap.SetSize(Width, Height);
    finally
      FBitmap.Canvas.UnLock;
    end;
    DoClearCanvas;
    DoCalcScrollData;
    DoInvaildate;
  end;
end;

function TTradeDetail.GetMouseMoveRect: TRect;
var
  tmpPtLeftTop, tmpPtRightBottom: TPoint;
begin
  Result := GetClientRect;
  Result.Inflate(10, 10, 0, 0);
  tmpPtLeftTop := ClientToScreen(Result.TopLeft);
  tmpPtRightBottom := ClientToScreen(Result.BottomRight);
  Result := Rect(tmpPtLeftTop.X, tmpPtLeftTop.Y, tmpPtRightBottom.X,
    tmpPtRightBottom.Y);
end;

procedure TTradeDetail.UpdateData(_ABData: TABData);
var
  tmpCell: TABCell;
  tmpIndex: Integer;
  tmpTradeData: TTradeData;
begin
  with FDisplay do
  begin
    FGrid.ClearRows;
    if Assigned(_ABData) then
    begin
      if Assigned(_ABData.Datas) then
      begin
        for tmpIndex := 0 to _ABData.Datas.Count - 1 do
        begin
          tmpTradeData := TTradeData(_ABData.Datas.Items[tmpIndex]);
          if Assigned(tmpTradeData) then
          begin
            FGrid.AddRow;
            tmpCell := FGrid.Cells[FGrid.FundNameColumn.ColumnIndex,
              FGrid.RowCount - 1];
            if Assigned(tmpCell) then
              tmpCell.Value := tmpTradeData.FundName;
            tmpCell := FGrid.Cells[FGrid.DirectionColumn.ColumnIndex,
              FGrid.RowCount - 1];
            if Assigned(tmpCell) then
              tmpCell.IntValue := tmpTradeData.Direction;
            tmpCell := FGrid.Cells[FGrid.VolumeColumn.ColumnIndex,
              FGrid.RowCount - 1];
            if Assigned(tmpCell) then
              tmpCell.Value := tmpTradeData.Volume;
            tmpCell := FGrid.Cells[FGrid.MoneyColumn.ColumnIndex,
              FGrid.RowCount - 1];
            if Assigned(tmpCell) then
              tmpCell.Value := tmpTradeData.Money;
            tmpCell := FGrid.Cells[FGrid.AvgPriceColumn.ColumnIndex,
              FGrid.RowCount - 1];
            if Assigned(tmpCell) then
              tmpCell.Value := tmpTradeData.AvgPrice;
          end;
        end;
      end;

      if FGrid.RowCount >= MaxRowCount then
        Height := FTitleBar.Height + HeaderHeight + MaxRowCount * RowHeight
      else
        Height := FTitleBar.Height + HeaderHeight + FGrid.RowCount * RowHeight;
    end;
  end;
end;

procedure TTradeDetail.UpdateShow(_ABData: TABData; _Pt: TPoint);
var
  tmpRect: TRect;
  tmpMonitor: TMonitor;
begin
  if Assigned(_ABData) then
    FTitleBar.Caption := '成交明细  ' + _ABData.Date
  else
    FTitleBar.Caption := '成交明细  ';
  UpdateData(_ABData);
  DoClearCanvas;
  DoCalcScrollData;
  DoInvaildate;
  tmpMonitor := Screen.MonitorFromWindow(GetActiveWindow);
  if tmpMonitor <> nil then
  begin
    tmpRect := Monitor.WorkareaRect;
    if _Pt.X + Self.Width > tmpRect.Right then
      _Pt.X := tmpRect.Right - Self.Width - 5;
    if _Pt.Y + Self.Height > tmpRect.Bottom then
      _Pt.Y := tmpRect.Bottom - Self.Height - 5;
  end;
  Left := _Pt.X;
  Top := _Pt.Y;
  Show;
end;

procedure TTradeDetail.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS, WM_ACTIVATE, WM_MOUSEACTIVATE:
      Message.Result := MA_NOACTIVATE;
  end;
  inherited WndProc(Message);
end;

procedure TTradeDetail.UpdateSkin;
begin
  FTitleBar.UpdateSkin;
  FDisplay.UpdateSkin;
  FTitleBar.CaptionColor := FDisplay.TitleCaptionColor;
  FTitleBar.BackColor := FDisplay.TitleBackColor;
  Color := FDisplay.BorderLineColor;
  FBitmap.Canvas.Font.Assign(FDisplay.TextFont);
  Self.Canvas.Font.Assign(FDisplay.TextFont);
  DoInvaildate;
  FVScrollBar.UpdateSkin(FAppContext);
  FVScrollBar.Invalidate;
end;

{ TABData }

constructor TABData.Create;
begin
  Money := 0;
  Datas := TList.Create;
end;

destructor TABData.Destroy;
begin
  if Assigned(Datas) then
    CleanList(Datas);
  inherited;
end;

procedure TABData.CleanList(_List: TList);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      if Assigned(_List.Items[tmpIndex]) then
        TObject(_List.Items[tmpIndex]).Free;
    _List.Clear;
  end;
end;

end.
