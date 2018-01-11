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
  LogLevel,
  CacheType,
  SectorMgr,
  BaseCache,
  BaseObject,
  AppContext,
  CommonLock,
  WNDataSetInf,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

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
    // SectorDic
    FSectorDic: TDictionary<Integer, TSector>;
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
    // GetRootSector
    function GetRootSector: TSector;
    // GetSector
    function GetSector(AId: Integer): TSector;
    // GetSectorElements
    function GetSectorElements(AId: Integer): string;
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
  FSectorDic := TDictionary<Integer, TSector>.Create;
  FRoot := TSectorImpl.Create(FAppContext, nil);
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
  FRoot.Free;
  FSectorDic.Free;
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
  FSectorDic.Clear;
  FSectorDic.AddOrSetValue(FRoot.Id, FRoot);
  TSectorImpl(FRoot).ClearChilds;

  LSql := 'SELECT PlateCode,ParentPlateCode,PlateName,OrderNumber,PlateLevel ' +
   'FROM DW_PlateInfo WHERE Flag = 1 ORDER BY PlateLevel, OrderNumber';
  LDataSet := FAppContext.CacheSyncQuery(ctBaseData, LSql);
  if (LDataSet <> nil) then begin
    if LDataSet.RecordCount >= 0 then begin
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
            LSector := TSectorImpl(LParentSector).AddChild(LId);
            TSectorImpl(LSector).FId := LId;
            TSectorImpl(LSector).FName := LPlateName.AsString;
            TSectorImpl(LSector).FElements := '';
            FSectorDic.AddOrSetValue(LSector.Id, LSector);
          end;
        end;
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

function TSectorMgrImpl.GetSectorElements(AId: Integer): string;
var
  LSector: TSector;
begin
  if FSectorDic.TryGetValue(AId, LSector) then begin
    Result := LSector.Elements;
  end else begin
    Result := '';
  end;
end;

end.
