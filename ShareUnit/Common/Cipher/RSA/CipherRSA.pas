unit CipherRSA;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Math,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  IdCTypes,
  IdGlobal,
  EncdDecd,
  NetEncoding,
  IdSSLOpenSSLHeaders;//IdSSLOpenSSLHeadersEx;

const
  RSA_KEYBITS = 2048;

  fn_RSA_sign_ex = 'RSA_sign';
  fn_RSA_verify_ex = 'RSA_verify';

  RSA_DEFAULT_FILEPATH = 'RSA\RSA';
  PUBLIC_KEY_FILENAME_SUFFIX = '.publickey';
  PRIVATE_KEY_FILENAME_SUFFIX = '.privatekey';

type

  TKey = class
  private
  protected
    // �洢 RSA ��Կ��Ϣ
    FRSA: PRSA;
    // Ĭ���ļ���
    FDefaultFileName: string;

    // ��ȡ RSA
    function GetRSA: PRSA;
    // ���� RSA
    procedure SetRSA(ARSA: PRSA);
    // �ͷ� key
    procedure ClearRSA(var ARSA: PRSA);
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���ֽ���������� Key
    procedure LoadKey(ABytes: TBytes); overload; virtual;
    // �����м��� Key
    procedure LoadKey(AStream: TStream); overload; virtual;
    // ���ļ����� Key
    procedure LoadKey(AFileName: string); overload; virtual;
    // �洢 Key ���ֽ�����
    procedure KeyToBytes(var ABytes: TBytes); virtual; abstract;
    // �洢 Key ����
    procedure KeyToStream(var AStream: TStream);
    // �洢 key ���ļ�
    procedure KeyToFileName(AKeyFileName: string);
    // �洢 Base64 ���ļ�
    procedure Base64KeyToFileName(AKeyFileName: string);
  end;

  TPublicKey = class(TKey)
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���ֽ���������� Key
    procedure LoadKey(ABytes: TBytes); override;
    // �洢 Key ���ֽ�����
    procedure KeyToBytes(var ABytes: TBytes); override;

    property PublicRSA: PRSA read GetRSA write SetRSA;
  end;

  TPrivateKey = class(TKey)
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���ֽ���������� Key
    procedure LoadKey(ABytes: TBytes); override;
    // �洢 Key ���ֽ�����
    procedure KeyToBytes(var ABytes: TBytes); override;

    property PrivateRSA: PRSA read GetRSA write SetRSA;
  end;

  TCipherRSA = class
  private
    FKeyBits: Integer;
    // �ǲ����Ѿ���ʼ��
    FIsInitRSA: boolean;
    // ��Կ
    FPublicKey: TPublicKey;
    // ˽Կ
    FPrivateKey: TPrivateKey;
  protected
    // ��ʼ��
    procedure InitRSA;
    // �ͷ���Դ
    procedure UnInitRSA;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    //
    procedure LoadKeys(AFileName: string = '');
    //
    procedure PublicKeyToBytes(var ABytes: TBytes);
    //
    procedure PrivateKeyToBytes(var ABytes: TBytes);
    // ���ֽ���������� Key
    procedure LoadPublicKey(ABytes: TBytes); overload;
    // ���ֽ���������� Key
    procedure LoadPrivateKey(ABytes: TBytes); overload;
    // ���ļ����ع�Կ
    procedure LoadPublicKey(AFileName: string); overload;
    // ���ļ�����˽Կ
    procedure LoadPrivateKey(AFileName: string); overload;
    // ������Կ��
    procedure GenerateKeyPair(AKeyBits: Integer = RSA_KEYBITS);
    // ����
    procedure Encrypt(APlain: TBytes; var ACiper: TBytes);
    // ����
    procedure Decrypt(ACiper: TBytes; var APlain: TBytes);
    // ǩ��
    function Sign(AData: TBytes; var ASigData: TBytes): boolean;
    // ��֤
    function Verify(AData: TBytes; var ASigData: TBytes): boolean;
  end;

