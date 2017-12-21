unit StatusAlarmDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� StatusAlarmDataMgr Implementation
// Author��      lksoulman
// Date��        2017-11-22
// Comments��
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
  StatusAlarmDataMgr,
  Generics.Collections;

type

  // StatusAlarmDataMgr Implementation
  TStatusAlarmDataMgrImpl = class(TBaseInterfacedObject, IStatusAlarmDataMgr)
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

    { IStatusAlarmDataMgr }

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

{ TStatusAlarmDataMgrImpl }

constructor TStatusAlarmDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FResourceStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_ALARM');
end;

destructor TStatusAlarmDataMgrImpl.Destroy;
begin
  if FResourceStream <> nil then begin
    FResourceStream.Free;
  end;
  FLock.Free;
  inherited;
end;

procedure TStatusAlarmDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusAlarmDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusAlarmDataMgrImpl.Update;
begin

end;

function TStatusAlarmDataMgrImpl.IsHasUpdate: Boolean;
begin
  Result := FIsHasUpdate;
end;

function TStatusAlarmDataMgrImpl.GetResourceStream: TResourceStream;
begin
  Result := FResourceStream;
end;

end.
