unit MsgExServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExService Implementation
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  MsgEx,
  MsgExImpl,
  MsgExPool,
  BaseObject,
  AppContext,
  CommonLock,
  CommonQueue,
  MsgExService,
  ExecutorThread,
  MsgExSubcriber,
  MsgExSubcriberMgr;

const

  WM_MSGEX_DATA = WM_USER + 1;

type

  // MsgExService Implementation
  TMsgExServiceImpl = class(TBaseInterfacedObject, IMsgExService)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // MsgHandle
    FMsgHandle: THandle;
    // MsgExPool
    FMsgExPool: TMsgExPool;
    // MsgExQueue
    FMsgExQueue: TSafeQueue<TMsgEx>;
    // SubcriberMgr
    FSubcriberMgr: TMsgExSubcriberMgr;
    // AsyncDispachMsgExThread
    FAsyncDispachMsgExThread: TExecutorThread;
  protected
    // ClearQueue
    procedure DoClearQueue;
    // SendMessageEx
    procedure DoSendMessageEx;
    // WndProc
    procedure DoWndProc(var Message: TMessage);
    // AsyncDispachMsgExThread
    procedure DoAsyncDispachMsgExThread(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    {IMsgExService}

    // StopService
    procedure StopService;
    // SendMessageEx
    procedure SendMessageEx(AID: Integer; AInfo: string);
    // Subcriber
    procedure Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // UnSubcriber
    procedure UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
  end;


implementation

{ TMsgExServiceImpl }

constructor TMsgExServiceImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FMsgHandle := Classes.AllocateHWnd(DoWndProc);
  FMsgExPool := TMsgExPool.Create(50);
  FMsgExQueue := TSafeQueue<TMsgEx>.Create;
  FSubcriberMgr := TMsgExSubcriberMgr.Create(AContext);
  FAsyncDispachMsgExThread := TExecutorThread.Create;
  FAsyncDispachMsgExThread.ThreadMethod := DoAsyncDispachMsgExThread;
  FAsyncDispachMsgExThread.StartEx;
  FIsStart := True;
end;

destructor TMsgExServiceImpl.Destroy;
begin
  StopService;
  DoClearQueue;
  FSubcriberMgr.Free;
  FMsgExQueue.Free;
  FMsgExPool.Free;
  Classes.DeallocateHWnd(FMsgHandle);
  FLock.Free;
  inherited;
end;

procedure TMsgExServiceImpl.DoClearQueue;
var
  LMsgEx: TMsgEx;
begin
  while not FMsgExQueue.IsEmpty do begin
    LMsgEx := FMsgExQueue.Dequeue;
    if LMsgEx <> nil then begin
      LMsgEx.Free;
    end;
  end;
end;

procedure TMsgExServiceImpl.DoSendMessageEx;
begin
  if FMsgHandle <> 0 then begin
    PostMessage(FMsgHandle, WM_MSGEX_DATA, 0, 0);
  end;
end;

procedure TMsgExServiceImpl.DoWndProc(var Message: TMessage);
var
  LMsgEx: TMsgEx;
begin
  case message.Msg of
    WM_MSGEX_DATA:
      begin
        if (not FIsStart)
          or FMsgExQueue.IsEmpty then Exit;

        LMsgEx := FMsgExQueue.Dequeue;
        if LMsgEx <> nil then begin
          FSubcriberMgr.InvokeNotify(LMsgEx);
          FMsgExPool.DeAllocate(LMsgEx);
        end;
      end;
  end;
end;

procedure TMsgExServiceImpl.DoAsyncDispachMsgExThread(AObject: TObject);
begin
  while not FAsyncDispachMsgExThread.IsTerminated do begin

    case FAsyncDispachMsgExThread.WaitForEx(INFINITE) of
      WAIT_OBJECT_0:
        begin
          if not FMsgExQueue.IsEmpty then begin
            DoSendMessageEx;
          end;
        end;
    end;
  end;
end;

procedure TMsgExServiceImpl.StopService;
begin
  if FIsStart then begin
    FAsyncDispachMsgExThread.ShutDown;
    FIsStart := False;
  end;
end;

procedure TMsgExServiceImpl.SendMessageEx(AID: Integer; AInfo: string);
var
  LMsgEx: TMsgEx;
begin
  if not FIsStart then Exit;
  
  FLock.Lock;
  try
    LMsgEx := TMsgEx(FMsgExPool.Allocate);
    if LMsgEx <> nil then begin
      TMsgExImpl(LMsgEx).Update(AID, AInfo);
      FMsgExQueue.Enqueue(LMsgEx);
      FAsyncDispachMsgExThread.ResumeEx;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgExServiceImpl.Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
begin
  FSubcriberMgr.Subcriber(AMsgExId, ASubcriber);
end;

procedure TMsgExServiceImpl.UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
begin
  FSubcriberMgr.UnSubcriber(AMsgExId, ASubcriber);
end;

end.
