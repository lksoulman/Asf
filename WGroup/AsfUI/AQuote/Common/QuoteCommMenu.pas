unit QuoteCommMenu;

interface

uses
  Windows,
  Classes,
  Messages,
  Controls,
  Graphics,
  ExtCtrls,
  SysUtils,
  Forms,
  Vcl.Imaging.pngimage,
  Generics.Collections,
  QuoteCommHint,
  CommonFunc,
  QuoteCommLibrary,
  BaseObject,
  AppContext,
  LogLevel;

const

  // 资源名称
  Const_ResourceName_RightMenu_CheckBox = 'RightMenu_CheckBox';
  Const_ResourceName_RightMenu_RadioBox = 'RightMenu_RadioBox';
  Const_ResourceName_RightMenu_AddStock = 'RightMenu_AddStock';
  Const_ResourceName_RightMenu_DelStock = 'RightMenu_DelStock';
  Const_ResourceName_RightMenu_MoveTop = 'RightMenu_MoveTop';
  Const_ResourceName_RightMenu_StockWarning = 'RightMenu_StockWarning';
  Const_ResourceName_RightMenu_SelfManager = 'RightMenu_SelfManager';

  // 日志输出前缀

  Const_Log_Output_Prefix = '[ RightMenu ]';

type

  // MenuItem的类型 (分割线，正常的)
  TMenuItemType = (mitLine, mitMenuItem);
  TMenuScrollType = (mstNone, mstUp, mstDw);
  TDrawIconType = (ditNone, ditCheckBox, ditRadioBox, ditText, ditImage);
  TDrawTriangleType = (dttRight, dttUp, dttDown);

  TDrawTextAlign = (dtaTopLeft, dtaTop, dtaTopRight, dtaLeft, dtaCenter,
    dtaRight, dtaBottomLeft, dtaBottom, dtaBottomRight);

  TGilPopMenu = class;
  TGilMenuWindow = class;

  TGilMenuItem = class
  private
    FItemIndex: Integer;
  protected
    FOwnMenuWindow: TGilMenuWindow;
    FSubMenuWindow: TGilMenuWindow;

    FRect: TRect;
    FID: Integer;
    FKey: string;
    FIsHint: Boolean;
    FEnable: Boolean;
    FCaption: string;
    FVisible: Boolean;
    FFocused: Boolean;
    FChecked: Boolean;
    FRadioed: Boolean;
    FIconText: string;
    FResourceName: string;
    FIsSubMenuItem: Boolean;
    FItemType: TMenuItemType;
    FIconType: TDrawIconType;
    FScrollType: TMenuScrollType;
    FData: TObject;
    FObjectRef: TObject;
    FOnClick: TNotifyEvent;

    procedure SetEnable(_Enable: Boolean);
    procedure SetCaption(_Caption: string);
    procedure SetVisible(_Visible: Boolean);
    procedure SetChecked(_Checked: Boolean);
    procedure SetRadioed(_Radioed: Boolean);
    procedure SetIconText(_IconText: string);
    procedure SetItemType(_ItemType: TMenuItemType);
    procedure SetIconType(_IconType: TDrawIconType);
    procedure SetResourceName(_ResourceName: string);
    procedure SetIsSubMenuItem(_IsSubMenuItem: Boolean);
  public
    constructor Create(_MenuType: TMenuItemType);
    destructor Destroy; override;

    property Rect: TRect read FRect write FRect;
    property ID: Integer read FID write FID;
    property Key: string read FKey write FKey;
    property Data: TObject read FData write FData;
    property IsHint: Boolean read FIsHint write FIsHint;
    property Enable: Boolean read FEnable write FEnable;
    property Caption: string read FCaption write SetCaption;
    property Visible: Boolean read FVisible write SetVisible;
    property Checked: Boolean read FChecked write SetChecked;
    property Radioed: Boolean read FRadioed write SetRadioed;
    property IconText: string read FIconText write SetIconText;
    property ObjectRef: TObject read FObjectRef write FObjectRef;
    property ItemType: TMenuItemType read FItemType write SetItemType;
    property IconType: TDrawIconType read FIconType write SetIconType;
    property ResourceName: string read FResourceName write SetResourceName;
    property IsSubMenuItem: Boolean read FIsSubMenuItem write SetIsSubMenuItem;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property SubMenu: TGilMenuWindow read FSubMenuWindow;
  end;

  TGilMenuDisplay = class(TBaseObject)
  public
    FSkinStyle: string;
    TextFont: TFont;
    DrawPng: TPngImage;

    BackColor: TColor; // 整体区域背景色
    IconRectBackColor: TColor; // 图标区域背景色
    FocusBackColor: TColor; // 光标聚焦菜单颜色
    UnEnableBackColor: TColor; // 不可用聚焦菜单颜色
    BorderLineColor: TColor; // 边框线颜
    TextFontColor: TColor; // 字体颜色
    IconTextFontColor: TColor; // 图标区域字体颜色
    UnEnableTextFontColor: TColor; // 不可用菜单字体颜色
    TriangleColor: TColor;
    DivideLineColor: TColor; // 分割线

    XSpace: Integer;
    MenuRound: Integer;
    MenuItemHeight: Integer;
    MenuItemLineHeight: Integer;
    ScrollHeight: Integer;
    IconRectWidth: Integer;
    SubRectWidth: Integer;
    MenuItemMaxTextWidth: Integer;

    constructor Create(AContext: IAppContext);
    destructor Destroy; override;

    function RefreshPng(_ResourceName: string): Boolean;
    procedure UpdateSkin;
  end;

  TGilMenuWindow = class(TForm)
  protected
    FPopMenu: TGilPopMenu;
    FParentWindow: TGilMenuWindow;
    FMenuItems: TList<TGilMenuItem>;
    FBitmap: TBitmap;
    FHideTimer: TTimer;
    FScrollTimer: TTimer;

    FOffset: Integer; // 总偏差
    FMinOffset: Integer; // 最小的偏差是 负值
    FMaxOffset: Integer; // 最大的偏差是 0;
    FScrollStep: Integer;
    FUpScrollOffset: Integer; // 和上面的滚动条的偏差
    FDwScrollOffset: Integer; // 和下面的滚动条的偏差
    FIsScroll: Boolean; // 是不是有滚动功能
    FIsSubMenuItem: Boolean;
    FMinIndex: Integer;
    FMaxIndex: Integer;
    FUpMenuItem: TGilMenuItem;
    FDwMenuItem: TGilMenuItem;
    FFocusMenuItem: TGilMenuItem; // 上次聚焦的
    FFocusScrollMenuItem: TGilMenuItem;

    procedure InitData;
    procedure InitEvent;

    procedure DoHideTimer(Sender: TObject);
    procedure DoScrollTimer(Sender: TObject);
    procedure DoClickUpMenuItem(Sender: TObject);
    procedure DoClickDwMenuItem(Sender: TObject);
    procedure CleanList(_List: TList<TGilMenuItem>);
    function GetMenuItem(_Index: Integer): TGilMenuItem;
    function GetMenuItemCount: Integer;
    procedure EraseRect(_Rect: TRect);

    function MouseInMenuWindow: Boolean;
    // 隐藏方法
    // 隐藏子菜单
    procedure HideAllMenuWindow;
    procedure HideSubMenuWindow(_SubMenuWindow: TGilMenuWindow);
    procedure HideParentMenuWindow(_ParentMenuWindow: TGilMenuWindow);
    procedure DoAllMenuWindowInvaildate;
    procedure DoMenuWindowInvaildate(_SubMenuWindow: TGilMenuWindow);

    // 计算MenuItem
    procedure CalcWH; overload;
    procedure CalcWH(var _Width, _Height: Integer;
      var _IsScroll, _IsSubMenuItem: Boolean); overload;
    procedure CalcMaxMinIndex; overload;
    procedure CalcMaxMinIndex(var _MinIndex, _MaxIndex, _UpScrollOffset,
      _DwScrollOffset, _MinOffset: Integer); overload;
    function CalcMenuItem(_Pt: TPoint; var _MenuItem: TGilMenuItem): Boolean;

    procedure DoCalcDrawItems;
    procedure Draw;
    procedure DrawBack;
    procedure DrawMenuItems;
    procedure DrawScrollItems;
    procedure DrawMenuItem(_Canvas: TCanvas; _MenuItem: TGilMenuItem;
      _BackColor, _IconRectBackColor, _FontColor, _IconFontColor,
      _SubColor: TColor);
    procedure DrawMenuItemLine(_Canvas: TCanvas; _MenuItem: TGilMenuItem;
      _LineColor: TColor);
    procedure DrawMenuItemIcon(_Canvas: TCanvas; _Rect: TRect;
      _MenuItem: TGilMenuItem; _BackColor, _FontColor: TColor);
    procedure DrawMenuItemText(_Canvas: TCanvas; _Rect: TRect;
      _MenuItem: TGilMenuItem; _BackColor, _FontColor: TColor);
    procedure DrawMenuItemSubFlag(_Canvas: TCanvas; _Rect: TRect;
      _TriangleType: TDrawTriangleType; _Color: TColor);
    procedure DrawFocusMenuItem(_Canvas: TCanvas; _MenuItem: TGilMenuItem;
      _BackColor, _IconRectBackColor, _FontColor, _IconFontColor,
      _SubColor: TColor);

    procedure CreateParams(var params: TCreateParams); override;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Resize; override;
    procedure Paint; override;
  public
    constructor CreateNew(AOwner: TComponent; _PopMenu: TGilPopMenu);
      reintroduce;
    destructor Destroy; override;
    function AddMenuItem(_Name: string; _Key: string): TGilMenuItem; overload;
    function AddMenuItem(_MenuItem: TGilMenuItem): TGilMenuItem; overload;
    procedure PopMenu(_Pt: TPoint);
    procedure ClearMenus;

    property MenuItems[_Index: Integer]: TGilMenuItem read GetMenuItem;
    property MenuItemCount: Integer read GetMenuItemCount;
  end;

  TGilPopMenu = class(TBaseInterfacedObject)
  protected
