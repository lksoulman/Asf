unit Verify;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

type

  IVerify = Interface(IInterface)
    ['{BB2A6946-62F0-4A16-BF97-BF93A738A0F2}']
    // ���ò�����֤�����
    procedure SetVerifyCodeCount(ACount: Integer); safeCall;
    // ��ȡ��֤���Ӧ����
    function GetStreamByVerifyCode(AVerifyCode: Integer): TStream; safeCall;
    // ��ȡ��֤���Ӧ�ַ���
    function GetStringByVerifyCode(AVerifyCode: Integer): WideString; safeCall;
    // ���������
    procedure GenerateVerifyCodes(var AVerifyCodes: TIntegerDynArray); safeCall;
  end;

implementation

end.
