unit QuoteCommMine;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Controls,
  ExtCtrls,
  Graphics,
  Forms,
  Generics.Collections,
  DateUtils,
  G32Graphic,
  QuoteCommLibrary,
  NativeXml,
  QuotaCommScrollBar,
  Math,
  QuoteCommHint,
  CommonFunc,
  AppContext,
  BaseObject;

const
  Const_StepSize = 20;
  Const_Messages_News = '新闻';
  Const_Messages_Announcement = '公告';
  Const_Messages_ResearchReport = '研报';
  Const_Messages_SpecialNote = '特别提示';

  Const_Pop_News = 'Pop_StockNews';
  Const_Pop_Announcement = 'Pop_StockAnnouncement';
  Const_Pop_ResearchReport = 'Pop_ResearchReport';
  Const_Pop_ReplaceStr_Id = '!id';
  Const_Pop_ReplaceStr_Title = '!title';
  Const_Pop_ReplaceStr_SecuCode = '!secuCode';

  // 输出日志的前缀
  Const_Log_Output_MineInfo_Prefix = 'MineInfo';

type

  TQuoteMineDisplay = class(TBaseObject)
  public

//    FGilAppController: IGilAppController;
    FSkinStyle: string;
    TextFont: TFont;

    BorderLineColor: TColor;
    BackColor: TColor;
    FocusRowBackColor: TColor;
    FontColor: TColor;
    FocusFontColor: TColor;

    RowHeight: Integer;
    MaxRowCount: Integer;
    MaxWidth: Integer;
    EllipsisHight: Integer;
    MinHandleSize: Integer;
    LeftSpace: Integer;
    RightSpace: Integer;
    XSpace: Integer;

    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;
    procedure UpdateSkin;
  end;

  TMineData = class
  private
    FID: string;
    FRect: TRect;
    FTitle: string;
    FInfoType: string;
    FPublicDate: string;
    FFocused: Boolean;
    FIsHint: Boolean;
    FOnClick: TNotifyEvent;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(_Data: TMineData);

    property ID: string read FID write FID;
    property Rect: TRect read FRect write FRect;
    property Title: string read FTitle write FTitle;
    property InfoType: string read FInfoType write FInfoType;
    property PublicDate: string read FPublicDate write FPublicDate;
    property Focused: Boolean read FFocused write FFocused;
    property IsHint: Boolean read FIsHint write FIsHint;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TQuoteMine = class(TForm)
  protected
    FAppContext: IAppContext;
//    FGilAppController: IGilAppController;
    FDisplay: TQuoteMineDisplay;
    FBitmap: TBitmap;
    FMineDatas: TList<TMineData>;
    FVScrollBar: TGaugeBarEx;
    FHideTimer: TTimer;
    FHint: THintControl;
    FFocusMineData: TMineData;
    FInnerCode: Integer;
    FMaxMineDataCount: Integer;
    FCursor: TCursor;
    FNewsUrl: string;
    FNewsWebIPName: string;
    FAnnouncementUrl: string;
    FAnnouncementWebIPName: string;
    FResearchReportUrl: string;
    FResearchReportWebIPName: string;

    FMaxIndex: Integer;
    FMinIndex: Integer;
    FMaxDateWidth: Integer;
    FMaxInfoTypeWidth: Integer;

    procedure InitData;
    procedure InitUrl;

    procedure CleanList(_List: TList<TMineData>);
    procedure UpdateData(_MineDatas: TList<TMineData>); virtual;
    procedure DoClickMine(Sender: TObject);

    procedure CalcMaxMinIndex;
    procedure DoCalcDrawMine;
    procedure DoCalcScrollData;
    procedure Draw;
    procedure DrawBackColor;
    procedure DrawMineDatas; virtual;
    procedure DrawMineData(_Canvas: TCanvas; _MineData: TMineData;
      _BackColor, _FontColor: TColor);
    procedure DrawFocusMineData(_Canvas: TCanvas; _MineData: TMineData;
      _BackColor, _FontColor: TColor);
    function CalcMineData(_Pt: TPoint; var _MineData: TMineData): Boolean;
    procedure EraseRect(_Rect: TRect);

    procedure DoVScrollChange(Sender: TObject);
    procedure DoHideTimer(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint)
      : Boolean; override;
    procedure CMMouseEnter(var Message: TMessage); Message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Resize; override;
    procedure Paint; override;
  public
    constructor CreateNew(AOwner: TComponent; AContext: IAppContext); reintroduce;
    destructor Destroy; override;
    procedure UpdateShow(AList: TList<TMineData>; _Pt: TPoint;
      _InnerCode: Integer);
    procedure UpdateSkin;
    function GetMouseMoveRect: TRect;
    property AppContext: IAppContext read FAppContext;
  end;

