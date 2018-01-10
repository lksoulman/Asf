unit SimpleReport;

interface

uses
  Windows,
  Classes,
  Controls,
  SysUtils,
  Graphics,
  Messages,
  NxGrid,
  NxColumnClasses,
  NxCustomGridControl,
  NxCollection,
  NxColumns,
  NxCells,
  NxClasses,
  NxSharedCommon,
  NxDisplays,
  NxGridCommon,
  System.StrUtils,
  GR32,
  G32Graphic,
  GaugeBarEx,
  GR32_RangeBars,
  CommonRefCounter,
  AppContext;

type

  //
  TOnGridEvent = procedure of object;
  //
  TOnGridContextMenu = procedure (var Message: TWMContextMenu) of object;
  //
  TOnGridProcessKeyDown = function(var Key: Word; Shift: TShiftState): Boolean of object;
  //
  TOnGridMouseWheelMove = function(Shift: TShiftState; MousePos: TPoint): Boolean of object;

  // G32Graphic Buffer
  TG32GraphicBuffer = class(TAutoObject)
  private
    // Bitmap 32
    FBuffer: TBitmap32;
    // G32Graphic
    FG32Graphic: TG32Graphic;
  protected
  public
    // Constructor
    constructor Create(AControl: TCustomControl; ACanvas: TCanvas); reintroduce;
    // Destructor
    destructor Destroy; override;

    property Buffer: TBitmap32 read FBuffer;
    property G32Graphic: TG32Graphic read FG32Graphic;
  end;


  // Style Display Ex
  TStyleDisplayEx = class(TFlatStyleDisplay)
  protected
    //
    FArrowSize: Integer;
    //
    FArrowColor: TColor;
    //
    FG32GraphicBuffer: TG32GraphicBuffer;

    // Draw Arrow
    procedure DrawArrow(X, Y: Integer; Ascending: Boolean); override;
    // Draw Header
    procedure DrawHeaderContent(Column: TNxCustomColumn; R: TRect); override;
  public
    // Draw Header Background
    procedure DrawHeaderBackground(Column: TNxCustomColumn; R: TRect); override;

    property ArrowSize: Integer read FArrowSize write FArrowSize;
    property ArrowColor: TColor read FArrowColor write FArrowColor;
    property G32GraphicBuffer: TG32GraphicBuffer read FG32GraphicBuffer write FG32GraphicBuffer;
  end;

  // Simple Grid
  TSimpleGrid = class(TNextGrid)
  protected
    // AppContext
    FAppContext: IAppContext;
    // Style Display
    FStyleDisplay: TStyleDisplayEx;
    // Paint Report After
    FOnPaintReportAfter: TOnGridEvent;
    // Paint Report Before
    FOnPaintReportBefore: TOnGridEvent;
    // Update Horz Scroll Bar
    FOnUpdateHorzScrollBar: TOnGridEvent;
    // Update Vert Scrool Bar
    FOnUpdateVertScrollBar: TOnGridEvent;
    // Context Menu
    FOnContextMenu: TOnGridContextMenu;
    // Mouse Wheel Up
    FOnMouseWheelUp: TOnGridMouseWheelMove;
    // Mouse Wheel Down
    FOnMouseWheelDown: TOnGridMouseWheelMove;
    // Process Key Down
    FOnProcessKeyDown: TOnGridProcessKeyDown;

    // PaintReport
    procedure PaintReport; override;
    // UpdateHorzScrollBar
    procedure UpdateHorzScrollBar; override;
    // UpdateVertScrollBar
    procedure UpdateVertScrollBar; override;
    // RecreateStyleDisplay
    procedure RecreateStyleDisplay; override;
    // WndProc
    procedure WndProc(var Message: TMessage); override;
    // ProcessKeyDown
    procedure ProcessKeyDown(var Key: Word; Shift: TShiftState); override;
    // WMContextMenu
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    //
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // InitStyleDisplay
    procedure InitStyleDisplay(AG32GraphicBuffer: TG32GraphicBuffer);

    property StyleDisplay: TStyleDisplayEx read FStyleDisplay;
    property OnContextMenu: TOnGridContextMenu read FOnContextMenu write FOnContextMenu;
    property OnMouseWheelUp: TOnGridMouseWheelMove read FOnMouseWheelUp write FOnMouseWheelUp;
    property OnMouseWheelDown: TOnGridMouseWheelMove read FOnMouseWheelDown write FOnMouseWheelDown;
    property OnProcessKeyDown: TOnGridProcessKeyDown read FOnProcessKeyDown write FOnProcessKeyDown;
    property OnPaintReportAfter: TOnGridEvent read FOnPaintReportAfter write FOnPaintReportAfter;
    property OnPaintReportBefore: TOnGridEvent read FOnPaintReportBefore write FOnPaintReportBefore;
    property OnUpdateHorzScrollBar: TOnGridEvent read FOnUpdateHorzScrollBar write FOnUpdateHorzScrollBar;
    property OnUpdateVertScrollBar: TOnGridEvent read FOnUpdateVertScrollBar write FOnUpdateVertScrollBar;
  end;

  // Class
  TSimpleGridClass = class of TSimpleGrid;

  // Simple Report
  TSimpleReport = class(TNxPanel)
  private
  protected
    // HorzBar
    FHorzBar: TGaugeBarEx;
    // VertBar
    FVertBar: TGaugeBarEx;
    // AppContext
    FAppContext: IAppContext;
    // FSimpleGrid
    FSimpleGrid: TSimpleGrid;
    // SimpleGridClass
    FSimpleGridClass: TSimpleGridClass;
    // G32Graphic Buffer
    FG32GraphicBuffer: TG32GraphicBuffer;

    // BeforeCreate
    procedure BeforeCreate; virtual;
    // InitGridEvent
    procedure InitGridEvent; virtual;

    // Resize
    procedure Resize; override;
    // ResetPos
    procedure DoResetPos; virtual;
    // PaintReportAfter
    procedure DoGridPaintReportAfter; virtual;
    // PaintReportBefore
    procedure DoGridPaintReportBefore; virtual;
    // UpdateVertScrollBar
    procedure DoGridUpdateVertScrollBar; virtual;
    // UpdateHorz ScrollBar
    procedure DoGridUpdateHorzScrollBar; virtual;
    // Resize
    procedure DoGridResize(Sender: TObject); virtual;
    // VertChange
    procedure DoGridVertChange(Sender: TObject); virtual;
    // HorzChange
    procedure DoGridHorzChange(Sender: TObject); virtual;
    // MouseLeave
    procedure DoGridMouseLeave(Sender: TObject); virtual;
    // MouseEnter
    procedure DoGridMouseEnter(Sender: TObject); virtual;
    // ContextMenu
    procedure DoGridContextMenu(var Message: TWMContextMenu); virtual;
    // VertScroll
    procedure DoGridVertScroll(Sender: TObject; Position: Integer); virtual;
    // HorzScroll
    procedure DoGridHorzScroll(Sender: TObject; Position: Integer); virtual;
    // WheelUp
    function DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; virtual;
    // WheelDown
    function DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; virtual;
    // ProcessKeyDown
    function DoGridProcessKeyDown(var Key: Word; Shift: TShiftState): Boolean; virtual;
    // MouseMove
    procedure DoGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
    // MouseUp
    procedure DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    // MouseDown
    procedure DoGirdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    // DrawCell
    procedure DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState); virtual;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // MouseWheelHandler
    procedure MouseWheelHandler(var Message: TMessage); override;
  end;

