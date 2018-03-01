unit UserPositionMenuUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserPositionMenuUI
// Author£º      lksoulman
// Date£º        2018-1-22
// Comments£º
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
  PositionCategory,
  Generics.Collections,
  MsgExSubcriberAdapter,
  UserPositionCategoryMgr,
  QuoteCommMenu;

type

  TUserPositionMenuUI = class;

  // UserPositionItem
  TUserPositionItem = class(TComponentUI)
  private
    // CategoryId
    FCategoryId: Integer;
    // ParentUI
    FParentUI: TUserPositionMenuUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserPositionMenuUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserPositionSubItem
  TUserPositionSubItem = class(TUserPositionItem)
  private
    // Width
    FWidth: Integer;
    // SubWidth
    FSubWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TUserPositionMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // UserPositionMenuUI
  TUserPositionMenuUI = class(TCustomFrameUI)
  private
    // ShowCount
    FShowCount: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // BorderValues
    FBorderValues: Integer;
    // SelectedCategoryId
    FSelectedCategoryId: Integer;
    // BackColor
    FBackColor: TColor;
    // BorderLineColor
    FBorderLineColor: TColor;
    // UserPositionItemLineColor
    FUserPositionItemLineColor: TColor;
    // UserPositionItemColor
    FUserPositionItemColor: TColor;
    // UserPositionItemFontColor
    FUserPositionItemFontColor: TColor;
    // UserPositionItemHotColor
    FUserPositionItemHotColor: TColor;
    // UserPositionItemHotFontColor
    FUserPositionItemHotFontColor: TColor;
    // UserPositionItemDownColor
    FUserPositionItemDownColor: TColor;
    // UserPositionItemDownFontColor
    FUserPositionItemDownFontColor: TColor;
    // SubPopMenu
    FSubPopMenu: TGilPopMenu;
    // UserPositionMenuUI
    FUserPositionSubItem: TUserPositionSubItem;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
    // UserPositionCategoryMgr
    FUserPositionCategoryMgr: IUserPositionCategoryMgr;
    // UserPositionItemDic
    FUserPositionItemDic: TDictionary<Integer, Integer>;
  protected
    // Update
    procedure DoUpdate;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // GetIndex
    function GetIndex(ACategoryId: Integer): Integer;
    // GetUserPositionItem
    function GetUserPositionItem(AIndex: Integer): TUserPositionItem;
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
    // DoRClickComponent
    procedure DoRClickComponent(AComponent: TComponentUI); override;
    // LClickSubMenuItem
    procedure DoLClickSubMenuItem(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TUserPositionItem }

constructor TUserPositionItem.Create(AParentUI: TUserPositionMenuUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FCategoryId := FId;
  FId := FParentUI.GetUniqueId;
end;

destructor TUserPositionItem.Destroy;
begin

  inherited;
end;

function TUserPositionItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TUserPositionItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TUserPositionItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LBackColor: TColor;
  LFontColor: TColor;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  if FParentUI.FSelectedCategoryId = FCategoryId then begin
    LBackColor := FParentUI.FUserPositionItemHotColor;
    LFontColor := FParentUI.FUserPositionItemHotFontColor;
  end else begin
    LBackColor := FParentUI.FUserPositionItemColor;
    LFontColor := FParentUI.FUserPositionItemFontColor;
    if FParentUI.MouseMoveId = FId then begin
      LBackColor := FParentUI.FUserPositionItemHotColor;
      LFontColor := FParentUI.FUserPositionItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LBackColor := FParentUI.FUserPositionItemDownColor;
        LFontColor := FParentUI.FUserPositionItemDownFontColor;
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
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FUserPositionItemLineColor);
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

{ TUserPositionSubItem }

constructor TUserPositionSubItem.Create(AParentUI: TUserPositionMenuUI);
begin
  inherited;
  FWidth := 80;
  FSubWidth := 20;
end;

destructor TUserPositionSubItem.Destroy;
begin

  inherited;
end;

function TUserPositionSubItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LSubColor: TColor;
  LBackColor: TColor;
  LFontColor: TColor;
  LPt, LPt1, LPt2: TPoint;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  if (FParentUI.FSelectedCategoryId = FCategoryId) then begin
    LSubColor := FParentUI.FUserPositionItemHotFontColor;
    LBackColor := FParentUI.FUserPositionItemHotColor;
    LFontColor := FParentUI.FUserPositionItemHotFontColor;
  end else begin
    LSubColor := FParentUI.FUserPositionItemFontColor;
    LBackColor := FParentUI.FUserPositionItemColor;
    LFontColor := FParentUI.FUserPositionItemFontColor;
    if FParentUI.MouseMoveId = FId then begin
      LSubColor := FParentUI.FUserPositionItemHotFontColor;
      LBackColor := FParentUI.FUserPositionItemHotColor;
      LFontColor := FParentUI.FUserPositionItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LSubColor := FParentUI.FUserPositionItemDownFontColor;
        LBackColor := FParentUI.FUserPositionItemDownColor;
        LFontColor := FParentUI.FUserPositionItemDownFontColor;
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
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FUserPositionItemLineColor);
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

