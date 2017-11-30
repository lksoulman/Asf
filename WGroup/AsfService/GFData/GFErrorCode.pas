unit GFErrorCode;

interface

const

  GFECODE_UNKNOWN               = -1;       // UnKnown
  GFECODE_SUCCESS               = 0;        // Success
  GFECODE_WAIT_TIMEOUT          = 1;        // Wait Timeout
  GFECODE_WAIT_FAILED           = 2;        // Wait Failed


  GFECODE_FUNCID_NULL           = 100;      // Indicator FundId Is NULL
  GFECODE_COMPRESS              = 101;      // Compress
  GFECODE_UNCOMPRESS            = 102;      // UnpCompress
  GFECODE_ENCRYPT               = 103;      // Encrypt
  GFECODE_DECRYPT               = 104;      // Decrypt
  GFECODE_URL_NULL              = 105;      // Url Is NULL
  GFECODE_POST                  = 106;      // POST
  GFECODE_RETURN_NULL           = 107;      // Return NULL

  GFECODE_INIT_NOLOGIN          = 200;      // Init No Login
  GFECODE_NEED_RELOGIN          = 201;      // Need Re Login

  GFECODE_INDICATOR_JSONFORMAT            = 9001;    // JSON��ʽ����
  GFECODE_INDICATOR_NOTEXISTS             = 9002;    // ָ�겻����
  GFECODE_INDICATOR_PARAMSCHECK           = 9003;    // ����У��ʧ��
  GFECODE_INDICATOR_PARAMSCOUNT           = 9004;    // ����������һ��
  GFECODE_INDICATOR_PARAMSTYPE            = 9005;    // ������������
  GFECODE_INDICATOR_EXECEXCEPT            = 9006;    // ָ��ִ���쳣
  GFECODE_INDICATOR_RETURNEXCEPT          = 9007;    // ָ�귵�ؽ���쳣
  GFECODE_SESSIONID_USEREXCEPT            = 9011;    // �û��쳣
  GFECODE_SESSIONID_PASSWDEXCEPT          = 9012;    // �ʺ�����У��ʧ��
  GFECODE_SESSIONID_MACCODEFAIL           = 9013;    // ������У��ʧ��
  GFECODE_SESSIONID_TIMEOUT               = 9014;    // �Ự��ʱ
  GFECODE_SESSIONID_LOGINELSEWHERE        = 9015;    // �ʺ��Ѿ��ڱ𴦵�¼
  GFECODE_SESSIONID_NOEXISTS              = 9016;    // ������ SID
  GFECODE_SESSIONID_NOLOGIN               = 9017;    // δ��¼
  GFECODE_SESSIONID_LOGINFAIL             = 9018;    // ��¼ʧ��
  GFECODE_BIND_INVAILDACCOUNT             = 9031;    // ��Ч�İ󶨰��˺�
  GFECODE_BIND_ACCOUNTBINDED              = 9032;    // �˺��ѱ���
  GFECODE_BIND_BINDEDEXCEPT               = 9033;    // �˺Ű��쳣
  GFECODE_SERVICESYS_EXCEPTION            = 9999;    // �����ϵͳ�쳣


implementation

end.
