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
  MsgType,
  Windows,
  Classes,
  StrUtils,
  SysUtils,
  SecuMain,
  AppContext,
  CommonLock,
  MsgService,
  MsgReceiver,
  CommonObject,
  WNDataSetInf,
  ExecutorThread,
  CommonDynArray,
  SecuMainAdapter,
  KeySearchEngine,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // SecuMain implementation
  TSecuMainImpl = class(TAppContextObject, ISecuMain, ISecuMainQuery)
  private
    // Lock
    FLock: TCSLock;
    // IsUpdating
    FIsUpdating: Boolean;
    // SecuMainItem Capacity
    FItemCapacity: Integer;
    // SecuMainAdapter
    FSecuMainAdapter: ISecuMainAdapter;
    // KeySearchEngine
    FKeySearchEngine: IKeySearchEngine;
    // Asynchronous update Thread
    FAsyncUpdateThread: TExecutorThread;
    // SecuMainItem List
    FSecuMainItems: TDynArray<PSecuMainItem>;
    // SecuMainItem Dictionary
    FSecuMainItemDic: TDictionary<Integer, PSecuMainItem>;
    // SecuMarket20HsCodeDic
    FSecuMarket20HsCodeDic: TDictionary<Integer, string>;

    // ToMarket
    function ToMarket(AValue: Integer): UInt8;
    // ToCategory
    function ToCategory(AValue: Integer): UInt16;
    // ToMarkInfo
    function ToMarkInfo(AMargin, AThrough: Integer): UInt8;
    // ToCodeInfoStr
    function ToCodeInfoStr(ASecuMainItem: PSecuMainItem; ACodeByAgent, ACompanyCode: string): string;
  protected
    // Clear
    procedure DoClearItems;
    // AddSecuMarket20HsCodes
    procedure AddSecuMarket20HsCodes;
    // Async Update Excecute
    procedure DoAsyncUpdateExecute(AObject: TObject);

    // Update Table
    procedure DoUpdateTable;
    // Update Table After
    procedure DoUpdateTableAfter;
    // Update Table Before
    procedure DoUpdateTableBefore;
    // Load DataSet
    procedure DoLoadDataSet(ADataSet: IWNDataSet);
    // Load SecuMaintItem
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
      AFormerSpell: IWNField);
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

    // Lock
    procedure Lock;
    // Un Lock
    procedure UnLock;
    // Update
    procedure Update;
    // AsyncUpdate
    procedure AsyncUpdate;
    // Get Item Count
    function GetItemCount: Integer;
    // Get Item
    function GetItem(AIndex: Integer): PSecuMainItem;

    { ISecuMainQuery }

    // Get Security By InnerCode
    function GetSecurity(AInnerCode: Integer): PSecuMainItem; safecall;
    // Get Securitys By InnerCodes
    function GetSecuritys(AInnerCodes: TIntegerDynArray; var ASecuMainItems: TSecuMainItemDynArray): Boolean; safecall;
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
  FIsUpdating := False;
  FLock := TCSLock.Create;
  FItemCapacity := 220000;
  FAsyncUpdateThread := TExecutorThread.Create;
  FAsyncUpdateThread.ThreadMethod := DoAsyncUpdateExecute;
  FSecuMainItems := TDynArray<PSecuMainItem>.Create(FItemCapacity);
  FSecuMainItemDic := TDictionary<Integer, PSecuMainItem>.Create(FItemCapacity);
  FSecuMarket20HsCodeDic := TDictionary<Integer, string>.Create(27);

  FSecuMainAdapter := FAppContext.FindInterface(ASF_COMMAND_ID_SECUMAINADAPTER) as ISecuMainAdapter;
  FKeySearchEngine := FAppContext.FindInterface(ASF_COMMAND_ID_KEYSEARCHENGINE) as IKeySearchEngine;

  AddSecuMarket20HsCodes;
end;

destructor TSecuMainImpl.Destroy;
begin
  FKeySearchEngine := nil;
  FSecuMainAdapter := nil;

  FAsyncUpdateThread.ShutDown;
  DoClearItems;
  FSecuMarket20HsCodeDic.Free;
  FSecuMainItemDic.Free;
  FSecuMainItems.Free;
  FLock.Free;
  inherited;
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
  DoUpdateTable;
end;

procedure TSecuMainImpl.AsyncUpdate;
begin
  FLock.Lock;
  try
    if not FAsyncUpdateThread.IsStart then begin
      FAsyncUpdateThread.StartEx;
    end;
    FAsyncUpdateThread.ResumeEx;
  finally
    FLock.UnLock;
  end;
