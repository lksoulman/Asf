{ ����Ԫ����һ�������TCP�࣬��֧�ּ�����֧�����ӣ�������ͬʱά��63������
  ���Ҫ���������ֻ֧��62�����ӣ����Ҫ֧�ָ������ӣ�����ʹ�ö��ʵ������
  �˴˻������ţ����ź����ǣ�û�п��ǵ���һ���������ѽ��ܵ������ӷ����������������

  ��������Ӧ��ʹ�÷������Լ����̣߳���Ҫ���¼��ص�����÷��ͣ���Ϊֻ��һ��
  �߳����������е����飬����������ͣ����Ʊ�Ӱ��������¼�����ѯ�����ݽ���

  ����������󣬾Ͳ�Ҫʹ�����̷߳��ͣ���Ϊ������ͬ���ģ���Ӱ��Ӧ�ó������Ϣѭ��

  ����ʹ��win98-win2003ͨ��API������ʹ����win98��������΢��ƽ̨
}

unit IOCPClient;

interface

uses Windows, Classes, NetEncoding, SysUtils, WinSock2, EncdDecd, IOCPUtil, IOCPLibrary, IOCPMemory,
  Ansistrings;

type

  // ��ͷ
  PPkgHead = ^TPkgHead;

  TPkgHead = packed record
    Sign: array [0 .. 3] of AnsiChar;
    DataLen: Cardinal; // ��ǰ�����ݳ���
  end;

  TClientStatus = (csFree, // ���У������������ӣ�Ҳ����������������
    csAccept, // ֻ�м����׽��ֲŻᴦ�����״̬
    csConnecting, // �������ӻ������ڽ�������
    csConnected, // ������
    csDisconnecting); // �Ͽ�״̬

  TClientOperType = (otProxy1, // ��������Э�̵�1��
    otProxy2, // ���մ���Э�̵�1����Ӧ�����͵�2��
    otProxy3, // ���մ���Э�̵�2����Ӧ�����͵�3��
    otRecvHead, // ����ͷ
    otRecvBody, // ������
    otRecvFile, // �����ļ���
    otRecvData); // ��������

  // ��������
  PProxyKind = ^TProxyKind;
  TProxyKind = (pkNoProxy = 1, pkHTTPProxy = 2, pkSOCKS5Proxy = 3, pkSOCKS4Proxy = 4);

  PClientContext = ^TClientContext;

  TClientContext = packed record
    Sock: TSocket; // �׽���
    TotalLen: Cardinal; // ���ֽ���
    FinishLen: Cardinal; // ����ֽ���
    Overlap: TOverlapped; // �ص��ṹ   ��������
    Index: byte; // ����
    Status: TClientStatus; // ʹ��״̬
    OperType: TClientOperType; // ����״̬,�������ƽ��ղ���
    UseProxy: boolean; // �Ƿ�ʹ��Proxy
    UsePkgHead: boolean; // �Ƿ�ʹ���Զ���Э��
    Reserve: byte; // ����
    SendRTL: TRTLCriticalSection;
    FileHandle: THandle; // �����ļ����
    Offset: Cardinal; // �����ļ�ƫ��
    Timeout: integer; // ��ʱֵ,Ϊ-1��ʾ�����Ƴ�ʱ,������ʼ��ʱ,�ɳ�ʱ�߳�
    // ÿ2�������ۼ�,�����ȴ�ʱ���򼤻ͬ�¼�,Ȼ��֪ͨ
    // ��ѯ�߳�����������
    MaxTimeout: integer; // ��ʱֵ
    NetEvent: THandle; // �����¼�
    RecvTime: Double; // ʹ���Զ���Э��ʱ�Ľ��ռ�ʱ

    ProxyDestIP: Cardinal; // ����IP������ʹ�������û�еĻ���������
    ProxyDestPort: Word;

    ProxyKind: PProxyKind;
    ProxyUser: PAnsiString; // �����û�
    ProxyPwd: PAnsiString; // �������
    ProxyLevel: Word;

    DestIP: Cardinal; // ������IP    ����ǽ��ܵ����ӣ���ô�ǶԷ�IP
    DestName: PAnsiChar; // ����������  �������Connect���ṩ���֣��������¼���֣�����Ϊnil
    DestPort: Word; // Ŀ��˿�
    OuterFlag: integer; // �ⲿ��־
    ConnTime: Double; // ���ӳɹ�ʱ��
    Data: PAnsiChar; // �����յ�������
    PkgHead: TPkgHead; // �Զ����TCPͷ
    Buf: PAnsiChar; // ָ��CONST_BUFFER_LEN���ȵ�ָ��
  end;

  TTcpClient = class;

  // �¼��ص�����
  // �������
  // �������
  TOnConnectOver = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte; // ����
    const ErrCode: integer) of object; // ������

  // ���ܵ�����
  TOnAcceptConnect = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte; // ����
    const IP: Cardinal; // �Է�IP
    const Port: Word) of object; // �Է��˿�

  // ���յ�����
  TOnRecvDataOver = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte; // ����
    const ErrCode: integer; // ������
    const Data: PAnsiChar; // ����ָ��
    const DataLen: Cardinal; // ���ݳ���
    const UseTime: Double) of object; // ���ν�����ʱ

  // ���ӱ��Ͽ��¼�  �Լ������Ͽ�û��֪ͨ
  TOnDisconnected = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte) of object; // ����

  // �ļ������¼�����������ʹ���Զ���Э��
  TOnRecvFileQuery = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte; // ����
    const FileSize: Cardinal; // ������ļ���С
    var SaveName: Ansistring; // �����ļ�������ղ����ղ��Ͽ�
    var Offset: Cardinal) of object; // ����ƫ�ƣ���������д�Ѵ����ļ�

  // �ļ���������¼�����������ʹ���Զ���Э��
  TOnRecvFileOver = procedure(Sender: TTcpClient; // �����¼��Ķ���
    const Index: byte; // ����
    const ErrCode: integer; // ������
    const SaveName: Ansistring; // �����¼�����ļ���
    const FileSize: Cardinal; // �ļ���С
    const FinishLen: Cardinal; // ����ֽ���
    const Offset: Cardinal; // �����¼���д��ƫ��
    const UseTime: Double) of object; // ���ν�����ʱ

  TOnWriteDebug = procedure(Sender: TTcpClient; const DebugStr: string) of object;

  TRecvThread = class(TThread)
  private
    FWaitArray: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle; // �����¼��������
    FWaitIndex: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of byte; // ��¼��ǰ��ѯ������
    FWaitCount: integer;
    FTcpClient: TTcpClient;
    FRecvEvent: THandle;

    procedure SetNoNagle(Sock: THandle);
    procedure StartNegociateWithProxy(pClient: PClientContext);
    procedure StartRecvFile(pClient: PClientContext; SaveName: Ansistring; Offset: Cardinal); // ȥ���ļ���׼�������ļ�

    function SendProxyData(pClient: PClientContext; const Buf: WSABUF): integer;

    procedure SendProxy2(pClient: PClientContext);
    procedure SendProxy3(pClient: PClientContext);

    procedure OnlyDisconnect(pClient: PClientContext);
    procedure DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
      const DataLen: Cardinal; const UseTime: Double);
    procedure DoConnectOver(const ErrCode: integer; pClient: PClientContext);

  protected

    procedure ReBuildWaitArray;
    procedure HandleOneEvent(const Index: byte);
    procedure CallAccept(pClient: PClientContext); // ����������

    procedure HandleConnOver(pClient: PClientContext);

    procedure HandleRecvHead(pClient: PClientContext); // ����ͷ
    procedure HandleRecvBody(pClient: PClientContext); // ������
    procedure HandleFileArrive(pClient: PClientContext); // �����ļ�����
    procedure HandleRecvFile(pClient: PClientContext); // �����ļ���

    procedure HandleRecvData(pClient: PClientContext); // �յ�������

    procedure RecvProxyRes1(pClient: PClientContext); // ���մ���Э�̵�1����Ӧ�����͵�2��
    procedure RecvProxyRes2(pClient: PClientContext); // ���մ���Э�̵�2����Ӧ�����͵�3��
    procedure RecvProxyRes3(pClient: PClientContext); // ���մ���Э�̵�3����Ӧ

    procedure Execute; override;
  public
    constructor Create(TcpIoClient: TTcpClient);
  end;

  TTimeOutThread = class(TThread)
  private
    FTcpClient: TTcpClient;
  protected
    procedure Execute; override;
  public
    constructor Create(TcpClient: TTcpClient);
  end;

  TTcpClient = class
  private
    FActive: boolean;
    FNeedListen: boolean;
    FRTLClient: TRTLCriticalSection;
    FClientArray: array [1 .. MAXIMUM_WAIT_OBJECTS - 1] of TClientContext;

    FExitSema: THandle;
    FTimeoutEvent: THandle;

    FRecvThread: TRecvThread;
    FTimeOutThread: TTimeOutThread;

    FListenPort: Word; // ���ؼ����˿�
    FListenIP: Cardinal; // ���ذ�IP

    FProxyKind: TProxyKind;
    FProxyIP: Ansistring; // ����IP������ʹ�������û�еĻ���������
    FProxyPort: Word; // ��������˿�
    FProxyUser: Ansistring; // �����û�
    FProxyPwd: Ansistring; // �������

    FProxyKind2: TProxyKind;
    FProxyIP2: Ansistring; // ����IP������ʹ�������û�еĻ���������
    FProxyPort2: Word; // ��������˿�
    FProxyUser2: Ansistring; // �����û�
    FProxyPwd2: Ansistring; // �������

    FUsePkgHead: boolean; // �����Ƿ�ʹ�ð�ͷ

    FInitWinSock: boolean;

    FOnAcceptConnect: TOnAcceptConnect;
    FOnConnectOver: TOnConnectOver;
    FOnRecvDataOver: TOnRecvDataOver;
    FOnDisconnected: TOnDisconnected;
    FOnRecvFileQuery: TOnRecvFileQuery;
    FOnRecvFileOver: TOnRecvFileOver;
    FOnWriteDebug: TOnWriteDebug;
    function GetFlags(const Index: integer): integer;
  protected
    function InitContext: integer;
    function UnInitContext: integer; // ��ʼ��������

    function CreateListenSock: integer; // ���������׽���
    function GetFreeContext: PClientContext;
    procedure ReturnContext(pClient: PClientContext);

    function GetProxyIPByProxyName(const ProxyIP: Ansistring): Cardinal;
    procedure DoConnectOver(const ErrCode: integer; pClient: PClientContext);
    procedure DoDisconnected(pClient: PClientContext);
    procedure DoRecvFileOver(const ErrCode: integer; pClient: PClientContext; const SaveName: Ansistring;
      const FileSize: Cardinal; const FinishLen: Cardinal; const Offset: Cardinal; const UseTime: Double);

    procedure DoRecvFileQuery(pClient: PClientContext; var SaveName: Ansistring; var Offset: Cardinal);
    procedure DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
      const DataLen: Cardinal; const UseTime: Double);
    procedure DoAcceptConnect(pClient: PClientContext; IP: Cardinal; const Port: Word);

    function CheckValid(const Index: byte): integer;
    function CheckValidFlag(const Index: byte): integer;
    function SendFinalData(pClient: PClientContext; Buf: PWSABUF; BufCount: Cardinal; NeedLen: Cardinal): integer;

    function EncodePkgHead(var PkgHead: TPkgHead; DataLen, PkgKind: Cardinal): integer;
    function DecodePkgHead(var PkgHead: TPkgHead): integer;

  public
    constructor Create;
    destructor Destroy; override;

    function StartServer: integer;
    function StopServer: integer;

    // ���ӵ��Է����ṩ2�����ط���  ����PassProxy������ʾ����ʱ�����ǰ������
    // �����Ƿ�ʹ�ô������Ϊfalse����ʾ��ͨ��������Ǽ�ֱ������
    // ֮������ô������Ϊ�˷���������ڲ��Լ�����
    function ConnectTo(const DestName: Ansistring; // Ŀ���������������
      const DestPort: Word; // Ŀ��˿�
      var Index: byte; // ���ص�������
      const Flag: integer = 0; // ��־
      const OwnProto: boolean = true; const PassProxy: boolean = true): integer; overload;

    function ConnectTo(const DestIP: Cardinal; // Ŀ��IP
      const DestPort: Word; // Ŀ��˿�
      var Index: byte; // ����������
      const Flag: integer = 0; // ��־
      const OwnProto: boolean = true; const PassProxy: boolean = true): integer; overload;

    // ר�ñ������ӵķ���
    function KeepConnection(const Index: byte): integer;

    // �������� �ṩ3�����ط���
    // �����Ϊ0����ʾ����ʧ�ܣ����������½��
    // $2006����ʾ�ϴη�������û����ɣ��Ժ��������
    // $9998 ��ʾ����δ����
    // $3009 ��ʾ��������
    // $1007 ��ʾ��ǰ����û������
    // $6002 ��ʾͨ�����緢��ʧ�ܣ����ӽ����Զ��Ͽ�
    // $6007 ��ʾ�޷���ط�����ɣ�������ϵͳ��Դ���㣬��ǰ����Ҳû�г������⣬�Ժ��������
    // ��������
    function SendData(const Index: byte; // ����
      const Data: Pointer; // ����
      const DataLen: Cardinal): integer; overload; // ���ݳ���

    function SendData(const Index: byte; // ����
      const Head, Data: Pointer; // ����ͷ+����ָ��
      const HeadLen, DataLen: Cardinal): integer; overload; // ����ͷ+���ݳ���

    // ����ķ���֧��"ͷ+������+β"��������
    function SendData(const Index: byte; const Head, Data, Tail: Pointer; const HeadLen, DataLen, TailLen: Cardinal)
      : integer; overload;

    // �����ļ� ֧��ʹ��һ���Զ����ͷ����Head��Ϊnil��HeadLen>0����£���֧�ֶϵ㷢��
    // ��֧�ֳ���2G�ļ��ķ���
    function SendFile(const Index: byte; const FileName: Ansistring; // ȫ·���ļ���
      var FileSize: Cardinal; // �ļ���С
      const Offset: Cardinal = 0; // ƫ��
      const Head: Pointer = nil; // �ļ�ͷ
      const HeadLen: Cardinal = 0 // ͷ����
      ): integer;

    // �Ͽ�����
    function DisconnectFrom(const Index: byte): integer;

    // ������ʱ����
    function StartTimeout(const Index: byte; NewTimeOut: Cardinal): integer; // �µĳ�ʱֵ
    function StopTimeout(const Index: byte): integer; // ����

    procedure WriteDebug(const DebugMsg: string);

    property Active: boolean read FActive;
    property ListenPort: Word read FListenPort write FListenPort;
    property NeedListen: boolean read FNeedListen write FNeedListen;

    property ProxyKind: TProxyKind read FProxyKind write FProxyKind;
    property ProxyIP: Ansistring read FProxyIP write FProxyIP; // ����IP������ʹ�������û�еĻ���������
    property ProxyPort: Word read FProxyPort write FProxyPort; // ��������˿�

    property ProxyUser: Ansistring read FProxyUser write FProxyUser; // �����û�
    property ProxyPwd: Ansistring read FProxyPwd write FProxyPwd; // �������

    property ProxyKind2: TProxyKind read FProxyKind2 write FProxyKind2;
    property ProxyIP2: Ansistring read FProxyIP2 write FProxyIP2; // ����IP������ʹ�������û�еĻ���������
    property ProxyPort2: Word read FProxyPort2 write FProxyPort2; // ��������˿�

    property ProxyUser2: Ansistring read FProxyUser2 write FProxyUser2; // �����û�
    property ProxyPwd2: Ansistring read FProxyPwd2 write FProxyPwd2; // �������

    property OnAcceptConnect: TOnAcceptConnect read FOnAcceptConnect write FOnAcceptConnect;
    property OnConnectOver: TOnConnectOver read FOnConnectOver write FOnConnectOver;
    property OnRecvDataOver: TOnRecvDataOver read FOnRecvDataOver write FOnRecvDataOver;
    property OnDisconnected: TOnDisconnected read FOnDisconnected write FOnDisconnected;
    property OnRecvFileQuery: TOnRecvFileQuery read FOnRecvFileQuery write FOnRecvFileQuery;
    property OnRecvFileOver: TOnRecvFileOver read FOnRecvFileOver write FOnRecvFileOver;
    property OnWriteDebug: TOnWriteDebug read FOnWriteDebug write FOnWriteDebug;

    property Flags[const index: integer]: integer read GetFlags;
  end;

