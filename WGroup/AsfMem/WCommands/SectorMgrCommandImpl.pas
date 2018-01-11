unit SectorMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2018-1-9
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  CommandImpl,
  SectorMgr;

type

  // SectorMgrCommand Implementation
  TSectorMgrCommandImpl = class(TCommandImpl)
  private
    // SectorMgr
    FSectorMgr: ISectorMgr;
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
  SectorMgrImpl;

{ TSectorMgrCommandImpl }

constructor TSectorMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSectorMgrCommandImpl.Destroy;
begin
  if FSectorMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FSectorMgr := nil;
  end;
  inherited;
end;

procedure TSectorMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FSectorMgr = nil then begin
    FSectorMgr := TSectorMgrImpl.Create(FAppContext) as ISectorMgr;
    FAppContext.RegisterInteface(FId, FSectorMgr);
  end;

  if (AParams = '')
    or (FSectorMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FSectorMgr.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
