unit UserSectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorMgr Implementation
// Author£º      lksoulman
// Date£º        2018-1-4
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  BaseObject,
  AppContext,
  CommonLock,
  CommonPool,
  UserSector,
  WNDataSetInf,
  UserSectorMgr,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // UserSectorPool
  TUserSectorPool = class(TObjectPool)
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

  // UserSectorMgr Implementation
  TUserSectorMgrImpl = class(TBaseInterfacedObject, IUserSectorMgr, IUserSectorMgrUpdate)
  private
    // Lock
    FLock: TCSLock;
    // MaxCID
    FMaxCID: Integer;
    // OrderNo
    FOrderNo: Integer;
    // UserSectorPool
    FUserSectorPool: TUserSectorPool;
    // UserSectors
    FUserSectors: TList<TUserSector>;
    // UserSectorDic
    FUserSectorDic: TDictionary<string, TUserSector>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
    // UserSectorStockFlag
    FUserSectorStockFlagDic: TDictionary<Integer, Integer>;
    // UserPositionStockFlagDic
    FUserPositionStockFlagDic: TDictionary<Integer, Integer>;
  protected
    // GetMaxCID
    function GetNewCID: Integer;
    // GetNewOrderNo
    function GetNewOrderNo: Integer;
    // Update
    procedure DoUpdate;
    // AddDefault
    procedure DoAddDefault;
    // DeAllocateUserSectors
    procedure DoDeAllocateUserSectors;
    // UpdateUserSectorStockFlags
    procedure DoUpdateUserSectorStockFlags;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // AddUserSectorStockFlagDic
    procedure DoAddUserSectorStockFlagDic(AInnerCode, ASelfFlag: Integer);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISectorUserMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // UpdateNotify
    procedure UpdateNotify;
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetUserSector(AIndex: Integer): TUserSector;
    // Add
    function Add(AName: string): TUserSector;
    // Delete
    function Delete(AName: string): Boolean;
    // GetUserSectorByName
    function GetUserSectorByName(AName: string): TUserSector;
    // GetUserSectorStockFlag
    function GetUserSectorStockFlag(AInnerCode: Integer): Integer;
    // GetUserPositionStockFlag
    function GetUserPositionStockFlag(AInnerCode: Integer): Integer;

    { IUserSectorMgrUpdate }

    // RemoveDic
    procedure RemoveDic(AName: string);
    // AddDicUserSector
    procedure AddDic(AUserSector: TUserSector);
  end;

implementation

uses
  Command,
  CacheType,
  UserSectorImpl;

{ TUserSectorPool }

constructor TUserSectorPool.Create(AContext: IAppContext; APoolSize: Integer);
begin
  inherited Create(APoolSize);
  FAppContext := AContext;
end;

destructor TUserSectorPool.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

function TUserSectorPool.DoCreate: TObject;
begin
  Result := TUserSectorImpl.Create(FAppContext);
end;

procedure TUserSectorPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure TUserSectorPool.DoAllocateBefore(AObject: TObject);
begin
  if AObject <> nil then begin
    TUserSectorImpl(AObject).ResetValule;
  end;
end;

procedure TUserSectorPool.DoDeAllocateBefore(AObject: TObject);
begin

end;

{ TUserSectorMgrImpl }

constructor TUserSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMaxCID := 0;
  FOrderNo := 0;
  FLock := TCSLock.Create;
  FUserSectorPool := TUserSectorPool.Create(FAppContext, 30);
  FUserSectorStockFlagDic := TDictionary<Integer, Integer>.Create(200);
  FUserPositionStockFlagDic := TDictionary<Integer, Integer>.Create(200);
  FUserSectors := TList<TUserSector>.Create;
  FUserSectorDic := TDictionary<string, TUserSector>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TUserSectorMgrImpl.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  DoDeAllocateUserSectors;
  FUserSectorDic.Free;
  FUserSectors.Free;
  FUserPositionStockFlagDic.Free;
  FUserSectorStockFlagDic.Free;
  FUserSectorPool.Free;
  FLock.Free;
  inherited;
end;

function TUserSectorMgrImpl.GetNewCID: Integer;
begin
  Inc(FMaxCID);
  Result := FMaxCID;
end;

