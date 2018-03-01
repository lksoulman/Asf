unit UserPositionSetUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserPositionSetUI
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
  Vcl.Forms,
  MsgEx,
  Command,
  ButtonUI,
  RenderDC,
  RenderUtil,
  AppContext,
  ComponentUI,
  CustomBaseUI,
  CustomFrameUI,
  PositionCategory,
  Generics.Collections,
  MsgExSubcriberAdapter,
  UserPositionCategoryMgr;

type

  // PositionCategoryUI
  TPositionCategoryUI = class;
  // PositionOperateUI
  TPositionOperateUI = class;

  // PositionCategoryItem
  TPositionCategoryItem = class(TComponentUI)
  private
    // Checked
    FChecked: Boolean;
    // CategoryId
    FCategoryId: Integer;
    // CheckedBoxSize
    FCheckedBoxSize: TSize;
    // ParentUI
    FParentUI: TPositionCategoryUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TPositionCategoryUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // CalcRect
    procedure CalcRect;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // PositionCategoryUI
  TPositionCategoryUI = class(TCustomFrameUI)
  private
    // ShowCount
    FShowCount: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // SelectedCategoryId
    FSelectedCategoryId: Integer;
    // BorderValues
    FBorderValues: Integer;
    // BackColor
    FBackColor: TColor;
    // BorderLineColor
    FBorderLineColor: TColor;
    // PositionCategoryItemColor
    FPositionCategoryItemColor: TColor;
    // PositionCategoryItemFontColor
    FPositionCategoryItemFontColor: TColor;
    // PositionCategoryItemHotColor
    FPositionCategoryItemHotColor: TColor;
    // PositionCategoryItemHotFontColor
    FPositionCategoryItemHotFontColor: TColor;
    // PositionCategoryItemDownColor
    FPositionCategoryItemDownColor: TColor;
    // PositionCategoryItemDownFontColor
    FPositionCategoryItemDownFontColor: TColor;

    // CheckedResourceStream
    FCheckedResourceStream: TResourceStream;
    // NoCheckedResourceStream
    FNoCheckedResourceStream: TResourceStream;
  protected
    // Update
    procedure DoUpdate;
    // Default
    procedure DoDefault;
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
    // MouseUpAfter
    procedure DoMouseUpAfter(AComponent: TComponentUI); override;
    // LClickComponent
    procedure DoLClickComponent(AComponent: TComponentUI); override;

    // GetIndex
    function DoGetIndex(ACategoryId: Integer): Integer;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // SetItemsChecked
    procedure SetItemsChecked(AChecked: Boolean);
    // SetItemsChecked
    procedure SetItemChecked(ACategoryId: Integer; AChecked: Boolean);
    // MoveTop
    procedure MoveTop;
    // MoveUp
    procedure MoveUp;
    // MoveDown
    procedure MoveDown;
    // MoveBottom
    procedure MoveBottom;
    // Default
    procedure Default;
  end;

  TOperateItem = class(TComponentUI)
  private
    // ResourceId
    FResourceId: Integer;
    // ParentUI
    FParentUI: TPositionOperateUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TPositionOperateUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // OperateLabelItem
  TOperateLabelItem = class(TComponentUI)
  private
    // ParentUI
    FParentUI: TPositionOperateUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TPositionOperateUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // PositionOperateUI
  TPositionOperateUI = class(TCustomFrameUI)
  private
    // ShowCount
    FShowCount: Integer;
    // ItemSpace
    FItemSpace: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // OperateLabelItem
    FOperateLabelItem: TOperateLabelItem;

    // BackColor
    FBackColor: TColor;
    // OperateItemColor
    FOperateItemColor: TColor;
    // OperateItemHotColor
    FOperateItemHotColor: TColor;
    // OperateItemDownColor
    FOperateItemDownColor: TColor;
    // OperateItemLabelColor
    FOperateItemLabelColor: TColor;
    // UpResourceStream
    FUpResourceStream: TResourceStream;
    // DownResourceStream
    FDownResourceStream: TResourceStream;
    // TopResourceStream
    FTopResourceStream: TResourceStream;
    // BottomResourceStream
    FBottomResourceStream: TResourceStream;
    // MoveOperateEvent
    FMoveOperateEvent: TNotifyEvent;
  protected
    // Update
    procedure DoUpdate;
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
    // LClickComponent
    procedure DoLClickComponent(AComponent: TComponentUI); override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // GetResourceStream
    function GetResourceStream(AId: Integer): TResourceStream;
  end;

  // UserPositionSetUI
  TUserPositionSetUI = class(TCustomBaseUI)
  private
    // Ok
    FBtnOk: TButtonUI;
    // Cancel
    FBtnCancel: TButtonUI;
    // DefaultButtonUI
    FBtnDefault: TButtonUI;
    // IsChangeSkin
    FIsChangeSkin: Boolean;
    // IsReLoadData
    FIsReLoadData: Boolean;
    // PositionOperateUI
    FPositionOperateUI: TPositionOperateUI;
    // PositionCategoryUI
    FPositionCategoryUI: TPositionCategoryUI;
    // UserPositionCategoryMgr
    FUserPositionCategoryMgr: IUserPositionCategoryMgr;
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // Update
    procedure DoUpdate;
    // BtnOk
    procedure DoBtnOk(Sender: TObject);
    // BtnCancel
    procedure DoBtnCancel(Sender: TObject);
    // BtnDefault
    procedure DoBtnDefault(Sender: TObject);
    // MoveOperate
    procedure DoMoveOperate(Sender: TObject);
    // SetPositionCategoryAndButtonPos
    procedure DoSetPositionCategoryAndButtonPos;
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

