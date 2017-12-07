// ����ͨѶ��ķ���

unit QuoteService;

interface

uses Windows, Classes, SysUtils, Messages, IOCPClient, IOCPLibrary, IOCPMemory,
  QuoteMngr_TLB, IniFiles, ZLib, QuoteConst, QuoteStruct, QuoteLibrary;

const

  C_CONNECT_INDEX = -99;

type
  // etWriteLog д��־ etProgress ��ʾ����  etConnected ���ӳɹ�   etDisconnected �Ͽ�����
  // etConnectServerError ���ӷ�����ʧ��
  // etLogin ��½�ɹ�
  TEventType = (etWriteLog = 1, etProgress = 2, etConnected = 3, etDisconnected = 4, etConnectServerError = 5,
    etLogin = 6, etLoginLevel = 7, etLoginFutues = 8, etLoginHK = 9, etLoginForeign = 10, etAnsKeepActive = 11,
    etInited = 12, etLoginDDE = 13, etLoginUSStock = 14);

  TOnHandleBusiness = procedure(pData: Pointer; size: Integer) of object;
  TOnKeepActive = procedure(ServerType: ServerTypeEnum) of object;

  // TCP�յ�������
  PRecvData = ^TRecvData;

  TRecvData = packed record
    DataLen: Cardinal;
    Data: PAnsiChar;
  end;

  // ��������ṹ��ɨ���߳����ɣ��������̺߳���Դ�ͷ��߳�ʹ��
  // �����һ��ͨ�ýṹ��������¼һ��ͷ��β������ʽ���ݣ���������һ����������
  PSendData = ^TSendData;

  TSendData = packed record
    Index: Integer;
    Data: PAnsiChar;
    DataLen: Cardinal;
    Head: PAnsiChar;
    HeadLen: Cardinal;
    Tail: PAnsiChar;
    TailLen: Cardinal;
    Flag: Integer;
  end;

  PEventData = ^TEventData;

  TEventData = packed record
    EventType: TEventType;
    SValue: PAnsiChar;
    SValueLen: Cardinal;
    Data: PAnsiChar;
    DataLen: Cardinal;
    Flag: Integer;
  end;

  TConnectStatus = (csFree, csConnecting, csConnected);

  PTQuoteContext = ^TQuoteContext;

  TQuoteContext = record
    ServerIP: AnsiString; // ������IP
    ServerPort: Word; // �������˿�
    ServerType: ServerTypeEnum; // ���ӷ���������
    Connected: TConnectStatus; // ��ǰ����״̬
    KeepCount: Word; // �������ӵļ�ʱֵ
  end;

  TServerInfo = record
    ServerIP: AnsiString; // ������IP
    ServerPort: Word; // �������˿�
    Index: Integer;
    ServerType: ServerTypeEnum; // ����������
  end;

  // ������״̬
  TServerStatus = record
    Connected: Boolean; // ��ǰ����״̬
    TcpIndex: Integer;
    StepIndex: Integer;
    KeepCount: Word; // �������ӵļ�ʱֵ
    KeepActiveCount: Integer;
    KeepRecvTime: Double;
  end;

  TQuoteService = class;

  TQuoteDispatcher = class
  private
    FService: TQuoteService;
    FActive: Boolean;
    FThread: TThread; // �������߳�
    FRecvQueue: TIOCPQueue; // �յ�������
    procedure FreeRecvData;
  protected
    function StartService: Boolean; // ����
    procedure StopService; // ֹͣ
    procedure AddRecData(pData: PRecvData);
    function GetRecvData: PRecvData;
  public
    constructor Create(Service: TQuoteService);
    destructor Destroy; override;
  end;

  TDispatcherThread = class(TThread)
  private
    FDispatcher: TQuoteDispatcher;
    FService: TQuoteService;
  protected
    procedure Execute; override;
    procedure HandleOnePkg(pData: PRecvData);
  public
    constructor Create(Dispatcher: TQuoteDispatcher);
  end;

  TQuoteService = class
  private
    FHandle: THandle;
    FActive: Boolean;
    // ͨѶ���
    FTcpClient: TTcpClient;
    // ���Ͷ���
    FSendQueue: TIOCPQueue;
    // �¼�����
    FEventQueue: TIOCPQueue;
    // ����߳�
    FMonitorThread: TThread;
    FDispatcher: TQuoteDispatcher;
    FTCPContext: array [1 .. MAXIMUM_WAIT_OBJECTS - 1] of TQuoteContext;
    // ������
    FConcurrent: Word;
    FServerInfos: array of TServerInfo;
    // ������״̬
    FServerStatus: array [1 .. MAXIMUM_WAIT_OBJECTS - 1] of TServerStatus;

    FOnHandleBusiness: TOnHandleBusiness;
    FOnKeepActive: TOnKeepActive;

    // �����¼��Ķ��� ���� ������ ����ָ�� ���ݳ���
    procedure DoRecvDataOver(Sender: TTcpClient; const Index: byte; const ErrCode: Integer; const Data: PAnsiChar;
      const DataLen: Cardinal; const UseTime: Double);

    // �����¼��Ķ��� ���� ������
    procedure DoConnectOver(Sender: TTcpClient; const Index: byte; const ErrCode: Integer);

    // �����¼��Ķ�������
    procedure DoDisconnected(Sender: TTcpClient; const Index: byte);

    procedure DoWriteDebug(Sender: TTcpClient; const DebugStr: string);

    procedure InitQuoteClient;

    function GetSendData: PSendData;
    // ���ӷ����� Concurrent������
    function ConnectServer(ServerType: ServerTypeEnum; Count: Integer): Boolean;
    procedure DoHandleBusiness(pData: Pointer; size: Integer);
    procedure DoKeepActive(ServerType: ServerTypeEnum);

    procedure FreeSendData;
    procedure FreeEventData;
    procedure InitConnectStatus(ServerType: Integer);
    function CheckServerType(ServerType: ServerTypeEnum): Boolean;
  public
    constructor Create(Handle: THandle);
    destructor Destroy; override;
    procedure WriteDebug(const Value: string);
    procedure Progress(const Msg: string; Max, Value: Integer);
    function GetEventData: PEventData;
    function ClearSetting: Boolean;
    function ServerSetting(IP: string; Port: Word; SType: ServerTypeEnum): Boolean;

    // ����ʱ������
    function ConcurrentSetting(Value: Word): Boolean;
    // ����IP   ����˿�   �����û�  �������
    function Proxy1Setting(Kind: TProxyKind; proxyIP: string; proxyPort: Word; proxyUser: string;
      proxyPWD: string): Boolean;
    function Proxy2Setting(Kind: TProxyKind; proxyIP: string; proxyPort: Word; proxyUser: string;
      proxyPWD: string): Boolean;
    function StartService: Boolean; // ����
    procedure StopService(Savelog: Boolean = True); // ֹͣ
    procedure Connect(ServerType: ServerTypeEnum); // ���ӷ�����
    procedure Disconnect(ServerType: ServerTypeEnum); // �Ͽ�������

    property Active: Boolean read FActive;
    function Connected(ServerType: ServerTypeEnum): Boolean;
    function TcpIndex(ServerType: ServerTypeEnum = stStockLevelI): Integer;

    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var ServerIP: string; var ServerPort: Word);

    procedure SendData(const Index: Integer; Data: PAnsiChar; DataLen: Cardinal; Flag: Integer = 0); overload;
    // ����ķ���֧��"ͷ+������+β"��������
    procedure SendData(const Index: Integer; const Head, Data, Tail: Pointer; const HeadLen, DataLen, TailLen: Cardinal;
      Flag: Integer = 0); overload;
    // �����¼�
    procedure SendEvent(const EventType: TEventType; const Data: Pointer; const SValue: AnsiString;
      const DataLen: Cardinal; Flag: Integer);
    property OnHandleBusiness: TOnHandleBusiness read FOnHandleBusiness write FOnHandleBusiness;
    property OnKeepActive: TOnKeepActive read FOnKeepActive write FOnKeepActive;

    procedure SendKeepActiveCount(ServerType: ServerTypeEnum); // ������������
    // procedure SendKeepActiveTime(ServerType: ServerTypeEnum);     //��������ʱ��

    // function KeepActiveRecvTime(ServerType: ServerTypeEnum): double;   //��������ʱ��
    function KeepActiveRecvCount(ServerType: ServerTypeEnum): Integer; // ��������ʱ��
    procedure EventAnsKeepActive(ServerType: ServerTypeEnum); // �¼�����

    procedure IncKeepCount(ServerType: ServerTypeEnum; Step: Integer);
    function KeepCount(ServerType: ServerTypeEnum): Integer;
  end;

  // ��ʱ����߳�
  TMonitorThread = class(TThread)
  private
    FService: TQuoteService;
    FTcpClient: TTcpClient;
  protected
    procedure Execute; override;
  public
    constructor Create(Service: TQuoteService);
  end;

