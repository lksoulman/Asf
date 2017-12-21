unit CaptionBarUI;

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
  CustomNCUI,
  AppContext,
  ComponentUI,
  CustomMasterUI,
  ShortKeyDataMgr,
  CommonRefCounter,
  Generics.Collections;

type

  // Custom
  TCustomItem = class(TComponentUI)
  private
  protected
    // Parent
    FParent: TObject;
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
  end;

  // LogoIconItem
  TLogoIconItem = class(TCustomItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // LogoTextItem
  TLogoTextItem = class(TCustomItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SysCloseItem
  TSysCloseItem = class(TCustomItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SysMaximizeItem
  TSysMaximizeItem = class(TCustomItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SysMinimizeItem
  TSysMinimizeItem = class(TCustomItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // ShortKeyItem
  TShortKeyItem = class(TCustomItem)
  private
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
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // CustomItemMgr
  TCustomItemMgr = class(TAutoObject)
  private
  protected
    // Parent
    FParent: TCustomNCUI;
    // AppContext
    FAppContext: IAppContext;
    // ComponentsRect
    FComponentsRect: TRect;
    // Components
    FComponents: TList<TComponentUI>;

    // ClearComponents
    procedure DoClearComponents; virtual;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; virtual;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); virtual;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomNCUI); virtual;
    // Destructor
    destructor Destroy; override;
    // Draw
    procedure Draw(ARenderDC: TRenderDC); virtual;
    // Calc
    procedure Calc(ARenderDC: TRenderDC; var ARect: TRect); virtual;
  end;

  // LogoItemMgr
  TLogoItemMgr = class(TCustomItemMgr)
  private
    // LogoIconItem
    FLogoIconItem: TLogoIconItem;
    // LogoTextItem
    FLogoTextItem: TLogoTextItem;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomNCUI); override;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc(ARenderDC: TRenderDC; var ARect: TRect); override;
  end;

  // SysMenuItemMgr
  TSysMenuItemMgr = class(TCustomItemMgr)
  private
    // SysCloseItem
    FSysCloseItem: TSysCloseItem;
    // SysMaximizeItem
    FSysMaximizeItem: TSysMaximizeItem;
    // SysMinimizeItem
    FSysMinimizeItem: TSysMinimizeItem;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomNCUI); override;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc(ARenderDC: TRenderDC; var ARect: TRect); override;
  end;

  // ShortKeyBar
  TShortKeyItemMgr = class(TCustomItemMgr)
  private
    // LeftShortKeyRect
    FLShortKeyRect: TRect;
    // RightShortKeyRect
    FRShortKeyRect: TRect;
    // ShortKeyDataMgr
    FShortKeyDataMgr: IShortKeyDataMgr;
    // LShortKeyItems
    FLShortKeyItems: TList<TShortKeyItem>;
    // RShortKeyItems
    FRShortKeyItems: TList<TShortKeyItem>;
  protected
    // AddTestData
    procedure DoAddTestData;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; override;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); override;
    // DrawLComponents
    procedure DoDrawLComponents(ARenderDC: TRenderDC);
    // DrawRComponents
    procedure DoDrawRComponents(ARenderDC: TRenderDC);
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomNCUI); override;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc(ARenderDC: TRenderDC; var ARect: TRect); override;
  end;

  // CaptionBarUI
  TCaptionBarUI = class(TCustomNCUI)
  private
    // LogoItemMgr
    FLogoItemMgr: TLogoItemMgr;
    // SysMenuItemMgr
    FSysMenuItemMgr: TSysMenuItemMgr;
    // ShortKeyItemMgr
    FShortKeyItemMgr: TShortKeyItemMgr;
  protected
    // GetCloseId
    function GetCloseId: Integer;
    // GetMaximizeId
    function GetMaximizeId: Integer;
    // GetMinimizeId
    function GetMinimizeId: Integer;
    // AddComponentDic
    procedure DoAddComponentDic;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; override;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); override;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); override;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomMasterUI); override;
    // Destructor
    destructor Destroy; override;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); override;
  end;

implementation

uses
  Command;

{ TCustomItem }

constructor TCustomItem.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
  FRectEx := Rect(0, 0, 0, 0);
end;

destructor TCustomItem.Destroy;
begin

  inherited;
end;

function TCustomItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TCustomItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

{ TLogoIconItem }

constructor TLogoIconItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TLogoIconItem.Destroy;
begin

  inherited;
end;

function TLogoIconItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TLogoIconItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect, LDesRect: TRect;
  LResourceStream: TResourceStream;
begin
  LDesRect := FRectEx;

  LResourceStream := TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetImgAppLogoS;
  if LResourceStream = nil then Exit;

  LDesRect.Inflate(-7, -7);
  LSrcRect := Rect(0, 0, 14, 14);
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, LDesRect, LSrcRect);
end;