//    FGilAppController: IGilAppController;
    FDisplay: TGilMenuDisplay;
    FMenuWindow: TGilMenuWindow;
    FHint: THintControl;
    FOwner: TComponent;

    function GetMenuItem(_Index: Integer): TGilMenuItem;
    function GetMenuItemCount: Integer;
    function GetMenuItemHeight: Integer;
  public
    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;

    function AddMenuItem(_Name: string; _Key: string): TGilMenuItem; overload;
    function AddMenuItem(_MenuItem: TGilMenuItem): TGilMenuItem; overload;
    procedure PopMenu(_Pt: TPoint); virtual;
    procedure HideAllMenus;
    procedure ClearMenus;
    procedure UpdateSkin; virtual;

    property MenuItems[_Index: Integer]: TGilMenuItem read GetMenuItem;
    property MenuItemCount: Integer read GetMenuItemCount;
    property MenuWindow: TGilMenuWindow read FMenuWindow;
    property MenuItemHeight: Integer read GetMenuItemHeight;
  end;

procedure DrawTextOutEx(DC: HDC; R: TRect; const Text: string;
  Align: TDrawTextAlign; AEllipsis: Boolean = False);

implementation

procedure DrawTextOutEx(DC: HDC; R: TRect; const Text: string;
  Align: TDrawTextAlign; AEllipsis: Boolean);
var
  tmpFormat: Cardinal;
begin
  case Align of
    dtaTopLeft:
      tmpFormat := DT_TOP + DT_LEFT + DT_SINGLELINE;
    dtaTop:
      tmpFormat := DT_TOP + DT_CENTER + DT_SINGLELINE;
    dtaTopRight:
      tmpFormat := DT_TOP + DT_RIGHT + DT_SINGLELINE;
    dtaLeft:
      tmpFormat := DT_LEFT + DT_VCENTER + DT_SINGLELINE;
    dtaCenter:
      tmpFormat := DT_CENTER + DT_VCENTER + DT_SINGLELINE;
    dtaRight:
      tmpFormat := DT_RIGHT + DT_VCENTER + DT_SINGLELINE;
    dtaBottomLeft:
      tmpFormat := DT_BOTTOM + DT_LEFT + DT_SINGLELINE;
    dtaBottom:
      tmpFormat := DT_BOTTOM + DT_CENTER + DT_SINGLELINE;
    dtaBottomRight:
      tmpFormat := DT_BOTTOM + DT_RIGHT + DT_SINGLELINE;
  else
    tmpFormat := 0;
  end;
  if AEllipsis then
    tmpFormat := tmpFormat + DT_END_ELLIPSIS;
  DrawText(DC, PChar(Text), Length(Text), R, tmpFormat + DT_NOPREFIX);
end;

{ TGilMeunDisplay }

constructor TGilMenuDisplay.Create(AContext: IAppContext);
begin
  inherited;
  FAppContext := AContext;
  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -13;

  DrawPng := TPngImage.Create;

  BackColor := $FAFAFA;
  IconRectBackColor := $EDEDED;
  FocusBackColor := $DCECF9;
  UnEnableBackColor := $FAFAFA;
  BorderLineColor := $969696;
  TextFontColor := $404040;
  IconTextFontColor := $505050;
  UnEnableTextFontColor := $AFAFAF;
  TriangleColor := $141414;
  DivideLineColor := $D2D2D2;

  // BackColor := $242424;
  // IconRectBackColor := $383838;
  // FocusBackColor := $595959;
  // UnEnableBackColor := $1F1F1F;
  // BorderLineColor := $121212;
  // TextFontColor := $AAAAAA;
  // IconTextFontColor := $DCDCDC;
  // UnEnableTextFontColor := $5A5A5A;
  // TriangleColor := $646464;
  // DivideLineColor := $808080;

  XSpace := 10;
  MenuRound := 4;
  MenuItemHeight := 30;
  MenuItemLineHeight := 5;
  ScrollHeight := MenuItemHeight;
  IconRectWidth := 26;
  SubRectWidth := 20;
  MenuItemMaxTextWidth := 250;
end;

destructor TGilMenuDisplay.Destroy;
begin
  if Assigned(DrawPng) then
    DrawPng.Free;
  if Assigned(TextFont) then
    TextFont.Free;
  FAppContext := nil;
  inherited;
end;

