unit SectorPriceHqCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorPriceHqCommand Implementation
// Author£º      lksoulman
// Date£º        2017-12-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  ChildPage,
  MasterMgr,
  AppContext,
  CommandImpl;

type

  // SectorPriceHqCommand Implementation
  TSectorPriceHqCommandImpl = class(TCommandImpl)
  private
  protected
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Execute
    procedure Execute(AParams: string); override;
  end;

implementation

uses
  SectorPriceHqImpl;

{ TSectorPriceHqCommandImpl }

constructor TSectorPriceHqCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSectorPriceHqCommandImpl.Destroy;
begin

  inherited;
end;

procedure TSectorPriceHqCommandImpl.Execute(AParams: string);
var
  LHandle: Integer;
  LMasterMgr: IMasterMgr;
  LMasterHandle, LParams: string;
  LSectorPriceHqImpl: TSectorPriceHqImpl;
begin
  if AParams = '' then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('MasterHandle', LMasterHandle);
    if LMasterHandle <> '' then begin
      LHandle := StrToIntDef(LMasterHandle, 0);
      if LHandle <> 0 then begin
        ParamsVal('Params', LParams);
        LMasterMgr := FAppContext.FindInterface(ASF_COMMAND_ID_MASTERMGR) as IMasterMgr;
        if LMasterMgr <> nil then begin
          if not LMasterMgr.IsHasChildPage(LHandle, FId) then begin
            LSectorPriceHqImpl := TSectorPriceHqImpl.Create(FAppContext);
            LSectorPriceHqImpl.Caption := FCaption;
            LSectorPriceHqImpl.CommandId := FId;
            LMasterMgr.AddChildPage(LHandle, LSectorPriceHqImpl as IChildPage);
          end;
          LMasterMgr.BringToFrontChildPage(LHandle, FId, LParams);
          LMasterMgr := nil;
        end;
      end;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
