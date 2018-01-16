unit QuoteCommButton;

interface

uses
  Windows, Messages, Classes, Controls, ExtCtrls, Graphics, system.SysUtils, System.Math,
  Vcl.Imaging.pngimage, Vcl.StdCtrls,  AppControllerInf,  CommonFunc, System.StrUtils,
  QuoteCommLibrary, gr32;

const
  Con_Disable_Suffix = 'Disable';
  Con_Down_Suffix = 'Down';
  Con_Hot_Suffix = 'Hot';

  Con_MultiSelectMaxSelCount = 3;

type
  TQuoteButtonPos = (btNone, btButton, btLeftIcon, btRightIcon);

  TQuoteIconStyle = (biNone, biPupupButton, biCloseButton, biIncButton, biDecButton, biLeftButton, biRightButton);
  TQuoteButtonType = (btNormal, btHot, btClose);

  TOnButtonClick = procedure(Sender: TObject; ButtonPos: TQuoteButtonPos) of object;

  TQuoteButtonDisplay = class
  public
    BackColor: TColor;

    ButtonFont: TFont;
    ButtonFontColor: TColor;
    ButtonFontHotColor: TColor; // 激活字体色
    ButtonFontDownColor: TColor; // 激活字体色
    ButtonLineColor: TColor; // 边框线色
    ButtonLineHotColor: TColor; // 激活边框线色
    ButtonLineDownColor: TColor; // 按下状态边框颜色
    ButtonBackColor: TColor; // 背景色
    ButtonBackHotColor: TColor; // 激活背景色
    ButtonBackDownColor: TColor; // 按下状态背景颜色

    ButtonWidth: Integer;
    ButtonHeight:INteger;
    ButtonIncWidth: SHORT;

    BottomHeight: integer;

    constructor Create;
    destructor Destroy; override;
    procedure UpdateSkin(AGilAppController: IGilAppController);
  end;

  TQuotePngBaseButton = class(TCustomControl)
  private
    FID: Integer;
    FDown: Boolean; // 按钮是否按下状态
    FImage: TPngImage;
    FResourceName: string;
  protected
    FMouseInBtn: Boolean;
    FOnReLoadImage: TNotifyEvent;
    FOnMouseLeftDown: TNotifyEvent;
    FOnMouseLeftUp: TNotifyEvent;

    procedure SetDown(const Value: Boolean); virtual;
    procedure SetResourceName(const Value: string); virtual;
    procedure ReLoadImage; virtual;

    procedure Paint; override;
    procedure Click; override;
    procedure SetEnabled(Value: Boolean); override;

    procedure CMMouseEnter(var Message: TMessage); Message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); Message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property Down: Boolean read FDown write SetDown;
    property MouseInBtn: Boolean read FMouseInBtn;
    property Image: TPngImage read FImage write FImage;
    property ResourceName: string read FResourceName write SetResourceName;

    property OnReLoadImage: TNotifyEvent read FOnReLoadImage write FOnReLoadImage;
    property OnMouseLeftDown: TNotifyEvent read FOnMouseLeftDown write FOnMouseLeftDown;
    property OnMouseLeftUp: TNotifyEvent read FOnMouseLeftUp write FOnMouseLeftUp;
    property OnClick;
    property Canvas;
  end;

  // *** 只有图片的按钮 ***//
  TQuoteOnlyPngButton = class(TQuotePngBaseButton)
  protected
    procedure CMMouseLeave(var Message: TMessage); Message CM_MOUSELEAVE;
  end;

  // *** 包含图片及边框等元素的按钮 ***//
  TQuotePngButton = class(TQuotePngBaseButton)
  private
    FLineColor: TColor; // 边框线色
    FLineHotColor: TColor; // 激活边框线色
    FLineDownColor: TColor; // 按下状态边框颜色
    FTextColor: TColor; // 按钮字体
    FTextHotColor: TColor; // 激活字体色
    FTextDownColor: TColor; // 按下状态字体色
    FBackColor: TColor; // 背景色
    FBackHotColor: TColor; // 激活背景色
    FBackDownColor: TColor; // 按下状态背景颜色

    FParentBGColor: TColor; // 填充底色（在背景的下一层）
    FRoundHCount: Integer; // 圆角矩形，横向圆弧点个数
    FRoundVCount: Integer; // 圆角矩形，竖向圆弧点个数

  protected
    procedure DrawButtonBorder; virtual;
    procedure DrawNormalButton; virtual;
    procedure DrawHotButton; virtual;
    procedure DrawDownButton; virtual;
    procedure DrawCaption; virtual;

    procedure Paint; override;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property LineColor: TColor read FLineColor write FLineColor;
    property LineHotColor: TColor read FLineHotColor write FLineHotColor;
    property LineDownColor: TColor read FLineDownColor write FLineDownColor;
    property BackColor: TColor read FBackColor write FBackColor;
    property BackHotColor: TColor read FBackHotColor write FBackHotColor;
    property BackDownColor: TColor read FBackDownColor write FBackDownColor;
    property TextColor: TColor read FTextColor write FTextColor;
    property TextHotColor: TColor read FTextHotColor write FTextHotColor;
    property TextDownColor: TColor read FTextDownColor write FTextDownColor;
    property ParentBGColor: TColor read FParentBGColor write FParentBGColor;
    property RoundHCount: Integer read FRoundHCount write FRoundHCount;
    property RoundVCount: Integer read FRoundVCount write FRoundVCount;

    // property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property Caption;
    property Anchors;
    property Enabled;
    property Font;
    property Visible;
  end;

  TTextButtonsManager = class;

  // *** 只有文本没有图标，有边框 ***//
  TQuoteTextButton = class(TCustomControl)
  private
    FID: Integer;
    FDown: Boolean; // 按钮是否按下状态
    FButtonsManager: TTextButtonsManager;

    FOnMouseLeftDown: TNotifyEvent;
    FOnMouseLeftUp: TNotifyEvent;
    procedure SetDown(const Value: Boolean);
  protected
    procedure DrawButtonBorder; virtual;
    procedure DrawNormalButton; virtual;
    procedure DrawHotButton; virtual;
    procedure DrawDownButton; virtual;
    procedure DrawCaption; virtual;

    procedure Paint; override;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;

    procedure CMMouseEnter(var Message: TMessage); Message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); Message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property Down: Boolean read FDown write SetDown;
    property ButtonsManager: TTextButtonsManager read FButtonsManager write FButtonsManager;
    property OnMouseLeftDown: TNotifyEvent read FOnMouseLeftDown write FOnMouseLeftDown;
    property OnMouseLeftUp: TNotifyEvent read FOnMouseLeftUp write FOnMouseLeftUp;
    property OnClick;
    property Caption;
    property Anchors;
    property Enabled;
    property Font;
    property Visible;
  end;

  TPngButtonClass = class of TQuotePngBaseButton;
  TArrayPngButton = array of TQuotePngBaseButton;

  TButtonsManager = class(TObject)
  private
    FResourceInstance: HInst;
    FBtnSize: Integer;
    FButtons: TArrayPngButton;
    FResourceNames: array of string;
    FPngButtonClass: TPngButtonClass;
    FDownSuffix: string;
    FHotSuffix: string;

    FOnMouseLeftDown: TNotifyEvent;
    FOnMouseLeftUp: TNotifyEvent;
    procedure DoReLoadImage(Sender: TObject);
    procedure UpdateBtnImage(APngButton: TQuotePngBaseButton);
    function GetButton(const AIndex: Integer): TQuotePngBaseButton;

    procedure DoMouseLeftDown(Sender: TObject);
    procedure DoMouseLeftUp(Sender: TObject);
  public
    constructor Create(APngButtonClass: TPngButtonClass);
    destructor Destroy; override;
    procedure InitButton(AParentCtrl: TCustomControl; ABtnSize: Integer;
      AResourceNames: array of string; AClickEvent: array of TNotifyEvent);
    procedure SetButtonHints(AHints: array of string);

    procedure UpdateSkin(AResourceInstance: HInst; ABackColor: TColor);
    procedure SettingBtnEnabled(AEnabled: Boolean);

    property BtnSize: Integer read FBtnSize write FBtnSize;
    property Buttons[const AIndex: Integer]: TQuotePngBaseButton read GetButton;
    property DownSuffix: string read FDownSuffix write FDownSuffix;
    property HotSuffix: string read FHotSuffix write FHotSuffix;

    property OnMouseDown: TNotifyEvent read FOnMouseLeftDown write FOnMouseLeftDown;
    property OnMouseUp: TNotifyEvent read FOnMouseLeftUp write FOnMouseLeftUp;
  end;

  TArrayTextButton = array [TFormulaType] of TQuoteTextButton;
  TButtonUpEvent = procedure(Sender: TObject; NewFormulaType: Integer) of object;

  TTextButtonsManager = class(TObject)
  private
    FLineColor: TColor; // 边框线色
    FLineHotColor: TColor; // 激活边框线色
    FLineDownColor: TColor; // 按下状态边框颜色
    FTextColor: TColor; // 按钮字体
    FTextHotColor: TColor; // 激活字体色
    FTextDownColor: TColor; // 按下状态字体色
    FBackColor: TColor; // 背景色
    FBackHotColor: TColor; // 激活背景色
    FBackDownColor: TColor; // 按下状态背景颜色

    FParentBGColor: TColor; // 填充底色（在背景的下一层）
    FRoundHCount: Integer; // 圆角矩形，横向圆弧点个数
    FRoundVCount: Integer; // 圆角矩形，竖向圆弧点个数

    FDisabledColor1: TColor; // 按钮禁用时的文本颜色1
    FDisabledColor2: TColor; // 按钮禁用时的文本颜色2

    FFormulaButtons: TArrayTextButton;
    FMultiSelecteds: TList;

    FOnSSButtonDown: TNotifyEvent;
    FOnSSButtonUp: TNotifyEvent;
    FOnMSButtonDown: TNotifyEvent;
    FOnMSButtonUp: TButtonUpEvent;

    procedure DoSSButtonDown(Sender: TObject);
    procedure DoSSButtonUp(Sender: TObject);
    procedure DoSSMouseLeftDown(Sender: TObject);
    procedure DoSSMouseLeftUp(Sender: TObject);
    procedure DoMSButtonDown(Sender: TObject);
    procedure DoMSButtonUp(Sender: TObject; NewFormulaType: Integer);
    procedure DoMSMouseLeftDown(Sender: TObject);
    procedure DoMSMouseLeftUp(Sender: TObject);
    function GetFormulaButton(const AIndex: TFormulaType): TQuoteTextButton;

  public
    constructor Create;
    destructor Destroy; override;
    procedure InitButton(AParentCtrl: TCustomControl; ACaptions: TArrayFormulaNames);

    procedure UpdateSkin(AColors: array of TColor; AFont: TFont);
    procedure ReSizePosition(ABtnWidth, ABtnHeight: Integer; AButtonsRect: TRect);
    procedure ResetBottomBtnState(AID: Integer);
    procedure CancelSSFormulaBtn(AFormulaID: Integer);
    procedure ChangeSSFormulaBtn(AOLDFormulaID, AFormulaID: Integer);
    procedure ChangeMSFormulaBtn(AOLDFormulaID, AFormulaID: Integer);

    property LineColor: TColor read FLineColor write FLineColor;
    property LineHotColor: TColor read FLineHotColor write FLineHotColor;
    property LineDownColor: TColor read FLineDownColor write FLineDownColor;
    property BackColor: TColor read FBackColor write FBackColor;
    property BackHotColor: TColor read FBackHotColor write FBackHotColor;
    property BackDownColor: TColor read FBackDownColor write FBackDownColor;
    property TextColor: TColor read FTextColor write FTextColor;
    property TextHotColor: TColor read FTextHotColor write FTextHotColor;
    property TextDownColor: TColor read FTextDownColor write FTextDownColor;
    property ParentBGColor: TColor read FParentBGColor write FParentBGColor;
    property RoundHCount: Integer read FRoundHCount write FRoundHCount;
    property RoundVCount: Integer read FRoundVCount write FRoundVCount;

    property FormulaButtons[const AIndex: TFormulaType]: TQuoteTextButton read GetFormulaButton;

    property OnSSButtonDown: TNotifyEvent read FOnSSButtonDown write FOnSSButtonDown;
    property OnSSButtonUp: TNotifyEvent read FOnSSButtonUp write FOnSSButtonUp;
    property OnMSButtonDown: TNotifyEvent read FOnMSButtonDown write FOnMSButtonDown;
    property OnMSButtonUp: TButtonUpEvent read FOnMSButtonUp write FOnMSButtonUp;
  end;

  TQuoteAutoPngButton = class(TQuotePngBaseButton)
  protected
    FInstance: HInst;
    FIsChangeInstance: Boolean;
    FBackColor: TColor;

    procedure SetResourceName(const Value: string); override;
    procedure ReLoadImage; override;
    procedure SetInstance(AInstance: HInst); virtual;
    procedure CMMouseEnter(var Message: TMessage); Message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); Message CM_MOUSELEAVE;

    procedure SetBackColor(AColor: TColor);
  public
    NormalResourceName: string; // 标准状态显示图片
    HotResourceName: string; // 激活状态显示图片
    DownResourceName: string; // 按下状态显示图片
    IsAutoWidth: Boolean;
    IsAutoHeight: Boolean;

    constructor Create(AOwner: TComponent); override;

    procedure UpdateSkin(AGilAppController: IGilAppController);

    property Instance: HInst read FInstance write SetInstance;

    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property BackColor: TColor read FBackColor write SetBackColor;

  end;

  { ---------------------------------------------------------------------------- }

  TQuoteButton = class(TCustomControl)
  private
    FQuoteButtonDisplay: TQuoteButtonDisplay;
    FButtonType: TQuoteButtonType;

    FMouseTest: TQuoteButtonPos;
    FMouseClickTest: TQuoteButtonPos;
    FMouseLeftDown: Boolean;

    FBorderLine: TQuoteBorderLine;

    FLineColor: TColor; // 边框线色
    FLineHotColor: TColor; // 激活边框线色
    FLineDownColor: TColor; // 按下状态边框颜色
    FLineSpecialColor: TColor;
    FFontColor: TColor; // 按钮字体
    FFontHotColor: TColor; // 激活字体色
    FFontDownColor: TColor; // 按下状态字体色
    FBackColor: TColor; // 背景色
    FBackHotColor: TColor; // 激活背景色
    FBackDownColor: TColor; // 按下状态背景颜色

    FIconColor: TColor;
    FIconHotColor: TColor;
    FDown: Boolean; // 按钮是否按下状态

    FLeftIconStyle: TQuoteIconStyle; // 按扭样式
    FRightIconStyle: TQuoteIconStyle; // 按扭样式
    FIncIconWidth: Integer;
    FOnButtonClick: TOnButtonClick;

    FParentBKColor: TColor; // 填充底色（在背景的下一层）
    FRoundXCount: ShortInt; // 圆角矩形，横向圆弧点个数
    FRoundYCount: ShortInt; // 圆角矩形，竖向圆弧点个数

  protected
    function GetHitTestInfoAt(P: TPoint): TQuoteButtonPos; virtual;
    function GetIconSize(IconStyle: TQuoteIconStyle): Integer; virtual;
    procedure DrawIcon(IconStyle: TQuoteIconStyle; ButtonType: TQuoteButtonType; Left: Boolean); virtual;
    procedure DrawTypeBtn(ButtonType: TQuoteButtonType); virtual;
    procedure DrawButtonBorder; virtual;
    procedure DrawNormalButton; virtual;
    procedure DrawHotButton; virtual;
    procedure DrawDownButton; virtual;
    procedure DrawCaption; virtual;

    procedure Paint; override;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure WMErase(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;

    procedure SetDown(ADown: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateSkin(AGilAppController: IGilAppController); virtual;
  published
    property ButtonType: TQuoteButtonType read FButtonType write FButtonType;
    property RoundXCount: ShortInt read FRoundXCount write FRoundXCount;
    property RoundYCount: ShortInt read FRoundYCount write FRoundYCount;
    property LineColor: TColor read FLineColor write FLineColor;
    property LineHotColor: TColor read FLineHotColor write FLineHotColor;
    property LineDownColor: TColor read FLineDownColor write FLineDownColor;
    property LineSpecialColor: TColor read FLineSpecialColor write FLineSpecialColor;
    property FontColor: TColor read FFontColor write FFontColor;
    property FontHotColor: TColor read FFontHotColor write FFontHotColor;
    property FontDownColor: TColor read FFontDownColor write FFontDownColor;
    property ParentBKColor: TColor read FParentBKColor write FParentBKColor;
    property BackColor: TColor read FBackColor write FBackColor;
    property BackHotColor: TColor read FBackHotColor write FBackHotColor;
    property BackDownColor: TColor read FBackDownColor write FBackDownColor;
    property IconColor: TColor read FIconColor write FIconColor;
    property IconHotColor: TColor read FIconHotColor write FIconHotColor;
    property Down: Boolean read FDown write SetDown;
    property BorderLine: TQuoteBorderLine read FBorderLine write FBorderLine;
    property LeftIconStyle: TQuoteIconStyle read FLeftIconStyle write FLeftIconStyle;
    property RightIconStyle: TQuoteIconStyle read FRightIconStyle write FRightIconStyle;
    property OnButtonClick: TOnButtonClick read FOnButtonClick write FOnButtonClick;
    property Caption;
    property Anchors;
    property Enabled;
    property Font;
    property Visible;
    property Canvas;
  end;

  TQuoteImgButton = class(TQuoteButton)
  private
  protected
    FIsLoadImg: Boolean;
    FAutoWidth: Boolean;

    FImage: string; // 标准状态显示图片
    FHotImage: string; // 激活状态显示图片
    FDownImage: string; // 按下状态显示图片

    FImgBitMap: TBitmap;
    FHotImgBitMap: TBitmap;
    FDownImgBitMap: TBitmap;

    procedure DrawTransparentBmp(ADescCanvas: TCanvas; X, Y: Integer; ASourceBmp: TBitmap; clTransparent: TColor);
    // 带 透明色的 拷贝

    procedure DrawNormalButton; override;
    procedure DrawHotButton; override;
    procedure DrawDownButton; override;

    procedure Paint; override;

    procedure SetImage(APath: String);
    procedure SetHotImage(APath: String);
    procedure SetDownImage(APath: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadImg;
  published
    property Image: string read FImage write FImage;
    property HotImage: string read FHotImage write FHotImage;
    property DownImage: string read FDownImage write FDownImage;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth;
  end;

  TQuoteIconButton = class(TQuoteButton)
  private
  protected
    FIsLoadImg: Boolean;
    FAutoWidth: Boolean;

    FImage: string; // 标准状态显示图片
    FHotImage: string; // 激活状态显示图片
    FDownImage: string; // 按下状态显示图片

    FImgIcon: TIcon;
    FHotImgIcon: TIcon;
    FDownImgIcon: TIcon;

    procedure DrawNormalButton; override;
    procedure DrawHotButton; override;
    procedure DrawDownButton; override;

    procedure Paint; override;

    procedure SetImage(APath: String);
    procedure SetHotImage(APath: String);
    procedure SetDownImage(APath: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadImg;
  published
    property Image: string read FImage write FImage;
    property HotImage: string read FHotImage write FHotImage;
    property DownImage: string read FDownImage write FDownImage;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth;
  end;

  //带有自选框icon小图标的按钮
  TQuoteSelectedIconButton  = class(TCustomControl)
  protected
    FGilAppController: IGilAppController; // 模块获取数据的接口
    FInstance: HINST; // 皮肤res文件读取使用的接口
    FID: Integer;
    FCaption: string;
    FBackColor: TColor;
    FLabel: TLabel; //用于展示caption
    FSelected: Boolean; //icon选中标志
    FBtnFont: TFont;

    FIconName: string;
    FSelectedIconName: string;
    FIcon: TPngImage;
    FSelectedIcon: TPngImage;
    FImgRect: TRect;
    FOnSelectedChange: TNotifyEvent;

    procedure SetCaption(Value: string); virtual;
    procedure SetBackColor(Value: TColor); virtual;
    procedure SetBtnFont(Value: TFont); virtual;

    function GetFontColor: TColor; virtual;
    procedure SetFontColor(Value: TColor); virtual;

    procedure SetAutoSize(Value: Boolean); virtual;

    procedure Paint; override;
    procedure InitImage; virtual;
    procedure DoBtnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConnectQuoteManager(const GilAppController: IGilAppController); virtual;
    procedure Disconnection; virtual;
    procedure UpdateSkin; virtual;
    procedure ReDrawIcon; virtual;
    //转换caption显示的样式，防止展示不全
    procedure TransferCaption; virtual;

    property ID: Integer read FID write FID;
    property AutoSize: Boolean write SetAutoSize;
    property Caption: string read FCaption write SetCaption;
    property BackColor: TColor read FBackColor write SetBackColor;
    property FontColor: TColor read GetFontColor write SetFontColor;
    property Selected: Boolean read FSelected write FSelected;
    property BtnFont: TFont read FBtnFont write SetBtnFont;
    property IconName: string read FIconName write FIconName;
    property SelectedIconName: string read FSelectedIconName write FSelectedIconName;
    property OnSelectedChange: TNotifyEvent read FOnSelectedChange write FOnSelectedChange;
  end;

implementation

constructor TQuoteButtonDisplay.Create;
begin

  ButtonFont:= TFont.Create;
  ButtonFont.Name := '微软雅黑';


  ButtonWidth := 60;
  ButtonHeight:= 25;
  ButtonIncWidth := 10;
  BottomHeight := 40;;
end;

destructor TQuoteButtonDisplay.Destroy;
begin
  ButtonFont.Free;
  inherited;
end;

procedure TQuoteButtonDisplay.UpdateSkin(AGilAppController: IGilAppController);
  function GetColorFromConfig(AKey: WideString): TColor;
  begin
    Result := TColor(HexToIntDef(AGilAppController.Config(ctSkin, AKey), 0));
  end;
begin
  if Assigned(AGilAppController) then
  with AGilAppController do
  begin
    BackColor := GetColorFromConfig('Form_Pop_BackColor');

    ButtonFontColor := GetColorFromConfig('Control_QuoteButton_FontColor');
    ButtonFontHotColor := GetColorFromConfig('Control_QuoteButton_FontHotColor');//激活字体色
    ButtonFontDownColor := GetColorFromConfig('Control_QuoteButton_FontDownColor');//激活字体色

    ButtonBackColor := GetColorFromConfig('Control_QuoteButton_BackColor');//控件边界的颜色
    ButtonBackHotColor := GetColorFromConfig('Control_QuoteButton_BackHotColor');//控件边界的颜色
    ButtonBackDownColor := GetColorFromConfig('Control_QuoteButton_BackDownColor');//控件边界的颜色

    ButtonLineColor := GetColorFromConfig('Control_QuoteButton_LineColor');
    ButtonLineHotColor := GetColorFromConfig('Control_QuoteButton_LineHotColor');
    ButtonLineDownColor := GetColorFromConfig('Control_QuoteButton_LineDownColor');
  end;
end;
{ TQuotePngBaseButton }

procedure TQuotePngBaseButton.Click;
begin
  inherited;
  ReLoadImage;
end;

procedure TQuotePngBaseButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FMouseInBtn := True;
  ReLoadImage;
end;

procedure TQuotePngBaseButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseInBtn := False;
  ReLoadImage;
end;

constructor TQuotePngBaseButton.Create(AOwner: TComponent);
begin
  inherited;
  FID := 0;
  FResourceName := '';
end;

destructor TQuotePngBaseButton.Destroy;
begin
  if Assigned(FImage) then
    FImage.Free;

  inherited;
end;

procedure TQuotePngBaseButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    if Assigned(FOnMouseLeftDown) then
      FOnMouseLeftDown(Self);
end;

procedure TQuotePngBaseButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    if Assigned(FOnMouseLeftUp) then
      FOnMouseLeftUp(Self);
end;

procedure TQuotePngBaseButton.Paint;
begin
  inherited;

  if Assigned(Image) then
    Canvas.Draw((Width - Image.Width) div 2, (Height - Image.Height) div 2, Image);
end;

procedure TQuotePngBaseButton.ReLoadImage;
begin
  if Assigned(FOnReLoadImage) then
    FOnReLoadImage(Self);
  Invalidate;
end;

procedure TQuotePngBaseButton.SetDown(const Value: Boolean);
begin
  if FDown <> Value then
  begin
    FDown := Value;
    ReLoadImage;
  end;
end;

procedure TQuotePngBaseButton.SetEnabled(Value: Boolean);
begin
  inherited;
  ReLoadImage;
end;

procedure TQuotePngBaseButton.SetResourceName(const Value: string);
begin
  if FResourceName <> Value then
  begin
    FResourceName := Value;
    if not Assigned(FImage) then
      FImage := TPngImage.Create;
  end;
end;

{ TQuoteOnlyPngButton }

procedure TQuoteOnlyPngButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FDown := False;
end;

{ TQuotePngButton }

constructor TQuotePngButton.Create(AOwner: TComponent);
begin
  inherited;
  FLineColor := $424442; // 边框线色
  FLineHotColor := $747674; // 激活边框线色
  FLineDownColor := $2A2C2B; // 按下状态边框颜色
  FTextColor := FLineColor; // 按钮字体
  FTextHotColor := FLineHotColor; // 激活字体色
  FTextDownColor := FLineDownColor; // 按下状态字体色
  FBackColor := $EBEEEB; // 背景色
  FBackHotColor := $F8F9F9; // 激活背景色
  FBackDownColor := $B9BCB9; // 按下状态背景颜色

  FParentBGColor := clNone; // 填充底色（在背景的下一层）
  FRoundHCount := 0; // 圆角矩形，横向圆弧点个数
  FRoundVCount := 0; // 圆角矩形，竖向圆弧点个数
end;

destructor TQuotePngButton.Destroy;
begin

  inherited;
end;

procedure TQuotePngButton.DrawButtonBorder;
begin
  with Canvas do
  begin
    RoundRect(ClientRect, RoundHCount, RoundVCount);
  end;
end;

procedure TQuotePngButton.DrawCaption;
begin

end;

procedure TQuotePngButton.DrawDownButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineDownColor;
    Brush.Color := FBackDownColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuotePngButton.DrawHotButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineHotColor;
    Brush.Color := FBackHotColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuotePngButton.DrawNormalButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineColor;
    Brush.Color := FBackColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuotePngButton.Paint;
begin
  with Canvas do
  begin
    if RoundHCount <> 0 then
    begin
      Pen.Color := FParentBGColor;
      Brush.Color := FParentBGColor;
      Brush.Style := bsSolid;
      Rectangle(ClientRect);
    end;

    if not Enabled then
      DrawNormalButton
    else if FDown then
      DrawDownButton
    else if MouseInClient then
    begin
      DrawHotButton
    end
    else
      DrawNormalButton;

    // DrawCaption;
  end;
  inherited;
end;

procedure TQuotePngButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  Perform(WM_LBUTTONDOWN, Message.Keys, Longint(Message.Pos));
end;

{ TQuoteTextButton }

procedure TQuoteTextButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TQuoteTextButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

constructor TQuoteTextButton.Create(AOwner: TComponent);
begin
  inherited;
  FID := 0;
  FDown := False;
end;

destructor TQuoteTextButton.Destroy;
begin

  inherited;
end;

procedure TQuoteTextButton.DrawButtonBorder;
begin
  with Canvas, FButtonsManager do
  begin
    RoundRect(ClientRect, RoundHCount, RoundVCount);
  end;
end;

procedure TQuoteTextButton.DrawCaption;
var
  tmpRect: TRect;
begin
  with Canvas, FButtonsManager do
  begin
    SelectObject(Handle, Self.Font.Handle);
    Brush.Style := bsClear;

    tmpRect := ClientRect;
    if not Enabled then
    begin
      OffsetRect(tmpRect, 1, 1);
      SetTextColor(Handle, ColorToRGB(FDisabledColor1));
      DrawText(Handle, PChar(Caption), Length(Caption), tmpRect, DT_EXPANDTABS or DT_CENTER or DT_VCENTER or
        DT_SINGLELINE);

      OffsetRect(tmpRect, -1, -1);
      SetTextColor(Handle, ColorToRGB(FDisabledColor2));
      DrawText(Handle, PChar(Caption), Length(Caption), tmpRect, DT_EXPANDTABS or DT_CENTER or DT_VCENTER or
        DT_SINGLELINE);
    end
    else
    begin
      if FDown then
      begin
        SetTextColor(Handle, TextDownColor); // 按钮字体
      end
      else
      begin
        if MouseInClient then
          SetTextColor(Handle, TextHotColor) // 激活字体色
        else
          SetTextColor(Handle, TextColor); // 按钮字体
      end;

      DrawText(Handle, PChar(Caption), Length(Caption), tmpRect,
        { DT_EXPANDTABS or } DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;
  end;
end;

procedure TQuoteTextButton.DrawDownButton;
begin
  with Canvas, FButtonsManager do
  begin
    Pen.Color := LineDownColor;
    Brush.Color := BackDownColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteTextButton.DrawHotButton;
begin
  with Canvas, FButtonsManager do
  begin
    Pen.Color := LineHotColor;
    Brush.Color := BackHotColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteTextButton.DrawNormalButton;
begin
  with Canvas, FButtonsManager do
  begin
    Pen.Color := LineColor;
    Brush.Color := BackColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteTextButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    if Assigned(FOnMouseLeftDown) then
      FOnMouseLeftDown(Self);
end;

procedure TQuoteTextButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    if Assigned(FOnMouseLeftUp) then
      FOnMouseLeftUp(Self);
end;

procedure TQuoteTextButton.Paint;
begin
  with Canvas, FButtonsManager do
  begin
    if RoundHCount <> 0 then
    begin
      Pen.Color := ParentBGColor;
      Brush.Color := ParentBGColor;
      Brush.Style := bsSolid;
      Rectangle(ClientRect);
    end;

    if not Enabled then
      DrawNormalButton
    else if FDown then
      DrawDownButton
    else if MouseInClient then
    begin
      DrawHotButton
    end
    else
      DrawNormalButton;

    DrawCaption;
  end;

  inherited;
end;

procedure TQuoteTextButton.SetDown(const Value: Boolean);
begin
  if FDown <> Value then
  begin
    FDown := Value;
    Invalidate;
  end;
end;

procedure TQuoteTextButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin

end;

{ TButtonsManager }

constructor TButtonsManager.Create(APngButtonClass: TPngButtonClass);
begin
  FPngButtonClass := APngButtonClass;
  FResourceInstance := 0;
  FBtnSize := 16;
  FDownSuffix := '';
  FHotSuffix := '';
end;

destructor TButtonsManager.Destroy;
var
  i: Integer;
begin
  for i := Low(FButtons) to High(FButtons) do
    FreeAndNil(FButtons[i]);
  SetLength(FButtons, 0);

  inherited;
end;

procedure TButtonsManager.SetButtonHints(AHints: array of string);
var
  i: Integer;
begin
  for i := Low(FButtons) to High(FButtons) do
    FButtons[i].Hint := AHints[i];
end;

procedure TButtonsManager.SettingBtnEnabled(AEnabled: Boolean);
begin
  if FResourceInstance <> 0 then
    FButtons[3].Enabled := AEnabled;
end;

procedure TButtonsManager.DoMouseLeftDown(Sender: TObject);
begin
  if Assigned(FOnMouseLeftDown) then
    FOnMouseLeftDown(Sender);
end;

procedure TButtonsManager.DoMouseLeftUp(Sender: TObject);
begin
  if Assigned(FOnMouseLeftUp) then
    FOnMouseLeftUp(Sender);
end;

procedure TButtonsManager.DoReLoadImage(Sender: TObject);
var
  tmpBtn: TQuotePngBaseButton;
begin
  tmpBtn := Sender as TQuotePngBaseButton;
  if not tmpBtn.Enabled then
    tmpBtn.ResourceName := FResourceNames[tmpBtn.ID] + Con_Disable_Suffix
  else if tmpBtn.Down then
    tmpBtn.ResourceName := FResourceNames[tmpBtn.ID] + DownSuffix
  else if tmpBtn.MouseInBtn then
    tmpBtn.ResourceName := FResourceNames[tmpBtn.ID] + HotSuffix
  else
    tmpBtn.ResourceName := FResourceNames[tmpBtn.ID];
  // 用ResourceName保存当前资源名的方式，可以防止皮肤更换后按钮的状态图片被改为一般状态
  tmpBtn.Image.LoadFromResourceName(FResourceInstance, tmpBtn.ResourceName);
end;

function TButtonsManager.GetButton(const AIndex: Integer): TQuotePngBaseButton;
begin
  if (Low(FButtons) <= AIndex) and (AIndex <= High(FButtons)) then
    Result := FButtons[AIndex]
  else
    Result := nil;
end;

procedure TButtonsManager.InitButton(AParentCtrl: TCustomControl; ABtnSize: Integer;
  AResourceNames: array of string; AClickEvent: array of TNotifyEvent);
var
  i: Integer;
  tmpBtn: TQuotePngBaseButton;
begin
  FBtnSize := ABtnSize;
  SetLength(FButtons, Length(AResourceNames));
  SetLength(FResourceNames, Length(AResourceNames));
  for i := Low(AResourceNames) to High(AResourceNames) do
  begin
    FResourceNames[i] := AResourceNames[i];
    tmpBtn := FPngButtonClass.Create(nil);
    tmpBtn.Parent := AParentCtrl;
    tmpBtn.Width := ABtnSize;
    tmpBtn.Height := ABtnSize;
    tmpBtn.ID := i;
    tmpBtn.Visible := True;
    tmpBtn.ShowHint := True;
    tmpBtn.ResourceName := FResourceNames[i];
    tmpBtn.OnReLoadImage := DoReLoadImage;
    tmpBtn.OnClick := AClickEvent[i];
    tmpBtn.OnMouseLeftDown := DoMouseLeftDown;
    tmpBtn.OnMouseLeftUp := DoMouseLeftUp;
    FButtons[i] := tmpBtn;
  end;
end;

procedure TButtonsManager.UpdateBtnImage(APngButton: TQuotePngBaseButton);
begin
  APngButton.Image.LoadFromResourceName(FResourceInstance, APngButton.ResourceName);
end;

procedure TButtonsManager.UpdateSkin(AResourceInstance: HInst; ABackColor: TColor);
var
  i: Integer;
  tmpBtn: TQuotePngBaseButton;
begin
  FResourceInstance := AResourceInstance;
  for i := Low(FButtons) to High(FButtons) do
  begin
    tmpBtn := FButtons[i];
    tmpBtn.Color := ABackColor;
    UpdateBtnImage(tmpBtn);
  end;
end;

{ TTextButtonsManager }

procedure TTextButtonsManager.CancelSSFormulaBtn(AFormulaID: Integer);
var
  tmpFormulaType: TFormulaType;
begin
   tmpFormulaType := TFormulaType(AFormulaID);
  if tmpFormulaType in [ftMA .. ftSAR] then
    FFormulaButtons[tmpFormulaType].Down := False;
end;

procedure TTextButtonsManager.ChangeMSFormulaBtn(AOLDFormulaID, AFormulaID: Integer);
var
  tmpIndex: Integer;
  tmpBtn: TQuoteTextButton;
begin
  if AOLDFormulaID < Ord(ftVOL) then
  begin
    tmpBtn := FFormulaButtons[TFormulaType(AFormulaID)];
    tmpBtn.Down := True;
    FMultiSelecteds.Add(tmpBtn);
  end
  else
  begin
    for tmpIndex := 0 to FMultiSelecteds.Count - 1 do
    begin
      if AOLDFormulaID = TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).ID then
      begin
        TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).Down := False;
        tmpBtn := FFormulaButtons[TFormulaType(AFormulaID)];
        tmpBtn.Down := True;
        FMultiSelecteds.Items[tmpIndex] := tmpBtn;
        Break;
      end;
    end;
  end;
end;

procedure TTextButtonsManager.ChangeSSFormulaBtn(AOLDFormulaID, AFormulaID: Integer);
begin
  if AOLDFormulaID >= Ord(ftMA) then
    FFormulaButtons[TFormulaType(AOLDFormulaID)].Down := False;
  FFormulaButtons[TFormulaType(AFormulaID)].Down := True;
end;

constructor TTextButtonsManager.Create;
begin
  FLineColor := $424442; // 边框线色
  FLineHotColor := $747674; // 激活边框线色
  FLineDownColor := $2A2C2B; // 按下状态边框颜色
  FTextColor := FLineColor; // 按钮字体
  FTextHotColor := FLineHotColor; // 激活字体色
  FTextDownColor := FLineDownColor; // 按下状态字体色
  FBackColor := $EBEEEB; // 背景色
  FBackHotColor := $F8F9F9; // 激活背景色
  FBackDownColor := $B9BCB9; // 按下状态背景颜色

  FParentBGColor := clNone; // 填充底色（在背景的下一层）
  FRoundHCount := 0; // 圆角矩形，横向圆弧点个数
  FRoundVCount := 0; // 圆角矩形，竖向圆弧点个数

  FMultiSelecteds := TList.Create;
end;

destructor TTextButtonsManager.Destroy;
var
  tmpFT: TFormulaType;
begin
  for tmpFT := Low(FFormulaButtons) to High(FFormulaButtons) do
    TQuoteTextButton(FFormulaButtons[tmpFT]).Free;

  FMultiSelecteds.Free;

  inherited;
end;

procedure TTextButtonsManager.DoMSButtonDown(Sender: TObject);
begin
  if Assigned(FOnMSButtonDown) then
    FOnMSButtonDown(Sender);
end;

procedure TTextButtonsManager.DoMSButtonUp(Sender: TObject; NewFormulaType: Integer);
begin
  if Assigned(FOnMSButtonUp) then
    FOnMSButtonUp(Sender, NewFormulaType);
end;

procedure TTextButtonsManager.DoMSMouseLeftDown(Sender: TObject);
begin

end;

procedure TTextButtonsManager.DoMSMouseLeftUp(Sender: TObject);
var
  tmpIndex: Integer;
  tmpTextBtn: TQuoteTextButton;
begin
  tmpTextBtn := TQuoteTextButton(Sender);
  tmpTextBtn.Down := not tmpTextBtn.Down;
  if tmpTextBtn.Down then
  begin
    if FMultiSelecteds.Count < Con_MultiSelectMaxSelCount then
    begin
      DoMSButtonDown(Sender);
      FMultiSelecteds.Add(tmpTextBtn);
    end
    else
    begin
      tmpIndex := FMultiSelecteds.Count - 1;
      TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).Down := False;
      DoMSButtonUp(TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]), tmpTextBtn.ID);
      FMultiSelecteds.Items[tmpIndex] := tmpTextBtn;
    end;
  end
  else
  begin
    for tmpIndex := 0 to FMultiSelecteds.Count - 1 do
    begin
      if tmpTextBtn.ID = TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).ID then
      begin
        FMultiSelecteds.Delete(tmpIndex);
        Break;
      end;
    end;
    DoMSButtonUp(Sender, -1);
  end;
