unit ButtonUI;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Controls,
  Stdctrls,
  Graphics,
  RzButton,
  Vcl.Forms,
  Vcl.ImgList,
  AppContext;

const
  BUTTONEX_MARGIN = 2;        // margin

type

  // ButtonUI
  TButtonUI = class(TRzToolButton)
  private
  protected
    // AppContext
    FAppContext: IAppContext;
    FDefault: Boolean;
    FCancel: Boolean;
    FActive: Boolean;
    FIsImageButton: Boolean;
    FMouseOver: Boolean;
    FBorderColor: TColor;
    FTextColor: TColor;
    FHotTextColor: TColor;
    FHotColor: TColor;
    FDownTextColor: TColor;
    FDownColor: TColor;
    FHotBorderColor: TColor;
    FDownBorderColor: TColor;
    FDisColor: TColor;
    FDisTextColor: TColor;
    FDisBorderColor: TColor;

    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // MouseEnter
    procedure DoMouseEnter(Sender: TObject);
    // MouseLeave
    procedure DoMouseLeave(Sender: TObject);
    // SetDefault
    procedure SetDefault(const Value: Boolean);
    // CMDialogKey
    procedure CMDialogKey(var Msg: TCMDialogKey); message cm_DialogKey;
    // CMFocusChanged
    procedure CMFocusChanged(var Msg: TCMFocusChanged); message cm_FocusChanged;
  protected
    // Paint
    procedure Paint; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle;
  published
//    property Color default $00FFFBFA;
    property HotColor: TColor read FHotColor write FHotColor;
    property DownColor: TColor read FDownColor write FDownColor;
    property DisColor: TColor read FDisColor write FDisColor;
    property TextColor: TColor read FTextColor write FTextColor;
    property HotTextColor: TColor read FHotTextColor write FHotTextColor;
    property DownTextColor: TColor read FDownTextColor write FDownTextColor;
    property DisTextColor: TColor read FDisTextColor write FDisTextColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property HotBorderColor: TColor read FHotBorderColor write FHotBorderColor;
    property DownBorderClolr: TColor read FDownBorderColor write FDownBorderColor;
    property DisBorderColor: TColor read FDisBorderColor write FDisBorderColor;
    property Cancel: Boolean read FCancel write FCancel default False;
    property Default: Boolean read FDefault write SetDefault default False;
  end;

implementation

{ TButtonUI }

constructor TButtonUI.Create(AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited Create(nil);
  Self.Font.Name := 'Î¢ÈíÑÅºÚ';
  Self.Font.Charset := GB2312_CHARSET;
  Self.Font.Height := -14;
  Self.OnMouseEnter := DoMouseEnter;
  Self.OnMouseLeave := DoMouseLeave;
  Transparent := False;
  FMouseOver := False;

  Color := $00FFFBFA;
  FHotColor := $00FFF3EB;
  FDownColor := $00FFE0CC;
  FDisColor := $00E8E8E8;
  FTextColor := $00332F2E;
  FHotTextColor := $00332F2E;
  FDownTextColor := $00332F2E;
  FDisTextColor := $00A3A3A3;
  FBorderColor := $00CFBAA5;
  FHotBorderColor := $00FFA74F;
  FDownBorderColor := $00FFA74F;
  FDisBorderColor := $00CCCCCC;

  DoUpdateSkinStyle;
end;

destructor TButtonUI.Destroy;
begin

  inherited;
  FAppContext := nil;
end;

procedure TButtonUI.UpdateSkinStyle;
begin
  DoUpdateSkinStyle;
end;

procedure TButtonUI.DoUpdateSkinStyle;
begin
  if FAppContext = nil then Exit;

  Color := FAppContext.GetGdiMgr.GetColorRefButtonBack;
  FBorderColor := FAppContext.GetGdiMgr.GetColorRefButtonBorder;
  FTextColor := FAppContext.GetGdiMgr.GetColorRefButtonText;
  FHotColor := FAppContext.GetGdiMgr.GetColorRefButtonHotBack;
  FHotBorderColor := FAppContext.GetGdiMgr.GetColorRefButtonHotBorder;
  FHotTextColor := FAppContext.GetGdiMgr.GetColorRefButtonHotText;
  FDownColor := FAppContext.GetGdiMgr.GetColorRefButtonDownBack;
  FDownBorderColor := FAppContext.GetGdiMgr.GetColorRefButtonDownBorder;
  FDownTextColor := FAppContext.GetGdiMgr.GetColorRefButtonDownText;
  FDisColor := FAppContext.GetGdiMgr.GetColorRefButtonDisableBack;
  FDisBorderColor := FAppContext.GetGdiMgr.GetColorRefButtonDisableBorder;
  FDisTextColor := FAppContext.GetGdiMgr.GetColorRefButtonDisableText;
end;

procedure TButtonUI.SetDefault(const Value: Boolean);
var
  Form: TCustomForm;
begin
  FDefault := Value;
  if Self.HasParent then
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.Perform(cm_FocusChanged, 0, Longint(Form.ActiveControl));
  end;
end;

procedure TButtonUI.CMDialogKey(var Msg: TCMDialogKey);
begin
  if (((Msg.CharCode = vk_Return) and FActive)
    or ((Msg.CharCode = vk_Escape) and FCancel)) and (KeyDataToShiftState(Msg.KeyData) = []) then
  begin
    try
      Click;
    finally
    end;
    Msg.Result := 1;
  end
  else
    inherited;
end;

procedure TButtonUI.CMFocusChanged(var Msg: TCMFocusChanged);
var
  MakeActive: Boolean;
begin
  with Msg do begin
    if (Sender is TRzButton) or (Sender is TButton) then begin
      MakeActive := False
    end else begin
      MakeActive := FDefault;
    end;
  end;

  if MakeActive <> FActive then begin
    FActive := MakeActive;
  end;
  inherited;
end;

procedure TButtonUI.DoMouseEnter(Sender: TObject);
begin
  FMouseOver := True;
end;

procedure TButtonUI.DoMouseLeave(Sender: TObject);
begin
  FMouseOver := False;
end;

procedure TButtonUI.Paint;
var
  LRect: TRect;
begin
  LRect := ClientRect;
  if Enabled then begin
    Canvas.Brush.Color := Color;
    Canvas.Font.Color := FTextColor;
    Canvas.Pen.Color := FBorderColor;
    if FState in [tbsDown, tbsExclusive] then begin
      Canvas.Brush.Color := FDownColor;
      Canvas.Font.Color := FDownTextColor;
      Canvas.Pen.Color := FDownBorderColor;
    end else if FMouseOver then begin
      Canvas.Brush.Color := FHotColor;
      Canvas.Font.Color := FHotTextColor;
      Canvas.Pen.Color := FHotBorderColor;
    end;
  end else begin
    Canvas.Brush.Color := FDisColor;
    Canvas.Font.Color := FDisTextColor;
    Canvas.Pen.Color := FDisBorderColor;
  end;
  Canvas.Rectangle(LRect);
  InflateRect(LRect, -1, -1);
  if Self.Caption <> '' then begin
    LRect.Inflate(-BUTTONEX_MARGIN, -BUTTONEX_MARGIN);
    LRect.Offset(0, -1);
    SelectObject(Canvas.Handle, Self.Font.Handle);
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(Caption), -1, LRect, DT_VCENTER or DT_CENTER or DT_SINGLELINE);
  end;
end;

end.
