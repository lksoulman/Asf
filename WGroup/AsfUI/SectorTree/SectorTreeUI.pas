unit SectorTreeUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SectorTreeUI
// Author：      lksoulman
// Date：        2018-1-12
// Comments：
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
  Vcl.Imaging.pngimage,
  NxGrid,
  NxCells,
  NxClasses,
  NxColumns,
  NxColumnClasses,
  NxCollection,
  NxCustomGridControl,
  MsgEx,
  Command,
  ButtonUI,
  Sector,
  SectorMgr,
  Attention,
  CommonPool,
  AppContext,
  G32Graphic,
  G32GaugeBar,
  SimpleReport,
  CustomBaseUI,
  CommonRefCounter,
  UserAttentionMgr,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // DefaultData
  TDefaultData = packed record
    FId: Integer;
    FName: string;
  end;

  // AttetionSectorReport
  TAttetionSectorReport = class;

  // SectorRowData
  TSectorRowData = class(TAutoObject)
  private
    // SectorId
    FSectorId: Integer;
    // Name
    FName: string;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // SectorRowDataPool
  TSectorRowDataPool = class(TObjectPool)
  private
  protected
    // Create
    function DoCreate: TObject; override;
    // Destroy
    procedure DoDestroy(AObject: TObject); override;
    // Allocate Before
    procedure DoAllocateBefore(AObject: TObject); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(AObject: TObject); override;
  end;

  // AttentionRowData
  TAttentionRowData = class(TAutoObject)
  private
    // SectorId
    FSectorId: Integer;
    // ModuleId
    FModuleId: Integer;
    // Name
    FName: string;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // SectorReportUI
  TBaseSectorReport = class(TSimpleReport)
  private
    // BackColor
    FBackColor: TColor;
    // FontColor
    FFontColor: TColor;
    // SelectRowBackColor
    FSelectRowBackColor: TColor;
    // SelectRowFontColor
    FSelectRowFontColor: TColor;
  protected
    // ClearRows
    procedure DoClearRows; virtual;
    // InitGridData
    procedure DoInitGridData; virtual;
    // InitGridColumns
    procedure DoInitGridColumns; virtual;
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
    // UpdateHorzScrollBar
    procedure DoGridUpdateHorzScrollBar; override;
    // MouseLeave
    procedure DoGridMouseLeave(Sender: TObject); override;
    // WheelUp
    function DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    // WheelDown
    function DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle; virtual;
    // ReLoadSectorData
    procedure ReLoadSectorData; virtual;
  end;

  // SectorTreeReport
  TSectorTreeReport = class(TBaseSectorReport)
  private
    //
    FSectorMgr: ISectorMgr;
    // IconWidth
    FIconWidth: Integer;
    // IconHeight
    FIconHeight: Integer;
    // LevelWidth
    FLevelWidth: Integer;
    // Expand
    FExpandIcon: TPngImage;
    // Collapse
    FCollapseIcon: TPngImage;
    // TreeColumn
    FTreeColumn: TNxTreeColumn;
    // SectorRowDataPool
    FSectorRowDataPool: TSectorRowDataPool;
    // AttetionSectorReport
    FAttetionSectorReport: TAttetionSectorReport;
    // AttentionRowDatas
    FAttentionRowDatas: TList<TAttentionRowData>;
  protected
    // ResetPos
    procedure DoResetPos; override;
    // ClearRows
    procedure DoClearRows; override;
    // InitGridColumns
    procedure DoInitGridColumns; override;
    // CollapseNodes
    procedure DoCollapseNodes;
    // SelectedSectorRowDatas
    procedure DoSelectedSectorRowDatas;
    // LoadSelectedSectorRowDatas
    procedure DoSelectedSectorRowData(ARowIndex: Integer);
    // DoAddAttentionRowData
    procedure DoAddAttentionRowData(ARow: TRow; ASectorRowData: TSectorRowData);
    // DoLoadTree
    procedure DoLoadTree(ASector: TSector; ARowIndex: Integer);
    // DoAddChildRow
    function DoAddChildRow(AParentRow: Integer; ASectorRowData: TSectorRowData): Integer;
    // MouseUp
    procedure DoGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // DrawCell
    procedure DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState); override;
    // DoGridDrawCellBackground
    procedure DoGridDrawCellBackground(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState; var DefaultDrawing: Boolean); override;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle; override;
    // ReLoadSectorData
    procedure ReLoadSectorData; override;
  end;

  // AttetionSectorReport
  TAttetionSectorReport = class(TBaseSectorReport)
  private
    // TextColumn
    FTextColumn: TNxTextColumn;
    // UserAttentionMgr
    FUserAttentionMgr: IUserAttentionMgr;
    // UserAttentionDic
    FUserAttentionDic: TDictionary<Integer, TAttentionRowData>;
  protected
    // ResetPos
    procedure DoResetPos; override;
    // ClearRows
    procedure DoClearRows; override;
    // InitGridColumns
    procedure DoInitGridColumns; override;
    // DrawCell
    procedure DoGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState); override;
    // DoGridDrawCellBackground
    procedure DoGridDrawCellBackground(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState; var DefaultDrawing: Boolean); override;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle; override;
    // ReLoadSectorData
    procedure ReLoadSectorData; override;
    // LoadDefault
    procedure LoadDefault;
    // DeleteSelected
    function DeleteSelected: Boolean;
    // SaveUserAttetions
    procedure SaveUserAttetions;
    // IsHasUserAttetion
    function IsHasUserAttetion(ASectorRowData: TSectorRowData): Boolean;
  end;

  // SectorTreeUI
  TSectorTreeUI = class(TCustomBaseUI)
  private
    // IsChangeSkin
    FIsChangeSkin: Boolean;
    // IsReLoadSectorMgr
    FIsReLoadSectorMgr: Boolean;
    // IsReLoadAttention
    FIsReLoadAttentionMgr: Boolean;
    // IsChangeAttention
    FIsChangeAttentionMgr: Boolean;
    // Ok
    FBtnOk: TButtonUI;
    // Add
    FBtnAdd: TButtonUI;
    // Del
    FBtnDel: TButtonUI;
    // Cancel
    FBtnCancel: TButtonUI;
    // DefaultButtonUI
    FBtnDefault: TButtonUI;
    // SectorTreeReport
    FSectorTreeReport: TSectorTreeReport;
    // AttetionSectorReport
    FAttetionSectorReport: TAttetionSectorReport;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;
    // SetSectorReportsPos
    procedure DoSetSectorReportsPos;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // AddUserAttentions
    procedure DoAddUserAttentions;
    // BtnOk
    procedure DoBtnOk(Sender: TObject);
    // BtnAdd
    procedure DoBtnAdd(Sender: TObject);
    // BtnDel
    procedure DoBtnDel(Sender: TObject);
    // BtnCancel
    procedure DoBtnCancel(Sender: TObject);
    // BtnDefault
    procedure DoBtnDefault(Sender: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ShowEx
    procedure ShowEx;
  end;


implementation

{$R *.dfm}

const
  MAX_COUNT = 20;


function GetRootSectorId(ARow: TRow): Integer;
var
  LParentRow, LRow: TRow;
  LSectorRowData: TSectorRowData;
begin
  Result := -1;
  LRow := ARow;
  while LRow <> nil do begin
    if LRow.ParentRow = nil then begin
      Break;
    end;
    LRow := LRow.ParentRow;
  end;
  if LRow <> nil then begin
    LSectorRowData := TSectorRowData(LRow.Data);
    if LSectorRowData <> nil then begin
      Result := LSectorRowData.FSectorId;
    end;
  end;
end;

function GetModuleId(ASectorId: Integer; ACount: Integer): Integer;
begin
  case ASectorId of
    7, 238:    // 沪深股票
      begin
        Result := 2100 + ACount;
      end;
    50:   // 股转
      begin
        Result := 3100 + ACount;
      end;
    174:  // 基金
      begin
        Result := 4100 + ACount;
      end;
    182:  // 债券
      begin
        Result := 5100 + ACount;
      end;
    196:  // 港股
      begin
        Result := 6100 + ACount;
      end;
    243:  // 期货
      begin
        Result := 7100 + ACount;
      end;
    249:  // 指数
      begin
        Result := 8100 + ACount;
      end;
    300:  // 美股
      begin
        Result := 9100 + ACount;
      end;
  else
    Result := -1;
  end;
end;

{ TSectorRowData }

constructor TSectorRowData.Create;
begin
  inherited;

end;

destructor TSectorRowData.Destroy;
begin
  FName := '';
  inherited;
end;

{ TSectorRowDataPool }

function TSectorRowDataPool.DoCreate: TObject;
begin
  Result := TSectorRowData.Create;
end;

procedure TSectorRowDataPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure TSectorRowDataPool.DoAllocateBefore(AObject: TObject);
begin

end;

procedure TSectorRowDataPool.DoDeAllocateBefore(AObject: TObject);
begin

end;

{ TAttentionRowData }

constructor TAttentionRowData.Create;
begin
  inherited;

end;

destructor TAttentionRowData.Destroy;
begin
  FName := '';
  inherited;
end;

{ TBaseSectorReport }

constructor TBaseSectorReport.Create(AParent: TWinControl; AContext: IAppContext);
var
  LFont: TFont;
begin
  inherited;
  FVertBar := TG32GaugeBar.Create(nil, FAppContext);
  FVertBar.Kind := sbVertical;
  FVertBar.OnChange := DoGridVertChange;
  FVertBar.Parent := Self;
  FVertBar.Align := alCustom;
  FVertBar.Visible := True;
  FVertBar.RefreshBar;
  FVertBar.UpdateSkinStyle;

  FHorzBar := TG32GaugeBar.Create(nil, FAppContext);
  FHorzBar.Kind := sbHorizontal;
  FHorzBar.OnChange := DoGridHorzChange;
  FHorzBar.Parent := Self;
  FHorzBar.Align := alCustom;
  FHorzBar.Visible := True;
  FHorzBar.RefreshBar;
  FHorzBar.UpdateSkinStyle;

  LFont := TFont.Create;
  LFont.Name := '微软雅黑';
  LFont.Charset := GB2312_CHARSET;
  LFont.Height := -13;
  FG32GraphicBuffer.G32Graphic.UpdateFont(LFont);
  LFont.Free;

  DoInitGridData;
  DoInitGridColumns;
end;

destructor TBaseSectorReport.Destroy;
begin

  inherited;
end;

procedure TBaseSectorReport.UpdateSkinStyle;
begin
  FBackColor := RGB(26, 26, 26);
  FFontColor := RGB(134, 134, 134);
  FSelectRowBackColor := RGB(89, 89, 89);
  FSelectRowFontColor := RGB(134, 134, 134);

  Color := FBackColor;
  FSimpleGrid.Color := FBackColor;
end;

procedure TBaseSectorReport.ReLoadSectorData;
begin

end;

procedure TBaseSectorReport.DoClearRows;
begin

end;

procedure TBaseSectorReport.DoInitGridData;
begin
  with FSimpleGrid do begin
    Parent := Self;
    Align := alCustom;
    Options := Options - [goHeader] + [goSelectFullRow];
    BorderStyle := bsNone;
    HeaderSize := 0;
    ParentBackground := False;
    ParentColor := False;
    ReadOnly := True;
    GridStyle := gsReport;
    GridLinesStyle := lsActiveHorzOnly;
    AppearanceOptions := AppearanceOptions + [aoHideFocus];
    OnVerticalScroll := DoGridVertScroll;
    HideScrollBar := True;
  end;
end;

procedure TBaseSectorReport.DoInitGridColumns;
begin

end;

procedure TBaseSectorReport.DoGridVertBarTop;
begin
  if FVertBar = nil then Exit;

  if FVertBar.Visible
    and (FVertBar.Position > FVertBar.Min) then begin
    FVertBar.Position := FVertBar.Min;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TBaseSectorReport.DoGridVertBarNextRow;
begin
  if FVertBar = nil then Exit;

  if (FVertBar.Position + 1) <= FVertBar.Max then begin
    FVertBar.Position := FVertBar.Position + 1;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TBaseSectorReport.DoGridVertBarPriorRow;
begin
  if FVertBar = nil then Exit;

  if (FVertBar.Position - 1) >= FVertBar.Min then begin
    FVertBar.Position := FVertBar.Position - 1;
    FSimpleGrid.VertScrollBar.Position := FVertBar.Position;
  end;
end;

procedure TBaseSectorReport.DoResetPos;
var
  LWidth, LHeight: Integer;
begin
  if (FVertBar <> nil)
    and (FVertBar.Visible) then begin
    LWidth := Width - FVertBar.Width;
    FVertBar.Top := 0;
    FVertBar.Left := Width - FVertBar.Width;
    if FHorzBar <> nil then begin
      FVertBar.Height := Height - FHorzBar.Height;
    end;
  end else begin
    LWidth := Width;
  end;

  if (FHorzBar <> nil)
    and (FHorzBar.Visible) then begin
    LHeight := Height - FHorzBar.Height;
    FHorzBar.Top := LHeight;
    FHorzBar.Left := 0;
    if FVertBar <> nil then begin
      FHorzBar.Width := Width - FVertBar.Width;
    end;
  end else begin
    LHeight := Height;
  end;

  FSimpleGrid.Top := 0;
  FSimpleGrid.Left := 0;
  FSimpleGrid.Width := LWidth;
  FSimpleGrid.Height := LHeight;
  FSimpleGrid.FixedCols := 0;
  FSimpleGrid.RowSize := 22;
end;

procedure TBaseSectorReport.DoGridPaintReportBefore;
begin
  FG32GraphicBuffer.G32Graphic.BackColor := FBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(Rect(0, 0, FSimpleGrid.Width, FSimpleGrid.Height));
end;

procedure TBaseSectorReport.DoGridUpdateVertScrollBar;
begin
  if FVertBar = nil then Exit;

  FVertBar.Enabled := (FSimpleGrid.VertScrollBar.PageSize > 0) and
    (FSimpleGrid.VertScrollBar.PageSize <= FSimpleGrid.VertScrollBar.Max);
  if FVertBar.Enabled then begin
    FVertBar.Max := FSimpleGrid.VertScrollBar.Max - FSimpleGrid.VertScrollBar.PageSize + 1;
    FVertBar.Min := FSimpleGrid.VertScrollBar.Min;
    FVertBar.LargeChange := FSimpleGrid.VertScrollBar.LargeChange;
    FVertBar.SmallChange := FSimpleGrid.VertScrollBar.SmallChange;
    FVertBar.Position := FSimpleGrid.VertScrollBar.Position;
    FVertBar.HandleSize := Max(25,
      Trunc((FSimpleGrid.VertScrollBar.PageSize * FVertBar.Height) /
      (FSimpleGrid.VertScrollBar.Max)));
  end else begin
    FVertBar.Position := 0;
    FVertBar.Max := 0;
    FVertBar.Min := 0;
  end;
end;

procedure TBaseSectorReport.DoGridUpdateHorzScrollBar;
begin
  if FHorzBar = nil then Exit;

  FHorzBar.Enabled := (FSimpleGrid.HorzScrollBar.PageSize > 0) and
    (FSimpleGrid.HorzScrollBar.PageSize <= FSimpleGrid.HorzScrollBar.Max);
  if FHorzBar.Enabled then begin
    FHorzBar.Max := FSimpleGrid.HorzScrollBar.Max - FSimpleGrid.VertScrollBar.PageSize + 1;
    FHorzBar.Min := FSimpleGrid.HorzScrollBar.Min;
    FHorzBar.LargeChange := FSimpleGrid.HorzScrollBar.LargeChange;
    FHorzBar.SmallChange := FSimpleGrid.HorzScrollBar.SmallChange;
    FHorzBar.Position := FSimpleGrid.HorzScrollBar.Position;
    FHorzBar.HandleSize := Max(25,
      Trunc((FSimpleGrid.HorzScrollBar.PageSize * FHorzBar.Width) /
      (FSimpleGrid.HorzScrollBar.Max + 1)));
  end else begin
    FHorzBar.Position := 0;
    FHorzBar.Max := 0;
    FHorzBar.Min := 0;
  end;
end;

procedure TBaseSectorReport.DoGridMouseLeave(Sender: TObject);
begin

end;

function TBaseSectorReport.DoGridWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

function TBaseSectorReport.DoGridWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := False;
end;

{ TSectorTreeReport }

constructor TSectorTreeReport.Create(AParent: TWinControl;
  AContext: IAppContext);
begin
  inherited;
  FSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SECTORMGR) as ISectorMgr;
  FIconWidth := 12;
  FIconHeight := 11;
  FLevelWidth := 20;
  FExpandIcon := TPngImage.Create;
  FCollapseIcon := TPngImage.Create;
  FAttentionRowDatas := TList<TAttentionRowData>.Create;
  FSectorRowDataPool := TSectorRowDataPool.Create(1000);