implementation


{ TG32GraphicBuffer }

constructor TG32GraphicBuffer.Create(AControl: TCustomControl; ACanvas: TCanvas);
begin
  inherited Create;
  FBuffer := TBitmap32.Create;
  FBuffer.SetSize(1, 1);
  FG32Graphic := TG32Graphic.Create(AControl, FBuffer, ACanvas);
end;

destructor TG32GraphicBuffer.Destroy;
begin
  FG32Graphic.Free;
  FBuffer.Free;
  inherited;
end;

{ TStyleDisplayEx }

procedure TStyleDisplayEx.DrawHeaderContent(Column: TNxCustomColumn; R: TRect);
var
  CaptionRect, InvertRect: TRect;
  CaptionWidth: Integer;
  ArrowPos, TextPos: TPoint;
  ACaption: string;
begin
  with Canvas, Column.Header do begin
    CaptionWidth := 0;
    case Orientation of
      hoHorizontal:
        if DisplayMode <> dmImageOnly then
        begin
          if Column.Header.MultiLine then
            CaptionWidth := GetMultilineTextWidth(Canvas, Caption)
          else
            CaptionWidth := GetTextWidth(Canvas, Caption);
          Inc(CaptionWidth, spTextToImageDist);
        end;
    end;

    if not(Glyph.Empty or (DisplayMode = dmTextOnly)) then begin
      inherited DrawHeaderContent(Column, R);
    end
    else
    begin
      case Alignment of
        taLeftJustify:
          TextPos.X := R.Left + spHeaderMargin;
        taRightJustify:
          begin
            TextPos.X := R.Right - CaptionWidth - spHeaderMargin;
            if Column.Sorted then
            begin
              Dec(TextPos.X, FArrowSize * 2);
            end;
            if TextPos.X < R.Left then
              TextPos.X := R.Left;
          end;
        taCenter:
          if CaptionWidth < (R.Right - R.Left) then
            TextPos.X := R.Left + ((R.Right - R.Left - CaptionWidth) shr 1);
      end;
    end;

    { Render Text }
    if DisplayMode <> dmImageOnly then
    begin
      ACaption := Caption;
      // 防止在向右对其列排序时，列头绘制出错
      if (TextPos.X < R.Left) then
      begin
        while (TextPos.X < R.Left) do
        begin
          ACaption := MidStr(ACaption, 2, Length(ACaption) - 1);
          TextPos.X := R.Right - GetTextWidth(Canvas, ACaption) - spHeaderMargin;
          if Column.Sorted then
          begin
            Dec(TextPos.X, FArrowSize * 2);
          end;
          if TextPos.X < R.Left then
            TextPos.X := R.Left;
        end;
      end;
      CaptionRect := Rect(TextPos.X, R.Top, R.Right, R.Bottom);
      AdjustTextRect(CaptionRect);
      case Orientation of
        hoHorizontal:
          DoDrawText(Canvas, CaptionRect, ACaption, Column.Header.MultiLine);
      end;
    end;
  end;

  if not DefaultDrawing then
    Exit;

  if Column.Sorted then
  begin
    ArrowPos.Y := R.Top + (R.Bottom - R.Top) div 2 - siSortArrowHeight div 2 - 1;
    ArrowPos.X := TextPos.X + CaptionWidth;
    if ((ArrowPos.X + siSortArrowWidth < R.Right) or not Column.Header.HideArrow) and
      not(sdaCustomArrow in StyleDisplayAttributes) then
    begin
      if (Column.Header.Caption <> '') then
        DrawArrow(ArrowPos.X, ArrowPos.Y, Column.SortKind = skAscending)
      else
        DrawArrow(ArrowPos.X - 8, ArrowPos.Y, Column.SortKind = skAscending);
    end;
  end;

  if (Column.Focused) and (sdaInvertFocus in StyleDisplayAttributes) then
  begin
    with R do
    begin
      if not Column.IsAlone then
        InvertRect := Rect(Left, Top, Right - 1, Bottom)
      else
        InvertRect := Rect(Left - 1, Top - 1, Right, Bottom);
      Canvas.CopyMode := cmDstInvert;
      Canvas.CopyRect(InvertRect, Canvas, InvertRect);
      Canvas.CopyMode := cmSrcCopy;
    end;
  end;