implementation

uses ComServ;

{ TQuoteService }

function TQuoteService.ConcurrentSetting(Value: Word): Boolean;
begin
  if not FActive then
  begin
    FConcurrent := Value;
    Result := True;
  end
  else
    Result := false;
end;

procedure TQuoteService.Connect(ServerType: ServerTypeEnum);
begin

  // WriteLogx('Connect1' + ServerTypeToStr(ServerType));
  // �����𶯺� ����
  WriteDebug('[TQuoteService.Connect] FActive=' + BoolToStr(FActive, true) + ' Connected=' +
    BoolToStr(Connected(ServerType), true) + ' ServerType=' + IntToStr(ServerType));
  if FActive and not Connected(ServerType) then
  begin

    InitConnectStatus(ServerType);
    ConnectServer(ServerType, FConcurrent);
  end;
end;

function TQuoteService.Connected(ServerType: ServerTypeEnum): Boolean;
var
  TIndex: Integer;
begin

  if ServerType < MAXIMUM_WAIT_OBJECTS - 1 then
  begin
    TIndex := TcpIndex(ServerType);
    Result := FTCPContext[TIndex].Connected = csConnected;
  end
  else
    Result := false;

end;

procedure TQuoteService.ConnectServerInfo(ServerType: ServerTypeEnum; var ServerIP: string; var ServerPort: Word);
var
  TIndex: Integer;
