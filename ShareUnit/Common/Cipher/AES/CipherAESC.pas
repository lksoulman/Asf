unit CipherAES;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Cipher AES
// Author��      lksoulman
// Date��        2017-8-2
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  AES,
  ElAES,
  Windows,
  Classes,
  SysUtils,
  AESEncript;

type

  // Cipher AES
  TCipherAES = class
  private
    // Key Buf
    FKey128Buf: TAESBuffer;
    //

  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���� Key 128
    procedure LoadKey128(AKey: AnsiString; ABuffer: TAESBuffer);
    // ���ܷ���
    function Encrypt128(APlain: AnsiString): AnsiString;
    // ���ܷ���
    function Decrypt128(ACiper: AnsiString): AnsiString;
  end;

implementation

{ TCipherAES }

constructor TCipherAES.Create;
begin
  inherited;

end;

destructor TCipherAES.Destroy;
begin

  inherited;
end;

procedure TCipherAES.LoadKey128(AKey: AnsiString);
begin
  CopyMemory(@FKey128Buf[0], @AKey[0], Length(AKey));
end;

function TCipherAES.Encrypt128(APlain: AnsiString): AnsiString;
begin
  Result := AES.EncryptString128B64(APlain, FKey128B, FKey128Buf);
end;

function TCipherAES.Decrypt128(ACiper: AnsiString): AnsiString;
begin
  Result := AESEncript.DecryptString128B64(ACiper, FKey128B, FKey128Buf);
end;

end.