implementation

var
  RSA_sign_ex: function(_type : TIdC_INT; const m : PIdAnsiChar; m_length : TIdC_UINT;
      sigret : PIdAnsiChar; siglen : PIdC_UINT; const rsa : PRSA) : TIdC_INT; cdecl = nil;
  RSA_verify_ex : function(dtype : TIdC_INT; const m : PIdAnsiChar; m_length : PIdC_UINT;
      sigbuf : PIdAnsiChar; siglen : PIdC_UINT; const rsa :PRSA) : TIdC_INT; cdecl = nil;

{ TKey }

constructor TKey.Create;
begin
  inherited;
  FRSA := nil;
end;

destructor TKey.Destroy;
begin
  ClearRSA(FRSA);
  inherited;
end;

function TKey.GetRSA: PRSA;
begin
  Result := FRSA;
end;

procedure TKey.SetRSA(ARSA: PRSA);
begin
  ClearRSA(FRSA);
  FRSA := ARSA;
end;

procedure TKey.ClearRSA(var ARSA: PRSA);
begin
  if ARSA <> nil then begin
    RSA_free(ARSA);
    ARSA := nil;
  end;
end;

procedure TKey.LoadKey(ABytes: TBytes);
begin

end;

procedure TKey.LoadKey(AStream: TStream);
var
  LBytes: TBytes;
  LKeyLen: Integer;
begin
  if AStream = nil then Exit;
  LKeyLen := AStream.Size - AStream.Position;
  if LKeyLen <= 0 then Exit;
  SetLength(LBytes, LKeyLen);
  AStream.Write(LBytes, LKeyLen);
  LoadKey(LBytes);
end;

procedure TKey.LoadKey(AFileName: string);
var
  LBytes: TBytes;
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    SetLength(LBytes, LFileStream.Size);
    ZeroMemory(@LBytes[0], LFileStream.Size);
    LFileStream.Read(LBytes, LFileStream.Size);
    LoadKey(LBytes);
  finally
    LFileStream.Free;
  end;
end;

procedure TKey.KeyToStream(var AStream: TStream);
var
  LBytes: TBytes;
  LKeyLen: Integer;
begin
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    AStream.Write(LBytes, LKeyLen);
    SetLength(LBytes, 0);
  end;
end;

procedure TKey.KeyToFileName(AKeyFileName: string);
var
  LBytes: TBytes;
  LKeyLen: Integer;
  LFilePath: string;
  LFileStream: TFileStream;
begin
  LFilePath := ExtractFilePath(AKeyFileName);
  if not FileExists(LFilePath) then begin
    ForceDirectories(LFilePath);
  end;
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    LFileStream := TFileStream.Create(AKeyFileName, fmCreate);
    try
      LFileStream.Position := 0;
      LFileStream.Write(LBytes, LKeyLen);
      SetLength(LBytes, 0);
    finally
      LFileStream.Free;
    end;
  end;
end;

procedure TKey.Base64KeyToFileName(AKeyFileName: string);
var
  LBytes: TBytes;
  LKeyLen: Integer;
  LFilePath: string;
  LMStream: TMemoryStream;
  LFileStream: TFileStream;
begin
  LFilePath := ExtractFilePath(AKeyFileName);
  if not FileExists(LFilePath) then begin
    ForceDirectories(LFilePath);
  end;
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    LMStream := TMemoryStream.Create;
    LFileStream := TFileStream.Create(AKeyFileName, fmCreate);
    try
      LMStream.Position := 0;
      LMStream.Write(LBytes, LKeyLen);
      LMStream.Position := 0;
      LFileStream.Position := 0;
      TNetEncoding.Base64.Encode(LMStream, LFileStream);
      SetLength(LBytes, 0);
    finally
      LFileStream.Free;
      LMStream.Free;
    end;
  end;