function TGilMenuDisplay.RefreshPng(_ResourceName: string): Boolean;
begin
  Result := False;
  try
    if Assigned(FAppContext) and (_ResourceName <> '') then
    begin
      DrawPng.LoadFromResourceName(FAppContext.GetResourceSkin.GetInstance,
        _ResourceName);
      Result := True;
    end;
  except
    on Ex: Exception do
    begin
      if Assigned(FAppContext) then begin
        FAppContext.SysLog(llError, Const_Log_Output_Prefix +
          '没有资源' + _ResourceName);
      end
    end;
  end;
end;

procedure TGilMenuDisplay.UpdateSkin;
const
  Const_RightMenu_Prefix = 'RightMenu_';
var
  tmpSkinStyle: string;
  function GetStrFromConfig(_Key: WideString): string;
  begin
    Result := FAppContext.GetResourceSkin.GetConfig(Const_RightMenu_Prefix + _Key);
//    Result := FGilAppController.Config(ctSkin, Const_RightMenu_Prefix + _Key);
  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_RightMenu_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_RightMenu_Prefix + _Key), 0));
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;
      TextFont.Name := GetStrFromConfig('TextFontName');
      BackColor := GetColorFromConfig('BackColor');
      IconRectBackColor := GetColorFromConfig('IconRectBackColor');
      FocusBackColor := GetColorFromConfig('FocusBackColor');
      UnEnableBackColor := GetColorFromConfig('UnEnableBackColor');
      BorderLineColor := GetColorFromConfig('BorderLineColor');
      TextFontColor := GetColorFromConfig('TextFontColor');
      IconTextFontColor := GetColorFromConfig('IconTextFontColor');
      UnEnableTextFontColor := GetColorFromConfig('UnEnableTextFontColor');
      TriangleColor := GetColorFromConfig('TriangleColor');
      DivideLineColor := GetColorFromConfig('DivideLineColor');
    end;

    if FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FFontRatio = Const_ScreenResolution_1080P then
    begin
      TextFont.Height := -14;
    end
    else if FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FFontRatio = Const_ScreenResolution_768P then
    begin
      TextFont.Height := -12;
    end;
//  end;
end;

{ TGilMenuItem }

constructor TGilMenuItem.Create(_MenuType: TMenuItemType);
begin
  FKey := '';
  FCaption := '';
  FIsHint := False;
  FEnable := True;
  FVisible := True;
  FFocused := False;
  FChecked := False;
  FRadioed := False;
  FIconText := '';
  FResourceName := '';
  FIconType := ditNone;
  FItemType := _MenuType;
  FScrollType := mstNone;
  FIsSubMenuItem := False;
end;

destructor TGilMenuItem.Destroy;
begin
  if Assigned(FSubMenuWindow) then
    FreeAndNil(FSubMenuWindow);
  inherited;
end;

procedure TGilMenuItem.SetEnable(_Enable: Boolean);
begin
  if FEnable <> _Enable then
  begin
    FEnable := _Enable;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetCaption(_Caption: string);
begin
  FCaption := _Caption;
  if Assigned(FOwnMenuWindow) then
    FOwnMenuWindow.DoCalcDrawItems;
end;

procedure TGilMenuItem.SetVisible(_Visible: Boolean);
begin
  if FVisible <> _Visible then
  begin
    FVisible := _Visible;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetChecked(_Checked: Boolean);
begin
  if FChecked <> _Checked then
  begin
    FChecked := _Checked;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetRadioed(_Radioed: Boolean);
var
  tmpIndex: Integer;
  tmpMenuItem: TGilMenuItem;
begin
  if (FRadioed <> _Radioed) and Assigned(FOwnMenuWindow) then
  begin
    for tmpIndex := 0 to FOwnMenuWindow.FMenuItems.Count - 1 do
    begin
      tmpMenuItem := FOwnMenuWindow.FMenuItems.Items[tmpIndex];
      if Assigned(tmpMenuItem) then
        tmpMenuItem.FRadioed := False;
    end;
    FRadioed := _Radioed;
    if FOwnMenuWindow.Showing then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetIconText(_IconText: string);
begin
  FIconText := _IconText;
  if Assigned(FOwnMenuWindow) then
    FOwnMenuWindow.DoCalcDrawItems;
end;

procedure TGilMenuItem.SetIconType(_IconType: TDrawIconType);
begin
  if FIconType <> _IconType then
  begin
    FIconType := _IconType;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetItemType(_ItemType: TMenuItemType);
begin
  if FItemType <> _ItemType then
  begin
    FItemType := _ItemType;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetResourceName(_ResourceName: string);
begin
  if FResourceName <> _ResourceName then
  begin
    FResourceName := _ResourceName;
    if Assigned(FOwnMenuWindow) then
      FOwnMenuWindow.DoCalcDrawItems;
  end;
end;

procedure TGilMenuItem.SetIsSubMenuItem(_IsSubMenuItem: Boolean);
begin
  if FIsSubMenuItem <> _IsSubMenuItem then
  begin
    FIsSubMenuItem := _IsSubMenuItem;
    if FIsSubMenuItem then
    begin
      if not Assigned(FSubMenuWindow) and Assigned(FOwnMenuWindow.FPopMenu) then
      begin
        FSubMenuWindow := TGilMenuWindow.CreateNew
          (FOwnMenuWindow.FPopMenu.FOwner, FOwnMenuWindow.FPopMenu);
        FSubMenuWindow.FParentWindow := FOwnMenuWindow;
      end;
    end
    else
    begin
      if Assigned(FSubMenuWindow) then
        FreeAndNil(FSubMenuWindow);
    end;
  end;
end;

{ TGilMenuWindow }

constructor TGilMenuWindow.CreateNew(AOwner: TComponent; _PopMenu: TGilPopMenu);
begin
  inherited CreateNew(AOwner);
  FPopMenu := _PopMenu;
  FMenuItems := TList<TGilMenuItem>.Create;
  FBitmap := TBitmap.Create;
  FHideTimer := TTimer.Create(nil);
  FScrollTimer := TTimer.Create(nil);
  InitData;
  InitEvent;
end;

destructor TGilMenuWindow.Destroy;
begin
  if Assigned(FUpMenuItem) then
    FreeAndNil(FUpMenuItem);
  if Assigned(FDwMenuItem) then
    FreeAndNil(FDwMenuItem);
  if Assigned(FScrollTimer) then
  begin
    FScrollTimer.Enabled := False;
    FScrollTimer.Free;
  end;
  if Assigned(FHideTimer) then
  begin
    FHideTimer.Enabled := False;
    FHideTimer.Free;
  end;
  if Assigned(FBitmap) then
    FBitmap.Free;
  if Assigned(FMenuItems) then
  begin
    CleanList(FMenuItems);
    FMenuItems.Free;
  end;
  inherited;
end;

procedure TGilMenuWindow.InitData;
begin
  Visible := False;
  Ctl3D := True;
  AutoScroll := False;
  BorderStyle := bsNone;
  BorderWidth := 0;
  BorderIcons := [];
  Position := poDesigned;

  FHideTimer.Enabled := False;
  FHideTimer.Interval := 50;

  FScrollTimer.Enabled := False;
  FScrollTimer.Interval := 200;

  FOffset := 0;
  FMinOffset := 0;
  FMaxOffset := 0;
  FScrollStep := 20;
  FUpScrollOffset := 0;
  FDwScrollOffset := 0;
  FIsScroll := False;
  FIsSubMenuItem := False;
  FMinIndex := 0;
  FMaxIndex := -1;

  FBitmap.Canvas.Font.Assign(FPopMenu.FDisplay.TextFont);
  Canvas.Font.Assign(FPopMenu.FDisplay.TextFont);
