unit BaseForm;

interface

uses
  Windows,
  Classes,
  Messages,
  Graphics,
  Controls,
  SysUtils,
  Types,
  AppContext,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Forms, CommonFunc;

type

  // CloseWindow RevertWindow MaxMinimizeWindow
  TBarButtonType = (bbtMinimize, bbtRevert, bbtClose);
  TBarButtonTypes = Set of TBarButtonType;
  TOnClickTitleBarButtonEvent = procedure(ABarButtonType: TBarButtonType)
    of object;

  TBaseBarButton = class
  private
    FId: Integer;
    FRect: TRect;
    FFocused: Boolean;
    FBarButtonType: TBarButtonType;
    FOnClick: TNotifyEvent;
  public
    constructor Create(_BarButtonType: TBarButtonType);
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property Rect: TRect read FRect write FRect;
    property Focused: Boolean read FFocused write FFocused;
    property BarButtonType: TBarButtonType read FBarButtonType
      write FBarButtonType;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TBaseTitleBarDisplay = class
  public
    FAppContext: IAppContext;
//    FGilAppController: IGilAppController;
    FSkinStyle: string;
    TextFont: TFont;
    HintFont: TFont;

    BackColor: TColor;
    CaptionColor: TColor;
    CloseButtonFocusBackColor: TColor;
    CloseButtonDownBackColor: TColor;
    ButtonFocusBackColor: TColor;
    ButtonDownBackColor: TColor;
    ToolFontColor: TColor;
    FocusToolFontColor: TColor;
    BorderLineColor: TColor;

    YSpace: Integer;
    XSpace: Integer;
    BarButtonWidth: Integer;

    constructor Create(AContext: IAppContext); reintroduce; virtual;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController);
//    procedure DisConnectQuoteManager;
    procedure UpdateSkin;
  end;

  TBaseFormDisplay = class
  public
    FAppContext: IAppContext;
//    FGilAppController: IGilAppController;
    FSkinStyle: string;

    ContentColor: TColor;
    BackColor: TColor;
    BorderLineColor: TColor;

    constructor Create(AContext: IAppContext); reintroduce; virtual;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController);
//    procedure DisConnectQuoteManager;
    procedure UpdateSkin; overload; virtual;
//    procedure UpdateSkin(AGilAppController: IGilAppController); overload; virtual;
  end;

  TBaseFormTitleBar = class(TPanel)
  private
    FAppContext: IAppContext;
    FDisplay: TBaseTitleBarDisplay;
    FBitMap: TBitmap;
    FCaption: String;
    FHint: String;
    FBarButtons: TList;
    FBarButtonTypes: TBarButtonTypes;
    FLastBarButton: TBaseBarButton;
    FOnClickBarButton: TOnClickTitleBarButtonEvent;
    FParentForm: TForm;
    FIsDragForm: Boolean;
    FIsResize: Boolean;

    procedure Draw; virtual;
    procedure DrawBack;virtual;
    procedure DrawFrameLine; virtual;
    procedure DrawCaption; virtual;
    procedure DrawButtons; virtual;

    procedure DrawButton(_Canvas: TCanvas; _BarButton: TBaseBarButton;
      _BackColor: TColor); virtual;

    procedure CalcRect;
    procedure EraseRect(_Rect: TRect);

    function CalcButton(_Pt: TPoint; var _BarButton: TBaseBarButton): Boolean;virtual;

    function GetBarButtons(_Index: Integer): TBaseBarButton;
    procedure CleanList(_List: TList);
    procedure SetBarButtonTypes(_BarButtonTypes: TBarButtonTypes);
    function GetCaption: string;
    procedure SetCaption(_Caption: string);
    procedure SetHint(_Hint: string);
    function GetBackColor: TColor;
    procedure SetBackColor(_Color: TColor);
    function GetCaptionColor: TColor;
    procedure SetCaptionColor(_Color: TColor);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Resize; override;
    procedure Paint; override;

    procedure InitData;
    procedure DoClick(Sender: TObject); virtual;
  public
    CaptionInCenter: Boolean;
    constructor Create(AOwner: TComponent; AContext: IAppContext); reintroduce; virtual;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController);
