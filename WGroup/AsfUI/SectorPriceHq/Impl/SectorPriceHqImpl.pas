unit SectorPriceHqImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorPriceHq Implementation
// Author£º      lksoulman
// Date£º        2018-1-17
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  ChildPageImpl,
  UserSectorMenuUI,
  SectorPriceMenuUI,
  UserPositionMenuUI;

type

  // SectorPriceHqImpl
  TSectorPriceHqImpl = class(TChildPageImpl)
  private
    // UserSectorMenuUI
    FUserSectorMenuUI: TUserSectorMenuUI;
    // SectorPriceMenuUI
    FSectorPriceMenuUI: TSectorPriceMenuUI;
    // UserPositionMenuUI
    FUserPositionMenuUI: TUserPositionMenuUI;
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
    // UpdateCommandParam
    procedure DoUpdateCommandParam(AParams: string); override;
  public
  end;

implementation

procedure TSectorPriceHqImpl.DoCreateObjects;
begin
  FSectorPriceMenuUI := TSectorPriceMenuUI.Create(FAppContext);
  FSectorPriceMenuUI.Parent := FChildPageUI;
  FSectorPriceMenuUI.Align := alTop;

  FUserSectorMenuUI := TUserSectorMenuUI.Create(FAppContext);
  FUserSectorMenuUI.Parent := FChildPageUI;
  FUserSectorMenuUI.Align := alBottom;

  FUserPositionMenuUI := TUserPositionMenuUI.Create(FAppContext);
  FUserPositionMenuUI.Parent := FChildPageUI;
  FUserPositionMenuUI.Align := alBottom;
end;

procedure TSectorPriceHqImpl.DoDestroyObjects;
begin
  FSectorPriceMenuUI.Free;
end;

procedure TSectorPriceHqImpl.DoInitObjectDatas;
begin

end;

procedure TSectorPriceHqImpl.DoAddSubcribeMsgExs;
begin

end;

procedure TSectorPriceHqImpl.DoActivate;
begin

end;

procedure TSectorPriceHqImpl.DoNoActivate;
begin

end;

procedure TSectorPriceHqImpl.DoReSubcribeHq;
begin

end;

procedure TSectorPriceHqImpl.DoReSecuMainMem;
begin

end;

procedure TSectorPriceHqImpl.DoReUpdateLanguage;
begin

end;

procedure TSectorPriceHqImpl.DoReUpdateSkinStyle;
begin

end;

procedure TSectorPriceHqImpl.DoUpdateCommandParam(AParams: string);
begin

end;

end.