end;

procedure TGilMenuWindow.InitEvent;
begin
  FHideTimer.OnTimer := DoHideTimer;
  FScrollTimer.OnTimer := DoScrollTimer;
end;

procedure TGilMenuWindow.DoHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  HideAllMenuWindow;
end;

procedure TGilMenuWindow.DoAllMenuWindowInvaildate;
begin
  DoMenuWindowInvaildate(Self);
end;

procedure TGilMenuWindow.DoMenuWindowInvaildate(_SubMenuWindow: TGilMenuWindow);
begin
  if Assigned(_SubMenuWindow) and _SubMenuWindow.Showing then
  begin
    DoCalcDrawItems;
    if Assigned(FFocusMenuItem) and FFocusMenuItem.IsSubMenuItem then
      DoMenuWindowInvaildate(FFocusMenuItem.SubMenu);
  end;
end;

procedure TGilMenuWindow.DoScrollTimer(Sender: TObject);
var
  tmpIsDraw: Boolean;
begin
  with FPopMenu.FDisplay do
  begin
    if Assigned(FFocusScrollMenuItem) then
    begin
      tmpIsDraw := False;
      case FFocusScrollMenuItem.FScrollType of
        mstUp:
          begin
            if (FOffset + FScrollStep) <= FMaxOffset then
            begin
              FOffset := FOffset + FScrollStep;
              tmpIsDraw := True;
            end
            else
            begin
              if FOffset <> FMaxOffset then
                tmpIsDraw := True;
              FOffset := FMaxOffset;
            end;
          end;
        mstDw:
          begin
            if (FOffset - FScrollStep) >= FMinOffset then
            begin
              FOffset := FOffset - FScrollStep;
              tmpIsDraw := True;
            end
            else
            begin
              if FOffset <> FMinOffset then
                tmpIsDraw := True;
              FOffset := FMinOffset;
            end;
          end;
      end;
      if tmpIsDraw then
      begin
        DoCalcDrawItems;
        if Assigned(FFocusMenuItem) then
        begin
          if FFocusMenuItem.IsSubMenuItem then
            HideSubMenuWindow(FFocusMenuItem.SubMenu);
          if (FFocusMenuItem.FItemIndex <= FMaxIndex) and
            (FFocusMenuItem.FItemIndex >= FMinIndex) then
          begin
            if FFocusMenuItem.Enable then
              DrawFocusMenuItem(Self.Canvas, FFocusMenuItem, FocusBackColor,
                FocusBackColor, TextFontColor, IconTextFontColor, TriangleColor)
            else
              DrawFocusMenuItem(Self.Canvas, FFocusMenuItem, FocusBackColor,
                FocusBackColor, UnEnableTextFontColor, IconTextFontColor,
                TriangleColor);
          end;
        end;
      end;
    end;
  end;
end;

procedure TGilMenuWindow.DoClickUpMenuItem(Sender: TObject);
begin

end;

procedure TGilMenuWindow.DoClickDwMenuItem(Sender: TObject);
begin

end;

procedure TGilMenuWindow.CleanList(_List: TList<TGilMenuItem>);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to FMenuItems.Count - 1 do
    begin
      if Assigned(FMenuItems.Items[tmpIndex]) then
        TObject(FMenuItems.Items[tmpIndex]).Free;
    end;
    FMenuItems.Clear;
  end;
end;

function TGilMenuWindow.GetMenuItem(_Index: Integer): TGilMenuItem;
begin
  Result := nil;
  if (_Index >= 0) and (_Index < FMenuItems.Count) then
    Result := FMenuItems.Items[_Index];
end;

function TGilMenuWindow.GetMenuItemCount: Integer;
begin
  Result := 0;
  if Assigned(FMenuItems) then
    Result := FMenuItems.Count;
end;

procedure TGilMenuWindow.EraseRect(_Rect: TRect);
begin
  Canvas.CopyRect(_Rect, FBitmap.Canvas, _Rect);
end;

procedure TGilMenuWindow.HideAllMenuWindow;
begin
  if Assigned(FFocusMenuItem) then
  begin
    HideSubMenuWindow(FFocusMenuItem.SubMenu);
    if Assigned(FFocusMenuItem) then
      FFocusMenuItem.FFocused := False;
    FFocusMenuItem := nil;
  end;
  if Self.Showing then
    Self.Hide;
  HideParentMenuWindow(FParentWindow);
end;

procedure TGilMenuWindow.HideSubMenuWindow(_SubMenuWindow: TGilMenuWindow);
begin
  if Assigned(_SubMenuWindow) and _SubMenuWindow.Showing then
  begin
    if Assigned(_SubMenuWindow.FFocusMenuItem) and
      (_SubMenuWindow.FFocusMenuItem.IsSubMenuItem) then
      HideSubMenuWindow(_SubMenuWindow.FFocusMenuItem.SubMenu);
    _SubMenuWindow.Hide;
    if Assigned(_SubMenuWindow.FFocusMenuItem) then
      _SubMenuWindow.FFocusMenuItem.FFocused := False;
    _SubMenuWindow.FFocusMenuItem := nil;
  end;
end;

procedure TGilMenuWindow.HideParentMenuWindow(_ParentMenuWindow
  : TGilMenuWindow);
begin
  if Assigned(_ParentMenuWindow) and _ParentMenuWindow.Showing then
  begin
    _ParentMenuWindow.Hide;
    HideParentMenuWindow(_ParentMenuWindow.FParentWindow);
    if Assigned(_ParentMenuWindow.FFocusMenuItem) then
      _ParentMenuWindow.FFocusMenuItem.FFocused := False;
    _ParentMenuWindow.FFocusMenuItem := nil;
  end;
end;

procedure TGilMenuWindow.CalcWH;
var
  tmpWidth, tmpHeight: Integer;
begin
  with FPopMenu.FDisplay do
  begin
    CalcWH(tmpWidth, tmpHeight, FIsScroll, FIsSubMenuItem);
    if tmpWidth <> Width then
      Width := tmpWidth;
    if tmpHeight <> Height then
      Height := tmpHeight;
    if FIsScroll then
    begin
      if not Assigned(FUpMenuItem) then
      begin
        FUpMenuItem := TGilMenuItem.Create(mitMenuItem);
        FUpMenuItem.OnClick := DoClickUpMenuItem;
        FUpMenuItem.FScrollType := mstUp;
      end;
      if not Assigned(FDwMenuItem) then
      begin
        FDwMenuItem := TGilMenuItem.Create(mitMenuItem);
        FDwMenuItem.OnClick := DoClickDwMenuItem;
        FDwMenuItem.FScrollType := mstDw;
      end;
    end;
  end;
end;

procedure TGilMenuWindow.CalcWH(var _Width, _Height: Integer;
  var _IsScroll, _IsSubMenuItem: Boolean);