{ TPositionCategoryItem }

constructor TPositionCategoryItem.Create(AParentUI: TPositionCategoryUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
  FCheckedBoxSize.cx := 13;
  FCheckedBoxSize.cy := 13;
end;

destructor TPositionCategoryItem.Destroy;
begin

  inherited;
end;

procedure TPositionCategoryItem.CalcRect;
var
  LSize: TSize;
begin
  if GetTextSizeX(FParentUI.RenderDC.MemDC, FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20,
    FCaption, LSize) then begin
    FRectEx.Right := FRectEx.Left + LSize.cx + FCheckedBoxSize.cx + 10;
  end;
end;

function TPositionCategoryItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TPositionCategoryItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TPositionCategoryItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOldObj: HGDIOBJ;
  LBackColor: TColor;
  LFontColor: TColor;
  LRect, LTempRect: TRect;
  LResourceStream: TResourceStream;
begin
  LRect := FRectEx;
  LRect.Right := LRect.Left + FCheckedBoxSize.cx;
  LRect.Top := (LRect.Top + LRect.Bottom - FCheckedBoxSize.cy + 2) div 2;
  LRect.Bottom := LRect.Top + FCheckedBoxSize.cy;
  LTempRect := LRect;
  OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
  if FChecked then begin
    LResourceStream := FParentUI.FCheckedResourceStream;
  end else begin
    LResourceStream := FParentUI.FNoCheckedResourceStream;
  end;
  if LResourceStream <> nil then begin
    DrawImageX(ARenderDC.GPGraphics, LResourceStream, LRect, LTempRect);
  end;

  if FParentUI.FSelectedCategoryId = FCategoryId then begin
    LBackColor := FParentUI.FPositionCategoryItemDownColor;
    LFontColor := FParentUI.FPositionCategoryItemDownFontColor;
  end else begin
    LBackColor := FParentUI.FBackColor;
    LFontColor := FParentUI.FPositionCategoryItemFontColor;
//    if FParentUI.FMouseMoveId = FId then begin
//      LBackColor := FParentUI.FBackColor;
//      LFontColor := FParentUI.FPositionCategoryItemFontColor;
//      if FParentUI.FMouseDownId = FId then begin
//        LBackColor := FParentUI.FPositionCategoryItemColor;
//        LFontColor := FParentUI.FPositionCategoryItemFontColor;
//      end;
//    end;
  end;

  LRect.Left := LRect.Right + 5;
  LRect.Top := FRectEx.Top;
  LRect.Bottom := FRectEx.Bottom;
  LRect.Right := FRectEx.Right;
  FillSolidRect(FParentUI.RenderDC.MemDC, @LRect, LBackColor);
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaCenter, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TPositionCategoryUI }

constructor TPositionCategoryUI.Create(AContext: IAppContext);
begin
  inherited;
  FItemHeight := 24;
  FSelectedCategoryId := -1;
  DoUpdate;
end;

destructor TPositionCategoryUI.Destroy;
begin

  inherited;
