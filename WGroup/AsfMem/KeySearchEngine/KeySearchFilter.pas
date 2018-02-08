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
    FResultItems: TDynArray<PSecuInfo>;
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
    // DoAddKeySearchFilters
    procedure DoAddKeySearchFilters;
    // FuzzyKeySearchFilters
    procedure DoFuzzyKeySearchFilters;
    // SearchExecute
    procedure DoSearchExecute(AObject: TObject);
    // GetKeySearchFilter
    function GetKeySearchFilter(ASecuInfo: PSecuInfo): TKeySearchFilter;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Start
    procedure Start;
    // ShutDown
    procedure ShutDown;
    // StartSearch
    procedure StartSearch;
    // ClearSecuInfos
    procedure ClearSecuInfos;
    // AddSecuInfo
    procedure AddSecuInfo(ASecuInfo: PSecuInfo);
    // SetOnResultCallBack
    procedure SetResultCallBack(AOnResultCallBack: TNotifyEvent);

    property Key: string read FKey write FKey;
    property IsMaxLimited: Boolean read GetIsMaxLimited;
    property IsStop: Boolean read FIsStop write FIsStop;
    property KeyLen: Integer read FKeyLen write FKeyLen;
    property IsTerminated: Boolean read GetIsTerminated;
    property MaxCount: Integer read FMaxCount write FMaxCount;
    property CharType: TCharType read FCharType write FCharType;
    property ResultItems: TDynArray<PSecuInfo> read FResultItems;
  end;

  // KeySearchFilter
  TKeySearchFilter = class(TAutoObject)
  private
    // SearchType
    FSearchType: Integer;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
    // SecuInfos
    FSecuInfos: TDynArray<PSecuInfo>;
  protected
    // Filter
    function DoFilter(ASecuInfo: PSecuInfo): Boolean;
  public
    // Constructor
    constructor Create(AObject: TKeySearchObject); reintroduce;
    // Destructor
    destructor Destroy; override;
    // FuzzySearchKey
    procedure FuzzySearchKey;
    // Clear SecuInfos
    procedure ClearSecuInfos;
    // AddSecuInfo
    procedure AddSecuInfo(ASecuInfo: PSecuInfo);

    property SearchType: Integer read FSearchType write FSearchType;
  end;

implementation

{ TKeySearchObject }

constructor TKeySearchObject.Create;
begin
  inherited;
  FMaxCount := 200;
  FResultItems := TDynArray<PSecuInfo>.Create;
  FKeySearchFilters := TList<TKeySearchFilter>.Create;
  FSearchThread := TExecutorThread.Create;
  FSearchThread.ThreadMethod := DoSearchExecute;
  DoAddKeySearchFilters;
end;

destructor TKeySearchObject.Destroy;
begin
  FOnResultCallBack := nil;
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
  FOnResultCallBack := nil;
  FSearchThread.ShutDown;
end;

procedure TKeySearchObject.StartSearch;
begin
  FSearchThread.ResumeEx;
end;

procedure TKeySearchObject.ClearSecuInfos;
var
  LIndex: Integer;
  LKeySearchFilter: TKeySearchFilter;
begin
  for LIndex := 0 to FKeySearchFilters.Count - 1 do begin
    LKeySearchFilter := FKeySearchFilters.Items[LIndex];
    if LKeySearchFilter <> nil then begin
      LKeySearchFilter.ClearSecuInfos;
    end;
  end;
end;

procedure TKeySearchObject.AddSecuInfo(ASecuInfo: PSecuInfo);
var
  LKeySearchFilter: TKeySearchFilter;
begin
  LKeySearchFilter := GetKeySearchFilter(ASecuInfo);
  if LKeySearchFilter <> nil then begin
    LKeySearchFilter.AddSecuInfo(ASecuInfo);
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

procedure TKeySearchObject.DoAddKeySearchFilters;
begin
  FStockHSKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FStockHSKeySearchFilter);
  FStockBKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FStockBKeySearchFilter);
  FStockNewOTCKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FStockNewOTCKeySearchFilter);
  FIndexKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FIndexKeySearchFilter);
  FFundKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FFundKeySearchFilter);
  FBondKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FBondKeySearchFilter);
  FFutureKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FFutureKeySearchFilter);
  FStockHKKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FStockHKKeySearchFilter);
  FStockUSKeySearchFilter := TKeySearchFilter.Create(Self);
  FKeySearchFilters.Add(FStockUSKeySearchFilter);