var
  tmpMonitor: TMonitor;
  tmpMenuItem: TGilMenuItem;
  tmpIndex, tmpCount, tmpLineCount, tmpWidth: Integer;
begin
  with FBitmap, FPopMenu.FDisplay do
  begin
    _Width := 0;
    _Height := 0;
    _IsScroll := False;
    tmpCount := 0;
    tmpLineCount := 0;
    _IsSubMenuItem := False;
    for tmpIndex := 0 to FMenuItems.Count - 1 do
    begin
      tmpMenuItem := FMenuItems.Items[tmpIndex];
      if Assigned(tmpMenuItem) and tmpMenuItem.Visible then
      begin
        tmpWidth := Canvas.TextWidth(tmpMenuItem.Caption);
        if (tmpWidth > _Width) then
        begin
          if tmpWidth < MenuItemMaxTextWidth then
            _Width := tmpWidth
          else
            _Width := MenuItemMaxTextWidth;
        end;

        case tmpMenuItem.ItemType of
          mitMenuItem:
            Inc(tmpCount);
          mitLine:
            Inc(tmpLineCount);
        end;

        if (not _IsSubMenuItem) and tmpMenuItem.IsSubMenuItem then
          _IsSubMenuItem := True;
      end;
    end;

    _Width := _Width + IconRectWidth + XSpace * 2;
    if _IsSubMenuItem then
      _Width := _Width + SubRectWidth - XSpace;

    _Height := tmpCount * MenuItemHeight + tmpLineCount * MenuItemLineHeight;
    tmpMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
    if tmpMonitor <> nil then
    begin
      if _Height > tmpMonitor.WorkareaRect.Height then
      begin
        _IsScroll := True;
        _Height := tmpMonitor.WorkareaRect.Height;
      end;
    end;
  end;
end;

procedure TGilMenuWindow.CalcMaxMinIndex;
begin
  CalcMaxMinIndex(FMinIndex, FMaxIndex, FUpScrollOffset, FDwScrollOffset,
    FMinOffset);
end;

procedure TGilMenuWindow.CalcMaxMinIndex(var _MinIndex, _MaxIndex,
  _UpScrollOffset, _DwScrollOffset, _MinOffset: Integer);
var
  tmpMenuItem: TGilMenuItem;
  tmpIsMinFirst, tmpIsMaxFirst: Boolean;
  tmpIndex, tmpHeight, tmpMenuItemHeight, tmpDrawMenuHeight,
    tmpTotalHeight: Integer;
begin
  with FPopMenu.FDisplay do
  begin
    tmpHeight := 0;
    _MinIndex := 0;
    _MaxIndex := FMenuItems.Count - 1;
    _UpScrollOffset := 0;
    _DwScrollOffset := 0;
    _MinOffset := 0;
    tmpIsMinFirst := True;
    tmpIsMaxFirst := True;
    if FIsScroll then
    begin
      tmpTotalHeight := Height - ScrollHeight * 2;
      for tmpIndex := 0 to FMenuItems.Count - 1 do
      begin
        tmpMenuItem := FMenuItems.Items[tmpIndex];
        if Assigned(tmpMenuItem) and tmpMenuItem.Visible then
        begin
          case tmpMenuItem.ItemType of
            mitMenuItem:
              tmpMenuItemHeight := MenuItemHeight;
          else
            tmpMenuItemHeight := MenuItemLineHeight;
          end;
          tmpHeight := tmpHeight + tmpMenuItemHeight;
          tmpDrawMenuHeight := tmpHeight + FOffset;
          if tmpIsMinFirst and (tmpDrawMenuHeight > 0) then
          begin
            tmpIsMinFirst := False;
            _MinIndex := tmpIndex;
            _UpScrollOffset := tmpMenuItemHeight - tmpDrawMenuHeight;
          end;
          if tmpIsMaxFirst and (tmpDrawMenuHeight >= tmpTotalHeight) then
          begin
            tmpIsMaxFirst := False;
            _MaxIndex := tmpIndex;
            _DwScrollOffset := tmpDrawMenuHeight - tmpTotalHeight;
          end;
        end;
      end;
      _MinOffset := tmpTotalHeight - tmpHeight;
    end;
  end;
end;

function TGilMenuWindow.CalcMenuItem(_Pt: TPoint;
  var _MenuItem: TGilMenuItem): Boolean;
var
  tmpIndex: Integer;
begin
  Result := False;

  if FIsScroll then
  begin
    if Assigned(FUpMenuItem) and PtInRect(FUpMenuItem.Rect, _Pt) then
    begin
      Result := True;
      _MenuItem := FUpMenuItem;
      Exit;
    end;

    if Assigned(FDwMenuItem) and PtInRect(FDwMenuItem.Rect, _Pt) then
    begin
      Result := True;
      _MenuItem := FDwMenuItem;
      Exit;
    end;
  end;

  for tmpIndex := FMinIndex to FMaxIndex do
  begin
    _MenuItem := FMenuItems.Items[tmpIndex];
    if Assigned(_MenuItem) and (_MenuItem.ItemType = mitMenuItem) and
      _MenuItem.Visible and PtInRect(_MenuItem.Rect, _Pt) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TGilMenuWindow.DoCalcDrawItems;
begin
  FBitmap.Canvas.Font.Assign(FPopMenu.FDisplay.TextFont);
  Canvas.Font.Assign(FPopMenu.FDisplay.TextFont);
  CalcWH;
  CalcMaxMinIndex;
  Draw;

  Invalidate;
end;

procedure TGilMenuWindow.Draw;
begin
  DrawBack;
  DrawMenuItems;
  DrawScrollItems;
end;

procedure TGilMenuWindow.DrawBack;
begin
  with FBitmap, FPopMenu.FDisplay do
  begin
    // 画整体背景和边框
    Canvas.Brush.Color := BackColor;
    Canvas.Pen.Color := BorderLineColor;
    Canvas.Rectangle(Rect(0, 0, Width, Height));

    // 画图标区域背景和边框
    Canvas.Brush.Color := IconRectBackColor;
    Canvas.FillRect(Rect(1, 1, IconRectWidth, Height - 1));
  end;
end;

procedure TGilMenuWindow.DrawScrollItems;
begin
  with FBitmap, FPopMenu.FDisplay do
  begin
    if FIsScroll then
    begin
      if Assigned(FUpMenuItem) then
        DrawMenuItemSubFlag(Canvas, FUpMenuItem.Rect, dttUp, TriangleColor);
      if Assigned(FDwMenuItem) then
        DrawMenuItemSubFlag(Canvas, FDwMenuItem.Rect, dttDown, TriangleColor);
    end;
  end;
end;

procedure TGilMenuWindow.DrawMenuItems;
var
  tmpRect: TRect;
  tmpClipRgn: HRGN;
  tmpIndex, tmpTop: Integer;
  tmpMenuItem: TGilMenuItem;
