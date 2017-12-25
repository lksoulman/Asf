unit MasterNCCaptionBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterNCMasterNCCaptionBarUI
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
  Command,
  RenderDC,
  RenderUtil,
  AppContext,
  ComponentUI,
  CustomBaseUI,
  CustomMasterUI,
  ShortKeyDataMgr,
  CommonRefCounter,
  Generics.Collections;

type

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
    constructor Create(AContext: IAppContext; AParentUI: TNCCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // MasterNCCaptionBarUI
  TMasterNCCaptionBarUI = class(TNCCaptionBarUI)
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
    // CalcShortKeysRect
    procedure DoCalcShortKeysRect(ARect: TRect);
//    // DrawLComponents
//    procedure DoDrawLComponents(ARenderDC: TRenderDC);
//    // DrawRComponents
//    procedure DoDrawRComponents(ARenderDC: TRenderDC);
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomBaseUI); override;
    // Destructor
    destructor Destroy; override;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); override;
  end;

implementation

{ TShortKeyItem }

constructor TShortKeyItem.Create(AContext: IAppContext; AParentUI: TNCCustomBaseUI);
begin
  inherited;

end;

destructor TShortKeyItem.Destroy;
begin
  FCommandParams := '';
  inherited;
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
  if FId = FParentUI.ParentUI.NCMouseMoveId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = FParentUI.ParentUI.NCMouseDownId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, FResourceStream, LRect, LSrcRect);
end;

{ TMasterNCCaptionBarUI }

constructor TMasterNCCaptionBarUI.Create(AContext: IAppContext; AParent: TCustomBaseUI);
begin
  inherited;
  FShortKeyDataMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SHORTKEYDATAMGR) as IShortKeyDataMgr;
  FLShortKeyItems := TList<TShortKeyItem>.Create;
  FRShortKeyItems := TList<TShortKeyItem>.Create;
  DoAddTestData;
end;

destructor TMasterNCCaptionBarUI.Destroy;
begin
  FLShortKeyItems.Free;
  FRShortKeyItems.Free;
  FShortKeyDataMgr := nil;
  inherited;
end;

procedure TMasterNCCaptionBarUI.DoAddTestData;
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
        LShortKeyItem := TShortKeyItem.Create(FAppContext, Self);
        DoAddComponent(LShortKeyItem);
        LShortKeyItem.FCommandId := LShortKeyData^.FCommandId;
        LShortKeyItem.FCommandParams := LShortKeyData^.FCommandParams;
        LShortKeyItem.FResourceStream := FShortKeyDataMgr.GetStream(LShortKeyData^.FResourceName);
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

procedure TMasterNCCaptionBarUI.DoCalcComponentsRect;
var
  LSize: TSize;
  LCaption: string;
  LLeft, LRight: Integer;
  LRect, LTempRect: TRect;
