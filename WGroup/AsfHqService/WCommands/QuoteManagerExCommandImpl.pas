unit QuoteManagerExCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º QuoteManagerExCommand Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
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
  QuoteManagerEx;

type

  // QuoteManagerExCommand Implementation
  TQuoteManagerExCommandImpl = class(TCommandImpl)
  private
    // QuoteManagerEx
    FQuoteManagerEx: IQuoteManagerEx;
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
  QuoteManagerExImpl;

{ TQuoteManagerExCommandImpl }

constructor TQuoteManagerExCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TQuoteManagerExCommandImpl.Destroy;
begin
  if FQuoteManagerEx <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FQuoteManagerEx := nil;
  end;
  inherited;
end;

procedure TQuoteManagerExCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  if FQuoteManagerEx = nil then begin
    FQuoteManagerEx := TQuoteManagerExImpl.Create(FAppContext) as IQuoteManagerEx;
    FAppContext.RegisterInteface(FId, FQuoteManagerEx);
  end;

//  if (AParams = '')
//    or (FQuoteManagerEx = nil) then Exit;

//  BeginSplitParams(AParams);
//  try
//    ParamsVal('FuncName', LFuncName);
//    if LFuncName = 'UpdateTables' then begin
//
//    end;
//  finally
//    EndSplitParams;
//  end;
end;

end.