implementation

{ TQuoteMineDisplay }

constructor TQuoteMineDisplay.Create(AContext: IAppContext);
begin
  inherited;
  TextFont := TFont.Create;
  TextFont.Name := '微软雅黑';
  TextFont.Charset := GB2312_CHARSET;
  TextFont.Height := -14;

  BorderLineColor := $CCCCCC;
  BackColor := $FFFFFF;
  FocusRowBackColor := $FFFFFF;
  FontColor := $1A1A1A;
  FocusFontColor := $FF0000;

  // BorderLineColor := $0F0F0F;
  // BackColor := $444444;
  // FocusRowBackColor := $737373;
  // FontColor := $FFFFFF;
  // FocusFontColor := $EBA24C;

  RowHeight := 26;
  MaxRowCount := 6;
  EllipsisHight := 10;
  MaxWidth := 500;
  MinHandleSize := 30;
  LeftSpace := 10;
  RightSpace := 10;
  XSpace := 10;
end;

destructor TQuoteMineDisplay.Destroy;
begin
  if Assigned(TextFont) then
    TextFont.Free;
  inherited;
end;

procedure TQuoteMineDisplay.UpdateSkin;
const
  Const_InfoMine_Prefix = 'InfoMine_';
var
  tmpSkinStyle: string;
  function GetStrFromConfig(_Key: WideString): string;
  begin
    Result := FAppContext.GetResourceSkin.GetConfig(Const_InfoMine_Prefix + _Key);
//    Result := FGilAppController.Config(ctSkin, Const_InfoMine_Prefix + _Key);
  end;

  function GetColorFromConfig(_Key: WideString): TColor;
  begin
    Result := FAppContext.GetResourceSkin.GetColor(Const_InfoMine_Prefix + _Key);
//    Result := TColor(HexToIntDef(FGilAppController.Config(ctSkin,
//      Const_InfoMine_Prefix + _Key), 0));
  end;

begin
//  if Assigned(FGilAppController) then
//  begin
    tmpSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle; //FGilAppController.Style;
    if tmpSkinStyle <> FSkinStyle then
    begin
      FSkinStyle := tmpSkinStyle;

      TextFont.Name := GetStrFromConfig('TextFontName');
      BorderLineColor := GetColorFromConfig('BorderLineColor');
      BackColor := GetColorFromConfig('BackColor');
      FocusRowBackColor := GetColorFromConfig('FocusRowBackColor');
      FontColor := GetColorFromConfig('FontColor');
      FocusFontColor := GetColorFromConfig('FocusFontColor');
    end;
//  end;
end;

{ TMineData }

constructor TMineData.Create;
begin
  FID := '';
  FPublicDate := '';
  FTitle := '';
  Focused := false;
  FIsHint := false;
end;

destructor TMineData.Destroy;
begin

  inherited;
end;

procedure TMineData.Assign(_Data: TMineData);
begin
  if Assigned(_Data) then
  begin
    FID := _Data.ID;
    FPublicDate := _Data.PublicDate;
    FTitle := _Data.Title;
    FInfoType := _Data.InfoType;
  end;
end;

{ TQuoteMine }

constructor TQuoteMine.CreateNew(AOwner: TComponent; AContext: IAppContext);
begin
  inherited CreateNew(AOwner);
  FAppContext := AContext;
  FDisplay := TQuoteMineDisplay.Create(AContext);
  FBitmap := TBitmap.Create;
  FMineDatas := TList<TMineData>.Create;
  FHideTimer := TTimer.Create(nil);
  FVScrollBar := TGaugeBarEx.Create(nil);
  FHint := THintControl.Create(nil);
  InitData;
end;

destructor TQuoteMine.Destroy;
begin
  if Assigned(FHint) then
    FHint.HideHint;
  if Assigned(FHideTimer) then
  begin
    FHideTimer.Enabled := false;
    FHideTimer.Free;
  end;
  if Assigned(FMineDatas) then
  begin
    FMineDatas.Count := FMaxMineDataCount;
    CleanList(FMineDatas);
    FMineDatas.Free;
  end;
  if Assigned(FBitmap) then
    FBitmap.Free;
  if Assigned(FDisplay) then
    FDisplay.Free;
  FAppContext := nil;
  inherited;