begin
  LRect := FComponentsRect;
  LTempRect := LRect;

  // CalcIcon
  LTempRect.Right := LTempRect.Left + 30;
  FCaptionBarIcon.RectEx := LTempRect;

  // CalcCaption
  LTempRect.Left := LTempRect.Right;
  LCaption := Caption;
  if GetTextSizeX(FRenderDC.MemDC, FAppContext.GetGdiMgr.GetFontObjHeight20, LCaption, LSize) then begin
    LTempRect.Right := LTempRect.Left + LSize.cx;
  end;
  if LTempRect.Right > LRect.Right then begin
    LTempRect.Right := LRect.Right;
  end;
  FCaptionBarText.RectEx := LTempRect;

  // Left
  LLeft := LTempRect.Right;

  LTempRect := LRect;
  LTempRect.Left := LTempRect.Right - 30;
  FCaptionBarClose.RectEx := LTempRect;

  if FCaptionBarMaximize <> nil then begin
    if LTempRect.Left <= LRect.Left then begin
      LTempRect.Left := LRect.Left;
      LTempRect.Right := LRect.Left;
      FCaptionBarMaximize.RectEx := LTempRect;
      if FCaptionBarMinimize <> nil then begin
        FCaptionBarMinimize.RectEx := LTempRect;
      end;
    end else begin
      LTempRect.Right := LTempRect.Left;
      LTempRect.Left := LTempRect.Right - 30;
      FCaptionBarMaximize.RectEx := LTempRect;
      if FCaptionBarMinimize <> nil then begin
        if LTempRect.Left <= LRect.Left then begin
          LTempRect.Left := LRect.Left;
          LTempRect.Right := LRect.Left;
          FCaptionBarMinimize.RectEx := LTempRect;
        end else begin
          LTempRect.Right := LTempRect.Left;
          LTempRect.Left := LTempRect.Right - 30;
          FCaptionBarMinimize.RectEx := LTempRect;
        end;
      end;
    end;
  end else begin
    if FCaptionBarMinimize <> nil then begin
      if LTempRect.Left <= LRect.Left then begin
        LTempRect.Left := LRect.Left;
        LTempRect.Right := LRect.Left;
        FCaptionBarMinimize.RectEx := LTempRect;
      end else begin
        LTempRect.Right := LTempRect.Left;
        LTempRect.Left := LTempRect.Right - 30;
        FCaptionBarMinimize.RectEx := LTempRect;
      end;
    end;
  end;

  // Right
  LRight := LTempRect.Left;
  if LLeft < LRight then begin
    LTempRect.Left := LLeft;
    LTempRect.Right := LRight;
    DoCalcShortKeysRect(LTempRect);
  end;
end;

procedure TMasterNCCaptionBarUI.DoDrawComponents(ARenderDC: TRenderDC);
begin
  inherited;

//  if FLShortKeyRect.Left < FLShortKeyRect.Right then begin
//    DoDrawLComponents(ARenderDC);
//  end;
//
//  if FRShortKeyRect.Left < FRShortKeyRect.Right then begin
//    DoDrawRComponents(ARenderDC);
//  end;
end;

procedure TMasterNCCaptionBarUI.DoCalcShortKeysRect(ARect: TRect);
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

//procedure TMasterNCCaptionBarUI.DoDrawLComponents(ARenderDC: TRenderDC);
//var
//  LClipRgn: HRGN;
//  LIndex: Integer;
//  LShortKeyItem: TShortKeyItem;
//begin
//  LClipRgn := CreateRectRgnIndirect(FLShortKeyRect);
//  if LClipRgn = 0 then Exit;
//  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
//  try
//    for LIndex := 0 to FLShortKeyItems.Count - 1 do begin
//      LShortKeyItem := FLShortKeyItems.Items[LIndex];
//      if LShortKeyItem.Visible
//        and LShortKeyItem.RectExIsValid then begin
//        LShortKeyItem.Draw(ARenderDC);
//      end;
//    end;
//  finally
//    SelectClipRgn(ARenderDC.MemDC, 0);
//    DeleteObject(LClipRgn);
//  end;
//end;
//
//procedure TMasterNCCaptionBarUI.DoDrawRComponents(ARenderDC: TRenderDC);
//var
//  LClipRgn: HRGN;
//  LIndex: Integer;
//  LShortKeyItem: TShortKeyItem;
//begin
//  LClipRgn := CreateRectRgnIndirect(FRShortKeyRect);
//  if LClipRgn = 0 then Exit;
//  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
//  try
//    for LIndex := 0 to FRShortKeyItems.Count - 1 do begin
//      LShortKeyItem := FRShortKeyItems.Items[LIndex];
//      if LShortKeyItem.Visible
//        and LShortKeyItem.RectExIsValid then begin
//        LShortKeyItem.Draw(ARenderDC);
//      end;
//    end;
//  finally
//    SelectClipRgn(ARenderDC.MemDC, 0);
//    DeleteObject(LClipRgn);
//  end;
//end;

procedure TMasterNCCaptionBarUI.LButtonClickComponent(AComponent: TComponentUI);
begin
  if AComponent = nil then Exit;

  if AComponent is TShortKeyItem then begin
    FAppContext.GetCommandMgr.ExecuteCmd(TShortKeyItem(AComponent).FCommandId,
      TShortKeyItem(AComponent).FCommandParams);
  end;
end;

end.