begin
  TIndex := TcpIndex(ServerType);
  if Active and Connected(ServerType) and (TcpIndex(ServerType) >= 0) then
  begin
    ServerIP := string(FTCPContext[TIndex].ServerIP);
    ServerPort := FTCPContext[TIndex].ServerPort;
  end;
end;

function TQuoteService.ConnectServer(ServerType: ServerTypeEnum; Count: Integer): Boolean;
var
  i: Integer;
begin

  // ��¼��ǰ���ӵ��ĸ�λ��
  if FServerStatus[ServerType].StepIndex = -1 then
    FServerStatus[ServerType].StepIndex := Low(FServerInfos);
  if FServerStatus[ServerType].StepIndex <= High(FServerInfos) then
  begin
    for i := FServerStatus[ServerType].StepIndex to high(FServerInfos) do
    begin
      // ����������
      if Count <= 0 then
      begin
        WriteDebug('���������ˣ�');
        Break;
      end;

      if FServerInfos[i].ServerType = ServerType then
      begin
        // ����  ��������
        SendData(C_CONNECT_INDEX, nil, 0, i);
        Dec(Count);
      end;

      Inc(FServerStatus[ServerType].StepIndex);
    end;
    Result := True;
  end
  else
    Result := false;
  if not Result then
  begin
    WriteDebug('���ӷ�����ʧ�ܣ�');
    SendEvent(etConnectServerError, nil, '', 0, 0);
  end;
end;

constructor TQuoteService.Create(Handle: THandle);
begin
  FConcurrent := 1;
  // ���� ͨѶ���
  FTcpClient := TTcpClient.Create;
  FHandle := Handle;

  // ���¼���ֵ
  FTcpClient.OnConnectOver := DoConnectOver;
  FTcpClient.OnDisconnected := DoDisconnected;
  FTcpClient.OnWriteDebug := DoWriteDebug;
  FTcpClient.OnRecvDataOver := DoRecvDataOver;

  // �¼���������
  FEventQueue := TFIFOQueue.Create(255, True);

  // ���Ͷ���
  FSendQueue := TFIFOQueue.Create(255, True);

  FDispatcher := TQuoteDispatcher.Create(Self);

  InitConnectStatus(-1);
end;

destructor TQuoteService.Destroy;
begin
  StopService(false);

  if FTcpClient <> nil then
  begin
    FTcpClient.Free;
    FTcpClient := nil;
  end;

  if FSendQueue <> nil then
  begin
    // �ͷ��ڴ�
    FreeSendData;
    FSendQueue.Free;
    FSendQueue := nil;
  end;

  if FEventQueue <> nil then
  begin
    // �ͷ��ڴ�
    FreeEventData;

    FEventQueue.Free;
    FEventQueue := nil;
  end;

  if FDispatcher <> nil then
  begin
    FDispatcher.Free;
    FDispatcher := nil;
  end;

  inherited Destroy;
end;

procedure TQuoteService.Disconnect(ServerType: ServerTypeEnum);
var
  i: Integer;
begin
  // �����𶯺� ����
  if FActive and Connected(ServerType) then
  begin
    InitConnectStatus(ServerType);

    for i := Low(FTCPContext) to High(FTCPContext) do
    begin
      if (FTCPContext[i].ServerType = ServerType) and (FTCPContext[i].Connected = csConnected) then
      begin
        FTcpClient.DisconnectFrom(i);
      end;
    end;
  end;
end;

function TQuoteService.StartService: Boolean;
begin

  if not FActive then
  begin
    FActive := True;
    InitQuoteClient;
    InitConnectStatus(-1);
    if not FDispatcher.StartService then
      WriteDebug('���ش�������������ʧ��');
    // ��ʼ��MonitorThread
    // WriteLogx('TMonitorThread.create');
    FMonitorThread := TMonitorThread.Create(Self);
    FMonitorThread.Resume;
    // WriteLogx('TMonitorThread.create ok');
  end;

  Result := True;

end;

procedure TQuoteService.StopService(Savelog: Boolean = True);
var
  i: Integer;
begin
  if FActive then
  begin
    FActive := false;

    InitConnectStatus(-1);

    FTcpClient.StopServer;

    if FMonitorThread <> nil then
    begin
      FMonitorThread.Terminate;
      if FSendQueue <> nil then
        FSendQueue.ReleaseSemaphore(1, nil);
      FMonitorThread := nil;
    end;
    // �ͷ��¼�����
    FreeEventData;
    // �ͷŷ��Ͷ���
    FreeSendData;

    // ֹͣ������
    FDispatcher.StopService;

    for i := Low(FTCPContext) to High(FTCPContext) do
    begin
      if FTCPContext[i].Connected = csConnected then
      begin
        FTcpClient.DisconnectFrom(i);
        if Savelog then
        begin

          SendEvent(etDisconnected, nil, '', 0, FTCPContext[i].ServerType);
          WriteDebug('StopService ���ӱ��Ͽ�');
        end;
      end;
    end;
  end;