end;

procedure TTextButtonsManager.DoSSButtonDown(Sender: TObject);
begin
  if Assigned(FOnSSButtonDown) then
    FOnSSButtonDown(Sender);
end;

procedure TTextButtonsManager.DoSSButtonUp(Sender: TObject);
begin
  if Assigned(FOnSSButtonUp) then
    FOnSSButtonUp(Sender);
end;

procedure TTextButtonsManager.DoSSMouseLeftDown(Sender: TObject);
begin

end;

procedure TTextButtonsManager.DoSSMouseLeftUp(Sender: TObject);
var
  tmpDownID: Integer;
  tmpFT: TFormulaType;
  tmpTextBtn: TQuoteTextButton;
begin
  tmpTextBtn := TQuoteTextButton(Sender);
  tmpDownID := tmpTextBtn.FID;
  tmpTextBtn.Down := not tmpTextBtn.Down;
  if tmpTextBtn.Down then
  begin
    for tmpFT := ftMA to ftSAR do
    begin
      tmpTextBtn := FFormulaButtons[tmpFT];
      if tmpTextBtn.Down and (tmpTextBtn.FID <> tmpDownID) then
      begin
        tmpTextBtn.Down := False;
        DoSSButtonUp(tmpTextBtn);
      end;
    end;
    DoSSButtonDown(Sender); // 这个要在DoSSButtonUp(tmpTextBtn);之后
  end
  else
    DoSSButtonUp(Sender);
