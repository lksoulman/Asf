unit KeyReportUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyReportUI
// Author£º      lksoulman
// Date£º        2017-11-15
// Comments£º
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
//  KeySet,
  AppContext,
  GaugeBarEx,
  SimpleReport,
  CommonDynArray,
  CommonRefCounter;

type

  // Key Row Data
  TKeyRowData = class(TAutoObject)
  private
    // PKeyItem
//    FKeyItem: PKeyItem;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

//    property KeyItem: PKeyItem read FKeyItem write FKeyItem;
  end;

  // KeyReportUI
  TKeyReportUI = class(TSimpleReport)
  private
    // Back Color
    FBackColor: TColor;
    // Font Color
    FFontColor: TColor;
    // Select Row Back Color
    FSelectRowBackColor: TColor;
    // Select Row Font Color
    FSelectRowFontColor: TColor;

    // App Context
    FAppContext: IAppContext;
    //
    FKeyInfoColumn: TNxTextColumn;
  protected
    // Clear Rows
    procedure DoClearRows;
    // Init Grid Columns
    procedure DoInitGridColumns;

    // Grid Vert Bar Top
    procedure DoGridVertBarTop;
    // Grid Vert Bar Next Row
    procedure DoGridVertBarNextRow;
    // Grid Vert Bar Prior Row
    procedure DoGridVertBarPriorRow;
    // Paint Report Before
    procedure DoGridPaintReportBefore; override;
    // Update Vert Scroll Bar
    procedure DoGridUpdateVertScrollBar; override;
    // Vert Change
    procedure DoGridVertChange(Sender: TObject); override;
    // Mouse Leave
    procedure DoGridMouseLeave(Sender: TObject); override;
    // Wheel Up
    function DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    // Wheel Down
    function DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    // Process Key Down
    function DoGridProcessKeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    // Mouse Move
    procedure DoGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    // Mouse Up
    procedure DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // Mouse Down
    procedure DoGirdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // Draw Cell
    procedure DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState); override;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Init
    procedure InitGridData;
    // Refresh Skin
    procedure RefreshSkin;
    // Load Search Result
//    procedure LoadSearchResult(AKeyItems: TDynArray<PKeyItem>);
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

constructor TKeyReportUI.Create(AOwner: TComponent);
var
  LFont: TFont;
begin
  inherited;
  FVertBar := TGaugeBarEx.Create(nil);
  FVertBar.Parent := Self;
  FVertBar.Align := alCustom;
  FVertBar.Kind := sbVertical;
  FVertBar.OnChange := DoGridVertChange;
  FVertBar.Visible := False;
  FVertBar.Enabled := True;
  FVertBar.RefreshBar;

  LFont := TFont.Create;
  LFont.Name := 'Î¢ÈíÑÅºÚ';
  LFont.Charset := GB2312_CHARSET;
  LFont.Height := -13;
  FG32GraphicBuffer.G32Graphic.UpdateFont(LFont);
  LFont.Free;
end;

destructor TKeyReportUI.Destroy;
begin
  DoClearRows;
  inherited;
end;

procedure TKeyReportUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin

  end;
end;

procedure TKeyReportUI.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TKeyReportUI.InitGridData;
begin
  with FSimpleGrid do begin
    Parent := Self;
    Align := alCustom;
    Options := [goDisableColumnMoving, goSelectFullRow];
    FixedCols := 1;
    BorderStyle := bsNone;
    HeaderSize := 0;
    RowSize := 22;
//    ParentBackground := False;
    ParentColor := False;
    ReadOnly := True;
    GridStyle := gsReport;
    GridLinesStyle := lsActiveHorzOnly;
    AppearanceOptions := [aoHideFocus];
    OnVerticalScroll := DoGridVertScroll;
    HideScrollBar := True;
  end;
  DoInitGridColumns;

  RefreshSkin;
end;

procedure TKeyReportUI.RefreshSkin;
begin
  FBackColor := RGB(26, 26, 26);
  FFontColor := RGB(134, 134, 134);
  FSelectRowBackColor := RGB(89, 89, 89);
  FSelectRowFontColor := RGB(134, 134, 134);

  Color := FBackColor;
  FSimpleGrid.Color := FBackColor;
end;

//procedure TKeyReportUI.LoadSearchResult(AKeyItems: TDynArray<PKeyItem>);
//var
//  LCell: TCell;
//  LIndex: Integer;
//  LPKeyItem: PKeyItem;
//  LKeyRowData: TKeyRowData;
//begin
//  FSimpleGrid.BeginUpdate;
//  try
//    DoClearRows;
//    for LIndex := 0 to AKeyItems.GetCount - 1 do begin
//      LPKeyItem := AKeyItems.GetElement(LIndex);
//      if LPKeyItem <> nil then begin
//        FSimpleGrid.AddRow();
//        LKeyRowData := TKeyRowData.Create;
//        LKeyRowData.KeyItem := LPKeyItem;
//        LCell := FSimpleGrid.Cell[FKeyInfoColumn.Tag, FSimpleGrid.RowCount - 1];
//        LCell.ObjectReference := LKeyRowData;
//      end;
//    end;
//  finally
//    FSimpleGrid.EndUpdate;
//  end;
//  if FSimpleGrid.RowCount > 0 then begin
//    FSimpleGrid.SelectedRow := 0;
//  end;
//end;

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

procedure TKeyReportUI.DoGridPaintReportBefore;
begin
  FG32GraphicBuffer.G32Graphic.BackColor := FBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(Rect(0, 0, FSimpleGrid.Width, FSimpleGrid.Height));
end;

procedure TKeyReportUI.DoGridUpdateVertScrollBar;
begin
  if FVertBar = nil then Exit;

  FVertBar.Visible := FSimpleGrid.VertScrollBar.Max <> 0;
  if FVertBar.Visible then begin
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
//    if LKeyRowData.KeyItem <> nil then begin
//      FG32GraphicBuffer.G32Graphic.EmptyPolyText('DrawText');
//
//      LSecuCode := LKeyRowData.KeyItem.FPSecuMainItem.FSecuCode;
//      LSecuAbbr := LKeyRowData.KeyItem.FPSecuMainItem.FSecuAbbr;
//      LSecuTypeName := LKeyRowData.KeyItem.FKeySet.Name;
//      if LSecuCode <> '' then begin
//        LCodeRect := CellRect;
//        LCodeRect.Left := LCodeRect.Left + 5;
//        LCodeRect.Right := LCodeRect.Left + 90;
//        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LCodeRect, LSecuCode, gtaLeft);
//      end;
//      if LSecuAbbr <> '' then begin
//        LAbbrRect := CellRect;
//        LAbbrRect.Left := LAbbrRect.Left + 80;
//        LAbbrRect.Right := LAbbrRect.Right - 80;
//        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LAbbrRect, LSecuAbbr, gtaLeft);
//      end;
//      if LSecuTypeName <> '' then begin
//        LNameRect := CellRect;
//        LNameRect.Left := LNameRect.Right - 45;
//        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LNameRect, LSecuTypeName, gtaLeft);
//      end;
//      FG32GraphicBuffer.G32Graphic.Ellipsis := True;
//      FG32GraphicBuffer.G32Graphic.LineColor := LFontColor;
//      FG32GraphicBuffer.G32Graphic.DrawPolyText('DrawText');
//    end;
  end;
end;

end.