end;

function TSecuMainImpl.GetItemCount: Integer;
begin
  Result := FSecuMainItems.GetCount;
end;

function TSecuMainImpl.GetItem(AIndex: Integer): PSecuMainItem;
begin
  Result := FSecuMainItems.GetElement(AIndex);
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

function TSecuMainImpl.ToCodeInfoStr(ASecuMainItem: PSecuMainItem; ACodeByAgent, ACompanyCode: string): string;
var
  LHSCode: string;
  LSecuMarket, LSecuCategory, LListedState: Integer;

  function GetCodeInfoStr(AHSCode: string): string;
  begin
    if (LSecuMarket in [76,77,78,79]) then begin
      Result := AHSCode;
    end else begin
      Result := Copy(AHSCode, 1, 6);
    end;
    if LSecuCategory = 110 then begin
      Result := AHSCode + '_' + SUFFIX_OPT; // 个股期权
      Exit;
    end;

    case LSecuMarket of
      83:
        begin // 上海市场
          if (LSecuCategory = 4) then begin // 指数
            if (Pos('2D', AHsCode) = 1)
              or (ASecuMainItem.FSecuSuffix = 'CSI') then begin// 中证/申万指数
              Result := Result + '_' + SUFFIX_OT
            end else if (Pos('CI', AHsCode) = 1) then begin // 中信指数
              Result := Copy(AHsCode, 3, 100) + '_' + SUFFIX_ZXI
            end else begin
              Result := Result + '_' + SUFFIX_SH;
            end;
          end else begin  // 上海证券交易所
            Result := Result + '_' + SUFFIX_SH;
          end;
        end;
      90:
        Result := Result + '_' + SUFFIX_SZ; // 深圳证券交易所
      81:
        Result := Result + '_' + SUFFIX_OC; // 三板市场
      10, 13, 15, 19, 20:
        Result := Result + '_' + SUFFIX_FU; // 期货
      72:
        Result := Result + '_' + SUFFIX_HK; // 香港联交所
      76,77,78,79:
        Result := Result + '_' + SUFFIX_US; // 美股
      84:
        begin
          case LSecuCategory of
            910, 930:
              begin
                Result := Copy(Result, 3, 6) + '_' + SUFFIX_OT; // 概念板块去掉前面的28
              end;
            920:
              begin
                Result := 'DY' + Copy(AHsCode, 5, 6) + '_' + SUFFIX_OT; // 地域板块前面的2800替换为DY
              end;
          else
            Result := Result + '_' + SUFFIX_OT; // 其他指数
          end;
        end;
      89:
        Result := AHsCode + '_' + SUFFIX_IB; // 银行间债券
          0:
        case LSecuCategory of
          910, 930:
            begin
              Result := Copy(Result, 3, 6) + '_' + SUFFIX_OT; // 概念板块去掉前面的28
            end;
          920:
            begin
              Result := 'DY' + Copy(AHsCode, 5, 6) + '_' + SUFFIX_OT; // 地域板块前面的2800替换为DY
            end;
        end;
    end;
  end;
begin
  Result := '';
  LSecuMarket := ASecuMainItem^.ToGilMarket;
  LListedState := ASecuMainItem^.FListedState;
  LSecuCategory := ASecuMainItem^.ToGilCategory;

  if ((LSecuMarket in [83,90,81,10,13,15,19,20,72,89,76,77,78,79]) and (LListedState in [1, 3]))
    or ((LSecuMarket = 84) and (LSecuCategory = 4) and (LListedState = 1))
    or ((LSecuCategory = 920) and (LListedState = 1))
    or ((LSecuCategory = 930) and (LListedState = 1))
    or ((LSecuCategory = 1) and (LSecuMarket = 9)) then begin

    if (ASecuMainItem^.FSecuSuffix = 'CSI') then begin  // 中证指数
      LHSCode := '';
    end else if LSecuCategory = 110 then begin    // 个股期权
      LHSCode := ACompanyCode;
    end else begin
      if LSecuMarket = 20 then begin // 中金所
        if not FSecuMarket20HsCodeDic.TryGetValue(ASecuMainItem^.FInnerCode, LHSCode) then begin
          LHSCode := '';
        end;
      end else if (LSecuMarket = 83) then begin // 根据恒生提供的转换规则，对沪深指数中以‘000’开头的指数代码做转化
        if (Pos('000', ASecuMainItem^.FSecuCode) = 1)
          and (LSecuCategory = 4) then begin
          if (ASecuMainItem^.FSecuCode = '000001') then begin
            LHSCode := '1A0001'
          end else if (ASecuMainItem^.FSecuCode = '000002') then begin
            LHSCode := '1A0002'
          end else if (ASecuMainItem^.FSecuCode = '000003') then begin
            LHSCode := '1A0003'
          end else begin
            LHSCode := ReplaceStr(ASecuMainItem^.FSecuCode, '000', '1B0');
          end;
        end else begin
          LHSCode := ACodeByAgent;
        end;
      end else begin
        LHSCode := ACodeByAgent;
      end;
    end;

    if Trim(LHSCode) = '' then begin
      LHSCode := ASecuMainItem^.FSecuCode;
    end;

    Result := GetCodeInfoStr(LHSCode);
  end;
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

