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
  Sector,
  Command,
  CacheType,
  SectorMgr,
  BaseCache,
  BaseObject,
  AppContext,
  CommonLock,
  WNDataSetInf,
  SectorUpdate,
  SectorMgrUpdate,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // SectorMgr Implementation
  TSectorMgrImpl = class(TBaseInterfacedObject, ISectorMgr, ISectorMgrUpdate)
  private
  protected
    // Lock
    FLock: TCSLock;
    // Root
    FRoot: ISector;
    // IsLoad
    FIsLoad: Boolean;
    // SectorDic
    FSectorDic: TDictionary<Integer, ISector>;
    // ParentDic
    FParentDic: TDictionary<Integer, ISector>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // Update
    procedure DoUpdate;
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
    // GetVersion
    function GetVersion: Integer;
    // GetRootSector
    function GetRootSector: ISector;
    // GetSector
    function GetSector(AId: Integer): ISector;
    // GetSectorElements
    function GetSectorElements(AId: Integer): string;

    { ISectorMgrUpdate }

    // DeleteSector
    procedure DeleteSector(AId: Integer);
  end;

implementation

uses
  SectorImpl;

{ TSectorMgrImpl }

constructor TSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FIsLoad := False;
  FLock := TCSLock.Create;
  FSectorDic := TDictionary<Integer, ISector>.Create;
  FParentDic := TDictionary<Integer, ISector>.Create;
  FRoot := TSectorImpl.Create(FAppContext, nil) as ISector;
  (FRoot as ISectorUpdate).GetSectorInfo.FId := -1;
  (FRoot as ISectorUpdate).GetSectorInfo.FName := 'Root';
  (FRoot as ISectorUpdate).GetSectorInfo.FVersion := 0;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
//  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfCache_ReUpdateUserCache_UserSector);
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

destructor TSectorMgrImpl.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  FRoot := nil;
  FParentDic.Free;
  FSectorDic.Free;
  FLock.Free;
  inherited;
end;

procedure TSectorMgrImpl.DoUpdate;
var
  LSql: string;
  LDataSet: IWNDataSet;
  LSector, LChildSector: ISector;
  LPlateCode, LParentPlateCode, LPlateName, LInnerCodes: IWNField;
begin
  LSql := 'SELECT PlateCode,ParentPlateCode,PlateName,OrderNumber,PlateLevel ' +
   'FROM DW_PlateInfo WHERE Flag = 1 ORDER BY PlateLevel, OrderNumber';

  LDataSet := FAppContext.CacheSyncQuery(ctBaseData, LSql);
  if (LDataSet <> nil) then begin
    if LDataSet.RecordCount >= 0 then begin
      LPlateCode := LDataSet.FieldByName('PlateCode');
      LParentPlateCode := LDataSet.FieldByName('ParentPlateCode');
      LPlateName := LDataSet.FieldByName('PlateName');

      LDataSet.First;
      while LDataSet.Eof do begin
        if FParentDic.TryGetValue(LParentPlateCode.AsInteger, LSector) then begin
          LChildSector := (LSector as ISectorUpdate).AddChild(LPlateCode.AsInteger);
        end else begin
          LChildSector := (FRoot as ISectorUpdate).AddChild(LPlateCode.AsInteger);
        end;
        (LChildSector as ISectorUpdate).GetSectorInfo.FId := LPlateCode.AsInteger;
        (LChildSector as ISectorUpdate).GetSectorInfo.FName := LPlateName.AsString;
        (LChildSector as ISectorUpdate).GetSectorInfo.FElements := '';
        FSectorDic.AddOrSetValue(LChildSector.Id, LChildSector);
        LDataSet.Next;
      end;
    end;
    LDataSet := nil;
  end;
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
begin
  FLock.Lock;
  try
    if not FIsLoad then begin
      DoUpdate;
      FIsLoad := True;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TSectorMgrImpl.GetVersion: Integer;
begin
  Result := (FRoot as ISectorUpdate).GetSectorInfo.FVersion;
end;

function TSectorMgrImpl.GetRootSector: ISector;
begin
  Result := FRoot;
end;

function TSectorMgrImpl.GetSector(AId: Integer): ISector;
begin
  if not FSectorDic.TryGetValue(AId, Result) then begin
    Result := nil;
  end;
end;

function TSectorMgrImpl.GetSectorElements(AId: Integer): string;
begin

end;

procedure TSectorMgrImpl.DeleteSector(AId: Integer);
begin
  FSectorDic.Remove(AId);
end;

end.
