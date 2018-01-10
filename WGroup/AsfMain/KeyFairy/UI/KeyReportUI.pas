unit KeyReportUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� KeyReportUI
// Author��      lksoulman
// Date��        2017-11-15
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Controls,
  SysUtils,
  Messages,
  Graphics,
  Math,
  Vcl.Forms,
  NxCells,
  NxClasses,
  NxColumns,
  NxColumnClasses,
  NxCollection,
  NxCustomGridControl,
  G32Graphic,
  SecuMain,
  AppContext,
  GaugeBarEx,
  GR32_RangeBars,
  SimpleReport,
  CommonDynArray,
  CommonRefCounter;

type

  // KeyRowData
  TKeyRowData = class(TAutoObject)
  private
    // SecuInfo
    FSecuInfo: PSecuInfo;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // KeyReportUI
  TKeyReportUI = class(TSimpleReport)
  private
    // BackColor
    FBackColor: TColor;
    // FontColor
    FFontColor: TColor;
    // SelectRowBackColor
    FSelectRowBackColor: TColor;
    // SelectRowFontColor
    FSelectRowFontColor: TColor;
    // KeyInfoColumn
    FKeyInfoColumn: TNxTextColumn;
  protected
    // ClearRows
    procedure DoClearRows;
    // InitGridData
    procedure DoInitGridData;
    // InitGridColumns
    procedure DoInitGridColumns;

    // GridVertBarTop
    procedure DoGridVertBarTop;
    // GridVertBarNextRow
    procedure DoGridVertBarNextRow;
    // GridVertBarPriorRow
    procedure DoGridVertBarPriorRow;
    // ResetPos
    procedure DoResetPos; override;
    // PaintReportBefore
    procedure DoGridPaintReportBefore; override;
    // UpdateVertScrollBar
    procedure DoGridUpdateVertScrollBar; override;
    // VertChange
    procedure DoGridVertChange(Sender: TObject); override;
    // MouseLeave
    procedure DoGridMouseLeave(Sender: TObject); override;
    // WheelUp
    function DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    // WheelDown
    function DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    // ProcessKeyDown
    function DoGridProcessKeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    // MouseMove
    procedure DoGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    // MouseUp
    procedure DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // MouseDown
    procedure DoGirdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // DrawCell
    procedure DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState); override;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle;
    // ClearGridRowDatas
    procedure ClearGridRowDatas;
    // LoadSearchResult
    procedure LoadSearchResult(AObject: TObject);
  end;


implementation

{ TKeyRowData }

constructor TKeyRowData.Create;
begin
  inherited;

end;

destructor TKeyRowData.Destroy;
begin

  inherited;
end;

{TKeyReportUI}

constructor TKeyReportUI.Create(AParent: TWinControl; AContext: IAppContext);
var
  LFont: TFont;
begin
  inherited;
  FVertBar := TGaugeBarEx.Create(nil, FAppContext);
  FVertBar.Kind := sbVertical;
  FVertBar.OnChange := DoGridVertChange;
  FVertBar.Parent := Self;
  FVertBar.Align := alRight;
  FVertBar.Visible := True;
//  FVertBar.Enabled := True;
  FVertBar.RefreshBar;
  FVertBar.UpdateSkinStyle;

  LFont := TFont.Create;
  LFont.Name := '΢���ź�';
  LFont.Charset := GB2312_CHARSET;
  LFont.Height := -13;
  FG32GraphicBuffer.G32Graphic.UpdateFont(LFont);
  LFont.Free;

  DoInitGridData;
  DoInitGridColumns;
end;

destructor TKeyReportUI.Destroy;
begin
  DoClearRows;
  inherited;
end;

procedure TKeyReportUI.UpdateSkinStyle;
begin
  FBackColor := RGB(26, 26, 26);
  FFontColor := RGB(134, 134, 134);
  FSelectRowBackColor := RGB(89, 89, 89);
  FSelectRowFontColor := RGB(134, 134, 134);

  Color := FBackColor;
  FSimpleGrid.Color := FBackColor;
end;

procedure TKeyReportUI.ClearGridRowDatas;
begin
  FSimpleGrid.BeginUpdate;
  try
    DoClearRows;
  finally
    FSimpleGrid.EndUpdate;
  end;
end;