{ TLogoTextItem }

constructor TLogoTextItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TLogoTextItem.Destroy;
begin

  inherited;
end;

function TLogoTextItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TLogoTextItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOBJ: HGDIOBJ;
  LCaption: string;
begin
  LCaption := TCaptionBarUI(FParent).Parent.Caption;
  if LCaption = '' then Exit;


  LOBJ := SelectObject(ARenderDC.MemDC, TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, LCaption,
      TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetColorRefMasterCaptionText, dtaLeft, False, True);
  finally
    SelectObject(ARenderDC.MemDC, LOBJ);
  end;
end;

{ TSysCloseItem }

constructor TSysCloseItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TSysCloseItem.Destroy;
begin

  inherited;
end;

function TSysCloseItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetImgAppClose;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TCaptionBarUI(FParent).Parent.MouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TCaptionBarUI(FParent).Parent.MouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TSysMaximizeItem }

constructor TSysMaximizeItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TSysMaximizeItem.Destroy;
begin

  inherited;
end;

function TSysMaximizeItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetImgAppMaximize;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TCaptionBarUI(FParent).Parent.MouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TCaptionBarUI(FParent).Parent.MouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TSysMinimizeItem }

constructor TSysMinimizeItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TSysMinimizeItem.Destroy;
begin

  inherited;
end;

function TSysMinimizeItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  LResourceStream := TCaptionBarUI(FParent).FAppContext.GetGdiMgr.GetImgAppMinimize;
  if LResourceStream = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TCaptionBarUI(FParent).Parent.MouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TCaptionBarUI(FParent).Parent.MouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LSrcRect);
end;

{ TShortKeyItem }

constructor TShortKeyItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TShortKeyItem.Destroy;
begin

  inherited;
end;

function TShortKeyItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TShortKeyItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TShortKeyItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FResourceStream = nil) then Exit;

  LRect := FRectEx;
  LRect.Left := LRect.Right - 30;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TCaptionBarUI(Self.FParent).Parent.MouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TCaptionBarUI(Self.FParent).Parent.MouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, FResourceStream, LRect, LSrcRect);
end;

{ TCustomItemMgr }

constructor TCustomItemMgr.Create(AContext: IAppContext; AParent: TCustomNCUI);
begin
  inherited Create;
  FParent := AParent;
  FAppContext := AContext;
  FComponents := TList<TComponentUI>.Create;
end;

destructor TCustomItemMgr.Destroy;
begin
  DoClearComponents;
  FComponents.Free;
  FAppContext := nil;
//  FParent := nil;
  inherited;
end;

procedure TCustomItemMgr.DoClearComponents;
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponent := FComponents.Items[LIndex];
    if LComponent <> nil then begin
      LComponent.Free;
    end;
  end;
  FComponents.Clear;
end;

procedure TCustomItemMgr.DoCalcComponentsRect;
begin

end;

procedure TCustomItemMgr.DoDrawBK(ARenderDC: TRenderDC);
begin

end;

procedure TCustomItemMgr.DoDrawComponents(ARenderDC: TRenderDC);
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FComponents.Count - 1 do begin
    LComponent := FComponents.Items[LIndex];
    if LComponent.Visible
      and LComponent.RectExIsValid then begin
      LComponent.Draw(ARenderDC);
    end;
  end;
end;

procedure TCustomItemMgr.Draw(ARenderDC: TRenderDC);
begin
  if FComponentsRect.Left < FComponentsRect.Right - 10 then begin
    DoDrawComponents(ARenderDC);
  end;
end;

procedure TCustomItemMgr.Calc(ARenderDC: TRenderDC; var ARect: TRect);
begin

end;

{ TLogoItemMgr }

constructor TLogoItemMgr.Create(AContext: IAppContext; AParent: TCustomNCUI);
begin
  inherited;
  FLogoIconItem := TLogoIconItem.Create(AParent);
  FLogoIconItem.Id := AParent.Parent.ComponentId.GenerateId;
  FComponents.Add(FLogoIconItem);
  FLogoTextItem := TLogoTextItem.Create(AParent);
  FLogoTextItem.Id := AParent.Parent.ComponentId.GenerateId;
  FComponents.Add(FLogoTextItem);
end;

destructor TLogoItemMgr.Destroy;
begin

  inherited;
end;

procedure TLogoItemMgr.Calc(ARenderDC: TRenderDC; var ARect: TRect);
var
  LSize: TSize;
  LRect: TRect;
  LCaption: string;
