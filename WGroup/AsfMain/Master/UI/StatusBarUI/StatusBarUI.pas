unit StatusBarUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusBarUI
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  ExtCtrls,
  GDIPAPI,
  GDIPOBJ,
  FrameUI,
  RenderDC,
  RenderUtil,
  AppContext,
  CommonLock,
  CommonPool,
  ComponentUI,
  ExecutorThread,
  StatusHqDataMgr,
  CommonRefCounter,
  StatusNewsDataMgr,
  StatusAlarmDataMgr,
  StatusReportDataMgr,
  StatusServerDataMgr,
  Generics.Collections;

type

  //
  TStatusBarUI = class;

  // Array
  TPointerDynArray = Array of Pointer;

  // Pointer FIFO Queue
  TPointerFIFOQueue = class(TAutoObject)
  private
    // Count
    FCount: Integer;
    // Capacity
    FCapacity: Integer;
    // Elements
    FElements: TPointerDynArray;
  protected
    // MovePrevElements
    procedure MovePrevElements;
    // NewCapacity
    procedure NewCapacity(ACapacity: Integer);
  public
    // Constructor
    constructor Create(ACapacity: Integer); reintroduce;
    // Destructor
    destructor Destroy; override;
    // GetCount
    function GetCount: Integer;
    // GetElement
    function GetElement(AIndex: Integer): Pointer;
    // Pop Element
    function PopElement: Pointer;
    // Push Element
    function PushElement(AElement: Pointer): Boolean;
  end;

  // StatusItem
  TStatusItem = class(TComponentUI)
  private
    // Width
    FWidth: Integer;
    // Parent
    FStatusBarUI: TStatusBarUI;
  protected
    // Calc Rect
    procedure DoCalcRect; virtual;
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectEx Is Valid
    function RectExIsValid: Boolean; override;
    // Pt In RectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;

    property Width: Integer read FWidth write FWidth;
  end;

  //
  THqType = (hstLeft, hstRight);

  // HqInfo
  THqInfo = packed record
//    FIndex: Integer;
//    FTurnover: string;
//    FNowPriceHL: string;
//    FColorValue: Integer;
    FSecuAbbrRect: TRect;
    FTurnoverRect: TRect;
    FNowPriceHLRect: TRect;
    FStatusHqData: PStatusHqData;
  end;

  // HqInfo
  PHqInfo = ^THqInfo;

  // HqInfoPool
  THqInfoPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  public
  end;

  // StatusHqItem
  TStatusHqItem = class(TStatusItem)
  private
    // HqType
    FHqType: THqType;
    // OffsetY
    FOffSetY: Integer;
    // Scroll Interval
    FInterval: Integer;
    // Current Index
    FCurrIndex: Integer;
    // Item Count
    FItemCount: Integer;
    // HqInfoPool
    FHqInfoPool: THqInfoPool;
    // HqInfoQueue
    FHqInfoQueue: TPointerFIFOQueue;
    // StatusHqDataMgr
    FStatusHqDataMgr: IStatusHqDataMgr;
  protected
    // ClearQueue
    procedure DoClearQueue;
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Scroll
    function Scroll: Boolean;
    // RectEx Is Valid
    function RectExIsValid: Boolean; override;
    // Pt In RectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
    // SetHqType
    function SetHqType(AHqType: THqType): Boolean;
  end;

  // NewsInfo
  TNewsInfo = packed record
    FId: Int64;
    FRect: TRect;
    FWidth: Integer;
    FTitle: string;
    FDateStr: string;
  end;

  // NewsInfo
  PNewsInfo = ^TNewsInfo;

  // NewsInfoPool
  TNewsInfoPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  public
  end;

  // StatusNewsItem
  TStatusNewsItem = class(TStatusItem)
  private
    // CurrIndex
    FCurrIndex: Integer;
    // NewsInfo
    FNewsInfo: PNewsInfo;
    // NewsInfoPool
    FNewsInfoPool: TNewsInfoPool;
    // DrawNewsInfoQueue
    FDrawNewsInfoQueue: TPointerFIFOQueue;
    // StatusNewsDataMgr
    FStatusNewsDataMgr: IStatusNewsDataMgr;
  protected
    // ClearQueue
    procedure DoClearQueue;
    // GetNextStatusNewsData
    function GetNextStatusNewsData: PStatusNewsData;
    // PtInNewsInfo
    function DoPtInNewsInfo(APt: TPoint; var ANewsInfo: PNewsInfo): Boolean;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Scroll
    function Scroll: Boolean;
    // Pt In RectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // StatusTimeItem
  TStatusTimeItem = class(TStatusItem)
  private
    // CurrentTime
    FCurrentTime: string;
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Pt In RectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // StatusAlarmItem
  TStatusAlarmItem = class(TStatusItem)
  private
    // StatusAlarmDataMgr
    FStatusAlarmDataMgr: IStatusAlarmDataMgr;
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // StatusReportItem
  TStatusReportItem = class(TStatusItem)
  private
    // StatusReportDataMgr
    FStatusReportDataMgr: IStatusReportDataMgr;
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // StatusNetworkItem
  TStatusNetworkItem = class(TStatusItem)
  private
    // StatusServerDataMgr
    FStatusServerDataMgr: IStatusServerDataMgr;
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // StatusBarUI
  TStatusBarUI = class(TFrameUI)
  private
    // RefreshTimer
    FRefreshTimer: TTimer;
    // News Item Index
    FNewsItemIndex: Integer;
    // Left StatusHqItem
    FLStatusHqItem: TStatusHqItem;
    // Right StatusHqItem
    FRStatusHqItem: TStatusHqItem;
    // News Item Index
    FStatusNewsItem: TStatusNewsItem;
    // Status Items
    FStatusItems: TList<TStatusItem>;
  protected
    // Init Status Items
    procedure DoInitStatusItems;
    // Calc Status Items
    procedure DoCalcStatusItems;
    // Refresh Timer
    procedure DoRefreshTimer(Sender: TObject);
    // Clear Items
    procedure DoClear(AItems: TList<TStatusItem>);
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
  end;