end;

function TQuoteService.TcpIndex(ServerType: ServerTypeEnum): Integer;
begin
  // (CheckServerType)

  Result := FServerStatus[ServerType].TcpIndex;

end;

procedure TQuoteService.WriteDebug(const Value: string);
var
  eData: PEventData;
  AStr: String;
begin
  if FActive and (Value <> '') then
  begin

    GetMemEx(Pointer(eData), SizeOf(TEventData));
    FillMemory(eData, SizeOf(TEventData), 0);

    eData^.EventType := etWriteLog;
    AStr := Value;
    eData^.SValueLen := (length(AStr) + 1) * SizeOf(Char);
    GetMemEx(Pointer(eData^.SValue), eData^.SValueLen);
    ZeroMemory(eData^.SValue, eData^.SValueLen);
    System.Move(PChar(AStr)^, eData^.SValue^, eData^.SValueLen - SizeOf(Char));

    FEventQueue.AddItem(eData, 0);
    PostMessage(FHandle, WM_HandleEvent, 0, 0);
  end;
end;

procedure TQuoteService.IncKeepCount(ServerType: ServerTypeEnum; Step: Integer);
begin
  if Active and CheckServerType(ServerType) and Connected(ServerType) then
  begin
    if Step = 0 then
      FServerStatus[ServerType].KeepCount := 0
    else
      Inc(FServerStatus[ServerType].KeepCount, Step);
  end;
end;

procedure TQuoteService.InitConnectStatus(ServerType: Integer);
var
  i: Integer;
begin

  if ServerType = -1 then
  begin
    // ���ͷ����еĶ���Ȼ���ؽ�
    for i := low(FServerStatus) to high(FServerStatus) do
    begin
      FServerStatus[i].Connected := false;
      FServerStatus[i].TcpIndex := -1;
      FServerStatus[i].StepIndex := -1;
      FServerStatus[i].KeepCount := 0; // �������ӵļ�ʱֵ
      FServerStatus[i].KeepActiveCount := 0;
      FServerStatus[i].KeepRecvTime := 0;
    end;
  end
  else
  begin

    FServerStatus[ServerType].Connected := false;
    FServerStatus[ServerType].TcpIndex := -1;
    FServerStatus[ServerType].StepIndex := -1;
    FServerStatus[ServerType].KeepCount := 0; // �������ӵļ�ʱֵ
    FServerStatus[ServerType].KeepActiveCount := 0;
    FServerStatus[ServerType].KeepRecvTime := 0;
  end;

end;

procedure TQuoteService.InitQuoteClient;
var
  i: Integer;
begin

  // ���ͷ����еĶ���Ȼ���ؽ�
  for i := low(FTCPContext) to high(FTCPContext) do
  begin
    // FTCPContext[i].WriteItem := nil;   //������Ӻ��ĸ�Դ����
    FTCPContext[i].Connected := csFree; // ��ǰ����״̬
    FTCPContext[i].KeepCount := 0;

  end;
end;

function TQuoteService.KeepActiveRecvCount(ServerType: ServerTypeEnum): Integer;
begin
  if Active and CheckServerType(ServerType) and Connected(ServerType) then
  begin
    Result := FServerStatus[ServerType].KeepActiveCount;
  end
  else
    Result := 0;
end;

// function TQuoteService.KeepActiveRecvTime(ServerType: ServerTypeEnum): double;
// begin
// if Active and CheckServerType(ServerType) and Connected(ServerType) then begin
// result := FServerStatus[ServerType].KeepRecvTime;
// end else result := 0;
// end;

function TQuoteService.KeepCount(ServerType: ServerTypeEnum): Integer;
begin
  if Active and CheckServerType(ServerType) and Connected(ServerType) then
    Result := FServerStatus[ServerType].KeepCount
  else
    Result := 0;
end;

procedure TQuoteService.DoConnectOver(Sender: TTcpClient; const Index: byte; const ErrCode: Integer);
var
  FlagValue: Integer;
  ServerType: ServerTypeEnum;