procedure TKeyReportUI.LoadSearchResult(AObject: TObject);
var
  LCell: TCell;
  LIndex: Integer;
  LSecuInfo: PSecuInfo;
  LKeyRowData: TKeyRowData;
  LSecuInfos: TDynArray<PSecuInfo>;
begin
  LSecuInfos := TDynArray<PSecuInfo>(AObject);

  FSimpleGrid.BeginUpdate;
  try
    DoClearRows;
    for LIndex := 0 to LSecuInfos.GetCount - 1 do begin
      LSecuInfo := LSecuInfos.GetElement(LIndex);
      if LSecuInfo <> nil then begin
        FSimpleGrid.AddRow();
        LKeyRowData := TKeyRowData.Create;
        LKeyRowData.FSecuInfo := LSecuInfo;
        LCell := FSimpleGrid.Cell[FKeyInfoColumn.Tag, FSimpleGrid.RowCount - 1];
        LCell.ObjectReference := LKeyRowData;
      end;
    end;
  finally
    FSimpleGrid.EndUpdate;
  end;
//  if FSimpleGrid.RowCount > 0 then begin
//    FSimpleGrid.SelectedRow := 0;
//  end;
end;

procedure TKeyReportUI.DoClearRows;
var
  LCell: TCell;
  LIndex: Integer;
  LKeyRowData: TKeyRowData;
begin
  for LIndex := 0 to FSimpleGrid.RowCount - 1 do begin
    LCell := FSimpleGrid.Cell[FKeyInfoColumn.Tag, LIndex];
    LKeyRowData := TKeyRowData(LCell.ObjectReference);
    LCell.ObjectReference := nil;
    if LKeyRowData <> nil then begin
      LKeyRowData.Free;
    end;
  end;
  FSimpleGrid.ClearRows;
end;

procedure TKeyReportUI.DoInitGridData;
begin
  with FSimpleGrid do begin
    Parent := Self;
    Align := alClient;
    Options := Options + [goDisableColumnMoving, goSelectFullRow];
    FixedCols := 1;
    BorderStyle := bsNone;
    HeaderSize := 0;
    RowSize := 22;
//    ParentBackground := False;
    ParentColor := False;
    ReadOnly := True;
    GridStyle := gsReport;
    GridLinesStyle := lsActiveHorzOnly;
    AppearanceOptions := AppearanceOptions + [aoHideFocus];
    OnVerticalScroll := DoGridVertScroll;
    HideScrollBar := True;
  end;
end;

procedure TKeyReportUI.DoInitGridColumns;
var
  tmpColumnOptions: TColumnOptions;
begin
  with FSimpleGrid do begin
    FKeyInfoColumn := TNxTextColumn.Create(FSimpleGrid);
    Columns.AddColumn(FKeyInfoColumn);
    FKeyInfoColumn.Header.Caption := 'ShowContent';
    FKeyInfoColumn.Header.Alignment := taCenter;
    FKeyInfoColumn.Alignment := taCenter;
    FKeyInfoColumn.Width := 100;
    FKeyInfoColumn.Visible := True;
    FKeyInfoColumn.DrawingOptions := doCustomOnly;
    tmpColumnOptions := FKeyInfoColumn.Options;
    Exclude(tmpColumnOptions, coCanSort);
    Include(tmpColumnOptions, coAutoSize);
    FKeyInfoColumn.Options := tmpColumnOptions;
    FKeyInfoColumn.Tag := 0;
  end;
end;

procedure TKeyReportUI.DoGridVertBarTop;
begin
  if FVertBar = nil then Exit;

  if FVertBar.Visible
    and (FVertBar.Position > FVertBar.Min) then begin
    FVertBar.Position := FVertBar.Min;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TKeyReportUI.DoGridVertBarNextRow;
begin
  if FVertBar = nil then Exit;

  if (FVertBar.Position + 1) <= FVertBar.Max then begin
    FVertBar.Position := FVertBar.Position + 1;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TKeyReportUI.DoGridVertBarPriorRow;
begin
  if FVertBar = nil then Exit;

  if (FVertBar.Position - 1) >= FVertBar.Min then begin
    FVertBar.Position := FVertBar.Position - 1;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TKeyReportUI.DoResetPos;
begin

end;

