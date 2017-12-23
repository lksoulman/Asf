unit SecuMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SecuMain Implementation
// Author：      lksoulman
// Date：        2017-9-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  StrUtils,
  SysUtils,
  SecuMain,
  BaseObject,
  AppContext,
  CommonLock,
  CommonObject,
  WNDataSetInf,
  ExecutorThread,
  CommonDynArray,
  MsgExSubcriberImpl,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // SecuMain Implementation
  TSecuMainImpl = class(TBaseInterfacedObject, ISecuMain, ISecuMainQuery)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // IsUpdating
    FIsUpdating: Boolean;
    // ItemCapacity
    FItemCapacity: Integer;
    // UpdateVersion
    FUpdateVersion: Integer;
    // AsyncUpdateThread
    FAsyncUpdateThread: TExecutorThread;
    // SecuInfos
    FSecuInfos: TDynArray<PSecuInfo>;
    // SecuInfoDic
    FSecuInfoDic: TDictionary<Integer, PSecuInfo>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
    // InnerCodeHSCodeDic
    FInnerCodeToHSCodeDic: TDictionary<Integer, string>;


    // ToMarket
    function ToMarket(AValue: Integer): UInt8;
    // ToCategory
    function ToCategory(AValue: Integer): UInt16;
    // ToMarkInfo
    function ToMarkInfo(AMargin, AThrough: Integer): UInt8;
    // SetIsUpdating
    procedure SetIsUpdating(AIsUpdating: Boolean);
  protected
    // Clear
    procedure DoClearItems;
    // AsyncUpdateExcecute
    procedure DoAsyncUpdateExecute(AObject: TObject);
    // SecuMainCacheTableUpdate
    procedure DoSecuMainCacheTableUpdate(AObject: TObject);

    // UpdateTable
    procedure DoUpdateTable;
    // UpdateTable Before
    procedure DoUpdateTableBefore;
    // LoadDataSet
    procedure DoLoadDataSet(ADataSet: IWNDataSet);
    // LoadSecuMaintItem
    procedure DoLoadSecuInfo(ASecuInfo: PSecuInfo;
//      AInnerCode,
      ASecuMarket,
      AListedState,
      ASecuCategory,
      AMargin,
      AThrough,
      ASecuAbbr,
      ASecuCode,
      ASecuSpell,
      ASecuSuffix,
      AFormerAbbr,
      AFormerSpell,
      ACodeByAgent,
      ACompanyCode: IWNField);
    // UpdatingGetItem
    function DoGetItemUpdating(AInnerCode: Integer): PSecuInfo;
    // NoUpdatingGetItem
    function DoGetItemNoUpdating(AInnerCode: Integer): PSecuInfo;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISecuMain }

    // StopService
    procedure StopService;
    // Lock
    procedure Lock;
    // Un Lock
    procedure UnLock;
    // Update
    procedure Update;
    // AsyncUpdate
    procedure AsyncUpdate;
    // IsUpdating
    function IsUpdating: Boolean;
    // GetItemCount
    function GetItemCount: Integer;
    // GetUpdateVersion
    function GetUpdateVersion: Integer;
    // GetItem
    function GetItem(AIndex: Integer): PSecuInfo;
    // GetHsCode
    function GetHsCode(AInnerCode: Integer): string;

    { ISecuMainQuery }

    // GetSecuInfo
    function GetSecuInfo(AInnerCode: Integer; var ASecuInfo: PSecuInfo): Boolean;
    // GetSecuInfos
    function GetSecuInfos(AInnerCodes: TIntegerDynArray; var ASecuInfos: TSecuInfoDynArray): Integer;
  end;

implementation

uses
  Command,
  LogLevel,
  CacheType;

const

  SQL_SECUMAIN = 'SELECT  '
	+' NBBM AS InnerCode,   '
	+' GPDM AS SecuCode,    '
	+' Suffix,              '
	+' ZQJC AS SecuAbbr,    '
	+' PYDM AS SecuSpell,   '
	+' ZQSC AS SecuMarket,  '
  +' GSDM as CompanyCode, '
	+' SSZT AS ListedState, '
	+' oZQLB AS SecuCategory,          '
	+' FormerName AS FormerAbbr,       '
	+' FormerNameCode AS FormerSpell,  '
	+' targetCategory AS Margin,       '
	+' ggt AS Through,                 '
	+' CodeByAgent                     '
  +' FROM                            '
	+' ZQZB A                          '
  +' LEFT JOIN                       '
	+' HSCODE B                        '
  +' ON                              '
	+' A.NBBM = B.InnerCode            ';