begin
  FlagValue := Sender.Flags[index];
  ServerType := FServerInfos[FlagValue].ServerType;
  if ErrCode = CONST_SUCCESS_NO then
  begin

    if not Connected(ServerType) then
    begin
      // ״̬��ֵ
      FServerStatus[ServerType].Connected := True;
      FServerStatus[ServerType].TcpIndex := Index; // ��ǰʹ�õ�index

      FTCPContext[Index].Connected := csConnected;
      FTCPContext[Index].ServerIP := FServerInfos[FlagValue].ServerIP;
      FTCPContext[Index].ServerPort := FServerInfos[FlagValue].ServerPort;
      FTCPContext[Index].ServerType := FServerInfos[FlagValue].ServerType;

      WriteDebug(Format('���ӳɹ�... %S:%D', [FServerInfos[FlagValue].ServerIP, FServerInfos[FlagValue].ServerPort]));
      SendEvent(etConnected, nil, '', 0, FTCPContext[Index].ServerType);

    end
    else
    begin // �����ӳɹ��ˣ��ͺ���������������
      WriteDebug(Format('Cancel... %S:%D', [FServerInfos[FlagValue].ServerIP, FServerInfos[FlagValue].ServerPort]));
      FTcpClient.DisconnectFrom(Index);
    end;
  end
  else
  begin
    // ���û�����Ͼͼ�������
    WriteDebug('���ӷ�����[������/��Ϣ]:$' + IntToHex(ErrCode, 4) + '/' + GetErrorMsg(ErrCode, false) + '/' +
      string(FServerInfos[Sender.Flags[Index]].ServerIP));

    if not Connected(ServerType) then
      ConnectServer(ServerType, 1);
  end;
end;

procedure TQuoteService.DoDisconnected(Sender: TTcpClient; const Index: byte);
begin
  FTCPContext[Index].Connected := csFree;

  InitConnectStatus(FTCPContext[Index].ServerType);
  WriteDebug('DoDisconnected ���ӱ��Ͽ� IP=' + FTCPContext[Index].ServerIP + ' Port=' +
    IntToStr(FTCPContext[Index].ServerPort) +  ' KeepCount=' + IntToStr(FTCPContext[Index].KeepCount));

  SendEvent(etDisconnected, nil, '', 0, FTCPContext[Index].ServerType);
end;

procedure TQuoteService.DoHandleBusiness(pData: Pointer; size: Integer);
begin
  if Assigned(FOnHandleBusiness) then
    FOnHandleBusiness(pData, size);
end;

procedure TQuoteService.DoKeepActive(ServerType: ServerTypeEnum);
begin
  if Assigned(FOnKeepActive) then
    FOnKeepActive(ServerType);

end;

procedure TQuoteService.DoRecvDataOver(Sender: TTcpClient; const Index: byte; const ErrCode: Integer;
  const Data: PAnsiChar; const DataLen: Cardinal; const UseTime: Double);
var
  pData: PRecvData;
begin
  // �յ����ݣ��Ӹ�TCQuoteDispatcher����
  if ErrCode = CONST_SUCCESS_NO then
  begin
    GetMemEx(Pointer(pData), SizeOf(TRecvData));
    pData.DataLen := DataLen;

    GetMemEx(pData.Data, DataLen);
    CopyMemory(@pData.Data[0], Data, DataLen);

    // ֪ͨ�������߳�������
    FDispatcher.AddRecData(pData);
  end
  else
  begin
    FTCPContext[Index].Connected := csFree;
    InitConnectStatus(FTCPContext[Index].ServerType);

    SendEvent(etDisconnected, nil, '', 0, FTCPContext[Index].ServerType);
    WriteDebug('DoRecvDataOver ���ӱ��Ͽ� ' + IntToStr(ErrCode) + ':' + GetErrorMsg(ErrCode, false));
  end;
end;

procedure TQuoteService.DoWriteDebug(Sender: TTcpClient; const DebugStr: string);
begin
  WriteDebug(DebugStr);
end;

procedure TQuoteService.EventAnsKeepActive(ServerType: ServerTypeEnum);
begin
  if Active and CheckServerType(ServerType) and Connected(ServerType) then
  begin
    FServerStatus[ServerType].KeepRecvTime := now;
    FServerStatus[ServerType].KeepActiveCount := 0;
  end;
end;

procedure TQuoteService.FreeEventData;
var
  eData: PEventData;
begin
  if FEventQueue <> nil then
  begin
    // �ͷ��ڴ�
    FEventQueue.LockQueue;
    try
      eData := FEventQueue.Pop;
      while eData <> nil do
      begin
        if (eData^.Data <> nil) then
          FreeMemEx(eData.Data);

        if (eData^.SValue <> nil) then
          FreeMemEx(eData^.SValue);

        FreeMemEx(eData);
        eData := FEventQueue.Pop;
      end;
    finally
      FEventQueue.UnLockQueue;
    end;
  end;
end;

procedure TQuoteService.FreeSendData;
var
  pData: PSendData;
begin
  if FSendQueue <> nil then
  begin
    // �ͷ��ڴ�
    FSendQueue.LockQueue;
    try
      pData := FSendQueue.Pop;
      while pData <> nil do
      begin
        if (pData.Data <> nil) then
          FreeMemEx(pData.Data);

        if (pData.Head <> nil) then
          FreeMemEx(pData.Head);

        if (pData.Tail <> nil) then
          FreeMemEx(pData.Tail);
        FreeMemEx(pData);

        pData := FSendQueue.Pop;
      end;
    finally
      FSendQueue.UnLockQueue;
    end;
  end;
end;

function TQuoteService.GetEventData: PEventData;
begin
  Result := FEventQueue.Pop;
end;

