unit HS_ASPacket;

interface

uses Windows;

type
///����������ӿ�(һ�������ж���칹�����
{*ִ������:
 *
 * 0��׼���� SetBuffer(),�������������ɵ������ṩ,�������BeginPack()֮ǰ׼��;
 * 1����ʼ:  BeginPack(),�������λ;
 *
 * 2����һ������������
 *
 *(a)����ֶ����б���AddField()
 *
 *(b)���ս������ά��˳�����ֶΣ�������¼������ݣ�AddValue()
 *
 * 3�����õ�һ��������ķ�����(��ѡ�����������Ϊ0��������) SetFirstRetCode()
 *
 * 4������һ�������(��ѡ) NewDataSet()���˴�ͬʱ�����˸ý�����ķ����룻
 *
 * 5���ο���2��ʵ��һ������������
 *
 * 6��������EndPack(),�ظ����ûᵼ�¼���ս����;
 *
 * 7��ȡ������(����������������С�����ݳ���)
 *    ������Ҳ����ֱ�ӽ��UnPack()���ؽ���ӿ�
 *
 *ʹ��ע������:IPacker��ʹ�õ��ڴ滺���������ɵ����߿��ƣ�
 *             ����������ķ����룬ֻ���ڰ���ʽ�汾0x20����ʱ��Ч��
 }
 IUnPacker = interface(IUnknown)

 end;