//    procedure DisConnectQuoteManager;
    procedure DoInvaildate;
    procedure UpdateSkin;

    property ParentForm: TForm read FParentForm write FParentForm;
    property IsDragForm: Boolean read FIsDragForm write FIsDragForm;
    property Display: TBaseTitleBarDisplay read FDisplay;
    property BarButtons[_Index: Integer]: TBaseBarButton read GetBarButtons;
    property BarButtonTypes: TBarButtonTypes read FBarButtonTypes
      write SetBarButtonTypes;
    property Caption: string read GetCaption write SetCaption;
    property OnClickBarButton: TOnClickTitleBarButtonEvent
      read FOnClickBarButton write FOnClickBarButton;

    property Hint: String write SetHint;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property CaptionColor: TColor read GetCaptionColor write SetCaptionColor;
  end;

  TBaseForm = class(TForm)
  private
  protected
    FAppContext: IAppContext;
    FTitleBar: TBaseFormTitleBar;
    FMouseChangeSize: Boolean;

    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown);
      message WM_NCLBUTTONDOWN;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
      message WM_GetMinMaxInfo;
    // 边框留1个像素接收WM_NCHITTEST消息
    procedure AdjustClientRect(var Rect: TRect); override;

    procedure DoCreate; override;
    procedure DoInitForm; virtual;
  public
    constructor CreateNew(AOwner: TComponent; AContext: IAppContext); reintroduce; virtual;
    destructor Destroy; override;
    procedure UpdateSkin; virtual;
    procedure SetCenter; virtual;
    procedure ShowCenter; virtual;
    procedure ShowPos(_Pt: TPoint);

    property MouseChangeSize: Boolean read FMouseChangeSize
      write FMouseChangeSize;
  end;

  //将tittle对象改为可从外部获取
  TBaseTittleForm = class(TBaseForm)
  protected
    procedure DoInitForm; override;
  public
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController); virtual;

    property TitleBar: TBaseFormTitleBar read FTitleBar write FTitleBar;
  end;

  TTopBaseFrom = class(TBaseForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
  end;

procedure DrawCopyRect(DestDC: HDC; const DestR: TRect; SrcDC: HDC;
  const SrcR: TRect);

implementation

procedure DrawCopyRect(DestDC: HDC; const DestR: TRect; SrcDC: HDC;
  const SrcR: TRect);
begin
  StretchBlt(DestDC, DestR.Left, DestR.Top, DestR.Right - DestR.Left,
    DestR.Bottom - DestR.Top, SrcDC, SrcR.Left, SrcR.Top,
    SrcR.Right - SrcR.Left, SrcR.Bottom - SrcR.Top, cmSrcCopy);
end;

{ TBaseFormButton }

constructor TBaseBarButton.Create(_BarButtonType: TBarButtonType);
begin
  FFocused := False;
  FBarButtonType := _BarButtonType;
end;

destructor TBaseBarButton.Destroy;
begin

  inherited;
end;

{ TBaseFormDisplay }

constructor TBaseTitleBarDisplay.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -14;

  HintFont := TFont.Create;
  HintFont.Charset := GB2312_CHARSET;
  HintFont.Color := $0000FF; // clWhite;
  HintFont.Height := -14;
  HintFont.Name := '微软雅黑';

  CaptionColor := $3E3E3E;
  BackColor := $F5F5F5;
  CloseButtonFocusBackColor := $2A00FF;
  CloseButtonDownBackColor := $1E1ED2;
  ButtonFocusBackColor := $018FFB;
  ButtonDownBackColor := $146EFB;
  ToolFontColor := $646464;
  FocusToolFontColor := $FFFFFF;
  BorderLineColor := $999999;
  FSkinStyle := '';

  // TextFont.Color := $FFFFFF;
  // BackColor := $444444;
  // CloseButtonFocusBackColor := $2A00FF;
  // CloseButtonDownBackColor := $1E1ED2;
  // ButtonFocusBackColor := $018FFB;
  // ButtonDownBackColor := $146EFB;
  // ToolFontColor := $969696;
  // FocusToolFontColor := $FFFFFF;

  YSpace := 5;
end;

destructor TBaseTitleBarDisplay.Destroy;
begin
  if Assigned(HintFont) then
    HintFont.Free;
  if Assigned(TextFont) then
    TextFont.Free;
  FAppContext := nil;
  inherited;
end;

//procedure TBaseTitleBarDisplay.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//begin
//  FGilAppController := GilAppController;
//end;
//
//procedure TBaseTitleBarDisplay.DisConnectQuoteManager;
//begin
//  FGilAppController := nil;
//end;

procedure TBaseTitleBarDisplay.UpdateSkin;
const
  Const_BaseTitleBar_Prefix = 'BaseTitleBar_';
var
  tmpSkinStyle: string;
//  function GetStrFromConfig(_Key: WideString): string;
//  begin
//    Result := FGilAppController.Config(ctSkin,
//      Const_BaseTitleBar_Prefix + _Key);
//  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_BaseTitleBar_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_BaseTitleBar_Prefix + _Key), 0));
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;
//      TextFont.Name := GetStrFromConfig('TextFontName');

      BackColor := GetColorFromConfig('BackColor');
      CaptionColor := GetColorFromConfig('CaptionColor');
      CloseButtonFocusBackColor :=
        GetColorFromConfig('CloseButtonFocusBackColor');
      CloseButtonDownBackColor :=
        GetColorFromConfig('CloseButtonDownBackColor');
      ButtonFocusBackColor := GetColorFromConfig('ButtonFocusBackColor');
      ButtonDownBackColor := GetColorFromConfig('ButtonDownBackColor');
      ToolFontColor := GetColorFromConfig('ToolFontColor');
      FocusToolFontColor := GetColorFromConfig('FocusToolFontColor');
      BorderLineColor := GetColorFromConfig('BorderLineColor');
    end
//  end;
end;

{ TBaseFormDisplay }
constructor TBaseFormDisplay.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TBaseFormDisplay.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

//procedure TBaseFormDisplay.ConnectQuoteManager(const GilAppController: IGilAppController);
//begin
//  FGilAppController := GilAppController;
//end;
//
//procedure TBaseFormDisplay.DisConnectQuoteManager;
//begin
//  FGilAppController := nil;
//end;

procedure TBaseFormDisplay.UpdateSkin;
var
  tmpSkinStyle: string;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(_Key); //TColor(HexToIntDef(AGilAppController.Config(ctSkin, _Key), 0));
  end;

begin
//  if Assigned(AGilAppController) then
//  begin
    ContentColor := GetColorFromConfig('BaseForm_ContentColor');
    BackColor := GetColorFromConfig('BaseForm_BackColor');
    BorderLineColor := GetColorFromConfig('BaseForm_BorderLine');
//  end;
end;
//
//procedure TBaseFormDisplay.UpdateSkin(AGilAppController: IGilAppController);
//var
//  tmpSkinStyle: string;
//
//  function GetColorFromConfig(_Key: WideString): TColor;
//  begin
//    Result := FAppContext.GetResourceSkin.GetColor(); //TColor(HexToIntDef(AGilAppController.Config(ctSkin, _Key), 0));
//  end;
//
//begin
//  if Assigned(AGilAppController) then
//  begin
//    ContentColor := GetColorFromConfig('BaseForm_ContentColor');
//    BackColor := GetColorFromConfig('BaseForm_BackColor');
//    BorderLineColor := GetColorFromConfig('BaseForm_BorderLine');
//  end;
//end;


{ TBaseFormTitleBar }

constructor TBaseFormTitleBar.Create(AOwner: TComponent; AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited Create(AOwner);
  FHint := '';
  FDisplay := TBaseTitleBarDisplay.Create(AContext);
  FBitMap := TBitmap.Create;
  FBarButtons := TList.Create;
  CaptionInCenter := False;
  InitData;
end;

destructor TBaseFormTitleBar.Destroy;
begin
  if Assigned(FBarButtons) then
  begin
    CleanList(FBarButtons);
    FBarButtons.Free;
  end;
  if Assigned(FBitMap) then
    FBitMap.Free;
  if Assigned(FDisplay) then
    FDisplay.Free;
  FAppContext := nil;
  inherited;
end;

//procedure TBaseFormTitleBar.ConnectQuoteManager(const GilAppController
//  : IGilAppController);
//begin
//  FGilAppController := GilAppController;
//  FDisplay.ConnectQuoteManager(FGilAppController);
//end;
//
//procedure TBaseFormTitleBar.DisConnectQuoteManager;
//begin
//  FGilAppController := nil;
//end;

procedure TBaseFormTitleBar.UpdateSkin;
begin
  FDisplay.UpdateSkin;
  DoInvaildate;
end;

procedure TBaseFormTitleBar.CleanList(_List: TList);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      TObject(_List[tmpIndex]).Free;
    _List.Clear;
  end;
end;

function TBaseFormTitleBar.GetBackColor: TColor;
begin
  Result := FDisplay.BackColor;
end;

procedure TBaseFormTitleBar.SetBackColor(_Color: TColor);
begin
  FDisplay.BackColor := _Color;
  if FIsResize then
    DoInvaildate;
end;

function TBaseFormTitleBar.GetBarButtons(_Index: Integer): TBaseBarButton;
begin
  Result := nil;
  if Assigned(FBarButtons) and (_Index >= 0) and (_Index < FBarButtons.Count)
  then
    Result := TBaseBarButton(FBarButtons.Items[_Index]);
end;

procedure TBaseFormTitleBar.InitData;
begin
  FIsDragForm := True;
  FIsResize := False;
end;

procedure TBaseFormTitleBar.SetBarButtonTypes(_BarButtonTypes: TBarButtonTypes);
var
  tmpBarButton: TBaseBarButton;
  tmpBarButtonType: TBarButtonType;
begin
  if Assigned(FBarButtons) then
  begin
    FBarButtonTypes := _BarButtonTypes;
    CleanList(FBarButtons);
    for tmpBarButtonType in FBarButtonTypes do
    begin
      tmpBarButton := TBaseBarButton.Create(tmpBarButtonType);
      tmpBarButton.OnClick := DoClick;
      tmpBarButton.Id := Integer(tmpBarButtonType);
      FBarButtons.Add(tmpBarButton);
    end;
    CalcRect;
  end;
end;

procedure TBaseFormTitleBar.SetCaption(_Caption: string);
begin
  FCaption := _Caption;
  if FIsResize then
    DoInvaildate;
end;

procedure TBaseFormTitleBar.SetHint(_Hint: string);
begin
  if(FHint <> _Hint)then
  begin
    FHint := _Hint;
    if FIsResize then
      DoInvaildate;
  end;
end;

function TBaseFormTitleBar.GetCaption: string;
begin
  Result := FCaption;
end;

procedure TBaseFormTitleBar.SetCaptionColor(_Color: TColor);
begin
  FDisplay.TextFont.Color := _Color;
  if FIsResize then
    DoInvaildate;
end;

function TBaseFormTitleBar.GetCaptionColor: TColor;
begin
  Result := FDisplay.TextFont.Color;
end;

function TBaseFormTitleBar.CalcButton(_Pt: TPoint;
  var _BarButton: TBaseBarButton): Boolean;
var
  tmpIndex: Integer;
begin
  _BarButton := nil;
  Result := False;
  for tmpIndex := 0 to FBarButtons.Count - 1 do
  begin
    _BarButton := BarButtons[tmpIndex];
    if Assigned(_BarButton) and PtInRect(_BarButton.Rect, _Pt) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TBaseFormTitleBar.CalcRect;
var
  tmpRect: TRect;
  tmpIndex: Integer;
  tmpBarButton: TBaseBarButton;
begin
  with FDisplay do
  begin
    if Assigned(FBarButtons) then
    begin
      tmpRect := Rect(0, 0, Width, Height - YSpace);
      for tmpIndex := FBarButtons.Count - 1 downto 0 do
      begin
        tmpBarButton := BarButtons[tmpIndex];
        if Assigned(tmpBarButton) then
        begin
          tmpRect.Left := tmpRect.Right - tmpRect.Height;
          tmpBarButton.Rect := tmpRect;
          tmpRect.Right := tmpRect.Left - XSpace;
        end;
      end;
    end;
  end;
end;

procedure TBaseFormTitleBar.EraseRect(_Rect: TRect);
begin
  DrawCopyRect(Canvas.Handle, _Rect, FBitMap.Canvas.Handle, _Rect);
end;

procedure TBaseFormTitleBar.DoClick(Sender: TObject);
var
  tmpBarButton: TBaseBarButton;
begin
  tmpBarButton := TBaseBarButton(Sender);
  if Assigned(FParentForm) then
  begin
    case tmpBarButton.BarButtonType of
      bbtMinimize:
        FParentForm.WindowState := wsMinimized;
      bbtClose:
        FParentForm.Close;
      bbtRevert:
        begin
          if FParentForm.WindowState = wsNormal then
            FParentForm.WindowState := wsMaximized
          else if FParentForm.WindowState = wsMaximized then
            FParentForm.WindowState := wsNormal;
        end
    else
      begin
        if Assigned(FOnClickBarButton) then
          FOnClickBarButton(tmpBarButton.BarButtonType);
      end;
    end;
  end;
end;

procedure TBaseFormTitleBar.DoInvaildate;
begin
  FBitMap.Canvas.Font.Assign(FDisplay.TextFont);
  self.Canvas.Font.Assign(FDisplay.TextFont);
  CalcRect;
  Draw;

  Invalidate;
end;

procedure TBaseFormTitleBar.Draw;
begin
  DrawBack;
  DrawFrameLine;
  DrawCaption;
  DrawButtons;
end;

procedure TBaseFormTitleBar.DrawBack;
begin
  with FBitMap, FDisplay do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
end;

procedure TBaseFormTitleBar.DrawFrameLine;
begin
  with FBitMap, FDisplay do
  begin
     Canvas.Pen.Color := BorderLineColor;
//     if blTop in FBorderLine then
//     begin
//     Canvas.MoveTo(0, 0);
//     Canvas.LineTo(Width, 0);
//     end;
//
//     if blRight in FBorderLine then
//     begin
//     Canvas.MoveTo(Width - 1, 0);
//     Canvas.LineTo(Width - 1, Height);
//     end;

//     if blBottom in FBorderLine then
//     begin
     Canvas.MoveTo(0, Height - 1);
     Canvas.LineTo(Width, Height - 1);
//     end;

//     if blLeft in FBorderLine then
//     begin
//     Canvas.MoveTo(0, 0);
//     Canvas.LineTo(0, Height);
//     end;
  end;
end;

procedure TBaseFormTitleBar.DrawButtons;
var
  tmpIndex: Integer;
  tmpBarButton: TBaseBarButton;
begin
  with FBitMap, FDisplay do
  begin
    for tmpIndex := FBarButtons.Count - 1 downto 0 do
    begin
      tmpBarButton := BarButtons[tmpIndex];
      if Assigned(tmpBarButton) then
      begin
        DrawButton(Canvas, tmpBarButton, BackColor);
      end;
    end;
  end;
end;

procedure TBaseFormTitleBar.DrawCaption;
var
  tmpTop, tmpLeft: Integer;
begin
  with FBitMap, FDisplay do
  begin
    tmpTop := (Height - Canvas.TextHeight('A')) div 2;
    if CaptionInCenter then
      tmpLeft := (Width - Canvas.TextWidth(FCaption)) div 2
    else
      tmpLeft := 10;
    Canvas.Brush.Color := BackColor;
    Canvas.Font.Color := CaptionColor;
    Canvas.TextOut(tmpLeft, tmpTop, FCaption);
//    if(Assigned(FGilAppController))then
//      FGilAppController.GetLogWriter.Log(llInfo, ClassName + '.DrawCaption: CaptionColor=' + IntToStr(CaptionColor)
//        + ' BackColor=' + IntToStr(BackColor));
//    if(Assigned(FGilAppController))then
//      FGilAppController.GetLogWriter.Log(llInfo, ClassName + '.DrawCaption: FCaption=' + FCaption
//        + ' tmpLeft=' + IntToStr(tmpLeft) + ' tmpTop=' + IntToStr(tmpTop));

    if(FHint <> '')then
    begin
      tmpLeft := tmpLeft + Canvas.TextWidth(FCaption + '  ');
      try
        Canvas.Font.Assign(HintFont);
        tmpTop := (Height - Canvas.TextHeight('A')) div 2;
        Canvas.TextOut(tmpLeft, tmpTop, FHint);
//        if(Assigned(FGilAppController))then
//          FGilAppController.GetLogWriter.Log(llInfo, ClassName + '.DrawCaption: FHint=' + FHint
//            + ' tmpLeft=' + IntToStr(tmpLeft) + ' tmpTop=' + IntToStr(tmpTop));
      finally
        Canvas.Font.Assign(TextFont);
      end;
    end;
  end;
end;

procedure TBaseFormTitleBar.DrawButton(_Canvas: TCanvas;
  _BarButton: TBaseBarButton; _BackColor: TColor);
var
  tmpRect: TRect;
  tmpColor: TColor;
  tmpSize, tmpY: Integer;
begin
  with FBitMap, FDisplay do
  begin
    tmpRect := _BarButton.Rect;
    _Canvas.Brush.Color := _BackColor;
    _Canvas.FillRect(tmpRect);
    if _BarButton.FFocused then
      tmpColor := FocusToolFontColor
    else
      tmpColor := ToolFontColor;

    _Canvas.Pen.Color := tmpColor;

    case _BarButton.BarButtonType of
      bbtClose:
        begin
          tmpSize := tmpRect.Width div 3;
          _Canvas.Pen.Width := 2;
          _Canvas.MoveTo(tmpRect.Left + tmpSize, tmpRect.Top + tmpSize);
          _Canvas.LineTo(tmpRect.Right - tmpSize, tmpRect.Bottom - tmpSize);
          _Canvas.MoveTo(tmpRect.Right - tmpSize, tmpRect.Top + tmpSize);
          _Canvas.LineTo(tmpRect.Left + tmpSize, tmpRect.Bottom - tmpSize);
          _Canvas.Pen.Width := 1;
        end;
      bbtRevert:
        begin
          if Assigned(FParentForm) then
          begin
            if FParentForm.WindowState = wsNormal then
            begin
              tmpSize := 4;
              tmpRect := Rect(tmpRect.Left + tmpRect.Width div tmpSize,
                tmpRect.Top + tmpRect.Height div tmpSize,
                tmpRect.Right - tmpRect.Width div tmpSize,
                tmpRect.Bottom - tmpRect.Height div tmpSize);

              _Canvas.Rectangle(tmpRect);
              _Canvas.MoveTo(tmpRect.Left, tmpRect.Top + 1);
              _Canvas.LineTo(tmpRect.Right - 1, tmpRect.Top + 1);
            end
            else if FParentForm.WindowState = wsMaximized then
            begin
              tmpSize := 3;
              tmpRect := Rect(tmpRect.Left + tmpRect.Width div tmpSize,
                tmpRect.Top + tmpRect.Height div tmpSize,
                tmpRect.Right - tmpRect.Width div tmpSize,
                tmpRect.Bottom - tmpRect.Height div tmpSize);

              tmpSize := 2;
              tmpRect := Rect(tmpRect.Left + tmpSize, tmpRect.Top - tmpSize,
                tmpRect.Right + tmpSize, tmpRect.Bottom - tmpSize);
              _Canvas.Rectangle(tmpRect);
              _Canvas.MoveTo(tmpRect.Left, tmpRect.Top + 1);
              _Canvas.LineTo(tmpRect.Right - 1, tmpRect.Top + 1);

              tmpRect := Rect(tmpRect.Left - 2 * tmpSize,
                tmpRect.Top + 2 * tmpSize, tmpRect.Right - 2 * tmpSize,
                tmpRect.Bottom + 2 * tmpSize);
              _Canvas.Rectangle(tmpRect);
              _Canvas.MoveTo(tmpRect.Left, tmpRect.Top + 1);
              _Canvas.LineTo(tmpRect.Right - 1, tmpRect.Top + 1);
              _Canvas.Pen.Width := 1;
            end;
          end;
        end;
      bbtMinimize:
        begin
          tmpY := (tmpRect.Top + tmpRect.Bottom + 1) div 2;
          _Canvas.MoveTo(tmpRect.Left + (tmpRect.Width div 4), tmpY);
          _Canvas.LineTo(tmpRect.Right - (tmpRect.Width div 4), tmpY);
          _Canvas.MoveTo(tmpRect.Left + (tmpRect.Width div 4), tmpY + 1);
          _Canvas.LineTo(tmpRect.Right - (tmpRect.Width div 4), tmpY + 1);
        end;
    end;
  end;
end;

procedure TBaseFormTitleBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  tmpRect: TRect;
  tmpColor: TColor;
  tmpBarButton: TBaseBarButton;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    if CalcButton(Point(X, Y), tmpBarButton) then
    begin
      if tmpBarButton.FBarButtonType = bbtClose then
        tmpColor := FDisplay.CloseButtonDownBackColor
      else
        tmpColor := FDisplay.ButtonDownBackColor;
      tmpBarButton.Focused := True;
      DrawButton(self.Canvas, tmpBarButton, tmpColor);
      FLastBarButton := tmpBarButton;
    end
    else
    begin
      tmpRect := Rect(0, 0, Width, Height);
      tmpBarButton := BarButtons[0];
      if Assigned(tmpBarButton) then
        tmpRect.Right := tmpBarButton.Rect.Right - 20;
      if Assigned(FParentForm) then
      begin
        if PtInRect(tmpRect, Point(X, Y)) then
        begin
          if (FParentForm.WindowState <> wsMaximized) and FIsDragForm then
          begin
            ReleaseCapture;
            FParentForm.Perform(WM_SYSCOMMAND, $F012, 0);
          end;
        end;
      end;
    end;
  end;
end;

procedure TBaseFormTitleBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpColor: TColor;
  tmpBarButton: TBaseBarButton;
begin
  inherited MouseMove(Shift, X, Y);
  if CalcButton(Point(X, Y), tmpBarButton) then
  begin
    if not tmpBarButton.Focused then
    begin
      if Assigned(FLastBarButton) then
      begin
        EraseRect(FLastBarButton.Rect);
        FLastBarButton.Focused := False;
      end;
      if ssLeft in Shift then
      begin
        if tmpBarButton.FBarButtonType = bbtClose then
          tmpColor := FDisplay.CloseButtonDownBackColor
        else
          tmpColor := FDisplay.ButtonDownBackColor;
      end
      else
      begin
        if tmpBarButton.FBarButtonType = bbtClose then
          tmpColor := FDisplay.CloseButtonFocusBackColor
        else
          tmpColor := FDisplay.ButtonFocusBackColor;
      end;

      tmpBarButton.Focused := True;
      DrawButton(self.Canvas, tmpBarButton, tmpColor);
      FLastBarButton := tmpBarButton;
    end;
  end
  else
  begin
    if Assigned(FLastBarButton) and FLastBarButton.Focused then
    begin
      EraseRect(FLastBarButton.Rect);
      FLastBarButton.Focused := False;
    end;
  end;
end;

procedure TBaseFormTitleBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  tmpBarButton: TBaseBarButton;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    if CalcButton(Point(X, Y), tmpBarButton) then
    begin
      if Assigned(tmpBarButton.OnClick) then
        tmpBarButton.OnClick(tmpBarButton);
    end;
  end;
end;

procedure TBaseFormTitleBar.CMMouseEnter(var Message: TMessage);
begin

end;

procedure TBaseFormTitleBar.CMMouseLeave(var Message: TMessage);
begin
  with FBitMap, FDisplay do
  begin
    if Assigned(FLastBarButton) and FLastBarButton.Focused then
    begin
      FLastBarButton.Focused := False;
      DrawButton(Canvas, FLastBarButton, BackColor);
      EraseRect(FLastBarButton.Rect);
    end;
    if Assigned(OnMouseLeave) then
      OnMouseLeave(self);
  end;
end;

procedure TBaseFormTitleBar.Paint;
var
  R: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FBitMap <> nil) then
  begin
    Canvas.Lock;
    try
      R := Rect(0, 0, Width, Height);
      DrawCopyRect(Canvas.Handle, R, FBitMap.Canvas.Handle, R);
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TBaseFormTitleBar.Resize;
begin
  if (FBitMap.Width <> Width) or (FBitMap.Height <> Height) then
  begin
    try
      FBitMap.SetSize(Width, Height);
      FIsResize := True;
    finally
    end;
  end;

  DoInvaildate;
  inherited;
end;

{ TBaseForm }

constructor TBaseForm.CreateNew(AOwner: TComponent; AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited CreateNew(AOwner);

  // Visible := False;
  // Ctl3D := False;
  // AutoScroll := False;
  BorderStyle := bsNone;
  // BorderWidth := 0;
  // BorderIcons := [];

  FMouseChangeSize := True;
  Position := poDesigned;

  BorderWidth := 1;

  FTitleBar := TBaseFormTitleBar.Create(nil, FAppContext);
  FTitleBar.Parent := self;
  FTitleBar.Align := alTop;
  FTitleBar.Height := 30;
  FTitleBar.BarButtonTypes := [bbtClose, bbtRevert];
  FTitleBar.Caption := '新窗口';
  FTitleBar.ParentForm := self;
end;

destructor TBaseForm.Destroy;
begin
  if Assigned(FTitleBar) then
    FreeAndNil(FTitleBar);
  FAppContext := nil;
  inherited;
end;

procedure TBaseForm.DoCreate;
begin
  inherited;
  DoInitForm;// (not WS_OVERLAPPED)  or
  // SetWindowLong(Handle,GWL_STYLE,GetWindowLong(Handle, GWL_STYLE) and (not WS_CAPTION) or WS_SYSMENU);

  // SetWindowLong(Handle,GWL_EXSTYLE,GetWindowLong(Handle, GWL_EXSTYLE)  or WS_EX_APPWINDOW);//子窗口在任务栏上显示
end;

procedure TBaseForm.DoInitForm;
begin
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) and
    (not WS_THICKFRAME) and (not WS_CAPTION) and (not WS_BORDER) and
    WS_SYSMENU);
