unit AxGrid;

interface

uses
  Windows,
  Classes,
  SysUtils,
  FrameUI,
  RenderDC,
  RenderGDI,
  RenderUtil,
  CommonLock,
  ComponentUI,
  CommonRefCounter,
  Generics.Collections;

type

  //
  TAxCustomGrid = class;

  // Cell
  TAxCustomCell = class(TAutoObject)
  private
    //
    FValue: string;
    //
    FRectEx: TRect;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // Class
  TAxCustomCellClass = class of TAxCustomCell;

  // Data Object
  TAxDataObject = class(TAutoObject)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // Row
  TAxCustomRow = class(TAutoObject)
  private
    // Top
    FTop: Integer;
    // Data Object
    FDataObject: TAxDataObject;
  protected
  public
   // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    property Top: Integer read FTop write FTop;
    property DataObject: TAxDataObject read FDataObject write FDataObject;
  end;

  // Class
  TAxCustomRowClass = class of TAxCustomRow;

  // Row
  TAxCustomRows = class(TAutoObject)
  private
    // Rows
    FCustomRows: TList<TAxCustomRow>;
  protected
  public
   // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Clear Column;
    procedure ClearRows;
    // Add Row
    procedure AddRow(ARow: TAxCustomRow);
    // Get Row Count
    function GetRowCount: Integer;
    // Get Row
    function GetRow(AIndex: Integer): TAxCustomRow;
    //
    function GetRowHeights(ARowHeight: Integer): Integer;
  end;

  // Column
  TAxCustomColumn = class(TAutoObject)
  private
    // Name
    FName: string;
    // Left
    FLeft: Integer;
    // Width
    FWidth: Integer;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    property Name: string read FName write FName;
    property Left: Integer read FLeft write FLeft;
    property Width: Integer read FWidth write FWidth;
  end;

  // Class
  TAxCustomColumnClass = class of TAxCustomColumn;

  // Column
  TAxCustomColumns = class(TAutoObject)
  private
    //
    FIsCalcWidth: Boolean;
    //
    FColumnWidths: Integer;
    // Columns
    FCustomColumns: TList<TAxCustomColumn>;
  protected
    // Get Column Width
    function GetColumnWidths: Integer;
  public
   // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Clear Column;
    procedure ClearColumns;
    // Add Column
    procedure AddColumn(AColumn: TAxCustomColumn);

    // Get Column Count
    function GetColumnCount: Integer;
    // Get Column
    function GetColumn(AIndex: Integer): TAxCustomColumn;

    property ColumnWidths: Integer read GetColumnWidths;
  end;

  //
  TAxScrollBar = class(TComponentUI)
  private
    // Pos
    FPos: Integer;
    // Size
    FSize: Integer;
    // Bar Rect
    FBarRectEx: TRect;
    // Block Rect
    FBlockRectEx: TRect;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Calc Rect
    procedure CalcRects; virtual;
    // Is valid Rect
    function IsValidRect: Boolean; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;

    property Size: Integer read FSize write FSize;
  end;
