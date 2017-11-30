unit JsonChannel;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Json Channel
// Author��      lksoulman
// Date��        2017-9-13
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  JSON,
  Channel,
  Windows,
  Classes,
  SysUtils,
  HttpContext,
  HttpExecutor,
  CommonObject,
  CommonRefCounter;

type

  // Json Channel
  TJsonChannel = class(TChannel)
  private
  protected
    // Get ErrorCode
    function DoGetErrorCode(AErrorCode: Integer): Integer;
    // Parse To Json
    function DoParseJson(AIndicator: string; var AFundId: string; var AParams: TJSONArray): Boolean;
    // Read Error
    function DoParseError(AExecutor: IHttpExecutor; var AErrorCode: Integer; var AErrorInfo: string): Boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Up Stream
    procedure UpStream(AContext: THttpContext; AExecutor: IHttpExecutor); override;
    // Down Stream
    procedure DownStream(AContext: THttpContext; AExecutor: IHttpExecutor); override;
  end;

implementation

uses
  ShareMgr,
  ErrorCode,
  GFDataParser;

{ TJsonChannel }

constructor TJsonChannel.Create;
begin
  inherited;

end;

destructor TJsonChannel.Destroy;
begin

  inherited;
end;

procedure TJsonChannel.UpStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LErrorInfo: string;
  LErrorCode: Integer;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  DoParseError(AExecutor, LErrorCode, LErrorInfo);
  AContext.GFDataUpdate.SetErrorCode(LErrorCode);
  AContext.GFDataUpdate.SetErrorInfo(LErrorInfo);
  AContext.GFDataUpdate.SetResponseStream(AExecutor.GetResponseStream);
end;

procedure TJsonChannel.DownStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LBytes: TBytes;
  LCount: Integer;
  LFuncId: string;
  LParams: TJSONArray;
  LJSONObject: TJSONObject;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  if DoParseJson(AContext.Indicator, LFuncId, LParams) then begin
    LJSONObject := TJSONObject.Create;
    try
      LJSONObject.AddPair('sid', AExecutor.GetShareMgr.GetSessionId);
      LJSONObject.AddPair('date', FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', Now));
      LJSONObject.AddPair('funcId', LFuncId);
      if (LParams <> nil)
        and (LParams.Count > 0) then begin
        LJSONObject.AddPair('params', LParams);
      end;
      Setlength(LBytes, LJSONObject.EstimatedByteSize);
      LCount := LJSONObject.ToBytes(LBytes, 0);
      AExecutor.WriteBytesRequestStream(LBytes, LCount);
    finally
      LJSONObject.Free;
    end;
  end else begin
    if LFuncId = '' then begin
      AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_FundId_IsNull);
    end;
  end;
end;

function TJsonChannel.DoGetErrorCode(AErrorCode: Integer): Integer;
begin
  case AErrorCode of
    0:
      begin
        Result := AErrorCode;
      end;
    1000:    // ����У��ʧ��
      begin
        Result := ErrorCode_Service_Indicator_Params_CheckFailed;
      end;
    1001:    // JSON��ʽ����
      begin
        Result := ErrorCode_Service_Indicator_JsonFormat;
      end;
    5500:    // ָ�겻����
      begin
        Result := ErrorCode_Service_Indicator_NoExists;
      end;
    5501:    // ����������һ��
      begin
        Result := ErrorCode_Service_Indicator_Params_CountFailed;
      end;
    5502:    // ������������
      begin
        Result := ErrorCode_Service_Indicator_Params_TypeFailed;
      end;
    5503:    // ָ��ִ���쳣
      begin
        Result := ErrorCode_Service_Indicator_Execute_Except;
      end;
    6000:    // �û��쳣
      begin
        Result := ErrorCode_Service_Login_Failed;
      end;
    6001:    // �ʺ�����У��ʧ��
      begin
        Result := ErrorCode_Service_Login_Password_CheckFailed;
      end;
    6002:    // ������У��ʧ��
      begin
        Result := ErrorCode_Service_Login_MacCode_CheckFailed;
      end;
    6003:    // �Ự��ʱ
      begin
        Result := ErrorCode_Service_Response_Session_Timeout;
      end;
    6004:    // �Ự��ʱ
      begin
        Result := ErrorCode_Service_Response_Session_Timeout;
      end;
    6005:    // ������ SID
      begin
        Result := ErrorCode_Service_Response_NoExistsSid;
      end;
    6006:    // δ��¼
      begin
        Result := ErrorCode_Service_Response_NoLogin;
      end;
    6007:    // ��¼ʧ��
      begin
        Result := ErrorCode_Service_Login_Failed;
      end;
    6010:     // ��Ч�� License
      begin
        Result := ErrorCode_Service_Login_License_Invalid;
      end;
    6011:     //
      begin
        Result := ErrorCode_Service_Login_License_Invalid;
      end;
    6012:    // License �Ѿ�����
      begin
        Result := ErrorCode_Service_Login_License_Binded;
      end;
    6013:    // License ���쳣
      begin
        Result := ErrorCode_Service_Login_License_Bind_Except;
      end;
    9999:    // ϵͳ�쳣
      begin
        Result := ErrorCode_Service_System_Except;
      end;
  else
    Result := AErrorCode;
  end;