end;

destructor TSectorTreeReport.Destroy;
begin
  DoClearRows;
  FSectorRowDataPool.Free;
  FAttentionRowDatas.Free;
  FCollapseIcon.Free;
  FExpandIcon.Free;
  FSectorMgr := nil;
  inherited;
end;

procedure TSectorTreeReport.UpdateSkinStyle;
var
  LInstance: HINST;
begin
  inherited;
  LInstance := FAppContext.GetResourceSkin.GetInstance;
  if LInstance <> 0 then begin
    FExpandIcon.LoadFromResourceName(LInstance, 'TreeImage_Add');
    FCollapseIcon.LoadFromResourceName(LInstance, 'TreeImage_Minus');
  end;
end;

procedure TSectorTreeReport.ReLoadSectorData;
begin
  if FSectorMgr <> nil then begin
    FSectorMgr.Lock;
    try
      FSimpleGrid.BeginUpdate;
      try
        DoClearRows;
        DoLoadTree(FSectorMgr.GetRootSector, -1);
        DoCollapseNodes;
      finally
        FSimpleGrid.EndUpdate;
      end;
    finally
      FSectorMgr.UnLock;
    end;
  end;
end;

procedure TSectorTreeReport.DoResetPos;
begin
  inherited;
  if FTreeColumn <> nil then begin
    FTreeColumn.Width := FSimpleGrid.Width - 2;
  end;