end;

function TPositionCategoryUI.DoGetIndex(ACategoryId: Integer): Integer;
var
  LIndex: Integer;
  LPositionCategoryItem: TPositionCategoryItem;
begin
  Result := -1;
  for LIndex := 0 to FComponents.Count - 1 do begin
    LPositionCategoryItem := TPositionCategoryItem(FComponents.Items[LIndex]);
    if (LPositionCategoryItem <> nil)
      and (LPositionCategoryItem.FCategoryId = ACategoryId) then begin
      Result := LIndex;
    end;
  end;
end;

procedure TPositionCategoryUI.SetItemsChecked(AChecked: Boolean);
var
  LIndex: Integer;
  LPositionCategoryItem: TPositionCategoryItem;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LPositionCategoryItem := TPositionCategoryItem(FComponents.Items[LIndex]);
    if LPositionCategoryItem <> nil then begin
      LPositionCategoryItem.FChecked := AChecked;
    end;
  end;
end;

procedure TPositionCategoryUI.SetItemChecked(ACategoryId: Integer; AChecked: Boolean);
var
  LIndex: Integer;
  LPositionCategoryItem: TPositionCategoryItem;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LPositionCategoryItem := TPositionCategoryItem(FComponents.Items[LIndex]);
    if (LPositionCategoryItem <> nil)
      and (ACategoryId = LPositionCategoryItem.FCategoryId) then begin
      LPositionCategoryItem.FChecked := AChecked;
    end;
  end;
end;

procedure TPositionCategoryUI.MoveTop;
var
  LComponent: TComponentUI;
  LMoveIndex, LIndex: Integer;
begin
  LMoveIndex := DoGetIndex(FSelectedCategoryId);
  if LMoveIndex = 0 then Exit;
  
  if (LMoveIndex > 0)
    and (LMoveIndex < FComponents.Count) then begin
    LComponent := FComponents.Items[LMoveIndex];
    for LIndex := LMoveIndex downto 1 do begin
      FComponents.Items[LIndex] := FComponents.Items[LIndex - 1];
    end;
    FComponents.Items[0] := LComponent;
  end;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TPositionCategoryUI.MoveUp;
var
  LMoveIndex: Integer;
  LComponent: TComponentUI;
begin
  LMoveIndex := DoGetIndex(FSelectedCategoryId);
  if LMoveIndex = 0 then Exit;

  if (LMoveIndex > 0)
    and (LMoveIndex < FComponents.Count) then begin
    LComponent := FComponents.Items[LMoveIndex];
    FComponents.Items[LMoveIndex] := FComponents.Items[LMoveIndex - 1];
    FComponents.Items[LMoveIndex - 1] := LComponent;
  end;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TPositionCategoryUI.MoveDown;
var
  LMoveIndex: Integer;
  LComponent: TComponentUI;
begin
  LMoveIndex := DoGetIndex(FSelectedCategoryId);
  if LMoveIndex = FComponents.Count - 1 then Exit;

  if (LMoveIndex >= 0)
    and (LMoveIndex < FComponents.Count - 1) then begin
    LComponent := FComponents.Items[LMoveIndex];
    FComponents.Items[LMoveIndex] := FComponents.Items[LMoveIndex + 1];
    FComponents.Items[LMoveIndex + 1] := LComponent;
  end;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TPositionCategoryUI.MoveBottom;
var
  LComponent: TComponentUI;
  LMoveIndex, LIndex: Integer;
begin
  LMoveIndex := DoGetIndex(FSelectedCategoryId);
  if LMoveIndex = FComponents.Count - 1 then Exit;

  if (LMoveIndex >= 0)
    and (LMoveIndex < FComponents.Count - 1) then begin
    LComponent := FComponents.Items[LMoveIndex];
    for LIndex := LMoveIndex to FComponents.Count - 2 do begin
      FComponents.Items[LIndex] := FComponents.Items[LIndex + 1];
    end;
    FComponents.Items[FComponents.Count - 1] := LComponent;
  end;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TPositionCategoryUI.Default;
begin
  DoClearComponents;
  DoDefault;

  DoCalcComponentsRect;
  Invalidate;
end;

procedure TPositionCategoryUI.DoUpdate;
var
  LPositionCategoryItem: TPositionCategoryItem;
