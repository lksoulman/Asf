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
  UserSector,
  WNDataSetInf,
  UserSectorMgr,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // UserSectorMgr Implementation
  TUserSectorMgrImpl = class(TBaseInterfacedObject, IUserSectorMgr, IUserSectorMgrUpdate)
  private
    // Lock
    FLock: TCSLock;
    // MaxCID
    FMaxCID: Integer;
    // OrderNo
    FOrderNo: Integer;
    // UserSectors
    FUserSectors: TList<TUserSector>;
    // UserSectorDic
    FUserSectorDic: TDictionary<string, TUserSector>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
    // SelfStockFlagDic
    FSelfStockFlagDic: TDictionary<Integer, Integer>;
  protected
    // GetMaxCID
    function GetNewCID: Integer;
    // GetNewOrderNo
    function GetNewOrderNo: Integer;
    // Update
    procedure DoUpdate;
    // ClearUserSectors
    procedure DoClearUserSectors;
    // UpdateSelfStockFlags
    procedure DoUpdateSelfStockFlags;
    // UpdateUserSectorsIndex
    procedure DoUpdateUserSectorsIndex;
    // UserSectorsSortByOrderNo
    procedure DoUserSectorsSortByOrderNo;
    // UpdateUserSectorsIsUsedFalse
    procedure DoUpdateUserSectorsIsUsedFalse;
    // UpdateUserSectorsIsUsedTrue
    function DoUpdateUserSectorsIsUsedTrue: Boolean;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // AddSelfStockFlagDic
    procedure DoAddSelfStockFlagDic(AInnerCode, ASelfFlag: Integer);
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
    // NotifyMsgEx
    procedure NotifyMsgEx;
    // UserSectorsSortByOrderNo
    procedure UserSectorsSortByOrderNo;
    // DeleteUserSector
    procedure DeleteUserSector(AName: string);
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetSector(AIndex: Integer): TUserSector;
    // IsExistUserSector
    function IsExistUserSector(AName: string): Boolean;
    // AddUserSector
    function AddUserSector(AName: string): TUserSector;
    // GetSelfStockFlag
    function GetSelfStockFlag(AInnerCode: Integer): Integer;

    { IUserSectorMgrUpdate }

    // UpdateAllSelfStockFlag
    procedure UpdateSelfStockFlagAll;
    // RemoveDic
    procedure RemoveDic(AName: string);
    // AddDicUserSector
    procedure AddDicUserSector(AUserSector: TUserSector);
    // UpdateSelfStockFlag
    procedure AddSelfStockFlag(AIndex, AInnerCode: Integer);
    // DeleteSelfStockFlag
    procedure DeleteSelfStockFlag(AIndex, AInnerCode: Integer);
  end;

implementation

uses
  Command,
  CacheType,
  UserSectorImpl;

{ TUserSectorMgrImpl }

constructor TUserSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMaxCID := 0;
  FOrderNo := 0;
  FLock := TCSLock.Create;
  FSelfStockFlagDic := TDictionary<Integer, Integer>.Create(200);
  FUserSectors := TList<TUserSector>.Create;
  FUserSectorDic := TDictionary<string, TUserSector>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TUserSectorMgrImpl.Destroy;
begin
  DoClearUserSectors;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  FUserSectorDic.Free;
  FUserSectors.Free;
  FSelfStockFlagDic.Free;
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
  LIsUpdate: Boolean;
  LDataSet: IWNDataSet;
  LUserSector: TUserSector;
  LID, LCID, LName, LOrderNo, LInnerCodes: IWNField;
