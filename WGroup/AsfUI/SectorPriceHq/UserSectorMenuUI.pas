unit UserSectorMenuUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserSectorMenuUI
// Author：      lksoulman
// Date：        2018-1-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Graphics,
  MsgEx,
  Command,
  RenderDC,
  RenderUtil,
  BaseObject,
  AppContext,
  ComponentUI,
  CustomFrameUI,
  UserSector,
  UserSectorMgr,
  Generics.Collections,
  MsgExSubcriberAdapter,
  QuoteCommMenu;

type

  TUserSectorMenuUI = class;

  // UserSectorItem
  TUserSectorItem = class(TComponentUI)
  private
    //
    FIndex: Integer;
    // ParentUI
    FParentUI: TUserSectorMenuUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserSectorMenuUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserSectorSubItem
  TUserSectorSubItem = class(TUserSectorItem)
  private
    // Width
    FWidth: Integer;
    // SubWidth
    FSubWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserSectorMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserSectorAddItem
  TUserSectorAddItem = class(TUserSectorItem)
  private
    // Width
    FWidth: Integer;
    // IconSize
    FIconSize: TSize;
    // IconWidth
    FIconWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserSectorMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserSectorAddStockItem
  TUserSectorAddStockItem = class(TUserSectorItem)
  private
    // Width
    FWidth: Integer;
    // IconSize
    FIconSize: TSize;
    // IconWidth
    FIconWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserSectorMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserSectorMenuUI
  TUserSectorMenuUI = class(TCustomFrameUI)
  private
    // ShowCount
    FShowCount: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // BorderValues
    FBorderValues: Integer;
    // SelectedIndex
    FSelectedIndex: Integer;
    // BackColor
    FBackColor: TColor;
    // BorderLineColor
    FBorderLineColor: TColor;
    // UserSectorItemLineColor
    FUserSectorItemLineColor: TColor;
    // UserSectorItemColor
    FUserSectorItemColor: TColor;
    // UserSectorItemFontColor
    FUserSectorItemFontColor: TColor;
    // UserSectorItemHotColor
    FUserSectorItemHotColor: TColor;
    // UserSectorItemHotFontColor
    FUserSectorItemHotFontColor: TColor;
    // UserSectorItemDownColor
    FUserSectorItemDownColor: TColor;
    // UserSectorItemDownFontColor
    FUserSectorItemDownFontColor: TColor;
    // UserSectorAddItemColor
    FUserSectorAddItemColor: TColor;
    // UserSectorAddItemFontColor
    FUserSectorAddItemFontColor: TColor;
    // UserSectorAddItemHotColor
    FUserSectorAddItemHotColor: TColor;
    // UserSectorAddItemHotFontColor
    FUserSectorAddItemHotFontColor: TColor;
    // UserSectorAddItemDownColor
    FUserSectorAddItemDownColor: TColor;
    // UserSectorAddItemDownFontColor
    FUserSectorAddItemDownFontColor: TColor;

    // SubPopMenu
    FSubPopMenu: TGilPopMenu;
    // UserSectorMgr
    FUserSectorMgr: IUserSectorMgr;
    // UserSectorSubItem
    FUserSectorSubItem: TUserSectorSubItem;
    // UserSectorAddItem
    FUserSectorAddItem: TUserSectorAddItem;
    // UserSectorAddStockItem
    FUserSectorAddStockItem: TUserSectorAddStockItem;
    // UserSectorAddResourceStream
    FUserSectorAddResourceStream: TResourceStream;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // GetUserSectorItem
    function GetUserSectorItem(AIndex: Integer): TUserSectorItem;
  protected
    // Update
    procedure DoUpdate;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; override;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); override;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); override;
    // FindComponent
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
    // DoMouseUpAfter
    procedure DoMouseUpAfter(AComponent: TComponentUI); override;
    // DoLClickComponent
    procedure DoLClickComponent(AComponent: TComponentUI); override;
    // LClickSubMenuItem
    procedure DoLClickSubMenuItem(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TUserSectorItem }