begin
  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_STOCK;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_STOCK;
  LPositionCategoryItem.FChecked := False;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_BOND;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_BOND;
  LPositionCategoryItem.FChecked := False;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUND_INNER;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUND_INNER;
  LPositionCategoryItem.FChecked := False;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUND_OUTER;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUND_OUTER;
  LPositionCategoryItem.FChecked := False;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUTURES;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUTURES;
  LPositionCategoryItem.FChecked := False;
  DoAddComponent(LPositionCategoryItem);
end;

procedure TPositionCategoryUI.DoDefault;
var
  LPositionCategoryItem: TPositionCategoryItem;
begin
  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_STOCK;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_STOCK;
  LPositionCategoryItem.FChecked := True;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_BOND;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_BOND;
  LPositionCategoryItem.FChecked := True;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUND_INNER;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUND_INNER;
  LPositionCategoryItem.FChecked := True;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUND_OUTER;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUND_OUTER;
  LPositionCategoryItem.FChecked := True;
  DoAddComponent(LPositionCategoryItem);

  LPositionCategoryItem := TPositionCategoryItem.Create(Self);
  LPositionCategoryItem.FCategoryId := POSITIONCATEGORY_FUTURES;
  LPositionCategoryItem.Caption := POSITIONCATEGORY_NAME_FUTURES;
  LPositionCategoryItem.FChecked := True;
  DoAddComponent(LPositionCategoryItem);
end;

procedure TPositionCategoryUI.DoUpdateSkinStyle;
var
  LResourceStream: TResourceStream;
begin
  FBackColor := FAppContext.GetResourceSkin.GetColor('PosManager_BackColor');
  FBorderLineColor := FAppContext.GetResourceSkin.GetColor('PosManager_SheetBorderLineColor');
  FPositionCategoryItemColor := FAppContext.GetResourceSkin.GetColor('PosManager_BackColor');
  FPositionCategoryItemFontColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonFontColor');
  FPositionCategoryItemHotColor := FAppContext.GetResourceSkin.GetColor('PosManager_BackColor');
  FPositionCategoryItemHotFontColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonFontColor');
  FPositionCategoryItemDownColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonSelectCheckColor');
  FPositionCategoryItemDownFontColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonCheckFontColor');

  if FCheckedResourceStream <> nil then begin
    LResourceStream := FCheckedResourceStream;
    FCheckedResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FCheckedResourceStream := FAppContext.GetResourceSkin.GetStream('Layout_CheckBox');

  if FNoCheckedResourceStream <> nil then begin
    LResourceStream := FNoCheckedResourceStream;
    FNoCheckedResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FNoCheckedResourceStream := FAppContext.GetResourceSkin.GetStream('Layout_UnCheckBox');
end;

procedure TPositionCategoryUI.DoCalcComponentsRect;
var
  LRect: TRect;
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  LRect := FComponentsRect;
  LRect.Inflate(-2, -2);
  LRect.Left := LRect.Left + 5;
  LRect.Bottom := LRect.Top;
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if LComponentUI <> nil then begin
      LRect.Top := LRect.Bottom;
      LRect.Bottom := LRect.Top + FItemHeight;
      LComponentUI.RectEx := LRect;
      TPositionCategoryItem(LComponentUI).CalcRect;
    end;
  end;
end;

procedure TPositionCategoryUI.DoDrawBK(ARenderDC: TRenderDC);
var
  LRect: TRect;
  LBorderPen, LOldOBJ: HGDIOBJ;
begin
  FillSolidRect(FRenderDC.MemDC, @FComponentsRect, FBackColor);

  LBorderPen := CreatePen(PS_SOLID, 1, FBorderLineColor);
  try
    LRect := FComponentsRect;
    LRect.Right := LRect.Right - 1;
    LRect.Bottom := LRect.Bottom - 1;
    DrawBorder(FRenderDC.MemDC, LBorderPen, LRect, 15);
  finally
    DeleteObject(LBorderPen);
  end;
end;

procedure TPositionCategoryUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if LComponentUI <> nil then begin
      LComponentUI.Draw(FRenderDC);
    end;
  end;
end;

function TPositionCategoryUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if (LComponentUI <> nil)
      and LComponentUI.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LComponentUI;
      Exit;
    end;
  end;
end;

