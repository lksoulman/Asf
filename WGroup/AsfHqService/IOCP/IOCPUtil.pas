unit IOCPUtil;

interface

uses Windows, SysUtils, Classes, WinSock2, IOCPLibrary, AnsiStrings;

const
  C_ERROR_IOPC_WSAStartup_1 = '��������!��ʼ��ʧ��!(%S)';

  // ���涨����Ƕ�ʱ������Ҫ�õĳ���
  WT_EXECUTEONLYONCE = $00000008; // ֻ����һ��
  WT_EXECUTEINTIMERTHREAD = $00000020; // �ڶ�ʱ�������߳���ִ��

  // ���涨����Ƕ�ʱ��������غ���,delphi��windows.pasû������
  // 1��������ʱ������
function CreateTimerQueue(): THandle; stdcall; // ����ֵΪ���о��
// 2����Ӷ�ʱ����
function CreateTimerQueueTimer(var phNewTimer: THandle; // ����Ķ�ʱ�����
  hTimerQueue: THandle; // CreateTimerQueue����ֵ
  pfnCallback: pointer; // 3�ж���Ļص�ָ��
  lpParameter: pointer; // �ص������Ĳ���
  dwDueTime: dword; // ��1�δ���ʱ�� ����
  dwPeriod: dword; // ������� ���� 0��ʾ1���Դ���,�����Ժ�ÿ�����ʱ���ٴ���ֱ��ȡ��
  dwFlags: ULONG): bool; stdcall; // ��־

// 3��ʱ�䵽Ҫ���õĻص�������ʽ
// ����MSDN�ϵ�˵��������ص�����Ӧ����������������߳���п�����Ӧ�ó������߳�
// Ҳ�п����ǲ���ϵͳ��ʱ���ɵ��̣߳���Ҫ���ܵ���TerminateThread��ֹ�߳�
// TimerOrWaitFiredʼ��Ϊtrue
{ procedure WaitOrTimerCallback(lpParameter:pointer;
  TimerOrWaitFired:boolean); stdcall; }
// 4��ɾ����ʱ����
function DeleteTimerQueueTimer(hTimerQueue: THandle; //
  hTimer: THandle; //
  hCompletionEvent: THandle): bool; stdcall; //
// 5��ɾ����ʱ������
function DeleteTimerQueueEx(TimerQueue: THandle; //
  CompletionEvent: THandle): bool; stdcall; //
// 6���޸Ķ�ʱ������
// �����ڳ�ʱ�ص������
// �����ڽ������������
// ���ڳ���ʱ�䴥���Ķ�ʱ����������
function ChangeTimerQueueTimer(TimerQueue: THandle; Timer: THandle; DueTime, Period: ULONG): bool; stdcall;

function WinSock2Startup: boolean;
procedure WinSock2Cleanup(Init: boolean);
function GetOwnErrByWinsockErr(const Error: integer): integer;

function IsValidIP(const S: AnsiString): boolean;
function GetAllIPByName(const HostName: AnsiString; IPs: TStringList; const GetStringIP: boolean = false): boolean;
function ConvertIPToDword(ip: PAnsiChar): dword;
function ConvertDwordToIP(ip: dword): PAnsiChar;
function TransferWinsockError(const winsockErr: integer): integer;
function IsWholeHTTPResponse(const buf: PAnsiChar; const buflen: Cardinal): boolean;

implementation

function IsWholeHTTPResponse(const buf: PAnsiChar; const buflen: Cardinal): boolean;
var
  rnpos, cnpos, cnlen, k: integer;