end;

procedure TBaseForm.WMNCHitTest(var Message: TWMNCHitTest);
var
  Arect: TRect;
  FTopLeftRect, FTopRightRect, FBottomLeftRect, FBottomRightRect, FTopRect,
    FLeftRect, FRightRect, FBottomRect: TRect;
  p: TPoint;
begin
  if (WindowState <> wsNormal) or (not FMouseChangeSize) then
  begin
    inherited;
    Exit;
  end;
  p.X := Message.XPos;
  p.Y := Message.YPos;
  GetWindowRect(Handle, Arect);
  FTopLeftRect := Rect(Arect.Left, Arect.Top, Arect.Left + 3, Arect.Top + 3);
  FTopRightRect := Rect(Arect.Right - 3, Arect.Top, Arect.Right, Arect.Top + 3);
  FBottomLeftRect := Rect(Arect.Left, Arect.Bottom - 3, Arect.Left + 3,
    Arect.Bottom);
  FBottomRightRect := Rect(Arect.Right - 3, Arect.Bottom - 3, Arect.Right,
    Arect.Bottom);

  FTopRect := Rect(FTopLeftRect.Right, Arect.Top, FTopRightRect.Right,
    Arect.Top + 3);
  FLeftRect := Rect(Arect.Left, FTopLeftRect.Bottom, Arect.Left + 3,
    FBottomLeftRect.Bottom);
  FRightRect := Rect(Arect.Right - 3, FTopRightRect.Bottom, Arect.Right,
    FBottomRightRect.Top);
  FBottomRect := Rect(FBottomLeftRect.Right, Arect.Bottom - 3,
    FBottomRightRect.Left, Arect.Bottom);

  if FTopLeftRect.Contains(p) then
    Message.Result := HTTOPLEFT
  else if FTopRightRect.Contains(p) then
    Message.Result := HTTOPRIGHT
  else if FBottomLeftRect.Contains(p) then
    Message.Result := HTBOTTOMLEFT
  else if FBottomRightRect.Contains(p) then
    Message.Result := HTBOTTOMRIGHT
  else if FLeftRect.Contains(p) then
    Message.Result := HTLEFT
  else if FRightRect.Contains(p) then
    Message.Result := HTRIGHT
  else if FBottomRect.Contains(p) then
    Message.Result := HTBOTTOM
  else if FTopRect.Contains(p) then
    Message.Result := HTTOP
  else
    inherited;
