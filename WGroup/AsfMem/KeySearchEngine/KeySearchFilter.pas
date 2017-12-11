unit KeySearchFilter;

////////////////////////////////////////////////////////////////////////////////
//
// Description： KeySearchFilter
// Author：      lksoulman
// Date：        2017-11-24
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain,
  ExecutorThread,
  CommonDynArray,
  CommonRefCounter,
  Generics.Collections;

type

  // CharType
  TCharType = (ctNomeric,            // 数字
               ctAlpha,              // 字母
               ctChinese             // 中文
               );

  // Result Call Back
  TOnResultCallBack = procedure(ASecuMainItems: TDynArray<PSecuMainItem>) of Object;

  TKeySearchFilter = class;

  // KeySearchObject
  TKeySearchObject = class(TAutoObject)
  private
    // Key
    FKey: string;
    // IsStop
    FIsStop: Boolean;
    // KeyLen
    FKeyLen: Integer;
    // MaxCount
    FMaxCount: Integer;
    // Char Type
    FCharType: TCharType;
    // SearchThread
    FSearchThread: TExecutorThread;
    // ResultCallBack
    FOnResultCallBack: TNotifyEvent;
    // ResultItems
    FResultItems: TDynArray<PSecuMainItem>;
    // KeySearchFilters
    FKeySearchFilters: TList<TKeySearchFilter>;

    //
    FStockHSKeySearchFilter: TKeySearchFilter;
    //
    FStockBKeySearchFilter: TKeySearchFilter;
    //
    FStockNewOTCKeySearchFilter: TKeySearchFilter;
    //
    FFundKeySearchFilter: TKeySearchFilter;
    //
    FIndexKeySearchFilter: TKeySearchFilter;
    //
    FBondKeySearchFilter: TKeySearchFilter;
    //
    FFutureKeySearchFilter: TKeySearchFilter;
    //
    FStockHKKeySearchFilter: TKeySearchFilter;
    //
    FStockUSKeySearchFilter: TKeySearchFilter;
  protected
    // ClearFilters
    procedure DoClearFilters;
    // GetIsMaxLimited
    function GetIsMaxLimited: Boolean;
    // GetIsTerminated
    function GetIsTerminated: Boolean;
    // FuzzySearch
    procedure DoFuzzyKeySearchFilteres;
    // SearchExecute
    procedure DoSearchExecute(AObject: TObject);
    // GetKeySearchFilter
    function GetKeySearchFilter(ASecuMainItem: PSecuMainItem): TKeySearchFilter;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Start
    procedure Start;
    // ShutDown
    procedure ShutDown;
    // Clear SecuMainItems
    procedure ClearSecuMainItems;
    // AddSecuMainItem
    procedure AddSecuMainItem(ASecuMainItem: PSecuMainItem);
    // SetOnResultCallBack
    procedure SetResultCallBack(AOnResultCallBack: TNotifyEvent);

    property Key: string read FKey write FKey;
    property IsMaxLimited: Boolean read GetIsMaxLimited;
    property IsStop: Boolean read FIsStop write FIsStop;
    property KeyLen: Integer read FKeyLen write FKeyLen;
    property IsTerminated: Boolean read GetIsTerminated;
    property MaxCount: Integer read FMaxCount write FMaxCount;
    property CharType: TCharType read FCharType write FCharType;
    property ResultItems: TDynArray<PSecuMainItem> read FResultItems;
  end;

  // KeySearchFilter
  TKeySearchFilter = class(TAutoObject)
  private
    // SearchType
    FSearchType: Integer;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
    // SecuMainItems
    FSecuMainItems: TDynArray<PSecuMainItem>;
  protected
    // Filter
    function DoFilter(ASecuMainItem: PSecuMainItem): Boolean;
  public
    // Constructor
    constructor Create(AObject: TKeySearchObject); reintroduce;
    // Destructor
    destructor Destroy; override;
    // FuzzySearchKey
    procedure FuzzySearchKey;
    // Clear SecuMainItems
    procedure ClearSecuMainItems;
    // AddSecuMainItem
    procedure AddSecuMainItem(ASecuMainItem: PSecuMainItem);

    property SearchType: Integer read FSearchType write FSearchType;
  end;

implementation

{ TKeySearchObject }

constructor TKeySearchObject.Create;
begin
  inherited;
  FMaxCount := 200;
  FResultItems := TDynArray<PSecuMainItem>.Create;
  FKeySearchFilters := TList<TKeySearchFilter>.Create;
  FSearchThread := TExecutorThread.Create;
  FSearchThread.ThreadMethod := DoSearchExecute;
end;