end;

procedure TQuoteMine.InitData;
begin
  Visible := false;
  Ctl3D := false;
  AutoScroll := false;
  BorderStyle := bsNone;
  Width := FDisplay.MaxWidth;

  FMaxMineDataCount := 0;
  Color := FDisplay.BackColor;

  FHideTimer.Enabled := false;
  FHideTimer.Interval := 300;
  FHideTimer.OnTimer := DoHideTimer;

  FBitmap.Canvas.Font.Assign(FDisplay.TextFont);
  Self.Canvas.Font.Assign(FDisplay.TextFont);

  FCursor := Self.Cursor;

  FNewsUrl := '';
  FAnnouncementUrl := '';
  FResearchReportUrl := '';

  with FVScrollBar do
  begin
    Parent := Self;
    Align := alCustom;
    Kind := sbVertical;
    ShowArrows := false;
    BorderLines := [blLeft, blTop, blRight, blBottom];
    BorderStyle := bsNone;
    OnChange := DoVScrollChange;
    FVScrollBar.LargeChange := 10;
  end;
end;

procedure TQuoteMine.InitUrl;
var
  tmpList: TList;
  tmpIndex: Integer;
  tmpXML: TNativeXml;
  tmpFilePath: string;
  // tmpStream: TResourceStream;
  tmpRoot, tmpNode, tmpChildNode: TXmlNode;
begin
  // try
  // tmpStream := GetResStream(Const_Web_ConfigDLL_ResourceName_ModuleURL);
  // tmpXML := TNativeXml.Create(nil);
  // tmpList := TList.Create;
  // try
  // tmpXML.LoadFromStream(tmpStream);
  // tmpXML.XmlFormat := xfReadable;
  // tmpRoot := tmpXML.Root;
  // tmpRoot.FindNodes(Const_Web_Module, tmpList);
  // for tmpIndex := 0 to tmpList.Count - 1 do
  // begin
  // tmpNode := TXmlNode(tmpList.Items[tmpIndex]);
  // tmpChildNode := tmpNode.FindNode(Const_Web_ModuleAsila);
  // if Assigned(tmpChildNode) then
  // begin
  // if (tmpChildNode.Value = Const_Pop_News) then
  // begin
  // tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
  // if Assigned(tmpChildNode) then
  // FNewsWebIPName := string(tmpChildNode.Value);
  // tmpChildNode := tmpNode.FindNode(Const_Web_URL);
  // if Assigned(tmpChildNode) then
  // FNewsUrl := string(tmpChildNode.Value);
  // end
  // else if (tmpChildNode.Value = Const_Pop_ResearchReport) then
  // begin
  // tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
  // if Assigned(tmpChildNode) then
  // FResearchReportWebIPName := string(tmpChildNode.Value);
  // tmpChildNode := tmpNode.FindNode(Const_Web_URL);
  // if Assigned(tmpChildNode) then
  // FResearchReportUrl := string(tmpChildNode.Value);
  // end
  // else if (tmpChildNode.Value = Const_Pop_Announcement) then
  // begin
  // tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
  // if Assigned(tmpChildNode) then
  // FAnnouncementWebIPName := string(tmpChildNode.Value);
  // tmpChildNode := tmpNode.FindNode(Const_Web_URL);
  // if Assigned(tmpChildNode) then
  // FAnnouncementUrl := string(tmpChildNode.Value);
  // end;
  // end;
  // end;
  // finally
  // if Assigned(tmpList) then
  // begin
  // tmpList.Clear;
  // tmpList.Free;
  // end;
  // if Assigned(tmpXML) then
  // begin
  // tmpXML.Clear;
  // tmpXML.Free;
  // end;
  // end;
  // except
  // on Ex: Exception do
  // if Assigned(FGilAppController) and Assigned(FGilAppController.GetLogWriter)
  // then
  // begin
  // FGilAppController.GetLogWriter.Log(llError,
  // Const_Log_Output_MineInfo_Prefix + ' 找不到此资源' +
  // Const_Web_ConfigDLL_ResourceName_ModuleURL);
  // end;
  // end;

