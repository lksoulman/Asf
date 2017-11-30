unit SuperTabBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SuperTabBarUI
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
  FrameUI,
  RenderDC,
  RenderGDI,
  RenderUtil,
  AppContext,
  CommonLock,
  ComponentUI,
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
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SuperTabBarUI
  TSuperTabBarUI = class(TFrameUI)
  private
    // Lock
    FLock: TCSLock;
    // SuperTabDataMgr
    FSuperTabDataMgr: ISuperTabDataMgr;
    // Items
    FItems: TList<TSuperTabItem>;
    // Draw Items
    FDrawItems: TList<TSuperTabItem>;
    // Sub Draw Items
    FSubDrawItems: TList<TSuperTabItem>;
    // Super Tab Item Dic
    FSuperTabItemDic: TDictionary<Integer, TSuperTabItem>;
  protected
    // Clear Items
    procedure DoClearItems(AItems: TList<TSuperTabItem>);
    // Super Tab Item Dic Add
    procedure DoSuperTabItemDicAdd(ATabItem: TSuperTabItem);

    // Calc Change Size
    procedure DoCalcChangeSize(AFrameRect: TRect);
    // Calc Super Tab Items
    procedure DoCalcSuperTabItems(AFrameRect: TRect);
    // Size
    procedure DoSize(AWidth, AHeight: Integer); override;
    // Update Skin Style
    procedure DoUpdateSkinStyle; override;
    // Paint Backgroud
    procedure DoDrawBK(ARect: TRect); override;
    // Paint Components
    procedure DoDrawComponents(ARect: TRect); override;
    // LButton Click Component
    procedure DoLButtonClickComponent(AComponent: TComponentUI); override;
    // Find Component
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // UpdateData
    procedure UpdateData;
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

function TSuperTabItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FResourceStream = nil) then Exit;

  LRect := FRectEx;
  LRect.Bottom := LRect.Top + 65;
  LGPImage := CreateGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 60, 65);
  if FId = TSuperTabBarUI(Self.FParent).SelectComponentId then begin
    OffsetRect(LSrcRect, 120, 0);
  end else begin
    if FId = TSuperTabBarUI(Self.FParent).MouseMoveComponentId then begin
      OffsetRect(LSrcRect, 60, 0);
      if FId = TSuperTabBarUI(Self.FParent).MouseDownComponentId then begin
        OffsetRect(LSrcRect, 60, 0);
      end;
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TSuperTabBarUI }

constructor TSuperTabBarUI.Create(AContext: IAppContext);
begin
  inherited;
  FSuperTabDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SuperTabDataMgr) as ISuperTabDataMgr;
  FLock := TCSLock.Create;
  FItems := TList<TSuperTabItem>.Create;
  FDrawItems := TList<TSuperTabItem>.Create;
  FSubDrawItems := TList<TSuperTabItem>.Create;
  FSuperTabItemDic := TDictionary<Integer, TSuperTabItem>.Create(25);
  UpdateData;
end;

destructor TSuperTabBarUI.Destroy;
begin
  DoClearItems(FItems);
  FSuperTabItemDic.Free;
  FSubDrawItems.Free;
  FDrawItems.Free;
  FLock.Free;
  FSuperTabDataMgr := nil;
  inherited;
end;

procedure TSuperTabBarUI.UpdateData;
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
        LSuperTabItem.Id := DoGetIncrId;
        LSuperTabItem.FCommandId := LSuperTabData^.FCommandId;
        LSuperTabItem.FResourceStream := FSuperTabDataMgr.GetStream(LSuperTabData^.FResourceName);
        DoSuperTabItemDicAdd(LSuperTabItem);
        FItems.Add(LSuperTabItem);
      end;
    end;
  finally
    FSuperTabDataMgr.UnLock;
  end;
end;

procedure TSuperTabBarUI.DoCalcChangeSize(AFrameRect: TRect);
var
  LIndex, LCount, LMod: Integer;
begin
  try
    FDrawItems.Clear;
    FSubDrawItems.Clear;
    FComponentDic.Clear;

    if AFrameRect.Height > 0 then begin
      LCount := AFrameRect.Height div 65;
      LMod := AFrameRect.Height mod 65;
      if LMod > 0 then begin
        Inc(LCount);
      end;
    end else begin
      LCount := 0;
    end;

    if LCount > FItems.Count then begin
      LCount := FItems.Count;
    end;

    for LIndex := 0 to LCount - 1 do begin
      FDrawItems.Add(FItems.Items[LIndex]);
      FComponentDic.AddOrSetValue(FItems.Items[LIndex].Id, FItems.Items[LIndex]);
    end;

    for LIndex := LCount to FItems.Count - 1 do begin
      FSubDrawItems.Add(FItems.Items[LIndex]);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TSuperTabBarUI.DoCalcSuperTabItems(AFrameRect: TRect);
var
  LRect: TRect;
  LIndex: Integer;
  LSuperTabItem: TSuperTabItem;
begin
  LRect := AFrameRect;
  LRect.Bottom := LRect.Top + 65;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    if LRect.Bottom > AFrameRect.Bottom then begin
      LRect.Bottom := AFrameRect.Bottom;
    end;
    LSuperTabItem := FDrawItems.Items[LIndex];
    LSuperTabItem.RectEx := LRect;
    OffsetRect(LRect, 0, 65);
    if (LRect.Left >= AFrameRect.Bottom)
      and (LRect.Bottom >= AFrameRect.Bottom) then begin
      Break;
    end;
  end;
end;

procedure TSuperTabBarUI.DoClearItems(AItems: TList<TSuperTabItem>);
var
  LIndex: Integer;
  LSuperTabItem: TSuperTabItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LSuperTabItem := AItems.Items[LIndex];
    if LSuperTabItem <> nil then begin
      LSuperTabItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TSuperTabBarUI.DoSuperTabItemDicAdd(ATabItem: TSuperTabItem);
begin
  FSuperTabItemDic.AddOrSetValue(ATabItem.Id, ATabItem);
end;

procedure TSuperTabBarUI.DoSize(AWidth, AHeight: Integer);
begin
  inherited;
  DoCalcChangeSize(FFrameRectEx);
  DoCalcSuperTabItems(FFrameRectEx);
end;

procedure TSuperTabBarUI.DoUpdateSkinStyle;
begin

end;

procedure TSuperTabBarUI.DoDrawBK(ARect: TRect);
begin
  FillSolidRect(FFrameRenderDC.MemDC, @ARect, FAppContext.GetGdiMgr.GetColorRefMasterSuperTabBack);
end;

procedure TSuperTabBarUI.DoDrawComponents(ARect: TRect);
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    LComponent := FDrawItems.Items[LIndex];
    if LComponent.Visible then begin
      LComponent.Draw(FFrameRenderDC);
    end;
  end;
end;

procedure TSuperTabBarUI.DoLButtonClickComponent(AComponent: TComponentUI);
begin
  if Assigned(FOnClickItem) then begin
    FOnClickItem(AComponent);
  end;
end;

function TSuperTabBarUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    AComponent := FDrawItems.Items[LIndex];
    if AComponent.Visible
      and PtInRect(AComponent.RectEx, APt) then begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