destructor TKeySearchObject.Destroy;
begin
  DoClearFilters;
  FKeySearchFilters.Free;
  FResultItems.Free;
  inherited;
end;

procedure TKeySearchObject.Start;
begin
  FSearchThread.StartEx;
end;

procedure TKeySearchObject.ShutDown;
begin
  FSearchThread.ShutDown;
end;

procedure TKeySearchObject.ClearSecuMainItems;
var
  LIndex: Integer;
  LKeySearchFilter: TKeySearchFilter;
begin
  for LIndex := 0 to FKeySearchFilters.Count - 1 do begin
    LKeySearchFilter := FKeySearchFilters.Items[LIndex];
    if LKeySearchFilter <> nil then begin
      LKeySearchFilter.ClearSecuMainItems;
    end;
  end;
end;

procedure TKeySearchObject.AddSecuMainItem(ASecuMainItem: PSecuMainItem);
var
  LKeySearchFilter: TKeySearchFilter;
begin
  LKeySearchFilter := GetKeySearchFilter(ASecuMainItem);
  if LKeySearchFilter <> nil then begin
    LKeySearchFilter.AddSecuMainItem(ASecuMainItem);
  end;
end;

procedure TKeySearchObject.DoClearFilters;
var
  LIndex: Integer;
  LKeySearchFilter: TKeySearchFilter;
begin
  for LIndex := 0 to FKeySearchFilters.Count - 1 do begin
    LKeySearchFilter := FKeySearchFilters.Items[LIndex];
    if LKeySearchFilter <> nil then begin
      LKeySearchFilter.Free;
    end;
  end;
  FKeySearchFilters.Clear;
end;

function TKeySearchObject.GetIsMaxLimited: Boolean;
begin
  Result := FResultItems.GetCount >= FMaxCount;
end;

function TKeySearchObject.GetIsTerminated: Boolean;
begin
  Result := FSearchThread.IsTerminated;
end;

procedure TKeySearchObject.DoFuzzyKeySearchFilteres;
var
  LIndex: Integer;
  LKeySearchFilter: TKeySearchFilter;
begin
  for LIndex := 0 to FKeySearchFilters.Count - 1 do begin
    if FIsStop
      or IsMaxLimited
      or FSearchThread.IsTerminated then Exit;

    LKeySearchFilter := FKeySearchFilters.Items[LIndex];
    if LKeySearchFilter <> nil then begin
      LKeySearchFilter.FuzzySearchKey;
    end;
  end;
end;

procedure TKeySearchObject.DoSearchExecute(AObject: TObject);
begin
  while not FSearchThread.IsTerminated do begin
    if FSearchThread.IsTerminated then Exit;

    case FSearchThread.WaitForEx of
      WAIT_OBJECT_0:
        begin
          if FSearchThread.IsTerminated then Exit;

          FIsStop := False;
          DoFuzzyKeySearchFilteres;
          if Assigned(FOnResultCallBack) then begin
            FOnResultCallBack(FResultItems);
          end;
        end;
    end;
  end;
end;