end;

procedure TSectorTreeReport.DoClearRows;
var
  LRow: TRow;
  LIndex: Integer;
  LSectorRowData: TSectorRowData;
begin
  for LIndex := 0 to FSimpleGrid.RowCount - 1 do begin
    LRow := FSimpleGrid.Row[LIndex];
    LSectorRowData := TSectorRowData(LRow.Data);
    LRow.Data := nil;
    if LSectorRowData <> nil then begin
      FSectorRowDataPool.DeAllocate(LSectorRowData);
    end;
  end;
  FSimpleGrid.ClearRows;
end;

procedure TSectorTreeReport.DoInitGridColumns;
var
  tmpColumnOptions: TColumnOptions;
begin
  with FSimpleGrid do begin
    FTreeColumn := TNxTreeColumn.Create(FSimpleGrid);
    Columns.AddColumn(FTreeColumn);
    FTreeColumn.Header.Caption := 'ShowContent';
    FTreeColumn.Header.Alignment := taCenter;
    FTreeColumn.Alignment := taCenter;
    FTreeColumn.Width := 100;
    FTreeColumn.Visible := True;
    FTreeColumn.DrawingOptions := doCustomOnly;
    FTreeColumn.ShowLines := false;
    FTreeColumn.ShowButtons := false;
//    tmpColumnOptions := FTreeColumn.Options;
//    Exclude(tmpColumnOptions, coCanSort);
//    Include(tmpColumnOptions, coAutoSize);
//    FTreeColumn.Options := tmpColumnOptions;
    FTreeColumn.Tag := 0;
  end;