//  if Assigned(FGilAppController) then
//  begin
//    try
//      tmpFilePath := FGilAppController.GetConfigPath + Const_Web_FilePath;
//      if FileExists(tmpFilePath) then
//      begin
//        tmpXML := TNativeXml.Create(nil);
//        tmpXML.LoadFromFile(tmpFilePath);
//        tmpXML.XmlFormat := xfReadable;
//        tmpRoot := tmpXML.Root;
//        tmpList := TList.Create;
//        tmpRoot.FindNodes(Const_Web_Module, tmpList);
//
//        for tmpIndex := 0 to tmpList.Count - 1 do
//        begin
//          tmpNode := TXmlNode(tmpList.Items[tmpIndex]);
//          tmpChildNode := tmpNode.FindNode(Const_Web_ModuleAsila);
//          if Assigned(tmpChildNode) then
//          begin
//            if (tmpChildNode.Value = Const_Pop_News) then
//            begin
//              tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
//              if Assigned(tmpChildNode) then
//                FNewsWebIPName := string(tmpChildNode.Value);
//              tmpChildNode := tmpNode.FindNode(Const_Web_URL);
//              if Assigned(tmpChildNode) then
//                FNewsUrl := string(tmpChildNode.Value);
//            end
//            else if (tmpChildNode.Value = Const_Pop_ResearchReport) then
//            begin
//              tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
//              if Assigned(tmpChildNode) then
//                FResearchReportWebIPName := tmpChildNode.Value;
//              tmpChildNode := tmpNode.FindNode(Const_Web_URL);
//              if Assigned(tmpChildNode) then
//                FResearchReportUrl := string(tmpChildNode.Value);
//            end
//            else if (tmpChildNode.Value = Const_Pop_Announcement) then
//            begin
//              tmpChildNode := tmpNode.FindNode(Const_Web_WebIPName);
//              if Assigned(tmpChildNode) then
//                FAnnouncementWebIPName := string(tmpChildNode.Value);
//              tmpChildNode := tmpNode.FindNode(Const_Web_URL);
//              if Assigned(tmpChildNode) then
//                FAnnouncementUrl := string(tmpChildNode.Value);
//            end;
//          end;
//        end;
//
//        if Assigned(tmpList) then
//        begin
//          tmpList.Clear;
//          tmpList.Free;
//        end;
//
//        if Assigned(tmpXML) then
//        begin
//          tmpXML.Clear;
//          tmpXML.Free;
//        end;
//      end
//      else
//      begin
//        if Assigned(FGilAppController) and
//          Assigned(FGilAppController.GetLogWriter) then
//        begin
//          FGilAppController.GetLogWriter.Log(llError,
//            Const_Log_Output_MineInfo_Prefix + ' 找不到文件' + tmpFilePath);
//        end;
//      end;
//    except
//      on Ex: Exception do
//      begin
//        if Assigned(FGilAppController) and
//          Assigned(FGilAppController.GetLogWriter) then
//        begin
//          FGilAppController.GetLogWriter.Log(llError,
//            Const_Log_Output_MineInfo_Prefix + ' 读取文件 ' + tmpFilePath + ' 报错');
//        end;
//      end;
//    end;
//  end;

//  FResearchReportUrl := FAppContext.GetCfg.GetWebCfg.GetUrl();
end;

procedure TQuoteMine.CMMouseEnter(var Message: TMessage);
begin
  if FHideTimer.Enabled then
    FHideTimer.Enabled := false;
end;

procedure TQuoteMine.CMMouseLeave(var Message: TMessage);
var
  tmpPt: TPoint;
  tmpRect: TRect;
begin
  if Assigned(FFocusMineData) then
  begin
    FFocusMineData.Focused := false;
    FFocusMineData := nil;
  end;
  tmpPt := ScreenToClient(Mouse.CursorPos);
  tmpRect := Rect(FVScrollBar.Left, FVScrollBar.Top,
    FVScrollBar.Left + FVScrollBar.Width, FVScrollBar.Top + FVScrollBar.Height);
  if not PtInRect(tmpRect, tmpPt) then
    FHideTimer.Enabled := true;
  FHint.HideHint;
end;

procedure TQuoteMine.CleanList(_List: TList<TMineData>);
var
  tmpIndex: Integer;
begin
  if Assigned(_List) then
  begin
    for tmpIndex := 0 to _List.Count - 1 do
      if Assigned(_List.Items[tmpIndex]) then
        TObject(_List[tmpIndex]).Free;
    _List.Clear;
  end;
end;

