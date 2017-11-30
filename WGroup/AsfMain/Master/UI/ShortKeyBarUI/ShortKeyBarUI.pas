unit ShortKeyBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ShortKeyBarUI
// Author£º      lksoulman
// Date£º        2017-10-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  GDIPOBJ,
  RenderDC,
  RenderUtil,
  AppContext,
  ComponentUI,
  ShortKeyDataMgr,
  CommonRefCounter,
  Generics.Collections;

type

  // ShortKeyItem
  TShortKeyItem = class(TComponentUI)
  private
    // Parent
    FParent: TObject;
    // CommandId
    FCommandId: Integer;
    // CommanParams
    FCommandParams: string;
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // ShortKeyBarUI
  TShortKeyBarUI = class(TAutoObject)
  private
    // Incr Id
    FIncrId: Integer;
    // Hit Id
    FHitId: Integer;
    // Down Hit Id
    FDownHitId: Integer;
    // Left ShortKeyRect
    FLShortKeyRect: TRect;
    // Right ShortKeyRect
    FRShortKeyRect: TRect;
    // ParentHandle
    FParentHandle: THandle;
    // AppContext
    FAppContext: IAppContext;
    // On Click Item
    FOnClickItem: TNotifyEvent;
    // ShortKeyDataMgr
    FShortKeyDataMgr: IShortKeyDataMgr;
    // Left ShorKeyItems
    FLShortKeyItems: TList<TShortKeyItem>;
    // Right ShorKeyItems
    FRShortKeyItems: TList<TShortKeyItem>;
    // ShorKeyItemsDic
    FShortKeyItemDic: TDictionary<Integer, TShortKeyItem>;
  protected
    // IncrId
    function DoIncrId: Integer;
    // Calc Items
    procedure DoCalcItems(ARect: TRect);
    // Clear Items
    procedure DoClearItems(AItems: TList<TShortKeyItem>);
    // Paint Menu Items
    procedure DoDrawItems(ARenderDC: TRenderDC; ARect: TRect; AItems: TList<TShortKeyItem>);
    // Menu Item Dic Add
    procedure DoMenuItemDicAdd(AMenuItem: TShortKeyItem);
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Update
    procedure UpdateData;
    // ClickItem
    procedure ClickItem(AObject: TObject);
    // Draw
    procedure Draw(ARenderDC: TRenderDC; ARect: TRect);
    // Get Menu Item
    function GetMenuItemById(AId: Integer): TShortKeyItem;
    // Get Menu Item
    function GetMenuItemByPt(ARect: TRect; APt: TPoint; var AMenuItem: TShortKeyItem): Boolean;


    property HitId: Integer read FHitId write FHitId;
    property DownHitId: Integer read FDownHitId write FDownHitId;
    property ParentHandle: THandle read FParentHandle write FParentHandle;
    property OnClickItem: TNotifyEvent read FOnClickItem write FOnClickItem;
  end;

implementation

uses
  Command;

{ TShortKeyItem }

constructor TShortKeyItem.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
  FRectEx := Rect(0, 0, 0, 0);
end;

destructor TShortKeyItem.Destroy;
begin
  inherited;
end;

function TShortKeyItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TShortKeyItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FResourceStream = nil) then Exit;

  LRect := FRectEx;
  LRect.Left := LRect.Right - 30;
  LGPImage := CreateGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TShortKeyBarUI(Self.FParent).HitId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TShortKeyBarUI(Self.FParent).DownHitId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TShortKeyBarUI }

constructor TShortKeyBarUI.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FShortKeyDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SHORTKEYDATAMGR) as IShortKeyDataMgr;
  FIncrId := 0;
  FHitId := -1;
  FDownHitId := -1;
  FLShortKeyItems := TList<TShortKeyItem>.Create;
  FRShortKeyItems := TList<TShortKeyItem>.Create;
  FShortKeyItemDic := TDictionary<Integer, TShortKeyItem>.Create(15);
  UpdateData;
end;

destructor TShortKeyBarUI.Destroy;
begin
  DoClearItems(FLShortKeyItems);
  DoClearItems(FRShortKeyItems);
  FLShortKeyItems.Free;
  FRShortKeyItems.Free;
  FShortKeyItemDic.Free;
  FShortKeyDataMgr := nil;
  FAppContext := nil;
  inherited;
