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
  AppContext,
  CommonLock,
  CommonObject,
  WNDataSetInf,
  MsgExSubcriber,
  ExecutorThread,
  CommonDynArray,
  AppContextObject,
  CommonRefCounter,
  MsgExSubcriberImpl,
  Generics.Collections;

type

  // SecuMain implementation
  TSecuMainImpl = class(TAppContextObject, ISecuMain, ISecuMainQuery)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // IsUpdating
    FIsUpdating: Boolean;
    // UpdateVersion
    FUpdateVersion: Integer;
    // SecuMainItemCapacity
    FItemCapacity: Integer;
    // MsgExSubcriber
    FMsgExSubcriber: IMsgExSubcriber;
    // AsyncUpdateThread
    FAsyncUpdateThread: TExecutorThread;
    // SecuMainItems
    FSecuMainItems: TDynArray<PSecuMainItem>;
    // InnerCodeHSCodeDic
    FInnerCodeToHSCodeDic: TDictionary<Integer, string>;
    // SecuMainItemDic
    FSecuMainItemDic: TDictionary<Integer, PSecuMainItem>;

    // ToMarket
    function ToMarket(AValue: Integer): UInt8;
    // ToCategory
    function ToCategory(AValue: Integer): UInt16;
    // ToMarkInfo
    function ToMarkInfo(AMargin, AThrough: Integer): UInt8;
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
    procedure DoLoadSecuMainItem(ASecuMainItem: PSecuMainItem;
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
    function DoGetItemUpdating(AInnerCode: Integer): PSecuMainItem;
    // NoUpdatingGetItem
    function DoGetItemNoUpdating(AInnerCode: Integer): PSecuMainItem;
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
    // GetItemCount
    function GetItemCount: Integer;
    // GetUpdateVersion
    function GetUpdateVersion: Integer;
    // GetItem
    function GetItem(AIndex: Integer): PSecuMainItem;
    // GetHsCode
    function GetHsCode(AInnerCode: Integer): string;

    { ISecuMainQuery }

    // GetSecurityByInnerCode
    function GetSecurity(AInnerCode: Integer): PSecuMainItem;
    // GetSecuritysByInnerCodes
    function GetSecuritys(AInnerCodes: TIntegerDynArray; var ASecuMainItems: TSecuMainItemDynArray): Boolean;
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
  FSecuMainItems := TDynArray<PSecuMainItem>.Create(FItemCapacity);
  FSecuMainItemDic := TDictionary<Integer, PSecuMainItem>.Create(FItemCapacity);
  FInnerCodeToHSCodeDic := TDictionary<Integer, string>.Create(413);
  FMsgExSubcriber := TMsgExSubcriberImpl.Create(DoSecuMainCacheTableUpdate);
  FMsgExSubcriber.SetActive(True);
  FAppContext.Subcriber(MSG_BASECACHE_TABLE_SECUMAIN_UPDATE, FMsgExSubcriber);
end;

destructor TSecuMainImpl.Destroy;
begin
  StopService;
  FMsgExSubcriber.SetActive(False);
  FAppContext.UnSubcriber(MSG_BASECACHE_TABLE_SECUMAIN_UPDATE, FMsgExSubcriber);
  FMsgExSubcriber := nil;
  DoClearItems;
  FInnerCodeToHSCodeDic.Free;
  FSecuMainItemDic.Free;
  FSecuMainItems.Free;
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
  FLock.Lock;
  try
    DoUpdateTable;
  finally
    FLock.UnLock;
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

function TSecuMainImpl.GetUpdateVersion: Integer;
begin
  Result := FUpdateVersion;
end;

function TSecuMainImpl.GetItemCount: Integer;
begin
  Result := FSecuMainItems.GetCount;
end;

function TSecuMainImpl.GetItem(AIndex: Integer): PSecuMainItem;
begin
  Result := FSecuMainItems.GetElement(AIndex);
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

function TSecuMainImpl.GetSecurity(AInnerCode: Integer): PSecuMainItem;
begin
  if FIsUpdating then begin
    Result := DoGetItemUpdating(AInnerCode);
  end else begin
    Result := DoGetItemNoUpdating(AInnerCode);
  end;
end;

function TSecuMainImpl.GetSecuritys(AInnerCodes: TIntegerDynArray; var ASecuMainItems: TSecuMainItemDynArray): Boolean;
var
  LSecuMainItem: PSecuMainItem;
  LIndex, LCount, LTotalCount: Integer;
begin
  Result := True;
  LTotalCount := Length(AInnerCodes);
  SetLength(ASecuMainItems, LTotalCount);
  if LTotalCount <= 0 then Exit;

  LCount := 0;
  for LIndex := 0 to LTotalCount - 1 do begin
    LSecuMainItem := GetSecurity(AInnerCodes[LIndex]);
    if LSecuMainItem <> nil then begin
      ASecuMainItems[LCount] := LSecuMainItem;
      Inc(LCount);
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

procedure TSecuMainImpl.DoClearItems;
var
  LIndex: Integer;
  LPSecuMainItem: PSecuMainItem;
begin
  for LIndex := 0 to FSecuMainItems.GetCount - 1 do begin
    LPSecuMainItem := FSecuMainItems.GetElement(LIndex);
    if LPSecuMainItem <> nil then begin
      Dispose(LPSecuMainItem);
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
          FLock.Lock;
          try
            DoUpdateTable;
          finally
            FLock.UnLock;
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
          Format('FuncName=SendMessageEx@Id=%d@Info=%s',[MSG_SECUMAIN_MEMORY_UPDATE, 'SecuMain Memory Update']), 2);
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
  for LIndex := 0 to self.FSecuMainItems.GetCount - 1 do begin
    FSecuMainItems.GetElement(LIndex).FIsUsed := False;
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
  LSecuMainItem: PSecuMainItem;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  FIsUpdating := True;
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

      if FSecuMainItemDic.TryGetValue(LInnerCode, LSecuMainItem)
        and (LSecuMainItem <> nil) then begin
        LSecuMainItem.FIsUsed := True;
      end else begin
        New(LSecuMainItem);
        FSecuMainItemDic.AddOrSetValue(LInnerCode, LSecuMainItem);
        LSecuMainItem.FIsUsed := True;
        LSecuMainItem.FInnerCode := LInnerCode;
        FSecuMainItems.Add(LSecuMainItem);
      end;

      DoLoadSecuMainItem(LSecuMainItem,
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

      LSecuMainItem.SetUpdate;

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
    FIsUpdating := False;

{$IFDEF DEBUG}
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TSecuMainImpl][DoLoadDataSet] Load DataSet use time is %d ms.', [LTick]), LTick);
{$ENDIF}
  end;