procedure TPositionCategoryUI.DoMouseUpAfter(AComponent: TComponentUI);
begin
  if AComponent is TPositionCategoryItem then begin
    TPositionCategoryItem(AComponent).FChecked := not TPositionCategoryItem(AComponent).FChecked;
    FSelectedCategoryId := TPositionCategoryItem(AComponent).FCategoryId;
  end;
end;

procedure TPositionCategoryUI.DoLClickComponent(AComponent: TComponentUI);
begin

end;

{ TOperateItem }

constructor TOperateItem.Create(AParentUI: TPositionOperateUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
end;

destructor TOperateItem.Destroy;
begin

  inherited;
end;

function TOperateItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TOperateItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TOperateItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect, LTempRect: TRect;
  LResourceStream: TResourceStream;
begin
  LRect := FRectEx;
  LTempRect := LRect;
  OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
  LResourceStream := FParentUI.GetResourceStream(FResourceId);
  if LResourceStream <> nil then begin
    DrawImageX(ARenderDC.GPGraphics, LResourceStream, LRect, LTempRect);
  end;
end;

{ TOperateLabelItem }

constructor TOperateLabelItem.Create(AParentUI: TPositionOperateUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
end;

destructor TOperateLabelItem.Destroy;
begin

  inherited;
end;

function TOperateLabelItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TOperateLabelItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TOperateLabelItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LBorderPen, LOldObj: HGDIOBJ;
begin
  // DrawText
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, FCaption, FParentUI.FOperateItemLabelColor, dtaLeft, False, True);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TPositionOperateUI }

constructor TPositionOperateUI.Create(AContext: IAppContext);
begin
  inherited;
  FItemSpace := 10;
  FItemWidth := 16;
  FItemHeight := 25;
  FOperateLabelItem := TOperateLabelItem.Create(Self);
  FOperateLabelItem.Caption := '说明：上下箭头调整显示次序的优先级别（至少选中一个资产类别）';
  DoUpdate;
end;

destructor TPositionOperateUI.Destroy;
begin
  FOperateLabelItem.Free;
  inherited;
end;

function TPositionOperateUI.GetResourceStream(AId: Integer): TResourceStream;
begin
  case AId of
    0:
      begin
        Result := FTopResourceStream;
      end;
    1:
      begin
        Result := FUpResourceStream;
      end;
    2:
      begin
        Result := FDownResourceStream;
      end;
    3:
      begin
        Result := FBottomResourceStream;
      end;
  else
    Result := nil;
  end;
end;

procedure TPositionOperateUI.DoUpdate;
var
  LOperateItem: TOperateItem;
begin
  LOperateItem := TOperateItem.Create(Self);
  LOperateItem.FResourceId := 0;
  DoAddComponent(LOperateItem);

  LOperateItem := TOperateItem.Create(Self);
  LOperateItem.FResourceId := 1;
  DoAddComponent(LOperateItem);

  LOperateItem := TOperateItem.Create(Self);
  LOperateItem.FResourceId := 2;
  DoAddComponent(LOperateItem);

  LOperateItem := TOperateItem.Create(Self);
  LOperateItem.FResourceId := 3;
  DoAddComponent(LOperateItem);
end;

procedure TPositionOperateUI.DoUpdateSkinStyle;
var
  LResourceStream: TResourceStream;
begin
  FBackColor := FAppContext.GetResourceSkin.GetColor('PosManager_BackColor');
  FOperateItemColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonBackColor');
  FOperateItemHotColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonFocusBackColor');
  FOperateItemDownColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonFocusBackColor');
  FOperateItemLabelColor := FAppContext.GetResourceSkin.GetColor('PosManager_ButtonLabelFontColor');

  if FUpResourceStream <> nil then begin
    LResourceStream := FUpResourceStream;
    FUpResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FUpResourceStream := FAppContext.GetResourceSkin.GetStream('PosManager_MoveUp');

  if FDownResourceStream <> nil then begin
    LResourceStream := FDownResourceStream;
    FDownResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FDownResourceStream := FAppContext.GetResourceSkin.GetStream('PosManager_MoveDown');

  if FTopResourceStream <> nil then begin
    LResourceStream := FTopResourceStream;
    FTopResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FTopResourceStream := FAppContext.GetResourceSkin.GetStream('PosManager_MoveTop');

  if FBottomResourceStream <> nil then begin
    LResourceStream := FBottomResourceStream;
    FBottomResourceStream := nil;
    FreeAndNil(LResourceStream);
  end;
  FBottomResourceStream := FAppContext.GetResourceSkin.GetStream('PosManager_MoveBottom');