implementation

{ TIOCPClient }

constructor TTcpClient.Create;
begin
  FExitSema := INVALID_HANDLE_VALUE;
  FTimeoutEvent := INVALID_HANDLE_VALUE;
  FInitWinSock := WinSock2Startup;
  FListenPort := 5151;
  FNeedListen := false;
  FUsePkgHead := true;

  FProxyKind := pkNoProxy;
  FProxyIP := ''; // ����IP������ʹ�������û�еĻ���������
  FProxyPort := 0; // ��������˿�

  FProxyUser := ''; // �����û�
  FProxyPwd := ''; // �������

  FProxyKind2 := pkNoProxy;
  FProxyIP2 := ''; // ����IP������ʹ�������û�еĻ���������
  FProxyPort2 := 0; // ��������˿�

  FProxyUser2 := ''; // �����û�
  FProxyPwd2 := ''; // �������

  InitializeCriticalSection(FRTLClient);
end;

destructor TTcpClient.Destroy;
begin
  StopServer;
  WinSock2Cleanup(FInitWinSock);

  DeleteCriticalSection(FRTLClient);

  inherited Destroy;
end;

function TTcpClient.DisconnectFrom(const Index: byte): integer;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin
    FClientArray[Index].Status := csDisconnecting;
    ReleaseSemaphore(FExitSema, 1, nil); // ֪ͨ�̸߳ı���ѯ
  end;
end;

procedure TTcpClient.DoAcceptConnect(pClient: PClientContext; IP: Cardinal; const Port: Word);
begin
  if assigned(FOnAcceptConnect) then
    try
      FOnAcceptConnect(self, pClient^.Index, IP, Port);
    except
    end;
end;

procedure TTcpClient.DoConnectOver(const ErrCode: integer; pClient: PClientContext);
begin
  if assigned(FOnConnectOver) then
    try
      FOnConnectOver(self, pClient^.Index, ErrCode);
    except
    end;
end;

procedure TTcpClient.DoDisconnected(pClient: PClientContext);
begin
  if assigned(FOnDisconnected) then
    try
      FOnDisconnected(self, pClient^.Index);
    except
    end;
end;

procedure TTcpClient.DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
  const DataLen: Cardinal; const UseTime: Double);
begin
  if assigned(FOnRecvDataOver) then
    try
      FOnRecvDataOver(self, pClient^.Index, ErrCode, Data, DataLen, UseTime);
    except
    end;
end;

procedure TTcpClient.DoRecvFileOver(const ErrCode: integer; pClient: PClientContext; const SaveName: Ansistring;
  const FileSize: Cardinal; const FinishLen: Cardinal; const Offset: Cardinal; const UseTime: Double);
begin
  if assigned(FOnRecvFileOver) then
    try
      FOnRecvFileOver(self, pClient^.Index, ErrCode, SaveName, FileSize, FinishLen, Offset, UseTime);
    except
    end;
end;

procedure TTcpClient.DoRecvFileQuery(pClient: PClientContext; var SaveName: Ansistring; var Offset: Cardinal);
begin
  if assigned(FOnRecvFileQuery) then
    try
      FOnRecvFileQuery(self, pClient^.Index, pClient^.TotalLen, SaveName, Offset);
    except
    end;
end;

function TTcpClient.EncodePkgHead(var PkgHead: TPkgHead; DataLen, PkgKind: Cardinal): integer;
begin

  // Copy(PkgHead.Sign, AnsiString('2003'), 4);
  // PkgHead.Sign[0] := '2';
  // PkgHead.Sign[1] := '0';
  // PkgHead.Sign[2] := '0';
  // PkgHead.Sign[3] := '3';
  Move(Ansistring('2003'), PkgHead.Sign[0], 4);

  PkgHead.DataLen := DataLen;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.DecodePkgHead(var PkgHead: TPkgHead): integer;
begin
  if CompareMem(PAnsiChar('2003'), @PkgHead.Sign[0], 4) then
    result := CONST_SUCCESS_NO
  else if CompareMem(PAnsiChar('003'), @PkgHead.Sign[0], 3) then
  begin
    Move(PkgHead.Sign[0], PkgHead.Sign[1], Sizeof(TPkgHead) - 1);
    result := CONST_SUCCESS_NO;
  end
  else
    result := CONST_ERROR_INVALID_PKG_FLAG;
end;

