unit SecuMainAdapterImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SecuMainAdapter Implementation
// Author£º      lksoulman
// Date£º        2017-12-05
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  StrUtils,
  SecuMain,
  CommonLock,
  AppContext,
  QuoteStruct,
  QuoteMngr_TLB,
  SecuMainAdapter,
  AppContextObject,
  Generics.Collections;

type

  // SecuMainAdapter Implementation
  TSecuMainAdapterImpl = class(TAppContextObject, ISecuMainAdapter)
  private
    // Lock
    FLock: TCSLock;
    // QuoteRealTime
    FQuoteRealTime: IQuoteRealTime;
    // ConceptCodeInfoStrDic
    FConceptCodeInfoStrDic: TDictionary<string, string>;
    // PreConceptCodeInfoStrDic
    FPreConceptCodeInfoStrDic: TDictionary<string, string>;
    // InnerCodeToCodeInfoStrDic
    FInnerCodeToCodeInfoStrDic: TDictionary<Integer, string>;
    // CodeInfoStrToInnerCodeDic
    FCodeInfoStrToInnerCodeDic: TDictionary<string, PSecuMainItem>;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    {ISecuMainAdapter}

    // UpdateConceptCodes
    procedure UpdateConceptCodes;
    // AddSecuMainItem
    procedure AddSecuMainItem(ASecuMainItem: PSecuMainItem);
    // SetQuoteRealTime
    procedure SetQuoteRealTime(AQuoteRealTime: IQuoteRealTime);
    // GetInnerCodeByCodeInfoStr
    function GetInnerCodeByCodeInfoStr(ACodeInfoStr: string; AInnerCode: Int64): WordBool;
    // GetCodeInfoStrByInnerCode
    function GetCodeInfoStrByInnerCode(AInnerCode: Int64; var ACodeInfoStr: string): WordBool;
  end;

implementation

{ TSecuMainAdapterImpl }

constructor TSecuMainAdapterImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FConceptCodeInfoStrDic := TDictionary<string, string>.Create;
  FPreConceptCodeInfoStrDic := TDictionary<string, string>.Create;
  FInnerCodeToCodeInfoStrDic := TDictionary<Integer, string>.Create(210000);
  FCodeInfoStrToInnerCodeDic := TDictionary<string, PSecuMainItem>.Create(210000);
end;

destructor TSecuMainAdapterImpl.Destroy;
begin
//  FQuoteRealTime := nil;
  FInnerCodeToCodeInfoStrDic.Free;
//  FCodeInfoStrToInnerCodeDic.Free;
//  FConceptCodeInfoStrDic.Free;
//  FSecuAbbrToConceptDic.Free;
  FLock.Free;
  inherited;
end;

procedure TSecuMainAdapterImpl.UpdateConceptCodes;
var
  LValue: Int64;
  LPCodeInfo: PCodeInfo;
  LSecuMainItem: PSecuMainItem;
  LCodeInfoStr, LPreCodeInfoStr: string;
  LEnum: TDictionary<string, string>.TPairEnumerator;
begin
  if FQuoteRealTime = nil then Exit;

  FLock.Lock;
  try
    LEnum := FPreConceptCodeInfoStrDic.GetEnumerator;
    while LEnum.MoveNext do begin
      if (FQuoteRealTime.GetCodeInfoByName(LEnum.Current.Key, LValue)) then begin

        LPCodeInfo := PCodeInfo(LValue);
        LCodeInfoStr := CodeInfoKey(LPCodeInfo);
        LPreCodeInfoStr := LEnum.Current.Value;
        if FCodeInfoStrToInnerCodeDic.TryGetValue(LPreCodeInfoStr, LSecuMainItem) then begin
          FCodeInfoStrToInnerCodeDic.Remove(LPreCodeInfoStr);
          FConceptCodeInfoStrDic.TryGetValue(LPreCodeInfoStr, LCodeInfoStr);
          FCodeInfoStrToInnerCodeDic.AddOrSetValue(LCodeInfoStr, LSecuMainItem);
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TSecuMainAdapterImpl.AddSecuMainItem(ASecuMainItem: PSecuMainItem);
var
  LCodeInfoStr: string;
  LAnsiName: AnsiString;
begin
  FLock.Lock;
  try
    LCodeInfoStr :=
    if not FCodeInfoStrToInnerCodeDic.ContainsKey(ASecuMainItem.FCodeInfoStr) then begin
      FInnerCodeToCodeInfoStrDic.AddOrSetValue(ASecuMainItem.FInnerCode, ASecuMainItem);
      if FConceptCodeInfoStrDic.TryGetValue(ASecuMainItem.FCodeInfoStr, LCodeInfoStr) then begin
        ASecuMainItem.FCodeInfoStr := LCodeInfoStr;
      end;
      FCodeInfoStrToInnerCodeDic.AddOrSetValue(ASecuMainItem.FCodeInfoStr, ASecuMainItem);

      case ASecuMainItem.ToGilMarket of
        0, 84:
          begin
            case ASecuMainItem.ToGilCategory of
              930:
                begin
                  LAnsiName := AnsiString(ASecuMainItem.FSecuAbbr);
                  LAnsiName := StringReplace(LAnsiName, '(', '£¨', [rfReplaceAll]);
                  LAnsiName := StringReplace(LAnsiName, ')', '£©', [rfReplaceAll]);
                  LAnsiName := LeftStr(LAnsiName, 16);
                  FSecuAbbrToConceptDic.AddOrSetValue(LAnsiName, ASecuMainItem);
                end;
            end;
          end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TSecuMainAdapterImpl.SetQuoteRealTime(AQuoteRealTime: IQuoteRealTime);
begin
  FQuoteRealTime := AQuoteRealTime;
end;

function TSecuMainAdapterImpl.GetInnerCodeByCodeInfoStr(ACodeInfoStr: string; AInnerCode: Int64): WordBool;
var
  LSecuMainItem: PSecuMainItem;
begin
  if FCodeInfoStrToInnerCodeDic.TryGetValue(ACodeInfoStr, LSecuMainItem) then begin
    Result := True;
    PInteger(AInnerCode)^ := LSecuMainItem.FInnerCode;
  end else begin
    Result := False;
  end;
end;

function TSecuMainAdapterImpl.GetCodeInfoStrByInnerCode(AInnerCode: Int64; var ACodeInfoStr: string): WordBool;
var
  LSecuMainItem: PSecuMainItem;
begin
  if FInnerCodeToCodeInfoStrDic.TryGetValue(PInteger(AInnerCode)^, LSecuMainItem) then begin
    Result := True;
    ACodeInfoStr := LSecuMainItem^.FCodeInfoStr;
  end else begin
    Result := False;
    ACodeInfoStr := '';
  end;
end;

end.