function TQuoteService.GetSendData: PSendData;
begin
  Result := FSendQueue.Pop;
end;

procedure TQuoteService.SendData(const Index: Integer; Data: PAnsiChar; DataLen: Cardinal; Flag: Integer);
var
  pData: PSendData;
begin
  GetMemEx(Pointer(pData), SizeOf(TSendData));
  FillMemory(Pointer(pData), SizeOf(TSendData), 0);
  pData.Index := index;
  pData.Data := Data;
  pData.DataLen := DataLen;
  pData.Flag := Flag;

  FSendQueue.AddItem(pData, 0);
  FSendQueue.ReleaseSemaphore(1, nil);
end;

procedure TQuoteService.SendData(const Index: Integer; const Head, Data, Tail: Pointer;
  const HeadLen, DataLen, TailLen: Cardinal; Flag: Integer);
var
  pData: PSendData;
begin
  GetMemEx(Pointer(pData), SizeOf(TSendData));
  pData.Index := index;
  pData.Data := Data;
  pData.DataLen := DataLen;
  pData.Head := Head;
  pData.HeadLen := HeadLen;
  pData.Tail := Tail;
  pData.TailLen := TailLen;

  pData.Flag := Flag;

  FSendQueue.AddItem(pData, 0);
  FSendQueue.ReleaseSemaphore(1, nil);
end;

procedure TQuoteService.SendEvent(const EventType: TEventType; const Data: Pointer; const SValue: AnsiString;
  const DataLen: Cardinal; Flag: Integer);
var
  eData: PEventData;
begin
  // WriteLogx('TQuoteService.SendEvent :' + SValue);
  GetMemEx(Pointer(eData), SizeOf(TEventData));
  FillMemory(Pointer(eData), SizeOf(TEventData), 0);
  eData^.EventType := EventType;
  eData^.Data := Data;

  eData^.SValueLen := length(SValue) + 1;
  GetMemEx(Pointer(eData^.SValue), eData^.SValueLen);
  System.Move(PAnsiChar(SValue)^, eData^.SValue^, length(SValue));

  eData^.DataLen := DataLen;
  eData^.Flag := Flag;

  FEventQueue.AddItem(eData, 0);
  PostMessage(FHandle, WM_HandleEvent, 0, 0);
end;

function TQuoteService.CheckServerType(ServerType: ServerTypeEnum): Boolean;
begin
  Result := (ServerType >= stStockLevelI) and (ServerType <= stDDE);
end;

procedure TQuoteService.SendKeepActiveCount(ServerType: ServerTypeEnum);
begin
  if Active and CheckServerType(ServerType) and Connected(ServerType) then
  begin
    Inc(FServerStatus[ServerType].KeepActiveCount);
    DoKeepActive(ServerType);
  end;
end;

// procedure TQuoteService.SendKeepActiveTime(ServerType: ServerTypeEnum);
// begin
// if Active and CheckServerType(ServerType) and Connected(ServerType)  then begin
// FServerStatus[ServerType].KeepRecvTime := 0;
// DoKeepActive(ServerType);
// end;
// end;

function TQuoteService.ServerSetting(IP: string; Port: Word; SType: ServerTypeEnum): Boolean;
begin
  if not FActive then
  begin
    SetLength(FServerInfos, length(FServerInfos) + 1);
    with FServerInfos[High(FServerInfos)] do
    begin
      ServerIP := AnsiString(IP);
      ServerPort := Port;
      ServerType := SType;
    end;

    Result := True;
  end
  else
    Result := false;
end;

function TQuoteService.ClearSetting: Boolean;
begin
  if not FActive then
  begin
    FConcurrent := 1;
    SetLength(FServerInfos, 0);
    Result := True;
  end
  else
    Result := false;
end;

procedure TQuoteService.Progress(const Msg: string; Max, Value: Integer);
// var
// eData: PEventData;
begin
  if FActive then
  begin
    { if  (Value mod 100 = 0) or (Value = 0) or (Max = Value) then begin
      GetMemEx(Pointer(eData), SizeOf(TEventData));
      FillMemory(eData, SizeOf(TEventData), 0);

      eData^.EventType := etProgress;
      eData^.SValue := Msg;

      eData^.Flag := Max;
      eData^.DataLen := Value;

      FEventQueue.AddItem(eData, 0);
      PostMessage(FHandle, WM_HandleEvent, 0, 0);
      end; }
  end;
end;

function TQuoteService.Proxy1Setting(Kind: TProxyKind; proxyIP: string; proxyPort: Word;
  proxyUser, proxyPWD: string): Boolean;
begin
  if not FActive then
  begin
    FTcpClient.ProxyKind := Kind;
    FTcpClient.proxyIP := AnsiString(proxyIP);
    FTcpClient.proxyPort := proxyPort;
    FTcpClient.proxyUser := AnsiString(proxyUser);
    FTcpClient.proxyPWD := AnsiString(proxyPWD);

    Result := True;
  end
  else
    Result := false;
end;

