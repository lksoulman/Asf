unit MsgExSubcriberImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExSubcriber Implementation
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  MsgExSubcriber,
  CommonRefCounter,
  Generics.Collections;

type

  // MsgExSubcriber Implementation
  TMsgExSubcriberImpl = class(TAutoInterfacedObject, IMsgExSubcriber)
  private
    // Active
    FActive: Boolean;
    // LogInfo
    FLogInfo: string;
    // NotifyEvent
    FNotifyEvent: TNotifyEvent;
  protected
  public
    // Constructor
    constructor Create(ANotifyEvent: TNotifyEvent); reintroduce;
    // Destructor
    destructor Destroy; override;

    {IMsgExSubcriber}

    // GetActive
    function GetActive: Boolean;
    // GetLogInfo
    function GetLogInfo: string;
    // SetActive
    procedure SetActive(Active: Boolean);
    // SetLogInfo
    procedure SetLogInfo(ALogInfo: string);
    // InvokeNotify
    procedure InvokeNotify(AMsgEx: TMsgEx);
  end;

implementation

{ TMsgExSubcriberImpl }

constructor TMsgExSubcriberImpl.Create(ANotifyEvent: TNotifyEvent);
begin
  inherited Create;
  FActive := False;
  FNotifyEvent := ANotifyEvent;
end;

destructor TMsgExSubcriberImpl.Destroy;
begin
  FActive := False;
  FNotifyEvent := nil;
  inherited;
end;

function TMsgExSubcriberImpl.GetActive: Boolean;
begin
  Result := FActive;
end;

function TMsgExSubcriberImpl.GetLogInfo: string;
begin
  Result := FLogInfo;
end;

procedure TMsgExSubcriberImpl.SetActive(Active: Boolean);
begin
  FActive := Active;
end;

procedure TMsgExSubcriberImpl.SetLogInfo(ALogInfo: string);
begin
  FLogInfo := ALogInfo;
end;

procedure TMsgExSubcriberImpl.InvokeNotify(AMsgEx: TMsgEx);
begin
  if Assigned(FNotifyEvent) then begin
    FNotifyEvent(AMsgEx);
  end;
end;

end.