end;

procedure TSectorTreeReport.DoCollapseNodes;
var
  LRow: TRow;
  LIndex: Integer;
begin
  for LIndex := 0 to FSimpleGrid.RowCount - 1 do begin
    LRow := FSimpleGrid.Row[LIndex];
    if LRow.Expanded then begin
      FSimpleGrid.Expanded[LIndex] := False;
    end;
  end;
end;

procedure TSectorTreeReport.DoSelectedSectorRowDatas;
begin
  FAttentionRowDatas.Clear;
  DoSelectedSectorRowData(FSimpleGrid.SelectedRow);
end;

procedure TSectorTreeReport.DoSelectedSectorRowData(ARowIndex: Integer);
var      
  LRow, LChildRow: TRow;
  LIndex, LCount: Integer; 
begin
  if (ARowIndex < 0)
    or (ARowIndex >= FSimpleGrid.RowCount) then Exit;
  
  LRow := FSimpleGrid.Row[ARowIndex];
  if LRow.HasChildren then begin
    LCount := 0;
    LIndex := ARowIndex;
    while LCount < LRow.ChildCount  do begin
      Inc(LIndex);
      Inc(LCount);
      if (LIndex >= 0) 
        and (LIndex < FSimpleGrid.RowCount - 1) then begin
        LChildRow := FSimpleGrid.Row[LIndex];
        if LChildRow.ParentRow = LRow then begin
          if LChildRow.HasChildren then begin
            DoSelectedSectorRowData(LIndex);
          end else begin
            DoAddAttentionRowData(LChildRow, TSectorRowData(LChildRow.Data));
          end;
        end;
      end;
    end;
  end else begin
    DoAddAttentionRowData(LRow, TSectorRowData(LRow.Data));
  end;
end;

