unit QuoteTimeHistory;

interface

uses
  Windows,
  Classes,
  Graphics,
  Controls,
  SysUtils,
  Forms,
  BaseForm,
  AppContext,
  QuoteManagerEx,
  QuoteTime,
  QuoteCommLibrary;

type

  THistoryTimeForm = class(TBaseForm)
  protected
    FQuoteTime: TQuoteTime;
    FHistoryTitle: string;

//    procedure DoChangeStock(_StockInfoRec: StockInfoRec);
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor CreateNew(AOwner: TComponent; AContext: IAppContext); override;
    destructor Destroy; override;
    procedure UpdateSkin; override;

    procedure ShowCenter; override;

//    procedure ConnectQuoteManager(const GilAppController: IGilAppController;
//      const QuoteManager: IQuoteManagerEx; NotifySvr: INotifyServices);
//    procedure DisConnectQuoteManager;
    procedure ChangeStock(InnerCode: Integer; Day: Integer);
  end;

implementation

{ THistoryTime }

constructor THistoryTimeForm.CreateNew(AOwner: TComponent; AContext: IAppContext);
begin
  inherited;
  FQuoteTime := TQuoteTime.Create(nil, smHistoryTime);
  FQuoteTime.Parent := Self;
  FQuoteTime.Align := alClient;
  FHistoryTitle := '历史分时';
  FTitleBar.Caption := FHistoryTitle;
  BorderWidth := 1;
end;

destructor THistoryTimeForm.Destroy;
begin
  if Assigned(FQuoteTime) then
    FreeAndNil(FQuoteTime);
  inherited;
end;

procedure THistoryTimeForm.CreateParams(var Params: TCreateParams);
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
//
//procedure THistoryTimeForm.ConnectQuoteManager(const GilAppController
//  : IGilAppController; const QuoteManager: IQuoteManagerEx;
//  NotifySvr: INotifyServices);
//begin
//  FTitleBar.ConnectQuoteManager(GilAppController);
//  FQuoteTime.ConnectQuoteManager(GilAppController, QuoteManager, NotifySvr);
//  UpdateSkin;
//end;

//procedure THistoryTimeForm.DisConnectQuoteManager;
//begin
//  FQuoteTime.DisConnectQuoteManager;
//  FTitleBar.DisConnectQuoteManager;
//end;

//procedure THistoryTimeForm.DoChangeStock(_StockInfoRec: StockInfoRec);
//begin
//  FTitleBar.Caption := FHistoryTitle + '-' + _StockInfoRec.ZQJC + ' (' +
//    _StockInfoRec.GPDM + ')';
//end;

procedure THistoryTimeForm.ChangeStock(InnerCode, Day: Integer);
begin
//  if FQuoteTime <> nil then
//    FQuoteTime.HistoryDayChangeStock(InnerCode, Day);
end;

procedure THistoryTimeForm.ShowCenter;
begin
  WindowState := wsNormal;
  Width := 600;
  Height := 500;
  inherited ShowCenter;
end;

procedure THistoryTimeForm.UpdateSkin;
begin
  FTitleBar.UpdateSkin;
  Color := FTitleBar.Display.BorderLineColor;
  FQuoteTime.UpdateSkin;
end;

end.
