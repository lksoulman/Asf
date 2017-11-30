unit EDCrypt;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Encrypt and Decrypt Interface
// Author£º      lksoulman
// Date£º        2017-8-5
// Comments£º    
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Encrypt and Decrypt Interface
  IEDCrypt = Interface(IInterface)
    ['{6E9AC6CB-8276-4E98-A149-1F2E33731227}']
    { MD5 }

    // String MD5
    function StringMD5(AString: AnsiString): AnsiString;

    { AES }

    // Encrypt AES
    function EncryptAES(APlain: AnsiString): AnsiString;
    // Decrypt AES
    function DecryptAES(ACiper: AnsiString): AnsiString;
    // Encrypt AES And EncodeStr HEX
    function EncryptAESEncodeHEX(APlain: AnsiString): AnsiString;
    // DecodeStr HEX and Decrypt AES
    function DecodeHEXDecryptAES(ACiper: AnsiString): AnsiString;
    // Encrypt AES And EncodeStr Base64
    function EncryptAESEncodeBase64(APlain: AnsiString): AnsiString;
    // DecodeStr Base64 And Decrypt AES
    function DecodeBase64DecryptAES(ACiper: AnsiString): AnsiString;

    { RSA }

    // Encrypt AES
    function EncryptRSA(APlain: AnsiString): AnsiString;
    // Decrypt AES
    function DecryptRSA(ACiper: AnsiString): AnsiString;
    // Encrypt RSA And EncodeStr HEX
    function EncryptRSAEncodeHEX(APlain: AnsiString): AnsiString;
    // DecodeStr HEX And Decrypt RSA
    function DecodeHEXDecryptRSA(ACiper: AnsiString): AnsiString;
    // Encrypt RSA And EncodeStr Base64
    function EncryptRSAEncodeBase64(APlain: AnsiString): AnsiString;
    // DecodeStr Base64 And Decrypt RSA
    function DecodeBase64DecryptRSA(ACiper: AnsiString): AnsiString;
  end;

implementation

end.