begin
  with FBitmap, FPopMenu.FDisplay do
  begin
    if FIsScroll then
    begin
      FUpMenuItem.Rect := Rect(1, 1, Width - 1, ScrollHeight);
      FDwMenuItem.Rect := Rect(1, Height - ScrollHeight, Width - 1, Height);
      Canvas.Brush.Color := BackColor;
      Canvas.FillRect(FUpMenuItem.Rect);
      Canvas.FillRect(FDwMenuItem.Rect);
      DrawMenuItemSubFlag(Canvas, FUpMenuItem.Rect, dttUp, TriangleColor);
      DrawMenuItemSubFlag(Canvas, FDwMenuItem.Rect, dttDown, TriangleColor);
      tmpRect := Rect(1, FUpMenuItem.Rect.Bottom, Width - 1,
        FDwMenuItem.Rect.Top);

      tmpTop := ScrollHeight - FUpScrollOffset;
    end
    else
    begin
      tmpTop := 0;
      tmpRect := Rect(1, 1, Width - 1, Height);
    end;

    tmpClipRgn := CreateRectRgn(tmpRect.Left, tmpRect.Top, tmpRect.Right,
      tmpRect.Bottom);
    SelectClipRgn(Canvas.Handle, tmpClipRgn);
    try
      for tmpIndex := FMinIndex to FMaxIndex do
      begin
        tmpMenuItem := FMenuItems.Items[tmpIndex];
        if Assigned(tmpMenuItem) and tmpMenuItem.Visible then
        begin
          case tmpMenuItem.ItemType of
            mitMenuItem:
              begin
                tmpMenuItem.Rect := Rect(0, tmpTop, Width,
                  tmpTop + MenuItemHeight);
                if tmpMenuItem.Enable then
                  DrawMenuItem(Canvas, tmpMenuItem, BackColor,
                    IconRectBackColor, TextFontColor, IconTextFontColor,
                    TriangleColor)
                else
                  DrawMenuItem(Canvas, tmpMenuItem, BackColor,
                    IconRectBackColor, UnEnableTextFontColor, IconTextFontColor,
                    TriangleColor);
              end;
            mitLine:
              begin
                tmpMenuItem.Rect := Rect(0, tmpTop, Width,
                  tmpTop + MenuItemLineHeight);
                DrawMenuItemLine(Canvas, tmpMenuItem, DivideLineColor);
              end;
          end;
          tmpTop := tmpMenuItem.Rect.Bottom;
        end;
      end;
    finally
      SelectClipRgn(Canvas.Handle, 0);
      DeleteObject(tmpClipRgn);
    end;
  end;
end;

procedure TGilMenuWindow.DrawMenuItem(_Canvas: TCanvas; _MenuItem: TGilMenuItem;
  _BackColor, _IconRectBackColor, _FontColor, _IconFontColor,
  _SubColor: TColor);
var
  tmpIconRect, tmpTextRect, tmpSubRect: TRect;
begin
  with FPopMenu.FDisplay do
  begin
    tmpIconRect := _MenuItem.Rect;
    tmpTextRect := _MenuItem.Rect;
    tmpIconRect.Right := tmpIconRect.Left + IconRectWidth;
    tmpTextRect.Left := tmpIconRect.Right + XSpace;
    if FIsSubMenuItem then
    begin
      tmpTextRect.Right := tmpTextRect.Right - SubRectWidth;
      tmpSubRect := _MenuItem.Rect;
      tmpSubRect.Left := tmpTextRect.Right;
    end
    else
      tmpTextRect.Right := tmpTextRect.Right - XSpace;
    DrawMenuItemIcon(_Canvas, tmpIconRect, _MenuItem, _IconRectBackColor,
      _IconFontColor);
    DrawMenuItemText(_Canvas, tmpTextRect, _MenuItem, _BackColor, _FontColor);
    if _MenuItem.IsSubMenuItem then
      DrawMenuItemSubFlag(_Canvas, tmpSubRect, dttRight, _SubColor);
  end;
end;

procedure TGilMenuWindow.DrawMenuItemIcon(_Canvas: TCanvas; _Rect: TRect;
  _MenuItem: TGilMenuItem; _BackColor, _FontColor: TColor);
var
  tmpX, tmpY, tmpWidth, tmpHeight: Integer;
  procedure DrawIcon(_ResourceName: string);
  begin
    with FPopMenu.FDisplay do
    begin
      if RefreshPng(_ResourceName) then
      begin
        if DrawPng.Width > _Rect.Width then
          tmpWidth := _Rect.Width
        else
          tmpWidth := DrawPng.Width;
        if DrawPng.Height > _Rect.Height then
          tmpHeight := _Rect.Height
        else
          tmpHeight := DrawPng.Height;
        tmpX := (_Rect.Left + _Rect.Right - tmpWidth) div 2;
        tmpY := (_Rect.Top + _Rect.Bottom - tmpHeight) div 2;
        _Canvas.Draw(tmpX, tmpY, DrawPng);
      end;
    end;
  end;

begin
  with FPopMenu.FDisplay do
  begin
    case _MenuItem.IconType of
      ditCheckBox:
        if _MenuItem.Checked then
          DrawIcon(Const_ResourceName_RightMenu_CheckBox);
      ditRadioBox:
        if _MenuItem.Radioed then
          DrawIcon(Const_ResourceName_RightMenu_RadioBox);
      ditImage:
        DrawIcon(_MenuItem.ResourceName);
      ditText:
        begin
          _Canvas.Brush.Color := _BackColor;
          _Canvas.Font.Color := _FontColor;
          _Canvas.Font.Style := [fsBold];
          DrawTextOutEx(_Canvas.Handle, _Rect, _MenuItem.IconText, dtaCenter);
          _Canvas.Font.Style := [];
        end;
    end;
  end;
end;

procedure TGilMenuWindow.DrawMenuItemLine(_Canvas: TCanvas;
  _MenuItem: TGilMenuItem; _LineColor: TColor);
var
  tmpY: Integer;
begin
  with FPopMenu.FDisplay do
  begin
    tmpY := (_MenuItem.Rect.Top + _MenuItem.Rect.Bottom) div 2;
    _Canvas.Pen.Color := _LineColor;
    _Canvas.MoveTo(_MenuItem.Rect.Left + IconRectWidth + 2, tmpY);
    _Canvas.LineTo(_MenuItem.Rect.Right - 3, tmpY);
  end;
end;

procedure TGilMenuWindow.DrawMenuItemText(_Canvas: TCanvas; _Rect: TRect;
  _MenuItem: TGilMenuItem; _BackColor, _FontColor: TColor);
begin
  _Canvas.Brush.Color := _BackColor;
  _Canvas.Font.Color := _FontColor;
  _MenuItem.IsHint := (_Canvas.TextWidth(_MenuItem.Caption) > _Rect.Width);
  DrawTextOutEx(_Canvas.Handle, _Rect, _MenuItem.Caption, dtaLeft, True);
end;

procedure TGilMenuWindow.DrawMenuItemSubFlag(_Canvas: TCanvas; _Rect: TRect;
  _TriangleType: TDrawTriangleType; _Color: TColor);
var
  tmpIndex, tmpX, tmpY, tmpCount: Integer;
