unit UserSectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSector Implementation
// Author£º      lksoulman
// Date£º        2018-1-3
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Command,
  Windows,
  Classes,
  SysUtils,
  UserCache,
  UserSector,
  BaseObject,
  AppContext,
  UserSectorUpdate,
  CommonRefCounter,
  Generics.Collections;

type

  // UserSector Implementation
  TUserSectorImpl = class(TBaseInterfacedObject, IUserSector, IUserSectorUpdate)
  private
    // UserSectorInfo
    FUserSectorInfo:  TUserSectorInfo;
  protected
    // UpdateLocalDB
    procedure DoUpdateLocalDB(AUpLoadValue: Integer);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISector }

    // GetName
    function GetName: string;
    // GetOrderNo
    function GetOrderNo: Integer;
    // GetInnerCodes
    function GetInnerCodes: string;
    // SetName
    procedure SetName(AName: string);
    // SetOrderNo
    procedure SetOrderNo(AOrderNo: Integer);
    // SetInnerCodes
    procedure SetInnerCodes(AInnerCodes: string);
    // Add
    procedure Add(AInnerCode: Integer);
    // Delete
    procedure Delete(AInnerCode: Integer);

    { IUserSectorUpdate }

    // GetUserSectorInfo
    function GetUserSectorInfo: PUserSectorInfo;
    // Compare
    function CompareAssign(AUserSectorInfo: PUserSectorInfo): Boolean;

    property Name: string read GetName write SetName;
    property OrderNo: Integer read GetOrderNo write SetOrderNo;
    property InnerCodes: string read GetInnerCodes write SetInnerCodes;
    property UserSectorInfo: PUserSectorInfo read GetUserSectorInfo;
  end;

implementation

uses
  UserSectorMgr;

const

  UPLOADVALUE_MODIFY = 1;
  UPLOADVALUE_DELETE = 2;

{ TUserSectorImpl }

constructor TUserSectorImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserSectorImpl.Destroy;
begin

  inherited;
end;

procedure TUserSectorImpl.DoUpdateLocalDB(AUpLoadValue: Integer);
var
  LUserCache: IUserCache;
  LSql, LTableName: string;
begin
  if FAppContext = nil then Exit;
  LUserCache := FAppContext.FindInterface(ASF_COMMAND_ID_USERCACHE) as IUserCache;
  if LUserCache = nil then Exit;

  LTableName := 'UserSector';
  LSql := Format('INSERT OR REPLACE INTO %s VALUES (''%s'',%d,''%s'',%d,''%s'',%d)',
    [LTableName,
     FUserSectorInfo.FID,
     FUserSectorInfo.FCID,
     FUserSectorInfo.FName,
     FUserSectorInfo.FOrderNo,
     FUserSectorInfo.FInnerCodes,
     AUpLoadValue]);
  LUserCache.ExecuteSql(LTableName, LSql);
end;

function TUserSectorImpl.GetName: string;
begin
  Result := FUserSectorInfo.FName;
end;

function TUserSectorImpl.GetOrderNo: Integer;
begin
  Result := FUserSectorInfo.FOrderNo;
end;

function TUserSectorImpl.GetInnerCodes: string;
begin
  Result := FUserSectorInfo.FInnerCodes;
end;

procedure TUserSectorImpl.SetName(AName: string);
var
  LUserSectorMgr: IUserSectorMgr;
begin
  if AName = '' then Exit;

  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      if FUserSectorInfo.FName <> AName then begin
        FUserSectorInfo.FName := Copy(AName, 1, Length(AName));
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

procedure TUserSectorImpl.SetOrderNo(AOrderNo: Integer);
var
  LUserSectorMgr: IUserSectorMgr;
begin
  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      if FUserSectorInfo.FOrderNo <> AOrderNo then begin
        FUserSectorInfo.FOrderNo := AOrderNo;
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

procedure TUserSectorImpl.SetInnerCodes(AInnerCodes: string);
var
  LUserSectorMgr: IUserSectorMgr;
begin
  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      if FUserSectorInfo.FInnerCodes <> AInnerCodes then begin
        if AInnerCodes <> '' then begin
          FUserSectorInfo.FInnerCodes := Copy(AInnerCodes, 1, Length(AInnerCodes));
        end else begin
          FUserSectorInfo.FInnerCodes := '';
        end;
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
        (LUserSectorMgr as IUserSectorMgrUpdate).UpdateSelfStockFlagAll;
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

procedure TUserSectorImpl.Add(AInnerCode: Integer);
var
  LInnerCodeStr: string;
  LInnerCodes: TStringList;
  LUserSectorMgr: IUserSectorMgr;
begin
  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      LInnerCodeStr := IntToStr(AInnerCode);
      if FUserSectorInfo.FInnerCodes <> '' then begin
        LInnerCodes := TStringList.Create;
        try
          LInnerCodes.Delimiter := ',';
          LInnerCodes.DelimitedText := FUserSectorInfo.FInnerCodes;
          if LInnerCodes.IndexOf(LInnerCodeStr) < 0 then begin
            FUserSectorInfo.FInnerCodes := LInnerCodeStr + ',' + FUserSectorInfo.FInnerCodes;
            DoUpdateLocalDB(UPLOADVALUE_MODIFY);
            (LUserSectorMgr as IUserSectorMgrUpdate).AddSelfStockFlag(FUserSectorInfo.FIndex, AInnerCode);
          end;
        finally
          LInnerCodes.Free;
        end;
      end else begin
        FUserSectorInfo.FInnerCodes := LInnerCodeStr;
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
        (LUserSectorMgr as IUserSectorMgrUpdate).AddSelfStockFlag(FUserSectorInfo.FIndex, AInnerCode);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

procedure TUserSectorImpl.Delete(AInnerCode: Integer);
var
  LIndex: Integer;
  LInnerCodeStr: string;
  LInnerCodes: TStringList;
  LUserSectorMgr: IUserSectorMgr;
begin
  if FUserSectorInfo.FInnerCodes = '' then Exit;

  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      LInnerCodeStr := IntToStr(AInnerCode);
      LInnerCodes := TStringList.Create;
      try
        LInnerCodes.Delimiter := ',';
        LInnerCodes.DelimitedText := FUserSectorInfo.FInnerCodes;
        LIndex := LInnerCodes.IndexOf(LInnerCodeStr);
        if LIndex >= 0 then begin
          LInnerCodes.Delete(LIndex);
          FUserSectorInfo.FInnerCodes := LInnerCodes.DelimitedText;
        end;
      finally
        LInnerCodes.Free;
      end;
      if LIndex >= 0 then begin
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
        (LUserSectorMgr as IUserSectorMgrUpdate).DeleteSelfStockFlag(FUserSectorInfo.FIndex, AInnerCode);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

function TUserSectorImpl.GetUserSectorInfo: PUserSectorInfo;
begin
  Result := @FUserSectorInfo;
end;

function TUserSectorImpl.CompareAssign(AUserSectorInfo: PUserSectorInfo): Boolean;
begin
  Result := True;
  if AUserSectorInfo = nil then Exit;

  if (AUserSectorInfo.FID <> FUserSectorInfo.FID)
    or (AUserSectorInfo.FOrderNo <> FUserSectorInfo.FOrderNo)
    or (AUserSectorInfo.FInnerCodes <> FUserSectorInfo.FInnerCodes) then begin
    FUserSectorInfo.FID := AUserSectorInfo.FID;
    FUserSectorInfo.FOrderNo := AUserSectorInfo.FOrderNo;
    FUserSectorInfo.FInnerCodes := AUserSectorInfo.FInnerCodes;
  end;
end;

end.
