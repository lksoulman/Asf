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

const

  UPLOADVALUE_MODIFY = 1;
  UPLOADVALUE_DELETE = 2;

type

  // UserSectorImpl
  TUserSectorImpl = class(TUserSector)
  private
  protected
    // LoadElements
    procedure DoLoadElements;
  public
    // ID
    FID: string;
    // CID
    FCID: Integer;
    // Name
    FName: string;
    // OrderNo
    FOrderNo: Integer;
    // InnerCodes
    FInnerCodes: string;
    // OrderIndex
    FOrderIndex: Integer;
    // IsLoadElements
    FIsLoadElements: Boolean;
    // Elements
    FElements: TArray<Integer>;

    // UpdateLocalDB
    procedure UpdateLocalDB(AUpLoadValue: Integer);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ResetValule
    procedure ResetValule;
    // GetName
    function GetName: string; override;
    // GetOrderNo
    function GetOrderNo: Integer; override;
    // GetInnerCodes
    function GetInnerCodes: string; override;
    // GetElements
    function GetElements: TArray<Integer>; override;
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

{ TUserSectorImpl }

constructor TUserSectorImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TUserSectorImpl.Destroy;
begin

  inherited;
end;

procedure TUserSectorImpl.ResetValule;
begin
  FIsLoadElements := False;
end;

procedure TUserSectorImpl.DoLoadElements;
var
  LInnerCodes: TStringList;
  LIndex, LInnerCode, LCount: Integer;
begin
  if FInnerCodes <> '' then begin
    LInnerCodes := TStringList.Create;
    try
      LCount := 0;
      LInnerCodes.DelimitedText := FInnerCodes;
      SetLength(FElements, LInnerCodes.Count);
      for LIndex := 0 to LInnerCodes.Count - 1 do begin
        LInnerCode := StrToIntDef(LInnerCodes.Strings[LIndex], 0);
        if LInnerCode <> 0 then begin
          FElements[LCount] := LInnerCode;
          Inc(LCount);
        end;
      end;
      if LCount < LInnerCodes.Count then begin
        SetLength(FElements, LCount);
      end;
    finally
      LInnerCodes.Free;
    end;
  end else begin
    SetLength(FElements, 0);
  end;
end;

procedure TUserSectorImpl.UpdateLocalDB(AUpLoadValue: Integer);
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

function TUserSectorImpl.GetElements: TArray<Integer>;
begin
  if FIsLoadElements then begin
    Result := FElements;
  end else begin
    DoLoadElements;
    FIsLoadElements := True;
    Result := FElements;
  end;
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
        (LUserSectorMgr as IUserSectorMgrUpdate).AddDic(Self);
        UpdateLocalDB(UPLOADVALUE_MODIFY);
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
        UpdateLocalDB(UPLOADVALUE_MODIFY);
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
        UpdateLocalDB(UPLOADVALUE_MODIFY);
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
            UpdateLocalDB(UPLOADVALUE_MODIFY);
          end;
        finally
          LInnerCodes.Free;
        end;
      end else begin
        FInnerCodes := LInnerCodeStr;
        UpdateLocalDB(UPLOADVALUE_MODIFY);
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
        UpdateLocalDB(UPLOADVALUE_MODIFY);
      end;
    finally
      LUserSectorMgr.UnLock;
    end;
    LUserSectorMgr := nil;
  end;
end;

end.
