unit UserPositionSetCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserPositionSetCommand Implementation
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
  UserPositionSet;

type

  // UserPositionSetCommand Implementation
  TUserPositionSetCommandImpl = class(TCommandImpl)
  private
    // UserPositionSet
    FUserPositionSet: IUserPositionSet;
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
  UserPositionSetImpl;

{ TUserPositionSetCommandImpl }

constructor TUserPositionSetCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TUserPositionSetCommandImpl.Destroy;
begin
  if FUserPositionSet <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FUserPositionSet := nil;
  end;
  inherited;
end;

procedure TUserPositionSetCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Hide' then begin
      if FUserPositionSet <> nil then begin
        FUserPositionSet.Hide;
      end;
    end else begin
      if FUserPositionSet = nil then begin
        FUserPositionSet := TUserPositionSetImpl.Create(FAppContext) as IUserPositionSet;
        FAppContext.RegisterInteface(FId, FUserPositionSet);
      end;
      if FUserPositionSet <> nil then begin
        if LFuncName = 'Show' then begin
          FUserPositionSet.Show;
        end;
      end;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