begin
  LRect := ARect;
  LRect.Right := LRect.Left + 30;
  FLogoIconItem.RectEx := LRect;

  LRect.Left := LRect.Right;
  LCaption := FParent.Parent.Caption;
  if GetTextSizeX(ARenderDC.MemDC, FAppContext.GetGdiMgr.GetFontObjHeight20, LCaption, LSize) then begin
    LRect.Right := LRect.Left + LSize.cx;
  end;
  FLogoTextItem.RectEx := LRect;

  ARect.Right := LRect.Right;
  FComponentsRect := ARect;
end;

{ TSysMenuItemMgr }

constructor TSysMenuItemMgr.Create(AContext: IAppContext; AParent: TCustomNCUI);
begin
  inherited;
  FSysCloseItem := TSysCloseItem.Create(AParent);
  FSysCloseItem.Id := AParent.Parent.ComponentId.GenerateId;
  FComponents.Add(FSysCloseItem);
  FSysMaximizeItem := TSysMaximizeItem.Create(AParent);
  FSysMaximizeItem.Id := AParent.Parent.ComponentId.GenerateId;
  FComponents.Add(FSysMaximizeItem);
  FSysMinimizeItem := TSysMinimizeItem.Create(AParent);
  FSysMinimizeItem.Id := AParent.Parent.ComponentId.GenerateId;
  FComponents.Add(FSysMinimizeItem);
end;

destructor TSysMenuItemMgr.Destroy;
begin

  inherited;
end;

procedure TSysMenuItemMgr.Calc(ARenderDC: TRenderDC; var ARect: TRect);
var
  LRect: TRect;
begin
  LRect := ARect;
  LRect.Left := LRect.Right - 30;
  FSysCloseItem.RectEx := LRect;

  if LRect.Left <= ARect.Left then begin
    LRect.Left := ARect.Left;
    LRect.Right := ARect.Left;
    FSysMaximizeItem.RectEx := LRect;
    FSysMinimizeItem.RectEx := LRect;
  end else begin
    LRect.Right := LRect.Left;
    LRect.Left := LRect.Right - 30;
    FSysMaximizeItem.RectEx := LRect;
    if LRect.Left <= ARect.Left then begin
      LRect.Left := ARect.Left;
      LRect.Right := ARect.Left;
      FSysMinimizeItem.RectEx := LRect;
    end else begin
      LRect.Right := LRect.Left;
      LRect.Left := LRect.Right - 30;
      FSysMinimizeItem.RectEx := LRect;
    end;
  end;
  if LRect.Left < ARect.Left then begin
    LRect.Left := ARect.Left;
  end;
  ARect.Left := LRect.Left;

  FComponentsRect := ARect;
end;

{ TShortKeyItemMgr }

constructor TShortKeyItemMgr.Create(AContext: IAppContext; AParent: TCustomNCUI);
begin
  inherited;
  FShortKeyDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SHORTKEYDATAMGR) as IShortKeyDataMgr;
  FLShortKeyItems := TList<TShortKeyItem>.Create;
  FRShortKeyItems := TList<TShortKeyItem>.Create;
  DoAddTestData;
end;

destructor TShortKeyItemMgr.Destroy;
begin
  FLShortKeyItems.Free;
  FRShortKeyItems.Free;
  FShortKeyDataMgr := nil;
  inherited;
end;

procedure TShortKeyItemMgr.DoAddTestData;
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
        LShortKeyItem := TShortKeyItem.Create(FParent);
        LShortKeyItem.Id := FParent.Parent.ComponentId.GenerateId;
        LShortKeyItem.FCommandId := LShortKeyData^.FCommandId;
        LShortKeyItem.FCommandParams := LShortKeyData^.FCommandParams;
        LShortKeyItem.FResourceStream := FShortKeyDataMgr.GetStream(LShortKeyData^.FResourceName);
        if LIndex < 2 then begin
          FLShortKeyItems.Add(LShortKeyItem);
        end else begin
          FRShortKeyItems.Add(LShortKeyItem);
        end;
        FComponents.Add(LShortKeyItem);
      end;
    end;
  finally
    FShortKeyDataMgr.UnLock;
  end;
end;

procedure TShortKeyItemMgr.DoCalcComponentsRect;
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
  LLeftFixRect := FComponentsRect;
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

  LRightFixRect := FComponentsRect;
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

procedure TShortKeyItemMgr.DoDrawComponents(ARenderDC: TRenderDC);
begin
  if FLShortKeyRect.Left < FLShortKeyRect.Right then begin
    DoDrawLComponents(ARenderDC);
  end;

  if FRShortKeyRect.Left < FRShortKeyRect.Right then begin
    DoDrawRComponents(ARenderDC);
  end;
end;

