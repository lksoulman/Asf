unit QuoteTimeMenu;

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseForm,
  QuoteCommMenu,
  QuoteCommStack,
  QuoteTimeMenuIntf,
  QuoteTimeStruct,
  QuoteTimeHandle,
  QuoteTimeGraph,
  QuoteTimeData,
  SelfRightMenuComm,
  QuoteCommLibrary,
  AppContext;

const

  Const_Stock_AddSelf = '添加自选股';
  Const_Stock_DelSelf = '删除自选股';

type

  TQuoteTimeMenu = class(TSelfRightMenuComm, IQuoteTimeMenu)
  protected
    FTimeGraphs: TQuoteTimeGraphs;
    FQuoteStack: TQuoteStack;
    // FSelfStockMenuItem: TGilMenuItem;
    FSymmetryAxisMenuItem: TGilMenuItem;
    FLimitAxisMenuItem: TGilMenuItem;
    FFullAxisMenuItem: TGilMenuItem;
    // FInnerCode: Integer;

    procedure DoClickMenuItem(Sender: TObject);
    procedure DoSelfStockChange(AInnerCode, AOperateType: Integer);
    procedure DoStackChange(OperateType: TStackOperateType; InnerCode: Integer);
  public
    constructor Create(AContext: IAppContext; _TimeGraphs: TQuoteTimeGraphs); reintroduce;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController;
//      const NotifySvr: INotifyServices); override;
//    procedure DisConnectQuoteManager; override;
    procedure ChangeStock(_InnerCode: Integer); override;
    procedure UpdateSkin; override;

    procedure MainMenu(const _Pt: TPoint); safecall;
    function HotKey(_ShortCut: TShortCut): boolean; safecall;
    function GetTimeMenuVisible: boolean; safecall;
    procedure AddUserBehavior(UserBehavior: string); safecall;

    procedure AddMenus;
    property QuoteStack: TQuoteStack read FQuoteStack;
  end;

implementation

{ TQuoteTimeMenu }

constructor TQuoteTimeMenu.Create(AContext: IAppContext;
  _TimeGraphs: TQuoteTimeGraphs);
begin
  inherited Create(AContext);
  FTimeGraphs := _TimeGraphs;
  FQuoteStack := TQuoteStack.Create(AContext, ltTime);
  FQuoteStack.OnStackChange := DoStackChange;
end;

destructor TQuoteTimeMenu.Destroy;
begin
  if Assigned(FQuoteStack) then
    FQuoteStack.Free;
  inherited;
end;

procedure TQuoteTimeMenu.ChangeStock(_InnerCode: Integer);
begin
  FInnerCode := _InnerCode;
  if Assigned(FQuoteStack) then
    FQuoteStack.ChangeStock(_InnerCode);
end;
//
//procedure TQuoteTimeMenu.ConnectQuoteManager(const GilAppController
//  : IGilAppController; const NotifySvr: INotifyServices);
//begin
//  inherited ConnectQuoteManager(GilAppController, NotifySvr);
//  FQuoteStack.ConnectQuoteManager(GilAppController);
//  FOnSelfStockChange := DoSelfStockChange;
//end;
//
//procedure TQuoteTimeMenu.DisConnectQuoteManager;
//begin
//  inherited DisConnectQuoteManager;
//end;

procedure TQuoteTimeMenu.AddMenus;
var
  tmpMenuItem: TGilMenuItem;
begin
  with FTimeGraphs do
  begin
    // tmpMenuItem := AddMenuItem('添加自选股', 'StackVarieties');
    // tmpMenuItem.IconType := ditImage;
    // tmpMenuItem.ResourceName := Const_ResourceName_RightMenu_AddStock;
    // tmpMenuItem.OnClick := DoClickMenuItem;
    // tmpMenuItem.Id := 0;
    // tmpMenuItem.Key := 'quote-singlesecuinfo-042501';
    // FSelfStockMenuItem := tmpMenuItem;

    AddSelfStockMenu;

    tmpMenuItem := AddMenuItem('叠加品种', 'StackVarieties');
    tmpMenuItem.IconType := ditText;
    tmpMenuItem.IconText := '叠';
    tmpMenuItem.OnClick := DoClickMenuItem;
    tmpMenuItem.Id := 1;
    tmpMenuItem.Key := 'quote-singlesecuinfo-042502';

    tmpMenuItem := AddMenuItem('普通坐标', 'GeneralYAxis');
    tmpMenuItem.IconType := ditRadioBox;
    tmpMenuItem.OnClick := DoClickMenuItem;
    tmpMenuItem.Id := 2;
    tmpMenuItem.Key := 'quote-singlesecuinfo-042503';
    tmpMenuItem.Radioed := Display.MainGraphYAxisType = atSymmetry;
    FSymmetryAxisMenuItem := tmpMenuItem;

    tmpMenuItem := AddMenuItem('涨停坐标', 'HighStopYAxis');
    tmpMenuItem.IconType := ditRadioBox;
    tmpMenuItem.OnClick := DoClickMenuItem;
    tmpMenuItem.Id := 3;
    tmpMenuItem.Key := 'quote-singlesecuinfo-042504';
    tmpMenuItem.Radioed := Display.MainGraphYAxisType = atLimitAxis;
    FLimitAxisMenuItem := tmpMenuItem;

    tmpMenuItem := AddMenuItem('放大坐标', 'EnlargeYAxis');
    tmpMenuItem.IconType := ditRadioBox;
    tmpMenuItem.OnClick := DoClickMenuItem;
    tmpMenuItem.Id := 4;
    tmpMenuItem.Key := 'quote-singlesecuinfo-042505';
    tmpMenuItem.Radioed := Display.MainGraphYAxisType = atFullAxis;
    FFullAxisMenuItem := tmpMenuItem;
  end;