end;

procedure TStyleDisplayEx.DrawArrow(X, Y: Integer; Ascending: Boolean);
var
  tmpX, tmpTop, tmpBottom, tmpIndex, tmpCount: Integer;
begin
  tmpCount := 3;
  Canvas.Pen.Color := FArrowColor;
  tmpX := X + 3; //(_Rect.Left + _Rect.Right) div 2;
  case Ascending of
    True:
      begin
        tmpTop := Y;
        tmpBottom := Y + FArrowSize;
        Canvas.Pen.Color := FArrowColor;
        for tmpIndex := 0 to tmpCount do
        begin
          Canvas.MoveTo(tmpX - tmpIndex, tmpTop + tmpIndex);
          Canvas.LineTo(tmpX + tmpIndex, tmpTop + tmpIndex);
        end;

        tmpX := tmpX - 1;
        tmpTop := tmpTop + tmpCount;
        tmpCount := 1;
        for tmpIndex := 0 to tmpCount do
        begin
          Canvas.MoveTo(tmpX + tmpIndex, tmpTop);
          Canvas.LineTo(tmpX + tmpIndex, tmpBottom);
        end;
      end;
    False:
      begin
        tmpTop := Y;
        tmpBottom := Y + FArrowSize;
        Canvas.Pen.Color := FArrowColor;
        for tmpIndex := 0 to tmpCount do
        begin
          Canvas.MoveTo(tmpX - tmpIndex, tmpBottom - tmpIndex);
          Canvas.LineTo(tmpX + tmpIndex, tmpBottom - tmpIndex);
        end;

        tmpX := tmpX - 1;
        tmpBottom := tmpBottom - tmpCount;
        tmpCount := 1;
        for tmpIndex := 0 to tmpCount do
        begin
          Canvas.MoveTo(tmpX + tmpIndex, tmpTop);
          Canvas.LineTo(tmpX + tmpIndex, tmpBottom);
        end;
      end;
  else

  end;