constructor TUserSectorItem.Create(AParentUI: TUserSectorMenuUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
end;

destructor TUserSectorItem.Destroy;
begin

  inherited;
end;

function TUserSectorItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TUserSectorItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TUserSectorItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LBackColor: TColor;
  LFontColor: TColor;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  if FParentUI.FSelectedIndex = FIndex then begin
    LBackColor := FParentUI.FUserSectorItemHotColor;
    LFontColor := FParentUI.FUserSectorItemHotFontColor;
  end else begin
    LBackColor := FParentUI.FUserSectorItemColor;
    LFontColor := FParentUI.FUserSectorItemFontColor;
    if FParentUI.MouseMoveId = FId then begin
      LBackColor := FParentUI.FUserSectorItemHotColor;
      LFontColor := FParentUI.FUserSectorItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LBackColor := FParentUI.FUserSectorItemDownColor;
        LFontColor := FParentUI.FUserSectorItemDownFontColor;
      end;
    end;
  end;

  LRect := FRectEx;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawText
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, FCaption, LFontColor, dtaCenter, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;

  // DrawLine
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FUserSectorItemLineColor);
  try
    LRect.Right := LRect.Right - 1;
    LOldObj := SelectObject(ARenderDC.MemDC, LBorderPen);
    try
      MoveToEx(ARenderDC.MemDC, LRect.Right, LRect.Top, nil);
      LineTo(ARenderDC.MemDC, LRect.Right, LRect.Bottom);
    finally
      SelectObject(ARenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;
end;

{ TUserSectorSubItem }

constructor TUserSectorSubItem.Create(AParentUI: TUserSectorMenuUI);
begin
  inherited;
  FWidth := 80;
  FSubWidth := 20;
end;

destructor TUserSectorSubItem.Destroy;
begin

  inherited;
end;

function TUserSectorSubItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LSubColor: TColor;
  LBackColor: TColor;
  LFontColor: TColor;
  LPt, LPt1, LPt2: TPoint;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  if (FParentUI.FSelectedIndex = FIndex) then begin
    LSubColor := FParentUI.FUserSectorItemHotFontColor;
    LBackColor := FParentUI.FUserSectorItemHotColor;
    LFontColor := FParentUI.FUserSectorItemHotFontColor;
  end else begin
    LSubColor := FParentUI.FUserSectorItemFontColor;
    LBackColor := FParentUI.FUserSectorItemColor;
    LFontColor := FParentUI.FUserSectorItemFontColor;
    if FParentUI.MouseMoveId = FId then begin
      LSubColor := FParentUI.FUserSectorItemHotFontColor;
      LBackColor := FParentUI.FUserSectorItemHotColor;
      LFontColor := FParentUI.FUserSectorItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LSubColor := FParentUI.FUserSectorItemDownFontColor;
        LBackColor := FParentUI.FUserSectorItemDownColor;
        LFontColor := FParentUI.FUserSectorItemDownFontColor;
      end;
    end;
  end;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawText
  LRect := FRectEx;
  LRect.Right := LRect.Right - FSubWidth;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaCenter, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;

  // DrawIcon
  LRect := FRectEx;
  LRect.Left := LRect.Right - FSubWidth;
  LBorderPen := CreatePen(PS_SOLID, 2, LSubColor);
  try
    LOldObj := SelectObject(FParentUI.RenderDC.MemDC, LBorderPen);
    try
      LPt := Point((LRect.Left + LRect.Right) div 2, (LRect.Top + LRect.Bottom) div 2);
      LPt.X := LPt.X - 3;
      LPt1.X := LPt.X;
      LPt1.Y := LPt.Y + 3;
      LPt2.X := LPt.X - 6;
      LPt2.Y := LPt.Y - 3;
      MoveToEx(FParentUI.RenderDC.MemDC, LPt1.X, LPt1.Y, nil);
      LineTo(FParentUI.RenderDC.MemDC, LPt2.X, LPt2.Y);
      LPt1.X := LPt.X;
      LPt1.Y := LPt.Y + 3;
      LPt2.X := LPt.X + 6;
      LPt2.Y := LPt.Y - 3;
      MoveToEx(FParentUI.RenderDC.MemDC, LPt1.X, LPt1.Y, nil);
      LineTo(FParentUI.RenderDC.MemDC, LPt2.X, LPt2.Y);
    finally
      SelectObject(FParentUI.RenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;

  // DrawLine
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FUserSectorItemLineColor);
  try
    LRect.Right := LRect.Right - 1;
    LOldObj := SelectObject(ARenderDC.MemDC, LBorderPen);
    try
      MoveToEx(ARenderDC.MemDC, LRect.Right, LRect.Top, nil);
      LineTo(ARenderDC.MemDC, LRect.Right, LRect.Bottom);
    finally
      SelectObject(ARenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;
end;

{ TUserSectorAddItem }

constructor TUserSectorAddItem.Create(AParentUI: TUserSectorMenuUI);
begin
  inherited;
  FWidth := 120;
  FIconSize.cx := 14;
  FIconSize.cy := 14;
  FIconWidth := 20;
  FCaption := '新增自选股板块';
end;

destructor TUserSectorAddItem.Destroy;
begin

  inherited;
end;

function TUserSectorAddItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOldObj: HGDIOBJ;
  LBackColor: TColor;
  LFontColor: TColor;
  LRect, LTempRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  LBackColor := FParentUI.FUserSectorAddItemColor;
  LFontColor := FParentUI.FUserSectorAddItemFontColor;
  if FParentUI.MouseMoveId = FId then begin
    LBackColor := FParentUI.FUserSectorAddItemHotColor;
    LFontColor := FParentUI.FUserSectorAddItemHotFontColor;
    if FParentUI.MouseDownId = FId then begin
      LBackColor := FParentUI.FUserSectorAddItemDownColor;
      LFontColor := FParentUI.FUserSectorAddItemDownFontColor;
    end;
  end;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawIcon
  LRect := FRectEx;
  LRect.Right := LRect.Left + FIconWidth;
  LRect.Left := (LRect.Left + LRect.Right - FIconSize.cx) div 2;
  LRect.Top := (LRect.Top + LRect.Bottom - FIconSize.cy + 2) div 2;
  LRect.Right := LRect.Left + FIconSize.cx;
  LRect.Bottom := LRect.Right + FIconSize.cy;
  LTempRect := LRect;
  OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
  LResourceStream := FParentUI.FUserSectorAddResourceStream;
  if LResourceStream <> nil then begin
    DrawImageX(ARenderDC.GPGraphics, LResourceStream, LRect, LTempRect);
  end;

  // DrawText
  LRect := FRectEx;
  LRect.Left := LRect.Left + FIconWidth;
  LRect.Right := FRectEx.Right;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaLeft, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TUserSectorAddStockItem }

constructor TUserSectorAddStockItem.Create(AParentUI: TUserSectorMenuUI);
begin
  inherited;
  FWidth := 80;
  FIconSize.cx := 14;
  FIconSize.cy := 14;
  FIconWidth := 20;
  FCaption := '新增个股';
end;

destructor TUserSectorAddStockItem.Destroy;
begin

  inherited;
end;

function TUserSectorAddStockItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOldObj: HGDIOBJ;
  LBackColor: TColor;
  LFontColor: TColor;
  LRect, LTempRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  LBackColor := FParentUI.FUserSectorAddItemColor;
  LFontColor := FParentUI.FUserSectorAddItemFontColor;
  if FParentUI.MouseMoveId = FId then begin
    LBackColor := FParentUI.FUserSectorAddItemHotColor;
    LFontColor := FParentUI.FUserSectorAddItemHotFontColor;
    if FParentUI.MouseDownId = FId then begin
      LBackColor := FParentUI.FUserSectorAddItemDownColor;
      LFontColor := FParentUI.FUserSectorAddItemDownFontColor;
    end;
  end;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawIcon
  LRect := FRectEx;
  LRect.Right := LRect.Left + FIconWidth;
  LRect.Left := (LRect.Left + LRect.Right - FIconSize.cx) div 2;
  LRect.Top := (LRect.Top + LRect.Bottom - FIconSize.cy + 2) div 2;
  LRect.Right := LRect.Left + FIconSize.cx;
  LRect.Bottom := LRect.Right + FIconSize.cy;
  LTempRect := LRect;
  OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
  LResourceStream := FParentUI.FUserSectorAddResourceStream;
  if LResourceStream <> nil then begin
    DrawImageX(ARenderDC.GPGraphics, LResourceStream, LRect, LTempRect);
  end;

  // DrawText
  LRect := FRectEx;
  LRect.Left := LRect.Left + FIconWidth;
  LRect.Right := FRectEx.Right;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaLeft, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TUserSectorMenuUI }