end;

{ TPublicKey }

constructor TPublicKey.Create;
begin
  inherited;

end;

destructor TPublicKey.Destroy;
begin

  inherited;
end;

procedure TPublicKey.LoadKey(ABytes: TBytes);
var
  ARSA: PRSA;
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  LKeyLen := Length(ABytes);
  if LKeyLen <= 0 then Exit;

  LBufAddr := Addr(ABytes[0]);
  ARSA := d2i_RSAPublicKey(nil, @LBufAddr, LKeyLen);
  if FRSA <> nil then begin
    ClearRSA(FRSA);
  end;
  FRSA := ARSA;
end;

procedure TPublicKey.KeyToBytes(var ABytes: TBytes);
var
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  SetLength(ABytes, 0);
  if FRSA = nil then Exit;

  LKeyLen := i2d_RSAPublicKey(FRSA, nil);
  SetLength(ABytes, LKeyLen);
  ZeroMemory(@ABytes[0], LKeyLen);
  LBufAddr := Addr(ABytes[0]);
  i2d_RSAPublicKey(FRSA, @LBufAddr);
end;

{ TPrivateKey }

constructor TPrivateKey.Create;
begin
  inherited;

end;

destructor TPrivateKey.Destroy;
begin

  inherited;
end;

procedure TPrivateKey.LoadKey(ABytes: TBytes);
var
  ARSA: PRSA;
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  LKeyLen := Length(ABytes);
  if LKeyLen <= 0 then  Exit;

  LBufAddr := Addr(ABytes[0]);
  ARSA := d2i_RSAPrivateKey(nil, @LBufAddr, LKeyLen);
  if FRSA <> nil then begin
    ClearRSA(FRSA);
  end;
  FRSA := ARSA;
end;

procedure TPrivateKey.KeyToBytes(var ABytes: TBytes);
var
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  SetLength(ABytes, 0);
  if FRSA = nil then Exit;

  LKeyLen := i2d_RSAPrivateKey(FRSA, nil);
  SetLength(ABytes, LKeyLen);
  ZeroMemory(@ABytes[0], LKeyLen);
  LBufAddr := Addr(ABytes[0]);
  i2d_RSAPrivateKey(FRSA, @LBufAddr);
end;

{ TCipherRSA }

constructor TCipherRSA.Create;
begin
  inherited;
  FKeyBits := RSA_KEYBITS;
  FPublicKey := TPublicKey.Create;
  FPrivateKey := TPrivateKey.Create;
  FIsInitRSA := False;
  InitRSA;
end;

destructor TCipherRSA.Destroy;
begin
  UnInitRSA;
  FPrivateKey.Free;
  FPublicKey.Free;
  inherited;
end;

procedure TCipherRSA.InitRSA;
const
  SSLCLIB_DLL_name = 'libeay32.dll';
var
  LhIdSSL: HMODULE;

  function LoadFunction(const FceName: {$IFDEF WINCE}TIdUnicodeString{$ELSE}string{$ENDIF}; const ACritical : Boolean = True): Pointer;
  begin
    LhIdSSL := SafeLoadLibrary(SSLCLIB_DLL_name);
    Result := {$IFDEF WINDOWS}Windows.{$ENDIF}GetProcAddress(LhIdSSL, {$IFDEF WINCE}PWideChar{$ELSE}PChar{$ENDIF}(FceName));
//    if (Result = nil) and ACritical then begin
//      FFailedLoadList.Add(FceName); {do not localize}
//    end;
  end;
begin
  try
    Load;
//    @RSA_sign_ex := LoadFunction(fn_RSA_sign_ex);
//    @RSA_verify_ex := LoadFunction(fn_RSA_verify_ex);
    FIsInitRSA := True;
  except

  end;
end;

procedure TCipherRSA.UnInitRSA;
begin

end;

procedure TCipherRSA.GenerateKeyPair(AKeyBits: integer = 2048);
var
  ARSA: PRSA;