end;

procedure TPositionOperateUI.DoCalcComponentsRect;
var
  LRect: TRect;
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  LRect := FComponentsRect;
  LRect.Inflate(-2, -2);
  LRect.Bottom := LRect.Top;
  LRect.Right := LRect.Left + FItemWidth;
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if LComponentUI <> nil then begin
      LRect.Top := LRect.Bottom + FItemSpace;
      LRect.Bottom := LRect.Top + FItemHeight;
      LComponentUI.RectEx := LRect;
    end;
  end;


  LRect := FComponentsRect;
  LRect.Inflate(-2, -2);
  LRect.Top := LRect.Bottom - 46;
  FOperateLabelItem.RectEx := LRect;
end;

procedure TPositionOperateUI.DoDrawBK(ARenderDC: TRenderDC);
begin
  FillSolidRect(FRenderDC.MemDC, @FComponentsRect, FBackColor);
end;

procedure TPositionOperateUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if LComponentUI <> nil then begin
      LComponentUI.Draw(FRenderDC);
    end;
  end;
end;

function TPositionOperateUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
  LComponentUI: TComponentUI;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponentUI := FComponents.Items[LIndex];
    if (LComponentUI <> nil)
      and LComponentUI.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LComponentUI;
      Exit;
    end;
  end;
end;

procedure TPositionOperateUI.DoLClickComponent(AComponent: TComponentUI);
begin
  if Assigned(FMoveOperateEvent) then begin
    if AComponent is TOperateItem then begin
      FMoveOperateEvent(AComponent);
    end;
  end;
end;

{ TUserPositionSetUI }

constructor TUserPositionSetUI.Create(AContext: IAppContext);
begin
  inherited;
  FUserPositionCategoryMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERPOSITIONCATEGORYMGR) as IUserPositionCategoryMgr;
  FIsChangeSkin := True;
  FIsReLoadData := True;

  FPositionOperateUI := TPositionOperateUI.Create(FAppContext);
  FPositionOperateUI.Parent := Self;
  FPositionOperateUI.Align := alCustom;
  FPositionOperateUI.Width := 200;
  FPositionOperateUI.Height := 250;

  FPositionCategoryUI := TPositionCategoryUI.Create(FAppContext);
  FPositionCategoryUI.Parent := Self;
  FPositionCategoryUI.Align := alCustom;
  FPositionCategoryUI.Width := 200;
  FPositionCategoryUI.Height := 250;
  FPositionOperateUI.FMoveOperateEvent := DoMoveOperate;

  FBtnOk := TButtonUI.Create(FAppContext);
  FBtnOk.Parent := Self;
  FBtnOk.Caption := '确定';
  FBtnOk.OnClick := DoBtnOk;
  FBtnCancel := TButtonUI.Create(FAppContext);
  FBtnCancel.Parent := Self;
  FBtnCancel.Caption := '取消';
  FBtnCancel.OnClick := DoBtnCancel;
  FBtnDefault := TButtonUI.Create(FAppContext);
  FBtnDefault.Parent := Self;
  FBtnDefault.Caption := '恢复默认';
  FBtnDefault.OnClick := DoBtnDefault;

  Width := 435;
  Height := 350;
  DoSetPositionCategoryAndButtonPos;
  DoUpdateSkinStyle;
end;

destructor TUserPositionSetUI.Destroy;
begin
  FPositionCategoryUI.Free;
  FUserPositionCategoryMgr := nil;
  inherited;
end;

procedure TUserPositionSetUI.DoSetPositionCategoryAndButtonPos;
var
  LTop, LLeft: Integer;
begin
  LTop := 15;
  LLeft := 15;
  FPositionCategoryUI.Top := LTop;
  FPositionCategoryUI.Left := LLeft;

  FPositionOperateUI.Top := LTop;
  FPositionOperateUI.Left := LLeft + FPositionCategoryUI.Width + 5;

  FBtnDefault.Width := 80;
  FBtnDefault.Height := 22;
  FBtnDefault.Top := Height - 70;
  FBtnDefault.Left := Width - 235;

  FBtnOk.Width := 50;
  FBtnOk.Height := 22;
  FBtnOk.Top := Height - 70;
  FBtnOk.Left := Width - 135;

  FBtnCancel.Width := 50;
  FBtnCancel.Height := 22;
  FBtnCancel.Top := Height - 70;
  FBtnCancel.Left := Width - 65;
