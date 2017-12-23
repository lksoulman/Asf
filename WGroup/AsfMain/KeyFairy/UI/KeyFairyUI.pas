unit KeyFairyUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairyUI
// Author£º      lksoulman
// Date£º        2017-11-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  RzEdit,
  GDIPOBJ,
  Command,
  RenderUtil,
  AppContext,
  KeyReportUI,
  CustomBaseUI,
  CommonDynArray,
  KeySearchEngine;

type

  // KeyFairyUI
  TKeyFairyUI = class(TCustomBaseUI)
    PnlEdit: TPanel;
    PnlClient: TPanel;
    EdtSearch: TRzEdit;
    procedure EdtSearchKeyPress(Sender: TObject; var Key: Char);
    procedure EdtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdtSearchChange(Sender: TObject);
  private
    // SearchDelayTimer
    FSearchDelayTimer: TTimer;
    // KeyReportUI
    FKeyReportUI: TKeyReportUI;
    // KeySearchEngine
    FKeySearchEngine: IKeySearchEngine;

  protected
    // WMActivate
//    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;

    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;

    // SearchDelayTimer
    procedure DoSearchDelayTimer(Sender: TObject);
    // LoadSearchResult
    procedure DoLoadSearchResult(Sender: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    // SetKey
    procedure SetKey(AKey: string);
  end;

implementation

{$R *.dfm}

{ TKeyFairyUI }

constructor TKeyFairyUI.Create(AContext: IAppContext);
begin
  inherited;

  EdtSearch.ParentFont := False;
  EdtSearch.ParentColor := False;
  EdtSearch.Font.Name := 'Î¢ÈíÑÅºÚ';
  EdtSearch.Font.Charset := GB2312_CHARSET;
  EdtSearch.Font.Height := -14;

//  FKeyReportUI := TKeyReportUI.Create(nil);
//  FKeyReportUI.Parent := PnlClient;
//  FKeyReportUI.Align := alClient;
//
//  FKeyReportUI.InitGridData;

  FSearchDelayTimer := TTimer.Create(nil);
  FSearchDelayTimer.Enabled := False;
  FSearchDelayTimer.Interval := 100;
  FSearchDelayTimer.OnTimer := DoSearchDelayTimer;
end;

destructor TKeyFairyUI.Destroy;
begin
//  FKeyReportUI.Free;
  inherited;
end;

procedure TKeyFairyUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
//  FBorderStyleEx := bsNone;
end;

procedure TKeyFairyUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := 'èóË¼¼üÅÌ¾«Áé';
  end;
end;

procedure TKeyFairyUI.DoUpdateSkinStyle;
begin
  inherited;
  if PnlEdit <> nil then begin
    PnlEdit.Color := RGB(26, 26, 26);
    PnlClient.Color := RGB(26, 26, 26);
  end;
  if EdtSearch <> nil then begin
    EdtSearch.Color := RGB(26, 26, 26);
    EdtSearch.Font.Color := RGB(134, 134, 134);
    EdtSearch.FrameColor := RGB(55, 55, 55);
    EdtSearch.FrameHotColor := RGB(79, 155, 255);
  end;
end;

procedure TKeyFairyUI.SetKey(AKey: string);
begin
  EdtSearch.Text := AKey;
end;

procedure TKeyFairyUI.DoSearchDelayTimer(Sender: TObject);
begin
  FSearchDelayTimer.Enabled := False;
  if FKeySearchEngine <> nil then begin
    FKeySearchEngine.FuzzySearchKey(EdtSearch.Text);
  end;
end;

procedure TKeyFairyUI.DoLoadSearchResult(Sender: TObject);
begin
//  FKeyReportUI.LoadSearchResult(APKeyItems);
end;

procedure TKeyFairyUI.EdtSearchChange(Sender: TObject);
begin
  FSearchDelayTimer.Enabled := True;
end;

procedure TKeyFairyUI.EdtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//
end;

procedure TKeyFairyUI.EdtSearchKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

//procedure TKeyFairyUI.WMActivate(var Message: TWMActivate);
//begin
//  if message.Active = 0 then begin
//    FIsActivate := False;
//    Self.Hide;
//    Exit;
//  end;
//  inherited;
//end;

end.
