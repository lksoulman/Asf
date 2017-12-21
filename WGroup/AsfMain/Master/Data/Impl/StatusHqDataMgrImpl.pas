unit StatusHqDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： StatusHqDataMgr Implementation
// Author：      lksoulman
// Date：        2017-11-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  Command,
  BaseObject,
  AppContext,
  CommonLock,
  QuoteStruct,
  Quotemessage,
  QuoteMngr_TLB,
  GilQuoteStruct,
  QuoteManagerEx,
  MsgExSubcriber,
  StatusHqDataMgr,
  MsgExSubcriberImpl,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // StatusHqDataMgr Implementation
  TStatusHqDataMgrImpl = class(TBaseHqInterfacedObject, IStatusHqDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // StatusHqDatas
    FStatusHqDatas: TList<PStatusHqData>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
  protected
    // ClearDatas
    procedure DoClearDatas;
    // AddTestDatas
    procedure DoAddTestDatas;
    // SubcribeHqMsg
    procedure DoSubcribeHqMsg(AObject: TObject);
    // ReSubcribeHqData
    procedure DoReSubcribeHqData; override;
    // UnSubcribeHqData
    procedure DoUnSubcribeHqData; override;
    // InfoReset
    procedure DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
    // DataReset
    procedure DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
    // DataArrive
    procedure DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer); override;
    // DoUpdate
    procedure DoUpdate(AStatusHqData: PStatusHqData; AQuoteRealTime: IQuoteRealTime);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IStatusHqDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Subcribe
    procedure Subcribe;
    // GetCount
    function GetDataCount: Integer;
    // GetData
    function GetData(AIndex: Integer): PStatusHqData;
  end;

implementation

{ TStatusHqDataMgrImpl }

constructor TStatusHqDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoSubcribeHqMsg);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfHqService_ReSubcribeHq);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FStatusHqDatas := TList<PStatusHqData>.Create;
  DoAddTestDatas;
end;

destructor TStatusHqDataMgrImpl.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  DoClearDatas;
  FStatusHqDatas.Free;
  FLock.Free;
  inherited;
end;

procedure TStatusHqDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LStatusHqData: PStatusHqData;
begin
  for LIndex := 0 to FStatusHqDatas.Count - 1 do begin
    LStatusHqData := FStatusHqDatas.Items[LIndex];
    if LStatusHqData <> nil then begin
      Dispose(LStatusHqData);
    end;
  end;
  FStatusHqDatas.Clear;
end;

procedure TStatusHqDataMgrImpl.DoAddTestDatas;
var
  LStatusHqData: PStatusHqData;
begin
  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 1;
  LStatusHqData^.FSecuAbbr := '上证:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 11089;
  LStatusHqData^.FSecuAbbr := '创业板:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 3159;
  LStatusHqData^.FSecuAbbr := '恒指:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 1055;
  LStatusHqData^.FSecuAbbr := '深证:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 7542;
  LStatusHqData^.FSecuAbbr := '中小板:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 3145;
  LStatusHqData^.FSecuAbbr := '沪深300:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  LStatusHqData^.FIsHasCodeInfo := False;
  FStatusHqDatas.Add(LStatusHqData);
end;

procedure TStatusHqDataMgrImpl.DoSubcribeHqMsg(AObject: TObject);
begin
  DoReSubcribeHqData;
end;

procedure TStatusHqDataMgrImpl.DoReSubcribeHqData;
var
  LIndex, LCount: Integer;
  LStatusHqData: PStatusHqData;
  LCodeInfos: Array of TCodeInfo;
begin
  if FQuoteManagerEx = nil then Exit;

  LCount := 0;
  SetLength(LCodeInfos, FStatusHqDatas.Count);
  for LIndex := 0 to FStatusHqDatas.Count - 1 do begin
    LStatusHqData := FStatusHqDatas.Items[LIndex];
    if (LStatusHqData <> nil) then begin
      if not LStatusHqData^.FIsHasCodeInfo then begin
        LStatusHqData^.FIsHasCodeInfo := FQuoteManagerEx.GetCodeInfoByInnerCode(Int64(@(LStatusHqData^.FInnerCode)),
          Int64(@(LStatusHqData^.FCodeInfo)));
      end;
      if LStatusHqData^.FIsHasCodeInfo then begin
        LCodeInfos[LCount] := LStatusHqData^.FCodeInfo;
        Inc(LCount);
      end;
    end;
  end;
  if LCount > 0 then begin
    DoUnSubcribeHqData;
    FQuoteManagerEx.Subscribe(QuoteType_REALTIME, Int64(@LCodeInfos[0]), LCount, FQuoteMessage.MsgCookie, 0);
  end;