implementation

uses
  Command;

{ TPointerFIFOQueue }

constructor TPointerFIFOQueue.Create(ACapacity: Integer);
begin
  inherited Create;
  FCount := 0;
  FCapacity := 0;
  if ACapacity > 0 then begin
    NewCapacity(ACapacity);
  end;
end;

destructor TPointerFIFOQueue.Destroy;
begin
  if FCapacity > 0 then begin
    SetLength(FElements, 0);
  end;
  inherited;
end;

procedure TPointerFIFOQueue.MovePrevElements;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FCount - 2 do begin
    FElements[LIndex] := FElements[LIndex + 1];
  end;
  FElements[FCount - 1] := nil;
end;

procedure TPointerFIFOQueue.NewCapacity(ACapacity: Integer);
begin
  if ACapacity <> FCapacity then begin
    SetLength(FElements, ACapacity);
    FCapacity := ACapacity;
  end;
end;

function TPointerFIFOQueue.GetCount: Integer;
begin
  Result := FCount;
end;

function TPointerFIFOQueue.GetElement(AIndex: Integer): Pointer;
begin
  if (AIndex >= 0)
    and (AIndex < FCount) then begin
    Result := FElements[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TPointerFIFOQueue.PopElement: Pointer;
begin
  if FCount > 0 then begin
    Result := FElements[0];
    MovePrevElements;
    Dec(FCount);
  end else begin
    Result := nil;
  end;
end;

function TPointerFIFOQueue.PushElement(AElement: Pointer): Boolean;
begin
  if AElement <> nil then begin
    Result := True;
    if FCount >= FCapacity then begin
      NewCapacity(FCapacity + 4);
    end;
    FElements[FCount] := AElement;
    Inc(FCount);
  end else begin
    Result := False;
  end;
end;

{ TStatusItem }

constructor TStatusItem.Create(AParent: TObject);
begin
  inherited Create;
  FStatusBarUI := TStatusBarUI(AParent);
end;

destructor TStatusItem.Destroy;
begin
  FStatusBarUI := nil;
  inherited;
end;

procedure TStatusItem.DoCalcRect;
begin

end;

function TStatusItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TStatusItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TStatusItem.Draw(ARenderDC: TRenderDC): Boolean;
begin
  Result := False;
end;

{ THqInfoPool }

function THqInfoPool.DoCreate: Pointer;
var
  LHqInfo: PHqInfo;
begin
  New(LHqInfo);
  Result := LHqInfo;
end;

procedure THqInfoPool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure THqInfoPool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure THqInfoPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TStatusHqItem }

