unit ExecutorThread;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-5-1
// Comments��    {Doug Lea thread}
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
    // �ǲ�������
    FIsStart: Boolean;
    // �߳��ǲ�������ִ��
    FIsRunning: boolean;
    // �ź���
    FSemaphore: THandle;
    // �ȴ��Ŀ�ʼʱ��
    FWaitStartTime: Cardinal;
    // �̵߳��ð󶨵Ĺ���
    FThreadMethod: TNotifyEvent;
    // �ṩЯ���Ķ���
    FObjectRef: TObject;

    // �߳�����ִ�з���
    procedure Execute; override;
    // �ر��߳�
    procedure DoShutDown; virtual;
    // �滻ִ�нӿ�
    procedure DoSubmitTask(ATask: IExecutorTask); virtual;
  public
    // ���췽��
    constructor Create; overload; virtual;
    // ��������
    destructor Destroy; override;
    // �����߳�
    procedure StartEx;
    // �ر��߳�
    function ShutDown: Boolean;
    // ����ʱ��
    function IdleTime: Cardinal;
    // ����
    function ResumeEx: LongBool;
    // �ȴ�
    function WaitForEx(AWaitTime: Cardinal = INFINITE): LongWord;
    // �߳��ǲ�����ֹ
    function IsTerminated: Boolean;
    // �ύִ�нӿ�
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
