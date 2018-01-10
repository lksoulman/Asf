unit GFDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º FinanceData Implementation
// Author£º      lksoulman
// Date£º        2017-9-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  GFData,
  Windows,
  Classes,
  SysUtils,
  GFDataUpdate,
  ExecutorThread,
  CommonRefCounter;

type

  // FinanceData Implementation
  TGFDataImpl = class(TAutoInterfacedObject, IGFData, IGFDataUpdate)
  private
    // Key
    FKey: Int64;
    // ErrorInfo
    FErrorInfo: string;
    // ErrorCode
    FErrorCode: Integer;
    // IsCanceled
    FIsCanceled: Boolean;
    // GFDataEvent
    FGFDataEvent: TGFDataEvent;
    // ResponseStream
    FDataStream: TStream;
    // RequestSize
    FRequestSize: Cardinal;
    // RequestCompressSize
    FRequestCompressSize: Cardinal;
    // ResponseSize
    FResponseSize: Cardinal;
    // ResponseCompressSize
    FResponseCompressSize: Cardinal;
    // QueueWaitUseTime
    FQueueWaitUseTime: Cardinal;
    // ExecutePostUseTime
    FExecutePostUseTime: Cardinal;
    // RequestCompressUseTime
    FRequestCompressUseTime: Cardinal;
    // ResponseUncompressUseTime
    FResponseUncompressUseTime: Cardinal;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IGFData }

    // GetKey
    function GetKey: Int64; safecall;
    // Cancel
    function Cancel: Boolean; safecall;
    // GetErrorCode
    function GetErrorCode: Integer; safecall;
    // GetErrorInfo
    function GetErrorInfo: WideString; safecall;
    // GetDataStream
    function GetDataStream: TStream; safecall;
    // GetRequestSize
    function GetRequestSize: Cardinal; safecall;
    // GetRequestCompressSize
    function GetRequestCompressSize: Cardinal; safecall;
    // GetCompressRatio
    function GetRequestCompressRatio: Double; safecall;
    // GetResponseSize
    function GetResponseSize: Cardinal; safecall;
    // GetResponseCompressSize
    function GetResponseCompressSize: Cardinal; safecall;
    // GetCompressRatio
    function GetResponseCompressRatio: Double; safecall;
    // GetQueueWaitUseTime
    function GetQueueWaitUseTime: Cardinal; safecall;
    // GetExecutePostUseTime
    function GetExecutePostUseTime: Cardinal; safecall;
    // GetRequestCompressUseTime
    function GetRequestCompressUseTime: Cardinal; safecall;
    // GetResponseUncompressUseTime
    function GetResponseUncompressUseTime: Cardinal; safecall;

    { IGFDataUpdate }

    // GetIsCanceled
    function GetIsCancel: Boolean; safecall;
    // GetDataEvent
    function GetDataEvent: TGFDataEvent; safecall;
    // SetKey
    function SetKey(AKey: Int64): Boolean; safecall;
    // SetDataEvent
    function SetDataEvent(AEvent: TGFDataEvent): Boolean; safecall;
    // SetCancel
    function SetCancel(ACancel: Boolean = True): Boolean; safecall;
    // SetErrorCode
    function SetErrorCode(AErrorCode: Integer): Boolean; safecall;
    // SetErrorInfo
    function SetErrorInfo(AErrorInfo: WideString): Boolean; safecall;
    // SetResponseStream
    function SetResponseStream(AResponseStream: TStream): Boolean; safecall;
    // SetRequestSize
    function SetRequestSize(ASize: Cardinal): Boolean; safecall;
    // SetRequestCompressSize
    function SetRequestCompressSize(ASize: Cardinal): Boolean; safecall;
    // SetResponseSize
    function SetResponseSize(ASize: Cardinal): Boolean; safecall;
    // SetResponseCompress Size
    function SetResponseCompressSize(ASize: Cardinal): Boolean; safecall;
    // SetQueueWaitUseTime
    function SetQueueWaitUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetExecutePostUseTime
    function SetExecutePostUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetRequestCompressUseTime
    function SetRequestCompressUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetResponseUncompressUseTime
    function SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean; safecall;
  end;

implementation

{ TGFDataImpl }

constructor TGFDataImpl.Create;
begin
  inherited;
  FKey := 0;
  FErrorCode := 0;
  FRequestSize := 0;
  FRequestCompressSize := 0;
  FResponseSize := 0;
  FResponseCompressSize := 0;
  FQueueWaitUseTime := 0;
  FExecutePostUseTime := 0;
  FRequestCompressUseTime := 0;
  FResponseUncompressUseTime := 0;
  FIsCanceled := False;
  FDataStream := TMemoryStream.Create;