procedure TQuoteMine.CalcMaxMinIndex;
begin
  with FDisplay do
  begin

  end;
end;

procedure TQuoteMine.DoCalcDrawMine;
begin
  CalcMaxMinIndex;
  Draw;

  Invalidate;
end;

procedure TQuoteMine.DoCalcScrollData;
begin
  with FDisplay do
  begin
    FVScrollBar.Visible := FMineDatas.Count > MaxRowCount;
    FVScrollBar.Position := 0;
    if FVScrollBar.Visible then
    begin
      FVScrollBar.Max := (FMineDatas.Count * RowHeight) - MaxRowCount *
        RowHeight;
      FVScrollBar.Min := 0;
      FVScrollBar.HandleSize := Max(MinHandleSize,
        FVScrollBar.Height * FVScrollBar.Height div (FMineDatas.Count *
        RowHeight));
      // FVScrollBar.Position := 0;
      FVScrollBar.Left := Width - FVScrollBar.Width - 1;
      FVScrollBar.Top := 1;
      FVScrollBar.Height := Height - 2;
    end;
  end;
end;

procedure TQuoteMine.Draw;
begin
  DrawBackColor;
  DrawMineDatas;
end;

procedure TQuoteMine.DrawBackColor;
begin
  with FBitmap, FDisplay do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.Pen.Color := BorderLineColor;
    Canvas.Rectangle(Rect(0, 0, Width, Height));
  end;
end;

procedure TQuoteMine.DrawMineDatas;
var
  tmpRect: TRect;
  tmpClipRgn: HRGN;
  tmpMineData: TMineData;
  tmpIndex, tmpTop, tmpHeight: Integer;
begin
  with FBitmap, FDisplay do
  begin
    FMinIndex := 0;
    FMaxIndex := FMineDatas.Count - 1;
    if FMineDatas.Count > MaxRowCount then
    begin
      FMinIndex := FVScrollBar.Position div RowHeight;
      FMaxIndex := FMinIndex + MaxRowCount - 1;
    end;

    tmpRect := Rect(1, 1, Width - FVScrollBar.Width - 1, Height - 1);
    tmpClipRgn := CreateRectRgn(tmpRect.Left, tmpRect.Top, tmpRect.Right,
      tmpRect.Bottom);
    if FVScrollBar.Visible then
    begin
      tmpHeight := (FVScrollBar.Position div RowHeight) * RowHeight;
      if ((tmpHeight + RowHeight) > FVScrollBar.Position) and
        (FVScrollBar.Position > tmpHeight) then
      begin
        tmpTop := tmpHeight - FVScrollBar.Position;
        FMaxIndex := FMaxIndex + 1;
      end
      else
        tmpTop := 0;
    end
    else
      tmpTop := 0;

    if FMaxIndex > FMineDatas.Count - 1 then
      FMaxIndex := FMineDatas.Count - 1;

    SelectClipRgn(Canvas.Handle, tmpClipRgn);
    try
      for tmpIndex := FMinIndex to FMaxIndex do
      begin
        tmpMineData := FMineDatas.Items[tmpIndex];
        if Assigned(tmpMineData) then
        begin
          tmpMineData.Rect := Rect(0, tmpTop, Width - FVScrollBar.Width - 1,
            tmpTop + RowHeight);
          DrawMineData(Canvas, tmpMineData, BackColor, FontColor);
          tmpTop := tmpMineData.Rect.Bottom;
        end;
      end;
    finally
      SelectClipRgn(Canvas.Handle, 0);
      DeleteObject(tmpClipRgn);
    end;
  end;
end;

procedure TQuoteMine.EraseRect(_Rect: TRect);
begin
  DrawCopyRect(Self.Canvas.Handle, _Rect, FBitmap.Canvas.Handle, _Rect);
end;

function TQuoteMine.GetMouseMoveRect: TRect;
var
  tmpPtLeftTop, tmpPtRightBottom: TPoint;
begin
  Result := GetClientRect;
  Result.Inflate(10, 10, 0, 0);
  tmpPtLeftTop := ClientToScreen(Result.TopLeft);
  tmpPtRightBottom := ClientToScreen(Result.BottomRight);
  Result := Rect(tmpPtLeftTop.X, tmpPtLeftTop.Y, tmpPtRightBottom.X,
    tmpPtRightBottom.Y);
end;

