unit StatusNewsDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： StatusNewsDataMgr Implementation
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
  Data.DB,
  GFData,
  GFDataSet,
  ErrorCode,
  BaseObject,
  AppContext,
  CommonLock,
  CommonPool,
  ServiceType,
  StatusNewsDataMgr,
  Generics.Collections;

type

  // StatusNewsPool
  TStatusNewsPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  public
  end;

  // StatusNewsDataMgr Implementation
  TStatusNewsDataMgrImpl = class(TBaseInterfacedObject, IStatusNewsDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // GFData
    FGFData: IGFData;
    // StatusNewsPool
    FStatusNewsPool: TStatusNewsPool;
    // StatusNewsDatas
    FStatusNewsDatas: TList<PStatusNewsData>;
  protected
    // ClearDatas
    procedure DoClearDatas;
    // Add TestDatas
    procedure DoAddTestDatas;
    // Update
    procedure DoUpdate(AGFDataSet: TGFDataSet);
    // GFDataArrive
    procedure DoGFDataArrive(AGFData: IGFData);
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IStatusNewsDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PStatusNewsData;
  end;

implementation

{ TStatusNewsPool }

function TStatusNewsPool.DoCreate: Pointer;
var
  LStatusNewsData: PStatusNewsData;
begin
  New(LStatusNewsData);
  Result := LStatusNewsData;
end;

procedure TStatusNewsPool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure TStatusNewsPool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure TStatusNewsPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TStatusNewsDataMgrImpl }

constructor TStatusNewsDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FStatusNewsPool := TStatusNewsPool.Create(20);
  FStatusNewsDatas := TList<PStatusNewsData>.Create;
//  DoAddTestDatas;
end;

destructor TStatusNewsDataMgrImpl.Destroy;
begin
  if FGFData <> nil then begin
    FGFData.Cancel;
    FGFData := nil;
  end;
  DoClearDatas;
  FStatusNewsDatas.Free;
  FStatusNewsPool.Free;
  FLock.Free;
  inherited;
end;

procedure TStatusNewsDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LStatusNewsData: PStatusNewsData;
begin
  for LIndex := 0 to FStatusNewsDatas.Count - 1 do begin
    LStatusNewsData := FStatusNewsDatas.Items[LIndex];
    if LStatusNewsData <> nil then begin
      FStatusNewsPool.DeAllocate(LStatusNewsData);
    end;
  end;
  FStatusNewsDatas.Clear;
end;

procedure TStatusNewsDataMgrImpl.DoAddTestDatas;
var
  LStatusNewsData: PStatusNewsData;
begin
  DoClearDatas;

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '精英智通中标1996万元配套弱电工程';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '智房科技与巨匠建设签订3000万元工程分包合同';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '金力股份收到889万元河北省专项资金补贴';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '新宁物流:停牌筹划购买资产事项';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '中富通:股东拟合计减持不超4.56%股份';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '天和防务:实控人拟增持不超5000万元';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '普华永道:中资地产商积极寻求海外市场机会';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
end;

procedure TStatusNewsDataMgrImpl.DoUpdate(AGFDataSet: TGFDataSet);
var
  LNowDate, LDate: string;
  LStatusNewsData: PStatusNewsData;
  Lid, LinfoTitle, LupdateTime, LinfoPublDate: TField;
begin
  FLock.Lock;
  try
    if AGFDataSet.RecordCount > 0 then begin
      AGFDataSet.First;
      Lid := AGFDataSet.FieldByName('id');
      LinfoTitle := AGFDataSet.FieldByName('infoTitle');
      LupdateTime := AGFDataSet.FieldByName('updateTime');
      LinfoPublDate := AGFDataSet.FieldByName('infoPublDate');
      if (Lid <> nil)
        and (LinfoTitle <> nil)
        and (LupdateTime <> nil)
        and (LinfoPublDate <> nil) then begin
        DoClearDatas;
        LNowDate := FormatDateTime('YYYYMMDD', Now);
        while not AGFDataSet.Eof do begin
          if LinfoTitle.AsString <> '' then begin
            LStatusNewsData := PStatusNewsData(FStatusNewsPool.Allocate);
            if LStatusNewsData <> nil then begin
              LStatusNewsData^.FWidth := 0;
              LStatusNewsData^.FId := Lid.AsLargeInt;
              LStatusNewsData^.FTitle := LinfoTitle.AsString;
              LStatusNewsData^.FDateTime := LinfoPublDate.AsDateTime;
              LDate := FormatDateTime('YYYYMMDD', LStatusNewsData^.FDateTime);
              if LNowDate <> LDate then begin
                LStatusNewsData^.FDateTime := LupdateTime.AsDateTime;
                LStatusNewsData^.FDateStr := FormatDateTime('MM-DD', LStatusNewsData^.FDateTime);
              end else begin
                LStatusNewsData^.FDateStr := FormatDateTime('hh:nn:ss', LStatusNewsData^.FDateTime);
              end;
              FStatusNewsDatas.Add(LStatusNewsData);
            end;
          end;
          AGFDataSet.Next;
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TStatusNewsDataMgrImpl.DoGFDataArrive(AGFData: IGFData);
var
  LGFDataSet: TGFDataSet;
begin
  if AGFData.GetErrorCode = ErrorCode_Success then begin
    LGFDataSet := TGFDataSet.Create(AGFData);
    try
      DoUpdate(LGFDataSet);
    finally
      LGFDataSet.Free;
    end;
  end;
  FGFData := nil;
end;

procedure TStatusNewsDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusNewsDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusNewsDataMgrImpl.Update;
var
  LIndicator: string;
begin
  if FGFData <> nil then begin
    FGFData.Cancel;
    FGFData := nil;
  end;
  LIndicator := Format('C_INFOFIN_NEWSLIST_TEXT4delphi("%s", "%s", ["1","100","true","updateTime.DESC","true"])',
    [FormatDateTime('YYYY-MM-DD 00:00:00.000', Now), FormatDateTime('YYYY-MM-DD 00:00:00.000', Now)]);
  FGFData := FAppContext.GFAsyncQuery(stBasic, LIndicator, DoGFDataArrive, 0);
end;

function TStatusNewsDataMgrImpl.GetDataCount: Integer;
begin
  Result := FStatusNewsDatas.Count;
end;

function TStatusNewsDataMgrImpl.GetData(AIndex: Integer): PStatusNewsData;
begin
  if (AIndex >= 0)
    and (AIndex < FStatusNewsDatas.Count) then begin
    Result := FStatusNewsDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.

