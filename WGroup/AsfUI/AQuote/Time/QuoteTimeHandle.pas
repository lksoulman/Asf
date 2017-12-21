unit QuoteTimeHandle;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Graphics,
  Controls,
  QuoteCommLibrary,
  QuoteTimeMenuIntf,
  QuoteTimeStruct,
  QuoteTimeGraph,
  QuoteTimeHint,
  QuoteTimeCross,
  QuoteTimeTradeDetail,
  QuoteTimeMovePt,
  QuoteTimeData;

type

  // Èë¿Ú²Ù×÷
  TEnterOperate = (eoMouseMove, eoMouseDown);

  TInterfaceObj = class(TObject, IInterface)
  protected
    FRefCount: integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
  end;

  TQuoteTimeHandle = class(TInterfaceObj)
  protected
    FEnterOperate: TEnterOperate;
    // FQuoteTimeOperates: TQuoteTimeOperates;
  public
    constructor Create;
    procedure Initialize; virtual;
    procedure DrawOperate; virtual;
    property EnterOperate: TEnterOperate read FEnterOperate;
    function MouseMove(Shift: TShiftState; const P: TPoint): boolean; virtual;
    function MouseDown(Button: TMouseButton; Shift: TShiftState;
      const P: TPoint): boolean; virtual;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; const P: TPoint)
      : boolean; virtual;
    function KeyDown(var Key: Word; Shift: TShiftState): boolean; virtual;
    function KeyUp(var Key: Word; Shift: TShiftState): boolean; virtual;
    function CMMouseLeave: boolean; virtual;
    function WMCancelMode: boolean; virtual;
    function CancelHandle: boolean; virtual;
    function CMEnter: boolean; virtual;
    function CMExit: boolean; virtual;

    function WMContextMenu(const SP, CP: TPoint): boolean; virtual;
  end;

  TQuoteTimeOperates = class
  private
    FHandles: TList;
    FActiveHandle: TQuoteTimeHandle;
    FTimeGraphs: TQuoteTimeGraphs;
    FTimeMenu: IQuoteTimeMenu;
    FMovePt: TPoint;
    FDataIndex, FIndex: integer;

    FTimeHintYL: TQuoteTimeHint;
    FTimeHintYR: TQuoteTimeHint;
    FTimeHintX: TQuoteTimeHint;
    FTimeCross: TQuoteTimeCross;
    FNowPriceMovePt: TQuoteTimeMovePt;
    FAveragePriceMovePt: TQuoteTimeMovePt;
    FArriveDataPt: TQuoteTimeMovePt;

    FTerminate: boolean;

    function GetHandles(const _Index: integer): TQuoteTimeHandle;
    procedure FreeHandles;
  protected
    property Handles[const Index: integer]: TQuoteTimeHandle read GetHandles;
    function Count: integer;
  public
    constructor Create(TimeGraphs: TQuoteTimeGraphs; _TimeMenu: IQuoteTimeMenu);
    destructor Destroy; override;
    procedure PaintTime;
    procedure ResetTime;
    procedure DrawOperates;
    procedure Resize;
    procedure UpdateSkin;
    procedure ResetFormat;

    procedure MouseMove(Shift: TShiftState; X, Y: integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    function KeyDown(var Key: Word; Shift: TShiftState): boolean;
    procedure KeyUp(var Key: Word; Shift: TShiftState);
    procedure CMMouseLeave(var Message: TMessage);
    procedure WMCancelMode(var Message: TWMCancelMode);
    procedure WMContextMenu(var Message: TWMContextMenu);

    property TimeGraphs: TQuoteTimeGraphs read FTimeGraphs;
    property ActiveHandle: TQuoteTimeHandle read FActiveHandle;
    property Terminate: boolean read FTerminate write FTerminate;
    property TimeCross: TQuoteTimeCross read FTimeCross;
  end;

implementation

{ TInterfaceObj }

function TInterfaceObj._AddRef: integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TInterfaceObj._Release: integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

function TInterfaceObj.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

{ TQuoteTimeHandle }

constructor TQuoteTimeHandle.Create;
begin
  Initialize;
  FRefCount := 1;
end;

procedure TQuoteTimeHandle.DrawOperate;
begin
end;

function TQuoteTimeHandle.CMEnter: boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.CMExit: boolean;
begin
  Result := true;
end;

procedure TQuoteTimeHandle.Initialize;
begin
end;

function TQuoteTimeHandle.CancelHandle: boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.CMMouseLeave: boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.KeyDown(var Key: Word; Shift: TShiftState): boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.KeyUp(var Key: Word; Shift: TShiftState): boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.MouseDown(Button: TMouseButton; Shift: TShiftState;
  const P: TPoint): boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.MouseMove(Shift: TShiftState;
  const P: TPoint): boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.MouseUp(Button: TMouseButton; Shift: TShiftState;
  const P: TPoint): boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.WMCancelMode: boolean;
begin
  Result := true;
end;

function TQuoteTimeHandle.WMContextMenu(const SP, CP: TPoint): boolean;
begin
  Result := true;
end;

{ TQuoteTimeOperates }

constructor TQuoteTimeOperates.Create(TimeGraphs: TQuoteTimeGraphs;
  _TimeMenu: IQuoteTimeMenu);
begin
  FTimeGraphs := TimeGraphs;
  FTimeMenu := _TimeMenu;
  FHandles := TList.Create;
  FTimeHintYL := TQuoteTimeHint.Create(TimeGraphs, htRulerYL);
  FTimeHintYR := TQuoteTimeHint.Create(TimeGraphs, htRulerYR);
  FTimeHintX := TQuoteTimeHint.Create(TimeGraphs, htRulerX);
  FTimeCross := TQuoteTimeCross.Create(TimeGraphs, FTimeMenu);
  FTimeCross.IsDrawCross := FTimeGraphs.Display.CrossLineVisible;
  FNowPriceMovePt := TQuoteTimeMovePt.Create(mptNowPricePt, TimeGraphs);
  FAveragePriceMovePt := TQuoteTimeMovePt.Create(mptAveragePricePt, TimeGraphs);
  // FArriveDataPt := TQuoteTimeMovePt.Create(mptArriveDataPt, TimeGraphs);
  // FArriveDataPt.AddEraseAfterOperate(FAveragePriceMovePt.ReDrawMovePt);
  // FArriveDataPt.AddEraseAfterOperate(FNowPriceMovePt.ReDrawMovePt);
end;

destructor TQuoteTimeOperates.Destroy;
begin
  // if Assigned(FArriveDataPt) then
  // FArriveDataPt.Free;
  if Assigned(FAveragePriceMovePt) then
    FAveragePriceMovePt.Free;
  if Assigned(FNowPriceMovePt) then
    FNowPriceMovePt.Free;
  if Assigned(FTimeCross) then
    FTimeCross.Free;
  if Assigned(FTimeHintYL) then
    FTimeHintYL.Free;
  if Assigned(FTimeHintYR) then
    FTimeHintYR.Free;
  if Assigned(FTimeHintX) then
    FTimeHintX.Free;
  if Assigned(FHandles) then
  begin
    FreeHandles;
    FHandles.Free;
  end;
  inherited;
end;

procedure TQuoteTimeOperates.DrawOperates;
begin
  FTimeCross.ReDrawCross;
  FTimeHintYL.ReDrawHint;
  if FTimeGraphs.Display.ShowMode <> smMulitStock then
    FTimeHintYR.ReDrawHint;
  FTimeHintX.ReDrawHint;
  FAveragePriceMovePt.ReDrawMovePt;
  FNowPriceMovePt.ReDrawMovePt;
  // with FTimeGraphs.QuoteTimeData do
  // begin
  // if Assigned(MainData) and (not MainData.QuoteEnd) then
  // FArriveDataPt.DrawArriveDataPt;
  // end;
end;

procedure TQuoteTimeOperates.FreeHandles;
var
  tmpIndex: integer;
begin
  for tmpIndex := 0 to FHandles.Count - 1 do
    TObject(FHandles[tmpIndex]).Free;
  FHandles.Clear;
end;

function TQuoteTimeOperates.Count: integer;
begin
  Result := FHandles.Count;
end;

function TQuoteTimeOperates.GetHandles(const _Index: integer): TQuoteTimeHandle;
begin
  Result := TQuoteTimeHandle(FHandles.Items[_Index]);
end;

function TQuoteTimeOperates.KeyDown(var Key: Word; Shift: TShiftState): boolean;
var
  tmpGraph: TQuoteTimeGraph;
  tmpLHint, tmpRHint: string;
begin
  Result := False;
  with FTimeGraphs do
  begin
    if FTimeGraphs.Display.ShowMode in [smNormal, smWSSelfDefinition] then
    begin
      if Key = VK_UP then
      begin
        if Assigned(FTimeMenu) then
          FTimeMenu.AddUserBehavior('keybordshotcut-timesharing-01');
        Enlarge;
        Result := true;
      end
      else if Key = VK_DOWN then
      begin
        if Assigned(FTimeMenu) then
          FTimeMenu.AddUserBehavior('keybordshotcut-timesharing-01');
        Narrow;
        Result := true;
      end
      else if Key = VK_LEFT then
      begin
        FTimeCross.EraseCross;
        FAveragePriceMovePt.EraseMovePt;
        FNowPriceMovePt.EraseMovePt;

        FTimeCross.DrawCross(cmtLeft);
        FAveragePriceMovePt.DrawMovePt(FTimeCross.LastPoint);
        FNowPriceMovePt.DrawMovePt(FTimeCross.LastPoint);

        FTimeHintX.DrawHint(FTimeCross.LastPoint,
          FTimeGraphs.XToXRulerHint(FTimeCross.DataIndex,
          FTimeCross.ColIndex), true);
        tmpGraph := GraphsHash[const_minutekey];
        if Assigned(tmpGraph) then
        begin
          tmpGraph.IndexToRulerHint(FTimeCross.DataIndex, FTimeCross.ColIndex,
            tmpLHint, tmpRHint);
          FTimeHintYL.DrawHint(FTimeCross.LastPoint, tmpLHint, true);
          if FTimeGraphs.Display.ShowMode <> smMulitStock then
            FTimeHintYR.DrawHint(FTimeCross.LastPoint, tmpRHint, true);
        end;
        Result := true;
      end
      else if Key = VK_RIGHT then
      begin
        FTimeCross.EraseCross;
        FAveragePriceMovePt.EraseMovePt;
        FNowPriceMovePt.EraseMovePt;

        FTimeCross.DrawCross(cmtRight);
        FAveragePriceMovePt.DrawMovePt(FTimeCross.LastPoint);
        FNowPriceMovePt.DrawMovePt(FTimeCross.LastPoint);

        FTimeHintX.DrawHint(FTimeCross.LastPoint,
          FTimeGraphs.XToXRulerHint(FTimeCross.DataIndex,
          FTimeCross.ColIndex), true);
        tmpGraph := GraphsHash[const_minutekey];
        if Assigned(tmpGraph) then
        begin
          tmpGraph.IndexToRulerHint(FTimeCross.DataIndex, FTimeCross.ColIndex,
            tmpLHint, tmpRHint);
          FTimeHintYL.DrawHint(FTimeCross.LastPoint, tmpLHint, true);
          if FTimeGraphs.Display.ShowMode <> smMulitStock then
            FTimeHintYR.DrawHint(FTimeCross.LastPoint, tmpRHint, true);
        end;
        Result := true;
      end
      else if Key = VK_HOME then
      begin
        FTimeCross.EraseCross;
        FAveragePriceMovePt.EraseMovePt;
        FNowPriceMovePt.EraseMovePt;

        FTimeCross.DrawCross(cmtHome);
        FAveragePriceMovePt.DrawMovePt(FTimeCross.LastPoint);
        FNowPriceMovePt.DrawMovePt(FTimeCross.LastPoint);

        FTimeHintX.DrawHint(FTimeCross.LastPoint,
          FTimeGraphs.XToXRulerHint(FTimeCross.DataIndex,
          FTimeCross.ColIndex), true);
        tmpGraph := GraphsHash[const_minutekey];
        if Assigned(tmpGraph) then
        begin
          tmpGraph.IndexToRulerHint(FTimeCross.DataIndex, FTimeCross.ColIndex,
            tmpLHint, tmpRHint);
          FTimeHintYL.DrawHint(FTimeCross.LastPoint, tmpLHint, true);
          if FTimeGraphs.Display.ShowMode <> smMulitStock then
            FTimeHintYR.DrawHint(FTimeCross.LastPoint, tmpRHint, true);
        end;
        Result := true;
      end
      else if Key = VK_END then
      begin
        FTimeCross.EraseCross;
        FAveragePriceMovePt.EraseMovePt;
        FNowPriceMovePt.EraseMovePt;

        FTimeCross.DrawCross(cmtEnd);
        FAveragePriceMovePt.DrawMovePt(FTimeCross.LastPoint);
        FNowPriceMovePt.DrawMovePt(FTimeCross.LastPoint);

        FTimeHintX.DrawHint(FTimeCross.LastPoint,
          FTimeGraphs.XToXRulerHint(FTimeCross.DataIndex,
          FTimeCross.ColIndex), true);
        tmpGraph := GraphsHash[const_minutekey];
        if Assigned(tmpGraph) then
        begin
          tmpGraph.IndexToRulerHint(FTimeCross.DataIndex, FTimeCross.ColIndex,
            tmpLHint, tmpRHint);
          FTimeHintYL.DrawHint(FTimeCross.LastPoint, tmpLHint, true);
          if FTimeGraphs.Display.ShowMode <> smMulitStock then
            FTimeHintYR.DrawHint(FTimeCross.LastPoint, tmpRHint, true);
        end;
        Result := true;
      end;
    end;
  end;
end;

procedure TQuoteTimeOperates.KeyUp(var Key: Word; Shift: TShiftState);
begin

end;

procedure TQuoteTimeOperates.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  tmpPt: TPoint;
  tmpGraph: TQuoteTimeGraph;
  tmpX, tmpY, tmpDataIndex, tmpIndex: integer;
begin
  with FTimeGraphs do
  begin
    if (mbLeft = Button) and (ssDouble in Shift) and
      (Display.ShowMode in [smNormal, smWSSelfDefinition]) and
      Assigned(QuoteTimeData.MainData) and
      not(QuoteTimeData.MainData.NullTimeData) then
    begin
      if PtInRect(FTimeGraphs.CenterRect, Point(X, Y)) then
      begin
        Display.CrossLineVisible := not Display.CrossLineVisible;
        FTimeCross.IsDrawCross := Display.CrossLineVisible;
        if FTimeGraphs.PtInGraphs(Point(X, Y), tmpGraph) then
        begin

          FTimeGraphs.XToIndexEx(X, tmpDataIndex, tmpIndex);
                  FDataIndex := tmpDataIndex;


//          if X > FTimeGraphs.GetCrossMoveMaxX then
//            tmpX := FTimeGraphs.GetCrossMoveMaxX;
          FDataIndex := tmpDataIndex;
          FIndex := tmpIndex;
          tmpX := FTimeGraphs.IndexToX(FDataIndex, FIndex);
          tmpPt := Point(tmpX, tmpY);

          FTimeCross.EraseCross;
          FAveragePriceMovePt.EraseMovePt;
          FNowPriceMovePt.EraseMovePt;
          FTimeCross.DrawCross(FDataIndex, FIndex, tmpPt);
          FAveragePriceMovePt.DrawMovePt(tmpPt);
          FNowPriceMovePt.DrawMovePt(tmpPt);
        end;
      end
    end;
  end;
end;

procedure TQuoteTimeOperates.MouseMove(Shift: TShiftState; X, Y: integer);
var
  tmpPt: TPoint;
  tmpData: TTimeData;
  tmpX, tmpY, tmpDataIndex, tmpIndex: integer;
  tmpGraph: TQuoteTimeGraph;
  tmpLHint, tmpRHint: string;
begin
  tmpData := FTimeGraphs.QuoteTimeData.MainData;
  if PPDistance(FMovePt, Point(X, Y)) > 0 then
  begin
    if (FTimeGraphs.Display.ShowMode in [smNormal, smMulitStock,
      smWSSelfDefinition]) then
    begin
      if Assigned(tmpData) and (not tmpData.NullTimeData) then
      begin
        if FTimeGraphs.PtInGraphs(Point(X, Y), tmpGraph) then
        begin
          FTimeGraphs.XToIndexEx(X, tmpDataIndex, tmpIndex);
          if ((tmpDataIndex <> FDataIndex) or (tmpIndex <> FIndex))
            or (FMovePt.Y <> Y) then
          begin
            tmpX := X;
            tmpY := Y;
//            if X > FTimeGraphs.GetCrossMoveMaxX then
//              tmpX := FTimeGraphs.GetCrossMoveMaxX;
            FDataIndex := tmpDataIndex;
            FIndex := tmpIndex;
            tmpX := FTimeGraphs.IndexToX(FDataIndex, FIndex);
            tmpPt := Point(tmpX, tmpY);

            FTimeCross.EraseCross;
            FAveragePriceMovePt.EraseMovePt;
            FNowPriceMovePt.EraseMovePt;

            FTimeCross.DrawCross(FDataIndex, FIndex, tmpPt);
            FAveragePriceMovePt.DrawMovePt(tmpPt);
            FNowPriceMovePt.DrawMovePt(tmpPt);

            FTimeHintX.DrawHint(tmpPt,
              FTimeGraphs.XToXRulerHint(FDataIndex, FIndex), true);
            FTimeGraphs.YToYRulerHint(tmpY, tmpGraph, tmpLHint, tmpRHint);
            FTimeHintYL.DrawHint(tmpPt, tmpLHint, true);
            if FTimeGraphs.Display.ShowMode <> smMulitStock then
              FTimeHintYR.DrawHint(tmpPt, tmpRHint, true);
          end;
        end
        else
        begin
          FTimeCross.EraseCross(False);
          FTimeHintYL.EraseHint;
          if FTimeGraphs.Display.ShowMode <> smMulitStock then
            FTimeHintYR.EraseHint;
          FTimeHintX.EraseHint;
          FAveragePriceMovePt.EraseMovePt;
          FNowPriceMovePt.EraseMovePt;
        end;
      end;
    end
    else
    begin
      FTimeCross.EraseCross(False);
      FTimeHintYL.EraseHint;
      if FTimeGraphs.Display.ShowMode <> smMulitStock then
        FTimeHintYR.EraseHint;
      FTimeHintX.EraseHint;
      FAveragePriceMovePt.EraseMovePt;
      FNowPriceMovePt.EraseMovePt;
    end;

    if FTimeGraphs.Display.ShowMode in [smNormal, smHistoryTime,
      smWSSelfDefinition] then
    begin
      if PtInRect(FTimeGraphs.VolumeHideButton.Rect, Point(X, Y)) then
      begin
        if not FTimeGraphs.VolumeButtonFocused then
        begin
          FTimeGraphs.VolumeButtonFocused := true;
          FTimeGraphs.DrawVolumeButton;
          FTimeGraphs.EraseRect(FTimeGraphs.VolumeHideButton.Rect);
        end;
      end
      else
      begin
        if FTimeGraphs.VolumeButtonFocused then
        begin
          FTimeGraphs.VolumeButtonFocused := False;
          FTimeGraphs.DrawVolumeButton;
          FTimeGraphs.EraseRect(FTimeGraphs.VolumeHideButton.Rect);
        end;
      end;
    end;
    tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
    if Assigned(tmpGraph) then
      tmpGraph.ToolsMouseMoveOperate(Shift, Point(X, Y));
    FMovePt := Point(X, Y);
  end;
end;

procedure TQuoteTimeOperates.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  tmpGraph: TQuoteTimeGraph;
begin
  if FTimeGraphs.Display.ShowMode in [smNormal, smHistoryTime,
    smWSSelfDefinition] then
    if PtInRect(FTimeGraphs.VolumeHideButton.Rect, Point(X, Y)) then
      FTimeGraphs.VolumeGraphVisible(not FTimeGraphs.VolumeVisible);

  tmpGraph := FTimeGraphs.GraphsHash[const_minutekey];
  if Assigned(tmpGraph) then
    tmpGraph.ToolsMouseUpOperate(Button, Shift, Point(X, Y));
end;

procedure TQuoteTimeOperates.PaintTime;
var
  tmpCenterRect: TRect;
begin
  if FTimeGraphs <> nil then
  begin
    tmpCenterRect := FTimeGraphs.CenterRect;
    FTimeGraphs.DrawFrame;
    if tmpCenterRect.Right > tmpCenterRect.Left then
    begin
      FTimeGraphs.DrawData;
    end;
  end;
end;

procedure TQuoteTimeOperates.ResetFormat;
begin
  if Assigned(FTimeCross) then
    FTimeCross.ResetFormat;
end;

procedure TQuoteTimeOperates.ResetTime;
begin

end;

procedure TQuoteTimeOperates.Resize;
begin
  FTimeCross.Resize;
end;

procedure TQuoteTimeOperates.UpdateSkin;
begin
  if Assigned(FTimeHintYL) then
    FTimeHintYL.UpdateSkin;
  if Assigned(FTimeHintYR) then
    FTimeHintYR.UpdateSkin;
  if Assigned(FTimeHintX) then
    FTimeHintX.UpdateSkin;
  if Assigned(FTimeCross) then
    FTimeCross.UpdateSkin;
end;

procedure TQuoteTimeOperates.CMMouseLeave(var Message: TMessage);
begin
  FTimeCross.MouseLeave;
  FTimeHintYL.EraseHint;
  if FTimeGraphs.Display.ShowMode <> smMulitStock then
    FTimeHintYR.EraseHint;
  FTimeHintX.EraseHint;
  FTimeCross.EraseCross;
  FAveragePriceMovePt.EraseMovePt;
  FNowPriceMovePt.EraseMovePt;
  FTimeGraphs.MouseLeave;
end;

procedure TQuoteTimeOperates.WMCancelMode(var Message: TWMCancelMode);
begin

end;

procedure TQuoteTimeOperates.WMContextMenu(var Message: TWMContextMenu);
var
  ScreenPt, ClientPt: TPoint;
begin
  ClipCursor(nil);

  ScreenPt := SmallPointToPoint(Message.Pos);
  ClientPt := FTimeGraphs.G32Graphic.Control.ScreenToClient(ScreenPt);

  if Assigned(FTimeMenu) and (FTimeGraphs.Display.ShowMode = smNormal) then
    FTimeMenu.MainMenu(ScreenPt);
end;

end.