begin
  FKeyBits := AKeyBits;
  if FIsInitRSA then begin
    // ����2048λ����Կ
    ARSA := RSA_generate_key(FKeyBits, 65537, nil, nil);
    if ARSA <> nil then begin
      FPublicKey.PublicRSA := ARSA;
//      FPrivateKey.PrivateRSA := ARSA;
    end;
  end;
end;

procedure TCipherRSA.Encrypt(APlain: TBytes; var ACiper: TBytes);
var
  LPublicRSA: PRSA;
  LPlainLen, LCiperLen, LRSAMaxLen: Integer;
begin
  LPlainLen := Length(APlain);
  LPublicRSA := FPublicKey.GetRSA;
  if (LPublicRSA <> nil) and (LPlainLen > 0) then begin
    LRSAMaxLen := RSA_size(LPublicRSA);
    LPlainLen := Min(LPlainLen, LRSAMaxLen - 11);
    SetLength(ACiper, LRSAMaxLen);
    LCiperLen := RSA_public_encrypt(LPlainLen, Pointer(APlain), Pointer(ACiper),
      LPublicRSA, RSA_PKCS1_PADDING);
    if LCiperLen = -1 then begin
      LCiperLen := 0;
    end;
  end else begin
    LCiperLen := 0;
  end;
  SetLength(ACiper, LCiperLen);
end;

procedure TCipherRSA.Decrypt(ACiper: TBytes; var APlain: TBytes);
var
  LPrivateRSA: PRSA;
  LPlainLen, LCiperLen, LRSAMaxLen: Integer;
begin
  LCiperLen := Length(ACiper);
  LPrivateRSA := FPrivateKey.GetRSA;
  if LPrivateRSA = nil then begin
    LPrivateRSA := FPublicKey.GetRSA;
  end;
  if (LPrivateRSA <> nil) and (LCiperLen > 0) then begin
    LRSAMaxLen := RSA_size(LPrivateRSA);
    SetLength(APlain, LRSAMaxLen);
    LPlainLen := RSA_private_decrypt(LCiperLen, Pointer(ACiper), Pointer(APlain),
      LPrivateRSA, RSA_PKCS1_PADDING);
    if LPlainLen = -1 then begin
      LPlainLen := 0;
    end;
  end else begin
    LPlainLen := 0;
  end;
  SetLength(APlain, LPlainLen);
end;

procedure TCipherRSA.LoadKeys(AFileName: string = '');
var
  LFileName: string;
begin
  LFileName := ExtractFilePath(ParamStr(0)) + RSA_DEFAULT_FILEPATH;
  FPublicKey.LoadKey(LFileName + PUBLIC_KEY_FILENAME_SUFFIX);
  FPrivateKey.LoadKey(LFileName + PRIVATE_KEY_FILENAME_SUFFIX);
end;

procedure TCipherRSA.PublicKeyToBytes(var ABytes: TBytes);
begin
  FPublicKey.KeyToBytes(ABytes);
end;

procedure TCipherRSA.PrivateKeyToBytes(var ABytes: TBytes);
begin
  FPrivateKey.KeyToBytes(ABytes);
end;

procedure TCipherRSA.LoadPublicKey(ABytes: TBytes);
begin
  FPublicKey.LoadKey(ABytes);
end;

procedure TCipherRSA.LoadPrivateKey(ABytes: TBytes);
begin
  FPrivateKey.LoadKey(ABytes);
end;

procedure TCipherRSA.LoadPublicKey(AFileName: string);
begin
  FPublicKey.LoadKey(AFileName);
end;

procedure TCipherRSA.LoadPrivateKey(AFileName: string);
begin
  FPrivateKey.LoadKey(AFileName);
end;

function TCipherRSA.Sign(AData: TBytes; var ASigData: TBytes): Boolean;
const
  BUF_LEN = 1024;
