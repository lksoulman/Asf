unit IOCPMemory;

interface

uses Windows, Classes, SysUtils, ZLib;

const

  M_SIZE_2K = 2048;
  M_SIZE_4K = 4096;
  M_SIZE_8K = 8192;
  M_SIZE_16K = 16384;
  M_SIZE_32K = 32768;
  M_SIZE_64K = 65536;
  M_SIZE_128K = 131072;
  M_SIZE_256K = 262144;
  M_SIZE_512K = 524288;
  M_SIZE_1M = 1048576;
  M_SIZE_2M = 2097152;

  C_QueueSize: array [0 .. 10] of integer = (M_SIZE_2K, M_SIZE_4K, M_SIZE_8K, M_SIZE_16K, M_SIZE_32K, M_SIZE_64K,
    M_SIZE_128K, M_SIZE_256K, M_SIZE_512K, M_SIZE_1M, M_SIZE_2M);
  C_InitCount = 1;

type

  // ����Ķ����ǱȽϳ����֧��FIFO��LIFO�Ķ��У������ӵ�Ԫ����ָ��ʹ�С
  // ��������ʹ�ù����в���������ͷ��ڴ棨�������ǰ�汾���ش�׶ˣ���
  // ��˲����Ƚϰ�ȫ�Ϳ���

  PQueueItem = ^TQueueItem;

  TQueueItem = packed record
    DataSize: integer; // ��ǰ���ݵĴ�С
    QueueValue: Pointer; // һ���ڴ��ָ�룬����ָ���κ�����
    Next: PQueueItem;
    Prior: PQueueItem;
  end;

  TIOCPQueue = class
  private
    FQueueHeads: TList;

    FHeadPtr: PQueueItem; // ��ǰ������ͷ��β  ��ȡ����FHeadPtr������������FTailPtr
    FTailPtr: PQueueItem;

    FCapacity: integer; // ��������   ���ڳ�ʼ���ڴ�ӳ����
    FCount: integer; // ���и���

    FNeedSema: boolean;
    FRCSQueueProtect: TRTLCriticalSection;
    FQueueSemaphore: THandle;

    function GetIsBlank: boolean;
  protected

    function DeltaCount(Value: integer): integer;
    function GrowQuete(Value: integer): boolean;

    function GetFIFOItem(var Size: integer; pRemainCount: PInteger = nil): Pointer;
    function GetLIFOItem(var Size: integer; pRemainCount: PInteger = nil): Pointer;
  public
    constructor Create(Capacity: integer; NeedSema: boolean = true);
    destructor Destroy; override;

    property IsBlank: boolean read GetIsBlank; // ͷ����β���ǿ�
    property QueueSize: integer read FCapacity;
    property Count: integer read FCount;
    property QueueSemaphore: THandle read FQueueSemaphore;
    procedure ClearItem; // ͷ��β�������

    function AddItem(Data: Pointer; Size: integer): bool;
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; virtual; abstract;
    function Pop: Pointer;
    procedure LockQueue;
    procedure UnLockQueue;
    function ReleaseSemaphore(lReleaseCount: Longint; lpPreviousCount: Pointer): bool;
  end;

  // �Ƚ��ȳ�
  TFIFOQueue = class(TIOCPQueue)
  public
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; override;
  end;

  // �Ƚ����
  TLIFOQueue = class(TIOCPQueue)
  public
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; override;
  end;

  PMemoryBlock = ^TMemoryBlock;
  TMemoryBlock = (mbBlock_2K = 0, // 2K��
    mbBlock_4K = 1, // 4K��
    mbBlock_8K = 2, // 8K��
    mbBlock_16K = 3, // 16K��
    mbBlock_32K = 4, // 32K��
    mbBlock_64K = 5, // 64K��
    mbBlock_128K = 6, // 128K��
    mbBlock_256K = 7, // 256K��
    mbBlock_512K = 8, // 512K��
    mbBlock_1M = 9, // 1M��
    mbBlock_2M = 10, // 2M��
    mbBlock_Free = 11);

function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
function FreeMemEx(P: Pointer): boolean;

implementation

// function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
// begin
// P := IOCPMemMngr.GetMemEx(Size);
// result := p <> nil;
// end;
//
// function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
// begin
// P := IOCPMemMngr.GetMemEx(Size);
// result := p <> nil;
// end;
//
// function FreeMemEx(P: Pointer): boolean;
// begin
// IOCPMemMngr.FreeMemEx(P);
// result := true;
// end;
//
// function ReallocMemEx(var P: Pointer; Size: integer): boolean;
// begin
// p := IOCPMemMngr.ReallocMemEx(p, Size);
// result := true;
// end;
//
function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
begin

  GetMem(Pointer(P), Size);
  result := P <> nil;
  // result := _GetMemEx(p, Size);
end;

function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
begin
  GetMem(P, Size);
  result := P <> nil;
  // result := _GetMemEx(p, Size);
end;

function FreeMemEx(P: Pointer): boolean;
begin
  FreeMem(P);
  result := true;
  // result := _FreeMemEx(P);
end;

function zlibAllocMem(AppData: Pointer; Items, Size: integer): Pointer;
begin
  GetMemEx(result, Items * Size);
  FillMemory(result, Items * Size, 0);
End;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
  FreeMemEx(Block);
End;