constructor TStatusHqItem.Create(AParent: TObject);
begin
  inherited Create(AParent);
  if (FStatusBarUI.FAppContext <> nil) then begin
    FStatusHqDataMgr := FStatusBarUI.FAppContext.FindInterface(ASF_COMMAND_ID_STATUSHQDATAMGR) as IStatusHqDataMgr;
  end;
  FWidth := 280;
  FHqType := hstLeft;
  FItemCount := 3;
  FCurrIndex := 0;
  FHqInfoPool := THqInfoPool.Create(3);
  FHqInfoQueue := TPointerFIFOQueue.Create(4);
end;

destructor TStatusHqItem.Destroy;
begin
  DoClearQueue;
  FHqInfoQueue.Free;
  FHqInfoPool.Free;
  FStatusHqDataMgr := nil;
  inherited;
end;

procedure TStatusHqItem.DoClearQueue;
var
  LIndex: Integer;
  LHqInfo: PHqInfo;
begin
  for LIndex := 0 to FHqInfoQueue.GetCount - 1 do begin
    LHqInfo := FHqInfoQueue.GetElement(LIndex);
    if LHqInfo <> nil then begin
      Dispose(LHqInfo);
    end;
  end;
end;

procedure TStatusHqItem.DoCalcRect;
var
  LSize: TSize;
  LHqInfo: PHqInfo;
  LTurnover, LNowPriceHL: string;
  LIndex, LRight, LOffSetY, LSpace, LColorValue: Integer;
begin

end;

function TStatusHqItem.Scroll: Boolean;
const
  START_SCROLL = 40;
var
  LHqInfo: PHqInfo;
  LNextIndex: Integer;
  LStatusHqData: PStatusHqData;
begin
  Result := True;
  if (FStatusBarUI.FFrameRenderDC.MemDC = 0)
    or (FStatusHqDataMgr = nil)
    or (FStatusBarUI.FMouseMoveComponentId = FStatusBarUI.FLStatusHqItem.Id)
    or (FStatusBarUI.FMouseMoveComponentId = FStatusBarUI.FRStatusHqItem.Id) then Exit;

  Inc(FInterval);
  if FInterval > START_SCROLL then begin
    Inc(FOffsetY, 2);
    if FHqInfoQueue.GetCount = 1 then begin
      if FHqType = hstLeft then begin
        LNextIndex := (FCurrIndex + 1) mod FItemCount;
      end else begin
        LNextIndex := ((FCurrIndex + 1) mod FItemCount) + FItemCount;
      end;
      LStatusHqData := FStatusHqDataMgr.GetData(LNextIndex);
      if LStatusHqData <> nil then begin
        LHqInfo := PHqInfo(FHqInfoPool.Allocate);
        if LHqInfo <> nil then begin
          LHqInfo^.FStatusHqData := LStatusHqData;
          FHqInfoQueue.PushElement(LHqInfo);
        end;
      end;
    end;
  end;

  if FOffsetY > FRectEx.Height then begin

    FOffsetY := 0;
    FInterval := 0;

    if FHqType = hstLeft then begin
      FCurrIndex := (FCurrIndex + 1) mod FItemCount;
    end else begin
      FCurrIndex := ((FCurrIndex + 1) mod FItemCount) + FItemCount;
    end;
    if FHqInfoQueue.GetCount >= 2 then begin
      LHqInfo := FHqInfoQueue.PopElement;
      if LHqInfo <> nil then begin
        FHqInfoPool.DeAllocate(LHqInfo);
      end;
    end;
  end;
end;

function TStatusHqItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TStatusHqItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TStatusHqItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LSize: TSize;
  LOBJ: HGDIOBJ;
  LHqInfo: PHqInfo;
  LColorRef: COLORREF;
  LTurnover, LNowPriceHL: string;
  LIndex, LRight, LOffSetY, LSpace, LColorValue: Integer;
