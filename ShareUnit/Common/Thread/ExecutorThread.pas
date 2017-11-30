unit ExecutorThread;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-5-1
// Comments：    {Doug Lea thread}
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  ExecutorTask;

type

  // ExecutorThread
  TExecutorThread = class(TThread)
  private
  protected
    // 是不是启动
    FIsStart: Boolean;
    // 线程是不是正在执行
    FIsRunning: boolean;
    // 信号量
    FSemaphore: THandle;
    // 等待的开始时间
    FWaitStartTime: Cardinal;
    // 线程调用绑定的过程
    FThreadMethod: TNotifyEvent;
    // 提供携带的对象
    FObjectRef: TObject;

    // 线程启动执行方法
    procedure Execute; override;
    // 关闭线程
    procedure DoShutDown; virtual;
    // 替换执行接口
    procedure DoSubmitTask(ATask: IExecutorTask); virtual;
  public
    // 构造方法
    constructor Create; overload; virtual;
    // 析构方法
    destructor Destroy; override;
    // 启动线程
    procedure StartEx;
    // 关闭线程
    function ShutDown: Boolean;
    // 空闲时间
    function IdleTime: Cardinal;
    // 启动
    function ResumeEx: LongBool;
    // 等待
    function WaitForEx(AWaitTime: Cardinal = INFINITE): LongWord;
    // 线程是不是终止
    function IsTerminated: Boolean;
    // 提交执行接口
    function SubmitTask(ATask: IExecutorTask): Boolean;

    property IsStart: Boolean read FIsStart;
    property ObjectRef: TObject read FObjectRef write FObjectRef;
    property ThreadMethod: TNotifyEvent read FThreadMethod write FThreadMethod;
  end;

  TExecutorThreadClass = class of TExecutorThread;

implementation

{ TExecutorThread }

constructor TExecutorThread.Create;
begin
  inherited Create(True);
  FIsStart := False;
  FIsRunning := False;
  FreeOnTerminate := True;
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

destructor TExecutorThread.Destroy;
begin
  CloseHandle(FSemaphore);
  inherited;
end;

procedure TExecutorThread.Execute;
begin
  if Assigned(FThreadMethod) then begin
    FThreadMethod(Self);
  end;
end;

procedure TExecutorThread.StartEx;
begin
  if not FIsStart then begin
    Start;
    FIsStart := True;
  end;
end;

function TExecutorThread.ShutDown: Boolean;
begin
  if not Terminated then begin
    DoShutDown;
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TExecutorThread.IdleTime: Cardinal;
begin
  if FIsRunning then begin
    Result := 0;
  end else begin
    Result := GetTickCount - FWaitStartTime;
  end;
end;

function TExecutorThread.ResumeEx: LongBool;
var
  LCount: Integer;
begin
  Result := Windows.ReleaseSemaphore(FSemaphore, 1, @LCount);
end;

function TExecutorThread.WaitForEx(AWaitTime: Cardinal = INFINITE): LongWord;
begin
  FWaitStartTime := GetTickCount;
  Result := WaitForSingleObject(FSemaphore, AWaitTime);
end;

function TExecutorThread.IsTerminated: boolean;
begin
  Result := Terminated;
end;

function TExecutorThread.SubmitTask(ATask: IExecutorTask): Boolean;
begin
  DoSubmitTask(ATask);
  Result := True;
end;

procedure TExecutorThread.DoShutDown;
begin
  Terminate;
  WaitForSingleObject(Self.Handle, 100);
end;

procedure TExecutorThread.DoSubmitTask(ATask: IExecutorTask);
begin
  if IsTerminated then Exit;

  FIsRunning := True;
  try
    if ATask <> nil then begin
      ATask.Run(Self);
      ATask.CallBack;
    end;
  finally
    FIsRunning := False;
  end;
end;

end.