end;

function TTextButtonsManager.GetFormulaButton(const AIndex: TFormulaType): TQuoteTextButton;
begin
  if (Low(FFormulaButtons) <= AIndex) and (AIndex <= High(FFormulaButtons)) then
    Result := FFormulaButtons[AIndex]
  else
    Result := nil;
end;

procedure TTextButtonsManager.InitButton(AParentCtrl: TCustomControl; ACaptions: TArrayFormulaNames);
var
  tmpFT: TFormulaType;
  tmpBtn: TQuoteTextButton;
begin
  for tmpFT := Low(FFormulaButtons) to High(FFormulaButtons) do
  begin
    tmpBtn := TQuoteTextButton.Create(AParentCtrl);
    tmpBtn.Parent := AParentCtrl;
    tmpBtn.ButtonsManager := Self;
    tmpBtn.Caption := ACaptions[tmpFT];
    tmpBtn.Color := BackColor;
    tmpBtn.ID := Ord(tmpFT);
    tmpBtn.Show;
    case tmpFT of
      ftVOL .. ftRSI:
        begin
          tmpBtn.OnMouseLeftDown := DoMSMouseLeftDown;
          tmpBtn.OnMouseLeftUp := DoMSMouseLeftUp;
        end;
      ftMA .. ftSAR:
        begin
          tmpBtn.OnMouseLeftDown := DoSSMouseLeftDown;
          tmpBtn.OnMouseLeftUp := DoSSMouseLeftUp;
        end;
    end;
    FFormulaButtons[tmpFT] := tmpBtn;
  end;