function TTcpClient.SendData(const Index: byte; const Data: Pointer; const DataLen: Cardinal): integer;
var
  SendBuf: array [0 .. 1] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin
    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 1;
      NeedLen := DataLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);

        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
        NeedLen := SendBuf[0].len + NeedLen;
        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := DataLen;
        SendBuf[0].Buf := Data;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;
end;

function TTcpClient.SendData(const Index: byte; const Head, Data: Pointer; const HeadLen, DataLen: Cardinal): integer;
var
  SendBuf: array [0 .. 2] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 2;
      NeedLen := HeadLen + DataLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;
        SendBuf[2].len := DataLen;
        SendBuf[2].Buf := Data;
        NeedLen := SendBuf[0].len + NeedLen;

        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;
        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;

end;

function TTcpClient.SendData(const Index: byte; const Head, Data, Tail: Pointer;
  const HeadLen, DataLen, TailLen: Cardinal): integer;
var
  SendBuf: array [0 .. 3] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 3;
      NeedLen := HeadLen + DataLen + TailLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;

        SendBuf[2].len := DataLen;
        SendBuf[2].Buf := Data;

        SendBuf[3].len := TailLen;
        SendBuf[3].Buf := Tail;
        NeedLen := SendBuf[0].len + NeedLen;

        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;
        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
        SendBuf[2].len := TailLen;
        SendBuf[2].Buf := Tail;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;
end;

function TTcpClient.SendFile(const Index: byte; const FileName: Ansistring; var FileSize: Cardinal;
  const Offset: Cardinal; const Head: Pointer; const HeadLen: Cardinal): integer;
var
  SendBuf: array [0 .. 3] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  MapHandle, FileHandle: THandle; // �ڴ�ӳ����������ļ����
  RealSize: Cardinal; // ��ʵ���ļ���С
  MemPtr: PAnsiChar; //
  PkgHead, pkgHead1: PPkgHead;
begin
  result := CheckValid(Index);
  if result <> CONST_SUCCESS_NO then
    exit;

  pClient := @FClientArray[Index];

  FileHandle := CreateFileA(PAnsiChar(FileName), GENERIC_READ, FILE_SHARE_READ, NiL, OPEN_EXISTING,
    FILE_FLAG_SEQUENTIAL_SCAN, 0);

  if FileHandle = INVALID_HANDLE_VALUE then
  begin
    result := CONST_ERROR_OPENFILE;
    exit;
  end;

  // ��ȡ�ļ���С
  RealSize := GetFileSize(FileHandle, nil);
  if RealSize = INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FileHandle);
    result := CONST_ERROR_GETFILESIZE;
    exit;
  end;

  if FileSize = 0 then
    FileSize := RealSize;

  if Offset >= RealSize then
  begin
    CloseHandle(FileHandle);
    result := CONST_ERROR_FILEOFFSET;
    exit;
  end;

  // ����ָ��ƫ��
  if FileSize + Offset > RealSize then
    FileSize := RealSize - Offset;

  try // �����ڴ�ӳ����
    MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, RealSize, nil);
    if MapHandle = 0 then
    begin
      result := CONST_ERROR_CREATEFILE;
      exit;
    end;
  finally
    CloseHandle(FileHandle);
  end;
  // ӳ��
  try
    MemPtr := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, Offset, FileSize);
    if MemPtr = nil then
    begin
      result := CONST_ERROR_CREATEFILE;
      exit;
    end;
  finally
    CloseHandle(MapHandle);
  end;

  // �������ڴ�ӳ��ȫ�����ˣ���ʼ����
  PkgHead := nil;
  pkgHead1 := nil;
  try
    if pClient.UsePkgHead then
    begin
      if (Head <> nil) and (HeadLen > 0) then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, HeadLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;

        GetMemEx(Pointer(pkgHead1), Sizeof(TPkgHead));
        SendBuf[2].len := Sizeof(TPkgHead);
        SendBuf[2].Buf := PAnsiChar(pkgHead1);
        EncodePkgHead(pkgHead1^, FileSize, CONST_PKGTYPE_FILE);

        SendBuf[3].len := FileSize;
        SendBuf[3].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len + SendBuf[2].len + SendBuf[3].len;
        BufCount := 4;
      end
      else
      begin

        GetMemEx(Pointer(pkgHead1), Sizeof(TPkgHead));

        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(pkgHead1);
        EncodePkgHead(pkgHead1^, FileSize, CONST_PKGTYPE_FILE);

        SendBuf[1].len := FileSize;
        SendBuf[1].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len;
        BufCount := 2;
      end;
    end
    else
    begin
      if (Head <> nil) and (HeadLen > 0) then
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;

        SendBuf[1].len := FileSize;
        SendBuf[1].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len;
        BufCount := 2;
      end
      else
      begin
        SendBuf[0].len := FileSize;
        SendBuf[0].Buf := MemPtr;

        NeedLen := SendBuf[0].len;
        BufCount := 1;
      end;
    end;
    result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
  finally
    UnmapViewOfFile(MemPtr); // ����Ҫ�ͷ��ڴ�ӳ��
    if PkgHead <> nil then
      FreeMemEx(PkgHead);
    if pkgHead1 <> nil then
      FreeMemEx(pkgHead1);
  end;
end;

function TTcpClient.SendFinalData(pClient: PClientContext; Buf: PWSABUF; BufCount, NeedLen: Cardinal): integer;
var
  tSendOverlap: TOverlapped;
  Flags, dRes: Cardinal;

  ErrCode: integer;