end;

procedure TBaseForm.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  if not FMouseChangeSize then
    Exit;

  if Message.HitTest = HTTOP then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_TOP,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTBOTTOM then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_BOTTOM,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTLEFT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_LEFT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTRIGHT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_RIGHT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTTOPLEFT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_TOPLEFT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTTOPRIGHT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_TOPRIGHT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTBOTTOMLEFT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_BOTTOMLEFT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else if Message.HitTest = HTBOTTOMRIGHT then
    SendMessage(Handle, WM_SYSCOMMAND, SC_SIZE or WMSZ_BOTTOMRIGHT,
      MAKELPARAM(Message.XCursor, Message.YCursor))
  else
    inherited;
end;

procedure TBaseForm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  Monitor: TMonitor;
  p: PMinMaxInfo;
  // rcWorkArea:TRect;
begin
  inherited;
  // GetMonitorInfo()
  // SystemParametersInfo(SPI_GETWORKAREA, 0,rcWorkArea, 0);
  Monitor := Screen.MonitorFromWindow(self.Handle);
  p := Message.MinMaxInfo;
  if Monitor <> nil then
  begin
    p.ptMaxTrackSize.X := Monitor.WorkareaRect.Right -
      Monitor.WorkareaRect.Left;
    // + Abs((Monitor.WorkareaRect.Left - p.ptMaxPosition.X) * 2);
    p.ptMaxTrackSize.Y := Monitor.WorkareaRect.Bottom -
      Monitor.WorkareaRect.Top;
    // + Abs((Monitor.WorkareaRect.Top - p.ptMaxPosition.Y) * 2);
  end;
  // p.ptMinTrackSize.X := 850;
  // p.ptMinTrackSize.Y := 538;