end;

procedure TStyleDisplayEx.DrawHeaderBackground(Column: TNxCustomColumn; R: TRect);
begin
  with Canvas, R do
  begin
    Brush.Color := Column.Header.Color;
    FillRect(R);
  end;
end;

{ TSimpleGrid }

constructor TSimpleGrid.Create(AContext: IAppContext);
begin
  inherited Create(nil);
  FAppContext := AContext;
  FStyleDisplay := TStyleDisplayEx.Create(nil);
end;

destructor TSimpleGrid.Destroy;
begin
  // NextGrid 如果显示而且有焦点，释放的时先设置 visible 为 false, 在释放就不会报错
  if Assigned(FStyleDisplay) then begin
    FStyleDisplay.Free;
  end;
  if Visible then begin
    Visible := False;
  end;
  inherited;
end;

procedure TSimpleGrid.InitStyleDisplay(AG32GraphicBuffer: TG32GraphicBuffer);
begin
  FStyleDisplay.G32GraphicBuffer := AG32GraphicBuffer;
end;

procedure TSimpleGrid.PaintReport;
begin
  if Assigned(FOnPaintReportBefore) then begin
    FOnPaintReportBefore;
  end;
  inherited PaintReport;
  if Assigned(FOnPaintReportAfter) then begin
    FOnPaintReportAfter;
  end;
end;

procedure TSimpleGrid.UpdateHorzScrollBar;
begin
  inherited UpdateHorzScrollBar;
  if Assigned(FOnUpdateHorzScrollBar) then begin
    FOnUpdateHorzScrollBar;
  end;
end;

procedure TSimpleGrid.UpdateVertScrollBar;
begin
  inherited UpdateVertScrollBar;
  if Assigned(FOnUpdateVertScrollBar) then begin
    FOnUpdateVertScrollBar;
  end;
end;

procedure TSimpleGrid.RecreateStyleDisplay;
begin
  CurrentStyleDisplay := FStyleDisplay;
  CurrentStyleDisplay.Canvas := Canvas;
  Invalidate;
  RedrawBorder;
end;

