unit SimpleHqTestCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SimpleHqTestCommand Implementation
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

  // SimpleHqTestCommand Implementation
  TSimpleHqTestCommandImpl = class(TCommandImpl)
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
  SimpleHqTestImpl;

{ TSimpleHqTestCommandImpl }

constructor TSimpleHqTestCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSimpleHqTestCommandImpl.Destroy;
begin
  
  inherited;
end;

procedure TSimpleHqTestCommandImpl.Execute(AParams: string);
var
  LHandle: Integer;
  LMasterMgr: IMasterMgr;
  LMasterHandle, LParams: string;
  LSimpleHqTestImpl: TSimpleHqTestImpl;
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
            LSimpleHqTestImpl := TSimpleHqTestImpl.Create(FAppContext);
            LSimpleHqTestImpl.Caption := FCaption;
            LSimpleHqTestImpl.CommandId := FId;
            LMasterMgr.AddChildPage(LHandle, LSimpleHqTestImpl as IChildPage);
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
