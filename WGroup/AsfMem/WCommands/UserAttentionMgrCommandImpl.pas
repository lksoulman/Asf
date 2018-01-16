unit UserAttentionMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserAttentionMgrCommand Implementation
// Author£º      lksoulman
// Date£º        2018-1-12
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
  UserAttentionMgr;

type

  // UserAttentionMgrCommand Implementation
  TUserAttentionMgrCommandImpl = class(TCommandImpl)
  private
    // UserAttentionMgr
    FUserAttentionMgr: IUserAttentionMgr;
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
  UserAttentionMgrImpl;

{ TUserAttentionMgrCommandImpl }

constructor TUserAttentionMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserAttentionMgrCommandImpl.Destroy;
begin
  if FUserAttentionMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FUserAttentionMgr := nil;
  end;
  inherited;
end;

procedure TUserAttentionMgrCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FUserAttentionMgr = nil then begin
    FUserAttentionMgr := TUserAttentionMgrImpl.Create(FAppContext) as IUserAttentionMgr;
    FAppContext.RegisterInteface(FId, FUserAttentionMgr);
  end;

  if (AParams = '')
    or (FUserAttentionMgr = nil) then Exit;

  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Update' then begin
      FUserAttentionMgr.Update;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