var
  LRSA: PRSA;
  LRet: Integer;
  LData: PAnsiChar;
  LMD_CTX : EVP_MD_CTX;
  LMLen, LSigLen: Cardinal;
  LMBuf, LSigBuf: array [0 .. BUF_LEN - 1] of AnsiChar;
begin
  Result := False;
  LRSA := FPrivateKey.GetRSA;
  if LRSA = nil then begin
    LRSA := FPublicKey.GetRSA;
    if LRSA = nil then Exit;
  end;
  LData := PAnsiChar(AData);
  ZeroMemory(@LMBuf, BUF_LEN);
  ZeroMemory(@LSigBuf, BUF_LEN);
//  RSA_private_encrypt
  {
    @function  EVP_SignInit
    ������Ҳ��һ���궨�庯�����䶨�����£�
    #define EVP_SignInit(a,b)  EVP_DigestInit(a,b)
    �����书�ܺ��÷���ǰ����ܵ�EVP_DigestInit������ȫһ����ʹ
    ��ȱʡʵ�ֵ��㷨��ʼ���㷨�ṹ ctx��
  }
  EVP_MD_CTX_init(@LMD_CTX);
  try
  {
      @function  EVP_SignInit_ex
      �ú�����һ���궨�庯������ʵ�ʶ������£�
      #define EVP_SignInit_ex(a,b,c)  EVP_DigestInit_ex(a,b,c)
      �ɼ����ú�����ǰ�������� EVP_DigestInit_ex�Ĺ��ܺ�ʹ�÷���
      ��һ���ģ�����ʹ��ENGINE����impl�������ʵ�ֺ�������������
      �ṹctx���ڵ��ñ�����ǰ������ctxһ��Ҫ���� EVP_MD_CTX_init
      ������ʼ����
      ��ϸʹ�÷����ο�ǰ������½��ܡ��ɹ�����1��ʧ�ܷ���0��
    }
    LRet := EVP_SignInit(@LMD_CTX, EVP_sha1());
    if LRet = 0 then Exit;

    {
      @function EVP_SignUpdate
      �ú���Ҳ��һ���궨�庯������ʵ�ʶ������£�
      #define EVP_SignUpdate(a,b,c)  EVP_DigestUpdate(a,b,c)
      �ú���ʹ�÷����͹���Ҳ��ǰ����ܵ�EVP_DigestUpdate����һ����
      ��һ�� cnt�ֽڵ����ݾ�����ϢժҪ����洢���ṹctx�У��ú���
      ������һ����ͬ��ctx�е��ö����ʵ�ֶԸ������ݵ���ϢժҪ������
      �ɹ�����1��ʧ�ܷ���0��
    }
    LRet := EVP_SignUpdate(@LMD_CTX, LData, Length(AData));
    if LRet = 0 then Exit;
    {
      @function EVP_SignFinal and EVP_DigestFinal_ex
      �ú������ܸ�EVP_DigestFinal_ex ������ͬ������ctx�ṹ���Զ�
      �����һ����˵�������µĳ���Ӧ��ʹ�� EVP_DigestInit_ex ��
      EVP_DigestFinal_ex ��������Ϊ��Щ����������ʹ����һ��
      EVP_MD_CTX�ṹ�󣬲������������ͳ�ʼ���ýṹ����ʹ��������
      �µ����ݴ��������µĴ�_ex�ĺ���Ҳ����ʹ�÷�ȱʡ��ʵ���㷨�⡣

      �ú�����ǰ������������ͬ������ǩ��ϵ�к�������ϢժҪ������
      ʼ��ͬ�ĵط�����ʵ���ú����ǽ�ǩ����������ϢժҪ�ṹctx ��
      ��һ�ݣ�Ȼ�����EVP_DigestFinal_ex�����ϢժҪ������Ȼ��
      ʼ��ժҪ��Ϣ��˽Կpkey����ǩ��,����ǩ����Ϣ�����ڲ���sig��
      �档�������s��Ϊ NULL����ô�ͻὫǩ����Ϣ���ݵĳ��ȣ���λ
      �ֽڣ������ڸò����У�ͨ��д���������EVP_PKEY_size(key)��
      ��Ϊ������ʱ���ǿ�����һ��ctx�����ԣ�ԭ����ctx�ṹ�����Լ�
      ��ʹ��EVP_SignUpdate�� EVP_SignFinal��������ɸ�����Ϣ��ǩ
      �����������������һ��Ҫʹ��EVP_MD_CTX_cleanup�����������
      ��ctx�ṹ������ͻ�����ڴ�й©��
      ���⣬��ʹ��DSA ˽Կǩ����ʱ��һ��Ҫ�Բ����������������
      �Ӳ��ֹ�����seeded)����������ͻ�ʧ�ܡ�RSA�㷨��һ����Ҫ
      ������������ʹ�õ�ǩ���㷨��ժҪ�㷨�Ĺ�ϵ����EVP_Digestϵ
      �����Ѿ�����ϸ˵�������ﲻ���ظ���
      �����������ɹ�����1�����򷵻�0��
    }
    LMLen := BUF_LEN;
    LRet := EVP_DigestFinal_ex(@LMD_CTX, LMBuf, LMLen);
    if LRet = 0 then Exit;

    LRet := RSA_sign_ex(NID_SHA1withRSA, LMBuf, LMLen, LSigBuf, @LSigLen, LRSA);
    if LRet = 1 then begin
      Result := True;
      SetLength(ASigData, LSigLen);
      CopyMemory(@ASigData[0], @LSigBuf[0], LSigLen);
    end;
  finally
    EVP_MD_CTX_cleanup(@LMD_CTX);
  end;