begin
  result := false;
  if (buf = nil) or (buflen = 0) then
    exit;

  rnpos := Pos(AnsiString(#13#10#13#10), buf); // ������2��������HTTPͷ����

  if (rnpos = 0) or (rnpos > integer(buflen)) then
    exit;

  cnpos := AnsiPos(AnsiString('content-length: '), AnsiStrings.StrLower(buf));
  if cnpos = 0 then
  begin // û��������
    result := rnpos + 3 = integer(buflen);
    exit;
  end;

  // ��Content-Length��������û����ȫ

  cnpos := cnpos + length(AnsiString('content-length: '));
  for k := cnpos - 2 to cnpos + 11 do
  begin
    if (buf[k] = #13) and (buf[k + 1] = #10) then
    begin
      break;
    end;
  end;

  cnlen := StrToIntDef(Trim(string(Copy(buf, cnpos, k - cnpos + 1))), 0);

  result := (rnpos + cnlen + 3) = integer(buflen);
end;

function TransferWinsockError(const winsockErr: integer): integer;
begin // ת��winsock�����Լ��Ĵ���
  case winsockErr of
    WSAENOTCONN, WSAENOTSOCK:
      begin
        result := CONST_ERROR_NOT_CONNECTED;
      end;
    WSAENETDOWN, WSAEHOSTUNREACH:
      begin
        result := CONST_ERROR_NETWORK_DAMAGE;
      end;
    WSAECONNABORTED:
      begin
        result := CONST_ERROR_LOCAL_DISCONNECT;
      end;
    WSAECONNRESET:
      begin
        result := CONST_ERROR_REMOTE_DISCONNECT;
      end;
    WSAETIMEDOUT:
      begin
        result := CONST_ERROR_IDLE_TIMEOUT;
      end;
    WSAECONNREFUSED:
      begin
        result := CONST_ERROR_HOST_DENY;
      end;
  else
    begin
      result := winsockErr;
    end;
  end;
end;

function IsValidIP(const S: AnsiString): boolean;
var
  j, i: integer;
  LTmp: AnsiString;
  function Fetch(AInput: AnsiString; const ADelim: AnsiString): AnsiString;
  var
    LPos: integer;
  begin
    // AnsiPos does not work with #0
    LPos := Pos(ADelim, AInput);
    if LPos = 0 then
    begin
      result := AInput;
      AInput := '';
    end
    else
    begin
      result := Copy(AInput, 1, LPos - 1);
      AInput := Copy(AInput, LPos + length(ADelim), MaxInt);
    end;
  end;

begin
  result := True;
  LTmp := AnsiString(Trim(string(S)));
  for i := 1 to 4 do
  begin
    j := StrToIntDef(string(Fetch(LTmp, '.')), -1); { Do not Localize }
    result := result and (j > -1) and (j < 256);
    if not result then
      exit;
  end;
end;

function ConvertIPToDword(ip: PAnsiChar): dword;
begin
  result := inet_addr(ip);
end;

function ConvertDwordToIP(ip: dword): PAnsiChar;
var
  Addr: TInAddr;
begin
  Addr.S_addr := ip;
  result := inet_ntoa(Addr);
end;

function GetAllIPByName(const HostName: AnsiString; IPs: TStringList; const GetStringIP: boolean): boolean;
var
  pHost: PHostEnt;
  pIP: PDWORD;
  ippos, i: integer; // ,k
  thostname, dhostname: AnsiString;
  buf: PAnsiChar;
begin
  result := false;

  pHost := gethostbyname(PAnsiChar(HostName));
  if pHost <> nil then
  begin
    IPs.Clear;
    thostname := pHost.h_name;
    dhostname := '';
    // �ж��Ƿ�������
    if pHost.h_aliases <> nil then
    begin
      // ʵ�ʲ��Է��֣������Intranet�Ļ���������û����������������ж�
      if pHost.h_aliases^ <> nil then
        dhostname := pHost.h_aliases^;
    end;

    buf := pHost.h_addr_list^;
    ippos := 0;
    if (dhostname = '') and (thostname <> '') then
    begin

      for i := 1 to 40 * pHost.h_length do
      begin
        if thostname = AnsiStrings.strpas(buf) then
        begin
          ippos := (i - 1) div pHost.h_length;
          break;
        end;
        inc(buf);
      end;
    end
    else if dhostname <> '' then
    begin
      for i := 1 to 40 * pHost.h_length do
      begin
        if dhostname = AnsiStrings.strpas(buf) then
        begin
          ippos := (i - 1) div pHost.h_length;
          break;
        end;
        inc(buf);
      end;
    end;

    if ippos = 0 then
      exit;

    pIP := PDWORD(pHost.h_addr_list^);
    for i := 0 to (ippos - 1) do
    begin
      if not GetStringIP then
        IPs.Add(inttostr(pIP^))
      else
        IPs.Add(string(ConvertDwordToIP(pIP^)));
      inc(pIP);
    end;
    result := True;
  end;
end;

function WinSock2Startup: boolean;
var
  WSData: TWSAData;
  sock: TSocket;
begin
  sock := Socket(AF_INET, SOCK_STREAM, 0);
  if sock = INVALID_SOCKET then
  begin
    if WSAStartup($0202, WSData) <> 0 then
      Raise Exception.Create(Format(C_ERROR_IOPC_WSAStartup_1, [SysErrorMessage(WSAGetlastError())]));
  end
  else
    closesocket(sock);
  result := True;
end;

procedure WinSock2Cleanup(Init: boolean);
begin
  if Init then
    WSACleanup;
end;

function GetOwnErrByWinsockErr(const Error: integer): integer;
begin

  case Error of
    WSAENOTSOCK, WSAECONNABORTED: // not sock,maybe local close connection
      result := CONST_ERROR_LOCAL_DISCONNECT;
    WSAEADDRINUSE: // address has been used
      result := CONST_ERROR_BIND_LISTEN;
    WSAENETDOWN, WSAENETRESET: // network fail
      result := CONST_ERROR_NETWORK_DAMAGE;
    WSAECONNRESET: // remote close connection
      result := CONST_ERROR_REMOTE_DISCONNECT;
    WSAETIMEDOUT:
      result := CONST_ERROR_IDLE_TIMEOUT;
    WSAECONNREFUSED:
      result := CONST_ERROR_HOST_DENY;
    WSAEHOSTUNREACH, WSAENETUNREACH:
      result := CONST_ERROR_HOST_NOT_FOUND;
    ERROR_INVALID_HANDLE:
      result := CONST_ERROR_WAIT;
  else
    result := Error;
  end;
end;

// ��ʱ��������أ�delphi��δ����
function CreateTimerQueue; external Kernel32 name 'CreateTimerQueue';
function CreateTimerQueueTimer; external Kernel32 name 'CreateTimerQueueTimer';
function DeleteTimerQueueTimer; external Kernel32 name 'DeleteTimerQueueTimer';
function DeleteTimerQueueEx; external Kernel32 name 'DeleteTimerQueueEx';
function ChangeTimerQueueTimer; external Kernel32 name 'ChangeTimerQueueTimer';

end.