end;

destructor TGFDataImpl.Destroy;
begin
  Cancel;
  FDataStream.Free;
  inherited;
end;

function TGFDataImpl.GetKey: Int64;
begin
  Result := FKey;
end;

function TGFDataImpl.Cancel: Boolean;
begin
  Result := True;
  FIsCanceled := True;
  FGFDataEvent := nil;
end;

function TGFDataImpl.GetErrorCode: Integer;
begin
  Result := FErrorCode;
end;

function TGFDataImpl.GetErrorInfo: WideString;
begin
  Result := FErrorInfo;
end;

function TGFDataImpl.GetRequestCompressRatio: Double;
begin
  if FRequestSize = 0 then begin
    Result := 1.0;
  end else begin
    Result := FRequestCompressSize / FRequestSize;
  end;
end;

function TGFDataImpl.GetDataStream: TStream;
begin
  Result := FDataStream;
end;

function TGFDataImpl.GetRequestSize: Cardinal;
begin
  Result := FRequestSize;
end;

function TGFDataImpl.GetRequestCompressSize: Cardinal;
begin
  Result := FRequestCompressSize;
end;

function TGFDataImpl.GetResponseSize: Cardinal;
begin
  Result := FResponseSize;
end;

function TGFDataImpl.GetResponseCompressSize: Cardinal;
begin
  Result := FResponseCompressSize;
end;

function TGFDataImpl.GetResponseCompressRatio: Double;
begin
  if FResponseSize = 0 then begin
    Result := 1.0;
  end else begin
    Result := FResponseCompressSize / FResponseSize;
  end;
end;

function TGFDataImpl.GetQueueWaitUseTime: Cardinal;
begin
  Result := FQueueWaitUseTime;
end;

function TGFDataImpl.GetExecutePostUseTime: Cardinal;
begin
  Result := FExecutePostUseTime;
end;

function TGFDataImpl.GetRequestCompressUseTime: Cardinal;
begin
  Result := FRequestCompressUseTime;
end;

function TGFDataImpl.GetResponseUncompressUseTime: Cardinal;
begin
  Result := FResponseUncompressUseTime;
end;

function TGFDataImpl.SetCancel(ACancel: Boolean): Boolean;
begin
  FIsCanceled := True;
  Result := True;
end;

function TGFDataImpl.SetDataEvent(AEvent: TGFDataEvent): Boolean;
begin
  Result := True;
  FGFDataEvent := AEvent;
end;

function TGFDataImpl.GetIsCancel: Boolean;
begin
  Result := FIsCanceled;
end;

function TGFDataImpl.GetDataEvent: TGFDataEvent;
begin
  Result := FGFDataEvent;
end;

function TGFDataImpl.SetKey(AKey: Int64): Boolean;
begin
  Result := True;
  FKey := AKey;
end;

function TGFDataImpl.SetErrorCode(AErrorCode: Integer): Boolean;
begin
  Result := True;
  FErrorCode := AErrorCode;
end;

function TGFDataImpl.SetErrorInfo(AErrorInfo: WideString): Boolean;
begin
  FErrorInfo := AErrorInfo;
end;

function TGFDataImpl.SetResponseStream(AResponseStream: TStream): Boolean;
begin
  AResponseStream.Position := 0;
  FDataStream.CopyFrom(AResponseStream, AResponseStream.Size);
  FDataStream.Position := 0;
end;

function TGFDataImpl.SetRequestSize(ASize: Cardinal): Boolean;
begin
  FRequestSize := ASize;
end;

function TGFDataImpl.SetRequestCompressSize(ASize: Cardinal): Boolean;
begin
  FRequestCompressSize := ASize;
end;

function TGFDataImpl.SetResponseSize(ASize: Cardinal): Boolean;
begin
  FResponseSize := ASize;
end;

function TGFDataImpl.SetResponseCompressSize(ASize: Cardinal): Boolean;
begin
  FResponseCompressSize := ASize;
end;

function TGFDataImpl.SetQueueWaitUseTime(AUseTime: Cardinal): Boolean;
begin
  FQueueWaitUseTime := AUseTime;
end;

function TGFDataImpl.SetExecutePostUseTime(AUseTime: Cardinal): Boolean;
begin
  FExecutePostUseTime := AUseTime;
end;

function TGFDataImpl.SetRequestCompressUseTime(AUseTime: Cardinal): Boolean;
begin
  FRequestCompressUseTime := AUseTime;
end;

function TGFDataImpl.SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean;
begin
  FResponseUncompressUseTime := AUseTime;
end;

end.