procedure TSectorTreeReport.DoAddAttentionRowData(ARow: TRow; ASectorRowData: TSectorRowData);
var
  LCount: Integer;
  LRootSectorId: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  if FAttetionSectorReport <> nil then begin
    LCount := MAX_COUNT - FAttetionSectorReport.FSimpleGrid.RowCount;
    if FAttentionRowDatas.Count >= LCount then Exit;

    LCount := FAttetionSectorReport.FSimpleGrid.RowCount + FAttentionRowDatas.Count;
    if not FAttetionSectorReport.IsHasUserAttetion(ASectorRowData) then begin
      LRootSectorId := GetRootSectorId(ARow);
      if LRootSectorId <> -1 then begin
        Inc(LCount);
        LAttentionRowData := TAttentionRowData.Create;
        LAttentionRowData.FSectorId := ASectorRowData.FSectorId;
        LAttentionRowData.FModuleId := GetModuleId(LRootSectorId, LCount);
        LAttentionRowData.FName := ASectorRowData.FName;
        FAttentionRowDatas.Add(LAttentionRowData);
      end;
    end;
  end;
end;

procedure TSectorTreeReport.DoLoadTree(ASector: TSector; ARowIndex: Integer);
var
  LSector: TSector;
  LIndex, LRowIndex: Integer;
  LSectorRowData: TSectorRowData;
begin
  for LIndex := 0 to ASector.GetChildCount - 1 do begin
    LSector := ASector.Childs[LIndex];
    if LSector <> nil then begin
      LSectorRowData := TSectorRowData(FSectorRowDataPool.Allocate);
      LSectorRowData.FSectorId := LSector.Id;
      LSectorRowData.FName := Copy(LSector.Name, 1, Length(LSector.Name));
      LRowIndex := DoAddChildRow(ARowIndex, LSectorRowData);
      if (LRowIndex >= 0)
        and (LRowIndex < FSimpleGrid.RowCount) then begin
        DoLoadTree(LSector, LRowIndex);
      end;
    end;
  end;
end;

function TSectorTreeReport.DoAddChildRow(AParentRow: Integer; ASectorRowData: TSectorRowData): Integer;
begin
  if (AParentRow < 0) then begin
    Result := FSimpleGrid.AddRow();
    FSimpleGrid.Row[Result].Data := ASectorRowData;
  end else begin
    FSimpleGrid.AddChildRow(AParentRow, crLast);
    Result := FSimpleGrid.LastAddedRow;
    FSimpleGrid.Row[Result].Data := ASectorRowData;
  end;
end;

procedure TSectorTreeReport.DoGridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LRow: TRow;
  LRowColPt: TPoint;
  LRect, LIconRect: TRect;
begin
  if Button = mbLeft then begin
    LRowColPt := FSimpleGrid.GetCellAtPos(Point(X, Y));
    if LRowColPt.Y >= 0 then begin
      LRow := FSimpleGrid.Row[LRowColPt.Y];
      if (LRow.HasChildren) then begin
        LRect := FSimpleGrid.GetCellRect(LRowColPt.X, LRowColPt.Y);
        LRect.Left := LRow.Level * FLevelWidth + 5;
        LIconRect.Left := LRect.Left;
        LIconRect.Top := (LRect.Top + LRect.Bottom - FIconHeight) div 2;
        LIconRect.Right := LIconRect.Left + FIconWidth;
        LIconRect.Bottom := LIconRect.Top + FIconHeight;
        if PtInRect(LIconRect, Point(X, Y)) then begin
          FSimpleGrid.Expanded[LRowColPt.Y] := not LRow.Expanded;
        end;
      end;

      if FHorzBar <> nil then begin
        FSimpleGrid.Columns[0].Width := FSimpleGrid.Width;
      end;
    end;
  end;
end;

procedure TSectorTreeReport.DoGridCustomDrawCell(Sender: TObject; ACol,
  ARow: Integer; CellRect: TRect; CellState: TCellState);
var
  LRow: TRow;
  LLeft: Integer;
  LIcon: TPngImage;
  LRect, LIconRect, LBackRect: TRect;
  LBackColor, LFontColor: TColor;
  LSectorRowData: TSectorRowData;
begin
  if csSelected in CellState then begin
    LBackColor := FSelectRowBackColor;
    LFontColor := FSelectRowFontColor;
  end else begin
    LBackColor := FBackColor;
    LFontColor := FFontColor;
  end;

  LBackRect := CellRect;
  LBackRect.Left := 0;
  LBackRect.Right := LBackRect.Left + FSimpleGrid.Width;
  FG32GraphicBuffer.G32Graphic.BackColor := LBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(LBackRect);

  LRect := CellRect;
  LRow := FSimpleGrid.Row[ARow];
  LRect.Left := LRect.Left + LRow.Level * FLevelWidth + 5;
  if LRow.HasChildren then begin
    if LRow.Expanded then begin
      LIcon := FCollapseIcon;
    end else begin
      LIcon := FExpandIcon;
    end;
    LIconRect.Left := LRect.Left;
    LIconRect.Top := (LRect.Top + LRect.Bottom - FIconHeight) div 2;
    FG32GraphicBuffer.Buffer.Canvas.Draw(LIconRect.Left, LIconRect.Top, LIcon);
    LRect.Left := LRect.Left + FIconWidth;
  end;

  FG32GraphicBuffer.G32Graphic.EmptyPolyText('DrawText');
  LSectorRowData := TSectorRowData(LRow.Data);
  FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LRect, LSectorRowData.FName, gtaLeft);
  FG32GraphicBuffer.G32Graphic.LineColor := LFontColor;
  FG32GraphicBuffer.G32Graphic.DrawPolyText('DrawText');
end;