end;

function TCipherRSA.Verify(AData: TBytes; var ASigData: TBytes): Boolean;
const
  BUF_LEN = 1024;
var
  LRSA: PRSA;
  LRet: Integer;
  LData: PAnsiChar;
  LMD_CTX : EVP_MD_CTX;
  LMLen, LSigLen, LError: Cardinal;
  LMBuf, LSigBuf, LErrBuf: array [0 .. BUF_LEN - 1] of AnsiChar;
begin
  Result := False;
  LRSA := FPublicKey.GetRSA;
  if LRSA = nil then begin
    LRSA := FPrivateKey.GetRSA;
    if LRSA = nil then Exit;
  end;
  LData := PAnsiChar(AData);
  ZeroMemory(@LMBuf, BUF_LEN);
  ZeroMemory(@LSigBuf, BUF_LEN);
  LSigLen := Length(ASigData);
  CopyMemory(@LSigBuf[0], @ASigData[0], Length(ASigData));
  EVP_MD_CTX_init(@LMD_CTX);
  try
    LRet := EVP_VerifyInit(@LMD_CTX, EVP_sha1());
    if LRet = 0 then Exit;
    LRet := EVP_VerifyUpdate(@LMD_CTX, LData, Length(AData));
    if LRet = 0 then Exit;

//    LRet := EVP_VerifyFinal(LMD_CTX, LSigBuf, LSigLen, LRSA);
    LRet := EVP_DigestFinal_ex(@LMD_CTX, LMBuf, LMLen);

//    LRet := EVP_DigestVerifyFinal(@LMD_CTX, LSigBuf, LSigLen);
    if LRet = 0 then Exit;

    LRet := RSA_verify_ex(EVP_sha1()._type, LMBuf, @LMLen, LSigBuf, @LSigLen, LRSA);
    if LRet = 1 then begin
      Result := True;
    end else begin
      LError := ERR_get_error;
      ZeroMemory(@LErrBuf, BUF_LEN);
      ERR_error_string(LError, LErrBuf);
    end;
  finally
    EVP_MD_CTX_cleanup(@LMD_CTX);
  end;
end;

end.
