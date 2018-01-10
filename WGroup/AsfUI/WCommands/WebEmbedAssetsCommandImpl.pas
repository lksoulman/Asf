unit WebEmbedAssetsCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� WebEmbedAssetsCommand Implementation
// Author��      lksoulman
// Date��        2017-12-15
// Comments��
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

  // WebEmbedAssetsCommand Implementation
  TWebEmbedAssetsCommandImpl = class(TCommandImpl)
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
  WebEmbedAssetsImpl;

{ TWebEmbedAssetsCommandImpl }

constructor TWebEmbedAssetsCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TWebEmbedAssetsCommandImpl.Destroy;
begin

  inherited;
end;

procedure TWebEmbedAssetsCommandImpl.Execute(AParams: string);
var
  LHandle: Integer;
  LMasterMgr: IMasterMgr;
  LMasterHandle, LParams: string;
  LWebEmbedAssetsImpl: TWebEmbedAssetsImpl;
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
            LWebEmbedAssetsImpl := TWebEmbedAssetsImpl.Create(FAppContext);
            LWebEmbedAssetsImpl.Caption := FCaption;
            LWebEmbedAssetsImpl.CommandId := FId;
            LMasterMgr.AddChildPage(LHandle, LWebEmbedAssetsImpl as IChildPage);
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
