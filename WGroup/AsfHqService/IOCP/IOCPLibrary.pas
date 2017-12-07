unit IOCPLibrary;

interface

uses windows;

const

  C_IOCP_BUFFER_SIZE = 1024 * 32; // ʹ��32K�Ļ�����

  // �����ͱ�־λ����
  CONST_PKGTYPE_DATA = $00; // 0.��ͨ����
  CONST_PKGTYPE_FILE = $01; // 1.�ļ���UDP��ʱ��֧��
  CONST_PKGTYPE_HEARTBEAT = $02; // 2.TCP������
  CONST_PKGTYPE_SERVERBUSY = $03; // 3.������æ���ذ����ͻ����յ�Ӧ�ö���

  // �����붨��
  CONST_SUCCESS_NO = $0; // �ɹ�

  // ���ӳ���
  CONST_ERROR_CONNECT = $1000; // ���ӷ�����ʧ��
  CONST_ERROR_INVALID_SERVERIP = $1001; // ��ЧIP
  CONST_ERROR_INVALID_SERVERPORT = $1002; // ��Ч�˿�
  CONST_ERROR_CHANGE_SETTING_ON_RUNNING = $1003; // ������������ʱ�ı�����
  CONST_ERROR_CREATE_SOCKET = $1004; // �����׽���ʧ��
  CONST_ERROR_SET_RECVTIMEOUT = $1005; // ���ý��ճ�ʱʧ��
  CONST_ERROR_HAVE_CONNECTED = $1006; // �����ӣ������ٴ�����
  CONST_ERROR_NOT_CONNECTED = $1007; // δ���ӣ����ܽ��д˲���
  CONST_ERROR_NO_NET_OPTION = $1008; // û�����÷�������Ϣ
  CONST_ERROR_TERMINATED = $1009; // ���ж�
  CONST_ERROR_IN_OPERATION = $100A; // ��ǰ���ڽ��ж�ռ����
  CONST_ERROR_CANCEL_OPERATION = $100B; // ����������
  CONST_ERROR_IDLE_TIMEOUT = $100C; // ���г�ʱ
  CONST_ERROR_NETWORK_DAMAGE = $100D; // �������ع���
  CONST_ERROR_PROXY_NEGOTIATE = $100E; // �����Э��ʧ��
  CONST_ERROR_PROXY_DENY = $100F; // ����ܾ�����
  CONST_ERROR_PROXY_AUTHENTICATE = $1010; // ������֤ʧ��
  CONST_ERROR_HOST_POWEROFF = $1011; // �����ػ�
  CONST_ERROR_HOST_NOT_FOUND = $1012; // �޴�����
  CONST_ERROR_HOST_DENY = $1013; // �����ܾ�

  // ���ͽ��մ�����
  CONST_ERROR_SEND_FAIL = $2000; // ���ͱ���ʧ�ܣ��Է���ֹ���ӣ�
  CONST_ERROR_RECV_FAIL = $2001; // ���ձ���ʧ�ܣ���ʱ��
  CONST_ERROR_RECV_NO_ENOUGH = $2002; // δ�չ�ָ���ֽ�
  CONST_ERROR_REMOTE_DISCONNECT = $2003; // Զ������������ֹ����
  CONST_ERROR_CONTROL_BANDWIDTH = $2004; // �޷����Ʒ��ʹ���
  CONST_ERROR_LOCAL_DISCONNECT = $2005; // ��������������ֹ����
  CONST_ERROR_SEND_AGAIN = $2006; // �������ϴη���δ����ǰ�ٴη���
  CONST_ERROR_SEND_REQUEST = $2007; // ��������ʧ��
  CONST_ERROR_RECV_AUTO = $2008; // ���ս��Զ�����
  CONST_ERROR_COMMAND_DISCONNECT = $2009; // HTTP����ͨ�������Ѿ��Ͽ�
  CONST_ERROR_CREATE_HTTP_TUNNEL = $200A; // �޷���HTTP���
  CONST_ERROR_HTTP_TUNNEL_SEND = $200B; // ����ͨ��HTTP�������ʧ��
  CONST_ERROR_HTTP_TUNNEL_RECV = $200C; // ��HTTP�����ȡ����ʧ��

  // ������س���
  CONST_ERROR_INVALID_REQUEST = $3000; // �Ƿ�������
  CONST_ERROR_INVALID_ACTION = $3001; // �Ƿ�����ҵ��
  CONST_ERROR_INVALID_PKG_LEN = $3002; // �Ƿ����ĳ���
  CONST_ERROR_INVALID_PKG_FLAG = $3003; // �Ƿ����ı�־
  CONST_ERROR_INVALID_HANDLE_RESULT = $3004; // �Ƿ�����������
  CONST_ERROR_PKG_TOOLONG = $3005; // ���������ݳ�������Դ��ڴ��������
  CONST_ERROR_PKG_NIL = $3006; // ����������Ϊ��
  CONST_ERROR_PKG_NO_ENOUGH = $3007; // ���������ݴ���ʵ������
  CONST_ERROR_PARAM_ISNULL = $3008; // �������Ϊ��
  CONST_ERROR_INVALID_PARAM_VALUE = $3009; // ��Ч����ֵ
  CONST_ERROR_FAIL_GEN_PKG_HEAD = $300A; // ���ݳ��Ȳ�����Լ������
  CONST_ERROR_FAIL_CHECK_CRC = $300B; // CRCУ��ʧ��
  CONST_ERROR_KEEPCONNECT = $200C; // ��δ������Ч������Ҫ�󱣳�����
  // �ļ����������
  CONST_ERROR_CREATEFILE = $4000; // �����ļ�ʧ��
  CONST_ERROR_OPENFILE = $4001; // ���ļ�ʧ��
  CONST_ERROR_READFILE = $4002; // ���ļ�ʧ��
  CONST_ERROR_WRITEFILE = $4003; // д�ļ�ʧ��
  CONST_ERROR_INVALID_FILENAME = $4004; // ��Ч�ļ���
  CONST_ERROR_NO_SUCH_FILE = $4005; // �޴��ļ�
  CONST_ERROR_NO_SUCH_DIR = $4006; // ��Ч��Ŀ¼
  CONST_ERROR_GETFILESIZE = $4007; // ��ȡ�ļ���Сʧ��
  CONST_ERROR_FILEOFFSET = $4008; // �ļ�ƫ����Ч
  CONST_ERROR_FILELEN = $4009; // ָ������Ч�ĳ���
  CONST_ERROR_NOT_RECVFILE = $400A; // �ļ�����ȴδ���������ļ�
  CONST_ERROR_NO_FILE_ARRIVE = $400B; // û���ļ�����,�������������ļ�
  CONST_ERROR_FILE_ARRIVE = $400C; // �ļ�������Ҫ�����ļ�����
  // ���в�������
  CONST_ERROR_QUEUE_BLANK = $5000; // ���п�
  CONST_ERROR_QUEUE_TOOLONG = $5001; // ���г��ȳ����������
  CONST_ERROR_QUEUE_IN = $5002; // �����ʧ��
  CONST_ERROR_QUEUE_OUT = $5003; // ������ʧ��
  // �ص�����
  CONST_ERROR_TOOMANY_OVERLAP = $6000; // �ص�����̫��
  CONST_ERROR_CANCELED_BY_OS = $6001; // ��������̨ȡ��
  CONST_ERROR_OTHER_OVERLAP_ERROR = $6002; // �����ص�����
  CONST_ERROR_OVERLAP_PARAM = $6003; // �ص������������޷��ص�
  CONST_ERROR_BIND_TO_COMPPORT = $6004; // �󶨵���ɶ˿ڳ���
  CONST_ERROR_ACCEPT_EVENT = $6005; // acceptex�¼�����
  CONST_ERROR_RECV_EVENT = $6006; // ���������¼�ʧ��
  CONST_ERROR_SEND_EVENT = $6007; // ���������¼�ʧ��
  CONST_SEND_ZERO = $6008; // ���ͳ���Ϊ 0.

  // �ؼ��ڲ�����
  CONST_ERROR_FAIL_CTRL_TIMEOUT = $998E; // �޷����Ƴ�ʱ
  CONST_ERROR_WAIT = $998F; // �ȴ�ʧ��
  CONST_ERROR_GET_FREE_SOCKET = $9990; // �޷���ȡ�յ�SOCKET;
  CONST_ERROR_CREATE_COMPPORT = $9991; // ������ɶ˿�ʧ��
  CONST_ERROR_CREATE_LISTENSOCKET = $9992; // ��������socketʧ��
  CONST_ERROR_BIND_LISTEN = $9993; // �޷���
  CONST_ERROR_LISTENING = $9994; // �޷�����
  CONST_ERROR_BIND_LISTEN_TO_COMPPORT = $9995; // ��������ɶ˿�ʧ��
  CONST_ERROR_CREATE_LOGDIR = $9996; // ��־Ŀ¼����ʧ��
  CONST_ERROR_SERVICE_STARTED = $9997; // �����Ѿ���������������
  CONST_ERROR_SERVICE_NOT_STARTED = $9998; // ����δ����������ֹͣ
  CONST_ERROR_ACCEPTEX = $9999; // �޷�Ͷ�ݽ������Ӳ���
  CONST_ERROR_EXCEPTION = $999A; // �ؼ��ڲ����������쳣
  CONST_ERROR_INVALID_INDEX = $999B; // ��Ч������

  CONST_ERROR_LISTEN_ERROR = $FFFD; // �������ִ���
  CONST_ERROR_ALLOC_MEMORY = $FFFE; // �����ڴ�ʧ��
  CONST_OTHER_ERROR = $FFFF; // ��������

  // windows��׼������������������
  { 13/������Ч��
    1345/ָ��������Ч����������Ⱥ������Բ����ݡ�
    1707/�����ַ��Ч��
    3678/���������ļ�ʱ����ԭ�ȼ�¼����������״̬û�и��ġ�
    5089/��������һ���������Գ�ͻ��δ���޸���Դ���ԡ�
    8255/һ�����������Ƿ���
    8311/�޸Ĳ����Ƿ�����������޸ĵ�ĳ�����档
    8423/���ڰ�ȫԭ�������޸ġ�
    9552/��Ч�� IP ��ַ��
    9553/��Ч�����ԡ�
    10022/�ṩ��һ����Ч�Ĳ����� }
  WERROR_INVALID_IP = 9552; // windows��׼������Ч��IP��ַ
  WERROR_CANNOT_MODIFY = 8423; // ���ܱ��޸�
  WERROR_INVALID_VALUE = 13; // ��Ч��ֵ

  // ���¶������֪ͨ���ͳ���
  NOTIFYKIND_CONNECT = 0; // ����֪ͨ
  NOTIFYKIND_DISCONNECT = 1; // ����֪ͨ
  NOTIFYKIND_KEEPCONNECTION = 2; // ��������֪ͨ
  NOTIFYKIND_ERROR = 255; // ����֪ͨ

