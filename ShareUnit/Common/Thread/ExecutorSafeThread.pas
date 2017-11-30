unit ExecutorSafeThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  ExecutorThread;

type

  TExecutorSafeThread = class(TExecutorThread)
  private
  protected
    // ��ȫ��
    FLock: TCSLock;
    // �߳��ǲ�������ִ��
    FIsRunning: boolean;
    // �ȴ��Ľ���ʱ��
    FWaitEndTime: TDateTime;
    // �ȴ��Ŀ�ʼʱ��
    FWaitStartTime: TDateTime;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    // ����
    procedure Lock;
    // ����
    procedure UnLock;
    // ��ȡ�ǲ�����������
    function GetIsRunning: Boolean;
    // ��������״̬
    procedure SetIsRunning(AIsRunning: Boolean);
  end;

implementation

{ TExecutorSafeThread }

constructor TExecutorSafeThread.Create;
begin
  inherited;
  FLock := TCSLock.Create;
end;

destructor TExecutorSafeThread.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TExecutorSafeThread.Lock;
begin
  FLock.Lock;
end;

procedure TExecutorSafeThread.UnLock;
begin
  FLock.UnLock;
end;

function TExecutorSafeThread.GetIsRunning: Boolean;
begin
  Result := FIsRunning;
end;

procedure TExecutorSafeThread.SetIsRunning(AIsRunning: Boolean);
begin
  FIsRunning := AIsRunning;
end;

end.