constructor TUserSectorMenuUI.Create(AContext: IAppContext);
begin
  inherited;
  FShowCount := 0;
  FItemWidth := 80;
  FItemHeight := 24;
  FBorderValues := 1;
  FSelectedIndex := -1;
  FUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  FUserSectorSubItem := TUserSectorSubItem.Create(Self);
  FUserSectorAddItem := TUserSectorAddItem.Create(Self);
  FUserSectorAddStockItem := TUserSectorAddStockItem.Create(Self);
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateUserSectorMgr);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  Height := FItemHeight;
  DoUpdateSkinStyle;
  DoUpdate;
end;

destructor TUserSectorMenuUI.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  if FSubPopMenu <> nil then begin
    FSubPopMenu.Free;
  end;
  FUserSectorAddStockItem.Free;
  FUserSectorAddItem.Free;
  FUserSectorSubItem.Free;
  FUserSectorMgr := nil;
  inherited;
end;

function TUserSectorMenuUI.GetUserSectorItem(AIndex: Integer): TUserSectorItem;
begin
  if (AIndex >= 0)
    and (AIndex < FComponents.Count) then begin
    Result := TUserSectorItem(FComponents.Items[AIndex]);
  end else begin
    Result := nil;
  end;
end;

procedure TUserSectorMenuUI.DoUpdate;
var
  LIndex: Integer;
  LUserSector: TUserSector;
  LUserSectorItem: TUserSectorItem;