procedure TSectorTreeReport.DoGridDrawCellBackground(Sender: TObject; ACol,
  ARow: Integer; CellRect: TRect; CellState: TCellState;
  var DefaultDrawing: Boolean);
var
  LRow: TRow;
  LWidth: Integer;
  LSectorRowData: TSectorRowData;
begin
  if ARow >= FSimpleGrid.RowCount then Exit;

  LRow := FSimpleGrid.Row[ARow];
  LWidth := LRow.Level * FLevelWidth + 5;
  if LRow.HasChildren then begin
    LWidth := LWidth + FIconWidth;
  end;
  LSectorRowData := TSectorRowData(LRow.Data);
  if LSectorRowData <> nil then begin
    LWidth := LWidth + Self.FG32GraphicBuffer.G32Graphic.TextWidth(LSectorRowData.FName);
  end;
  if CellRect.Width < LWidth then begin
    FSimpleGrid.Columns[0].Width := LWidth;
  end;
end;

{ TAttetionSectorReport }

constructor TAttetionSectorReport.Create(AParent: TWinControl;
  AContext: IAppContext);
begin
  inherited;
  FUserAttentionMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERATTENTIONMGR) as IUserAttentionMgr;
  FUserAttentionDic := TDictionary<Integer, TAttentionRowData>.Create;
end;

destructor TAttetionSectorReport.Destroy;
begin
  DoClearRows;
  FUserAttentionDic.Free;
  FUserAttentionMgr := nil;
  inherited;
end;

procedure TAttetionSectorReport.UpdateSkinStyle;
begin
  inherited;

end;

procedure TAttetionSectorReport.ReLoadSectorData;
var
  LRow: TRow;
  LAttention: TAttention;
  LIndex, LRowIndex: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  if FUserAttentionMgr <> nil then begin
    FUserAttentionMgr.Lock;
    try
      FSimpleGrid.BeginUpdate;
      try
        DoClearRows;
        for LIndex := 0 to FUserAttentionMgr.GetCount - 1 do begin
          LAttention := FUserAttentionMgr.GetAttention(LIndex);
          if LAttention <> nil then begin
            LAttentionRowData := TAttentionRowData.Create;
            LAttentionRowData.FSectorId := LAttention.SectorId;
            LAttentionRowData.FModuleId := LAttention.ModuleId;
            LAttentionRowData.FName := LAttention.Name;
            LRowIndex := FSimpleGrid.AddRow();
            LRow := FSimpleGrid.Row[LRowIndex];
            LRow.Data := LAttentionRowData;
          end;
        end;
      finally
        FSimpleGrid.EndUpdate;
      end;
    finally
      FUserAttentionMgr.UnLock;
    end;
  end;
end;

procedure TAttetionSectorReport.LoadDefault;
begin
  FSimpleGrid.BeginUpdate;
  try
    DoClearRows;
  finally
    FSimpleGrid.EndUpdate;
  end;
end;

function TAttetionSectorReport.DeleteSelected: Boolean;
var
  LRow: TRow;
  LRowIndex: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  Result := False;
  LRowIndex := FSimpleGrid.SelectedRow;
  if (LRowIndex >= 0)
    and (LRowIndex < FSimpleGrid.RowCount) then begin
    Result := True;
    LRow := FSimpleGrid.Row[LRowIndex];
    LAttentionRowData := TAttentionRowData(LRow.Data);
    if LAttentionRowData <> nil then begin
      LAttentionRowData.Free;
    end;
    FSimpleGrid.DeleteRow(LRowIndex);
    FSimpleGrid.SelectedRow := -1;
  end;
end;

procedure TAttetionSectorReport.SaveUserAttetions;
var
  LRow: TRow;
  LIndex: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  if FUserAttentionMgr = nil then Exit;

  FUserAttentionMgr.Lock;
  try
    FUserAttentionMgr.ClearData;
    for LIndex := 0 to FSimpleGrid.RowCount - 1 do begin
      LRow := FSimpleGrid.Row[LIndex];
      LAttentionRowData := TAttentionRowData(LRow.Data);
      if LAttentionRowData <> nil then begin
        FUserAttentionMgr.Add(LAttentionRowData.FSectorId, LAttentionRowData.FModuleId, LAttentionRowData.FName);
      end;
    end;
    FUserAttentionMgr.SaveData;
  finally
    FUserAttentionMgr.UnLock;
  end;
end;

function TAttetionSectorReport.IsHasUserAttetion(ASectorRowData: TSectorRowData): Boolean;
begin
  Result := False;
  if ASectorRowData = nil then Exit;

  Result := FUserAttentionDic.ContainsKey(ASectorRowData.FSectorId);
end;

procedure TAttetionSectorReport.DoResetPos;
begin
  inherited;
  if FTextColumn <> nil then begin
    FTextColumn.Width := FSimpleGrid.Width - 2;
  end;
end;

procedure TAttetionSectorReport.DoClearRows;
var
  LRow: TRow;
  LIndex: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  for LIndex := 0 to FSimpleGrid.RowCount - 1 do begin
    LRow := FSimpleGrid.Row[LIndex];
    LAttentionRowData := TAttentionRowData(LRow.Data);
    LRow.Data := nil;
    if LAttentionRowData <> nil then begin
      LAttentionRowData.Free;
    end;
  end;
  FSimpleGrid.ClearRows;
end;

procedure TAttetionSectorReport.DoInitGridColumns;
var
  tmpColumnOptions: TColumnOptions;
