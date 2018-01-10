unit HomePageImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º HomePage Implementation
// Author£º      lksoulman
// Date£º        2018-1-2
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  MsgEx,
  SecuMain,
  HomePageUI,
  AppContext,
  ChildPageImpl,
  MsgExSubcriber;

type

  // HomePage Implementation
  THomePageImpl = class(TChildPageImpl)
  private
    // HomePageUI
    FHomePageUI: THomePageUI;
  protected
    // CreateObjects
    procedure DoCreateObjects; override;
    // DestroyObjects
    procedure DoDestroyObjects; override;
    // InitObjectDatas
    procedure DoInitObjectDatas; override;
    // AddSubcribeMsgExs
    procedure DoAddSubcribeMsgExs; override;

    // Activate
    procedure DoActivate; override;
    // NoActivate
    procedure DoNoActivate; override;
    // ReSubcribeHq
    procedure DoReSubcribeHq; override;
    // ReSecuMainMem
    procedure DoReSecuMainMem; override;
    // ReUpdateLanguage
    procedure DoReUpdateLanguage; override;
    // ReUpdateSkinStyle
    procedure DoReUpdateSkinStyle; override;
    // ReLoadInfo
    procedure DoReLoadInfo(AMsgEx: TMsgEx); override;
    // UpdateCommandParam
    procedure DoUpdateCommandParam(AParams: string); override;
  public
  end;

implementation

{ THomePageImpl }

procedure THomePageImpl.DoCreateObjects;
begin
  FHomePageUI := THomePageUI.Create(FAppContext);
  FHomePageUI.Parent := FChildPageUI;
  FHomePageUI.Align := alClient;
  FHomePageUI.Show;
end;

procedure THomePageImpl.DoDestroyObjects;
begin
  FHomePageUI.Free;
end;

procedure THomePageImpl.DoInitObjectDatas;
begin
  inherited;

end;

procedure THomePageImpl.DoAddSubcribeMsgExs;
begin
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfUI_ReLoadInfo);
end;

procedure THomePageImpl.DoActivate;
begin

end;

procedure THomePageImpl.DoNoActivate;
begin

end;

procedure THomePageImpl.DoReSubcribeHq;
begin

end;

procedure THomePageImpl.DoReSecuMainMem;
begin

end;

procedure THomePageImpl.DoReUpdateLanguage;
begin

end;

procedure THomePageImpl.DoReUpdateSkinStyle;
begin
  inherited;

end;

procedure THomePageImpl.DoReLoadInfo(AMsgEx: TMsgEx);
begin
  FHomePageUI.ShowInfo(AMsgEx.Info);
end;

procedure THomePageImpl.DoUpdateCommandParam(AParams: string);
begin
  
end;

end.
