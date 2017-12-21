unit SelfRightMenuComm;

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  QuoteCommMenu;

const
  Const_SelfStockManager_Name = '自选管理';
  Const_SelfStockDeleteAll_ID = -1;
  Const_SelfStockDeleteAll_Name = '删除所有';

  Const_SelfStockOperateType_Del = 0;
  Const_SelfStockOperateType_Add = 1;

type

  TOnSelfStockChangeEvent = procedure(AInnerCode, AOperateType: Integer) of object;

  TSelfRightMenuComm = class(TGilPopMenu)
  protected
    FInnerCode: Integer;
//    FGilRanges: IGilRanges;
//    FNotify: INotify;
//    FNotifySvr: INotifyServices;
    FSelfStockManagerItem: TGilMenuItem;
    FOnSelfStockChange: TOnSelfStockChangeEvent;

//    procedure LoadSelfStockPlate; virtual;
//    procedure UpdateSelfMenuState; virtual;
//    procedure DoClickSelfStockMenuItem(Sender: TObject); virtual;
//    procedure DoRangeChange(NotifyType: NotifyTypeEnum; Param: NativeUInt);
  public
    constructor Create(AContext: IAppContext); override;
    destructor Destroy; override;
//    procedure ConnectQuoteManager(const GilAppController: IGilAppController;
//      const NotifySvr: INotifyServices); reintroduce; virtual;
//    procedure DisConnectQuoteManager; override;
    procedure AddSelfStockMenu;
    procedure ChangeStock(_InnerCode: Integer); virtual;
    procedure PopMenu(_Pt: TPoint); override;

    property OnSelfStockChange: TOnSelfStockChangeEvent read FOnSelfStockChange write FOnSelfStockChange;
  end;

implementation

{ TSelfRightMenuComm }

constructor TSelfRightMenuComm.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TSelfRightMenuComm.Destroy;
begin

  inherited;
end;

//procedure TSelfRightMenuComm.ConnectQuoteManager(const GilAppController
//  : IGilAppController; const NotifySvr: INotifyServices);
//var
//  Unknown: IInterface;
//  tmpNotify: TNotifyMessage;
//begin
//  inherited ConnectQuoteManager(GilAppController);
//  if FGilAppController.QueryInterface(IGilRanges, Unknown) then
//    FGilRanges := Unknown as IGilRanges;
//
//  FNotifySvr := NotifySvr;
//  tmpNotify := TNotifyMessage.Create(NotifySvr, GilAppController, 'TSelfRightMenuComm');
//  tmpNotify.OnRangeChange := DoRangeChange;
//  FNotify := tmpNotify;
//  FNotify.Connect();
//
//  LoadSelfStockPlate;
//end;

//procedure TSelfRightMenuComm.DisConnectQuoteManager;
//begin
//  if Assigned(FNotify) then
//  begin
//    FNotify.DisConnect;
//    FNotify := nil;
//  end;
//  FNotifySvr := nil;
//  inherited;
//end;

procedure TSelfRightMenuComm.AddSelfStockMenu;
begin
  FSelfStockManagerItem := AddMenuItem(Const_SelfStockManager_Name,
    'SelfStockManager');
  FSelfStockManagerItem.ResourceName :=
    Const_ResourceName_RightMenu_SelfManager;
  FSelfStockManagerItem.IconType := ditImage;
  FSelfStockManagerItem.IsSubMenuItem := True;
end;

//procedure TSelfRightMenuComm.LoadSelfStockPlate;
//var
//  tmpIndex: Integer;
//  tmpMenuItem: TGilMenuItem;
//  tmpRangeItem: IRangeItem;
//  tmpUserRange: IUserRangeItem;
//begin
//  if Assigned(FGilRanges) and Assigned(FSelfStockManagerItem) and
//    Assigned(FSelfStockManagerItem.SubMenu) then
//  begin
//    FSelfStockManagerItem.SubMenu.ClearMenus;
//    tmpMenuItem := FSelfStockManagerItem.SubMenu.AddMenuItem
//      (Const_SelfStockDeleteAll_Name, 'SelfStockDeleteAll');
//    tmpMenuItem.ID := Const_SelfStockDeleteAll_ID;
//    tmpMenuItem.OnClick := DoClickSelfStockMenuItem;
//    tmpUserRange := FGilRanges.GetUserRange;
//    if Assigned(tmpUserRange) then
//    begin
//      for tmpIndex := 0 to tmpUserRange.ItemCount - 1 do
//      begin
//        tmpRangeItem := tmpUserRange.Items(tmpIndex);
//        if Assigned(tmpRangeItem) then
//        begin
//          tmpMenuItem := FSelfStockManagerItem.SubMenu.AddMenuItem
//            (tmpRangeItem.Get_RangeName, IntToStr(tmpIndex));
//          tmpMenuItem.IconType := ditImage;
//          tmpMenuItem.OnClick := DoClickSelfStockMenuItem;
//          tmpMenuItem.ID := tmpIndex;
//        end;
//      end;
//    end;
//  end;
//end;