begin
  Result := True;

  LOBJ := SelectObject(ARenderDC.MemDC, FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18);
  try
    for LIndex := 0 to FHqInfoQueue.GetCount - 1 do begin
      LHqInfo := FHqInfoQueue.GetElement(LIndex);
      if LHqInfo <> nil then begin
        LOffSetY := LIndex * FRectEx.Height - FOffSetY;
        LTurnover := LHqInfo^.FStatusHqData^.GetTurnover;
        LNowPriceHL := LHqInfo^.FStatusHqData^.GetNowPriceHL;
        LColorValue := LHqInfo^.FStatusHqData^.GetColorValue;

        LSpace := 10;
        LRight := FRectEx.Left;

        GetTextSizeX(FStatusBarUI.FFrameRenderDC.MemDC,
          FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18,
          LHqInfo^.FStatusHqData^.FSecuAbbr, LSize);
        LHqInfo^.FSecuAbbrRect := FRectEx;
        LHqInfo^.FSecuAbbrRect.Left := LRight + LSpace;
        LHqInfo^.FSecuAbbrRect.Right := LHqInfo^.FSecuAbbrRect.Left + LSize.cx;
        if LHqInfo^.FSecuAbbrRect.Left > FRectEx.Right then begin
          LHqInfo^.FSecuAbbrRect.Left := FRectEx.Right;
        end;
        if LHqInfo^.FSecuAbbrRect.Right > FRectEx.Right then begin
          LHqInfo^.FSecuAbbrRect.Right := FRectEx.Right;
        end;
        LRight := LHqInfo^.FSecuAbbrRect.Right;
        OffsetRect(LHqInfo^.FSecuAbbrRect, 0, LOffSetY);
        if LHqInfo^.FSecuAbbrRect.Left < LHqInfo^.FSecuAbbrRect.Right then begin
          DrawTextX(ARenderDC.MemDC, LHqInfo^.FSecuAbbrRect, LHqInfo^.FStatusHqData^.FSecuAbbr,
            FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefMasterStatusBarText,
            dtaLeft, False, False);
        end;

        GetTextSizeX(FStatusBarUI.FFrameRenderDC.MemDC,
          FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18,
          LNowPriceHL, LSize);
        LHqInfo^.FNowPriceHLRect := FRectEx;
        LHqInfo^.FNowPriceHLRect.Left := LRight + LSpace;
        LHqInfo^.FNowPriceHLRect.Right := LHqInfo^.FNowPriceHLRect.Left + LSize.cx;
        if LHqInfo^.FNowPriceHLRect.Left > FRectEx.Right then begin
          LHqInfo^.FNowPriceHLRect.Left := FRectEx.Right;
        end;
        if LHqInfo^.FNowPriceHLRect.Right > FRectEx.Right then begin
          LHqInfo^.FNowPriceHLRect.Right := FRectEx.Right;
        end;
        LRight := LHqInfo^.FNowPriceHLRect.Right;
        OffsetRect(LHqInfo^.FNowPriceHLRect, 0, LOffSetY);
        if LHqInfo^.FNowPriceHLRect.Left < LHqInfo^.FNowPriceHLRect.Right then begin
          if LColorValue > 0 then begin
            LColorRef := FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefHqRed;
          end else if LColorValue < 0 then begin
            LColorRef := FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefHqGreen;
          end else begin
            LColorRef := FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefMasterStatusBarText;
          end;
          DrawTextX(ARenderDC.MemDC, LHqInfo^.FNowPriceHLRect, LNowPriceHL,
            LColorRef,
            dtaLeft, False, False);
        end;

        GetTextSizeX(FStatusBarUI.FFrameRenderDC.MemDC,
          FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18,
          LTurnover, LSize);
        LHqInfo^.FTurnoverRect := FRectEx;
        LHqInfo^.FTurnoverRect.Left := LRight + LSpace;
        LHqInfo^.FTurnoverRect.Right := LHqInfo^.FTurnoverRect.Left + LSize.cx;
        if LHqInfo^.FTurnoverRect.Left > FRectEx.Right then begin
          LHqInfo^.FTurnoverRect.Left := FRectEx.Right;
        end;
        if LHqInfo^.FTurnoverRect.Right > FRectEx.Right then begin
          LHqInfo^.FTurnoverRect.Right := FRectEx.Right;
        end;
        OffsetRect(LHqInfo^.FTurnoverRect, 0, LOffSetY);

        if LHqInfo^.FTurnoverRect.Left < LHqInfo^.FTurnoverRect.Right then begin
          DrawTextX(ARenderDC.MemDC, LHqInfo^.FTurnoverRect, LTurnover,
            FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefHqTurnover,
            dtaLeft, False, False);
        end;
      end;
    end;
  finally
    SelectObject(ARenderDC.MemDC, LOBJ);
  end;
end;

function TStatusHqItem.SetHqType(AHqType: THqType): Boolean;
var
  LHqInfo: PHqInfo;
  LStatusHqData: PStatusHqData;