begin
  with FPopMenu.FDisplay do
  begin
    tmpCount := 5;
    _Canvas.Pen.Color := _Color;
    case _TriangleType of
      dttRight:
        begin
          tmpX := (_Rect.Left + _Rect.Right - tmpCount) div 2;
          tmpY := (_Rect.Top + _Rect.Bottom - 2) div 2;

          for tmpIndex := tmpCount downto 0 do
          begin
            _Canvas.MoveTo(tmpX + tmpCount - tmpIndex, tmpY + tmpIndex);
            _Canvas.LineTo(tmpX + tmpCount - tmpIndex, tmpY - tmpIndex);
          end;
        end;
      dttUp:
        begin
          tmpX := (_Rect.Left + _Rect.Right) div 2;
          tmpY := (_Rect.Top + _Rect.Bottom - tmpCount) div 2;

          for tmpIndex := 0 to tmpCount do
          begin
            _Canvas.MoveTo(tmpX + tmpIndex, tmpY + tmpIndex);
            _Canvas.LineTo(tmpX - tmpIndex, tmpY + tmpIndex);
          end;
        end;
      dttDown:
        begin
          tmpX := (_Rect.Left + _Rect.Right) div 2;
          tmpY := (_Rect.Top + _Rect.Bottom - tmpCount) div 2;

          for tmpIndex := 0 to tmpCount do
          begin
            _Canvas.MoveTo(tmpX + tmpCount - tmpIndex, tmpY + tmpIndex);
            _Canvas.LineTo(tmpX - tmpCount + tmpIndex, tmpY + tmpIndex);
          end;
        end;
    end;
  end;
end;

procedure TGilMenuWindow.DrawFocusMenuItem(_Canvas: TCanvas;
  _MenuItem: TGilMenuItem; _BackColor, _IconRectBackColor, _FontColor,
  _IconFontColor, _SubColor: TColor);
var
  tmpClipRgn: HRGN;
  tmpRect, tmpIconRect, tmpTextRect, tmpSubRect: TRect;
begin
  with FPopMenu.FDisplay do
  begin
    tmpRect := _MenuItem.Rect;
    tmpRect.Inflate(-1, -1);
    tmpIconRect := _MenuItem.Rect;
    tmpTextRect := _MenuItem.Rect;
    tmpIconRect.Right := tmpIconRect.Left + IconRectWidth;
    tmpTextRect.Left := tmpIconRect.Right + XSpace;
    if FIsSubMenuItem then
    begin
      tmpTextRect.Right := tmpTextRect.Right - SubRectWidth;
      tmpSubRect := _MenuItem.Rect;
      tmpSubRect.Left := tmpTextRect.Right;
    end
    else
      tmpTextRect.Right := tmpTextRect.Right - XSpace;

    if (_MenuItem.FItemIndex = FMinIndex) then
      tmpRect.Top := tmpRect.Top + FUpScrollOffset
    else if _MenuItem.FItemIndex = FMaxIndex then
      tmpRect.Bottom := tmpRect.Bottom - FDwScrollOffset;

    tmpClipRgn := CreateRectRgn(tmpRect.Left, tmpRect.Top, tmpRect.Right,
      tmpRect.Bottom);
    SelectClipRgn(_Canvas.Handle, tmpClipRgn);
    try
      _Canvas.Brush.Color := _BackColor;
      _Canvas.Pen.Color := _BackColor;
      _Canvas.RoundRect(_MenuItem.Rect, MenuRound, MenuRound);
      DrawMenuItemIcon(_Canvas, tmpIconRect, _MenuItem, _IconRectBackColor,
        _IconFontColor);
      DrawMenuItemText(_Canvas, tmpTextRect, _MenuItem, _BackColor, _FontColor);
      if _MenuItem.IsSubMenuItem then
        DrawMenuItemSubFlag(_Canvas, tmpSubRect, dttRight, _SubColor);
    finally
      SelectClipRgn(_Canvas.Handle, 0);
      DeleteObject(tmpClipRgn);
    end;
  end;
end;

procedure TGilMenuWindow.CreateParams(var params: TCreateParams);
begin
  inherited;
  with params do
  begin
    Style := WS_POPUP;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;

    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
  params.WndParent := Screen.ActiveForm.Handle;
  if (params.WndParent <> 0) and
    (IsIconic(params.WndParent) or not IsWindowVisible(params.WndParent) or
    not IsWindowEnabled(params.WndParent)) then
    params.WndParent := 0;
  if params.WndParent = 0 then
    params.WndParent := Application.Handle;
end;

procedure TGilMenuWindow.WMActivate(var Message: TWMActivate);
begin
  if Message.Active = Integer(False) then
  begin
    if not MouseInMenuWindow then
    begin
      FHideTimer.Interval := 50;
      FHideTimer.Enabled := True;
    end;
  end;
end;

procedure TGilMenuWindow.CMMouseEnter(var Message: TMessage);
begin

end;

procedure TGilMenuWindow.CMMouseLeave(var Message: TMessage);
begin
  if FScrollTimer.Enabled then
    FScrollTimer.Enabled := False;
  FPopMenu.FHint.HideHint;
  if Assigned(FFocusMenuItem) and (not FFocusMenuItem.IsSubMenuItem) and
    FFocusMenuItem.FFocused then
  begin
    FFocusMenuItem.FFocused := False;
    EraseRect(FFocusMenuItem.Rect);
  end;
end;

procedure TGilMenuWindow.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

function TGilMenuWindow.MouseInMenuWindow: Boolean;
var
  tmpPos: TPoint;
  tmpPopMenu: TGilMenuWindow;
begin
  Result := False;
  tmpPopMenu := Self;
  while Assigned(tmpPopMenu) do
  begin
    tmpPos := tmpPopMenu.ScreenToClient(Mouse.CursorPos);
    Result := Result or PtInRect(tmpPopMenu.GetClientRect, tmpPos);
    if Result then
      Exit;
    if Assigned(tmpPopMenu.FFocusMenuItem) then
    begin
      tmpPopMenu := tmpPopMenu.FFocusMenuItem.SubMenu;
    end
    else
      tmpPopMenu := nil;
  end;

  tmpPopMenu := Self.FParentWindow;
  while Assigned(tmpPopMenu) do
  begin
    tmpPos := tmpPopMenu.ScreenToClient(Mouse.CursorPos);
    Result := Result or PtInRect(tmpPopMenu.GetClientRect, tmpPos);
    if Result then
      Exit;
    tmpPopMenu := tmpPopMenu.FParentWindow;
  end;
end;

procedure TGilMenuWindow.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpPt: TPoint;
  tmpMenuItem: TGilMenuItem;
begin
  with FPopMenu.FDisplay do
  begin
    if CalcMenuItem(Point(X, Y), tmpMenuItem) then
    begin
      if (tmpMenuItem.FScrollType = mstNone) and tmpMenuItem.Enable then
      begin
        if not tmpMenuItem.FFocused then
        begin
//          if not tmpMenuItem.FFocused then
//          begin
          if Assigned(FFocusMenuItem) and FFocusMenuItem.FFocused then
          begin
            FFocusMenuItem.FFocused := False;
            if (FFocusMenuItem.FItemIndex >= FMinIndex) and
              (FFocusMenuItem.FItemIndex <= FMaxIndex) then
              EraseRect(FFocusMenuItem.Rect);
            HideSubMenuWindow(FFocusMenuItem.SubMenu);
          end;