{ TSecuMainImpl }

constructor TSecuMainImpl.Create(AContext: IAppContext);
begin
  inherited;
  FUpdateVersion := -1;
  FIsUpdating := False;
  FLock := TCSLock.Create;
  FItemCapacity := 220000;
  FAsyncUpdateThread := TExecutorThread.Create;
  FAsyncUpdateThread.ThreadMethod := DoAsyncUpdateExecute;
  FSecuInfos := TDynArray<PSecuInfo>.Create(FItemCapacity);
  FSecuInfoDic := TDictionary<Integer, PSecuInfo>.Create(FItemCapacity);
  FInnerCodeToHSCodeDic := TDictionary<Integer, string>.Create(413);
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoSecuMainCacheTableUpdate);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateBaseCache_SecuMain);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TSecuMainImpl.Destroy;
begin
  StopService;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  DoClearItems;
  FInnerCodeToHSCodeDic.Free;
  FSecuInfoDic.Free;
  FSecuInfos.Free;
  FLock.Free;
  inherited;
end;

procedure TSecuMainImpl.StopService;
begin
  if FIsStart then begin
    FAsyncUpdateThread.ShutDown;
    FIsStart := False;
  end;
end;

procedure TSecuMainImpl.Lock;
begin
  FLock.Lock;
end;

procedure TSecuMainImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TSecuMainImpl.Update;
begin
  SetIsUpdating(True);
  try
    DoUpdateTable;
  finally
    SetIsUpdating(False);
  end;
end;

procedure TSecuMainImpl.AsyncUpdate;
begin
  FLock.Lock;
  try
    if not FAsyncUpdateThread.IsStart then begin
      FAsyncUpdateThread.StartEx;
      FIsStart := True;
    end;
    FAsyncUpdateThread.ResumeEx;
  finally
    FLock.UnLock;
  end;
end;

function TSecuMainImpl.IsUpdating: Boolean;
begin
  Result := FIsUpdating;
end;

function TSecuMainImpl.GetUpdateVersion: Integer;
begin
  Result := FUpdateVersion;
end;

function TSecuMainImpl.GetItemCount: Integer;
begin
  Result := FSecuInfos.GetCount;
end;

function TSecuMainImpl.GetItem(AIndex: Integer): PSecuInfo;
begin
  Result := FSecuInfos.GetElement(AIndex);
end;

function TSecuMainImpl.GetHsCode(AInnerCode: Integer): string;
var
  LHsCode: string;
begin
  if FInnerCodeToHSCodeDic.TryGetValue(AInnerCode, LHsCode) then begin
    Result := LHsCode;
  end else begin
    Result := '';
  end;
end;

function TSecuMainImpl.GetSecuInfo(AInnerCode: Integer; var ASecuInfo: PSecuInfo): Boolean;
var
  LIsUpdating: Boolean;
begin
  FLock.Lock;
  try
    LIsUpdating := FIsUpdating;
  finally
    FLock.UnLock;
  end;
  if LIsUpdating then begin
    ASecuInfo := nil;
  end else begin
    ASecuInfo := DoGetItemNoUpdating(AInnerCode);
  end;
  Result := ASecuInfo <> nil;
end;

function TSecuMainImpl.GetSecuInfos(AInnerCodes: TIntegerDynArray; var ASecuInfos: TSecuInfoDynArray): Integer;
var
  LSecuInfo: PSecuInfo;
  LIsUpdating: Boolean;
  LIndex, LTotalCount: Integer;
begin
  Result := 0;
  LTotalCount := Length(AInnerCodes);
  if LTotalCount <= 0 then Exit;

  FLock.Lock;
  try
    LIsUpdating := FIsUpdating;
  finally
    FLock.UnLock;
  end;
  if LIsUpdating then Exit;
  
  for LIndex := 0 to LTotalCount - 1 do begin
    LSecuInfo := DoGetItemNoUpdating(AInnerCodes[LIndex]);
    if LSecuInfo <> nil then begin
      ASecuInfos[Result] := LSecuInfo;
      Inc(Result);
    end;
  end;
end;

function TSecuMainImpl.ToMarket(AValue: Integer): UInt8;
begin
  if AValue < SECUMARKET_310 then begin
    Result := AValue;
  end else if AValue = GIL_SECUMARKET_310 then begin
    Result := SECUMARKET_310;
  end else if AValue = GIL_SECUMARKET_320 then begin
    Result := SECUMARKET_320;
  end else begin
    Result := 0;
  end;
end;

function TSecuMainImpl.ToCategory(AValue: Integer): UInt16;
begin
  Result := AValue;
end;