end;

procedure TBaseForm.AdjustClientRect(var Rect: TRect);
begin
  inherited;
  // Rect.Top := Rect.Top + 1;
  // Rect.Left := Rect.Left + 1;
  // Rect.Right := Rect.Right - 1;
  // Rect.Bottom := Rect.Bottom - 1;
end;

procedure TBaseForm.WMSetCursor(var Message: TWMSetCursor);
begin
  case Message.HitTest of
    HTTOPLEFT, HTBOTTOMRIGHT:
      SetCursor(LoadCursor(0, MAKEINTRESOURCE(IDC_SIZENWSE)));
    HTTOPRIGHT, HTBOTTOMLEFT:
      SetCursor(LoadCursor(0, MAKEINTRESOURCE(IDC_SIZENESW)));
    HTLEFT, HTRIGHT:
      SetCursor(LoadCursor(0, MAKEINTRESOURCE(IDC_SIZEWE)));
    HTBOTTOM, HTTOP:
      SetCursor(LoadCursor(0, MAKEINTRESOURCE(IDC_SIZENS)));
  else
    inherited;
  end;
end;

procedure TBaseForm.SetCenter;
var
  vMonitor: TMonitor;
  tmpRect: TRect;
begin
  vMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
  if vMonitor = nil then
    vMonitor := Monitor;
  tmpRect := vMonitor.WorkareaRect;

  if self.Width > tmpRect.Width then  self.Width := tmpRect.Width - 20;
  if self.Height > tmpRect.Height then self.Height :=  tmpRect.Height - 20;


  tmpRect.Left := (tmpRect.Left + tmpRect.Right - Width) div 2;
  tmpRect.Top := (tmpRect.Top + tmpRect.Bottom - Height) div 2;
  Left := tmpRect.Left;
  Top := tmpRect.Top;