end;

procedure TTextButtonsManager.ResetBottomBtnState(AID: Integer);
var
  tmpIndex: Integer;
begin
  for tmpIndex := 0 to FMultiSelecteds.Count - 1 do
  begin
    if AID = TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).ID then
    begin
      TQuoteTextButton(FMultiSelecteds.Items[tmpIndex]).Down := False;
      FMultiSelecteds.Delete(tmpIndex);
      Break;
    end;
  end;
end;

procedure TTextButtonsManager.ReSizePosition(ABtnWidth, ABtnHeight: Integer; AButtonsRect: TRect);
var
  tmpPos: Integer;
  tmpFT: TFormulaType;
  tmpBtn: TQuoteTextButton;
begin
  tmpPos := AButtonsRect.Left + 1;
  for tmpFT := Low(FFormulaButtons) to High(FFormulaButtons) do
  begin
    tmpBtn := FFormulaButtons[tmpFT];
    tmpBtn.Left := tmpPos;
    tmpBtn.Top := AButtonsRect.Top + 1;
    tmpBtn.Width := ABtnWidth;
    tmpBtn.Height := ABtnHeight;
    Inc(tmpPos, ABtnWidth - 1);
  end;
end;

procedure TTextButtonsManager.UpdateSkin(AColors: array of TColor; AFont: TFont);
var
  tmpFT: TFormulaType;
  tmpBtn: TQuoteTextButton;