function TQuoteService.Proxy2Setting(Kind: TProxyKind; proxyIP: string; proxyPort: Word;
  proxyUser, proxyPWD: string): Boolean;
begin
  if not FActive then
  begin
    FTcpClient.ProxyKind2 := Kind;
    FTcpClient.ProxyIP2 := AnsiString(proxyIP);
    FTcpClient.ProxyPort2 := proxyPort;
    FTcpClient.ProxyUser2 := AnsiString(proxyUser);
    FTcpClient.ProxyPwd2 := AnsiString(proxyPWD);

    Result := True;
  end
  else
    Result := false;
end;

{ TMonitorThread }

constructor TMonitorThread.Create(Service: TQuoteService);
begin
  FService := Service;
  FTcpClient := FService.FTcpClient;
  FreeOnTerminate := True;
  inherited Create(false);
  // WriteLogx('TMonitorThread in');
end;

procedure TMonitorThread.Execute;
var
  dRes, err, i: Cardinal;
  Index: byte;
  pData: PSendData;
  ServerType: ServerTypeEnum;
begin
  // WriteLogx('TMonitorThread.Execute');
  FService.WriteDebug('TMonitorThread Started:' + IntToStr(Handle));
  while not Terminated do
  begin

    dRes := WaitForSingleObject(FService.FSendQueue.QueueSemaphore, 1000);
    case dRes of
      WAIT_OBJECT_0:
        begin // ���͵���
          // ȥ��������
          if not Terminated then
          begin

            pData := FService.GetSendData;
            if pData <> nil then
              try
                // ʵ����������   �������� Index = -9
                if (pData.Index = C_CONNECT_INDEX) then
                begin
                  if not FService.Connected(FService.FServerInfos[pData.Flag].ServerType) then
                  begin
                    err := FTcpClient.ConnectTo(FService.FServerInfos[pData.Flag].ServerIP,
                      FService.FServerInfos[pData.Flag].ServerPort, index, pData.Flag);

                    if err <> CONST_SUCCESS_NO then
                    begin
                      FService.FServerInfos[pData.Flag].Index := -1; // �´�����
                      // ����������һ��������
                      FService.WriteDebug('���ӷ�����ʧ��:$' + IntToHex(err, 4));
                      FService.ConnectServer(FService.FServerInfos[pData.Flag].ServerType, 1);
                    end
                    else
                    begin
                      FService.FServerInfos[pData.Flag].Index := Index;
                      // FService.WriteDebug('���ӷ�����ʧ��:$' + IntToHex(err, 4));
                      // FService.SendEvent(etConnectingError, nil, '', 0, 0);
                    end;
                  end;

                end
                else if FService.FTCPContext[pData^.Index].Connected = csConnected then
                begin // ������� �ŷ�����
                  if (pData.Head <> nil) and (pData.Tail <> nil) then
                    err := FTcpClient.SendData(pData.Index, pData.Head, pData.Data, pData.Tail, pData.HeadLen,
                      pData.DataLen, pData.TailLen)
                  else if (pData.Head <> nil) then
                    err := FTcpClient.SendData(pData.Index, pData.Head, pData.Data, pData.HeadLen, pData.DataLen)
                  else
                    err := FTcpClient.SendData(pData.Index, pData.Data, pData.DataLen);
                  if err <> CONST_SUCCESS_NO then
                  begin
                    FService.WriteDebug('��������ʧ��:$' + IntToHex(err, 4) + '/' + GetErrorMsg(err, false));
                  end;
                end;

              finally
                if (pData.Data <> nil) then
                  FreeMemEx(pData.Data);

                if (pData.Head <> nil) then
                  FreeMemEx(pData.Head);

                if (pData.Tail <> nil) then
                  FreeMemEx(pData.Tail);

                FreeMemEx(pData);
              end;
          end;
        end;
      WAIT_TIMEOUT:
        begin
          // FService.WriteDebug('TMonitorThread WAIT_TIMEOUT ���������');
          for i := low(FService.FTCPContext) to High(FService.FTCPContext) do
          begin
            if FService.FTCPContext[i].Connected = csConnected then
            begin
              ServerType := FService.FTCPContext[i].ServerType;
              FService.IncKeepCount(ServerType, 1);

              // ��������û�з���
              if FService.KeepActiveRecvCount(ServerType) >= 3 then
              begin
                // OutputDebugString('KeepActiveRecvCount >= 3');
                FService.FTCPContext[i].Connected := csFree;
                FService.SendEvent(etDisconnected, nil, '', 0, ServerType)
              end
              else
              begin
                if FService.KeepCount(ServerType) >= 60 then
                begin
                  FService.SendKeepActiveCount(ServerType);
                  // KeepCount ��λ
                  FService.IncKeepCount(ServerType, 0);
                end;
              end;
            end;
          end;

          { for i := low(FService.FTCPContext) to High(FService.FTCPContext) do begin
            if FService.FTCPContext[i].Connected = csConnected then begin
            inc(FService.FTCPContext[i].KeepCount);

            if FService.FTCPContext[i].KeepCount >= 60 then begin
            FService.DoKeepActive(i);
            FService.WriteDebug(inttostr(i) + '��������...');
            FService.FTCPContext[i].KeepCount := 0;
            end;
            end;
            end; }
        end;
    end;
  end;
  FService.WriteDebug('TMonitorThread Stoped: ' + IntToStr(Handle));
  // WriteLogx('TMonitorThread.Stoped');