end;

procedure TBaseForm.ShowCenter;
begin
  SetCenter;
  Show;
end;

procedure TBaseForm.ShowPos(_Pt: TPoint);
var
  vMonitor: TMonitor;
  tmpRect: TRect;
  tmpSize: Integer;
begin
  tmpSize := 5;
  vMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
  if vMonitor = nil then
    vMonitor := Monitor;
  tmpRect := vMonitor.WorkareaRect;
  if (_Pt.X + Width + tmpSize) > tmpRect.Right then
    _Pt.X := tmpRect.Right - Width - tmpSize;
  if (_Pt.Y + Height + tmpSize) > tmpRect.Bottom then
    _Pt.Y := tmpRect.Bottom - Height - tmpSize;
  Left := _Pt.X;
  Top := _Pt.Y;
  Show;
  if Left <> _Pt.X then
    Left := _Pt.X;
  if Top <> _Pt.Y then
    Top := _Pt.Y;
end;

procedure TBaseForm.UpdateSkin;
begin
  FTitleBar.UpdateSkin;
end;
//******************************************************************************

procedure TBaseTittleForm.DoInitForm;
begin
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) and
    (not WS_THICKFRAME) and (not WS_CAPTION) and (not WS_BORDER));
end;

//procedure TBaseTittleForm.ConnectQuoteManager(const GilAppController: IGilAppController);
//begin
//  if(Assigned(GilAppController))and(Assigned(FTitleBar))then
//    FTitleBar.ConnectQuoteManager(GilAppController);
//end;

{ TTopBaseFrom }

procedure TTopBaseFrom.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := Screen.ActiveForm.Handle; // Application.ActiveFormHandle;
    if (WndParent <> 0) and
      (IsIconic(WndParent) or not IsWindowVisible(WndParent) or
      not IsWindowEnabled(WndParent)) then
      WndParent := 0;
    if WndParent = 0 then
      WndParent := Application.Handle;
  end;
end;

end.
