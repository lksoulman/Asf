unit UserSectorSetCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorSetCommand Implementation
// Author£º      lksoulman
// Date£º        2018-1-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Command,
  SysUtils,
  AppContext,
  CommandImpl,
  UserSectorSet;

type

  // UserSectorSetCommand Implementation
  TUserSectorSetCommandImpl = class(TCommandImpl)
  private
    // UserSectorSet
    FUserSectorSet: IUserSectorSet;
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
  UserSectorSetImpl;

{ TUserSectorSetCommandImpl }

constructor TUserSectorSetCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserSectorSetCommandImpl.Destroy;
begin
  if FUserSectorSet <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FUserSectorSet := nil;
  end;
  inherited;
end;

procedure TUserSectorSetCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Hide' then begin
      if FUserSectorSet <> nil then begin
        FUserSectorSet.Hide;
      end;
    end else begin
      if FUserSectorSet = nil then begin
        FUserSectorSet := TUserSectorSetImpl.Create(FAppContext) as IUserSectorSet;
        FAppContext.RegisterInteface(FId, FUserSectorSet);
      end;
      if FUserSectorSet <> nil then begin
        if LFuncName = 'Show' then begin
          FUserSectorSet.Show;
        end;
      end;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