end;

{ TQuoteDispatcher }
constructor TQuoteDispatcher.Create(Service: TQuoteService);
begin
  FService := Service;
  FRecvQueue := TFIFOQueue.Create(255, True);
end;

destructor TQuoteDispatcher.Destroy;
begin
  StopService;

  if FRecvQueue <> nil then
  begin
    FreeRecvData;
    FRecvQueue.Free;
    FRecvQueue := nil;
  end;
  inherited Destroy;
end;

procedure TQuoteDispatcher.FreeRecvData;
var
  pData: PRecvData;
begin
  if FRecvQueue <> nil then
  begin
    // �ͷ��ڴ�
    FRecvQueue.LockQueue;
    try
      pData := FRecvQueue.Pop;
      while pData <> nil do
      begin
        if (pData.Data <> nil) then
          FreeMemEx(pData.Data);
        FreeMemEx(pData);

        pData := FRecvQueue.Pop;
      end;
    finally
      FRecvQueue.UnLockQueue;
    end;
  end;
end;

procedure TQuoteDispatcher.AddRecData(pData: PRecvData);
begin
  FRecvQueue.AddItem(pData, 0);
  FRecvQueue.ReleaseSemaphore(1, nil);
end;

function TQuoteDispatcher.GetRecvData: PRecvData;
begin
  Result := FRecvQueue.Pop;
end;

function TQuoteDispatcher.StartService: Boolean;
begin
  // ���������������̣߳�ҲҪ������������д�߳�
  if not FActive then
  begin
    FActive := True;
    FThread := TDispatcherThread.Create(Self);
  end;
  Result := True;
end;

procedure TQuoteDispatcher.StopService;
begin
  if FActive then
  begin
    // ֹͣ�߳�
    if FThread <> nil then
    begin
      FThread.Terminate;
      if FRecvQueue <> nil then
        FRecvQueue.ReleaseSemaphore(1, nil);
      FThread := nil;
    end;
    // �ͷ��ڴ�
    FreeRecvData;

    FActive := false;
  end;
end;

{ TDispatcherThread }

constructor TDispatcherThread.Create(Dispatcher: TQuoteDispatcher);
begin
  FDispatcher := Dispatcher;
  FService := Dispatcher.FService;
  FreeOnTerminate := True;
  inherited Create(false);
end;

procedure TDispatcherThread.Execute;
var
  dRes: Integer;
  pData: PRecvData;
begin
  FService.WriteDebug('TDispatcherThread Started:' + IntToStr(Handle));
  while not Terminated do
    try
      dRes := WaitForSingleObject(FDispatcher.FRecvQueue.QueueSemaphore, INFINITE);
      case dRes of
        WAIT_OBJECT_0:
          begin
            if not Terminated then
            begin
              pData := FDispatcher.GetRecvData;
              if pData <> nil then
              begin
                // ����pData��Data��TransPkg�ﶨ��ı���
                HandleOnePkg(pData);
              end;
            end;
          end;
      else
        begin
          // ����ֵ��������
        end;
      end;
    except
      on E: Exception do
      begin

        FService.WriteDebug('TDispatcherThread : ' + IntToStr(Handle) + 'Error' + E.Message);
      end;
    end;
  FService.WriteDebug('TDispatcherThread Stoped :' + IntToStr(Handle));
end;

procedure TDispatcherThread.HandleOnePkg(pData: PRecvData);
var
  pHead: PDataHead;
  TransZipData: PTransZipData;
  zData: Pointer;
  zSize: Integer;
begin
  try
    pHead := PDataHead(@pData.Data[0]);
    // ��ʱ����2�౨��
    case pHead^.m_nType of
      RT_ZIPDATA:
        begin
          TransZipData := PTransZipData(pHead);
          zData := nil;
          zSize := 0;
          // FService.WriteDebug(Format('Recv: %d Zip %d/%d', [pData.DataLen, TransZipData.m_lZipLen, TransZipData.m_lOrigLen]));

          ZDecompress(Pointer(@TransZipData.m_cData[0]), TransZipData.m_lZipLen, zData, zSize);
          try
            if TransZipData.m_lOrigLen = zSize then
            begin
              FService.DoHandleBusiness(zData, zSize);
            end;
          finally
            if zData <> nil then
              FreeMem(zData);
          end;
        end;
    else
      begin
        // FService.WriteDebug('Recv:'  + inttostr(pData.DataLen));
        FService.DoHandleBusiness(pHead, pData.DataLen);
      end;
    end;
  finally
    if (pData <> nil) and (pData.Data <> nil) then
      FreeMemEx(pData.Data);

    if pData <> nil then
      FreeMemEx(pData);
  end;
end;

end.