function TUserSectorMgrImpl.GetNewOrderNo: Integer;
begin
  Result := FOrderNo;
  Inc(FOrderNo);
end;

procedure TUserSectorMgrImpl.DoUpdate;
var
  LSql: string;
  LDataSet: IWNDataSet;
  LUserSector: TUserSector;
  LID, LCID, LName, LOrderNo, LInnerCodes: IWNField;
begin
  LSql := 'SELECT ID, CID, Name, OrderNo, InnerCodes FROM UserSector WHERE UpLoadValue < 2 Order By OrderNo ASC';
  LDataSet := FAppContext.CacheSyncQuery(ctUserData, LSql);
  if (LDataSet <> nil) then begin

    FUserSectorDic.Clear;
    FUserSectorStockFlagDic.Clear;
    DoDeAllocateUserSectors;

    if LDataSet.RecordCount > 0 then begin
      LID := LDataSet.FieldByName('ID');
      LCID := LDataSet.FieldByName('CID');
      LName := LDataSet.FieldByName('Name');
      LOrderNo := LDataSet.FieldByName('OrderNo');
      LInnerCodes := LDataSet.FieldByName('InnerCodes');

      LDataSet.First;
      while not LDataSet.Eof do begin

        if not FUserSectorDic.TryGetValue(LName.AsString, LUserSector) then begin

          LUserSector := TUserSector(FUserSectorPool.Allocate);
          if LUserSector <> nil then begin
            TUserSectorImpl(LUserSector).FID := LID.AsString;
            TUserSectorImpl(LUserSector).FCID := LCID.AsInteger;
            TUserSectorImpl(LUserSector).FName := LName.AsString;
            TUserSectorImpl(LUserSector).FOrderNo := LOrderNo.AsInteger;
            TUserSectorImpl(LUserSector).FInnerCodes := LInnerCodes.AsString;
            TUserSectorImpl(LUserSector).FOrderIndex := FUserSectors.Add(LUserSector);
            FUserSectorDic.AddOrSetValue(LUserSector.Name, LUserSector);
          end;
        end;

        if LCID.AsInteger > FMaxCID then begin
          FMaxCID := LCID.AsInteger;
        end;
        if LOrderNo.AsInteger >= FOrderNo then begin
          FOrderNo := LOrderNo.AsInteger + 1;
        end;
        LDataSet.Next;
      end;
    end else begin
      DoAddDefault;
    end;
    LDataSet := nil;
  end;
  DoUpdateUserSectorStockFlags;
end;

procedure TUserSectorMgrImpl.DoAddDefault;
var
  LUserSector: TUserSector;
begin
  if FUserSectors.Count <= 0 then begin
    LUserSector := TUserSector(FUserSectorPool.Allocate);
    TUserSectorImpl(LUserSector).FID := '';
    TUserSectorImpl(LUserSector).FCID := GetNewCID;
    TUserSectorImpl(LUserSector).FName := '×ÔÑ¡¹É';
    TUserSectorImpl(LUserSector).FOrderNo := FOrderNo;
    TUserSectorImpl(LUserSector).FInnerCodes := '1,1055,1752';
    TUserSectorImpl(LUserSector).FOrderIndex := FUserSectors.Add(LUserSector);
    TUserSectorImpl(LUserSector).UpdateLocalDB(UPLOADVALUE_MODIFY);
    FUserSectorDic.AddOrSetValue(LUserSector.Name, LUserSector);
  end;
end;

procedure TUserSectorMgrImpl.DoDeAllocateUserSectors;
var
  LIndex: Integer;
  LUserSector: TUserSector;
begin
  for LIndex := 0 to FUserSectors.Count - 1 do begin
    LUserSector := FUserSectors.Items[LIndex];
    if LUserSector <> nil then begin
      FUserSectorPool.DeAllocate(LUserSector);
    end;
  end;
  FUserSectors.Clear;
end;

procedure TUserSectorMgrImpl.DoUpdateUserSectorStockFlags;
var
  LInnerCodes: TStringList;
  I, J, LInnerCode, LSelfFlag: Integer;