function TSecuMainImpl.ToMarkInfo(AMargin, AThrough: Integer): UInt8;
var
  LMargin, LThrough: UInt8;
begin
  if AMargin = GIL_MARGIN_FINANCE then begin
    LMargin := MARGIN_FINANCE;
  end else if AMargin = GIL_MARGIN_LOAN then begin
    LMargin := MARGIN_LOAN;
  end else begin
    LMargin := MARGIN_FINANCE_AND_LOAN;
  end;
  LThrough := AThrough;
  LThrough := LThrough and THROUGH_MASK;
  Result := LMargin or LThrough;
end;

procedure TSecuMainImpl.SetIsUpdating(AIsUpdating: Boolean);
begin
  FLock.Lock;
  try
    FIsUpdating := AIsUpdating;
  finally
    FLock.UnLock;
  end;
end;

procedure TSecuMainImpl.DoClearItems;
var
  LIndex: Integer;
  LPSecuInfo: PSecuInfo;
begin
  for LIndex := 0 to FSecuInfos.GetCount - 1 do begin
    LPSecuInfo := FSecuInfos.GetElement(LIndex);
    if LPSecuInfo <> nil then begin
      Dispose(LPSecuInfo);
    end;
  end;
end;

procedure TSecuMainImpl.DoAsyncUpdateExecute(AObject: TObject);
var
  LResult: Cardinal;
begin
  while not FAsyncUpdateThread.IsTerminated do begin
    LResult := FAsyncUpdateThread.WaitForEx;
    case LResult of
      WAIT_OBJECT_0:
        begin
          SetIsUpdating(True);
          try
            DoUpdateTable;
          finally
            SetIsUpdating(False);
          end;
        end;
    end;
  end;
end;

procedure TSecuMainImpl.DoSecuMainCacheTableUpdate(AObject: TObject);
begin
  AsyncUpdate;
end;

procedure TSecuMainImpl.DoUpdateTable;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LDataSet: IWNDataSet;
  LUpdateVersion: Integer;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    LUpdateVersion := FUpdateVersion;
    if FAppContext = nil then Exit;

    DoUpdateTableBefore;
    try
      LDataSet := FAppContext.CacheSyncQuery(ctBaseData, SQL_SECUMAIN);

      // 防止线程退出了循环还没有退出
      if FAsyncUpdateThread.IsTerminated then Exit;

      if (LDataSet <> nil) then begin
        if (LDataSet.RecordCount > 0) then begin
          DoLoadDataSet(LDataSet);
          Inc(LUpdateVersion);
        end;
        LDataSet := nil;
      end else begin
        FAppContext.SysLog(llWARN, '[TSecuMainImpl][DoUpdateTable] Load dateset is nil.');
      end;
    finally
      if LUpdateVersion <> FUpdateVersion then begin
        FUpdateVersion := LUpdateVersion;
        FAppContext.GetCommandMgr.DelayExecuteCmd(ASF_COMMAND_ID_MSGEXSERVICE,
          Format('FuncName=SendMessageEx@Id=%d@Info=%s',[Msg_AsfMem_ReUpdateSecuMain, 'SecuMain Memory Update']), 2);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TSecuMainImpl][DoUpdateTable] CacheSyncQuery and Load DataSet use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSecuMainImpl.DoUpdateTableBefore;
var
  LIndex: Integer;
begin
  for LIndex := 0 to self.FSecuInfos.GetCount - 1 do begin
    FSecuInfos.GetElement(LIndex).FIsUsed := False;
  end;
end;