end;

procedure TStatusHqDataMgrImpl.DoUnSubcribeHqData;
begin
  FQuoteManagerEx.Subscribe(QuoteType_REALTIME, 0, 0, FQuoteMessage.MsgCookie, 0);
end;

procedure TStatusHqDataMgrImpl.DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TStatusHqDataMgrImpl.DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin
  FLock.Lock;
  try
    DoReSubcribeHqData;
  finally
    FLock.UnLock;
  end;
end;

procedure TStatusHqDataMgrImpl.DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer);
var
  LIndex: Integer;
  LStatusHqData: PStatusHqData;
begin
  if AQuoteType = QuoteType_REALTIME then begin
    for LIndex := 0 to FStatusHqDatas.Count - 1 do begin
      LStatusHqData := FStatusHqDatas.Items[LIndex];
      if (LStatusHqData <> nil) then begin
        DoUpdate(LStatusHqData, FQuoteManagerEx.QueryData(QuoteType_REALTIME,
          Int64(@LStatusHqData.FCodeInfo)) as IQuoteRealTime);
      end;
    end;
  end;
end;

procedure TStatusHqDataMgrImpl.DoUpdate(AStatusHqData: PStatusHqData; AQuoteRealTime: IQuoteRealTime);
var
  LScalc: Double;
  LStockType: PStockType;
  LCommRealTime: PQuoteRealTimeData;
begin
  if AQuoteRealTime = nil then Exit;

  AQuoteRealTime.BeginRead;
  try
    LStockType := PStockType(AQuoteRealTime.GetStockTypeInfo(AStatusHqData.FCodeInfo.m_cCodeType));
    if (LStockType <> nil)
      and (LStockType^.m_nPriceUnit > 0) then begin
      LScalc := 1 / LStockType^.m_nPriceUnit
    end else begin
      LScalc := 0.001;
    end;
    LCommRealTime := PQuoteRealTimeData(AQuoteRealTime.Datas[AStatusHqData.FCodeInfo.m_cCodeType,
      CodeInfoToCode(@AStatusHqData.FCodeInfo)]);
    if LCommRealTime <> nil then begin
      case GetRealTimeSC(@AStatusHqData.FCodeInfo) of
        rscSTOCK:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_stStockData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := LCommRealTime.m_cNowData.m_stStockData.m_fAvgPrice;
          end;
        rscINDEX:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_indData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := LCommRealTime.m_cNowData.m_indData.m_fAvgPrice;
          end;
        rscHKSTOCK:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_hkData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := LCommRealTime.m_cNowData.m_hkData.m_fAvgPrice;
          end;
        rscFUTURES:
          begin
            AStatusHqData.FPreClose := LCommRealTime.m_cNowData.m_qhData.m_lPreJieSuanPrice * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_qhData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := 0;
          end;
        rscOPTION, rscFX, rscIB:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
          end;
        rscUS:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_USData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := LCommRealTime.m_cNowData.m_USData.m_fMoney;
          end;
        rscTHREEBOAD:
          begin
            AStatusHqData.FPreClose := AQuoteRealTime.PrevClose[AStatusHqData.FCodeInfo.m_cCodeType,
              CodeInfoToCode(@AStatusHqData.FCodeInfo)] * LScalc;
            AStatusHqData.FNowPrice := LCommRealTime.m_cNowData.m_USData.m_lNewPrice * LScalc;
            AStatusHqData.FTurnover := LCommRealTime.m_cNowData.m_USData.m_fMoney;
          end;
      else
        begin
          AStatusHqData.FPreClose := 0;
          AStatusHqData.FNowPrice := 0;
          AStatusHqData.FTurnover := 0;
        end;
      end;
    end else begin
      AStatusHqData.FPreClose := 0;
      AStatusHqData.FNowPrice := 0;
      AStatusHqData.FTurnover := 0;
    end;
    AStatusHqData.Calc;
  finally
    AQuoteRealTime.EndRead;
  end;
end;

procedure TStatusHqDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusHqDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusHqDataMgrImpl.Subcribe;
begin
  FLock.Lock;
  try
    DoReSubcribeHqData;
  finally
    FLock.UnLock;
  end;
end;

function TStatusHqDataMgrImpl.GetDataCount: Integer;
begin
  Result := FStatusHqDatas.Count;
end;

function TStatusHqDataMgrImpl.GetData(AIndex: Integer): PStatusHqData;
begin
  if (AIndex >= 0)
    and (AIndex < FStatusHqDatas.Count) then begin
    Result := FStatusHqDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