const
  C_ERROR_IOPC_CreateSock_1 = '��������SOCKETʧ��! (%S)';
  C_ERROR_IOPC_BindnSock_1 = '�󶨼���SOCKETʧ��! (%S)';
  C_ERROR_IOPC_ListenSock_1 = '��������ʧ��! (%S)';
  C_ERROR_IOPC_AcceptEvent_1 = '���������¼�ʧ! (%S)';
  C_ERROR_IOPC_AcceptSelect_1 = '��������¼�ʧ��! (%S)';
  C_ERROR_IOPC_StartServer = '�����Ѿ���������������!';
  C_ERROR_IOPC_StartServerParam = 'socket�� > ������ ��Ч����ֵ!';
  C_ERROR_IOPC_CreateTimerQueue = 'CreateTimerQueueʧ��!';
  C_ERROR_IOPC_StopServer = '����δ����������ֹͣ';
  C_ERROR_IOPC_StartServerListenComp_1 = '�󶨼����׽��ֵ���ɶ˿�ʧ�ܶ����·�������ʧ��!(%s)';

function GetErrorMsg(ErrNo: dword; NeedErrorCode: boolean): string;

implementation

function GetErrorMsg(ErrNo: dword; NeedErrorCode: boolean): string;
begin
  case ErrNo of
    CONST_SUCCESS_NO:
      result := '�ɹ�'; // 0000
    // ���ӳ���
    CONST_ERROR_CONNECT:
      result := '���ӷ�����ʧ��'; // $1000
    CONST_ERROR_INVALID_SERVERIP:
      result := '��Ч������IP��ַ'; // $1001
    CONST_ERROR_INVALID_SERVERPORT:
      result := '��Ч�˿�'; // $1002
    CONST_ERROR_CHANGE_SETTING_ON_RUNNING: // $1003
      result := '������ʱ������ı�����';
    CONST_ERROR_CREATE_SOCKET:
      result := '�����׽���ʧ��'; // $1004
    CONST_ERROR_SET_RECVTIMEOUT:
      result := '�����׽��ֽ��ճ�ʱʧ��'; // $1005
    CONST_ERROR_HAVE_CONNECTED: // $1006
      result := '�����ӻ��Ѿ���������,�����ٴ�����';
    CONST_ERROR_NOT_CONNECTED:
      result := 'δ����,���ܽ��д˲���'; // $1007
    CONST_ERROR_NO_NET_OPTION:
      result := 'û�����÷�������Ϣ'; // $1008
    CONST_ERROR_TERMINATED:
      result := '�������ж�'; // $1009
    CONST_ERROR_IN_OPERATION: // $100A
      result := '��ǰ���ڽ��ж�ռ����,�޷�����������';
    CONST_ERROR_CANCEL_OPERATION: // $100B
      result := '����������';
    CONST_ERROR_IDLE_TIMEOUT: // $100C
      result := '�ѳ���ϵͳ�ȴ�ʱ��';
    CONST_ERROR_NETWORK_DAMAGE:
      result := '�����������,��������!'; // $100D
    CONST_ERROR_PROXY_NEGOTIATE: // $100E
      result := '����ܾ��������';
    CONST_ERROR_PROXY_DENY:
      result := '���ӱ�����ܾ�'; // $100F
    CONST_ERROR_PROXY_AUTHENTICATE:
      result := 'û��ͨ��������֤,��ȷ���û�������'; // $1010
    CONST_ERROR_HOST_POWEROFF:
      result := '�������Ѿ��ػ�'; // $1011
    CONST_ERROR_HOST_NOT_FOUND:
      result := '������������������Ŀ�����粻ͨ'; // $1012
    CONST_ERROR_HOST_DENY:
      result := '���ӱ��Է��ܾ�,�����Ƿ���û������'; // $1013
    // ���ͽ��մ�����
    CONST_ERROR_SEND_FAIL:
      result := '���ͱ���ʧ��(�Է���������ֹ����)'; // $2000
    CONST_ERROR_RECV_FAIL:
      result := 'δ��ȫ�㹻����(�Է���������ֹ����)'; // $2001
    CONST_ERROR_RECV_NO_ENOUGH:
      result := 'δ�չ�ָ���ֽ�'; // $2002
    CONST_ERROR_REMOTE_DISCONNECT:
      result := 'Զ�����������������ӻ��߷���û������'; // $2003
    CONST_ERROR_CONTROL_BANDWIDTH:
      result := '�޷����Ʒ��ʹ���'; // $2004
    CONST_ERROR_LOCAL_DISCONNECT:
      result := 'ȡ����Է�������,ԭ���ǵ��Է����粻ͨ���߿���ʱ�䳬������'; // $2005
    CONST_ERROR_SEND_AGAIN:
      result := '�������ϴ�����δ����ǰ�ٴ�����'; // $2006
    CONST_ERROR_SEND_REQUEST:
      result := '��������ʧ��'; // $2007
    CONST_ERROR_RECV_AUTO:
      result := '���ս��Զ�����'; // $2008
    CONST_ERROR_COMMAND_DISCONNECT:
      result := 'HTTP����ͨ�������Ѿ��Ͽ�,����������'; // $2009
    CONST_ERROR_CREATE_HTTP_TUNNEL:
      result := '��HTTP���û�гɹ�'; // $200A
    // ������س���
    CONST_ERROR_INVALID_REQUEST:
      result := '��������ݸ�ʽ�����޷�����'; // $3000
    CONST_ERROR_INVALID_ACTION:
      result := '��֧�ִ������'; // $3001
    CONST_ERROR_INVALID_PKG_LEN:
      result := '�Ƿ����ĳ���'; // $3002
    CONST_ERROR_INVALID_PKG_FLAG:
      result := '�Ƿ����ı�־'; // $3003
    CONST_ERROR_INVALID_HANDLE_RESULT:
      result := '�Ƿ�����������'; // $3004
    CONST_ERROR_PKG_TOOLONG:
      result := '���������ݳ���'; // $3005��Դ��ڴ��������
    CONST_ERROR_PKG_NIL:
      result := '����������Ϊ��'; // $3006
    CONST_ERROR_PKG_NO_ENOUGH:
      result := '�������ֽ�������ʵ���ֽ�����С��1'; // $3007
    CONST_ERROR_PARAM_ISNULL:
      result := '�������Ϊ��'; // $3008
    CONST_ERROR_INVALID_PARAM_VALUE:
      result := '��Ч����ֵ'; // $3009
    CONST_ERROR_FAIL_GEN_PKG_HEAD:
      result := '���ݳ��Ȳ�����Լ������'; // $300A
    CONST_ERROR_FAIL_CHECK_CRC:
      result := 'CRCУ��ʧ��'; // $300B
    CONST_ERROR_KEEPCONNECT:
      result := '��δ������Ч������Ҫ�󱣳�����'; // $200C
    // �ļ�������
    CONST_ERROR_CREATEFILE:
      result := '�����ļ�ʧ��'; // $4000
    CONST_ERROR_OPENFILE:
      result := '���ļ�ʧ��'; // $4001
    CONST_ERROR_READFILE:
      result := '���ļ�ʧ��'; // $4002
    CONST_ERROR_WRITEFILE:
      result := 'д�ļ�ʧ��'; // $4003
    CONST_ERROR_INVALID_FILENAME:
      result := '��Ч�ļ���'; // $4004
    CONST_ERROR_NO_SUCH_FILE:
      result := 'δ�ҵ�ָ���ļ�'; // $4005
    CONST_ERROR_NO_SUCH_DIR:
      result := '��Ч��Ŀ¼'; // $4006
    CONST_ERROR_GETFILESIZE:
      result := '��ȡ�ļ���Сʧ��'; // $4007
    CONST_ERROR_FILEOFFSET:
      result := '�ļ�ƫ����Ч'; // $4008
    CONST_ERROR_FILELEN:
      result := 'ָ������Ч�ĳ���'; // $4009
    CONST_ERROR_NOT_RECVFILE:
      result := '�ļ�����ȴδ���������ļ�'; // $400A
    CONST_ERROR_NO_FILE_ARRIVE:
      result := 'û���ļ�����,�������������ļ�'; // $400B
    CONST_ERROR_FILE_ARRIVE:
      result := '�ļ�������Ҫ�����ļ�����'; // $400C
    // ���в�������
    CONST_ERROR_QUEUE_BLANK:
      result := '���п�'; // $5000
    CONST_ERROR_QUEUE_TOOLONG:
      result := '���г��ȳ����������'; // $5001
    CONST_ERROR_QUEUE_IN:
      result := '�������ʧ��'; // $5002
    CONST_ERROR_QUEUE_OUT:
      result := '������ʧ��'; // $5003
    // OS����
    CONST_ERROR_TOOMANY_OVERLAP:
      result := '�ص�����̫��'; // $6000
    CONST_ERROR_CANCELED_BY_OS:
      result := '��������̨ȡ��'; // $6001
    CONST_ERROR_OTHER_OVERLAP_ERROR:
      result := 'ϵͳ����ǰI/O����ʧ��'; // $6002
    CONST_ERROR_OVERLAP_PARAM:
      result := '�ص������������޷��ص�'; // $6003
    CONST_ERROR_BIND_TO_COMPPORT:
      result := '�󶨵���ɶ˿ڳ���'; // $6004
    CONST_ERROR_ACCEPT_EVENT:
      result := '�޷�����Ͷ�ݽ������Ӳ���'; // $6005
    CONST_ERROR_RECV_EVENT: // $6006
      result := '�����׽��ֵ��첽״̬û�гɹ�';
    CONST_ERROR_SEND_EVENT: // $6007
      result := '���������¼�ʧ��';
    CONST_SEND_ZERO:
      result := '���ͳ���Ϊ0���ط���'; // $6008
    // �ؼ��ڲ�����
    CONST_ERROR_FAIL_CTRL_TIMEOUT:
      result := '�޷����Ƴ�ʱ'; // $998E
    CONST_ERROR_WAIT:
      result := 'ϵͳ����,�޷���ز�������'; // $998F
    CONST_ERROR_GET_FREE_SOCKET:
      result := '�޷������׽���'; // $9990
    CONST_ERROR_CREATE_COMPPORT:
      result := '������ɶ˿�ʧ��'; // $9991
    CONST_ERROR_CREATE_LISTENSOCKET:
      result := '���������׽���ʧ��'; // $9992
    CONST_ERROR_BIND_LISTEN:
      result := '�޷��󶨼����׽��ֵ�����IP'; // $9993
    CONST_ERROR_LISTENING:
      result := '�����׽����޷�����'; // $9994
    CONST_ERROR_BIND_LISTEN_TO_COMPPORT:
      result := '���׽��ֵ���ɶ˿�ʧ��'; // $9995
    CONST_ERROR_CREATE_LOGDIR:
      result := '��־Ŀ¼����ʧ��'; // $9996
    CONST_ERROR_SERVICE_STARTED:
      result := '�����Ѿ���������������'; // $9997
    CONST_ERROR_SERVICE_NOT_STARTED:
      result := '����δ����������ֹͣ'; // $9998
    CONST_ERROR_ACCEPTEX:
      result := '�޷�Ͷ�ݽ������Ӳ���'; // $9999
    CONST_ERROR_EXCEPTION:
      result := 'δ֪�����´���û�����,������������!'; // $999A
    CONST_ERROR_INVALID_INDEX:
      result := '��Ч������'; // $999B
    CONST_ERROR_LISTEN_ERROR:
      result := '�������ִ���'; // $FFFD
    CONST_OTHER_ERROR:
      result := '��������' // $FFFF
  else
    result := 'δ֪����';
  end; // end case
end;

end.