{ TUserPositionMenuUI }

constructor TUserPositionMenuUI.Create(AContext: IAppContext);
begin
  inherited;
  FUserPositionCategoryMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERPOSITIONCATEGORYMGR) as IUserPositionCategoryMgr;
  FUserPositionSubItem := TUserPositionSubItem.Create(Self);
  FUserPositionItemDic := TDictionary<Integer, Integer>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateUserPositionCategroyMgr);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FShowCount := 0;
  FItemWidth := 80;
  FItemHeight := 24;
  FBorderValues := 1;
  FSelectedCategoryId := -1;
  Height := FItemHeight;
  DoUpdateSkinStyle;
  DoUpdate;
end;

destructor TUserPositionMenuUI.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  if FSubPopMenu <> nil then begin
    FSubPopMenu.Free;
  end;
  FUserPositionItemDic.Free;
  FUserPositionSubItem.Free;
  FUserPositionCategoryMgr := nil;
  inherited;
end;

procedure TUserPositionMenuUI.DoUpdate;
var
  LIndex, LCategoryId: Integer;
  LPositionCategory: TPositionCategory;
  LUserPositionItem: TUserPositionItem;
begin
  if FUserPositionCategoryMgr = nil then Exit;

  FUserPositionCategoryMgr.Lock;
  try
    DoClearComponents;
    LCategoryId := FSelectedCategoryId;
    FSelectedCategoryId := -1;
    for LIndex := 0 to FUserPositionCategoryMgr.GetCount - 1 do begin
      LPositionCategory := FUserPositionCategoryMgr.GetPositionCategory(LIndex);
      if LPositionCategory <> nil then begin
        LUserPositionItem := TUserPositionItem.Create(Self);
        LUserPositionItem.FCategoryId := LPositionCategory.Id;
        LUserPositionItem.Caption := LPositionCategory.Name;
        DoAddComponent(LUserPositionItem);
        FUserPositionItemDic.AddOrSetValue(LUserPositionItem.FCategoryId, LIndex);

        if FSelectedCategoryId = -1 then begin
          FSelectedCategoryId := LPositionCategory.Id;
        end;

        if LCategoryId = LPositionCategory.Id then begin
          FSelectedCategoryId := LPositionCategory.Id;
        end;
      end;
    end;
  finally
    FUserPositionCategoryMgr.UnLock;
  end;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TUserPositionMenuUI.DoUpdateMsgEx(AObject: TObject);
begin
  DoUpdate;
end;

procedure TUserPositionMenuUI.DoUpdateSkinStyle;
var
  LResourceStream: TResourceStream;
begin
  FBackColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_BackColor');
  FBorderLineColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_BorderLineColor');
  FUserPositionItemLineColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonDivisionLineColor');
  FUserPositionItemColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonBackColor');
  FUserPositionItemFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonFontColor');
  FUserPositionItemHotColor  := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectBackColor');
  FUserPositionItemHotFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectFontColor');
  FUserPositionItemDownColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectBackColor');
  FUserPositionItemDownFontColor := FAppContext.GetResourceSkin.GetColor('CustomSheetMenu_ButtonSelectFontColor');
end;

function TUserPositionMenuUI.GetIndex(ACategoryId: Integer): Integer;
var
  LIndex: Integer;
begin
  if FUserPositionItemDic.TryGetValue(ACategoryId, LIndex) then begin
    Result := LIndex;
  end else begin
    Result := -1;
  end;
end;

function TUserPositionMenuUI.GetUserPositionItem(AIndex: Integer): TUserPositionItem;
begin
  if (AIndex >= 0)
    and (AIndex < FComponents.Count)then begin
    Result := TUserPositionItem(FComponents.Items[AIndex])
  end else begin
    Result := nil;
  end;
end;

procedure TUserPositionMenuUI.DoCalcComponentsRect;
var
  LRect: TRect;
  LIndex, LCount, LWidth: Integer;
  LUserPositionItem: TUserPositionItem;
