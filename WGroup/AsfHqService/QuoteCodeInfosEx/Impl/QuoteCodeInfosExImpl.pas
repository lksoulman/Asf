unit QuoteCodeInfosExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-28
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  QuoteStruct,
  QuoteCodeInfosEx,
  CommonRefCounter;

type

  TQuoteCodeInfosExImpl = class(TAutoInterfacedObject, IQuoteCodeInfosEx)
  private
    // Count
    FCount: Integer;
    // Capacity
    FCapacity: Integer;
    // InnerCodes
    FInnerCodes: TArray<Integer>;
    // PCodeInfos
    FPCodeInfos: TArray<PCodeInfo>;
  protected
    // NewCapacity
    procedure NewCapacity(ACapacity: Integer);
  public
    // Constructor
    constructor Create(ACapacity: Integer = 0); reintroduce;
    // Destructor
    destructor Destroy; override;
    // AddElement
    procedure AddElement(AInnerCode: Integer; APCodeInfo: PCodeInfo);

    { IQuoteCodeInfosEx }

    // GetCount
    function GetCount: Integer;
    // GetPCodeInfo
    function GetPCodeInfo(AIndex: Integer): Int64;
    // GetInnerCode
    function GetInnerCode(AIndex: Integer): Integer;
  end;

implementation

{ TQuoteCodeInfosExImpl }

constructor TQuoteCodeInfosExImpl.Create(ACapacity: Integer = 0);
begin
  inherited Create;
  FCount := 0;
  FCapacity := 0;
  SetLength(FInnerCodes, 0);
  SetLength(FPCodeInfos, 0);
  NewCapacity(ACapacity);
end;

destructor TQuoteCodeInfosExImpl.Destroy;
begin
  SetLength(FInnerCodes, 0);
  SetLength(FPCodeInfos, 0);
  inherited;
end;

procedure TQuoteCodeInfosExImpl.AddElement(AInnerCode: Integer; APCodeInfo: PCodeInfo);
begin
  if FCount >= FCapacity then begin
    NewCapacity(FCapacity + 20);
  end;
  FInnerCodes[FCount] := AInnerCode;
  FPCodeInfos[FCount] := APCodeInfo;
  Inc(FCount);
end;

procedure TQuoteCodeInfosExImpl.NewCapacity(ACapacity: Integer);
var
  LCapcity: Integer;
begin
  if ACapacity < 0 then begin
    LCapcity := 0;
  end else begin
    LCapcity := ACapacity;
  end;
  if LCapcity > FCapacity then begin
    SetLength(FInnerCodes, ACapacity);
    SetLength(FPCodeInfos, ACapacity);
    FCapacity := ACapacity;
  end;
end;

function TQuoteCodeInfosExImpl.GetCount: Integer;
begin
  Result := FCount;
end;

function TQuoteCodeInfosExImpl.GetPCodeInfo(AIndex: Integer): Int64;
begin
  if (AIndex >= 0) and (AIndex < FCount) then begin
    Result := Int64(FPCodeInfos[AIndex]);
  end else begin
    Result := 0;
  end;
end;

function TQuoteCodeInfosExImpl.GetInnerCode(AIndex: Integer): Integer;
begin
  if (AIndex >= 0) and (AIndex < FCount) then begin
    Result := FInnerCodes[AIndex];
  end else begin
    Result := 0;
  end;
end;

end.