procedure TSecuMainImpl.AddSecuMarket20HsCodes;
begin
  FSecuMarket20HsCodeDic.AddOrSetValue(2006539, 'IC0001');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006540, 'IC0002');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006541, 'IC0003');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006542, 'IC0004');
  FSecuMarket20HsCodeDic.AddOrSetValue(2000440, 'IF0001');
  FSecuMarket20HsCodeDic.AddOrSetValue(2000441, 'IF0002');
  FSecuMarket20HsCodeDic.AddOrSetValue(2000442, 'IF0003');
  FSecuMarket20HsCodeDic.AddOrSetValue(2000443, 'IF0004');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006535, 'IH0001');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006536, 'IH0002');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006537, 'IH0003');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006538, 'IH0004');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006532, 'T0001');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006533, 'T0002');
  FSecuMarket20HsCodeDic.AddOrSetValue(2006534, 'T0003');
  FSecuMarket20HsCodeDic.AddOrSetValue(2004449, 'TF0001');
  FSecuMarket20HsCodeDic.AddOrSetValue(2004450, 'TF0002');
  FSecuMarket20HsCodeDic.AddOrSetValue(2004441, 'TF0003');
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
          DoUpdateTable;
        end;
    end;
  end;
end;

procedure TSecuMainImpl.DoUpdateTable;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    if FAppContext = nil then Exit;

    DoUpdateTableBefore;

    LDataSet := FAppContext.CacheSyncQuery(ctBaseData, SQL_SECUMAIN);

    // 防止线程退出了循环还没有退出
    if FAsyncUpdateThread.IsTerminated then Exit;

    if (LDataSet <> nil) then begin
      if (LDataSet.RecordCount > 0) then begin
        DoLoadDataSet(LDataSet);
      end;
      LDataSet := nil;
    end else begin
      FAppContext.SysLog(llWARN, '[TSecuMainImpl][DoUpdateTable] Load dateset is nil.');
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TSecuMainImpl][DoUpdateTable] CacheSyncQuery and Load DataSet use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSecuMainImpl.DoUpdateTableAfter;
begin

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
  if FKeySearchEngine <> nil then begin
    FKeySearchEngine.SetIsUpdate(True);
    FKeySearchEngine.ClearKeySecuMainItems;
  end;
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
        LFormerSpell);

      LSecuMainItem.SetUpdate;

      if FSecuMainAdapter <> nil then begin
        LSecuMainItem.FCodeInfoStr := ToCodeInfoStr(LSecuMainItem, LCodeByAgent.AsString, LCompanyCode.AsString);
        FSecuMainAdapter.AddSecuMainItem(LSecuMainItem);
      end;

      if FKeySearchEngine <> nil then begin
        FKeySearchEngine.AddSecuMainItem(LSecuMainItem);
      end;

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
    if FKeySearchEngine <> nil then begin
      FKeySearchEngine.SetIsUpdate(False);
    end;
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
  AFormerSpell: IWNField);
begin
  ASecuMainItem^.FSecuMarket := ToMarket(StrToIntDef(ASecuMarket.AsString, 0));
  ASecuMainItem^.FListedState := AListedState.AsInteger;
  ASecuMainItem^.FSecuCategory := ToCategory(ASecuCategory.AsInteger);
  ASecuMainItem^.FSecuMarkInfo := ToMarkInfo(StrToIntDef(AMargin.AsString, 0), StrToIntDef(AThrough.AsString, 0));
  ASecuMainItem^.FSecuAbbr := ASecuAbbr.AsString;
  ASecuMainItem^.FSecuCode := ASecuCode.AsString;
  ASecuMainItem^.FSecuSpell := ASecuSpell.AsString;
  ASecuMainItem^.FSecuSuffix := ASecuSuffix.AsString;
  ASecuMainItem^.FFormerAbbr := AFormerAbbr.AsString;
  ASecuMainItem^.FFormerSpell := AFormerSpell.AsString;
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