procedure TSecuMainImpl.DoLoadDataSet(ADataSet: IWNDataSet);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LInnerCode: Integer;
  LInnerCodeF,
  LSecuMarket,
  LListedState,
  LSecuCategory,
  LMargin,
  LThrough,
  LSecuAbbr,
  LSecuCode,
  LSecuSpell,
  LSecuSuffix,
  LFormerAbbr,
  LFormerSpell,
  LCodeByAgent,
  LCompanyCode: IWNField;
  LSecuInfo: PSecuInfo;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  try
    ADataSet.First;
    LInnerCodeF := ADataSet.FieldByName('InnerCode');
    LSecuMarket := ADataSet.FieldByName('SecuMarket');
    LListedState := ADataSet.FieldByName('ListedState');
    LSecuCategory := ADataSet.FieldByName('SecuCategory');
    LMargin := ADataSet.FieldByName('Margin');
    LThrough := ADataSet.FieldByName('Through');
    LSecuAbbr := ADataSet.FieldByName('SecuAbbr');
    LSecuCode := ADataSet.FieldByName('SecuCode');
    LSecuSpell := ADataSet.FieldByName('SecuSpell');
    LSecuSuffix := ADataSet.FieldByName('Suffix');
    LFormerAbbr := ADataSet.FieldByName('FormerAbbr');
    LFormerSpell := ADataSet.FieldByName('FormerSpell');
    LCodeByAgent := ADataSet.FieldByName('CodeByAgent');
    LCompanyCode := ADataSet.FieldByName('CompanyCode');
    while not ADataSet.Eof do begin
      // 防止线程退出了循环还没有退出
      if FAsyncUpdateThread.IsTerminated then Exit;

      LInnerCode := LInnerCodeF.AsInteger;

      if FSecuInfoDic.TryGetValue(LInnerCode, LSecuInfo)
        and (LSecuInfo <> nil) then begin
        LSecuInfo.FIsUsed := True;
      end else begin
        New(LSecuInfo);
        FSecuInfoDic.AddOrSetValue(LInnerCode, LSecuInfo);
        LSecuInfo.FIsUsed := True;
        LSecuInfo.FInnerCode := LInnerCode;
        FSecuInfos.Add(LSecuInfo);
      end;

      DoLoadSecuInfo(LSecuInfo,
        LSecuMarket,
        LListedState,
        LSecuCategory,
        LMargin,
        LThrough,
        LSecuAbbr,
        LSecuCode,
        LSecuSpell,
        LSecuSuffix,
        LFormerAbbr,
        LFormerSpell,
        LCodeByAgent,
        LCompanyCode);

      LSecuInfo.SetUpdate;

      ADataSet.Next;
    end;

    LInnerCodeF := nil;
    LSecuMarket := nil;
    LListedState := nil;
    LSecuCategory := nil;
    LMargin := nil;
    LThrough := nil;
    LSecuAbbr := nil;
    LSecuCode := nil;
    LSecuSpell := nil;
    LSecuSuffix := nil;
    LFormerAbbr := nil;
    LFormerSpell := nil;
  finally

{$IFDEF DEBUG}
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TSecuMainImpl][DoLoadDataSet] Load DataSet use time is %d ms.', [LTick]), LTick);
{$ENDIF}
  end;
end;

procedure TSecuMainImpl.DoLoadSecuInfo(ASecuInfo: PSecuInfo;
//  AInnerCode,
  ASecuMarket,
  AListedState,
  ASecuCategory,
  AMargin,
  AThrough,
  ASecuAbbr,
  ASecuCode,
  ASecuSpell,
  ASecuSuffix,
  AFormerAbbr,
  AFormerSpell,
  ACodeByAgent,
  ACompanyCode: IWNField);
begin
  ASecuInfo^.FSecuMarket := ToMarket(StrToIntDef(ASecuMarket.AsString, 0));
  ASecuInfo^.FListedState := AListedState.AsInteger;
  ASecuInfo^.FSecuCategory := ToCategory(ASecuCategory.AsInteger);
  ASecuInfo^.FSecuMarkInfo := ToMarkInfo(StrToIntDef(AMargin.AsString, 0), StrToIntDef(AThrough.AsString, 0));
  ASecuInfo^.FSecuAbbr := ASecuAbbr.AsString;
  ASecuInfo^.FSecuCode := ASecuCode.AsString;
  ASecuInfo^.FSecuSpell := ASecuSpell.AsString;
  ASecuInfo^.FSecuSuffix := ASecuSuffix.AsString;
//  ASecuInfo^.FFormerAbbr := AFormerAbbr.AsString;
//  ASecuInfo^.FFormerSpell := AFormerSpell.AsString;
//  ASecuInfo^.FCodeByAgent := ACodeByAgent.AsString;
  ASecuInfo^.FCompanyName := ACompanyCode.AsString;
  if ACodeByAgent.AsString <> '' then begin
    FInnerCodeToHSCodeDic.AddOrSetValue(ASecuInfo^.FInnerCode, ACodeByAgent.AsString);
  end;
end;

function TSecuMainImpl.DoGetItemUpdating(AInnerCode: Integer): PSecuInfo;
begin
  if not (FSecuInfoDic.TryGetValue(AInnerCode, Result)
    and (Result <> nil)) then begin
   Result := nil;
  end;
end;

function TSecuMainImpl.DoGetItemNoUpdating(AInnerCode: Integer): PSecuInfo;
var
  LSecuInfo: PSecuInfo;
begin
  if FSecuInfoDic.TryGetValue(AInnerCode, LSecuInfo) then begin
    Result := LSecuInfo;
  end else begin
    Result := nil;
  end;
end;

end.