///��׼�ӿڲ�ѯ,����com��׼

  IPacker = interface(IUnknown)
    ///�������ʼ��(ʹ�õ����ߵĻ�����)
    {* ��һ��ʹ�ô����ʱ������ʹ�ñ��������úû�����(���ݳ��ȱ���ΪiDataLen)
    *@param  char * pBuf  ��������ַ
    *@param  int iBufSize  �������ռ�
    *@param  int iDataLen  �������ݳ��ȣ��������ݼ�����������֮��ֻ��V1.0��ʽ�İ���Ч��
    }
    procedure SetBuffer(pBuf: Pointer; iBufSize: integer; iDataLen: integer ); stdcall;

    ///��λ�����¿�ʼ����һ����(�ֶ������¼����Ϊ0��0��)
    {*
    * ���ܣ���ʼ������Ѱ���������(�ظ�ʹ�����еĻ������ռ�)
    *@return ��
    }
    procedure BeginPack(); stdcall;

    ///��ʼ��һ�������
    {*�ڴ򵥽�����İ�ʱ�����Բ����ñ�����,��ȡĬ��ֵ
    *@param const char *szDatasetName 0x20������Ҫָ�����������
    *@param int iReturnCode           0x20������ҪΪÿ�������ָ������ֵ
    }
    function NewDataset(szDatasetName: PAnsiChar; iReturnCode: integer): integer; stdcall;

    {*
    * ���ܣ��������ֶ�
    *
    *��ִ�д���Ҫ��:�� NewDataset()��Reset(),SetBuffer()֮��,����ֶΰ�˳�����;
    *
    *@param szFieldName���ֶ���
    *@param cFieldType ���ֶ�����:I������F��������C�ַ���S�ַ�����R�������������
    *@param iFieldWidth ���ֶο�ȣ���ռ����ֽ�����
    *@param iFieldScale ���ֶξ���,��cFieldType='F'ʱ��С��λ��(ȱʡΪ4λС��)
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddField(szFieldName: PAnsiChar; cFieldType: AnsiChar; iFieldWidth: integer; iFieldScale: integer): integer; stdcall;

    {*
    * ���ܣ��������ַ�������
    * ��ִ�д���Ҫ��:�����������ֶ�������֮��,����ֶΰ�˳�����;
    *@param       szValue���ַ�������
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddValue(szValue: PAnsiChar): integer; stdcall; overload;

    {*
    * ���ܣ���������������
    *@param       iValue����������
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddValue(iValue: integer): integer; stdcall; overload;

    {*
    * ���ܣ������Ӹ�������
    *@param       fValue����������
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddValue( fValue: double): integer; stdcall; overload;

    {*
    * ���ܣ�������һ���ַ�
    *@param		 cValue���ַ�
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddValue(cValue: AnsiChar): integer; stdcall; overload;

    {*
    * ���ܣ�������һ�������
    *@param	void * lpBuff ������
    *@param	int iLen  ���ݳ���
    *@return ������ʾʧ�ܣ�����ΪĿǰ���ĳ���
    }
    function AddValue(lpBuff: Pointer; iLen: integer): integer; stdcall; overload;

    ///�������
    procedure EndPack(); stdcall;

    {*
    * ���ܣ�ȡ������ָ��
    *@return ������ָ��
    }
    procedure PackBuf(); stdcall;

    {*
    * ���ܣ�ȡ����������
    *@return ����������
    }
    function PackLen(): integer; stdcall;

    {*
    * ���ܣ�ȡ��������������С
    *@return ��������������С
    }
    function PackBufSize(): integer; stdcall;

    {*
    * ���ܣ�ȡ�����ʽ�汾
    *@return �汾
    }
    function getVersion(): integer; stdcall;

    ///���ý�����ķ�����(0x20������Ҫ��)������������Ҫ����
    {*������ȡȱʡֵ0�������ã�������ã��������EndPack()֮ǰ����
    * ���ܣ�ȡ�����ʽ�汾
    *@return �汾
    }
    procedure SetReturnCode(dwRetCode: Cardinal); stdcall;

    {*
    * ���ܣ�ֱ�ӷ��ص�ǰ�������Ľ���ӿ�,������EndPack()֮����ܵ���,�ڴ�����ͷ�ʱ��Ӧ�Ľ����ʵ��Ҳ�ͷ�
    *
    *@return ������ӿڣ��˽���ӿڲ��ܵ���destroy()���ͷ�
    }
    function UnPack(): IUnPacker; stdcall;

  end;

   PAppContext = ^IAppContext;
  ///����������ӿ�
  IPackService = interface(IUnknown)
    ///����ҵ�����ʽ�汾
    {����ҵ������ַ��ж�ҵ�����ʽ�汾,ҵ����汾ʶ�����

    V1���ײ��ŵ����ַ����͵����������Ե�һ���ֽ�>=0x30;

    V2���һ���ֽڷŵ��ǰ汾�ţ�ĿǰֵΪ0x20�������Ը���ʱ��ֵ�������0x2F

    @param void * lpBuffer  ҵ�������(������ָ��Ϸ�ҵ��������ֽ�)
    @return int  ҵ�����ʽ�汾(1: V1��,0x20~0x2F V2��汾��)
    }
    function GetVersion(const lpBuffer: Pointer): integer; stdcall;// FUNCTION_CALL_MODE GetVersion(const void * lpBuffer) = 0;

    ///ȡһ��ҵ��������,��ô��������ͨ��FreePacker()�ͷ�;
    {
    *@param int iVersion ҵ�����ʽ�汾(ȡֵ:1 �ִ���,����ֵ 0x20��)
    *@return IPacker * ������ӿ�ָ��
    }
    function GetPacker(iVersion: integer): integer; stdcall;
    ///�ͷŴ����
    {
    *@param IPacker * Ҫ�ͷŵĴ�����ӿ�ָ��
    }
    procedure FreePacker(lpPacker: integer) ; stdcall;

    ///ȡһ��ҵ��������,��ý��������ͨ��FreePacker()�ͷ�;
    {����GetVersion
    *@param void * lpBuffer Ҫ��������ݣ�����ARͨ�Ű�ͷ��
    *@param unsigned int iLen ���ݳ���
    *@return IUnPacker * ����������ӿ�ָ��
    }
    function  GetUnPacker(lpBuffer: Pointer;  Len: Cardinal): IUnPacker; stdcall;

    ///�ͷŽ����
    procedure FreeUnPacker(lpUnPacker: IUnPacker); stdcall;

  end;

  ///Ӧ�������Ľӿ�(ͨ�����ӿڿ��Ի�ȡ��ǰӦ�õ��ڲ�����ӿ���ȫ������)
  {*����������ṩ��̬���ع���ȫ�����ڲ�����ӿڵĻ���(���������
  *
  *���������ڲ�ģ������һ���ڳ�ʼ��ʱ�յ�Ӧ�ÿ�ܴ���ı��ӿ�ָ��
  *
  *�Ӷ�ͨ�����ӿڼ̳е�IKnown�ӿ��µ�QueryInterface��������ID��ȡ�����������ӿڻ��ڲ�����ӿھ����
  *
  *Ҳ����ͨ�����ӿڣ���ȡӦ�ü�ȫ�����ݣ�
  *
  *�����������ʵ�ֱ��ӿ�ʱ����̬���غͳ�ʼ���Ļ�������ȫ�����ݵȣ�
  }
   IAppContext = interface(IUnknown)
	///ȡ���ӿڰ汾
	{*����������Ϊ���ӿڵĵ�һ������,���ӿڰ汾��һ�»ᵼ�²���Ԥ�ڵĽ�����Ǽ����޸�Ҫ�����±������������
	 *@return int ���ӿڰ汾yyyymmdd
	 }
    function getVersion(): integer; stdcall;

	///ȡAR/AS����
	{*
	 *@return const char * ����AR/AS��������
	 }
    function getName(): PAnsiChar; stdcall;

	///ȡ���
	{*
	 *@return int ����AR/AS�������ڱ��
	 }
    function getID(): integer; stdcall;

	///ȡӦ������ʱ�ĳ�ʼ��ѡ��,��ѡ����ȡ����ѡ��ֵ
	{*
	 *@param const char * szParamName ��������������ѡ����Ϊ��׼�����ַ���
	 *@param const char * szDefaultValue    ���ָ������û��ͨ�������л򻷾������ṩֵ���򷵻�ȱʡֵ
	 *@return const char * ����ֵ
	 }
    function getOption(szParamName: PAnsiChar; szDefaultValue: PAnsiChar): PAnsiChar; stdcall;

    ///����ȫ������ID������ָ��ȫ������ָ��
    {*
     *@param int iGlbDataID  Ӧ������ID
     *@return void * �ɹ�������Ӧ��������ָ�룬������NULL
     }
    procedure getGlbData(iGlbDataID: integer );

	///����ȫ������ID������ָ��ȫ������ָ��
    {*
     *@param int iGlbDataID  ȫ������ID
     *@param const void * pData      ����ָ��(����ΪNULL)
     *@return int �ɹ�����I_OK��������I_NONE
     }
    function setGlbData(iGlbDataID: integer; pData: Pointer): integer; stdcall;

	///ȡ���õİ�ȫ�ȼ�
	{*
	 *@return int ��ȫ�ȼ�(0����У�����ǩ����1 У�����ǩ��)
	 }
    function getSafeLevel(): integer; stdcall;

  end;

///�����ʼ��xxxxInit()
{*
 *@return int �汾�� yyyymmdd��ʽ
}
TPackServiceInit = function (P: IAppContext): integer; stdcall;

///ȡ����ӿھ�� getxxxxInstance()
{*
 *@return void * ����������
}
TPackSvrInstanceProc = function(p: IAppContext): integer; stdcall;


///����ͳһ��AS�������������ѯ�ӿ� getxxxInfo()
{*���������������̬����ʱ��ͨ�����ӿڻ��Ի�ȡ������Ϣ(����xxxxInit(),getxxxxInterface()����ָ��)
 *@param void ** ppv    �������������Ϣ(�������)��
 *@return ����0��ʾ�鵽��Ҫ�Ľӿڣ����򷵻ظ���
}
//function getPackServiceInfo(iIndex: integer; ppv : tagBaseServiceInfo *  ): integer; stdcall;

implementation

end.