end;

function TJsonChannel.DoParseJson(AIndicator: string; var AFundId: string; var AParams: TJSONArray): Boolean;
var
  LJSONArray: TJSONArray;
  LStringStream: TStringStream;
  LGFDataParser: TGFDataParser;
begin
  AFundId := '';
  AParams := nil;
  LJSONArray := nil;
  Result := False;
  if AIndicator = '' then Exit;

  LStringStream := TStringStream.Create(AIndicator);
  try
    LGFDataParser := TGFDataParser.Create(LStringStream, TEncoding.ANSI);
    try
      if LGFDataParser.Token = Classes.toSymbol then begin
        AFundId := LGFDataParser.TokenString;
        LGFDataParser.NextToken;
      end;

      if AFundId = '' then Exit;

      while LGFDataParser.Token <> toEOF do begin
        if LGFDataParser.Token = '[' then begin
          LJSONArray := TJSONArray.Create;
          if AParams = nil then begin
            AParams := TJSONArray.Create;
          end;
          AParams.Add(LJSONArray);
        end else if LGFDataParser.Token = ']' then begin
          LJSONArray := nil;
        end else if CharInSet(LGFDataParser.Token,
          [Classes.toSymbol, Classes.toString, Classes.toWString,
          Classes.toInteger, Classes.toFloat]) then begin
          if LJSONArray <> nil then begin
            LJSONArray.Add(LGFDataParser.TokenString);
          end else begin
            if AParams = nil then begin
              AParams := TJSONArray.Create;
            end;
            AParams.Add(LGFDataParser.TokenString);
          end;
        end;
        LGFDataParser.NextToken;
      end;
      Result := True;
    finally
      LGFDataParser.Free;
    end;
  finally
    LStringStream.Free;
  end;
end;

function TJsonChannel.DoParseError(AExecutor: IHttpExecutor; var AErrorCode: Integer; var AErrorInfo: string): Boolean;
var
  LTempStream: TStream;
  LGFDataParser: TGFDataParser;
  LSize, LResponseCode, LResponseInfo: Integer;
begin
  Result := True;
  AErrorInfo := '';
  LResponseCode := 0;
  LResponseInfo := 0;
  AErrorCode := ErrorCode_Unknown;
  LSize := AExecutor.GetResponseStream.Size;
  if LSize > 2000 then begin
    LSize := 2000;
  end;
  LTempStream := AExecutor.GetTempStream;
  LTempStream.Size := 0;
  LTempStream.Position := 0;
  AExecutor.GetResponseStream.Position := 0;
  LTempStream.CopyFrom(AExecutor.GetResponseStream, LSize);
  LTempStream.Position := 0;
  LGFDataParser := TGFDataParser.Create(LTempStream, TEncoding.UTF8);
  try
    while LGFDataParser.Token <> toEOF do begin
      if CharInSet(LGFDataParser.Token , [Classes.toSymbol, Classes.toString,
        Classes.toWString, Classes.toInteger, Classes.toFloat]) then begin
        // ƥ����һ�� code
        if LResponseCode = 1 then begin
          AErrorCode := StrToIntDef(LGFDataParser.TokenString, -1);
          LResponseCode := 2;
        end else if LResponseInfo = 1 then begin  //ƥ����һ�� Msg
          AErrorInfo := LGFDataParser.TokenString;
          LResponseInfo := 2;
        end else if (LResponseCode = 0)
          and SameText('respCode', LGFDataParser.TokenString) then begin
          LResponseCode := 1;
        end else if (LResponseInfo = 0)
          and SameText('respMsg', LGFDataParser.TokenString) then begin
          LResponseInfo := 1;
        end;
      end;
      //û�д� �� ���ҵ����˳�
      if(AErrorCode = 0)
        or ((LResponseCode = 2) and (LResponseInfo = 2)) then begin
        break;
      end;
      LGFDataParser.NextToken;
    end;
    AErrorCode := DoGetErrorCode(AErrorCode);
  finally
    LGFDataParser.Free;
  end;
end;

end.
