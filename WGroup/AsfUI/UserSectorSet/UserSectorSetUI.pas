unit UserSectorSetUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£∫ SectorTreeUI
// Author£∫      lksoulman
// Date£∫        2018-1-12
// Comments£∫
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Controls,
  SysUtils,
  Messages,
  Graphics,
  Vcl.Forms,
  MsgEx,
  Command,
  ButtonUI,
  AppContext,
  CustomBaseUI,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // UserSectorSetUI
  TUserSectorSetUI = class(TCustomBaseUI)
  private
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
    // NCBarInitDatas
    procedure DoNCBarInitDatas; override;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle; override;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ShowEx
    procedure ShowEx;
  end;


implementation

{$R *.dfm}

{ TUserSectorSetUI }

constructor TUserSectorSetUI.Create(AContext: IAppContext);
begin
  inherited;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);

end;

destructor TUserSectorSetUI.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  inherited;
end;

procedure TUserSectorSetUI.ShowEx;
begin
  SetScreenCenter;
  if not Self.Showing then begin
    Show;
  end else begin
    BringToFront;
  end;
end;

procedure TUserSectorSetUI.DoUpdateMsgEx(AObject: TObject);
var
  LMsgEx: TMsgEx;
begin
  LMsgEx := TMsgEx(AObject);
  case LMsgEx.Id of
    Msg_AsfMem_ReUpdateSectorMgr:
      begin

      end;
    Msg_AsfMem_ReUpdateAttentionMgr:
      begin
        
      end;
    Msg_AsfMain_ReUpdateSkinStyle:
      begin

      end;
  end;
end;

procedure TUserSectorSetUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderStyleEx := bsNone;
end;

procedure TUserSectorSetUI.DoNCBarInitDatas;
begin
  if FNCCaptionBarUI <> nil then begin
    FNCCaptionBarUI.Caption := '∞ÂøÈ…Ë÷√';
  end;
end;

procedure TUserSectorSetUI.DoUpdateSkinStyle;
begin
  inherited;
  
end;

end.