//procedure TSelfRightMenuComm.UpdateSelfMenuState;
//var
//  tmpIndex: Integer;
//  tmpStockFlag: Integer;
//  tmpIsSelfStock: Boolean;
//  tmpMenuItem: TGilMenuItem;
//begin
//  if Assigned(FGilRanges) and Assigned(FSelfStockManagerItem) and
//    Assigned(FSelfStockManagerItem.SubMenu) then
//  begin
//    tmpStockFlag := FGilRanges.GetStockAttributeEx(FInnerCode);
//    for tmpIndex := 1 to FSelfStockManagerItem.SubMenu.MenuItemCount - 1 do
//    begin
//      tmpIsSelfStock := ((tmpStockFlag and STOCK_ATTRIBUTE_SELF_SEL)
//        = STOCK_ATTRIBUTE_SELF_SEL);
//      tmpMenuItem := FSelfStockManagerItem.SubMenu.MenuItems[tmpIndex];
//      if Assigned(tmpMenuItem) then
//      begin
//        if tmpIsSelfStock then
//          tmpMenuItem.ResourceName := Const_ResourceName_RightMenu_DelStock
//        else
//          tmpMenuItem.ResourceName := Const_ResourceName_RightMenu_AddStock;
//      end;
//      tmpStockFlag := tmpStockFlag shr 1;
//    end;
//  end;
//end;

//procedure TSelfRightMenuComm.DoClickSelfStockMenuItem(Sender: TObject);
//var
//  tmpMenuItem: TGilMenuItem;
//begin
//  if Assigned(FGilRanges) and Assigned(Self.MenuWindow) then
//  begin
//    tmpMenuItem := TGilMenuItem(Sender);
//    if tmpMenuItem.ID = Const_SelfStockDeleteAll_ID then
//    begin
//      FGilRanges.DelSecuFromAllPlates(FInnerCode);
//      FGilRanges.UserRangeChange(Self.MenuWindow.Handle);
//      if Assigned(FOnSelfStockChange) then
//        FOnSelfStockChange(FInnerCode, Const_SelfStockOperateType_Del);
//    end
//    else
//    begin
//      if tmpMenuItem.ResourceName = Const_ResourceName_RightMenu_AddStock then
//      begin
//        tmpMenuItem.ResourceName := Const_ResourceName_RightMenu_DelStock;
//        FGilRanges.AddSecu(FInnerCode, tmpMenuItem.ID);
//        FGilRanges.UserRangeChange(Self.MenuWindow.Handle);
//        if Assigned(FOnSelfStockChange) then
//          FOnSelfStockChange(FInnerCode, Const_SelfStockOperateType_Add);
//      end
//      else if tmpMenuItem.ResourceName = Const_ResourceName_RightMenu_DelStock
//      then
//      begin
//        tmpMenuItem.ResourceName := Const_ResourceName_RightMenu_AddStock;
//        FGilRanges.DelSecu(FInnerCode, tmpMenuItem.ID);
//        FGilRanges.UserRangeChange(Self.MenuWindow.Handle);
//
//        if Assigned(FOnSelfStockChange) then
//          FOnSelfStockChange(FInnerCode, Const_SelfStockOperateType_Del);
//      end;
//    end;
//  end;
//end;

//procedure TSelfRightMenuComm.DoRangeChange(NotifyType: NotifyTypeEnum;
//  Param: NativeUInt);
//begin
//  if Param <> Self.MenuWindow.Handle then
//  begin
//    LoadSelfStockPlate;
//  end;
//end;

procedure TSelfRightMenuComm.ChangeStock(_InnerCode: Integer);
begin
  FInnerCode := _InnerCode;
end;

procedure TSelfRightMenuComm.PopMenu(_Pt: TPoint);
begin
//  UpdateSelfMenuState;
  inherited PopMenu(_Pt);
end;

end.