begin
  if FUserSectorMgr = nil then Exit;

  FUserSectorMgr.Lock;
  try
    DoClearComponents;
    for LIndex := 0 to FUserSectorMgr.GetCount - 1 do begin
      LUserSector := FUserSectorMgr.GetUserSector(LIndex);
      if LUserSector <> nil then begin
        LUserSectorItem := TUserSectorItem.Create(Self);
        LUserSectorItem.FIndex := LIndex;
        LUserSectorItem.Caption := LUserSector.Name;
        DoAddComponent(LUserSectorItem);
      end;
    end;
    FSelectedIndex := 0;
  finally
    FUserSectorMgr.UnLock;
  end;
end;

procedure TUserSectorMenuUI.DoUpdateMsgEx(AObject: TObject);
begin

end;

procedure TUserSectorMenuUI.DoUpdateSkinStyle;
var
  LResourceStream: TResourceStream;
begin
  FBackColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_BackColor');
  FBorderLineColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_BorderLineColor');
  FUserSectorItemLineColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonDivisionLineColor');
  FUserSectorItemColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonBackColor');
  FUserSectorItemFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonFontColor');
  FUserSectorItemHotColor  := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectBackColor');
  FUserSectorItemHotFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectFontColor');
  FUserSectorItemDownColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectBackColor');
  FUserSectorItemDownFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectFontColor');
  FUserSectorAddItemColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateBackColor');
  FUserSectorAddItemFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateFontColor');
  FUserSectorAddItemHotColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateBackColor');
  FUserSectorAddItemHotFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateFocusFontColor');
  FUserSectorAddItemDownColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateBackColor');
  FUserSectorAddItemDownFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonAddPlateFocusFontColor');

  if FUserSectorAddResourceStream <> nil then begin
    LResourceStream := FUserSectorAddResourceStream;
    FUserSectorAddResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FUserSectorAddResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_Add');
end;

procedure TUserSectorMenuUI.DoCalcComponentsRect;
var
  LRect: TRect;
  LIndex, LCount, LWidth: Integer;
  LUserSectorItem: TUserSectorItem;