procedure TQuoteMine.DrawMineData(_Canvas: TCanvas; _MineData: TMineData;
  _BackColor, _FontColor: TColor);
var
  tmpRect: TRect;
begin
  with FDisplay do
  begin
    _Canvas.Brush.Color := _BackColor;
    _Canvas.Font.Color := _FontColor;
    tmpRect := _MineData.Rect;
    tmpRect.Left := tmpRect.Left + LeftSpace;
    tmpRect.Right := tmpRect.Left + FMaxDateWidth;
    DrawTextOut(_Canvas.Handle, tmpRect, _MineData.PublicDate, gtaLeft);

    tmpRect.Left := tmpRect.Right + XSpace;
    tmpRect.Right := tmpRect.Left + FMaxInfoTypeWidth;
    DrawTextOut(_Canvas.Handle, tmpRect, _MineData.InfoType, gtaLeft);

    tmpRect.Left := tmpRect.Right + XSpace;
    tmpRect.Right := _MineData.Rect.Right;
    _MineData.IsHint := _Canvas.TextWidth(_MineData.Title) > tmpRect.Width;
    DrawTextOut(_Canvas.Handle, tmpRect, _MineData.Title, gtaLeft, true);
  end;
end;

procedure TQuoteMine.DrawFocusMineData(_Canvas: TCanvas; _MineData: TMineData;
  _BackColor, _FontColor: TColor);
var
  tmpClipRgn: HRGN;
begin
  with FBitmap, FDisplay do
  begin
    tmpClipRgn := CreateRectRgn(1, 1, Width - FVScrollBar.Width - 1,
      Height - 1);
    SelectClipRgn(_Canvas.Handle, tmpClipRgn);
    try
      _Canvas.Brush.Color := _BackColor;
      _Canvas.FillRect(_MineData.Rect);
      DrawMineData(_Canvas, _MineData, _BackColor, _FontColor);
    finally
      SelectClipRgn(_Canvas.Handle, 0);
      DeleteObject(tmpClipRgn);
    end;
  end;
end;

function TQuoteMine.CalcMineData(_Pt: TPoint; var _MineData: TMineData)
  : Boolean;
var
  tmpIndex: Integer;
begin
  Result := false;
  for tmpIndex := FMinIndex to FMaxIndex do
  begin
    _MineData := FMineDatas.Items[tmpIndex];
    if Assigned(_MineData) and PtInRect(_MineData.Rect, _Pt) then
    begin
      Result := true;
      Break;
    end;
  end;
end;

procedure TQuoteMine.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := WS_POPUP;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;

    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
  Params.WndParent := Screen.ActiveForm.Handle;
  if (Params.WndParent <> 0) and
    (IsIconic(Params.WndParent) or not IsWindowVisible(Params.WndParent) or
    not IsWindowEnabled(Params.WndParent)) then
    Params.WndParent := 0;
  if Params.WndParent = 0 then
    Params.WndParent := Application.Handle;
end;

function TQuoteMine.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := true;
  if (FVScrollBar.Position + Const_StepSize) <= FVScrollBar.Max then
    FVScrollBar.Position := FVScrollBar.Position + Const_StepSize
  else
    FVScrollBar.Position := FVScrollBar.Max;
end;

function TQuoteMine.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := true;
  if (FVScrollBar.Position - Const_StepSize) >= FVScrollBar.Min then
    FVScrollBar.Position := FVScrollBar.Position - Const_StepSize
  else
    FVScrollBar.Position := FVScrollBar.Min;
end;

procedure TQuoteMine.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpPt: TPoint;
  tmpMineData: TMineData;
begin
  inherited MouseMove(Shift, X, Y);
  with FBitmap, FDisplay do
  begin
    if CalcMineData(Point(X, Y), tmpMineData) then
    begin
      if (Self.Cursor <> crHandPoint) and
        (tmpMineData.InfoType <> Const_Messages_SpecialNote) then
        Self.Cursor := crHandPoint;
      if (Self.Cursor <> FCursor) and
        (tmpMineData.InfoType = Const_Messages_SpecialNote) then
        Self.Cursor := FCursor;
      if not tmpMineData.Focused then
      begin
        if Assigned(FFocusMineData) and FFocusMineData.Focused then
        begin
          FFocusMineData.Focused := false;
          EraseRect(FFocusMineData.Rect);
        end;
        FFocusMineData := tmpMineData;
        tmpMineData.Focused := true;
        DrawFocusMineData(Self.Canvas, tmpMineData, BackColor, FocusFontColor);
      end;
      if tmpMineData.IsHint then
      begin
        tmpPt := ClientToScreen(Point(tmpMineData.Rect.Left + 65,
          tmpMineData.Rect.Bottom + 5));
        FHint.ShowHint(tmpMineData.Title, tmpPt.X, tmpPt.Y);
      end
      else
        FHint.HideHint;
    end
    else
    begin
      if Assigned(FFocusMineData) and FFocusMineData.Focused then
      begin
        FFocusMineData.Focused := false;
        EraseRect(FFocusMineData.Rect);
        if Self.Cursor <> FCursor then
          Self.Cursor := FCursor;
      end;
      FHint.HideHint;
    end;
  end;