end;

procedure TShortKeyBarUI.UpdateData;
var
  LIndex: Integer;
  LShortKeyData: PShortKeyData;
  LShortKeyItem: TShortKeyItem;
begin
  if FShortKeyDataMgr = nil then Exit;

  FShortKeyDataMgr.Lock;
  try
    for LIndex := 0 to FShortKeyDataMgr.GetDataCount - 1 do begin
      LShortKeyData := FShortKeyDataMgr.GetData(LIndex);
      if LShortKeyData <> nil then begin
        LShortKeyItem := TShortKeyItem.Create(Self);
        LShortKeyItem.Id := DoIncrId;
        LShortKeyItem.FCommandId := LShortKeyData^.FCommandId;
        LShortKeyItem.FCommandParams := LShortKeyData^.FCommandParams;
        LShortKeyItem.FResourceStream := FShortKeyDataMgr.GetStream(LShortKeyData^.FResourceName);
        DoMenuItemDicAdd(LShortKeyItem);
        if LIndex < 2 then begin
          FLShortKeyItems.Add(LShortKeyItem);
        end else begin
          FRShortKeyItems.Add(LShortKeyItem);
        end;
      end;
    end;
  finally
    FShortKeyDataMgr.UnLock;
  end;
end;

procedure TShortKeyBarUI.ClickItem(AObject: TObject);
begin
  if AObject = nil then Exit;

  FAppContext.GetCommandMgr.ExecuteCmd(TShortKeyItem(AObject).FCommandId,
    TShortKeyItem(AObject).FCommandParams);
end;

procedure TShortKeyBarUI.Draw(ARenderDC: TRenderDC; ARect: TRect);
begin
  if ARenderDC.MemDC = 0 then Exit;
  if ARect.Left >= ARect.Right then Exit;

  DoCalcItems(ARect);

  if FLShortKeyRect.Left < FLShortKeyRect.Right then begin
    DoDrawItems(ARenderDC, FLShortKeyRect, FLShortKeyItems);
  end;

  if FRShortKeyRect.Left < FRShortKeyRect.Right then begin
    DoDrawItems(ARenderDC, FRShortKeyRect, FRShortKeyItems);
  end;
end;

function TShortKeyBarUI.GetMenuItemById(AId: Integer): TShortKeyItem;
begin
  if not FShortKeyItemDic.TryGetValue(AId, Result) then begin
    Result := nil;
  end;
end;

function TShortKeyBarUI.GetMenuItemByPt(ARect: TRect; APt: TPoint; var AMenuItem: TShortKeyItem): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AMenuItem := nil;
  DoCalcItems(ARect);

  if PtInRect(FLShortKeyRect, APt) then begin
    for LIndex := 0 to FLShortKeyItems.Count - 1 do begin
      AMenuItem := FLShortKeyItems.Items[LIndex];
      if AMenuItem.Visible
        and AMenuItem.RectExIsValid then begin
        if PtInRect(AMenuItem.RectEx, APt) then begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;

  if PtInRect(FRShortKeyRect, APt) then begin
    for LIndex := 0 to FRShortKeyItems.Count - 1 do begin
      AMenuItem := FRShortKeyItems.Items[LIndex];
      if AMenuItem.Visible
        and AMenuItem.RectExIsValid then begin
        if PtInRect(AMenuItem.RectEx, APt) then begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

function TShortKeyBarUI.DoIncrId: Integer;
begin
  Result := FIncrId;
  Inc(FIncrId);
end;

procedure TShortKeyBarUI.DoClearItems(AItems: TList<TShortKeyItem>);
var
  LIndex: Integer;
  LShortKeyItem: TShortKeyItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LShortKeyItem := AItems.Items[LIndex];
    if LShortKeyItem <> nil then begin
      LShortKeyItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TShortKeyBarUI.DoMenuItemDicAdd(AMenuItem: TShortKeyItem);
begin
  FShortKeyItemDic.AddOrSetValue(AMenuItem.Id, AMenuItem);
end;