begin
  LWidth := FComponentsRect.Width;
  LCount := LWidth div FItemWidth;

  if LCount >= FComponents.Count then begin
    LCount := FComponents.Count;
    if FUserPositionSubItem <> nil then begin
      FUserPositionSubItem.Visible := False;
    end;
  end else begin
    if FUserPositionSubItem <> nil then begin
      LWidth := LWidth - FUserPositionSubItem.FWidth;
      LCount := LWidth div FItemWidth;
      FUserPositionSubItem.Visible := True;
    end;
  end;

  LRect := FComponentsRect;
  LRect.Top := LRect.Top + 1;
  LRect.Right := FComponentsRect.Left;
  for LIndex := 0 to LCount - 1 do begin
    LUserPositionItem := TUserPositionItem(FComponents.Items[LIndex]);
    if LUserPositionItem <> nil then begin
      LRect.Left := LRect.Right;
      LRect.Right := LRect.Left + FItemWidth;
      LUserPositionItem.RectEx := LRect;
    end;
  end;
  FShowCount := LCount;

  if (FUserPositionSubItem <> nil)
    and FUserPositionSubItem.Visible then begin
    LRect.Left := LRect.Right;
    LRect.Right := LRect.Left + FUserPositionSubItem.FWidth;
    FUserPositionSubItem.RectEx := LRect;
    LIndex := GetIndex(FSelectedCategoryId);
    if LIndex <> -1 then begin
      if LIndex < LCount then begin
        LUserPositionItem := GetUserPositionItem(LCount);
        if LUserPositionItem <> nil then begin
          FUserPositionSubItem.FCategoryId := LUserPositionItem.FCategoryId;
          FUserPositionSubItem.Caption := LUserPositionItem.Caption;
        end;
      end else begin
        LUserPositionItem := GetUserPositionItem(LIndex);
        if LUserPositionItem <> nil then begin
          FUserPositionSubItem.FCategoryId := LUserPositionItem.FCategoryId;
          FUserPositionSubItem.Caption := LUserPositionItem.Caption;
        end;
      end;
    end;
  end;
end;

procedure TUserPositionMenuUI.DoDrawBK(ARenderDC: TRenderDC);
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

procedure TUserPositionMenuUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex, LCount: Integer;
  LUserPositionItem: TUserPositionItem;
begin
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if LIndex > FComponents.Count - 1 then begin
      Break;
    end;
    LUserPositionItem := TUserPositionItem(FComponents.Items[LIndex]);
    if (LUserPositionItem <> nil)
      and LUserPositionItem.Visible then begin
      LUserPositionItem.Draw(FRenderDC);
    end;
  end;

  if (FUserPositionSubItem <> nil)
    and FUserPositionSubItem.Visible then begin
    FUserPositionSubItem.Draw(FRenderDC);
  end;
end;

function TUserPositionMenuUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex, LCount: Integer;
  LUserPositionItem: TUserPositionItem;
begin
  Result := False;
  AComponent := nil;
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if LIndex > FComponents.Count - 1 then begin
      Break;
    end;
    LUserPositionItem := TUserPositionItem(FComponents.Items[LIndex]);
    if (LUserPositionItem <> nil)
      and LUserPositionItem.Visible
      and LUserPositionItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LUserPositionItem;
      Exit;
    end;
  end;

  if (FUserPositionSubItem <> nil)
    and FUserPositionSubItem.Visible
    and FUserPositionSubItem.PtInRectEx(APt) then begin
    Result := True;
    AComponent := FUserPositionSubItem;
    Exit;
  end;
end;

procedure TUserPositionMenuUI.DoMouseUpAfter(AComponent: TComponentUI);
begin
  if AComponent is TUserPositionSubItem then begin

  end else begin

  end;
end;

procedure TUserPositionMenuUI.DoLClickComponent(AComponent: TComponentUI);
var
  LPt: TPoint;
  LSubRect: TRect;
  LIndex, LHeight: Integer;
  LUserPostionItem: TUserPositionItem;
  LMenuItem, LSelectMenuItem: TGilMenuItem;
begin
  if AComponent is TUserPositionSubItem then begin
    LSubRect := AComponent.RectEx;
    if PtInRect(LSubRect, FMouseUpPt) then begin
      if FSubPopMenu = nil then begin
        FSubPopMenu := TGilPopMenu.Create(FAppContext);
        FSubPopMenu.UpdateSkin;
      end;
      FSubPopMenu.ClearMenus;
      for LIndex := FShowCount to FComponents.Count -1 do begin
        LUserPostionItem := TUserPositionItem(FComponents.Items[LIndex]);
        if LUserPostionItem <> nil then begin
          LMenuItem := FSubPopMenu.AddMenuItem(LUserPostionItem.Caption, '');
          LMenuItem.OnClick := DoLClickSubMenuItem;
          LMenuItem.ID := LUserPostionItem.FCategoryId;
          LMenuItem.IconType := ditRadioBox;
          if LIndex = FShowCount then begin
            LSelectMenuItem := LMenuItem;
            LSelectMenuItem.Radioed := True;
          end;
          if LUserPostionItem.FCategoryId = FSelectedCategoryId then begin
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
  end else begin

  end;
end;

procedure TUserPositionMenuUI.DoRClickComponent(AComponent: TComponentUI);
begin
  FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_USERPOSITIONSET, 'FuncName=Show');
end;

procedure TUserPositionMenuUI.DoLClickSubMenuItem(AObject: TObject);
begin

end;

end.

