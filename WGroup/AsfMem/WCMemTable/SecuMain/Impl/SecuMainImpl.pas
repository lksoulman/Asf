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
    // Is Updating table
    FIsUpdating: Boolean;
    // SecuMainItem Capacity
    FItemCapacity: Integer;
    // KeySearchEngine
    FKeySearchEngine: IKeySearchEngine;
    // Asynchronous update Thread
    FAsyncUpdateThread: TExecutorThread;
    // SecuMainItem List
    FSecuMainItems: TDynArray<PSecuMainItem>;
    // SecuMainItem Dictionary
    FSecuMainItemDic: TDictionary<Integer, PSecuMainItem>;

    // To SecuMarket
    function ToMarket(AValue: Integer): UInt8;
    // To SecuCategory
    function ToCategory(AValue: Integer): UInt16;
    // To SecuMarkInfo
    function ToMarkInfo(AMargin, AThrough: Integer): UInt8;
  protected
    // Clear
    procedure DoClearItems;
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
    // Updating Get Item
    function DoGetItemUpdating(AInnerCode: Integer): PSecuMainItem;
    // No Updating Get Item
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
    // Get Item By InnerCode
    function GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem;

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
  FItemCapacity := 200000;
  FAsyncUpdateThread := TExecutorThread.Create;
  FAsyncUpdateThread.ThreadMethod := DoAsyncUpdateExecute;
  FSecuMainItems := TDynArray<PSecuMainItem>.Create(FItemCapacity);
  FSecuMainItemDic := TDictionary<Integer, PSecuMainItem>.Create(FItemCapacity);

  FKeySearchEngine := FAppContext.FindInterface(ASF_COMMAND_ID_KEYSEARCHENGINE) as IKeySearchEngine;
end;

destructor TSecuMainImpl.Destroy;
begin
  FKeySearchEngine := nil;

  FAsyncUpdateThread.ShutDown;
  DoClearItems;
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

function TSecuMainImpl.GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem;
begin
  if FIsUpdating then begin
    Result := DoGetItemUpdating(AInnerCode);
  end else begin
    Result := DoGetItemNoUpdating(AInnerCode);
  end;
end;

function TSecuMainImpl.GetSecurity(AInnerCode: Integer): PSecuMainItem;
begin
  Result := GetItemByInnerCode(AInnerCode);
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
    LSecuMainItem := GetItemByInnerCode(AInnerCodes[LIndex]);
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
  LFormerSpell: IWNField;
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

      DoLoadSecuMainItem(LSecuMainItem, LSecuMarket,
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

      if FKeySearchEngine <> nil then begin
        FKeySearchEngine.AddSecuMainItem(LSecuMainItem);
      end;

      ADataSet.Next;
    end;
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
//  ASecuMainItem^.FInnerCode := ;
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