//          end;
          tmpMenuItem.FFocused := True;
          FFocusMenuItem := tmpMenuItem;
          if tmpMenuItem.Enable then
            DrawFocusMenuItem(Self.Canvas, tmpMenuItem, FocusBackColor,
              FocusBackColor, TextFontColor, IconTextFontColor, TriangleColor)
          else
            DrawFocusMenuItem(Self.Canvas, tmpMenuItem, FocusBackColor,
              FocusBackColor, UnEnableTextFontColor, IconTextFontColor,
              TriangleColor);

          if tmpMenuItem.Enable and tmpMenuItem.IsSubMenuItem and
            Assigned(tmpMenuItem.SubMenu) and (not tmpMenuItem.SubMenu.Showing)
          then
          begin
            tmpPt := ClientToScreen(Point(tmpMenuItem.Rect.Right - 2,
              tmpMenuItem.Rect.Top));
            tmpMenuItem.SubMenu.PopMenu(tmpPt);
          end;
        end;

        if tmpMenuItem.IsHint then
        begin
          tmpPt := ClientToScreen(Point(X + 5, Y + 10));
          FPopMenu.FHint.ShowHint(tmpMenuItem.Caption, tmpPt.X, tmpPt.Y);
        end
        else
          FPopMenu.FHint.HideHint;

        if FScrollTimer.Enabled then
          FScrollTimer.Enabled := False;
      end
      else
      begin
        FFocusScrollMenuItem := tmpMenuItem;
        FScrollTimer.Enabled := True;
        FPopMenu.FHint.HideHint;
      end;
    end
    else
    begin
      if FScrollTimer.Enabled then
        FScrollTimer.Enabled := False;

      FPopMenu.FHint.HideHint;
    end;
  end;
end;

procedure TGilMenuWindow.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  tmpMenuItem: TGilMenuItem;
begin
  inherited;
  if (Button = mbLeft) and CalcMenuItem(Point(X, Y), tmpMenuItem) then
  begin
    if tmpMenuItem.Enable and not tmpMenuItem.IsSubMenuItem then
    begin
      if tmpMenuItem.FScrollType = mstNone then
        HideAllMenuWindow;
      if Assigned(tmpMenuItem.OnClick) then
        tmpMenuItem.OnClick(tmpMenuItem);
      case tmpMenuItem.IconType of
        ditCheckBox:
          tmpMenuItem.Checked := not tmpMenuItem.Checked;
        ditRadioBox:
          tmpMenuItem.Radioed := True;
      end;
    end;
  end;
end;

procedure TGilMenuWindow.Paint;
var
  tmpRect: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FBitmap <> nil) then
  begin
    Canvas.Lock;
    try
      tmpRect := Rect(0, 0, Width, Height);
      Canvas.CopyRect(tmpRect, FBitmap.Canvas, tmpRect);
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TGilMenuWindow.Resize;
begin
  if (FBitmap.Width <> Width) or (FBitmap.Height <> Height) then
  begin
    FBitmap.Canvas.Lock;
    try
      FBitmap.SetSize(Width, Height);
    finally
      FBitmap.Canvas.UnLock;
    end;
    DoCalcDrawItems;
  end;
end;

function TGilMenuWindow.AddMenuItem(_Name, _Key: string): TGilMenuItem;
begin
  Result := TGilMenuItem.Create(mitMenuItem);
  Result.Caption := _Name;
  Result.Key := _Key;
  Result.FOwnMenuWindow := Self;
  Result.FItemIndex := FMenuItems.Add(Result);
end;

function TGilMenuWindow.AddMenuItem(_MenuItem: TGilMenuItem): TGilMenuItem;
begin
  Result := _MenuItem;
  Result.FOwnMenuWindow := Self;
  Result.FItemIndex := FMenuItems.Add(_MenuItem);
end;

procedure TGilMenuWindow.PopMenu(_Pt: TPoint);
var
  tmpRect: TRect;
  tmpMonitor: TMonitor;
begin
  DoCalcDrawItems;
  tmpMonitor := Screen.MonitorFromWindow(GetActiveWindow);
  // tmpMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
  if tmpMonitor <> nil then
  begin
    tmpRect := tmpMonitor.WorkareaRect;
    if (_Pt.Y + Height) > tmpRect.Bottom then
      _Pt.Y := tmpRect.Bottom - Height;
    if (_Pt.X + Width) > tmpRect.Right then
    begin
      if Assigned(FParentWindow) then
        _Pt.X := FParentWindow.Left - Width + 2
      else
        _Pt.X := tmpRect.Right - Width;
    end;
  end;
  Left := _Pt.X;
  Top := _Pt.Y;
  // SetForegroundWindow 解决托盘上显示的菜单，点击任务栏上的空白区域不消失
  SetForegroundWindow(Application.Handle);
  Show;
end;

procedure TGilMenuWindow.ClearMenus;
begin
  FOffset := 0;
  FMinOffset := 0;
  FMaxOffset := 0;
  FUpScrollOffset := 0;
  FDwScrollOffset := 0;
  FFocusMenuItem := nil;
  FFocusScrollMenuItem := nil;
  FMinIndex := 0;
  FMaxIndex := -1;
  CleanList(FMenuItems);
end;

{ TGilPopMenu }

constructor TGilPopMenu.Create(AContext: IAppContext);
begin
  inherited;
//  FOwner := AOwner;
  FDisplay := TGilMenuDisplay.Create(FAppContext);
  FMenuWindow := TGilMenuWindow.CreateNew(nil, Self);
  FHint := THintControl.Create(nil);
  UpdateSkin;
end;

destructor TGilPopMenu.Destroy;
begin
  if Assigned(FHint) then
    FHint.Free;
  if Assigned(FMenuWindow) then
    FreeAndNil(FMenuWindow);
  if Assigned(FDisplay) then
    FreeAndNil(FDisplay);
  inherited;
end;

function TGilPopMenu.GetMenuItem(_Index: Integer): TGilMenuItem;
begin
  Result := FMenuWindow.GetMenuItem(_Index);
end;

function TGilPopMenu.GetMenuItemCount: Integer;
begin
  Result := FMenuWindow.GetMenuItemCount;
end;

function TGilPopMenu.GetMenuItemHeight: Integer;
begin
  Result := FDisplay.MenuItemHeight;
end;

procedure TGilPopMenu.HideAllMenus;
begin
  if Assigned(FMenuWindow) and FMenuWindow.Showing then
    FMenuWindow.FHideTimer.Enabled := True;
end;

function TGilPopMenu.AddMenuItem(_Name, _Key: string): TGilMenuItem;
begin
  Result := FMenuWindow.AddMenuItem(_Name, _Key);
end;

function TGilPopMenu.AddMenuItem(_MenuItem: TGilMenuItem): TGilMenuItem;
begin
  Result := FMenuWindow.AddMenuItem(_MenuItem);
end;

procedure TGilPopMenu.PopMenu(_Pt: TPoint);
begin
  _Pt.X := _Pt.X + 2;
  _Pt.Y := _Pt.Y + 2;
  FMenuWindow.PopMenu(_Pt);
end;

procedure TGilPopMenu.ClearMenus;
begin
  FMenuWindow.ClearMenus;
end;

procedure TGilPopMenu.UpdateSkin;
begin
  FDisplay.UpdateSkin;
  FMenuWindow.DoAllMenuWindowInvaildate;
end;

end.
