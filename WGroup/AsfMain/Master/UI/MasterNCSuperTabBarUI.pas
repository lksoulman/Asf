unit MasterNCSuperTabBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterNCSuperTabBarUI
// Author£º      lksoulman
// Date£º        2017-10-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  GDIPOBJ,
  RenderDC,
  RenderUtil,
  AppContext,
  CommonLock,
  ComponentUI,
  CustomBaseUI,
  CustomMasterUI,
  SuperTabDataMgr,
  Generics.Collections;

type

  // SuperTabItem
  TSuperTabItem = class(TCustomItem)
  private
    // CommandId
    FCommandId: Integer;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TNCCustomBaseUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // RectEx Is Valid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // MasterNCSuperTabBarUI
  TMasterNCSuperTabBarUI = class(TNCSuperTabBarUI)
  private
    // SelectComponentId
    FSelectComponentId: Integer;
    // SubItems
    FSubItems: TList<TComponentUI>;
    // SubItems
    FDrawItems: TList<TComponentUI>;
    // SuperTabDataMgr
    FSuperTabDataMgr: ISuperTabDataMgr;
  protected
    // AddTestData
    procedure DoAddTestData;
    // CalcSubItems
    procedure DoCalcDrawItems;
    // CalcDrawAndSubItems
    procedure DoCalcDrawAndSubItems;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); override;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); override;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
    // Change
    procedure Change(ACommandId: Integer); override;
    // Calc
    procedure Calc(ADC: HDC; ARect: TRect); override;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); override;
    // FindComponent
    function FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
  end;

implementation

uses
  Command;

{ TSuperTabItem }

constructor TSuperTabItem.Create(AContext: IAppContext; AParentUI: TNCCustomBaseUI);
begin
  inherited;

end;

destructor TSuperTabItem.Destroy;
begin

  inherited;
end;

function TSuperTabItem.RectExIsValid: Boolean;
begin
  Result := True;
end;

function TSuperTabItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TSuperTabItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FResourceStream = nil) then Exit;

  LRect := FRectEx;
  LRect.Bottom := LRect.Top + 65;

  LSrcRect := Rect(0, 0, 60, 65);
  if FId = TMasterNCSuperTabBarUI(FParentUI).FSelectComponentId then begin
    OffsetRect(LSrcRect, 120, 0);
  end else begin
    if FId = FParentUI.ParentUI.NCMouseMoveId then begin
      OffsetRect(LSrcRect, 60, 0);
      if FId = FParentUI.ParentUI.NCMouseDownId then begin
        OffsetRect(LSrcRect, 60, 0);
      end;
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, FResourceStream, LRect, LSrcRect);
end;

{ TMasterNCSuperTabBarUI }

constructor TMasterNCSuperTabBarUI.Create(AContext: IAppContext; AParentUI: TCustomBaseUI);
begin
  inherited;
  FSuperTabDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SuperTabDataMgr) as ISuperTabDataMgr;
  FSubItems := TList<TComponentUI>.Create;
  FDrawItems := TList<TComponentUI>.Create;
  DoAddTestData;
end;

destructor TMasterNCSuperTabBarUI.Destroy;
begin
  FDrawItems.Free;
  FSubItems.Free;
  FSuperTabDataMgr := nil;
  inherited;
end;

procedure TMasterNCSuperTabBarUI.Change(ACommandId: Integer);
begin

end;

procedure TMasterNCSuperTabBarUI.DoAddTestData;
var
  LIndex: Integer;
  LSuperTabData: PSuperTabData;
  LSuperTabItem: TSuperTabItem;
begin
  if FSuperTabDataMgr = nil then Exit;

  FSuperTabDataMgr.Lock;
  try
    for LIndex := 0 to FSuperTabDataMgr.GetDataCount - 1 do begin
      LSuperTabData := FSuperTabDataMgr.GetData(LIndex);
      if LSuperTabData <> nil then begin
        LSuperTabItem := TSuperTabItem.Create(FAppContext, Self);
        DoAddComponent(LSuperTabItem);
        LSuperTabItem.FCommandId := LSuperTabData^.FCommandId;
        LSuperTabItem.FResourceStream := FSuperTabDataMgr.GetStream(LSuperTabData^.FResourceName);
      end;
    end;
  finally
    FSuperTabDataMgr.UnLock;
  end;