begin

  FillChar(tSendOverlap, Sizeof(TOverlapped), #0);
  tSendOverlap.hEvent := CreateEvent(nil, false, false, nil);
  if tSendOverlap.hEvent = INVALID_HANDLE_VALUE then
  begin
    result := CONST_ERROR_SEND_EVENT;
    exit;
  end;
  // {$IfDEF DEBUG}
  // outputdebugstring(PChar(format('SendFinalData�������ݳ���:%d %s',[NeedLen,formatdatetime('hh:mm:ss zzz',Now)])));
  // {$ENDIF}
  try
    // times:=GetTickCount;
    if WSASend(pClient.Sock, Buf, BufCount, dRes, 0, @tSendOverlap, nil) <> 0 then
    begin

      ErrCode := WSAGetLastError;
      if (ErrCode = ERROR_IO_PENDING) or (ErrCode = WSAEWOULDBLOCK) then
      begin
        // �ȴ�
        if not WSAGetOverlappedResult(pClient.Sock, @tSendOverlap, dRes, true, Flags) then
        begin // �ص�û�гɹ�
          outputdebugstring(PChar(Format('WSAGetOverlappedResult Error:%d.', [WSAGetLastError()])));
          result := CONST_ERROR_OTHER_OVERLAP_ERROR;
          WriteDebug(Format('WSAGetOverlappedResult Error:%d. [IP=%d  Port=%d]', [WSAGetLastError(), FListenIP, FListenPort]));
          DoDisconnected(pClient);
          pClient.Status := csDisconnecting;
          ReleaseSemaphore(FExitSema, 1, nil);
          exit;
        end;
      end
      else
      begin
        // ˵���Ѿ�����
        outputdebugstring(PChar(Format('WSASend Error:%d ', [ErrCode])));
        result := CONST_ERROR_OTHER_OVERLAP_ERROR;
        WriteDebug(Format('WSASend Error:%d  [IP=%d  Port=%d]', [ErrCode, FListenIP, FListenPort]));
        DoDisconnected(pClient);
        pClient.Status := csDisconnecting;
        ReleaseSemaphore(FExitSema, 1, nil);
        exit;
      end;

    end;
    // times:=GetTickCount-times;
    if dRes = NeedLen then
    begin
      result := CONST_SUCCESS_NO;
      // WriteDebug('SendFinalData Used time:'+inttostr(times));

    end
    else
    begin
      // {$IfDEF DEBUG}
      outputdebugstring(PChar(Format('���Ͳ����������ȣ�%d  �ѷ��ͳ���:%d', [NeedLen, dRes])));
      // {$ENDIF}
      result := CONST_ERROR_OTHER_OVERLAP_ERROR;
      pClient.Status := csDisconnecting;
      WriteDebug(Format('���Ͳ����������ȣ�%d  �ѷ��ͳ���:%d [IP=%d  Port=%d]', [NeedLen, dRes, FListenIP, FListenPort]));
      DoDisconnected(pClient);
      ReleaseSemaphore(FExitSema, 1, nil);
    end;
  finally
    CloseHandle(tSendOverlap.hEvent); // �رվ��
  end;
end;

function TTcpClient.StartServer: integer;
begin
  result := CONST_SUCCESS_NO;
  if not FActive then
    try
      // ��ʼ�� Context
      result := InitContext;
      if result <> CONST_SUCCESS_NO then
        exit;

      // ���� ����
      if FNeedListen then
      begin
        result := CreateListenSock;
        if result <> CONST_SUCCESS_NO then
          exit;
      end;

      // �����߳̿�ʼ��ѯ
      FRecvThread := TRecvThread.Create(self);
      FTimeOutThread := TTimeOutThread.Create(self);
      // FCMDThrd := TCMDSendThrd.create(self);

      FActive := true;

    finally
      if result <> CONST_SUCCESS_NO then
        StopServer;
    end;
end;

function TTcpClient.StopServer: integer;
begin
  FActive := false;
  // ֪ͨ�߳��˳�
  if FRecvThread <> nil then
  begin
    FRecvThread.Terminate;
    FRecvThread := nil;
  end;

  if FTimeOutThread <> nil then
  begin
    FTimeOutThread.Terminate;
    FTimeOutThread := nil;
  end;
  if FExitSema <> INVALID_HANDLE_VALUE then
    ReleaseSemaphore(FExitSema, 1, nil);

  if FTimeoutEvent <> INVALID_HANDLE_VALUE then
    SetEvent(FTimeoutEvent); // ֪ͨ��ʱ�߳��˳�

  UnInitContext;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.StartTimeout(const Index: byte; NewTimeOut: Cardinal): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < low(FClientArray)) or (index > high(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if (FClientArray[Index].Status <> csConnecting) and (FClientArray[Index].Status <> csConnected) then
  begin
    result := CONST_ERROR_FAIL_CTRL_TIMEOUT;
    exit;
  end;

  FClientArray[Index].MaxTimeout := NewTimeOut;
  FClientArray[Index].Timeout := 0;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.StopTimeout(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < low(FClientArray)) or (index > high(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if (FClientArray[Index].Status <> csConnecting) and (FClientArray[Index].Status <> csConnected) then
  begin
    result := CONST_ERROR_FAIL_CTRL_TIMEOUT;
    exit;
  end;

  FClientArray[Index].Timeout := -1;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.CreateListenSock: integer;
var
  pClient: PClientContext;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  lenn: integer;
begin
  pClient := @FClientArray[Low(FClientArray)];
  pClient^.Status := csAccept; // ��ñ�GetFreeContext�õ�
  FreeMemEx(pClient^.Buf);

  pClient^.Buf := nil; // ���ڽ�������ʱ���������û����
  pClient^.Data := nil;

  pClient^.Sock := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, WSA_FLAG_OVERLAPPED);
  if pClient^.Sock = INVALID_SOCKET then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  Addrin := @Addr;
  // �󶨵���������ip��ַ
  Addrin^.sin_family := AF_INET;
  if FListenPort = 0 then
    Addrin^.sin_port := htons(0)
  else
    Addrin^.sin_port := htons(FListenPort);
  Addrin^.sin_addr.S_addr := htonl(INADDR_ANY);

  if bind(pClient^.Sock, Addr, Sizeof(TSockAddrIn)) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  if listen(pClient^.Sock, 5) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  // ��ȡ�󶨵Ķ˿�
  lenn := Sizeof(TSockAddr);
  if getsockname(pClient^.Sock, Addr, lenn) <> 0 then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  FListenPort := htons(Addrin^.sin_port);
  FListenIP := Addrin^.sin_addr.S_addr;

  pClient^.NetEvent := CreateEvent(nil, false, false, nil);
  if pClient^.NetEvent = INVALID_HANDLE_VALUE then
  begin // �¼�����û�гɹ���Ҫ�˳�
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  // �¼�ѡ��û�гɹ�����ôacceptex���ò���Ͷ�ݣ����Ҫ�˳�
  if WSAEventSelect(pClient^.Sock, pClient^.NetEvent, FD_ACCEPT) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.UnInitContext: integer;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      ReturnContext(@FClientArray[i]);
      DeleteCriticalSection(FClientArray[i].SendRTL);
    end;

    if FExitSema <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FExitSema);
      FExitSema := INVALID_HANDLE_VALUE;
    end;

    if FTimeoutEvent <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FTimeoutEvent);
      FTimeoutEvent := INVALID_HANDLE_VALUE;
    end;

    result := CONST_SUCCESS_NO;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

procedure TTcpClient.WriteDebug(const DebugMsg: string);
begin
  if assigned(FOnWriteDebug) then
    FOnWriteDebug(self, '[TTcpClient] ' + DebugMsg);
end;

function TTcpClient.GetFlags(const Index: integer): integer;
begin
  result := 0;
  if CheckValidFlag(Index) = CONST_SUCCESS_NO then
  begin
    result := FClientArray[Index].OuterFlag;
  end;
end;

function TTcpClient.GetFreeContext: PClientContext;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    result := nil;
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      if FClientArray[i].Status = csFree then
      begin
        FClientArray[i].Timeout := -1;
        FClientArray[i].Status := csConnecting;
        FClientArray[i].MaxTimeout := 1000;

        GetMemEx(FClientArray[i].Buf, C_IOCP_BUFFER_SIZE); // ָ��CONST_BUFFER_LEN���ȵ�ָ��

        FClientArray[i].Data := FClientArray[i].Buf;
        result := @FClientArray[i];

        break;
      end;
    end;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.GetProxyIPByProxyName(const ProxyIP: Ansistring): Cardinal;
var
  IPs: TStringList;
begin
  result := INADDR_NONE;

  IPs := TStringList.Create;
  try
    if GetAllIPByName(ProxyIP, IPs) then
    begin
      if IPs.Count > 0 then
        result := StrToInt64(IPs[0]);
    end;
  finally
    IPs.Free;
  end;
end;

function TTcpClient.InitContext;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    FExitSema := CreateSemaphore(nil, 0, 2, nil);
    FTimeoutEvent := CreateEvent(nil, false, false, nil);

    ZeroMemory(@FClientArray[1], Sizeof(TClientContext) * (MAXIMUM_WAIT_OBJECTS - 1));
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      with FClientArray[i] do
      begin
        Sock := INVALID_SOCKET; // �׽���
        NetEvent := INVALID_HANDLE_VALUE; // �����¼�
        // DestIP := 0;           //������IP
        // DestName := nil;       //����������
        // DestPort := 0;         //Ŀ��˿�
        OuterFlag := 0; // �ⲿ��־
        Overlap.hEvent := INVALID_HANDLE_VALUE; // �ص��ṹ   ��������
        Index := i; // ����
        // Status:=;              //ʹ��״̬
        // OperType:=;            //����״̬,�������ƽ��ղ���
        // UseProxy:byte;         //�Ƿ�ʹ��Proxy
        // OwnProto:=true;        //�Ƿ�ʹ���Զ���Э��
        // Reserve:byte;          //����
        // PkgHead:TPkgHead1;     //�Զ����TCPͷ
        InitializeCriticalSection(SendRTL);
        Buf := nil;
        Data := nil;
        FileHandle := INVALID_HANDLE_VALUE;
      end;
    end;
    result := CONST_SUCCESS_NO;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.KeepConnection(const Index: byte): integer;
var
  SendBuf: WSABUF;
  pClient: PClientContext;
  PkgHead: TPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    pClient := @FClientArray[Index];
    if not pClient.UsePkgHead then
    begin
      result := CONST_ERROR_INVALID_ACTION;
      exit;
    end;

    SendBuf.len := Sizeof(TPkgHead);
    SendBuf.Buf := @PkgHead;

    EncodePkgHead(PkgHead, 0, CONST_PKGTYPE_HEARTBEAT);

    result := SendFinalData(pClient, @SendBuf, 1, Sizeof(TPkgHead));
  end;
end;

procedure TTcpClient.ReturnContext(pClient: PClientContext);
begin
  EnterCriticalSection(FRTLClient);
  try
    // ���ͷ���Դ��������б�־
    if (pClient^.Data <> nil) then
    begin
      if pClient^.Data <> pClient^.Buf then
        FreeMemEx(pClient^.Data);
      pClient^.Data := nil;
    end;

    if pClient^.Buf <> nil then
    begin
      FreeMemEx(pClient^.Buf);
      pClient^.Buf := nil;
    end;

    if pClient^.DestName <> nil then
    begin
      FreeMemEx(pClient^.DestName);
      pClient^.DestName := nil;
    end;

    if pClient^.NetEvent <> INVALID_HANDLE_VALUE then
    begin
      try
        CloseHandle(pClient^.NetEvent);
      except
      end;
      pClient^.NetEvent := INVALID_HANDLE_VALUE;
    end;

    if pClient^.FileHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        CloseHandle(pClient^.FileHandle);
      except
      end;
      pClient^.FileHandle := INVALID_HANDLE_VALUE;
    end;

    if pClient^.Sock <> INVALID_SOCKET then
    begin
      try
        closesocket(pClient^.Sock);
      except
      end;
      pClient^.Sock := INVALID_SOCKET;
    end;
    // ����ñ�־
    pClient^.ProxyLevel := 0;
    pClient^.Status := csFree;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.CheckValid(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < Low(FClientArray)) or (index > High(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if FClientArray[Index].Status <> csConnected then
  begin
    result := CONST_ERROR_NOT_CONNECTED;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.CheckValidFlag(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < Low(FClientArray)) or (index > High(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.ConnectTo(const DestIP: Cardinal; const DestPort: Word; var Index: byte; const Flag: integer;
  const OwnProto, PassProxy: boolean): integer;
var
  pClient: PClientContext;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  ErrCode: integer;
begin
  pClient := nil;
  result := CONST_ERROR_CONNECT;
  try
    if not FActive then
    begin
      result := StartServer();
      if result <> CONST_SUCCESS_NO then
        exit;
    end;

    if DestIP = INADDR_NONE then
    begin
      result := CONST_ERROR_INVALID_SERVERIP;
      exit;
    end;

    pClient := GetFreeContext();
    if pClient = nil then
    begin
      result := CONST_ERROR_GET_FREE_SOCKET;
      exit;
    end;

    // ��¼����
    pClient^.DestIP := DestIP;
    pClient^.DestPort := DestPort;
    index := pClient^.Index;
    pClient^.UsePkgHead := OwnProto;
    pClient^.UseProxy := PassProxy;
    pClient^.OuterFlag := Flag;

    FillChar(Addr, Sizeof(Addr), 0);
    Addrin := @Addr;

    Addrin^.sin_family := AF_INET; // ��������
    if (FProxyKind = pkNoProxy) or not(PassProxy) then
    begin
      Addrin^.sin_addr.S_addr := DestIP;
      Addrin^.sin_port := htons(DestPort); // �˿�
    end
    else
    begin // �д������Ӵ���
      Addrin^.sin_port := htons(FProxyPort); // �˿�

      if IsValidIP(FProxyIP) then
        Addrin^.sin_addr.S_addr := inet_addr(PAnsiChar(FProxyIP))
      else
        Addrin^.sin_addr.S_addr := GetProxyIPByProxyName(FProxyIP);

      // ��ЧIP��ַ
      if Addrin^.sin_addr.S_addr = INADDR_NONE then
      begin
        result := CONST_ERROR_INVALID_SERVERIP;
        exit;
      end;
    end;
    // �����׽���
    pClient^.Sock := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, WSA_FLAG_OVERLAPPED);
    if pClient^.Sock = INVALID_SOCKET then
    begin
      ErrCode := WSAGetLastError;
      WriteDebug(inttostr(ErrCode) + '  / ' + GetErrorMsg(ErrCode, false));
      result := CONST_ERROR_CREATE_SOCKET;
      exit;
    end;

    pClient^.NetEvent := CreateEvent(nil, false, false, nil); // �׽��������¼�
    if WSAEventSelect(pClient.Sock, pClient.NetEvent, FD_CONNECT) = SOCKET_ERROR then
    begin // or FD_READ or FD_CLOSE
      result := CONST_ERROR_CREATE_SOCKET;
      exit;
    end;

    // ��������
    ErrCode := Connect(pClient^.Sock, Addr, Sizeof(Addr));
    if ErrCode <> NO_ERROR then
    begin
      ErrCode := WSAGetLastError;
      if ErrCode <> WSAEWOULDBLOCK then
      begin
        if ErrCode = WSAEINTR then
          WriteDebug('Connect fail WSAEINTR');

        result := CONST_ERROR_CONNECT;
        exit;
      end;
    end;

    // ֪ͨ�̸߳ı���ѯ
    ReleaseSemaphore(FExitSema, 1, nil);

    result := CONST_SUCCESS_NO;
  finally
    if (result <> CONST_SUCCESS_NO) and (pClient <> nil) then
      ReturnContext(pClient);
  end;
end;

function TTcpClient.ConnectTo(const DestName: Ansistring; const DestPort: Word; var Index: byte; const Flag: integer;
  const OwnProto, PassProxy: boolean): integer;
var
  IPs: TStringList;
  i: integer;
  pClient: PClientContext;
begin
  result := CONST_ERROR_CONNECT;
  if IsValidIP(DestName) then
  begin
    result := ConnectTo(ConvertIPToDWORD(PAnsiChar(DestName)), DestPort, Index, Flag, OwnProto, PassProxy);
  end
  else
  begin

    IPs := TStringList.Create;
    try
      if not GetAllIPByName(DestName, IPs) then
      begin
        result := CONST_ERROR_HOST_NOT_FOUND;
        exit;
      end;

      for i := 0 to IPs.Count - 1 do
      begin
        // ����ȥ��
        result := ConnectTo(StrToInt64(IPs[i]), DestPort, Index, Flag, OwnProto, PassProxy);
        if result = CONST_SUCCESS_NO then
        begin
          pClient := @FClientArray[Index];

          // ����IP
          GetMemEx(pClient^.DestName, length(DestName) + 1);
          Ansistrings.strpcopy(pClient^.DestName, DestName);

          break;
        end;
      end;
    finally
      IPs.Free;
    end;
  end;
end;

{ TRecvThread }

procedure TRecvThread.CallAccept(pClient: PClientContext);
var
  tSock, tEvent: THandle;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  addrlen: integer;
  NewClient: PClientContext;
begin
  addrlen := Sizeof(TSockAddr);
  tSock := accept(pClient.Sock, @Addr, @addrlen);
  if tSock = INVALID_SOCKET then
    exit;

  tEvent := CreateEvent(nil, false, false, nil);
  if tEvent = INVALID_HANDLE_VALUE then
  begin
    closesocket(tSock);
    exit;
  end;

  SetNoNagle(tSock);

  if WSAEventSelect(tSock, tEvent, FD_READ or FD_CLOSE) = SOCKET_ERROR then
  begin
    closesocket(tSock);
    CloseHandle(tEvent);
    exit;
  end;

  // ���������Ѿ������ˣ�ȥ��ȡ������
  NewClient := FTcpClient.GetFreeContext;
  if NewClient = nil then
  begin
    closesocket(tSock);
    CloseHandle(tEvent);
    exit;
  end;
  Addrin := @Addr;
  // ��¼�����Ϣ
  NewClient.Sock := tSock;
  NewClient.DestIP := Addrin^.sin_addr.S_addr;
  NewClient.DestPort := ntohs(Addrin^.sin_port);
  NewClient.UseProxy := false;
  NewClient.Status := csConnected;
  NewClient.NetEvent := tEvent;
  NewClient.ConnTime := now;
  NewClient.UsePkgHead := FTcpClient.FUsePkgHead;
  if NewClient.UsePkgHead then
    NewClient.OperType := otRecvHead
  else
    NewClient.OperType := otRecvData;

  ReBuildWaitArray;
  // ֪ͨ��������
  FTcpClient.DoAcceptConnect(NewClient, NewClient.DestIP, NewClient.DestPort);

end;

constructor TRecvThread.Create(TcpIoClient: TTcpClient);
begin
  FreeOnTerminate := true;
  FTcpClient := TcpIoClient;
  inherited Create(false);
end;

procedure TRecvThread.DoConnectOver(const ErrCode: integer; pClient: PClientContext);
begin
  FTcpClient.DoConnectOver(ErrCode, pClient);
  if ErrCode <> CONST_SUCCESS_NO then
  begin
    pClient^.Status := csDisconnecting;
    ReBuildWaitArray;
  end;
end;

procedure TRecvThread.DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
  const DataLen: Cardinal; const UseTime: Double);
begin
  FTcpClient.DoRecvDataOver(ErrCode, pClient, Data, DataLen, UseTime);
  if ErrCode <> CONST_SUCCESS_NO then
  begin
    pClient^.Status := csDisconnecting;
    ReBuildWaitArray;
  end;
end;

procedure TRecvThread.Execute;
var
  i: integer;
  dRes: Cardinal;
begin
  ReBuildWaitArray;

  FRecvEvent := CreateEvent(nil, false, false, nil); // �����¼�
  try
    while not Terminated do
    begin
      dRes := WaitForMultipleObjects(FWaitCount, @FWaitArray, false, INFINITE);

      if Terminated then
        exit;

      case dRes of
        WAIT_OBJECT_0:
          begin // �ı���ѯ�����˳�֪ͨ
            if FTcpClient.FActive then
            begin // ���µ��׽��ּ�����ѯ
              ReBuildWaitArray;
            end
            else
              break;
          end;
        WAIT_TIMEOUT:
          begin // �ȴ���ʱ

            FTcpClient.WriteDebug('WAIT_TIMEOU');
            break;
          end;
        WAIT_FAILED:
          begin // �ȴ�ʧ��
            FTcpClient.WriteDebug('WAIT_FAILED');
            break;
          end;
      else
        begin // �����˾�����������
          i := Cardinal(dRes) - WAIT_OBJECT_0;
          // ����֪�����Ǹ���������¼�

          // �ȴ���I��Ȼ����ȥѭ����������¼��Ƿ�Ҳ������
          HandleOneEvent(FWaitIndex[i]);

          if Terminated then
            exit;

          while i < FWaitCount do
          begin
            dRes := WaitForSingleObject(FWaitIndex[i], 0);
            if dRes = WAIT_OBJECT_0 then
              HandleOneEvent(FWaitIndex[i]);

            inc(i);

            if Terminated then
              exit;
          end;
        end;
      end;
    end;
  finally
    CloseHandle(FRecvEvent)
  end;
end;

procedure TRecvThread.StartNegociateWithProxy(pClient: PClientContext);
var
  ConnStr, sip: Ansistring;
  ErrCode: integer;
  SendBuf: WSABUF;
begin
  case pClient^.ProxyKind^ of
    pkHTTPProxy:
      begin
        sip := ConvertDWORDToIP(pClient^.ProxyDestIP);

        ConnStr := 'CONNECT ' + Ansistring(sip) + ':' + Ansistring(inttostr(pClient^.ProxyDestPort)) + ' HTTP/1.1' +
          #13#10 + 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)' + #13#10 + 'Host: ' + Ansistring(sip)
          + #13#10 + 'Content-Length: 0' + #13#10 + 'Proxy-Connection: Keep-Alive' + #13#10 + 'Pragma: no-cache' + #13#10;

        if pClient^.ProxyUser^ <> '' then
        begin // �ṩ���û���������
          ConnStr := ConnStr + 'Proxy-Authorization: Basic ' +
            Ansistring(EncdDecd.EncodeString(string(pClient^.ProxyUser^ + ':' + pClient^.ProxyPwd^))) + #13#10;
        end;

        ConnStr := ConnStr + #13#10;
        Ansistrings.strpcopy(pClient^.Buf, ConnStr);
        SendBuf.len := length(ConnStr);
        SendBuf.Buf := pClient^.Buf;

        // �޸�״̬���Ա����Э��
        pClient^.OperType := otProxy1;
        // ���ͣ�����Ҫ�ȵ����ͽ���
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // ��������ʧ��
          DoConnectOver(ErrCode, pClient);
        end;
      end;

    pkSOCKS5Proxy:
      begin
        pClient^.Buf[0] := #5; // SOCKS�汾5
        pClient^.Buf[1] := #2; // ֧��2�ַ���
        pClient^.Buf[2] := #0; // ����1������֤
        pClient^.Buf[3] := #2; // ����2���û��Ϳ�����֤
        SendBuf.len := 4;
        SendBuf.Buf := pClient^.Buf;
        // �޸�״̬���Ա����Э��
        pClient^.OperType := otProxy1;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // ��������ʧ��
          DoConnectOver(ErrCode, pClient);
        end;
      end;

    pkSOCKS4Proxy:
      begin
        // ��������������socks4Э��
        pClient^.Buf[0] := #4; // SOCKS�汾4   1�ֽ�
        pClient^.Buf[1] := #1; // Connect����  1�ֽ�
        PWord(@pClient^.Buf[2])^ := htons(pClient^.ProxyDestPort); // �������˿�2�ֽ�
        PCardinal(@pClient^.Buf[4])^ := pClient^.ProxyDestIP; // ������ip4�ֽ�
        if pClient^.ProxyUser^ <> '' then // �ṩ���û�
          CopyMemory(@pClient^.Buf[8], @(pClient^.ProxyUser^[1]), length(pClient^.ProxyUser^));
        pClient^.Buf[8 + length(pClient^.ProxyUser^)] := #0; // ��β
        SendBuf.len := 9 + length(pClient^.ProxyUser^);
        SendBuf.Buf := pClient^.Buf;
        // �޸�״̬���Ա����Э��
        pClient^.OperType := otProxy1;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // ��������ʧ��
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

procedure TRecvThread.StartRecvFile(pClient: PClientContext; SaveName: Ansistring; Offset: Cardinal);
var
  ExistsFlag: boolean;
  FileSize: Cardinal;
begin
  // ��ʼ�����ļ�
  // �ļ�����¼��Data��
  GetMemEx(pClient^.Data, length(SaveName) + 1);
  Ansistrings.strpcopy(pClient^.Data, SaveName);
  pClient^.Offset := Offset;

  // �򵥵㣬��ͬ����ʽȥд�ļ�����Ȼ��Ҫ���ֲ���ϵͳ����Ϊ98��֧���ص���д�ļ�
  if not ForceDirectories(ExtractFilePath(string(SaveName))) then
  begin // �����ļ�Ŀ¼ʧ��
    FTcpClient.DoRecvFileOver(CONST_ERROR_NO_SUCH_DIR, pClient, SaveName, 0, 0, 0, 0);
    OnlyDisconnect(pClient);
    exit;
  end;
  ExistsFlag := FileExists(string(SaveName));

  pClient^.FileHandle := CreateFileA(pClient^.Data, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS,
    FILE_ATTRIBUTE_NORMAL, 0);
  if pClient^.FileHandle = HFILE_ERROR then
  begin // �����ļ�Ŀ¼ʧ��
    FTcpClient.DoRecvFileOver(CONST_ERROR_OPENFILE, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
    OnlyDisconnect(pClient);
    exit;
  end;

  if ExistsFlag then
  begin
    FileSize := GetFileSize(pClient^.FileHandle, nil);
    if Offset > FileSize then
    begin
      CloseHandle(pClient^.FileHandle);
      FTcpClient.DoRecvFileOver(CONST_ERROR_FILEOFFSET, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
      OnlyDisconnect(pClient);
      exit;
    end;
    if SetFilePointer(pClient^.FileHandle, Offset, nil, FILE_BEGIN) = $FFFFFFFF then
    begin
      CloseHandle(pClient^.FileHandle);
      FTcpClient.DoRecvFileOver(CONST_ERROR_FILEOFFSET, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
      OnlyDisconnect(pClient);
      exit;
    end;
  end;

  // ok���ļ��Ѿ��򿪣��ý��ձ�־
  pClient^.OperType := otRecvFile;
  pClient^.FinishLen := 0;
end;

procedure TRecvThread.HandleConnOver(pClient: PClientContext);
begin
  SetNoNagle(pClient.Sock);

  // ���¹����¼�����Ϊԭ��ֻ������FD_CONNECT
  if WSAEventSelect(pClient.Sock, pClient.NetEvent, FD_READ or FD_CLOSE) = SOCKET_ERROR then
  begin
    pClient.Status := csDisconnecting;
    exit;
  end;

  if FTcpClient.FProxyKind = pkNoProxy then
  begin // ��ʹ�ô���
    pClient.Status := csConnected;
    pClient.ConnTime := now;
    if pClient.UsePkgHead then
      pClient.OperType := otRecvHead
    else
      pClient.OperType := otRecvData;
    // ֪ͨ���ӳɹ�
    DoConnectOver(CONST_SUCCESS_NO, pClient);
  end
  else
  begin // ��Ҫ������

    if pClient.UseProxy then
    begin
      // ��ʼ����Э��
      pClient^.OperType := otProxy1;

      // ���ӷ�����IP
      if FTcpClient.FProxyKind2 <> pkNoProxy then
      begin
        if IsValidIP(FTcpClient.FProxyIP2) then
          pClient^.ProxyDestIP := inet_addr(PAnsiChar(FTcpClient.FProxyIP2))
        else
          pClient^.ProxyDestIP := FTcpClient.GetProxyIPByProxyName(FTcpClient.FProxyIP2);
        pClient^.ProxyDestPort := FTcpClient.FProxyPort2;
      end
      else
      begin
        pClient^.ProxyDestIP := pClient^.DestIP;
        pClient^.ProxyDestPort := pClient^.DestPort;
      end;

      pClient^.ProxyKind := @FTcpClient.FProxyKind;
      pClient^.ProxyUser := @FTcpClient.FProxyUser; // �����û�
      pClient^.ProxyPwd := @FTcpClient.FProxyPwd; // �������

      StartNegociateWithProxy(pClient);
    end
    else
    begin
      pClient.Status := csConnected;
      pClient.ConnTime := now;
      if pClient.UsePkgHead then
        pClient.OperType := otRecvHead
      else
        pClient.OperType := otRecvData;
      // ֪ͨ���ӳɹ�
      DoConnectOver(CONST_SUCCESS_NO, pClient);
    end;
  end;
end;

procedure TRecvThread.HandleFileArrive(pClient: PClientContext);
var
  SaveName: Ansistring;
  Offset: Cardinal;
begin
  SaveName := '';
  try
    FTcpClient.DoRecvFileQuery(pClient, SaveName, Offset);
  except
    DoRecvDataOver(CONST_ERROR_NO_FILE_ARRIVE, pClient, nil, 0, 0);
    exit;
  end;

  if SaveName <> '' then
    StartRecvFile(pClient, SaveName, Offset)
  else
    DoRecvDataOver(CONST_ERROR_NO_FILE_ARRIVE, pClient, nil, 0, 0);
end;

procedure TRecvThread.HandleOneEvent(const Index: byte);
var
  pClient: PClientContext;
  we: TWSANetworkEvents; // �����¼�
  dRes: Cardinal;
begin
  pClient := @FTcpClient.FClientArray[index];
  // ��ö�������¼���Ȼ����������¼�����֧����
  dRes := WSAEnumNetworkEvents(pClient.Sock, pClient^.NetEvent, we);
  if dRes = NO_ERROR then
  begin
    if (we.lNetworkEvents and FD_READ = FD_READ) then
    begin
      if we.iErrorCode[FD_READ_BIT] = NO_ERROR then
      begin // �����ݿ��Զ�
        case pClient^.OperType of
          otProxy1:
            RecvProxyRes1(pClient);
          otProxy2: // ���մ���Э�̵�1����Ӧ�����͵�2��
            RecvProxyRes2(pClient);
          otProxy3: // ���մ���Э�̵�2����Ӧ�����͵�3��
            RecvProxyRes3(pClient);
          otRecvHead: // ����ͷ
            HandleRecvHead(pClient);
          otRecvBody: // ������
            HandleRecvBody(pClient);
          otRecvFile: // �����ļ���
            HandleRecvFile(pClient);
          otRecvData: // �յ�������
            HandleRecvData(pClient);
        end;
      end
      else
      begin // �����ݴ�����
        // ����һ�����ӶϿ��¼���Ȼ���ͷ�����
        if pClient.Status = csConnected then
          DoRecvDataOver(TransferWinsockError(we.iErrorCode[FD_READ_BIT]), pClient, nil, 0, 0)
        else
          DoConnectOver(TransferWinsockError(we.iErrorCode[FD_READ_BIT]), pClient);
      end;
    end
    else if (we.lNetworkEvents and FD_CONNECT) = FD_CONNECT then
    begin
      if we.iErrorCode[FD_CONNECT_BIT] = NO_ERROR then
      begin
        HandleConnOver(pClient);
      end
      else
      begin // ����һ������ʧ���¼���Ȼ���ͷ�����
        TransferWinsockError(we.iErrorCode[FD_CONNECT_BIT]);
        FTcpClient.WriteDebug('[TRecvThread]����Ŀ��ʧ��:' + inttostr(we.iErrorCode[FD_CONNECT_BIT]) + '/' +
          string(ConvertDWORDToIP(pClient.DestIP)) + '/' + inttostr(pClient.DestPort));
        DoConnectOver(TransferWinsockError(we.iErrorCode[FD_CONNECT_BIT]), pClient);
      end;
    end
    else if (we.lNetworkEvents and FD_CLOSE) = FD_CLOSE then
    begin // ���ӱ�����
      if pClient.Status = csConnected then
      begin
        FTcpClient.WriteDebug('[TRecvThread] ���ӱ�����');
        FTcpClient.DoDisconnected(pClient);
        OnlyDisconnect(pClient);
      end
      else
        DoConnectOver(CONST_ERROR_REMOTE_DISCONNECT, pClient);
    end
    else if (we.lNetworkEvents and FD_ACCEPT) = FD_ACCEPT then
    begin // �����ӽ���
      if we.iErrorCode[FD_ACCEPT_BIT] = NO_ERROR then
        CallAccept(pClient);
    end;
    // ���������¼�������
  end
  else
  begin
    // ����һ�����ӶϿ��¼���Ȼ���ͷ�����
  end;
end;

procedure TRecvThread.HandleRecvBody(pClient: PClientContext);
var
  Flag, RecvLen: Cardinal;
  ErrorCode: Cardinal;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := pClient^.TotalLen - pClient^.FinishLen;
  if RecvBuf.len > C_IOCP_BUFFER_SIZE then
    RecvBuf.len := C_IOCP_BUFFER_SIZE;

  RecvBuf.Buf := @pClient^.Data[pClient^.FinishLen];

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  RecvLen := 0;

  // FTcpClient.WriteDebug('HandleRecvBody WSARecv Len:' + Inttostr(RecvBuf.len));

  if WSARecv(pClient^.Sock, @RecvBuf, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // ����ʧ��
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Body Error 1:' + inttostr(ErrorCode));
        DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, pClient^.Data, pClient^.FinishLen, 0);
        exit;
      end;
    end
    else
    begin
      // �������ʧ��
      FTcpClient.WriteDebug('Recv Body Error 2:' + inttostr(ErrorCode));
      DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, pClient^.Data, pClient^.FinishLen, 0);
      exit;
    end;
  end;

  // ����ʵ���ϲ�����ô�жϣ���Ϊ�����ղ�����ô��
  if RecvLen = 0 then
  begin
    // �������ʧ��
    // DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, pClient^.Data,pClient^.FinishLen,0);
    exit;
  end;

  // ����ƫ��
  pClient^.FinishLen := pClient^.FinishLen + RecvLen;

  if pClient^.FinishLen = pClient^.TotalLen then
  begin
    // ������ճɹ�
    DoRecvDataOver(CONST_SUCCESS_NO, pClient, pClient^.Data, pClient^.TotalLen, (now - pClient^.RecvTime) * 86400);
    if Terminated then
      exit;

    // ���Ƿ�Ҫ�ͷ��ڴ�
    if pClient^.Data <> pClient^.Buf then
    begin
      FreeMemEx(pClient^.Data);
      pClient^.Data := pClient^.Buf;
    end;
    // ���¿�ʼ����
    pClient^.OperType := otRecvHead;
    pClient^.TotalLen := 0;
  end;
end;

procedure TRecvThread.HandleRecvData(pClient: PClientContext);
var
  Flag: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, pClient^.TotalLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // ����ʧ��
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, pClient^.TotalLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Data Error 1:' + inttostr(ErrorCode));
        DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
        exit;
      end;
      // ��ȷ�ľͲ�����
    end
    else
    begin
      // �������ʧ��
      DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
      FTcpClient.WriteDebug('Recv Data Error:' + inttostr(ErrorCode));
      exit;
    end;
  end;
  // ����ʵ���ϲ�����ô�жϣ���Ϊ�����ղ�����ô��
  if pClient^.TotalLen = 0 then
  begin
    // �������ʧ��
    // DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, nil, 0, 0);
    exit;
  end;
  // �ύ����
  DoRecvDataOver(CONST_SUCCESS_NO, pClient, pClient^.Buf, pClient^.TotalLen, 0);
end;

procedure TRecvThread.HandleRecvFile(pClient: PClientContext);
var
  Flag, RecvLen, WriteLen: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;

  if RecvBuf.len > pClient^.TotalLen - pClient^.FinishLen then
    RecvBuf.len := pClient^.TotalLen - pClient^.FinishLen;

  RecvBuf.Buf := pClient^.Buf;
  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  RecvLen := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // ����ʧ��
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv File Error:' + inttostr(ErrorCode));
        FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
          pClient^.Offset, (now - pClient.RecvTime) * 86400);
        OnlyDisconnect(pClient);
        exit;
      end;
    end
    else
    begin
      FTcpClient.WriteDebug('Recv File Error:' + inttostr(ErrorCode));
      // ��������ļ�ʧ��
      FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
        pClient^.Offset, (now - pClient.RecvTime) * 86400);
      OnlyDisconnect(pClient);
      exit;
    end;
  end;
  // ����ʵ���ϲ�����ô�жϣ���Ϊ�����ղ�����ô��
  if RecvLen = 0 then
  begin // ��������ļ�ʧ��
    // ��������ļ�ʧ��
    // FTcpClient.DoRecvFileOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen, pClient^.Offset, (now - pClient.RecvTime)*86400);
    // OnlyDisconnect(pClient);
    exit;
  end;
  // д�ļ�
  if not(WriteFile(pClient^.FileHandle, pClient^.Buf[0], RecvLen, WriteLen, nil)) or (WriteLen <> RecvLen) then
  begin
    // ��������ļ�ʧ��
    FTcpClient.DoRecvFileOver(CONST_ERROR_WRITEFILE, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
      pClient^.Offset, (now - pClient.RecvTime) * 86400);
    OnlyDisconnect(pClient);
    exit;
  end;

  // ����ƫ��
  pClient^.FinishLen := pClient^.FinishLen + RecvLen;
  if pClient^.FinishLen = pClient^.TotalLen then
  begin // ������
    CloseHandle(pClient^.FileHandle);
    pClient^.FileHandle := INVALID_HANDLE_VALUE;
    // ��������ļ�ʧ��
    FTcpClient.DoRecvFileOver(CONST_SUCCESS_NO, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
      pClient^.Offset, (now - pClient.RecvTime) * 86400);
    // �ͷ�pClient^.Data  �ļ���
    FreeMemEx(pClient^.Data);
    pClient^.Data := pClient^.Buf;
    pClient^.OperType := otRecvHead; // ���»ص�����ͷ��״̬
  end;
end;

procedure TRecvThread.HandleRecvHead(pClient: PClientContext);
var
  ErrorCode: integer;
  FinishLen: Cardinal;
  FBuff: PWSABUF;
  Flag, RecvLen: Cardinal;
begin
  // ΢���������������˼������buffֻ������������
  GetMemEx(Pointer(FBuff), Sizeof(WSABUF));
  try
    FBuff.len := Sizeof(TPkgHead);
    FBuff.Buf := @pClient^.PkgHead;
    FinishLen := 0;
    FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
    pClient^.Overlap.hEvent := FRecvEvent;

    Flag := 0;
    RecvLen := 0;
    while not Terminated do
    begin

      // �ͻ����׽��� //���ջ�����  //����������
      if WSARecv(pClient^.Sock, FBuff, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
      begin

        // ����ʧ��
        ErrorCode := WSAGetLastError;
        if (ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK) then
        begin
          Flag := 0;
          if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
          begin
            ErrorCode := WSAGetLastError;
            FTcpClient.WriteDebug('Recv Head Error 1:' + inttostr(ErrorCode));
            DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
            exit;
          end; // ��ȷ�ľͲ�����
        end
        else
        begin
          // �������ʧ��
          DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
          FTcpClient.WriteDebug('Recv Head Error 2:' + inttostr(ErrorCode));
          exit;
        end;
      end;
      FinishLen := FinishLen + RecvLen;

      // �����˳�
      if FinishLen = Sizeof(TPkgHead) then
        break
      else
      begin
        FBuff^.len := Sizeof(TPkgHead) - FinishLen;
        FBuff^.Buf := @PAnsiChar(@pClient^.PkgHead)[FinishLen];
        FTcpClient.WriteDebug('Recv Head :' + inttostr(FinishLen));

      end;
    end;
  finally
    FreeMemEx(FBuff);
  end;

  // ����ʵ���ϲ�����ô�жϣ���Ϊ�����ղ�����ô��
  if FinishLen <> Sizeof(TPkgHead) then
  begin
    // �������ʧ��
    DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, nil, 0, 0);

  end
  else
  begin
    // ���ͷ
    if FTcpClient.DecodePkgHead(pClient^.PkgHead) <> CONST_SUCCESS_NO then
    begin
      // Ѱ������ͷ
      DoRecvDataOver(CONST_ERROR_INVALID_PKG_FLAG, pClient, nil, 0, 0);
      // pClient^.OperType := otRecvFindHead;
      exit;
    end;

    // �������ģ�׼�����ձ�����

    // �Զ���ͷ�еõ� �ܵĽ��ճ���
    pClient^.TotalLen := pClient^.PkgHead.DataLen;
    // �õ� ������
    // DataKind := pClient^.PkgHead.PkgKind;
    pClient^.RecvTime := now;

    // if datakind = CONST_PKGTYPE_FILE then begin
    // //�ļ�����
    // HandleFileArrive(pClient);
    // end else if DataKind = CONST_PKGTYPE_HEARTBEAT then begin
    // //������
    //
    // end else begin
    // �����ڴ�
    if (pClient^.TotalLen > C_IOCP_BUFFER_SIZE) then
    begin

      GetMemEx(pClient^.Data, pClient^.TotalLen);
      if pClient^.Data = nil then
      begin
        DoRecvDataOver(CONST_ERROR_ALLOC_MEMORY, pClient, nil, 0, 0);
        exit;
      end;
    end
    else
      pClient^.Data := pClient^.Buf;

    pClient^.FinishLen := 0;
    pClient^.OperType := otRecvBody;
  end;
  // end;
end;

procedure TRecvThread.OnlyDisconnect(pClient: PClientContext);
begin
  pClient^.Status := csDisconnecting;
  ReBuildWaitArray;
end;

procedure TRecvThread.ReBuildWaitArray;
var
  i, Index: integer;
  pClient: PClientContext;
begin
  FWaitArray[0] := FTcpClient.FExitSema; // 0ʼ�����˳��¼�������֪ͨ
  FWaitCount := 1; // �ʼֻ��һ���ɵȴ����
  Index := Low(FTcpClient.FClientArray);

  // �Ƿ�Ҫ����
  if FTcpClient.FNeedListen then
  begin
    FWaitArray[1] := FTcpClient.FClientArray[Low(FTcpClient.FClientArray)].NetEvent;
    FWaitIndex[1] := Low(FTcpClient.FClientArray);
    inc(FWaitCount);
    inc(Index);
  end;

  for i := Index to High(FTcpClient.FClientArray) do
  begin
    if FTcpClient.FClientArray[i].Status <> csFree then
    begin
      pClient := @FTcpClient.FClientArray[i];
      case pClient^.Status of
        csConnecting, csConnected:
          begin
            // wate INVALID_HANDLE_VALUE ʱ��Ȳ�����
            if FTcpClient.FClientArray[i].NetEvent <> INVALID_HANDLE_VALUE then
            begin
              FWaitArray[FWaitCount] := FTcpClient.FClientArray[i].NetEvent;
              FWaitIndex[FWaitCount] := FTcpClient.FClientArray[i].Index;
              inc(FWaitCount);
            end;
          end;
        csDisconnecting: // �������Ҫ�ͷ�
          FTcpClient.ReturnContext(pClient);
      end;
    end;
  end;

end;

procedure TRecvThread.RecvProxyRes1(pClient: PClientContext);
var
  Flag: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;
  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, pClient^.TotalLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, pClient^.TotalLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res1 Error 1:' + inttostr(ErrorCode));
        DoConnectOver(TransferWinsockError(ErrorCode), pClient);
        exit;
      end;
      // ��ȷ�ľͲ�����
    end
    else
    begin
      // ��������ʧ��
      DoConnectOver(TransferWinsockError(ErrorCode), pClient);
      FTcpClient.WriteDebug('Recv Proxy Res1 Error 2:' + inttostr(ErrorCode));
      exit;
    end;
  end;

  // �����յ�����ĵ�1����Ӧ

  case pClient^.ProxyKind^ of
    pkHTTPProxy:
      begin

        // �ȿ���û��������Ӧ
        if not IsWholeHTTPResponse(pClient^.Buf, pClient^.TotalLen) then
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_DENY, pClient);
          exit;
        end;
        // �����ˣ�����Ӧ�Ƿ��ǳɹ�
        if (pos(Ansistring('HTTP/1.1 200 '), AnsiUpperCase(string(pClient^.Buf))) = 1) or
          (pos(Ansistring('HTTP/1.0 200 '), AnsiUpperCase(string(pClient^.Buf))) = 1) then
        begin
          if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
          begin
            // ��ʼ����Э��
            pClient^.OperType := otProxy1;

            pClient^.ProxyDestIP := pClient^.DestIP;
            pClient^.ProxyDestPort := pClient^.DestPort;
            pClient^.ProxyKind := @FTcpClient.FProxyKind2;
            pClient^.ProxyUser := @FTcpClient.FProxyUser2; // �����û�
            pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // �������
            pClient^.ProxyLevel := 2;
            StartNegociateWithProxy(pClient);
          end
          else
          begin

            pClient^.ConnTime := now;
            pClient^.Status := csConnected;

            if pClient^.UsePkgHead then
              pClient^.OperType := otRecvHead
            else
              pClient^.OperType := otRecvData;
            // �������ӳɹ�
            DoConnectOver(CONST_SUCCESS_NO, pClient);
          end;
        end
        else
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_CONNECT, pClient);
        end;

      end;
    pkSOCKS4Proxy:
      begin
        // ���������ķ���
        if (pClient^.TotalLen <> 8) or (pClient^.Buf[0] <> #0) then
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;
        case pClient^.Buf[1] of
          #90:
            begin
              if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
              begin
                // ��ʼ����Э��
                pClient^.OperType := otProxy1;
                pClient^.ProxyDestIP := pClient^.DestIP;
                pClient^.ProxyDestPort := pClient^.DestPort;
                pClient^.ProxyKind := @FTcpClient.FProxyKind2;
                pClient^.ProxyUser := @FTcpClient.FProxyUser2; // �����û�
                pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // �������
                pClient^.ProxyLevel := 2;
                StartNegociateWithProxy(pClient);
              end
              else
              begin
                pClient^.ConnTime := now;
                pClient^.Status := csConnected;
                if pClient^.UsePkgHead then
                  pClient^.OperType := otRecvHead
                else
                  pClient^.OperType := otRecvData;
                // �������ӳɹ�
                DoConnectOver(CONST_SUCCESS_NO, pClient);
              end;
            end;
          #91:
            begin
              // ��������ʧ��
              DoConnectOver(CONST_ERROR_PROXY_DENY, pClient);
            end;
          #93:
            begin
              // ��������ʧ��
              DoConnectOver(CONST_ERROR_PROXY_AUTHENTICATE, pClient);
            end;
        else
          begin
            // ��������ʧ��
            DoConnectOver(CONST_ERROR_CONNECT, pClient);
          end;
        end; // end case
      end;
    pkSOCKS5Proxy:
      begin
        if (pClient^.TotalLen <> 2) or (pClient^.Buf[0] = #255) then
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;

        case pClient^.Buf[1] of
          #0:
            begin // ȥ���͵�3������ֱ������

              // ���͵�3��Э�̣���Ϊ��û�������֤
              SendProxy3(pClient);
            end;
          #2:
            begin // ���͵�2��������������֤

              // ���͵�2��Э�̣���Ϊ��Ҫ�������֤
              SendProxy2(pClient);
            end;
        else
          begin
            // ��������ʧ��
            DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          end;
        end; //
      end;
  end;
end;

procedure TRecvThread.RecvProxyRes2(pClient: PClientContext);
var
  Flag: Cardinal;
  i: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient.Buf;
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient.Sock, @RecvBuf, 1, pClient.TotalLen, Flag, @pClient.Overlap, nil) <> NO_ERROR then
  begin

    i := WSAGetLastError;
    if ((i = ERROR_IO_PENDING) or (i = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient.Sock, @pClient.Overlap, pClient.TotalLen, true, Flag) then
      begin
        i := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res2 Error 1:' + inttostr(i));
        DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
        exit;
      end;
      // ��ȷ�ľͲ�����
    end
    else
    begin
      // ��������ʧ��
      DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
      FTcpClient.WriteDebug('Recv Proxy Res2 Error 2:' + inttostr(i));
      exit;
    end;
  end;
  // �����յ�����ĵ�2����Ӧ
  case FTcpClient.FProxyKind of
    pkSOCKS5Proxy:
      begin
        if (pClient.TotalLen <> 2) then
        begin
          // CONST_ERROR_PROXY_NEGOTIATE
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;
        if (pClient.Buf[1] <> #0) then
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_AUTHENTICATE, pClient);
          exit;
        end;
        // �����ռ���������
        SendProxy3(pClient);
      end;
  end;
end;

procedure TRecvThread.RecvProxyRes3(pClient: PClientContext);
var
  Flag: Cardinal;
  i: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient.Buf;
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient.Sock, @RecvBuf, 1, pClient.TotalLen, Flag, @pClient.Overlap, nil) <> NO_ERROR then
  begin

    i := WSAGetLastError;
    if ((i = ERROR_IO_PENDING) or (i = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient.Sock, @pClient.Overlap, pClient.TotalLen, true, Flag) then
      begin
        i := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res3 Error 1:' + inttostr(i));
        DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
        exit;
      end;
      // ��ȷ�ľͲ�����
    end
    else
    begin
      // ��������ʧ��
      DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
      FTcpClient.WriteDebug('Recv Proxy Res3 Error:' + inttostr(i));
      exit;
    end;
  end;
  // �����յ�����ĵ�3����Ӧ
  case FTcpClient.FProxyKind of
    pkSOCKS5Proxy:
      begin // ֻ��SOCKS5����ᵽ��һ��

        if pClient.TotalLen <> 10 then
        begin
          // ��������ʧ��
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;

        case pClient.Buf[1] of
          #0:
            begin // ���ӳɹ�
              if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
              begin
                // ��ʼ����Э��
                pClient^.OperType := otProxy1;
                pClient^.ProxyDestIP := pClient^.DestIP;
                pClient^.ProxyDestPort := pClient^.DestPort;
                pClient^.ProxyKind := @FTcpClient.FProxyKind2;
                pClient^.ProxyUser := @FTcpClient.FProxyUser2; // �����û�
                pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // �������
                pClient^.ProxyLevel := 2;
                StartNegociateWithProxy(pClient);
              end
              else
              begin
                pClient.ConnTime := now;
                pClient.Status := csConnected;
                if pClient.UsePkgHead then
                  pClient.OperType := otRecvHead
                else
                  pClient.OperType := otRecvData;

                // �������ӳɹ�
                DoConnectOver(CONST_SUCCESS_NO, pClient);
              end;

            end;
          #3:
            begin
              // ��������ʧ��
              DoConnectOver(CONST_ERROR_NETWORK_DAMAGE, pClient);
            end;
          #4:
            begin
              // ��������ʧ��
              DoConnectOver(CONST_ERROR_HOST_POWEROFF, pClient);
            end;
          #5:
            begin
              // ��������ʧ��
              DoConnectOver(CONST_ERROR_HOST_DENY, pClient);
            end;
        else
          begin
            // ��������ʧ��
            DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          end;
        end; // end case
      end;
  end;
end;

procedure TRecvThread.SendProxy2(pClient: PClientContext);
var
  SendBuf: WSABUF;
  ErrCode: integer;
begin
  case pClient^.ProxyKind^ of
    pkSOCKS5Proxy:
      begin
        pClient.Buf[0] := #1; // ��1�ֽ�
        // ��2�ֽ�Ϊ�û�������
        pClient.Buf[1] := AnsiChar(byte(length(pClient^.ProxyUser^)));

        // ��3�ֽ���Ϊ�û���
        CopyMemory(@pClient.Buf[2], @pClient^.ProxyUser^[1], byte(pClient.Buf[1]));

        // �����û������ǿ����
        pClient.Buf[byte(pClient.Buf[1]) + 2] := AnsiChar(byte(length(pClient^.ProxyPwd^)));
        // ����Ⱥ����ǿ���
        CopyMemory(@pClient.Buf[byte(pClient.Buf[1]) + 3], @pClient^.ProxyPwd^[1],
          byte(pClient.Buf[byte(pClient.Buf[1]) + 2]));

        SendBuf.len := byte(pClient.Buf[1]) + 3 + byte(pClient.Buf[byte(pClient.Buf[1]) + 2]);
        SendBuf.Buf := pClient.Buf;
        // �޸�״̬���Ա����Э��

        pClient.OperType := otProxy2;

        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // ��������ʧ��
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

procedure TRecvThread.SendProxy3(pClient: PClientContext);
var
  SendBuf: WSABUF;
  ErrCode: integer;
begin
  case pClient^.ProxyKind^ of
    pkSOCKS5Proxy:
      begin
        pClient.Buf[0] := #5; // SOCKS�汾5
        pClient.Buf[1] := #1; // Connect����
        pClient.Buf[2] := #0; // ����
        pClient.Buf[3] := #1; // IPv4���͵�ַ
        PCardinal(@pClient.Buf[4])^ := pClient.ProxyDestIP;
        PWord(@pClient.Buf[8])^ := htons(pClient.ProxyDestPort);
        SendBuf.len := 10;
        SendBuf.Buf := pClient.Buf;
        // �޸�״̬���Ա����Э��
        pClient.OperType := otProxy3;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // ��������ʧ��
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

function TRecvThread.SendProxyData(pClient: PClientContext; const Buf: WSABUF): integer;
var
  dRes, Flags: Cardinal;
  ErrCode: integer;
begin
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  if WSASend(pClient.Sock, @Buf, 1, dRes, 0, @pClient^.Overlap, nil) <> 0 then
  begin
    ErrCode := WSAGetLastError;
    if (ErrCode = ERROR_IO_PENDING) or (ErrCode = WSAEWOULDBLOCK) then
    begin
      Flags := 0;
      // �ȴ�
      if not WSAGetOverlappedResult(pClient.Sock, @pClient^.Overlap, dRes, true, Flags) then
      begin // �ص�û�гɹ�
        result := CONST_ERROR_OTHER_OVERLAP_ERROR;
        exit;
      end;
    end
    else
    begin
      // ˵���Ѿ�����
      result := CONST_ERROR_OTHER_OVERLAP_ERROR;
      exit;
    end;

  end;
  if dRes = Buf.len then
    result := CONST_SUCCESS_NO
  else
    result := CONST_ERROR_SEND_FAIL;
end;

procedure TRecvThread.SetNoNagle(Sock: TSocket);
var
  NoNagle: bool;
begin
  NoNagle := true; // ��ʹ��Nagle�㷨 int
  setsockopt(Sock, IPPROTO_TCP, TCP_NODELAY, PAnsiChar(@NoNagle), Sizeof(bool));
end;

{ TTimeOutThread }

constructor TTimeOutThread.Create(TcpClient: TTcpClient);
begin
  FreeOnTerminate := true;
  FTcpClient := TcpClient;
  inherited Create(false);
end;

procedure TTimeOutThread.Execute;
var
  i, dRes: integer;
  pClient: PClientContext;
begin
  while not Terminated do
  begin
    // ���� ��Ѷһ��
    dRes := WaitForSingleObject(FTcpClient.FTimeoutEvent, 2000);

    if Terminated then
      break;

    if dRes = WAIT_TIMEOUT then
    begin
      for i := Low(FTcpClient.FClientArray) to High(FTcpClient.FClientArray) do
      begin
        pClient := @FTcpClient.FClientArray[i];
        // csConnected csConnecting  ֻ�Դ������Ӻͽ���״̬�������ļ��
        if ((pClient.Status = csConnected) or (pClient.Status = csConnecting)) and (pClient.Timeout >= 0) then
        begin
          // ��ʱ
          inc(pClient.Timeout, 2);

          // ��ʱ
          if (pClient.MaxTimeout > 0) and (pClient.Timeout >= pClient.MaxTimeout) then
          begin

            if pClient.Status = csConnected then
            begin // ���ճ�ʱ
              if pClient.OperType in [otRecvHead, otRecvBody, otRecvData] then
              begin // ����ͷ
                FTcpClient.DoRecvDataOver(CONST_ERROR_RECV_FAIL, pClient, nil, 0, 0);
              end
              else if pClient.OperType = otRecvFile then
              begin // �����ļ���
                FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen,
                  pClient^.FinishLen, pClient^.Offset, (now - pClient.RecvTime) * 86400);
              end;
            end
            else if pClient.Status = csConnecting then
            begin
              FTcpClient.DoConnectOver(CONST_ERROR_CONNECT, pClient);
            end;

            // �ر�����
            pClient.Status := csDisconnecting;
            // ֪ͨ��ѯ�߳�����
            ReleaseSemaphore(FTcpClient.FExitSema, 1, nil);
          end;
        end;
        if Terminated then
          break;
      end;
    end
    else
      break;
  end;
end;

end.
