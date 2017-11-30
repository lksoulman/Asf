unit StatusNewsDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� StatusNewsDataMgr Implementation
// Author��      lksoulman
// Date��        2017-11-22
// Comments��
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
  AppContext,
  CommonLock,
  CommonPool,
  ServiceType,
  AppContextObject,
  CommonRefCounter,
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
  TStatusNewsDataMgrImpl = class(TAppContextObject, IStatusNewsDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // GFData
    FGFData: IGFData;
    // StatusNewsPool
    FStatusNewsPool: TStatusNewsPool;
    // StatusNewsDatas
    FStatusNewsDatas: TList<PStatusNewsData>;
    // StatusNewsDataDic
    FStatusNewsDataDic: TDictionary<Int64, PStatusNewsData>;
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
    // Find Data
    function FindData(AId: Integer): PStatusNewsData;
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
  FStatusNewsDataDic := TDictionary<Int64, PStatusNewsData>.Create;
  DoAddTestDatas;
end;

destructor TStatusNewsDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FStatusNewsDataDic.Free;
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
  FStatusNewsDataDic.Clear;
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
  LStatusNewsData^.FTitle := '��Ӣ��ͨ�б�1996��Ԫ�������繤��';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '�Ƿ��Ƽ���޽�����ǩ��3000��Ԫ���̷ְ���ͬ';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '�����ɷ��յ�889��Ԫ�ӱ�ʡר���ʽ���';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '��������:ͣ�Ƴﻮ�����ʲ�����';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '�и�ͨ:�ɶ���ϼƼ��ֲ���4.56%�ɷ�';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '��ͷ���:ʵ���������ֲ���5000��Ԫ';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);

  New(LStatusNewsData);
  LStatusNewsData^.FId := 0;
  LStatusNewsData^.FWidth := 0;
  LStatusNewsData^.FTitle := '�ջ�����:���ʵز��̻���Ѱ�����г�����';
  LStatusNewsData^.FDateTime := Now;
  LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', Now);
  FStatusNewsDatas.Add(LStatusNewsData);
  FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);
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
                LStatusNewsData^.FDateTimeStr := FormatDateTime('MM-DD', LStatusNewsData^.FDateTime);
              end else begin
                LStatusNewsData^.FDateTimeStr := FormatDateTime('hh:nn:ss', LStatusNewsData^.FDateTime);
              end;
              FStatusNewsDataDic.AddOrSetValue(LStatusNewsData^.FId, LStatusNewsData);
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
begin

//       FGFData.Cancel;
//  FGFData := FAppContext.GFAsyncQuery(stBasic, '', DoGFDataArrive, 0);
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

function TStatusNewsDataMgrImpl.FindData(AId: Integer): PStatusNewsData;
begin
  if not FStatusNewsDataDic.TryGetValue(AId, Result) then begin
    Result := nil;
  end;
end;

end.

