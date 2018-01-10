unit KeyFairyUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： KeyFairyUI
// Author：      lksoulman
// Date：        2017-11-27
// Comments：
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
  RzCommon,
  RzEdit,
  GDIPOBJ,
  Command,
  SecuMain,
  RenderUtil,
  AppContext,
  KeyReportUI,
  CustomBaseUI,
  CommonDynArray,
  KeySearchEngine;

type

  // KeyEditEx
  TKeyEditEx = class(TPanel)
  private
    // EditEx
    FEditEx: TRzEdit;
    // HorzSpace
    FHorzSpace: Integer;
    // VertSpace
    FVertSpace: Integer;
    // AppContext
    FAppContext: IAppContext;
  protected
    // GetText
    function GetText: string;
    // SetText
    procedure SetText(AText: string);
    // GetBackColor
    function GetBackColor: TColor;
    // SetBackColor
    procedure SetBackColor(AColor: TColor);
    // GetFontColor
    function GetFontColor: TColor;
    // SetFontColor
    procedure SetFontColor(AColor: TColor);
    // GetFrameColor
    function GetFrameColor: TColor;
    // SetFrameColor
    procedure SetFrameColor(AColor: TColor);
    // GetFrameHotColor
    function GetFrameHotColor: TColor;
    // SetFrameHotColor
    procedure SetFrameHotColor(AColor: TColor);

    // Resize
    procedure Resize; override;
    // ResetEditEx
    procedure DoResetEditEx; virtual;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; virtual;
  public
    // Constructor
    constructor Create(AParent: TWinControl; AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // UpdateSkinStyle
    procedure UpdateSkinStyle; virtual;

    property Text: string read GetText write SetText;
    property HorzSpace: Integer read FHorzSpace write FHorzSpace;
    property VertSpace: Integer read FVertSpace write FVertSpace;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property FontColor: TColor read GetFontColor write SetFontColor;
//    property FrameColorEx: TColor read GetFrameColor write SetFrameColor;
    property FrameHotColor: TColor read GetFrameHotColor write SetFrameHotColor;
  end;

  // KeyFairyUI
  TKeyFairyUI = class(TCustomBaseUI)
  private
    // KeyEditEx
    FKeyEditEx: TKeyEditEx;
    // KeyReportUI
    FKeyReportUI: TKeyReportUI;
    // KeySearchDelayTimer
    FKeySearchDelayTimer: TTimer;
    // KeySearchEngine
    FKeySearchEngine: IKeySearchEngine;
  protected
    // 响应程序激活消息
    procedure OnActivateApp(var message: TWMACTIVATEAPP); message WM_ACTIVATEAPP;
    // 响应激活消息
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;

    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;

    // EditKeyChange
    procedure DoEditKeyChange(Sender: TObject);
    // EditKeyPress
    procedure DoEditKeyPress(Sender: TObject; var Key: Char);


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

{ TKeyEditEx }

constructor TKeyEditEx.Create(AParent: TWinControl; AContext: IAppContext);
begin
  FAppContext := AContext;
  inherited Create(nil);
  Parent := AParent;
  BevelOuter := bvNone;
  ParentColor := False;
  ParentBackground := False;
  FHorzSpace := 5;
  FVertSpace := 5;
  FEditEx := TRzEdit.Create(nil);
  FEditEx.Parent := Self;
  FEditEx.Align := alNone;
//  FEditEx.Ctl3D := False;
  FEditEx.ParentFont := False;
  FEditEx.ParentColor := False;
  FEditEx.AutoSelect := False;
  FEditEx.FrameStyle := fsFlat;
  FEditEx.FrameVisible := False;
  FEditEx.FrameHotTrack := False;
  FEditEx.FrameHotStyle := fsFlatBold;
  FEditEx.FramingPreference := fpCustomFraming;
  FEditEx.Font.Name := '微软雅黑';
  FEditEx.Font.Charset := GB2312_CHARSET;
  DoUpdateSkinStyle;
end;

destructor TKeyEditEx.Destroy;
begin
  FEditEx.Text := '';
  FEditEx.Free;
  inherited;
  FAppContext := nil;
end;

procedure TKeyEditEx.UpdateSkinStyle;
begin
  DoUpdateSkinStyle;
end;

function TKeyEditEx.GetText: string;
begin
  Result := FEditEx.Text;
end;

procedure TKeyEditEx.SetText(AText: string);
begin
  FEditEx.Text := AText;
  FEditEx.SelStart := Length(FEditEx.Text);
  FEditEx.SelLength := 0;
end;

function TKeyEditEx.GetBackColor: TColor;
begin
  Result := Self.Color;
end;

procedure TKeyEditEx.SetBackColor(AColor: TColor);
begin
  if Self.Color <> AColor then begin
    Self.Color := AColor;
    FEditEx.Color := AColor;
  end;
end;

function TKeyEditEx.GetFontColor: TColor;
begin
  Result := FEditEx.Font.Color;
end;

procedure TKeyEditEx.SetFontColor(AColor: TColor);
begin
  if FEditEx.Font.Color <> AColor then begin
    FEditEx.Font.Color := AColor;
  end;
end;

function TKeyEditEx.GetFrameColor: TColor;
begin
  Result := FEditEx.FrameColor;
end;

procedure TKeyEditEx.SetFrameColor(AColor: TColor);
begin
  if FEditEx.FrameColor <> AColor then begin
    FEditEx.FrameColor := AColor;
  end;
end;

function TKeyEditEx.GetFrameHotColor: TColor;
begin
  Result := FEditEx.FrameHotColor;
end;

procedure TKeyEditEx.SetFrameHotColor(AColor: TColor);
begin
  if FEditEx.FrameHotColor <> AColor then begin
    FEditEx.FrameHotColor := AColor;
  end;
end;

procedure TKeyEditEx.Resize;
begin
  inherited;
  DoResetEditEx;
end;

procedure TKeyEditEx.DoResetEditEx;
var
  LValue: Integer;
begin
  if FEditEx.Top <> FVertSpace then begin
    FEditEx.Top := FVertSpace;
  end;
  if FEditEx.Left <> FHorzSpace then begin
    FEditEx.Left := FHorzSpace;
  end;
  LValue :=  Self.Width - 2 * FHorzSpace;
  if FEditEx.Width <> LValue then begin
    FEditEx.Width := LValue;
  end;
//  LValue :=  Self.Height - 2 * FVertSpace;
//  if FEditEx.Height <> LValue then begin
//    FEditEx.Height := LValue;
//  end;
end;

procedure TKeyEditEx.DoUpdateSkinStyle;
begin
  BackColor := RGB(26, 26, 26);
  FontColor := RGB(134, 134, 134);
//  FrameColor := RGB(26, 26, 26);
  FrameHotColor := RGB(26, 26, 26);
end;

{ TKeyFairyUI }

constructor TKeyFairyUI.Create(AContext: IAppContext);
begin
  inherited;
  KeyPreview := True;
  FKeySearchEngine := FAppContext.FindInterface(ASF_COMMAND_ID_KEYSEARCHENGINE) as IKeySearchEngine;
  FKeyEditEx := TKeyEditEx.Create(Self, FAppContext);
  FKeyEditEx.Align := alTop;
  FKeyEditEx.Height := 36;
  FKeyEditEx.UpdateSkinStyle;
  FKeyEditEx.FEditEx.OnChange := DoEditKeyChange;
  FKeyEditEx.FEditEx.OnKeyPress := DoEditKeyPress;
  FKeyReportUI := TKeyReportUI.Create(Self, FAppContext);
  FKeyReportUI.Align := alClient;
  FKeyReportUI.UpdateSkinStyle;
  FKeySearchDelayTimer := TTimer.Create(nil);
  FKeySearchDelayTimer.Enabled := False;
  FKeySearchDelayTimer.Interval := 100;
  FKeySearchDelayTimer.OnTimer := DoSearchDelayTimer;
  FKeySearchEngine.SetResultCallBack(DoLoadSearchResult);
end;

destructor TKeyFairyUI.Destroy;
begin
  FKeySearchDelayTimer.Enabled := False;
  FKeySearchDelayTimer.Free;
  FKeyReportUI.Free;
  FKeyEditEx.Free;
  FKeySearchEngine := nil;
  inherited;
end;

procedure TKeyFairyUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
end;

procedure TKeyFairyUI.WMActivate(var Message: TWMActivate);
begin
  inherited;
end;

procedure TKeyFairyUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderStyleEx := bsNone;
end;

procedure TKeyFairyUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := '梵思键盘精灵';
  end;
end;

procedure TKeyFairyUI.DoUpdateSkinStyle;
begin
  inherited;
end;

procedure TKeyFairyUI.DoEditKeyChange(Sender: TObject);
begin
  FKeySearchDelayTimer.Enabled := True;
end;

procedure TKeyFairyUI.DoEditKeyPress(Sender: TObject; var Key: Char);
begin

end;

procedure TKeyFairyUI.SetKey(AKey: string);
begin
  if FKeyEditEx <> nil then begin
    FKeyEditEx.Text := AKey;
    FKeySearchDelayTimer.Enabled := True;
  end;
end;

procedure TKeyFairyUI.DoSearchDelayTimer(Sender: TObject);
begin
  FKeySearchDelayTimer.Enabled := False;
  FKeyReportUI.ClearGridRowDatas;
  if FKeySearchEngine <> nil then begin
    if FKeyEditEx <> nil then begin
      FKeySearchEngine.FuzzySearchKey(FKeyEditEx.Text);
    end;
  end;
end;

procedure TKeyFairyUI.DoLoadSearchResult(Sender: TObject);
begin
  FKeyReportUI.LoadSearchResult(Sender);
end;

end.