end;

procedure TQuoteMine.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  tmpMineData: TMineData;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if CalcMineData(Point(X, Y), tmpMineData) then
  begin
    if tmpMineData.InfoType <> Const_Messages_SpecialNote then
    begin
      Hide;
      if Assigned(tmpMineData.OnClick) then
        tmpMineData.OnClick(tmpMineData);
    end;
  end;
end;

procedure TQuoteMine.Paint;
var
  tmpRect: TRect;
begin
  if not(csDesigning in ComponentState) and (HandleAllocated) and
    (FBitmap <> nil) then
  begin
    Canvas.Lock;
    try
      tmpRect := Rect(0, 0, Width, Height);
      DrawCopyRect(Canvas.Handle, tmpRect, FBitmap.Canvas.Handle, tmpRect);
    finally
      Canvas.UnLock;
    end;
  end
  else
    inherited;
end;

procedure TQuoteMine.Resize;
begin
  if (FBitmap.Width <> Width) or (FBitmap.Height <> Height) then
  begin
    FBitmap.Canvas.Lock;
    try
      FBitmap.SetSize(Width, Height);
    finally
      FBitmap.Canvas.UnLock;
    end;
    DoCalcScrollData;
    DoCalcDrawMine;
  end;
end;

procedure TQuoteMine.DoVScrollChange(Sender: TObject);
begin
  DoCalcDrawMine;
end;

procedure TQuoteMine.DoHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := false;
  FHint.HideHint;
  Hide;
end;

procedure TQuoteMine.UpdateData(_MineDatas: TList<TMineData>);
var
  tmpMineData, tmpNewMineData: TMineData;
  tmpIndex, tmpWidth, tmpTitleWidth: Integer;
begin
  with FDisplay do
  begin
    FFocusMineData := nil;
    tmpTitleWidth := 0;
    FMaxDateWidth := 0;
    FMaxInfoTypeWidth := 0;
    if Assigned(_MineDatas) then
    begin
      FMineDatas.Count := _MineDatas.Count;
      if FMineDatas.Count > FMaxMineDataCount then
        FMaxMineDataCount := FMineDatas.Count;
      for tmpIndex := 0 to _MineDatas.Count - 1 do
      begin
        tmpMineData := _MineDatas.Items[tmpIndex];
        if Assigned(tmpMineData) then
        begin
          if FMineDatas.Items[tmpIndex] = nil then
          begin
            tmpNewMineData := TMineData.Create;
            tmpNewMineData.OnClick := DoClickMine;
            FMineDatas.Items[tmpIndex] := tmpNewMineData;
          end
          else
            tmpNewMineData := FMineDatas.Items[tmpIndex];
          tmpNewMineData.Assign(tmpMineData);
          tmpNewMineData.Focused := false;

          tmpWidth := FBitmap.Canvas.TextWidth(tmpNewMineData.PublicDate);
          if tmpWidth > FMaxDateWidth then
            FMaxDateWidth := tmpWidth;
          tmpWidth := FBitmap.Canvas.TextWidth(tmpNewMineData.InfoType);
          if tmpWidth > FMaxInfoTypeWidth then
            FMaxInfoTypeWidth := tmpWidth;
          tmpWidth := FBitmap.Canvas.TextWidth(tmpNewMineData.Title);
          if tmpWidth > tmpTitleWidth then
            tmpTitleWidth := tmpWidth;
        end;
      end;
    end;

    tmpWidth := LeftSpace + FMaxDateWidth + XSpace + FMaxInfoTypeWidth + XSpace
      + tmpTitleWidth + XSpace + FVScrollBar.Width + 2;
    if tmpWidth < MaxWidth then
      Width := tmpWidth
    else
      Width := MaxWidth;
    if FMineDatas.Count <= MaxRowCount then
      Height := FMineDatas.Count * RowHeight
    else
      Height := MaxRowCount * RowHeight;
  end;