function TKeySearchObject.GetKeySearchFilter(ASecuMainItem: PSecuMainItem): TKeySearchFilter;
begin
  case ASecuMainItem.FSearchType of
    // 沪深股票
    SEARCHTYPE_STOCK_HS:
      begin
        if FStockHSKeySearchFilter <> nil then begin
          Result := FStockHSKeySearchFilter;
        end else begin
          FStockHSKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FStockHSKeySearchFilter);
          Result := FStockHSKeySearchFilter;
        end;
      end;
    // B股
    SEARCHTYPE_STOCK_B:
      begin
        if FStockBKeySearchFilter <> nil then begin
          Result := FStockBKeySearchFilter;
        end else begin
          FStockBKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FStockBKeySearchFilter);
          Result := FStockBKeySearchFilter;
        end;
      end;
    // 新三板
    SEARCHTYPE_STOCK_NEWOTC:
      begin
        if FStockNewOTCKeySearchFilter <> nil then begin
          Result := FStockNewOTCKeySearchFilter;
        end else begin
          FStockNewOTCKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FStockNewOTCKeySearchFilter);
          Result := FStockNewOTCKeySearchFilter;
        end;
      end;
    // 基金
    SEARCHTYPE_FUND:
      begin
        if FFundKeySearchFilter <> nil then begin
          Result := FFundKeySearchFilter;
        end else begin
          FFundKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FFundKeySearchFilter);
          Result := FFundKeySearchFilter;
        end;
      end;
    // 指数
    SEARCHTYPE_INDEX:
      begin
        if FIndexKeySearchFilter <> nil then begin
          Result := FIndexKeySearchFilter;
        end else begin
          FIndexKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FIndexKeySearchFilter);
          Result := FIndexKeySearchFilter;
        end;
      end;
    // 债券
    SEARCHTYPE_BOND:
      begin
        if FBondKeySearchFilter <> nil then begin
          Result := FBondKeySearchFilter;
        end else begin
          FBondKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FBondKeySearchFilter);
          Result := FBondKeySearchFilter;
        end;
      end;
    // 期货
    SEARCHTYPE_FUTURE:
      begin
        if FFutureKeySearchFilter <> nil then begin
          Result := FFutureKeySearchFilter;
        end else begin
          FFutureKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FFutureKeySearchFilter);
          Result := FFutureKeySearchFilter;
        end;
      end;
    // 港股
    SEARCHTYPE_STOCK_HK:
      begin
        if FStockHKKeySearchFilter <> nil then begin
          Result := FStockHKKeySearchFilter;
        end else begin
          FStockHKKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FStockHKKeySearchFilter);
          Result := FStockHKKeySearchFilter;
        end;
      end;
    // 美股
    SEARCHTYPE_STOCK_US:
      begin
        if FStockUSKeySearchFilter <> nil then begin
          Result := FStockUSKeySearchFilter;
        end else begin
          FStockUSKeySearchFilter := TKeySearchFilter.Create(Self);
          FKeySearchFilters.Add(FStockUSKeySearchFilter);
          Result := FStockUSKeySearchFilter;
        end;
      end;
  else
    begin
      if FStockHSKeySearchFilter <> nil then begin
        Result := FStockHSKeySearchFilter;
      end else begin
        FStockHSKeySearchFilter := TKeySearchFilter.Create(Self);
        FKeySearchFilters.Add(FStockHSKeySearchFilter);
        Result := FStockHSKeySearchFilter;
      end;
    end;
  end;
end;

procedure TKeySearchObject.SetResultCallBack(AOnResultCallBack: TNotifyEvent);
begin
  FOnResultCallBack := AOnResultCallBack;
end;

{ TKeySearchFilter }

constructor TKeySearchFilter.Create(AObject: TKeySearchObject);
begin
  inherited Create;
  FKeySearchObject := AObject;
  FSecuMainItems := TDynArray<PSecuMainItem>.Create;
end;

destructor TKeySearchFilter.Destroy;
begin
  FSecuMainItems.Free;
  inherited;
end;

procedure TKeySearchFilter.FuzzySearchKey;
var
  LIndex: Integer;
  LSecuMainItem: PSecuMainItem;
begin
  for LIndex := 0 to FSecuMainItems.GetCount - 1 do begin
    if FKeySearchObject.FIsStop
      or FKeySearchObject.IsTerminated
      or FKeySearchObject.IsMaxLimited then Exit;

    LSecuMainItem := FSecuMainItems.GetElement(LIndex);
    if (LSecuMainItem <> nil)
      and DoFilter(LSecuMainItem)then begin
      FKeySearchObject.FResultItems.Add(LSecuMainItem);
    end;
  end;
end;

procedure TKeySearchFilter.ClearSecuMainItems;
begin
  FSecuMainItems.ClearCount;
end;

procedure TKeySearchFilter.AddSecuMainItem(ASecuMainItem: PSecuMainItem);
begin
  FSecuMainItems.Add(ASecuMainItem);
end;

function TKeySearchFilter.DoFilter(ASecuMainItem: PSecuMainItem): Boolean;
begin
  Result := False;
  case FKeySearchObject.FCharType of
    ctNomeric:
      begin
        if Pos(FKeySearchObject.FKey, ASecuMainItem^.FSecuCode) > 0 then begin
          Result := True;
        end;
      end;
    ctAlpha:
      begin
        if (Pos(FKeySearchObject.FKey, ASecuMainItem.FSecuSpell) > 0)
          or (Pos(FKeySearchObject.FKey, ASecuMainItem.FSecuAbbr) > 0)
          or (Pos(FKeySearchObject.FKey, ASecuMainItem.FSecuCode) > 0) then begin
          Result := True;
        end;
      end;
    ctChinese:
      begin
        if (Pos(FKeySearchObject.FKey, ASecuMainItem.FSecuAbbr) > 0) then begin
          Result := True;
        end else begin

//          if ASecuMainItem.FFormerAbbr = '' then Exit;
//
//          if Pos(FKeySearchObject.FKey, ASecuMainItem.FFormerAbbr) > 0 then begin
//            Result := True;
//          end;
        end;
      end;
  end;
end;

end.
