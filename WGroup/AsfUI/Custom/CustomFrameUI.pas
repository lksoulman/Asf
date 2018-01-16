unit CustomFrameUI;

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Controls,
  RenderDC,
  AppContext,
  RenderUtil,
  CommonLock,
  ComponentUI,
  Generics.Collections;

type

  // CustomFrameUI
  TCustomFrameUI = class(TCustomControl)
  private
  protected
    // Id
    FUniqueId: Integer;
    // MouseMoveId
    FMouseMoveId: Integer;
    // MouseDownId
    FMouseDownId: Integer;
    // Lock
    FLock: TCSLock;
    // RenderDC
    FRenderDC: TRenderDC;
    // ComponentsRect
    FComponentsRect: TRect;
    // AppContext
    FAppContext: IAppContext;
    // Components
    FComponents: TList<TComponentUI>;
    // ComponentDic
    FComponentDic: TDictionary<Integer, TComponentUI>;

    // Paint
    procedure Paint; override;
    // WMSize
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    // WMEraseBkgnd
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    // MouseMove
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    // MouseDown
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    // MouseUp
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    // GetUniqueId
    function GetUniqueId: Integer;
    // ClearComponents
    procedure DoClearComponents; virtual;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; virtual;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); virtual;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); virtual;
    // AddComponent
    procedure DoAddComponent(AComponent: TComponentUI); virtual;
    // MouseEnter
    procedure DoMouseEnter(Sender: TObject); virtual;
    // MouseLeave
    procedure DoMouseLeave(Sender: TObject); virtual;
    // Calc
    procedure DoCalc(ADC: HDC; ARect: TRect); virtual;
    // Draw
    procedure DoDraw(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // FindComponent
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; overload; virtual;
    // FindComponent
    function DoFindComponent(AId: Integer; var AComponent: TComponentUI): Boolean; overload; virtual;
  protected
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;

    property MouseMoveId: Integer read FMouseMoveId write FMouseMoveId;
    property MouseDownId: Integer read FMouseDownId write FMouseDownId;
  end;

implementation

{ TCustomFrameUI }

constructor TCustomFrameUI.Create(AContext: IAppContext);
begin
  FAppContext := nil;
  inherited Create(nil);
  Self.OnMouseEnter := DoMouseEnter;
  Self.OnMouseLeave := DoMouseLeave;
  FUniqueId := 0;
  FLock := TCSLock.Create;
  FRenderDC := TRenderDC.Create;
  FComponents := TList<TComponentUI>.Create;
  FComponentDic := TDictionary<Integer, TComponentUI>.Create;
end;

destructor TCustomFrameUI.Destroy;
begin
  DoClearComponents;
  FComponentDic.Free;
  FComponents.Free;
  FRenderDC.Free;
  FLock.Free;
  inherited;
  FAppContext := nil;
end;

function TCustomFrameUI.GetUniqueId: Integer;
begin
  FLock.Lock;
  try
    Result := FUniqueId;
    Inc(FUniqueId);
  finally
    FLock.UnLock;
  end;
end;

procedure TCustomFrameUI.DoClearComponents;
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

procedure TCustomFrameUI.DoCalcComponentsRect;
begin

end;

procedure TCustomFrameUI.DoDrawBK(ARenderDC: TRenderDC);
begin

end;

procedure TCustomFrameUI.DoDrawComponents(ARenderDC: TRenderDC);
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

procedure TCustomFrameUI.DoAddComponent(AComponent: TComponentUI);
begin
  if FComponents.IndexOf(AComponent) < 0 then begin
    AComponent.Id := GetUniqueId;
    FComponents.Add(AComponent);
    FComponentDic.AddOrSetValue(AComponent.Id, AComponent);
  end;
end;

procedure TCustomFrameUI.DoMouseEnter(Sender: TObject);
begin

end;

procedure TCustomFrameUI.DoMouseLeave(Sender: TObject);
begin

end;

procedure TCustomFrameUI.DoCalc(ADC: HDC; ARect: TRect);
begin
  if not FRenderDC.IsInit then begin
    FRenderDC.SetDC(ADC);
  end;

  if FRenderDC.MemDC = 0 then Exit;

  FComponentsRect := ARect;
  FRenderDC.SetBounds(ADC, FComponentsRect);
  if FComponentsRect.Left < FComponentsRect.Right then begin
    DoCalcComponentsRect;
  end;
end;

procedure TCustomFrameUI.DoDraw(ADC: HDC; ARect: TRect; AId: Integer = -1);
var
  LComponentUI: TComponentUI;
begin
  if FRenderDC.MemDC = 0 then Exit;

  if AId = -1 then begin
    if FComponentsRect.Left < FComponentsRect.Right - 10 then begin
      DoDrawBK(FRenderDC);
      DoDrawComponents(FRenderDC);
    end;
  end else begin
    if FComponentDic.TryGetValue(AId, LComponentUI) then begin
      LComponentUI.Draw(FRenderDC);
    end;
  end;

  FRenderDC.BitBltX(ADC, ARect);
end;

function TCustomFrameUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FComponents.Count - 1 do begin
    AComponent := FComponents.Items[LIndex];
    if AComponent.Visible
      and AComponent.RectExIsValid
      and AComponent.PtInRectEx(APt) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TCustomFrameUI.DoFindComponent(AId: Integer; var AComponent: TComponentUI): Boolean;
begin
  if FComponentDic.TryGetValue(AId, AComponent) then begin
    Result := True;
  end else begin
    Result := False;
    AComponent := nil;
  end;
end;

procedure TCustomFrameUI.Paint;
var
  LDC: HDC;
  LRect: TRect;
begin
  LDC := Canvas.Handle;
  DoDraw(LDC, LRect);
end;

procedure TCustomFrameUI.WMSize(var Message: TWMSize);
var
  LDC: HDC;
  LRect: TRect;
begin
  inherited;
  LDC := GetWindowDC(Self.Handle);
  try
    LRect := GetClientRect;
    DoCalc(LDC, LRect);
  finally
    ReleaseDC(Self.Handle, LDC);
  end;
end;

procedure TCustomFrameUI.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCustomFrameUI.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TCustomFrameUI.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TCustomFrameUI.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

end.