begin
  FUserSectorStockFlagDic.Clear;
  if FUserSectors.Count > 0 then begin
    LInnerCodes := TStringList.Create;
    try
      LSelfFlag := 1;
      for I := 0 to FUserSectors.Count - 1 do begin
        if FUserSectors.Items[I] <> nil then begin
          LInnerCodes.DelimitedText := FUserSectors.Items[I].GetInnerCodes;
          if LInnerCodes.DelimitedText <> '' then begin
            for J := 0 to LInnerCodes.Count - 1 do begin
              LInnerCode := StrToIntDef(LInnerCodes.Strings[J], 0);
              if LInnerCode <> 0 then begin
                DoAddUserSectorStockFlagDic(LInnerCode, LSelfFlag);
              end;
            end;
          end;
        end;
        LSelfFlag := LSelfFlag shr 1;
      end;
    finally
      LInnerCodes.Free;
    end;
  end;
end;

procedure TUserSectorMgrImpl.DoUpdateMsgEx(AObject: TObject);
begin
  Update;
end;

procedure TUserSectorMgrImpl.DoAddUserSectorStockFlagDic(AInnerCode, ASelfFlag: Integer);
var
  LValue: Integer;
begin
  if FUserSectorStockFlagDic.TryGetValue(AInnerCode, LValue) then begin
    LValue := LValue or ASelfFlag;
    FUserSectorStockFlagDic.AddOrSetValue(AInnerCode, LValue);
  end else begin
    FUserSectorStockFlagDic.AddOrSetValue(AInnerCode, ASelfFlag);
  end;
end;

procedure TUserSectorMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TUserSectorMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TUserSectorMgrImpl.Update;
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
    FAppContext.SysLog(llSLOW, Format('[TUserSectorMgrImpl][Update] Update use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TUserSectorMgrImpl.UpdateNotify;
begin
  Update;
  FAppContext.SendMsgEx(Msg_AsfMem_ReUpdateUserSectorMgr, '');
end;

function TUserSectorMgrImpl.Delete(AName: string): Boolean;
var
  LUserSector: TUserSector;
begin
  FLock.Lock;
  try
    Result := False;
    if FUserSectorDic.TryGetValue(AName, LUserSector) then begin
      Result := True;
      FUserSectorDic.Remove(AName);
      if FUserSectors.IndexOf(LUserSector) >= 0 then begin
        FUserSectors.Remove(LUserSector);
      end;
      TUserSectorImpl(LUserSector).UpdateLocalDB(UPLOADVALUE_DELETE);
      FUserSectorPool.DeAllocate(LUserSector);
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetCount: Integer;
begin
  Result := FUserSectors.Count;
end;

function TUserSectorMgrImpl.GetUserSector(AIndex: Integer): TUserSector;
begin
  if (AIndex >= 0) and (AIndex < FUserSectors.Count) then begin
    Result := FUserSectors.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TUserSectorMgrImpl.GetUserSectorByName(AName: string): TUserSector;
begin
  FLock.Lock;
  try
    if not FUserSectorDic.TryGetValue(AName, Result) then begin
      Result := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.Add(AName: string): TUserSector;
begin
  FLock.Lock;
  try
    if not FUserSectorDic.TryGetValue(AName, Result) then begin
      Result := TUserSector(FUserSectorPool.Allocate);
      TUserSectorImpl(Result).FCID := GetNewCID;
      TUserSectorImpl(Result).FOrderNo := GetNewOrderNo;
      TUserSectorImpl(Result).FOrderIndex := FUserSectors.Add(Result);
      FUserSectorDic.AddOrSetValue(AName, Result);
      Result.Name := AName;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetUserSectorStockFlag(AInnerCode: Integer): Integer;
begin
  FLock.Lock;
  try
    if not FUserSectorStockFlagDic.TryGetValue(AInnerCode, Result) then begin
      Result := 0;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetUserPositionStockFlag(AInnerCode: Integer): Integer;
begin
  FLock.Lock;
  try
    if not FUserPositionStockFlagDic.TryGetValue(AInnerCode, Result) then begin
      Result := 0;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TUserSectorMgrImpl.RemoveDic(AName: string);
begin
  FUserSectorDic.Remove(AName);
end;

procedure TUserSectorMgrImpl.AddDic(AUserSector: TUserSector);
begin
  FUserSectorDic.AddOrSetValue(AUserSector.Name, AUserSector);
end;

end.
