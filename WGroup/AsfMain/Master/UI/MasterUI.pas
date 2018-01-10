unit MasterUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterUI
// Author£º      lksoulman
// Date£º        2017-12-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Variants,
  Graphics,
  Controls,
  Vcl.Forms,
  RenderUtil,
  AppContext,
  ComponentUI,
  CustomMasterUI,
  KeySearchEngine,
  MasterNCStatusBarUI,
  MasterNCCaptionBarUI,
  MasterNCSuperTabBarUI;

type

  // MasterUI
  TMasterUI = class(TCustomMasterUI)
  private
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;

    // CloseEx
    procedure DoCloseEx; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // Change
    procedure Change(ACommandId: Integer);
  end;

implementation

uses
  Command;

{$R *.dfm}

{ TAppMainFormUI }

constructor TMasterUI.Create(AContext: IAppContext);
begin
  inherited;
  KeyPreview := True;
end;

destructor TMasterUI.Destroy;
begin

  inherited;
end;

procedure TMasterUI.DoBeforeCreate;
begin
  inherited;
  FNCStatusBarUIClass := TMasterNCStatusBarUI;
  FNCCaptionBarUIClass := TMasterNCCaptionBarUI;
  FNCSuperTabBarUIClass := TMasterNCSuperTabBarUI;
end;

procedure TMasterUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := 'èóË¼';
  end;
end;

procedure TMasterUI.DoUpdateSkinStyle;
begin
  inherited;
  FBorderPen := FAppContext.GetGdiMgr.GetBrushObjMasterBorder;
  FBackColor := FAppContext.GetGdiMgr.GetColorRefMasterBack;
  FCaptionBackColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionBack;
  FCaptionTextColor := FAppContext.GetGdiMgr.GetColorRefMasterCaptionText;
end;

procedure TMasterUI.DoCloseEx;
begin
  FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_MASTERMGR, Format('FuncName=DelMaster@Handle=%d', [Self.Handle]));
end;

procedure TMasterUI.Change(ACommandId: Integer);
begin
  FNCStatusBarUI.Change(ACommandId);
  FNCCaptionBarUI.Change(ACommandId);
  FNCSuperTabBarUI.Change(ACommandId);
end;

end.
