unit CommonQueue;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,  
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type


  TSemaphoreQueue<T> = class(TAutoObject)
  protected
    // ���й������
    FQueue: TQueue<T>;
    // Windows �źž��
    FSemaphore: Cardinal;

    // ��ʼ�� Windows �źž��
    procedure InitSemaphore;
    // ж�� Windows �źž��
    procedure UnInitSemaphore;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ������
    function Dequeue: T; virtual;
    // ������
    procedure Enqueue(const AValue: T); virtual;
    // �ͷ��ź�
    procedure ReleaseSemaphore;

    property Semaphore: Cardinal read FSemaphore;
  end;

  TSafeQueue<T> = class(TAutoObject)
  protected
    // ���й������
    FQueue: TQueue<T>;
    // �̰߳�ȫ��
    FLock: TCSLock;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ������
    function Dequeue: T;
    // ������
    procedure Enqueue(const AValue: T);
    // �����ǲ���Ϊ��
    function IsEmpty: boolean;
  end;

  TSafeSemaphoreQueue<T> = class(TSemaphoreQueue<T>)
  protected
    // �̰߳�ȫ��
    FLock: TCSLock;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ������
    function Dequeue: T; override;
    // ������
    procedure Enqueue(const AValue: T); override;
    // �����ǲ���Ϊ��
    function IsEmpty: boolean;
  end;

  TSafeSemaphoreCircularQueue = class
  private
    // �̰߳�ȫ��
    FLock: TCSLock;
    // ����Ԫ�ظ���
    FCount: Integer;
    // ��������
    FCapacity: Integer;
    // Windows �źž��
    FSemaphore: Cardinal;
    // Ԫ��ָ��
    FElements: Array of Pointer;
    // Ԫ���±�
    FElementIndex: Integer;

    // ��ʼ�� Windows �źž��
    procedure InitSemaphore;
    // ж�� Windows �źž��
    procedure UnInitSemaphore;
  protected
    // �����µ�����
    function NewCapacity: Integer;
    // ��������
    procedure GrowCapacity(ANewCapacity: Integer);
  public
    // ���췽��
    constructor Create(ACapacity: Integer); virtual;
    // ��������
    destructor Destroy; override;
    // Ԫ���±�ŵ���һ��
    procedure First;
    // Ԫ���±�ŵ���һ��
    procedure Next;
    // ���
    procedure Clear;
    // �ǲ��ǽ���
    function IsEOF: Boolean;
    // ����һ��Ԫ����ĩβ
    procedure Add(AElement: Pointer);
    // ����һ��Ԫ���ڵ�ǰ��ѭ��������һ��Ԫ�ص��±�
    procedure AddAtElementIndex(AElement: Pointer);
    // ��ȡ��һ��Ԫ�ز����ƶ��±�
    function GetNextElement: Pointer;
    // ��ȡ��ǰԪ��
    function GetCurrentElement: Pointer;
    // �ͷ��ź�
    procedure ReleaseSemaphore;

    property Semaphore: Cardinal read FSemaphore;
  end;


implementation

{ TSemaphoreQueue<T> }

constructor TSemaphoreQueue<T>.Create;
begin
  inherited;
  FQueue := TQueue<T>.Create;
  InitSemaphore;
end;

destructor TSemaphoreQueue<T>.Destroy;
begin
  UnInitSemaphore;
  FQueue.Free;
  inherited;
end;

procedure TSemaphoreQueue<T>.InitSemaphore;
begin
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

procedure TSemaphoreQueue<T>.UnInitSemaphore;
begin
  CloseHandle(FSemaphore);
end;

procedure TSemaphoreQueue<T>.Enqueue(const AValue: T);
begin
  FQueue.Enqueue(AValue);
end;

function TSemaphoreQueue<T>.Dequeue: T;
begin
  Result := FQueue.Dequeue;
end;

procedure TSemaphoreQueue<T>.ReleaseSemaphore;
var
  tmpCount: Integer;
begin
  Windows.ReleaseSemaphore(FSemaphore, 1, @tmpCount);
end;

{ TSafeQueue<T> }

constructor TSafeQueue<T>.Create;
begin
  inherited;
  FQueue := TQueue<T>.Create;
  FLock := TCSLock.Create;
end;

destructor TSafeQueue<T>.Destroy;
begin
  FLock.Free;
  FQueue.Free;
  inherited;
end;