procedure TShortKeyItemMgr.DoDrawLComponents(ARenderDC: TRenderDC);
var
  LClipRgn: HRGN;
  LIndex: Integer;
  LShortKeyItem: TShortKeyItem;
begin
  LClipRgn := CreateRectRgnIndirect(FLShortKeyRect);
  if LClipRgn = 0 then Exit;
  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
  try
    for LIndex := 0 to FLShortKeyItems.Count - 1 do begin
      LShortKeyItem := FLShortKeyItems.Items[LIndex];
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

procedure TShortKeyItemMgr.DoDrawRComponents(ARenderDC: TRenderDC);
var
  LClipRgn: HRGN;
  LIndex: Integer;
  LShortKeyItem: TShortKeyItem;
begin
  LClipRgn := CreateRectRgnIndirect(FRShortKeyRect);
  if LClipRgn = 0 then Exit;
  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
  try
    for LIndex := 0 to FRShortKeyItems.Count - 1 do begin
      LShortKeyItem := FRShortKeyItems.Items[LIndex];
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

procedure TShortKeyItemMgr.Calc(ARenderDC: TRenderDC; var ARect: TRect);
begin
  FComponentsRect := ARect;
  if FComponentsRect.Left < FComponentsRect.Right - 10 then begin
    DoCalcComponentsRect;
  end;
end;


{ TCaptionBarUI }

constructor TCaptionBarUI.Create(AContext: IAppContext; AParent: TCustomMasterUI);
begin
  inherited;
  FWMPAINT := WM_NCPAINT_CAPTIONBAR;
  FLogoItemMgr := TLogoItemMgr.Create(AContext, Self);
  FSysMenuItemMgr := TSysMenuItemMgr.Create(AContext, Self);
  FShortKeyItemMgr := TShortKeyItemMgr.Create(AContext, Self);
  DoAddComponentDic;
end;

destructor TCaptionBarUI.Destroy;
begin
  FComponents.Clear;
  FShortKeyItemMgr.Free;
  FSysMenuItemMgr.Free;
  FLogoItemMgr.Free;
  inherited;
end;

function TCaptionBarUI.GetCloseId: Integer;
begin
  Result := FSysMenuItemMgr.FSysCloseItem.Id;
end;

function TCaptionBarUI.GetMaximizeId: Integer;
begin
  Result := FSysMenuItemMgr.FSysMaximizeItem.Id;
end;

function TCaptionBarUI.GetMinimizeId: Integer;
begin
  Result := FSysMenuItemMgr.FSysMinimizeItem.Id;
end;

procedure TCaptionBarUI.DoAddComponentDic;
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FSysMenuItemMgr.FComponents.Count - 1 do begin
    LComponent := FSysMenuItemMgr.FComponents.Items[LIndex];
    if LComponent <> nil then begin
      FComponents.Add(LComponent);
      FComponentDic.AddOrSetValue(LComponent.Id, LComponent);
    end;
  end;

  for LIndex := 0 to FShortKeyItemMgr.FComponents.Count - 1 do begin
    LComponent := FShortKeyItemMgr.FComponents.Items[LIndex];
    if LComponent <> nil then begin
      FComponents.Add(LComponent);
      FComponentDic.AddOrSetValue(LComponent.Id, LComponent);
    end;
  end;
end;

procedure TCaptionBarUI.DoCalcComponentsRect;
var
  LRect: TRect;
  LLeft, LRight: Integer;
begin
  LRect := FComponentsRect;
  FSysMenuItemMgr.Calc(FRenderDC, LRect);
  LRight := LRect.Left;
  LRect.Left := FComponentsRect.Left;
  LRect.Right := LRight;
  FLogoItemMgr.Calc(FRenderDC, LRect);
  LLeft := LRect.Right;
  LRect.Left := LLeft;
  LRect.Right := LRight;
  FShortKeyItemMgr.Calc(FRenderDC, LRect);
end;

procedure TCaptionBarUI.DoDrawBK(ARenderDC: TRenderDC);
begin
  FillSolidRect(ARenderDC.MemDC, @FComponentsRect, FAppContext.GetGdiMgr.GetColorRefMasterCaptionBack);
end;

procedure TCaptionBarUI.DoDrawComponents(ARenderDC: TRenderDC);
begin
  FSysMenuItemMgr.Draw(ARenderDC);
  FLogoItemMgr.Draw(ARenderDC);
  FShortKeyItemMgr.Draw(ARenderDC);
end;

procedure TCaptionBarUI.LButtonClickComponent(AComponent: TComponentUI);
begin
  if AComponent = nil then Exit;

  if AComponent is TShortKeyItem then begin
    FAppContext.GetCommandMgr.ExecuteCmd(TShortKeyItem(AComponent).FCommandId,
      TShortKeyItem(AComponent).FCommandParams);
  end;
end;

end.
