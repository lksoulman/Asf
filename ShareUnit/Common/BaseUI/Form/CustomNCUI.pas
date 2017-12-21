unit CustomNCUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º NCComstomUI
// Author£º      lksoulman
// Date£º        2017-12-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  RenderDC,
  AppContext,
  ComponentUI,
  CustomMasterUI,
  CommonRefCounter,
  Generics.Collections;

type

  // CustomNCUI
  TCustomNCUI = class(TAutoObject)
  private
  protected
    // WMPAINT
    FWMPAINT: Cardinal;
    // Parent
    FParent: TCustomMasterUI;
    // AppContext
    FAppContext: IAppContext;
    // RenderDC
    FRenderDC: TRenderDC;
    // ComponentsRect
    FComponentsRect: TRect;
    // Components
    FComponents: TList<TComponentUI>;
    // ComponentDic
    FComponentDic: TDictionary<Integer, TComponentUI>;

    // ClearComponents
    procedure DoClearComponents;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; virtual;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); virtual;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TCustomMasterUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Invaliate
    procedure Invalidate; virtual;
    // Change
    procedure Change(ACommandId: Integer); virtual;
    // Calc
    procedure Calc(ADC: HDC; ARect: TRect); virtual;
    // Draw
    procedure Draw(ADC: HDC; ARect: TRect; AId: Integer = -1); virtual;
    // LButtonClickComponent
    procedure LButtonClickComponent(AComponent: TComponentUI); virtual;
    // FindComponent
    function FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; overload; virtual;
    // FindComponent
    function FindComponent(AId: Integer; var AComponent: TComponentUI): Boolean; overload; virtual;

    property Parent: TCustomMasterUI read FParent;
    property ComponentsRect: TRect read FComponentsRect write FComponentsRect;
  end;

  // CustomNCUIClass
  TCustomNCUIClass = class of TCustomNCUI;

implementation

{ TCustomNCUI }

constructor TCustomNCUI.Create(AContext: IAppContext; AParent: TCustomMasterUI);
begin
  inherited Create;
  FWMPAINT := 0;
  FAppContext := AContext;
  FParent := AParent;
  FRenderDC := TRenderDC.Create;
  FComponents := TList<TComponentUI>.Create;
  FComponentDic := TDictionary<Integer, TComponentUI>.Create;
end;

destructor TCustomNCUI.Destroy;
begin
  DoClearComponents;
  FComponentDic.Free;
  FComponents.Free;
  FRenderDC.Free;
  FAppContext := nil;
  inherited;
end;

procedure TCustomNCUI.DoClearComponents;
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

procedure TCustomNCUI.DoCalcComponentsRect;
begin

end;

procedure TCustomNCUI.DoDrawBK(ARenderDC: TRenderDC);
begin

end;

procedure TCustomNCUI.DoDrawComponents(ARenderDC: TRenderDC);
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

procedure TCustomNCUI.Invalidate;
begin
  if FWMPAINT = 0 then Exit;

  if FParent.Showing then begin
    PostMessage(FParent.Handle, FWMPAINT, 0, 0);
  end;
end;

procedure TCustomNCUI.Change(ACommandId: Integer);
begin

end;

procedure TCustomNCUI.Calc(ADC: HDC; ARect: TRect);
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

procedure TCustomNCUI.Draw(ADC: HDC; ARect: TRect; AId: Integer);
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

procedure TCustomNCUI.LButtonClickComponent(AComponent: TComponentUI);
begin

end;

function TCustomNCUI.FindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
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

function TCustomNCUI.FindComponent(AId: Integer; var AComponent: TComponentUI): Boolean;
begin
  if FComponentDic.TryGetValue(AId, AComponent) then begin
    Result := True;
  end else begin
    Result := False;
    AComponent := nil;
  end;
end;

end.