begin
  LWidth := FComponentsRect.Width - FUserSectorAddItem.FWidth - FUserSectorAddStockItem.FWidth;
  if LWidth > 0 then begin
    LCount := LWidth div FItemWidth;
  end else begin
    LCount := 0;
  end;

  if LCount >= FComponents.Count then begin
    LCount := FComponents.Count;
    FUserSectorSubItem.Visible := False;
  end else begin
    LWidth := LWidth - FUserSectorSubItem.FWidth;
    LCount := LWidth div FItemWidth;
    FUserSectorSubItem.Visible := True;
  end;

  LRect := FComponentsRect;
  LRect.Top := LRect.Top + 1;
  LRect.Right := FComponentsRect.Left;
  for LIndex := 0 to LCount - 1 do begin
    LUserSectorItem := TUserSectorItem(FComponents.Items[LIndex]);
    if LUserSectorItem <> nil then begin
      LRect.Left := LRect.Right;
      LRect.Right := LRect.Left + FItemWidth;
      LUserSectorItem.RectEx := LRect;
    end;
  end;

  FShowCount := LCount;

  if FUserSectorSubItem.Visible then begin

    LRect.Left := LRect.Right;
    LRect.Right := LRect.Left + FUserSectorSubItem.FWidth;
    FUserSectorSubItem.RectEx := LRect;

    if FSelectedIndex < LCount then begin
      LUserSectorItem := GetUserSectorItem(LCount);
      if LUserSectorItem <> nil then begin
        FUserSectorSubItem.FIndex := LUserSectorItem.FIndex;
        FUserSectorSubItem.Caption := LUserSectorItem.FCaption;
      end;
    end else begin
      LUserSectorItem := GetUserSectorItem(FSelectedIndex);
      if LUserSectorItem <> nil then begin
        FUserSectorSubItem.FIndex := LUserSectorItem.FIndex;
        FUserSectorSubItem.Caption := LUserSectorItem.FCaption;
      end;
    end;
  end;

  LRect.Left := LRect.Right;
  LRect.Right := LRect.Left + FUserSectorAddItem.FWidth;
  FUserSectorAddItem.RectEx := LRect;

  LRect.Right := FComponentsRect.Right;
  LRect.Left := LRect.Right - FUserSectorAddStockItem.FWidth;
  FUserSectorAddStockItem.RectEx := LRect;
end;

procedure TUserSectorMenuUI.DoDrawBK(ARenderDC: TRenderDC);
var
  LBorderPen, LOldObj: HGDIOBJ;
begin
  FillSolidRect(FRenderDC.MemDC, @FComponentsRect, FBackColor);

  if (FBorderValues and $1) = $1  then begin
    LBorderPen := CreatePen(PS_SOLID, 1, FBorderLineColor);
    try
      LOldObj := SelectObject(FRenderDC.MemDC, LBorderPen);
      try
        MoveToEx(FRenderDC.MemDC, FComponentsRect.Left, FComponentsRect.Top, nil);
        LineTo(FRenderDC.MemDC, FComponentsRect.Right, FComponentsRect.Top);
      finally
        SelectObject(FRenderDC.MemDC, LOldObj);
      end;
    finally
      DeleteObject(LBorderPen);
    end;
  end;
end;

procedure TUserSectorMenuUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex, LCount: Integer;
  LUserSectorItem: TUserSectorItem;
begin
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if LIndex > FComponents.Count - 1 then begin
      Break;
    end;
    LUserSectorItem := TUserSectorItem(FComponents.Items[LIndex]);
    if (LUserSectorItem <> nil)
      and LUserSectorItem.Visible then begin
      LUserSectorItem.Draw(FRenderDC);
    end;
  end;

  if FUserSectorSubItem.Visible then begin
    FUserSectorSubItem.Draw(FRenderDC);
  end;

  FUserSectorAddItem.Draw(FRenderDC);

  FUserSectorAddStockItem.Draw(FRenderDC);
end;

function TUserSectorMenuUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex, LCount: Integer;
  LUserSectorItem: TUserSectorItem;
