unit LoadProcessImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º LoadProcess Implementation
// Author£º      lksoulman
// Date£º        2017-11-17
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  BaseObject,
  AppContext,
  CommonQueue,
  LoadProcess,
  LoadProcessUI,
  ExecutorThread,
  CommonRefCounter;

type

  // LoadProcess Implementation
  TLoadProcessImpl = class(TBaseInterfacedObject, ILoadProcess)
  private
    // WaitEvent
    FWaitEvent: Cardinal;
    // LoadProcessUI
    FLoadProcessUI: TLoadProcessUI;
    // Auto Executor
    FAutoExecutor: TExecutorThread;
    // ShowInfoQueue
    FShowInfoQueue: TSafeSemaphoreQueue<string>;
  protected
    // Auto Show Execute
    procedure DoAutoShowExecute(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ILoadProcess }

    // Show
    function Show: Boolean;
    // Is Showing
    function IsShowing: Boolean;
    // Get Wait Event
    function GetWaitEvent: Cardinal;
    // Show
    procedure ShowInfo(AInfo: string);
  end;

implementation

{ TLoadProcessImpl }

constructor TLoadProcessImpl.Create(AContext: IAppContext);
begin
  inherited;
  FWaitEvent := CreateEvent(nil, false, False, nil);
  FShowInfoQueue := TSafeSemaphoreQueue<string>.Create;
  FLoadProcessUI := TLoadProcessUI.Create(AContext);
  FAutoExecutor := TExecutorThread.Create;
  FAutoExecutor.ThreadMethod := DoAutoShowExecute;
  FAutoExecutor.StartEx;
end;

destructor TLoadProcessImpl.Destroy;
begin
  FAutoExecutor.ShutDown;
  FLoadProcessUI.Free;
  FShowInfoQueue.Free;
  if FWaitEvent <> 0 then begin
    SetEvent(FWaitEvent);
    CloseHandle(FWaitEvent);
  end;
  inherited;
end;

function TLoadProcessImpl.Show: Boolean;
begin
  Result := False;
  if FLoadProcessUI = nil then Exit;

  if not FLoadProcessUI.Showing then begin
    FLoadProcessUI.Show;
  end;
end;

function TLoadProcessImpl.IsShowing: Boolean;
begin
  Result := False;
  if FLoadProcessUI = nil then Exit;

  Result := FLoadProcessUI.Showing;
end;

function TLoadProcessImpl.GetWaitEvent: Cardinal;
begin
  Result := FWaitEvent;
end;

procedure TLoadProcessImpl.ShowInfo(AInfo: string);
begin
  if FShowInfoQueue = nil then Exit;

  FShowInfoQueue.Enqueue(AInfo);
  FAutoExecutor.ResumeEx;
end;

procedure TLoadProcessImpl.DoAutoShowExecute(AObject: TObject);
var
  LShowInfo: string;
begin
  while not FAutoExecutor.IsTerminated do begin
    case FAutoExecutor.WaitForEx(INFINITE) of
      WAIT_OBJECT_0:
        begin
          if not FShowInfoQueue.IsEmpty then begin
            LShowInfo := FShowInfoQueue.Dequeue;
            if UpperCase(LShowInfo) <> 'CLOSE' then begin
              FLoadProcessUI.ShowInfo(LShowInfo);
            end else begin
              if FLoadProcessUI.Showing then begin
                FLoadProcessUI.Hide;
              end;
              if FWaitEvent <> 0 then begin
                SetEvent(FWaitEvent);
              end;
            end;
          end;
        end;
    end;
    Sleep(400);
  end;
end;

end.