end;

procedure TKeySearchObject.DoFuzzyKeySearchFilters;
var
  LIndex: Integer;
  LKeySearchFilter: TKeySearchFilter;
begin
  FResultItems.ClearCount;
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
          DoFuzzyKeySearchFilters;
          if Assigned(FOnResultCallBack) then begin
            if FSearchThread.IsTerminated then Exit;

            FOnResultCallBack(FResultItems);
          end;
        end;
    end;
  end;
end;

function TKeySearchObject.GetKeySearchFilter(ASecuInfo: PSecuInfo): TKeySearchFilter;
begin
  case ASecuInfo.FSearchType of
    // 沪深股票
    SEARCHTYPE_STOCK_HS:
      begin
        Result := FStockHSKeySearchFilter;
      end;
    // B股
    SEARCHTYPE_STOCK_B:
      begin
        Result := FStockBKeySearchFilter;
      end;
    // 新三板
    SEARCHTYPE_STOCK_NEWOTC:
      begin
        Result := FStockNewOTCKeySearchFilter;
      end;
    // 基金
    SEARCHTYPE_FUND:
      begin
        Result := FFundKeySearchFilter;
      end;
    // 指数
    SEARCHTYPE_INDEX:
      begin
        Result := FIndexKeySearchFilter;
      end;
    // 债券
    SEARCHTYPE_BOND:
      begin
        Result := FBondKeySearchFilter;
      end;
    // 期货
    SEARCHTYPE_FUTURE:
      begin
        Result := FFutureKeySearchFilter;
      end;
    // 港股
    SEARCHTYPE_STOCK_HK:
      begin
        Result := FStockHKKeySearchFilter;
      end;
    // 美股
    SEARCHTYPE_STOCK_US:
      begin
        Result := FStockUSKeySearchFilter;
      end;
  else
    begin
      Result := FStockHSKeySearchFilter;
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
  FSecuInfos := TDynArray<PSecuInfo>.Create;
end;

destructor TKeySearchFilter.Destroy;
begin
  FSecuInfos.Free;
  inherited;
end;

procedure TKeySearchFilter.FuzzySearchKey;
var
  LIndex: Integer;
  LSecuInfo: PSecuInfo;
begin
  for LIndex := 0 to FSecuInfos.GetCount - 1 do begin
    if FKeySearchObject.FIsStop
      or FKeySearchObject.IsTerminated
      or FKeySearchObject.IsMaxLimited then Exit;

    LSecuInfo := FSecuInfos.GetElement(LIndex);
    if (LSecuInfo <> nil)
      and DoFilter(LSecuInfo)then begin
      FKeySearchObject.FResultItems.Add(LSecuInfo);
    end;
  end;
end;

procedure TKeySearchFilter.ClearSecuInfos;
begin
  FSecuInfos.ClearCount;
end;

procedure TKeySearchFilter.AddSecuInfo(ASecuInfo: PSecuInfo);
begin
  FSecuInfos.Add(ASecuInfo);
end;

function TKeySearchFilter.DoFilter(ASecuInfo: PSecuInfo): Boolean;
begin
  Result := False;
  case FKeySearchObject.FCharType of
    ctNomeric:
      begin
        if Pos(FKeySearchObject.FKey, ASecuInfo^.FSecuCode) > 0 then begin
          Result := True;
        end;
      end;
    ctAlpha:
      begin
        if (Pos(FKeySearchObject.FKey, ASecuInfo.FSecuSpell) > 0)
          or (Pos(FKeySearchObject.FKey, ASecuInfo.FSecuAbbr) > 0)
          or (Pos(FKeySearchObject.FKey, ASecuInfo.FSecuCode) > 0) then begin
          Result := True;
        end;
      end;
    ctChinese:
      begin
        if (Pos(FKeySearchObject.FKey, ASecuInfo.FSecuAbbr) > 0) then begin
          Result := True;
        end else begin

//          if ASecuInfo.FFormerAbbr = '' then Exit;
//
//          if Pos(FKeySearchObject.FKey, ASecuInfo.FFormerAbbr) > 0 then begin
//            Result := True;
//          end;
        end;
      end;
  end;
end;

end.