procedure TSimpleGrid.WndProc(var Message: TMessage);
var
  LStyle: Integer;
begin
  if (Message.Msg = WM_NCCALCSIZE) then begin
    LStyle := GetWindowLong(Handle, GWL_STYLE);
    if (LStyle and (WS_HSCROLL or WS_VSCROLL)) <> 0 then begin
      SetWindowLong(Handle, GWL_STYLE, LStyle and not(WS_HSCROLL or WS_VSCROLL));
    end;
  end;
  if (Message.Msg = WM_SETFOCUS) then begin
    inherited;
  end else begin
    inherited;
  end;
end;

procedure TSimpleGrid.WMContextMenu(var Message: TWMContextMenu);
begin
  if Assigned(FOnContextMenu) then begin
    FOnContextMenu(Message);
  end;
end;

procedure TSimpleGrid.ProcessKeyDown(var Key: Word; Shift: TShiftState);
var
  tmpPt: TPoint;
begin
  tmpPt := Mouse.CursorPos;
  if PtInRect(GetClientRect, tmpPt) then begin
    inherited ProcessKeyDown(Key, Shift);
    if Assigned(FOnProcessKeyDown) then
      FOnProcessKeyDown(Key, Shift);
  end;
end;

function TSimpleGrid.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
  if Assigned(FOnMouseWheelUp) then begin
    Result := FOnMouseWheelUp(Shift, MousePos);
  end;
end;

function TSimpleGrid.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
  if Assigned(FOnMouseWheelDown) then begin
    Result := FOnMouseWheelDown(Shift, MousePos);
  end;
end;

{ TSimpleReport }

