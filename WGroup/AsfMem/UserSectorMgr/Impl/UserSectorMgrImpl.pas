unit UserSectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorMgr Implementation
// Author£º      lksoulman
// Date£º        2017-12-04
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
  UserSectorUpdate,
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
    FUserSectors: TList<IUserSector>;
    // UserSectorDic
    FUserSectorDic: TDictionary<string, IUserSector>;
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
    function GetSector(AIndex: Integer): IUserSector;
    // IsExistUserSector
    function IsExistUserSector(AName: string): Boolean;
    // AddUserSector
    function AddUserSector(AName: string): IUserSector;
    // GetSelfStockFlag
    function GetSelfStockFlag(AInnerCode: Integer): Integer;

    { IUserSectorMgrUpdate }

    // ClearUserSectors
    procedure ClearUserSectors;
    // UpdateAllSelfStockFlag
    procedure UpdateSelfStockFlagAll;
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
  FUserSectors := TList<IUserSector>.Create;
  FUserSectorDic := TDictionary<string, IUserSector>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TUserSectorMgrImpl.Destroy;
begin
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
  LDataSet: IWNDataSet;
  LUserSector: IUserSector;
  LIsUpdate: Boolean;
  LUserSectorInfo: TUserSectorInfo;
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
              LUserSectorInfo.FID := LID.AsString;
              LUserSectorInfo.FCID := LCID.AsInteger;
              LUserSectorInfo.FName := LName.AsString;
              LUserSectorInfo.FOrderNo := LOrderNo.AsInteger;
              LUserSectorInfo.FInnerCodes := LInnerCodes.AsString;
              if (LUserSector as IUserSectorUpdate).CompareAssign(@LUserSectorInfo) then begin
                if not LIsUpdate then begin
                  LIsUpdate := True;
                end;
              end;
            end else begin
              LUserSector := TUserSectorImpl.Create(FAppContext);
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FID := LID.AsString;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FCID := LCID.AsInteger;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FName := LName.AsString;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FOrderNo := LOrderNo.AsInteger;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FInnerCodes := LInnerCodes.AsString;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FIsUsed := True;
              (LUserSector as IUserSectorUpdate).UserSectorInfo.FIndex := FUserSectors.Add(LUserSector);
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
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FID := LID.AsString;
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FCID := GetNewCID;
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FName := '×ÔÑ¡¹É';
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FOrderNo := FOrderNo;
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FInnerCodes := '1,1055,1752';
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FIsUsed := True;
        (LUserSector as IUserSectorUpdate).UserSectorInfo.FIndex := FUserSectors.Add(LUserSector);
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
begin
  for LIndex := 0 to FUserSectors.Count - 1 do begin
    if FUserSectors.Items[LIndex] <> nil then begin
      FUserSectorDic.Remove(FUserSectors.Items[LIndex].Name);
      FUserSectors.Items[LIndex] := nil;
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
      (FUserSectors.Items[LIndex] as IUserSectorUpdate).UserSectorInfo.FIndex := LIndex;
    end;
  end;
end;

procedure TUserSectorMgrImpl.DoUserSectorsSortByOrderNo;
var
  I, J, K: Integer;
  LUserSector: IUserSector;
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
begin
  for LIndex := 0 to FUserSectors.Count - 1 do begin
    if FUserSectors.Items[LIndex] <> nil then begin
      (FUserSectors.Items[LIndex] as IUserSectorUpdate).UserSectorInfo.FIsUsed := False;
    end;
  end;
end;

function TUserSectorMgrImpl.DoUpdateUserSectorsIsUsedTrue: Boolean;
var
  LIndex: Integer;
  LUserSector: IUserSector;
begin
  Result := False;
  for LIndex := FUserSectors.Count - 1 downto 0 do begin
    LUserSector := FUserSectors.Items[LIndex];
    if LUserSector <> nil then begin
      if not (LUserSector as IUserSectorUpdate).UserSectorInfo.FIsUsed then begin
        Result := True;
        FUserSectorDic.Remove(LUserSector.Name);
        FUserSectors.Remove(LUserSector);
        LUserSector := nil;
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
  LUserSector: IUserSector;
begin
  FLock.Lock;
  try
    if FUserSectorDic.TryGetValue(AName, LUserSector) then begin
      FUserSectorDic.Remove(AName);
      FUserSectors.Remove(LUserSector);
      DoUserSectorsSortByOrderNo;
      DoUpdateUserSectorsIndex;
      DoUpdateSelfStockFlags;
      LUserSector := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetCount: Integer;
begin
  Result := FUserSectors.Count;
end;

function TUserSectorMgrImpl.GetSector(AIndex: Integer): IUserSector;
begin
  if (AIndex >= 0) and (AIndex < FUserSectors.Count) then begin
    Result := FUserSectors.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TUserSectorMgrImpl.IsExistUserSector(AName: string): Boolean;
var
  LUserSector: IUserSector;
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

function TUserSectorMgrImpl.AddUserSector(AName: string): IUserSector;
begin
  FLock.Lock;
  try
    if not FUserSectorDic.TryGetValue(AName, Result) then begin
      Result := TUserSectorImpl.Create(FAppContext);
      (Result as IUserSectorUpdate).UserSectorInfo.FCID := GetNewCID;
      (Result as IUserSectorUpdate).UserSectorInfo.FOrderNo := GetNewOrderNo;
      (Result as IUserSectorUpdate).UserSectorInfo.FIndex := FUserSectors.Add(Result);
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

procedure TUserSectorMgrImpl.ClearUserSectors;
begin
  DoClearUserSectors;
end;

procedure TUserSectorMgrImpl.UpdateSelfStockFlagAll;
begin
  DoUpdateSelfStockFlags;
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
