unit SectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorMgr Implementation
// Author£º      lksoulman
// Date£º        2018-1-9
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  Sector,
  Command,
  LogLevel,
  CacheType,
  SectorMgr,
  BaseCache,
  BaseObject,
  AppContext,
  CommonLock,
  CommonPool,
  WNDataSetInf,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // SectorPool
  TSectorPool = class(TObjectPool)
  private
    // AppContext
    FAppContext: IAppContext;
  protected
    // Create
    function DoCreate: TObject; override;
    // Destroy
    procedure DoDestroy(AObject: TObject); override;
    // Allocate Before
    procedure DoAllocateBefore(AObject: TObject); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(AObject: TObject); override;
  public
    // Constructor
    constructor Create(AContext: IAppContext; APoolSize: Integer = 10); reintroduce;
    // Destructor
    destructor Destroy; override;
  end;

  // SectorMgr Implementation
  TSectorMgrImpl = class(TBaseInterfacedObject, ISectorMgr)
  private
  protected
    // Lock
    FLock: TCSLock;
    // Root
    FRoot: TSector;
    // IsLoad
    FIsLoad: Boolean;
    // SectorPool
    FSectorPool: TSectorPool;
    // SectorDic
    FSectorDic: TDictionary<Integer, TSector>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // Update
    procedure DoUpdate;
    // DeAllocateSectors
    procedure DeAllocateSectors;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISectorMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // GetRootSector
    function GetRootSector: TSector;
    // GetSector
    function GetSector(AId: Integer): TSector;
    // GetSectorElements
    function GetSectorElements(AId: Integer): TArray<Integer>;
  end;

implementation

uses
  SectorImpl;

{ TSectorPool }

constructor TSectorPool.Create(AContext: IAppContext; APoolSize: Integer);
begin
  inherited Create(APoolSize);
  FAppContext := AContext;
end;

destructor TSectorPool.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

function TSectorPool.DoCreate: TObject;
begin
  Result := TSectorImpl.Create(FAppContext);
end;

procedure TSectorPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure TSectorPool.DoAllocateBefore(AObject: TObject);
begin

end;

procedure TSectorPool.DoDeAllocateBefore(AObject: TObject);
begin
  if AObject <> nil then begin
    TSectorImpl(AObject).ResetValue;
  end;
end;

{ TSectorMgrImpl }

constructor TSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FIsLoad := False;
  FLock := TCSLock.Create;
  FSectorPool := TSectorPool.Create(FAppContext, 1010);
  FSectorDic := TDictionary<Integer, TSector>.Create;
  FRoot := TSectorImpl.Create(FAppContext);
  TSectorImpl(FRoot).FId := -1;
  TSectorImpl(FRoot).FName := 'Root';
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
//  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TSectorMgrImpl.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  DeAllocateSectors;
  FRoot.Free;
  FSectorDic.Free;
  FSectorPool.Free;
  FLock.Free;
  inherited;
end;

procedure TSectorMgrImpl.DoUpdate;
var
  LSql: string;
  LDataSet: IWNDataSet;
  LParentId, LId: Integer;
  LParentSector, LSector: TSector;
  LPlateCode, LParentPlateCode, LPlateName, LInnerCodes: IWNField;
begin
  LSql := 'SELECT PlateCode,ParentPlateCode,PlateName,OrderNumber,PlateLevel ' +
   'FROM DW_PlateInfo WHERE Flag = 1 and PlateCode > 5 ORDER BY PlateLevel, OrderNumber';
  LDataSet := FAppContext.CacheSyncQuery(ctBaseData, LSql);
  if (LDataSet <> nil) then begin

    if LDataSet.RecordCount >= 0 then begin

      TSectorImpl(FRoot).ClearChilds;
      DeAllocateSectors;
      FSectorDic.AddOrSetValue(FRoot.Id, FRoot);


      LPlateCode := LDataSet.FieldByName('PlateCode');
      LParentPlateCode := LDataSet.FieldByName('ParentPlateCode');
      LPlateName := LDataSet.FieldByName('PlateName');

      LDataSet.First;
      while not LDataSet.Eof do begin
        if LParentPlateCode.IsNull then begin
          LParentId := -1;
        end else begin
          LParentId := LParentPlateCode.AsInteger;
        end;
        if FSectorDic.TryGetValue(LParentId, LParentSector) then begin
          LId := LPlateCode.AsInteger;
          if not FSectorDic.ContainsKey(LId) then begin
            LSector := TSector(FSectorPool.Allocate);
            if LSector <> nil then begin
              TSectorImpl(LParentSector).AddChild(LSector);
              TSectorImpl(LSector).FId := LId;
              TSectorImpl(LSector).FName := LPlateName.AsString;
              TSectorImpl(LSector).FParent := LParentSector;
              FSectorDic.AddOrSetValue(LSector.Id, LSector);
            end;
          end;
        end;
        LDataSet.Next;
      end;
      FAppContext.SendMsgEx(Msg_AsfMem_ReUpdateSectorMgr, '');
    end;
    LDataSet := nil;
  end;
end;

procedure TSectorMgrImpl.DeAllocateSectors;
var
  LIndex: Integer;
  LSectors: TArray<TSector>;
begin
  FSectorDic.Remove(FRoot.Id);
  LSectors := FSectorDic.Values.ToArray;
  for LIndex := Low(LSectors) to High(LSectors) do begin
    if LSectors[LIndex] <> nil then begin
      FSectorPool.DeAllocate(LSectors[LIndex]);
    end;
  end;
  SetLength(LSectors, 0);
  FSectorDic.Clear;
end;

procedure TSectorMgrImpl.DoUpdateMsgEx(AObject: TObject);
begin
  Update;
end;

procedure TSectorMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TSectorMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TSectorMgrImpl.Update;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FLock.Lock;
    try
      DoUpdate;
    finally
      FLock.UnLock;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TSectorMgrImpl][Update] Update use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

function TSectorMgrImpl.GetRootSector: TSector;
begin
  Result := FRoot;
end;

function TSectorMgrImpl.GetSector(AId: Integer): TSector;
begin
  if not FSectorDic.TryGetValue(AId, Result) then begin
    Result := nil;
  end;
end;

function TSectorMgrImpl.GetSectorElements(AId: Integer): TArray<Integer>;
var
  LSector: TSector;
begin
  if FSectorDic.TryGetValue(AId, LSector) then begin
    Result := LSector.Elements;
  end else begin
    Result := [];
  end;
end;

end.
