unit EmbedWebAssetsCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º EmbedWebAssetsCommand Implementation
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

  // EmbedWebAssetsCommand Implementation
  TEmbedWebAssetsCommandImpl = class(TCommandImpl)
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
  EmbedWebAssetsImpl;

{ TEmbedWebAssetsCommandImpl }

constructor TEmbedWebAssetsCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TEmbedWebAssetsCommandImpl.Destroy;
begin

  inherited;
end;

procedure TEmbedWebAssetsCommandImpl.Execute(AParams: string);
var
  LHandle: Integer;
  LMasterMgr: IMasterMgr;
  LMasterHandle, LParams: string;
  LEmbedWebAssetsImpl: TEmbedWebAssetsImpl;
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
            LEmbedWebAssetsImpl := TEmbedWebAssetsImpl.Create(FAppContext);
            LEmbedWebAssetsImpl.Caption := FCaption;
            LEmbedWebAssetsImpl.CommandId := FId;
            LMasterMgr.AddChildPage(LHandle, LEmbedWebAssetsImpl as IChildPage);
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