end;

procedure TQuoteTimeMenu.MainMenu(const _Pt: TPoint);
var
  tmpMainData: TTimeData;
//  LStockInfoRec: StockInfoRec;
begin
  // if FTimeGraphs.QuoteTimeData.IsSelfStock and
  // (FSelfStockMenuItem.Caption <> Const_Stock_DelSelf) then
  // begin
  // FSelfStockMenuItem.ResourceName := Const_ResourceName_RightMenu_DelStock;
  // FSelfStockMenuItem.Caption := Const_Stock_DelSelf;
  // end
  // else if not FTimeGraphs.QuoteTimeData.IsSelfStock and
  // (FSelfStockMenuItem.Caption <> Const_Stock_AddSelf) then
  // begin
  // FSelfStockMenuItem.ResourceName := Const_ResourceName_RightMenu_AddStock;
  // FSelfStockMenuItem.Caption := Const_Stock_AddSelf;
  // end;

  tmpMainData := FTimeGraphs.QuoteTimeData.MainData;
  if Assigned(tmpMainData) then
  begin
    FLimitAxisMenuItem.Enable := FTimeGraphs.QuoteTimeData.MainData.
      HasLimitAixs;
    if FTimeGraphs.Display.MainGraphYAxisType = atLimitAxis then
    begin
      if tmpMainData.HasLimitAixs then
      begin
        if not FLimitAxisMenuItem.Radioed then
          FLimitAxisMenuItem.Radioed := True;
      end
      else
      begin
        if FLimitAxisMenuItem.Radioed then
          FSymmetryAxisMenuItem.Radioed := True;
      end;
    end
    else if (FTimeGraphs.Display.MainGraphYAxisType = atFullAxis) and
      (not FFullAxisMenuItem.Radioed) then
    begin
      FFullAxisMenuItem.Radioed := True;
    end
    else if (FTimeGraphs.Display.MainGraphYAxisType = atSymmetry) and
      (not FSymmetryAxisMenuItem.Radioed) then
    begin
      FSymmetryAxisMenuItem.Radioed := True;
    end;
  end;
//  if Assigned(FGilAppController)
//    and FGilAppController.QueryStockInfo(FInnerCode, LStockInfoRec)
//    and IsForeignIndex(LStockInfoRec.ZQLB, LStockInfoRec.ZQSC) then begin
//    if FSelfStockManagerItem.Enable then begin
//      FSelfStockManagerItem.Enable := False;
//    end;
//  end else begin
//    if not FSelfStockManagerItem.Enable then begin
//      FSelfStockManagerItem.Enable := True;
//    end;
//  end;
  PopMenu(_Pt);
  AddUserBehavior('quote-singlesecuinfo-0425');
end;

procedure TQuoteTimeMenu.DoClickMenuItem(Sender: TObject);
const
  constAxisType: array [2 .. 4] of TAxisType = (atSymmetry, atLimitAxis,
    atFullAxis);
var
  tmpMenuItem: TGilMenuItem;
begin
  with FTimeGraphs do
  begin
    tmpMenuItem := TGilMenuItem(Sender);
    if Assigned(tmpMenuItem) then
    begin
      case tmpMenuItem.Id of
        // 0:
        // begin
        // if tmpMenuItem.Caption = Const_Stock_AddSelf then
        // FTimeGraphs.QuoteTimeData.SelfStockOperate(ssoAdd)
        // else
        // FTimeGraphs.QuoteTimeData.SelfStockOperate(ssoDel);
        // end;
        1:
          begin
            if not FQuoteStack.Visible then
              FQuoteStack.ShowCenter;
          end;
        2, 3, 4:
          begin
            if tmpMenuItem.IconType = ditRadioBox then
            begin
              tmpMenuItem.Radioed := True;
              if Display.MainGraphYAxisType <> constAxisType[tmpMenuItem.Id]
              then
              begin
                Display.MainGraphYAxisType := constAxisType[tmpMenuItem.Id];
                QuoteTimeData.OnInvalidate;
              end;
            end;
          end;
      end;

    end;
  end;
end;

procedure TQuoteTimeMenu.DoSelfStockChange(AInnerCode, AOperateType: Integer);
begin
  AddUserBehavior('quote-singlesecuinfo-042501');
end;

procedure TQuoteTimeMenu.AddUserBehavior(UserBehavior: string);
begin
//  if (UserBehavior <> '') and Assigned(FGilAppController) then
//    FGilAppController.AddUserBehavior(UserBehavior);
end;

procedure TQuoteTimeMenu.DoStackChange(OperateType: TStackOperateType;
  InnerCode: Integer);
var
  tmpInnerCodes: TInnerCodes;
begin
  with FTimeGraphs.QuoteTimeData do
  begin
    CleanStack;
    FQuoteStack.GetStackInnerCodes(tmpInnerCodes);
    SubscribeStack(tmpInnerCodes, Length(tmpInnerCodes));
    OnInvalidate;
  end;
end;

function TQuoteTimeMenu.GetTimeMenuVisible: boolean;
begin
  Result := FMenuWindow.Visible;
end;

function TQuoteTimeMenu.HotKey(_ShortCut: TShortCut): boolean;
begin

end;

procedure TQuoteTimeMenu.UpdateSkin;
begin
  inherited;
  if Assigned(FQuoteStack) then
    FQuoteStack.UpdateSkin;
end;

end.