begin
  with FSimpleGrid do begin
    FTextColumn := TNxTextColumn.Create(FSimpleGrid);
    Columns.AddColumn(FTextColumn);
    FTextColumn.Header.Caption := 'ShowContent';
    FTextColumn.Header.Alignment := taCenter;
    FTextColumn.Alignment := taCenter;
    FTextColumn.Width := 100;
    FTextColumn.Visible := True;
    FTextColumn.DrawingOptions := doCustomOnly;
    FTextColumn.Tag := 0;
  end;
end;

procedure TAttetionSectorReport.DoGridCustomDrawCell(Sender: TObject; ACol,
  ARow: Integer; CellRect: TRect; CellState: TCellState);
var
  LRow: TRow;
  LNameRect: TRect;
  LBackColor, LFontColor: TColor;
  LAttentionRowData: TAttentionRowData;
begin
  LRow := FSimpleGrid.Row[ARow];
  if csSelected in CellState then begin
    LBackColor := FSelectRowBackColor;
    LFontColor := FSelectRowFontColor;
  end else begin
    LBackColor := FBackColor;
    LFontColor := FFontColor;
  end;
  FG32GraphicBuffer.G32Graphic.BackColor := LBackColor;
  FG32GraphicBuffer.G32Graphic.FillRect(CellRect);

  if LRow <> nil then begin
    LAttentionRowData := TAttentionRowData(LRow.Data);
    if LAttentionRowData <> nil then begin
      FG32GraphicBuffer.G32Graphic.EmptyPolyText('DrawText');

      if LAttentionRowData.FName <> '' then begin
        LNameRect := CellRect;
        LNameRect.Left := LNameRect.Left + 5;
        FG32GraphicBuffer.G32Graphic.AddPolyText('DrawText', LNameRect, LAttentionRowData.FName, gtaLeft);
      end;
      FG32GraphicBuffer.G32Graphic.Ellipsis := True;
      FG32GraphicBuffer.G32Graphic.LineColor := LFontColor;
      FG32GraphicBuffer.G32Graphic.DrawPolyText('DrawText');
    end;
  end;
end;

procedure TAttetionSectorReport.DoGridDrawCellBackground(Sender: TObject; ACol,
  ARow: Integer; CellRect: TRect; CellState: TCellState;
  var DefaultDrawing: Boolean);
var
  LRow: TRow;
  LWidth: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  if ARow >= FSimpleGrid.RowCount then Exit;

  LRow := FSimpleGrid.Row[ARow];
  LWidth := 5;
  LAttentionRowData := TAttentionRowData(LRow.Data);
  if LAttentionRowData <> nil then begin
    LWidth := LWidth + FG32GraphicBuffer.G32Graphic.TextWidth(LAttentionRowData.FName);
  end;
  if CellRect.Width < LWidth then begin
    FSimpleGrid.Columns[0].Width := LWidth;
  end;
end;

{ TSectorTreeUI }

constructor TSectorTreeUI.Create(AContext: IAppContext);
begin
  inherited;
  FIsChangeSkin := True;
  FIsReLoadSectorMgr := True;
  FIsReLoadAttentionMgr := True;
  FIsChangeAttentionMgr := False;
  FBtnOk := TButtonUI.Create(FAppContext);
  FBtnOk.Parent := Self;
  FBtnOk.Caption := '确定';
  FBtnOk.OnClick := DoBtnOk;
  FBtnAdd := TButtonUI.Create(FAppContext);
  FBtnAdd.Parent := Self;
  FBtnAdd.Caption := '添加';
  FBtnAdd.OnClick := DoBtnAdd;
  FBtnDel := TButtonUI.Create(FAppContext);
  FBtnDel.Parent := Self;
  FBtnDel.Caption := '删除';
  FBtnDel.OnClick := DoBtnDel;
  FBtnCancel := TButtonUI.Create(FAppContext);
  FBtnCancel.Parent := Self;
  FBtnCancel.Caption := '取消';
  FBtnCancel.OnClick := DoBtnCancel;
  FBtnDefault := TButtonUI.Create(FAppContext);
  FBtnDefault.Parent := Self;
  FBtnDefault.Caption := '恢复默认';
  FBtnDefault.OnClick := DoBtnDefault;
  FSectorTreeReport := TSectorTreeReport.Create(Self, FAppContext);
  FSectorTreeReport.Parent := Self;
  FSectorTreeReport.Align := alCustom;
  FSectorTreeReport.FSimpleGrid.OnDblClick := DoBtnAdd;
  FAttetionSectorReport := TAttetionSectorReport.Create(Self, FAppContext);
  FAttetionSectorReport.Align := alCustom;
  FAttetionSectorReport.Parent := Self;
  FSectorTreeReport.FAttetionSectorReport := FAttetionSectorReport;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateSectorMgr);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMain_ReUpdateSkinStyle);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  DoSetSectorReportsPos;
end;

destructor TSectorTreeUI.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  FAttetionSectorReport.Free;
  FSectorTreeReport.Free;
  FBtnDefault.Free;
  FBtnCancel.Free;
  FBtnDel.Free;
  FBtnAdd.Free;
  FBtnOk.Free;
  inherited;
end;

procedure TSectorTreeUI.ShowEx;
begin
  if FIsReLoadSectorMgr then begin
    FSectorTreeReport.ReLoadSectorData;
    FIsReLoadSectorMgr := False;
  end;
  FSectorTreeReport.DoCollapseNodes;

  if FIsChangeAttentionMgr then begin
    FAttetionSectorReport.ReLoadSectorData;
    FIsChangeAttentionMgr := True;
  end;

  if FIsChangeSkin then begin
    UpdateSkinStyle;
    FIsChangeSkin := True;
  end;

  SetScreenCenter;
  if not Self.Showing then begin
    Show;
  end else begin
    BringToFront;
  end;