end;

procedure TSecuMainImpl.DoLoadSecuMainItem(ASecuMainItem: PSecuMainItem;
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
  ASecuMainItem^.FSecuMarket := ToMarket(StrToIntDef(ASecuMarket.AsString, 0));
  ASecuMainItem^.FListedState := AListedState.AsInteger;
  ASecuMainItem^.FSecuCategory := ToCategory(ASecuCategory.AsInteger);
  ASecuMainItem^.FSecuMarkInfo := ToMarkInfo(StrToIntDef(AMargin.AsString, 0), StrToIntDef(AThrough.AsString, 0));
  ASecuMainItem^.FSecuAbbr := ASecuAbbr.AsString;
  ASecuMainItem^.FSecuCode := ASecuCode.AsString;
  ASecuMainItem^.FSecuSpell := ASecuSpell.AsString;
  ASecuMainItem^.FSecuSuffix := ASecuSuffix.AsString;
//  ASecuMainItem^.FFormerAbbr := AFormerAbbr.AsString;
//  ASecuMainItem^.FFormerSpell := AFormerSpell.AsString;
//  ASecuMainItem^.FCodeByAgent := ACodeByAgent.AsString;
  ASecuMainItem^.FCompanyName := ACompanyCode.AsString;
  if ACodeByAgent.AsString <> '' then begin
    FInnerCodeToHSCodeDic.AddOrSetValue(ASecuMainItem^.FInnerCode, ACodeByAgent.AsString);
  end;
end;

function TSecuMainImpl.DoGetItemUpdating(AInnerCode: Integer): PSecuMainItem;
begin
  if not (FSecuMainItemDic.TryGetValue(AInnerCode, Result)
    and (Result <> nil)) then begin
   Result := nil;
  end;
end;

function TSecuMainImpl.DoGetItemNoUpdating(AInnerCode: Integer): PSecuMainItem;
begin
  if not (FSecuMainItemDic.TryGetValue(AInnerCode, Result)
    and (Result <> nil)) and Result.FIsUsed then begin
   Result := nil;
  end;
end;

end.
