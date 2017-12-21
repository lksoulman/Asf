unit MsgExSubcriberAdapter;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExSubcriberAdapter Implementation
// Author£º      lksoulman
// Date£º        2017-12-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  AppContext,
  MsgExSubcriber,
  CommonRefCounter,
  MsgExSubcriberImpl,
  Generics.Collections;

type
  // MsgExSubcriberAdapter
  TMsgExSubcriberAdapter = class(TAutoObject)
  private
    // IsSubcribe
    FIsSubcribe: Boolean;
    // AppContext
    FAppContext: IAppContext;
    // SubcribeMsgExs
    FSubcribeMsgExs: TList<Integer>;
    // MsgExSubcriber
    FMsgExSubcriber: IMsgExSubcriber;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; ANotifyEvent: TNotifyEvent); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // SubcribeMsgEx
    procedure SubcribeMsgEx;
    // UnSubcribeMsgEx
    procedure UnSubcribeMsgEx;
    // AddSubcribeMsgEx
    procedure AddSubcribeMsgEx(AMsgEx: Integer);
    // SetSubcribeMsgExState
    procedure SetSubcribeMsgExState(AIsActive: Boolean);
  end;

implementation

{ TMsgExSubcriberAdapter }

constructor TMsgExSubcriberAdapter.Create(AContext: IAppContext; ANotifyEvent: TNotifyEvent);
begin
  inherited Create;
  FIsSubcribe := False;
  FAppContext := AContext;
  FSubcribeMsgExs := TList<Integer>.Create;
  FMsgExSubcriber := TMsgExSubcriberImpl.Create(ANotifyEvent) as IMsgExSubcriber;
end;

destructor TMsgExSubcriberAdapter.Destroy;
begin
  SetSubcribeMsgExState(False);
  UnSubcribeMsgEx;
  FMsgExSubcriber := nil;
  FSubcribeMsgExs.Free;
  FAppContext := nil;
  inherited;
end;

procedure TMsgExSubcriberAdapter.SubcribeMsgEx;
var
  LIndex: Integer;
begin
  if not FIsSubcribe then begin
    for LIndex := 0 to FSubcribeMsgExs.Count - 1 do begin
      FAppContext.Subcriber(FSubcribeMsgExs.Items[LIndex], FMsgExSubcriber);
    end;
    FMsgExSubcriber.SetActive(True);
    FIsSubcribe := True;
  end;
end;

procedure TMsgExSubcriberAdapter.UnSubcribeMsgEx;
var
  LIndex: Integer;
begin
  if FIsSubcribe then begin
    FMsgExSubcriber.SetActive(True);
    for LIndex := 0 to FSubcribeMsgExs.Count - 1 do begin
      FAppContext.UnSubcriber(FSubcribeMsgExs.Items[LIndex], FMsgExSubcriber);
    end;
    FIsSubcribe := False;
  end;
end;

procedure TMsgExSubcriberAdapter.AddSubcribeMsgEx(AMsgEx: Integer);
begin
  if FSubcribeMsgExs.IndexOf(AMsgEx) < 0 then begin
    FSubcribeMsgExs.Add(AMsgEx);
    if FIsSubcribe then begin
      FAppContext.Subcriber(AMsgEx, FMsgExSubcriber);
    end;
  end;
end;

procedure TMsgExSubcriberAdapter.SetSubcribeMsgExState(AIsActive: Boolean);
begin
  FMsgExSubcriber.SetActive(AIsActive);
end;

end.