procedure TKeyReportUI.DoGridPaintReportBefore;
begin
  FG32GraphicBuffer.G32Graphic.BackColor := FBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(Rect(0, 0, FSimpleGrid.Width, FSimpleGrid.Height));
end;

procedure TKeyReportUI.DoGridUpdateVertScrollBar;
begin
  if FVertBar = nil then Exit;

  FVertBar.Enabled := FSimpleGrid.VertScrollBar.Max <> 0;
  if FVertBar.Enabled then begin
    FVertBar.Max := FSimpleGrid.RowCount - FSimpleGrid.VertScrollBar.PageSize + 1;
    FVertBar.Min := 0;
    FVertBar.LargeChange := FSimpleGrid.VertScrollBar.LargeChange;
    FVertBar.SmallChange := FSimpleGrid.VertScrollBar.SmallChange;
    FVertBar.Position := FSimpleGrid.VertScrollBar.Position;
    FVertBar.HandleSize := Max(25,
      Trunc((FSimpleGrid.VertScrollBar.PageSize * Height) /
      (FSimpleGrid.VertScrollBar.Max + 1)));
  end else begin
    FVertBar.Position := 0;
    FVertBar.Max := 0;
    FVertBar.Min := 0;
  end;
//  DoResetPos;
end;

procedure TKeyReportUI.DoGridVertChange(Sender: TObject);
begin
  if FVertBar = nil then Exit;

  FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
end;

procedure TKeyReportUI.DoGridMouseLeave(Sender: TObject);
begin

end;

function TKeyReportUI.DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TKeyReportUI.DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TKeyReportUI.DoGridProcessKeyDown(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
  if (Key = VK_UP) or (Key = VK_DOWN) then begin
    if FVertBar = nil then Exit;

    if FVertBar.Visible
      and (FVertBar.Position <> FSimpleGrid.VertScrollBar.Position) then begin
      Result := True;
      FVertBar.Position := FSimpleGrid.VertScrollBar.Position;
    end;
  end;
end;

procedure TKeyReportUI.DoGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TKeyReportUI.DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TKeyReportUI.DoGirdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TKeyReportUI.DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState);
var
  LCell: TCell;
  LSecuCode: string;
  LSecuAbbr: string;
  LSecuTypeName: string;
  LKeyRowData: TKeyRowData;
  LBackColor, LFontColor: TColor;
  LCodeRect, LAbbrRect, LNameRect: TRect;
begin
  LCell := FSimpleGrid.Cell[ACol, ARow];
  if csSelected in CellState then begin
    LBackColor := FSelectRowBackColor;
    LFontColor := FSelectRowFontColor;
  end else begin
    LBackColor := FBackColor;
    LFontColor := FFontColor;
  end;
  FG32GraphicBuffer.G32Graphic.BackColor := LBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(CellRect);

  if LCell <> nil then begin
    LKeyRowData := TKeyRowData(LCell.ObjectReference);
    if LKeyRowData.FSecuInfo <> nil then begin
      FG32GraphicBuffer.G32Graphic.EmptyPolyText('DrawText');

      LSecuCode := LKeyRowData.FSecuInfo.FSecuCode;
      LSecuAbbr := LKeyRowData.FSecuInfo.FSecuAbbr;
      LSecuTypeName := LKeyRowData.FSecuInfo.GetSearchTypeName;
      if LSecuCode <> '' then begin
        LCodeRect := CellRect;
        LCodeRect.Left := LCodeRect.Left + 5;
        LCodeRect.Right := LCodeRect.Left + 90;
        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LCodeRect, LSecuCode, gtaLeft);
      end;
      if LSecuAbbr <> '' then begin
        LAbbrRect := CellRect;
        LAbbrRect.Left := LAbbrRect.Left + 80;
        LAbbrRect.Right := LAbbrRect.Right - 80;
        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LAbbrRect, LSecuAbbr, gtaLeft);
      end;
      if LSecuTypeName <> '' then begin
        LNameRect := CellRect;
        LNameRect.Left := LNameRect.Right - 45;
        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LNameRect, LSecuTypeName, gtaLeft);
      end;
      FG32GraphicBuffer.G32Graphic.Ellipsis := True;
      FG32GraphicBuffer.G32Graphic.LineColor := LFontColor;
      FG32GraphicBuffer.G32Graphic.DrawPolyText('DrawText');
    end;
  end;
end;

end.