//
//  TAxVertScrollBar = class(TAxScrollBar)
//  private
//  protected
//  public
//    // Constructor
//    constructor Create; override;
//    // Destructor
//    destructor Destroy; override;
//  end;
//
//  TAxHorzScrollBar = class(TAxScrollBar)
//  private
//  protected
//  public
//    // Constructor
//    constructor Create; override;
//    // Destructor
//    destructor Destroy; override;
//  end;

  // Grid
  TAxCustomGrid = class(TFrameUI)
  private
    // Body Rect
    FBodyRect: TRect;
    // Header Rect
    FHeaderRect: TRect;
    // Vert Bar
    FVertBarRect: TRect;
    // Horz Bar
    FHorzBarRect: TRect;

    // Row Height
    FRowHeight: Integer;
    // Row Height
    FHeaderHeight: Integer;
    // Scroll Bar Size
    FScrollBarSize: Integer;

    //
    FIsHasVert: Boolean;
    //
    FIsHasHorz: Boolean;
    // Is Updating
    FIsUpdating: Boolean;
    // Update Lock
    FUpdateLock: TCSLock;
    // Last Row Index
    FLastRowIndex: Integer;
    // First Row Index;
    FFirstRowIndex: Integer;
    // Last Column Index
    FLastColumnIndex: Integer;
    // First Column Index
    FFirstColumnIndex: Integer;
    // Row Object
    FRowObjects: TAxCustomRows;
    // Column Object
    FColumnObjects: TAxCustomColumns;
  protected
    // Calc Grid
    procedure DoCalcRect;
    // Calc Index
    procedure DoCalcRowIndexs;
    // Calc Index
    procedure DoCalcColumnIndexs;
    // Draw Grid Body
    procedure DoDrawGridBody;
    // Draw Grid Header
    procedure DoDrawGridHeaders;
    // Draw Grid Cell
    procedure DoDrawGridCell(ACol, ARow: Integer; ACellRect: TRect);
    // Draw Grid Column Header
    procedure DoDrawGridColumnHeader(AColumn: TAxCustomColumn; AHeaderRect: TRect);

    // Size
    procedure DoSize(AWidth: Integer; AHeight: Integer); override;
    // Paint Backgroud
    procedure DoPaintBackground(AInvalidateRect: TRect); override;
    // Paint Components
    procedure DoPaintComponents(AInvalidateRect: TRect); override;
    // Mouse Move
    procedure DoMouseMove(AMousePt: TPoint; AKeys: Integer); override;
    // Click Component
    procedure DoClickComponent(AComponent: TComponentUI); override;
    // Find Component
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;
    // Clear
    procedure ClearRows;
  end;


implementation

{ TAxCustomCell }

constructor TAxCustomCell.Create;
begin
  inherited;

end;

destructor TAxCustomCell.Destroy;
begin

  inherited;
end;

{ TAxDataObject }

constructor TAxDataObject.Create;
begin
  inherited;

end;

destructor TAxDataObject.Destroy;
begin

  inherited;
end;

{ TAxCustomRow }

constructor TAxCustomRow.Create;
begin
  inherited;

end;

destructor TAxCustomRow.Destroy;
begin

  inherited;
end;

{ TAxCustomRows }

constructor TAxCustomRows.Create;
begin
  inherited;

end;

destructor TAxCustomRows.Destroy;
begin

  inherited;
end;

procedure TAxCustomRows.ClearRows;
var
  LIndex: Integer;
  LCustomRow: TAxCustomRow;
begin
  for LIndex := 0 to FCustomRows.Count - 1 do begin
    LCustomRow := FCustomRows.Items[LIndex];
    if LCustomRow <> nil then begin
      LCustomRow.Free;
    end;
  end;
  FCustomRows.Clear;
end;

procedure TAxCustomRows.AddRow(ARow: TAxCustomRow);
begin
  FCustomRows.Add(ARow);
end;

function TAxCustomRows.GetRowCount: Integer;
begin
  Result := FCustomRows.Count;
end;

function TAxCustomRows.GetRow(AIndex: Integer): TAxCustomRow;
begin
  if (AIndex >= 0) and (AIndex < FCustomRows.Count) then begin
    Result := FCustomRows.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TAxCustomRows.GetRowHeights(ARowHeight: Integer): Integer;
begin
  Result := FCustomRows.Count * ARowHeight;
end;

{ TAxCustomColumn }

constructor TAxCustomColumn.Create;
begin
  inherited;

end;

destructor TAxCustomColumn.Destroy;
begin

  inherited;
end;

{ TAxCustomColumns }

constructor TAxCustomColumns.Create;
begin
  inherited;
  FCustomColumns := TList<TAxCustomColumn>.Create;
end;

destructor TAxCustomColumns.Destroy;
begin
  ClearColumns;
  FCustomColumns.Free;
  inherited;
end;

procedure TAxCustomColumns.ClearColumns;
var
  LIndex: Integer;
  LColumn: TAxCustomColumn;
begin
  for LIndex := 0 to FCustomColumns.Count - 1 do begin
    LColumn := FCustomColumns.Items[LIndex];
    LColumn.Free;
  end;
  FCustomColumns.Clear;
end;

procedure TAxCustomColumns.AddColumn(AColumn: TAxCustomColumn);
begin
  if AColumn = nil then Exit;

  if FCustomColumns.IndexOf(AColumn) < 0 then begin
    FCustomColumns.Add(AColumn);
  end;
end;

function TAxCustomColumns.GetColumnCount: Integer;
begin
  Result := FCustomColumns.Count;
end;

