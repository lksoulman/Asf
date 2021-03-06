unit QDOSingleColValue;

interface

uses
  Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
  QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs, QuoteDataMngr,
  GilQuoteStruct, Generics.collections, QDOBase;

const
  UPDATE_COLVELUE_COL_CODE = 1100;
  UPDATE_COLVELUE_DATA = 1101;
  UPDATE_COLVULUE_CLEAR = 1102;

type
  TQuoteSingleColValue = class(TQuoteSync, IQuoteColValue)
  protected
    FDatas: PGilQuoteColValues;
    FCount: Integer;
    FVarCode: Integer;
    FColCode: Integer;

    procedure FreeDatas();

    function Count: Integer; safecall;
    function Get_Datas: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_ColCode: Integer; safecall;
  public
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); override; safecall;
    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy(); override;
  end;

implementation

uses System.Win.ComServ;

{ TQuoteColValue }
constructor TQuoteSingleColValue.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteMarketMonitor);
  FDatas := nil;
  FCount := 0;
  FColCode := -1;
  FVarCode := 0;
end;

destructor TQuoteSingleColValue.Destroy;
begin
  FCount := 0;
  FreeDatas;
  inherited;
end;

procedure TQuoteSingleColValue.FreeDatas();
begin
  if FDatas <> nil then
  begin
    FreeMemory(FDatas);
    FDatas := nil;
  end;
end;

function TQuoteSingleColValue.Count: Integer;
begin
  Result := FCount;
end;

function TQuoteSingleColValue.Get_ColCode: Integer;
begin
  Result := FColCode;
end;

function TQuoteSingleColValue.Get_Datas: Int64;
begin
  Result := Int64(FDatas);
end;

function TQuoteSingleColValue.Get_VarCode: Integer;
begin
  Result := FVarCode;
end;

procedure TQuoteSingleColValue.Update(DataType: Integer; Data: Int64; Size: Integer);
var
  AnsHQColValue: PAnsHQColValue;
  tmpData: PGilQuoteColValues;
  tmpCount, i: Integer;
  pData32: PGilQuoteColValue32;
  pData64: PGilQuoteColValue64;
begin
  case DataType of
    UPDATE_COLVELUE_COL_CODE:
      FColCode := Data;
    UPDATE_COLVULUE_CLEAR:
      begin
        BeginWrite;
        try
          FCount := 0;
          FreeDatas;
        finally
          EndWrite;
        end;
      end;
    UPDATE_COLVELUE_DATA:
      begin
        BeginWrite;
        try
          AnsHQColValue := PAnsHQColValue(Data);
          if (Size = 0) or (Data = 0) or (AnsHQColValue.m_lHQColCount = 0) or
            (AnsHQColValue.m_HQColFields[0].m_lField <> FColCode) then
            exit;
          tmpCount := FCount + AnsHQColValue.m_lColCodeSize;
          tmpData := GetMemory(tmpCount * SizeOf(TGilQuoteColValues));
          FillMemory(tmpData, tmpCount * SizeOf(TGilQuoteColValues), 0);
          if (FCount > 0) and (FDatas <> nil) then
          begin
            CopyMemory(tmpData, FDatas, FCount * SizeOf(TGilQuoteColValues));
          end
          else
          begin
            FCount := 0;
          end;
          // �ͷ��ڴ�
          FreeDatas;
          FDatas := tmpData;
          for i := 0 to AnsHQColValue.m_lColCodeSize - 1 do
          begin
            tmpData := PGilQuoteColValues(Int64(FDatas) + FCount * SizeOf(TGilQuoteColValues));
            if AnsHQColValue.m_HQColFields[0].m_lFieldWidth = 4 then // 4�ֽ�
            begin
              pData32 := PGilQuoteColValue32(Int64(@AnsHQColValue.m_pData[0]) + (SizeOf(TGilQuoteColValue32) * i));
              tmpData.m_CodeInfo := pData32.m_CodeInfo;
              tmpData.IntValue := pData32.m_Value;
            end
            else if AnsHQColValue.m_HQColFields[0].m_lFieldWidth = 8 then
            begin
              pData64 := PGilQuoteColValue64(Int64(@AnsHQColValue.m_pData[0]) + (SizeOf(TGilQuoteColValue64) * i));
              tmpData.m_CodeInfo := pData64.m_CodeInfo;
              tmpData.Int64Value := pData64.m_Value;
            end
            else
              continue;
            inc(FCount);
          end;
          inc(FVarCode);
        finally
          EndWrite;
        end;
      end;
  end;

end;

end.
