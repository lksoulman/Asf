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
  Sector,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  UserSector,
  CommonLock,
  WNDataSetInf,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type


  // UserSectorMgr Implementation
  TUserSectorMgrImpl = class(TAppContextObject, IUserSector)
  private
    // Lock
    FLock: TCSLock;
    // Sectors
    FRootSector: ISector;
  protected
    // Update
    procedure DoUpdate;
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
    // GetCount
    function GetCount: Integer;
    // GetSector
    function GetSector(AIndex: Integer): ISector;
    //

  end;

implementation

uses
  CacheType,
  UserSectorImpl;

{ TUserSectorMgrImpl }

constructor TUserSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FRootSector := TUserSectorImpl.Create;
end;

destructor TUserSectorMgrImpl.Destroy;
begin
  FRootSector := nil;
  FLock.Free;
  inherited;
end;

procedure TUserSectorMgrImpl.DoUpdate;
var
  LSql: string;
  LDataSet: IWNDataSet;
  LUserSectorInfo: PUserSectorInfo;
  LID, LCID, LName, LOrder, LInnerCodes: IWNField;
begin
  LSql := 'SELECT ID,CID,Name,Order,InnerCodes FROM UserSector';
  LDataSet := FAppContext.CacheSyncQuery(ctUserData, LSql);
  if LDataSet <> nil then begin
    LDataSet.First;
    LID := LDataSet.FieldByName('ID');
    LCID := LDataSet.FieldByName('CID');
    LName := LDataSet.FieldByName('Name');
    LOrder := LDataSet.FieldByName('Order');
    LInnerCodes := LDataSet.FieldByName('InnerCodes');

    if (LID <> nil)
      and (LCID <> nil)
      and (LName <> nil)
      and (LOrder <> nil)
      and (LInnerCodes <> nil) then begin
      while not LDataSet.Eof do begin
        LUserSectorInfo := FRootSector.AddChildSectorByName(LName.AsString).GetDataPtr;
        if LUserSectorInfo <> nil then begin
          LUserSectorInfo.FID := LID.AsString;
          LUserSectorInfo.FCID := LID.AsInteger;
          LUserSectorInfo.FName := LName.AsString;
          LUserSectorInfo.FOrder := LOrder.AsInteger;
          LUserSectorInfo.FInnerCodes := LInnerCodes.AsString;
        end;
        LDataSet.Next;
      end;
    end;

    LID := nil;
    LCID := nil;
    LName := nil;
    LOrder := nil;
    LInnerCodes := nil;
    LDataSet := nil;
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
begin
  FLock.Lock;
  try
    DoUpdate;
  finally
    FLock.UnLock;
  end;
end;

function TUserSectorMgrImpl.GetCount: Integer;
begin
  Result := FRootSector.GetChildSectorCount;
end;

function TUserSectorMgrImpl.GetSector(AIndex: Integer): ISector;
begin
  Result := FRootSector.GetChildSector(AIndex);
end;

end.