begin
  FBackColor := AColors[0];
  FBackHotColor := AColors[1];
  FBackDownColor := AColors[2];
  FLineColor := AColors[3];
  FLineHotColor := AColors[4];
  FLineDownColor := AColors[5];
  FTextColor := AColors[6];
  FTextHotColor := AColors[7];
  FTextDownColor := AColors[8];
  FDisabledColor1 := AColors[9];
  FDisabledColor2 := AColors[10];

  for tmpFT := Low(FFormulaButtons) to High(FFormulaButtons) do
  begin
    tmpBtn := FFormulaButtons[tmpFT];
    tmpBtn.Font.Assign(AFont);
    tmpBtn.Invalidate;
  end;
end;

{ TQuoteButton }

procedure TQuoteButton.CMMouseLeave(var Message: TMessage);
begin
  if FMouseLeftDown then
  begin
    if FMouseTest <> btNone then
    begin
      FMouseTest := btNone;
      Invalidate;
    end;
  end
  else
  begin

    if FMouseTest <> btNone then
    begin
      FMouseTest := btNone;
      FMouseClickTest := btNone;
      Invalidate;
    end;
  end;
  inherited;
end;

constructor TQuoteButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonType := btNormal;

  RoundXCount := 0;
  RoundYCount := 0;
  DoubleBuffered := True;
  ControlStyle := ControlStyle + [csCaptureMouse];
  FIncIconWidth := 4;
  BorderLine := [];

  Width := 80;
  Height := 18;
  Caption := Name;

  FLineColor := $00625B01;
  FLineHotColor := $00897E01;
  FLineDownColor := $00897E01;
  FLineSpecialColor := -1;

  FFontColor := clSilver;
  FFontHotColor := $000176F9;

  FBackColor := clBlack;
  FBackHotColor := clBlack;
  FBackDownColor := clBlack;

  FIconColor := $003FB2E6;
  FIconHotColor := $0094FAFD;
  ParentFont := False;
  ParentColor := False;

  FQuoteButtonDisplay:= TQuoteButtonDisplay.Create;

end;

destructor TQuoteButton.Destroy;
begin
  FreeAndNil(FQuoteButtonDisplay);
  inherited Destroy;
end;

procedure TQuoteButton.DrawButtonBorder;
begin
  with Canvas do
  begin
    RoundRect(ClientRect, RoundXCount, RoundYCount);
    if FLineSpecialColor <> -1 then
    begin
      Pen.Color := FLineSpecialColor;

      if blLeft in BorderLine then
      begin
        MoveTo(ClientRect.Left, ClientRect.Top);
        LineTo(ClientRect.Left, ClientRect.Bottom - 1);
      end;
      if blTop in BorderLine then
      begin
        MoveTo(ClientRect.Left, ClientRect.Top);
        LineTo(ClientRect.Right - 1, ClientRect.Top);
      end;
      if blRight in BorderLine then
      begin
        MoveTo(ClientRect.Right - 1, ClientRect.Top);
        LineTo(ClientRect.Right - 1, ClientRect.Bottom - 1);
      end;
      if blBottom in BorderLine then
      begin
        MoveTo(ClientRect.Left, ClientRect.Bottom - 1);
        LineTo(ClientRect.Right - 1, ClientRect.Bottom - 1);
      end;
    end;
  end;

end;

procedure TQuoteButton.DrawCaption;
var
  aRect: TRect;
begin
  with Canvas do
  begin
    // 字体
    SelectObject(Canvas.Handle, Self.Font.Handle);
    Brush.Style := bsClear;

    aRect := Rect(ClientRect.Left + FIncIconWidth + GetIconSize(FLeftIconStyle), ClientRect.Top,
      ClientRect.Right - FIncIconWidth - GetIconSize(FRightIconStyle), ClientRect.Bottom);
    if not Enabled then
    begin
      OffsetRect(aRect, 1, 1);
      SetTextColor(Canvas.Handle, ColorToRGB(clBtnHighlight));
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), aRect, DT_EXPANDTABS or DT_CENTER or DT_VCENTER or
        DT_SINGLELINE);

      OffsetRect(aRect, -1, -1);
      SetTextColor(Canvas.Handle, ColorToRGB(clBtnShadow));
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), aRect, DT_EXPANDTABS or DT_CENTER or DT_VCENTER or
        DT_SINGLELINE);
    end
    else
    begin
      if FDown then
      begin
        SetTextColor(Canvas.Handle, FFontDownColor); // 按钮字体
      end
      else if FMouseLeftDown then
      begin
        // OffsetRect(aRect, 1, 1);
        SetTextColor(Canvas.Handle, FFontColor); // 按钮字体
      end
      else
      begin
        if FMouseTest = btButton then
          SetTextColor(Canvas.Handle, FFontHotColor) // 激活字体色
        else
          SetTextColor(Canvas.Handle, FFontColor); // 按钮字体
      end;

      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), aRect,
        { DT_EXPANDTABS or } DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;

  end;
end;

procedure TQuoteButton.DrawDownButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineDownColor;
    Brush.Color := FBackDownColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteButton.DrawHotButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineHotColor;
    Brush.Color := FBackHotColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteButton.DrawIcon(IconStyle: TQuoteIconStyle; ButtonType: TQuoteButtonType; Left: Boolean);
var
  aTop, aWidth: Integer;
  aRect: TRect;