end;

procedure TQuoteMine.DoClickMine(Sender: TObject);
var
  tmpPos: Integer;
  tmpMineData: TMineData;
  tmpUrl, tmpServerIP, tmpSecuCode: string;
//  tmpStockInfoRec: StockInfoRec;
begin
  tmpMineData := TMineData(Sender);
  if Assigned(tmpMineData) then
  begin
    tmpUrl := '';
    tmpServerIP := '';
    if tmpMineData.InfoType = Const_Messages_News then
    begin
      tmpUrl := StringReplace(FNewsUrl, Const_Pop_ReplaceStr_Id, tmpMineData.ID,
        [rfReplaceAll]);
      tmpUrl := StringReplace(tmpUrl, Const_Pop_ReplaceStr_Title,
        tmpMineData.Title, [rfReplaceAll]);
//      if Assigned(FGilAppController) then
//        tmpServerIP := FGilAppController.GetWebIP(FNewsWebIPName);
    end
    else if tmpMineData.InfoType = Const_Messages_Announcement then
    begin
//      if FGilAppController.QueryStockInfo(FInnerCode, tmpStockInfoRec) then
//      begin
//        tmpSecuCode := tmpStockInfoRec.GPDM;
//        tmpPos := Pos('.', tmpSecuCode);
//        if tmpPos > 0 then
//        begin
//          Delete(tmpSecuCode, tmpPos, Length(tmpSecuCode));
//        end;
//      end
//      else
//        tmpSecuCode := '';
      tmpUrl := StringReplace(FAnnouncementUrl, Const_Pop_ReplaceStr_Id,
        tmpMineData.ID, [rfReplaceAll]);
      tmpUrl := StringReplace(tmpUrl, Const_Pop_ReplaceStr_SecuCode,
        IntToStr(FInnerCode), [rfReplaceAll]);
      tmpUrl := StringReplace(tmpUrl, Const_Pop_ReplaceStr_Title,
        tmpMineData.Title, [rfReplaceAll]);
//      if Assigned(FGilAppController) then
//        tmpServerIP := FGilAppController.GetWebIP(FAnnouncementWebIPName);
    end
    else if tmpMineData.InfoType = Const_Messages_ResearchReport then
    begin
      tmpUrl := StringReplace(FResearchReportUrl, Const_Pop_ReplaceStr_Id,
        tmpMineData.ID, [rfReplaceAll]);
      tmpUrl := StringReplace(tmpUrl, Const_Pop_ReplaceStr_Title,
        tmpMineData.Title, [rfReplaceAll]);
//      if Assigned(FGilAppController) then
//        tmpServerIP := FGilAppController.GetWebIP(FResearchReportWebIPName);
    end;
//    if Assigned(FGilAppController) and (tmpUrl <> '') then
//    begin
//      tmpUrl := StringReplace(tmpUrl, Const_Web_WebIPName_ReplaceStr,
//        tmpServerIP, [rfReplaceAll]);
//      FGilAppController.CreateModuleByAlias(Const_Asila_Chromium, tmpUrl);
//    end;
  end;
end;

procedure TQuoteMine.UpdateShow(AList: TList<TMineData>; _Pt: TPoint;
  _InnerCode: Integer);
var
  tmpRect: TRect;
  tmpMonitor: TMonitor;
begin
  FInnerCode := _InnerCode;
  UpdateData(AList);
  DoCalcScrollData;
  DoCalcDrawMine;
  tmpMonitor := Screen.MonitorFromWindow(GetActiveWindow);
  if tmpMonitor <> nil then
  begin
    tmpRect := Monitor.WorkareaRect;
    if _Pt.X + Self.Width > tmpRect.Right then
      _Pt.X := tmpRect.Right - Self.Width - 5;
    if _Pt.Y + Self.Height > tmpRect.Bottom then
      _Pt.Y := tmpRect.Bottom - Self.Height - 5;
  end;
  Left := _Pt.X;
  Top := _Pt.Y;
  Show;
end;

procedure TQuoteMine.UpdateSkin;
begin
  FDisplay.UpdateSkin;
  FVScrollBar.UpdateSkin(FAppContext);
  DoCalcDrawMine;
end;

end.