begin
  Result := True;
  FHqType := AHqType;
  case FHqType of
    hstLeft:
      begin
        FCurrIndex := 0;
      end;
  else
    begin
      FCurrIndex := 3;
    end;
  end;
  LStatusHqData := FStatusHqDataMgr.GetData(FCurrIndex);
  if LStatusHqData <> nil then begin
    LHqInfo := PHqInfo(FHqInfoPool.Allocate);
    if LHqInfo <> nil then begin
      LHqInfo^.FStatusHqData := LStatusHqData;
      FHqInfoQueue.PushElement(LHqInfo);
    end;
  end;
end;

{ TNewsInfoPool }

function TNewsInfoPool.DoCreate: Pointer;
var
  LNewsInfo: PNewsInfo;
begin
  New(LNewsInfo);
  Result := LNewsInfo;
end;

procedure TNewsInfoPool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure TNewsInfoPool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure TNewsInfoPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TStatusNewsItem }

constructor TStatusNewsItem.Create(AParent: TObject);
begin
  inherited;
  FStatusNewsDataMgr := FStatusBarUI.FAppContext.FindInterface(ASF_COMMAND_ID_STATUSNEWSDATAMGR) as IStatusNewsDataMgr;
  FCurrIndex := 0;
  FNewsInfoPool := TNewsInfoPool.Create(20);
  FDrawNewsInfoQueue := TPointerFIFOQueue.Create(4);
end;

destructor TStatusNewsItem.Destroy;
begin
  DoClearQueue;
  FDrawNewsInfoQueue.Free;
  FNewsInfoPool.Free;
  FStatusNewsDataMgr := nil;
  inherited;
end;

procedure TStatusNewsItem.DoClearQueue;
var
  LIndex: Integer;
  LNewInfo: PNewsInfo;
begin
  for LIndex := 0 to FDrawNewsInfoQueue.GetCount - 1 do begin
    LNewInfo := FDrawNewsInfoQueue.GetElement(LIndex);
    if LNewInfo <> nil then begin
      Dispose(LNewInfo);
    end;
  end;
end;

function TStatusNewsItem.GetNextStatusNewsData: PStatusNewsData;
begin
  Result := nil;
  if FStatusNewsDataMgr = nil then Exit;

  FStatusNewsDataMgr.Lock;
  try
    Result := FStatusNewsDataMgr.GetData(FCurrIndex);
    if FStatusNewsDataMgr.GetDataCount > 0 then begin
      FCurrIndex := (FCurrIndex + 1) mod FStatusNewsDataMgr.GetDataCount;
    end;
  finally
    FStatusNewsDataMgr.UnLock;
  end;
end;

function TStatusNewsItem.Scroll: Boolean;
var
  LSize: TSize;
  LTitle: string;
  LNewsInfo: PNewsInfo;
  LIndex, LRight, LCount: Integer;
  LStatusNewsData: PStatusNewsData;
begin
  Result := True;
  if (FStatusNewsDataMgr = nil)
    or (FRectEx.Left >= FRectEx.Right)
    or (FStatusBarUI.FFrameRenderDC.MemDC = 0)
    or (FStatusBarUI.FMouseMoveComponentId = FId) then Exit;

  LRight := FRectEx.Right;
  if FDrawNewsInfoQueue.GetCount > 0 then begin

    for LIndex := 0 to FDrawNewsInfoQueue.GetCount - 1 do begin
      LNewsInfo := FDrawNewsInfoQueue.GetElement(LIndex);
      if LNewsInfo <> nil then begin
        OffsetRect(LNewsInfo^.FRect, -3, 0);
      end;
    end;

    LNewsInfo := FDrawNewsInfoQueue.GetElement(0);
    if LNewsInfo <> nil then begin
      if LNewsInfo^.FRect.Right < FRectEx.Left then begin
        LNewsInfo := FDrawNewsInfoQueue.PopElement;
        FNewsInfoPool.DeAllocate(LNewsInfo);
      end;
    end;

    LNewsInfo := FDrawNewsInfoQueue.GetElement(FDrawNewsInfoQueue.GetCount - 1);
    if LNewsInfo <> nil then begin
      LRight := LNewsInfo^.FRect.Right + 100;
    end;
  end;

  LCount := 0;

  while LRight <= FRectEx.Right do begin

    if LCount >= 3 then Exit;

    LStatusNewsData := GetNextStatusNewsData;
    if LStatusNewsData <> nil then begin
      if LStatusNewsData^.FWidth = 0 then begin
        LTitle := LStatusNewsData^.FDateStr + '  ' + LStatusNewsData^.FTitle;
        GetTextSizeX(FStatusBarUI.FFrameRenderDC.MemDC,
          FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18,
          LTitle,
          LSize);
        LStatusNewsData^.FWidth := LSize.cx;
      end;

      if LStatusNewsData^.FWidth = 0 then Exit;

      LNewsInfo := PNewsInfo(FNewsInfoPool.Allocate);
      if LNewsInfo <> nil then begin
        LNewsInfo^.FId := LStatusNewsData^.FId;
        LNewsInfo^.FTitle := LStatusNewsData^.FTitle;
        LNewsInfo^.FDateStr := LStatusNewsData^.FDateStr;
        LNewsInfo^.FWidth := LStatusNewsData^.FWidth;
        LNewsInfo^.FRect := FRectEx;
        LNewsInfo^.FRect.Left := LRight;
        LNewsInfo^.FRect.Right := LRight + LNewsInfo^.FWidth;
        FDrawNewsInfoQueue.PushElement(LNewsInfo);
        LRight := LNewsInfo^.FRect.Right + 100;
      end;
    end;
    Inc(LCount);
  end;