begin
  Result := False;
  AComponent := nil;
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if LIndex > FComponents.Count - 1 then begin
      Break;
    end;
    LUserSectorItem := TUserSectorItem(FComponents.Items[LIndex]);
    if (LUserSectorItem <> nil)
      and LUserSectorItem.Visible
      and LUserSectorItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LUserSectorItem;
      Exit;
    end;
  end;

  if (FUserSectorSubItem <> nil)
    and FUserSectorSubItem.PtInRectEx(APt) then begin
    Result := True;
    AComponent := FUserSectorSubItem;
    Exit;
  end;

  if (FUserSectorAddItem <> nil)
    and FUserSectorAddItem.PtInRectEx(APt) then begin
    Result := True;
    AComponent := FUserSectorAddItem;
    Exit;
  end;

  if (FUserSectorAddStockItem <> nil)
    and FUserSectorAddStockItem.PtInRectEx(APt) then begin
    Result := True;
    AComponent := FUserSectorAddStockItem;
    Exit;
  end;
end;

procedure TUserSectorMenuUI.DoMouseUpAfter(AComponent: TComponentUI);
var
  LPt: TPoint;
  LTextRect: TRect;
begin
  if AComponent is TUserSectorSubItem then begin
    LTextRect := AComponent.RectEx;
    LTextRect.Right := LTextRect.Right - TUserSectorSubItem(AComponent).FSubWidth;
    if PtInRect(LTextRect, FMouseUpPt) then begin
      FSelectedIndex := TUserSectorItem(AComponent).FIndex;
    end;
  end else if AComponent is TUserSectorAddItem then begin

  end else if AComponent is TUserSectorAddStockItem then begin

  end else begin
    FSelectedIndex := TUserSectorItem(AComponent).FIndex;
  end;
end;

procedure TUserSectorMenuUI.DoLClickComponent(AComponent: TComponentUI);
var
  LPt: TPoint;
  LSubRect: TRect;
  LIndex, LHeight: Integer;
  LUserSectorItem: TUserSectorItem;
  LMenuItem, LSelectMenuItem: TGilMenuItem;
begin
  if AComponent is TUserSectorSubItem then begin
    LSubRect := AComponent.RectEx;
    if PtInRect(LSubRect, FMouseUpPt) then begin
      if FSubPopMenu = nil then begin
        FSubPopMenu := TGilPopMenu.Create(FAppContext);
        FSubPopMenu.UpdateSkin;
      end;
      FSubPopMenu.ClearMenus;
      for LIndex := FShowCount to FComponents.Count -1 do begin
        LUserSectorItem := TUserSectorItem(FComponents.Items[LIndex]);
        if LUserSectorItem <> nil then begin
          LMenuItem := FSubPopMenu.AddMenuItem(LUserSectorItem.Caption, '');
          LMenuItem.OnClick := DoLClickSubMenuItem;
          LMenuItem.ID := LUserSectorItem.FIndex;
          LMenuItem.IconType := ditRadioBox;
          if LIndex = FShowCount then begin
            LSelectMenuItem := LMenuItem;
            LSelectMenuItem.Radioed := True;
          end;
          if LUserSectorItem.FIndex = FSelectedIndex then begin
            LSelectMenuItem := LMenuItem;
            LSelectMenuItem.Radioed := True;
          end;
        end;
      end;
      if FSubPopMenu.MenuItemCount > 0 then begin
        LHeight := FSubPopMenu.MenuItemHeight * FSubPopMenu.MenuItemCount;
        LPt := Self.ClientToScreen(Point(AComponent.RectEx.Left, AComponent.RectEx.Bottom));
        LPt.X := LPt.X - 3;
        LPt.Y := LPt.Y - LHeight - Self.Height - 2;
        FSubPopMenu.PopMenu(LPt);
      end;
    end;
  end else if AComponent is TUserSectorAddItem then begin

  end else if AComponent is TUserSectorAddStockItem then begin

  end else begin

  end;
end;

procedure TUserSectorMenuUI.DoLClickSubMenuItem(AObject: TObject);
var
  LMenuItem: TGilMenuItem;
begin
  LMenuItem := TGilMenuItem(AObject);
  if FUserSectorSubItem <> nil then begin
    if FUserSectorSubItem.FIndex <> LMenuItem.ID then begin
      FUserSectorSubItem.FIndex := LMenuItem.ID;
      FUserSectorSubItem.Caption := LMenuItem.Caption;
      if FUserSectorSubItem <> nil then begin
        FSelectedIndex := LMenuItem.ID;
      end;
      Invalidate;
    end;
  end;
end;

end.