begin
  LIsUpdate := False;
  LSql := 'SELECT ID, CID, Name, OrderNo, InnerCodes FROM UserSector WHERE UpLoadValue < 2 Order By OrderNo';
  LDataSet := FAppContext.CacheSyncQuery(ctUserData, LSql);
  if (LDataSet <> nil) then begin
    if LDataSet.RecordCount > 0 then begin
      LID := LDataSet.FieldByName('ID');
      LCID := LDataSet.FieldByName('CID');
      LName := LDataSet.FieldByName('Name');
      LOrderNo := LDataSet.FieldByName('OrderNo');
      LInnerCodes := LDataSet.FieldByName('InnerCodes');

      if (LID <> nil)
        and (LCID <> nil)
        and (LName <> nil)
        and (LOrderNo <> nil)
        and (LInnerCodes <> nil) then begin

        DoUpdateUserSectorsIsUsedFalse;
        try
          LDataSet.First;
          while not LDataSet.Eof do begin
            if FUserSectorDic.TryGetValue(LName.AsString, LUserSector) then begin
              if (TUserSectorImpl(LUserSector).FID <> LID.AsString)
                or (TUserSectorImpl(LUserSector).FOrderNo <> LOrderNo.AsInteger)
                or (TUserSectorImpl(LUserSector).FInnerCodes <> LInnerCodes.AsString) then begin
                TUserSectorImpl(LUserSector).FID := LID.AsString;
                TUserSectorImpl(LUserSector).FOrderNo := LOrderNo.AsInteger;
                TUserSectorImpl(LUserSector).FInnerCodes := LInnerCodes.AsString;
              end;
            end else begin
              LUserSector := TUserSectorImpl.Create(FAppContext);
              TUserSectorImpl(LUserSector).FID := LID.AsString;
              TUserSectorImpl(LUserSector).FCID := LCID.AsInteger;
              TUserSectorImpl(LUserSector).FName := LName.AsString;
              TUserSectorImpl(LUserSector).FOrderNo := LOrderNo.AsInteger;
              TUserSectorImpl(LUserSector).FInnerCodes := LInnerCodes.AsString;
              TUserSectorImpl(LUserSector).FIsUsed := True;
              TUserSectorImpl(LUserSector).FOrderIndex := FUserSectors.Add(LUserSector);
              FUserSectorDic.AddOrSetValue(LUserSector.Name, LUserSector);
              if not LIsUpdate then begin
                LIsUpdate := True;
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
        finally
          LIsUpdate := DoUpdateUserSectorsIsUsedTrue;
        end;
      end;

      LID := nil;
      LCID := nil;
      LName := nil;
      LOrderNo := nil;
      LInnerCodes := nil;
    end else begin
      if FUserSectors.Count <= 0 then begin
        LUserSector := TUserSectorImpl.Create(FAppContext);
        TUserSectorImpl(LUserSector).FID := LID.AsString;
        TUserSectorImpl(LUserSector).FCID := GetNewCID;
        TUserSectorImpl(LUserSector).FName := '×ÔÑ¡¹É';
        TUserSectorImpl(LUserSector).FOrderNo := FOrderNo;
        TUserSectorImpl(LUserSector).FInnerCodes := '1,1055,1752';
        TUserSectorImpl(LUserSector).FIsUsed := True;
        TUserSectorImpl(LUserSector).FOrderIndex := FUserSectors.Add(LUserSector);
        FUserSectorDic.AddOrSetValue(LUserSector.Name, LUserSector);
      end;
    end;
    LDataSet := nil;
  end;

  if LIsUpdate then begin
    DoUserSectorsSortByOrderNo;
    DoUpdateUserSectorsIndex;
  end;
end;

procedure TUserSectorMgrImpl.DoClearUserSectors;
var
  LIndex: Integer;
  LUserSector: TUserSector;
begin
  for LIndex := FUserSectors.Count - 1 downto 0 do begin
    LUserSector := FUserSectors.Items[LIndex];
    if LUserSector <> nil then begin
      LUserSector.Free;
    end;
  end;
  FUserSectors.Clear;
  FUserSectorDic.Clear;
  FSelfStockFlagDic.Clear;
end;

procedure TUserSectorMgrImpl.DoUpdateSelfStockFlags;
var
  LInnerCodes: TStringList;
  I, J, LInnerCode, LSelfFlag: Integer;
begin
  FSelfStockFlagDic.Clear;
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
                DoAddSelfStockFlagDic(LInnerCode, LSelfFlag);
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

procedure TUserSectorMgrImpl.DoUpdateUserSectorsIndex;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FUserSectors.Count - 1 do begin
    if FUserSectors.Items[LIndex] <> nil then begin
      TUserSectorImpl(FUserSectors.Items[LIndex]).FOrderIndex := LIndex;
    end;
  end;
end;

procedure TUserSectorMgrImpl.DoUserSectorsSortByOrderNo;
var
  I, J, K: Integer;
  LUserSector: TUserSector;
begin
  for I := 0 to FUserSectors.Count - 2 do begin
    K := I;
    for J := I + 1 to FUserSectors.Count - 1 do begin
      if FUserSectors.Items[K].GetOrderNo
        > FUserSectors.Items[J].GetOrderNo then begin
        K := J;
      end;
    end;
    if I <> K then begin
      LUserSector := FUserSectors.Items[I];
      FUserSectors.Items[I] := FUserSectors.Items[K];
      FUserSectors.Items[K] := LUserSector;
    end;
  end;
end;

procedure TUserSectorMgrImpl.DoUpdateUserSectorsIsUsedFalse;
var
  LIndex: Integer;
  LUserSector: TUserSector;
begin
  for LIndex := 0 to FUserSectors.Count - 1 do begin
    LUserSector := FUserSectors.Items[LIndex];
    if LUserSector <> nil then begin
      TUserSectorImpl(LUserSector).FIsUsed := False;
    end;
  end;
end;

function TUserSectorMgrImpl.DoUpdateUserSectorsIsUsedTrue: Boolean;
var
  LIndex: Integer;
  LUserSector: TUserSector;