function TAxCustomColumns.GetColumn(AIndex: Integer): TAxCustomColumn;
begin
  if (AIndex >= 0) and (AIndex < FCustomColumns.Count) then begin
    Result := FCustomColumns.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TAxCustomColumns.GetColumnWidths: Integer;
var
  LIndex: Integer;
  LColumn: TAxCustomColumn;
begin
  if not FIsCalcWidth then begin
    FColumnWidths := 0;
    for LIndex := 0 to FCustomColumns.Count - 1 do begin
      LColumn := FCustomColumns.Items[LIndex];
      LColumn.Free;
    end;
  end;
  Result := FColumnWidths;
end;

{ TAxScrollBar }

constructor TAxScrollBar.Create;
begin
  inherited;

end;

destructor TAxScrollBar.Destroy;
begin

  inherited;
end;

procedure TAxScrollBar.CalcRects;
begin

end;

function TAxScrollBar.IsValidRect: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

procedure TAxScrollBar.Paint(ARenderDC: TRenderDC);
begin

end;

{ TAxCustomGrid }

constructor TAxCustomGrid.Create(AOwner: TComponent);
begin
  inherited;
  FRowHeight := 28;
  FHeaderHeight := 30;
  FScrollBarSize := 28;
  FIsUpdating := False;
  FUpdateLock := TCSLock.Create;
  FRowObjects := TAxCustomRows.Create;
  FColumnObjects := TAxCustomColumns.Create;
end;

destructor TAxCustomGrid.Destroy;
begin
  ClearRows;
  FColumnObjects.Free;
  FRowObjects.Free;
  FUpdateLock.Free;
  inherited;
end;

procedure TAxCustomGrid.ClearRows;
begin

  FRowObjects.ClearRows;
end;

procedure TAxCustomGrid.DoCalcRect;
var
  LRect: TRect;
  LBodyWidth, LBodyHeight: Integer;
begin
  FIsHasHorz := False;
  FIsHasHorz := False;
  LRect := FFrameRectEx;
  if (LRect.Top + FHeaderHeight < LRect.Bottom) then begin
    LRect.Bottom := LRect.Top + FHeaderHeight;
  end;
  FHeaderRect := LRect;

  LRect := FFrameRectEx;
  LRect.Top := FHeaderRect.Bottom;

  FBodyRect := LRect;

  LBodyWidth := FColumnObjects.ColumnWidths;
  LBodyHeight := FRowObjects.GetRowHeights(FRowHeight);

  if LRect.Left + LBodyWidth <= LRect.Right then begin
//    FBodyRect.Right := FBodyRect.Left + LBodyWidth;
    FIsHasVert := False;
  end else begin
    FIsHasVert := True;
    if LRect.Top + LBodyHeight <= LRect.Bottom - FScrollBarSize then begin
//      LRect.Bottom := LRect.Top + LBodyHeight;
      FIsHasHorz := False;
    end else begin
      FIsHasHorz := True;
    end;
  end;

  if not FIsHasHorz then begin
    if LRect.Top + LBodyHeight < LRect.Bottom then begin
//      LRect.Bottom := LRect.Top + LBodyHeight;
      FIsHasHorz := False;
    end else begin
      FIsHasHorz := True;
      if LRect.Left + LBodyWidth <= LRect.Right - FScrollBarSize then begin
//        LRect.Right := LRect.Left + LBodyWidth;
        FIsHasVert := False;
      end else begin
        FIsHasVert := True;
      end;
    end;
  end;

  if FIsHasVert and FIsHasHorz then begin
    FBodyRect.Right := FBodyRect.Right - FScrollBarSize;
    FBodyRect.Bottom := FBodyRect.Bottom - FScrollBarSize;
    if FBodyRect.Right < FBodyRect.Left then begin
      FBodyRect.Right := FBodyRect.Left;
    end;

    if FBodyRect.Bottom < FBodyRect.Top then begin
      FBodyRect.Bottom := FBodyRect.Top;
    end;

    FVertBarRect := LRect;
    FVertBarRect.Left := FBodyRect.Right;
    FVertBarRect.Bottom := FBodyRect.Bottom;

    FHorzBarRect := LRect;
    FHorzBarRect.Top := FBodyRect.Bottom;
    FHorzBarRect.Right := FBodyRect.Right;
  end else if (not FIsHasVert) and FIsHasHorz then begin
    FBodyRect.Right := FBodyRect.Right - FScrollBarSize;
    if FBodyRect.Right < FBodyRect.Left then begin
      FBodyRect.Right := FBodyRect.Left;
    end;

    FVertBarRect.Left := FBodyRect.Right;
  end else if FIsHasVert and (not FIsHasHorz) then begin
    FBodyRect.Bottom := FBodyRect.Bottom - FScrollBarSize;
    if FBodyRect.Bottom < FBodyRect.Top then begin
      FBodyRect.Bottom := FBodyRect.Top;
    end;
    FVertBarRect.Bottom := FBodyRect.Bottom;
  end;