begin
  aWidth := GetIconSize(IconStyle);

  // 确定区域
  if Left then
  begin
    aRect := Rect(ClientRect.Left + FIncIconWidth, ClientRect.Top, ClientRect.Left + FIncIconWidth + aWidth,
      ClientRect.Bottom);
  end
  else
  begin
    aRect := Rect(ClientRect.Right - aWidth - FIncIconWidth, ClientRect.Top, ClientRect.Right - FIncIconWidth,
      ClientRect.Bottom);
  end;

  // 定义颜色
  if FMouseLeftDown then
  begin
    Canvas.Brush.Color := FIconColor;
    Canvas.Pen.Color := FIconColor;
  end
  else if (Left and (FMouseTest = btLeftIcon)) or (not Left and (FMouseTest = btRightIcon)) then
  begin
    Canvas.Brush.Color := FIconHotColor;
    Canvas.Pen.Color := FIconHotColor;
  end
  else
  begin
    Canvas.Brush.Color := FIconColor;
    Canvas.Pen.Color := FIconColor;
  end;

  case IconStyle of
    biPupupButton:
      begin
        Canvas.MoveTo(aRect.Left, aRect.Top);
        Canvas.LineTo(aRect.Left, aRect.Bottom);

        aTop := (Height - 5) div 2;
        aRect.Top := aRect.Top + aTop;

        Canvas.Polygon([Point(aRect.Left + FIncIconWidth, aRect.Top), Point(aRect.Left + FIncIconWidth + 10, aRect.Top),
          Point(aRect.Left + FIncIconWidth + 5, aRect.Top + 5), Point(aRect.Left + FIncIconWidth, aRect.Top)]);
      end;

    biLeftButton:
      begin
        aTop := (Height - 9) div 2;
        aRect.Top := aRect.Top + aTop;
        aRect.Left := aRect.Left + (aWidth - 10) div 2;

        Canvas.Brush.Color := FIconColor;
        Canvas.Pen.Color := FIconColor;
        Canvas.Polygon([Point(aRect.Left + 5, aRect.Top), Point(aRect.Left + 5 - 5, aRect.Top + 5),
          Point(aRect.Left + 5, aRect.Top + 10), Point(aRect.Left + 5, aRect.Top)]);
        Canvas.Brush.Color := FIconHotColor;
        Canvas.Pen.Color := FIconHotColor;
        Canvas.Polygon([Point(aRect.Left + 12, aRect.Top), Point(aRect.Left + 12 - 5, aRect.Top + 5),
          Point(aRect.Left + 12, aRect.Top + 10), Point(aRect.Left + 12, aRect.Top)]);
      end;

    biRightButton:
      begin
        aTop := (Height - 9) div 2;
        aRect.Top := aRect.Top + aTop;
        aRect.Left := aRect.Left + (aWidth - 11) div 2;
        Canvas.Brush.Color := FIconColor;
        Canvas.Pen.Color := FIconColor;
        Canvas.Polygon([Point(aRect.Left, aRect.Top), Point(aRect.Left + 5, aRect.Top + 5),
          Point(aRect.Left, aRect.Top + 10), Point(aRect.Left, aRect.Top)]);
        Canvas.Brush.Color := FIconHotColor;
        Canvas.Pen.Color := FIconHotColor;
        Canvas.Polygon([Point(aRect.Left + 6, aRect.Top), Point(aRect.Left + 6 + 5, aRect.Top + 5),
          Point(aRect.Left + 6, aRect.Top + 10), Point(aRect.Left + 6, aRect.Top)]);

      end;

    biCloseButton, biIncButton, biDecButton:
      begin

        // 画圆底
        Canvas.Brush.Style := bsSolid;

        aTop := (Height - aWidth) div 2;
        aRect.Top := aRect.Top + aTop;
        aRect.Bottom := aRect.Top + aWidth;

        Canvas.RoundRect(aRect, aWidth - 4, aWidth - 4);

        if IconStyle = biCloseButton then
        begin

          // 画叉叉
          Canvas.Pen.Style := psSolid;
          Canvas.Pen.Color := FBackColor;

          Canvas.MoveTo(aRect.Left + 2, aRect.Top + 2);
          Canvas.LineTo(aRect.Right - 2, aRect.Bottom - 2);

          Canvas.MoveTo(aRect.Right - 3, aRect.Top + 2);
          Canvas.LineTo(aRect.Left + 1, aRect.Bottom - 2);
        end
        else
        begin

          // 画加减
          Canvas.Pen.Style := psSolid;
          Canvas.Pen.Color := FBackColor;
          aTop := (aRect.Bottom - aRect.Top) div 2;
          Canvas.MoveTo(aRect.Left + 1, aRect.Top + aTop);
          Canvas.LineTo(aRect.Right - 1, aRect.Top + aTop);

          if IconStyle = biIncButton then
          begin // +

            aTop := (aRect.Right - aRect.Left) div 2;
            Canvas.MoveTo(aRect.Left + aTop, aRect.Top + 1);
            Canvas.LineTo(aRect.Left + aTop, aRect.Bottom - 1);
          end;
        end;
      end;
  end;
end;

procedure TQuoteButton.DrawNormalButton;
begin
  with Canvas do
  begin
    Pen.Color := FLineColor;
    Brush.Color := FBackColor;
    Brush.Style := bsSolid;
    DrawButtonBorder;
  end;
end;

procedure TQuoteButton.DrawTypeBtn(ButtonType: TQuoteButtonType);
// var
// vRect: TRect;
// vXInc,vYInc: ShortInt;
begin
  if ButtonType = btClose then
  begin
    Height := Width;
    // vRect := TRect.Create(0,0,Width,Height);
    // vXInc := RoundXCount div 2;
    // vYInc := RoundYCount div 2;

    // 画叉叉
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := FParentBKColor;

    Canvas.MoveTo(0, 0);
    Canvas.LineTo(Width, Height);

    Canvas.MoveTo(0, Height - 1);
    Canvas.LineTo(Width, -1);
  end;
end;

function TQuoteButton.GetHitTestInfoAt(P: TPoint): TQuoteButtonPos;
var
  LeftIconWidth, RightIconWidth: Integer;
begin
  Result := btNone;

  LeftIconWidth := GetIconSize(FLeftIconStyle);
  RightIconWidth := GetIconSize(FRightIconStyle);

  if PtInRect(Rect(ClientRect.Left + FIncIconWidth + LeftIconWidth, ClientRect.Top,
    ClientRect.Right - FIncIconWidth - RightIconWidth, ClientRect.Bottom), P) then
    Result := btButton
  else if PtInRect(Rect(ClientRect.Left, ClientRect.Top, ClientRect.Left + FIncIconWidth + LeftIconWidth,
    ClientRect.Bottom), P) then
    Result := btLeftIcon
  else if PtInRect(Rect(ClientRect.Right - FIncIconWidth - RightIconWidth, ClientRect.Top, ClientRect.Right,
    ClientRect.Bottom), P) then
    Result := btRightIcon;
end;

function TQuoteButton.GetIconSize(IconStyle: TQuoteIconStyle): Integer;
begin
  case IconStyle of
    biPupupButton:
      Result := 16;
    biCloseButton, biIncButton, biDecButton:
      Result := 9;
    biLeftButton:
      Result := 15;
    biRightButton:
      Result := 15;
  else
    Result := 0;
  end;
end;

procedure TQuoteButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FMouseLeftDown := ssLeft in Shift;
  if FMouseLeftDown then
  begin
    if (FMouseTest <> btNone) then
    begin
      FMouseClickTest := FMouseTest;
      Invalidate;
    end;
  end;
end;

procedure TQuoteButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FMouseLeftDown then
  begin
    Invalidate;

    if Assigned(FOnButtonClick) then
      FOnButtonClick(Self, FMouseTest);
    FMouseTest := btNone;
  end;
  FMouseLeftDown := ssLeft in Shift;
end;