end;

function TStatusNewsItem.PtInRectEx(APt: TPoint): Boolean;
begin
  if PtInRect(FRectEx, APt) then begin
    Result := DoPtInNewsInfo(APt, FNewsInfo);
  end else begin
    Result := False;
  end;
end;

function TStatusNewsItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOBJ: HGDIOBJ;
  LClipRgn: HRGN;
  LTitle: string;
  LIndex: Integer;
  LNewsInfo: PNewsInfo;
begin
  Result := True;
  if FDrawNewsInfoQueue.GetCount = 0 then Exit;

  LClipRgn := CreateRectRgnIndirect(FRectEx);
  if LClipRgn = 0 then Exit;
  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
  try
    LOBJ := SelectObject(FStatusBarUI.FrameRenderDC.MemDC,
      FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18);
    try
      for LIndex := 0 to FDrawNewsInfoQueue.GetCount - 1 do begin
        LNewsInfo := FDrawNewsInfoQueue.GetElement(LIndex);
        if LNewsInfo <> nil then begin
          LTitle := LNewsInfo^.FDateStr + '  ' + LNewsInfo^.FTitle;
          DrawTextX(ARenderDC.MemDC, LNewsInfo^.FRect, LTitle,
                FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefMasterStatusBarText,
                dtaLeft, False, False);
        end;
      end;
    finally
      SelectObject(FStatusBarUI.FrameRenderDC.MemDC, LOBJ);
    end;
  finally
    SelectClipRgn(ARenderDC.MemDC, 0);
    DeleteObject(LClipRgn);
  end;
end;

function TStatusNewsItem.DoPtInNewsInfo(APt: TPoint; var ANewsInfo: PNewsInfo): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  ANewsInfo := nil;
  for LIndex := FDrawNewsInfoQueue.GetCount - 1 downto 0 do begin
    ANewsInfo := FDrawNewsInfoQueue.GetElement(LIndex);
    if (ANewsInfo <> nil)
      and PtInRect(ANewsInfo.FRect, APt) then begin
      Result := True;
    end;
  end;
end;

{ TStatusTimeItem }

constructor TStatusTimeItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 130;
end;

destructor TStatusTimeItem.Destroy;
begin

  inherited;
end;

function TStatusTimeItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TStatusTimeItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOBJ: HGDIOBJ;
begin
  Result := True;
  FCurrentTime := Format('CN %s', [FormatDateTime('MM-DD hh:nn:ss', Now)]);
  LOBJ := SelectObject(ARenderDC.MemDC, FStatusBarUI.FAppContext.GetGdiMgr.GetFontObjHeight18);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, FCurrentTime,
      FStatusBarUI.FAppContext.GetGdiMgr.GetColorRefMasterStatusBarText,
      dtaLeft, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOBJ);
  end;
end;

{ TStatusAlarmItem }

constructor TStatusAlarmItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
  FStatusAlarmDataMgr := FStatusBarUI.FAppContext.FindInterface(ASF_COMMAND_ID_STATUSALARMDATAMGR) as IStatusAlarmDataMgr;