constructor TSimpleReport.Create(AParent: TWinControl; AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited Create(nil);
  Parent := AParent;
  BeforeCreate;
  FSimpleGrid := FSimpleGridClass.Create(FAppContext);
  FSimpleGrid.Parent := Self;
  FSimpleGrid.Align := alClient;
  FG32GraphicBuffer := TG32GraphicBuffer.Create(FSimpleGrid, FSimpleGrid.Canvas);
  FSimpleGrid.InitStyleDisplay(FG32GraphicBuffer);
  InitGridEvent;
end;

destructor TSimpleReport.Destroy;
begin
  FG32GraphicBuffer.Free;
  FSimpleGrid.Free;
  if FVertBar <> nil then begin
    FVertBar.Free;
    FVertBar := nil;
  end;
  if FHorzBar <> nil then begin
    FHorzBar.Free;
    FHorzBar := nil;
  end;
  inherited;
  FAppContext := nil;
end;

procedure TSimpleReport.MouseWheelHandler(var Message: TMessage);
var
  LPt: TPoint;
begin
  inherited;
//  LPt := ScreenToClient(Mouse.CursorPos);
//  if PtInRect(Self.GetClientRect, LPt) then begin
//    Message.Result := FVertBar.Perform(CM_MOUSEWHEEL, -Message.WParam,
//      Message.LParam);
//  end;
end;

procedure TSimpleReport.BeforeCreate;
begin
  FSimpleGridClass := TSimpleGrid;
end;

procedure TSimpleReport.InitGridEvent;
begin
//  FSimpleGrid.OnResize := DoGridResize;
  FSimpleGrid.OnMouseUp := DoGridMouseUp;
  FSimpleGrid.OnMouseDown := DoGirdMouseDown;
  FSimpleGrid.OnMouseMove := DoGridMouseMove;
  FSimpleGrid.OnMouseLeave := DoGridMouseLeave;
  FSimpleGrid.OnMouseEnter := DoGridMouseEnter;
  FSimpleGrid.OnMouseWheelUp := DoGridWheelUp;
  FSimpleGrid.OnMouseWheelDown := DoGridWheelDown;
  FSimpleGrid.OnContextMenu := DoGridContextMenu;
  FSimpleGrid.OnCustomDrawCell := DoGridCustomDrawCell;
  FSimpleGrid.OnProcessKeyDown := DoGridProcessKeyDown;
  FSimpleGrid.OnPaintReportAfter := DoGridPaintReportAfter;
  FSimpleGrid.OnPaintReportBefore := DoGridPaintReportBefore;
  FSimpleGrid.OnUpdateVertScrollBar := DoGridUpdateVertScrollBar;
  FSimpleGrid.OnUpdateHorzScrollBar := DoGridUpdateHorzScrollBar;
end;

procedure TSimpleReport.Resize;
begin
  inherited;
  DoResetPos;
  DoGridResize(nil);
end;

procedure TSimpleReport.DoResetPos;
var
  LWidth, LHeight: Integer;
begin
  if (FVertBar <> nil)
    and (FVertBar.Visible) then begin
    LWidth := Width - FVertBar.Width;
    FVertBar.Top := 0;
    FVertBar.Left := Width - FVertBar.Width;
  end else begin
    LWidth := Width;
  end;

  if (FHorzBar <> nil)
    and (FHorzBar.Visible) then begin
    LHeight := Height - FHorzBar.Height;
    FHorzBar.Top := LHeight - FHorzBar.Height;
    FHorzBar.Left := 0;
  end else begin
    LHeight := Height;
  end;

  FSimpleGrid.Width := LWidth;
  FSimpleGrid.Height := LHeight;
end;

procedure TSimpleReport.DoGridPaintReportAfter;
var
  tmpRect: TRect;
begin
  tmpRect := Rect(0, FSimpleGrid.HeaderSize, FSimpleGrid.Width, FSimpleGrid.Height);
  if (FSimpleGrid.HandleAllocated)
    and (FG32GraphicBuffer.Buffer <> nil) then begin
    FSimpleGrid.Canvas.Lock;
    try
      DrawCopyRect(FSimpleGrid.Canvas.Handle, tmpRect, FG32GraphicBuffer.Buffer.Handle, tmpRect);
    finally
      FSimpleGrid.Canvas.UnLock;
    end;
  end;
end;

procedure TSimpleReport.DoGridPaintReportBefore;
begin

end;

procedure TSimpleReport.DoGridUpdateHorzScrollBar;
begin

end;

procedure TSimpleReport.DoGridUpdateVertScrollBar;
begin

end;

procedure TSimpleReport.DoGridResize(Sender: TObject);
begin
  if (FG32GraphicBuffer.Buffer <> nil)
    and ((FSimpleGrid.Width <> FG32GraphicBuffer.Buffer.Width)
          or (FSimpleGrid.Height <> FG32GraphicBuffer.Buffer.Height)) then
  begin
    FG32GraphicBuffer.Buffer.Lock;
    try
      FG32GraphicBuffer.Buffer.SetSize(FSimpleGrid.Width, FSimpleGrid.Height);
      FG32GraphicBuffer.G32Graphic.GraphicReset;
      FG32GraphicBuffer.G32Graphic.BackColor := clWhite;
      FG32GraphicBuffer.G32Graphic.Clear;
    finally
      FG32GraphicBuffer.Buffer.UnLock;
    end;
  end;
end;

procedure TSimpleReport.DoGridVertChange(Sender: TObject);
begin

end;

procedure TSimpleReport.DoGridHorzChange(Sender: TObject);
begin

end;

procedure TSimpleReport.DoGridMouseEnter(Sender: TObject);
begin

end;

procedure TSimpleReport.DoGridMouseLeave(Sender: TObject);
begin

end;

procedure TSimpleReport.DoGridContextMenu(var Message: TWMContextMenu);
begin

end;

procedure TSimpleReport.DoGridHorzScroll(Sender: TObject; Position: Integer);
begin

end;

procedure TSimpleReport.DoGridVertScroll(Sender: TObject; Position: Integer);
begin

end;

function TSimpleReport.DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TSimpleReport.DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TSimpleReport.DoGridProcessKeyDown(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
end;

procedure TSimpleReport.DoGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TSimpleReport.DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TSimpleReport.DoGirdMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TSimpleReport.DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState);
begin

end;

end.