end;

procedure TMasterNCSuperTabBarUI.Calc(ADC: HDC; ARect: TRect);
begin
  if not FRenderDC.IsInit then begin
    FRenderDC.SetDC(ADC);
  end;

  if FRenderDC.MemDC = 0 then Exit;

  FComponentsRect := ARect;
  FRenderDC.SetBounds(ADC, FComponentsRect);
  if FComponentsRect.Top < FComponentsRect.Bottom - 10 then begin
    DoCalcDrawAndSubItems;
    DoCalcDrawItems;
  end;
end;

procedure TMasterNCSuperTabBarUI.LButtonClickComponent(AComponent: TComponentUI);
var
  LInnerCode: Integer;
  LSuperTabItem: TSuperTabItem;
begin
  if AComponent Is TSuperTabItem then begin
    LSuperTabItem := TSuperTabItem(AComponent);
    if LSuperTabItem.FCommandId = ASF_COMMAND_ID_SIMPLEHQTIMETEST then begin
      LInnerCode := 1752;
    end else begin
      LInnerCode := 1;
    end;
    FAppContext.GetCommandMgr.ExecuteCmd(LSuperTabItem.FCommandId, Format('MasterHandle=%d@Params=InnerCode=%d', [FParentUI.Handle, LInnerCode]));
  end;
end;

function TMasterNCSuperTabBarUI.FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    AComponent := FDrawItems.Items[LIndex];
    if AComponent.Visible
      and AComponent.RectExIsValid
      and AComponent.PtInRectEx(APt) then begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TMasterNCSuperTabBarUI.DoCalcDrawAndSubItems;
var
  LIndex, LCount, LMod: Integer;
begin
  FSubItems.Clear;
  FDrawItems.Clear;
  if FComponentsRect.Height > 0 then begin
    LCount := FComponentsRect.Height div 65;
    LMod := FComponentsRect.Height mod 65;
    if LMod > 0 then begin
      Inc(LCount);
    end;
  end else begin
    LCount := 0;
  end;

  if LCount > FComponents.Count then begin
    LCount := FComponents.Count;
  end;

  for LIndex := 0 to LCount - 1 do begin
    FDrawItems.Add(FComponents.Items[LIndex]);
  end;

  for LIndex := LCount to FComponents.Count - 1 do begin
    FSubItems.Add(FComponents.Items[LIndex]);
  end;
end;

procedure TMasterNCSuperTabBarUI.DoCalcDrawItems;
var
  LRect: TRect;
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  LRect := FComponentsRect;
  LRect.Bottom := LRect.Top + 65;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    if LRect.Bottom > FComponentsRect.Bottom then begin
      LRect.Bottom := FComponentsRect.Bottom;
    end;
    LComponent := FDrawItems.Items[LIndex];
    LComponent.RectEx := LRect;
    OffsetRect(LRect, 0, 65);
    if (LRect.Left >= FComponentsRect.Bottom)
      and (LRect.Bottom >= FComponentsRect.Bottom) then begin
      Break;
    end;
  end;
end;

procedure TMasterNCSuperTabBarUI.DoUpdateSkinStyle;
begin

end;

procedure TMasterNCSuperTabBarUI.DoDrawBK(ARenderDC: TRenderDC);
begin
  FillSolidRect(ARenderDC.MemDC, @FComponentsRect, FAppContext.GetGdiMgr.GetColorRefMasterSuperTabBack);
end;

procedure TMasterNCSuperTabBarUI.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    LComponent := FDrawItems.Items[LIndex];
    if LComponent.Visible
      and LComponent.RectExIsValid then begin
      LComponent.Draw(ARenderDC);
    end;
  end;
end;

end.