end;

procedure TAxCustomGrid.DoCalcRowIndexs;
var
  LCustomRow: TAxCustomRow;
  LRowCount, LColumnTotalCount, LMod, LIndex, LHeight: Integer;
begin
  if FRowHeight = 0 then Exit;

  LHeight := 0;
  FLastRowIndex := FFirstRowIndex;
  LRowCount := FRowObjects.GetRowCount;
  while FLastRowIndex < LRowCount - 1 do begin
    LCustomRow := FRowObjects.GetRow(FLastRowIndex);
    if LCustomRow <> nil then begin
      LHeight := LHeight + FRowHeight;
      if LHeight >= self.FBodyRect.Height then begin
        Break;
      end;
    end;
    Inc(FLastRowIndex);
  end;
end;

procedure TAxCustomGrid.DoCalcColumnIndexs;
var
  LColumnCount, LWidth: Integer;
  LCustomColumn: TAxCustomColumn;
begin
  LWidth := 0;
  FLastColumnIndex := FFirstColumnIndex;
  LColumnCount := FColumnObjects.GetColumnCount;
  while FLastColumnIndex < LColumnCount - 1 do begin
    LCustomColumn := FColumnObjects.GetColumn(FLastColumnIndex);
    if LCustomColumn <> nil then begin
      LWidth := LWidth + LCustomColumn.Width;
      if LWidth >= FBodyRect.Width then begin
        Break;
      end;
    end;
    Inc(FLastColumnIndex);
  end;
end;

procedure TAxCustomGrid.DoDrawGridBody;
var
  LRect: TRect;
  I, J: Integer;
  LCustomRow: TAxCustomRow;
  LCustomColumn: TAxCustomColumn;
begin
  for I := FFirstRowIndex to FLastRowIndex do begin
    LCustomRow := FRowObjects.GetRow(I);
    if LCustomRow <> nil then begin
      for J := FFirstColumnIndex to FLastColumnIndex do begin
        LCustomColumn := FColumnObjects.GetColumn(J);
        if LCustomColumn <> nil then begin

        end;
      end;
    end;
  end;
end;

procedure TAxCustomGrid.DoDrawGridHeaders;
var
  LRect: TRect;
  LIndex: Integer;
  LCustomColumn: TAxCustomColumn;
begin
  LRect := FHeaderRect;
  for LIndex := FFirstColumnIndex to FLastColumnIndex do begin
    LCustomColumn := FColumnObjects.GetColumn(LIndex);
    if LCustomColumn <> nil then begin
      LRect.Left := LCustomColumn.Left;
      LRect.Right := LCustomColumn.Left + LCustomColumn.Width;
      DoDrawGridColumnHeader(LCustomColumn, LRect);
    end;
  end;
end;

procedure TAxCustomGrid.DoDrawGridCell(ACol, ARow: Integer; ACellRect: TRect);
begin

end;

procedure TAxCustomGrid.DoDrawGridColumnHeader(AColumn: TAxCustomColumn; AHeaderRect: TRect);
begin

end;

procedure TAxCustomGrid.DoSize(AWidth: Integer; AHeight: Integer);
begin
  inherited;

end;

procedure TAxCustomGrid.DoPaintBackground(AInvalidateRect: TRect);
begin
    FillSolidRect(FFrameRenderDC.MemDC, @AInvalidateRect, APPC_MAINFORM_SUPERTAB_BACK);
end;

procedure TAxCustomGrid.DoPaintComponents(AInvalidateRect: TRect);
begin

end;

procedure TAxCustomGrid.DoMouseMove(AMousePt: TPoint; AKeys: Integer);
begin

end;

procedure TAxCustomGrid.DoClickComponent(AComponent: TComponentUI);
begin

end;

function TAxCustomGrid.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
begin

end;

end.