function TSafeQueue<T>.Dequeue: T;
begin
  FLock.Lock;
  try
    Result := FQueue.Dequeue;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeQueue<T>.Enqueue(const AValue: T);
begin
  FLock.Lock;
  try
    FQueue.Enqueue(AValue);
  finally
    FLock.UnLock;
  end;
end;

function TSafeQueue<T>.IsEmpty: boolean;
begin
  FLock.Lock;
  try
    Result := (FQueue.Count <= 0);
  finally
    FLock.UnLock;
  end;
end;

{ TSafeSemaphoreQueue<T> }

constructor TSafeSemaphoreQueue<T>.Create;
begin
  inherited;
  FLock := TCSLock.Create;
end;

destructor TSafeSemaphoreQueue<T>.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TSafeSemaphoreQueue<T>.Dequeue: T;
begin
  FLock.Lock;
  try
    Result := FQueue.Dequeue;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreQueue<T>.Enqueue(const AValue: T);
begin
  FLock.Lock;
  try
    FQueue.Enqueue(AValue);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreQueue<T>.IsEmpty: boolean;
begin
  FLock.Lock;
  try
    Result := (FQueue.Count <= 0);
  finally
    FLock.UnLock;
  end;
end;

{ TSafeSemaphoreCircularQueue }

constructor TSafeSemaphoreCircularQueue.Create(ACapacity: Integer);
begin
  inherited Create;
  InitSemaphore;
  FLock := TCSLock.Create;
  FCount := 0;
  FElementIndex := 0;
  if ACapacity < 0 then begin
    ACapacity := 10;
  end;
  FCapacity := ACapacity;
  self.GrowCapacity(FCapacity);
end;

destructor TSafeSemaphoreCircularQueue.Destroy;
begin
  FLock.Free;
  UnInitSemaphore;
  inherited;
end;

function TSafeSemaphoreCircularQueue.NewCapacity: Integer;
begin
  Result := FCapacity * 2;
end;

procedure TSafeSemaphoreCircularQueue.GrowCapacity(ANewCapacity: Integer);
begin
  SetLength(FElements, ANewCapacity);
end;

procedure TSafeSemaphoreCircularQueue.InitSemaphore;
begin
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

procedure TSafeSemaphoreCircularQueue.UnInitSemaphore;
begin
  CloseHandle(FSemaphore);
end;

procedure TSafeSemaphoreCircularQueue.First;
begin
  FElementIndex := 0;
end;

procedure TSafeSemaphoreCircularQueue.Next;
begin
  FLock.Lock;
  try
    if FCount = 0 then Exit;

    FElementIndex := (FElementIndex + 1) mod FCount;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.ReleaseSemaphore;
var
  tmpCount: Integer;
begin
  Windows.ReleaseSemaphore(FSemaphore, 1, @tmpCount);
end;

procedure TSafeSemaphoreCircularQueue.Clear;
begin
  FLock.Lock;
  try
    FCount := 0;
    SetLength(FElements, 0);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.IsEOF: Boolean;
begin
  FLock.Lock;
  try
    if FElementIndex = FCount - 1 then begin
      Result := True;
    end else begin
      Result := False;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.Add(AElement: Pointer);
begin
  FLock.Lock;
  try
    if FCount >= FCapacity then begin
      GrowCapacity(NewCapacity);
    end;
    FElements[FCount] := AElement;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.AddAtElementIndex(AElement: Pointer);
var
  LIndex: Integer;
begin
  FLock.Lock;
  try
    if FCount >= FCapacity then begin
      GrowCapacity(NewCapacity);
    end;
    if (FCount > 0) or (FElementIndex < FCount - 1) then begin
      LIndex := (FElementIndex + 1) mod FCount;
      CopyMemory(@FElements[LIndex], @FElements[LIndex + 1], (FCount - LIndex));
    end else begin
      LIndex := FCount;
    end;
    FElements[LIndex] := AElement;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.GetNextElement: Pointer;
begin
  FLock.Lock;
  try
    Result := nil;
    if FCount = 0 then Exit;
    Result := FElements[FElementIndex];
    FElementIndex := (FElementIndex + 1) mod FCount;
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.GetCurrentElement: Pointer;
begin
  Result := nil;
  FLock.Lock;
  try
    if (FCount = 0) or (FElementIndex >= FCount) then Exit;
    Result := FElements[FElementIndex];
  finally
    FLock.UnLock;
  end;
end;

end.