procedure TQuoteButton.WMErase(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TQuoteButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  Perform(WM_LBUTTONDOWN, Message.Keys, Longint(Message.Pos));
end;

procedure TQuoteButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  QuoteButtonTest: TQuoteButtonPos;
begin
  inherited MouseMove(Shift, X, Y);

  QuoteButtonTest := GetHitTestInfoAt(Classes.Point(X, Y));
  if not FMouseLeftDown then
  begin
    if QuoteButtonTest <> FMouseTest then
    begin
      Invalidate;
      FMouseTest := QuoteButtonTest;
    end;
  end;
  if FMouseLeftDown then
  begin
    if QuoteButtonTest <> FMouseClickTest then
    begin
      if FMouseTest <> btNone then
      begin
        FMouseTest := btNone;
        Invalidate;
      end;
    end
    else if FMouseTest <> FMouseClickTest then
    begin
      FMouseTest := FMouseClickTest;
      Invalidate;
    end;
  end;
end;

procedure TQuoteButton.Paint;
begin
  with Canvas do
  begin
    if RoundXCount <> 0 then
    begin
      Pen.Color := FParentBKColor;
      Brush.Color := FParentBKColor;
      Brush.Style := bsSolid;
      Rectangle(ClientRect);
    end;

    // 鼠标在按钮区域内
    if not Enabled then
      DrawNormalButton
    else if FDown then
      DrawDownButton
    else if (FMouseTest <> btNone) then
    begin
      DrawHotButton
    end
    else
      DrawNormalButton;

    if FButtonType = btNormal then
    begin
      // 画text
      DrawCaption;

      DrawIcon(LeftIconStyle, btNormal, True);
      DrawIcon(RightIconStyle, btNormal, False);
    end
    else
    begin
      DrawTypeBtn(FButtonType);
    end;
  end;
end;

procedure TQuoteButton.SetDown(ADown: Boolean);
begin
  FDown := ADown;
  Invalidate;
end;

procedure TQuoteButton.UpdateSkin(AGilAppController: IGilAppController);
begin
  FQuoteButtonDisplay.UpdateSkin(AGilAppController);

  FLineColor := FQuoteButtonDisplay.ButtonLineColor;
  FLineHotColor :=  FQuoteButtonDisplay.ButtonLineHotColor;
  FLineDownColor := FQuoteButtonDisplay.ButtonLineDownColor;

  FFontColor := FQuoteButtonDisplay.ButtonFontColor;
  FFontHotColor := FQuoteButtonDisplay.ButtonFontHotColor;
  FFontDownColor := FQuoteButtonDisplay.ButtonFontDownColor;

  FBackColor := FQuoteButtonDisplay.ButtonBackColor;
  FBackHotColor := FQuoteButtonDisplay.ButtonBackHotColor;
  FBackDownColor := FQuoteButtonDisplay.ButtonBackDownColor;
  Invalidate;
end;

{ TQuoteImgButton }

constructor TQuoteImgButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 20;
  Height := 20;
  FIsLoadImg := False;
  FAutoWidth := False;

  FImage := ''; // 标准状态显示图片
  FHotImage := ''; // 激活状态显示图片
  FDownImage := ''; // 按下状态显示图片

  FImgBitMap := TBitmap.Create;
  FHotImgBitMap := TBitmap.Create;
  FDownImgBitMap := TBitmap.Create;
end;

destructor TQuoteImgButton.Destroy;
begin
  inherited;
end;

procedure TQuoteImgButton.DrawTransparentBmp(ADescCanvas: TCanvas; X, Y: Integer; ASourceBmp: TBitmap;
  clTransparent: TColor);
var
  bmpXOR, bmpAND, bmpINVAND, bmpTarget: TBitmap;
  oldcol: Longint;
begin
  bmpAND := TBitmap.Create;
  bmpINVAND := TBitmap.Create;
  bmpXOR := TBitmap.Create;
  bmpTarget := TBitmap.Create;
  try
    bmpAND.Width := ASourceBmp.Width;
    bmpAND.Height := ASourceBmp.Height;
    bmpAND.Monochrome := True;
    oldcol := SetBkColor(ASourceBmp.Canvas.Handle, ColorToRGB(clTransparent));
    BitBlt(bmpAND.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, ASourceBmp.Canvas.Handle, 0, 0, SRCCOPY);
    SetBkColor(ASourceBmp.Canvas.Handle, oldcol);

    bmpINVAND.Width := ASourceBmp.Width;
    bmpINVAND.Height := ASourceBmp.Height;
    bmpINVAND.Monochrome := True;
    BitBlt(bmpINVAND.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, bmpAND.Canvas.Handle, 0, 0, NOTSRCCOPY);

    bmpXOR.Width := ASourceBmp.Width;
    bmpXOR.Height := ASourceBmp.Height;
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, ASourceBmp.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(bmpXOR.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, bmpINVAND.Canvas.Handle, 0, 0, SRCAND);

    bmpTarget.Width := ASourceBmp.Width;
    bmpTarget.Height := ASourceBmp.Height;
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, ADescCanvas.Handle, X, Y, SRCCOPY);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, bmpAND.Canvas.Handle, 0, 0, SRCAND);
    BitBlt(bmpTarget.Canvas.Handle, 0, 0, ASourceBmp.Width, ASourceBmp.Height, bmpXOR.Canvas.Handle, 0, 0, SRCINVERT);
    BitBlt(ADescCanvas.Handle, X, Y, ASourceBmp.Width, ASourceBmp.Height, bmpTarget.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    bmpXOR.Free;
    bmpAND.Free;
    bmpINVAND.Free;
    bmpTarget.Free;
  end;
end;

procedure TQuoteImgButton.DrawDownButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FDownImgBitMap.Width, FDownImgBitMap.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgBitMap.Width / FImgBitMap.Height * Height);
  end;
  vDesRect := TRect.Create(0, 0, Width, Height);;

  if Canvas.HandleAllocated then
  begin
    // SetBkMode(Canvas.Handle, Windows.TRANSPARENT); // 背景透明
    Canvas.CopyMode := cmSrcCopy;
    Canvas.CopyRect(vDesRect, FDownImgBitMap.Canvas, vSourceRect);
  end;
end;

procedure TQuoteImgButton.DrawHotButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FHotImgBitMap.Width, FHotImgBitMap.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgBitMap.Width / FImgBitMap.Height * Height);
  end;
  vDesRect := TRect.Create(0, 0, Width, Height);;

  if Canvas.HandleAllocated then
  begin
    // SetBkMode(Canvas.Handle, Windows.TRANSPARENT); // 背景透明
    Canvas.CopyMode := cmSrcCopy;
    Canvas.CopyRect(vDesRect, FHotImgBitMap.Canvas, vSourceRect);
  end;
end;

procedure TQuoteImgButton.DrawNormalButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FImgBitMap.Width, FImgBitMap.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgBitMap.Width / FImgBitMap.Height * Height);
  end;

  vDesRect := TRect.Create(0, 0, Width, Height);;

  if Canvas.HandleAllocated then
  begin
    // SetBkMode(Canvas.Handle, Windows.TRANSPARENT); // 背景透明
    Canvas.CopyMode := cmSrcCopy;
    Canvas.CopyRect(vDesRect, FImgBitMap.Canvas, vSourceRect);
  end;
end;

procedure TQuoteImgButton.LoadImg;
begin
  if not FIsLoadImg then
  begin
    if FileExists(FImage) then
    begin
      FImgBitMap.LoadFromFile(FImage);

      if FileExists(FHotImage) then
      begin
        FHotImgBitMap.LoadFromFile(FHotImage);
      end
      else
      begin
        FHotImgBitMap.LoadFromFile(FImage);
      end;

      if FileExists(FDownImage) then
      begin
        FDownImgBitMap.LoadFromFile(FDownImage);
      end
      else
      begin
        FDownImgBitMap.LoadFromFile(FImage);
      end;

      FIsLoadImg := True;
    end;
  end;
end;

procedure TQuoteImgButton.Paint;
begin
  LoadImg;

  if FIsLoadImg then
  begin
    with Canvas do
    begin
      // 鼠标在按钮区域内
      if not Enabled then
        DrawNormalButton
      else if FDown then
        DrawDownButton
      else if (FMouseTest <> btNone) then
      begin
        DrawHotButton
      end
      else
        DrawNormalButton;
    end;
  end;
end;

procedure TQuoteImgButton.SetDownImage(APath: String);
begin
  FIsLoadImg := False;
  FDownImage := APath; // 按下状态显示图片
end;

procedure TQuoteImgButton.SetHotImage(APath: String);
begin
  FIsLoadImg := False;
  FHotImage := APath; // 激活状态显示图片
end;

procedure TQuoteImgButton.SetImage(APath: String);
begin
  FIsLoadImg := False;
  FImage := APath; // 标准状态显示图片
  if FHotImage = '' then
    FHotImage := APath; // 激活状态显示图片
  if FDownImage = '' then
    FDownImage := APath; // 按下状态显示图片
end;

// ------------------------------------------------------------------------------
{ TQuoteIconButton }

constructor TQuoteIconButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 20;
  Height := 20;
  FIsLoadImg := False;
  FAutoWidth := False;

  FImage := ''; // 标准状态显示图片
  FHotImage := ''; // 激活状态显示图片
  FDownImage := ''; // 按下状态显示图片

  FImgIcon := TIcon.Create;
  FHotImgIcon := TIcon.Create;
  FDownImgIcon := TIcon.Create;
end;

destructor TQuoteIconButton.Destroy;
begin
  inherited;
end;

procedure TQuoteIconButton.DrawDownButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FDownImgIcon.Width, FDownImgIcon.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgIcon.Width / FImgIcon.Height * Height);
  end;

  vDesRect := vSourceRect;
  gr32.OffsetRect(vDesRect, (Width - vSourceRect.Width) div 2, (Height - vSourceRect.Height) div 2);

  if Canvas.HandleAllocated then
  begin
    // SetBkColor(Canvas.Handle, ParentBKColor);
    Canvas.Brush.Color := ParentBKColor;
    Canvas.FillRect(ClientRect);
    Canvas.CopyMode := cmSrcCopy;
    Canvas.Draw(vDesRect.Left, vDesRect.Top, FDownImgIcon);
  end;
end;

procedure TQuoteIconButton.DrawHotButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FHotImgIcon.Width, FHotImgIcon.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgIcon.Width / FImgIcon.Height * Height);
  end;
  vDesRect := vSourceRect;
  gr32.OffsetRect(vDesRect, (Width - vSourceRect.Width) div 2, (Height - vSourceRect.Height) div 2);

  if Canvas.HandleAllocated then
  begin
    // SetBkColor(Canvas.Handle, ParentBKColor);
    Canvas.Brush.Color := ParentBKColor;
    Canvas.FillRect(ClientRect);
    Canvas.CopyMode := cmSrcCopy;
    Canvas.Draw(vDesRect.Left, vDesRect.Top, FHotImgIcon);
  end;
end;

procedure TQuoteIconButton.DrawNormalButton;
var
  vDesRect, vSourceRect: TRect;
begin
  vSourceRect := TRect.Create(0, 0, FImgIcon.Width, FImgIcon.Height);
  if FAutoWidth then
  begin
    Width := Trunc(FImgIcon.Width / FImgIcon.Height * Height);
  end;

  vDesRect := vSourceRect;
  gr32.OffsetRect(vDesRect, (Width - vSourceRect.Width) div 2, (Height - vSourceRect.Height) div 2);

  if Canvas.HandleAllocated then
  begin
    // SetBkColor(Canvas.Handle, Windows.TRANSPARENT); // 背景透明
    // SetBkColor(Canvas.Handle, ParentBKColor);
    Canvas.Brush.Color := ParentBKColor;
    Canvas.FillRect(ClientRect);
    Canvas.CopyMode := cmSrcCopy;
    Canvas.Draw(vDesRect.Left, vDesRect.Top, FImgIcon);
  end;
end;

procedure TQuoteIconButton.LoadImg;
begin
  if not FIsLoadImg then
  begin
    if FileExists(FImage) then
    begin
      FImgIcon.LoadFromFile(FImage);

      if FileExists(FHotImage) then
      begin
        FHotImgIcon.LoadFromFile(FHotImage);
      end
      else
      begin
        FHotImgIcon.LoadFromFile(FImage);
      end;

      if FileExists(FDownImage) then
      begin
        FDownImgIcon.LoadFromFile(FDownImage);
      end
      else
      begin
        FDownImgIcon.LoadFromFile(FImage);
      end;

      FIsLoadImg := True;
    end;
  end;
