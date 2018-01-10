unit KeyFairyCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairyCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  KeyFairy,
  AppContext,
  CommandImpl;

type

  // KeyFairyCommand Implementation
  TKeyFairyCommandImpl = class(TCommandImpl)
  private
    // KeyFairy
    FKeyFairy: IKeyFairy;
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
  KeyFairyImpl;

{ TKeyFairyCommandImpl }

constructor TKeyFairyCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TKeyFairyCommandImpl.Destroy;
begin
  if FKeyFairy <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FKeyFairy := nil;
  end;
  inherited;
end;

procedure TKeyFairyCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if AParams = '' then begin
    if FKeyFairy = nil then begin
      FKeyFairy := TKeyFairyImpl.Create(FAppContext) as IKeyFairy;
      FAppContext.RegisterInteface(FId, FKeyFairy);
    end;
  end else begin
    BeginSplitParams(AParams);
    try
      ParamsVal('FuncName', LFuncName);
      if LFuncName <> 'Hide' then begin
        if FKeyFairy <> nil then begin
          FKeyFairy.Hide;
        end;
      end;
    finally
      EndSplitParams;
    end;
  end;
end;

end.