end;

destructor TStatusAlarmItem.Destroy;
begin
  FStatusAlarmDataMgr := nil;
  inherited;
end;

procedure TStatusAlarmItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

function TStatusAlarmItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FStatusAlarmDataMgr = nil)
    or (FStatusAlarmDataMgr.GetResourceStream = nil) then Exit;

  LRect := FRectEx;
  LGPImage := CreateGPImage(FStatusAlarmDataMgr.GetResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
  if FId = FStatusBarUI.MouseMoveComponentId then begin
    OffsetRect(LSrcRect, 20, 0);
    if FId = FStatusBarUI.MouseDownComponentId then begin
      OffsetRect(LSrcRect, 20, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TStatusReportItem }

constructor TStatusReportItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
  FStatusReportDataMgr := FStatusBarUI.FAppContext.FindInterface(ASF_COMMAND_ID_STATUSREPORTDATAMGR) as IStatusReportDataMgr;
end;

destructor TStatusReportItem.Destroy;
begin
  FStatusReportDataMgr := nil;
  inherited;
end;

procedure TStatusReportItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

function TStatusReportItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  Result := True;
  if (FStatusReportDataMgr = nil) 
    or (FStatusReportDataMgr.GetResourceStream = nil) then Exit;

  LRect := FRectEx;
  LGPImage := CreateGPImage(FStatusReportDataMgr.GetResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
  if FId = FStatusBarUI.MouseMoveComponentId then begin
    OffsetRect(LSrcRect, 20, 0);
    if FId = FStatusBarUI.MouseDownComponentId then begin
      OffsetRect(LSrcRect, 20, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TStatusNetworkItem }

constructor TStatusNetworkItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
  FStatusServerDataMgr := FStatusBarUI.FAppContext.FindInterface(ASF_COMMAND_ID_STATUSSERVERDATAMGR) as IStatusServerDataMgr;
end;

destructor TStatusNetworkItem.Destroy;
begin
  FStatusServerDataMgr := nil;
  inherited;
end;

procedure TStatusNetworkItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

function TStatusNetworkItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  if FStatusServerDataMgr = nil then Exit;

  LResourceStream := FStatusServerDataMgr.GetResourceStream(FStatusServerDataMgr.GetIsConnected);

  if LResourceStream = nil then Exit;

  LRect := FRectEx;
  LGPImage := CreateGPImage(LResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
  if FId = FStatusBarUI.MouseMoveComponentId then begin
    OffsetRect(LSrcRect, 20, 0);
    if FId = FStatusBarUI.MouseDownComponentId then begin
      OffsetRect(LSrcRect, 20, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TStatusBarUI }

constructor TStatusBarUI.Create(AContext: IAppContext);
begin
  inherited;
  FStatusItems := TList<TStatusItem>.Create;
  DoInitStatusItems;
  FRefreshTimer := TTimer.Create(nil);
  FRefreshTimer.Interval := 200;
  FRefreshTimer.Enabled := True;
  FRefreshTimer.OnTimer := DoRefreshTimer;
end;

destructor TStatusBarUI.Destroy;
begin
  FRefreshTimer.Enabled := False;
  FRefreshTimer.OnTimer := nil;
  FRefreshTimer.Free;
  DoClear(FStatusItems);
  FStatusItems.Free;
  inherited;
end;

procedure TStatusBarUI.DoInitStatusItems;
var
  LStatusItem: TStatusItem;
begin
  LStatusItem := TStatusHqItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  TStatusHqItem(LStatusItem).SetHqType(hstLeft);
  FStatusItems.Add(LStatusItem);
  FComponentDic.Add(LStatusItem.Id, LStatusItem);
  FLStatusHqItem := TStatusHqItem(LStatusItem);

  LStatusItem := TStatusHqItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  TStatusHqItem(LStatusItem).SetHqType(hstRight);
  FStatusItems.Add(LStatusItem);
  FComponentDic.Add(LStatusItem.Id, LStatusItem);
  FRStatusHqItem := TStatusHqItem(LStatusItem);

  LStatusItem := TStatusNewsItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  FNewsItemIndex := FStatusItems.Add(LStatusItem);
  FStatusNewsItem := TStatusNewsItem(LStatusItem);

  LStatusItem := TStatusTimeItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  FStatusItems.Add(LStatusItem);

  LStatusItem := TStatusAlarmItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  FStatusItems.Add(LStatusItem);
  FComponentDic.Add(LStatusItem.Id, LStatusItem);

  LStatusItem := TStatusReportItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  FStatusItems.Add(LStatusItem);
  FComponentDic.Add(LStatusItem.Id, LStatusItem);

  LStatusItem := TStatusNetworkItem.Create(Self);
  LStatusItem.Id := DoGetIncrId;
  FStatusItems.Add(LStatusItem);
  FComponentDic.Add(LStatusItem.Id, LStatusItem);
end;

procedure TStatusBarUI.DoCalcStatusItems;
var
  LIndex: Integer;
  LStatusItem: TStatusItem;
  LLeftFixRect, LRightFixRect, LRectEx: TRect;

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
begin
  LRightFixRect := FFrameRectEx;
  LRightFixRect.Top := LRightFixRect.Top + 1;

  LRectEx.Left := LRightFixRect.Right - 5;
  for LIndex := FStatusItems.Count - 1 downto FNewsItemIndex + 1 do begin
    LStatusItem := FStatusItems.Items[LIndex];
    if LStatusItem.Visible then begin
      CalcRectR(LRectEx.Left, LStatusItem.Width, LRectEx);
      LStatusItem.RectEx := LRectEx;
      LStatusItem.DoCalcRect;
    end;
  end;
  LLeftFixRect := LRightFixRect;
  LRightFixRect.Left := LRectEx.Left;
  LLeftFixRect.Right := LRectEx.Left;

  LRectEx.Right := LLeftFixRect.Left;
  for LIndex := 0 to FNewsItemIndex - 1 do begin
    LStatusItem := FStatusItems.Items[LIndex];
    if LStatusItem.Visible then begin
      CalcRectL(LRectEx.Right, LStatusItem.Width, LRectEx);
      LStatusItem.RectEx := LRectEx;
      LStatusItem.DoCalcRect;
    end;
  end;
  LLeftFixRect.Left := LRectEx.Right;
  LLeftFixRect.Right := LRightFixRect.Left - 10;
  if LLeftFixRect.Right < LLeftFixRect.Left then begin
    LLeftFixRect.Right := LLeftFixRect.Left;
  end;
  FStatusNewsItem.RectEx := LLeftFixRect;
end;

procedure TStatusBarUI.DoRefreshTimer(Sender: TObject);
begin
  if FLStatusHqItem <> nil then begin
    FLStatusHqItem.Scroll;
  end;

  if FRStatusHqItem <> nil then begin
    FRStatusHqItem.Scroll;
  end;

  if FStatusNewsItem <> nil then begin
    FStatusNewsItem.Scroll;
  end;

  DoInvalidatePaint;
end;

procedure TStatusBarUI.DoClear(AItems: TList<TStatusItem>);
var
  LIndex: Integer;
  LStatusItem: TStatusItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LStatusItem := AItems.Items[LIndex];
    if LStatusItem <> nil then begin
      LStatusItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TStatusBarUI.DoSize(AWidth: Integer; AHeight: Integer);
begin
  inherited;
  DoCalcStatusItems;
end;

procedure TStatusBarUI.DoUpdateSkinStyle;
begin

end;

procedure TStatusBarUI.DoDrawBK(ARect: TRect);
begin
  FillSolidRect(FFrameRenderDC.MemDC, @ARect, FAppContext.GetGdiMgr.GetColorRefMasterStatusBarBack);
end;

procedure TStatusBarUI.DoDrawComponents(ARect: TRect);
var
  LIndex: Integer;
  LStatusItem: TStatusItem;
begin
  for LIndex := 0 to FStatusItems.Count - 1 do begin
    LStatusItem := FStatusItems.Items[LIndex];
    if LStatusItem.Visible
      and LStatusItem.RectExIsValid then begin
      LStatusItem.Draw(FFrameRenderDC);
    end;
  end;
end;

procedure TStatusBarUI.DoLButtonClickComponent(AComponent: TComponentUI);
begin

end;

function TStatusBarUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
  LStatusItem: TStatusItem;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FStatusItems.Count - 1 do begin
    LStatusItem := FStatusItems.Items[LIndex];
    if LStatusItem.Visible
      and LStatusItem.RectExIsValid
      and LStatusItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LStatusItem;
      Exit;
    end;
  end;
end;

end.