end;

procedure TUserPositionSetUI.ShowEx;
begin
  if FIsChangeSkin then begin
    UpdateSkinStyle;
    Invalidate;
    FIsChangeSkin := True;
  end;
  if FIsReLoadData then begin
    DoUpdate;
  end;
  SetScreenCenter;
  if not Self.Showing then begin
    Show;
  end else begin
    BringToFront;
  end;
end;

procedure TUserPositionSetUI.DoUpdateMsgEx(AObject: TObject);
var
  LMsgEx: TMsgEx;
begin
  LMsgEx := TMsgEx(AObject);
  case LMsgEx.Id of
    Msg_AsfMem_ReUpdateSectorMgr:
      begin

      end;
    Msg_AsfMem_ReUpdateAttentionMgr:
      begin
        
      end;
    Msg_AsfMain_ReUpdateSkinStyle:
      begin

      end;
  end;
end;

procedure TUserPositionSetUI.DoUpdate;
var
  LIndex: Integer;
  LPositionCategory: TPositionCategory;
begin
  if FUserPositionCategoryMgr = nil then Exit;

  FUserPositionCategoryMgr.Lock;
  try
    FPositionCategoryUI.SetItemsChecked(False);
    for LIndex := 0 to FUserPositionCategoryMgr.GetCount - 1 do begin
      LPositionCategory := FUserPositionCategoryMgr.GetPositionCategory(LIndex);
      if LPositionCategory <> nil then begin
        FPositionCategoryUI.SetItemChecked(LPositionCategory.Id, True);
      end;
    end;
  finally
    FUserPositionCategoryMgr.UnLock;
  end;
end;

procedure TUserPositionSetUI.DoBtnOk(Sender: TObject);
var
  LIndex: Integer;
  LPositionCategoryItem: TPositionCategoryItem;
begin
  if FUserPositionCategoryMgr = nil then Exit;

  FUserPositionCategoryMgr.Lock;
  try
    FUserPositionCategoryMgr.ClearData;
    for LIndex := 0 to FPositionCategoryUI.FComponents.Count - 1 do begin
      LPositionCategoryItem := TPositionCategoryItem(FPositionCategoryUI.FComponents.Items[LIndex]);
      if LPositionCategoryitem.FChecked then begin
        FUserPositionCategoryMgr.Add(LPositionCategoryitem.FCategoryId, LPositionCategoryitem.FCaption);
      end;
    end;
    FUserPositionCategoryMgr.SaveData;
  finally
    FUserPositionCategoryMgr.UnLock;
  end;

end;

procedure TUserPositionSetUI.DoBtnCancel(Sender: TObject);
begin
  Hide;
end;

procedure TUserPositionSetUI.DoBtnDefault(Sender: TObject);
begin
  FPositionCategoryUI.Default;
end;

procedure TUserPositionSetUI.DoMoveOperate(Sender: TObject);
var
  LOperateItem: TOperateItem;
begin
  LOperateItem := TOperateItem(Sender);
  case LOperateItem.FResourceId of
    0:
      begin
        FPositionCategoryUI.MoveTop;
      end;
    1:
      begin
        FPositionCategoryUI.MoveUp;
      end;
    2:
      begin
        FPositionCategoryUI.MoveDown;
      end;
    3:
      begin
        FPositionCategoryUI.MoveBottom;
      end;
  end;
end;

procedure TUserPositionSetUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderStyleEx := bsNone;
end;

procedure TUserPositionSetUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := '选择资产类别';
  end;
end;

procedure TUserPositionSetUI.DoUpdateSkinStyle;
begin
  inherited DoUpdateSkinStyle;
  if FPositionCategoryUI <> nil then begin
    FPositionCategoryUI.DoUpdateSkinStyle;
    FBackColor := FPositionCategoryUI.FBackColor;
    Color := FBackColor;
  end;
  if FPositionOperateUI <> nil then begin
    FPositionOperateUI.DoUpdateSkinStyle;
  end;
end;

end.