function DeflateInit(var stream: TZStreamRec; level: integer): integer;
begin
  result := DeflateInit_(stream, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit(var stream: TZStreamRec): integer;
begin
  result := InflateInit_(stream, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function ZCompressCheck(code: integer): integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZCompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

function ZDecompressCheck(code: integer): integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZDecompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

{ TIOCPQueue }

function TIOCPQueue.AddItem(Data: Pointer; Size: integer): bool;
var
  Value: integer;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    if FCount >= FCapacity then
    begin
      Value := DeltaCount(FCapacity);
      GrowQuete(Value - FCapacity);
      FCapacity := Value;
    end;

    FTailPtr^.QueueValue := Data;
    FTailPtr^.DataSize := Size;

    FTailPtr := FTailPtr^.Next;

    FCount := FCount + 1;
    result := true;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

procedure TIOCPQueue.ClearItem;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    if FQueueHeads.Count > 0 then
    begin
      FHeadPtr := FQueueHeads[0];
      FTailPtr := FHeadPtr;
    end;
    FCount := 0;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

constructor TIOCPQueue.Create(Capacity: integer; NeedSema: boolean);
begin
  FCount := 0;

  FNeedSema := NeedSema;

  FQueueHeads := TList.Create;

  // ��ʼ���ٽ���Դ
  InitializeCriticalSection(FRCSQueueProtect);

  if FNeedSema then
    FQueueSemaphore := CreateSemaphore(nil, 0, High(integer), nil);

  if Capacity <= 1 then
    FCapacity := 2
  else
    FCapacity := Capacity;

  GrowQuete(FCapacity);
end;

function TIOCPQueue.DeltaCount(Value: integer): integer;
begin
  if Value > 255 then
    result := Value + Value div 4
  else
    result := Value + 64
end;

destructor TIOCPQueue.Destroy;
var
  i: integer;
begin
  DeleteCriticalSection(FRCSQueueProtect);

  if FQueueHeads <> nil then
  begin
    for i := 0 to FQueueHeads.Count - 1 do
      FreeMemEx(FQueueHeads[i]);
    FQueueHeads.Free;
  end;

  if FNeedSema and (FQueueSemaphore <> 0) then
  begin
    CloseHandle(FQueueSemaphore);
    FQueueSemaphore := 0;
  end;

  inherited Destroy;
end;

function TIOCPQueue.GetFIFOItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    result := FHeadPtr^.QueueValue;
    Size := FHeadPtr^.DataSize;
    FHeadPtr := FHeadPtr^.Next;
    FCount := FCount - 1;
    if pRemainCount <> nil then
      pRemainCount^ := FCount;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

function TIOCPQueue.GetIsBlank: boolean;
begin
  result := FHeadPtr = FTailPtr;
end;

function TIOCPQueue.GetLIFOItem(var Size: integer; pRemainCount: PInteger): Pointer;
var
  LIFOItem: PQueueItem;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    LIFOItem := FTailPtr^.Prior;
    result := LIFOItem^.QueueValue;
    Size := LIFOItem^.DataSize;

    FTailPtr := FTailPtr^.Prior;
    FCount := FCount - 1;
    if pRemainCount <> nil then
      pRemainCount^ := FCount;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

function TIOCPQueue.GrowQuete(Value: integer): boolean;
var
  i: integer;
  pItem: PQueueItem;
  QueueHead: Pointer;
begin
  result := false;
  GetMemEx(QueueHead, Value * SizeOf(TQueueItem));

  if QueueHead <> nil then
  begin

    // ���濪ʼ��������
    result := true;

    pItem := QueueHead;
    for i := 1 to Value - 1 do
    begin
      pItem.Next := Pointer(integer(pItem) + SizeOf(TQueueItem));
      if pItem <> QueueHead then
        pItem.Prior := Pointer(integer(pItem) - SizeOf(TQueueItem));
      inc(pItem);
    end;
    // ���һ��
    pItem.Prior := Pointer(integer(pItem) - SizeOf(TQueueItem));

    if FQueueHeads.Count = 0 then
    begin
      // �ֻص���ǰ
      pItem.Next := QueueHead;
      PQueueItem(QueueHead).Prior := pItem;
      FHeadPtr := QueueHead;
      FTailPtr := QueueHead;
    end
    else
    begin
      // �Ͽ�����
      PQueueItem(QueueHead)^.Prior := FTailPtr^.Prior;
      FTailPtr^.Prior^.Next := PQueueItem(QueueHead);
      pItem^.Next := FHeadPtr;
      FHeadPtr^.Prior := pItem;
      FTailPtr := QueueHead;
    end;

    FQueueHeads.Add(QueueHead);
  end;
end;

procedure TIOCPQueue.LockQueue;
begin
  EnterCriticalSection(FRCSQueueProtect);
end;

function TIOCPQueue.Pop: Pointer;
var
  Size: integer;
begin
  result := GetItem(Size, nil);
end;

function TIOCPQueue.ReleaseSemaphore(lReleaseCount: integer; lpPreviousCount: Pointer): bool;
begin
  result := Windows.ReleaseSemaphore(FQueueSemaphore, lReleaseCount, lpPreviousCount);
end;

procedure TIOCPQueue.UnLockQueue;
begin
  LeaveCriticalSection(FRCSQueueProtect);
end;

{ TFIFOQueue }
function TFIFOQueue.GetItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  result := nil;
  if (FCount > 0) then
  begin
    result := GetFIFOItem(Size, pRemainCount);
  end;
end;

{ TLIFOQueue }
function TLIFOQueue.GetItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  result := nil;
  if (FCount > 0) then
  begin
    result := GetLIFOItem(Size, pRemainCount);
  end;
end;

//
// initialization
// IOCPMemMngr := TIOCPMemory.Create;
//
//
// finalization
// IOCPMemMngr.Free;
end.
