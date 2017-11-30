unit Protocol;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Protocol
// Author��      lksoulman
// Date��        2017-9-8
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  // Э���־
  PROTOCOL_SIGN          = $01;

  // Э��汾
  PROTOCOL_VERSION       = $01;             // Э��汾

  // У���־
  PROTOCOL_CRCSUM        = $00;             // ����У��

  // Э�����
  PROTOCOL_ENCRYPT_NO    = $00;             // Э�鲻����
  PROTOCOL_ENCRYPT_AES   = $01;             // Э���� AES ����

  // Э��ѹ��
  PROTOCOL_COMPRESS_NO   = $00;             // Э�鲻ѹ��
  PROTOCOL_COMPRESS_ZIP  = $01;             // Э���� ZIP ѹ��
  PROTOCOL_COMPRESS_GZIP = $02;             // Э���� GZIP ѹ��

  // ������
  ErrorCode_OK           = 0;               // �޴���
  ErrorCode_NoService    = 1;               // �޷���

  ErrorMsg_Ok            = '';              //
  ErrorMsg_NoService     = 'û�д˷���';    //

type

  // Request Header Data
  TReqHead = packed record
    FSig: Int16;                      // Sign
    FVers: Byte;                      // Version
    FCrcSum: Int32;                   // Crc Check Sum
    FDataLen: Int32;                  // Data Len
    FEncrypt: Byte;                   // Encrypt Flag
    FCompress: Byte;                  // Compress Flag
    FDecryptLen: Int32;               // Decrypt Data Len
    FOriginDataLen: Int32;            // Origin Data Len
    FType: Byte;                      // Type
    FKey: Int64;                      // Extend Key
    FExtKey: Int64;                   // Error Code
  end;

  // Request Header Data Pointer
  PReqHead = ^TReqHead;

  // Response Header Data
  TRepHead = packed record
    FSig: Int16;                      // Sign
    FVers: Byte;                      // Version
    FCrcSum: Int32;                   // Crc Check Sum
    FDataLen: Int32;                  // Data Len
    FEncrypt: Byte;                   // Encrypt Flag
    FCompress: Byte;                  // Compress Flag
    FDecryptLen: Int32;               // Decrypt Data Len
    FOriginDataLen: Int32;            // Origin Data Len
    FType: Byte;                      // Type
    FKey: Int64;                      // Key
    FExtKey: Int64;                   // Extend Key
    FErrorCode: Int16;                // Error Code
  end;

  // Response Header Data Pointer
  PRepHead = ^TRepHead;

implementation

end.