begin
  Result := False;
  for LIndex := FUserSectors.Count - 1 downto 0 do begin
    LUserSector := FUserSectors.Items[LIndex];
    if LUserSector <> nil then begin
      if not TUserSectorImpl(LUserSector).FIsUsed then begin
        Result := True;
        FUserSectorDic.Remove(LUserSector.Name);
        FUserSectors.Delete(LIndex);
        LUserSector.Free;
      end;
    end;
  end;
end;

procedure TUserSectorMgrImpl.DoUpdateMsgEx(AObject: TObject);
begin
  Update;
end;

procedure TUserSectorMgrImpl.DoAddSelfStockFlagDic(AInnerCode, ASelfFlag: Integer);
var
  LValue: Integer;
begin
  if FSelfStockFlagDic.TryGetValue(AInnerCode, LValue) then begin
    LValue := LValue or ASelfFlag;
    FSelfStockFlagDic.AddOrSetValue(AInnerCode, LValue);
  end else begin
    FSelfStockFlagDic.AddOrSetValue(AInnerCode, ASelfFlag);
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

procedure TUserSectorMgrImpl.NotifyMsgEx;
begin
  FAppContext.SendMsgEx(Msg_AsfMem_ReUpdateUserSector, '');
end;

procedure TUserSectorMgrImpl.UserSectorsSortByOrderNo;
begin
  FLock.Lock;
  try
    DoUserSectorsSortByOrderNo;
    DoUpdateUserSectorsIndex;
  finally
    FLock.UnLock;
  end;
end;

procedure TUserSectorMgrImpl.DeleteUserSector(AName: string);
var
  LUserSector: TUserSector;
begin
  FLock.Lock;
  try
    if FUserSectorDic.TryGetValue(AName, LUserSector) then begin
      FUserSectorDic.Remove(AName);
      FUserSectors.Remove(LUserSector);
      DoUserSectorsSortByOrderNo;
      DoUpdateUserSectorsIndex;
      DoUpdateSelfStockFlags;
      LUserSector.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetCount: Integer;
begin
  Result := FUserSectors.Count;
end;

function TUserSectorMgrImpl.GetSector(AIndex: Integer): TUserSector;
begin
  if (AIndex >= 0) and (AIndex < FUserSectors.Count) then begin
    Result := FUserSectors.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TUserSectorMgrImpl.IsExistUserSector(AName: string): Boolean;
var
  LUserSector: TUserSector;
begin
  FLock.Lock;
  try
    if FUserSectorDic.TryGetValue(AName, LUserSector) then begin
      Result := True;
    end else begin
      Result := False;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.AddUserSector(AName: string): TUserSector;
begin
  FLock.Lock;
  try
    if not FUserSectorDic.TryGetValue(AName, Result) then begin
      Result := TUserSectorImpl.Create(FAppContext);
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

function TUserSectorMgrImpl.GetSelfStockFlag(AInnerCode: Integer): Integer;
begin
  FLock.Lock;
  try
    if not FSelfStockFlagDic.TryGetValue(AInnerCode, Result) then begin
      Result := 0;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TUserSectorMgrImpl.UpdateSelfStockFlagAll;
begin
  DoUpdateSelfStockFlags;
end;

procedure TUserSectorMgrImpl.RemoveDic(AName: string);
begin
  FUserSectorDic.Remove(AName);
end;

procedure TUserSectorMgrImpl.AddDicUserSector(AUserSector: TUserSector);
begin
  FUserSectorDic.AddOrSetValue(AUserSector.Name, AUserSector);
end;

procedure TUserSectorMgrImpl.AddSelfStockFlag(AIndex, AInnerCode: Integer);
var
  LStockFlag, LTmpStockFlag: Integer;
begin
  LStockFlag := 1;
  LStockFlag := LStockFlag shr AIndex;
  if FSelfStockFlagDic.TryGetValue(AInnerCode, LTmpStockFlag) then begin
    LStockFlag := LTmpStockFlag or LStockFlag;
  end;
  FSelfStockFlagDic.AddOrSetValue(AInnerCode, LStockFlag);
end;

procedure TUserSectorMgrImpl.DeleteSelfStockFlag(AIndex, AInnerCode: Integer);
var
  LStockFlag, LTmpStockFlag: Integer;
begin
  if FSelfStockFlagDic.TryGetValue(AInnerCode, LTmpStockFlag) then begin
    LStockFlag := 1;
    LStockFlag := not(LStockFlag shr AIndex);
    LStockFlag := LTmpStockFlag and LStockFlag;
    if LStockFlag = 0 then begin
      FSelfStockFlagDic.Remove(AInnerCode);
    end else begin
      FSelfStockFlagDic.AddOrSetValue(AInnerCode, LStockFlag);
    end;
  end;
end;

end.