procedure TShortKeyBarUI.DoCalcItems(ARect: TRect);
var
  LIndex: Integer;
  LRectEx, LFixRect, LLeftFixRect, LRightFixRect: TRect;
  LShortKeyItem: TShortKeyItem;

  procedure CalcRectL(ALeft, AWidth: Integer; var ARectEx: TRect);
  begin
    ARectEx := LLeftFixRect;
    ARectEx.Left := ALeft;

    if ALeft < LLeftFixRect.Right then begin
      ARectEx.Right := ALeft + AWidth;
    end else begin
      ARectEx.Right := LLeftFixRect.Right;
    end;

    if ARectEx.Right > LLeftFixRect.Right then begin
      ARectEx.Right := LLeftFixRect.Right;
    end;

    if ARectEx.Left > LLeftFixRect.Right then begin
      ARectEx.Left := LLeftFixRect.Right;
    end;
  end;

  procedure CalcRectR(ARight, AWidth: Integer; var ARectEx: TRect);
  begin
    ARectEx := LRightFixRect;
    ARectEx.Right := ARight;

    if ARight > LRightFixRect.Left then begin
      ARectEx.Left := ARight - AWidth;
    end else begin
      ARectEx.Left := LRightFixRect.Left;
    end;

    if ARectEx.Left < LRightFixRect.Left then begin
      ARectEx.Left := LRightFixRect.Left;
    end;

    if ARectEx.Right < LRightFixRect.Left then begin
      ARectEx.Right := LRightFixRect.Left;
    end;
  end;

  procedure CalcRMenuItemRectEx(var ARectEx: TRect);
  begin
    if ARectEx.Left > LFixRect.Left then begin
      OffsetRect(ARectEx, -30, 0);
      if ARectEx.Left < LFixRect.Left then begin
        ARectEx.Left := LFixRect.Left;
      end;
      if ARectEx.Right < LFixRect.Left then begin
        ARectEx.Right := LFixRect.Left;
      end;
    end else begin
      if ARectEx.Left < LFixRect.Left then begin
        ARectEx.Left := LFixRect.Left;
      end;
      if ARectEx.Right > LFixRect.Left then begin
        ARectEx.Right := LFixRect.Left;
      end;
    end;

    if ARectEx.Right > LFixRect.Right then begin
      ARectEx.Right := LFixRect.Right;
    end;
  end;
begin
  LLeftFixRect := ARect;
  LRectEx.Right := LLeftFixRect.Left;
  for LIndex := 0 to FLShortKeyItems.Count - 1 do begin
    LShortKeyItem := FLShortKeyItems.Items[LIndex];
    if LShortKeyItem.Visible then begin
      CalcRectL(LRectEx.Right, 30, LRectEx);
      LShortKeyItem.RectEx := LRectEx;
    end;
  end;
  FLShortKeyRect := LLeftFixRect;
  FLShortKeyRect.Right := LRectEx.Right;


  LRightFixRect := ARect;
  LRightFixRect.Left := LRectEx.Right;
  LRectEx.Left := LRightFixRect.Right;
  for LIndex := 0 to FRShortKeyItems.Count - 1 do begin
    LShortKeyItem := FRShortKeyItems.Items[LIndex];
    if LShortKeyItem.Visible then begin
      CalcRectR(LRectEx.Left, 30, LRectEx);
      LShortKeyItem.RectEx := LRectEx;
    end;
  end;
  FRShortKeyRect := LRightFixRect;
  FRShortKeyRect.Left := LRectEx.Left;
end;

procedure TShortKeyBarUI.DoDrawItems(ARenderDC: TRenderDC; ARect: TRect; AItems: TList<TShortKeyItem>);
var
  LClipRgn: HRGN;
  LIndex: Integer;
  LShortKeyItem: TShortKeyItem;
begin
  LClipRgn := CreateRectRgnIndirect(ARect);
  if LClipRgn = 0 then Exit;
  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
  try
    for LIndex := 0 to AItems.Count - 1 do begin
      LShortKeyItem := AItems.Items[LIndex];
      if LShortKeyItem.Visible
        and LShortKeyItem.RectExIsValid then begin
        LShortKeyItem.Draw(ARenderDC);
      end;
    end;
  finally
    SelectClipRgn(ARenderDC.MemDC, 0);
    DeleteObject(LClipRgn);
  end;
end;

end.