end;

procedure TQuoteIconButton.Paint;
begin
  LoadImg;

  if FIsLoadImg then
  begin
    with Canvas do
    begin
      // 鼠标在按钮区域内
      if not Enabled then
        DrawNormalButton
      else if FDown then
        DrawDownButton
      else if (FMouseTest <> btNone) then
      begin
        DrawHotButton
      end
      else
        DrawNormalButton;
    end;
  end;
end;

procedure TQuoteIconButton.SetDownImage(APath: String);
begin
  FIsLoadImg := False;
  FDownImage := APath; // 按下状态显示图片
end;

procedure TQuoteIconButton.SetHotImage(APath: String);
begin
  FIsLoadImg := False;
  FHotImage := APath; // 激活状态显示图片
end;

procedure TQuoteIconButton.SetImage(APath: String);
begin
  FIsLoadImg := False;
  FImage := APath; // 标准状态显示图片
  if FHotImage = '' then
    FHotImage := APath; // 激活状态显示图片
  if FDownImage = '' then
    FDownImage := APath; // 按下状态显示图片
end;

{ TQuoteAutoPngButton }

procedure TQuoteAutoPngButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TQuoteAutoPngButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
end;

constructor TQuoteAutoPngButton.Create(AOwner: TComponent);
begin
  inherited;
  IsAutoWidth := False;
  IsAutoHeight := False;
end;

procedure TQuoteAutoPngButton.UpdateSkin(AGilAppController: IGilAppController);
begin
  if Assigned(AGilAppController) then      
    Instance := AGilAppController.GetSkinInstance;
end;

procedure TQuoteAutoPngButton.ReLoadImage;
begin
  if Down then
  begin
    ResourceName := DownResourceName;
  end
  else if FMouseInBtn then
  begin
    ResourceName := HotResourceName;
  end
  else
  begin
    ResourceName := NormalResourceName;
  end;
  if IsAutoWidth then
    Self.Width := FImage.Width;
  if IsAutoHeight then
    Self.Height := FImage.Height;
  inherited ReLoadImage;
end;

procedure TQuoteAutoPngButton.SetBackColor(AColor: TColor);
begin
  Self.Color := AColor;
end;

procedure TQuoteAutoPngButton.SetInstance(AInstance: HInst);
begin
  if FInstance <> AInstance then
  begin
    FIsChangeInstance := True;
    FInstance := AInstance;
    ReLoadImage;
  end;
end;

procedure TQuoteAutoPngButton.SetResourceName(const Value: string);
begin
  if not Assigned(FImage) then
    FImage := TPngImage.Create;
  if FIsChangeInstance or (FResourceName <> Value) then
  begin
    FResourceName := Value;
    if FInstance > 0 then
    begin
      FIsChangeInstance := False;
      FImage.LoadFromResourceName(FInstance, FResourceName);
    end;
  end;
end;
//******************************************************************************

constructor TQuoteSelectedIconButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := RGB(255, 255, 255);
  FDoubleBuffered := True;
  OnMouseUp := DoBtnMouseUp;

  FInstance := 0;
  FCaption := '';
  FSelected := False;
  FIconName := '';
  FSelectedIconName := '';
  FBtnFont := TFont.Create;
  FIcon := TPngImage.Create;
  FSelectedIcon := TPngImage.Create;
  FImgRect := Rect(0,0,0,0);

  FLabel := TLabel.Create(nil);
  FLabel.Parent := Self;
  FLabel.Align := alCustom;
  FLabel.Height := 22;
  FLabel.Font.Charset := GB2312_CHARSET;
  FLabel.Font.Height := -11;
  FLabel.Font.Name := '微软雅黑';
end;

destructor TQuoteSelectedIconButton.Destroy;
begin
  if(Assigned(FBtnFont))then
    FreeAndNil(FBtnFont);
  if(Assigned(FLabel))then
    FreeAndNil(FLabel);
  if(Assigned(FIcon))then
    FreeAndNil(FIcon);
  if(Assigned(FSelectedIcon))then
    FreeAndNil(FSelectedIcon);
  inherited Destroy;
end;

procedure TQuoteSelectedIconButton.SetCaption(Value: string);
begin
  if(Value <> '')then
  begin
    FCaption := Value;
    FLabel.Caption := Value;
  end;
end;

procedure TQuoteSelectedIconButton.SetBackColor(Value: TColor);
begin
  FBackColor := Value;
  Color := FBackColor;
end;

procedure TQuoteSelectedIconButton.SetBtnFont(Value: TFont);
begin
  if(Assigned(Value))then
  begin
    FBtnFont.Assign(Value);
    FLabel.Font.Assign(Value);
  end;
end;

function TQuoteSelectedIconButton.GetFontColor: TColor;
begin
  Result := RGB(255, 255 ,255);
  if(Assigned(FLabel))then
    Result := FLabel.Font.Color;
end;

procedure TQuoteSelectedIconButton.SetFontColor(Value: TColor);
begin
  if(Assigned(FLabel))then
    FLabel.Font.Color := Value;
end;

procedure TQuoteSelectedIconButton.SetAutoSize(Value: Boolean);
var
  ASpace: Integer;
begin
  if(Value)then
  begin
    if (FSelected) then
      ASpace := FSelectedIcon.Width
    else
      ASpace := FIcon.Width;

    Width := ASpace + FLabel.Width + 3;

    if (FSelected) then
      ASpace := FSelectedIcon.Height
    else
      ASpace := FIcon.Height;

    Height := max(ASpace,FLabel.Height) + 4;
  end;
end;

procedure TQuoteSelectedIconButton.Paint;
var
  AIcon: TPngImage;
  AIconRect: TRect;
begin
  if(FSelected)then
    AIcon := FSelectedIcon
  else
    AIcon := FIcon;

  if(AIcon.Width > 0)and(AIcon.Height > 0)then
  begin
    if(AIcon.Height > Height)then
      AIconRect := Rect(0, 0, AIcon.Width, Height)
    else
      AIconRect := Rect(0, (Height - AIcon.Height)div 2, AIcon.Width, (Height + AIcon.Height)div 2);
    FImgRect := AIconRect;
    Canvas.Draw(AIconRect.Left, AIconRect.Top, AIcon);
  end;
end;

procedure TQuoteSelectedIconButton.InitImage;
begin
  if(FInstance <> 0)then
  begin
    try
      if (FIconName <> '') then
        FIcon.LoadFromResourceName(FInstance, FIconName);
      if (FSelectedIconName <> '') then
        FSelectedIcon.LoadFromResourceName(FInstance, FSelectedIconName);
    except

    end;
  end;
end;

procedure TQuoteSelectedIconButton.DoBtnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  APoint: TPoint;
begin
  APoint := Point(X, Y);
  if(PtInRect(FImgRect, APoint))then
  begin
    FSelected := not FSelected;
    ReDrawIcon;
    if(Assigned(FOnSelectedChange))then
      FOnSelectedChange(Self);
  end;
end;

procedure TQuoteSelectedIconButton.ConnectQuoteManager(const GilAppController: IGilAppController);
begin
   if(Assigned(GilAppController))then
   begin
     FGilAppController := GilAppController;
     FInstance := FGilAppController.GetSkinInstance;
     InitImage;
   end;
end;

procedure TQuoteSelectedIconButton.Disconnection;
begin
  if(FInstance <> 0)then
    FInstance := 0;
  if(Assigned(FGilAppController))then
    FGilAppController := nil;
end;

procedure TQuoteSelectedIconButton.UpdateSkin;
begin
  if(FSelected)then
  begin
    if(FSelectedIcon.Width > 0)then
      FLabel.Left := FSelectedIcon.Width
    else
      FLabel.Left := 0;
  end
  else
  begin
    if(FIcon.Width > 0)then
      FLabel.Left := FIcon.Width
    else
      FLabel.Left := 0;
  end;

  FLabel.Top := (Height - FLabel.Height)div 2;
  Invalidate;
end;

procedure TQuoteSelectedIconButton.ReDrawIcon;
var
  AIcon, APreIcon: TPngImage;
  AIconRect, APreIconRect: TRect;
begin
  if(FSelected)then
  begin
    AIcon := FSelectedIcon;
    APreIcon := FIcon;
  end
  else
  begin
    AIcon := FIcon;
    APreIcon := FSelectedIcon;
  end;

  if(AIcon.Width > 0)and(AIcon.Height > 0)then
  begin
    if(AIcon.Height > Height)then
      AIconRect := Rect(0, 0, AIcon.Width, Height)
    else
      AIconRect := Rect(0, (Height - AIcon.Height)div 2, AIcon.Width, (Height + AIcon.Height)div 2);

    if (APreIcon.Width > 0) and (APreIcon.Height > 0) then
    begin
      if (APreIcon.Height > Height) then
        APreIconRect := Rect(0, 0, APreIcon.Width, Height)
      else
        APreIconRect := Rect(0, (Height - APreIcon.Height) div 2, APreIcon.Width, (Height + APreIcon.Height) div 2);

      Canvas.Brush.Color := FBackColor;
      Canvas.FillRect(APreIconRect);
    end;
    FImgRect := AIconRect;
    Canvas.Draw(AIconRect.Left, AIconRect.Top, AIcon);
  end;
end;

procedure TQuoteSelectedIconButton.TransferCaption;
var
  AValue: string;
  ASpace, ALength: Integer;
begin
  if (FSelected) then
    ASpace := FSelectedIcon.Width
  else
    ASpace := FIcon.Width;

  AValue := FCaption;
  if (ASpace + FLabel.Canvas.TextWidth(AValue) > Width) then
  begin
    ASpace := ASpace + FLabel.Canvas.TextWidth('...');
    while (ASpace + FLabel.Canvas.TextWidth(AValue) > Width) do
    begin
      ALength := Length(AValue);
      AValue := LeftStr(AValue, ALength - 1);
    end;
    FLabel.Caption := AValue + '...';
  end
  else
    FLabel.Caption := AValue;
end;

end.
