unit SuperTabBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SuperTabBarExUI
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
  CustomNCUI,
  AppContext,
  CommonLock,
  ComponentUI,
  CustomMasterUI,
  SuperTabDataMgr,
  Generics.Collections;

type

  // SuperTabItem
  TSuperTabItem = class(TComponentUI)
  private
    // Parent
    FParent: TObject;
    // CommandId
    FCommandId: Integer;
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce;
    // Destructor
    destructor Destroy; override;
    // RectEx Is Valid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SuperTabBarUI
  TSuperTabBarUI = class(TCustomNCUI)
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
    procedure DoDrawBK(ARenderDC: TRenderDC);
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomMasterUI); override;
    // Destructor
    destructor Destroy; override;
    // Change
    procedure Change(ACommandId: Integer); override;
    // Calc
    procedure Calc(ADC: HDC; ARect: TRect); override;
    // Draw
    procedure Draw(ADC: HDC; ARect: TRect; AId: Integer = -1); override;

    property SelectComponentId: Integer read FSelectComponentId write FSelectComponentId;
  end;

implementation

uses
  Command;

{ TSuperTabItem }

constructor TSuperTabItem.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
end;

destructor TSuperTabItem.Destroy;
begin
  FParent := nil;
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
//  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FResourceStream = nil) then Exit;

  LRect := FRectEx;
  LRect.Bottom := LRect.Top + 65;
//  LGPImage := CreateGPImage(FResourceStream);

//  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 60, 65);
  if FId = TSuperTabBarUI(Self.FParent).SelectComponentId then begin
    OffsetRect(LSrcRect, 120, 0);
  end else begin
    if FId = TSuperTabBarUI(Self.FParent).Parent.MouseMoveId then begin
      OffsetRect(LSrcRect, 60, 0);
      if FId = TSuperTabBarUI(Self.FParent).Parent.MouseDownId then begin
        OffsetRect(LSrcRect, 60, 0);
      end;
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, FResourceStream, LRect, LSrcRect);
//  LGPImage.Free;
end;

{ TSuperTabBarUI }

constructor TSuperTabBarUI.Create(AContext: IAppContext; AParent: TCustomMasterUI);
begin
  inherited;
  FWMPAINT := WM_NCPAINT_SUPERTABBAR;
  FSuperTabDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SuperTabDataMgr) as ISuperTabDataMgr;
  FSubItems := TList<TComponentUI>.Create;
  FDrawItems := TList<TComponentUI>.Create;
  DoAddTestData;
end;

destructor TSuperTabBarUI.Destroy;
begin
  FDrawItems.Free;
  FSubItems.Free;
  FSuperTabDataMgr := nil;
  inherited;
end;

procedure TSuperTabBarUI.Change(ACommandId: Integer);
begin

end;

procedure TSuperTabBarUI.DoAddTestData;
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
        LSuperTabItem := TSuperTabItem.Create(Self);
        LSuperTabItem.Id := FParent.ComponentId.GenerateId;
        LSuperTabItem.FCommandId := LSuperTabData^.FCommandId;
        LSuperTabItem.FResourceStream := FSuperTabDataMgr.GetStream(LSuperTabData^.FResourceName);
        FComponents.Add(LSuperTabItem);
        FComponentDic.AddOrSetValue(LSuperTabItem.Id, LSuperTabItem);
      end;
    end;
  finally
    FSuperTabDataMgr.UnLock;
  end;
end;

procedure TSuperTabBarUI.Calc(ADC: HDC; ARect: TRect);
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

procedure TSuperTabBarUI.Draw(ADC: HDC; ARect: TRect; AId: Integer);
var
  LComponent: TComponentUI;
begin
  if FRenderDC.MemDC = 0 then Exit;

  if AId = -1 then begin
    if FComponentsRect.Top < FComponentsRect.Bottom - 10 then begin
      DoDrawBK(FRenderDC);
      DoDrawComponents(FRenderDC);
    end;
  end else begin
    if FComponentDic.TryGetValue(AId, LComponent) then begin
      LComponent.Draw(FRenderDC);
    end;
  end;

  FRenderDC.BitBltX(ADC, ARect);
end;

procedure TSuperTabBarUI.DoCalcDrawAndSubItems;
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

procedure TSuperTabBarUI.DoCalcDrawItems;
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

procedure TSuperTabBarUI.DoUpdateSkinStyle;
begin

end;

procedure TSuperTabBarUI.DoDrawBK(ARenderDC: TRenderDC);
begin
  FillSolidRect(ARenderDC.MemDC, @FComponentsRect, FAppContext.GetGdiMgr.GetColorRefMasterSuperTabBack);
end;

end.
