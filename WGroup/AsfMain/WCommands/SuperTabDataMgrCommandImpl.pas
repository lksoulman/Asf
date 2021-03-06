unit SuperTabDataMgrCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� SuperTabDataMgrCommand Implementation
// Author��      lksoulman
// Date��        2017-11-20
// Comments��
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
  SuperTabDataMgr;

type

  // SuperTabDataMgrCommand Implementation
  TSuperTabDataMgrCommandImpl = class(TCommandImpl)
  private
    // SuperTabDataMgr
    FSuperTabDataMgr: ISuperTabDataMgr;
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
  SuperTabDataMgrImpl;

{ TSuperTabDataMgrCommandImpl }

constructor TSuperTabDataMgrCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSuperTabDataMgrCommandImpl.Destroy;
begin
  if FSuperTabDataMgr <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FSuperTabDataMgr := nil;
  end;
  inherited;
end;

procedure TSuperTabDataMgrCommandImpl.Execute(AParams: string);
begin
  if FSuperTabDataMgr = nil then begin
    FSuperTabDataMgr := TSuperTabDataMgrImpl.Create(FAppContext) as ISuperTabDataMgr;
    FAppContext.RegisterInteface(FId, FSuperTabDataMgr);
  end;
end;

end.