end;

procedure TSectorTreeUI.DoSetSectorReportsPos;
var
  LTop, LLeft, LWidth, LHeight: Integer;
begin
  LTop := 20;
  LLeft := 40;
  LHeight := Height - 110;
  LWidth := (Width - 2 * LLeft - 80) div 2;
  FSectorTreeReport.Top := LTop;
  FSectorTreeReport.Left := LLeft;
  FSectorTreeReport.Width := LWidth;
  FSectorTreeReport.Height := LHeight;

  FAttetionSectorReport.Top := LTop;
  FAttetionSectorReport.Left := Width - LWidth - LLeft;
  FAttetionSectorReport.Width := LWidth;
  FAttetionSectorReport.Height := LHeight;

  FBtnAdd.Width := 50;
  FBtnAdd.Height := 22;
  FBtnAdd.Top := 100;
  FBtnAdd.Left := (Width - FBtnAdd.Width) div 2;

  FBtnDel.Width := 50;
  FBtnDel.Height := 22;
  FBtnDel.Top := 160;
  FBtnDel.Left := (Width - FBtnAdd.Width) div 2;

  FBtnDefault.Width := 80;
  FBtnDefault.Height := 22;
  FBtnDefault.Top := Height - 70;
  FBtnDefault.Left := Width - 260;

  FBtnOk.Width := 50;
  FBtnOk.Height := 22;
  FBtnOk.Top := Height - 70;
  FBtnOk.Left := Width - 160;

  FBtnCancel.Width := 50;
  FBtnCancel.Height := 22;
  FBtnCancel.Top := Height - 70;
  FBtnCancel.Left := Width - 90;
end;

procedure TSectorTreeUI.DoUpdateMsgEx(AObject: TObject);
var
  LMsgEx: TMsgEx;
begin
  LMsgEx := TMsgEx(AObject);
  case LMsgEx.Id of
    Msg_AsfMem_ReUpdateSectorMgr:
      begin
        if Self.Showing then begin
          FSectorTreeReport.ReLoadSectorData;
        end else begin
          FIsReLoadSectorMgr := True;
        end;
      end;
    Msg_AsfMem_ReUpdateAttentionMgr:
      begin
        if Self.Showing then begin
          FAttetionSectorReport.ReLoadSectorData;
        end else begin
          FIsReLoadAttentionMgr := True;
        end;
      end;
    Msg_AsfMain_ReUpdateSkinStyle:
      begin

      end;
  end;
end;

procedure TSectorTreeUI.DoAddUserAttentions;
var
  LRow: TRow;
  LIndex, LRowIndex: Integer;
  LAttentionRowData: TAttentionRowData;
begin
  FSectorTreeReport.DoSelectedSectorRowDatas;
  if FSectorTreeReport.FAttentionRowDatas.Count > 0 then begin

    if FAttetionSectorReport.FTextColumn <> nil then begin
      FAttetionSectorReport.FTextColumn.Width := FAttetionSectorReport.FSimpleGrid.Width;
    end;

    FIsChangeAttentionMgr := True;
    FAttetionSectorReport.FSimpleGrid.BeginUpdate;
    try
      for LIndex := 0 to FSectorTreeReport.FAttentionRowDatas.Count - 1 do begin
        LAttentionRowData := FSectorTreeReport.FAttentionRowDatas.Items[LIndex];
        if LAttentionRowData <> nil then begin
          FAttetionSectorReport.FUserAttentionDic.AddOrSetValue(LAttentionRowData.FSectorId, LAttentionRowData);
          LRowIndex := FAttetionSectorReport.FSimpleGrid.AddRow();
          LRow := FAttetionSectorReport.FSimpleGrid.Row[LRowIndex];
          LRow.Data := LAttentionRowData;
        end;
      end;
      FSectorTreeReport.FAttentionRowDatas.Clear;
    finally
      FAttetionSectorReport.FSimpleGrid.EndUpdate;
    end;
  end;
end;

procedure TSectorTreeUI.DoBtnOk(Sender: TObject);
var
  LIndex: Integer;
begin
  if FIsChangeAttentionMgr then begin
    FAttetionSectorReport.SaveUserAttetions;
    FIsChangeAttentionMgr := False;
  end;
end;

procedure TSectorTreeUI.DoBtnAdd(Sender: TObject);
begin
  DoAddUserAttentions;
end;

procedure TSectorTreeUI.DoBtnDel(Sender: TObject);
var
  LIsChange: Boolean;
begin
  LIsChange := FAttetionSectorReport.DeleteSelected;
  if LIsChange then begin
    FIsChangeAttentionMgr := True;
  end;
end;

procedure TSectorTreeUI.DoBtnCancel(Sender: TObject);
begin
  Hide;
end;

procedure TSectorTreeUI.DoBtnDefault(Sender: TObject);
begin
  FAttetionSectorReport.LoadDefault;
end;

procedure TSectorTreeUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderStyleEx := bsNone;
end;

procedure TSectorTreeUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := '板块添加';
  end;
end;

procedure TSectorTreeUI.DoUpdateSkinStyle;
begin
  inherited;
  if FSectorTreeReport <> nil then begin
    FSectorTreeReport.UpdateSkinStyle;
  end;
  if FAttetionSectorReport <> nil then begin
    FAttetionSectorReport.UpdateSkinStyle;
  end;
end;

end.
