unit UserSectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSectorImpl
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
  CommonRefCounter,
  Generics.Collections;

type

  // UserSectorImpl
  TUserSectorImpl = class(TUserSector)
  private
  protected
    // UpdateLocalDB
    procedure DoUpdateLocalDB(AUpLoadValue: Integer);
  public
    FID: string;
    FCID: Integer;
    FName: string;
    FOrderNo: Integer;
    FInnerCodes: string;
    FIsUsed: Boolean;
    FOrderIndex: Integer;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISector }

    // GetName
    function GetName: string; override;
    // GetOrderNo
    function GetOrderNo: Integer; override;
    // GetInnerCodes
    function GetInnerCodes: string; override;
    // SetName
    procedure SetName(AName: string); override;
    // SetOrderNo
    procedure SetOrderNo(AOrderNo: Integer); override;
    // SetInnerCodes
    procedure SetInnerCodes(AInnerCodes: string); override;
    // Add
    procedure Add(AInnerCode: Integer); override;
    // Delete
    procedure Delete(AInnerCode: Integer); override;
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
      FID,
      FCID,
      FName,
      FOrderNo,
      FInnerCodes,
     AUpLoadValue]);
  LUserCache.ExecuteSql(LTableName, LSql);
end;

function TUserSectorImpl.GetName: string;
begin
  Result := FName;
end;

function TUserSectorImpl.GetOrderNo: Integer;
begin
  Result := FOrderNo;
end;

function TUserSectorImpl.GetInnerCodes: string;
begin
  Result := FInnerCodes;
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
      if FName <> AName then begin
        (LUserSectorMgr as IUserSectorMgrUpdate).RemoveDic(FName);
        FName := Copy(AName, 1, Length(AName));
        (LUserSectorMgr as IUserSectorMgrUpdate).AddDicUserSector(Self);
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
      if FOrderNo <> AOrderNo then begin
        FOrderNo := AOrderNo;
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
      if FInnerCodes <> AInnerCodes then begin
        if AInnerCodes <> '' then begin
          FInnerCodes := Copy(AInnerCodes, 1, Length(AInnerCodes));
        end else begin
          FInnerCodes := '';
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
      if FInnerCodes <> '' then begin
        LInnerCodes := TStringList.Create;
        try
          LInnerCodes.Delimiter := ',';
          LInnerCodes.DelimitedText := FInnerCodes;
          if LInnerCodes.IndexOf(LInnerCodeStr) < 0 then begin
            FInnerCodes := LInnerCodeStr + ',' + FInnerCodes;
            DoUpdateLocalDB(UPLOADVALUE_MODIFY);
            (LUserSectorMgr as IUserSectorMgrUpdate).AddSelfStockFlag(FOrderIndex, AInnerCode);
          end;
        finally
          LInnerCodes.Free;
        end;
      end else begin
        FInnerCodes := LInnerCodeStr;
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
        (LUserSectorMgr as IUserSectorMgrUpdate).AddSelfStockFlag(FOrderIndex, AInnerCode);
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
  if FInnerCodes = '' then Exit;

  LUserSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERSECTORMGR) as IUserSectorMgr;
  if LUserSectorMgr <> nil then begin
    LUserSectorMgr.Lock;
    try
      LInnerCodeStr := IntToStr(AInnerCode);
      LInnerCodes := TStringList.Create;
      try
        LInnerCodes.Delimiter := ',';
        LInnerCodes.DelimitedText := FInnerCodes;
        LIndex := LInnerCodes.IndexOf(LInnerCodeStr);
        if LIndex >= 0 then begin
          LInnerCodes.Delete(LIndex);
          FInnerCodes := LInnerCodes.DelimitedText;
        end;
      finally
        LInnerCodes.Free;
      end;
      if LIndex >= 0 then begin
        DoUpdateLocalDB(UPLOADVALUE_MODIFY);
        (LUserSectorMgr as IUserSectorMgrUpdate).DeleteSelfStockFlag(FOrderIndex, AInnerCode);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

end.
