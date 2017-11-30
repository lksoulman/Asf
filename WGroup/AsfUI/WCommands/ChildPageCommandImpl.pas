unit ChildPageCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ChildPageCommand Implementation
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Command,
  SysUtils,
  MasterMgr,
  SyncAsync,
  AppContext,
  CommandImpl;

type

  // ChildPageCommand Implementation
  TChildPageCommandImpl = class(TCommandImpl)
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
    // Execute
    procedure ExecuteEx(AParams: array of string); override;
    // Execute
    procedure ExecuteAsync(AParams: string); override;
    // Execute
    procedure ExecuteAsyncEx(AParams: array of string); override;
  end;

implementation

uses
  MasterMgrImpl;

{ TChildPageCommandImpl }

constructor TChildPageCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TChildPageCommandImpl.Destroy;
begin

  inherited;
end;

procedure TChildPageCommandImpl.Execute(AParams: string);
begin

end;

procedure TChildPageCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TChildPageCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TChildPageCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
