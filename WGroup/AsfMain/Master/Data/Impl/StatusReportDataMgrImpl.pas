unit StatusReportDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º StatusReportDataMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  CommonLock,
  StatusReportDataMgr,
  Generics.Collections;

type

  // StatusReportDataMgr Implementation
  TStatusReportDataMgrImpl = class(TBaseInterfacedObject, IStatusReportDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // IsHasUpdate
    FIsHasUpdate: Boolean;
    // ResourceStream
    FResourceStream: TResourceStream;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IStatusReportDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // IsHasUpdate
    function IsHasUpdate: Boolean;
    // GetResourceStream
    function GetResourceStream: TResourceStream;
  end;

implementation

{ TStatusReportDataMgrImpl }

constructor TStatusReportDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FResourceStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_REPORT');
end;

destructor TStatusReportDataMgrImpl.Destroy;
begin
  if FResourceStream <> nil then begin
    FResourceStream.Free;
  end;
  FLock.Free;
  inherited;
end;

procedure TStatusReportDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusReportDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusReportDataMgrImpl.Update;
begin

end;

function TStatusReportDataMgrImpl.IsHasUpdate: Boolean;
begin
  Result := FIsHasUpdate;
end;

function TStatusReportDataMgrImpl.GetResourceStream: TResourceStream;
begin
  Result := FResourceStream;
end;

end.

